import SwiftUI

struct LoginHeaderView: View {
    var archDepth: CGFloat = 60

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0xFBEEDC), Color(hex: 0xF8F3EA)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                clouds(width: w, height: h)

                skyTower
                    .position(x: w * 0.1, y: h - 92)

                building(width: 16, height: 44, color: Color(hex: 0xB9C6CF))
                    .position(x: w * 0.19, y: h - 26)

                trees(sizes: [34, 44, 30, 38], color: Color(hex: 0xA9C79B))
                    .position(x: w * 0.1, y: h - 14)

                building(width: 54, height: 78, color: Color(hex: 0xE8D9C0))
                    .position(x: w - 92, y: h - 46)

                building(width: 46, height: 104, color: Color(hex: 0xCAD5DC))
                    .position(x: w - 30, y: h - 58)

                trees(sizes: [30, 40, 34], color: Color(hex: 0xA9C79B))
                    .position(x: w - 60, y: h - 10)

                LoginHeaderArch(depth: archDepth)
                    .fill(Color.white)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }

    private func clouds(width w: CGFloat, height h: CGFloat) -> some View {
        ZStack {
            Ellipse().frame(width: 150, height: 46).position(x: w * 0.78, y: h * 0.32)
            Ellipse().frame(width: 110, height: 34).position(x: w * 0.3, y: h * 0.42)
            Ellipse().frame(width: 90, height: 28).position(x: w * 0.92, y: h * 0.5)
        }
        .foregroundColor(.white.opacity(0.75))
        .blur(radius: 10)
    }

    private var skyTower: some View {
        let color = Color(hex: 0x9DB0BD)
        return VStack(spacing: 0) {
            Rectangle().frame(width: 2, height: 34)
            Circle().frame(width: 5, height: 5)
            Rectangle().frame(width: 3, height: 10)
            Capsule().frame(width: 24, height: 8)
            Capsule().frame(width: 18, height: 12)
            Capsule().frame(width: 22, height: 6)
            TaperedShaft().frame(width: 12, height: 108)
        }
        .foregroundColor(color)
    }

    private func building(width: CGFloat, height: CGFloat, color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: height)
            .overlay(
                VStack(spacing: 6) {
                    ForEach(0..<Int(height / 14), id: \.self) { _ in
                        HStack(spacing: 5) {
                            ForEach(0..<Int(width / 11), id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.white.opacity(0.55))
                                    .frame(width: 5, height: 6)
                            }
                        }
                    }
                }
                .padding(.top, 8),
                alignment: .top
            )
    }

    private func trees(sizes: [CGFloat], color: Color) -> some View {
        HStack(alignment: .bottom, spacing: -10) {
            ForEach(Array(sizes.enumerated()), id: \.offset) { _, size in
                Circle()
                    .fill(color.opacity(0.85))
                    .frame(width: size, height: size)
            }
        }
    }
}

struct LoginHeaderArch: Shape {
    var depth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.maxY - depth * 2)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY + 1))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY + 1))
        path.closeSubpath()
        return path
    }
}

private struct TaperedShaft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topInset = rect.width * 0.3
        path.move(to: CGPoint(x: rect.minX + topInset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topInset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct LoginHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeaderView()
            .frame(height: 260)
    }
}
