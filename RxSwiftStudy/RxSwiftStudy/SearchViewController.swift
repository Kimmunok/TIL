//
//  SearchViewController.swift
//  RxSwiftStudy
//
//  Created by 김문옥 on 07/08/2019.
//  Copyright © 2019 MunokKim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import DaumAPI
import SwiftyJSON
import Alamofire

private let daumRestApiSearchKey = "d008716ce9b2495626e4831190a44e21"

// 이름이 너무 긴 것을 Typealias를 통해 줄여줌
typealias TvDataSectionModel = SectionModel<String, String>
typealias TvDataDataSource = RxTableViewSectionedReloadDataSource<TvDataSectionModel>

public enum RequestType : String{
    case GET, POST
}

protocol ApiRequest{
    var method: RequestType { get }
    var path: String { get }
    var parameters: [String:String]{ get }
}

extension ApiRequest {
    
    func request(with baseURL : URL) -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL compoenents")
        }
        components.queryItems = parameters.map {
            URLQueryItem(name: String($0), value: String($1))
        }
        guard let url = components.url else {
            fatalError("Could not get url")
        }
        let request : URLRequest = {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.addValue("KakaoAK " + daumRestApiSearchKey,
                             forHTTPHeaderField: "Authorization")
            return request
        }()
        return request
    }
}

class ApiService {
    
    let baseURL = URL(string: "https://dapi.kakao.com/v2/search/image")!
    /**
     Alamofire 로 짜기
     **/
    func get<T: Codable>(apiRequest: ApiRequest) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = apiRequest.request(with: self.baseURL)
            let dataRequest = Alamofire.request(request).responseData {
                response in
                switch response.result {
                case .success(let data) :
                    do {
                        let model : T = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(model)
                    } catch let error {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }
    
    /**
     searchController.searchBar.rx.text.asObservable()
     .map { ($0 ?? "").lowercased() }
     .map { UniversityRequest(name: $0) }
     .flatMap { request -> Observable<[UniversityModel]> in
     return self.apiClient.send(apiRequest: request)
     }
     .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) { index, model, cell in
     cell.textLabel?.text = model.name
     }
     .disposed(by: disposeBag)
     **/
}

extension SearchViewController: ApiRequest {
    var method: RequestType { return .GET }
    
    var path: String { return "" }
    
    var parameters: [String : String] { return ["query":""] }
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    //    let provider = Provider<API>()
    let disposeBag: DisposeBag = DisposeBag()
    
//    func search(keyword: String) -> Observable<DaumImageSearchResult> {
//        let urlString =
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //        let parameter:SearchParameters = (query: "", sort: nil, page: 1, size: nil)
        //        provider.request(API.searchForImage(parameters: parameter)) { (result: Result<APIResponse, APIError>) in
        //
        //        }
        bind()
    }
    
    func bind() {
        searchTextField.rx.text.orEmpty
            .flatMap { str -> Observable<DaumImageSearchResult> in
                
                return ApiService.get(apiRequest: ApiRequest)
        }
        
        //        Alamofire.request(str_search,
        //                          method: .get,
        //                          encoding: JSONEncoding.prettyPrinted,
        //                          headers: ["Authorization": "KakaoAK your REST API KEY"])
        //            .responseJSON{ response in
        //                switch response.result {
        //                case .success(let json):
        //                    // 검색에 성공을 하면 검색 결과가 json으로 넘어 옵니다. 이 값을 통해 원하는 화면을 표시 하면됩니다.
        //                    print(jsont)
        //                case .failure(let error):
        //                    // 검색에 실패할 경우 error 메세지와 함께 넘어옵니다.
        //                    print("Request failed with error: \(error)")
        //                    DispatchQueue.main.async {
        //                        print(message: "검색 도중에 에러가 발생했습니다.")
        //                    }
        //                }
        //        }
        
        
        //
        //        searchTextField.rx.text.orEmpty
        //            .filter { !$0.isEmpty }
        //            .flatMap({ [weak self] keyword -> Single<APIResponse> in
        //                guard let self = self else { return .never() }
        //                return self.provider.rx.request(API.searchForImage(parameters: (query: keyword, sort: nil, page: 1, size: nil)))
        //            }).map({ (data: Data, urlResponse: URLResponse) -> JSON in
        //                return try! JSON(data: data)
        //            }).map({ json -> TvDataSectionModel in
        //                return [ SectionModel(model: <#T##_#>, items: <#T##[_]#>)
        //                ]
        //            })
        //            .disposed(by: disposeBag)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
