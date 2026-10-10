import SwiftUI
import CoreImage.CIFilterBuiltins

/// Responsive welcome: actions stay visible while the artwork uses the remaining space.
struct WelcomeScreen: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1
    @State private var appeared = false

    var body: some View {
        GeometryReader { geometry in
            let widthScale = min(max(min(geometry.size.width, 480) / 390, 0.78), 1.18)
            let scale = min(max(min(widthScale, geometry.size.height / 800), 0.6), 1.18)
            let inset = 22 * widthScale
            ZStack {
                LinearGradient(colors: [Color(hex: 0x05223F), Color(hex: 0x082641)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                RadialGradient(colors: [Color(hex: 0x3677AC).opacity(0.28), .clear],
                               center: UnitPoint(x: 0.76, y: 0.47), startRadius: 0,
                               endRadius: geometry.size.height * 0.65)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ViewThatFits(in: .vertical) {
                        VStack(spacing: 0) {
                            introduction(scale: scale, inset: inset)
                                .fixedSize(horizontal: false, vertical: true)
                            WelcomeDocumentArtwork(reduceMotion: reduceMotion)
                                .frame(minHeight: 72 * scale, idealHeight: 72 * scale, maxHeight: .infinity)
                                .welcomeEntrance(appeared: appeared, reduceMotion: reduceMotion, start: 0.12)
                                .accessibilityHidden(true)
                        }
                        // Larger accessibility text can scroll independently of the actions.
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                introduction(scale: scale, inset: inset)
                                WelcomeDocumentArtwork(reduceMotion: reduceMotion)
                                    .frame(height: 72 * scale)
                                    .welcomeEntrance(appeared: appeared, reduceMotion: reduceMotion, start: 0.12)
                                    .accessibilityHidden(true)
                            }
                        }
                        .scrollBounceBehavior(.basedOnSize)
                    }
                    .frame(maxHeight: .infinity)
                    actions(scale: scale, inset: inset)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                }
                .frame(maxWidth: 480)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .preferredColorScheme(.dark)
        .onAppear { appeared = true }
    }

    private func introduction(scale: CGFloat, inset: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 14 * scale)
            VStack(alignment: .leading, spacing: 2) {
                WelcomeBrandIcon(size: max(38, 54 * scale))
                Text("Your tax. Our pulse.")
                    .font(.system(size: max(12, 14 * scale) * textScale, weight: .medium))
                    .foregroundStyle(Color(hex: 0xB5CDE2))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("welcome_brand_slogan")
            }
            .padding(.horizontal, inset)
            .opacity(appeared || reduceMotion ? 1 : 0)
            .animation(reduceMotion ? nil : TaxPulseMotion.curve(duration: 0.9), value: appeared)
            Spacer().frame(height: 12 * scale)
            (Text("Welcome to\n") + Text("Tax Pulse").foregroundColor(Color(hex: 0x7DB7DB)))
                .font(.system(size: max(28, 46 * scale) * textScale, weight: .bold))
                .kerning(-1.5 * scale)
                .foregroundStyle(Color(hex: 0xF3F6FA))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, inset)
                .accessibilityIdentifier("welcome_headline")
                .welcomeEntrance(appeared: appeared, reduceMotion: reduceMotion, start: 0.12)
            Spacer().frame(height: 10 * scale)
            Text("A clearer view of your taxes.")
                .font(.system(size: max(16, 23 * scale) * textScale, weight: .semibold))
                .kerning(-0.4 * scale)
                .foregroundStyle(Color(hex: 0xF3F6FA))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, inset)
                .accessibilityIdentifier("welcome_tagline")
                .welcomeEntrance(appeared: appeared, reduceMotion: reduceMotion, start: 0.16)
            Spacer().frame(height: 14 * scale)
            Text("Lebanese payroll and profit tax,\nproperty tax, penalties and deadlines.")
                .font(.system(size: max(14, 18 * scale) * textScale))
                .kerning(-0.25 * scale)
                .lineSpacing(3 * scale)
                .foregroundStyle(Color(hex: 0xB5CDE2))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, inset)
                .accessibilityIdentifier("welcome_description")
                .welcomeEntrance(appeared: appeared, reduceMotion: reduceMotion, start: 0.2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func actions(scale: CGFloat, inset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Button { state.onboardingStep = 2 } label: {
                ZStack {
                    Capsule().fill(LinearGradient(colors: [Color(hex: 0x3883B3), Color(hex: 0x2E73A1)],
                                                 startPoint: .leading, endPoint: .trailing))
                    Text("Get started")
                        .font(.system(size: max(16, 18 * scale) * textScale, weight: .semibold))
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 22 * scale, weight: .regular))
                            .padding(.trailing, 20 * scale)
                    }
                }
                .foregroundStyle(Color(hex: 0xF3F6FA))
                .frame(height: max(48, max(54 * scale, max(16, 18 * scale) * textScale * 1.3 + 16)))
                .contentShape(Capsule())
            }
            .buttonStyle(WelcomePressStyle(reduceMotion: reduceMotion))
            .padding(.horizontal, inset)
            .accessibilityIdentifier("welcome_start")
            .welcomeEntrance(appeared: appeared, reduceMotion: reduceMotion, start: 0.3, minimumOpacity: 0.7)

            Text("Smarter Tax Simplified For You")
                .font(.system(size: max(12, 14 * scale) * textScale))
                .foregroundStyle(Color(hex: 0x7DB7DB))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 48)
                .padding(.horizontal, inset)
                .accessibilityIdentifier("welcome_secondary_slogan")
            .welcomeEntrance(appeared: appeared, reduceMotion: reduceMotion, start: 0.32, minimumOpacity: 0.7)

            Spacer().frame(height: 16 * scale)
            VStack(spacing: 3 * scale) {
                Text("Haddad Audit Firm")
                    .font(.system(size: max(11, 13 * scale) * textScale))
                    .foregroundStyle(Color(hex: 0xB5CDE2))
                Text("Built with care in Lebanon")
                    .font(.system(size: max(10, 11 * scale) * textScale))
                    .foregroundStyle(Color(hex: 0x7DB7DB))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, inset)
            .welcomeEntrance(appeared: appeared, reduceMotion: reduceMotion, start: 0.2)
            Spacer().frame(height: 16 * scale)
        }
    }
}

