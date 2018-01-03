package hxd;

/**
	Base class for a Heaps application.

	This class contains code to set up a typical Heaps app,
	including 3D and 2D scene, input, update and loops.

	It's designed to be a base class for an application entry point,
	and provides several methods for overriding, in which we can plug
	custom code. See API documentation for more information.
**/
class App implements h3d.IDrawable {

	/**
		Rendering engine.
	**/
	public var engine(default,null) : h3d.Engine;

	/**
		Default 3D scene.
	**/
	public var s3d(default,null) : h3d.scene.Scene;

	/**
		Default 2D scene.
	**/
	public var s2d(default,null) : h2d.Scene;

	/**
		Input event listener collection.
		Both 2D and 3D scenes are added to it by default.
	**/
	public var sevents(default,null) : hxd.SceneEvents;

	public var wantedFPS(get, set) : Float;
	var isDisposed : Bool;

	public function new() {
		var engine = h3d.Engine.getCurrent();
		if( engine != null ) {
			this.engine = engine;
			engine.onReady = setup;
			haxe.Timer.delay(setup, 0);
		} else {
			hxd.System.start(function() {
				this.engine = engine = new h3d.Engine();
				engine.onReady = setup;
				engine.init();
			});
		}
	}

	function get_wantedFPS() return hxd.Timer.wantedFPS;
	function set_wantedFPS(fps) return hxd.Timer.wantedFPS = fps;

	/**
		Screen resize callback.

		By default does nothing. Override this method to provide custom on-resize logic.
	**/
	@:dox(show)
	function onResize() {
	}

	public function setScene( scene : hxd.SceneEvents.InteractiveScene, disposePrevious = true ) {
		var new2D = Std.instance(scene, h2d.Scene);
		var new3D = Std.instance(scene, h3d.scene.Scene);
		if( new2D != null )
			sevents.removeScene(s2d);
		if( new3D != null )
			sevents.removeScene(s3d);
		sevents.addScene(scene);
		if( disposePrevious ) {
			if( new2D != null )
				s2d.dispose();
			else if( new3D != null )
				s3d.dispose();
			else
				throw "Can't dispose previous scene";
		}
		if( new2D != null )
			this.s2d = new2D;
		if( new3D != null )
			this.s3d = new3D;
	}

	function setScene2D( s2d : h2d.Scene, disposePrevious = true ) {
		sevents.removeScene(this.s2d);
		sevents.addScene(s2d,0);
		if( disposePrevious )
			this.s2d.dispose();
		this.s2d = s2d;
	}

	public function render(e:h3d.Engine) {
		s3d.render(e);
		s2d.render(e);
	}

	function setup() {
		var initDone = false;
		engine.onReady = staticHandler;
		engine.onResized = function() {
			if( s2d == null ) return; // if disposed
			s2d.checkResize();
			if( initDone ) onResize();
		};
		s3d = new h3d.scene.Scene();
		s2d = new h2d.Scene();
		sevents = new hxd.SceneEvents();
		sevents.addScene(s2d);
		sevents.addScene(s3d);
		loadAssets(function() {
			initDone = true;
			init();
			hxd.Timer.skip();
			mainLoop();
			hxd.System.setLoop(mainLoop);
			hxd.Key.initialize();
		});
	}

	function dispose() {
		engine.onResized = staticHandler;
		engine.onContextLost = staticHandler;
		isDisposed = true;
		s2d.dispose();
		s3d.dispose();
		sevents.dispose();
	}

	/**
		Load assets asynchronously.

		Called during application setup. By default immediately calls `onLoaded`.
		Override this method to provide asynchronous asset loading logic.

		@param onLoaded a callback that should be called by the overriden
		                method when loading is complete
	**/
	@:dox(show)
	function loadAssets( onLoaded ) {
		onLoaded();
	}

	/**
		Initialize application.

		Called during application setup after `loadAssets` completed.
		By default does nothing. Override this method to provide application initialization logic.
	**/
	@:dox(show)
	function init() {
	}

	function mainLoop() {
		hxd.Timer.update();
		sevents.checkEvents();
		if( isDisposed ) return;
		update(hxd.Timer.tmod);
		if( isDisposed ) return;
		s2d.setElapsedTime(Timer.tmod/60);
		s3d.setElapsedTime(Timer.tmod / 60);
		engine.render(this);
	}

	/**
		Update application.

		Called each frame right before rendering.
		First call is done after the application is set up (so `loadAssets` and `init` are called).

		@param dt Time elapsed since last frame, normalized.
	**/
	@:dox(show)
	function update( dt : Float ) {
	}

	static function staticHandler() {}

}