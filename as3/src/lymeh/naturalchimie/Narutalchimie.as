package lymeh.naturalchimie  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import lymeh.mobile.utils.SM;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.AssetManager;
	
	[SWF(frameRate="60", backgroundColor="#DDDDDD", width="320", height="480")]
	public class Narutalchimie extends Sprite
	{
		private var _starling:Starling;
		
		public function Narutalchimie()
		{
			super();
			
			if (stage) start();
			else addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:flash.events.Event):void
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
			start();
		}
		
		private function start():void
		{
			Starling.multitouchEnabled = false; // for Multitouch Scene
			Starling.handleLostContext = true; // required on Windows, needs more memory
			
			// set general properties
			
			/*Constants.STAGE_HEIGHT = 320;
			Constants.STAGE_WIDTH = 960 * 320/640;;
			*/
			SM.init(SM.ORIENTATION_PORTAIT);
			SM.setViewPort(stage.fullScreenWidth, stage.fullScreenHeight);
			
			var viewPort:Rectangle = new Rectangle(0,0,stage.fullScreenWidth, stage.fullScreenHeight);
			/*var viewPort:Rectangle = RectangleUtil.fit(
				new Rectangle(0, 0, Constants.STAGE_WIDTH, Constants.STAGE_HEIGHT), 
				new Rectangle(0, 0, 960, 640)
			);*/
			
			_starling = new Starling(Main, stage, viewPort);
			_starling.simulateMultitouch = false;
			_starling.enableErrorChecking = Capabilities.isDebugger;
			_starling.start();
			
			_starling.stage.stageWidth  = SM.getStarlingStageWidth();  // <- same size on all devices!
			_starling.stage.stageHeight = SM.getStarlingStageHeight(); // <- same size on all devices!
			
			//_starling.showStatsAt();
			
			// this event is dispatched when stage3D is set up
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
		}
		
		private function onRootCreated(event:starling.events.Event, app:Main):void {
			// set framerate to 30 in software mode
			if (_starling.context.driverInfo.toLowerCase().indexOf("software") != -1)
				_starling.nativeStage.frameRate = 30;
			
			// create the AssetManager, which handles all required assets for this resolution
			var scaleFactor:int = this.stage.stageWidth < 480 ? 1 : 2; // midway between 320 and 640
			var assets:AssetManager = new AssetManager(scaleFactor);
			assets.verbose = Capabilities.isDebugger;
			//assets.enqueue(EmbeddedSounds);
			/*if(1 == scaleFactor) {
				assets.enqueue(EmbeddedAssets1x);
			} else {
				assets.enqueue(EmbeddedAssets2x);
			}*/
			
			// Background
			//var background:Bitmap = scaleFactor == 1 ? new Background() : new BackgroundHD();
			//Background = BackgroundHD = null; // no longer needed!
			
			// background texture is embedded, because we need it right away!
			//var bgTexture:Texture = Texture.fromBitmap(background, false, false, scaleFactor);
			
			// game will first load resources, then start menu
			app.start(assets);
			
			
			/*background.x = viewPort.x;
			background.y = viewPort.y;
			background.width  = viewPort.width;
			background.height = viewPort.height;
			background.smoothing = true;
			addChild(background);*/
			
			// launch Starling
			//viewPort = null;
			/*mStarling = new Starling(Main, stage, viewPort);
			mStarling.stage.stageWidth  = stageWidth;  // <- same size on all devices!
			mStarling.stage.stageHeight = stageHeight; // <- same size on all devices!
			mStarling.simulateMultitouch  = false;
			mStarling.enableErrorChecking = Capabilities.isDebugger;
			mStarling.showStats = false;
			mStarling.showStatsAt("left", "bottom");*/
			
			/*mStarling.addEventListener(starling.events.Event.ROOT_CREATED, 
			function onRootCreated(event:Object, app:Main):void
			{
			mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			removeChild(background);
			
			var bgTexture:Texture = Texture.fromBitmap(background, false, false, scaleFactor);
			
			app.start(bgTexture, assets);
			mStarling.start();
			});*/
		}
	}
}