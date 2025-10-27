class ImportTokenAddressResponse {
  final bool? status;
  final String? msg;

  ImportTokenAddressResponse({
    this.status,
    this.msg,
  });

  /// ✅ Factory constructor to create from JSON safely
  factory ImportTokenAddressResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ImportTokenAddressResponse(status: null, msg: null);
    }

    return ImportTokenAddressResponse(
      status: json['status'] is bool ? json['status'] as bool : null,
      msg: json['msg']?.toString(),
    );
  }

  /// ✅ Convert back to JSON (for logging or requests)
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': msg,
    };
  }

  /// ✅ Helper for quick success/failure check
  bool get isSuccess => status == true;
}
