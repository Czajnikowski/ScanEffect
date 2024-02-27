//
//  ScanEffect.metal
//  ScanEffectExample
//
//  Created by Maciek Czarnik on 21/02/2024.
//

#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

float2 center(float4 rect) {
  return rect.xy + rect.zw / 2;
}

[[ stitchable ]] half4 scanEffect(
  float2 sensorPosition,
  SwiftUI::Layer containerLayer,
  float4 sensorAreaRect,
  float4 contentRect,
  device const float *contentDisplacementValues,
  int contentDisplacementValuesCount,
  float2 rRelativeDisplacement,
  float2 gRelativeDisplacement,
  float2 bRelativeDisplacement
) {
  float2 relativeSensorPosition = sensorPosition / sensorAreaRect.zw;
  
  int xDisplacementIndex = floor(relativeSensorPosition.y * contentDisplacementValuesCount / 2.0) * 2.0;
  int yDisplacementIndex = xDisplacementIndex + 1;
  float2 displacedSensorPosition = sensorPosition
  - float2(
    contentDisplacementValues[xDisplacementIndex],
    contentDisplacementValues[yDisplacementIndex]
  );
  
  
  float2 chromaticAberration = (sensorPosition - center(contentRect) - displacedSensorPosition) / contentRect.zw;
  half4 sampleR = containerLayer.sample(displacedSensorPosition + chromaticAberration * rRelativeDisplacement);
  half4 sampleG = containerLayer.sample(displacedSensorPosition + chromaticAberration * gRelativeDisplacement);
  half4 sampleB = containerLayer.sample(displacedSensorPosition + chromaticAberration * bRelativeDisplacement);
  
  half4 sample = half4(
    sampleR.r,
    sampleG.g,
    sampleB.b,
    (sampleR.a + sampleG.a + sampleB.a) / 3
  );

  if (sample.a < 0.01) {
    discard_fragment();
  }
  
  return half4(sample.rgb, sample.a);
}
