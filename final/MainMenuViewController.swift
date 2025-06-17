//
//  MainMenuViewController.swift
//  final
//
//  Created by SeoJunYoung on 2025/06/16.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToWordStudy(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WordListVC") as! WordListViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func goToQuiz(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "QuizCategoryVC") as? QuizCategoryViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func goToWrongNote(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "WrongNoteVC") as? WrongNoteViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
