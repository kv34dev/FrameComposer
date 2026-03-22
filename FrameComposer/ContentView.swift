import SwiftUI
import AVFoundation
import CoreMotion

struct ContentView: View {
    @StateObject private var camera = CameraManager()
    @StateObject private var motionManager = MotionManager()

    @State private var selectedTemplate: GridTemplate = .ruleOfThirds
    @State private var selectedAspectRatio: AspectRatio = .threeByFour
    @State private var overlayOpacity: Double = 0.7
    @State private var showTemplatePicker = false
    @State private var showCapturedImage = false
    @State private var flashEffect = false
    @State private var fibonacciRotation: FibonacciRotation = .topLeft

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if camera.permissionGranted {
                cameraBody
            } else {
                permissionDeniedView
            }
        }
        .statusBarHidden(true)
        .onAppear {
            camera.startSession()
            motionManager.start()
        }
        .onDisappear {
            camera.stopSession()
            motionManager.stop()
        }
    }

    // MARK: - Camera Body
    var cameraBody: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            FrameMaskView(aspectRatio: selectedAspectRatio)
                .ignoresSafeArea()

            GridOverlayView(
                template: selectedTemplate,
                aspectRatio: selectedAspectRatio,
                opacity: overlayOpacity,
                fibonacciRotation: fibonacciRotation,
                horizonAngle: $motionManager.rollAngle
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            if flashEffect {
                Color.white
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                topBar
                Spacer()
                // Show fibonacci rotation controls when that template is active
                if selectedTemplate == .fibonacci {
                    fibonacciControls
                        .padding(.bottom, 8)
                }
                bottomControls
            }

            if showTemplatePicker {
                VStack {
                    Spacer()
                    TemplatePicker(
                        selectedTemplate: $selectedTemplate,
                        isShowing: $showTemplatePicker
                    )
                }
                .ignoresSafeArea()
                .transition(.move(edge: .bottom))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showTemplatePicker)
                .background(
                    Color.clear
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showTemplatePicker = false } }
                )
                .zIndex(10)
            }

            if showCapturedImage, let img = camera.capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(20)
            }
        }
    }

    // MARK: - Top Bar
    var topBar: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("FRAME COMPOSER")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .kerning(3)

            Spacer()

            HStack(spacing: 4) {
                ForEach(AspectRatio.allCases) { ratio in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedAspectRatio = ratio
                        }
                    } label: {
                        Text(ratio.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(selectedAspectRatio == ratio ? .black : .white.opacity(0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(selectedAspectRatio == ratio ? Color.white : Color.white.opacity(0.15))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 12)
    }

    // MARK: - Fibonacci Rotation Controls
    var fibonacciControls: some View {
        HStack(spacing: 8) {
            Text("SPIRAL")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .kerning(2)

            ForEach(FibonacciRotation.allCases) { rot in
                Button {
                    withAnimation(.spring(response: 0.25)) {
                        fibonacciRotation = rot
                    }
                } label: {
                    Text(rot.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(fibonacciRotation == rot ? .black : .white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(fibonacciRotation == rot ? Color.orange : Color.white.opacity(0.15))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Bottom Controls
    var bottomControls: some View {
        VStack(spacing: 20) {
            opacitySlider

            HStack(alignment: .center, spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        showTemplatePicker.toggle()
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 50, height: 50)
                            Image(systemName: "square.grid.3x3")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.white)
                        }
                        Text(selectedTemplate.rawValue)
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                            .frame(width: 72)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button {
                    triggerCapture()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 76, height: 76)
                        Circle()
                            .fill(camera.isCapturing ? Color.white.opacity(0.6) : Color.white)
                            .frame(width: 64, height: 64)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(camera.isCapturing ? 0.9 : 1.0)
                .animation(.spring(response: 0.2), value: camera.isCapturing)

                Spacer()

                Button {
                    camera.toggleCamera()
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 50, height: 50)
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.white)
                        }
                        Text(camera.isUsingFrontCamera ? "Front" : "Rear")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 28)
        }
        .padding(.bottom, 44)
    }

    // MARK: - Opacity Slider
    var opacitySlider: some View {
        HStack(spacing: 10) {
            Image(systemName: "square.dashed")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))

            Slider(value: $overlayOpacity, in: 0.1...1.0)
                .tint(Color.white)
                .frame(width: 120)

            Image(systemName: "square.filled.and.square")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.1)))
    }

    // MARK: - Permission View
    var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.4))

            Text("Camera Access Required")
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)

            Text("Allow access in\nSettings → Privacy → Camera")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(20)
        }
    }

    // MARK: - Actions
    func triggerCapture() {
        withAnimation(.easeOut(duration: 0.05)) { flashEffect = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeIn(duration: 0.2)) { flashEffect = false }
        }
        camera.capturePhoto()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { showCapturedImage = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { showCapturedImage = false }
            }
        }
    }
}

// MARK: - Frame Mask
struct FrameMaskView: View {
    let aspectRatio: AspectRatio

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let targetRatio = aspectRatio.ratio
            let containerRatio = size.width / size.height

            let frameSize: CGSize = {
                if containerRatio > targetRatio {
                    let h = size.height
                    return CGSize(width: h * targetRatio, height: h)
                } else {
                    let w = size.width
                    return CGSize(width: w, height: w / targetRatio)
                }
            }()

            let ox = (size.width - frameSize.width) / 2
            let oy = (size.height - frameSize.height) / 2

            Rectangle()
                .fill(Color.black.opacity(0.55))
                .mask(
                    ZStack {
                        Rectangle().fill(Color.white)
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: frameSize.width, height: frameSize.height)
                            .offset(x: ox - (size.width - frameSize.width) / 2,
                                    y: oy - (size.height - frameSize.height) / 2)
                    }
                    .compositingGroup()
                    .luminanceToAlpha()
                )
        }
    }
}

// MARK: - Motion Manager
class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    @Published var rollAngle: Double = 0.0

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion = motion else { return }
            // Roll = rotation around the Z axis (portrait tilt left/right)
            self?.rollAngle = motion.attitude.roll
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
