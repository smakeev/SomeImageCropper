//
//  CropViewController.swift
//  Example
//
//  Created by Sergey Makeev on 21.03.2020.
//  Copyright © 2020 SOME projects. All rights reserved.
//

import UIKit
import SomeImageCropper

class CropViewController: UIViewController {
	
	private var button: UIButton!
	
	var image: UIImage? = nil {
		didSet {
			cropper.sourceImage = image
			cropper.reset()
		}
	}
	
	let cropper: CropperView = CropperView()
	var owner: ViewController? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .gray
		cropper.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(cropper)
		
		cropper.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		cropper.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		cropper.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		cropper.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
		
		let useButton: UIButton = UIButton()
		useButton.backgroundColor = .black
		useButton.setTitle("Use", for: .normal)
		useButton.addTarget(self, action:#selector(self.useClicked), for: .touchUpInside)
		useButton.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(useButton)
		
		useButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		useButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		useButton.topAnchor.constraint(equalTo: cropper.bottomAnchor).isActive = true
		
		let cancelButton: UIButton = UIButton()
		cancelButton.backgroundColor = .black
		cancelButton.setTitle("Cancel", for: .normal)
		cancelButton.addTarget(self, action:#selector(self.cancelClicked), for: .touchUpInside)
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(cancelButton)
		
		cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		cancelButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		cancelButton.topAnchor.constraint(equalTo: cropper.bottomAnchor).isActive = true
	}
	
	@objc
	func useClicked() {
		 _ = cropper.crop() { img in
			self.owner?.imageView.image = img
			self.owner?.dismiss(animated: true) {
				self.dismiss(animated: false)
			}
		}
	}
	
	@objc
	func cancelClicked() {
		 owner?.dismiss(animated: true) {
			self.dismiss(animated: false)
		}
	}
}
