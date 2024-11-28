function onCreate()
	stupidList = {'Left', 'Right'}

	makeLuaSprite('back1', 'concurrenceog/Stage', 50, 170);
        setScrollFactor('back1', 0.95, 0.95);
	scaleObject('back1', 1.25, 1.25)         
        addLuaSprite('back1', false);

	makeLuaSprite('slowBack1', 'concurrenceog/slowStage', 50, 170);
        setScrollFactor('slowBack1', 0.95, 0.95);
	scaleObject('slowBack1', 1.25, 1.25)         

	makeAnimatedLuaSprite('Flora', 'concurrenceog/Flora_BG_Assets', 720, 480)
	addAnimationByIndices('Flora', 'danceLeft', 'New', '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16', 24)
	addAnimationByIndices('Flora', 'danceRight', 'New', '17,18,19,20,21,22,23,24,25,26,27,28,29', 24)
	scaleObject('Flora', 0.28, 0.28)
	addLuaSprite('Flora')
	--objectPlayAnimation('Flora', 'Wave')
	
	makeAnimatedLuaSprite('dumCynch', 'characters/CynchOG', getProperty('dad.x'), getProperty('dad.y'))
	scaleObject('dumCynch', 0.7, 0.7)
	setProperty('dumCynch.offset.x', -460)
	setProperty('dumCynch.offset.y', -368)
	addAnimationByPrefix('dumCynch', 'idle', 'Idle Cynch', 24, true)
end

function onCreatePost()
	addCharacterToList('cynch-og-sans', 'dad')
end

function onEvent(n, v1, v2)
	if n == 'turnballs' then
		v1 = v1 or 'false'

		if v1 == 'false' then
			setObjectOrder('Flora', 2)

			setProperty('slowBack1.alpha', 1)
			setBlendMode('back1', 'shader')
			addLuaSprite('slowBack1', false);
			setObjectOrder('slowBack1', 0)
			doTweenAlpha('slowBack1', 'back1', 0, 0.6, 'sineInOut')

			doTweenColor('boyturndark', 'boyfriend', '232323', 0.6, 'sineInOut')
			doTweenColor('gurlturndark', 'gf', '232323', 0.6, 'sineInOut')
			doTweenColor('floorturndark', 'Flora', '232323', 0.6, 'sineInOut')

			triggerEvent('Change Character', 1, 'cynch-og-sans')
			setProperty('dad.alpha', 0)
			addLuaSprite('dumCynch')
			objectPlayAnimation('dumCynch', 'idle')
			doTweenAlpha('dadyalph', 'dad', 1, 0.6, 'sineInOut')
			doTweenAlpha('dadclonealph', 'dumCynch', 0, 0.6, 'sineInOut')
		else
			setObjectOrder('Flora', 3)

			setProperty('back1.alpha', 1)
			setBlendMode('slowBack1', 'shader')
			addLuaSprite('slowBack1', false);
			setObjectOrder('back1', 0)
			doTweenAlpha('back1', 'slowBack1', 0, 0.6, 'sineInOut')

			doTweenColor('boyturndark', 'boyfriend', 'FFFFFF', 0.6, 'sineInOut')
			doTweenColor('gurlturndark', 'gf', 'FFFFFF', 0.6, 'sineInOut')
			doTweenColor('floorturndark', 'Flora', 'FFFFFF', 0.6, 'sineInOut')

			setProperty('dad.alpha', 1)
			addLuaSprite('dumCynch')
			objectPlayAnimation('dumCynch', 'idle')
			doTweenAlpha('dadyalph', 'dad', 0, 0.6, 'sineInOut')
			if v2 == 'true' then
				doTweenAlpha('dadclonealphdead', 'dumCynch', 1, 0.6, 'sineInOut')
			else
				doTweenAlpha('dadclonealph', 'dumCynch', 1, 0.6, 'sineInOut')
			end
		end
	end
end

function onCountdownTick(t)
	objectPlayAnimation('Flora', 'dance'..stupidList[t%2 + 1])
end

function onBeatHit()
	objectPlayAnimation('Flora', 'dance'..stupidList[curBeat%2 + 1])
end

function onTweenCompleted(tag)
	if tag == 'dadclonealph' then
		removeLuaSprite('dumCynch', false)
		--triggerEvent('Change Character', 1, 'cynch')
		setProperty('dad.alpha', 1)
	end
	if tag == 'dadclonealphdead' then
		removeLuaSprite('dumCynch', true)
		triggerEvent('Change Character', 1, 'cynch-og')
		setProperty('dad.alpha', 1)
	end
end