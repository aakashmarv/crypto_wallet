class TransactionHistoryResponse {
  final bool? status;
  final List<Transaction>? result;
  final double? trxLength;

  TransactionHistoryResponse({
    this.status,
    this.result,
    this.trxLength,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      status: json['status'] as bool?,
      result: (json['result'] as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      trxLength: (json['trx_length'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'result': result?.map((e) => e.toJson()).toList(),
    'trx_length': trxLength,
  };
}

class Transaction {
  final String? hash;
  final String? blockHash;
  final double? blockNumber;
  final double? chainId;
  final String? contract;
  final String? createdAt;
  final dynamic decodedInput;
  final double? fee;
  final String? from;
  final String? functionName;
  final double? gas;
  final double? gasLimit;
  final double? gasPrice;
  final double? gasUsed;
  final double? nonce;
  final List<OtherDetail>? otherDetails;
  final String? r;
  final String? s;
  final String? signers;
  final double? status;
  final String? to;
  final String? tokenAddress;
  final double? tokenDecimals;
  final String? tokenSymbol;
  final double? tokenValue;
  final double? transactionIndex;
  final String? transactionType;
  final double? transactiontype;
  final String? type;
  final String? updatedAt;
  final double? v;
  final double? value;

  Transaction({
    this.hash,
    this.blockHash,
    this.blockNumber,
    this.chainId,
    this.contract,
    this.createdAt,
    this.decodedInput,
    this.fee,
    this.from,
    this.functionName,
    this.gas,
    this.gasLimit,
    this.gasPrice,
    this.gasUsed,
    this.nonce,
    this.otherDetails,
    this.r,
    this.s,
    this.signers,
    this.status,
    this.to,
    this.tokenAddress,
    this.tokenDecimals,
    this.tokenSymbol,
    this.tokenValue,
    this.transactionIndex,
    this.transactionType,
    this.transactiontype,
    this.type,
    this.updatedAt,
    this.v,
    this.value,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      hash: json['hash'] as String?,
      blockHash: json['blockHash'] as String?,
      blockNumber: (json['blockNumber'] as num?)?.toDouble(),
      chainId: (json['chainId'] as num?)?.toDouble(),
      contract: json['contract'] as String?,
      createdAt: json['createdAt'] as String?,
      decodedInput: json['decodedInput'],
      fee: (json['fee'] as num?)?.toDouble(),
      from: json['from'] as String?,
      functionName: json['functionName'] as String?,
      gas: (json['gas'] as num?)?.toDouble(),
      gasLimit: (json['gasLimit'] as num?)?.toDouble(),
      gasPrice: (json['gasPrice'] as num?)?.toDouble(),
      gasUsed: (json['gasUsed'] as num?)?.toDouble(),
      nonce: (json['nonce'] as num?)?.toDouble(),
      otherDetails: (json['otherDetails'] as List?)
          ?.map((e) => OtherDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      r: json['r'] as String?,
      s: json['s'] as String?,
      signers: json['signers'] as String?,
      status: (json['status'] as num?)?.toDouble(),
      to: json['to'] as String?,
      tokenAddress: json['tokenAddress'] as String?,
      tokenDecimals: (json['tokenDecimals'] as num?)?.toDouble(),
      tokenSymbol: json['tokenSymbol'] as String?,
      tokenValue: (json['tokenValue'] as num?)?.toDouble(),
      transactionIndex: (json['transactionIndex'] as num?)?.toDouble(),
      transactionType: json['transactionType'] as String?,
      transactiontype: (json['transactiontype'] as num?)?.toDouble(),
      type: json['type'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['v'] as num?)?.toDouble(),
      value: (json['value'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'hash': hash,
    'blockHash': blockHash,
    'blockNumber': blockNumber,
    'chainId': chainId,
    'contract': contract,
    'createdAt': createdAt,
    'decodedInput': decodedInput,
    'fee': fee,
    'from': from,
    'functionName': functionName,
    'gas': gas,
    'gasLimit': gasLimit,
    'gasPrice': gasPrice,
    'gasUsed': gasUsed,
    'nonce': nonce,
    'otherDetails': otherDetails?.map((e) => e.toJson()).toList(),
    'r': r,
    's': s,
    'signers': signers,
    'status': status,
    'to': to,
    'tokenAddress': tokenAddress,
    'tokenDecimals': tokenDecimals,
    'tokenSymbol': tokenSymbol,
    'tokenValue': tokenValue,
    'transactionIndex': transactionIndex,
    'transactionType': transactionType,
    'transactiontype': transactiontype,
    'type': type,
    'updatedAt': updatedAt,
    'v': v,
    'value': value,
  };
}

class OtherDetail {
  final CoinTransfer? coinTransfer;

  OtherDetail({this.coinTransfer});

  factory OtherDetail.fromJson(Map<String, dynamic> json) {
    return OtherDetail(
      coinTransfer: json['coinTransfer'] != null
          ? CoinTransfer.fromJson(json['coinTransfer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'coinTransfer': coinTransfer?.toJson(),
  };
}

class CoinTransfer {
  final String? from;
  final String? to;
  final double? value;

  CoinTransfer({
    this.from,
    this.to,
    this.value,
  });

  factory CoinTransfer.fromJson(Map<String, dynamic> json) {
    return CoinTransfer(
      from: json['from'] as String?,
      to: json['to'] as String?,
      value: (json['value'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'value': value,
  };
}
