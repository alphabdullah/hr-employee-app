/// Models for multi-step registration flow

/// Step 1: Profile & Account Information
// class RegisterStep1Model {
//   final String name;
//   final String surname;
//   final String email;
//   final String password;
//   final String passwordConfirmation;
//   final String? dob;
//   final String? telNo;
//   final String? whatsappNo;
//   final String? address;
//   final String? country;
//   final String? city;
//   final double? latitude;
//   final double? longitude;
//   final String? postCode;
//   final String? natInsuranceNo;
//   final String? nationality;
//   final bool? rightToWorkUk;
//   final String? gender;
//   final String? maritalStatus;
//   final bool? needWorkPermit;
//   final String? workPermitExpiry;
//   final int? studentVisaHoursPerWeek;
//   final String? preferContact; // email, sms, both
//   final String? userType; // merchandisers, support_staff, drivers, team_leaders

//   RegisterStep1Model({
//     required this.name,
//     required this.surname,
//     required this.email,
//     required this.password,
//     required this.passwordConfirmation,
//     this.dob,
//     this.telNo,
//     this.whatsappNo,
//     this.address,
//     this.country,
//     this.city,
//     this.latitude,
//     this.longitude,
//     this.postCode,
//     this.natInsuranceNo,
//     this.nationality,
//     this.rightToWorkUk,
//     this.gender,
//     this.maritalStatus,
//     this.needWorkPermit,
//     this.workPermitExpiry,
//     this.studentVisaHoursPerWeek,
//     this.preferContact,
//     this.userType,
//   });

//   factory RegisterStep1Model.empty() {
//     return RegisterStep1Model(
//       name: '',
//       surname: '',
//       email: '',
//       password: '',
//       passwordConfirmation: '',
//     );
//   }

//   Map<String, dynamic> toJson({bool includePassword = true}) {
//     final json = <String, dynamic>{
//       'name': name,
//       'surname': surname,
//       'email': email,
//     };
    
//     // Only include password fields if password is provided or in registration mode
//     if (includePassword && password.isNotEmpty) {
//       json['password'] = password;
//       json['password_confirmation'] = passwordConfirmation;
//     }

//     if (dob != null && dob!.isNotEmpty) json['dob'] = dob;
//     if (telNo != null && telNo!.isNotEmpty) json['tel_no'] = telNo;
//     if (whatsappNo != null && whatsappNo!.isNotEmpty) json['whatsapp_no'] = whatsappNo;
//     if (address != null && address!.isNotEmpty) json['address'] = address;
//     if (country != null && country!.isNotEmpty) json['country'] = country;
//     if (city != null && city!.isNotEmpty) json['city'] = city;
//     if (latitude != null) json['latitude'] = latitude;
//     if (longitude != null) json['longitude'] = longitude;
//     if (postCode != null && postCode!.isNotEmpty) json['post_code'] = postCode;
//     if (natInsuranceNo != null && natInsuranceNo!.isNotEmpty) json['nat_insurance_no'] = natInsuranceNo;
//     if (nationality != null && nationality!.isNotEmpty) json['nationality'] = nationality;
//     if (rightToWorkUk != null) json['right_to_work_uk'] = rightToWorkUk;
//     if (gender != null && gender!.isNotEmpty) json['gender'] = gender;
//     if (maritalStatus != null && maritalStatus!.isNotEmpty) json['marital_status'] = maritalStatus;
//     if (needWorkPermit != null) json['need_work_permit'] = needWorkPermit;
//     if (workPermitExpiry != null && workPermitExpiry!.isNotEmpty) json['work_permit_expiry'] = workPermitExpiry;
//     if (studentVisaHoursPerWeek != null) json['student_visa_hours_per_week'] = studentVisaHoursPerWeek;
//     if (preferContact != null && preferContact!.isNotEmpty) json['prefer_contact'] = preferContact;
//     if (userType != null && userType!.isNotEmpty) json['user_type'] = userType;

//     return json;
//   }

