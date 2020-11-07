//
//  GSConstants.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/26/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import Foundation

var menuBar: GSMenuBarView?

struct GSString {
    
    static let AppName                                      =   "BayFay"
    
    struct storyboard {
        
        static let CommonSB                                 =   "Common"
        static let LoginSB                                  =   "Login"
        static let PaymentSB                                =   "Payment"
        static let SubscriptionSB                           =   "Subscription"
    }

    struct NavBarTitle {
        
        static let PickzyShops                              =   "PickZy Shops"
        static let Profile                                  =   "Profile"
        static let AddPayment                               =   "Add Payment"
        static let TrackOrder                               =   "Track Order"
        static let SuperMarket                              =   "Super market"
        static let VerifySelectItems                        =   "Verify Select items"
        static let VerifyDeliveredItems                     =   "Verify delivered items"
        static let PurchaseHistory                          =   "Purchase History"
        static let AddNewCard                               =   "Add New Card"
        static let Notifications                            =   "Notifications"
    }
    
    struct Icons {
        static let Store_Kids_icon                          =   "Store_Kids_icon"
        static let Store_Mobile_icon                        =   "Store_Mobile_icon"
        static let Store_SuperMarket_icon                   =   "Store_SuperMarket_icon"
        static let SideMenuIcon                             =   "SideMenu_icon"
        static let Back_arrow                               =   "Back_arrow"
        static let Bell_Icon                                =   "Bell_icon"
    }
    
    struct ShopCategories {
        static let superMarket                              =   "Super Market"
        static let kidsStore                                =   "Kids Store"
        static let mobileStore                              =   "Mobile Store"
    }
    
    struct Push {
        
        static let GSWelcomeScreenViewController            =  "GSWelcomeScreenViewController"
        static let GSWelcomeContentViewController           =  "GSWelcomeContentViewController"
        static let GSSignInViewController                   =  "GSSignInViewController"
        static let GSLoginViewController                    =  "GSLoginViewController"
        static let GSOtpViewController                      =  "GSOtpViewController"
        static let GSForgotPasswordViewController           =   "GSForgotPasswordViewController"
        static let GSShopsViewController                    =  "GSShopsViewController"
        static let GSProductsViewController                 =  "GSProductsViewController"
        static let GSNotificationViewController             =  "GSNotificationViewController"
        static let GSOrderPlacedViewController              =  "GSOrderPlacedViewController"
        static let GSProfileViewController                  =  "GSProfileViewController"
        static let GSAddPaymentViewController               =  "GSAddPaymentViewController"
        static let GSPaymentTypeViewController              =  "GSPaymentTypeViewController"
        static let GSCartViewController                     =  "GSCartViewController"
        static let GSTrackOrderListViewController           =  "GSTrackOrderListViewController"
        static let GSTrackOrderMapViewController            =  "GSTrackOrderMapViewController"
        static let GSSavedCardsViewController               =  "GSSavedCardsViewController"
        static let GSProductReportViewController            =   "GSProductReportViewController"
        
        static let GSVerifyItemsViewController              =  "GSVerifyItemsViewController"
        static let GSAddCardViewController                  =  "GSAddCardViewController"
        static let GSMakePaymentViewController              =  "GSMakePaymentViewController"
        static let GSDeliveryOptionViewController           =  "GSDeliveryOptionViewController"
        
        static let GSDetailMakePaymentViewController        =  "GSDetailMakePaymentViewController"
        static let GSStoreFeedbackViewController            =  "GSStoreFeedbackViewController"
        static let GSWishListViewController                 =  "GSWishListViewController"
        static let GSOrderCustomizationViewController       =  "GSOrderCustomizationViewController"
        static let GSShopDetailsViewController              =  "GSShopDetailsViewController"
        static let GSNotificationsViewController            =  "GSNotificationsViewController"
        
        static let GSPurchaseHistoryViewController          =  "GSPurchaseHistoryViewController"
        static let GSPurchasedProductsViewController        =  "GSPurchasedProductsViewController"
        
        static let GSProfileEditViewController              =  "GSProfileEditViewController"
        static let GSNotificationSettingsViewController     =  "GSNotificationSettingsViewController"
        static let GSCountryViewController                  =  "GSCountryViewController"
        static let GSProductDetailsViewController           =  "GSProductDetailsViewController"
        
        static let GSPinLocationViewController              =  "GSPinLocationViewController"
        
        static let GSPlacesAutoCompleteViewController       =  "GSPlacesAutoCompleteViewController"
        
        static let GSOrderConfirmationViewController        =   "GSOrderConfirmationViewController"
        static let GSPaymentWebViewController               =   "GSPaymentWebViewController"
        static let GSPaymentCCDCDetailViewController        =   "GSPaymentCCDCDetailViewController"
        
        static let GSCategoryMenuViewController             =   "GSCategoryMenuViewController"
        
        static let GSMessagesRootViewController             =   "GSMessagesRootViewController"
        static let GSMessagesViewController                 =   "GSMessagesViewController"
        static let GSMessagesAlbumPhotoViewController       =   "GSMessagesAlbumPhotoViewController"
        
        static let GSPurchasedProductsVerifyViewController  =   "GSPurchasedProductsVerifyViewController"
        
        static let GSNetbankingListViewController           =   "GSNetbankingListViewController"
        static let GSUPIPaymentViewController               =   "GSUPIPaymentViewController"
        
        static let GSInviteFriendsViewController            =   "GSInviteFriendsViewController"
        static let GSSupportViewController                  =   "GSSupportViewController"
        static let GSSupportDetailsViewController           =   "GSSupportDetailsViewController"
        static let GSAboutViewController                    =   "GSAboutViewController"
        static let GSHelpViewController                     =   "GSHelpViewController"
        static let GSHelpDetailViewController               =   "GSHelpDetailViewController"
        
