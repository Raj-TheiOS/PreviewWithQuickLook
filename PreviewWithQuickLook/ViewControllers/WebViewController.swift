//
//  WebViewController.swift
//  PreviewWithQuickLook
//
//  Created by Raj_iLS on 29/09/22.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var docUrl: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(webView)
        webView.load(URLRequest(url: docUrl!))
    }


}
