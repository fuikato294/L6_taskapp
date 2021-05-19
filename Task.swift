//
//  Task.swift
//  L6 taskapp
//
//  Created by fumitaka katou on 2021/03/08.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    // プライマリーキーとは、データベースでそれぞれのデータを一意的に識別するためのID
    // object dynamic装飾子は、データベースライブラリであるRealmがKey Visual Observingを利用するための
    // KVO とはプロパティの変更を監視するための仕組み
    @objc dynamic var id = 0

    // タイトル
    @objc dynamic var title = ""

    // 内容
    @objc dynamic var contents = ""

    // 日時
    @objc dynamic var date = Date()

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
