local Bean = {}

Bean.Config = {
  Loader = {
    ClientWaitForServer = true , -- waits till server modules are Inited not FULLY STARTED
    PathSeperator = "/" , -- for module finding
  }

  
}

-- core services all listed here
Bean.Loader = require(script.Loader)
Bean.Debug = require(script.Debug)



return Bean