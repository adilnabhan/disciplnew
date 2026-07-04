import razorpay
import logging
from django.conf import settings
from razorpay.errors import BadRequestError, GatewayError, ServerError
from rest_framework.exceptions import ValidationError
from django.utils import timezone
from apps.fitnesscenter.models import BankAccountDetails

logger = logging.getLogger(__name__)
def create_trainer_linked_account(organization, bank_details):
    client = razorpay.Client(auth=(
        settings.RAZORPAY_KEY_ID,
        settings.RAZORPAY_KEY_SECRET
    ))

    # If Razorpay account already exists, update settlement details only
    if bank_details.razorpay_account_id and bank_details.razorpay_product_id:
        try:
            logger.info(f"Updating existing Razorpay account {bank_details.razorpay_account_id} for org {organization.id}")
            clean_phone = organization.phone_number.replace('+', '').replace(' ', '').replace('-', '')
            account_ref= f'dcrefid-{clean_phone}'
            try:
                accounts = client.account.all(data={
                            "count": 100,
                            "skip": 0
                        })
                print(accounts)
            except Exception as e:
                print("Error while fetching accounts:")
                print(type(e))
                print(str(e))
                print("Args:", e.args)
            # Update settlement details (bank account info)
            updated_product = client.product.edit(
                bank_details.razorpay_account_id,
                bank_details.razorpay_product_id,
                {
                    "settlements": {
                        "account_number": bank_details.account_number,
                        "ifsc_code": bank_details.ifsc_code,
                        "beneficiary_name": bank_details.account_holder_name
                    },
                    "tnc_accepted": True
                }
            )

            logger.info(f"Successfully updated Razorpay account for org {organization.id}, activation_status: {updated_product.get('activation_status')}")
            print(f"Successfully updated Razorpay account for org {organization.id}, activation_status: {updated_product.get('activation_status')}")
            status = updated_product.get('activation_status')
            return {
                "account_id": bank_details.razorpay_account_id,
                "product_id": bank_details.razorpay_product_id,
                "activation_status": updated_product.get("activation_status"),
                "activated_at": timezone.now() if status == "activated" else None
            }

        except BadRequestError as e:
            logger.error(f"Razorpay BadRequestError updating account for org {organization.id}: {str(e)}")
            raise ValidationError({
                "razorpay_error": str(e)
            })
        except (GatewayError, ServerError) as e:
            logger.error(f"Razorpay gateway/server error updating account for org {organization.id}: {str(e)}")
            raise ValidationError({
                "razorpay_error": f"Payment gateway error: {str(e)}"
            })
        except ConnectionError as e:
            logger.error(f"Connection error updating account for org {organization.id}: {str(e)}")
            raise ValidationError({
                "razorpay_error": f"Network error: {str(e)}"
            })
        except Exception as e:
            logger.error(f"Unexpected error updating Razorpay account for org {organization.id}: {str(e)}")
            raise ValidationError({
                "razorpay_error": f"Failed to update payment account: {str(e)}"
            })

    # Create new Razorpay account if none exists
    try:
        # Clean phone number for reference_id (remove + and other special chars)
        clean_phone = organization.phone_number.replace('+', '').replace(' ', '').replace('-', '')

        payload = {
            "email": organization.email,
            "phone": clean_phone,
            "type": "route",
            "reference_id": f'dcrefid-{clean_phone}',
            "legal_business_name": organization.name,
            "business_type": bank_details.business_type or "proprietorship",
            "profile": {
                "category": "healthcare",
                "subcategory": "fitness",
                "addresses": {
                    "registered": {
                        "street1": organization.location.building_name,
                        "street2": organization.location.street,
                        "city": organization.location.city,
                        "state": organization.location.state,
                        "postal_code": organization.location.pin_code,
                        "country": "IN"
                    }
                }
            }
        }
        print("Creating Razorpay Route account with payload:", payload)
        try:
            account = client.account.create(payload)
            bank_details.razorpay_account_id = account["id"]
            bank_details.razorpay_account_status = BankAccountDetails.VERIFICATION_PENDING
            bank_details.save(update_fields=[
                "razorpay_account_id",
                "razorpay_account_status"
            ])
        except BadRequestError as e:
            error_message = str(e).lower()
            if "reference_id" in error_message and "exists" in error_message:
                logger.warning("Account already exists in Razorpay. Fetching using reference_id.")
                accounts = client.account.all({
                    "reference_id": payload["reference_id"]
                })

                if accounts.get("items"):
                    existing_account = accounts["items"][0]

                    bank_details.razorpay_account_id = existing_account["id"]
                    bank_details.razorpay_account_status = existing_account.get("status")
                    bank_details.save(update_fields=[
                        "razorpay_account_id",
                        "razorpay_account_status"
                    ])
                else:
                    print(e.args)
                    raise ValidationError("Account exists but could not be fetched.")
            else:
                print(e.args)
                logger.error(f"Unexpected error creating account: {str(e)}")
                raise ValidationError({
                    "razorpay_error": "Failed to create payment account."
                })

        stake_payload = {
            "name": organization.name,
            "email": organization.email,
            "relationship": {
                "director": False,
                "executive": True
            },
            "addresses": {
                "residential": {
                    "street": organization.location.building_name if organization.location else "",
                    "city": organization.location.city if organization.location else "",
                    "state": organization.location.state if organization.location else "",
                    "postal_code": organization.location.pin_code if organization.location else "",
                    "country": "IN"
                }
            }
        }

        # Add PAN only if available
        if bank_details.pan_number:
            stake_payload["kyc"] = {
                "pan": bank_details.pan_number
            }
        
        
        try:
            account_id = bank_details.razorpay_account_id
            if bank_details.razorpay_stakeholder_id:
                stake_holder_id = bank_details.razorpay_stakeholder_id
                client.stakeholder.edit(account_id, stake_holder_id, {
                    "relationship": {
                        "director": False,
                        "executive": True
                    }
                })
            else:
                stake_response = client.stakeholder.create(
                    account_id, stake_payload
                )
                bank_details.razorpay_stakeholder_id = stake_response["id"]
                bank_details.save(update_fields=["razorpay_stakeholder_id"])
                print("Created stakeholder:", stake_response)
        except BadRequestError as e:
            error_message = str(e).lower()
            if "already exists" in error_message:
                logger.warning(
                    f"Stakeholder already exists for account {account_id}. Fetching existing stakeholder."
                )

                stakeholders = client.stakeholder.all(account_id)
                items = stakeholders.get("items", [])

                if items:
                    existing_stakeholder = items[0]

                    bank_details.razorpay_stakeholder_id = existing_stakeholder["id"]
                    bank_details.save(update_fields=["razorpay_stakeholder_id"])
                else:
                    print(e.args)
                    raise ValidationError("Stakeholder exists but could not be fetched.")
            else:
                print(e.args)
                logger.error(f"Unexpected error creating stakeholder: {str(e)}")
                raise ValidationError({
                    "razorpay_error": "Failed to create stakeholder."
                })
                
        account_id = bank_details.razorpay_account_id
        try:
            product_response = client.product.requestProductConfiguration(
                account_id,
                {
                    "product_name": "route",
                    "tnc_accepted": True,
                })
            product_id = product_response["id"]
            bank_details.razorpay_product_id = product_id
            bank_details.save(update_fields=["razorpay_product_id"])
        except BadRequestError as e:
            error_message = str(e).lower()

            if "already exists" in error_message or "product already requested" in error_message:
                logger.warning(
                    f"Product already exists for account {account_id}. Fetching existing product."
                )

                products = client.product.all(account_id)
                items = products.get("items", [])

                if not items:
                    print(e.args)
                    raise ValidationError("Product exists but could not be fetched.")

                existing_product = next(
                    (p for p in items if p.get("product_name") == "route"),
                    items[0]
                )

                product_id = existing_product["id"]

                bank_details.razorpay_product_id = product_id
                bank_details.save(update_fields=["razorpay_product_id"])
                product_response = existing_product

            else:
                print(e.args)
                logger.error(f"Unexpected product creation error: {str(e)}")
                raise ValidationError({
                    "razorpay_error": str(e)
                })
        
        account_id = bank_details.razorpay_account_id
        updated_product = client.product.edit(account_id,bank_details.razorpay_product_id, {
            "settlements": {
                "account_number": bank_details.account_number,
                "ifsc_code": bank_details.ifsc_code,
                "beneficiary_name": bank_details.account_holder_name
            },
            "tnc_accepted": True
        })

        status = updated_product.get('activation_status')


        logger.info(f"Successfully created Razorpay account for org {organization.id}, activation_status: {updated_product.get('activation_status')}")
        # return {
        #     "account_id": account["id"],
        #     "product_id": product_response["id"],
        #     "activation_status": product_response.get("activation_status"),
        # }
        return {
            "account_id": account_id,
            "product_id": bank_details.razorpay_product_id,
            "activation_status": updated_product.get("activation_status"),
            "razorpay_account_status": status,
            "razorpay_stakeholder_id": bank_details.razorpay_stakeholder_id,
            "activation_status": updated_product.get("activation_status"),
            "activated_at": timezone.now() if status == "activated" else None,
        }

    except BadRequestError as e:
        logger.error(f"Razorpay BadRequestError for org {organization.id}: {str(e)}")
        print(e.args)
        raise ValidationError({
            "razorpay_error": str(e)
        })
    except (GatewayError, ServerError) as e:
        print(e.args)
        logger.error(f"Razorpay gateway/server error for org {organization.id}: {str(e)}")
        raise ValidationError({
            "razorpay_error": f"Payment gateway error: {str(e)}"
        })
    except ConnectionError as e:
        print(e.args)
        logger.error(f"Connection error for org {organization.id}: {str(e)}")
        raise ValidationError({
            "razorpay_error": f"Network error: {str(e)}"
        })
    except Exception as e:
        print(e.args)
        logger.error(f"Unexpected error creating Razorpay account for org {organization.id}: {str(e)}")
        raise ValidationError({
            "razorpay_error": f"Failed to create payment account: {str(e)}"
        })
