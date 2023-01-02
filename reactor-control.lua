--
-- Draconic Reactor Control Program
-- (c) Jonathan Ramos Weigend, 2023 Blumenau, Brasil
--
local component = require("component")
local event = require("event")
local reactor = component.draconic_reactor

-- EDIT THIS
local signalLowFlowIncrease = 100000
local signalLowFlowDecrease = 100000
local energyControlValue = 50
local fieldStrengthControlValue = 50
local maxTemperatureControlValue = 6000
local loopFrequencyInSeconds = 1

-- Set flux gates - Hack for multiple flux_gate components in OpenComputer 1.7
gates = {}
for address, name in pairs(component.list("flux_gate")) do
    gate = component.proxy(address)
    table.insert(gates, 1, gate) 
end
-- Assuming gate 1 == Energy Output, gate 2 = Energy Field Control
local flux = gates[1]
local flux2 = gates[2]


function printRectorInfomation(ri)
    print("--- Reactor Information -------------------------------------------------------") 
    print("  Status:                          ", ri.status)
    print("  Temperature:                     ", ri.temperature)
    print("  --- Field ---") 
    print("   Field Drain Rate:                ", ri.fieldDrainRate)
    print("   Field Strength:                  ", ri.fieldStrength)
    print("   Field Strength Max:              ", ri.maxFieldStrength)
    print("  --- Energy ---") 
    print("   Energy Saturation:               ", ri.energySaturation)
    print("   Energy Saturation Max:           ", ri.maxEnergySaturation)
    print("   Energy Generation Rate:          ", ri.generationRate)
    print("  --- Fuel ---") 
    print("   Fuel Conversion:                 ", ri.fuelConversion)
    print("   Fuel Conversion Rate             ", ri.fuelConversionRate)
    print("   Fuel Conversion Max:             ", ri.maxFuelConversion)
end

local signalLowFlow = flux.getSignalLowFlow()
local signalLowFlowShield = flux2.getSignalLowFlow()

-- Main Loop
while true do
    os.execute("clear")

    reactorInfo = reactor.getReactorInfo()
    printRectorInfomation(reactorInfo)

    -- do not conrol any value during shutdown
    if (not (reactorInfo.status == "running")) then goto exit end

    -- shutdown when fuelConversion > 90%
    if (((reactorInfo.fuelConversion / reactorInfo.maxFuelConversion) * 100) > 90) then
       reactor.stopReactor()
    end    
   
    print("--- Controlling Energy Output  ------------------------------------------------") 
    energyInPercent = (reactorInfo.energySaturation / reactorInfo.maxEnergySaturation) * 100
    print ("Energy in Percent: " .. energyInPercent .. "   (" .. string.sub(flux.address, 1,8) .. "...)")
    temperature = reactorInfo.temperature

    if (energyInPercent < energyControlValue or temperature > maxTemperatureControlValue) then
        if (signalLowFlow > 0) then
            print("[-] Decreasing Signal Low Flow ", signalLowFlow, " with ", signalLowFlowDecrease)
            signalLowFlow = signalLowFlow - signalLowFlowDecrease
        else
            print("[!] Can not further decrease ", signalLowFlow)
        end
    else
        print ("[+] Increasing Signal Low Flow ", signalLowFlow, " with ", signalLowFlowIncrease)
        signalLowFlow = signalLowFlow + signalLowFlowIncrease
    end
    flux.setSignalLowFlow(signalLowFlow)

    ::exit::

    print("--- Controlling Field Strength  -----------------------------------------------") 
    fieldStrengthInPercent = (reactorInfo.fieldStrength / reactorInfo.maxFieldStrength) * 100
    print("Field Strength in Percent: " .. fieldStrengthInPercent .. "   (" .. string.sub(flux2.address, 1,8) .. "...)")
    if (fieldStrengthInPercent < fieldStrengthControlValue) then
        print("[+] Increasing Shield Signal Low Flow ", signalLowFlowShield, " with ", signalLowFlowIncrease)
        signalLowFlowShield = signalLowFlowShield + signalLowFlowIncrease
    else 
        print("[-] Decreasing Shield Signal Low Flow ", signalLowFlowShield, " with ", signalLowFlowDecrease)
        signalLowFlowShield = signalLowFlowShield - signalLowFlowDecrease
    end
    flux2.setSignalLowFlow(signalLowFlowShield)
    
    print("--- Summary  ------------------------------------------------------------------") 
    print("Efficiency in %: ", (signalLowFlow / signalLowFlowShield) * 100)
    print("Efficiency in RF: ", signalLowFlow - signalLowFlowShield);
 
    -- Wait until timeout or wait on any key and exit
    e = event.pull(loopFrequencyInSeconds)
    if (e == "key_down") then return end
end

