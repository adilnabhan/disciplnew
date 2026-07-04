import requests
from django.conf import settings


def get_distance_from_google(origin: str, destination: str) -> dict | None:
    """
    Get distance and duration from Google Distance Matrix API.

    Args:
        origin (str): User location in 'lat,long' format.
        destination (str): Gym location in 'lat,long' format.

    Returns:
        dict: {
            'distance_km': float,
            'duration_text': str
        } or None if failed.
    """
    try:
        response = requests.get(
            'https://maps.googleapis.com/maps/api/distancematrix/json',
            params={
                'origins': origin,
                'destinations': destination,
                'key': settings.GOOGLE_API_KEY,
                'units': 'metric'
            }
        )
        print(response, 'RESPONSE')
        result = response.json()
        if result.get('rows'):
            element = result['rows'][0]['elements'][0]
            print(element, 'ELEMNTS')
            if element.get('status') == 'OK':
                print('OK')
                return {
                    'distance_km': element['distance']['value'] / 1000,
                    'duration_text': element['duration']['text']
                }
    except Exception as e:
        print(f"[Google API Error] {e}")
    return None
