//
//  AppDelegate.swift
//  ECommerceSNS
//
//  Created by 김문옥 on 2018. 8. 23..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    // 회원가입하고 넘어가는 부분
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // 구글 인증 에러났을 때
            return
        }
        
        guard let authentication = user.authentication else { return }
        // 인증된 토큰이 나옴
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        
        // authentication개체로부터 구글 인증된 정보(구글아이디토큰, 구글엑세스토큰)를 가져와서 Firebase사용자인증정보로 넘겨주는 부분
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // 인증 정보 저장이 에러났을 때
                return
            }
            // User is signed in
            // ...
            
            self.getUserInfo()
        }
    }
    
    func getUserInfo() {
        
        // Cloud Firestore 인스턴스를 초기화합니다.
        let db = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else {
            print("User Auth Error!")
            return
        }
        
//        guard let email = user.email, let name = user.displayName, let uid = user.uid else {
//            print("Provider Data or User ID Error!")
//            return
//        }
        
        // 계정 등록되어있는지 확인 (문서 가져오기)
        db.collection("users").document(user.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                self.goToMain()
            } else {
                print("Document does not exist")
                
                self.setUser()
            }
        }
    }
    
    func setUser() {
        
        // Cloud Firestore 인스턴스를 초기화합니다.
        let db = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else {
            print("User Auth Error!")
            return
        }
        
        guard let email = user.email, let name = user.displayName else {
            print("Provider Data or User ID Error!")
            return
        }
        
        let docData = [
            "googleEmail": email,
            "googleName": name,
            "uid": user.uid,
            "userEmail": "user@email.com",
            "userName": "user"
        ]
        
        // 문서 설정 (데이터 추가)
        db.collection("users").document(user.uid).setData(docData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document successfully written!")
                
                self.goToMain()
            }
        }
    }
    
    func goToMain() {
        
//        let mainVC : UITableViewController
//
//        mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! UITableViewController
//
//        mainVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//
//        if let topVC = self.window!.rootViewController {
//            topVC.present(mainVC, animated: true, completion: nil)
//        }
        
        // go
        if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? UIViewController {
            // self.window!.rootViewController?.navigationController?.pushViewController(view, animated: true)
            self.window!.rootViewController?.present(view, animated: true, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

