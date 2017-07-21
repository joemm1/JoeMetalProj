import UIKit
import Metal

class ViewController: UIViewController
{
    var device:             MTLDevice!
    var metalLayer:         CAMetalLayer!
    var pipelineState:      MTLRenderPipelineState!
    var commandQueue:       MTLCommandQueue!
    var timer:              CADisplayLink!
    var projectionMatrix:   Matrix4!
    var lastFrameTimestamp: CFTimeInterval = 0.0
    var subMeshes =         Array<SubMesh>()
  
    override func viewDidLoad()
    {
        super.viewDidLoad()

        device = MTLCreateSystemDefaultDevice()

        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)

        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        let cube = Cube(device: device, world: Matrix4())
        subMeshes.append(cube)

        commandQueue = device.makeCommandQueue()

        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }

    func render()
    {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let viewMatrix = Matrix4()
        viewMatrix.translate(0.0, y: 0.0, z: -7.0)
        viewMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)

        let metalObjects = MetalObjects(device: self.device, commandQueue: self.commandQueue, drawable: drawable)
        let clearColour = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        let perPassUniforms = PerPassUniforms(device: self.device, binding: 1, view: viewMatrix, proj: projectionMatrix)

        let renderPass = RenderPass()
        renderPass.render(metalObjects: metalObjects, clearColour: clearColour, perPassUniforms: perPassUniforms, subMeshes: subMeshes)
    }

    func newFrame(displayLink: CADisplayLink)
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
        for subMesh in subMeshes
        {
            subMesh.update(delta: timeSinceLastUpdate)
        }
        
        autoreleasepool
        {
            self.render()
        }
    }

}

