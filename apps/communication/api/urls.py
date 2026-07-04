from django.urls import path
from apps.communication.api.views import (
    DeviceTokenRegisterView, DeviceTokenDeleteView,
    # Credit APIs
    CreditBalanceView, CreditPurchaseView, CreditTransactionListView,
    # Template APIs
    WhatsAppTemplateListCreateView, WhatsAppTemplateDetailView,
    # Automation Rule APIs
    AutomationRuleListCreateView, AutomationRuleDetailView, AutomationRuleToggleView,
    # Campaign APIs
    CampaignSendView,
    # Message Queue & Analytics
    MessageQueueListView, MessageAnalyticsView,
)

urlpatterns = [
    # Device tokens (existing)
    path('device-token/register/', DeviceTokenRegisterView.as_view(), name='device-token-register'),
    path('device-token/delete/', DeviceTokenDeleteView.as_view(), name='device-token-delete'),

    # Credit management
    path('credits/balance/', CreditBalanceView.as_view(), name='credit-balance'),
    path('credits/purchase/', CreditPurchaseView.as_view(), name='credit-purchase'),
    path('credits/transactions/', CreditTransactionListView.as_view(), name='credit-transactions'),

    # WhatsApp templates
    path('templates/', WhatsAppTemplateListCreateView.as_view(), name='template-list-create'),
    path('templates/<int:pk>/', WhatsAppTemplateDetailView.as_view(), name='template-detail'),

    # Automation rules
    path('automation-rules/', AutomationRuleListCreateView.as_view(), name='automation-rule-list-create'),
    path('automation-rules/<int:pk>/', AutomationRuleDetailView.as_view(), name='automation-rule-detail'),
    path('automation-rules/<int:pk>/toggle/', AutomationRuleToggleView.as_view(), name='automation-rule-toggle'),

    # Campaigns
    path('campaigns/send/', CampaignSendView.as_view(), name='campaign-send'),

    # Message queue & analytics
    path('messages/', MessageQueueListView.as_view(), name='message-queue-list'),
    path('analytics/', MessageAnalyticsView.as_view(), name='message-analytics'),
]
