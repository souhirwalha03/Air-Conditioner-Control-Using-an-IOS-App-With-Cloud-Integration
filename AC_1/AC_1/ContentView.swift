//Option Command Arrow Left
//  ContentView.swift
//  AC_1


import SwiftUI



import Foundation


struct ContentView: View {
    @ObservedObject var tabManager = TabManager()

    var body: some View {
        VStack {
            switch tabManager.lastSelectedIndex{
            case 0 :
                TemperatureView()
            case 1 :
                Text ("Light")
            default:
                TemperatureView()
            }
            Spacer()
            CustomTabView(manager: tabManager)
                .padding(.leading, 30)
                .padding(.trailing, 30)
        }
    }
}

struct CustomTabView: View {
    @ObservedObject var manager : TabManager
    
    var body : some View {
        ZStack{
            RoundedRectangle( cornerRadius: 40).frame(height: 80)
                .foregroundColor(Color.black)
            HStack (spacing : 30 ){
                ForEach(manager.tabMenus){
                    menu in MenuItemView(menu: menu)
                        .onTapGesture {
                            manager.selectMenu(index: menu.id)
                        }
                }
            }
        }.onAppear{
            manager.selectMenu(index: 0)
        }
    }
}



class TabManager : ObservableObject {
    @Published var tabMenus = AppData.menus
    @Published var lastSelectedIndex = -1

    func selectMenu (index: Int){
        if index != lastSelectedIndex{
            tabMenus [index].selected = true
            if lastSelectedIndex != -1 {
                tabMenus[lastSelectedIndex].selected = false
                
            }
            lastSelectedIndex = index
        }
    }
}


struct MenuItemView: View{
    let menu : TabMenu
    var body: some View{
        ZStack{
            Circle().fill(menu.color)
                .frame(width:50, height: 50)
                .opacity(menu.selected ? 1.0 : 0.0)
            
            Image(systemName: menu.imageName)
                .foregroundColor(menu.selected ? .white : .gray)
                .font(.title2)
        }
    }
}


struct AppData{
    static let menus = [
        TabMenu(id: 0, imageName: "thermometer", color: Color(red: 155/255, green: 151/255, blue: 151/255)),
        TabMenu(id: 1, imageName: "lightbulb", color: ColorConstants.lightTab)
    ]
}



//3 in 0
struct TemperatureView : View {
    @State var tempValue : CGFloat = 0.0
    @State private var isSwitchOn = false
    func sendSwitchStatus() {
        let apiUrl = URL(string: "http://192.168.1.148:80/")!
        
        let switchStatus = ["switch_status": isSwitchOn]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: switchStatus) {
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            print("HTTP Method: \(request.httpMethod ?? "No method specified")")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data {
                                                    do {
                                                        let responseJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                                        print(responseJson ?? "No response data")
                                                    } catch {
                                                        print("Error parsing JSON: \(error)")
                                                    }
                                                }
                    } else {
                        print("HTTP Status Code: \(response.statusCode)")
                    }
                }
            }

            
            task.resume()
        }
    }
    var body: some View {
        VStack{
            Text("Temperature").font(.largeTitle)
                .foregroundColor(ColorConstants.textColorPrimary)
                .bold()
                .padding(.top, 60)
                .padding(.bottom, 1)

            
            TemperatureControlView(tempValue: $tempValue).padding(.top, 60)
            if isSwitchOn == false {
                Text("Power Off").font(.largeTitle)
                    .foregroundColor(ColorConstants.textColorPrimary)
                    .padding(.top, 1)
            }
            else {
                Text("Power On").font(.largeTitle)
                    .foregroundColor(ColorConstants.textColorPrimary)
                    .padding(.top, 1)

            }
                    
            Toggle("", isOn: $isSwitchOn)
                           .toggleStyle(CustomToggleStyle())
                           .padding(.top, 20)
                           .onChange(of: isSwitchOn) { newValue in
                                               
                               sendSwitchStatus()
                                           }
            
        }
            
    }
}









struct TabMenu : Identifiable{
    let id: Int
    let imageName : String
    let color: Color
    var selected: Bool = false
}







struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 60)
                .frame(width: 90, height: 45)
                .foregroundColor(configuration.isOn ? Color(red: 145/255, green: 212/255, blue: 200/255): Color(red: 209/255, green: 215/255, blue: 218/255))
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(5.5)
                        .offset(x: configuration.isOn ? 25 : -23, y: 0)
                        .animation(Animation.easeInOut(duration: 0.2))
                    
                )
            
            
        }
        

    }
    
    
}


struct TemperatureControlView : View {
    @Binding var tempValue : CGFloat
    @State var angleValue : CGFloat = 0.0
    let minvalue :CGFloat = 15.0
    let maxvalue :CGFloat = 40.0
    let totalvalue :CGFloat = 100.0
    let knobradius :CGFloat = 10.0
    let radius :CGFloat = 125.0
    
    @State private var previousTempValue: CGFloat = 0.0

    
    func sendTemperature(value: CGFloat) {
        let apiUrl = URL(string: "http://192.168.1.148:80")!
        
        let data = ["tempValue": value]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data {
                            do {
                                let responseJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                print(responseJson ?? "No response data")
                            } catch {
                                print("Error parsing JSON: \(error)")
                            }
                        }
                    } else {
                        print("HTTP Status Code: \(response.statusCode)")
                    }
                }
            }
            task.resume()
        }
    }

    var body: some View {
        ZStack{
            OuterBorderCircle()
            HStack(alignment: .firstTextBaseline, spacing:3){
                Text("\(String.init(format: "%.0f", tempValue))")
                    .font(.system(size: 60))
                    .bold()
                    .foregroundColor(ColorConstants.textColorPrimary)
                    .onChange(of: tempValue) { newValue in
                        
                            let roundedValue = newValue.rounded()
                        
                        if roundedValue != previousTempValue.rounded(){
                            previousTempValue = newValue
                            
                                sendTemperature(value: roundedValue)
                            
                        }
                        
                    }

                
                
                
                Text("°C").font(.system(size: 30))
                    .bold()
                    .foregroundColor(ColorConstants.textColorPrimary)
            }
            
            Circle()
                .trim(from: minvalue/totalvalue, to:maxvalue/totalvalue)
                .stroke(AngularGradient(
                    gradient: Gradient(colors: [Color.green, Color.yellow, Color.red ]),
                    center: .center,
                    startAngle: .degrees(50),
                    endAngle: .degrees(150))
                        ,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: radius * 2, height: radius * 2 )
                .rotationEffect(.degrees(-190))
            
            knobCircle(radius: knobradius * 2, padding: 6)
                .offset(y: -radius)
                .rotationEffect(Angle.degrees(Double(angleValue)))
                .shadow(color: Color.black.opacity(0.2), radius: 3, x:-3 , y:2)
                .gesture(DragGesture(minimumDistance: 0.0).onChanged({
                    value in
                    change(location: value.location)
                    
                }))
                .rotationEffect(.degrees(-100))
        }
        .onAppear{
            updateInitialValue()

                                                
        }
    }
    


    private func updateInitialValue (){
        tempValue = minvalue
        angleValue = CGFloat (tempValue / totalvalue) * 360

                            
    }
    
    
    private func change(location: CGPoint){
        let vector =    CGVector(dx: location.x, dy: location.y)
        let angle = atan2(vector.dy - knobradius, vector.dx - knobradius) + .pi/2.0
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        let value = fixedAngle / (2.0 * .pi ) * totalvalue
        
        if value >= minvalue && value <= maxvalue {
            angleValue = fixedAngle * 180 / .pi
            tempValue = value
        }
    }
}








struct OuterBorderCircle: View {
    var body: some View{
        ZStack{
            Circle()
                .stroke (Color(white:0.9), lineWidth : 1)
                .frame(width: 250, height: 250 )
            

        }
    }
}


struct knobCircle: View {
    let radius: CGFloat
    let padding: CGFloat
    var body: some View {
        ZStack{
            Circle()
                .fill(Color.init(white: 0.96))
                .frame(width: radius, height: radius)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x:-10, y: 8)
            Circle()
                .fill(Color.white)
                .frame(width: radius - padding, height: radius - padding)
        }
    }
}


struct ColorConstants {
    static let textColorPrimary = Color(red: 69/255, green: 74/255, blue: 86/255)
    static let lightsliderStart = Color(red: 225/255, green: 228/255, blue: 167/255)
    static let lightTab = Color (red: 228/255, green: 230/255, blue: 0/255)
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