        static let GSPromoCodeListViewController            =   "GSPromoCodeListViewController"
        
        static let GSOrderInvoiceViewController             =   "GSOrderInvoiceViewController"
        
        static let GSGlobalSearchViewController             =   "GSGlobalSearchViewController"
        
        static let GSSubscribeController                    =   "GSSubscribeController"

        static let GSSubscribeDaysViewController            =   "GSSubscribeDaysViewController"

        static let GSSubscriberDaysViewController           =   "GSSubscriberDaysViewController"
        
        static let GSSubscriberViewController               =   "GSSubscriberViewController"
        
        static let GSSubacriptionWalletViewController               =   "GSSubacriptionWalletViewController"
    }
    
    struct API {
        static let NetworkFailure                           =  "Network issue occured"
        static let NoInternetConnection                     =  "Your device is not connected."
        static let unknownError                             =   "Something went wrong"
    }
    
    struct CellIdentifier {
        
        static let ProductVC_Item_CollectionCell                =   "GSItemsCollectionCell"
        
        static let ShopVC_ShopCat_TableCell                     =  "shopsCatTableCell"
        static let ShopVC_shop_collectionCell                   =   "categoryCell"
        static let ShopVC_table_headerView                      =   "headerView"
        static let ShopVC_table_simple_headerView               =   "simpleHeaderView"
        
        static let NotificationVC_Offer_tableCell               =   "notificationsOfferCell"
        static let NotificationVC_update_tableCell              =   "notificationsUpdateCellId"
        static let DeliveryOptionVC_delivery_tableCell          =   "deliveryCellID"
        static let AddPaymentVC_addPayment_tableCell            =   "addPaymentCell"
        static let PaymentTypeVC_paymentMode_tableCell          =   "paymentModeCell"
        static let PaymentTypeVC_promocode_tableCell            =   "paymentPromoTableCell"
        static let PaymetnTypeVC_bayFayCoins_cell               =   "bayFayCoinsCell"
        static let CountryVC_country_tableCell                  =   "countryCell"
        static let CartVC_cartList_tableCell                    =   "CartListCell"
        static let TrackOrderVC_rowList_tableCell               =   "trackOrderRowListCell"
        static let PurchaseHistoryVC_tableCell                  =   "purchaseHistoryCell"
        static let PurchasedProductsVC_tableCell                =   "purchasedProductCell"
        
        static let ProfileAndSettingVC_profSettings_tableCell   =   "profileSettingCell"
        static let ProfileAndSettingVC_favoriteDelLoc_tableCell =   "favouriteDelLocationCell"
        static let ProfileAndSettingVC_addLoc_tableCell         =   "addLocationToFavouriteCell"
        
        static let ProfileEditVC_prof_tableCell                 =   "profileTableCell"
        
        static let NotificationSettingsVC_option_tableCell      =   "notifyOptionCell"
        static let NotificationSettingsVC_switch_tableCell      =   "NotifySwitchCell"
        
        static let VerifyItemsVC_complaint_tableCell            =   "deliveryComplaintCell"
        static let VerifyItemsVC_delivered_tableCell            =   "deliveredCell"
        static let VerifyItemsVC_unDelivered_tableCell          =   "notDeliveredCell"
        
        static let ShopDetailsVC_shop_tableCell                 =   "shopDetailsCell"
        static let ShopDetailsVC_order_tableCell                =   "orderProductCell"
        
        static let OrderCustomizationVC_cat_tableCell           =   "customOrderCatCell"
        static let OrderCustomizationVC_shop_tableCell          =   "customOrderShop"
        static let OrderCustomizationVC_productsCell            =   "customeOrderProductDetailsCell"
        static let OrderCustomizationVC_order_tableCell         =   "customOrderCell"
        
        static let StoreFeedbackVC_comment_tableCell            =   "CommentCell"
        static let StoreFeedbackVC_option_tableCell             =   "FeedBackOptionCell"
        
        static let ProductDetailsVC_detail_tableCell            =   "productDetailCell"
        static let ProductDetailsVC_description_tableCell       =   "productDescriptionCell"
        static let ProductDetailsVC_review_tableCell            =   "productReviewCell"
        
        static let Menu_header_tableCell                        =   "menuTableHeader"
        static let Menu_menu_tableCell                          =   "menuBarCell"
        
        static let ProductImageView_image_collectionCell        =   "fullImageCell"
        
        static let Places_tableCell                             =   "placesCell"
        static let ProductSearch_tableCell                      =   "productSearchCell"
        
        static let ViewBilling_tableCell                        =   "viewBillingCell"
        static let addressInOrderConfirmationTableCell          =   "addressCell"
        
        static let orderPlacedAddressTableCell                  =   "orderPlacedAddressTableViewCell"
        
        static let ccdcDetailsTableCell                         =   "ccdc_details_tableCell"
        
        static let categoryMenuTableCell                        =   "category_menu_tableCell"
        
        static let verifyOrderComplaintUpdatedTablCell          =   "updatedVerifyOrderComplaintCell"
        static let verifyOrderComplaintNestedLableTableCell     =   "verifyOrderNestedComplaintLableCell"
        static let varifyOrderComplaintNestedActionTableCell    =   "verifyOrderNestedComplaintActionCell"
        
