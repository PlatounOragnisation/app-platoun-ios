//
//  PlatounTableViewDataSource.swift
//  Platoun
//
//  Created by Flavian Mary on 29/10/2020.
//  Copyright © 2020 Flavian Mary. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseUI
import FirebaseCrashlytics

protocol EditablePlatounTableViewDelegate {
    func deleteRow(at indexPath: IndexPath)
    func canEditRowAt(at indexPath: IndexPath) -> Bool
}

class PlatounTableViewDataSource: NSObject, UITableViewDataSource, FUIBatchedArrayDelegate {
    var editableDelegate: EditablePlatounTableViewDelegate?

    var tableView: UITableView? = nil
    var collection: FUIBatchedArray
    var populateCell: (UITableView, IndexPath, DocumentSnapshot)->UITableViewCell
    var animation: UITableView.RowAnimation
    
    
    init(with collection: FUIBatchedArray, populateCell: @escaping (UITableView, IndexPath, DocumentSnapshot)->UITableViewCell) {
        self.collection = collection
        self.populateCell = populateCell
        self.animation = .automatic
        super.init()
        self.collection.delegate = self
    }
    
    init(with query: Query, populateCell: @escaping (UITableView, IndexPath, DocumentSnapshot)->UITableViewCell) {
        self.collection = FUIBatchedArray(query: query, delegate: nil)
        self.populateCell = populateCell
        self.animation = .automatic
        super.init()
        self.collection.delegate = self
    }
    
    
    var count: Int {
        get { self.collection.count }
    }
    
    var items: [DocumentSnapshot] {
        get { self.collection.items }
    }
    
    func snapshot(at index: Int) -> DocumentSnapshot {
        return self.collection.object(at: index)
    }
    
    func bind(to view: UITableView) {
        self.tableView = view
        view.dataSource = self
    }
    
    func unBind() {
        self.tableView?.dataSource = nil
        self.tableView = nil
    }
    
    func startObserve() {
        self.collection.observeQuery()
    }
    
    func stopObserve() {
        self.collection.stopObserving()
    }
    
    var query: Query {
        get { self.collection.query }
        set { self.collection.query = newValue }
    }
    
    func batchedArray(_ array: FUIBatchedArray, didUpdateWith diff: FUISnapshotArrayDiff<DocumentSnapshot>) {
        self.tableView?.beginUpdates()
        
        let deletedIndexPaths = diff.deletedIndexes.map { IndexPath(row: $0.intValue, section: 0) }
        self.tableView?.deleteRows(at: deletedIndexPaths, with: self.animation)
        
        let changedIndexPaths = diff.changedIndexes.map { IndexPath(row: $0.intValue, section: 0) }
        self.tableView?.reloadRows(at: changedIndexPaths, with: self.animation)
        
        
        for i in 0..<diff.movedResultIndexes.count {
            let initialIndex = diff.movedInitialIndexes[i].intValue
            let finalIndex = diff.movedResultIndexes[i].intValue
            self.tableView?.moveRow(
                at: IndexPath(row: initialIndex, section: 0),
                to: IndexPath(row: finalIndex, section: 0))
        }
        
        let insertedIndexPaths = diff.insertedIndexes.map { IndexPath(row: $0.intValue, section: 0) }
        self.tableView?.insertRows(at: insertedIndexPaths, with: self.animation)

        self.tableView?.endUpdates()
        
        let movedIndexPaths = diff.movedResultIndexes.map { IndexPath(row: $0.intValue, section: 0) }
        self.tableView?.reloadRows(at: movedIndexPaths, with: self.animation)
    }
    
    func batchedArray(_ array: FUIBatchedArray, willUpdateWith diff: FUISnapshotArrayDiff<DocumentSnapshot>) {
        print("update")
    }
    
    func batchedArray(_ array: FUIBatchedArray, queryDidFailWithError error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let snap = self.collection.items[indexPath.row]
        let cell = self.populateCell(tableView, indexPath, snap)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.editableDelegate?.canEditRowAt(at: indexPath) ?? false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.editableDelegate?.deleteRow(at: indexPath)
        case .insert: break
        case .none: break
        @unknown default: break
        }
    }
}
