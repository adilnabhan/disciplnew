import razorpay
from django.conf import settings
from django.apps import apps
import json

# Initialize the Razorpay client
razorpay_client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))

def create_razorpay_base_plan(membership_plan_instance):
    """
    Creates a base Razorpay Plan for a given MembershipPlan.
    This plan defines the core billing cycle.
    """
    # Get the MembershipPlan model from the app registry
    MembershipPlan = apps.get_model('fitnesscenter', 'MembershipPlan')
    
    amount_in_paise = int(membership_plan_instance.actual_price * 100)
    
    period_map = {
        MembershipPlan.MONTHLY: "monthly",
        MembershipPlan.QUARTERLY: "monthly",
        MembershipPlan.HALF_YEARLY: "monthly",
        MembershipPlan.YEARLY: "monthly",
        MembershipPlan.CUSTOM: "monthly"
    }
    
    plan_data = {
        "period": period_map.get(membership_plan_instance.package_type, "monthly"),
        "interval": 1,
        "item": {
            "name": f"{membership_plan_instance.name} ({membership_plan_instance.get_package_type_display()})",
            "amount": amount_in_paise,
            "currency": "INR",
        }
    }
    
    try:
        razorpay_plan = razorpay_client.plan.create(data=plan_data)
        membership_plan_instance.razorpay_plan_id = razorpay_plan['id']
        return True, None
    except Exception as e:
        return False, str(e)


def create_razorpay_plan(emi_plan_instance):
    """
    Creates a Razorpay Plan for an EMI option.
    """
    # # Get the MembershipPlan model from the app registry
    # EmiPlan = apps.get_model('fitnesscenter', 'EmiPlan')
    
    amount_in_paise = int(emi_plan_instance.emi_amount_per_cycle * 100)
    
    plan_data = {
        "period": "monthly",
        "interval": 1,
        "item": {
            "name": f"{emi_plan_instance.membership_plan.name} - {emi_plan_instance.emi_name}",
            "amount": amount_in_paise,
            "currency": "INR",
        }
    }
    
    try:
        razorpay_plan = razorpay_client.plan.create(data=plan_data)
        emi_plan_instance.razorpay_plan_id = razorpay_plan['id']
        return True, None
    except Exception as e:
        return False, str(e)