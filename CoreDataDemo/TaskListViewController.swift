//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 10.03.2021.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let cellID = "cell"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Bar Appearence
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.name = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    private func showEditAlert(with title: String, message: String, and task: Task) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            self.saveChange(taskName, and: task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.textFields?.first?.text = task.name
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func saveChange(_ taskName: String, and task: Task) {
        task.name = taskName
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        fetchData()
        
    }
}

// MARK: - TAble View Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = taskList[indexPath.row]
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
}

 //MARK: - UITableViewDelegate
extension TaskListViewController{
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            context.delete(task)
            
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic
            )
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
       
        showEditAlert(with: "Update task", message: "What do you want to do?", and: task)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

