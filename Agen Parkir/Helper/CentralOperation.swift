//
//  CentralOperation.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 26/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum OperationState {
    case success, canceled, empty, error
}

enum LoadBuilding {
    case home, booking
}

class FacebookLoginOperation: AbstractOperation {
    var facebookToken: String?
    
    var error: String?
    var state: OperationState?
    
    init(_ facebookToken: String) {
        self.facebookToken = facebookToken
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/fb-callback?token_access=\(facebookToken ?? "")&player_id=\(UserDefaults.standard.string(forKey: StaticVar.onesignal_player_id) ?? "")"
        
        Alamofire.request(url, method: .post).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)["data"]
                print("facebook login data \(data)")
                
                UserDefaults.standard.set(data["token"].string, forKey: StaticVar.token)
                UserDefaults.standard.set(data["email"].string, forKey: StaticVar.email)
                UserDefaults.standard.set(data["id"].int, forKey: StaticVar.id)
                UserDefaults.standard.set(data["name"].string, forKey: StaticVar.name)
                
                self.state = .success
                self.finish(true)
                
            case .failure(let error):
                print("facebook login error \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

//for register
class RegisterOperation: AbstractOperation {
    
    //MARK: Data
    var registerModel: RegisterModel?
    
    //MARK: Props
    var error: String?
    
    init(registerModel: RegisterModel) {
        self.registerModel = registerModel
    }
    
    override func main() {
        if isCancelled {
            self.finish(true)
            return
        }
        
        register()
    }
    
    private func register() {
        let param: [String : String] = [
            "fullName": (registerModel?.fullName)!,
            "email": (registerModel?.email)!,
            "password": (registerModel?.password)!,
            "phone": (registerModel?.phone)!,
            "player_id": UserDefaults.standard.string(forKey: StaticVar.onesignal_player_id)!
        ]
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/register"
        
        Alamofire.request(url, method: .post, parameters: param).responseJSON { (response) in
            
            switch response.result {
            case .success(let responseSuccess):
                print("\(responseSuccess)")
                
                let data = JSON(responseSuccess)
                
                if "\(responseSuccess)".contains("code = 401") {
                    self.error = data["message"].string
                    self.finish(true)
                    return
                } else {
                    self.finish(true)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

//for login
class LoginOperation: AbstractOperation {
    //MARK: Data
    var loginData: (String, String)?
    
    var error: String?
    
    init(loginData: (String, String)) {
        self.loginData = loginData
    }
    
    override func main() {
        if isCancelled {
            self.finish(true)
            return
        }
        
        login()
    }
    
    private func login() {
        let param: [String : String] = [
            "email": (loginData?.0)!,
            "password": (loginData?.1)!,
            "player_id": UserDefaults.standard.string(forKey: StaticVar.onesignal_player_id)!
        ]
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/login"
        
        Alamofire.request(url, method: .post, parameters: param as Parameters).responseJSON { (response) in
            
            switch response.result {
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)
                
                print("data login \(data)")
                
                if data["code"].int == 401 {
                    self.error = data["message"].string
                    self.finish(true)
                    return
                } else if data["data"]["status"].string == "nonactive" {
                    self.error = data["data"]["message"].string
                    self.finish(true)
                    return
                } else if data["data"]["status"].string == "failed" {
                    self.error = data["data"]["message"].string
                    self.finish(true)
                }
                
                UserDefaults.standard.set(data["data"]["token"].string, forKey: StaticVar.token)
                
                self.finish(true)
            case .failure(let error):
                print(error.localizedDescription)
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

//for activation
class ActivationOperation: AbstractOperation {
    var otp: String?
    
    var error: String?
    
    init(otp: String) {
        self.otp = otp
    }
    
    override func main() {
        if isCancelled {
            self.finish(true)
            return
        }
        
        activation()
    }
    
    private func activation() {
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/activation?otp=\(otp ?? "")"
        
        Alamofire.request(url, method: .post).responseJSON { (response) in
            
            switch response.result {
                
            case .success(let responseSuccess):
                print("full response activation \(responseSuccess)")
                
                let data = JSON(responseSuccess)
                
                if "\(responseSuccess)".contains("code = 401") {
                    self.error = data["message"].string
                    self.finish(true)
                } else {
                    print("success activate account")
                    
                    UserDefaults.standard.set(data["data"]["token"].string, forKey: StaticVar.token)
                    UserDefaults.standard.set(data["data"]["email"].string, forKey: StaticVar.email)
                    UserDefaults.standard.set(data["data"]["id"].int, forKey: StaticVar.id)
                    
                    self.finish(true)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

//for forgot password
class ForgotPasswordOperation: AbstractOperation {
    var email: String?
    
    var error: String?
    var message: String?
    
    init(email: String) {
        self.email = email
    }
    
    override func main() {
        if isCancelled {
            self.finish(true)
            return
        }
        
        forgotPassword()
    }
    
    private func forgotPassword() {
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/forgot-password?email=\(email ?? "")"
        
        Alamofire.request(url, method: .post).responseJSON { (response) in
            
            switch response.result {
            case .success(let responseSuccess):
                print("full response \(responseSuccess)")
                
                let data = JSON(responseSuccess)
                
                if "\(responseSuccess)".contains("code = 401") {
                    self.error = data["message"].string
                    self.finish(true)
                    return
                } else {
                    self.message = data["message"].string
                    self.finish(true)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

//for resend email
class ResendEmailOperation: AbstractOperation {
    var email: String?
    
    var error: String?
    var message: String?
    
    init(email: String) {
        self.email = email
    }
    
    override func main() {
        if isCancelled {
            self.finish(true)
            return
        }
        
        resendEmail()
    }
    
    private func resendEmail() {
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/resend_email?email=\(email ?? "")"
        
        Alamofire.request(url, method: .post).responseJSON { (response) in
            let stringResponse = response.description
            
            print("full response \(stringResponse)")
            
            if stringResponse.contains("code = 401") {
                self.error = PublicFunction().errorMessage(stringResponse)
                self.finish(true)
                return
            } else {
                self.message = stringResponse
                print("success resend email code")
                self.finish(true)
            }
        }
    }
}

//for get recently order list
class RecentlyOperation: AbstractOperation {
    //transfered data
    var listRecently = [RecentlyModel]()
    var error: String?
    var state: OperationState?
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/recently?customers_id=\(UserDefaults.standard.string(forKey: StaticVar.id) ?? "")"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            
//            for i in 1...10 {
//                self.listRecently.append(RecentlyModel(venueName: "Venue \(i)", image: "", orderDate: PublicFunction().getCurrentDate(pattern: "yyyy-MM-dd")))
//
//                if i == 10 {
//                    self.state = .success
//                    self.finish(true)
//                }
//            }
            
            switch response.result {
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)
                print("data recently: \(data)")

                if data["data"].array?.count == 0 {
                    print("recently array is empty")
                    self.state = .empty
                    self.finish(true)
                    return
                }

                self.state = .success

                for (index, recently) in (data["data"].array?.enumerated())! {
                    let recentlyModel = RecentlyModel(venueName: recently["name"].string!, image: recently["images"].string!, orderDate: recently["last_booked"].string ?? "Booking Incomplete", building_id: recently["building_id"].int!)

                    self.listRecently.append(recentlyModel)

                    if index == (data["data"].array?.count)! - 1 {
                        self.finish(true)
                    }
                }

            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

//for get billboard list
class BillboardOperation: AbstractOperation {
    var listBillboard = [BillboardModel]()
    var error: String?
    var state: OperationState?
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/billboard"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            
            switch response.result{
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)
                
                print("data billboard: \(data)")
                
                if data["data"].array?.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }
                
                self.state = .success
                
                for (index, recently) in (data["data"].array?.enumerated())! {
                    let billboardModel = BillboardModel(image: recently["images"].string!, id: recently["store_id"].int!)
                    
                    print(billboardModel)
                    
                    self.listBillboard.append(billboardModel)
                    
                    if index == (data["data"].array?.count)! - 1 {
                        self.finish(true)
                    }
                }
                
            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

//for get current profile
class CurrentOperation: AbstractOperation {
    var currentModel: CurrentModel?
    var error: String?
    
    override func main() {
        if isCancelled{
            self.finish(true)
            return
        }
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: StaticVar.token) ?? "")"
        ]
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/current"
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON { (response) in
            
            switch response.result {
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)["data"]
                
                print("current data \(data)")
                
                if data["data"]["status"].string == "expired" {
                    self.error = "Your session is end, please login again"
                    self.finish(true)
                    return
                }
                
                let amount_my_card = String((data["my_card"].string?.dropLast(3))!)
                let phone = data["phone"].int ?? 0123456789
                UserDefaults.standard.set(amount_my_card, forKey: StaticVar.my_card)
                UserDefaults.standard.set(data["name"].string!, forKey: StaticVar.name)
                UserDefaults.standard.set("\(phone)", forKey: StaticVar.phone)
                UserDefaults.standard.set(data["email"].string, forKey: StaticVar.email)
                UserDefaults.standard.set(data["id"].int, forKey: StaticVar.id)
                
                //connect to sendbird
                //menambahkan proxy customer untuk aplikasi agen parkir, dan store untuk store dan officer untuk juru parkir
                PublicFunction().connectSendbird("customer_\(data["id"].int!)", data["name"].string!, "")
                
                guard let image = data["images"].string else {
                    UserDefaults.standard.set("", forKey: StaticVar.images)
                    self.currentModel = CurrentModel(data["id"].int!, data["name"].string!, data["email"].string!, phone, "", data["my_card"].string!)
                    self.finish(true)
                    return
                }
                
                UserDefaults.standard.set(image, forKey: StaticVar.images)
                self.currentModel = CurrentModel(data["id"].int!, data["name"].string!, data["email"].string!, phone, image, data["my_card"].string!)
                self.finish(true)
                
            case .failure(let error):
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

//for get services list
class ServicesOperation: AbstractOperation {
    var listServices = [ServicesModel]()
    var error: String?
    var state: OperationState?

    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }

        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/services"

        Alamofire.request(url, method: .get).responseJSON { (response) in

//            for i in 1...3 {
//                self.listServices.append(ServicesModel("", "Service Title \(i)", "Service description \(i)", "Today"))
//
//                if i == 3 {
//                    self.state = .success
//                    self.finish(true)
//                }
//            }
            
            switch response.result{
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)

                if data["data"].array?.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }

                self.state = .success

                for (index, service) in (data["data"].array?.enumerated())! {
                    let serviceModel = ServicesModel(service["images"].string!, service["title"].string!, service["description"].string!, service["date"].string!)

                    self.listServices.append(serviceModel)

                    if index == (data["data"].array?.count)! - 1 {
                        self.finish(true)
                    }
                }


            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }

        }
    }
}

//for get list building
class ShowListBuildingOperation: AbstractOperation {
    var listBuilding = [BuildingModel]()
    var error: String?
    var state: OperationState?
    
    var data: (pageNumber: Int, purpose: LoadBuilding, nameQuery: String)?
    
    init(_ data: (pageNumber: Int, purpose: LoadBuilding, nameQuery: String)) {
        self.data = data
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/list-building?name=\(data?.nameQuery ?? "")&latitude=\(UserDefaults.standard.string(forKey: StaticVar.latitude) ?? "")&longitude=\(UserDefaults.standard.string(forKey: StaticVar.longitude) ?? "")&page=\(data!.pageNumber)"
        
        print("show building url \(url)")
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            
            switch response.result {
            case .success(let responseSuccess):
                
                let data = JSON(responseSuccess)
                
                print("list building data \(data)")
                
                let list = data["data"].array
                
                if list?.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }
                
                self.state = .success
                
                for (index, building) in (list?.enumerated())! {
                    var buildingModel = BuildingModel()
                    buildingModel.building_id = building["building_id"].int
                    buildingModel.name_building = building["name_building"].string
                    buildingModel.motor = building["motor"].int
                    buildingModel.mobil = building["mobil"].int
                    buildingModel.has_outdoor = building["has_outdoor"].int
                    buildingModel.has_indoor = building["has_indoor"].int
                    buildingModel.has_mobil = building["has_mobil"].int
                    buildingModel.has_motor = building["has_motor"].int
                    buildingModel.has_standard = building["has_standard"].int
                    buildingModel.has_valet = building["has_valet"].int
                    buildingModel.has_store = building["has_store"].int
                    buildingModel.has_ticketing = building["has_ticketing"].int
                    buildingModel.images = building["images"].string
                    buildingModel.index = index + 1
                    buildingModel.address = building["address"].string
                    self.listBuilding.append(buildingModel)
                    
                    if self.data?.purpose == .home {
                        if index == 4 {
                            self.finish(true)
                            break
                        }
                    }
                    
                    if index == (list?.count)! - 1 {
                        self.finish(true)
                    }
                }
            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

class LogoutOperation: AbstractOperation {
    var error: String?
    
    override func main() {
        if isCancelled {
            self.finish(true)
            return
        }
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: StaticVar.token) ?? "")"
        ]
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/logout?customers_id=\(UserDefaults.standard.string(forKey: StaticVar.id) ?? "")"
        
        Alamofire.request(url, method: .post, headers: headers).responseJSON { (response) in
            
            switch response.result {
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)
                
                print("data logout \(data)")
                
                if data["message"].string == "Successfully logged out" {
                    self.finish(true)
                } else {
                    self.error = "Error while loging you out, please check your interner connection"
                    self.finish(true)
                }
            case .failure(let error):
                self.error = error.localizedDescription
            }
            
        }
    }
}

class AccountOperation: AbstractOperation {
    var account: (name: String, imageUrl: String, imageData: UIImage)?
    
    var error: String?
    
    init(_ account: (name: String, imageUrl: String, imageData: UIImage)) {
        self.account = account
    }
    
    override func main() {
        if isCancelled {
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/account"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: StaticVar.token) ?? "")"
        ]
        
        let params: [String: String] = [
            "name": (account?.name)!,
            "customer_id": UserDefaults.standard.string(forKey: StaticVar.id)!
        ]
        
        if account?.imageUrl != "" {
            let data = account?.imageData.jpegData(compressionQuality: 0.5)
            let type = account?.imageUrl.components(separatedBy: ".")[1]
            
            saveWithImage(url, params, headers, imageData: data!, (account?.imageUrl)!, type!)
        } else {
            self.saveDataTextOnly(url: url, params: params, headers: headers)
        }
    }
    
    private func saveDataTextOnly(url: String, params: [String: String], headers: [String: String]) {
        Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            
            print("original data account \(response)")
            
            switch response.result {
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)
                print("data account \(data)")
                if data["message"] == "success" {
                    UserDefaults.standard.set(data["data"]["name"].string, forKey: StaticVar.name)
                    self.finish(true)
                } else {
                    self.error = "Error updating your account"
                    self.finish(true)
                }
            case .failure(let error):
                print("error data account \(error.localizedDescription)")
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
    
    private func saveWithImage(_ url: String, _ params: [String: String], _ headers: [String: String], imageData: Data, _ fileName: String, _ type: String){
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "images", fileName: fileName, mimeType: "image/\(type)")
            
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: url, method: .post, headers: headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    print("success upload \(JSON(response.result.value as Any))")
                    self.finish(true)
                }
                
            case .failure(let encodingError):
                print("error upload \(encodingError.localizedDescription)")
                self.error = encodingError.localizedDescription
                self.finish(true)
            }
        }
        
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            for (key, value) in params {
//                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
//            }
//
//            if let data = imageData {
//                multipartFormData.append(data, withName: "images", fileName: fileName, mimeType: "image/\(type)")
//            }
//
//        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
//            switch result{
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    print("Succesfully uploaded")
//                    if let err = response.error{
//                        onError?(err)
//                        return
//                    }
//                    onCompletion?(nil)
//                }
//            case .failure(let error):
//                print("Error in upload: \(error.localizedDescription)")
//                onError?(error)
//            }
//        }
    }
}

class PostPlateOperation: AbstractOperation {
    var dataPlate: (vehicle_id: String, number_plate: String, title: String)?
    
    var error: String?
    var state: OperationState?
    
    init(dataPlate: (vehicle_id: String, number_plate: String, title: String)) {
        self.dataPlate = dataPlate
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let params: [String: String] = [
            "customers_id": UserDefaults.standard.string(forKey: StaticVar.id)!,
            "vehicle_id": (dataPlate?.vehicle_id)!,
            "number_plate": (dataPlate?.number_plate)!,
            "title": (dataPlate?.title)!
        ]
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/post-plate"
        
        Alamofire.request(url, method: .post, parameters: params).responseJSON { (response) in
            
            switch response.result{
            case .success(let success):
                print("data post plate \(success)")
                let data = JSON(success)
                
                if data["message"].string == "success" {
                    self.state = .success
                    
                } else {
                    self.state = .error
                    self.error = "Error registered plate"
                }
                
                self.finish(true)
            case .failure(let error):
                print("error post plate \(error.localizedDescription)")
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
        
    }
}

class ShowListPlateOperation: AbstractOperation {
    var listPlate = [PlateModel]()
    var state: OperationState?
    var error: String?
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/list-plate/\(UserDefaults.standard.string(forKey: StaticVar.id) ?? "")"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            
            switch response.result {
            case .success(let success):
                print("data list plate \(success)")
                let data = JSON(success)
                let array = data["data"].array
                
                if array?.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }
                
                for (index, plate) in (array?.enumerated())! {
                    self.listPlate.append(PlateModel(plate["plate_id"].int!, plate["vehicle_id"].int!, plate["number_plate"].string!, plate["title_plate"].string!))
                    
                    if index == (array?.count)! - 1 {
                        self.state = .success
                        self.finish(true)
                    }
                }
            case .failure(let error):
                print("error list plate \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

class DeletePlateOperation: AbstractOperation {
    let plateID: String?
    
    var state: OperationState?
    var error: String?
    
    init(_ plateID: String) {
        self.plateID = plateID
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/delete-plate?plate_id=\(plateID ?? "")"
        
        Alamofire.request(url, method: .post).responseJSON { (response) in
            
            switch response.result {
            case .success(let success):
                print("data delete plate \(success)")
                let data = JSON(success)
                
                if data["message"].string == "success" {
                    self.state = .success
                    self.finish(true)
                } else {
                    self.state = .error
                    self.error = "There was something error with system, please try again"
                    self.finish(true)
                }
            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                print("error delete plate \(error.localizedDescription)")
            }
            
        }
    }
}

class DetailBuildingOperation: AbstractOperation {
    var buildingId: Int?
    
    var buildingModel: BuildingModel?
    var state: OperationState?
    var error: String?
    
    init(buildingId: Int) {
        self.buildingId = buildingId
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/building?buildings_id=\(buildingId!)"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)
                print("building data \(data)")
                
                self.buildingModel = BuildingModel()
                self.buildingModel!.building_id = data["data"]["building_id"].int
                self.buildingModel!.name_building = data["data"]["name_building"].string
                self.buildingModel!.motor = data["data"]["motor"].int
                self.buildingModel!.mobil = data["data"]["mobil"].int
                self.buildingModel!.has_outdoor = data["data"]["has_outdoor"].int
                self.buildingModel!.has_indoor = data["data"]["has_indoor"].int
                self.buildingModel!.has_mobil = data["data"]["has_mobil"].int
                self.buildingModel!.has_motor = data["data"]["has_motor"].int
                self.buildingModel!.has_standard = data["data"]["has_standard"].int
                self.buildingModel!.has_valet = data["data"]["has_valet"].int
                self.buildingModel!.has_store = data["data"]["has_store"].int
                self.buildingModel!.has_ticketing = data["data"]["has_ticketing"].int
                self.buildingModel!.images = data["data"]["images"].string
                self.buildingModel!.category_id = data["data"]["category_id"].int
                self.buildingModel!.category_name = data["data"]["category_name"].string
                
                self.state = .success
                
                self.finish(true)
                
            case .failure(let error):
                print("error building data \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class BookingOperation: AbstractOperation {
    var bookingData: (building_id: String, parking_types: String, vehicle_types: String, voucher_id: String, type: String, plate: String, payment_type_id: String)?
    
    var returnBookingData: (order_id: Int, booking_code: String, parking_lot: Int, area_name: String, customer_name: String, building_name: String, is_percentage: Int, plate_number: String, sub_tariff: Int, total: Int)?
    var state: OperationState?
    var error: String?
    
    init(bookingData: (building_id: String, parking_types: String, vehicle_types: String, voucher_id: String, type: String, plate: String, payment_type_id: String)) {
        self.bookingData = bookingData
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let param: [String: String] = [
            "building_id": (bookingData?.building_id)!,
            "parking_types": (bookingData?.parking_types)!,
            "vehicle_types": (bookingData?.vehicle_types)!,
            "voucher_id": (bookingData?.voucher_id)!,
            "type": (bookingData?.type)!,
            "plate": (bookingData?.plate)!,
            "customer_id": UserDefaults.standard.string(forKey: StaticVar.id)!,
            "payment_type_id": (bookingData?.payment_type_id)!
        ]
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/booking"
        
        Alamofire.request(url, method: .post, parameters: param).responseJSON { (response) in
            
            switch response.result{
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)["data"]
                print("booking data \(responseSuccess)")
                
                if JSON(responseSuccess)["code"].int == 400 {
                    self.state = .error
                    self.error = JSON(responseSuccess)["message"].string
                    self.finish(true)
                    return
                }
                
                self.returnBookingData = (order_id: data["order_id"].int, booking_code: data["booking_code"].string, parking_lot: data["parking_lot"].int, area_name: data["area_name"].string, customer_name: data["customer_name"].string, building_name: data["building_name"].string, is_percentage: data["is_percentage"].int, plate_number: data["plate_number"].string, sub_tariff: data["sub_tariff"].int, total: data["total"].int) as? (order_id: Int, booking_code: String, parking_lot: Int, area_name: String, customer_name: String, building_name: String, is_percentage: Int, plate_number: String, sub_tariff: Int, total: Int)
                
                UserDefaults.standard.set(data["parking_lot"].int, forKey: StaticVar.parking_lot)
                UserDefaults.standard.set(data["total"].int, forKey: StaticVar.last_total_price)
                UserDefaults.standard.set(data["vehicle_types"].string, forKey: StaticVar.last_vehicle_type)
                UserDefaults.standard.set(data["parking_types"].string, forKey: StaticVar.last_parking_type)
                UserDefaults.standard.set(data["payment_types_id"].string, forKey: StaticVar.last_payment_type)
                UserDefaults.standard.set(self.bookingData?.type, forKey: StaticVar.last_place_type)
                
                self.state = .success
                self.finish(true)
            case .failure(let error):
                print("error booking \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

class OrderOperation: AbstractOperation {
    var order_id: String?
    
    var state: OperationState?
    var error: String?
    
    init(order_id: String) {
        self.order_id = order_id
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/order?orders_id=\(order_id ?? "")"
        
        Alamofire.request(url, method: .post).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)
                print("order data \(data)")
                
                if data["code"].int == 400 {
                    self.state = .error
                    self.finish(true)
                    return
                }
                
                self.state = .success
                
                self.finish(true)
            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class CancelBookingOperation: AbstractOperation {
    var orders_id: String?
    
    var state: OperationState?
    var error: String?
    
    init(orders_id: String) {
        self.orders_id = orders_id
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/cancel-order?orders_id=\(orders_id ?? "")"
        
        Alamofire.request(url, method: .post).responseJSON { (response) in
            
            switch response.result {
            case .success(let success):
                let data = JSON(success)
                print("Cancel booking operation \(data)")
                
                if data["code"].int == 400 {
                    self.state = .error
                    self.finish(true)
                    return
                }
                
                self.state = .success
                
                self.finish(true)
            case .failure(let error):
                print("cancel booking operation error \(error.localizedDescription)")
                self.error = error.localizedDescription
                self.state = .error
                self.finish(true)
            }
            
        }
    }
}

class ListOngoingOperation: AbstractOperation {
    //transfered data
    var listOngoing = [OngoingModel]()
    var state: OperationState?
    var error: String?
    
    var vehicle_type: Int?
    
    init(vehicle_type: Int) {
        self.vehicle_type = vehicle_type
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/list-ongoing?customers_id=\(UserDefaults.standard.string(forKey: StaticVar.id) ?? "")"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)["data"]["parking"]
                
                guard let _ = data["order_id"].int else {
                    self.state = .error
                    self.error = "You have no active booking yet"
                    self.finish(true)
                    return
                }
                
                print("ongoing data \(data)")
                
                var ongoingModel = OngoingModel()
                ongoingModel.building_name = data["building_name"].string
                ongoingModel.booking_start_time = data["booking_start_time"].string
                ongoingModel.order_id = data["order_id"].int
                ongoingModel.plate_number = data["plate_number"].string
                ongoingModel.name_customers = data["name_customers"].string
                ongoingModel.booking_status_id = data["booking_status_id"].int
                ongoingModel.payment_status = data["payment_status"].int
                ongoingModel.isNonCash = data["isNonCash"].int
                ongoingModel.latitude = data["latitude"].string
                ongoingModel.longitude = data["longitude"].string
                ongoingModel.booking_code = data["booking_code"].string
                ongoingModel.vehicle_type = self.vehicle_type
                ongoingModel.removeTimer = false
                
                self.listOngoing.append(ongoingModel)
                
                self.state = .success
                self.finish(true)
                
            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class DetailOngoingOperation: AbstractOperation {
    var order_id: Int?
    
    var returnDetailOngoing: (parking_lot: String, booking_code: String, tariff: Int, plate_number: String, building_name: String, vehicle_types_id: Int, parking_types: Int, type: String, payment_types_id: Int, name_areas: String, images: [String], store_list: [String])?
    var state: OperationState?
    var error: String?
    
    init(order_id: Int) {
        self.order_id = order_id
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/list-ongoing-details/?orders_id=\(order_id!)"
        
        print("detail ongoind url \(url)")
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)["data"]
                let building = data["building"]
                let images = data["images"].array
                //let stores = data["store_list"].array
                var listImage = [String]()
                let listStore = [String]()
                print("detail ongoing data \(data)")
                
                for image in images! {
                    listImage.append((image["images"].string ?? nil)!)
                }
                
//                for store in stores! {
//                    listStore.append(store["images"].string ?? "")
//                }
                
                self.returnDetailOngoing = (parking_lot: data["parking_lot"].string!, booking_code: data["booking_code"].string!, tariff: data["tariff"].int!, plate_number: data["plate_number"].string!, building_name: building["building_name"].string!, vehicle_types_id: building["vehicle_types_id"].int!, parking_types: building["parking_types"].int!, type: building["type"].string!, payment_types_id: building["payment_types_id"].int!, name_areas: building["name_areas"].string!, images: listImage, store_list: listStore)
                
                self.state = .success
                self.finish(true)
                
            case .failure(let error):
                self.error = error.localizedDescription
                self.state = .error
                self.finish(true)
            }
        }
    }
}

class ListReceiptsOperation: AbstractOperation {
    var currentPage: Int?
    
    var listReceipts = [ReceiptsModel]()
    var state: OperationState?
    var error: String?
    
    init(currentPage: Int) {
        self.currentPage = currentPage
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/list-receipt/?customers_id=\(UserDefaults.standard.string(forKey: StaticVar.id) ?? "")&page=\(currentPage!)"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let list = JSON(success)["data"].array
                
                if list?.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }
                
                self.state = .success
                
                for (index, receipt) in (list?.enumerated())! {
                    let details = receipt["details"]
                    var receiptsModel = ReceiptsModel()
                    receiptsModel.orders_id = receipt["orders_id"].int!
                    receiptsModel.booking_status_id = receipt["booking_status_id"].int!
                    receiptsModel.booking_code = details["booking_code"].string!
                    receiptsModel.payment_types = details["payment_types"].int!
                    //receiptsModel.booking_tax = details["booking_tax"].
                    receiptsModel.booking_sub_total = details["booking_sub_total"].int!
                    receiptsModel.booking_total = details["booking_total"].int!
                    receiptsModel.vouchers_nominal = details["vouchers_nominal"].int!
                    receiptsModel.customers_name = details["customers_name"].string!
                    receiptsModel.customers_images = details["customers_images"].string!
                    receiptsModel.building_name = details["building_name"].string!
                    receiptsModel.booking_start_time = details["booking_start_time"].string ?? ""
                    receiptsModel.parking_lot = details["parking_lot"].string!
                    receiptsModel.plate_number = details["plate_number"].string!
                    receiptsModel.parking_types = details["parking_types"].int!
                    receiptsModel.vehicle_types = details["vehicle_types"].int!
                    
                    self.listReceipts.append(receiptsModel)
                    
                    if index == (list?.count)! - 1 {
                        self.finish(true)
                    }
                }
                
            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class SubmitReceipts: AbstractOperation {
    var order_id: Int?
    
    //var receiptModel: ReceiptsModel?
    var state: OperationState?
    var error: String?
    
    init(order_id: Int) {
        self.order_id = order_id
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
    
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/list-receipt-submit/?orders_id=\(order_id!)"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)
                
                print("submit receipts data \(data)")
                
                self.state = .success
                self.finish(true)
            case .failure(let error):
                print("detail receipt data \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class TopupOperation: AbstractOperation {
    var gross_amount: Int?
    
    var orders_id: Int?
    var state: OperationState?
    var error: String?
    
    init(_ gross_amount: Int) {
        self.gross_amount = gross_amount
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/top-up"
        
        let params: [String: Any] = [
            "gross_amount": gross_amount as Any,
            "customers_id": Int(UserDefaults.standard.string(forKey: StaticVar.id)!) as Any
        ]
        
        Alamofire.request(url, method: .get, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            
            switch response.result {
            case .success(let success):
                let data = JSON(success)
                print("gross amount data \(data)")
                self.orders_id = data["orders_id"].int
                self.state = .success
                self.finish(true)
            case .failure(let error):
                print("gross amount error \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
            
        }
    }
}

class TopupCreditCardOperation: AbstractOperation {
    var topupData: (order_type: String, order_id: Int, gross_amount: Int, customers_id: Int)?
    
    var state: OperationState?
    var error: String?
    var token: String?
    
    init(topupData: (order_type: String, order_id: Int, gross_amount: Int, customers_id: Int)) {
        self.topupData = topupData
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/snap-token"
        
        let param: [String: Any] = [
            "order_type": topupData?.order_type as Any,
            "order_id": topupData?.order_id as Any,
            "gross_amount": topupData?.gross_amount as Any,
            "customers_id": topupData?.customers_id as Any
        ]
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)
                print("topup credit card data \(data)")
                
                if "\(success)".contains("error_messages") {
                    self.state = .error
                    self.error = data["error_messages"][0].string
                    self.finish(true)
                    return
                }
                
                self.token = data["token"].string
                self.state = .success
                self.finish(true)
            case .failure(let error):
                print("topup credit card error \(error.localizedDescription)")
                self.error = error.localizedDescription
                self.state = .error
                self.finish(true)
            }
        }
    }
}

class HistoryOperation: AbstractOperation {
    var dataHistory: (customer_id: String, current_page: Int)?
    
    var listHistory = [HistoryModel]()
    var state: OperationState?
    var error: String?
    
    init(_ dataHistory: (customer_id: String, current_page: Int)) {
        self.dataHistory = dataHistory
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/history-my-card?customers_id=\(dataHistory?.customer_id ?? "")&page=\(dataHistory?.current_page ?? 1)"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let list = JSON(success)["data"].array
                
                if list?.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }
                
                self.state = .success
                
                for (index, history) in (list?.enumerated())! {
                    var historyModel = HistoryModel()
                    historyModel.nominal = history["nominal"].string!
                    historyModel.trans_date = history["trans_date"].string!
                    historyModel.event_id = history["event_id"].int!
                    
                    self.listHistory.append(historyModel)
                    
                    if index == (list?.count)! - 1 {
                        self.finish(true)
                    }
                }
                
            case .failure(let error):
                self.state = .error
                self.finish(true)
                self.error = error.localizedDescription
            }
        }
    }
}

class TicketOperation: AbstractOperation {
    var building_id: Int?
    
    var venueTicketModel: VenueTicketModel?
    var listTicket = [TicketModel]()
    var error: String?
    var state: OperationState?
    
    init(building_id: Int) {
        self.building_id = building_id
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/ticket?buildings_id=\(building_id!)"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)["data"]
                let jsonArrayTicket = data["ticketing"].array
                print("ticket data \(data)")
                
                if jsonArrayTicket?.count == 0 {
                    self.venueTicketModel = VenueTicketModel(data["name_building"].string!, data["address"].string!, data["images_building"].string!, data["count_event"].int!, self.listTicket)
                    
                    print("no ticketing in this venue")
                    self.state = .success
                    self.finish(true)
                } else {
                    for (index, ticket) in (jsonArrayTicket?.enumerated())! {
                        var ticketModel = TicketModel()
                        ticketModel.tickets_id = ticket["tickets_id"].int!
                        ticketModel.images = ticket["images"].string ?? ""
                        ticketModel.schedule = ticket["schedule"].string!
                        ticketModel.name = ticket["name"].string!
                        ticketModel.price = ticket["price"].int!
                        ticketModel.quantity = ticket["quantity"].int!
                        ticketModel.limit_ticket = ticket["limit_ticket"].int!
                        ticketModel.limit_ticket_to = ticket["limit_ticket_to"].int!
                        ticketModel.buildings_id = ticket["buildings_id"].int!
                        ticketModel.reedem_date = ticket["reedem_date"].string!

                        self.listTicket.append(ticketModel)

                        if index == (jsonArrayTicket?.count)! - 1 {
                            self.venueTicketModel = VenueTicketModel(data["name_building"].string!, data["address"].string!, data["images_building"].string!, data["count_event"].int!, self.listTicket)
                            self.state = .success
                            self.finish(true)
                        }
                    }
                }
                
            case .failure(let error):
                print("ticket error \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class TicketOrderOperation: AbstractOperation {
    var orderData: (tickets_id: String, customers_id: String, quantity_order: String, payment_types_id: String)?
    
    var token: String?
    var state: OperationState?
    var error: String?
    
    init(_ orderData: (tickets_id: String, customers_id: String, quantity_order: String, payment_types_id: String)) {
        self.orderData = orderData
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/ticket-order?tickets_id=\(orderData!.tickets_id)&customers_id=\(UserDefaults.standard.string(forKey: StaticVar.id) ?? "")&quantity_order=\(orderData!.quantity_order)&payment_types_id=\(orderData!.payment_types_id)"
        
        Alamofire.request(url, method: .post).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)
                print("ticket order data \(data)")
                
                if "\(data)".contains("token") {
                    self.token = data["token"].string!
                }
                
                self.state = .success
                self.finish(true)
            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class TicketDetailOperation: AbstractOperation {
    var orders_id: String?
    
    var ticketDetail: TicketDetailModel?
    var state: OperationState?
    var error: String?
    
    init(_ orders_id: String) {
        self.orders_id = orders_id
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/list-ongoing-details-ticket?orders_id=\(orders_id!)"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)["data"]
                self.ticketDetail = TicketDetailModel()
                self.ticketDetail?.tickets_id = data["tickets_id"].int!
                self.ticketDetail?.buildings_id = data["buildings_id"].int!
                self.ticketDetail?.tickets_name = data["tickets_name"].string!
                self.ticketDetail?.schedule = data["schedule"].string!
                self.ticketDetail?.reedem_date = data["reedem_date"].string!
                self.ticketDetail?.description = data["description"].string!
                self.ticketDetail?.images = data["images"].string ?? ""
                self.ticketDetail?.building_name = data["building_name"].string!
                self.ticketDetail?.booking_code = data["booking_code"].string!
                self.ticketDetail?.customers_id = data["customers_id"].int!
                self.ticketDetail?.booking_sub_total = data["booking_sub_total"].int!
                self.ticketDetail?.booking_total = data["booking_total"].int!
                self.ticketDetail?.types_pays_id = data["types_pays_id"].int!
                self.ticketDetail?.customers_name = data["customers_name"].string!
                self.ticketDetail?.quantity_order = data["quantity_order"].int!
                self.ticketDetail?.tickets_order = data["tickets_order"].string!
                
                self.state = .success
                self.finish(true)
                
            case .failure(let error):
                print("ticket detail error \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class TicketListOngoingOperation: AbstractOperation {
    var listTicket = [String]()
    var state: OperationState?
    var error: String?
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/list-ongoing-ticket?customers_id=\(UserDefaults.standard.string(forKey: StaticVar.id) ?? "")"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let data = JSON(success)["data"].array
                
                if data?.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }
                
                self.state = .success
                
                for (index, value) in (data?.enumerated())! {
                    self.listTicket.append("\(value["orders_id"].int!)")
                    
                    if index == (data?.count)! - 1 {
                        self.finish(true)
                    }
                }
            case .failure(let error):
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class ListStoreOperation: AbstractOperation {
    var data: (building_id: String, address: String, page: Int)?
    
    var error: String?
    var state: OperationState?
    var listStore = [StoreModel]()
    
    init(_ data: (building_id: String, address: String, page: Int)) {
        self.data = data
    }
    
    override func main() {
        if isCancelled{
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/show-store?buildings_id=\(data?.building_id ?? "")&page=\(data?.page ?? 1)"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let storeArray = JSON(success)["data"].array
                
                print("data list store \(String(describing: storeArray))")
                
                if storeArray!.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }
                
                self.state = .success
                
                for (index, value) in storeArray!.enumerated(){
                    var storeModel = StoreModel()
                    storeModel.address = value["address"].string!
                    storeModel.description = value["description"].string!
                    storeModel.images = value["images"].string ?? ""
                    storeModel.name_building = value["name_building"].string!
                    storeModel.name_store = value["name_store"].string!
                    storeModel.store_id = value["store_id"].int!
                    storeModel.opened = value["opened"].int!
                    storeModel.time = value["time"].string ?? ""
                    
                    self.listStore.append(storeModel)
                    
                    if index == (storeArray?.count)! - 1 {
                        self.finish(true)
                    }
                }
                
            case .failure(let error):
                print("list store error \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}

class DetailStoreOperation: AbstractOperation {
    var data: (stores_id: String, page: Int)?
    
    var error: String?
    var state: OperationState?
    var listProduct = [ProductModel]()
    
    init(_ data: (stores_id: String, page: Int)) {
        self.data = data
    }
    
    override func main() {
        if isCancelled {
            self.state = .canceled
            self.finish(true)
            return
        }
        
        let root = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
        let url = "\(root)api/android/store-building?stores_id=\(data?.stores_id ?? "")&page=\(data?.page ?? 1)"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let success):
                let productsArray = JSON(success)["data"].array
                
                print("detail store data \(String(describing: productsArray))")
                
                if productsArray?.count == 0 {
                    self.state = .empty
                    self.finish(true)
                    return
                }
                
                for (index, product) in productsArray!.enumerated() {
                    var productModel = ProductModel()
                    productModel.product_description = product["product_description"].string!
                    productModel.product_name = product["product_name"].string!
                    productModel.product_price = product["product_price"].int!
                    productModel.product_images = product["product_images"].string ?? ""
                    self.listProduct.append(productModel)
                    
                    if index == productsArray!.count - 1 {
                        self.state = .success
                        self.finish(true)
                    }
                }
                
            case .failure(let error):
                print("detail store error \(error.localizedDescription)")
                self.state = .error
                self.error = error.localizedDescription
                self.finish(true)
            }
        }
    }
}
