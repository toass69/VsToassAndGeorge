function onStartSong() 

setPropertyFromClass('flixel.FlxG','sound.music.volume', 1)

end

function onCreate()
setProperty('skipCountdown',true)
setProperty('gf.visible',false)
end

function onBeatHit()
	if curBeat == 32 then
setProperty('healthBar.visible', true);
setProperty('healthBarBG.visible', true);
setProperty('iconP1.visible', true);
setProperty('iconP2.visible', true);
setProperty('scoreTxt.visible', true);
end

function onStepHit()
	if curStep == 1552 then

makeLuaSprite('black','fade/black',-270, -367)
addLuaSprite('black',false)
setLuaSpriteScrollFactor('black', 1.0, 1.0)
scaleObject('black', 2.7, 2.7);
setObjectCamera('black', 'hud')
end
end
end