package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Main extends MovieClip {
		
		private var itemsNum:int; // total items count
		private var rowNum:int = 54; // row count (horizontal items)
		private var cellNum:int = 36; // cell count (vertical items)
		private var itemPadding:int = 1; // itemPadding between items
		private var itemSize:int = 12; // each item size (width & height)
		private var yPoz:int; // x pozition for each item
		private var xPoz:int; // y pozition for each item
		private var i:int; // iterator for all 
		private var isRunning:Boolean; 
		private var currFrame:int = 0;
		private var delay:int = 8;
		private var generation:uint = 0;
		private var xOffset:int;
		private var yOffset:int;

		private var allItems:Vector.<Vector.<Item>>;
		private var neighbours:Vector.<Item> = new Vector.<Item>(8, true);
		private var neighboursCount:int;
		private var toFlip:Vector.<Item> = new Vector.<Item>();
		private var toFlipCount:int;
		
		private var gameStage:Sprite;
		private var panel:Panel;
		private var patternLibrary:PatternLibraryWindow;
		private var settings:SettingsWindow;
		private var startWindow:Boolean = true;
		
		
		public function Main():void {
			
			if (stage) drawControls();
			else addEventListener(Event.ADDED_TO_STAGE, drawControls);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
		}
		
		private function drawControls():void{
			
			// create items area
			gameStage = new Sprite();
			addChild(gameStage);
			
			// create controls panel
			panel = new Panel();
			panel.y = stage.stageHeight - panel.height;
			
			// adding and setup library of patterns
			patternLibrary = new PatternLibraryWindow("Основные «формы жизни»:", 390, 360);
			patternLibrary.XMLpath = "xml/patterns.xml";
			patternLibrary.numColumns = 3;
			addChild(patternLibrary);
			patternLibrary.move((stage.stageWidth - 390) >> 1, panel.y - 360);
			
			// adding and setup window with sizes
			settings = new SettingsWindow( "Выберите размер поля:", 240, 214 );
			addChild(settings);
			settings.move((stage.stageWidth - 240) >> 1, (stage.stageHeight - 214) >> 1);
			settings.show();
			
			// adding event handlers to buttons
			panel.buttonPlayPause.buttonMode = true;
			panel.buttonPlayPause.addEventListener(MouseEvent.CLICK, playPauseScene);
			panel.buttonClear.buttonMode = true;
			panel.buttonClear.addEventListener(MouseEvent.CLICK, clearScene);
			panel.buttonPattern.buttonMode = true;
			panel.buttonPattern.addEventListener(MouseEvent.CLICK, showHidePatterns);
			panel.buttonSettings.buttonMode = true;
			panel.buttonSettings.addEventListener(MouseEvent.CLICK, showHideSettings);
			stage.addEventListener(MouseEvent.CLICK, sceneIsClicked);
			
		}
		
		private function drawArea():void{
			
			// count total number of all items and create Vector with same length
			itemsNum = rowNum*cellNum;
			allItems = new Vector.<Vector.<Item>>(itemsNum);
			
			// draw border
			gameStage.graphics.clear();
			gameStage.graphics.lineStyle(1, 0xffffff);
			gameStage.graphics.beginFill(0xffffff, 1);
			gameStage.graphics.drawRect(1, 1, (itemPadding + itemSize)*rowNum, (itemPadding + itemSize)*cellNum);
			
			// repozition items area
			gameStage.x = (stage.stageWidth - (rowNum*(itemSize + itemPadding) + 3)) >> 1;
			gameStage.y = (stage.stageHeight - panel.height - (cellNum*(itemSize + itemPadding) + 3)) >> 1;
			
			// fill in Vector
			for(i = 0; i < itemsNum; i++){
				
				yPoz = int(i/rowNum);
				xPoz = i%rowNum;

				if (!allItems[yPoz]) allItems[yPoz] = new Vector.<Item>;
				
				allItems[yPoz][xPoz] = new Item();
				allItems[yPoz][xPoz].x = (itemPadding << 1) + (itemPadding + itemSize)*xPoz;
				allItems[yPoz][xPoz].y = (itemPadding << 1) + (itemPadding + itemSize)*yPoz;
				allItems[yPoz][xPoz].name = "item_" + i;
				allItems[yPoz][xPoz].addEventListener(MouseEvent.CLICK, cellIsClicked);
				gameStage.addChild(allItems[yPoz][xPoz]);
				
			}
			
		}
		
		private function randomize():void {
			
			i = itemsNum;
			
			while( i-- ){

				allItems[int(i/rowNum)][i%rowNum].isAlive = Math.random() > 0.8;
			}
		}
		
		public function addPattern( pat:XMLList, xMax:int, yMax:int ):void {
			
			// clear area
			clearScene();
			showHidePatterns();
			
			// count offset in items from stage top left corner to pattern top left corner 
			xOffset = (rowNum - xMax) >> 1;
			yOffset = (cellNum - yMax) >> 1;
			
			// activate pattern
			for each(var it:XML in pat){
				
				allItems[int(it.@y) + yOffset][int(it.@x) + xOffset].isAlive = true;
			}

		}
		
		public function setSize( xNum:int, yNum:int ):void {
			
			// hide settings window
			if( settings.active ) showHideSettings();
			
			// remember new size
			rowNum = xNum;
			cellNum = yNum;
			
			// clear Vector and area
			if( allItems ){
				allItems.splice( 0, allItems.length );
				removeAll();
			}
			
			// draw area
			drawArea();
			
			// if this is first run - add panel & randomizing area
			if( startWindow ) {
				addChild( panel );
				randomize();
			}
		}
		
				private function run( e:Event ):void{
			
			if( isRunning ){
				currFrame ++;

				if( currFrame > delay ){
					
					if ( toFlip.length ) toFlip.splice( 0, toFlip.length );
					
					generation ++;
					i = itemsNum;
			
					while( --i ){

						yPoz = int(i/rowNum);
						xPoz = i%rowNum;
						
						if( needToFlip(checkCount(allItems[yPoz][xPoz]), allItems[yPoz][xPoz].isAlive) ) toFlip.push(allItems[yPoz][xPoz]);
						
					}
					
					toFlipCount = toFlip.length;
					
					while( toFlipCount-- ){
						toFlip[toFlipCount].flip();
					}
					
					currFrame = 0;
				}
			}
		}
		
		/** get neighbours count */
		
		private function checkCount(item:Item):int{
			
			// find position in Vector
			yPoz = int( item.name.split('_')[1] / rowNum );
			xPoz = item.name.split('_')[1] % rowNum;
			
			// find all neighbours
			neighbours[0] = ( yPoz - 1 > -1 && xPoz - 1 > -1 ) ? Item(allItems[yPoz - 1][xPoz - 1] ) : null;
			neighbours[1] = ( yPoz - 1 > -1 ) ? Item(allItems[yPoz - 1][xPoz] ) : null;
			neighbours[2] = ( yPoz - 1 > -1 && xPoz + 1 < rowNum ) ? Item(allItems[yPoz - 1][xPoz + 1] ) : null;
			neighbours[3] = ( xPoz - 1 > -1 ) ? Item(allItems[yPoz][xPoz - 1] ) : null;
			neighbours[4] = ( xPoz + 1 < rowNum ) ? Item(allItems[yPoz][xPoz + 1] ) : null;
			neighbours[5] = ( yPoz + 1 < cellNum && xPoz - 1 > -1) ? Item(allItems[yPoz + 1][xPoz - 1] ) : null;
			neighbours[6] = ( yPoz + 1 < cellNum ) ? Item(allItems[yPoz + 1][xPoz] ) : null;
			neighbours[7] = ( yPoz + 1 < cellNum && xPoz + 1 < rowNum ) ? Item(allItems[yPoz + 1][xPoz + 1] ) : null;
			
			neighboursCount = 0;
			
			// count them
			for each ( var it in neighbours ){
				
				if( it != null && it.isAlive ){
					neighboursCount ++;
				}
			}
			
			return neighboursCount;
		}
		
		/** Check if current item need to be flipped */
		
		private function needToFlip( nCount:int, isAlive:Boolean ):Boolean{
			
			if( ( nCount < 2 && isAlive ) || ( nCount > 3 && isAlive ) ) return true;
			else if( nCount == 3 && !isAlive ) return true;
			else return false;
			
		}
		
		private function playPauseScene( e:MouseEvent ):void{
			
			isRunning = !isRunning;
			
			panel.buttonPlayPause.gotoAndStop( isRunning + 1 );
			
			if( isRunning ){
				stage.addEventListener( Event.ENTER_FRAME, run );
			}else{
				stage.removeEventListener( Event.ENTER_FRAME, run );
				
			}
			
		}
		
		private function pauseScene():void{
			
			isRunning = false;
			panel.buttonPlayPause.gotoAndStop( isRunning + 1 );
			stage.removeEventListener( Event.ENTER_FRAME, run );
			
		}
		
		public function clearScene( e:MouseEvent = null ):void{
			
			pauseScene();
			generation = 0;
			
			i = itemsNum;
			
			while( i-- ){
				allItems[int(i/rowNum)][i%rowNum].isAlive = false;
			}
			
		}
		
		public function removeAll():void{
			
			pauseScene();
			generation = 0;

			i = gameStage.numChildren;
			
			while( i-- ){
				gameStage.removeChildAt( i );
			}

		}
		
		private function cellIsClicked( e:MouseEvent ):void{
			
			e.target.flip();
			if( patternLibrary.active ) showHidePatterns();
			if( settings.active ) showHideSettings();
			
		}
		
		private function sceneIsClicked( e:MouseEvent ):void{
			
			if( e.target is Stage ){
				if( patternLibrary.active ) showHidePatterns();
				if( settings.active ) showHideSettings();
			}
			
		}
		
		private function showHidePatterns( e:MouseEvent = null ):void{
			
			if( settings.active ) showHideSettings();
			
			panel.buttonPattern.gotoAndStop( !patternLibrary.active + 1 );

			if( !patternLibrary.active ) patternLibrary.show();
			else patternLibrary.hide();
			
			
		}
		
		private function showHideSettings( e:MouseEvent = null ):void{
			
			if( patternLibrary.active) showHidePatterns();
			
			panel.buttonSettings.gotoAndStop( !settings.active + 1 );
			
			if( !settings.active ) {
				
				if( startWindow ) removeFirstWindow();
				settings.show();
			}
			else settings.hide();
			
		}
		
		private function removeFirstWindow():void{
			
			startWindow = false;
			settings.move( ( stage.stageWidth - 240 ) >> 1, panel.y - 214);
			settings.title = "Размер поля:";
			
		}

	}
	
}
