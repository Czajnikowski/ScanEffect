//
//  ScanEffectContentDisplacementCalculator.swift
//  ScanEffectExample
//
//  Created by Maciek Czarnik on 26/02/2024.
//

import simd
import SwiftUI

/// Describes the displacement of scanned content.
///
/// The calculator wraps a closure that gets called by `scanEffect` to calculate content displacement for a scan sensor at particular vertical position. Be aware that the closure gets executed `sensorAreaSize.height` times per frame, so **avoid time intensive operations and side effects** (`print` included) in the body.
///
/// To get an intuition and explore some possibilities please reffer to sample instances defined in `ScanEffectContentDisplacementCalculator+Functions.swift`
///
public struct ScanEffectContentDisplacementCalculator {
  public typealias Calculate = (
    _ sensorVerticalPosition: Float,
    _ contentFrame: SIMD4<Float>,
    _ sensorAreaSize: SIMD2<Float>
  ) -> SIMD2<Float>
  
  let calculate: Calculate
  
  /// Initializes an instance by providing the ``Calculate`` closure.
  ///
  /// - Parameter calculate: a closure that returns displacement for scan sensor at particular vertical position.
  public init(calculate: @escaping Calculate) {
    self.calculate = calculate
  }
}

extension ScanEffectContentDisplacementCalculator {
  /// Initializes an instance by wrapping another calculator.
  public init(
    _ buildCalculator: @escaping (
      _ sensorVerticalPosition: Float,
      _ contentFrame: SIMD4<Float>,
      _ sensorAreaSize: SIMD2<Float>
    ) -> ScanEffectContentDisplacementCalculator
  ) {
    self.init { sensorVerticalPosition, contentFrame, sensorAreaSize in
      buildCalculator(sensorVerticalPosition, contentFrame, sensorAreaSize)
        .calculate(sensorVerticalPosition, contentFrame, sensorAreaSize)
    }
  }
}
