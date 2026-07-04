import os
import requests
from django.core.files.base import ContentFile
from urllib.parse import urlparse

def resolve_image_file(image_val, search_dirs=None):
    """
    Given an image value (URL or local filename/path), resolves and returns
    a tuple of (filename, ContentFile) or (None, None).
    """
    if not image_val:
        return None, None
        
    image_val = str(image_val).strip()
    if not image_val:
        return None, None

    # 1. Handle Remote URL
    if image_val.startswith(('http://', 'https://')):
        try:
            response = requests.get(image_val, timeout=10)
            if response.status_code == 200:
                parsed_url = urlparse(image_val)
                filename = os.path.basename(parsed_url.path)
                if not filename or '.' not in filename:
                    filename = 'downloaded_image.jpg'
                cf = ContentFile(response.content)
                cf.name = filename
                return filename, cf
        except Exception as e:
            print(f"Error downloading image from {image_val}: {e}")
            return None, None

    # 2. Handle Local File
    if not search_dirs:
        search_dirs = []
    
    # Standard directories to search in
    standard_dirs = ['public', 'media', '.']
    # Merge search_dirs first, then standard_dirs
    all_search_dirs = list(search_dirs) + standard_dirs

    # First check if the path is absolute and exists
    if os.path.isabs(image_val) and os.path.exists(image_val):
        try:
            with open(image_val, 'rb') as f:
                filename = os.path.basename(image_val)
                cf = ContentFile(f.read())
                cf.name = filename
                return filename, cf
        except Exception as e:
            print(f"Error opening absolute path {image_val}: {e}")

    # Now search in specified directories
    for directory in all_search_dirs:
        if not directory:
            continue
        possible_path = os.path.join(directory, image_val)
        if os.path.exists(possible_path):
            try:
                with open(possible_path, 'rb') as f:
                    filename = os.path.basename(possible_path)
                    cf = ContentFile(f.read())
                    cf.name = filename
                    return filename, cf
            except Exception as e:
                print(f"Error opening local path {possible_path}: {e}")
                
    return None, None
