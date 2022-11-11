//
//  BookPagesController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import ObjectiveC
import UIKit
import SwiftSoup

class BookPagesController: NSObject {
    private var items: [String]
    
    override init() {
        items = []
    }
    
    func setup(model: BookModel){
        self.parseModelToPages(model)
    }
    
    func viewControllerAtIndex(_ index: Int) -> BookPageViewController? {
        if (items.count == 0) || (index >= items.count - 1) {
            return nil
        }
        
        let vc = BookPageViewController()
        vc.item = items[index]
        return vc
    }

    
    func indexOfViewController(_ viewController: BookPageViewController) -> Int {
        let page = viewController.item
        var pageIndex = 0
        
        if let index = items.firstIndex(where: { $0 == page }) {
            pageIndex = index
        } else {
            pageIndex = NSNotFound
        }
        
        return pageIndex
    }
}

private extension BookPagesController {
    func parseModelToPages(_ model: BookModel) {
        var pages: [String] = []
        
        model.chapters.forEach { chapter in
            let parsedChapter = try? SwiftSoup.parse(chapter.xhtml)
            let paragraphs = try? parsedChapter?.select("p").eachText()
            guard let paragraphs = paragraphs else{return}
            pages += paragraphs
        }
        
        items = pages
    }
}

extension BookPagesController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = Int()
    
        if let vc = viewController as? BookPageViewController {
            index = indexOfViewController(vc)
            if (index == 0) || (index == NSNotFound) {
                return nil
            }
            
            index -= 1
            
            return viewControllerAtIndex(index)
        }
        return nil
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController as! BookPageViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == items.count {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
}
