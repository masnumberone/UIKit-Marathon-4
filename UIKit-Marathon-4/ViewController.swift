//
//  ViewController.swift
//  UIKit-Marathon-4
//
//  Created by work on 10.05.2023.
//

import UIKit

class ViewController: UIViewController {
    
    struct Item: Hashable, Equatable {
        let number: Int
        var checkmark: Bool
        
        public static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.number == rhs.number
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(number)
        }
    }
    
    lazy var dataSource = UITableViewDiffableDataSource<Int, Item>(tableView: tableView) { tableView, indexPath, index in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(index.number)"
        cell.accessoryType = index.checkmark ? .checkmark : .none
        return cell
    }
    
    lazy var tableView = UITableView(frame: .init(x: view.safeAreaInsets.left,
                                                  y: view.safeAreaInsets.top,
                                                  width: view.bounds.width - view.safeAreaInsets.right - self.view.safeAreaInsets.right,
                                                  height: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom),
                                     style: .insetGrouped)
    
    lazy var shuffleButton = UIBarButtonItem(title: "Shuffle",
                                             style: .plain,
                                             target: self,
                                             action: #selector(shuffleTableSnapshot))
    
    var snapshot = NSDiffableDataSourceSnapshot<Int,Item>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "👋👋👋"
        navigationItem.trailingItemGroups = [UIBarButtonItemGroup(barButtonItems: [shuffleButton],
                                                                  representativeItem: nil)]
        
        view.addSubview(tableView)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        snapshot.appendSections([0])
        (0...29).forEach({ snapshot.appendItems([.init(number: $0, checkmark: false)]) })
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc
    func shuffleTableSnapshot() {
        var items = snapshot.itemIdentifiers.shuffled()
        snapshot.deleteItems(items)
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var item = dataSource.itemIdentifier(for: indexPath)!
        item.checkmark.toggle()
        
        if (item.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            snapshot.deleteItems([item])
            snapshot.insertItems([item], beforeItem: snapshot.itemIdentifiers.first!)
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            var items = snapshot.itemIdentifiers
            items[indexPath.row] = item
            snapshot.deleteItems(items)
            snapshot.appendItems(items)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
