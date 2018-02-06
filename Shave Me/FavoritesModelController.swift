//
//  FavoritesModelController.swift
//  Shave Me
//
//  Created by NoorAli on 12/25/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import ObjectMapper

class FavoritesModelController {
    var favoritesListings: FeaturedListings!
    var mPageIndex: Int = 0
    var mStopPagination: Bool = false
    
    func add(newFavoritesListings: FeaturedListings) {
        if var shops = favoritesListings.BarberShop, let newShops = newFavoritesListings.BarberShop {
            for model in newShops {
                if shops.first(where: { model.barberShopid == $0.barberShopid }) == nil {
                    shops.append(model)
                }
            }
            favoritesListings.BarberShop = shops
        } else {
            favoritesListings = newFavoritesListings
        }
    }
    
    class func parseResponse(response: Any?) -> FeaturedListings? {
        if let favoritesListings = Mapper<FeaturedListings>().map(JSONObject: response) {
            for featuredModel in favoritesListings.BarberShop! {
                DBFavorite.addUpdate(barberID: featuredModel.barberShopid, isLiked: true, isUpdated: false)
            }
            return favoritesListings
        }
        return nil
    }
    
    class func updateFavoritesWithServer() {
        // New favorites
        let likedFavorites = DBFavorite.getBy(isLiked: true, isUpdated: true)
        if likedFavorites.count > 0 {
            let likedBarberIDs = likedFavorites.map({"\($0.barberId)"}).joined(separator: ",")
            let model = InsertFavoriteModel(userId: AppController.sharedInstance.loggedInUser!.id, barberIds: likedBarberIDs)
            _ = NetworkManager.postFavourites(model: model) { (methodName, response) in }
        }
        
        let unlikedFavorites = DBFavorite.getBy(isLiked: false, isUpdated: true)
        if unlikedFavorites.count > 0 {
            let unlikedBarberIDs = unlikedFavorites.map({"\($0.barberId)"}).joined(separator: ",")
            _ = NetworkManager.deleteFavourites(barberIds: unlikedBarberIDs, userID: AppController.sharedInstance.loggedInUser!.id) { (methodName, response) in }
        }
        
    }
}