        static let messageNormalIncomingTableCell               =   "messageNormalIncomingTableCell"
        static let messageNormalOutgoingTableCell               =   "messageNormalOutgoingTableCell"
        static let messageActionOutgoingTableCell               =   "messageActionOutgoingTableCell"
        static let messageActionIncomingTableCell               =   "messageActionIncomingTableCell"
        static let rootMessageCell                              =   "messagesRootCell"
        static let messageAlbumPhotoOutgoingTableCell           =   "imageOutgoingCell"
        static let messageAlbumPhotoIncomingTableCell           =   "imageIncomingCell"
        
        static let productReportTextViewTableCell               =   "reportTextViewCell"
        
        static let supportNormalTableViewCell                   =   "supportTableCell"
        static let supportContactTableViewCell                  =   "supportContactCell"
        static let supportSendMessageTableViewCell              =   "supportSendMessageCell"
        
        static let helpScreenTableViewCell                      =   "helpViewCell"
        static let helpContactCell                              =   "helpContactCell"
        
        static let commonCellForVerifyTrackorderPurchaseHistory =   "commonVerifyCell"
        
        static let cancelOrderPopup_radioBtnTableViewCell       =   "cancelOrderRadioButtonTableViewCell"
        static let cancelOrderPopup_feedbackTableViewCell       =   "cancelOrderFeedbackTableViewCell"
        
        static let feedbackViewCollectionCell                   =   "storeFeedbackRadioCollectionCell"
        static let feedBackViewCollectionFooter                 =   "storeFeedbackFooterView"
        
        static let promoCodeTableViewCell                       =   "promCodeTableViewCell"
        
        static let globalSearchCell                             =   "globalSearchCell"
    }
    
    struct NibNames {
        static let GSShopCatCollectionHeaderView                =   "GSShopCatCollectionHeaderView"
        static let GSShopCatCollectionSimpleHeaderView          =   "GSShopCatCollectionSimpleHeaderView"
        static let GSTrackOrderListTableHeaderView              =   "GSTrackOrderListTableHeaderView"
        static let GSTrackOrderListFooterView                   =   "GSTrackOrderListFooterView"
        static let GSPurchaseHistoryTableHeaderView             =   "GSPurchaseHistoryTableHeaderView"
        static let GSTrackPurchaseVerifyTableCell               =   "GSTrackPurchaseVerifyTableCell"
        static let GSOrderProductTableCell                      =   "GSOrderProductTableCell"
        static let GSCustomOrderTableCell                       =   "GSCustomOrderTableCell"
        static let GSProductDetailsHeaderView                   =   "GSProductDetailsHeaderView"
        static let GSProductReviewHeaderView                    =   "GSProductReviewHeaderView"
        static let GSFullImageCollectionCell                    =   "GSFullImageCollectionCell"
        
        static let GSMenuBarTableCell                           =   "GSMenuBarTableCell"
        static let GSMenuTableHeaderView                        =   "GSMenuTableHeaderView"

        static let GSProductSearchTableCell                     =   "GSProductSearchTableViewCell"
        static let GSProductDetailsWithOfferTableCell           =   "GSProductDetailsWithOfferTableCell"
        
        static let GSViewBillingFooterView                      =   "GSViewBillingFooterView"
        static let GSViewBillingTableCell                       =   "GSViewBillingTableCell"
        
        static let GSCustomOrderTableHeaderView                 =   "GSCustomOrderTableHeaderView"
        static let GSCategoryMenuTableCell                      =   "GSCategoryMenuTableCell"
        
        static let GSOrderConfirmationPreferenceTimeFooterView  =   "GSOrderConfirmationPreferenceTimeFooterView"
        
        static let GSRadioButtonTableCell                       =   "GSRadioButtonTableCell"
        static let GSCancellationTextViewTableCell              =   "GSCancellationTextViewTableCell"
        
        static let GSStoreFeedbackCollectionFooterView          =   "GSStoreFeedbackCollectionFooterView"
        static let GSStoreFeedbackRadioCollectionViewCell       =   "GSStoreFeedbackRadioCollectionViewCell"
        
        static let GSOrderInvoiceHeaderView                     =   "GSOrderInvoiceHeaderView"
        static let GSOrderInvoiceFooterView                     =   "GSOrderInvoiceFooterView"
    }
}

struct AppKeys {
    static let Google_Maps_Key                          =  "AIzaSyDWyeIbv-9oQK0Tj_-ggBIjLYr-yN_9oos"    //"AIzaSyCV9S87U3jzEHiKZAAslM4DzyeS4z-_qds"
    static let Google_Directions                        =  "AIzaSyDWyeIbv-9oQK0Tj_-ggBIjLYr-yN_9oos"    //"AIzaSyAgBEweDHpyj3HCT8jIgNaqpP7DBtrVZ9o"
    static let staticSecurityKey                        =   "zgNC,8zVLAN7X:P"
}

struct Validation {
    
    static let alphabets                    =  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
}

struct APIurl {
    
    #if DEVELOPEMENT
    static let baseURL                      =       "https://devuser.shoporservice.com/user"
//  static let baseURL                      =       "https://produser.shoporservice.com/user"
    #elseif QA
    static let baseURL                      =       "https://qauser.shoporservice.com/user"
    #else
    static let baseURL                      =       "https://produser.shoporservice.com/user"
    #endif
    
    // **Must remove this third party URL
    static let countryListURL               =       "https://restcountries.eu/rest/v2/all?fields=name;alpha2Code;callingCodes;flag"
    static let dummyToken = "00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0"
    
    struct subURL {
        
        static let guestLogin               =       "/auth/guest"
        static let loginWithPassword        =       "/auth/password"
        static let signUp                   =       "/auth/signup"
        static let signupVerify             =       "/auth/signup/verify"
        static let loginVerify              =       "/auth/onetimepassword/verify"
        static let loginWithOtp             =       "/auth/onetimepassword"
        static let forgotPasswordVerify     =       "/auth/forgotpassword/verify"
        static let resetPassword            =       "/auth/resetpassword"
        static let refreshToken             =       "/auth/refresh"
        static let logout                   =       "/auth/logout"

