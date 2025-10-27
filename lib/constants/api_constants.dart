class ApiConstants {
  // Base URL
  static const String baseUrl = "https://rubyexplorer.com/api";
  static const int chainId = 18359;

  // Endpoints
  static const String rpcUrl = "https://bridge-rpc.rubyscan.io";

  static String getCoinUrl = "$baseUrl/getrubyprice";

  static String getTokenlistUrl(String walletAddress) => "$baseUrl/getaddressdetails/$walletAddress";
  static String getTransactionUrl(String address, int page, int pageSize) =>
      "$baseUrl/getTransction/$address/$page/$pageSize";
  static String getImportTokenAddress(String walletAddress, String contractAddress)=>
      "$baseUrl/importtokenaddress/$walletAddress/$contractAddress";


}
