import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum ApplicantType { person, entity }

extension ApplicantTypeX on ApplicantType {
  String get label => this == ApplicantType.person ? 'Person' : 'Entity';
}

enum ApplicantRole { policyHolder, insured, beneficiary }

class Applicant {
  Applicant({required this.role, this.type = ApplicantType.person});

  final ApplicantRole role;
  ApplicantType type;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final remarkController = TextEditingController();

  final fatherNameController = TextEditingController();
  DateTime? dob;
  String? gender;
  String? maritalStatus;
  final occupationController = TextEditingController();

  final weightController = TextEditingController();
  final heightFtController = TextEditingController();
  final heightInController = TextEditingController();
  String idType = 'NRC';
  final idNoController = TextEditingController();

  final regNoController = TextEditingController();
  String? businessType;
  DateTime? incorporationDate;
  final contactPersonController = TextEditingController();

  String relationship = 'Spouse';
  final percentController = TextEditingController();

  final roomNoController = TextEditingController();
  final buildingNoController = TextEditingController();
  final houseNoController = TextEditingController();
  final streetNoController = TextEditingController();
  final wardNoController = TextEditingController();

  final townController = TextEditingController();
  final townshipController = TextEditingController();
  final districtController = TextEditingController();
  final stateRegionController = TextEditingController();

  String documentType = 'NRC';
  XFile? nrcFrontPhoto;
  XFile? nrcBackPhoto;
  XFile? passportPhoto;

  bool get isEntity => type == ApplicantType.entity;

  String? get addressSummary {
    final parts = [
      if (roomNoController.text.trim().isNotEmpty)
        'Rm ${roomNoController.text.trim()}',
      if (buildingNoController.text.trim().isNotEmpty)
        'Bldg ${buildingNoController.text.trim()}',
      if (houseNoController.text.trim().isNotEmpty)
        'No. ${houseNoController.text.trim()}',
      if (streetNoController.text.trim().isNotEmpty)
        '${streetNoController.text.trim()} St',
      if (wardNoController.text.trim().isNotEmpty)
        'Ward ${wardNoController.text.trim()}',
      if (townController.text.trim().isNotEmpty) townController.text.trim(),
      if (townshipController.text.trim().isNotEmpty)
        townshipController.text.trim(),
      if (stateRegionController.text.trim().isNotEmpty)
        stateRegionController.text.trim(),
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  int get filledOptionalCount {
    var n = 0;
    if (maritalStatus != null) n++;
    if (occupationController.text.trim().isNotEmpty) n++;
    if (weightController.text.trim().isNotEmpty) n++;
    if (heightFtController.text.trim().isNotEmpty ||
        heightInController.text.trim().isNotEmpty) {
      n++;
    }
    if (remarkController.text.trim().isNotEmpty) n++;
    return n;
  }

  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    remarkController.dispose();
    fatherNameController.dispose();
    occupationController.dispose();
    weightController.dispose();
    heightFtController.dispose();
    heightInController.dispose();
    idNoController.dispose();
    regNoController.dispose();
    contactPersonController.dispose();
    percentController.dispose();
    roomNoController.dispose();
    buildingNoController.dispose();
    houseNoController.dispose();
    streetNoController.dispose();
    wardNoController.dispose();
    townController.dispose();
    townshipController.dispose();
    districtController.dispose();
    stateRegionController.dispose();
  }
}

class ApplicantValidators {
  ApplicantValidators._();

  static final _nameRegex = RegExp(r"^[A-Za-zက-႟\s]+$");
  static final _mobileFormatRegex = RegExp(r'^09\d{7,}$');
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final _idNoRegex = RegExp(r'^[A-Za-zက-႟0-9/()\s]+$');
  static final intRegex = RegExp(r'^\d+$');

