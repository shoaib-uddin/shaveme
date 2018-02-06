//
//  FeaturedModelController.swift
//  Shave Me
//
//  Created by NoorAli on 1/3/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

class FeaturedModelController {
    var featuredListings: FeaturedListings!
    var mPageIndex: Int = 0
    var mStopPagination: Bool = false
    
    func add(newFeaturedListings: FeaturedListings) {
        if var shops = featuredListings.BarberShop, let newShops = newFeaturedListings.BarberShop {
            for model in newShops {
                if shops.first(where: { model.barberShopid == $0.barberShopid }) == nil {
                    shops.append(model)
                }
            }
            featuredListings.BarberShop = shops
        } else {
            featuredListings = newFeaturedListings
        }
    }
}
