import h2d.Drawable;
import h2d.Flow;
import h2d.Font;
import h2d.Graphics;
import h2d.Sprite;
import h2d.Text.Align;

class HtmlTextWidget extends Sprite
{
	public var align: Align;
	public var textField: h2d.HtmlText;
	public var back: Graphics;

	public function new(parent:h2d.Scene, font: Font, str:String, align:h2d.Text.Align){
		super(parent);
		this.align = align;
		back = new Graphics(this);

		var tf = new h2d.HtmlText(font, this);
		tf.textColor = 0xffffff;
		tf.textAlign = align;
		tf.text = str;
		textField = tf;

		refreshBounds();
	}

	public function refreshBounds() {
		back.clear();

		var bounds = textField.getBounds(this);
		var size = textField.getSize();

		back.beginFill(0x5050ff,  0.5);
		back.drawRect(bounds.x, 0, size.width, size.height);
		back.endFill();

		back.lineStyle(1, 0x50ff50);
		back.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);

		back.lineStyle(1, 0xff5050);
		back.moveTo(bounds.x, 0);
		back.lineTo(bounds.x + textField.textWidth, 0);
		back.moveTo(bounds.x, 0);
		back.lineTo(bounds.x, textField.textHeight);
	}

	public function setMaxWidth(w:Int) {
		textField.maxWidth = w;
		refreshBounds();
	}
}

class HtmlText extends hxd.App {

	var textWidgets:Array<HtmlTextWidget> = [];
	var resizeWidgets: Array<HtmlTextWidget> = [];

	override function init() {
		
		// Enable global scaling
		// s2d.scale(1.25);

		var font = hxd.res.DefaultFont.get();
		// var font = hxd.Res.customFont.toFont();

		var multilineText = "This is a multiline <font color=\"#FF00FF\">text.<br/>Lorem</font> ipsum dolor";
		var singleText = "Hello simple text";

		var xpos = 0;
		var yoffset = 10.0;

		function createWidget(str:String, align:h2d.Text.Align) {
			var w = new HtmlTextWidget(s2d, font, str, align);
			w.x = xpos;
			w.y = yoffset;
			textWidgets.push(w);
			return w;
		}

		// Static single and multiline widgets
		xpos += 450;
		for (a in [Align.Left, Align.Center, Align.Right, Align.MultilineCenter, Align.MultilineRight]) {
			var w = createWidget("", a);
			var label = new h2d.HtmlText(font, w);
			label.text = Std.string(a);
			label.x = 5;
			label.alpha = 0.5;
			yoffset += w.textField.textHeight + 10;
			var w = createWidget(singleText, a);
			yoffset += w.textField.textHeight + 10;
			var w = createWidget(multilineText, a);
			yoffset += w.textField.textHeight + 10;
		}

		// Resized widgets
		xpos += 200;
		yoffset = 10;
		var longText = "Lorem ipsum dolor sit amet, fabulas repudiare accommodare nec ut.<br />Ut nec facete maiestatis, <font color=\"#FF00FF\">partem debitis eos id</font>, perfecto ocurreret repudiandae cum no.";
		//var longText = "Lorem ipsum dolor sit amet, fabulas repudiare accommodare nec ut.Ut nec facete maiestatis, <font color=\"#FF00FF\">partem debitis eos id</font>, perfecto ocurreret repudiandae cum no.";
		for (a in [Align.Left, Align.Center, Align.Right, Align.MultilineCenter, Align.MultilineRight]) {
			var w = createWidget(longText, a);
			w.setMaxWidth(200);
			resizeWidgets.push(w);
			yoffset += 100;
		}
		
		// Flows
		function createText(parent:Sprite, str : String, align:Align) {
			var tf = new h2d.HtmlText(font, parent);
			tf.textColor = 0xffffff;
			tf.textAlign = align;
			tf.text = str;
			tf.maxWidth = 150;
			return tf;
		}

		function createFlow(parent:Sprite) {
			var flow = new Flow(parent);
			flow.debug = true;
			flow.horizontalSpacing = 5;
			flow.verticalSpacing = 5;
			flow.padding = 5;
			return flow;
		}


		yoffset = 0;
		var flow = createFlow(s2d);
		flow.verticalAlign = FlowAlign.Middle;
		createText(flow, singleText, Align.Left);
		createText(flow, multilineText, Align.Left);

		yoffset += flow.getBounds().height + 10;

		var flow = createFlow(s2d);
		flow.y = yoffset;
		flow.multiline = false;
		flow.verticalAlign = FlowAlign.Middle;
		createText(flow, multilineText, Align.Center);
		createText(flow, multilineText, Align.Right);

		yoffset += flow.getBounds().height + 10;

		var flow = createFlow(s2d);
		flow.y = yoffset;
		flow.verticalAlign = FlowAlign.Middle;
		flow.maxWidth = 150;
		createText(flow, singleText, Align.Left);
		createText(flow, multilineText, Align.Center);

		yoffset += flow.getBounds().height + 10;

		var flow = createFlow(s2d);
		flow.y = yoffset;
		flow.horizontalAlign = FlowAlign.Middle;
		flow.maxWidth = 150;
		flow.isVertical = true;
		createText(flow, singleText, Align.Left);
		createText(flow, multilineText, Align.Right);

		yoffset += flow.getBounds().height + 10;

		{
			var flow = createFlow(s2d);
			flow.y = yoffset;
			flow.horizontalAlign = FlowAlign.Left;
			flow.maxWidth = 360;
			flow.horizontalSpacing = 8;
			flow.isVertical = false;
			var f = createText(flow, "short text", Align.Right);
			createText(flow, singleText, Align.Left);
			yoffset += flow.getBounds().height + 10;
		}


		var flow = createFlow(s2d);
		flow.y = yoffset;
		flow.x = 100;
		flow.horizontalAlign = FlowAlign.Middle;
		flow.isVertical = true;
		{
			var f1 = createFlow(flow);
			createText(f1, multilineText, Align.Left);
			var f2 = createFlow(flow);
			createText(f2, multilineText, Align.Left);
		}

		onResize();
	}


	override function update(dt:Float) {
		for (w in resizeWidgets) {
			w.setMaxWidth(Std.int(300 + Math.sin(haxe.Timer.stamp() * 0.5) * 100.0));
		}
	}

	static function main() {
		hxd.Res.initEmbed();
		new HtmlText();
	}

}