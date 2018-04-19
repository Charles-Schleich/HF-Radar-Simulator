
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

# DEFINE FUNCTIONS

function addTarget(xCoord::String , yCoord::String )
    x = parse(Float64,xCoord);
    y = parse(Float64,yCoord);
    
    id = string("TAR", length(targetArr));
    target = AntennaObject(id,"TAR",x,y,"blue");
    println("Adding Target ", id, "to targetArr");
    push!(targetArr, target);
    updateModel();
end


function addRecieveAntenna(xCoord::String , yCoord::String )
    print(xCoord,"  ",yCoord)
    
    x = parse(Float64,xCoord)
    y = parse(Float64,yCoord)
    id = string("RX", length(rxArr))
    target = AntennaObject(id,"RX",x,y,"orange")
    println("Adding Recieve Antenna ", id," to rxArr")
    push!(rxArr, target)
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

# READ IN CSV
# READ IN CSV
# READ IN CSV
function readInCSV(fileName::String)
    # emptying Arrays
    emptyArrays()

    dt = CSV.read(fileName,types=[String, String, Float64,Float64,String])
    numRows = size(dt)[1]
    fail=0
    for i in 1:numRows 
        id,typ,ex,ey,colour = dt[1][i] , dt[2][i] , dt[3][i] , dt[4][i] , dt[5][i]
        
        tempTarget = AntennaObject(id,typ,ex,ey,colour)

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
            waveform = waveformAtDistance( txToTarg + rxToTarg);
            summedWaveform=summedWaveform+waveform
        end
        name = string("waveForms/",i._id,".wf")
        writedlm(name, summedWaveform)
        figure();
        title("waveforms")
        ylabel("Amplitude")
        plot(r,summedWaveform)
    end
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


 #  _______  ______   _____  _______  _____  _   _   _____       _____  ____   _____   ______ 
 # |__   __||  ____| / ____||__   __||_   _|| \ | | / ____|     / ____|/ __ \ |  __ \ |  ____|
 #    | |   | |__   | (___     | |     | |  |  \| || |  __     | |    | |  | || |  | || |__   
 #    | |   |  __|   \___ \    | |     | |  | . ` || | |_ |    | |    | |  | || |  | ||  __|  
 #    | |   | |____  ____) |   | |    _| |_ | |\  || |__| |    | |____| |__| || |__| || |____ 
 #    |_|   |______||_____/    |_|   |_____||_| \_| \_____|     \_____|\____/ |_____/ |______|
                                                                                            

# function findTarget()

#############################################################################################################

# Program Begins 
# Program Begins 
# Program Begins

# tx1 = AntennaObject("TX0","TX", 50,50,"green")
# push!(txArr, tx1)

# rx1 = AntennaObject("RX0","RX", 200,100,"orange")
# push!(rxArr,rx1)
# #                      id  , typ ,  x  ,  y  ,colour
# tar1 = AntennaObject("TAR0","TAR", 200 , 200 ,"blue")
# tar2 = AntennaObject("TAR1","TAR", 250 , 200 ,"blue")
# push!(targetArr,tar1 )
# push!(targetArr,tar2 )

# dt = CSV.read("objects.csv",types=[String, String, Float64,Float64,String])
include("hfSim_radar.jl")

files = fileName[]
fileModel= ListModel(files)

allElem = AntennaObject[]
allElem = [txArr; targetArr;rxArr]
startModel= ListModel(allElem)

@qmlfunction targetExists addTarget outputDistances addRecieveAntenna getElemNumber emptyArrays readInCSV isfile simulate tunnelPrint appendModel checkArrSimulate getFileNames showWaveForm
@qmlapp "radar.qml" startModel fileModel
exec()




# tar0 = readdlm("waveForms/TAR0.txt")
# tar1 = readdlm("waveForms/TAR1.txt")

# figure();
# title("Chirp: after first target")
# xlabel("time ")
# ylabel("Amplitude")
# grid("on")
# plot(t,tar0)
