//
//  TableBallViewModel.swift
//  Table Ball
//
//  Created by 刘坤昊 on 2021/2/13.
//

import SwiftUI
import CoreMotion
import AudioToolbox

class TableBallViewModel: ObservableObject {
    @Published var tableBall = TableBall(position: Vector2f(x: 0, y: 0), speed: Vector2f(x: 0, y: 0),hole: Vector2f(x: 100, y: 312))
    @Published var hasStart = false
    var isDraging = false
    
    private var boundSize: Vector2f?
    
    // MARK: - Intend(s)
    
    func setBoundSize (_ size: CGSize) {
        self.boundSize = Vector2f(x: Double(size.width), y:  Double(size.height))
    }
    
    // Accelerometer's data
    private let frequency = 1.0 / 60.0 
    private var timer: Timer?

    private let motion = CMMotionManager()
    private let motionFactor: Double = 0.2

    func startAccelerometers() {
        timer?.invalidate()
       // Make sure the accelerometer hardware is available.
       if self.motion.isAccelerometerAvailable {
          self.motion.accelerometerUpdateInterval = frequency
          self.motion.startAccelerometerUpdates()

          // Configure a timer to fetch the data.
          self.timer = Timer(fire: Date(), interval: frequency,
                             repeats: true, block: { timer in
             // Get the accelerometer data.
             if let data = self.motion.accelerometerData {
                let x = data.acceleration.x * self.motionFactor
                let y = -(data.acceleration.y * self.motionFactor)
//                let z = data.acceleration.z
                // Updates ball's Position and Speed
                if !self.isDraging {
                    self.tableBall.speed = self.tableBall.speed + Vector2f(x: x, y: y)
                    self.tableBall.position = self.tableBall.position + self.tableBall.speed
                    self.checkIfOutOfBound()
                }
                
                self.CheckDistence()
             }
          })
          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer!, forMode: .default)
       } else {
            print("Don't Support Accelerometer!")
       }
    }
    
    
    func resetGame() {
        if motion.isAccelerometerActive {
            motion.stopAccelerometerUpdates()
        }
        timer?.invalidate()
        tableBall.position = .zero
        tableBall.speed = .zero
        stopRadarSound()
    }
    
    func checkIfOutOfBound() {
        let miniOffset:Double = 0.3
        let speedCutDownFactor:Double = 0.5
        
        if let size = boundSize {
            if tableBall.position.x < 0 {
                tableBall.position.x = 0
                tableBall.speed.x *= -speedCutDownFactor
                if abs(tableBall.speed.x) >= miniOffset {
                    vibrates()
                }
            }
            if tableBall.position.x > size.x {
                tableBall.position.x = size.x
                tableBall.speed.x *= -speedCutDownFactor
                if abs(tableBall.speed.x) >= miniOffset {
                    vibrates()
                }
            }
            if tableBall.position.y < 0 {
                tableBall.position.y = 0
                tableBall.speed.y *= -speedCutDownFactor
                if abs(tableBall.speed.y) >= miniOffset {
                    vibrates()
                }
            }
            if tableBall.position.y > size.y {
                tableBall.position.y = size.y
                tableBall.speed.y *= -speedCutDownFactor
                if abs(tableBall.speed.y) >= miniOffset {
                    vibrates()
                }
            }
            
        }
    }
    
    enum BallState: Double {
        case veayNear = 0.05
        case near = 0.1
        case close = 0.2
        case middle = 0.5
        case far = 1.0
        case canNotSeen = 0
    }
    
    private var ballState: BallState?
    
    private func CheckDistence () {
        let distence = Vector2f.DistenceBewteen(tableBall.position, tableBall.hole)
        
        
        if distence < 20 {
            hasStart = false
            resetGame()
            AudioServicesPlaySystemSound(SystemSoundID(1303))
        }
        else if distence < 50 {
            radarSoundJugde(currentState: .veayNear)
        }
        else if distence < 100 {
            radarSoundJugde(currentState: .near)
        }
        else if distence < 200 {
            radarSoundJugde(currentState: .close)
        }
        else if distence < 300 {
            radarSoundJugde(currentState: .middle)
        }
        else if distence < 400{
            radarSoundJugde(currentState: .far)
        }
        else {
            stopRadarSound()
            ballState = .canNotSeen
        }
    }
    
    func radarSoundJugde (currentState: BallState) {
        if let state = ballState {
            if state != currentState {
                playRadarSound(frequency: currentState.rawValue)
                ballState = currentState
            }
        } else {
            playRadarSound(frequency: currentState.rawValue)
            ballState = currentState
        }
    }
    
    private var soundTimer: Timer?
    func playRadarSound (frequency: Double) {
        stopRadarSound()
        soundTimer = Timer(fire: Date(), interval: frequency, repeats: true) { timer in
            AudioServicesPlaySystemSound(SystemSoundID(1103))
        }
        RunLoop.current.add(soundTimer!, forMode: .default)
    }
    
    func stopRadarSound () {
        if let timer = soundTimer {
            timer.invalidate()
        }
    }
    
    func vibrates () {
        let vibrates = SystemSoundID(1519)
        let hitSound = SystemSoundID(1113)
        AudioServicesPlaySystemSound(vibrates)
        AudioServicesPlaySystemSound(hitSound)
    }
    
   
    
    // MARK: - Access to the model
    
    var steadyBallPosition: CGPoint {
        get{
            CGPoint(x: CGFloat(tableBall.position.x), y: CGFloat(tableBall.position.y))
        }
        set{
            tableBall.position.x = Double(newValue.x)
            tableBall.position.y = Double(newValue.y)
        }
    }
    
    var holePosition: CGPoint {
        CGPoint(x: CGFloat(tableBall.hole.x) , y: CGFloat(tableBall.hole.y))
    }
    
    var speed: Vector2f {
        get {
            tableBall.speed
        }
        set {
            tableBall.speed = newValue
        }
    }
}


