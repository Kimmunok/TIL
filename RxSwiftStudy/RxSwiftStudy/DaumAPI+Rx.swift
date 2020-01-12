//
//  DaumAPI+Rx.swift
//  SameButDifferentApp
//
//  Created by ByoungHoon Yun on 21/07/2019.
//  Copyright © 2019 ByoungHoon. All rights reserved.
//

import RxSwift
import DaumAPI
import SwiftyJSON

public extension Reactive where Base: ProviderType {

    func request(_ api: Base.API) -> Single<APIResponse> {

        return Single.create { [weak base] (single) -> Disposable in

            base?.request(api, complete: { (result) in
                
                switch result {
                case .success(let response):
                    single(.success(response))
                case .failure(let error):
                    single(.error(error))
                }
            })

            return Disposables.create {
                base?.session = nil
            }
        }
    }
}

extension PrimitiveSequenceType where Element == APIResponse, Trait == SingleTrait {

    func mapJSON() -> Observable<JSON> {
        return flatMap({ (element) -> Single<JSON> in
            guard let json = try? JSON(data: element.data) else { return .error(RxError.noElements) }
            return .just(json)
        }).asObservable()
    }
}

//extension ObservableType where Element == JSON {
//
//    func mapImageList() -> Observable<[AnyMedia]> {
//        return map { ($0["documents"].array?
//            .compactMap { AnyMedia(Image(json: $0)) } ?? [])
//        }
//    }
//
//    func mapVideoList() -> Observable<[AnyMedia]> {
//        return map { ($0["documents"].array?
//            .compactMap { AnyMedia(Video(json: $0)) } ?? [])
//        }
//    }
//}
//
//extension ObservableType where Element == [AnyMedia] {
//
//    func sortList(_ isLatest: Bool) -> Observable<[AnyMedia]> {
//        return map { $0.sorted(by: { (result1, result2) -> Bool in
//            return isLatest
//            ? result1.createdDate > result2.createdDate
//            : result1.createdDate < result2.createdDate })
//        }
//    }
//
//}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