        static let dashBoardTemp            =       "/dsbd/vw"
        static let storeCategories          =       "/category/view/type"
        static let homePublicShops          =       "/category/view/location"   // ?type=public&
        //static let homePrivateShops         =       "/category/view/location/private" // Deprecated
        static let homePrivateShops         =       "/category/v2/view/location/private"
        static let homeBrandedShops         =       "/category/view/location" // ?type=branded&
        static let homeGlobalShops          =       "/category/view/location/global"
        static let homePage                 =       "/category/view/location"
        static let updateUserLocation       =       "/profile/location/edit"
        static let updateDeviceToken        =       "/profile/device/edit"
        
        static let viewImage                =       "/category/view/img?img="
        static let viewPromoCodeStoreImage  =       "/promo/view/img?img="
        static let viewProductImage         =       "/product/img/view?img="
        static let viewBannerImage          =       "/ads/view/img?img="

        // static let productsList             =       "/product/view" // - Deprecated
        static let productsList             =       "/product/view/products" // V2.0 API

        static let categoryList             =       "/product/view/product_category"
        static let productsCount            =       "/product/view/c"
        static let productCountInCategory   =       "/product/view/by_category/c"
        static let updateStoreView          =       "/product/update/storeStats"
        // static let productListByCategory    =       "/product/view/by_category" // - Deprecated
        static let productListByCategory    =       "/product/view/listByCategory" // V2.0 API

        // static let productListBySearch      =       "/product/view/by_search" // - Deprecated
        static let productListBySearch      =       "/product/view/listBySearch" // V2.0 API

        static let frameTypesForProducts    =       "/category/view/frametype"
        
        static let productDetails           =       "/product/view/by_product"
        static let productReviews           =       "/product/view/reviews"
        static let productViewReportTypes   =       "/product/view/reporttype"
        static let reportProduct            =       "/product/update/productReport"
        static let addProductToCart         =       "/cart/add"
        
        static let offerPopupAPI            =       "/promo/promopopupAnd"
        
        static let viewCart                 =       "/cart/view/cr"
//        static let viewCart                 =       "/cart/view/cart"
        static let saveForLaterList         =       "/cart/view/sf"
        static let uncheckCart              =       "/cart/uncheck"
        static let checkSaveForLater        =       "/cart/check"
        static let removeCart               =       "/cart/remove/cr"
        static let removeSaveForLater       =       "/cart/remove/sf"
        static let clearCart                =       "/cart/clear/cr"
        static let clearSaveForLater        =       "/cart/clear/sf"
        static let verifyStockInCart        =       "/cart/verify/stock"
        static let verifyShopsBeforeOrder   =       "/cart/verify/shop"
        static let deliveryTypes            =       "/order/view/delivery/type"
        static let deliveryTypeEdit         =       "/profile/delivery/edit"
        
        static let placeOrderByShop_COD     =       "/order/place/cashOnDelivery/shop"
        static let placeOrderTakeAway_COD   =       "/order/place/cashOnDelivery/takeaway"
        static let placeOrderByShop_payment =       "/order/place/online/shop"
        static let placeOrderTakeAway_payment   =   "/order/place/online/takeaway"
        static let OrderWithOnlyBayfayCash  =       "/order/place/online/bfcash"
        static let viewBilling              =       "/order/view/billing"
        
        static let autoSelectedShops        =       "/cart/view/as"
        static let customSelectedShops      =       "/cart/view/cs"
        static let writeCustomOrderToCart   =       "/cart/write"
        static let productQuantityInCart    =       "/cart/qty"
        
        static let trackOrderList           =       "/order/track/upcoming" //"/orderTest/view/upcoming"
        static let viewTrackOrderProducts   =       "/order/track/viewProducts"
        static let viewLocationOfProducts   =       "/order/track/viewLocation"
        static let replacementConfiguration =       "/order/view/replacement/titles"   //"/orderTest/view/replacement/type"
        static let verifyProducts           =       "/order/track/verifyProducts"     //"/orderTest/customer/verify"
        static let verifyOrderStatus        =       "/order/track/verifyOrder"
        static let cancelOrder              =       "/order/track/cancelOrder"
//        static let cancelOrderByStore       =       "/order/track/cancelShop"
        static let cancelOrderTitles        =       "/order/view/cancel/titles"
        static let cancelEscalatedOrders    =       "/order/track/cancelEscalation"
        
        static let purchaseHistoryList      =       "/order/history/purchase?"  //"/orderTest/view/purchase/history"
        static let viewPurchaseHistoryProducts      =   "/order/history/viewProducts"
        static let verifyPurchaseHistoryProducts    =   "/order/history/verifyProducts"
        static let verifyPurchaseHistoryStatus      =   "/order/history/verifyOrder"
        
        static let viewShopReviewTitles     =       "/order/view/shopreview/titles"
        static let viewProductReviewTitles  =       "/order/view/productreview/titles"
        static let trackOrderSubmitStoreFeedback    =   "/order/track/reviewShop"
        static let purchaseHistorySubmitStoreFeedback   =   "/order/history/reviewShop"
        static let trackOrderSubmitProductFeedback  =   "/order/track/reviewProduct"
        static let purchaseHistorySubmitProductFeedback =   "/order/history/reviewProduct"
        static let appRatingAPI             =       "/category/view/apprating"
        
