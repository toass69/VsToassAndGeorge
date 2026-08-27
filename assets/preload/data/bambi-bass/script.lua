function onCreatePost()
	setProperty('wiggle.scale.y', 0.5)
	setProperty('wiggle.y', -700)
	scaleObject('wiggle', 1.8, 1.8)
	p1pos = getProperty('iconP1.y')
	p2pos = getProperty('iconP2.y')


	for i=0,4,1 do
		setPropertyFromGroup('opponentStrums', i, 'texture', 'NOTE_assets_3D')
	end
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_assets_3D'); --Change texture
		end

		if getPropertyFromGroup('unspawnNotes', i, 'mustPress') and math.random(0, 2) == 1 then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_assets_3D'); --Change texture
		end
	end

end

function onUpdatePost(elapse)

	elapsed = elapsed + elapse
	--elapsed = elapsed + 0.01

	wigHeight = (math.sin(elapsed * 2) / wigWeak + 1.4)
	wigWidth = (math.cos(elapsed * 2) / wigWeak + 1.5)
	wigX = (math.cos(elapsed) * (wigWeak * 90) - 1600)
	dadY = (math.cos(elapsed * 1.8) * 540)

	setProperty('dad.x', dadY + 600)
	setProperty('gf.y', dadY / 4 - 300 + gfOffs)

	setProperty('wiggle.scale.y', wigHeight + 1)
	setProperty('wiggle.scale.x', wigWidth + 1)
	setProperty('wiggle.x', wigX)

	setProperty('wiggle2.scale.y', wigHeight + 1)
	setProperty('wiggle2.scale.x', wigWidth + 1)
	setProperty('wiggle2.x', wigX + 1200)

	setProperty('wiggleBig.scale.y', (wigHeight * 3) + 5)
	setProperty('wiggleBig.scale.x', (wigWidth * 3) + 5)
	setProperty('wiggleBig.x', wigX + 1200)

	if gfTween then
		gfOffs = gfOffs + (elapse * 2300)
		if gfOffs > 0 then
			gfOffs = 0
			gfTween = false
		end
	end

	--setProperty('wiggle.height', getProperty('wiggle.height') + 3)

end

function onUpdate(elapsed)

  if curStep >= 0 then

    songPos = getSongPosition()

    local currentBeat = (songPos/1000)*(bpm/330)

    doTweenY(dadTweenY, 'dad', 0-110*math.sin((currentBeat*0.25)*math.pi),0.001)

  end

end



