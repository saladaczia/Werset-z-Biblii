import AppKit

let root = URL(fileURLWithPath: CommandLine.arguments[1])
let ivory = NSColor(srgbRed: 0.96, green: 0.945, blue: 0.91, alpha: 1)
let ink = NSColor(srgbRed: 0.18, green: 0.235, blue: 0.22, alpha: 1)
let gold = NSColor(srgbRed: 0.59, green: 0.47, blue: 0.30, alpha: 1)
func rect(_ x: Double,_ y: Double,_ w: Double,_ h: Double)->NSRect { NSRect(x:x,y:y,width:w,height:h) }
func fill(_ r:NSRect,_ color:NSColor,_ radius:CGFloat=0) { color.setFill(); NSBezierPath(roundedRect:r,xRadius:radius,yRadius:radius).fill() }
func text(_ value:String,_ r:NSRect,_ size:CGFloat,_ color:NSColor=ink,_ serif:Bool=false,_ weight:NSFont.Weight = .regular) {
 let para=NSMutableParagraphStyle(); para.lineSpacing=4
 let font=serif ? NSFont(name:"Georgia",size:size)! : NSFont.systemFont(ofSize:size,weight:weight)
 (value as NSString).draw(in:r,withAttributes:[.font:font,.foregroundColor:color,.paragraphStyle:para])
}
func picture(_ name:String,_ r:NSRect,_ radius:CGFloat=0) {
 let image=NSImage(contentsOf:root.appendingPathComponent("zrodla/\(name).png"))!
 NSGraphicsContext.saveGraphicsState()
 NSBezierPath(roundedRect:r,xRadius:radius,yRadius:radius).addClip()
 image.draw(in:r,from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:[.interpolation:NSImageInterpolation.high])
 NSGraphicsContext.restoreGraphicsState()
}
func shadow(_ r:NSRect,_ radius:CGFloat) {
 NSGraphicsContext.saveGraphicsState()
 let s=NSShadow();s.shadowColor=ink.withAlphaComponent(0.20);s.shadowBlurRadius=45;s.shadowOffset=NSSize(width:0,height:15);s.set()
 fill(r,ivory,radius)
 NSGraphicsContext.restoreGraphicsState()
}
func phone(_ name:String) {
 let w=940.0,h=w*874/402,x=(1320-w)/2,y=690.0
 let outer=rect(x-29,y-29,w+58,h+58)
 shadow(outer,158)
 // Flat titanium edge, separate black bezel, and rounded display corners.
 let metal=NSGradient(colors:[NSColor(white:0.28,alpha:1),NSColor(white:0.70,alpha:1),NSColor(white:0.38,alpha:1)])!
 metal.draw(in:NSBezierPath(roundedRect:outer,xRadius:158,yRadius:158),angle:0)
 fill(rect(x-23,y-23,w+46,h+46),NSColor(white:0.12,alpha:1),152)
 fill(rect(x-17,y-17,w+34,h+34),.black,146)
 // Action, volume and side buttons belong to the frame, outside the display.
 for (by,bh) in [(y+265,65.0),(y+390,130.0),(y+550,130.0)] {
   fill(rect(x-35,by,8,bh),NSColor(white:0.38,alpha:1),4)
 }
 fill(rect(x+w+27,y+440,8,205),NSColor(white:0.38,alpha:1),4)
 picture(name,rect(x,y,w,h),130)
 // iPhone status area and Dynamic Island at the same scale as the screen.
 fill(rect(x+w/2-133,y+28,266,73),.black,36.5)
 fill(rect(x+w/2+82,y+51,23,23),NSColor(srgbRed:0.035,green:0.047,blue:0.065,alpha:1),11.5)



}
let cards:[(String,String,String,String)] = [
 ("01-refleksja","Chwila spokoju.\nKażdego dnia.","Werset z Biblii i refleksja,\nktóre możesz zabrać w swój dzień.","reader"),
 ("02-motywy","Twoja chwila.\nTwój motyw.","Motywy Jezusa i natury.\nJeśli chcesz — inne tło każdego dnia.","themes"),
 ("03-ulubione","Zachowaj słowa,\nktóre poruszają.","Zapisuj ulubione refleksje\ni wracaj do nich, kiedy potrzebujesz.","favorites"),
 ("04-udostepnianie","Dobre słowo\nwarto przekazać.","Zapisz refleksję jako zdjęcie\nlub udostępnij ją bliskim.","export"),
 ("05-widgety","Słowo bliżej.\nJuż na ekranie.","Dzisiejszy werset w małym\nlub średnim widżecie.","widgets")
]
func render(_ width:Int,_ height:Int,_ drawing:()->Void)->NSBitmapImageRep {
 let cg=CGContext(data:nil,width:width,height:height,bitsPerComponent:8,bytesPerRow:width*4,space:CGColorSpace(name:CGColorSpace.sRGB)!,bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue)!
 NSGraphicsContext.saveGraphicsState()
 cg.translateBy(x:0,y:CGFloat(height));cg.scaleBy(x:CGFloat(width)/1320,y:-CGFloat(height)/2868)
 NSGraphicsContext.current=NSGraphicsContext(cgContext:cg,flipped:true)
 drawing()
 NSGraphicsContext.restoreGraphicsState()
 return NSBitmapImageRep(cgImage:cg.makeImage()!)
}
for (file,title,subtitle,source) in cards {
 for (folder,w,h) in [("iPhone-6.9",1320,2868),("iPhone-6.3",1206,2622)] {
 let rep=render(w,h) {
 fill(rect(0,0,1320,2868),ivory)
 text(title,rect(96,190,1150,290),96,ink,true)
 text(subtitle,rect(100,470,1120,150),38,ink.withAlphaComponent(0.78))
 if source == "widgets" {
   shadow(rect(100,830,1120,525),84)
   picture("widget-medium",rect(100,830,1120,525),84)
   shadow(rect(100,1475,550,550),90)
   picture("widget-small",rect(100,1475,550,550),90)
   text("Mały format.\nWielkie słowa.",rect(720,1615,510,160),49,ink,true)
   fill(rect(100,2220,1120,2),gold.withAlphaComponent(0.30))
   text("Dotknij i przeczytaj refleksję.",rect(100,2300,1120,90),45,ink,true)
   text("Tło zgodne z Twoim wyborem w aplikacji.",rect(100,2400,1120,100),32,ink.withAlphaComponent(0.7))
 } else if source == "export" {
   let r=rect(170,740,980,980*16/9)
   shadow(r,40);picture("export",r,40)
   text("BEZ PRZYCISKÓW. SAM TEKST I TŁO.",rect(170,2580,1040,60),29,gold,false,.semibold)
   text("Także w formacie 9:16.",rect(170,2645,1040,90),40,ink,true)
 } else { phone(source) }
 }
 try rep.representation(using:.png,properties:[:])!.write(to:root.appendingPathComponent("\(folder)/\(file).png"))
 }
}
// Contact sheet uses the exact exported artworks, without introducing new content.
let cg=CGContext(data:nil,width:1500,height:652,bitsPerComponent:8,bytesPerRow:6000,space:CGColorSpace(name:CGColorSpace.sRGB)!,bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue)!
NSGraphicsContext.current=NSGraphicsContext(cgContext:cg,flipped:false)
for (i,card) in cards.enumerated() {
 let img=NSImage(contentsOf:root.appendingPathComponent("iPhone-6.9/\(card.0).png"))!
 img.draw(in:NSRect(x:i*300,y:0,width:300,height:652))
}
let rep=NSBitmapImageRep(cgImage:cg.makeImage()!)
try rep.representation(using:.png,properties:[:])!.write(to:root.appendingPathComponent("Podglad.png"))
