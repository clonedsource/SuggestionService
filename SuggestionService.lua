local Service = {}
--//Services//--

--//End of "Services"//--



--//Misc.//--

--//End of "Misc."//--



--//Arrays//--
local SuggestionGroups = {}
--//End of "Arrays"//--



--//Main Functions//--

--//End of "Main Functions"//--



--//Main//--
function Service:NewSuggestionGroup(Name: string)
	local SuggestionGroup = {
		SuggestionBase = {
			
		};
		
	}
	local Added, Removed = Instance.new("BindableEvent"), Instance.new("BindableEvent")
	SuggestionGroup.Added = Added.Event
	SuggestionGroup.Removed = Removed.Event
	
	SuggestionGroup.AddSuggestions = function(...)
		local Formatted = ...
		if not (type(...) == "table") then
			Formatted = {...}

		end
		
		task.desynchronize()
		for _, Value in pairs(Formatted) do
			if Value then
				table.insert(SuggestionGroup.SuggestionBase, Value)
				task.synchronize()
				Added:Fire(Value)
				task.desynchronize()

			end

		end
		task.synchronize()
	end
	
	SuggestionGroup.RemoveSuggestions = function(...)
		local Formatted = ...
		if not (type(...) == "table") then
			Formatted = {...}
			
		end
		task.desynchronize()
		for _, Value in pairs(Formatted) do
			if Value then
				local Index = table.find(SuggestionGroup.SuggestionBase, Value)
				if Index then
					task.synchronize()
					Removed:Fire(Value, Index)
					task.desynchronize()
					
				end
				
			end
			
		end
		task.synchronize()
		gcinfo()
		
	end
	
	SuggestionGroup.Suggest = function(
		Value, MaxSuggestions: number
	)
		local Count = MaxSuggestions or 1
		

		if type(Value) == "userdata" then
			Value = Value.Name
			
		elseif type(Value) == "number" then
			Value = tostring(Value)
			
		end
		
		local returnValues = ((Count > 1) and {}) or nil
		local InMemory = {}
		
		task.desynchronize()
		for _, PossibleSuggestion in pairs(SuggestionGroup.SuggestionBase) do -- Place it in memory.
			if PossibleSuggestion then
				local possibleValue = PossibleSuggestion
				if type(PossibleSuggestion) == "userdata" then
					possibleValue = PossibleSuggestion.Name

				elseif type(PossibleSuggestion) == "number" then
					possibleValue = tostring(PossibleSuggestion)

				end
				
				local len = (possibleValue:match(Value:sub(0, Count)) or ""):len()
				
				if len > 0 then
					table.insert(InMemory, {Length = len, ["Value"] = PossibleSuggestion})
					
				end
				
			end
		end
		table.sort(InMemory, function(A, B) -- Then sort it.
			return A.Length > B.Length
		end)
		task.synchronize()
		
		if type(returnValues) == "table" then
			for N = 1, Count do
				if N > #InMemory then
					break
					
				end
				returnValues[N] = InMemory[N].Value
				
			end
			
		else
			returnValues = InMemory[1].Value
			
		end
		InMemory = nil
		gcinfo()
		
		return returnValues
		
	end
	
	SuggestionGroups[Name] = SuggestionGroup
	return SuggestionGroup
	
end
function Service:GetSuggestionGroup(Name: string)
	local result, grabber = SuggestionGroups[Name], nil
	if not result then
		grabber = coroutine.wrap(function()
			pcall(task.delay, 10, coroutine.close, coroutine.running())
			repeat task.wait(1) until SuggestionGroups[Name]
			
			coroutine.yield(SuggestionGroups[Name])
			
		end)
		
	end
	
	return result, grabber
	
end
--//End of "Main"//--



--//Connections//--
return Service
--//End of "Connections"//--
