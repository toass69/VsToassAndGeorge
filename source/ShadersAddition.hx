// ============================================================
// Add this to Shaders.hx (same file that already has GlitchEffect / GlitchShader / PulseEffect)
// Ported/hardcoded from BLOCKEDFOREVA.lua's FLAG.frag shader
// ============================================================

class FlagShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float uTime;
		uniform float uSpeed;
		uniform float uFrequency;
		uniform float uWaveAmplitude;

		vec2 sineWave(vec2 pt)
		{
			float x = 0.0;
			float y = 0.0;

			float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
			float offsetY = sin(pt.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / pt.y * pt.x);
			pt.x += offsetX;
			pt.y += offsetY;

			return vec2(pt.x + x, pt.y + y);
		}

		void main()
		{
			vec2 uv = sineWave(openfl_TextureCoordv);
			gl_FragColor = texture2D(bitmap, uv);
		}
	')
	public function new()
	{
		super();
		this.uTime.value = [0];
		this.uSpeed.value = [2];
		this.uFrequency.value = [1];
		this.uWaveAmplitude.value = [1];
	}
}

class FlagEffect
{
	public var shader:FlagShader = new FlagShader();

	public var waveAmplitude(default, set):Float = 1;
	public var waveFrequency(default, set):Float = 1;
	public var waveSpeed(default, set):Float = 2;

	public function new() {}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value[0] = v;
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value[0] = v;
		return v;
	}

	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value[0] = v;
		return v;
	}
}
