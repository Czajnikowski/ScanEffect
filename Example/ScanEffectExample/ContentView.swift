//
//  ContentView.swift
//  ScanEffectExample
//
//  Created by Maciek Czarnik on 20/02/2024.
//

import SwiftUI
import ScanEffect

struct ContentView: View {
  @State private var startDate = Date.now
  
  var body: some View {
    TimelineView(.animation) { timelineContext in
      VStack {
        Text("I ❤️")
        Text("glitches")
        Image(systemName: "face.dashed")
      }
      .font(
        .system(
          size: 36,
          weight: .bold,
          design: .rounded
        )
      )
      .scanEffect(
//        .zero
//        .move
//        .relativeMove
//        .verticalScale
//        .verticalScaleToFill
//        .horizontalSin
//        .verticalizedLineOfContent
//        .compounding
//        .init(calculate: { sensorVerticalPosition, contentFrame, sensorAreaSize in
//          ...
//        })
        .additiveExample(
          relativeProgress: timeSinceStart(timelineContext) / 5
        )
      )
    }
    .ignoresSafeArea()
    .preferredColorScheme(.dark)
    .onTapGesture {
      startDate = .now
    }
  }
  
  private func timeSinceStart(_ timelineContext: TimelineViewDefaultContext) -> Float {
    Float(timelineContext.date.timeIntervalSince(startDate))
  }
}

#Preview {
  ContentView()
}
