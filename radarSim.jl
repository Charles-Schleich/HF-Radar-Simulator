#  HF Surface wave simulator
#  Charles Schleich, SCHCHA027
#  University of Capetown undergraduate Thesis 2018

using CSV
using QML
# using GR
using PyPlot # works with JuliaDisplay
# using Plots
# using PlotLy

type AntennaObject
    _id::String
    typ::String 
    ex::Float64
    ey::Float64
    colour::String
    wf::Array{Complex{Float64},1}
    wfCreated::Bool
end

type fileName 
    filename::String
end

type distToTarg
    tar::String
    distance::Float64
end

type rxDist
    rx ::String
    dists ::Array{distToTarg}
end

type txDist
    tx :: String
    dists :: Array{distToTarg}
end

# DEFINE ARRAYS 
txArr = AntennaObject[]
rxArr = AntennaObject[]
targetArr = AntennaObject[]

 #   ____   _      _              _        
 #  / __ \ | |    (_)            | |       
 # | |  | || |__   _   ___   ___ | |_  ___ 
 # | |  | || '_ \ | | / _ \ / __|| __|/ __|
 # | |__| || |_) || ||  __/| (__ | |_ \__ \
 #  \____/ |_.__/ | | \___| \___| \__||___/
 #               _/ |                      
 #              |__/                       

function addTarget(xCoord::String , yCoord::String )
    x = parse(Float64,xCoord);
    y = parse(Float64,yCoord);
    
    id = string("TAR", length(targetArr));
    target = AntennaObject(id,"TAR",x,y,"blue",[],false);
    println("Adding Target ", id, "to targetArr");
    push!(targetArr, target);
    updateModel();
end

function addRxAntennas(xCoord::String , yCoord::String, number::String)
    qwl = freq_to_wavelen(f0)/2
    x = parse(Float64,xCoord)
    y = parse(Float64,yCoord)
    n = parse(Int,number)
    global rxArr = AntennaObject[]
    addSingleTx(x,y)
    for i in 1:(n)
        id = string("RX", length(rxArr))
        x1 = x + (qwl*i)
        y1 = y 
        target = AntennaObject(id,"RX",x1,y1,"orange",[],false)
        push!(rxArr, target)
    end
    updateModel();
end

function addSingleTx(x,y)
    global txArr = AntennaObject[]
    target = AntennaObject("TX","TX",x,y,"green",[],false)
    push!(txArr, target)
    updateModel();
end

function targetExists(xCoord::String ,yCoord::String)
    x = parse(Float64,xCoord)
    y = parse(Float64,yCoord)
    found = false
    allElememnts = [txArr; targetArr;rxArr]
    for i in allElememnts
        if (i.ex == x) && (i.ey == y)
            found=true
            break
        end 
    end
    return found
end

function makeRandomTargets()
    global targetArr = AntennaObject[]
    for i in 1:10
        x=rand(0:200000)
        y=rand(40000:200000)
        id = string("TAR",length(targetArr)) 
        target = AntennaObject(id,"TAR",x,y,"green",[],false)
        push!(targetArr, target)
    end
    updateModel();
end

#   _____   _____ __      __
#  / ____| / ____|\ \    / /
# | |     | (___   \ \  / / 
# | |      \___ \   \ \/ /  
# | |____  ____) |   \  /   
#  \_____||_____/     \/

function readInCSV(fileName::String)
    # emptying Arrays
    emptyArrays()
    fileName=string("scenarios/",fileName)
    dt = CSV.read(fileName,types=[String, String, Float64,Float64,String])
    numRows = size(dt)[1]
    fail=0
    for i in 1:numRows 
        id,typ,ex,ey,colour = dt[1][i] , dt[2][i] , dt[3][i] , dt[4][i] , dt[5][i]
        
        tempTarget = AntennaObject(id,typ,ex,ey,colour,[],false)

        if typ =="TX"
            push!(txArr,tempTarget)
        elseif typ =="RX"
            push!(rxArr,tempTarget)
        elseif typ =="TAR"
            push!(targetArr,tempTarget)
        else
            print("ERROR: type Defined in CSV File is wrong,")
            fail=1
            break
        end 
    end
    if fail==0
        allElem = AntennaObject[]
        allElem = [txArr; targetArr;rxArr]
        objectModel= ListModel(allElem)
        @qmlset qmlcontext().startModel = objectModel
    end 
