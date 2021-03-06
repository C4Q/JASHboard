//
//  CategoryPhotosCollectionViewController.swift
//  jashdraft
//
//  Created by Sabrina Ip on 2/6/17.
//  Copyright © 2017 Sabrina. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class CategoryPhotosCollectionViewController: UICollectionViewController, JashCollectionViewCellDelegate,JashLoadingScreenProtocol{
    
    //MARK: - Properties
    var categoryTitle: String?
    var jashImages: [JashImage] = [] {
        didSet {
            DispatchQueue.main.async {
                //self.loadingDelegate?.showLoadingView()
                self.collectionView?.reloadData()
            }
        }
    }
    var imageSetCounter = 0
    var imagesTotal = 0
    var dbReference: FIRDatabaseReference!
    var storageReference: FIRStorageReference!
    var dbHandle: UInt!
    var loadingDelegate: JashLoadingScreenProtocol?
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingDelegate = self
        initializeFirebaseReferences()
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let category = self.title?.uppercased() else { return }
        self.loadingDelegate?.showLoadingView()
        
        self.dbReference = FIRDatabase.database().reference().child("CATEGORIES/\(category)")
        
        self.dbHandle = self.dbReference.observe(.value, with: { (snapshot) in
            print("Number of pictures: \(snapshot.childrenCount)")
            self.imagesTotal = Int(snapshot.childrenCount)
            self.loadingDelegate?.dismissLoadingView()
            //Because this is constantly observing for changes in votes we cant directly append into self.jashImages or we will see redundancies every time the view is loaded.
            var currentImages: [JashImage] = []
            
            let enumerator = snapshot.children
            while let child = enumerator.nextObject() as? FIRDataSnapshot {
                
                let votesDictionary = child.value as! [String: AnyObject]
                guard let votes = Vote(snapshot: votesDictionary),
                    let imageTitle = votesDictionary["title"] as? String
                    else { return }
                
                let jashImage = JashImage(votes: votes, imageId: child.key, category: category, title: imageTitle)
                
                currentImages.append(jashImage)
            }
            self.jashImages = currentImages
        })
     
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Remove listener with handle
        self.dbReference.removeObserver(withHandle: self.dbHandle)
    }
    
    internal func initializeFirebaseReferences() {
        //Initializing reference to Firebase
        self.dbReference = FIRDatabase.database().reference()
        self.storageReference = FIRStorage.storage().reference()
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jashImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.cellIdentifier, for: indexPath) as! CategoryCollectionViewCell
        let jashImage = jashImages[indexPath.row]
        cell.alpha = 0
        
        // Configure the cell
        
        cell.delegate = self
        self.storageReference = FIRStorage.storage().reference().child("\(jashImage.category)/\(jashImage.imageId)")
        
        self.imageSetCounter += 1
        self.storageReference.data(withMaxSize: Int64.max, completion: { (data: Data?, error: Error?) in
            DispatchQueue.main.async {
                if let data = data {
                    cell.cellImage = UIImage(data: data)
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.alpha = 1
                        self.imageSetCounter -= 1
                        self.loadingDelegate?.dismissLoadingView()
                    })
                }
            }
        })
        
        //this needs to occur after the asynchronous block completes or the votes appear as 0
        cell.upCount = jashImage.votes.upvotes
        cell.downCount = jashImage.votes.downvotes

        return cell
    }
    
    // MARK: - Navigation
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let jashImage = self.jashImages[indexPath.row]
        
        if let navController = self.navigationController{
            let categoryController = IndividualPhotoViewController()
            categoryController.jashImage = jashImage
            
            let backItem = UIBarButtonItem()
            backItem.title = " "
            navigationItem.backBarButtonItem = backItem
            navController.pushViewController(categoryController, animated: true)
        }
    }
    
    //MARK:- Utilities
    private func setUpCollectionView(){
        self.collectionView!.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.cellIdentifier)
        let layout = UICollectionViewFlowLayout()
        let screenSize = UIScreen.main.bounds
        
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenSize.width / 2 - 0.5, height: screenSize.width / 2 - 0.5 )
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.backgroundColor = JashColors.dividerColor
        collectionView?.collectionViewLayout = layout
        // self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.title = categoryTitle
    }
    
    //MARK: JashCollectionViewCell Delegate
    
    func showPopUpWith(image: UIImage) {
        let popUp = PreviewPopViewController()
        popUp.image = image
        popUp.modalTransitionStyle = .crossDissolve
        popUp.modalPresentationStyle = .overCurrentContext
        
        present(popUp, animated: true, completion: nil)
    }
    
    func hidePopUp() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: JashLoadingScreen Delegae
    
    func showLoadingView() {
        let loading = JashLoadingScreenViewController()
        loading.modalTransitionStyle = .crossDissolve
        loading.modalPresentationStyle = .overCurrentContext
        
        present(loading, animated: true, completion: nil)
    }
    
    func dismissLoadingView() {
        if imageSetCounter == 0 || imagesTotal == 0{
            dismiss(animated: true, completion: nil)
        }
    }
    
}
