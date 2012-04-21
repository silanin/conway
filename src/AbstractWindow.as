package  {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
    import flash.text.TextFormat;
	import flash.filters.DropShadowFilter;
	
	import com.greensock.*;
	
	public class AbstractWindow extends Sprite {
		
		protected var bg:Sprite;
		private var t:TextField;
		private var tf:TextFormat;
		
		private var _width:int;
		private var _height:int;
		private var _title:String;
		private var _padding:int;
		private var _active:Boolean;
		
		
		/** Get/Set active item */
		
		public function get active():Boolean {
			
			return _active;
		}
		
		public function set active( act:Boolean ):void {
			
			_active = act;
		}
		
		/** Get/Set title */
		
		public function set title( str:String ):void {
			
			_title = str;
			t.text = _title;
		}
		
		public function get title():String {
			
			return _title;
		}
		

		public function AbstractWindow() {
			
		}
		
		public function setSize( w:int, h:int ):void {
			
			clear();
			draw( w, h, _title, _padding );
		}
		
		public function move( x:int, y:int ):void {
			
			this.x = x;
			this.y = y;
		}
		
		public function show():void {
			
			_active = true;
			addChild( bg );
			TweenLite.to( bg, .5, {alpha:1} );
		}
		
		public function hide():void {
			
			_active = false;
			TweenLite.to( bg, .5, {alpha:0, onComplete: removeFromStage} );
		}
		
		protected function init():void {
			
			bg = new Sprite();
			tf = new TextFormat();
			t = new TextField();
		}
		
		/** Draw & redraw all assets dinamycly */
		
		protected function draw( w:int = 100, h:int = 100, tit:String  = "Заголовок", pad:int = 20 ):void {
			
			_width = w;
			_height = h;
			_title = tit;
			_padding = pad;
			
			// draw background
			bg.graphics.beginFill( 0xffffff, 1 );
			bg.graphics.drawRect( 0, 0, _width, _height );
			bg.graphics.endFill();
			bg.alpha = 0;
			
			// apply filter
			var filter = new DropShadowFilter( 0, 45, 0, .6, 6, 6 );
			bg.filters = [filter];
			
			// create title format
			tf.font = new Helvetica().fontName;
			tf.color = 0x666666;
			tf.size = 16;
			
			// draw title
			t.multiline = false;
			t.embedFonts = true;
			t.selectable = false;
			t.antiAliasType = AntiAliasType.ADVANCED;
			t.gridFitType = GridFitType.PIXEL;
			t.defaultTextFormat = tf;
			t.text = _title;
			t.width = _width - ( _width >> 2 ) + 6;
			t.height = t.textHeight + 6;
			t.y = pad >> 1;
			t.x = pad - 3;
			
			// add title to background
			bg.addChild(t);

		}
		
		protected function clear():void {
			
			bg.graphics.clear();
			bg.removeChild( t );
		}
		
		private function removeFromStage():void {
			
			removeChild( bg );
		}

	}
	
}
