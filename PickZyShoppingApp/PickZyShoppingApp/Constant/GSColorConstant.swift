//
//  GSColorConstant.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 12/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

var defaultTheme = color.whiteTheme.self

struct color {
    
    struct whiteTheme {
        
        //--
        static let NAVIGATION_BG_COLOR        = "F7F7F7" //"fbfbfb"  //
        static let NAVIGATION_TITLE_COLOR     = "000000"
        static let NAVIGATION_LEFT_BUT_COLOR  = "007AFF"
        static let NAVIGATION_BOTTOM_LINE     = "D3D3D3"
        static let NAVIGATION_ICON_COLOR      = ""
        static let NAVIGATION_TITLE_FONT_SIZE = 16
        //--
        static let SEARCHBAR_BG_COLOR         = "C8C8CD"
        static let SEARCHBAR_BORDER_COLOR     = "C2C2C8"
        //--
        static let VIEW_OR_TABLE_BACKGROUND   = "ECECEC"
        
        //--
        
        static let navigationBG             = "fbfbfb"
        static let NavBarBtnTitle           = "2196f3"
        static let NavBarBottomLine         = "D3D3D3"

        static let sideMenuHeader    = "f5f5f5"
        static let sideMenuSelected    = "673ab7"
        static let sideMenuText    = "000000"
        
        static let alertBox    = "f5f5f5"
        static let alertTitle_BG = "EEEEEE"
        
        static let singleBtnAlert_OkBtn_BG = "027AFF"
        static let singleBtnAlert_msg_text = "555555"
        
        static let paymentMadeAlert_Btn_BG = "1E7869"
        static let paymentMadeAlert_msg_text = "1E7869"
        
        static let cancelOrderAlert_YesBtn_BG = "EF2922"
        static let cancelOrderAlert_NoBtn_BG = "79BC32"
        static let cancelOrderAlert_msg_text = "555555"
        
        static let notificationIcon    = "673ab7"
        static let searchList    = "fafafa"
        static let searchListText    = "000000"
        
        //Added
        
        // Welcome includes welcome screen login signup and otp
        static let welcome_loginButton_BG    = "03A9F4"
        static let welcome_signUpButton_BG    = "8BC34A"
        static let welcome_skipButton_title = "8C8C8C"
        
        static let welcome_textFieldBG    = "f5f5f5"
        static let welcome_textField_Placeholder    = "616161"
        static let welcome_infoLabelText = "898989" ///*"555555"*/"9E9E9E"
        static let underLineButtonTxt = "2196f3"

        static let welcome_loginBtn_title = "FFFFFF"
        static let welcome_signUpBtn_title = "FFFFFF"
        
        static let login_textField_placeholder = "898989" //"8C8C8C"
        static let login_textField_text = "000000"

        static let signUp_textField_placeholder = "898989" //"8C8C8C"
        static let signUp_textField_text = "000000"
        
        static let otp_textField_placeholder = "898989" //"8C8C8C"
        static let otp_textField_text = "000000"
        
        static let shopVC_textField_placeholder = "000000"
        static let shopVC_textField_text = "000000"
        static let shopVC_locationsView_BG    = "ececec"
        static let shopVC_textField_BG = "FFFFFF"
        static let shopVC_textField_Border = "ECECEC"
        static let shopVC_shopImg_BG    = "f5f5f5"
        static let shopVC_shopIconBadge    = "f44336"
        static let shopVC_header_BG1    = /*"cfbaf6"*/"fafafa"
        static let shopVC_header_BG2 = /*"BEE0FB"*/"fafafa"
        static let shopVC_header_BG3 = /*"94EDF8"*/"fafafa"
        static let shopVC_header_title = "424242"
        static let shopVC_inviteBtn_title = "555555"
        static let shopVC_inviteBtn_BG = "8BC257"
        static let shopVC_market_title = "555555"
        static let shopVC_sugestionLabelText = "04988A"
        
        static let cartIconBG = "2C7833"
        static let cartIconText = "FFFFFF"
        
