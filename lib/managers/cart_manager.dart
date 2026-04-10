import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';

class CartManager {
  static List<CartItem> cart = [];

  static ValueNotifier<int> cartNotifier = ValueNotifier(0);

  static Future init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("cart");

    if (data != null) {
      final List decoded = jsonDecode(data);
      cart = decoded.map((e) => CartItem.fromJson(e)).toList();
    }

    cartNotifier.value = totalItems();
  }

  static List<Map<String, dynamic>> items() {
    return cart.map((e) => e.toJson()).toList();
  }

  static Future saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final data = cart.map((e) => e.toJson()).toList();

    await prefs.setString("cart", jsonEncode(data));

    cartNotifier.value = totalItems();
  }

  static void addToCart(Map<String, dynamic> product) {
    final index = cart.indexWhere(
      (item) =>
          item.product["id"] == product["id"] &&
          item.product["type"] == product["type"],
    );

    if (index >= 0) {
      cart[index].quantity++;
    } else {
      cart.add(CartItem(product: product));
    }

    saveCart();
  }

  static void remove(int index) {
    cart.removeAt(index);
    saveCart();
  }

  static void increase(int index) {
    cart[index].quantity++;
    saveCart();
  }

  static void decrease(int index) {
    if (cart[index].quantity > 1) {
      cart[index].quantity--;
    } else {
      cart.removeAt(index);
    }

    saveCart();
  }

  static int totalItems() {
    int sum = 0;

    for (var item in cart) {
      sum += item.quantity;
    }

    return sum;
  }

  static double total() {
    double sum = 0;

    for (var item in cart) {
      sum += (item.product["price"] ?? 0) * item.quantity;
    }

    return sum;
  }
}
