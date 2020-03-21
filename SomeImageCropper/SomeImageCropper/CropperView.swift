//
//  CropperView.swift
//  SomeImageCropper
//
//  Created by Sergey Makeev on 21.03.2020.
//  Copyright © 2020 SOME projects. All rights reserved.
//

import Foundation
import UIKit
import SomeInnerView

public class CropperView: UIView {
	
	public var selectionView: UIView {
		selectorView.selectionView
	}
	
	public var backgroundView: UIView {
		selectorView.background
	}
	
	private var _sourceImage: UIImage? = nil
	public var sourceImage: UIImage? {
		get {
			return _sourceImage
		}
		set {
			guard let validValue = newValue else {
				_sourceImage = nil
				selectorView.mainImage      = nil
				selectorView.secondaryImage = nil
				return
			}
			_sourceImage = validValue.fixOrientation()
			selectorView.mainImage      = _sourceImage
			selectorView.secondaryImage = _sourceImage
		}
	}
	
	public var selectionIsFixed: Bool = true {
		didSet {
			selectorView.isSelectionFixed = selectionIsFixed
		}
	}
	
	private var engine: CropperEngine!
	private var cropDone: ((UIImage?) -> Void)? = nil
	private var selectorView: InnerView!
	private var inProgress: Bool = false
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		internalInit()
	}
	
	public init() {
		super.init(frame: .zero)
		internalInit()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		internalInit()
	}
	
	private func internalInit() {
		engine = CropperEngine()
		selectorView = InnerView()
		selectorView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(selectorView)
		
		selectorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		selectorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		selectorView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
		selectorView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
		
		let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		
		blurEffectView.translatesAutoresizingMaskIntoConstraints = false
		selectorView.background.addSubview(blurEffectView)
		
		blurEffectView.leadingAnchor.constraint(equalTo: selectorView.background.leadingAnchor).isActive = true
		blurEffectView.trailingAnchor.constraint(equalTo: selectorView.background.trailingAnchor).isActive = true
		blurEffectView.topAnchor.constraint(equalTo: selectorView.background.topAnchor).isActive = true
		blurEffectView.bottomAnchor.constraint(equalTo: selectorView.background.bottomAnchor).isActive = true
		
		selectorView.selectionView.backgroundColor = .white
		
		selectorView.x = 0.25
		selectorView.y = 0.25
		selectorView.bottom = 0.75
		selectorView.right  = 0.75
		selectorView.isSelectionInitialized = true
		
		selectorView.isSelectionFixed = true
		selectorView.selectionView.isUserInteractionEnabled = true
		
		self.clipsToBounds = true
		
		//add tap to move selection center
		let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
		selectorView.background.addGestureRecognizer(tapGesture)
		
	}
	
	@objc
	private func onTap(_ sender: UITapGestureRecognizer) {
		let translation = sender.location(in: selectorView.selectionView.superview)
		selectorView.selectionView.center = translation
		print(translation)
		selectorView.changeSelectionFrame(to: selectorView.selectionView.frame)
	}
	
	public func reset() {
		selectorView.x = 0.25
		selectorView.y = 0.25
		selectorView.bottom = 0.75
		selectorView.right  = 0.75
	}
	
	@discardableResult public func crop(with handler: ((UIImage?) -> Void)? = nil) -> Bool {
		guard !inProgress else { return false }
		if handler != nil {
			cropDone = handler
		}
		
		cropDone.map { resultProvider in
			guard let validImage = sourceImage else { return }
			inProgress = true
			let source: UIImage = validImage.copy() as! UIImage
			let rect = CGRect(x: selectorView.x,
							y: selectorView.y,
							width: selectorView.right - selectorView.x,
							height: selectorView.bottom - selectorView.y)
			let scale = Double(selectorView.zoom)
			DispatchQueue.global().async { [weak self] in
				guard let validSelf = self else { return }
				let result = validSelf.engine.doCrop(for: source, rect: rect, scale: NSNumber(floatLiteral: scale))
				DispatchQueue.main.async {
					resultProvider(result)
					validSelf.inProgress = false
				}
			}
		}
		
		return true
	}
}

internal extension UIImage {
// Repair Picture Rotation
func fixOrientation() -> UIImage {
	if self.imageOrientation == .up {
		return self
	}
	
	var transform = CGAffineTransform.identity
	
	switch self.imageOrientation {
	case .down, .downMirrored:
		transform = transform.translatedBy(x: self.size.width, y: self.size.height)
		transform = transform.rotated(by: .pi)
		break
		
	case .left, .leftMirrored:
		transform = transform.translatedBy(x: self.size.width, y: 0)
		transform = transform.rotated(by: .pi / 2)
		break
		
	case .right, .rightMirrored:
		transform = transform.translatedBy(x: 0, y: self.size.height)
		transform = transform.rotated(by: -.pi / 2)
		break
		
	default:
		break
	}
	
	switch self.imageOrientation {
	case .upMirrored, .downMirrored:
		transform = transform.translatedBy(x: self.size.width, y: 0)
		transform = transform.scaledBy(x: -1, y: 1)
		break
		
	case .leftMirrored, .rightMirrored:
		transform = transform.translatedBy(x: self.size.height, y: 0);
		transform = transform.scaledBy(x: -1, y: 1)
		break
		
	default:
		break
	}
	
	let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
	ctx?.concatenate(transform)
	
	switch self.imageOrientation {
	case .left, .leftMirrored, .right, .rightMirrored:
		ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
		break
		
	default:
		ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
		break
	}
	
	let cgimg: CGImage = (ctx?.makeImage())!
	let img = UIImage(cgImage: cgimg)
	
	return img
	}
}
