//
//  RRQuickPreviewController.swift
//  PreviewWithQuickLook
//
//  Created by Raj_iLS on 28/09/22.
//

import UIKit
import QuickLook

class RRQuickPreviewController: QLPreviewController, QLPreviewControllerDataSource {

    var fileName: String = ""
    var url: URL?

    private var previewItem : PreviewItem!
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.tintColor = .black
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self;
        self.view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        self.title = fileName;
        self.downloadfile(fileName: fileName, itemUrl: url)
        
        self.hideErrorLabel();
        // Do any additional setup after loading the view.
    }
    
    @objc
    func hideErrorLabel() {
        
        var found = false
        for v in self.view.allViews.filter({ $0 is UILabel }) {
            v.isHidden = true
            found = true
        }
        
        if !found {
            self.perform(#selector(hideErrorLabel), with: nil, afterDelay: 0.1);
        }

    }
    
    private func downloadfile(fileName:String, itemUrl:URL?){
        
        self.previewItem = PreviewItem()
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            self.previewItem.previewItemURL = destinationUrl;
            self.loadFile()
        }
        else {
            DispatchQueue.main.async(execute: {
                if let itemUrl = itemUrl {
                    
                    URLSession.shared.downloadTask(with: itemUrl, completionHandler: { (location, response, error) -> Void in
                        if error != nil {
                            for v in self.view.allViews.filter({ $0 is UILabel }) {
                                v.isHidden = false
                                (v as? UILabel)?.text = error?.localizedDescription
                            }
                        } else {
                            guard let tempLocation = location, error == nil else { return }
                            try? FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                            self.previewItem.previewItemURL = destinationUrl;
                            self.loadFile()
                        }
                    }).resume()
                }
            })
        }
    }
    
    func loadFile() {
    
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.reloadData()
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewItem == nil ? 0 : 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItem
    }
}


class PreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL?
    var previewItemTitle: String?
}


extension UIView {
    var allViews: [UIView] {
        var views = [self]
        subviews.forEach {
            views.append(contentsOf: $0.allViews)
        }
        return views
    }
}
