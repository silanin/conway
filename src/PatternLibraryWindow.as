package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import com.hexluv.gui.scrollbar.HexluvScrollbar;
	
	
	public class PatternLibraryWindow extends AbstractWindow{
		
		private var container:Sprite;
		private var xml:XML;
		private var innerList:XMLList;
		private var outerList:XML;
		private var xMax:int;
		private var yMax:int;
		private var item:PatternItem;
		private var numPatterns:int;
		private var padding:int = 20;
		private var itemPadding:int = 4;
		private var _title:String;
		private var _src:String;
		private var _xnum:int = 3;
		private var _h:int;
		private var _w:int;

		private var scrollBar:HexluvScrollbar;
		
		public function set XMLpath( data:String ){
			_src = data;
		}
		
		public function get XMLpath():String{
			return _src;
		}
		
		public function set numColumns( num:int ){
			_xnum = num;
		}
		
		public function get numColumns():int{
			return _xnum;
		}
		
		public function PatternLibraryWindow( title:String, w:int, h:int ):void {
			
			_title = title;
			_w = w;
			_h = h;
			
			if(stage) initLibrary();
			else addEventListener( Event.ADDED_TO_STAGE, initLibrary );
			
		}
		
		public function parseXML( e:Event ):void {
			
			xml = new XML( e.target.data );
			numPatterns = xml.PATTERN.length();
			
			while(numPatterns--){
				
				item = new PatternItem( xml.PATTERN.NAME[numPatterns], xml.PATTERN.PICTURE[numPatterns], 101, 101 );
				container.addChild( item );
				item.x = numPatterns%_xnum*( 101 + ( itemPadding << 2 ) );
				item.y = int( numPatterns/_xnum )*( 120 + itemPadding );
				item.name = "pattern_" + numPatterns;
				item.buttonMode = true;
				item.mouseChildren = false;
				item.addEventListener( MouseEvent.CLICK, patternClick );

			}
			
			super.bg.addChild(container);
			
			addScrollBar();
			
		}
		
		override public function setSize( w:int, h:int ):void {
			
			super.setSize( w, h );
			
			_w = w;
			_h = h;
			
		}
		
		private function initLibrary( e:Event = null ):void{
			
			super.init();
			super.draw( _w, _h, _title, padding );
			
			container = new Sprite();
			container.y = padding << 1;
			container.x = padding;
			
			UniLoader.loadXML( _src, parseXML );
		}
		
		private function addScrollBar():void {
			
			scrollBar = new HexluvScrollbar( container, 12, _h - ( padding*3 ), false, stage, {alpha1:1, alpha2:0.1, fTint:0xcccccc, bTint:0x666666, corner:14} );
			bg.addChild( scrollBar );
		}
		
		private function patternClick(e:MouseEvent):void{
			
			outerList = xml.PATTERN.DATA[e.target.name.split('_')[1]];
			xMax = outerList.@xMax;
			yMax = outerList.@yMax;
			innerList = outerList.POINT;
			
			MovieClip( this.parent ).addPattern( innerList, xMax, yMax );
		}

	}
	
}

/*
========================================================
| Helper class  - drawing concrete pattern ( from xml )
========================================================
*/

import flash.events.Event;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.display.GradientType;
import flash.geom.Matrix;

internal class PatternItem extends Sprite{
		
	private var label:TextField;
	private var format:TextFormat;
	private var _tit:String;
	private var _img:String;
	private var _w:int;
	private var _h:int;

	public function PatternItem( tit:String, img:String, w:int, h:int ):void {
		
		_tit = tit;
		_img = img;
		_w = w;
		_h = h;
		
		createBackground();
		
	}
	
	private function createBackground():void {
		
		var gradientBoxMatrix:Matrix = new Matrix();
		gradientBoxMatrix.createGradientBox( _w, _h );
		
		graphics.beginGradientFill( GradientType.RADIAL, [0xFFFFFF, 0xefefef], [1,1], [0, 255], gradientBoxMatrix );
		graphics.lineStyle( 1, 0xcccccc );
		graphics.drawRect( 0, 0, _w, _h );
		graphics.endFill();
		
		UniLoader.loadImage( _img, createPicture );
		createTextField();
	}
	

	
	private function createPicture( e:Event ):void {
		
		e.target.content.x = 1;
		e.target.content.y = 1;
		addChild( e.target.content );
		
	}

	private function createTextField():void {
		
		label = new TextField();
		label.multiline = false;
		label.embedFonts = true;
		label.selectable = false;

		format = new TextFormat();
		format.font = new iFlash().fontName;
		format.color = 0x666666;
		format.size = 8;

		label.defaultTextFormat = format;
		label.text = _tit;
		label.width = label.textWidth + 3;
		label.height = 18;
		label.y = _h + 2;
		label.x = ( _w - label.textWidth ) >> 1;
		addChild(label);
	}

}
