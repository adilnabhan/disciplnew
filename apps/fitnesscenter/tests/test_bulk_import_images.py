import os
import shutil
import tempfile
import openpyxl
from django.test import TestCase, override_settings
from django.core.management import call_command
from unittest.mock import patch, MagicMock

from apps.fitnesscenter.models import Organization, OrganizationPhoto

@override_settings(MEDIA_ROOT=os.path.join(tempfile.gettempdir(), 'test_media'))
class BulkImportImagesTests(TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.image_dir = os.path.join(self.temp_dir, 'images')
        os.makedirs(self.image_dir, exist_ok=True)
        
        # Create dummy image files
        self.dummy_image_name = 'test_logo.jpg'
        self.dummy_image_path = os.path.join(self.image_dir, self.dummy_image_name)
        with open(self.dummy_image_path, 'wb') as f:
            f.write(b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR...')  # Dummy image bytes
            
        self.dummy_photo_name = 'gallery_photo.jpg'
        self.dummy_photo_path = os.path.join(self.image_dir, self.dummy_photo_name)
        with open(self.dummy_photo_path, 'wb') as f:
            f.write(b'dummy bytes')

        # Create temporary excel sheet
        self.excel_path = os.path.join(self.temp_dir, 'test_gyms.xlsx')
        wb = openpyxl.Workbook()
        ws = wb.active
        
        # Write headers
        headers = [
            'name', 'email', 'phone_number', 'description', 'categories', 'amenities',
            'city', 'state', 'building_name', 'street', 'pin_code', 'latitude', 'longitude',
            'logo', 'photos'
        ]
        ws.append(headers)
        
        # Write local image row
        ws.append([
            'Test Gym Alpha', 'alpha@gym.com', '1234567890', 'A cool gym', 'Gym', 'Parking',
            'Kochi', 'Kerala', 'Building Alpha', 'Street Alpha', '682001', 9.98, 76.28,
            self.dummy_image_name, self.dummy_photo_name
        ])
        
        # Write URL image row
        ws.append([
            'Test Gym Beta', 'beta@gym.com', '0987654321', 'Another cool gym', 'Gym', 'Parking',
            'Kochi', 'Kerala', 'Building Beta', 'Street Beta', '682002', 9.99, 76.29,
            'https://example.com/beta_logo.jpg', 'https://example.com/beta_photo.jpg'
        ])
        
        wb.save(self.excel_path)

    def tearDown(self):
        shutil.rmtree(self.temp_dir, ignore_errors=True)
        media_root = os.path.join(tempfile.gettempdir(), 'test_media')
        shutil.rmtree(media_root, ignore_errors=True)

    @patch('requests.get')
    def test_import_gyms_command_with_images(self, mock_get):
        # Mock successful download of remote logo/photo
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.content = b'mocked download content'
        mock_get.return_value = mock_response

        # Execute management command
        call_command('import_gyms', file=self.excel_path, image_dir=self.image_dir)

        # Check Alpha Gym (local images)
        alpha_org = Organization.objects.get(name='Test Gym Alpha')
        self.assertTrue(alpha_org.logo.name.endswith('test_logo.jpg'))
        self.assertEqual(alpha_org.photos.count(), 1)
        self.assertTrue(alpha_org.photos.first().image.name.endswith('gallery_photo.jpg'))

        # Check Beta Gym (URL images)
        beta_org = Organization.objects.get(name='Test Gym Beta')
        self.assertTrue(beta_org.logo.name.endswith('beta_logo.jpg'))
        self.assertEqual(beta_org.photos.count(), 1)
        self.assertTrue(beta_org.photos.first().image.name.endswith('beta_photo.jpg'))
        mock_get.assert_any_call('https://example.com/beta_logo.jpg', timeout=10)
        mock_get.assert_any_call('https://example.com/beta_photo.jpg', timeout=10)

    @patch('requests.get')
    def test_organization_resource_import_with_images(self, mock_get):
        # Mock successful download
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.content = b'mocked download content'
        mock_get.return_value = mock_response

        from apps.fitnesscenter.admin import OrganizationResource
        
        resource = OrganizationResource()
        row_alpha = {
            'name': 'Resource Gym Alpha',
            'email': 'res_alpha@gym.com',
            'phone_number': '1111111111',
            'logo': 'https://example.com/res_logo.jpg',
            'photos': 'https://example.com/res_photo1.jpg, https://example.com/res_photo2.jpg'
        }
        
        org = Organization.objects.create(
            name='Resource Gym Alpha',
            email='res_alpha@gym.com',
            phone_number='1111111111'
        )
        
        # Mock resolve_image_file lookup path to find our local file in the setup
        with patch('apps.fitnesscenter.image_utils.resolve_image_file') as mock_resolve:
            # First call (logo) returns mock download content
            from django.core.files.base import ContentFile
            mock_resolve.side_effect = [
                ('res_logo.jpg', ContentFile(b'logo content')),
                ('res_photo1.jpg', ContentFile(b'photo 1 content')),
                ('res_photo2.jpg', ContentFile(b'photo 2 content')),
            ]
            
            resource.after_save_instance(org, row_alpha, dry_run=False)
            
            org.refresh_from_db()
            self.assertTrue(org.logo.name.endswith('res_logo.jpg'))
            self.assertEqual(org.photos.count(), 2)
            photo_names = [p.image.name for p in org.photos.all()]
            self.assertTrue(any(name.endswith('res_photo1.jpg') for name in photo_names))
            self.assertTrue(any(name.endswith('res_photo2.jpg') for name in photo_names))