end

function emptyArrays()
    global txArr = AntennaObject[]
    global rxArr = AntennaObject[]
    global targetArr = AntennaObject[]
    allElem = AntennaObject[]
    allElem = [txArr; targetArr;rxArr]
    objectModel= ListModel(allElem)
    @qmlset qmlcontext().startModel = objectModel
end

function appendModel()
    appendarr = AntennaObject[]
    tar1 = AntennaObject("TAR0","TAR", 100 , 300 ,"blue")
    push!(appendarr ,tar1 )
    tempModel= ListModel(allElem)
    return tempModel
end

function updateModel()
    allElem = AntennaObject[]
    allElem = [txArr; targetArr;rxArr]
    objectModel= ListModel(allElem)
    @qmlset qmlcontext().startModel = objectModel

    rxModel= ListModel(rxArr)
    @qmlset qmlcontext().recieveModel = rxModel

end


#  _____  _____   _____  _______         _   _   _____  ______   _____ 
# |  __ \|_   _| / ____||__   __| /\    | \ | | / ____||  ____| / ____|
# | |  | | | |  | (___     | |   /  \   |  \| || |     | |__   | (___  
# | |  | | | |   \___ \    | |  / /\ \  | . ` || |     |  __|   \___ \ 
# | |__| |_| |_  ____) |   | | / ____ \ | |\  || |____ | |____  ____) |
# |_____/|_____||_____/    |_|/_/    \_\|_| \_| \_____||______||_____/

function calcDist(source::AntennaObject , target::AntennaObject)

    xs, ys = source.ex, (source.ey)
    xt, yt = target.ex, (target.ey)
    r = ( (xs-xt)^2 + (ys-yt)^2 )^0.5

    return(r)
end

function distRxToTargets(rxArr, targetArr)
    for i in (rxArr)
        distTargArr = distToTarg[]
        for j in (targetArr)
            r = calcDist(i,j)
            push!(distTargArr, distToTarg(j._id,r))
            println(i._id, " to " , j._id,  " : ", r)
        end
        push!(rxDistArray,rxDist(i._id,distTargArr))
    end
end

function outputDistances()
    global rxDistArray = rxDist[]
    distRxToTargets(rxArr,targetArr)
end

function getElemNumber(objType::String)
    if objType=="RX"
        return length(rxArr)
    elseif objType=="TAR"
        return length(targetArr)
    end
end


function calcBlind(pulseT)
    pt = parse(Int,pulseT)/(10^6)
    blindR = round(((299792458*pt)/2)/1000,3)
    blindRStr = string("Blind Range: ", blindR, "km")

    return(blindRStr)
end

function calcSpacing(centerFreq)
    cf = parse(Int,centerFreq)
    antennaSpacing = round((299792458/cf)/2,3)

    antennaSpacingStr = string("Antenna Spacing: ", antennaSpacing, "m")

    return(antennaSpacingStr)
end

#   _____  _                    _         _    _               
#  / ____|(_)                  | |       | |  (_)              
# | (___   _  _ __ ___   _   _ | |  __ _ | |_  _   ___   _ ___  
#  \___ \ | || '_ ` _ \ | | | || | / _` || __|| | / _ \ | '_  \ 
#  ____) || || | | | | || |_| || || (_| || |_ | || (_) || | | |
# |_____/ |_||_| |_| |_| \__,_||_| \__,_| \__||_| \___/ |_| |_|

function checkArrSimulate()
    if(length(rxArr)>0 && length(txArr)>0 && length(targetArr)>0)
        return true
    else
        return false
    end
end

function simulate()
    println("one")
    outputRxAntennaWaveforms(rxArr,txArr,targetArr)
end

function outputRxAntennaWaveforms(rxArray::Array{AntennaObject},txArray::Array{AntennaObject}, targetArray::Array{AntennaObject})
    
    transmittAntenna=txArray[1]
    for i in (rxArray)
        summedWaveform = zeros(t)
        for j in (targetArray)
            txToTarg = calcDist(transmittAntenna,j);
            rxToTarg = calcDist(i,j);
            # println(txToTarg+rxToTarg)
            waveform = wavRaw( txToTarg , rxToTarg);
            summedWaveform=summedWaveform+waveform
        end
        i.wf = summedWaveform
        i.wfCreated = true
    end
     updateModel();
