//
//  SectionsDemoViewController.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/18/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SectionsDemoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        title = "Sections"
        
        // register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // create data
        let items = Observable.just([
            SectionModel(model: "Mobile", items: [
                "iOS",
                "Android",
                "Flutter",
                "ReactNative"
            ]),
            SectionModel(model: "Web", items: [
                "PHP",
                "Ruby",
                "NodeJS",
                "Java",
                "Python",
                "Golang"
            ])
        ])
        
        // datasource
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>> (
            // for cell
            configureCell: { (dataSource, tableView, indexPath, item) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = item
                return cell
            },
            // for Header
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
            }
        )
        
        dataSource.titleForFooterInSection = { dataSource, index in
          return "footer \(index)"
        }
        
        // bind
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }

}
