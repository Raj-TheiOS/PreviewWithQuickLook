//
//  ViewController.swift
//  PreviewWithQuickLook
//
//  Created by Raj_iLS on 28/09/22.
//

import UIKit
import QuickLook

class FilesViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDataSource {
    
    @IBOutlet weak var changeEnironment: UISegmentedControl!
    @IBOutlet weak var tblFileList: UITableView!
    
    let onlineUrls = ["https://firebasestorage.googleapis.com/v0/b/chronicle-cloud-167518.appspot.com/o/dev%2Fbhumi%2F480764BD-06EC-4B11-B501-197C6F2328EC.csv?alt=media&token=7eefb880-0f13-4018-accb-cf97d12fb5f8", "https://firebasestorage.googleapis.com/v0/b/chronicle-cloud-167518.appspot.com/o/dev%2Fbhumi%2F4B5B4EDA-1F92-4BEC-BBC5-9A2691A48344.doc?alt=media&token=3051c3d6-835b-4589-9bbc-71cac2eaa368", "https://firebasestorage.googleapis.com/v0/b/chronicle-cloud-167518.appspot.com/o/dev%2Fbhumi%2FA4BE36F3-140F-4E59-8582-71BD495FCCB1.xls?alt=media&token=6efd6111-0e40-4866-8f64-a6e0e58bcc3f", "https://firebasestorage.googleapis.com/v0/b/chronicle-cloud-167518.appspot.com/o/dev%2Fbhumi%2F73508E37-964C-41E7-9030-E883DE7F3EA2.xlsx?alt=media&token=a3a2298a-c4eb-43c0-9b48-f7891be7dbea", "https://firebasestorage.googleapis.com/v0/b/chronicle-cloud-167518.appspot.com/o/dev%2Fbhumi%2F36749677-F35E-4169-9DA9-399E66661D59.pptx?alt=media&token=2eb7a650-0ed8-4fc0-93a8-9916e9b9471f"]


    let fileNames = ["Sample-image.jpeg", "Sample-pdf.pdf", "Sample-txt.txt", "Sample-csv.csv" ]
    var fileURLs = [URL]()
    
    let quickLookController = QLPreviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        navigationItem.title = "Preview Files"
        
        changeEnironment.addTarget(self, action: #selector(self.environmentChanged(_:)), for: .valueChanged)

        self.changeEnironment.selectedSegmentIndex = 0
        
        self.prepareFileURLs()
        quickLookController.dataSource = self
    }
    

    @objc func environmentChanged(_ sender: UISegmentedControl) {
        if changeEnironment.selectedSegmentIndex == 0 {
            self.fileURLs.removeAll()
            self.prepareFileURLs()
            self.tblFileList.reloadData()
        } else if changeEnironment.selectedSegmentIndex == 1 {
            self.fileURLs.removeAll()
            self.convertToURL()
            self.tblFileList.reloadData()
        } else if changeEnironment.selectedSegmentIndex == 2 {
            self.fileURLs.removeAll()
            self.convertToURL()
            self.tblFileList.reloadData()
        }
    }
    
    func convertToURL() {
        for file in onlineUrls {
            let fileUrl = URL(string: file)
            fileURLs.append(fileUrl!)
        }
    }
    func prepareFileURLs() {
        for file in fileNames {
            let fileParts = file.components(separatedBy: ".")
            print(fileParts[0], fileParts[1])
            if let fileURL = Bundle.main.url(forResource: fileParts[0], withExtension: fileParts[1]) {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    fileURLs.append(fileURL)
                }
            }
        }
    }
    
    func extractAndBreakFilenameInComponents(fileURL: URL) -> (fileName: String, fileExtension: String) {
        // Break the NSURL path into its components and create a new array with those components.
        let fileURLParts = fileURL.path.components(separatedBy: "/")
     
        // Get the file name from the last position of the array above.
        let fileName = fileURLParts.last
     
        // Break the file name into its components based on the period symbol (".").
        let filenameParts = fileName?.components(separatedBy: ".")
     
        // Return a tuple.
        return (filenameParts![0], filenameParts![1])
    }
    func getFileTypeFromFileExtension(fileExtension: String) -> String {
        var fileType = ""
     
        switch fileExtension {
        case "docx":
            fileType = "Microsoft Word document"
     
        case "pages":
            fileType = "Pages document"
     
        case "jpeg":
            fileType = "Image document"
     
        case "key":
            fileType = "Keynote document"
     
        case "pdf":
            fileType = "PDF document"
     
        case "csv":
            fileType = "CSV document"
            
        case "xls":
            fileType = "XLS document"
          
        case "pptx":
            fileType = "PPTX document"

        default:
            fileType = "Text document"
     
        }
     
        return fileType
    }
    // MARK: Custom Methods
    
    func configureTableView() {
        tblFileList.delegate = self
        tblFileList.dataSource = self
        tblFileList.register(UINib(nibName: "FileListCell", bundle: nil), forCellReuseIdentifier: "idCellFile")
        tblFileList.reloadData()
    }

    
    // MARK: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileURLs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")

        let currentFileParts = extractAndBreakFilenameInComponents(fileURL: fileURLs[indexPath.row])
     
        cell.textLabel?.text = currentFileParts.fileName
        cell.detailTextLabel?.text = getFileTypeFromFileExtension(fileExtension: currentFileParts.fileExtension)

        return cell
    }
    
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if changeEnironment.selectedSegmentIndex == 2 {
            let yourVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            yourVc.docUrl = fileURLs[indexPath.row]
            self.present(yourVc, animated: true, completion: nil)
        }else {
            let quickPreviewController = RRQuickPreviewController()
            quickPreviewController.url = fileURLs[indexPath.row]
            quickPreviewController.fileName = fileURLs[indexPath.row].lastPathComponent
            self.show(quickPreviewController, sender: true)
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return fileURLs.count
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURLs[index] as QLPreviewItem
    }
}