        static let storeFeedBack            =       "/orderTest/store/feedback"
        static let viewStoreFeedback        =       "/orderTest/view/storeFeedback"
        static let feedbackOptions          =       "/orderTest/view/feedback/config"
        static let productFeedBack          =       "/orderTest/product/feedback"
        static let viewProductFeedback      =       "/orderTest/view/productFeedback"
        
        static let viewProfile              =       "/profile/view"
        static let removeProfileImage       =       "/profile/image/remove"
        static let changeProfileImage       =       "/profile/image/change"
        static let addAddressToProfile      =       "/profile/address/add"
        static let editSavedAddress         =       "/profile/address/edit"
        static let deleteAddress            =       "/profile/address/delete"
        static let profileEditPreferences   =       "/profile/preferences/edit"
        static let updateProfile            =       "/profile/edit"
        static let updateProfilePwd         =       "/profile/password/edit"
        
        static let messages_orderList       =       "/order/escalate/current" //"/message/view/orderList"
        static let messages_orderProductList =       "/order/escalate/viewProducts"
        static let messages_chatList        =       "/order/escalate/viewCorrespondence"
        static let updateCorrespondance     =       "/order/escalate/updateCorrespondence"
        static let deleteCorrespondence     =       "/order/escalate/deleteCorrespondence"
        static let denyTemplateRequest      =       "/order/escalate/denyTemplate"
        static let acceptTemplateRequest    =       "/order/escalate/acceptTemplate"
        static let message_viewAlbum        =       "/order/escalate/image?file="
        
        static let update_escalationStatus  =       "/message/resolute/update"
        static let update_escalationDeny    =       "/message/deny/update"
        static let recentChat_cancel        =       "/message/recent/cancel"
        static let message_newEscalation    =       "/message/new/escalation"
        
        static let trackOrderListCount      =       "/order/track/upcoming/c"
        static let messagesListCount        =       "/order/escalate/current/c"
        
        static let generateHashesFromServer =       "/order/payment"
        static let verifyRazorPay           =       "/order/razor/verifyPayment" // v2.0 API

        static let orderHelp_titles         =       "/order/help/titles?order_id="
        static let orderHelp_content        =       "/order/help/content?title_id="
        static let deliveryDelayBuzz        =       "/order/help/buzz"
        
        static let support_titles           =       "/order/support/titles"
        static let support_content          =       "/order/support/content?title_id="
        static let support_ask              =       "/order/support/ask"
        
        static let recentOrders             =       "/order/view/last"
        
        static let bayFayCash               =       "/wallet/bfcash"
        static let promoCodeList            =       "/promo/list"
        
        static let refundForOrderIssue      =       "/order/refund/orderIssue"
        
        static let welcomeMessage           =       "/category/welcome/message"
        
        static let fetchShopDetails         =       "/order/history/reOrder"
        
        static let notification_updates     =       "/notify/updates"
        static let notification_offers      =       "/notify/offer"
        
        static let globalSearch             =       "/global/products?search_str="
        
        static let scratchCard              =       "/ads/shop"
        static let scratchCardActivate      =       "/ads/accept"
        static let scratchCardClicked       =       "/ads/clickAd"
        static let scratchCardCount         =       "/ads/count"
        
        static let subscriptionType         =       "/subs/types"
        static let subscriptionAmount       =       "/subs/amount"
        static let subscriptionSubscribe    =       "/subs/subscribe"
        static let subscriptionWalletAmount =       "/subs/walletInfo"
        static let subscriptionList         =       "/subs/list"
        static let subscriptionRecharge     =       "/subs/recharge"
        static let subscriptionProductList           =       "/subs/products"
        static let subscriptionProductDetails        =       "/subs/viewSubs"
        static let subscriptionProductEdits          =       "/subs/editSubs"
        static let subscriptionProductPause          =       "/subs/pause"
        static let subscriptionProductUnSubscribe    =       "/subs/unsubscribe"
        static let subscriptionProductFeedbacktext   =       "/subs/feedbackText"
        static let subscriptionProductSaveProduct    =       "/subs/saveProducts"
        static let subscriptionManualOrder           =       "/subs/order"
    }
}

struct APIKeys {
    
    static let bearer_token_prefix  =   "Bearer "
    static let token_expire_key     =   "token"
    
    struct loginVC {
        static let login            =   "login"
        static let mobile           =   "mobile"
        static let dialing_code     =   "dialing_code"
        static let number           =   "number"
        static let password         =   "password"
        static let device_details   =   "device_details"
        static let deviceType       = "type"
        static let deviceToken      = "token"
        static let current_location =   "current_location"
        static let locationType     =   "type"
        static let coordinates      =   "coordinates"
        
    }
    struct signUpVC {
        static let first_name   =   "first_name"
        static let last_name    =   "last_name"
        static let mobile       =   "mobile"
        static let dialing_code =   "dialing_code"
        static let number       =   "number"
        static let emailObject  =   "email"
        static let email_id     =   "id"
        static let password     =   "password"
    }
    
    struct Shops {
        static let shopCodLimitType_any = "any"
    }
    
    struct ProductDetails {
        struct Request {
            static let id_req   =   "_id"
            static let stores   =   "stores"
            static let product  =   "product"
        }
        struct Response {
            static let id_res       =   "_id"
            static let productInfo  =   "productInfo"
            static let images       =   "images"
            static let image_name   =   "name"
            static let image_keyid  =   "keyid"
            static let image_width  =   "width"
            static let image_height =   "height"
            
            static let product_name =   "product_name"
            static let stores       =   "stores"
            static let product_details  =   "product_details"
            static let selling_price    =   "selling_price"
            static let offer        =   "offer"
            static let stock        =   "stock"
            
            static let store_id     =   "store_id"

        }
    }
    
