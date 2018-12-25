//
//  main.swift
//  FunctionalProgramming
//
//  Created by 김문옥 on 25/12/2018.
//  Copyright © 2018 MunokKim. All rights reserved.
//

import Foundation



//////////////////////////// 3-1 FizzBuzz

//let fizz = { $0 % 3 == 0 ? "fizz" : "" }
//let buzz = { $0 % 5 == 0 ? "buzz" : "" }
//let fizzbuzz: (Int) -> String = { i in { a, b in
//    b.isEmpty ? a : b
//    }("\(i)", fizz(i) + buzz(i))
//}
//
//Array(1...100).forEach { print(fizzbuzz($0)) }




//////////////////////////// 3-2 Low-High

//enum Result: String {
//    case wrong = "Wrong"
//    case correct = "Correct!"
//    case high = "High"
//    case low = "Low"
//}
//
//func generateAnswer(_ min: Int, _ max: Int) -> Int {
//    return Int(arc4random()) % (max - min) + min
//}
//
//func inputAndCheck(_ answer: Int) -> () -> Bool {
//    return { printResult(evaluateInput(answer)) }
//}
//
//func evaluateInput(_ answer: Int) -> Result {
//    guard let inputNumber = Int(readLine() ?? "") else { return .wrong }
//    if inputNumber > answer { return .high }
//    if inputNumber < answer { return .low }
//    return .correct
//}
//
//func printResult(_ r: Result) -> Bool {
//    if case .correct = r { return false }
//    print(r.rawValue)
//    return true
//}
//
//func corrected(_ count: Int) -> Void {
//    print("Correct! : \(count)")
//}
//
//func countingLoop(_ needContinue: @escaping () -> Bool, _ finished: (Int) -> Void) {
//
//    func counter(_ c: Int) -> Int {
//        if !needContinue() { return c }
//        return counter(c + 1)
//    }
//
//    finished(counter(0))
//}
//
//countingLoop(inputAndCheck(generateAnswer(1, 100)), corrected)
//
//
//
////////////////////////// 3-3 Weather Forecast
//
//struct Location: Codable {
//    let title: String
//    let location_type: String
//    let woeid: Int
//    let latt_long: String
//}
//
//struct WeatherInfo: Codable {
//    let consolidated_weather: [Weather]
//}
//
//struct Weather: Codable {
//    let weather_state_name: String
//    let wind_direction_compass: String
//    let applicable_date: String
//    let min_temp: Float
//    let max_temp: Float
//    let the_temp: Float
//    let wind_speed: Float
//    let wind_direction: Float
//    let air_pressure: Float
//    let humidity: Float
//    let visibility: Float
//    let predictability: Float
//}
//
//func getData(_ url: URL, _ complted: @escaping (Data) -> ()) {
//    DispatchQueue.global(qos: .default).async {
//        if let data = try? Data(contentsOf: url) {
//            complted(data)
//        }
//    }
//}
//
//// 지역 검색 -> [Location]
//func getLocation(_ query: String, _ complted: @escaping ([Location]) -> ()) {
//    let url = URL(string: "https://www.metaweather.com/api/location/search?query=\(query)")!
//    getData(url) { data in
//        if let locations = try? JSONDecoder().decode([Location].self, from: data) {
//            complted(locations)
//        }
//    }
//}
//
//// Location -> woeid -> [Weather]
//func getWeathers(_ woeid: Int, _ complted: @escaping ([Weather]) -> ()) {
//    let url = URL(string: "https://www.metaweather.com/api/location/\(woeid)")!
//    getData(url) { data in
//        if let weatherInfo = try? JSONDecoder().decode(WeatherInfo.self, from: data) {
//            complted(weatherInfo.consolidated_weather)
//        }
//    }
//}
//
//// Weather -> print
//func printWeather(_ weather: Weather) {
//    let state = weather.weather_state_name.padding(toLength: 15,
//                                                   withPad: " ",
//                                                   startingAt: 0)
//    let forecast = String(format: "%@: %@ %2.2f°C ~ %2.2f°C",
//                          weather.applicable_date,
//                          state,
//                          weather.max_temp,
//                          weather.min_temp)
//    print(forecast)
//}
//
//getLocation("san") { locations in
//    locations.forEach({ location in
//        getWeathers(location.woeid) { weathers in
//            print("[\(location.title)]")
//            weathers.forEach({ weather in
//                printWeather(weather)
//            })
//            print("")
//        }
//    })
//}
//
//RunLoop.main.run()



