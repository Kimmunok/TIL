//
//  imageViewController.swift
//  Cassini
//
//  Created by 김문옥 on 2018. 2. 3..
//  Copyright © 2018년 김문옥. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    var imageURL: NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                let contentsOfURL = NSData(contentsOf: url as URL) // Raw, JPEG, PNG 등등을 가져옴
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData as Data) // 여기 있는 데이터로부터 UIImage를 생성
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        print("무시된 데이터가 url로부터 반환됨 : \(url)")
                    }
                }
            }
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    {
        didSet {
            scrollView?.contentSize = imageView.frame.size
            scrollView.delegate = self // 질문이 생기면 나(ImageViewController)에게 보내라 라는 뜻
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private var imageView = UIImageView()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit() // 안에 어떤 이미지가 있든 그것에 맞게 imageView의 크기를 알아서 조정해 준다
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
     }
}

