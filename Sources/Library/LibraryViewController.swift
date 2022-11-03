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


final class LibraryViewController: UIViewController {
    private enum Constants {
        static let cellIdentifier = "BookCell"

    }
    
    private let booksTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private var selectedBookRelay = BehaviorRelay<BookModel?>(value: nil)
    private var viewModel: LibraryViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    func setup(viewModel: LibraryViewModelProtocol) {
        self.viewModel = viewModel
        
        selectedBookRelay
            .subscribe(onNext: { [weak self] book in
                self?.viewModel?.selectedBook(model: book)
            })
            .disposed(by: disposeBag)
        
        viewModel.stateDriver
            .drive(onNext: { [weak self] state in
                self?.addUI(state)
            }).disposed(by: disposeBag)
    }
}

private extension LibraryViewController {
    func addUI(_ state: LibraryViewState) {
        view.backgroundColor = AppColor.background
     
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
         1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as! BookTableViewCell
        cell.setup(model: BookModel())
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        58
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedBookRelay.accept(bookList[safe: indexPath.row])
    }
}