    struct BadResponse {
        static let message      =   "message"
        static let error        =   "error"
    }
    
    struct ScratchCard {
        static let searchLocation   = "searchLocation"
        static let deliveryLocation = "deliveryLocation"
        static let maxDistance      = "maxDistance"
    }
}

struct UserDefaultKeys {
    
    static let apiDynamicSecretKey     =   "apiTokenToCall"
    static let deviceToken             =     "device_token"
    static let isGuestUserLogin        =    "is_guest_login"
//    static let isAppOpenedAlready    =     "is_app_opened_already"
    static let isShopWelcomeShown      =     "is_shop_welcome_shown"
    static let isProductAnimationShown = "is_product_animation_shown"
    
    static let appStoreReviewShown     = "is_appStore_review_shown"
    static let lastStoreShownEpochTime = "last_storeReview_epochTime"
    
    static let storesForNotification   = "stores_for_notifications"
    static let subscriptionName        = "subscription_name"
    static let subscriptionUpdate        = "subscription_update"

    struct user {
        static let accessToken      =   "user_unique_id"
        static let refreshToken     =   "user_refresh_token"
        static let user_details     =   "user_details"
        static let profile_image    =   "profile_image_url"
        static let referralCode     =   "referral_code"
        static let referralLink     =   "referral_link"
    }
    struct Shops {
        static let isCodEnabled             = "is_cod_enabled"
        static let codLimit                 = "cod_limit"
        static let isNeedToShowCOD          = "is_needToShow_COD"
        static let isNoteFeatureEnabled     = "is_notes_enabled"
        static let isUploadFeatureEnabled   = "is_upload_feature_enabled"
        static let localDeliveryFromTime    = "localDelivery_from_time"
        static let localDeliveryToTime      = "localDelivery_to_time"
        static let localDeliveryDuration    = "local_delivery_duration"
        static let localDeliveryDurationUnit = "local_delivery_duration_unit"
        static let otherDeliveryDuration    = "other_delivery_duration"
        static let otherDeliveryDurationUnit = "other_delivery_duration_unit"
        static let isGlobalShopsLoaded      =   "is_global_shops_loaded"
        static let isSubscriptionEnabled     = "enable_subscription"

    }
    
    struct Products {
        static let selectedStoreCategory_id =   "selectedStoreCategory_id"
        static let storeIdToDifferentiateCartClear = "storeId_to_clear_cart"
        static let selectedShopType = "selected_shop_type"
        static let selecedStoreArray        =   "selectedStores_array"
        static let isPrivateShop            =   "is_private_shop"
    }
    
    struct DeliveryPreferences {
        static let isPrefferDateTimeSelected = "preffered_delivery_status"
        static let prefferedDate = "preffered_date_for_delivery"
        static let prefferedTime = "preffered_time_for_delivery"
    }
    
    struct DeliveryFeatureDetails {
        static let deliveryNotes = "delivery_notes"
        static let deliveryInstructionImage = "delivery_instruction_image"
    }
    
    struct locations {
    
        static let searchLatitude = "searchLatitude"
        static let searchLongitude = "searchLongitude"
        static let searchPlace     = "searchPlace"
        
        static let deliveryLat = "deliveryLatitude"
        static let deliveryLong = "deliveryLongitude"
        static let deliveryPlace = "deliveryPlace"
        
        static let delivery_zipCode = "delivery_zip_code"
        static let delivery_changeable = "delivery_changeable_address"
        static let delivery_landMark = "delivery_landmark"
        static let delivery_unchangeable_address = "delivery_unchangeable_address"
        
        static let savedAddressObject = "saved_address_obj"
    }
    
    struct Payment {
        static let selectedDeliveryType =   "selected_delivery_type"
        static let selectedDeliveryTypeDisplayName = "selected_delivery_type_displayName"
        static let selectedPaymentMode =    "selected_payment_type"
        
        static let isBayFayCashSelected = "is_bayfay_cash_selected"
        static let promoCode =  "selected_promo_code"
        
        static let isDeliveryConfigured =   "is_delivery_configured"
        static let isPaymentConfigured  =   "is_payment_configured"
        
        static let transactionId        =   "transactionId"
        
        static let razorPaymentId       =   "razor_PaymentId"
        static let razorPaykey          =   "razor_Paymentkey"
        static let paymentAmount        =   "payment_Amount"
        static let paymentHash          =   "payment_Hash"
        static let paymentGatewayType   =   "payment_gatetype"


    }
//    struct Cart {
//        static let cartCount = "cart_count"
//    }
}

struct StaticKeys {
    struct Cart {
        struct CustomDictionary {
            static let store_id =   "store_id"
            static let product_item =   "item"
        }
    }
}

struct TrackOrderConstants {
    
    struct NewOrderStatus {
        
        struct Ordered {
            static let name = "Ordered"
            static let status = 1
        }
        struct Accepted {
            static let name = "Accepted"
            static let status = 2
        }
        struct ReadyToShip {
            static let name = "Ready To Ship"
            static let status = 3
        }
        struct Shipping {
            static let name = "Shipping"
            static let status = 4
        }
        struct Delivered {
            static let name = "Delivered"
            static let status = 5
        }
        struct Verified {
            static let name = "Verified"
            static let status = 6
        }
        struct Cancelled {
            static let name = "Cancelled"
            static let status = 7
        }
        struct Rejected {
            static let name = "Cancelled by Merchant"
            static let status = 8
        }
        struct Denied {
            static let name = "Denied"
            static let status = 9
        }
    }
    
    struct ExpiryDateStatus {
        static let Available = 1
        static let Unavailable = 2
        static let Unknown = 3
    }
    