  static int ageOf(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  static String? name(String v) {
    final t = v.trim();
    if (t.isEmpty || _nameRegex.hasMatch(t)) return null;
    return 'No special characters are allowed.';
  }

  static String? email(String v) {
    final t = v.trim();
    if (t.isEmpty || _emailRegex.hasMatch(t)) return null;
    return 'Please enter valid email.';
  }

  static String? idNo(String v) {
    final t = v.trim();
    if (t.isEmpty || _idNoRegex.hasMatch(t)) return null;
    return 'Number only.';
  }

  static String? mobileFormat(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    if (t.length < 7) return 'Minimum length is 7.';
    if (!_mobileFormatRegex.hasMatch(t)) {
      return 'Please enter correct mobile no.';
    }
    return null;
  }

  static String? mobileDigits(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    if (t.length < 7) return 'Minimum length is 7.';
    if (!intRegex.hasMatch(t)) return 'Only numbers are allowed.';
    return null;
  }

  static String? percent(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    if (!intRegex.hasMatch(t)) return 'Number only.';
    final n = int.tryParse(t);
    if (n == null || n > 100) return 'Number only.';
    return null;
  }

  static String? dobAge(DateTime dob) {
    final age = ageOf(dob);
    if (age < 18) return 'Minimum age is 18.';
    if (age > 100) return 'Maximum age is 100';
    return null;
  }

  static String? numberOnly(String v, {String message = 'Number only.'}) {
    final t = v.trim();
    if (t.isEmpty || double.tryParse(t) != null) return null;
    return message;
  }

  static String? dobMaxAge(DateTime dob) {
    if (dobFuture(dob) != null) return 'Should not be greater than today';
    return ageOf(dob) > 100 ? 'Maximum age is 100' : null;
  }

  static String? requestPolicyDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return d.isBefore(today) ? 'Should not be less than today.' : null;
  }

  static String? notifyMobile(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    if (t.length < 13) return 'Minimum length is 7';
    if (!_mobileFormatRegex.hasMatch(t)) {
      return 'Please enter correct mobile no.';
    }
    return null;
  }

  static String? dobFuture(DateTime dob) =>
      dob.isAfter(DateTime.now()) ? 'Should not be greater than today' : null;
}

extension ApplicantValidity on Applicant {
  /// The first thing standing between this card and Continue, phrased for
  /// the FA. `isValid` answers yes/no; this answers "which field", so the
  /// step can say what is missing instead of "complete the required
  /// fields" over a form that looks complete.
  String? get validationMessage {
    String? need(String label) => '$label is required.';

    if (nameController.text.trim().isEmpty) return need('Name');
    final nameErr = ApplicantValidators.name(nameController.text);
    if (nameErr != null) return 'Name: $nameErr';
    if (mobileController.text.trim().isEmpty) {
      return need('Mobile phone no');
    }

    if (isEntity) {
      if (regNoController.text.trim().isEmpty) return need('Registration no');
      if (businessType == null) return need('Business type');
      if (contactPersonController.text.trim().isEmpty) {
        return need('Contact person');
      }
      final contactErr = ApplicantValidators.name(contactPersonController.text);
      if (contactErr != null) return 'Contact person: $contactErr';
      if (incorporationDate != null &&
          ApplicantValidators.dobFuture(incorporationDate!) != null) {
        return 'Incorporation date: '
            '${ApplicantValidators.dobFuture(incorporationDate!)}';
      }
    } else {
      if (fatherNameController.text.trim().isEmpty) {
        return need("Father's name");
      }
      final fatherErr = ApplicantValidators.name(fatherNameController.text);
      if (fatherErr != null) return "Father's name: $fatherErr";
      if (idNoController.text.trim().isEmpty) return need('Identification');
      final idErr = ApplicantValidators.idNo(idNoController.text);
      if (idErr != null) return 'Identification: $idErr';
      if (dob == null) return need('Date of birth');
      final dobError = switch (role) {
        ApplicantRole.beneficiary => ApplicantValidators.dobFuture(dob!),
        ApplicantRole.insured => ApplicantValidators.dobMaxAge(dob!),
        ApplicantRole.policyHolder => ApplicantValidators.dobAge(dob!),
      };
      if (dobError != null) return 'Date of birth: $dobError';
      if (role != ApplicantRole.beneficiary && gender == null) {
        return need('Gender');
      }
      for (final (label, text) in [
        ('Weight', weightController.text),
        ('Height (ft)', heightFtController.text),
        ('Height (in)', heightInController.text),
      ]) {
        final err = ApplicantValidators.numberOnly(text);
        if (err != null) return '$label: $err';
      }
    }

    if (role != ApplicantRole.beneficiary && !addressComplete) {
      return 'Address is incomplete — house no, street, ward and town are '
          'all required.';
    }

    switch (role) {
      case ApplicantRole.beneficiary:
        if (mobileController.text.trim().length < 7) {
          return 'Mobile phone no: Minimum length is 7.';
        }
        final digitsErr = ApplicantValidators.mobileDigits(
          mobileController.text,
        );
        if (digitsErr != null) return 'Mobile phone no: $digitsErr';
        final pctErr = ApplicantValidators.percent(percentController.text);
        if (pctErr != null) return 'Beneficiary percentage: $pctErr';
        if (double.tryParse(percentController.text.trim()) == null) {
          return need('Beneficiary percentage');
        }
      case ApplicantRole.insured:
        final mobErr = ApplicantValidators.mobileFormat(mobileController.text);
        if (mobErr != null) return 'Mobile phone no: $mobErr';
        final emailErr = ApplicantValidators.email(emailController.text);
        if (emailErr != null) return 'Email: $emailErr';
      case ApplicantRole.policyHolder:
        final emailErr = ApplicantValidators.email(emailController.text);
        if (emailErr != null) return 'Email: $emailErr';
    }
    return null;
  }