//   RegisterStep1Model copyWith({
//     String? name,
//     String? surname,
//     String? email,
//     String? password,
//     String? passwordConfirmation,
//     String? dob,
//     String? telNo,
//     String? whatsappNo,
//     String? address,
//     String? country,
//     String? city,
//     double? latitude,
//     double? longitude,
//     String? postCode,
//     String? natInsuranceNo,
//     String? nationality,
//     bool? rightToWorkUk,
//     String? gender,
//     String? maritalStatus,
//     bool? needWorkPermit,
//     String? workPermitExpiry,
//     int? studentVisaHoursPerWeek,
//     String? preferContact,
//     String? userType,
//   }) {
//     return RegisterStep1Model(
//       name: name ?? this.name,
//       surname: surname ?? this.surname,
//       email: email ?? this.email,
//       password: password ?? this.password,
//       passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
//       dob: dob ?? this.dob,
//       telNo: telNo ?? this.telNo,
//       whatsappNo: whatsappNo ?? this.whatsappNo,
//       address: address ?? this.address,
//       country: country ?? this.country,
//       city: city ?? this.city,
//       latitude: latitude ?? this.latitude,
//       longitude: longitude ?? this.longitude,
//       postCode: postCode ?? this.postCode,
//       natInsuranceNo: natInsuranceNo ?? this.natInsuranceNo,
//       nationality: nationality ?? this.nationality,
//       rightToWorkUk: rightToWorkUk ?? this.rightToWorkUk,
//       gender: gender ?? this.gender,
//       maritalStatus: maritalStatus ?? this.maritalStatus,
//       needWorkPermit: needWorkPermit ?? this.needWorkPermit,
//       workPermitExpiry: workPermitExpiry ?? this.workPermitExpiry,
//       studentVisaHoursPerWeek: studentVisaHoursPerWeek ?? this.studentVisaHoursPerWeek,
//       preferContact: preferContact ?? this.preferContact,
//       userType: userType ?? this.userType,
//     );
//   }
// }


/// Step 1: Profile & Account Information
class RegisterStep1Model {
  final String name;
  final String surname;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String? dob;
  final String? telNo;
  final String? whatsappNo;
  final String? address;
  final String? country;
  final String? region; // New field
  final String? district; // New field
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? postCode;
  final String? natInsuranceNo;
  final String? nationality;
  final bool? rightToWorkUk;
  final String? gender;
  final String? maritalStatus;
  final bool? needWorkPermit;
  final String? workPermitExpiry;
  final int? studentVisaHoursPerWeek;
  final String? preferContact; // email, sms, both
  final String? userType; // merchandisers, support_staff, drivers, team_leaders

  RegisterStep1Model({
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.dob,
    this.telNo,
    this.whatsappNo,
    this.address,
    this.country,
    this.region, // New
    this.district, // New
    this.city,
    this.latitude,
    this.longitude,
    this.postCode,
    this.natInsuranceNo,
    this.nationality,
    this.rightToWorkUk,
    this.gender,
    this.maritalStatus,
    this.needWorkPermit,
    this.workPermitExpiry,
    this.studentVisaHoursPerWeek,
    this.preferContact,
    this.userType,
  });

  factory RegisterStep1Model.empty() {
    return RegisterStep1Model(
      name: '',
      surname: '',
      email: '',
      password: '',
      passwordConfirmation: '',
    );
  }

  Map<String, dynamic> toJson({bool includePassword = true}) {
    final json = <String, dynamic>{
      'name': name,
      'surname': surname,
      'email': email,
    };
    
    // Only include password fields if password is provided or in registration mode
    if (includePassword && password.isNotEmpty) {
      json['password'] = password;
      json['password_confirmation'] = passwordConfirmation;
    }

    if (dob != null && dob!.isNotEmpty) json['dob'] = dob;
    if (telNo != null && telNo!.isNotEmpty) json['tel_no'] = telNo;
    if (whatsappNo != null && whatsappNo!.isNotEmpty) json['whatsapp_no'] = whatsappNo;
    if (address != null && address!.isNotEmpty) json['address'] = address;
    if (country != null && country!.isNotEmpty) json['country'] = country;
    if (region != null && region!.isNotEmpty) json['region'] = region; // New
    if (district != null && district!.isNotEmpty) json['district'] = district; // New
    if (city != null && city!.isNotEmpty) json['city'] = city;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (postCode != null && postCode!.isNotEmpty) json['post_code'] = postCode;
    if (natInsuranceNo != null && natInsuranceNo!.isNotEmpty) json['nat_insurance_no'] = natInsuranceNo;
    if (nationality != null && nationality!.isNotEmpty) json['nationality'] = nationality;
    if (rightToWorkUk != null) json['right_to_work_uk'] = rightToWorkUk;
    if (gender != null && gender!.isNotEmpty) json['gender'] = gender;
    if (maritalStatus != null && maritalStatus!.isNotEmpty) json['marital_status'] = maritalStatus;
    if (needWorkPermit != null) json['need_work_permit'] = needWorkPermit;
    if (workPermitExpiry != null && workPermitExpiry!.isNotEmpty) json['work_permit_expiry'] = workPermitExpiry;
    if (studentVisaHoursPerWeek != null) json['student_visa_hours_per_week'] = studentVisaHoursPerWeek;
    if (preferContact != null && preferContact!.isNotEmpty) json['prefer_contact'] = preferContact;
    if (userType != null && userType!.isNotEmpty) json['user_type'] = userType;

    return json;
  }

