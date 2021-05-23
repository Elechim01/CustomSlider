//
//  HomeView.swift
//  CustomSlider (iOS)
//
//  Created by Michele Manniello on 23/05/21.
//

import SwiftUI
import AudioToolbox

struct HomeView: View {
    @State var offset : CGFloat = 0
    var body: some View {
        VStack(spacing:15){
//            Top excerize View..
            Image("excersize")
                .resizable()
                .frame(width: 200, height: 200)
                .padding(.top,40)
            Spacer(minLength: 0)
            Text("Weight")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(.black)
            Text("\(getWeight()) Kg")
                .font(.system(size: 38, weight: .heavy))
                .foregroundColor(Color("purple1"))
                .padding(.bottom,20)
            
//            sample Buildling in SwiftUI
            //                ie From 40 to 100KG
            let pickerCount = 6
            CustomSlider(pickerCount: pickerCount,offset : $offset,content: {
              
                HStack(spacing:0){
                    ForEach(1...pickerCount,id:\.self){ index in
                        VStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 1, height: 30)
                                //                        each Picker Tick wil have 20 width
                                Text("\(30 + (index * 10))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                        }
                        .frame(width:20)
                        //                        SubTicks....
                        //                        Fixed Subtics will have four for each main Tick
                        ForEach(1...4,id:\.self){ subIndex in
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 1, height: 15)
                                //                        each Picker Tick wil have 20 width
                                .frame(width:20)
                        }
                    }
                    VStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 1, height: 30)
                            //                        each Picker Tick wil have 20 width
                            Text("\(100 )")
                                .font(.caption2)
                                .foregroundColor(.gray)
                    }

                }
                
                //                Moving The First Tick to center..
                .offset(x: (getRect().width - 30)/2)
                .padding(.trailing,getRect().width - 30)
            })
//            MakHeight
            .frame(height:50)
            .overlay(
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 1, height: 50)
                    .offset(x: 0.8, y: -30)
            )
            .padding()
            Button(action: {
                
            }, label: {
                Text("Next")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical,15)
                    .padding(.horizontal,60)
                    .background(Color("purple1"))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: -5, y: -5)
            })
            .padding(.top,20)
            .padding(.bottom,10)
            
        }
        .frame(maxWidth:.infinity, maxHeight:.infinity)
        .background(
            Circle()
                .fill(Color("purple"))
//            Enlarging Cirlce..
                .scaleEffect(1.5)
//            Moving Up...
                .offset(y:-getRect().height / 2.4)
        )
    }
    func getWeight() -> String {
//        since our weight starts from 40..
        let startWight = 40
        let progress = offset / 20
//        each subtick will calcilated as 2..
        return "\(startWight + (Int(progress) * 2))"
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
//Screen size
func getRect() -> CGRect {
    return UIScreen.main.bounds
}
//were going to build custom slider the help of uiscrollview in uiKit...
//with the help of vew Builders
struct CustomSlider<Content:View> : UIViewRepresentable {
    var content:Content
//    Binding offset for Kg Calculations..
    @Binding var offset: CGFloat
    var pickerCount : Int
    
    init(pickerCount : Int,offset : Binding<CGFloat>, @ViewBuilder content: @escaping ()-> Content) {
        self.content = content()
        self._offset = offset
        self.pickerCount = pickerCount
    }
    func makeCoordinator() -> Coordinator {
        return CustomSlider.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIScrollView{
        let scrollView = UIScrollView()
        let swiftUiview = UIHostingController(rootView: content).view!
//        So SwiftUI Width will be total of pickerCount Multipled with 20 + screen Size..
//        each pickerCount have 4 subpicker...
//        so 6*4 = 24 +6 = 30
//        picker * 5
        let width = CGFloat((pickerCount * 5 ) * 20) + (getRect().width - 30)
        swiftUiview.frame = CGRect(x:0,y: 0,width: width,height: 50)
        scrollView.contentSize = swiftUiview.frame.size
        scrollView.addSubview(swiftUiview)
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = context.coordinator
        return scrollView
    }
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
    }
//    Delegate methods for Offset..
    class Coordinator: NSObject,UIScrollViewDelegate {
        var parent : CustomSlider
        init(parent: CustomSlider) {
            self.parent = parent
        }
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = scrollView.contentOffset.x
        }
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.x
            let value = (offset / 20).rounded(.toNearestOrAwayFromZero)
            scrollView.setContentOffset(CGPoint(x: value * 20, y: 0), animated: false)
//            Tick and Vibrate Sound On end...
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
//            Tick Sound Code...
            AudioServicesPlayAlertSound(1157)
        }
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            //             if end declate not fired...
            if !decelerate{
                let offset = scrollView.contentOffset.x
                let value = (offset / 20).rounded(.toNearestOrAwayFromZero)
                scrollView.setContentOffset(CGPoint(x: value * 20, y: 0), animated: false)
//            Tick and Vibrate Sound On end...
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
//            Tick Sound Code...
                AudioServicesPlayAlertSound(1157)
            }
        }
    }
    
}