private struct WelcomeBrandIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            let blue = Color(hex: 0x38BDF8)
            RadialGradient(stops: [
                .init(color: blue.opacity(0.30), location: 0),
                .init(color: blue.opacity(0.14), location: 0.5),
                .init(color: .clear, location: 1)
            ], center: .center, startRadius: 0, endRadius: size * 0.7)
            RoundedRectangle(cornerRadius: size * 0.23)
                .stroke(blue.opacity(0.40), lineWidth: 1)
                .frame(width: size, height: size)
            Canvas { context, bounds in
                let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
                let lights = [
                    CGPoint(x: center.x - size / 2, y: center.y + size * 0.12),
                    CGPoint(x: center.x + size * 0.20, y: center.y - size / 2),
                    CGPoint(x: center.x + size / 2, y: center.y - size * 0.18)
                ]
                for light in lights {
                    for axis in [CGSize(width: size * 0.18, height: 0), CGSize(width: 0, height: size * 0.18)] {
                        let start = CGPoint(x: light.x - axis.width, y: light.y - axis.height)
                        let end = CGPoint(x: light.x + axis.width, y: light.y + axis.height)
                        var ray = Path()
                        ray.move(to: start)
                        ray.addLine(to: end)
                        context.stroke(ray, with: .linearGradient(
                            Gradient(colors: [.clear, blue.opacity(0.65), .clear]),
                            startPoint: start, endPoint: end), lineWidth: 1)
                    }
                }
            }
            .accessibilityHidden(true)
            artwork
                .resizable().scaledToFit()
                .frame(width: size, height: size)
                .accessibilityLabel("Tax Pulse app icon")
                .accessibilityIdentifier("welcome_brand")
        }
        .frame(width: size * 1.4, height: size * 1.4)
    }

    private var artwork: Image {
        if let image = WelcomeLogoArtwork.transparentImage { return Image(uiImage: image) }
        return Image("WelcomeBrand")
    }
}

