-- local us = minetest.get_us_time()
-- local ns = us
-- local ms = (us / 1000) % 1000
-- local sec = us / 1000 / 1000
-- local s = sec % 60
-- local m = (sec % 3600) / 60
-- local h = (sec % 86400) / 3600

local timer = {}
local timers = {}
local incrementor = 0
local function time()
	return os.clock() * 1000
end

function timer.update()
	for id, timer in pairs(timers) do
		local t = time()
		if t >= timer.next then
			if timer.count == 1 then
				timer["func"]()
				timers[id] = nil
			else
				timer.count = timer.count - 1
				timer.next = t + timer.delay
				timer["func"]()
			end
		end
	end
end

function timer.create(id, delay, func, count)
	local count = count or math.huge
	timers[id] = {
		delay = delay,
		func = func,
		count = count,
		next = delay + time(),
	}
	return id
end

function timer.once(delay, func)
	local id = "timer_" .. incrementor + 1
	timer.create(id, delay, func, 1)
	incrementor = incrementor + 1
	return id
end

function timer.remove(id)
	if timers[id] then
		timers[id] = nil
		return true
	end
	return false
end

function timer.timers()
	return timers
end

return timer
