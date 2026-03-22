import SwiftUI
import CoreMotion

// MARK: - Grid Overlay Container
struct GridOverlayView: View {
    let template: GridTemplate
    let aspectRatio: AspectRatio
    let opacity: Double
    let fibonacciRotation: FibonacciRotation
    @Binding var horizonAngle: Double  // live tilt angle from accelerometer

    var body: some View {
        GeometryReader { geo in
            let size = frameSize(in: geo.size)
            let origin = frameOrigin(in: geo.size, frameSize: size)

            ZStack {
                // Frame border
                Rectangle()
                    .stroke(Color.white, lineWidth: 1.5)
                    .frame(width: size.width, height: size.height)
                    .position(x: origin.x + size.width / 2, y: origin.y + size.height / 2)

                // Grid lines
                gridContent(size: size)
                    .frame(width: size.width, height: size.height)
                    .position(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
                    .clipped()
            }
        }
        .opacity(opacity)
    }

    private func frameSize(in containerSize: CGSize) -> CGSize {
        let containerRatio = containerSize.width / containerSize.height
        let targetRatio = aspectRatio.ratio
        if containerRatio > targetRatio {
            let height = containerSize.height
            return CGSize(width: height * targetRatio, height: height)
        } else {
            let width = containerSize.width
            return CGSize(width: width, height: width / targetRatio)
        }
    }

    private func frameOrigin(in containerSize: CGSize, frameSize: CGSize) -> CGPoint {
        CGPoint(
            x: (containerSize.width - frameSize.width) / 2,
            y: (containerSize.height - frameSize.height) / 2
        )
    }

    @ViewBuilder
    private func gridContent(size: CGSize) -> some View {
        switch template {
        case .ruleOfThirds:
            RuleOfThirdsGrid(size: size)
        case .goldenRatio:
            GoldenRatioGrid(size: size)
        case .diagonals:
            DiagonalsGrid(size: size)
        case .center:
            CenterGrid(size: size)
        case .fibonacci:
            FibonacciGrid(size: size, rotation: fibonacciRotation)
        case .horizons:
            HorizonsGrid(size: size, tiltAngle: horizonAngle)
        case .portrait:
            PortraitGrid(size: size)
        case .symmetry:
            SymmetryGrid(size: size)
        }
    }
}

// MARK: - Rule of Thirds
struct RuleOfThirdsGrid: View {
    let size: CGSize