  bool get isValid {
    if (nameController.text.trim().isEmpty) return false;
    if (ApplicantValidators.name(nameController.text) != null) return false;
    if (mobileController.text.trim().isEmpty) return false;

    if (isEntity) {
      if (regNoController.text.trim().isEmpty) return false;
      if (businessType == null) return false;
      if (contactPersonController.text.trim().isEmpty) return false;
      if (ApplicantValidators.name(contactPersonController.text) != null) {
        return false;
      }
      if (incorporationDate != null &&
          ApplicantValidators.dobFuture(incorporationDate!) != null) {
        return false;
      }
    } else {
      if (fatherNameController.text.trim().isEmpty) return false;
      if (ApplicantValidators.name(fatherNameController.text) != null) {
        return false;
      }
      if (idNoController.text.trim().isEmpty) return false;
      if (ApplicantValidators.idNo(idNoController.text) != null) return false;
      if (dob == null) return false;
      final dobError = switch (role) {
        ApplicantRole.beneficiary => ApplicantValidators.dobFuture(dob!),
        ApplicantRole.insured => ApplicantValidators.dobMaxAge(dob!),
        ApplicantRole.policyHolder => ApplicantValidators.dobAge(dob!),
      };
      if (dobError != null) return false;
      if (role != ApplicantRole.beneficiary && gender == null) return false;
      if (ApplicantValidators.numberOnly(weightController.text) != null) {
        return false;
      }
      if (ApplicantValidators.numberOnly(heightFtController.text) != null) {
        return false;
      }
      if (ApplicantValidators.numberOnly(heightInController.text) != null) {
        return false;
      }
    }

    if (role != ApplicantRole.beneficiary && !addressComplete) {
      return false;
    }

    switch (role) {
      case ApplicantRole.beneficiary:
        if (mobileController.text.trim().length < 7) return false;
        if (ApplicantValidators.mobileDigits(mobileController.text) != null) {
          return false;
        }
        if (ApplicantValidators.percent(percentController.text) != null) {
          return false;
        }
        if (double.tryParse(percentController.text.trim()) == null) {
          return false;
        }
      case ApplicantRole.insured:
        if (ApplicantValidators.mobileFormat(mobileController.text) != null) {
          return false;
        }
        if (ApplicantValidators.email(emailController.text) != null) {
          return false;
        }
      case ApplicantRole.policyHolder:
        if (ApplicantValidators.email(emailController.text) != null) {
          return false;
        }
    }
    return true;
  }

  bool get addressComplete =>
      houseNoController.text.trim().isNotEmpty &&
      streetNoController.text.trim().isNotEmpty &&
      wardNoController.text.trim().isNotEmpty &&
      townController.text.trim().isNotEmpty;

  bool get documentsCaptured {
    if (isEntity) return true;
    if (idNoController.text.trim() == 'No ID') return true;
    return documentType == 'NRC'
        ? nrcFrontPhoto != null && nrcBackPhoto != null
        : passportPhoto != null;
  }
}
