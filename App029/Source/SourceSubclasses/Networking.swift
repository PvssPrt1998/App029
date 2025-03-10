import Foundation
import Alamofire

final class Networking {
    func fetchTemplatesByCategory(completion: @escaping (TemplatesByCategory) -> Void, errorHandler: @escaping () -> Void) {
        let token = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        
        let header: HTTPHeaders = [(.authorization(bearerToken: token))]
        let parameters: Parameters = ["isNew" : "true", "appName" : "com.dmyver.skp1l3n", "ai[0]": ["pv"], "ai[1]": ["pika"]]
        
        AF.request("https://vewapnew.online/api/templatesByCategories", method: .get, parameters: parameters, headers: header).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let templates = try JSONDecoder().decode(TemplatesByCategory.self, from: data)
                    //print(templates.data.first?.categoryTitleEn)
                    completion(templates)
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    errorHandler()
                }
            case  .failure(_):
                errorHandler()
            }
        }
    }
    
    func fetchCurrentTokens(apphudId: String, completion: @escaping (Int) -> Void, errorHandler: @escaping () -> Void) {
        let token = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        
        let header: HTTPHeaders = [(.authorization(bearerToken: token))]
        let parameters: Parameters = ["userId" : apphudId, "bundleId" : Bundle.main.bundleIdentifier ?? "com.dmyver.skp1l3n"]
        
        AF.request("https://vewapnew.online/api/user", method: .get, parameters: parameters, headers: header).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
                    print(userInfo)
                    completion(userInfo.data.availableGenerations)
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    errorHandler()
                }
            case  .failure(_):
                errorHandler()
            }
        }
    }
    
    func createVideo(data: Data, idEffect: String, escaping: @escaping (String) -> Void) {
        let token = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        
        let headers: HTTPHeaders = [(.authorization(bearerToken: token))]
        
        let param: Parameters = ["templateId": idEffect, "image" : data, "userId": userID, "appId": Bundle.main.bundleIdentifier ?? "com.test.test"]
        
        //print(data, "param")
               
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(Data(idEffect.utf8), withName: "templateId")
            multipartFormData.append(data, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            multipartFormData.append(Data(userID.utf8), withName: "userId")
            multipartFormData.append(Data((Bundle.main.bundleIdentifier ?? "com.dmyver.skp1l3n").utf8), withName: "appId")
        }, to: "https://vewapnew.online/api/generate", headers: headers)
        .responseData { response in
           // debugPrint(response, "createOK")
            switch response.result {
            case .success(let data):
                do {
                    let effects = try JSONDecoder().decode(Generate.self, from: data)
                    escaping(effects.data.generationId)
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    escaping("error")
                }
                
            case .failure(let error):
                print("Ошибка запроса:", error.localizedDescription)
                escaping("error")
            }
        }
    }
    
    func getStatus(itemId: String, escaping: @escaping(String, String) -> Void) {
        
        let token = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        
        let header: HTTPHeaders = [(.authorization(bearerToken: token)),
                                    HTTPHeader(name: "AppId", value: Bundle.main.bundleIdentifier ?? "com.dmyver.skp1l3n")]
        
        let param: Parameters = ["generationId": itemId, "appId": Bundle.main.bundleIdentifier ?? "com.dmyver.skp1l3n"]

        
        AF.request("https://vewapnew.online/api/generationStatus", method: .get, parameters: param, headers: header).responseData { response in
            //debugPrint(response, "statusGettttt")
            switch response.result {
            case .success(let data):
                do {
                    let item = try JSONDecoder().decode(Status.self, from: data)
                    if let status = item.data?.status {
                        print("networking.getStatus " + status + " " + (item.data?.resultUrl ?? "noVideo"))
                        escaping(status, item.data?.resultUrl ?? "noVideo")
                    } else {
                        escaping("error", "error")
                    }
                } catch {
                    print("Ошибка декодирования JSON:", error.localizedDescription)
                    escaping("error", "error")
                }
            case  .failure(_):
                print("ошибка в запросе")
                escaping("error", "error")
            }
        }
        
    }
}
