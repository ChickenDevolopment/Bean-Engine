local Maid = {} 
Maid.ClassName = "Maid"

function Maid.new()
  return setmetatable({
    _Tasks = {}
  }, Maid)
end






function Maid:Clean()
    for _ , task in self._Tasks do
      if typeof(task) == "RBXScriptConnection" then
        task:Disconnect()
      elseif typeof(task) == "Instance"
        task:Destroy()
      end
    end
end

return Maid