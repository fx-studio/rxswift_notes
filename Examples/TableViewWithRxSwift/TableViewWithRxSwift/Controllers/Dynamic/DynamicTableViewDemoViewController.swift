//
//  DynamicTableViewDemoViewController.swift
//  TableViewWithRxSwift
//
//  Created by Tien Le P. VN.Danang on 2/22/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DynamicTableViewDemoViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    private var bag = DisposeBag()
    
    // items
    private var colors: [ColorItem] = [
        ColorItem()
    ]
    // section
    private let sections = BehaviorRelay<[ColorSection]>(value: [])
    
    // dataSource
    private var dataSource = RxTableViewSectionedAnimatedDataSource<ColorSection>(
        animationConfiguration: AnimationConfiguration(insertAnimation: .fade,
                                                       reloadAnimation: .fade,
                                                       deleteAnimation: .fade),
        configureCell: { (dataSource, tableView, IndexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: IndexPath) as! ColorCell
            cell.titleLabel.text = item.id.uuidString
            cell.titleLabel.backgroundColor = item.color
            return cell
        },
        canEditRowAtIndexPath: { (dataSource, IndexPath) in
            return true
        },
        canMoveRowAtIndexPath: { _, _ in
            return true
        }
    )
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        title = "Dynamic TableView"
        
        // barbuttonItem
        let addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addNewItem))
        self.navigationItem.rightBarButtonItem = addButton
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editItems))
        self.navigationItem.leftBarButtonItem = editButton
        
        // register cell
        let nib = UINib(nibName: "ColorCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        // bind to TableView
        // Type [ColorSection] --> [ColorItem]
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        // first item
        self.sections.accept([ColorSection(items: colors)])
        
        // delete
        tableView.rx.itemDeleted
            .subscribe(onNext: { indexPath in
                self.colors.remove(at: indexPath.row)
                self.sections.accept([ColorSection(items: self.colors)])
            })
            .disposed(by: bag)
        
        // move item
        tableView.rx.itemMoved
            .subscribe(onNext: { indexPaths in
                let item = self.colors.remove(at: indexPaths.sourceIndex.row)
                self.colors.insert(item, at: indexPaths.destinationIndex.row)
                self.sections.accept([ColorSection(items: self.colors)])
            })
            .disposed(by: bag)
    }
    
    //MARK: Action
    @objc func addNewItem() {
        colors.append(ColorItem())
        self.sections.accept([ColorSection(items: colors)])
    }
    
    @objc func editItems() {
        let editMode = tableView.isEditing
        tableView.setEditing(!editMode, animated: true)
    }
}