    struct VerifyStatus {
        static let delivered    =   1
        static let undelivered  =   2
        static let replacement  =   3
    }
    
    struct VerifyStatusTitles {
        static let delivered    =   "delivered"
        static let undelivered  =   "undelivered"
    }
    
    struct Configuration {
        static let replacement = "replacement"
    }
    
    struct EscalationStatus {
        static let EscalatedByCustomer = 1
        static let EscalatedByShop = 2
        static let AcceptedByCustomer = 3
        static let AcceptedByShop = 4
        static let RefundedRequested = 5
        static let RefundedInitiated = 6
        static let EscalationClosed = 7
    }
}

struct GSConstant {
    
    static let radiusPickerData      = ["1", "2", "3", "4", "5","6", "7", "8", "9" , "10"]
    static let addToCartMax          = 100
    static let meterToKm             = 1000
    static let defaultRadius         = (5 * meterToKm)
    static let defaultRadiusToShow = "5"
    static let thumbnailFullscreenLQ = "500"
    static let thumbnailFullscreenHQ = "1000"
    static let tumbnailImgHeight     = "300" // pixel
    static let tumbnailLQImgHeight   = "75"  // Low quality pixel
    static let MAX_CACHE_MEMORY_SIZE = (1000000 * 50) // 50MB
    static let verifyItemsFeedback_maxCharacter = 150
    static let verifyItemsFeedback_minCharacter = 40
    static let mobileNumberLength = 10
    static let otpMaxAllowedLength = 6
    static let numericCharacters = "0123456789"
    static let pincodeMaxAllowedCharacters = 6
    static let refreshTokenDifferentiationSeconds = 20
    static let selfPickUP_id = 3
    
    static let offer_discount_type = 2
    
    static let localPushNotificationIdentifier = "local_notification"
    
    // progress bar configuration / UIColor(red:0.68, green:0.81, blue:0.72, alpha:1.0)
    static let progressBarBGColor : UIColor = UIColor(red:0.73, green:0.87, blue:0.98, alpha:1.0)
    static let progressBarColor : UIColor = UIColor(red:0.26, green:0.65, blue:0.45, alpha:1.0)
    static let promoBackgroundColor : UIColor = UIColor(red:168, green:228, blue:68, alpha:1.0)
    static let promoNoteTxtColor : UIColor = UIColor(red:254, green:0, blue:0, alpha:1.0)

    static let categoryBarBGColor : UIColor = UIColor(red:0.26, green:0.65, blue:0.45, alpha:0.5)
    
    static let progressBarHeight: CGFloat = 2
    static let categoryBarHeight: CGFloat = 20

    static var deviceTopStatusBarHeight : CGFloat = 20
    static var progressYaxis : CGFloat = deviceTopStatusBarHeight
    static let linearBar: LinearProgressBar = LinearProgressBar()

    // Private global variables
    static let HOME_PAGE_SHOP_COUNTS = 6
    static let rupee_symbol =   "₹"
    static let currency_symbol = rupee_symbol
    
    // Customer visible static messages
    static let suggestionMsg         = "No nearby shops found within the specified kilometers, we will notify you when shops attached in your area. If you are a merchant click below link for more details"
    static let cartBillMessage       =  "No products in cart"
    static let cartBillLoadingIssue  =  "Issue in loading the bill"
    static let messageTemplate = "Customer requested you to accept the Replacement/Undelivered request,  kindly confirm."
    static let inviteFriendsInfoLable = "Invite your friends and get 5% cashback when your friend make first purchase using your code."
    
    static let deviceType   =   1       // For iOS as per API
    
    static let apiDateFormatter = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let appDateFormatter =   "dd/MM/yyyy"
    static let appTimeFormatter =   "hh:mm a"
    static let appDateTimeFormatter =   "dd/MM/yyyy hh:mm a"
    
    static let defaultDeliveryMethod_id = 1
    static let defaultDeliveryDisplayName = "Delivery By Shop"
    
    static let termsAndConditions_url = "http://www.bayfay.com/terms.html"
    static let privacyPolicy_url = "http://www.bayfay.com/privacy.html"
    static let appWebsite_url = "http://www.bayfay.com"
    static let appVersionPrefix = "Ver"
    
    static let noPermissionToLoadPhotos = "\(GSString.AppName) does not have access to your photos. You can enable access in privacy settings"
    static let noPermissionToLoadCamera = "\(GSString.AppName) does not have access to your Camera. You can enable access in privacy settings"
    
    static let cancelOrderButtonTitle = "Cancel"
    static let helpButtonTitle = "Help"
    
    
    struct AlertMessages {
        
        static let fillAllDetails = "Please fill the fields to go next"
        static let validPhoneNumber = "Enter valid phone number"
        static let validPassword = "Enter valid password. Password should be minimum of 6 and it should contain only alphabets and digits"
        static let enterEmail = "Enter email id"
        static let validEmail = "Enter valid email id"
        static let enterOtp = "Enter OTP"
        static let enterPassword = "Enter password"
        static let enterConfirmPwd = "Enter confirm password"
        static let passwordConfirmPwdNoMatch = "New password and confirm password should be same"
        static let selectAnyOne = "Please select cancel reason"

        static let locationChangeAlert = "If you change the address, your cart with current location will be removed. Are you sure you want to continue?"
        static let radiusChangeAlert = "If you change the radius, your cart with current location will be removed. Are you sure you want to continue?"
        static let unableToFetchLocation = "Unable to fetch your location..."
        static let noCart = "No Products in Cart"
        static let otherStoreCartClear = "If you want to purchase from other category shops, you must check out the current cart items or would you like to clear the cart?"
        static let otherStoreTypeCartClear = "If you want to purchase from other category shops, you must check out the current cart items or would you like to clear the cart?"
        static let noProducts = "No items found"
        static let productDetailsView_stockUnavailable = "Either stock is not availble or total available stock has been moved to your cart..."
        static let reportViewValidation = "Select or write the correct reason to report"
        
