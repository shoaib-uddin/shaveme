//
//  SearchModelController.swift
//  Shave Me
//
//  Created by NoorAli on 12/20/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

class SearchModelController {
    var searchListings: SearchListings!
    var mPageIndex: Int = 0
    var mStopPagination: Bool = false
    
    func add(newSearchListings: SearchListings) {
        if var shops = searchListings.Shop, let newShops = newSearchListings.Shop {
            for model in newShops {
                if shops.first(where: { model.barberShopId == $0.barberShopId }) == nil {
                    shops.append(model)
                }
            }
            searchListings.Shop = shops
        } else {
            searchListings = newSearchListings
        }
    }
}