  RegisterStep1Model copyWith({
    String? name,
    String? surname,
    String? email,
    String? password,
    String? passwordConfirmation,
    String? dob,
    String? telNo,
    String? whatsappNo,
    String? address,
    String? country,
    String? region, // New
    String? district, // New
    String? city,
    double? latitude,
    double? longitude,
    String? postCode,
    String? natInsuranceNo,
    String? nationality,
    bool? rightToWorkUk,
    String? gender,
    String? maritalStatus,
    bool? needWorkPermit,
    String? workPermitExpiry,
    int? studentVisaHoursPerWeek,
    String? preferContact,
    String? userType,
  }) {
    return RegisterStep1Model(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      dob: dob ?? this.dob,
      telNo: telNo ?? this.telNo,
      whatsappNo: whatsappNo ?? this.whatsappNo,
      address: address ?? this.address,
      country: country ?? this.country,
      region: region ?? this.region, // New
      district: district ?? this.district, // New
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      postCode: postCode ?? this.postCode,
      natInsuranceNo: natInsuranceNo ?? this.natInsuranceNo,
      nationality: nationality ?? this.nationality,
      rightToWorkUk: rightToWorkUk ?? this.rightToWorkUk,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      needWorkPermit: needWorkPermit ?? this.needWorkPermit,
      workPermitExpiry: workPermitExpiry ?? this.workPermitExpiry,
      studentVisaHoursPerWeek: studentVisaHoursPerWeek ?? this.studentVisaHoursPerWeek,
      preferContact: preferContact ?? this.preferContact,
      userType: userType ?? this.userType,
    );
  }
}


/// Step 2: Compliance Information
class RegisterStep2Model {
  final bool? isDriver;
  final String? drivingLicenseNo;
  final String? drivingLicenseDate;
  final bool? ownCar;
  final bool? criminalRecord;
  final String? criminalRecordType; // spent, unspent
  final bool? cscs;
  final bool? sia;
  final bool? mhe;
  final bool? cis;
  final bool? firstAid;
  final String? otherCardText;
  final bool? registeredDisabled;
  final String? disabilityAdjustmentsText;
  final String? disabilityDetailsText;

  RegisterStep2Model({
    this.isDriver,
    this.drivingLicenseNo,
    this.drivingLicenseDate,
    this.ownCar,
    this.criminalRecord,
    this.criminalRecordType,
    this.cscs,
    this.sia,
    this.mhe,
    this.cis,
    this.firstAid,
    this.otherCardText,
    this.registeredDisabled,
    this.disabilityAdjustmentsText,
    this.disabilityDetailsText,
  });

  factory RegisterStep2Model.empty() {
    return RegisterStep2Model();
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (isDriver != null) json['is_driver'] = isDriver;
    if (drivingLicenseNo != null && drivingLicenseNo!.isNotEmpty) json['driving_license_no'] = drivingLicenseNo;
    if (drivingLicenseDate != null && drivingLicenseDate!.isNotEmpty) json['driving_license_date'] = drivingLicenseDate;
    if (ownCar != null) json['own_car'] = ownCar;
    if (criminalRecord != null) json['criminal_record'] = criminalRecord;
    if (criminalRecordType != null && criminalRecordType!.isNotEmpty) json['criminal_record_type'] = criminalRecordType;
    if (cscs != null) json['cscs'] = cscs;
    if (sia != null) json['sia'] = sia;
    if (mhe != null) json['mhe'] = mhe;
    if (cis != null) json['cis'] = cis;
    if (firstAid != null) json['first_aid'] = firstAid;
    if (otherCardText != null && otherCardText!.isNotEmpty) json['other_card_text'] = otherCardText;
    if (registeredDisabled != null) json['registered_disabled'] = registeredDisabled;
    if (disabilityAdjustmentsText != null && disabilityAdjustmentsText!.isNotEmpty) {
      json['disability_adjustments_text'] = disabilityAdjustmentsText;
    }
    if (disabilityDetailsText != null && disabilityDetailsText!.isNotEmpty) {
      json['disability_details_text'] = disabilityDetailsText;
    }

    return json;
  }

