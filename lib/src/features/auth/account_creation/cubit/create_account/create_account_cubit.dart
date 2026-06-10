import 'package:customer_mobile_app/imports_bindings.dart';

part 'create_account_state.dart';
part 'create_account_cubit.freezed.dart';

class CreateAccountCubit extends Cubit<CreateAccountState> {
  CreateAccountCubit({
    required SentOtpEntity sentOtp,
    ConstantChoicesModel? constChoices,
    Option<Either<ApiException, LoginSuccessModel>>? loginSuccessModel,
  }) : super(
         CreateAccountState(
           sentOtpEntity: sentOtp,
           constChoices: constChoices,
           onboardingUser: loginSuccessModel,
         ),
       );

  // Future<void> onboardUser({
  //   required String firstName,
  //   required String lastName,
  //   required String email,
  //   required DateTime dateOfBirth,
  //   required String gender,
  //   required String emergencyContactNumber,
  //   required String profession,
  //   required String bloodGroup,
  //   required String height,
  //   required String weight,
  // }) async {
  //   if (state.onboardingUser?.isNone() ?? false) {
  //     return;
  //   }
  //   emit(state.copyWith(onboardingUser: none()));
  //   final result = await AuthRepository().onboarding(
  //     body: {
  //       'email': email,
  //       'first_name': firstName,
  //       'last_name': lastName,
  //       'otp_id': state.sentOtpEntity.id,
  //       'mobile_number': state.sentOtpEntity.mobileNumber,
  //       'process': 'registration',
  //       'source': platformSource,
  //       'user_role': userRole,
  //       'date_of_birth': dateOfBirth.format('yyyy-MM-dd'),
  //       'gender': gender,
  //       'blood_group': bloodGroup,
  //       'emergency_contact_number': emergencyContactNumber,
  //       'meta': <String, dynamic>{
  //         'height': height,
  //         'weight': weight,
  //         'profession': profession,
  //       },
  //     },
  //   );
  //   emit(state.copyWith(onboardingUser: some(result)));
  // }


  /// with out image
  // Future<void> onboardUser({
  //   required String firstName,
  //   required String lastName,
  //   required String email,
  //   XFile? image,
  // }) async {
  //   // Start button loading
  //   emit(
  //     state.copyWith(
  //       isLoading: true,
  //       onboardingUser: none(),
  //       createOrUpdateOnboarding: none(),
  //     ),
  //   );
  //   try {
  //     final result = await AuthRepository().onboarding(
  //       body: {
  //         'email': email,
  //         'first_name': firstName,
  //         'last_name': lastName,
  //         'otp_id': state.sentOtpEntity.id,
  //         'mobile_number': state.sentOtpEntity.mobileNumber,
  //         'process': 'registration',
  //         'source': platformSource,
  //         'user_role': userRole,
  //       },
  //     );
  //
  //     // Stop loader and emit result
  //     emit(
  //       state.copyWith(
  //         isLoading: false,
  //         onboardingUser: some(result),
  //         createOrUpdateOnboarding: some(result),
  //       ),
  //     );
  //   } catch (e) {
  //     // Catch unhandled exceptions and stop loader
  //     emit(
  //       state.copyWith(
  //         isLoading: false,
  //         createOrUpdateOnboarding: some(
  //           left(ApiException.unknown(msg: e.toString())),
  //         ),
  //       ),
  //     );
  //   }
  // }

  /// with image formdata
  Future<void> onboardUser({
    required String firstName,
    required String lastName,
    required String email,
    XFile? image,
  }) async {
    // Start loading
    emit(
      state.copyWith(
        isLoading: true,
        onboardingUser: none(),
        createOrUpdateOnboarding: none(),
      ),
    );

    try {
      // Prepare raw body
      final formData = FormData.fromMap({
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'otp_id': state.sentOtpEntity.id,
        'mobile_number': state.sentOtpEntity.mobileNumber,
        'process': 'registration',
        'source': platformSource,
        'user_role': userRole,
      });
      if (image != null) {
        formData.files.add(
          MapEntry(
            'profile_picture',
            await MultipartFile.fromFile(image.path, filename: image.name),
          ),
        );
      }

      final result = await AuthRepository().onboarding(body: formData);

      // Stop loader and emit result
      emit(
        state.copyWith(
          isLoading: false,
          onboardingUser: some(result),
          createOrUpdateOnboarding: some(result),
        ),
      );
    } catch (e) {
      // Catch unhandled exceptions and stop loader
      emit(
        state.copyWith(
          isLoading: false,
          createOrUpdateOnboarding: some(
            left(ApiException.unknown(msg: e.toString())),
          ),
        ),
      );
    }
  }

  Future<void> onboardingUpdate({
    required Map<String, dynamic> body,
    required int? id,
  }) async {
    // Start loader
    emit(
      state.copyWith(
        isLoading: true,
        // onboardingUser: none(),
        createOrUpdateOnboarding: none(),
      ),
    );

    try {
      final result = await AuthRepository().onboardingUpdate(
        body: body,
        id: id,
      );

      // Handle both success and failure properly
      result.fold(
        (failure) {
          // Emit error and stop loader
          emit(
            state.copyWith(
              isLoading: false,
              createOrUpdateOnboarding: some(left(failure)),
            ),
          );
        },
        (r) {
          // Emit success and stop loader
          emit(
            state.copyWith(
              isLoading: false,
              createOrUpdateOnboarding: some(right(r)),
              // onboardingUser: some(right(r)),
            ),
          );
        },
      );
    } catch (e) {
      // Catch unhandled exceptions and stop loader
      emit(
        state.copyWith(
          isLoading: false,
          createOrUpdateOnboarding: some(
            left(ApiException.unknown(msg: e.toString())),
          ),
        ),
      );
    }
  }
}