        static let trackOrderListVC_BG = "F5F5F5"
        static let trackOrderCell_Content_BG = "FFFFFF"
        static let trackOrderListVC_Header_BG = "F9F9F9"
        static let trackOrderListVC_Header_ContentBG = "ECECEC"
        static let trackOrderListVC_Footer_BG = "F5F5F5"
        static let trackOrderListVC_Footer_btn_BG = "FF2727"
        static let trackOrderListVC_header_title = "686868"
        static let trackOrderListVC_Footer_title = "FFFFFF"
        static let trackOrderListVC_cell_text = "383838"
        static let trackOrderListVC_cell_contactBtn_text = "515151"
        static let trackOrderListVC_cell_contactBtn_border = "AAAAAA"
        static let trackOrderListVC_cell_orderCount_lbl_text = "415964"
        static let trackOrderListVC_cell_cost_lbl_text = "127EDA"
        static let trackOrder_orderCountLabelText = "9F20AE"
        static let trackOrderListVC_orderKey_lbl_text = "404040"
        static let trackOrderListVC_orderValue_lbl_text = "A16DFD"

        static let cart_BottomStack_BG = "F5F5F5"
        static let Cart_btn_border = "E0E0E0"
        static let cart_viewBilling_btn_title = "0000ff"
        static let cart_MakePayment_BG = "8BC34A"
        static let cart_Subscribe_BG = "F59100"
        static let cart_MakePaymentBtn_title = "FFFFFF"
        static let cart_MakePaymentBtn_border = "51B054"
        static let cart_customOrderBtn_BG = "FFFFFF"
        static let cart_customOrderBtn_title = "000000"
        static let cart_deliveryModeBtn_BG = "FFFFFF"
        static let cart_deliveryModeBtn_title = "000000"
        static let cart_paymentIconBtn_BG = "FFFFFF"
        static let cart_cell_key_label_text = "000000"
        static let cart_cell_value_label_text = "000000"
        static let cart_cell_save_bg = "E8F9D4"
        static let cart_cell_save_border = "A8E85C"
        static let cart_header_bg = "F7F7F7"
        static let cart_header_title = "292929"
        static let cart_quantity_border = "C1C1C1"
 
        static let purchaseHistory_table_BG = "F5F5F5"
        static let purchaseHist_tableHeader_BG = "FAFAFA"
        static let purchaseHist_Header_title = "787878"
        static let purchaseHist_ExtraLabel_title = "673AB7"
        static let purchaseHist_OrderCount_title = "F44336"
        static let purchaseHist_cell_title = "000000"
        static let purchaseHist_cell_BG = "FAFAFA"
        
        static let profileAndSettings_cell_AddMoreLocbtn_text = "006FC7"
        static let profileAndSettings_cell_text = "000000"
        static let profileAndSettings_cell_subTitle = "4B4B4B"
        static let profileAndSettings_header_title = "7E7E7E"
        
        static let notification_normalCell_text = "434343"
        static let notification_imageCell_text = "673AB7"
        
        static let productVC_priceTag_BG = "1EB116"
        static let productVC_priceTag_title = "FFFFFF"
        static let productVC_bottomLine = "c9c9c9"
        
        static let OrderAddressConfirmationVC_header_bg = "EFEFEF"
        static let OrderAddressConfirmationVC_normal_text = "444444"
        static let OrderAddressConfirmationVC_confirmAddressBtn_bg = "" // "FAFAFA"
        static let OrderAddressConfirmationVC_confirmAddressBtn_title = "3278FA"
        static let OrderAddressConfirmationVC_confirmAddressBtn_border = "E7E7E7"
        static let OrderAddressConfirmationVC_cell_header = "616161"
        static let OrderAddressConfirmationVC_cell_text = "666666"
        
        static let OrderPlacedVC_header_bg = "F7F7F7"
        static let OrderPlacedVC_header_title = "353535"
        static let OrderPlacedVC_cell_text = "8E8E8E"
        static let OrderPlacedVC_continueShop_Btn_bg = "8BE126"
        static let OrderPlacedVC_continueShop_Btn_title = "324122"
        static let OrderPlacedVC_trackOrder_Btn_bg = "FF2727"
        static let OrderPlacedVC_trackOrder_Btn_title = "FFFFFF"
        static let OrderPlacedVC_trackOrder_info_text   =   "49606A"
        
        static let CCDCDetailVC_header_BG = "E0E0E0"
        static let CCDCDetailVC_header_text = "424242"
        static let CCDCDetailVC_tableView_BG = "F5F5F5"
        static let CCDCDetailVC_cell_text = "757575"
        
