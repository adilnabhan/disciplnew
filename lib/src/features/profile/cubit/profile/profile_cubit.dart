import 'package:customer_mobile_app/imports_bindings.dart';

part 'profile_state.dart';
part 'profile_cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  Future<void> fetchCustomerDetails() async {
    emit(state.copyWith(customerDetails: none()));
    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          customerDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }
    final response = await CustomerDetailsRepository().customerDetails(id: id);
    emit(state.copyWith(customerDetails: some(response)));
  }

  // Future<void> updateProfileDetails({
  //   required String firstName,
  //   required String lastName,
  //   required String email,
  //   required DateTime dateOfBirth,
  //   required String gender,
  //   required String profession,
  //   String? emergencyContactNumber,
  // }) async {
  //   if (state.updateProfileDetails?.isNone() ?? false) {
  //     return;
  //   }
  //   emit(state.copyWith(updateProfileDetails: none()));
  //   final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
  //   if (id == null) {
  //     emit(
  //       state.copyWith(
  //         updateProfileDetails: some(left(const ApiException.unknown())),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final body = {
  //     'first_name': firstName,
  //     'last_name': lastName,
  //     'email': email,
  //     'date_of_birth':
  //         dateOfBirth
  //             .toIso8601String()
  //             .split('T')
  //             .first, // Format as yyyy-MM-dd
  //     'gender': gender.toLowerCase(),
  //     'profession': profession,
  //   };
  //
  //   // Only include emergency contact if provided
  //   if (emergencyContactNumber != null && emergencyContactNumber.isNotEmpty) {
  //     body['emergency_contact_number'] = emergencyContactNumber;
  //   }
  //
  //   final response = await CustomerDetailsRepository().updateProfileDetails(
  //     id: id,
  //     body: body,
  //   );
  //   response.fold(
  //     (error) {},
  //     (details) => emit(state.copyWith(customerDetails: some(right(details)))),
  //   );
  //   emit(state.copyWith(updateProfileDetails: some(response)));
  // }

  Future<void> updateProfileDetails({
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String gender,
    required String profession,
    String? emergencyContactNumber,
    XFile? image,
  }) async {
    if (state.updateProfileDetails?.isNone() ?? false) {
      return;
    }

    emit(state.copyWith(updateProfileDetails: none()));

    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          updateProfileDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }

    // ✅ Create FormData
    final formData = FormData.fromMap({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'gender': gender.toLowerCase(),
      'profession': profession,
      if (emergencyContactNumber != null && emergencyContactNumber.isNotEmpty)
        'emergency_contact_number': emergencyContactNumber,
    });
    if (image != null) {
      formData.files.add(
        MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(image.path, filename: image.name),
        ),
      );
    }

    // ✅ Send FormData to repository
    final response = await CustomerDetailsRepository().updateProfileDetails(
      id: id,
      body: formData, // send as FormData
    );

    response.fold(
      (error) {
        debugPrint('❌ Error: $error');
      },
      (details) {
        emit(state.copyWith(customerDetails: some(right(details))));
        final profilePic = details.profilePicture;

        Feggy.read<AppCubit>()!.updateProfilePicture(profilePic);
      },
    );

    emit(state.copyWith(updateProfileDetails: some(response)));
  }

  Future<void> updateHealthProfile({
    required String bloodGroup,
    required String height,
    required String weight,
  }) async {
    if (state.updateProfileDetails?.isNone() ?? false) {
      return;
    }
    emit(state.copyWith(updateProfileDetails: none()));
    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          updateProfileDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }
    final body = <String, dynamic>{
      'blood_group': bloodGroup,
      'height': height,
      'weight': weight,
    };

    print('passing data is--${body}');
    final response = await CustomerDetailsRepository().updateHealthProfile(
      id: id,
      body: body,
    );
    response.fold(
      (error) {},
      (details) => emit(state.copyWith(customerDetails: some(right(details)))),
    );
    emit(state.copyWith(updateProfileDetails: some(response)));
  }

  Future<void> fetchConstChoices() async {
    emit(state.copyWith(constChoice: none()));
    final response = await AuthRepository().fetchConstChoices();
    emit(state.copyWith(constChoice: some(response)));
    print(state.constChoice);
  }

  Future<void> updateLifeStyle({
    String? sleepingHur,
    String? workingHur,
    String? jobSatisfaction,
  }) async {
    if (state.updateProfileDetails?.isNone() ?? false) {
      return;
    }
    emit(state.copyWith(updateProfileDetails: none()));
    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          updateProfileDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }
    final body = <String, dynamic>{
      'average_working_hours': workingHur,
      'average_sleep_hours': sleepingHur,
      'job_satisfaction': jobSatisfaction,
    };
    print('body is---$body');

    final response = await CustomerDetailsRepository().updateHealthProfile(
      id: id,
      body: body,
    );
    response.fold(
      (error) {},
      (details) => emit(state.copyWith(customerDetails: some(right(details)))),
    );

    // final result = await AuthRepository().onboardingUpdate(
    //   body: body,
    //   id: id,
    // );
    // response.fold(
    //       (error) {},
    //       (details) => emit(state.copyWith()),
    // );
    emit(state.copyWith(updateProfileDetails: some(response)));
  }

  Future<void> detailsUpdate({
    required Map<String, dynamic> body,
    required int? id,
  }) async {
    // Start loader
    emit(
      state.copyWith(
        // onboardingUser: none(),
        updateProfileDetails: none(),
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
          emit(state.copyWith(updateProfileDetails: some(left(failure))));
        },
        (r) {
          // Emit success and stop loader
          emit(
            state.copyWith(
              updateProfileDetails: some(right(r)),
              // onboardingUser: some(right(r)),
            ),
          );
        },
      );
    } catch (e) {
      // Catch unhandled exceptions and stop loader
      emit(
        state.copyWith(
          updateProfileDetails: some(
            left(ApiException.unknown(msg: e.toString())),
          ),
        ),
      );
    }
  }
}
