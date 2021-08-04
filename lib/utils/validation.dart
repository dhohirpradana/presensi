class InputValidationMixin {
  static bool isPasswordValid(String password) => password.isNotEmpty;
  static bool isNisValid(String nis) => nis.isNotEmpty;
}
