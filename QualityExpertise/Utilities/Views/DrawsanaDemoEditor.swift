//
//  DrawsanaDemoEditor.swift
//  ALNASR
//
//  Created by Amarjith B on 13/11/25.
//


import UIKit
import Drawsana

class DrawsanaDemoEditor: ViewController {

    var baseImage: UIImage
    var onDone: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    init(image: UIImage, onDone: ((UIImage) -> Void)?, onCancel: (() -> Void)?) {
        self.baseImage = image
        self.onDone = onDone
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // FIX 1: Override loadView and set image BEFORE calling super
    override func loadView() {
        // Assign image so super.loadView() can read it
        self.imageView.image = baseImage
        super.loadView()  // This will now see a valid image
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addTopButtons()
    }

    func addTopButtons() {
        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.tintColor = .white
        done.titleLabel?.font = .boldSystemFont(ofSize: 17)
        done.frame = CGRect(x: view.bounds.width - 90, y: 40, width: 80, height: 40)
        done.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(done)

        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.tintColor = .white
        cancel.titleLabel?.font = .boldSystemFont(ofSize: 17)
        cancel.frame = CGRect(x: 10, y: 40, width: 80, height: 40)
        cancel.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancel)
    }

    @objc private func doneTapped() {
        guard let annotated = drawingView.render(over: imageView.image) else {
            onDone?(baseImage)
            return
        }
        onDone?(annotated)
//        dismiss(animated: true)
    }

    @objc private func cancelTapped() {
        onCancel?()
//        dismiss(animated: true)
    }
}
