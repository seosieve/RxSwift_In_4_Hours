//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
    var disposable: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposable?.dispose()
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
//    func downloadJson(_ url: String) -> Observable<String?> {
//        return Observable.create { emitter in
//            emitter.onNext("Hello World")
//            emitter.onCompleted()
//            return Disposables.create()
//        }
//    }
    
    //Sugar API
//    func downloadJson(_ url: String) -> Observable<String?> {
//        Observable.from(["Hello","World"])
//    }

    func downloadJson(_ url: String) -> Observable<String?> {
        return Observable.create { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, err in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    emitter.onNext(json)
                }
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create() {
                task.cancel()
            }
            
        }
    }

    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        disposable = Observable.zip(jsonObservable, helloObservable) {$1 + "\n" + $0!}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
            })
    }
}
