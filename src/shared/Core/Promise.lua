-- done by chat gpt due to lazyiness

local Promise = {}
Promise.ClassName = "Promise"

function Promise.new(executor)
    local self = setmetatable({
        _state = "Pending" ,  -- "Fulfilled", "Rejected" 
        _value = nil , 
        _successCallbacks = {} ,
        _errorCallbacks = {} , 
        _finallyCallbacks = {}
    }, Promise)

    
    
    
    

    local function resolve(value)
        if self._state ~= "Pending" then return end
        self._state = "Fulfilled"
        self._value = value
        for _, callback in ipairs(self._successCallbacks) do
            task.spawn(callback, value)
        end
        for _, f in ipairs(self._finallyCallbacks) do
            task.spawn(f)
        end
    end

    local function reject(err)
        if self._state ~= "Pending" then return end
        self._state = "Rejected"
        self._value = err
        for _, callback in ipairs(self._errorCallbacks) do
            task.spawn(callback, err)
        end
        for _, f in ipairs(self._finallyCallbacks) do
            task.spawn(f)
        end
    end

    task.spawn(function()
        local ok, result = pcall(executor, resolve, reject)
        if not ok then
            reject(result)
        end
    end)

    return self
end

function Promise:then_(onFulfilled)
    if self._state == "Fulfilled" then
        task.spawn(onFulfilled, self._value)
    else
        table.insert(self._successCallbacks, onFulfilled)
    end
    return self
end

function Promise:catch(onRejected)
    if self._state == "Rejected" then
        task.spawn(onRejected, self._value)
    else
        table.insert(self._errorCallbacks, onRejected)
    end
    return self
end

function Promise:finally(onFinally)
    if self._state ~= "Pending" then
        task.spawn(onFinally)
    else
        table.insert(self._finallyCallbacks, onFinally)
    end
    return self
end

-- Static helpers
function Promise.resolve(value)
    return Promise.new(function(resolve, _)
        resolve(value)
    end)
end

function Promise.reject(err)
    return Promise.new(function(_, reject)
        reject(err)
    end)
end

return Promise