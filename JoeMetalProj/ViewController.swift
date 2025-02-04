import UIKit
import Metal

class ViewController: UIViewController
{
    var timer:              CADisplayLink!
    var lastFrameTimestamp: CFTimeInterval = 0.0
	
	var app:				App!
  
    override func viewDidLoad()
    {
        super.viewDidLoad()
		
		app = App(view: self.view)

        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
	
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		app.updateSubViews()
	}

	@objc func newFrame(displayLink: CADisplayLink)
    {
        if lastFrameTimestamp == 0.0
        {
            lastFrameTimestamp = displayLink.timestamp
        }

        let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp

        gameloop(timeSinceLastUpdate: elapsed)
    }
  
    func gameloop(timeSinceLastUpdate: CFTimeInterval)
    {
		let start = Date()
		
		app.update(delta: timeSinceLastUpdate)
		
        autoreleasepool
        {
			app.render()
        }
		
		//print to screen
		let strGpu = String(format: "GPU: %.1f ms", app.renderer.mainPass.lastFrameGpuTime * 1000.0)
		gKernel.textLayer.addEntry(TextEntry(strGpu))
		let strCpu = String(format: "CPU: %.1f ms", (app.renderer.mainPass.timeAtPresent.timeIntervalSince1970 - start.timeIntervalSince1970) * 1000.0)
		gKernel.textLayer.addEntry(TextEntry(strCpu))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
		app.touchMgr.touchStart(point: (touches.first?.location(in: view))!)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
		app.touchMgr.touchMove(point: (touches.first?.location(in: view))!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		app.touchMgr.touchEnd(point: (touches.first?.location(in: view))!)
    }
}

