//
//  TextLayer.swift
//  JoeMetalProj
//
//  Created by Joe Milner-Moore on 21/08/2017.
//  Copyright © 2017 Joe Milner-Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

struct RectEntry
{
	let x:					CGFloat
	let y:					CGFloat
	let w:					CGFloat
	let h:					CGFloat
	let colour:				UIColor
	
	init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, colour: UIColor = UIColor.white)
	{
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		self.colour = colour
	}
}

struct LineEntry
{
	let start:		CGPoint
	let end:		CGPoint
	let colour:		UIColor
	
	init(_ start: CGPoint, _ end: CGPoint, colour: UIColor = UIColor.white)
	{
		self.start = start
		self.end = end
		self.colour = colour
	}
}

struct TextEntry
{
	let str:				String
	let colour:				UIColor
	let x:					CGFloat
	let y:					CGFloat
	let w:					CGFloat
	let h:					CGFloat
	
	init(_ str: String, colour: UIColor = UIColor.white, x: CGFloat = 0, y: CGFloat = -1, w: CGFloat = -1, h: CGFloat = -1)
	{
		self.str = str
		self.colour = colour
		self.x = x
		self.y = y
		self.w = w
		self.h = h
	}
}

class TextLayer : CALayer
{
	var entries = 			[TextEntry]()
	var rectEntries = 		[RectEntry]()
	var lineEntries =		[LineEntry]()
	
	func addEntry(_ entry: TextEntry)
	{
		entries.append(entry)
		needsDisplay()
	}
	
	override func draw(in context: CGContext)
	{
		UIGraphicsPushContext(context)
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .left
		
		var autoHeight = 20 as CGFloat
		
		for e in entries
		{
			let attrs = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Thin", size: 14)!,
			             NSAttributedStringKey.paragraphStyle: paragraphStyle,
			             NSAttributedStringKey.foregroundColor: e.colour ]
			
			let w = (e.w > 0) ? e.w : self.frame.width - e.x
			let h = (e.h > 0) ? e.h : self.frame.height - e.y
			
			var y = e.y
			if (e.y < 0)
			{
				y = autoHeight
				autoHeight += 16
			}

			e.str.draw(with: CGRect(x: e.x, y: y, width: w, height: h), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
		}
		
		for e in rectEntries
		{
			context.setStrokeColor(e.colour.cgColor)
			context.setLineWidth(1)
			context.addRect(CGRect(x: e.x, y: e.y, width: e.w, height: e.h))
			context.strokePath()
		}
		
		for e in lineEntries
		{
			context.setStrokeColor(e.colour.cgColor)
			context.setLineWidth(1)
			context.move(to: e.start)
			context.addLine(to: e.end)
			context.strokePath()
		}
		
		UIGraphicsPopContext()
			
		entries.removeAll()
	}
}

