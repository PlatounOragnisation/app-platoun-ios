//
//  PageImageController.swift
//  Platoun
//
//  Created by Flavian Mary on 21/03/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import ImageIOUIKit

protocol PageImageControllerDelegate {
    func updateCount(current: Int, total: Int)
}

class PageImageController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var urls: [URL] = []
    var current = 0
    var countDelegate: PageImageControllerDelegate?
    private var orderedViewControllers: [UIViewController] = []
    
    
    func initialiseViewControllers(count: Int) {
        guard self.orderedViewControllers.count != count else { return }
        guard self.orderedViewControllers.count <= count else {
            self.orderedViewControllers.removeLast(orderedViewControllers.count - count)
            return
        }
        
        let vcs: [UIViewController] = (self.orderedViewControllers.count ..< count).map { _ in ImageViewController.newInstance() }
        self.orderedViewControllers.append(contentsOf: vcs)
    }
    
    func updateImages(images: [URL]) {
        self.urls = images
        self.orderedViewControllers.enumerated().forEach { (index, vc) in
            (vc as! ImageViewController).updateImage(url: images[index])
        }
        self.current = 0
        
        if let firstViewController = self.orderedViewControllers.getOrNil(self.current) {
            setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: false,
                completion: nil)
        } else {
            setViewControllers(nil, direction: .forward, animated: false, completion: nil)
        }
        self.countDelegate?.updateCount(current: self.current, total: images.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        countDelegate?.updateCount(current: 0, total: 0)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            self.current = index
            self.countDelegate?.updateCount(current: index, total: self.urls.count)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 && orderedViewControllers.count > previousIndex else { return nil }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex && orderedViewControllers.count > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
    
}

class ImageViewController: LightViewController {
    
    static func newInstance() -> ImageViewController {
        let vc = ImageViewController()
        _ = vc.view
        return vc
    }
    
    static func newInstance(url: URL) -> ImageViewController {
        let vc = ImageViewController()
        _ = vc.view
        vc.updateImage(url: url)
        return vc
    }
    
    func updateImage(url: URL) {
        self.url = url
        self.imageView.setImage(with: url, placeholder: nil, options: .progressiveLoad)
    }
    
    private var url: URL!
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
        
    override func loadView() {
        self.view = imageView
    }
}
