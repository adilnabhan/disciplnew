import razorpay
import logging
from django.conf import settings
from apps.fitnesscenter.models import BankAccountDetails

logger = logging.getLogger(__name__)


def sync_razorpay_status_if_needed(bank_details: BankAccountDetails):
    """
    Sync Razorpay account activation status.

    This function is intentionally called ONLY after bank details update.
    No throttling or background checks.
    """

    # Guard: only check pending accounts
    if (
        not bank_details.razorpay_account_id or
        bank_details.razorpay_account_status != BankAccountDetails.VERIFICATION_PENDING
    ):
        return bank_details

    try:
        client = razorpay.Client(
            auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
        )

        rp_account = client.account.fetch(bank_details.razorpay_account_id)
        activation_status = rp_account.get("activation_status")

        if activation_status == "activated":
            bank_details.razorpay_account_status = BankAccountDetails.ACTIVATED
            bank_details.razorpay_error_details = None

        elif activation_status == "rejected":
            bank_details.razorpay_account_status = BankAccountDetails.VERIFICATION_FAILED
            bank_details.razorpay_error_details = "rejected"

        # created / under_review → no change

        bank_details.save(update_fields=[
            "razorpay_account_status",
            "razorpay_error_details"
        ])

    except Exception as e:
        logger.error(
            f"Razorpay status sync failed for account "
            f"{bank_details.razorpay_account_id}: {e}"
        )

    return bank_details