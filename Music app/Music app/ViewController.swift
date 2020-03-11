//
//  ViewController.swift
//  Music app
//
//  Created by mac mini on 07/03/20.
//  Copyright © 2020 mac mini. All rights reserved.
//

import UIKit
import AVFoundation


struct Word: Decodable{
    let start_time : Float
    let end_time: Float
    let text : String
}

struct Response: Decodable {
    let sections: [Section]
}


struct Section: Decodable {
    let words : [Word]
}


class ViewController: UIViewController {

    var sections = [Section]()
    var words = [Word]()
    
    var player = AVPlayer()
    var timer = Timer()
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblWord: UILabel!
    
    let rangeArray = [NSRange]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        loadJSON()
        guard let songUrl = URL(string: "https://transcription-asr.s3-ap-southeast-1.amazonaws.com/GCjWdk8GZNmL04DS9hfzYM2dm2EtcOG3yMN63go6.mpga") else{return}
        
       loadAllTheText()
       self.play(url: songUrl)
       timer =  Timer.scheduledTimer(timeInterval: 0.100 , target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        
        // Do any additional setup after loading the view.
        
    }

   
    func highlightCode(baseString: String , highlightText: String , index: Int){
        let attributed = NSMutableAttributedString(string: baseString)
              do
              {
                  let regex = try! NSRegularExpression(pattern: highlightText,options: .caseInsensitive)
                for match in regex.matches(in: baseString, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.count)) as [NSTextCheckingResult] {
                    
        
                      attributed.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.orange, range: match.range)
                        
        
                  }
                  
                  self.lblSubtitle.attributedText = attributed
              }
    }
    
    
    
    func loadAllTheTextWithHightlight(hIndex : Int){
        lblSubtitle.text = ""

            for (index , word) in words.enumerated(){
                print(" this is index \(index) and this is highlight index \(hIndex)" )
                
                
               
                
                
                if index == hIndex{
                    
                    let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red , NSAttributedString.Key.backgroundColor: UIColor.orange]
                    
                    
                        
                    
                    let attributedText = NSAttributedString(string: " \(word.text)", attributes: attributes)

                        
                        
                    let mutableAttributedString = NSMutableAttributedString()
                    mutableAttributedString.append(lblSubtitle.attributedText!)
                    mutableAttributedString.append(attributedText)
                    
                    
                    lblSubtitle.attributedText = mutableAttributedString
                }else{
                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
                let attributedText = NSAttributedString(string: " \(word.text)", attributes: attributes)
                    let mutableAttributedString = NSMutableAttributedString()
                    mutableAttributedString.append(lblSubtitle.attributedText!)
                    mutableAttributedString.append(attributedText)
                    lblSubtitle.attributedText = mutableAttributedString
                    
                //lblSubtitle.text = lblSubtitle.text! + "  \(word.text)"
                }
            }

    }
    
    
    
    
    @objc func runTimedCode(){
        //print(self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.player.currentItem?.currentTime())!))))))
       // print(self.player.currentItem?.currentTime().seconds)
        let playerCurrentTime = Float((self.player.currentItem?.currentTime().seconds)!)
            filterFunction(currentTime: playerCurrentTime)
    }
    
    
    func loadJSON(){
        if let path = Bundle.main.path(forResource: "file-sample", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                print(jsonResult)
                  
                guard let jsonData = try? JSONDecoder().decode(Response.self, from: data) else { return }
                
                print(jsonData.sections[0].words[0].start_time)
                sections = jsonData.sections
                words = sections[0].words
                words += sections[1].words
                words += sections[2].words
                print(words)
              } catch {
                   // handle error
              }
        }
    }
    
    
    
    
    func filterFunction(currentTime: Float){
        for (index , word) in words.enumerated(){
            let startTime = word.start_time
            let endTime = word.end_time
            
            if (startTime..<endTime).contains(currentTime){
                if lblSubtitle.text != word.text {
                    //print(startTime , endTime)
                    //print(word.text)
                    lblWord.text = word.text
                }
              // print(index)
                //highlightCode(baseString: lblSubtitle.text!, highlightText: word.text , index: index)
                loadAllTheTextWithHightlight(hIndex: index)
                //loadAllTheText(hIndex: index)
            }
            
            
        }
    }
    //35 29 26
    
    func loadAllTheText(){
        lblSubtitle.text = ""
        for section in sections{
            for (index ,word) in section.words.enumerated(){
                print(index)
                lblSubtitle.text = lblSubtitle.text! + "  \(word.text)"
            }
            lblSubtitle.text = lblSubtitle.text! + "\n\n\n"
        }
    }
    
    
    
    
    func play(url:URL) {
        self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
        self.player.automaticallyWaitsToMinimizeStalling = false
        player.volume = 1.0
        player.play()
    }
    
    func formatTimeFromSeconds(totalSeconds: Int32) -> Int32 {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        //return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
        return minutes
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        play(url: URL(string: "https://transcription-asr.s3-ap-southeast-1.amazonaws.com/GCjWdk8GZNmL04DS9hfzYM2dm2EtcOG3yMN63go6.mpga")!)
        print(self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.player.currentItem?.currentTime())!))))))
        //print(self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.player.currentItem?.asset.duration)!))))))
        
    }
    

      
    
    
}



extension RangeReplaceableCollection where Element: Equatable
{
    mutating func prependUnique(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
        insert(element, at: startIndex)
    }
}
