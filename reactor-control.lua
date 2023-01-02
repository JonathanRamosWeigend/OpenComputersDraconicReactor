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
-- fluxgate controls energy output of reactor
local flux = component.proxy("85bc7a1c-acbe-4210-b129-451c6b2fa655")
-- fluxgate controls energy input to control the field
local flux2 = component.proxy("17fed63d-c209-4233-9bee-98bcbbff7a41")
-- END OF EDIT


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
    if (reactorInfo.status not "running") then goto exit end

    -- shutdown when fuelConversion > 90%
    if (((reactorInfo.fuelConversion / reactorInfo.maxFuelConversion) * 100) > 90) then
       reactor.shutdown()
    end    
   
    print("--- Controlling Energy Output  ------------------------------------------------") 
    energyInPercent = (reactorInfo.energySaturation / reactorInfo.maxEnergySaturation) * 100
    print ("Energy in Percent: ", energyInPercent)
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
    print("--- Controlling Field Strength  -----------------------------------------------") 
    fieldStrengthInPercent = (reactorInfo.fieldStrength / reactorInfo.maxFieldStrength) * 100
    print("Field Strength in Percent: ", fieldStrengthInPercent)
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
 
    ::exit::
    -- Wait until timeout or wait on any key and exit
    e = event.pull(loopFrequencyInSeconds)
    if (e == "key_down") then return end
end

