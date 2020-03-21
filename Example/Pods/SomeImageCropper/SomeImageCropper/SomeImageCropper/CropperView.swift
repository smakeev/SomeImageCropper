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
	
	public var sourceImage: UIImage? = nil {
		didSet {
			selectorView.mainImage      = sourceImage
			selectorView.secondaryImage = sourceImage
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
	}
	
	public func crop(with handler: ((UIImage?) -> Void)? = nil) -> Bool {
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
			DispatchQueue.global().async { [weak self] in
				guard let validSelf = self else { return }
				let result = validSelf.engine.doCrop(for: source, rect: rect, scale: 1.0)
				DispatchQueue.main.async {
					resultProvider(result)
					validSelf.inProgress = false
				}
			}
		}
		
		return true
	}
	
	
}
