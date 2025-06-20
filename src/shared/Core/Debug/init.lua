local Debug = {}
Debug.ClassName = "Debug"


function Debug.new(Name: string) -- to create new Debug object
  return setmetatable({
    _name = Name ,
    _logs = {}
  }, Debug)
end

function Debug:IsDebug(value) -- to Check if it is a Debug object
  return type(value) == "table" and value.ClassName == "Debug"
end

function Debug:Log(Message: string) -- to log to a Debug object
  if self._name then 
    local E = `[LOG][{self._name}] {message}`
    table.insert(self._logs , E)
    print(E)
  end
end

function Debug:Warn(Message: string) -- to warn to a Debug object
  if self._name then 
    local E = `[WARN][{self._name}] {message}`
    table.insert(self._logs , E)
    warn(E)
  end
end

function Debug:Error(Message: string) -- to Error to a Debug object
  if self._name then 
    local E = `[ERROR][{self._name}] {message}`
    table.insert(self._logs , E)
    error(E , 2)
  end
end

function Debug:GetLog(Incident: number?) -- to get a single log from a Debug object
  Incident = Incident or 0
  return self._logs[Incident]
end

function Debug:GetLogs() -- get all logs from a Debug object
  return self._logs
end




return Debug