from django.core.management.base import BaseCommand
import razorpay
from django.conf import settings
from apps.fitnesscenter.models import BankAccountDetails


class Command(BaseCommand):
    help = "Sync Razorpay account activation status"

    def handle(self, *args, **options):
        client = razorpay.Client(
            auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
        )

        pending_accounts = BankAccountDetails.objects.filter(
            razorpay_account_status=BankAccountDetails.VERIFICATION_PENDING,
            razorpay_account_id__isnull=False
        )

        self.stdout.write(
            f"Found {pending_accounts.count()} pending Razorpay accounts"
        )

        for bank_details in pending_accounts:
            try:
                rp_account = client.account.fetch(
                    bank_details.razorpay_account_id
                )

                status = rp_account.get("activation_status") or rp_account.get("status")

                if status == "activated":
                    bank_details.razorpay_account_status = (
                        BankAccountDetails.ACTIVATED
                    )
                    bank_details.razorpay_error_details = None

                elif status == "rejected":
                    bank_details.razorpay_account_status = (
                        BankAccountDetails.VERIFICATION_FAILED
                    )
                    bank_details.razorpay_error_details = "rejected"

                bank_details.save(update_fields=[
                    "razorpay_account_status",
                    "razorpay_error_details",
                ])

                self.stdout.write(
                    f"Synced account {bank_details.razorpay_account_id} → {status}"
                )

            except Exception as e:
                self.stderr.write(
                    f"Error syncing {bank_details.razorpay_account_id}: {str(e)}"
                )