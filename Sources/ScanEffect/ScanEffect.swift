//
//  ScanEffect.swift
//  ScanEffect
//
//  Created by Maciek Czarnik on 21/02/2024.
//

import SwiftUI

extension View {
  /// Applies a scan effect.
  ///
  /// Have you ever played with scanner while its scanning? You can achieve funny effects by moving scanned content when the scan is in progress . `scanEffect` creates a container (*sensor area view*) that hosts a *content* (modified view). It allows to *displace* or move content while the scan is in progress using ``ScanEffectContentDisplacementCalculator``.
  ///
  /// It also applies a chromatic aberration effect based on the amount of displacement that you can control with `rRelativeDisplacement`, `gRelativeDisplacement` and `bRelativeDisplacement`.
  ///
  /// - Parameters:
  ///   - displacedContentPositionCalculator: a closure that gets calld to calculate content displacement for particular vertical sensor position. Check ``ScanEffectContentDisplacementCalculator`` for more details.
  ///   - rRelativeDisplacement: adjusts the relative red channel displacement. To disable chromatic aberration effect provide `0`.
  ///   - gRelativeDisplacement: same but for green channel.
  ///   - bRelativeDisplacement: same but for blue channel.
  ///   - isEnabled: enables or disables effect.
  /// - Returns: a view with applied effect.
  public func scanEffect(
    _ displacedContentPositionCalculator: ScanEffectContentDisplacementCalculator,
    rRelativeDisplacement: SIMD2<Float> = SIMD2<Float>(repeating: 1),
    gRelativeDisplacement: SIMD2<Float> = SIMD2<Float>(repeating: 1.2),
    bRelativeDisplacement: SIMD2<Float> = SIMD2<Float>(repeating: 1.8),
    isEnabled: Bool = true
  ) -> some View {
    modifier(
      ScanEffect(
        displacedContentPosition: displacedContentPositionCalculator,
        rRelativeDisplacement: rRelativeDisplacement,
        gRelativeDisplacement: gRelativeDisplacement,
        bRelativeDisplacement: bRelativeDisplacement,
        isEnabled: isEnabled
      )
    )
  }
}

private struct ScanEffect: ViewModifier {
  private enum ContentFramePreferenceKey: PreferenceKey {
    typealias Value = CGRect?
    
    static func reduce(
      value: inout Value,
      nextValue: () -> Value
    ) {
      value = nextValue()
    }
  }
  
  let displacedContentPosition: ScanEffectContentDisplacementCalculator
  let rRelativeDisplacement: SIMD2<Float>
  let gRelativeDisplacement: SIMD2<Float>
  let bRelativeDisplacement: SIMD2<Float>
  
  let isEnabled: Bool
  
  @State private var contentFrame: CGRect?
  @State private var sensorAreaSize: CGSize?
  @State private var sensorVerticalPositions: [Float]?
  
  func body(content: Content) -> some View {
    if isEnabled {
      GeometryReader { containerGeometry in
        Rectangle()
          .fill(.background.opacity(0.001))
          .overlay {
            content
              .anchorPreference(
                key: ContentFramePreferenceKey.self,
                value: .bounds,
                transform: { containerGeometry[$0] }
              )
          }
          .onAppear {
            sensorAreaSize = containerGeometry.size
          }
          .onChange(of: containerGeometry.size) {
            sensorAreaSize = containerGeometry.size
          }
          .onChange(of: sensorAreaSize) {
            sensorVerticalPositions = sensorAreaSize
              .map { Array(stride(from: 0, to: Float($0.height), by: 1)) }
          }
      }
      .frame(minWidth: contentFrame?.width, minHeight: contentFrame?.height)
      .compositingGroup()
      .layerEffect(
        .init(
          function: .init(library: .bundle(.module), name: "scanEffect"),
          arguments: makeShaderArguments()
        ),
        maxSampleOffset: .zero
      )
      .onPreferenceChange(ContentFramePreferenceKey.self) {
        contentFrame = $0
      }
    } else {
      content
    }
  }
  
  private func makeShaderArguments() -> [Shader.Argument] {
    [.boundingRect] + {
      guard let sensorVerticalPositions, let sensorAreaSize, let contentFrame else {
        return []
      }
      
      return [
        .float4(contentFrame),
        .floatArray(
          sensorVerticalPositions.flatMap { sensorVerticalPosition in
            let displacement = displacedContentPosition.calculate(
              sensorVerticalPosition,
              .init(contentFrame),
              .init(sensorAreaSize)
            )
            
            return [
              displacement.x,
              displacement.y
            ]
          }
        ),
        .float2(rRelativeDisplacement),
        .float2(gRelativeDisplacement),
        .float2(bRelativeDisplacement),
      ]
    }()
  }
}
