package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class SettingsWindow extends AbstractWindow {
		
		private static const sizes:Array = [{ title: 'малое поле', width: 20, height:20 }, { title: 'среднее поле', width: 40, height:24 }, { title: 'большое поле', width: 54, height:36 }];
		private var item:SizeItem;
		private var container:Sprite;
		private var padding:int = 20;
		private var itemWidth:int = 200;
		private var itemHeight:int = 46;
		private var itemPadding:int = 4;
		private var _title:String;
		private var _h:int;
		private var _w:int;

		public function SettingsWindow( title:String, w:int, h:int ):void {
			
			_title = title;
			_w = w;
			_h = h;
			
			if( stage ) initSettings();
			else addEventListener( Event.ADDED_TO_STAGE, initSettings );
		}
		
		private function initSettings( e:Event = null ):void {
			
			super.init();
			super.draw( _w, _h, _title, padding );
			
			addSizeBoxes();
			
		}
		
		private function addSizeBoxes():void {
			
			container = new Sprite();
			container.y = padding << 1;
			container.x = padding;
			
			var numItems = sizes.length;
			
			while( numItems-- ){
				
				item = new SizeItem( sizes[numItems].width + "x" + sizes[numItems].height, itemWidth, itemHeight );
				container.addChild( item );
				item.y = int( numItems*( itemHeight + itemPadding ) );
				item.name = "size_" + numItems;
				item.buttonMode = true;
				item.mouseChildren = false;
				item.addEventListener( MouseEvent.CLICK, sizeClick );
				
			}
			
			super.bg.addChild(container);
			
		}
		
		private function sizeClick(e:MouseEvent):void{
			
			var num:int = e.target.name.split('_')[1];
			MovieClip(this.parent).setSize( sizes[num].width, sizes[num].height );
			
		}

	}
	
}

/*
========================================================
| Helper class - drawing concrete sizes
========================================================
*/

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.display.GradientType;
import flash.geom.Matrix;

internal class SizeItem extends Sprite{
		
	private var label:TextField;
	private var format:TextFormat;
	private var _tit:String
	private var _w:int;
	private var _h:int;
	private var gradientBoxMatrix:Matrix;

	public function SizeItem( tit:String, w:int, h:int ):void {
		
		_tit = tit;
		_w = w;
		_h = h;
		
		createBackground();
		createTextField();
		
	}
	
	private function createBackground():void {
		
		gradientBoxMatrix = new Matrix();
		gradientBoxMatrix.createGradientBox( _w, _h );
		
		graphics.beginGradientFill( GradientType.RADIAL, [0xFFFFFF, 0xefefef], [1,1], [0, 255], gradientBoxMatrix );
		graphics.lineStyle( 1, 0xcccccc );
		graphics.drawRect( 0, 0, _w, _h );
		graphics.endFill();

	}

	private function createTextField():void {
		
		label = new TextField();
		label.embedFonts = true;
		label.selectable = false;
		label.antiAliasType = AntiAliasType.ADVANCED;
		label.gridFitType = GridFitType.SUBPIXEL;
		label.sharpness = 100;

		format = new TextFormat();
		format.font = new Helvetica().fontName;
		format.color = 0x666666;
		format.size = 14;

		label.defaultTextFormat = format;
		label.htmlText = "<p align='center'>" + _tit + "\n<font color='#acacac' size='11'>клеток</font></p>";
		label.width = label.textWidth + 6;
		label.height = label.textHeight + 6;
		label.y = int( ( _h - label.textHeight ) >> 1 );
		label.x = int( ( _w - label.textWidth ) >> 1 );
		addChild(label);
	}

}