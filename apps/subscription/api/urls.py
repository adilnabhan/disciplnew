from django.urls import path, include

from apps.subscription.api.views import CheckPaymentStatusAPIView, CreateRazorpayCustomerOrderAPIView, CreateRazorpayOrderAPIView, CreateTrainerOrderAPIView, CustomerSubscriptionCreateAPIView, get_discipl_subscription_plans, razorpay_checkout, razorpay_webhook


urlpatterns = [
    path('discipl-subscription-plans/', get_discipl_subscription_plans, name='all-discipl-subscription_plans'),
    path('create-order/', CreateRazorpayOrderAPIView.as_view(), name='create-razorpay-order'),
    path('trainer/create-order/', CreateTrainerOrderAPIView.as_view(), name='create-trainer-razorpay-order'),
    path('razorpay/checkout/<str:order_id>/', razorpay_checkout, name='razorpay_checkout'),

    path('webhook/', razorpay_webhook, name='razorpay-webhook'),
    path('payment/status/', CheckPaymentStatusAPIView.as_view(), name='check-payment-status'),
    path('customer/', include([
        path('create-order/', CreateRazorpayCustomerOrderAPIView.as_view(), name='create-razorpay-customer-order'),
        path('create-subscription/', CustomerSubscriptionCreateAPIView.as_view(), name='create-razorpay-customer-subscription'),
        # path('webhook/', customer_razorpay_webhook, name='razorpay-webhook'),
        # path('payment/status/', CheckCustomerPaymentStatusAPIView.as_view(), name='check-customer-payment-status'),
    ]))
    
]