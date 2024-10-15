import 'package:project3/mshop/ShoppingCart.dart';

class Products {
  int? productNo;
  String? productName;
  String? productDetails;
  String? productImageUrl;
  double? price;

  Products({
    this.productNo,
    this.productName,
    this.productDetails,
    this.productImageUrl,
    this.price,
  });
  Products.fromJson(Map<String, dynamic> json) {
    productNo = int.parse(json['productNo']);
    productName = json['productName'];
    productDetails = json['productDetails'];
    productImageUrl = json['productImageUrl'];
    price = double.parse(json['price']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['productNo'] = productNo;
    data['productName'] = productName;
    data['productDetails'] = productDetails;
    data['productImageUrl'] = productImageUrl;
    data['price'] = price;

    return data;
  }

  // CartItem으로부터 Product 생성
  factory Products.fromCartItem(CartItem cartItem) {
    return Products(
      productNo: cartItem.productId,
      productName: cartItem.productTitle,
      price: cartItem.price.toDouble(), // double로 변환
      productImageUrl: cartItem.mainImage,
    );
  }

  // Product를 CartItem으로 변환
  CartItem toCartItem(int quantity) {
    return CartItem(
      productId: productNo!,
      productTitle: productName!,
      price: price!.toInt(), // int로 변환
      mainImage: productImageUrl!,
      quantity: quantity,
    );
  }
}
