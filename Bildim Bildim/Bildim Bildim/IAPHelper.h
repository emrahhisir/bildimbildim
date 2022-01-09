//
//  IAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductRestoredNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

extern const NSString *IAP_PRODUCT_REMOVEAD;

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (BOOL)isProductRequestNotCompleted;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
- (SKProduct *)findProduct:(NSString *)productIdentifier;
- (NSString *)productIdentifier:(NSString *)textFileName;

+ (IAPHelper *)sharedInstance;

@end