private enum WelcomeLogoArtwork {
    // Render once and retain the original RGB artwork; only the background alpha changes.
    static let transparentImage: UIImage? = {
        guard let original = UIImage(named: "WelcomeBrand"), let input = CIImage(image: original),
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        let filter = CIFilter.colorMatrix()
        filter.inputImage = input
        filter.aVector = CIVector(x: -11, y: 11, z: 11, w: 0)
        filter.biasVector = CIVector(x: 0, y: 0, z: 0, w: -2530.0 / 255.0)
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        guard let output = filter.outputImage,
              let rendered = context.createCGImage(output, from: input.extent, format: .RGBA8, colorSpace: colorSpace)
        else { return nil }
        return UIImage(cgImage: rendered, scale: original.scale, orientation: original.imageOrientation)
    }()
}

private extension View {
    func welcomeEntrance(appeared: Bool, reduceMotion: Bool, start: Double, minimumOpacity: Double = 0) -> some View {
        modifier(WelcomeEntranceModifier(progress: appeared || reduceMotion ? 1 : 0,
                                         start: start, minimumOpacity: minimumOpacity))
            .animation(reduceMotion ? nil : TaxPulseMotion.curve(duration: 0.9), value: appeared)
    }
}

/// Interpolate the same shared progress and phase thresholds as Android.
private struct WelcomeEntranceModifier: ViewModifier, Animatable {
    var progress: Double
    let start: Double
    let minimumOpacity: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let fraction = min(max((progress - start) / (1 - start), 0), 1)
        return content
            .opacity(minimumOpacity + (1 - minimumOpacity) * fraction)
            .offset(y: CGFloat((1 - fraction) * 12))
    }
}

enum TaxPulseMotion {
    static func curve(duration: Double) -> Animation {
        .timingCurve(0.4, 0, 0.2, 1, duration: duration)
    }

    /// Compose FastOutSlowInEasing: cubic-bezier(0.4, 0, 0.2, 1).
    static func easedProgress(_ progress: Double) -> Double {
        let x = min(max(progress, 0), 1)
        if x == 0 || x == 1 { return x }
        var low = 0.0
        var high = 1.0
        for _ in 0..<20 {
            let t = (low + high) / 2
            let u = 1 - t
            let sampleX = 3 * u * u * t * 0.4 + 3 * u * t * t * 0.2 + t * t * t
            if sampleX < x { low = t } else { high = t }
        }
        let t = (low + high) / 2
        return 3 * (1 - t) * t * t + t * t * t
    }
}

private struct WelcomePressStyle: ButtonStyle {
    let reduceMotion: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.975 : 1)
            .animation(reduceMotion ? nil : TaxPulseMotion.curve(duration: 0.12), value: configuration.isPressed)
    }
}

private struct WelcomeDocumentArtwork: View {
    let reduceMotion: Bool
    @State private var started = Date()
    @State private var active = false

