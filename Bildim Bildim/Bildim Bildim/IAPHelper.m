//
//  IAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

// 1
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductRestoredNotification = @"IAPHelperProductRestoredNotification";

@interface IAPHelper ()

@end

const NSString *IAP_PRODUCT_REMOVEAD = @"mobew.bildimbildim.removeAd";

@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSArray * _products;
    
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

static const NSString *PRODUCT_ID_PREFIX = @"mobew.bildimbildim.";

+ (NSSet *)readProductListFromServer
{
    NSMutableSet *result = [NSMutableSet set];
    
    [result addObject:IAP_PRODUCT_REMOVEAD];
    return result;
}

+ (IAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static IAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [self readProductListFromServer];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        _purchasedProductIdentifiers = [[NSMutableSet alloc] init];
        
        // Check for previously purchased products
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                if ([self productPurchased:productIdentifier] == NO) {
                    [_purchasedProductIdentifiers addObject:productIdentifier];
                }
                //NSLog(@"Previously purchased: %@", productIdentifier);
            } /*else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }*/
        }
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
    
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    if (_products != nil) {
        _completionHandler = [completionHandler copy];
        _completionHandler(YES, _products);
    }
    else {
        _completionHandler = [completionHandler copy];
        
        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
        _productsRequest.delegate = self;
        [_productsRequest start];
    }
}

- (BOOL)isProductRequestNotCompleted {
    return (_products == nil);
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    __block BOOL result = NO;
    [_purchasedProductIdentifiers enumerateObjectsUsingBlock:^(NSString *productId, BOOL *stop) {
        //NSLog(@"%@\n%@\n", product.productIdentifier, productIdentifier);
        NSRange isFound = [productIdentifier rangeOfString:productId options:NSCaseInsensitiveSearch];
        if (isFound.location != NSNotFound) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

- (SKProduct *)findProduct:(NSString *)productIdentifier
{
    static SKProduct *result = nil;
    BOOL notFound = YES;
    
    for (int i = 0; notFound && (i < [_products count]); ++i) {
        SKProduct *product = [_products objectAtIndex:i];
        NSRange isFound = [productIdentifier rangeOfString:product.productIdentifier options:NSCaseInsensitiveSearch];
        if (isFound.location != NSNotFound) {
            result = product;
            notFound = NO;
        }
    }
    
    /*
    [_products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
        //NSLog(@"%@\n%@\n", product.productIdentifier, productIdentifier);
        NSRange isFound = [productIdentifier rangeOfString:product.productIdentifier options:NSCaseInsensitiveSearch];
        if (isFound.location != NSNotFound) {
            result = product;
            *stop = YES;
        }
    }];
    */
    return result;
}

- (void)buyProduct:(SKProduct *)product
{
    //NSLog(@"Buying %@...", product.productIdentifier);
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    _products = response.products;
    /*for (SKProduct * skProduct in _products) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }*/
    
    _completionHandler(YES, _products);
    //_completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    //NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    _products = nil;
    
    _completionHandler(NO, nil);
    //_completionHandler = nil;
    
    // Ends user interaction disable.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"completeTransaction...");
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"restoreTransaction...");
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self provideContentForRestoredProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    
    //NSLog(@"failedTransaction...");
    /*if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }*/
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // Ends user interaction disable.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    if ([self productPurchased:productIdentifier] == NO) {
        [_purchasedProductIdentifiers addObject:productIdentifier];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

- (void)provideContentForRestoredProductIdentifier:(NSString *)productIdentifier
{
    if ([self productPurchased:productIdentifier] == NO) {
        [_purchasedProductIdentifiers addObject:productIdentifier];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoredNotification object:productIdentifier userInfo:nil];
    
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (NSString *)productIdentifier:(NSString *)textFileName
{
    static NSString *productIdentifier = nil;
    
    NSArray *tokens = [textFileName componentsSeparatedByString:@"/"];
    tokens = [tokens[[tokens count] - 1] componentsSeparatedByString:@"."];
    
    if (tokens != nil) {
        productIdentifier = [[NSString alloc] initWithFormat:@"%@%@", PRODUCT_ID_PREFIX, tokens[0]];
    }
    
    return productIdentifier;
}

@end