        //Non Menu View Controllers
        
        static let deliveryOptionsVC_header_BG = "FAFAFA"
        static let deliveryOptionsVC_BG = "FAFAFA"
        static let deliveryOptionsVC_header_title = "434343"
        static let deliveryOptionsVC_Cell_text = "000000"
        static let deliveryOptionsVC_Cell_BG = "FFFFFF"
        
        static let makePayment_totalCostKey_title = "000000"
        static let makePayment_totalCostValue_text = "2EA295"
        static let makePayment_creditDebitHeading_text = "000000"
        static let makePayment_creditDebitNumber_text = "000000"
        static let makePayment_txtField_text = "000000"
        
        static let paymentType_cell_text = "000000"
        static let paymentType_header_bg = "FAFAFA"
        static let paymentType_cell_bg = "FFFFFF"
        static let paymentType_header_text = "616161"
        static let paymentType_table_bg = "FAFAFA"
        
        static let paymentOpt_tableHeader_BG = "F9F9F9" // "F5F5F5"
        static let paymentOpt_header_text = "424242"
        static let paymentOpt_cell_BG = "FFFFFF"
        static let paymentOpt_BorderC = "EAEAEA"// "E6E6E8"
        static let paymentOpt_table_BG = "F5F5F5" // "F9F9F9"
        static let paymentOpt_addPaymentBtn_text = "297BFF"
        static let paymentOpt_cellTitle_text = "000000"
        static let paymentOpt_cellApplyPromoLable = "FF5959"
        static let paymentOpt_cellPromoAppliedLable = "31C03D"
        
        static let addNewCard_textField_text = "000000"
        static let addNewCard_placeHolder = "9E9E9E"
        static let addNewCard_header_text = "9E9E9E"
        static let addNewCard_country_title = "000000"
        
        static let detailedMakePayment_view_BG = "F5F5F5"
        static let detailedMakePayment_storeNameKey_text = "9C27B0"
        static let detailedMakePayment_storeNameValue_text = "9C27B0"
        static let detailedMakePayment_delDateKey_text = "434343"
        static let detailedMakePayment_delDateValue_text = "434343"
        static let detailedMakePayment_paymentTop_text = "434343"
        static let detailedMakePayment_cost_text = "40B055"
        static let detailedMakePayment_doneBtn_BG = "FFFFFF"
        static let detailedMakePayment_doneBtn_title = "000000"
        
        static let countryList_cell_title = "000000"
        static let countryList_sideIndex_text = "434343"
        
        static let trackOrderMap_content_BG = "FAFAFA"
        static let trackOrderMap_header_text = "434343"
        static let trackOrderMap_info_text = "000000"
        static let trackOrderMap_deliveryTime_text = "FC4B45"
        static let trackOrderMap_deliveryDist_text = "009788"
        static let trackOrderMap_orderCount_text = "9F20AE"
        
        static let purchasedProducts_cell_info_text = "000000"
        static let purchasedProducts_cell_replacement_title = "00B5F1"
        static let purchasedProducts_cell_replacementValue_text = "05A89D"
        static let purchasedProducts_cell_cost_title = "FD4F4A"
        static let purchasedProducts_cell_reviewBtn_BG = "FC3E3B"
        static let purchasedProducts_cell_reviewBtn_title = "FFFFFF"
        static let purchasedProducts_cell_orderCount_text = "9F20AE"
        
        static let profileEdit_topLabel = "000000"
        static let profileEdit_bottomLabel = "434343"
        static let profileEdit_table_BG = "F0F0F0"
        static let profileEdit_cell_BG = "FFFFFF"
        
        static let notificationSettings_table_BG = "EFEFF4"
        static let notificationSettings_cell_BG = "FFFFFF"
        static let notificationSettings_cell_title = "434343"
        
