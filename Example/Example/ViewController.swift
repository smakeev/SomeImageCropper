//
//  ViewController.swift
//  Example
//
//  Created by Sergey Makeev on 20.03.2020.
//  Copyright © 2020 SOME projects. All rights reserved.
//

import UIKit
import SomeImageCropper

class ViewController: UIViewController {

	let pickerController = UIImagePickerController()
	let cropViewController = CropViewController()
	
	@IBOutlet weak var imageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		pickerController.delegate = self
		cropViewController.owner = self
		pickerController.allowsEditing = false
		pickerController.mediaTypes = ["public.image"]
	}

	@IBAction func takePhoto(_ sender: Any) {
		pickerController.sourceType = .camera
		self.present(pickerController, animated: true, completion: nil)
	}
	
	
	@IBAction func takeImage(_ sender: Any) {
		pickerController.sourceType = .photoLibrary
		self.present(pickerController, animated: true, completion: nil)
	}
	
	
	func crop(_ image: UIImage?) {
		guard let validImage = image else { return }
		cropViewController.image = validImage
		self.present(cropViewController, animated: true)
	}
}

extension ViewController: UIImagePickerControllerDelegate {
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.dismiss(animated: true) {
			self.pickerController.dismiss(animated: false)
		}
	}
	
	public func imagePickerController(_ picker: UIImagePickerController,
									  didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		let image = info[.originalImage] as? UIImage
		self.dismiss(animated: true) {
			self.pickerController.dismiss(animated: false) {
				self.crop(image)
			}
		}
	}
}

extension ViewController: UINavigationControllerDelegate {
	
}
