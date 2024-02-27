//
//  ScanEffectContentDisplacementCalculator+Functions.swift
//  ScanEffectExample
//
//  Created by Maciek Czarnik on 24/02/2024.
//

import Foundation

public extension ScanEffectContentDisplacementCalculator {
  /// Applies no change to the scanned content. Useful in previewing original content and sensor area.
  static var zero: Self {
    .init { _, _, _ in
      SIMD2<Float>.zero
    }
  }
  
  /// Applies a constant move for an entire scan frame.
  static func move(_ offset: SIMD2<Float>) -> Self {
    .init { _, _, _ in
      offset
    }
  }
  
  /// Applies a constant move relative to sensor area metrics.
  static func relativeMove(_ relativeOffset: SIMD2<Float>) -> Self {
    .init { _, _, sensorAreaSize in
      relativeOffset * sensorAreaSize
    }
  }
  
  /// Scales content by a factor.
  static func verticalScale(
    _ factor: Float,
    relativeAnchor: Float = .zero
  ) -> Self {
    .init { sensorVerticalPosition, _, scanAreaSize in
        .init(
          x: 0,
          y: (sensorVerticalPosition - relativeAnchor * scanAreaSize.y) * (1 - 1 / factor)
        )
    }
  }
  
  /// Scales content to fill the sensor area.
  static var verticalScaleToFill: Self {
    .init { _, contentFrame, sensorAreaSize in
        .verticalScale(
          sensorAreaSize.height / contentFrame.height,
          relativeAnchor: contentFrame.midY / sensorAreaSize.height
        )
    }
  }
  
  /// Simulates content displacement that goes hand in hand with the vertical position of the scan sensor.
  static func verticalizedLineOfContent(
    atRelativeContentOffset relativeContentOffset: Float = 0.5
  ) -> Self {
    .init { sensorVerticalPosition, contentFrame, _ in
        .init(
          x: 0,
          y: sensorVerticalPosition - (contentFrame.y + contentFrame.height * relativeContentOffset)
        )
    }
  }
  
  /// Simulates content "descending" from the top
  static func compounding(relativeProgress: Float = 0.5) -> Self {
    .init { sensorVerticalPosition, contentFrame, sensorAreaSize in
      switch relativeProgress.clamped(to: 0 ... 1) {
      case 0 ... 1 - sensorVerticalPosition.clamped(to: 0 ... sensorAreaSize.height) / sensorAreaSize.height:
          .verticalizedLineOfContent(atRelativeContentOffset: 1 - relativeProgress)
      default:
          .verticalScaleToFill
      }
    }
  }
  
  /// Applies a wave horizontal wave effect
  static func horizontalSin(
    _ amplitude: Float,
    period: Float = 2 * .pi,
    phase: Float = 0
  ) -> Self {
    .init { verticalSensorPosition, _, _ in
        .move(
          .init(
            x: amplitude * Darwin.sin(verticalSensorPosition / period + phase),
            y: 0
          )
        )
    }
  }
  
  /// Example of  the `AdditiveBuilder`
  @ScanEffectContentDisplacementCalculator.AdditiveBuilder
  static func additiveExample(relativeProgress: Float) -> Self {
    .compounding(relativeProgress: relativeProgress);
    .horizontalSin(10, period: 40 + relativeProgress * 100)
  }
}

extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}
