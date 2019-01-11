import UIKit

public class MJSlider: UIControl {
	
    private let indicatorLayer = CAShapeLayer()
	private let lineWidth = CGFloat(2)
    private var lastTouchedLocation : CGPoint = CGPoint(x: 0, y:0)
    private var indicatorPosition : CGFloat = 0
    var max : CGFloat = 0
    var min : CGFloat = 0
 
    
    public var value: Float{
        get {
            return abs(Float((indicatorPosition / max) - 1))
        }
        set {
            let v = abs((CGFloat(newValue) * max) - max)
            indicatorPosition = v
            self.updateLayer()
        }
     }
   
    private var sliderValue: CGFloat {
		get {
			return indicatorPosition
		}
		set {
			indicatorPosition = newValue
			self.updateLayer()
		}
    }
    private var sliderColor: UIColor?
    private var sliderBackgroundColor: UIColor?
    private var sliderTransparency: Float?
   // private var sliderCornerRadious: Float?
    
//    public var cornerRadius: Float? {
//        get {
//            return CGFloat(sliderCornerRadious)
//        }
//
//        set {
//            sliderCornerRadious = newValue
//            updateLayer()
//        }
//    }
    
    public var transparency : Float? {
        get {
            return sliderTransparency
        }
        
        set {
            sliderTransparency = newValue
            updateLayer()
        }
    }
    // Override tint
    override public var tintColor: UIColor? {
        get {
            return sliderBackgroundColor
        }
        
        set {
            sliderBackgroundColor = newValue
            updateLayer()
        }
    }
    // Override background
    override public var backgroundColor: UIColor?{
        get {
            return sliderColor
        }
        
        set {
            sliderColor = newValue
            updateLayer()
        }
    }

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        max = bounds.height
        min = CGFloat(0)
        updateLayer()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        max = bounds.maxY
        min = bounds.minY
        updateLayer()
        
    }

    private func updateLayer() {
        
    	let shapeLayer = layer as! CAShapeLayer
        shapeLayer.lineWidth = lineWidth
        
        if let color = sliderColor {
            shapeLayer.backgroundColor = color.cgColor
        }
        else {
            shapeLayer.backgroundColor = UIColor.blue.cgColor
        }
//        if let cr = sliderCornerRadious{
//            shapeLayer.cornerRadius = CGFloat(cr)
//        } else {
//            shapeLayer.cornerRadius = 20
//        }
        
        if let tr = sliderTransparency{
            shapeLayer.opacity = tr
        } else {
            shapeLayer.opacity = 1
        }
        
        let slider = CGRect(x: 0 , y: sliderValue , width: bounds.width, height: (sliderValue - frame.height) * (-1))
        let path = UIBezierPath(roundedRect: slider, cornerRadius: 0)
        
        indicatorLayer.path = path.cgPath
        indicatorLayer.lineWidth = shapeLayer.lineWidth
        if let color2 = sliderBackgroundColor {
            indicatorLayer.fillColor = color2.cgColor
        }
        else {
            indicatorLayer.fillColor = UIColor.red.cgColor
        }
        
        shapeLayer.masksToBounds = true
        shapeLayer.addSublayer(indicatorLayer)
        
    }

    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        lastTouchedLocation = touch.location(in: self)
        //necessary when adding constraints programmatically, AVF (otherwise frame is zero)

	return true
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // Calculate vector from center to touch.
        let vector  =  touch.location(in: self)

        if vector.y < min {
            sliderValue = min
        } else if vector.y > max {
            sliderValue = max
        } else {
            sliderValue = vector.y
        }
        lastTouchedLocation = vector
        sendActions(for: UIControlEvents.valueChanged)
        return true
    }
   
    open override class var layerClass : AnyClass {
        return CAShapeLayer.self
    }
}