        static let verifyItems_header_title = "555555"
        static let verifyItems_header_bg = "EFEFEF"
        static let verifyItems_keyLabel_text = "626262"
        static let verifyItems_delStatus_green_text = "4CAF50"
        static let verifyItems_delStatus_red_text = "F4473B"
        static let verifyItems_submitBtn_BG = "03A9F4"
        static let verifyItems_header_cost_text = "2C2C2C"
        static let verifyItems_submitBtn_title = "FFFFFF"
        static let verifyItems_cell_productName_lbl = "010101"
        static let verifyItems_cell_defaultInfo_titles = "5C5C5C"
        static let verifyItems_cell_helpBtn_border = "FF4545"
        static let verifyItems_cell_highlightInfo_titles = "F5554A"
        static let verifyItems_cell_complaintRadio_title = "000000"
        static let verifyItems_daysLeft_title = "009D90"
        static let verifyItems_writeReviewColor = "FC4B45"
        static let verifyItems_complaintCell_BG = "FBFBFB"
//        static let verifyItems_complaintCell_submitBtn_BG = "E0E0E0"
        static let verifyItems_complaintCell_submitBtn_title = "FFFFFF"
        static let verifyItems_complaintCell_border = "E9E9E9"
        
        
        static let shopDetails_leftHeader_title = "434343"
        static let shopDetails_rightHeader_title = "9F20AE"
        static let shopDetails_Table_BG = "EAEAEA"
        static let shopDetails_cell_text = "000000"
        static let shopDetails_DetailsCell_BG = "FFFFFF"
        static let shopDetails_itemCell_BG = "F5F5F5"
        static let shopDetails_orderCount_title = "9F20AE"
        
        static let customOrder_bottomBtn_BG = "89C450"
        static let customOrder_bottomBtn_title = "FFFFFF"
        static let customOrder_table_bg = "ECECEC"
        static let customOrder_table_footer_bg = "D8D8D8"
        static let customOrder_catCell_Content_BG = "FAFAFA"
        static let customOrder_catCell_content_darkBG = "E0E0E0"
        static let customOrder_catCell_left_title = "434343"
        static let customOrder_catCell_right_title = "9C27B0"
        static let customOrder_shopCell_text = "000000"
        static let customOrder_shopCell_BG = "E5E5E5"
        static let customOrder_itemCell_BG = "F5F5F5"
        static let customOrder_itemCell_text = "000000"
        static let customOrder_priceLabel_BG = "FDFDFD"
        static let customOrder_priceLabel_border = "E3E3E3"
        static let customOrder_priceLabel_text = "EC3F7A"
        
        static let storeFeedBack_view_BG = "F5F5F5"
        static let storeFeedBack_storeName_text = "9C27B0"
        static let storeFeedBack_deliveryDate_text = "434343"
        static let storeFeedBack_cell_BG = "EAEAEA"
        static let storeFeedBack_cell_text = "000000"
        static let storeFeedBack_submitBtn_BG   =   "FFFFFF"
        
        static let productDescVC_detailTable_BG = "fafafa"
        static let productDescVC_detailTable_border = "e1e1e1"
        static let productDescVC_addCartBtn_BG = "4CAF50"
        static let productDescVC_tabBtn_BG = "dfdfdf"
        static let productDescVC_tabBtn_selection_BG = "FFFFFF"
        static let productDescVC_tabBtn_border = "dfdfdf"
        static let productDescVC_otherInfoLbl_BG = "f5f5f5"
        static let productDescVC_otherInfoLbl_border = "c4c4c4"
        static let productDescVC_reviewsLabel_BG = "f5f5f5"

        static let AddCardVC_saveButton_NoInteraction_BG = "AAAAAA"
        static let AddCardVC_saveButton_withInteraction_BG = "8BC34A"
        
        static let MessageRootVC_BG = "EAEAEA"
        static let MessageRootVC_cell_BG = "F5F5F5"
        static let MessageRootVC_cell_title = "616161"
        static let MessageRootVC_cell_qty = "7A7A7A"
        static let MessageRootVC_cell_issue = "FD5353"
        static let MessageRootVC_cell_count = "FFFFFF"
        static let MessageRootVC_cell_count_BG = "FE3A3A"
        
