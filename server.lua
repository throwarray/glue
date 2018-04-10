MODULE.UTILS = UTILS


AddEventHandler('glue:GetExports', function (cb) cb(MODULE) end)