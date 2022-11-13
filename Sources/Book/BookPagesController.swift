//
//  BookPagesController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import ObjectiveC
import UIKit

class BookPagesController: NSObject {
    private let pages: Pages
    
    init(_ pages: Pages) {
        self.pages = pages
    }
    
    func viewControllerAtIndex(_ index: Int) -> BookPageViewController? {
        if (pages.items.count == 0) || (index >= pages.items.count - 1) {
            return nil
        }
        
        let vc = BookPageViewController()
        vc.item = pages.items[index]
        return vc
    }

    
    func indexOfViewController(_ viewController: BookPageViewController) -> Int {
        let page = viewController.item
        var pageIndex = 0
        
        if let index = pages.items.firstIndex(where: { $0 == page }) {
            pageIndex = index
        } else {
            pageIndex = NSNotFound
        }
        
        return pageIndex
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
        
        if index == pages.items.count {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
}