end
# SAVE ABS AND ANGLE VALUES IF THAT HELPS MAYBE YES ?

function SimRangeFinder()
    println("---")
    makePostMFWaveforms(rxArr,txArr,targetArr)
end

function makePostMFWaveforms(rxArray::Array{AntennaObject},txArray::Array{AntennaObject}, targetArray::Array{AntennaObject})
    transmittAntenna=txArray[1]
    dispWf=zeros(t)
    for i in (rxArray)
        summedWaveform = zeros(t)
        for j in (targetArray)
            txToTarg = calcDist(transmittAntenna,j);
            rxToTarg = calcDist(i,j);
            waveform = wavAtDist_AfterMF(txToTarg + rxToTarg);
            summedWaveform=summedWaveform+ abs.(waveform)
        end
        i.wf = summedWaveform
        dispWf = dispWf+summedWaveform
    end
    updateModel();
end
# SAVE ABS AND ANGLE VALUES IF THAT HELPS MAYBE YES ?

function tunnelPrint(variable)
    print(variable,"\n")
end

function getFileNames()
    path = "waveForms/"
    key = ".wf"
    filtered = filter(x->contains(x,key), readdir(path))
    fNames = map(fileName, filtered)
    newfileModel = ListModel(fNames)
    @qmlset qmlcontext().fileModel = newfileModel
end

# STILL NOT 100%

function showWaveForm(d::JuliaDisplay,w,h)
    waveform = readdlm("waveForms/RX0.wf")
    len = length(waveform)

    # f = figure(figsize=(w/80-0.7,h/80-0.7))
    # f = figure(figsize=(w/80-0.4,h/80-0.4)) # Fullscreen
    fsize = (w/100+0.6,h/100+0.8)

    f = figure(figsize = fsize  )
    print(fsize )
    # x = 0:(pi/100):2*pi
    # plt = plot(x,sin.(x))
    # plt = plot(t,abs.(fft(waveform)))
    plt = plot(t,waveform)
    display(d,f)
    close(f)
    return
end


#  VIEW WAVEFORMS

function showRXWaveform(rxNum)
    close("all")
    print(rxNum)
    figure("Recieve Antenna Waveform")
    title_ = string("Recieve Antenna", rxNum+1,"Wavform")
    title(title_)
    xlabel("Range")
    ylabel("Amplitude")
    plot(r,rxArr[rxNum+1].wf)
end

function addToPlotRXWaveform(rxNum)
    plot(r,rxArr[rxNum+1].wf)
end


function clearplot()
    close("all")
end




 #  _____  _   _  _____  _______ 
 # |_   _|| \ | ||_   _||__   __|
 #   | |  |  \| |  | |     | |   
 #   | |  | . ` |  | |     | |   
 #  _| |_ | |\  | _| |_    | |   
 # |_____||_| \_||_____|   |_|   
                            
function initParams(cf,bw,sr,pt)
    cf,bw,sr,pt = parse(Int,cf),parse(Int,bw),parse(Int,sr),parse(Int,pt)
    vt=initializeSim(cf,bw,sr,pt);
    return("Params Initialized")
end

function loadDefaults() 
    vt = defaultSimParams();
    return("Success")
end

############################################################################################################
# Program Begins 
# Program Begins 
# Program Begins

include("hfSim_radar.jl");

files = fileName[]
fileModel= ListModel(files)

allElem = AntennaObject[]
allElem = [txArr; targetArr;rxArr]
startModel= ListModel(allElem)
recieveModel = ListModel(rxArr)

@qmlfunction targetExists addTarget outputDistances addRxAntennas getElemNumber emptyArrays readInCSV isfile simulate tunnelPrint appendModel checkArrSimulate getFileNames showWaveForm SimRangeFinder loadDefaults initParams makeRandomTargets calcBlind calcSpacing showRXWaveform addToPlotRXWaveform clearplot
# @qmlfunction loadDefaults initParams
@qmlapp "radar.qml" startModel fileModel recieveModel
exec()

# tar0 = readdlm("waveForms/TAR0.txt")
# tar1 = readdlm("waveForms/TAR1.txt")

# figure();
# title("Chirp: after first target")
# xlabel("time ")
# ylabel("Amplitude")
# grid("on")
# plot(t,tar0)
