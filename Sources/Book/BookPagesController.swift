//
//  BookPagesController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import ObjectiveC
import UIKit

class BookPagesController: NSObject {
    private let pageItems: [AttributedString]
    
    init(_ pageItems: [AttributedString]) {
        self.pageItems = pageItems
    }
    
    func viewControllerAtIndex(_ index: Int) -> BookPageViewController? {
        if (pageItems.count == 0) || (index >= pageItems.count - 1) {
            return nil
        }
        
        let vc = BookPageViewController()
        vc.item = pageItems[index]
        return vc
    }

    
    func indexOfViewController(_ viewController: BookPageViewController) -> Int {
        let pageItem = viewController.item
        var pageIndex = 0
        
        if let index = pageItems.firstIndex(where: { $0.attributedString == pageItem?.attributedString }) {
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
        
        if index == pageItems.count {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
}