    var body: some View {
        Canvas { context, _ in
            let w = size.width
            let h = size.height
            let lineColor = Color.white
            let dotColor = Color.yellow

            for i in [1, 2] {
                let x = w * CGFloat(i) / 3
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: h))
                context.stroke(path, with: .color(lineColor), lineWidth: 1.2)
            }
            for i in [1, 2] {
                let y = h * CGFloat(i) / 3
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: w, y: y))
                context.stroke(path, with: .color(lineColor), lineWidth: 1.2)
            }
            for i in [1, 2] {
                for j in [1, 2] {
                    let pt = CGPoint(x: w * CGFloat(i) / 3, y: h * CGFloat(j) / 3)
                    let rect = CGRect(x: pt.x - 6, y: pt.y - 6, width: 12, height: 12)
                    context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Golden Ratio
struct GoldenRatioGrid: View {
    let size: CGSize
    let phi: CGFloat = 1.618

    var body: some View {
        Canvas { context, _ in
            let w = size.width
            let h = size.height
            let color = Color.yellow
            let dotColor = Color.orange

            let vx = w / phi
            let hx = h / phi

            for x in [vx, w - vx] {
                var p = Path()
                p.move(to: CGPoint(x: x, y: 0))
                p.addLine(to: CGPoint(x: x, y: h))
                context.stroke(p, with: .color(color), lineWidth: 1.5)
            }
            for y in [hx, h - hx] {
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: w, y: y))
                context.stroke(p, with: .color(color), lineWidth: 1.5)
            }
            for pt in [CGPoint(x: vx, y: hx), CGPoint(x: w - vx, y: hx),
                       CGPoint(x: vx, y: h - hx), CGPoint(x: w - vx, y: h - hx)] {
                let rect = CGRect(x: pt.x - 6, y: pt.y - 6, width: 12, height: 12)
                context.fill(Path(ellipseIn: rect), with: .color(dotColor))
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Diagonals
struct DiagonalsGrid: View {
    let size: CGSize

    var body: some View {
        Canvas { context, _ in
            let w = size.width
            let h = size.height
            let color = Color.cyan

            var d1 = Path()
            d1.move(to: .zero)
            d1.addLine(to: CGPoint(x: w, y: h))
            context.stroke(d1, with: .color(color), lineWidth: 1.5)

            var d2 = Path()
            d2.move(to: CGPoint(x: w, y: 0))
            d2.addLine(to: CGPoint(x: 0, y: h))
            context.stroke(d2, with: .color(color), lineWidth: 1.5)

            let subColor = Color.cyan.opacity(0.5)
            let cx = w / 2
            let cy = h / 2
            for (start, end) in [
                (CGPoint(x: 0, y: 0), CGPoint(x: cx, y: cy * 0.5)),
                (CGPoint(x: w, y: 0), CGPoint(x: cx, y: cy * 0.5)),
                (CGPoint(x: 0, y: h), CGPoint(x: cx, y: h - cy * 0.5)),
                (CGPoint(x: w, y: h), CGPoint(x: cx, y: h - cy * 0.5))
            ] {
                var p = Path()
                p.move(to: start)
                p.addLine(to: end)
                context.stroke(p, with: .color(subColor), lineWidth: 0.8)
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Center Grid
struct CenterGrid: View {
    let size: CGSize

    var body: some View {
        Canvas { context, _ in
            let w = size.width
            let h = size.height
            let color = Color.white

            var v = Path()
            v.move(to: CGPoint(x: w / 2, y: 0))
            v.addLine(to: CGPoint(x: w / 2, y: h))
            context.stroke(v, with: .color(color), lineWidth: 1.2)

            var hl = Path()
            hl.move(to: CGPoint(x: 0, y: h / 2))
            hl.addLine(to: CGPoint(x: w, y: h / 2))
            context.stroke(hl, with: .color(color), lineWidth: 1.2)

            for r in [min(w, h) * 0.1, min(w, h) * 0.2, min(w, h) * 0.35] {
                let rect = CGRect(x: w/2 - r, y: h/2 - r, width: r*2, height: r*2)
                context.stroke(Path(ellipseIn: rect), with: .color(color.opacity(0.7)), lineWidth: 1.0)
            }
            let dotRect = CGRect(x: w/2 - 5, y: h/2 - 5, width: 10, height: 10)
            context.fill(Path(ellipseIn: dotRect), with: .color(Color.white))
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Fibonacci Spiral (correct with rotation)
struct FibonacciGrid: View {
    let size: CGSize
    let rotation: FibonacciRotation

    var body: some View {
        ZStack {
            Canvas { context, sz in
                drawFibonacci(context: context, size: sz)
            }
        }
        .rotationEffect(.degrees(rotation.degrees))
        .frame(width: size.width, height: size.height)
    }

    // Draws a proper Fibonacci/golden spiral using golden ratio rectangles
    func drawFibonacci(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let phi: CGFloat = 1.618033988749895

        let color = Color.orange
        let gridColor = Color.orange.opacity(0.55)
        let lineWidth: CGFloat = 2.0

        // Fibonacci rectangle sequence (normalized to fit frame)
        // We place rectangles in sequence: right, down, left, up (counterclockwise spiral)
        // Starting with full width as first rectangle

        // Fit the golden spiral into the frame.
        // The golden rectangle has ratio phi:1
        // We'll work in normalized 0..1 space then scale.

        // Sequence of squares in golden rectangle (normalized, total = phi+1 wide, 1 tall):
        // rect1: x=0, y=0, size=1x1
        // rect2: x=1, y=0, size=(phi-1)x(phi-1) -- but phi-1 = 1/phi
        // ... continue subdividing

        // Instead: use a cleaner approach - place 6 Fibonacci squares filling the frame
        // The golden rectangle = phi : 1. We map it to our frame.

        let frameRatio = w / h
        var drawW: CGFloat
        var drawH: CGFloat

        if frameRatio > phi {
            // wider than golden ratio
            drawH = h
            drawW = h * phi
        } else {
            drawW = w
            drawH = w / phi
        }

        let offsetX = (w - drawW) / 2
        let offsetY = (h - drawH) / 2

        // Subdivide into squares. Direction cycle: right→down→left→up
        // Start: full golden rect = drawW x drawH, large square = drawH x drawH on left
        struct Rect { var x, y, w, h: CGFloat }

        var rects: [Rect] = []
        var current = Rect(x: offsetX, y: offsetY, w: drawW, h: drawH)

        // Direction: 0=left square, 1=top square, 2=right square, 3=bottom square
        let dirs = [0, 1, 2, 3, 0, 1, 2, 3]
        for dir in dirs {
            if current.w < 2 || current.h < 2 { break }
            let sq: CGFloat
            var squareRect: Rect
            var remaining: Rect

            switch dir {
            case 0: // cut left square
                sq = min(current.w, current.h)
                squareRect = Rect(x: current.x, y: current.y, w: sq, h: sq)
                remaining = Rect(x: current.x + sq, y: current.y, w: current.w - sq, h: current.h)
            case 1: // cut top square
                sq = min(current.w, current.h)
                squareRect = Rect(x: current.x, y: current.y, w: sq, h: sq)
                remaining = Rect(x: current.x, y: current.y + sq, w: current.w, h: current.h - sq)
            case 2: // cut right square
                sq = min(current.w, current.h)
                squareRect = Rect(x: current.x + current.w - sq, y: current.y, w: sq, h: sq)
                remaining = Rect(x: current.x, y: current.y, w: current.w - sq, h: current.h)
            case 3: // cut bottom square
                sq = min(current.w, current.h)
                squareRect = Rect(x: current.x, y: current.y + current.h - sq, w: sq, h: sq)
                remaining = Rect(x: current.x, y: current.y, w: current.w, h: current.h - sq)
            default:
                squareRect = current
                remaining = current
            }
            rects.append(squareRect)
            current = remaining
        }

        // Draw rectangle grid lines
        for r in rects {
            var p = Path()
            p.addRect(CGRect(x: r.x, y: r.y, width: r.w, height: r.h))
            context.stroke(p, with: .color(gridColor), lineWidth: 0.8)
        }

        // Draw spiral arcs through each square
        // Arc direction matches the subdivision direction
        var spiralPath = Path()
        let arcDirs = [0, 1, 2, 3, 0, 1, 2, 3]
        // Arc: for each square, draw quarter-circle from one corner to opposite corner
        // Arc center is the corner of the square opposite to where we came from
        for (i, r) in rects.enumerated() {
            guard i < arcDirs.count else { break }
            let dir = arcDirs[i]
            // Center and start/end angles depend on which corner the arc curves around
            let center: CGPoint
            let startAngle: Angle
            let endAngle: Angle

            switch dir {
            case 0: // left square, arc from bottom-left corner going right/up
                center = CGPoint(x: r.x + r.w, y: r.y + r.h)
                startAngle = .degrees(180)
                endAngle = .degrees(270)
            case 1: // top square, arc from top-right corner going down/left
                center = CGPoint(x: r.x, y: r.y + r.h)
                startAngle = .degrees(270)
                endAngle = .degrees(0)
            case 2: // right square, arc from top-right corner going left/down
                center = CGPoint(x: r.x, y: r.y)
                startAngle = .degrees(0)
                endAngle = .degrees(90)
            case 3: // bottom square, arc from bottom-left corner going up/right
                center = CGPoint(x: r.x + r.w, y: r.y)
                startAngle = .degrees(90)
                endAngle = .degrees(180)
            default:
                continue
            }

            let radius = r.w // square, so w == h
            spiralPath.addArc(center: center, radius: radius,
                              startAngle: startAngle, endAngle: endAngle,
                              clockwise: false)
        }

        context.stroke(spiralPath, with: .color(color), lineWidth: lineWidth)

        // Draw the outer golden rectangle border
        var border = Path()
        border.addRect(CGRect(x: offsetX, y: offsetY, width: drawW, height: drawH))
        context.stroke(border, with: .color(color.opacity(0.7)), lineWidth: 1.0)
    }
}

// MARK: - Horizons Grid (gravity-aware)
struct HorizonsGrid: View {
    let size: CGSize
    let tiltAngle: Double  // radians, 0 = phone vertical, positive = tilted right

    var body: some View {
        Canvas { context, _ in
            let w = size.width
            let h = size.height

            // Draw 5 horizontal lines that tilt with the phone
            // tiltAngle is the roll of the phone; lines stay "horizontal" relative to gravity
            let angle = tiltAngle

            // For each line ratio, draw a line across the full canvas at that height,
            // rotated around the center by the tilt angle so it stays earth-horizontal
            let ratios: [(CGFloat, Color, CGFloat)] = [
                (0.2,  Color.blue,  1.5),
                (0.33, Color.white, 1.2),
                (0.5,  Color.white, 0.8),
                (0.67, Color.white, 1.2),
                (0.8,  Color.blue,  1.5),
            ]

            let cx = w / 2
            let cy = h / 2
            let diag = sqrt(w * w + h * h)  // long enough line to always cross full frame

            for (ratio, color, lw) in ratios {
                // Center of this line (relative to frame center)
                let lineY = h * ratio
                let dy = lineY - cy  // offset from center

                // The line extends horizontally from center, but offset by dy vertically
                // When tilted, we rotate the offset direction too
                let cosA = CGFloat(cos(angle))
                let sinA = CGFloat(sin(angle))

                // Rotated center of line
                let lineCx = cx - dy * sinA
                let lineCy = cy + dy * cosA

                // Line direction (perpendicular to tilt)
                let dx = cosA * diag / 2
                let dy2 = sinA * diag / 2

                let start = CGPoint(x: lineCx - dx, y: lineCy - dy2)
                let end   = CGPoint(x: lineCx + dx, y: lineCy + dy2)

                var p = Path()
                p.move(to: start)
                p.addLine(to: end)
                context.stroke(p, with: .color(color), lineWidth: lw)
            }

            // True vertical line (tilted) - perpendicular to horizon lines
            let perpDx = -CGFloat(sin(angle)) * diag / 2
            let perpDy =  CGFloat(cos(angle)) * diag / 2

            var vc = Path()
            vc.move(to: CGPoint(x: cx + perpDx, y: cy + perpDy))
            vc.addLine(to: CGPoint(x: cx - perpDx, y: cy - perpDy))
            context.stroke(vc, with: .color(Color.white.opacity(0.4)), lineWidth: 0.8)

            // Level indicator dot
            let dotR: CGFloat = 5
            let dotRect = CGRect(x: cx - dotR, y: cy - dotR, width: dotR*2, height: dotR*2)
            context.fill(Path(ellipseIn: dotRect), with: .color(Color.yellow))
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Portrait Grid
struct PortraitGrid: View {
    let size: CGSize

    var body: some View {
        Canvas { context, _ in
            let w = size.width
            let h = size.height
            let accentColor = Color.pink
            let subColor = Color.white.opacity(0.7)

            let eyeY = h * 0.3
            for (y, c, lw) in [(eyeY, accentColor, 1.5),
                                 (h * 0.6, accentColor.opacity(0.8), 1.2),
                                 (h * 0.75, subColor, 1.0)] {
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: w, y: y))
                context.stroke(p, with: .color(c), lineWidth: lw)
            }

            var cv = Path()
            cv.move(to: CGPoint(x: w / 2, y: 0))
            cv.addLine(to: CGPoint(x: w / 2, y: h))
            context.stroke(cv, with: .color(subColor), lineWidth: 1.0)

            for xRatio in [0.33, 0.67] as [CGFloat] {
                var lp = Path()
                lp.move(to: CGPoint(x: w * xRatio, y: 0))
                lp.addLine(to: CGPoint(x: w * xRatio, y: h))
                context.stroke(lp, with: .color(subColor.opacity(0.6)), lineWidth: 0.8)
            }

            let ovalW = w * 0.55
            let ovalH = h * 0.5
            let ovalRect = CGRect(x: (w - ovalW) / 2, y: eyeY - ovalH * 0.3,
                                   width: ovalW, height: ovalH)
            context.stroke(Path(ellipseIn: ovalRect), with: .color(accentColor.opacity(0.6)), lineWidth: 1.0)

            for xRatio in [0.35, 0.65] as [CGFloat] {
                let pt = CGPoint(x: w * xRatio, y: eyeY)
                let r: CGFloat = 5
                context.fill(Path(ellipseIn: CGRect(x: pt.x-r, y: pt.y-r, width: r*2, height: r*2)),
                             with: .color(accentColor))
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Symmetry Grid
struct SymmetryGrid: View {
    let size: CGSize

    var body: some View {
        Canvas { context, _ in
            let w = size.width
            let h = size.height
            let color = Color.white

            var vc = Path()
            vc.move(to: CGPoint(x: w / 2, y: 0))
            vc.addLine(to: CGPoint(x: w / 2, y: h))
            context.stroke(vc, with: .color(color), lineWidth: 1.8)

            var hc = Path()
            hc.move(to: CGPoint(x: 0, y: h / 2))
            hc.addLine(to: CGPoint(x: w, y: h / 2))
            context.stroke(hc, with: .color(color), lineWidth: 1.8)

            for ratio in [0.25, 0.75] as [CGFloat] {
                var vp = Path()
                vp.move(to: CGPoint(x: w * ratio, y: 0))
                vp.addLine(to: CGPoint(x: w * ratio, y: h))
                context.stroke(vp, with: .color(color.opacity(0.5)), lineWidth: 0.8)

                var hp = Path()
                hp.move(to: CGPoint(x: 0, y: h * ratio))
                hp.addLine(to: CGPoint(x: w, y: h * ratio))
                context.stroke(hp, with: .color(color.opacity(0.5)), lineWidth: 0.8)
            }

            var d1 = Path()
            d1.move(to: CGPoint(x: 0, y: 0))
            d1.addLine(to: CGPoint(x: w, y: h))
            context.stroke(d1, with: .color(color.opacity(0.35)), lineWidth: 0.7)

            var d2 = Path()
            d2.move(to: CGPoint(x: w, y: 0))
            d2.addLine(to: CGPoint(x: 0, y: h))
            context.stroke(d2, with: .color(color.opacity(0.35)), lineWidth: 0.7)
        }
        .frame(width: size.width, height: size.height)
    }
}
