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
                        Circle()
                            .foregroundColor(.black)
                            .frame(width: holeHeight, height: holeHeight)
                            .position(tableBall.holePosition)
                            .offset(x: holeOffset, y: holeOffset)
                        
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: ballHeight, height: ballHeight)
                            .position(ballPosition)
                            .offset(x: ballOffset, y: ballOffset)
                    }
                    .gesture(dragGesrure())
                    
                    if !tableBall.hasStart {
                        ZStack{
                            Color.yellow
                            Text("Press Start")
                        }
                    }
                }
                .border(Color.black)
                .onAppear{
                    tableBall.setBoundSize(getBoundSize(originSize: geometry.size))
                }
            })
            HStack{
                Button("start") {
                    tableBall.resetGame()
                    tableBall.startAccelerometers()
                    tableBall.hasStart = true
                }
                .padding(.horizontal)
                Button("reset"){
                    tableBall.resetGame()
                    tableBall.hasStart = false
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getBoundSize(originSize size: CGSize) -> CGSize {
        CGSize(width: size.width - ballHeight, height: size.height - ballHeight)
    }
    
    
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
                tableBall.isDraging = true
                gestureDragPosition = value.location
                tableBall.steadyBallPosition = gestureDragPosition
            }
            .onEnded { value in
                if tableBall.hasStart {
                    tableBall.steadyBallPosition = value.location
                    tableBall.startAccelerometers()
                    tableBall.speed = .zero
                }
                tableBall.isDraging = false
            }
    }
    
    // MARK: - Drawing Constant
    
    private let ballHeight: CGFloat = 30
    private var ballOffset: CGFloat { ballHeight / 2 }
    private let holeHeight: CGFloat = 40
    private var holeOffset: CGFloat { holeHeight / 2 }
}

