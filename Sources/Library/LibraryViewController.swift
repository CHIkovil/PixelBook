//
//  LibraryViewController.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import CoreData


final class LibraryViewController: UIViewController {
    private enum Constants {
        static let cellIdentifier = "BookCell"
        static let currentViewHeight: CGFloat = 300
        static let contentOffset: CGFloat = 10
        static let sortedKey: String = "title"
        static let cellDeleteText: String = "Удалить"
    }
    
    private var fetchBooksController: NSFetchedResultsController<BlackBook.Book>?
    
    private lazy var currentBookView: LibraryCurrentItemView = {
        let view = LibraryCurrentItemView()
        return view
    }()
    
    private lazy var booksTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LibraryTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.backgroundColor = AppColor.background
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.keyboardDismissMode = .onDrag
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private var viewModel: LibraryViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = AppColor.background
        view.addSubview(currentBookView)
        view.addSubview(booksTableView)
        
        currentBookView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.top)
            $0.height.equalTo(Constants.currentViewHeight)
            $0.width.equalToSuperview()
        }
        
        booksTableView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(currentBookView.snp.bottom).offset(Constants.contentOffset)
            $0.bottom.equalTo(view.snp.bottom)
            $0.width.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    func setup(viewModel: LibraryViewModelProtocol) {
        self.viewModel = viewModel
        self.setupFetchedBooks()
        
        viewModel.currentBookDriver
            .drive(onNext: { [weak self] model in
                guard let self = self, let model = model else{return}
                self.currentBookView.setup(model: model)
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.managedObjectContextDidChange(notification:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
    
    private func setupFetchedBooks(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<BlackBook.Book>(entityName: AppConstants.bookEntityName)
        request.sortDescriptors = [NSSortDescriptor(key: Constants.sortedKey,ascending: true)]
        fetchBooksController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchBooksController?.delegate = self
        do {
            try fetchBooksController?.performFetch()
        } catch{
            
        }
    }
}

private extension LibraryViewController {
    @objc func managedObjectContextDidChange(notification: Notification){
        viewModel?.viewWillAppear()
        booksTableView.reloadData()
    }
}


extension LibraryViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        booksTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        booksTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let insertIndex = newIndexPath else{return}
            booksTableView.insertRows(at: [insertIndex], with: .automatic)
        case .delete:
            guard let deleteIndex = indexPath else{return}
            booksTableView.deleteRows(at: [deleteIndex], with: .automatic)
        case .move:
            guard let fromIndex = indexPath, let toIndex = newIndexPath else{return}
            booksTableView.moveRow(at: fromIndex, to: toIndex)
        case .update:
            guard let updateindex = indexPath else{return}
            booksTableView.reloadRows(at: [updateindex], with: .automatic)
        @unknown default:
            fatalError("Unhandled case")
        }
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return fetchBooksController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as? LibraryTableViewCell, let item = fetchBooksController?.object(at: indexPath) as? BlackBook.Book else {fatalError("Wrong cell indetifier requested")}
        let model = BookRequests.convertToModel(item)
        cell.setup(model)
        return cell
    }
    
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        150
    }
    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = fetchBooksController?.object(at: indexPath) as? BlackBook.Book else {fatalError("Wrong cell indetifier requested")}
        let model = BookRequests.convertToModel(item)
        viewModel?.selectedBookRelay.accept(model)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .normal, title:  nil, handler: { [weak self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            guard let self = self, let item = self.fetchBooksController?.object(at: indexPath) as? BlackBook.Book else{return}
            let model = BookRequests.convertToModel(item)
            BookRequests.delete(model)
        })
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
            UIImage(named: "delete")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
        }
        deleteAction.backgroundColor = AppColor.unactive
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
