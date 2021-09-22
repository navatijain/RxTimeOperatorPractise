//
//  ViewController.swift
//  RxTimeOperators
//
//  Created by Navati Jain on 2021-08-24.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
         //view.addSubview(replay())
        //view.addSubview(replayAll())
         //view.addSubview(buffer1())
       //  view.addSubview(delayElements())
        view.addSubview(delaySubscription())
        
        // view.addSubview(replayFinal())
       // view.addSubview(replayWithIntervalTimer())
      //  view.addSubview(replayWithIntervalTimer())
     //   view.addSubview(replayWithRepeatingTimer())
    }
    
    func replay() -> UIView {
        //MARK: Constants
        let elementsPerSecond = 1
        let maxElements = 58
        let replayedElements = 3 //1
        let replayDelay: TimeInterval = 5 //3
        
        //MARK: UI rendering
        let sourceTimeline = TimelineView<Int>.make()
        let replayedTimeline = TimelineView<Int>.make()
        
        let stack = UIStackView.makeVertical([
                                                UILabel.makeTitle("replay"),
                                                UILabel.make("Emit \(elementsPerSecond) per second:"),
                                                sourceTimeline,
                                                UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
                                                replayedTimeline])
        let hostView = setupHostView()
        hostView.addSubview(stack)
        
        //MARK: Observables
        //emit elements
        let sourceObservable = Observable<Int>.create { observer in
            var value = 0
            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
                if value <= maxElements {
                    observer.onNext(value)
                    value += 1
                }
            }
            return Disposables.create {
                timer.suspend()
            }
        }.replay(replayedElements)
        
        //TimelineView class implements RxSwift‘s ObserverType protocol
        _ = sourceObservable.subscribe(sourceTimeline)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
            _ = sourceObservable.subscribe(replayedTimeline)
        }
        
        _ = sourceObservable.connect()
        
        return hostView
    }
    
    func replayAll() -> UIView {
        //MARK: Constants
        let elementsPerSecond = 1
        let maxElements = 58
        //let replayedElements = 1 //3
        let replayDelay: TimeInterval = 3 //5
        
        //MARK: UI rendering
        let sourceTimeline = TimelineView<Int>.make()
        let replayedTimeline = TimelineView<Int>.make()
        
        let stack = UIStackView.makeVertical([
                                                UILabel.makeTitle("replay"),
                                                UILabel.make("Emit \(elementsPerSecond) per second:"),
                                                sourceTimeline,
                                                UILabel.make("Replay all after \(replayDelay) sec:"),
                                                replayedTimeline])
        let hostView = setupHostView()
        hostView.addSubview(stack)
        
        //MARK: Observables
        //emit elements
        let sourceObservable = Observable<Int>.create { observer in
            var value = 1
            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
                if value <= maxElements {
                    observer.onNext(value)
                    value += 1
                }
            }
            return Disposables.create {
                timer.suspend()
            }
        }.replayAll()
        
        //TimelineView class implements RxSwift‘s ObserverType protocol
        _ = sourceObservable.subscribe(sourceTimeline)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
            _ = sourceObservable.subscribe(replayedTimeline)
        }
        
        _ = sourceObservable.connect()
        
        return hostView
    }
    
    func buffer1() -> UIView {
        //MARK: Constants
        let bufferTimeSpan: RxTimeInterval = .seconds(4)
        let bufferMaxCount = 2
        
        //MARK: UI rendering
        let sourceTimeline = TimelineView<String>.make()
        let bufferedTimeline = TimelineView<Int>.make()
        
        let stack = UIStackView.makeVertical([
                                                UILabel.makeTitle("buffer"),
                                                UILabel.make("Emitted elements:"),
                                                sourceTimeline,
                                                UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan) seconds):"),
                                                bufferedTimeline])
        
        let hostView = setupHostView()
        hostView.addSubview(stack)
        
        //MARK: Observables
        let sourceObservable = PublishSubject<String>()
        
        _ = sourceObservable.subscribe(sourceTimeline)
        
        _ = sourceObservable
            .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
            .map(\.count)
            .subscribe(bufferedTimeline)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            sourceObservable.onNext("🐱")
            sourceObservable.onNext("🐱")
            sourceObservable.onNext("🐱")
            sourceObservable.onNext("🐱")
            sourceObservable.onNext("🐱")
        }
    
        
        return hostView
    }
    
    
    

    
