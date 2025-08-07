class ApiEndpoints {
  ApiEndpoints._();

  // static const String baseUrl =
  // "https://lightslategrey-whale-350840.hostingersite.com/api/v1";
  // static const String baseUrl = "http://192.168.8.125:8000/api/v1";
  static const String baseUrl = "https://visibledm.com/api/v1";
  static const int receiveTimeout = 10000;
  static const int connectionTimeout = 10000;
  static const String signUpEndpoint = "$baseUrl/auth/signup";
  static const String signInEndpoint = "$baseUrl/auth/signin";
  static const String logoutEndpoint = "$baseUrl/auth/logout";
  static const String usersEndpoint = "$baseUrl/user";
  static const String usersActivationEndpoint = "$baseUrl/user/deactivate";
  static const String unassignRoleEndpoint = "$baseUrl/user/unassign_role";
  static const String productEndpoint = "$baseUrl/product";
  static const String drumEndpoint = "$baseUrl/drum";
  static const String pumpEndpoint = "$baseUrl/pump";
  static const String shiftEndpoint = "$baseUrl/shift";
  static const String salesEndpoint = "$baseUrl/sale";
  static const String stockEndpoint = "$baseUrl/stock";
  static const String customerEndpoint = "$baseUrl/customers";
  static const String TOKEN_KEY = "token";
}