    var body: some View {
        ZStack {
            Image("WelcomeDocument")
                .resizable().scaledToFit()
                .padding(.horizontal, 28).padding(.vertical, 8)
            TimelineView(.animation(paused: reduceMotion || !active)) { timeline in
                let elapsed = max(timeline.date.timeIntervalSince(started), 0)
                let reveal = reduceMotion ? 1 : TaxPulseMotion.easedProgress(elapsed / 1.2)
                let light = reduceMotion ? 0.8 : elapsed.truncatingRemainder(dividingBy: 3.2) / 2.7
                Canvas { context, size in
                    let points = welcomePulsePoints(size: size)
                    let count = max(1, Int(Double(points.count - 1) * reveal) + 1)
                    var visible = Path()
                    visible.addLines(Array(points.prefix(count)))
                    context.stroke(visible, with: .color(Color(hex: 0x74B5E0).opacity(0.9)),
                                   style: StrokeStyle(lineWidth: 2.1, lineCap: .round, lineJoin: .round))
                    if reveal >= 0.99 {
                        let distance = min(light, 1) * Double(points.count - 1)
                        let index = min(Int(distance), points.count - 2)
                        let fraction = CGFloat(distance - Double(index))
                        let point = CGPoint(x: points[index].x + (points[index + 1].x - points[index].x) * fraction,
                                            y: points[index].y + (points[index + 1].y - points[index].y) * fraction)
                        let length = zip(points, points.dropFirst()).reduce(CGFloat.zero) { total, pair in
                            total + hypot(pair.1.x - pair.0.x, pair.1.y - pair.0.y)
                        }
                        let tailIndex = max(0, index - Int(CGFloat(points.count - 1) * 70 / max(length, 1)))
                        var trail = Path()
                        trail.addLines(Array(points[tailIndex...index]) + [point])
                        context.stroke(trail, with: .linearGradient(
                            Gradient(colors: [.clear, Color(hex: 0x63C5F5), Color(hex: 0xCBEDFF)]),
                            startPoint: points[tailIndex], endPoint: point),
                            style: StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round))
                        context.fill(Path(ellipseIn: CGRect(x: point.x - 11, y: point.y - 11, width: 22, height: 22)),
                                     with: .radialGradient(
                                        Gradient(colors: [Color(hex: 0x7CC9F2).opacity(0.32), .clear]),
                                        center: point, startRadius: 0, endRadius: 11))
                        context.fill(Path(ellipseIn: CGRect(x: point.x - 4.5, y: point.y - 4.5, width: 9, height: 9)),
                                     with: .color(Color(hex: 0xB9E6FF)))
                        context.fill(Path(ellipseIn: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)),
                                     with: .color(Color(hex: 0xF3F6FA)))
                    }
                }
            }
        }
        .onAppear { started = Date(); active = true }
        .onDisappear { active = false }
    }
}

/// Sample the same smooth pulse curves used by Android; no baked animation in the image.
private func welcomePulsePoints(size: CGSize) -> [CGPoint] {
    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * size.width, y: y * size.height) }
    var points = [p(0, 0.35), p(0.21, 0.35)]
    func curve(_ c1: CGPoint, _ c2: CGPoint, _ end: CGPoint) {
        let start = points.last!
        for step in 1...64 {
            let t = CGFloat(step) / 64
            let u = 1 - t
            points.append(CGPoint(x: u*u*u*start.x + 3*u*u*t*c1.x + 3*u*t*t*c2.x + t*t*t*end.x,
                                  y: u*u*u*start.y + 3*u*u*t*c1.y + 3*u*t*t*c2.y + t*t*t*end.y))
        }
    }
    curve(p(0.25, 0.35), p(0.275, 0.21), p(0.30, 0.235))
    curve(p(0.325, 0.25), p(0.345, 0.48), p(0.37, 0.46))
    curve(p(0.395, 0.46), p(0.40, 0.39), p(0.44, 0.405))
    curve(p(0.56, 0.43), p(0.70, 0.52), p(0.81, 0.51))
    curve(p(0.88, 0.51), p(0.94, 0.48), p(1, 0.46))
    // Even distances keep the light's speed steady through the curves and straight section.
    var distances: [CGFloat] = [0]
    for index in 1..<points.count {
        distances.append(distances.last! + hypot(points[index].x - points[index-1].x, points[index].y - points[index-1].y))
    }
    let total = distances.last!
    var segment = 1
    return (0...400).map { index in
        let distance = total * CGFloat(index) / 400
        while segment < points.count - 1 && distances[segment] < distance { segment += 1 }
        let fraction = (distance - distances[segment-1]) / max(distances[segment] - distances[segment-1], 0.001)
        return CGPoint(x: points[segment-1].x + (points[segment].x - points[segment-1].x) * fraction,
                       y: points[segment-1].y + (points[segment].y - points[segment-1].y) * fraction)
    }
}
