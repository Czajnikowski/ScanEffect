//
//  ScanEffectContentDisplacementCalculator+AdditiveBuilder.swift
//  ScanEffectExample
//
//  Created by Maciek Czarnik on 26/02/2024.
//

public extension ScanEffectContentDisplacementCalculator {
  /// An additive builder.
  ///
  /// This builder simply takes all the relevant calculators and sums the returned displacements.
  @resultBuilder
  struct AdditiveBuilder {
    public static func buildArray(
      _ components: [ScanEffectContentDisplacementCalculator]
    ) -> ScanEffectContentDisplacementCalculator {
      .init { verticalSensorPosition, contentFrame, sensorAreaSize in
        var totalDisplacement = SIMD2<Float>.zero
        for component in components {
          totalDisplacement += component.calculate(verticalSensorPosition, contentFrame, sensorAreaSize)
        }
        return totalDisplacement
      }
    }
    
    public static func buildBlock(
      _ components: ScanEffectContentDisplacementCalculator...
    ) -> ScanEffectContentDisplacementCalculator {
      buildArray(components)
    }
    
    public static func buildExpression(
      _ expression: ScanEffectContentDisplacementCalculator
    ) -> ScanEffectContentDisplacementCalculator {
      return expression
    }
    
    public static func buildPartialBlock(
      first: ScanEffectContentDisplacementCalculator
    ) -> ScanEffectContentDisplacementCalculator {
      first
    }
    
    public static func buildFinalResult(_ component: ScanEffectContentDisplacementCalculator) -> ScanEffectContentDisplacementCalculator {
      component
    }
    
    public static func buildPartialBlock(
      accumulated: ScanEffectContentDisplacementCalculator,
      next: ScanEffectContentDisplacementCalculator
    ) -> ScanEffectContentDisplacementCalculator {
      buildArray([accumulated, next])
    }
    
    public static func buildEither(
      first component: ScanEffectContentDisplacementCalculator
    ) -> ScanEffectContentDisplacementCalculator {
      component
    }
    
    public static func buildEither(
      second component: ScanEffectContentDisplacementCalculator
    ) -> ScanEffectContentDisplacementCalculator {
      component
    }
  }
}
