class PendingCartModel {
  final int productId;
  final int quantity;

  PendingCartModel({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "quantity": quantity,
      };

  factory PendingCartModel.fromJson(Map<String, dynamic> json) {
    return PendingCartModel(
      productId: json["product_id"],
      quantity: json["quantity"],
    );
  }
}