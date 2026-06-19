import 'package:customer_mobile_app/imports_bindings.dart';

///* This class contains Api uris
@immutable
final class ApiUris {
  ///* BASE URL
  static const _baseUrlEnv = String.fromEnvironment('baseUrl');
  static const _baseUrl =
      _baseUrlEnv == '' ? 'https://discipl-backend.onrender.com' : _baseUrlEnv;
  static const _v1 = '$_baseUrl/api/v1/';

  ///============================= AUTH =============================\\\
  static const sentOtp = '${_v1}user/send-otp/';
  static const loginWithOtp = '${_v1}user/otp/verify/';
  static const verifyOtp = '${_v1}user/otp/verification/registration/';
  static const tokenRefresh = '${_v1}user/token/refresh/';
  static const onboarding = '${_v1}user/onboarding/';
  static String onboardingUpdate(int id) => '${_v1}customer/manage/$id/update/';
  static const logout = '${_v1}user/logout/';
  // static const tokenRefresh = '${_v1}user/token/refresh/';
  static const constantChoices = '${_v1}customer/constant-choices';

  ///============================= Customer =============================\\\
  static String customerDetails(int id) => '${_v1}customer/manage/$id/';
  static const updateCustomerProfile = '${_v1}customer/manage/profile/health/';

  ///============================= Home =============================\\\
  static const home = '${_v1}customer/customer-homepage/';

  ///============================= Payment =============================\\\
  static const paymentHistory = '${_v1}customer/payment-history/';
  static const paymentDetailsHistory = '${_v1}customer/payment-detail-history/';

  ///============================= Membership =============================\\\
  static String activeMembership(int id) =>
      '${_v1}customer/manage/$id/active-membership/';
  static const allMemberships = '${_v1}customer/membership-org/';

  ///============================= Subscription =============================\\\
  static const initiateRazorpayOrder =
      '${_v1}subscription/customer/create-subscription/';
  static const checkPaymentStatus = '${_v1}subscription/payment/status/';

  ///============================= Fitness Center =============================\\\
  static String fitnesscenterDetails(int id) => '${_v1}fitnesscenter/gym/$id/';

  static String fitnesscenterMembershipPlans(int id) =>
      '${_v1}customer/membership-plans/$id/';
  static const fitnesscenterCategories = '${_v1}fitnesscenter/categories/';
  static const listFitnesscenter = '${_v1}customer/nearest/fitnesscenter/';
  static const listAllFitnesscenter = '${_v1}fitnesscenter/gym/list/';

  ///============================= Reviews =============================\\\
  static const addReview = '${_v1}customer/reviews/';

  static String updateReview(int id) => '${_v1}customer/reviews/$id/';
  static const customerPostedReviews = '${_v1}customer/reviews/';

  static String deleteReview(int id) => '${_v1}customer/reviews/$id/';

  static String fitnessCenterReviews(int id) =>
      '${_v1}fitnesscenter/organization/$id/reviews/';

  ///============================= Workout =============================\\\
  static const exercises = '${_v1}customer/exercises/';
  static const exerciseDetail = '${_v1}customer/exercises/detail/';
  static String exerciseDetailById(int id) => '${_v1}customer/exercises/$id/';
  static const muscleGroups = '${_v1}trainer/muscle-groups/';
  static const equipment = '${_v1}trainer/equipment/';
  static const exerciseTypes = '${_v1}trainer/exercise-types/';
  static const activeSession = '${_v1}customer/sessions/active/';
  static const activeSessionExercises =
      '${_v1}customer/sessions/active/exercises/';
  static const startSession = '${_v1}customer/sessions/start/';
  static String sessionDetails(int id) => '${_v1}customer/sessions/$id/';
  static String addSetToLog(int logId) =>
      '${_v1}customer/workout-logs/$logId/sets/';
  static const workoutLog = '${_v1}customer/workout-log/';
  static const presets = '${_v1}customer/my-plans/';
  static String presetDetail(int id) => '${_v1}customer/my-plans/$id/';

  static const loginAsGuest = '${_v1}user/login/guest/';
}
