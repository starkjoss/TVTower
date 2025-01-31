-- File: TaskCheckSigns
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_G["TaskCheckSigns"] = class(AITask, function(c)
	AITask.init(c)	-- must init base!
	c.Id = _G["TASK_CHECKSIGNS"]
	c.BudgetWeight = 0
	c.BasePriority = 1
	c.NeededInvestmentBudget = 0
	c.InvestmentPriority = 0

	--no budget to spare
	c.RequiresBudgetHandling = false

	c.terrorLevel = 0
end)

function TaskCheckSigns:typename()
	return "TaskCheckSigns"
end

function TaskCheckSigns:Activate()
	-- Was getan werden soll:
	self.CheckRoomSignsJob = JobCheckRoomSigns()
	self.CheckRoomSignsJob.Task = self
	self.TargetRoom = -1
	--determine target id on every task execution (current floor elevator)
	self.TargetID = TVT:getTargetID("elevatorplan", -1, TVT:getFigureFloor(), 0)

	--self.LogLevel = LOG_TRACE
end

function TaskCheckSigns:GetNextJobInTargetRoom()
	if (self.CheckRoomSignsJob.Status ~= JOB_STATUS_DONE) then
		return self.CheckRoomSignsJob
	end

--	self:SetWait()
	self:SetDone()
end

function TaskCheckSigns:getSituationPriority()
	if self.terrorLevel >= 2 then
		self.SituationPriority = math.max(self.SituationPriority, self.terrorLevel)
	end

	return self.SituationPriority
end

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_G["JobCheckRoomSigns"] = class(AIJob, function(c)
	AIJob.init(c)	-- must init base!
	c.Task = nil
end)

function JobCheckRoomSigns:typename()
	return "JobCheckRoomSigns"
end

function JobCheckRoomSigns:Prepare(pParams)

end

function JobCheckRoomSigns:Tick()
	local scheduleRoomBoardTask = false
	local forceChangeSigns = false
	for index = 0, TVT.ep_GetSignCount() - 1, 1 do
		local response = TVT.ep_GetSignAtIndex(index)
		if response.result == TVT.RESULT_OK then
			local sign = response.data
			if (sign ~= nil and sign.GetOwner() == TVT.ME) then
				--Noch am richtigen Platz?
				if sign.IsAtOriginalPosition() == 0 then
					scheduleRoomBoardTask = true
					self:LogInfo("own room in danger - need to go to the room board")
					break
				end
			end
		end
	end

	--trigger changing enemy room signs
	if scheduleRoomBoardTask == false and self.Task.terrorLevel >=3 then
		if math.random(0,100) > 70 then
			scheduleRoomBoardTask = true
			forceChangeSigns = true
		end
	end

	if scheduleRoomBoardTask == true then
		local t = getPlayer().TaskList[_G["TASK_ROOMBOARD"]]
		if t ~= nil then
			t.SituationPriority = 20
			t.forceChangeSigns = forceChangeSigns
		else
			self:LogError("did not find roomboard task")
		end
	end

	-- handled the situation "for now"
	self.Task.SituationPriority = 0
	self.Task.terrorLevel = 0

	self.Status = JOB_STATUS_DONE
end
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<