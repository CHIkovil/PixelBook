//
//  ModelViewController.swift
//  BlackBook
//
//  Created by Nikolas on 09.11.2022.
//

import ObjectiveC
import UIKit

class PageModelController: NSObject {
    let items: [String]
    
    init(_ items: [String]) {
        self.items = items
    }
    
    func viewControllerAtIndex(_ index: Int) -> PageDataViewController? {
        
        if (items.count == 0) || (index >= items.count - 1) {
            return nil
        }
        
        let dataViewController = PageDataViewController()
        dataViewController.data = items[index]
        return dataViewController
    }

    
    func indexOfViewController(_ viewController: PageDataViewController) -> Int {
        let page = viewController.data
        var pageIndex = 0
        
        if let index = items.firstIndex(where: { $0 == page }) {
            pageIndex = index
        } else {
            pageIndex = NSNotFound
        }
        
        return pageIndex
    }
}

extension PageModelController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = Int()
    
        if let vc = viewController as? PageDataViewController {
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
        var index = indexOfViewController(viewController as! PageDataViewController)
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
