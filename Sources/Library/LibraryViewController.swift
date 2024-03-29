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
        static let contentOffset: CGFloat = 15
        static let sortedKey: String = "title"
        static let cellDeleteText: String = "Удалить"
        static let cellHeight: CGFloat = 150
        static let minTableTopOffset: CGFloat = AppConstants.topContentOffset
        static let maxTableTopOffset: CGFloat = Constants.currentViewHeight + Constants.contentOffset
        static let maxTableHeight: CGFloat = UIScreen.main.bounds.height - AppConstants.topContentOffset
        static let minTableHeight: CGFloat = UIScreen.main.bounds.height - Constants.currentViewHeight - Constants.contentOffset
        static let tableWidth: CGFloat =  UIScreen.main.bounds.width
        static let deleteIconName: String = "delete"
        static let deleteIconSide: CGFloat = 20
        static let notificationAlpha: CGFloat = 0.95
    }
    
    private var fetchBooksController: NSFetchedResultsController<BlackBook.Book>?
    
    private lazy var notificationView: NotificationView = {
        let view = NotificationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var exampleView: LibraryExampleView = {
        let view = LibraryExampleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var currentBookView: LibraryCurrentItemView = {
        let view = LibraryCurrentItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private lazy var booksTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: Constants.minTableTopOffset, width: Constants.tableWidth, height: Constants.maxTableHeight))
        tableView.register(LibraryTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.backgroundColor = AppColor.background
        tableView.separatorStyle = .none
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 1
        tableView.layer.shadowOffset = CGSize(width: 4, height: 4)
        tableView.layer.shadowRadius = 10
        tableView.layer.masksToBounds = false
        tableView.layer.borderColor = UIColor.clear.cgColor
        tableView.layer.borderWidth = AppConstants.contentBorderWidth
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.keyboardDismissMode = .onDrag
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        tableView.panGestureRecognizer.addTarget(self, action: #selector(self.didTouchTableView(gestureRecognizer:)))
        tableView.alpha = 0
        return tableView
    }()
    
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = AppColor.background
        view.addSubview(currentBookView)
        view.addSubview(booksTableView)
        view.addSubview(exampleView)
        view.addSubview(notificationView)
        
        currentBookView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.top)
            $0.height.equalTo(Constants.currentViewHeight)
            $0.width.equalToSuperview()
        }
        
        notificationView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(AppConstants.topContentOffset - AppConstants.notificationViewHeight)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(AppConstants.notificationViewHeight)
            $0.width.equalTo(AppConstants.notificationViewWidth)
        }
        
        exampleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(AppConstants.topContentOffset)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-AppConstants.topContentOffset)
            $0.width.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear(true)
        try? fetchBooksController?.performFetch()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            
            if hitView === self.currentBookView {
                self.selectCurrentBook()
            }
        }
    }
    
    private var viewModel: LibraryViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup(viewModel: LibraryViewModelProtocol) {
        self.viewModel = viewModel
        self.setupFetchedBooks()
        
        viewModel.сurrentBookDriver
            .drive(onNext: { [weak self] state in
                guard let self = self else{return}
                if let state = state {
                    self.updateCurrentBook(state.currentBook)
                    self.animateMoveDownTableView()
                    self.animateShowUI(state.isRead)
                }else{
                    self.booksTableView.alpha = 1
                    self.currentBookView.alpha = 1
                }
                
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didNewBook(notification:)),
                                               name: .init(rawValue: AppConstants.newBookNotificationName),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didNewCurrentBook(notification:)),
                                               name: .init(rawValue: AppConstants.newCurrentBookNotificationName),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didRepeatedBook(notification:)),
                                               name: .init(rawValue: AppConstants.repeatedBookNotificationName),
                                               object: nil)
    }
}

private extension LibraryViewController {
    func setupFetchedBooks(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<BlackBook.Book>(entityName: AppConstants.bookEntityName)
        request.sortDescriptors = [NSSortDescriptor(key: Constants.sortedKey,ascending: true)]
        fetchBooksController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchBooksController?.delegate = self
    }
    
    func updateCurrentBook(_ book: BookModel){
        self.currentBookView.setup(model: book)
    }
    
    func resetCurrentBook(_ book: BookModel) {
        self.animateMoveUpTableView(isReset: true)
        self.currentBookView.reset()
    }
    
