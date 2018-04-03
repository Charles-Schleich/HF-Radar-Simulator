# simulation of data

# IMPORTS 
include("Funcs.jl")


# DEFINE TYPES 
type AntennaObject
    name::String
    typ::String 
    ex::Float64
    ey::Float64
    colour::String
end

# DEFINE ARRAYS 
txArr = AntennaObject[]
targetArr = AntennaObject[]
rxArr = AntennaObject[]

# DEFINE FUNCTIONS 
# DEFINE FUNCTIONS 
# DEFINE FUNCTIONS 

function coordsToGrid(x,y)
    return (x*5/1000, (1000-(y*5))/1000)
end

function makeRecieveAntennas()
    for i in (1:1:2)
        x,y= coordsToGrid(20*i+20,20)
        name = string("RX Antenna",i)
        temp = AntennaObject(name,"RX",x,y,"blue")  
        push!(rxArr, temp)
    end
end

function calcDist(source::AntennaObject , target::AntennaObject)
    xs, ys = source.ex*1000 , (1000 - source.ey*1000)
    xt, yt = target.ex*1000 , (1000 - target.ey*1000)
    r = ( (xs-xt)^2 + (ys-yt)^2   )^0.5
    return(r)
end

function allDistances(rxArray, targetArray)
    for i in (rxArray)
        for j in (targetArr)
            r = calcDist(i,j)
            println(i.name, " to " , j.name,  " : ", r)
        end
    end
end

# PROGRAM BEGINS 
# PROGRAM BEGINS 
# PROGRAM BEGINS 

println("Enter in x-y coords for a TX Antenna")
println("Enter in x (km) (max 200)")
x= 20#parse(Float64,readline(STDIN))
println("Enter in y (km) (max 200)")
y= 20#parse(Float64,readline(STDIN))

x1,y1= 100,150

x,y = coordsToGrid(x,y)
x1,y1 = coordsToGrid(x1,y1)

#     AntennaObject(   Name    , Type       , x , y )
tx1 = AntennaObject("TX","TX", x,y,"green")
target = AntennaObject("Target","TRGT",x1,y1,"red")

push!(txArr, tx1)
push!(targetArr, target)

makeRecieveAntennas()

txToTarget = calcDist(tx1,target)
println("TX to Target Distance : ", txToTarget);
allElem = [txArr; targetArr;rxArr]
println("Distances are as follows")
allDistances(rxArr,targetArr)

testFunct(20)


#INTERFACING WITH QML
using QML
objectModel= ListModel(allElem)

@qmlapp "thesis_model_qml.qml" objectModel
exec()
