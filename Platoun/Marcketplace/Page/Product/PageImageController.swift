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
        self.orderedViewControllers.enumerated().forEach { (index, vc) in
            (vc as! ImageViewController).updateImage(url: images[index])
        }
        if let firstViewController = self.orderedViewControllers.getOrNil(self.current) {
            setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: false,
                completion: nil)
        } else {
            setViewControllers(nil, direction: .forward, animated: false, completion: nil)
        }
    }
    
    
//    func updateImagesDownloaded(urls: [URL]) {
//        self.urls = urls
//
//        let displayVC: UIViewController?
//        if orderedViewControllers.count > self.current && urls.count > self.current {
//            let url = urls[self.current]
//            (orderedViewControllers.first as! ImageViewController).updateImage(url: url)
//            displayVC = orderedViewControllers.first
//        } else if urls.count > self.current {
//            let url = urls[self.current]
//            displayVC = ImageViewController.newInstance(url: url)
//            orderedViewControllers.append(displayVC!)
//        } else {
//            displayVC = nil
//        }
//
//        if let firstViewController = displayVC {
//            setViewControllers(
//                [firstViewController],
//                direction: .forward,
//                animated: false,
//                completion: nil)
//        } else {
//            setViewControllers(nil, direction: .forward, animated: false, completion: nil)
//        }
//
//        countDelegate?.updateCount(current: self.current, total: images.count)
//
//        if orderedViewControllers.count > images.count {
//            self.orderedViewControllers.removeLast(orderedViewControllers.count - images.count)
//        }
//
//        for (index, vc) in self.orderedViewControllers.enumerated() {
//            let url = images[index]
//            (vc as! ImageViewController).updateImg(img: imgs[url] ?? nil, url: url)
//        }
//
//        if orderedViewControllers.count < images.count {
//            for i in orderedViewControllers.count ..< images.count {
//                let url = images[i]
//                orderedViewControllers.append(ImageViewController.newInstance(url: url, img: imgs[url] ?? nil))
//            }
//        }
//    }
    
//    private func updateImages(images: [String]) {
//        self.images = images
//        self.orderedViewControllers = self.images.map { ImageViewController.newInstance(image: $0) }
//        if let firstViewController = orderedViewControllers.first {
//            setViewControllers(
//                [firstViewController],
//                direction: .forward,
//                animated: false,
//                completion: nil)
//        } else {
//            setViewControllers(nil, direction: .forward, animated: false, completion: nil)
//        }
//        countDelegate?.updateCount(current: 0, total: images.count)
//    }
    
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
//        if isLoad {
        self.imageView.load(url)
//        self.imageView.downloaded(from: self.image!)
//        }
    }
    
    private var url: URL!
    
    lazy var imageView: ImageSourceView = {
        let view = ImageSourceView()
        view.isAnimationEnabled = true
//        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
//    var isLoad: Bool = false
    
    override func loadView() {
//        self.view.addSubview(imageView)
        
        self.view = imageView
//        self.isLoad = true
//        if
//        self.imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        self.imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        self.imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        self.imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
}
