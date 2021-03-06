# High Frequency Radar Simulator 
# University of Capetown, Electrical and Engieering Undergraduate Honours Thesis 2018
# Charles Schleich 
# SCHCHA027


# import Images
# import ImageView

using CSV
using QML
# using GR
using DataFrames
# import PyPlot 
using PyPlot

# using Plots
# using PlotLy

type AntennaObject
    _id::String
    typ::String 
    ex::Float64
    ey::Float64
    colour::String
    wf::Array{Complex{Float64},1}
    wfstage::String
end

type fileName 
    filename::String
end

# DEFINE ARRAYS 
txArr = AntennaObject[]
rxArr = AntennaObject[]
targetArr = AntennaObject[]
image_FA =[]
image_IA =[]
xRef=0
yRef=0
distscale = 100
    
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
    target = AntennaObject(id,"TAR",x,y,"blue",[],"None");
    println("Adding Target ", id, "to targetArr");
    push!(targetArr, target);
    updateModel();
end

function addRxAntennas(xCoord::String , yCoord::String, number::String, spacingScale::String)

    
    x = parse(Float64,xCoord)
    y = parse(Float64,yCoord)
    n = parse(Int,number)
    s = parse(Float64,spacingScale)
    
    hwl = s*freq_to_wavelen(f0)/2
 
    #x y is the centre point of the array.
    global xRef = x
    global yRef = y

    totallength = hwl*(n-1);
    xstart = x - totallength/2
    global rxArr = AntennaObject[]
    
    xTxlocation = xstart - hwl

    addSingleTx(x,y)

    for i in 1:(n)
        id = string(length(rxArr))
        x1 = xstart + (hwl*(i-1))
        y1 = y 
        target = AntennaObject(id,"RX",x1,y1,"orange",[],"None")
        push!(rxArr, target)
    end
    updateModel();
end

function addSingleTx(x,y)
    global txArr = AntennaObject[]
    target = AntennaObject("TX","TX",x,y,"green",[],"None")
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
    for i in 1:100
        x=rand(0:200000)
        y=rand(40000:200000)
        id = string("TAR",length(targetArr)) 
        target = AntennaObject(id,"TAR",x,y,"green",[],"None")
        push!(targetArr, target)
    end
    updateModel();
end

function clearTargets()
    global targetArr = AntennaObject[];
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
        
        tempTarget = AntennaObject(id,typ,ex,ey,colour,[],"None")

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


function saveScenario(filename)
    print(filename)

    idcol=String[]
    typeCol=String[]
    xcol=Float64[]
    ycol=Float64[]
    colourcol=String[]

    allElem = AntennaObject[]
    allElem = [txArr; targetArr;rxArr]

    for i in allElem
        push!(idcol,i._id)
        push!(typeCol,i.typ)
        push!(xcol,i.ex)
        push!(ycol,i.ey)
        push!(colourcol,i.colour)
    end
    dataF = DataFrame(id =idcol,typ=typeCol,ex=xcol,ey=ycol,colour=colourcol)

    CSV.write(filename, dataF)
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
    tar1 = AntennaObject("TAR0","TAR", 100 , 300 ,"blue",[],"None")
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

function calcSpacing(centerFreq,scale)
    cf = parse(Int,centerFreq)
    scle = parse(Float64,scale)

    antennaSpacing = round((scle*(299792458/cf))/2,3)

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
        i.wfstage = "RAW"
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

# function showWaveForm(d::JuliaDisplay,w,h)
#     waveform = readdlm("waveForms/RX0.wf")
#     len = length(waveform)

#     # f = figure(figsize=(w/80-0.7,h/80-0.7))
#     # f = figure(figsize=(w/80-0.4,h/80-0.4)) # Fullscreen
#     fsize = (w/100+0.6,h/100+0.8)

#     f = figure(figsize = fsize  )
#     print(fsize )
#     # x = 0:(pi/100):2*pi
#     # plt = plot(x,sin.(x))
#     # plt = plot(t,abs.(fft(waveform)))
#     plt = plot(t,waveform)
#     display(d,f)
#     close(f)
#     return
# end


#  VIEW WAVEFORMS

function showRXWaveform(rxNum)

    # close("all")
    figure("Recieve Antenna Waveform")
    title_ = string("Recieve Antenna ", rxNum+1," Waveform")
    title(title_)
    xlabel("Range")
    ylabel("Amplitude")
    plot(r, rxArr[rxNum+1].wf)
end

function addToPlotRXWaveform(rxNum)
    plot(r,rxArr[rxNum+1].wf)
end


function showAbsRXWaveform(rxNum)
    # close("all")

    figure("Abs of RX")
    title_ = string("Recieve Antenna Waveforms Magnitude Superimposed")
    title(title_)
    xlabel("Range")
    ylabel("Amplitude")
    for rx in (rxArr)
        plot(r, abs.(rx.wf))
    end

