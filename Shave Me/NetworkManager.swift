//
//  NetworkManager.swift
//  Shave Me
//
//  Created by NoorAli on 12/6/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import SystemConfiguration

class NetworkManager {
    public static func getServices(completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "ln": AppController.sharedInstance.language
        ]
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_SERVICES_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getFacilities(completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "ln": AppController.sharedInstance.language
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_FACILITIES_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getHomeBanner(completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "ln": AppController.sharedInstance.language,
            "pi": "0",
            "ps": "3"
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_HOMEBANNER_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getUserLoginDetails(email: String, password: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "ln": AppController.sharedInstance.language,
            "un": email,
            "pass": password
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_USER_AUTHENTICATION_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getBarberLoginDetails(email: String, password: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "ln": AppController.sharedInstance.language,
            "un": email,
            "pass": password
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_BARBER_AUTHETICATION_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getBarberShopDetails(shopID: Int, userID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        let latitude: Double = AppController.sharedInstance.currenLocation?.coordinate.latitude ?? 0
        let longitude: Double = AppController.sharedInstance.currenLocation?.coordinate.longitude ?? 0
        
        var parameters = [
            "id" : String(shopID),
            "ln" : AppController.sharedInstance.language,
            "la" : String(latitude),
            "lo" : String(longitude),
            "uid": String(userID),
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_BARBERDETAIL_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getBarberUserDetails(barberID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "ln": AppController.sharedInstance.language,
            "uid": String(barberID)
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_BARBER_USER_DETAILS_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getSuggestions(query: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        // TODO: Encode query
        var parameters = [
            "ln": AppController.sharedInstance.language,
            "sn": query
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_SEARCH_SUGGESTIONS, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getReservations(userID: Int, dateTime: String?, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "ln": AppController.sharedInstance.language,
            "uId": String(userID)
        ]
        
        if let dateTime = dateTime {
            parameters["dt"] = dateTime
        }
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_RESERVATION_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getReservationsByStylist(stylistID: Int?, dateTime: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "dt": dateTime,
            "ln": AppController.sharedInstance.language,
            "stylistid": String(stylistID ?? 0)
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_RESERVATION_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }

    
    public static func getSearchByName(query: String, pageIndex: Int, userID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        
        let latitude: Double = AppController.sharedInstance.currenLocation?.coordinate.latitude ?? 0
        let longitude: Double = AppController.sharedInstance.currenLocation?.coordinate.longitude ?? 0
        
        var parameters = [
            "pi": String(pageIndex),
            "ln": AppController.sharedInstance.language,
            "uId": String(userID),
            "f" : "n",
            "ps" : "10",
            "la" : String(latitude),
            "lo" : String(longitude),
            "sn" : query
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_SEARCHBYNAME_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getFeaturedListings(pageIndex: Int, userID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        let latitude: Double = AppController.sharedInstance.currenLocation?.coordinate.latitude ?? 0
        let longitude: Double = AppController.sharedInstance.currenLocation?.coordinate.longitude ?? 0
        
        var parameters = [
            "pi": String(pageIndex),
            "ln": AppController.sharedInstance.language,
            "uid": String(userID),
            "ps" : "10",
            "la" : String(latitude),
            "lo" : String(longitude)
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_FEATURED_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getAdvancedSearch(searchModel: ShopListingSearchModel, pageIndex: Int, userID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        let latitude: Double = AppController.sharedInstance.currenLocation?.coordinate.latitude ?? 0
        let longitude: Double = AppController.sharedInstance.currenLocation?.coordinate.longitude ?? 0
        
        var parameters = [
            "pi": String(pageIndex),
            "ln": AppController.sharedInstance.language,
            "ps" : "10",
            "uId": String(userID),
            "s" : searchModel.SERVICEIDS,
            "f" : searchModel.FACILITISID,
            "cf" : searchModel.COSTFROM,
            "ct" : searchModel.COSTTO,
            "dt" : searchModel.DISTTO,
            "df" : searchModel.DISTFROM,
            "la" : String(latitude),
            "lo" : String(longitude),
            "sn" : searchModel.NAME,
            "sa" : searchModel.ADDRESS
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_ADVANCESEARCH_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getSearchByLocation(latitude: String, longitude: String, pageIndex: Int, userID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        let PROXIMITY = "5"
        
        var parameters = [
            "pi": String(pageIndex),
            "ln": AppController.sharedInstance.language,
            "km" : PROXIMITY,
            "ps" : "10",
            "la" : latitude,
            "lo" : longitude,
            "uId": String(userID)
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_SEARCHBYLOCATION_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getDisableBarberListAPI(stylishtID: Int, dateTime: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        
        var parameters = [
            "sid" : String(stylishtID),
            "dt" : dateTime,
            "type" : "I",
            "ln": AppController.sharedInstance.language
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_DISABLE_BARBER_LIST_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getPassword(userID: Int, oldPassword: String, newPassword: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "newpass" : newPassword,
            "oldpass" : oldPassword,
            "uid": String(userID)
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_CHANGE_PASSWORD, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getUpdatePassword(code: String, password: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters = [
            "code" : code,
            "password" : password
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.UPDATE_PASSWORD_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getReviews(shopID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "ln": AppController.sharedInstance.language,
            "sid": shopID
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_REVIEW, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getStylists(barberID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "ln": AppController.sharedInstance.language,
            "bid": barberID
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_STYLIST_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }

    
    public static func getReportRequest(barberShopId: Int, startDate: String, endDate: String, stylistIDs: String, statusIDs: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        
        var parameters: [String : Any] = [
            "bid": barberShopId,
            "startdate": startDate,
            "enddate": endDate,
            "stylist": stylistIDs,
            "statusid": statusIDs,
            "ln": AppController.sharedInstance.language
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_REPORT_REQUEST, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getBarberReservations(barberID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "ln": AppController.sharedInstance.language,
            "bid": barberID
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_BARBERRESERVATION_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getBarberReservation(reservationID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "ln": AppController.sharedInstance.language,
            "id": reservationID
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_BARBERRESERVATION_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getDisableBarberAllList(barberID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "ln": AppController.sharedInstance.language,
            "bid": barberID
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_DISABLE_BARBER_ALL_LIST_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getGallery(barberID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "ln": AppController.sharedInstance.language,
            "bid": barberID
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_GALLERY_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }

    
    public static func getForgotPassword(email: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "un": email
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_FORGET_PASSWORD_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func getFavourites(userID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        let latitude: Double = AppController.sharedInstance.currenLocation?.coordinate.latitude ?? 0
        let longitude: Double = AppController.sharedInstance.currenLocation?.coordinate.longitude ?? 0
        
        var parameters = [
            "ln": AppController.sharedInstance.language,
            "la" : String(latitude),
            "lo" : String(longitude),
            "uId": String(userID)
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.GET_FAVORITES_API, method: .get, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func deleteFavourites(barberIds: String, userID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "barberIds" : barberIds,
            "uId": String(userID)
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.DELETE_FAVORITES, method: .delete, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func logout(token: String, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "deviceId" : token
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.LOGOUT_API, method: .delete, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func deleteStylist(stylistID: Int, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        var parameters: [String : Any] = [
            "id" : String(describing: stylistID)
        ]
        
        parameters["t"] = ServiceUtils.createHashToken(parameters: parameters)
        
        return request(methodName: ServiceUtils.DELETE_STYLIST_REQUEST, method: .delete, parameters: parameters, completionHandler: completionHandler)
    }
    
    public static func postFavourites(model: InsertFavoriteModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        let params = model.toJSON()
        
        return request(methodName: ServiceUtils.POST_INSERT_FAVOIRTES, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postGallery(model: AddGalleryModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        let params = model.toJSON()
        
        return request(methodName: ServiceUtils.POST_ADD_GALLERY_REQUEST, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postGCMUserRegisterationModel(model: GcmModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        let params = model.toJSON()
        
        return request(methodName: ServiceUtils.POST_GCMREGISTRATIONKEY_API, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postFeaturingRequest(model: FeaturingRequestModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        let params = model.toJSON()
        
        return request(methodName: ServiceUtils.POST_FEATURING_REQUEST, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postGCMShopRegisterationModel(model: GcmShopModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        let params = model.toJSON()
        
        return request(methodName: ServiceUtils.POST_GCMSHOPREGISTRATIONKEY_API, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postRecommendation(model: RecommendationModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        let params = model.toJSON()
        
        return request(methodName: ServiceUtils.POST_RECOMMENDATION_API, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postUserReview(model: UserRatingModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        let params = model.toJSON()
        
        return request(methodName: ServiceUtils.POST_USERREVIEW_API, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postFeedback(model: FeedbackModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        let params = model.toJSON()
        
        return request(methodName: ServiceUtils.POST_FEEBACK_API, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postReview(reviewModel: AddReviewModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        reviewModel.token = ServiceUtils.createHashToken(parameters: reviewModel.toJSON())
        
        let url = ServiceUtils.BASE_URL + ServiceUtils.POST_ADDREVIEW_API
        let params = reviewModel.toJSON()
        
        return Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody).validate().responseJSON { response in
            processResponse(methodName: ServiceUtils.POST_ADDREVIEW_API, response: response, completionHandler: completionHandler)
        }
    }
    
    public static func postRegisteration(model: UserModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        
        let methodName = ServiceUtils.POST_REGISTRATION_API
        let urlStr = ServiceUtils.BASE_URL + methodName
        let params = model.toJSON()
        
        return requestRaw(urlStr: urlStr, methodName: methodName, method: .post, parameters: params, completionHandler: completionHandler)
    }

    public static func postDisableBarber(models: [DisableBarberModel], completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        
        let url = ServiceUtils.BASE_URL + ServiceUtils.POST_DISABLE_BARBER_API
        let params = models.toJSON()
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        return Alamofire.request(request).validate().responseJSON { response in
            processResponse(methodName: ServiceUtils.POST_DISABLE_BARBER_API, response: response, completionHandler: completionHandler)
        }
    }

    public static func updateRegisteration(userID: Int, model: UserModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        
        let methodName = ServiceUtils.UPDATE_REGISTRATION_API
        let urlStr = ServiceUtils.BASE_URL + methodName + String(userID)
        let params = model.toJSON()
        
        let url = URL(string: urlStr)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            completionHandler(methodName, RequestResult(message: "ConnectionError".localized()))
            return nil
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let dataRequest = Alamofire.request(urlRequest)
        dataRequest.validate().responseJSON { response in
            processResponse(methodName: methodName, response: response, completionHandler: completionHandler)
        }
        return dataRequest
    }
    
    public static func updateBarberDetails(model: UpdateShopModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        
        let methodName = ServiceUtils.POST_BARBER_DETAILS_API
        let urlStr = ServiceUtils.BASE_URL + methodName + "?id=" + String(model.barberId!)
        let params = model.toJSON()
        
        let url = URL(string: urlStr)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            completionHandler(methodName, RequestResult(message: "ConnectionError".localized()))
            return nil
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let dataRequest = Alamofire.request(urlRequest)
        dataRequest.validate().responseJSON { response in
            processResponse(methodName: methodName, response: response, completionHandler: completionHandler)
        }
        return dataRequest
    }
    
    public static func updateStylistDetails(model: AddOrUpdateStylistModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        
        let methodName = ServiceUtils.UPDATE_STYLIST_API
        let urlStr = ServiceUtils.BASE_URL + methodName + String(model.StylistId!)
        let params = model.toJSON()
        
        return requestRaw(urlStr: urlStr, methodName: methodName, method: .put, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postStylistDetails(model: AddOrUpdateStylistModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        model.token = ServiceUtils.createHashToken(parameters: model.toJSON())
        
        let methodName = ServiceUtils.POST_ADD_STYLIST_API
        let urlStr = ServiceUtils.BASE_URL + methodName
        let params = model.toJSON()
        
        return requestRaw(urlStr: urlStr, methodName: methodName, method: .post, parameters: params, completionHandler: completionHandler)
    }
    
    public static func postReservation(reservationModel: ReservationConfirmationModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        reservationModel.token = ServiceUtils.createHashToken(parameters: reservationModel.toJSON())
        
        let url = ServiceUtils.BASE_URL + ServiceUtils.POST_RESERVATION_API
        let params = reservationModel.toJSON()
        
        return Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody).validate().responseJSON { response in
            processResponse(methodName: ServiceUtils.POST_RESERVATION_API, response: response, completionHandler: completionHandler)
        }
    }
    
    public static func updateReservation(reservationID: Int, reservationModel: ReservationConfirmationModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        reservationModel.token = ServiceUtils.createHashToken(parameters: reservationModel.toJSON())
        
        let url = ServiceUtils.BASE_URL + ServiceUtils.UPDATE_RESERVATION_API + String(reservationID)
        let params = reservationModel.toJSON()
        
        return Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody).validate().responseJSON { response in
            processResponse(methodName: ServiceUtils.UPDATE_RESERVATION_API, response: response, completionHandler: completionHandler)
        }
    }
    
    public static func updateReservation(reservationID: Int, reservationModel: CancelReservationModel, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        reservationModel.token = ServiceUtils.createHashToken(parameters: reservationModel.toJSON())
        
        let url = ServiceUtils.BASE_URL + ServiceUtils.UPDATE_RESERVATION_API + String(reservationID)
        let params = reservationModel.toJSON()
        
        return Alamofire.request(url, method: .put, parameters: params, encoding: URLEncoding.httpBody).validate().responseJSON { response in
            processResponse(methodName: ServiceUtils.UPDATE_RESERVATION_API, response: response, completionHandler: completionHandler)
        }
    }
    
    static func request(url: String, methodName: String, method: HTTPMethod = .post, parameters: Parameters, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        if ServiceUtils.isConnectedToNetwork() {
            
            let dataRequest = Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding.httpBody)
            dataRequest.validate().responseJSON { response in
                processResponse(methodName: methodName, response: response, completionHandler: completionHandler)
            }
            return dataRequest
        } else {
            completionHandler(methodName, RequestResult(message: "ConnectionError".localized(), code: RequestStatus.CODE_NO_INTERNET_CONNECT))
            return nil
        }
    }
    
    static func request(methodName: String, method: HTTPMethod = .get, parameters: Parameters, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        if ServiceUtils.isConnectedToNetwork() {
            let dataRequest = Alamofire.request(ServiceUtils.BASE_URL + methodName, method: method, parameters: parameters)
            dataRequest.validate().responseJSON { response in
                processResponse(methodName: methodName, response: response, completionHandler: completionHandler)
            }
            return dataRequest
        } else {
            completionHandler(methodName, RequestResult(message: "ConnectionError".localized()))
            return nil
        }
    }
    
    static func requestRaw(urlStr: String, methodName: String, method: HTTPMethod = .post, parameters: Parameters, completionHandler: @escaping (String, RequestResult) -> Void) -> DataRequest? {
        if ServiceUtils.isConnectedToNetwork() {
            let url = URL(string: urlStr)!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method == .put ? "PUT" : "POST"
            
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                completionHandler(methodName, RequestResult(message: "ConnectionError".localized()))
                return nil
            }
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            let dataRequest = Alamofire.request(urlRequest)
            dataRequest.validate().responseJSON { response in
                processResponse(methodName: methodName, response: response, completionHandler: completionHandler)
            }
            return dataRequest
        } else {
            completionHandler(methodName, RequestResult(message: "ConnectionError".localized()))
            return nil
        }
    }

    
    static func processResponse(methodName: String, response: DataResponse<Any>, completionHandler: @escaping (String, RequestResult) -> Void) {
//        print("Request: \(response.request)")
//        print("Response: \(response.response)")
        
        switch response.result {
        case .success:
            if let JSON = response.result.value {
//                print(JSON)
                
                var requestResult: RequestResult? = nil
                
                // If its an error or some kind
                let list = Mapper<ErrorModel>().mapArray(JSONObject: JSON)
                if let list = list {
                    if list.count == 1 && list[0].Message != nil {
                        requestResult = RequestResult(message: list[0].Message)
                    }
                }
                
                // If no error came
                if requestResult == nil {
                    requestResult = RequestResult(value: JSON)
                }
                
                completionHandler(methodName, requestResult!)
            }
        case .failure(let error):
            var errorString = error.localizedDescription
            if let data = response.data, let responseDataStr = String(data: data, encoding: String.Encoding.utf8), let errorArray = Mapper<ErrorModel>().mapArray(JSONString: responseDataStr), errorArray.count > 0, let message = errorArray.first!.Message {
                errorString = message
            }
            completionHandler(methodName, RequestResult(message: errorString))
        }
    }
}

class ServiceUtils {
//        public static let BASE_URL = "http://192.168.1.20/shaveme/api/"
//            public static let BASE_URL = "http://192.168.1.17/shaveme/api/"
    public static let BASE_URL = "http://www.shavemearabia.com/api/"
//    public static let BASE_URL = "http://shaveme.stagingserver-me.com/api/"
    
    public static let GET_HOMEBANNER_API = "homebanner"
    public static let GET_FEATURED_API = "FeatureBarber"
    public static let GET_BARBERDETAIL_API = "Barber"
    public static let GET_SEARCHBYNAME_API = "Barber"
    public static let GET_SEARCHBYADDRESS_API = "Barber?f=a"
    public static let GET_SEARCHBYLOCATION_API = "Barber"
    public static let GET_ADVANCESEARCH_API = "Barber"
    public static let GET_FACILITIES_API = "Facilities"
    public static let GET_SERVICES_API = "Services"
    public static let POST_ADDREVIEW_API = "Review"
    public static let POST_REGISTRATION_API = "UserMaster"
    public static let UPDATE_REGISTRATION_API = "UserMaster?id="
    public static let POST_RESERVATION_API = "ReservationRequest"
    public static let GET_RESERVATION_API = "ReservationRequest"
    public static let UPDATE_RESERVATION_API = "ReservationRequest?id="
    public static let GET_BARBERRESERVATION_API = "ReservationRequest"
    public static let GET_RESERVATIONBYSTYLIST_API = "ReservationRequest?stylistid="
    public static let POST_FEEBACK_API = "Feedback"
    public static let POST_RECOMMENDATION_API = "Recomendation"
    public static let POST_INSERT_FAVOIRTES = "Favorite"
    public static let GET_FAVORITES_API = "Favorite"
    public static let DELETE_FAVORITES = "Favorite"
    public static let GET_USER_AUTHENTICATION_API = "UserMaster?"
    public static let GET_FORGET_PASSWORD_API = "UserMaster"
    public static let UPDATE_PASSWORD_API = "UserMaster"
    public static let GET_CHANGE_PASSWORD = "UserMaster"
    public static let GET_REVIEW = "Review"
    public static let GET_BARBER_AUTHETICATION_API = "ShopUserMaster"
    public static let GET_BARBER_USER_DETAILS_API = "ShopUserMaster"
    public static let POST_BARBER_DETAILS_API = "ShopMaster"
    public static let GET_STYLIST_API = "ShopStylist"
    public static let DELETE_STYLIST_REQUEST = "ShopStylist"
    public static let POST_ADD_STYLIST_API = "ShopStylist"
    public static let UPDATE_STYLIST_API = "ShopStylist?id="
    public static let POST_DISABLE_STYLIST = "ShopStylist?id="
    public static let POST_FEATURING_REQUEST = "ShopFeaturedRequest"
    public static let GET_GALLERY_API = "ShopGallery"
    public static let POST_ADD_GALLERY_REQUEST = "ShopGallery"
    public static let DELETE_GALLERY_API = "ShopGallery?id="
    public static let GET_REPORT_REQUEST = "ShopReport"
    public static let GET_CALENDAR_RESERVATION_API = "ReservationRequest?uId=UID&t=TOKEN"
    public static let GET_CALENDAR_BARBERRESERVATION_API = "ReservationRequest?bid=BID&t=TOKEN"
    public static let GET_GCMREGISTRATIONKEY_API = "GCM"
    public static let POST_GCMREGISTRATIONKEY_API = "PushNotifications"
    public static let POST_GCMSHOPREGISTRATIONKEY_API = "ShopPushNotifications"
    public static let LOGOUT_API = "PushNotifications"
    public static let POST_USERREVIEW_API = "ShopReview"
    public static let GET_DISABLE_BARBER_ALL_LIST_API = "ShopStylistUnAvailability"
    public static let GET_DISABLE_BARBER_LIST_API = "ShopStylistUnAvailability"
    public static let POST_DISABLE_BARBER_API = "ShopStylistUnAvailability"
    public static let GET_SEARCH_SUGGESTIONS = "barber"
    
    public static func createHashToken(parameters: Parameters) -> String? {
        let SECURE_SECRET = "shaveme"
        let SECOND_SECURE_SECRET = "precise"
        
        let sortedKeys = Array(parameters.keys).sorted(by: <)
        
        var string = SECURE_SECRET
        sortedKeys.forEach { (key) in
            if parameters[key] is [[String: Any]] {
            } else if let val = parameters[key] as? Int {
                if  val != 0 {
                    string += String(describing: val)
                }
            } else if let val = parameters[key] as? Double {
                string += String(format: "%g", val)
            } else if key != "imgPath" && key != "image" && key != "profilePic" && key != "token" {
                string += String(describing: parameters[key]!)
            }
        }
        string += SECOND_SECURE_SECRET
        
        return ServiceUtils.MD5(string: string)?.uppercased()
    }
    
    public static func createHashTokenForUpdateShop(parameters: Parameters) -> String? {
        let SECURE_SECRET = "shaveme"
        let SECOND_SECURE_SECRET = "precise"
        
        let sortedKeys = Array(parameters.keys).sorted(by: <)
        
        var string = SECURE_SECRET
        sortedKeys.forEach { (key) in
            if parameters[key] is [String: Any] {
            } else if let val = parameters[key] as? Int {
                if  val != 0 {
                    string += String(describing: val)
                }
            } else if let val = parameters[key] as? Double {
                string += String(format: "%g", val)
            } else if key != "imgPath" && key != "image" && key != "profilePic" {
                string += String(describing: parameters[key]!)
            }
        }
        string += SECOND_SECURE_SECRET
        
        return ServiceUtils.MD5(string: string)?.uppercased()
    }
    
    private static func MD5(string: String) -> String? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        let md5Hex = digestData.map { String(format: "%02hhx", $0) }.joined()
        
        return md5Hex
    }
    
    class func isConnectedToNetwork() -> Bool {
        return AppController.sharedInstance.reachability.isReachable
//        let networkReachability : Reachability = Reachability.reachabilityForInternetConnection()
//        let networkStatus : NetworkStatus = networkReachability.currentReachabilityStatus()
//        
//        if networkStatus == NotReachable {
//            print("No Internet")
//            return false
//        } else {
//            print("Internet Available")
//            return true
//        }
        
    }
}