        static let onlySelfPickupAvailable = "Home delivery option not available for this shop, you can self pickup from the shop when items ready for delivery.\nNote: You will be notified"
        
        static let noProductsToCustomize = "No items in the cart to customize"
        static let noProductsInBilling = "No items in the cart to show billing info"
        static let cartProductUnavailability = "Items not available currently"
        static let cartRemoveProduct = "Are you sure want to remove this product?"
        static let cartClearCart = "Are you sure want to clear cart?"
        
        static let loadCardIssue = "Issue in loading selected card, retry"
        
        static let orderConfirmation_enterDetailedAddress = "Enter your detailed address"
        static let enterZipcode = "Enter your zip code"
        static let invalidZipcode = "Zip Code is not valid"
        
        static let merchantMobileActionSheet_title = "Shop Contact Numbers"
        static let callMerchant = "Select the contact number to make call"
        
        static let unableToFetchPhoto = "Unable to fetch the photo"
        
        static let verifyItems_maximumAttachmentSelected = "Maximum attachments selected. Please select the images to replace or delete"
        static let cancelOrderFailed = "Seems cancellation selection has not loaded. Do you want to retry?"
        
        static let addressType = "Enter the address type"
        static let emptyAddressType = "Address type cannot be empty"
        static let addressTypeAlreadyExist = "Address type already exists"
        
        static let redirectToBank = "You'll be redirected to Bank's website, please wait.."
        static let paymentServerTimeout = "Server request timeout, retry"
        static let verifiedCard = "Successfully verified your card, we will refund the charged amount within 24hours"
        static let transactionFailed = "Transaction failed, try again"
        static let cancelTransaction = "Are you sure you want to cancel the transaction?"
        static let deletedCard = "Card details deleted successfully."
        
        static let sureSignout = "Are you sure you want to logout?"
        static let deleteAddress = "Are you sure you want to delete this address?"
        
        static let enterMessageInSupport = "Enter your message"
        static let supportContactUnavailable = "Contact Number not available"
        
        static let enterRating = "Rate your experience"
        
        static let tokenExpired = "Token expired... Please login again"
        
        static let codAlert = "Are you sure you want to place order?"
        static let codAlert_cashBack = "Cashback is not applicable for COD order. Do you want to continue?"

        static let cancelOrderPopUpHeader = "Are you sure you want to cancel this order?"
        static let selectAnyCancellationReason = "Please select the cancellation reason"
        
        static let cancelRestriction = "You can't cancel the order from app once shop started to prepare your order. If you still want to cancel, kindly contact shop or BayFay support to cancel your order"
        
        static let rewardEmpty = "Currently Rewards Unavailable"
        
        static let transaction_failed_title = "Transaction failed"
        static let transaction_failed_msg = "Any Amount deducted will be refunded within 4-7 days, try Again."
        static let pauseSubscription = "Are you sure you want to Pause?"
        static let unPauseSubscription = "Are you sure you want to Unpause?"
        static let unSubscription = "Are you sure you want to Unsubscribe?"
        static let subscriptionalert = "Are you sure you want to Subscribe?"

        static let subscriptionMessage = "Minimum one product should be in the subscription list."
        static let manualOrderAlert = "If the auto schedule fails due to low wallet balance, you can recharge and place the order manually. kindly confirm if you want to place the order now?"
    }
    
    struct ToolTip {
        static let privateShopInfo = "Purchase products from your favourite shop"
        static let publicShopInfo = "Find the lowest price for the products from different shops"
        static let brandedShopInfo = "Find the branded products in best deals"
        static let globalShopInfo = "Find the global products in best deals"
        
        static let toolTip_expiryButton_info = "You will be notified when the product expires."
        static let toolTip_addCard_cvv = "Your cvv is 3 digit no at your card's back side."
        static let toolTip_addCard_expiryDate = "Expiry date of your card."
        
        static let bayFayCash = "All the cashback and referral bonus will credit as \(GSString.AppName) cash."
    }
}

struct CardTypes {
    static let MASTERCARD   =   "MASTERCARD"
    static let MAESTRO      =   "MAESTRO"
    static let VISA         =   "VISA"
    static let AMEX         =   "AMEX"
    static let DINER        =   "DINER"
    static let RUPAY        =   "RUPAY"
}

struct GSProductFrameType {
    
    static let emptyTitleForFullScreen = ""
    
    struct Names {
        static let oneX = "1X"
        static let twoX = "2X"
        static let threeX = "3X"
        static let fullScreen = "Fullscreen"
    }
    struct Values {
        static let oneX_iPhone:CGFloat = 1.10
        static let oneX_iPad:CGFloat = 1
        static let twoX_iPhone:CGFloat = 1.40
        static let twoX_iPad:CGFloat = 2
        static let threeX_iPhone:CGFloat = 1.80
        static let threeX_iPad:CGFloat = 3
        static let fullScreen_iPhone:CGFloat = 0
        static let fullScreen_iPad:CGFloat = 0
    }
}

struct GSMessagesConstants {
    
    struct MessageTemplateStatus {
        static let accepted = 1
        static let denied = 2
    }
}

struct GSAlertConstants {
    
}

struct PushConfiguration {
    
    static let track_order_list = 1
    static let track_order_view = 2
    static let purchase_history_list = 3
    static let purchase_history_view = 4
    static let messages_list = 5
    static let messages_view = 6
    static let referral = 7
}


