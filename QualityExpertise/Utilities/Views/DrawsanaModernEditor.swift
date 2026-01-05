//
//  DrawsanaModernEditor.swift
//  ALNASR
//
//  Created by Amarjith B on 13/11/25.
//



import UIKit
import Drawsana

class ModernDrawsanaEditorVC: UIViewController, DrawsanaViewDelegate, SelectionToolDelegate {
    func selectionToolDidTapOnAlreadySelectedShape(_ shape: any Drawsana.ShapeSelectable) {
        
    }
    
    func drawsanaView(_ drawsanaView: Drawsana.DrawsanaView, didSwitchTo tool: any Drawsana.DrawingTool) {
        
    }
    
    func drawsanaView(_ drawsanaView: Drawsana.DrawsanaView, didStartDragWith tool: any Drawsana.DrawingTool) {
        
    }
    
    func drawsanaView(_ drawsanaView: Drawsana.DrawsanaView, didEndDragWith tool: any Drawsana.DrawingTool) {
        
    }
    
    func drawsanaView(_ drawsanaView: Drawsana.DrawsanaView, didChangeStrokeColor strokeColor: UIColor?) {
        
    }
    
    func drawsanaView(_ drawsanaView: Drawsana.DrawsanaView, didChangeFillColor fillColor: UIColor?) {
        
    }
    
    func drawsanaView(_ drawsanaView: Drawsana.DrawsanaView, didChangeStrokeWidth strokeWidth: CGFloat) {
        
    }
    
    func drawsanaView(_ drawsanaView: Drawsana.DrawsanaView, didChangeFontName fontName: String) {
        
    }
    
    func drawsanaView(_ drawsanaView: Drawsana.DrawsanaView, didChangeFontSize fontSize: CGFloat) {
        
    }
    

    // MARK: - Inputs
    let baseImage: UIImage
    var onDone: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - Drawsana
    let drawingView = DrawsanaView()
    lazy var textTool = TextTool(delegate: self)
    lazy var selectionTool = SelectionTool(delegate: self)

    // MARK: - UI
    private let topBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let bottomBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    private let toolScroll = UIScrollView()
    private let colorScroll = UIScrollView()

    init(image: UIImage,
         onDone: ((UIImage) -> Void)?,
         onCancel: (() -> Void)?) {
        self.baseImage = image
        self.onDone = onDone
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupDrawingCanvas()
        setupTopBar()
        setupBottomBar()
        setupTools()
        setupColors()
    }

    private func setupDrawingCanvas() {
        drawingView.delegate = self
        drawingView.backgroundColor = .clear
        drawingView.userSettings.strokeWidth = 4
        drawingView.userSettings.strokeColor = .red

        let bg = UIImageView(image: baseImage)
        bg.contentMode = .scaleAspectFit
        bg.frame = view.bounds
        bg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(bg)

        drawingView.frame = bg.frame
        drawingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(drawingView)
    }

    // MARK: - Top Bar
    private func setupTopBar() {
        topBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 60)
        topBar.autoresizingMask = [.flexibleWidth]
        view.addSubview(topBar)

        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(.white, for: .normal)
        cancel.frame = CGRect(x: 15, y: 12, width: 80, height: 36)
        cancel.addAction(UIAction(handler: { _ in
            self.onCancel?()
        }), for: .touchUpInside)

        let done = UIButton(type: .system)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel?.font = .boldSystemFont(ofSize: 17)
        done.frame = CGRect(x: topBar.bounds.width - 95, y: 12, width: 80, height: 36)
        done.autoresizingMask = .flexibleLeftMargin
        done.addAction(UIAction(handler: { _ in self.finish() }), for: .touchUpInside)

        topBar.contentView.addSubview(cancel)
        topBar.contentView.addSubview(done)
    }

    // MARK: - Bottom Bar
    private func setupBottomBar() {
        let h: CGFloat = 120
        bottomBar.frame = CGRect(
            x: 0, y: view.bounds.height - h,
            width: view.bounds.width, height: h
        )
        bottomBar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(bottomBar)

        toolScroll.frame = CGRect(x: 0, y: 10, width: bottomBar.bounds.width, height: 55)
        toolScroll.showsHorizontalScrollIndicator = false
        colorScroll.frame = CGRect(x: 0, y: 70, width: bottomBar.bounds.width, height: 45)
        colorScroll.showsHorizontalScrollIndicator = false

        bottomBar.contentView.addSubview(toolScroll)
        bottomBar.contentView.addSubview(colorScroll)
    }

    // MARK: - Tools
    private func setupTools() {
        let tools: [(String, DrawingTool)] = [
            ("✏️", PenTool()),
            ("🩹", EraserTool()),
            ("⬛️", RectTool()),
            ("🟠", EllipseTool()),
            ("➡️", ArrowTool()),
            ("🔤", textTool),
            ("✥", selectionTool)
        ]

        var x: CGFloat = 10

        for (title, tool) in tools {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.tintColor = .white
            btn.frame = CGRect(x: x, y: 5, width: 50, height: 50)
            btn.layer.cornerRadius = 25
            btn.backgroundColor = UIColor.white.withAlphaComponent(0.12)

            btn.addAction(UIAction(handler: { _ in
                self.drawingView.set(tool: tool)
            }), for: .touchUpInside)

            toolScroll.addSubview(btn)
            x += 60
        }

        toolScroll.contentSize = CGSize(width: x, height: 55)
    }

    // MARK: - Colors
    private func setupColors() {
        let colors: [UIColor] = [
            .white, .black, .systemRed, .systemYellow,
            .systemGreen, .systemBlue, .systemOrange, .systemPurple
        ]
        var x: CGFloat = 10

        for c in colors {
            let btn = UIButton()
            btn.frame = CGRect(x: x, y: 5, width: 35, height: 35)
            btn.layer.cornerRadius = 17
            btn.backgroundColor = c
            btn.layer.borderWidth = (c == .white ? 1.2 : 0)
            btn.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor

            btn.addAction(UIAction(handler: { _ in
                self.drawingView.userSettings.strokeColor = c
                self.drawingView.userSettings.fillColor = c
            }), for: .touchUpInside)

            colorScroll.addSubview(btn)
            x += 45
        }

        colorScroll.contentSize = CGSize(width: x, height: 45)
    }

    // MARK: - Finish (Render)
    private func finish() {
        guard let final = drawingView.render(over: baseImage) else {
            onDone?(baseImage)
            return
        }
        onDone?(final)
    }
}

// MARK: - TextTool Delegates
extension ModernDrawsanaEditorVC: TextToolDelegate {
    func textToolPointForNewText(tappedPoint: CGPoint) -> CGPoint { tappedPoint }
    func textToolDidTapAway(tappedPoint: CGPoint) { drawingView.set(tool: selectionTool) }
    func textToolWillUseEditingView(_ editingView: TextShapeEditingView) {}
    func textToolDidUpdateEditingViewTransform(_ editingView: TextShapeEditingView, transform: ShapeTransform) {}
}
