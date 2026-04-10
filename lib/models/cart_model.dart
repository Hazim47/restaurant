class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {"product": product, "quantity": quantity};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Map<String, dynamic>.from(json["product"]),
      quantity: json["quantity"],
    );
  }
}
