import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentLogic {
  static final InAppPurchase _iap = InAppPurchase.instance;

  static Future<bool> purchasePlan(String productId) async {
    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) return false;

    final ProductDetailsResponse response =
        await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.contains(productId) || response.productDetails.isEmpty) {
      return false;
    }

    final ProductDetails productDetails =
        response.productDetails.firstWhere((p) => p.id == productId);

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);

    bool success = false;
    await for (final purchaseDetailsList in _iap.purchaseStream) {
      for (var purchase in purchaseDetailsList) {
        if (purchase.productID == productId &&
            purchase.status == PurchaseStatus.purchased) {
          success = true;
          _iap.completePurchase(purchase);
        }
      }
      break;
    }

    return success;
  }
}
