import SwiftUI

struct TemplatePicker: View {
    @Binding var selectedTemplate: GridTemplate
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.4))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            Text("GRID")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .kerning(3)
                .padding(.bottom, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GridTemplate.allCases) { template in
                        TemplateCard(
                            template: template,
                            isSelected: selectedTemplate == template
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTemplate = template
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation { isShowing = false }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 32)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
}

struct TemplateCard: View {
    let template: GridTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Preview box
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: isSelected ? 1.5 : 0.5)
                        )
                    
                    MiniGridPreview(template: template)
                        .frame(width: 54, height: 72)
                        .clipped()
                        .cornerRadius(8)
                }
                .frame(width: 70, height: 88)
                
                Text(template.rawValue)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 70)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.04 : 1.0)
    }
}

// Mini preview of each grid in card
struct MiniGridPreview: View {
    let template: GridTemplate
    
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            
            switch template {
            case .ruleOfThirds:
                drawGrid(context: context, w: w, h: h, xDivs: [1,2], yDivs: [1,2], total: 3, color: .white)
            case .goldenRatio:
                drawGolden(context: context, w: w, h: h)
            case .diagonals:
                drawDiagonals(context: context, w: w, h: h)
            case .center:
                drawCenter(context: context, w: w, h: h)
            case .fibonacci:
                drawGrid(context: context, w: w, h: h, xDivs: [1,2], yDivs: [1,2], total: 3, color: .orange)
            case .horizons:
                drawHorizons(context: context, w: w, h: h)
            case .portrait:
                drawPortrait(context: context, w: w, h: h)
            case .symmetry:
                drawSymmetry(context: context, w: w, h: h)
            }
        }
        .background(Color.black.opacity(0.4))
    }
    
    func drawGrid(context: GraphicsContext, w: CGFloat, h: CGFloat, xDivs: [Int], yDivs: [Int], total: Int, color: Color) {
        let c = color.opacity(0.7)
        for i in xDivs {
            var p = Path()
            p.move(to: CGPoint(x: w * CGFloat(i) / CGFloat(total), y: 0))
            p.addLine(to: CGPoint(x: w * CGFloat(i) / CGFloat(total), y: h))
            context.stroke(p, with: .color(c), lineWidth: 0.6)
        }
        for i in yDivs {
            var p = Path()
            p.move(to: CGPoint(x: 0, y: h * CGFloat(i) / CGFloat(total)))
            p.addLine(to: CGPoint(x: w, y: h * CGFloat(i) / CGFloat(total)))
            context.stroke(p, with: .color(c), lineWidth: 0.6)
        }
    }
    
    func drawGolden(context: GraphicsContext, w: CGFloat, h: CGFloat) {
        let phi: CGFloat = 1.618
        let c = Color.yellow.opacity(0.7)
        for x in [w / phi, w - w / phi] {
            var p = Path()
            p.move(to: CGPoint(x: x, y: 0))
            p.addLine(to: CGPoint(x: x, y: h))
            context.stroke(p, with: .color(c), lineWidth: 0.6)
        }
        for y in [h / phi, h - h / phi] {
            var p = Path()
            p.move(to: CGPoint(x: 0, y: y))
            p.addLine(to: CGPoint(x: w, y: y))
            context.stroke(p, with: .color(c), lineWidth: 0.6)
        }
    }
    
    func drawDiagonals(context: GraphicsContext, w: CGFloat, h: CGFloat) {
        let c = Color.cyan.opacity(0.8)
        var d1 = Path(); d1.move(to: .zero); d1.addLine(to: CGPoint(x: w, y: h))
        var d2 = Path(); d2.move(to: CGPoint(x: w, y: 0)); d2.addLine(to: CGPoint(x: 0, y: h))
        context.stroke(d1, with: .color(c), lineWidth: 0.8)
        context.stroke(d2, with: .color(c), lineWidth: 0.8)
    }
    
    func drawCenter(context: GraphicsContext, w: CGFloat, h: CGFloat) {
        let c = Color.white.opacity(0.7)
        var v = Path(); v.move(to: CGPoint(x: w/2, y: 0)); v.addLine(to: CGPoint(x: w/2, y: h))
        var hl = Path(); hl.move(to: CGPoint(x: 0, y: h/2)); hl.addLine(to: CGPoint(x: w, y: h/2))
        context.stroke(v, with: .color(c), lineWidth: 0.7)
        context.stroke(hl, with: .color(c), lineWidth: 0.7)
        let r: CGFloat = min(w,h) * 0.2
        context.stroke(Path(ellipseIn: CGRect(x: w/2-r, y: h/2-r, width: r*2, height: r*2)), with: .color(c.opacity(0.5)), lineWidth: 0.5)
    }
    
    func drawHorizons(context: GraphicsContext, w: CGFloat, h: CGFloat) {
        for ratio in [0.25, 0.4, 0.6, 0.75] as [CGFloat] {
            var p = Path()
            p.move(to: CGPoint(x: 0, y: h * ratio))
            p.addLine(to: CGPoint(x: w, y: h * ratio))
            context.stroke(p, with: .color(Color.blue.opacity(0.6)), lineWidth: 0.6)
        }
    }
    
    func drawPortrait(context: GraphicsContext, w: CGFloat, h: CGFloat) {
        let c = Color.pink.opacity(0.7)
        for y in [h * 0.3, h * 0.6] {
            var p = Path()
            p.move(to: CGPoint(x: 0, y: y))
            p.addLine(to: CGPoint(x: w, y: y))
            context.stroke(p, with: .color(c), lineWidth: 0.6)
        }
        var cv = Path(); cv.move(to: CGPoint(x: w/2, y: 0)); cv.addLine(to: CGPoint(x: w/2, y: h))
        context.stroke(cv, with: .color(c.opacity(0.4)), lineWidth: 0.4)
    }
    
    func drawSymmetry(context: GraphicsContext, w: CGFloat, h: CGFloat) {
        let c = Color.white.opacity(0.7)
        var v = Path(); v.move(to: CGPoint(x: w/2, y: 0)); v.addLine(to: CGPoint(x: w/2, y: h))
        var hl = Path(); hl.move(to: CGPoint(x: 0, y: h/2)); hl.addLine(to: CGPoint(x: w, y: h/2))
        context.stroke(v, with: .color(c), lineWidth: 0.8)
        context.stroke(hl, with: .color(c), lineWidth: 0.8)
    }
}
