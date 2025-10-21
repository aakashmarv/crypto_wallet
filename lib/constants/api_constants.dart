class ApiConstants {
  // Base URL
  static const String baseUrl = "https://rubyexplorer.com/api";


  // Endpoints
  static const String rpcUrl = "https://bridge-rpc.rubyscan.io";

  static String getTokenlistUrl(String walletAddress) => "$baseUrl/getaddressdetails/$walletAddress";

}
