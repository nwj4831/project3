class Product {
  int? productNo;
  String? productName;
  String? productDetails;
  String? productImageUrl;
  int? price;
  int? quantity;

  Product({
    this.productNo,
    this.productName,
    this.productDetails,
    this.productImageUrl,
    this.price,
    this.quantity,
  });

  Product.fromJson(Map<String, dynamic> json) {
    productNo = json['productNo'];
    productName = json['productName'];
    productDetails = json['productDetails'];
    productImageUrl = json['productImageUrl'];
    price = json['price'].toInt();
    quantity = json['quantity']; // 수량 필드
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['productNo'] = productNo;
    data['productName'] = productName;
    data['productDetails'] = productDetails;
    data['productImageUrl'] = productImageUrl;
    data['price'] = price;
    data['quantity'] = quantity; // 수량 필드
    return data;
  }
}
