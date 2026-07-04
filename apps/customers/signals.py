
class CustomerRegistrationService:
    @staticmethod
    def update_customer(user, meta):
        if not user or not hasattr(user, 'customer'):
            return

        customer = user.customer
        customer.height = meta.get('height')
        customer.weight = meta.get('weight')
        customer.profession = meta.get('profession')
        customer.emergency_contact_name = meta.get('emergency_contact_name')
        customer.emergency_contact_number = meta.get('emergency_contact_number')
        customer.save()