    func selectCurrentBook() {
        guard let model = self.currentBookView.model else{return}
        viewModel?.selectedBookRelay.accept(model)
    }
    
    func deleteBook(_ indexPath: IndexPath) {
        guard let item = self.fetchBooksController?.object(at: indexPath) as? BlackBook.Book else{return}
        notificationView.setup(.deleted, alpha: Constants.notificationAlpha)
        let model = BookRequests.convertToModel(item)
        PagesRequests.delete(model)
        BookRequests.delete(model)
        
        if self.currentBookView.model == model {
            self.resetCurrentBook(model)
        }
    }
    
    @objc func didNewBook(notification: Notification){
        notificationView.setup(.added, alpha: Constants.notificationAlpha)
        booksTableView.reloadData()
    }
    
    @objc func didRepeatedBook(notification: Notification){
        notificationView.setup(.repeated, alpha: Constants.notificationAlpha)
    }
    
    @objc func didNewCurrentBook(notification: Notification){
        if self.booksTableView.frame.height > Constants.minTableHeight {
            self.animateMoveDownTableView()
        }else{
            viewModel?.viewWillAppear(false)
        }
    }
    
    @objc func didTouchTableView(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            
            if translation.y < 0 && self.booksTableView.frame.height == Constants.minTableHeight{
                self.animateMoveUpTableView(isReset: false)
            }
            
            if translation.y > 0 && (self.booksTableView.frame.height == Constants.maxTableHeight || self.booksTableView.frame.height == CGFloat(self.booksTableView.numberOfRows(inSection: 0)) * Constants.cellHeight - 1) && self.currentBookView.model != nil && self.booksTableView.contentOffset.y == 0{
                self.animateMoveDownTableView()
            }
        }
    }
    
    func animateMoveUpTableView(isReset: Bool) {
        UIView.animate(withDuration: 0.25) {[weak self] in
            guard let self = self else{return}
            var frame = self.booksTableView.frame
            frame.origin.y = Constants.minTableTopOffset
            
            let cellsHeight = CGFloat(self.booksTableView.numberOfRows(inSection: 0)) * Constants.cellHeight
            frame.size.height = cellsHeight < Constants.maxTableHeight && !isReset ? cellsHeight - 1 : Constants.maxTableHeight
    
            self.booksTableView.frame = frame
            self.booksTableView.contentOffset.y =  0
        }
    }
    
    func animateMoveDownTableView() {
        UIView.animate(withDuration: 0.25) {[weak self] in
            guard let self = self else{return}
            var frame = self.booksTableView.frame
            frame.origin.y = Constants.maxTableTopOffset
            frame.size.height = Constants.minTableHeight
            
            self.booksTableView.frame = frame
            self.booksTableView.contentOffset.y = 0
        }
    }
    
    func animateExample(isShow: Bool){
        if isShow {
            self.exampleView.animateShow()
        }else{
            self.exampleView.animateHide()
        }
    }
    
    func animateShowUI(_ isRead:Bool){
        let duration = isRead ? 2.0 : 0.8
        UIView.animate(withDuration: duration) {[weak self] in
            guard let self = self else{return}
            self.booksTableView.alpha = 1
            self.currentBookView.alpha = 1
        }
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
        let rowsCount = fetchBooksController?.fetchedObjects?.count ?? 0
        
        switch rowsCount {
        case 0:
            self.animateExample(isShow: true)
        case 1:
            self.animateExample(isShow: false)
        default:break
        }
        
        return rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as? LibraryTableViewCell, let item = fetchBooksController?.object(at: indexPath) as? BlackBook.Book else {fatalError("Wrong cell indetifier requested")}
        let model = BookRequests.convertToModel(item)
        cell.setup(model)
        return cell
    }
    
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        Constants.cellHeight
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
            guard let self = self else{return}
            self.deleteBook(indexPath)
        })
        
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: Constants.deleteIconSide, height: Constants.deleteIconSide)).image { _ in
            let image = UIImage(named: Constants.deleteIconName)?.inverseImage(cgResult: false)
            let backgroundActiveImage = image?.mask(with: AppColor.backgroundActive)
            backgroundActiveImage?.draw(in: CGRect(x: 0, y: 0, width: Constants.deleteIconSide, height: Constants.deleteIconSide))
        }
        
        deleteAction.backgroundColor = AppColor.background
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