        static let MessageVC_header_bg = "F9F9F9"
        static let MessageVC_header_title = "949494"
        static let MessageVC_line_bg = "EFEFEF"
        static let MessageVC_toolBar_bg = "F5F5F5"
        static let MessageVC_textView_border = "E3E3E3"
        static let MessageVC_normalMessage_incomingBG = "F2FBE7"
        static let MessageVC_normalMessage_outgoingBG = "F0FAFF"
        static let MessageVC_actionMessage_outgoingBG = "FAFAFA"
        static let MessageVC_actionMessage_incomingBG = "FAFAFA"
        static let MessageVC_message_text = "3C3C3D"
        static let MessageVC_message_cancel_border = "FE4949"
        static let MessageVC_message_denyBtn_bg = "FF2727"
        static let MessageVC_message_acceptBtn_bg = "8BE126"
        static let MessageVC_actionMessage_bg = "FAFAFA"
        static let MessageVC_actionMessageIncomingHeader_bg = "F2FBE7"
        static let MessageVC_actionMessageOutgoingHeader_bg = "F0FAFF"
        
        static let InviteVC_referralLbl_BG = "F5F5F5"
        static let InviteVC_infoLbl = "444444"
        static let InviteVC_referralLbl = "4F4F4F"
        
        static let SupportVC_text = "6D6D6D"
        static let SupportVC_border = "C0C0C0"
        static let SupportVC_submitBtn_title = "343434"
        static let SupportDetailsVC_text = "4E4E4E"
        
        //Custom Views
        static let productDescriptionView_labels = "000000"
        static let productDescriptionView_productName_BG = "F5F5F5"
        static let productDescriptionView_closeBtn_BG = "F44336"
        static let productDescriptionView_closeBtn_title = "FFFFFF"
        static let productDescriptionView_addCartBtn_BG = "3EA23E"
        static let productDescriptionView_addCartBtn_title = "FFFFFF"
        static let productDescriptionView_cell_text = "000000"
        
        static let pageControlSingleView_BG = "FFFFFF"
        static let pageControl_BG = "BDBDBD"
        static let pageControl_selection = "000000"
        
        static let EditAddressView_header_lbl = "050505"
        static let EditAddressView_separatorLine = "EBEBEB"
        static let EditAddressView_txtField_BG = "F5F5F5"
        static let EditAddressView_addressType_normal_title = "757575"
        static let EditAddressView_addressType_selected = "0A0A0A"
        static let EditAddressView_cancel_btn_title = "262626"
        static let EditAddressView_cancel_btn_border = "CECECE"
        static let EditAddressView_save_btn_title = "FFFFFF"
        static let EditAddressView_save_btn_bg = "3372D4"
        
        static let ProductReportsVC_productName = "525252"
        static let ProductReportsVC_tableBG = "FBFBFB"
        static let ProductReportsVC_textViewBorder = "E8E8E8"
        static let ProductReportsVC_bottomLine = "E7E7E7"
        
        static let FeedbackPopupView_info_text = "202020"
        static let FeedbackPopupView_name_text = "282828"
        static let FeedbackPopupView_textView_border = "E1E1E1"
        
        static let GSOrderCancellationPopUpView_headerText = "000000"
        static let GSOrderCancellationPopUpView_cell_label = "494949"
        static let GSOrderCancellationPopUpView_cell_Layer_border = "E6E6E6"
        static let GSOrderCancellationPopUpView_cell_txtView_bg = "FAFAFA"
        static let GSOrderCancellationPopUpView_cell_btn_title = "0B0B0B"
        
        static let LastOrderPopUpView_submitBtn_border = "03A9F4"
        static let LastOrderPopUpView_submitBtn_title = "212121"
        static let LastOrderPopUpView_radioBtnTitle = "444444"
        
        static let PromoCodeView_bg = "F5F5F5"
        static let PromoCodeView_header_border = "EAEAEA"
        static let PromoCodeView_limitType = "2C8DDE"
        
        // Pop Ups
        static let popUp1_BG    =   "03A9F4"
        static let popUp2_BG    =   "D5EA00"
        static let popUp3_BG    =   "4CAF50"
        static let popUp4_BG    =   "00BCD4"
        static let popUp5_BG    =   "E94136"
        
        static let popUp1_text  =   "FFFFFF"
        static let popUp2_text  =   "000000"
        static let popUp3_text  =   "FFFFFF"
        static let popUp4_text  =   "FFFFFF"
        static let popUp5_text  =   "FFFFFF"
        
        // Loading indicator
        static let progressBGColor    =   "FFFFFF"
        static let progressBarColor   =   "000000"
        
        static let offerPopup_bg = "D9EB3A"
    }
    
    struct blackTheme {
        
        
    }
}