end

function viewPhase(rxNum)
    # close("all")

    figure("Phase of RX")
    title_ = string("Recieve Antenna Waveforms Angle Superimposed")
    title(title_)
    xlabel("Range")
    ylabel("Amplitude")
    for rx in (rxArr)
        plot(r, angle.(rx.wf))
    end

end

function clearplot()
    close("all")
end

 #   _____  _____   ______  
 #  / ____||  __ \ |  ____| 
 # | (___  | |__) || |__    
 #  \___ \ |  ___/ |  __|   
 #  ____) || |     | |      
 # |_____/ |_|     |_|      


function checkSinglePoint()
    if(length(targetArr)==1)
        return true
    else
        return false
    end
end

 #  ______                       
 # |  ____|                      
 # | |__  ___    ___  _   _  ___ 
 # |  __|/ _ \  / __|| | | |/ __|
 # | |  | (_) || (__ | |_| |\__ \
 # |_|   \___/  \___| \__,_||___/
                               
                              
function checkBoundsSize(low::String , upp::String )
    println("check: ",low," ",upp)
    lower = parse(Float64,low);
    upper = parse(Float64,upp);
    if lower > upper 
        return false
    else 
        return true
    end
end


function mFilter()
    if (rxArr[1].wfstage == "RAW")
        for i in rxArr
            temp= matchedFilter(i.wf)
            i.wf= temp
            i.wfstage = "MF"
        end
        updateModel();
    end
end


function IQ_bb()
    mFilter();
    if (rxArr[1].wfstage=="MF") 
        for i in rxArr
            temp = basebandedIQdata(i.wf);
            i.wf= temp;
            i.wfstage = "IQ - Baseband";
        updateModel();
        end
    end

end


function processFocusingAlgorithm(ru,rl,au,al)

    if rl==""
        rl=1
    else
        rl=parse(Int64,rl);  
    end
    if ru==""
        ru=200000
    else
        ru=parse(Int,ru);  
    end

    if al==""
        al=-60
    else
        al=parse(Int64,al);
    end
    if au==""
        au=60
    else
        au=parse(Int64,au);
    end

    println("Simulation Bounds")
    println("range :", rl , " to ", ru)
    println("angle :",al , " to ", au)

    # return() 

    if (rxArr[1].wfstage=="None")
        outputRxAntennaWaveforms(rxArr,txArr,targetArr);
    end
    mFilter() # matched filtere the output 
    IQ_bb()   # make baseband IQ data 

    println("Focusing Algorithm")
    rtm = focusingAlgorithm(txArr,rxArr,rl,ru,al,au);

    image = focusImaging(rtm);
    global image_FA = image;


    println("END")
end


function processIntersectionAlgorithm()
    # make post window Match filter figure

    if (rxArr[1].wfstage=="None")
        outputRxAntennaWaveforms(rxArr,txArr,targetArr);
    end
    mFilter() # matched filtere the output 
    IQ_bb()   # make baseband IQ data 

    # SECOND METHOD
    println("Testing at Intersecction Algorithm")
    @time image = intersectionImaging(txArr,rxArr) 
    # global image_IA = image;


end

function viewImageFA()
    if image_FA!=[]
        figure();
        imshow(image_FA);
        tight_layout();
        return(1)
    else
        return(0)
    end
end


function viewImageIA()
    if image_IA!=[]
        figure();
        imshow(image_FA);
        tight_layout();
        return(1)
    else
        return(0)
    end
end

 #  _____  _   _  _____  _______ 
 # |_   _|| \ | ||_   _||__   __|
 #   | |  |  \| |  | |     | |   
 #   | |  | . ` |  | |     | |   
 #  _| |_ | |\  | _| |_    | |   
 # |_____||_| \_||_____|   |_|  
                            
function initParams(cf,bw,sr,pt,sWind)
    cf,bw,sr,pt,sw = parse(Int,cf),parse(Int,bw),parse(Int,sr),parse(Int,pt) , parse(Int,sWind)
    vt=initializeSim(cf,bw,sr,pt,sw);
    return("Params Initialized")
end

function loadDefaults() 
    a =defaultSimParams();
    return("Params Initialized")
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

@qmlfunction targetExists addTarget addRxAntennas getElemNumber emptyArrays readInCSV saveScenario isfile simulate tunnelPrint appendModel checkArrSimulate getFileNames loadDefaults initParams makeRandomTargets calcBlind calcSpacing checkSinglePoint processFocusingAlgorithm mFilter IQ_bb showAbsRXWaveform viewPhase showRXWaveform addToPlotRXWaveform clearplot viewImageFA viewImageIA clearTargets processIntersectionAlgorithm checkBoundsSize

@qmlapp "radar.qml" startModel fileModel recieveModel
exec()