  RegisterStep2Model copyWith({
    bool? isDriver,
    String? drivingLicenseNo,
    String? drivingLicenseDate,
    bool? ownCar,
    bool? criminalRecord,
    String? criminalRecordType,
    bool? cscs,
    bool? sia,
    bool? mhe,
    bool? cis,
    bool? firstAid,
    String? otherCardText,
    bool? registeredDisabled,
    String? disabilityAdjustmentsText,
    String? disabilityDetailsText,
  }) {
    return RegisterStep2Model(
      isDriver: isDriver ?? this.isDriver,
      drivingLicenseNo: drivingLicenseNo ?? this.drivingLicenseNo,
      drivingLicenseDate: drivingLicenseDate ?? this.drivingLicenseDate,
      ownCar: ownCar ?? this.ownCar,
      criminalRecord: criminalRecord ?? this.criminalRecord,
      criminalRecordType: criminalRecordType ?? this.criminalRecordType,
      cscs: cscs ?? this.cscs,
      sia: sia ?? this.sia,
      mhe: mhe ?? this.mhe,
      cis: cis ?? this.cis,
      firstAid: firstAid ?? this.firstAid,
      otherCardText: otherCardText ?? this.otherCardText,
      registeredDisabled: registeredDisabled ?? this.registeredDisabled,
      disabilityAdjustmentsText: disabilityAdjustmentsText ?? this.disabilityAdjustmentsText,
      disabilityDetailsText: disabilityDetailsText ?? this.disabilityDetailsText,
    );
  }
}

/// Step 3: Availability Information
class RegisterStep3Model {
  final List<String> dayDays; // monday, tuesday, etc.
  final List<String> nightDays;

  RegisterStep3Model({
    this.dayDays = const [],
    this.nightDays = const [],
  });

  factory RegisterStep3Model.empty() {
    return RegisterStep3Model();
  }

  Map<String, dynamic> toJson() {
    return {
      'day_days': dayDays,
      'night_days': nightDays,
    };
  }

  RegisterStep3Model copyWith({
    List<String>? dayDays,
    List<String>? nightDays,
  }) {
    return RegisterStep3Model(
      dayDays: dayDays ?? this.dayDays,
      nightDays: nightDays ?? this.nightDays,
    );
  }
}

/// Step 4: Bank Details
class RegisterStep4Model {
  final String? accountHolder;
  final String? bankName;
  final String? bankTown;
  final String? accountNumber;
  final String? sortCode;

  RegisterStep4Model({
    this.accountHolder,
    this.bankName,
    this.bankTown,
    this.accountNumber,
    this.sortCode,
  });

  factory RegisterStep4Model.empty() {
    return RegisterStep4Model();
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (accountHolder != null && accountHolder!.isNotEmpty) json['account_holder'] = accountHolder;
    if (bankName != null && bankName!.isNotEmpty) json['bank_name'] = bankName;
    if (bankTown != null && bankTown!.isNotEmpty) json['bank_town'] = bankTown;
    if (accountNumber != null && accountNumber!.isNotEmpty) json['account_number'] = accountNumber;
    if (sortCode != null && sortCode!.isNotEmpty) json['sort_code'] = sortCode;

    return json;
  }

  RegisterStep4Model copyWith({
    String? accountHolder,
    String? bankName,
    String? bankTown,
    String? accountNumber,
    String? sortCode,
  }) {
    return RegisterStep4Model(
      accountHolder: accountHolder ?? this.accountHolder,
      bankName: bankName ?? this.bankName,
      bankTown: bankTown ?? this.bankTown,
      accountNumber: accountNumber ?? this.accountNumber,
      sortCode: sortCode ?? this.sortCode,
    );
  }
}
