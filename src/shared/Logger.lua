local Logger = {}

function Logger.Print(text, active)
	if active then
		print(text)
	end
end

function Logger.Warn(text, active)
	if active then
		warn(text)
	end
end

function Logger.Error(text, active)
	if active then
		error(text)
	end
end

return Logger
