--This is probably gonna be full of math shit--
local tweenService = game:GetService('TweenService')


local module = {}
function module.getBobbing(addition, speed, modifier)
	return math.sin(tick()*addition*speed)*modifier
end

function module.proBobbing(intensity, speed, modifier)
	return intensity * math.sin(tick()*speed*modifier)
end

function module.lerpNumber(a, b, t)
	return a + (b - a) * t
end

function module.tweenVal(tweenTime,valueToTween,newVal,easingStyle)
	local tween = tweenService:Create(valueToTween, TweenInfo.new(tweenTime, easingStyle, Enum.EasingDirection.Out), {Value = newVal})
	tween:Play()
end

--This is for angles only
function module.RandomVector3Angle(vect1: Vector3,vect2: Vector3, numOfDecimals: number)
	local rnd = math.random
	local decimals = 10

	if numOfDecimals and tonumber(numOfDecimals) then
		decimals = decimals^numOfDecimals
		if decimals <= 0 then
			decimals = 10
		end
	end

	vect1 = vect1*decimals
	vect2 = vect2*decimals

	local x = math.rad(rnd(vect1.X,vect2.X))
	local y = math.rad(rnd(vect1.Y,vect2.Y))
	local z = math.rad(rnd(vect1.Z,vect2.Z))

	return Vector3.new(x,y,z)/decimals

end


--This is for regular vector3s so translation only
function module.RandomVector3(vect1: Vector3,vect2: Vector3, numOfDecimals: number)
	local rnd = math.random
	local decimals = 10

	if numOfDecimals and tonumber(numOfDecimals) then
		decimals = decimals^numOfDecimals
		if decimals <= 0 then
			decimals = 10
		end
	end

	vect1 = vect1*decimals
	vect2 = vect2*decimals

	local x = rnd(vect1.X,vect2.X)
	local y = rnd(vect1.Y,vect2.Y)
	local z = rnd(vect1.Z,vect2.Z)

	return Vector3.new(x,y,z)/decimals
end

function module.isPointInsidePart(point, part, additionalPartSize): boolean
	additionalPartSize = additionalPartSize or 0
	local offset = part.CFrame:pointToObjectSpace(point)
	return math.abs(offset.X) <= (part.Size.X + additionalPartSize) / 2
		and math.abs(offset.Y) <= (part.Size.Y + additionalPartSize) / 2
		and math.abs(offset.Z) <= (part.Size.Z + additionalPartSize) / 2
end

function module.FindFirstChildWithPartialString(parentInstance: Instance, partialString: string)
	for i, instance: Instance in next, parentInstance:GetChildren() do
		if instance.Name:match(partialString) == partialString then
			return instance
		else
			return nil
		end
	end
end

function module.GetInstanceWithPartialString(instance: Instance, listToSortThrough)
	for index, val in pairs(listToSortThrough) do
		if instance.Name:match(index) == index then
			return index
		end
	end
	
end
return module
