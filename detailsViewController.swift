
import UIKit
import SnapKit
import CoreData

class detailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    var artimg : UIImageView = {
        let img = UIImageView()
        return img}()
    
    var nameTf : UITextField = {
        let nm = UITextField()
        nm.font = .systemFont(ofSize: 5.0)
        nm.font = UIFont.boldSystemFont(ofSize: 20)
        nm.textColor = .black
        return nm}()
    
    var artistTf : UITextField = {
        let nm = UITextField()
        nm.font = .systemFont(ofSize: 5.0)
        nm.font = UIFont.boldSystemFont(ofSize: 20)
        nm.textColor = .black
        return nm}()
    
    var yearTf : UITextField = {
        let nm = UITextField()
        nm.font = .systemFont(ofSize: 5.0)
        nm.font = UIFont.boldSystemFont(ofSize: 20)
        nm.textColor = .black
        return nm}()
    
    let saveButton : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20.0)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.layer.cornerRadius = 15
        btn.layer.borderWidth = 0
        btn.backgroundColor = .gray
        return btn}()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        super.view.addSubview(artimg)
        super.view.addSubview(saveButton)
        super.view.addSubview(nameTf)
        super.view.addSubview(artistTf)
        super.view.addSubview(yearTf)
        
        view.backgroundColor = .white
        
        
        artimg.contentMode = UIView.ContentMode.scaleAspectFit
        artimg.image = UIImage(named: "Image.jpg")
        artimg.snp.makeConstraints{ make -> Void in
            make.right.equalToSuperview().offset(-50)
            make.left.equalToSuperview().offset(50)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.height.equalTo(300)}
        
        nameTf.placeholder = "name"
        nameTf.snp.makeConstraints{ make -> Void in
            make.right.equalToSuperview().offset(-100)
            make.left.equalToSuperview().offset(100)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(400)
            make.height.equalTo(20)}
        
        artistTf.placeholder = "artist"
        artistTf.snp.makeConstraints{ make -> Void in
            make.right.equalToSuperview().offset(-100)
            make.left.equalToSuperview().offset(100)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(450)
            make.height.equalTo(20)}
        
        yearTf.placeholder = "year"
        yearTf.snp.makeConstraints{ make -> Void in
            make.right.equalToSuperview().offset(-100)
            make.left.equalToSuperview().offset(100)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(500)
            make.height.equalTo(20)}
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-140)
            make.left.equalToSuperview().offset(140)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(600)
            make.height.equalTo(25)}
    
        saveButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
                        
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
                       
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
                       
                       do {
                          let results = try context.fetch(fetchRequest)
                           if results.count > 0 {
                                for result in results as! [NSManagedObject] {
                                   if let name = result.value(forKey: "name") as? String {
                                       nameTf.text = name}

                                   if let artist = result.value(forKey: "artist") as? String {
                                       artistTf.text = artist}
                                   
                                   if let year = result.value(forKey: "year") as? Int {
                                       yearTf.text = String(year)}
                                   
                                   if let imageData = result.value(forKey: "image") as? Data {
                                       let image = UIImage(data: imageData)
                                       artimg.image = image}}
                           }} catch{ print("error")}
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        artimg.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageClicked))
        artimg.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func buttonClicked(saveButton: UIButton, sender : Any){
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameTf.text!, forKey: "name")
        newPainting.setValue(artistTf.text!, forKey: "artist")
        newPainting.setValue(UUID(), forKey: "id")
        if let year = Int(yearTf.text!){
            newPainting.setValue(year, forKey: "year")
        }

        let data = artimg.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func imageClicked(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        artimg.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
