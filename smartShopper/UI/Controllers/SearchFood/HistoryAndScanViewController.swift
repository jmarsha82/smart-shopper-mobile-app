//
//  HistoryAndScanViewController.swift
//  smartShopper
//
//  Created on 5/2/21.
//

import UIKit

// MARK: - Start
/// Controller to allow the user to switch between the ```Scanned History```
/// or the ```Ingredient History``` in the `Scanned` tab.
class HistoryAndScanViewController: UIViewController {

    @IBOutlet weak var viewSegControl: UISegmentedControl!

    let SCANNED = 0
    let HISTORY = 1

    private lazy var scannerVC: ScannerViewController = {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var newVC = storyBoard.instantiateViewController(withIdentifier: "ScannerVC")
            as? ScannerViewController ?? ScannerViewController()
        self.addVC(asChildVC: newVC)
        return newVC
    }()

    private lazy var historyVC: IngredientsHistoryViewController = {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var newVC = storyBoard.instantiateViewController(withIdentifier: "IngHistoryVC")
            as? IngredientsHistoryViewController ?? IngredientsHistoryViewController()
        self.addVC(asChildVC: newVC)
        return newVC
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // loadHistoryVC()
        initView()
    }

    func initView() {
        addVC(asChildVC: scannerVC)
    }

    func updateView() {
        if viewSegControl.selectedSegmentIndex == SCANNED {
            removeVC(asChildVC: historyVC)
            addVC(asChildVC: scannerVC)
        } else {
            removeVC(asChildVC: scannerVC)
            addVC(asChildVC: historyVC
            )
        }
    }

    @IBAction func switchViewControllers(_ sender: Any) {
        updateView()
    }

    private func addVC(asChildVC childVC: UIViewController) {
        addChild(childVC)
        childVC.view.frame = view.bounds
        childVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }

    private func removeVC(asChildVC childVC: UIViewController) {
        guard childVC.parent != nil else {
            return
        }
        childVC.willMove(toParent: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
    }
}
