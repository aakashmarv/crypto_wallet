class ApiConstants {
  // Base URL
  static String rpcUrl = "https://bridge-rpc.rubyscan.io";
  static String baseUrl = "https://rubyexplorer.com/api";

  static void setNetwork(bool isTestnet) {
    if (isTestnet) {
      rpcUrl = "http://159.65.157.10:8545";
      baseUrl = "https://testnet.rubyexplorer.com/api";
    } else {
      rpcUrl = "https://bridge-rpc.rubyscan.io";
      baseUrl = "https://rubyexplorer.com/api";
    }
  }
  static const int chainId = 18359;

  // Endpoints
  static String get getCoinUrl => "$baseUrl/getrubyprice";

  static String getTokenlistUrl(String walletAddress) => "$baseUrl/getaddressdetails/$walletAddress";
  static String getTransactionUrl(String address, int page, int pageSize) =>
      "$baseUrl/getTransction/$address/$page/$pageSize";
  static String getImportTokenAddress(String walletAddress, String contractAddress)=>
      "$baseUrl/importtokenaddress/$walletAddress/$contractAddress";


}
