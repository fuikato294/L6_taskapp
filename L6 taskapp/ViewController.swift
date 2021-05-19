//
//  ViewController.swift
//  L6 taskapp
//
//  Created by fumitaka katou on 2021/03/08.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加

    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    // tableView(_:numberOfRowsInSection:)はtaskArrayの要素数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count // ←０から修正
    }

    // tableView(_:cellForRowAtIndexPath:)は各セルの内容を返すメソッド
    // データ配列であるtaskArrayから該当するデータを取り出してセルに設定する
    // DateFormatterクラスは、日付を表すDateクラスを任意の形式で文字列に変換する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        // DateFormatterクラスで日付を表すクラスを任意の形の文字列に変換する
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // performSegue(withIdentifier:sender:) メソッドにより'cellsegue'のsegueが実装され画面遷移する
        // cellsegue
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }

    // セルが編集が可能であることを伝えるメソッド（今回は削除）
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    // データベースのRealmクラスのdeleteメソッドに削除したいオブジェクト（今回はTaskクラスのインスタンス）を与えることで削除する
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            // ユーザーはテーブル行を左にスワイプして削除ボタンを表示し、タップする
            // 今回はdeleteメソッドがエラーを発生させる可能性があるものの、その可能性が低いためtry! を記述することで無視させます
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
}
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let InputViewController:InputViewController = segue.destination as! InputViewController


        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            InputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            InputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    // Bool は、真か偽かの値をとる型
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    }

