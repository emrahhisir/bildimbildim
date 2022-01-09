//
//  SplitVCRootViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 10/12/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import UIKit

class SplitVCRootViewController: UIViewController, UISplitViewControllerDelegate {
  
    var detailViewController: GenericDetailViewController?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    arrangeSize(view.bounds.size)
    configureSplitVC()
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    arrangeSize(size)
  }
  
  private func arrangeSize(size: CGSize) {
    var overrideTraitCollection: UITraitCollection? = nil
    if size.width > 320 {
      overrideTraitCollection = UITraitCollection(horizontalSizeClass: .Regular)
    }
    for vc in self.childViewControllers as! [UIViewController] {
      setOverrideTraitCollection(overrideTraitCollection, forChildViewController: vc)
    }
  }
  
  private func configureSplitVC() {
    // Set up split view delegate
    let splitVC = self.childViewControllers[0] as! UISplitViewController
    splitVC.delegate = self
  }
  
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return true
    }
    
    func setGenericDetailViewController(detailViewController: GenericDetailViewController) {
        
        let splitVC = self.childViewControllers[0] as! UISplitViewController
        
        if (detailViewController.isRoot != nil) {
            splitVC.preferredPrimaryColumnWidthFraction = 0.0
        }
        else {
            splitVC.preferredPrimaryColumnWidthFraction = 0.3
        }
        self.detailViewController = detailViewController;
        
        var navigationControllers: [AnyObject] = splitVC.childViewControllers
        if (navigationControllers.count < 2) {
            let detailNC = UINavigationController()
            detailNC.pushViewController(detailViewController, animated: false)
            navigationControllers.append(detailNC)
            splitVC.viewControllers = navigationControllers
        }
        else {
            //navigationControllers.last?.popViewControllerAnimated(false)
            //navigationControllers.last?.presentViewController(detailViewController, animated: true, completion: nil)
            navigationControllers.last?.pushViewController(detailViewController, animated: true)
        }
        
    }
    
    func popToRootViewController(animated: Bool) {
        let splitVC = self.childViewControllers[0] as! UISplitViewController
        splitVC.preferredPrimaryColumnWidthFraction = 0.0
        var navigationControllers: [AnyObject] = splitVC.childViewControllers
        navigationControllers.last?.popToRootViewControllerAnimated(animated)
        detailViewController = navigationControllers.last?.topViewController as? GenericDetailViewController
    }
    
    func popToTopViewController(animated: Bool) {
        let splitVC = self.childViewControllers[0] as! UISplitViewController
        var navigationControllers: [AnyObject] = splitVC.childViewControllers
        navigationControllers.last?.popViewControllerAnimated(animated)
        detailViewController = navigationControllers.last?.topViewController as? GenericDetailViewController
    }
    
    func popToTopViewControllerWithSidebar(animated: Bool) {
        let splitVC = self.childViewControllers[0] as! UISplitViewController
        splitVC.preferredPrimaryColumnWidthFraction = 0.3
        var navigationControllers: [AnyObject] = splitVC.childViewControllers
        navigationControllers.last?.popViewControllerAnimated(animated)
        detailViewController = navigationControllers.last?.topViewController as? GenericDetailViewController
    }
    
    func replaceCategorySelectViewController(detailViewController: CategorySelectViewController) {
        let splitVC = self.childViewControllers[0] as! UISplitViewController
        splitVC.preferredPrimaryColumnWidthFraction = 0.3
        var navigationControllers: [AnyObject] = splitVC.childViewControllers
        let oldCategorySelectViewController = navigationControllers.last?.popViewControllerAnimated(false) as! CategorySelectViewController
        detailViewController.teamNumber = oldCategorySelectViewController.teamNumber
        detailViewController.roundNumber = oldCategorySelectViewController.roundNumber
        setGenericDetailViewController(detailViewController)
    }
    
}