//
//  GSScratchCardModel.swift
//  Shopor
//
//  Created by Ratheesh on 30/12/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//



import Foundation

// MARK: - ScratchcardModel
struct ScratchcardModel: Codable {
    let success: Bool?
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let titlemsg: String?
    let cardInfo: [CardInfo]?
    let adInfo: [AdInfo]?
}

// MARK: - AdInfo
struct AdInfo: Codable {
    let id, adID, categoryID, storeID: String?
    let adType: Int?
    let bannerAdInfo: BannerAdInfo?
    let privateIcon: String?
    let textAdInfo: TextAdInfo?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case adID = "ad_id"
        case categoryID = "category_id"
        case storeID = "store_id"
        case adType = "ad_type"
        case bannerAdInfo = "banner_ad_info"
        case privateIcon = "private_icon"
        case textAdInfo = "text_ad_info"

    }
}

// MARK: - BannerAdInfo
struct BannerAdInfo: Codable {
    let image: String?
    let width, height: Int?
}
// MARK: - TextAdInfo
struct TextAdInfo: Codable {
    let adContent: String?
    
    enum CodingKeys: String, CodingKey {
        case adContent = "ad_content"
    }
}
// MARK: - CardInfo
struct CardInfo: Codable {
    let id: String?
    let cardType: Int?
    let promoInfo: PromoInfo?
    let rewardInfo: RewardInfo?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case cardType = "card_type"
        case promoInfo = "promo_info"
        case rewardInfo = "reward_info"

    }
}

// MARK: - PromoInfo
struct PromoInfo: Codable {
    let promoID, promoCode: String?
    let codeModel, codeType, codeValue, maxLimit: Int?
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case promoID = "promo_id"
        case promoCode = "promo_code"
        case codeModel = "code_model"
        case codeType = "code_type"
        case codeValue = "code_value"
        case maxLimit = "max_limit"
        case note
    }
}

// MARK: - RewardInfo
struct RewardInfo: Codable {
    let randomCost: Int?
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case randomCost = "random_cost"
        case note
    }
}

struct ScratchcardActivateModel: Codable {
    let success: Bool?
    let message: String?
}

struct ScratchcardClickedModel: Codable {
    let success: Bool?
    let message: String?
}

struct ScratchcardCountModel: Codable {
    let success: Bool?
    let count: Int?
}