//    func window() -> UIView {
//        //MARK: Constants
//        let elementsPerSecond = 3
//        let windowTimeSpan: RxTimeInterval = .seconds(4)
//        let windowMaxCount = 10
//
//
//        //MARK: UI rendering
//        let sourceTimeline = TimelineView<String>.make()
//
//        let stack = UIStackView.makeVertical([
//          UILabel.makeTitle("window"),
//          UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
//          sourceTimeline,
//          UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec):")])
//
//        let hostView = setupHostView()
//        hostView.addSubview(stack)
//
//        //MARK: Observables
//
//        let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
//          sourceObservable.onNext("🐱")
//        }
//
//        _ = sourceObservable.subscribe(sourceTimeline)
//
//        _ = sourceObservable
//          .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
//          .flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in
//            let timeline = TimelineView<Int>.make()
//            stack.insert(timeline, at: 4)
//            stack.keep(atMost: 8)
//            return windowedObservable
//              .map { value in (timeline, value) }
//              .concat(Observable.just((timeline, nil)))
//          }
//          .subscribe(onNext: { tuple in
//            let (timeline, value) = tuple
//            if let value = value {
//              timeline.add(.next(value))
//            } else {
//              timeline.add(.completed(true))
//            }
//          })
//
//
//        return hostView
//    }
    
    func delayElements() -> UIView {
        let elementsPerSecond = 1
        let delay: RxTimeInterval = .milliseconds(1500)
        
        let sourceTimeline = TimelineView<Int>.make()
        let delayedTimeline = TimelineView<Int>.make()
        
        let stack = UIStackView.makeVertical([
                                                UILabel.makeTitle("delay"),
                                                UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
                                                sourceTimeline,
                                                UILabel.make("Delayed elements (with a \(delay)s delay):"),
                                                delayedTimeline])
        
        let sourceObservable = Observable<Int>.create { observer in
            var value = 1
            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
                    observer.onNext(value)
                    value += 1
                
            }
            return Disposables.create {
                timer.suspend()
            }
        }
        
        _ = sourceObservable.subscribe(sourceTimeline)
        
        // Setup the delayed subscription
        _ = Observable<Int>
            .timer(.seconds(3), scheduler: MainScheduler.instance)
            .flatMap { _ in
                sourceObservable.delay(delay, scheduler: MainScheduler.instance)
            }
            .subscribe(delayedTimeline)
        
        let hostView = setupHostView()
        hostView.addSubview(stack)
        return hostView
    }
    
