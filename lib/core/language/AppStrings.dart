import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static Map<String, Map<String, String>> _data = {
    "en": {
      // عام
      "shawarma_4you": "Shawarma 4you",
      "home": "Home",
      "menu": "Menu",
      "orders": "Orders",
      "favorites": "Favorites",
      "settings": "Settings",
      "support": "Support",

      // المستخدم
      "name": "Name",
      "phone": "Phone",
      "email": "Email",

      // السلة
      "cart": "Cart",
      "empty_cart": "Cart is empty",
      "total": "Total",
      "add_to_cart": "Add to cart",

      // الطلب
      "checkout": "Checkout",
      "order_now": "Order Now",
      "delivery_type": "Delivery Type",
      "delivery": "Delivery",
      "pickup": "Pickup",
      "location": "Location",
      "detect_location": "Detect location",
      "loading_location": "Detecting location...",

      // الدفع
      "payment": "Payment Method",
      "cash": "Cash",
      "confirm_order": "Confirm Order",

      // تسجيل الخروج
      "logout": "Logout",
      "confirm_logout": "Confirm Logout",
      "confirm_logout_msg": "Are you sure you want to logout?",

      // رسائل
      "required_fields": "Please enter all required fields",
      "enter_location": "Please enter location",
      "added_success": "Added to cart",
      "error": "Something went wrong",

      // المفضلة
      "empty_favorites": "No favorites yet",

      // الإعدادات
      "dark_mode": "Dark Mode",
      "language": "Language",
      "notifications": "Notifications",

      // أزرار
      "save": "Save",
      "cancel": "Cancel",
      "edit": "Edit",

      "enter_name_phone": "Please enter name and phone",
      "all": "All",
      "shawarma": "Shawarma",
      "snacks": "Snacks",
      "family_meals": "Family Meals",
      "drinks": "Drinks",
      "broasted": "Broasted",
      "sauces": "Sauces",
      "unknown_location": "Unknown location",
      "yes": "Yes",
      "no": "No",
      "logoutConfirmation": "Are you sure you want to log out?",
      "contactUs": "Contact us: 0782333118",
      "paymentMethod": "Payment Method",
      "choosePaymentMethod": "Choose payment method",
      "cashOnDelivery": "Cash on delivery",
      "confirmOrder": "Confirm Order",
      "orderSuccess": "Order sent successfully",
      "orderError": "Error sending order",

      "google_login": "Continue with Google",

      "pickup_text": "Pickup from restaurant",

      "detecting_location": "Detecting location...",

      "detailed_address": "Enter your address in detail",
      "distance": "Distance",
      "delivery_fee": "Delivery",
      "enter_location_detail": "Please enter location and detailed address",

      "enter_here": "Type here...",
      "loading": "Loading...",
      "verifying": "Verifying...",
      "available": "Available",
      "closed": "Closed",
      "more_than_24h": "More than 24 hours ago",
      "hour_ago": "hour ago",
      "no_notifications": "No notifications",

      "order_price": "Order price",
      "delivery_fee_label": "Delivery",

      "choose_snack": "Choose Snack",
      "sandwich": "Sandwich",
      "meal": "Meal",
      "delete": "Delete",
      "order_status": "Order Status:",
      "items": "Items",
      "my_current_orders": "My Current Orders",
      "no_orders": "No orders",
      "order_deleted": "Order Deleted",
      "added_To_Cart": "Added_To_Cart",
      "add": "Add",
    },

    "ar": {
      // عام
      "shawarma_4you": " 4you شاورما",
      "home": "الرئيسية",
      "menu": "المنيو",
      "orders": "طلباتي",
      "favorites": "المفضلة",
      "settings": "الإعدادات",
      "support": "الدعم",

      "added_To_Cart": "تمت الإضافة إلى السلة",
      // المستخدم
      "name": "الاسم",
      "phone": "رقم الهاتف",
      "email": "البريد الإلكتروني",

      // السلة
      "cart": "السلة",
      "empty_cart": "السلة فارغة",
      "total": "المجموع",
      "add_to_cart": "إضافة للسلة",

      // الطلب
      "checkout": "إتمام الطلب",
      "order_now": "اطلب الآن",
      "delivery_type": "طريقة الاستلام",
      "delivery": "توصيل",
      "pickup": "استلام من المطعم",
      "location": "الموقع",
      "detect_location": "تحديد الموقع",
      "loading_location": "جاري تحديد الموقع...",

      // الدفع
      "payment": "طريقة الدفع",
      "cash": "كاش",
      "confirm_order": "تأكيد الطلب",

      // تسجيل الخروج
      "logout": "تسجيل الخروج",
      "confirm_logout": "تأكيد تسجيل الخروج",
      "confirm_logout_msg": "هل أنت متأكد أنك تريد تسجيل الخروج؟",

      // رسائل
      "required_fields": "يرجى إدخال جميع الحقول",
      "enter_location": "يرجى إدخال الموقع",
      "added_success": "تمت الإضافة",
      "error": "حدث خطأ",

      // المفضلة
      "empty_favorites": "لا يوجد مفضلة",

      // الإعدادات
      "dark_mode": "الوضع الليلي",
      "language": "اللغة",
      "notifications": "الإشعارات",

      // أزرار
      "save": "حفظ",
      "cancel": "إلغاء",
      "edit": "تعديل",
      "enter_name_phone": "يرجى إدخال الاسم ورقم الهاتف",
      "all": "الكل",
      "shawarma": "شاورما",
      "snacks": "سناكات",
      "family_meals": "وجبات عائلية",
      "drinks": "مشروبات",
      "broasted": "بروستد",
      "sauces": "صوصات",
      "unknown_location": "الموقع غير معروف",
      "yes": "نعم",
      "no": "لا",
      "logoutConfirmation": "هل أنت متأكد أنك تريد تسجيل الخروج؟",
      "contactUs": "تواصل معنا :0782033839",

      "paymentMethod": "طريقة الدفع",
      "choosePaymentMethod": "اختر طريقة الدفع",
      "cashOnDelivery": "الدفع عند الاستلام",
      "confirmOrder": "تأكيد الطلب",
      "orderSuccess": "تم إرسال الطلب بنجاح",
      "orderError": "حدث خطأ أثناء إرسال الطلب",
      "google_login": "الدخول عبر Google",
      "pickup_text": "استلام من المطعم",
      "detecting_location": "جاري التحديد...",
      "detailed_address": "حط عنوانك منطقتك بضبط",
      "distance": "المسافة",
      "delivery_fee": "التوصيل",
      "enter_location_detail": "حدد موقعك واكتب عنوانك بالتفصيل",
      "enter_here": "اكتب هنا...",
      "loading": "جارٍ التحميل...",
      "verifying": "جارٍ التحقق...",
      "available": "متاح",
      "closed": "مغلق",
      "morethan24h": "منذ أكثر من 24 ساعة",
      "hourago": "ساعة مضت",
      "no_notifications": "لا توجد إشعارات",
      "order_price": "سعر الطلب",
      "delivery_fee_label": "التوصيل",
      "choose_snack": "اختر نوع السناك",
      "sandwich": "سندويشة",
      "meal": "وجبة",
      "delete": "حذف",
      "order_status": "حالة الطلب:",
      "items": "الأصناف",
      "my_current_orders": "طلباتي الحالية",
      "no_orders": "لا توجد طلبات",
      "order_deleted": "'انحذف الطلب",
      "add": "اضافه",
    },
  };

  // getters
  String get order_deleted => _data[locale.languageCode]!["order_deleted"]!;
  String get add => _data[locale.languageCode]!["add"]!;
  String get added_To_Cart => _data[locale.languageCode]!["added_To_Cart"]!;
  String get shawarma_4you => _data[locale.languageCode]!["shawarma_4you"]!;
  String get home => _data[locale.languageCode]!["home"]!;
  String get menu => _data[locale.languageCode]!["menu"]!;
  String get orders => _data[locale.languageCode]!["orders"]!;
  String get favorites => _data[locale.languageCode]!["favorites"]!;
  String get settings => _data[locale.languageCode]!["settings"]!;
  String get support => _data[locale.languageCode]!["support"]!;

  String get name => _data[locale.languageCode]!["name"]!;
  String get phone => _data[locale.languageCode]!["phone"]!;
  String get email => _data[locale.languageCode]!["email"]!;

  String get cart => _data[locale.languageCode]!["cart"]!;
  String get emptyCart => _data[locale.languageCode]!["empty_cart"]!;
  String get total => _data[locale.languageCode]!["total"]!;
  String get addToCart => _data[locale.languageCode]!["add_to_cart"]!;

  String get checkout => _data[locale.languageCode]!["checkout"]!;
  String get orderNow => _data[locale.languageCode]!["order_now"]!;
  String get deliveryType => _data[locale.languageCode]!["delivery_type"]!;
  String get delivery => _data[locale.languageCode]!["delivery"]!;
  String get pickup => _data[locale.languageCode]!["pickup"]!;
  String get location => _data[locale.languageCode]!["location"]!;
  String get detectLocation => _data[locale.languageCode]!["detect_location"]!;
  String get loadingLocation =>
      _data[locale.languageCode]!["loading_location"]!;

  String get payment => _data[locale.languageCode]!["payment"]!;
  String get cash => _data[locale.languageCode]!["cash"]!;
  String get confirmOrder => _data[locale.languageCode]!["confirm_order"]!;

  String get logout => _data[locale.languageCode]!["logout"]!;
  String get confirmLogout => _data[locale.languageCode]!["confirm_logout"]!;
  String get confirmLogoutMsg =>
      _data[locale.languageCode]!["confirm_logout_msg"]!;

  String get requiredFields => _data[locale.languageCode]!["required_fields"]!;
  String get enterLocation => _data[locale.languageCode]!["enter_location"]!;
  String get addedSuccess => _data[locale.languageCode]!["added_success"]!;
  String get error => _data[locale.languageCode]!["error"]!;

  String get emptyFavorites => _data[locale.languageCode]!["empty_favorites"]!;

  String get darkMode => _data[locale.languageCode]!["dark_mode"]!;
  String get language => _data[locale.languageCode]!["language"]!;
  String get notifications => _data[locale.languageCode]!["notifications"]!;

  String get save => _data[locale.languageCode]!["save"]!;
  String get cancel => _data[locale.languageCode]!["cancel"]!;
  String get edit => _data[locale.languageCode]!["edit"]!;
  String get enterNamePhone => _data[locale.languageCode]!["enter_name_phone"]!;

  String get enter_Location => _data[locale.languageCode]!["enter_location"]!;

  String get all => _data[locale.languageCode]!["all"]!;
  String get shawarma => _data[locale.languageCode]!["shawarma"]!;
  String get snacks => _data[locale.languageCode]!["snacks"]!;
  String get familyMeals => _data[locale.languageCode]!["family_meals"]!;
  String get drinks => _data[locale.languageCode]!["drinks"]!;
  String get broasted => _data[locale.languageCode]!["broasted"]!;
  String get sauces => _data[locale.languageCode]!["sauces"]!;
  String get yes => _data[locale.languageCode]!["yes"]!;
  String get no => _data[locale.languageCode]!["no"]!;
  String get logoutConfirmation =>
      _data[locale.languageCode]!["logoutConfirmation"]!;
  String get contactUs => _data[locale.languageCode]!["contactUs"]!;
  String get paymentMethod => _data[locale.languageCode]!['paymentMethod']!;
  String get choosePaymentMethod =>
      _data[locale.languageCode]!['choosePaymentMethod']!;
  String get cashOnDelivery => _data[locale.languageCode]!['cashOnDelivery']!;
  String get orderSuccess => _data[locale.languageCode]!['orderSuccess']!;
  String get orderError => _data[locale.languageCode]!['orderError']!;

  String get unknownLocation =>
      _data[locale.languageCode]!["unknown_location"]!;
  String get googleLogin => _data[locale.languageCode]!["google_login"]!;

  String get pickupText => _data[locale.languageCode]!["pickup_text"]!;

  String get detectingLocation =>
      _data[locale.languageCode]!["detecting_location"]!;

  String get detailedAddress =>
      _data[locale.languageCode]!["detailed_address"]!;
  String get distance => _data[locale.languageCode]!["distance"]!;
  String get deliveryFee => _data[locale.languageCode]!["delivery_fee"]!;
  String get enterLocationDetail =>
      _data[locale.languageCode]!["enter_location_detail"]!;

  String get enterHere => _data[locale.languageCode]!["enter_here"]!;
  String get loading => _data[locale.languageCode]!["loading"]!;
  String get verifying => _data[locale.languageCode]!["verifying"]!;
  String get available => _data[locale.languageCode]!["available"]!;
  String get closed => _data[locale.languageCode]!["closed"]!;
  String get moreThan24h => _data[locale.languageCode]!["more_than_24h"]!;
  String get hourAgo => _data[locale.languageCode]!["hour_ago"]!;
  String get noNotifications =>
      _data[locale.languageCode]!["no_notifications"]!;

  String get orderPrice => _data[locale.languageCode]!["order_price"]!;
  String get deliveryFeeLabel =>
      _data[locale.languageCode]!["delivery_fee_label"]!;

  String get chooseSnack => _data[locale.languageCode]!["choose_snack"]!;
  String get sandwich => _data[locale.languageCode]!["sandwich"]!;
  String get meal => _data[locale.languageCode]!["meal"]!;
  String get delete => _data[locale.languageCode]!["delete"]!;
  String get orderStatus => _data[locale.languageCode]!["order_status"]!;
  String get items => _data[locale.languageCode]!["items"]!;
  String get myCurrentOrders =>
      _data[locale.languageCode]!["my_current_orders"]!;
  String get noOrders => _data[locale.languageCode]!["no_orders"]!;
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => ["en", "ar"].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async {
    return AppStrings(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
