//
//  Shader.Argument+.swift
//  ScanEffectExample
//
//  Created by Maciek Czarnik on 22/02/2024.
//

import SwiftUI
import simd

extension Shader.Argument {
  static func float2(_ float2: SIMD2<Float>) -> Self {
    .float2(float2.x, float2.y)
  }
  
  static func float4(_ rect: CGRect) -> Self {
    .float4(
      rect.origin.x,
      rect.origin.y,
      rect.size.width,
      rect.size.height
    )
  }
}
