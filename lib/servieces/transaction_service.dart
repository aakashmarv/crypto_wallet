// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../constants/api_constants.dart';
//
// class TransactionService {
//   Future<List<Map<String, dynamic>>> fetchTransactions(String address) async {
//     final url = "${ApiConstants.etherscanBaseUrl}?module=account&action=txlist&address=$address"
//         "&startblock=0&endblock=99999999&sort=desc&apikey=${ApiConstants.etherscanApiKey}";
//
//     final res = await http.get(Uri.parse(url));
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       if (data['status'] == "1") {
//         final List txs = data['result'];
//         return txs.map((tx) {
//           return {
//             'hash': tx['hash'],
//             'from': tx['from'],
//             'to': tx['to'],
//             'value': (BigInt.parse(tx['value']) / BigInt.from(10).pow(18)).toStringAsFixed(6),
//             'timestamp': int.parse(tx['timeStamp']),
//             'status': tx['isError'] == "0" ? 'success' : 'failed',
//           };
//         }).toList();
//       }
//     }
//     return [];
//   }
// }
