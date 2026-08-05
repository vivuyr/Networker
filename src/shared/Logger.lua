export type Logger = {
	Print: (text: string, active: boolean) -> (),
	Warn: (text: string, active: boolean) -> (),
	Error: (text: string, active: boolean) -> (),
}
local Logger = {}

function Logger.Print(text: string, active: boolean)
	if active then
		print(text)
	end
end

function Logger.Warn(text: string, active: boolean)
	if active then
		warn(text)
	end
end

function Logger.Error(text: string, active: boolean)
	if active then
		error(text)
	end
end

return Logger :: Logger
