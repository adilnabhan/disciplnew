import 'package:customer_mobile_app/imports_bindings.dart';

///* This class contains Api uris
@immutable
final class ApiUris {
  ///* BASE URL
  static const _baseUrlEnv = String.fromEnvironment('baseUrl');
  static final _baseUrl = _baseUrlEnv == ''
      ? 'https://discipl-backend.onrender.com'
      : (_baseUrlEnv.endsWith('/')
          ? _baseUrlEnv.substring(0, _baseUrlEnv.length - 1)
          : _baseUrlEnv);
  static final _v1 = '$_baseUrl/api/v1/';

  ///============================= AUTH =============================\\\
  static final sentOtp = '${_v1}user/send-otp/';
  static final loginWithOtp = '${_v1}user/otp/verify/';
  static final verifyOtp = '${_v1}user/otp/verification/registration/';
  static final tokenRefresh = '${_v1}user/token/refresh/';
  static final onboarding = '${_v1}user/onboarding/';
  static String onboardingUpdate(int id) => '${_v1}customer/manage/$id/update/';
  static final logout = '${_v1}user/logout/';
  // static final tokenRefresh = '${_v1}user/token/refresh/';
  static final constantChoices = '${_v1}customer/constant-choices';

  ///============================= Customer =============================\\\
  static String customerDetails(int id) => '${_v1}customer/manage/$id/';
  static final updateCustomerProfile = '${_v1}customer/manage/profile/health/';

  ///============================= Home =============================\\\
  static final home = '${_v1}customer/customer-homepage/';

  ///============================= Payment =============================\\\
  static final paymentHistory = '${_v1}customer/payment-history/';
  static final paymentDetailsHistory = '${_v1}customer/payment-detail-history/';

  ///============================= Membership =============================\\\
  static String activeMembership(int id) =>
      '${_v1}customer/manage/$id/active-membership/';
  static final allMemberships = '${_v1}customer/membership-org/';

  ///============================= Subscription =============================\\\
  static final initiateRazorpayOrder =
      '${_v1}subscription/customer/create-subscription/';
  static final checkPaymentStatus = '${_v1}subscription/payment/status/';

  ///============================= Fitness Center =============================\\\
  static String fitnesscenterDetails(int id) => '${_v1}fitnesscenter/gym/$id/';

  static String fitnesscenterMembershipPlans(int id) =>
      '${_v1}customer/membership-plans/$id/';
  static final fitnesscenterCategories = '${_v1}fitnesscenter/categories/';
  static final listFitnesscenter = '${_v1}customer/nearest/fitnesscenter/';
  static final listAllFitnesscenter = '${_v1}fitnesscenter/gym/list/';

  ///============================= Reviews =============================\\\
  static final addReview = '${_v1}customer/reviews/';

  static String updateReview(int id) => '${_v1}customer/reviews/$id/';
  static final customerPostedReviews = '${_v1}customer/reviews/';

  static String deleteReview(int id) => '${_v1}customer/reviews/$id/';

  static String fitnessCenterReviews(int id) =>
      '${_v1}fitnesscenter/organization/$id/reviews/';

  ///============================= Workout =============================\\\
  static final exercises = '${_v1}customer/exercises/';
  static final exerciseDetail = '${_v1}customer/exercises/detail/';
  static String exerciseDetailById(int id) => '${_v1}customer/exercises/$id/';
  static final muscleGroups = '${_v1}trainer/muscle-groups/';
  static final equipment = '${_v1}trainer/equipment/';
  static final exerciseTypes = '${_v1}trainer/exercise-types/';
  static final activeSession = '${_v1}customer/sessions/active/';
  static final activeSessionExercises =
      '${_v1}customer/sessions/active/exercises/';
  static final startSession = '${_v1}customer/sessions/start/';
  static String sessionDetails(int id) => '${_v1}customer/sessions/$id/';
  static String addSetToLog(int logId) =>
      '${_v1}customer/workout-logs/$logId/sets/';
  static String updateSetLog(int setLogId) =>
      '${_v1}customer/set-logs/$setLogId/';
  static final workoutLog = '${_v1}customer/workout-log/';
  static final restDay = '${_v1}customer/sessions/rest-day/';
  static final presets = '${_v1}customer/presets/';
  static String presetDetail(int id) => '${_v1}customer/presets/$id/';

  static final loginAsGuest = '${_v1}user/login/guest/';

  ///============================= Nutrition & Social =============================\\\
  static final nutritionGoals = '${_v1}customer/calorie-summary/';
  static final foodSearch = '${_v1}customer/nutrition/foods/search/';
  static final foodLog = '${_v1}customer/food-log/';
  static String foodLogDelete(int id) => '${_v1}customer/food-log/$id/';
  static final waterLog = '${_v1}customer/water-log/';
  static final scoreboard = '${_v1}social/scoreboard/';
  static final socialDashboard = '${_v1}social/dashboard/';
  static final notifications = '${_v1}customer/notifications/';

  ///============================= Partners & QR Perks =============================\\\
  static final partnerMyQr = '${_v1}partners/my-qr/';
  static final partnerMerchants = '${_v1}partners/';
  static String partnerMerchantDetail(int id) => '${_v1}partners/$id/';
  static final partnerMyTransactions = '${_v1}partners/my-transactions/';
  static final partnerRedeemPoints = '${_v1}partners/redeem-points/';
  static final partnerMyVouchers = '${_v1}partners/my-vouchers/';

  ///============================= Marathon & Events =============================\\\
  static final marathonInfo = '${_v1}customer/marathon/info/';
  static final marathonValidateCoupon = '${_v1}customer/marathon/validate-coupon/';
  static final marathonCreateOrder = '${_v1}customer/marathon/create-order/';
  static final marathonVerifyPayment = '${_v1}customer/marathon/verify-payment/';
  static final marathonMyRegistrations = '${_v1}customer/marathon/my-registrations/';
}


