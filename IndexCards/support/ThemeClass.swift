//
//  ThemeClass.swift
//  IndexCards
//
//  Created by James Lambert on 05/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import Foundation
import UIKit

class Theme : ThemeDelegateProtocol {
   
    //MARK:- ThemeDelegateProtocol
    func colorOf(_ item: Item ) -> UIColor {
        switch item {
        case .card1: return Theme.themes[chosenTheme].color.card1
        case .card2: return Theme.themes[chosenTheme].color.card2
        case .card3: return Theme.themes[chosenTheme].color.card3
        case .card4: return Theme.themes[chosenTheme].color.card4
        case .card5: return Theme.themes[chosenTheme].color.card5
        case .deck: return Theme.themes[chosenTheme].color.deck
        case .text: return Theme.themes[chosenTheme].color.text
        case .table: return Theme.themes[chosenTheme].color.table
        }
    }
    
    func sizeOf(_ item: Shape) -> CGFloat {
        switch item {
        case .cornerRadiusToBoundsWidth:
            return Theme.themes[chosenTheme].size.cornerRadiusToBoundsWidth
        case .cornerRadiusToBoundsWidthForButtons:
            return Theme.themes[chosenTheme].size.cornerRadiusToBoundsWidthForButtons
        case .indexCardAspectRatio:
            return Theme.themes[chosenTheme].size.indexCardAspectRatio
        case .menuItemHeightToBoundsHeightRatio:
            return Theme.themes[chosenTheme].size.menuItemHeightToBoundsHeightRatio
        }
    }
    
    func timeOf(_ animation: Animation) -> Double {
        switch animation {
        case .editCardZoom:
            return Theme.themes[chosenTheme].time.editCardZoom
        case .tapDeckTurn:
            return Theme.themes[chosenTheme].time.tapDeckTurn
        case .showMenu:
            return Theme.themes[chosenTheme].time.showMenu
        case .addShape:
            return Theme.themes[chosenTheme].time.addShape
        }
    }
    
    //MARK:- ThemeDelegate
    
    var chosenTheme = 0
    
    //set of themes
    private static let themes : [ThemeStructure] = [retro]
  
    //a theme struct
    private static let retro = ThemeStructure(
        color: ColorFor(
            card1:  #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1),
            card2:  #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1),
            card3:  #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),
            card4:  #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1),
            card5:  #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
            text:   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
            deck:   #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1),
            table:  #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
        size: defaultSize,
        time: defaultTime)
    
    //more themes here...
    
    
    //defaults
    private static let defaultSize = SizeFor(
        cornerRadiusToBoundsWidth: 0.03,
        cornerRadiusToBoundsWidthForButtons: 0.15,
        indexCardAspectRatio: CGFloat(1.5),
        menuItemHeightToBoundsHeightRatio: CGFloat(0.8))

    private static let defaultTime = TimeFor(
        editCardZoom: 0.3,
        tapDeckTurn: 0.2,
        showMenu: 0.2,
        addShape: 0.2)
}



//MARK:- Protocol

protocol ThemeDelegateProtocol {
    func colorOf(_ item : Item) -> UIColor
    func sizeOf(_ item : Shape) -> CGFloat
    func timeOf(_ animation : Animation) -> Double
}



//MARK:- types
enum Item {
    case card1
    case card2
    case card3
    case card4
    case card5
    case text
    case deck
    case table
}

enum Shape {
    case cornerRadiusToBoundsWidth
    case cornerRadiusToBoundsWidthForButtons
    case indexCardAspectRatio
    case menuItemHeightToBoundsHeightRatio
}

enum Animation{
    case editCardZoom
    case tapDeckTurn
    case showMenu
    case addShape
}


//MARK:- Private
private struct ThemeStructure {
    let color : ColorFor
    let size : SizeFor
    let time : TimeFor
}

private struct ColorFor {
    let card1 :   UIColor
    let card2 :   UIColor
    let card3 :   UIColor
    let card4 :   UIColor
    let card5 :   UIColor
    
    let text :    UIColor
    let deck :    UIColor
    let table:    UIColor
}


private struct TimeFor {
    let editCardZoom : Double
    let tapDeckTurn : Double
    let showMenu : Double
    let addShape : Double
}

private struct SizeFor {
    let cornerRadiusToBoundsWidth : CGFloat
    let cornerRadiusToBoundsWidthForButtons : CGFloat
    let indexCardAspectRatio : CGFloat
    let menuItemHeightToBoundsHeightRatio : CGFloat
}
