//
//  TableBallView.swift
//  Table Ball
//
//  Created by 刘坤昊 on 2021/2/13.
//

import SwiftUI

struct TableBallView: View {
  
    @ObservedObject var tableBall = TableBallViewModel()
    
    
     var body: some View {
        VStack{
            GeometryReader(content: { geometry in
                ZStack {
                    ZStack{
                        Color.white
                        Circle() // hole
                            .foregroundColor(.black)
                            .frame(width: holeSize, height: holeSize)
                            .position(tableBall.holePosition)
                        
                        Circle() // ball
                            .foregroundColor(.green)
                            .frame(width: ballSize, height: ballSize)
                            .position(ballPosition)

                    }
                    .gesture(dragGesrure())
                    .clipped()
                    
                    if !hasStart {
                        ZStack{
                            Color.yellow
                            Text("Press Start")
                        }
                    }
                }
                .border(Color.black)
                .onAppear{
                    tableBall.setBoundSize(geometry.size)
                }
            })
            HStack{
                if hasStart {
                    Button("restart") {
                        tableBall.resetGame()
                        tableBall.hasStart = false
                    }
                    .padding(.horizontal)
                } else {
                    Button("start") {
                        tableBall.resetGame()
                        tableBall.startAccelerometers()
                        tableBall.hasStart = true
                    }
                    .padding(.horizontal)
                }
                
            }
        }
    }
    
    // MARK: - Drag Gesture
    
    @GestureState private var gestureDragPosition: CGPoint = .zero
    private var ballPosition: CGPoint {
        if gestureDragPosition == .zero {
            return tableBall.steadyBallPosition
        }
        return gestureDragPosition
    }
    
    private func dragGesrure() -> some Gesture {
        
        return DragGesture()
            .updating($gestureDragPosition) { (value, gestureDragPosition, transaction) in
                if hasStart {
                    tableBall.isDragging = true
                }
                gestureDragPosition = value.location
                tableBall.steadyBallPosition = gestureDragPosition
            }
            .onEnded { value in
                if hasStart {
                    tableBall.steadyBallPosition = value.location
                    tableBall.startAccelerometers()
                    tableBall.speed = .zero
                }
                tableBall.isDragging = false
            }
    }
    
    // MARK: - Drawing Constant
    
    private var hasStart: Bool {
        get { tableBall.hasStart }
    }
    private var isDragging:Bool {
        get { tableBall.isDragging }
    }
    
    private var ballSize: CGFloat { tableBall.ballSize }
    private var holeSize: CGFloat { tableBall.holeSize }
    private var ballOffset: CGFloat { ballSize / 2 }
    private var holeOffset: CGFloat { holeSize / 2 }
}

