class TokenListResponse {
  final bool? status;
  final String? address;
  final String? balance;
  final int? transactionCount;
  final int? tokentrxLength;
  final int? inttrxLength;
  final int? latestBlock;
  final List<TokenInfo>? token;
  final int? contract;

  TokenListResponse({
    this.status,
    this.address,
    this.balance,
    this.transactionCount,
    this.tokentrxLength,
    this.inttrxLength,
    this.latestBlock,
    this.token,
    this.contract,
  });

  /// Factory constructor for parsing from JSON
  factory TokenListResponse.fromJson(Map<String, dynamic> json) {
    return TokenListResponse(
      status: json['status'] as bool?,
      address: json['address'] as String?,
      balance: json['Balance']?.toString(),
      transactionCount: json['transactionCount'] is int
          ? json['transactionCount']
          : int.tryParse(json['transactionCount']?.toString() ?? '0'),
      tokentrxLength: json['tokentrxLength'] is int
          ? json['tokentrxLength']
          : int.tryParse(json['tokentrxLength']?.toString() ?? '0'),
      inttrxLength: json['inttrxLength'] is int
          ? json['inttrxLength']
          : int.tryParse(json['inttrxLength']?.toString() ?? '0'),
      latestBlock: json['latestBlock'] is int
          ? json['latestBlock']
          : int.tryParse(json['latestBlock']?.toString() ?? '0'),
      token: (json['token'] as List?)
          ?.map((e) => TokenInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      contract: json['contract'] is int
          ? json['contract']
          : int.tryParse(json['contract']?.toString() ?? '0'),
    );
  }

  /// Convert object to JSON (for debugging or caching)
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'address': address,
      'Balance': balance,
      'transactionCount': transactionCount,
      'tokentrxLength': tokentrxLength,
      'inttrxLength': inttrxLength,
      'latestBlock': latestBlock,
      'token': token?.map((e) => e.toJson()).toList(),
      'contract': contract,
    };
  }
}

class TokenInfo {
  final String? contractAddress;
  final String? balance;
  final String? name;

  TokenInfo({
    this.contractAddress,
    this.balance,
    this.name,
  });

  factory TokenInfo.fromJson(Map<String, dynamic> json) {
    // Handle nested MongoDB Decimal: {"balance": {"$numberDecimal": "4"}}
    String? balanceValue;
    final balanceData = json['balance'];
    if (balanceData is Map && balanceData.containsKey(r'$numberDecimal')) {
      balanceValue = balanceData[r'$numberDecimal']?.toString();
    } else if (balanceData != null) {
      balanceValue = balanceData.toString();
    }

    return TokenInfo(
      contractAddress: json['contractAddress'] as String?,
      balance: balanceValue,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractAddress': contractAddress,
      'balance': balance,
      'name': name,
    };
  }
}