// 자판기 프로젝트

// 자판기 프로젝트 고도화
// 1. 음료수의 재고상태를 State에 추가하세요
// 2. 음료수의 재고를 채워넣기 위한 Input 명령을 추가해 넣으세요
// 3. 현재 음료수 개수에 따라 음료수 부족 에러를 추가해 넣으세요
// 4. 음료수가 출력되면 재고도 함께 차감되도록 하세요

enum Product: Int {
    case cola = 1000
    case cider = 1100
    case fanta = 1200
    func name() -> String {
        switch self {
        case .cola: return "콜라"
        case .cider: return "사이다"
        case .fanta: return "환타"
        }
    }
}

enum Input {
    case moneyInput(Int)
    case productSelect(Product)
    case reset
    case stockInput(Int)
    case none
}

enum Output {
    case displayMoney(Int)
    case productOut(Product)
    case shortMoneyError
    case change(Int)
    case noStockError
    case displayStock(Int)
}

struct State {
    let money: Int
    let stock: Int
    
    static func initial() -> State {
        return State(money: 0, stock: 0)
    }
}

func consoleInput() -> Input {
    guard let command = readLine() else { return .none }
    switch command {
    case "100": return .moneyInput(100)
    case "500": return .moneyInput(500)
    case "1000": return .moneyInput(1000)
    case "cola": return .productSelect(.cola)
    case "cider": return .productSelect(.cider)
    case "fanta": return .productSelect(.fanta)
    case "reset": return .reset
    case "stock": return .stockInput(10)
    default: return .none
    }
}

func consoleOutput(_ output: Output) -> Void {
    switch output {
    case .displayMoney(let m):
        print("현재 금액은 \(m)원 입니다.")
    case .productOut(let p):
        print("\(p.name())이 나왔습니다.")
    case .shortMoneyError:
        print("잔액이 부족합니다.")
    case .change(let c):
        print("잔액 \(c)원이 나왔습니다.")
    case .noStockError:
        print("재고가 없습니다.")
    case .displayStock(let s):
        print("재고가 \(s)개 남았습니다.")
    }
}

func operation(_ inp: @escaping () -> Input, _ out: @escaping (Output) -> Void) -> (State) -> State {
    return { state in
        let input = inp()
        
        switch input {
        case .moneyInput(let m):
            let money = state.money + m
            let stock = state.stock
            out(.displayMoney(money))
            return State(money: money, stock: stock)
            
        case .productSelect(let p):
            if state.money < p.rawValue {
                out(.shortMoneyError)
                return state
            }
            if state.stock <= 0 {
                out(.noStockError)
                return state
            }
            out(.productOut(p))
            let money = state.money - p.rawValue
            let stock = state.stock - 1
            out(.displayMoney(money))
            return State(money: money, stock: stock)
            
        case .reset:
            out(.change(state.money))
            out(.displayMoney(0))
            return State(money: 0, stock: state.stock)
            
        case .stockInput(_):
            let money = state.money
            let stock = state.stock + 10
            out(.displayStock(stock))
            return State(money: money, stock: stock)
            
        case .none:
            return state
        }
    }
}

func machineLoop(_ f: @escaping (State) -> State) {
    func loop(_ s: State) {
        loop(f(s))
    }
    loop(State.initial())
}

machineLoop(operation(consoleInput, consoleOutput))