//    func delaySubscription() -> UIView {
//        let elementsPerSecond = 1
//        let delay: RxTimeInterval = .milliseconds(6000)
//
//        let sourceTimeline = TimelineView<Int>.make()
//        let delayedTimeline = TimelineView<Int>.make()
//
//        let stack = UIStackView.makeVertical([
//                                                UILabel.makeTitle("delay"),
//                                                UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
//                                                sourceTimeline,
//                                                UILabel.make("Delayed elements (with a \(delay)s delay):"),
//                                                delayedTimeline])
//
//        let sourceObservable = Observable<Int>.create { observer in
//            var value = 1
//            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
//                    observer.onNext(value)
//                    value += 1
//
//            }
//            return Disposables.create {
//                timer.suspend()
//            }
//        }
//
//        _ = sourceObservable.subscribe(sourceTimeline)
//
//
//        //DELAY:
//        _ = sourceObservable
//          .delaySubscription(delay, scheduler: MainScheduler.instance)
//          .subscribe(delayedTimeline)
//
//        let hostView = setupHostView()
//        hostView.addSubview(stack)
//        return hostView
//    }
    
    //    func buffer2() -> UIView {
    //        //MARK: Constants
    //        let bufferTimeSpan: RxTimeInterval = .seconds(4)
    //        let bufferMaxCount = 2
    //
    //        //MARK: UI rendering
    //        let sourceTimeline = TimelineView<String>.make()
    //        let bufferedTimeline = TimelineView<Int>.make()
    //
    //        let stack = UIStackView.makeVertical([
    //                                                UILabel.makeTitle("buffer"),
    //                                                UILabel.make("Emitted elements:"),
    //                                                sourceTimeline,
    //                                                UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan) seconds):"),
    //                                                bufferedTimeline])
    //
    //        let hostView = setupHostView()
    //        hostView.addSubview(stack)
    //
    //        //MARK: Observables
    //        let sourceObservable = PublishSubject<String>()
    //
    //     _ = sourceObservable.subscribe(sourceTimeline)
    //
    //        _ = sourceObservable
    //            .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
    //            .map(\.count)
    //            .subscribe(bufferedTimeline)
    //
    ////        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    ////            sourceObservable.onNext("🐱")
    ////            sourceObservable.onNext("🐱")
    ////            sourceObservable.onNext("🐱")
    ////            sourceObservable.onNext("🐱")
    ////            sourceObservable.onNext("🐱")
    ////        }
    //
    //        let elementsPerSecond = 0.7
    //        _ = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
    //          sourceObservable.onNext("🐱")
    //        }
    //
    //        return hostView
    //    }
    
    func replayFinal() -> UIView {
        let elementsPerSecond = 1
        let maxElements = 58
        let replayedElements = 1
        let replayDelay: TimeInterval = 3
        
        let sourceObservable = Observable<Int>
            .interval(.milliseconds(Int(1000.0 / Double(elementsPerSecond))), scheduler: MainScheduler.instance)
            .replay(replayedElements)
        
        let sourceTimeline = TimelineView<Int>.make()
        let replayedTimeline = TimelineView<Int>.make()
        
        let stack = UIStackView.makeVertical([
                                                UILabel.makeTitle("replay"),
                                                UILabel.make("Emit \(elementsPerSecond) per second:"),
                                                sourceTimeline,
                                                UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
                                                replayedTimeline])
        
        _ = sourceObservable.subscribe(sourceTimeline)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
            _ = sourceObservable.subscribe(replayedTimeline)
        
        }
        
        _ = sourceObservable.connect()
        
        let hostView = setupHostView()
        hostView.addSubview(stack)
        
        return hostView
    }
    
    func replayWithIntervalTimer() -> UIView {
        //MARK: Constants
        let elementsPerSecond = 1
        let replayedElements =  2//3
        let replayDelay: TimeInterval = 5 //3
        
        //MARK: UI rendering
        let sourceTimeline = TimelineView<Int>.make()
        let replayedTimeline = TimelineView<Int>.make()
        
        let stack = UIStackView.makeVertical([
                                                UILabel.makeTitle("replay"),
                                                UILabel.make("Emit \(elementsPerSecond) per second:"),
                                                sourceTimeline,
                                                UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
                                                replayedTimeline])
        let hostView = setupHostView()
        hostView.addSubview(stack)
        
        //MARK: Observables
        //emit elements
//        let sourceObservable = Observable<Int>.create { observer in
//            var value = 0
//            let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
//                if value <= maxElements {
//                    observer.onNext(value)
//                    value += 1
//                }
//            }
//            return Disposables.create {
//                timer.suspend()
//            }
//        }.replay(replayedElements)
        
        let sourceObservable = Observable<Int>
            .interval(
                .milliseconds(Int(1000.0 / Double(elementsPerSecond))),
                scheduler: MainScheduler.instance
            ).replay(replayedElements)

        //TimelineView class implements RxSwift‘s ObserverType protocol
        _ = sourceObservable.subscribe(sourceTimeline)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
            _ = sourceObservable.subscribe(replayedTimeline)
        }
        
        _ = sourceObservable.connect()
        
        return hostView
    }
    
}
