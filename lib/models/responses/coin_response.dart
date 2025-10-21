class CoinResponse {
  final bool? status;
  final CoinResult? result;

  CoinResponse({
    this.status,
    this.result,
  });

  factory CoinResponse.fromJson(Map<String, dynamic> json) {
    return CoinResponse(
      status: json['status'] as bool?,
      result: json['result'] != null
          ? CoinResult.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'result': result?.toJson(),
  };
}

class CoinResult {
  final String? id;
  final int? coinId;
  final double? price;
  final double? volume;
  final List<ChartData>? chartData;
  final String? lastUpdated;
  final String? updatedAt;
  final String? coinName;
  final double? marketCap;
  final double? priceChange24h;
  final double? priceChange7d;
  final int? rank;
  final String? symbol;

  CoinResult({
    this.id,
    this.coinId,
    this.price,
    this.volume,
    this.chartData,
    this.lastUpdated,
    this.updatedAt,
    this.coinName,
    this.marketCap,
    this.priceChange24h,
    this.priceChange7d,
    this.rank,
    this.symbol,
  });

  factory CoinResult.fromJson(Map<String, dynamic> json) {
    return CoinResult(
      id: json['_id'] as String?,
      coinId: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      volume: (json['volume'] is num) ? (json['volume'] as num).toDouble() : null,
      chartData: (json['chartdata'] as List?)
          ?.map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] as String?,
      updatedAt: json['updatedAt'] as String?,
      coinName: json['coinName'] as String?,
      marketCap: (json['marketCap'] is num) ? (json['marketCap'] as num).toDouble() : null,
      priceChange24h: (json['priceChange24h'] is num)
          ? (json['priceChange24h'] as num).toDouble()
          : null,
      priceChange7d: (json['priceChange7d'] is num)
          ? (json['priceChange7d'] as num).toDouble()
          : null,
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank']?.toString() ?? ''),
      symbol: json['symbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'id': coinId,
    'price': price,
    'volume': volume,
    'chartdata': chartData?.map((e) => e.toJson()).toList(),
    'lastUpdated': lastUpdated,
    'updatedAt': updatedAt,
    'coinName': coinName,
    'marketCap': marketCap,
    'priceChange24h': priceChange24h,
    'priceChange7d': priceChange7d,
    'rank': rank,
    'symbol': symbol,
  };
}

class ChartData {
  final double? price;
  final int? time;
  final String? timestamp;
  final double? quantity;
  final String? id;

  ChartData({
    this.price,
    this.time,
    this.timestamp,
    this.quantity,
    this.id,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      time: json['time'] is int ? json['time'] : int.tryParse(json['time']?.toString() ?? ''),
      timestamp: json['timestamp'] as String?,
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toDouble() : null,
      id: json['_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'price': price,
    'time': time,
    'timestamp': timestamp,
    'quantity': quantity,
    '_id': id,
  };
}
