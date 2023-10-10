local omw, interfaces = pcall(require, "openmw.interfaces")

local dataManager = {}
function dataManager.setValue(valueName, value)
    if omw then
        interfaces.CA_DataManager.setValue(valueName, value)
    end
end

function dataManager.getValue(valueName,default)
    if omw then
        local val = interfaces.CA_DataManager.getValue(valueName)
        if not val and default then
            return default
        end
        return interfaces.CA_DataManager.getValue(valueName)
    end
end
function dataManager.getValueOrInt(valueName)
    return dataManager.getValue(valueName,0)
end
function dataManager.getValueOrTable(valueName)
    return dataManager.getValue(valueName,{})
end
return dataManager