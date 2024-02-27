//
//  SIMD+.swift
//  ScanEffectExample
//
//  Created by Maciek Czarnik on 26/02/2024.
//

import CoreGraphics

extension SIMD4<Float> {
  init(_ frame: CGRect) {
    self.init(
      x: Float(frame.minX),
      y: Float(frame.minY),
      z: Float(frame.size.width),
      w: Float(frame.size.height)
    )
  }
}

extension SIMD2<Float> {
  init(_ size: CGSize) {
    self.init(
      x: Float(size.width),
      y: Float(size.height)
    )
  }
}

extension SIMD4 {
  var width: Scalar { z }
  var height: Scalar { w }
}

extension SIMD4 where Scalar: FloatingPoint {
  var midY: Scalar { y + height / 2 }
}

extension SIMD2 {
  var width: Scalar { x }
  var height: Scalar { y }
}
