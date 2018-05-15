# using CSV
# using DataFrames

# type AntennaObject
#     _id::String
#     typ::String 
#     ex::Float64
#     ey::Float64
#     colour::String
#     wf::Array{Complex{Float64},1}
#     wfstage::String
# end

# tar = AntennaObject("id","TAR",1,2,"blue",[],"None")
# rx = AntennaObject("id","RX",3,4,"green",[],"None")
# tx = AntennaObject("id","RX",5,6,"green",[],"None")

# arr = AntennaObject[]
# push!(arr,tar)
# push!(arr,tx)
# push!(arr,rx)
# print(arr)


# idcol=String[]
# typeCol=String[]
# xcol=Float64[]
# ycol=Float64[]
# colourcol=String[]

# for i in arr
# 	push!(idcol,i._id)
# 	push!(typeCol,i.typ)
# 	push!(xcol,i.ex)
# 	push!(ycol,i.ey)
# 	push!(colourcol,i.colour)
# end

# # df = DataFrame(id =idcol,typ=typeCol,ex=xcol,ey=ycol,colour=colourcol)

# fn=string("out.csv")
# dt = CSV.read(fn,types=[String, String, Float64,Float64,String])

# print(df)

# CSV.write("out.csv", df)

# DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
# 4×2 DataFrames.DataFrame
# │ Row │ A │ B │
# ├─────┼───┼───┤
# │ 1   │ 1 │ M │
# │ 2   │ 2 │ F │
# │ 3   │ 3 │ F │
# │ 4   │ 4 │ M │

# using Images

# import Images
# import ImageView
# using QML

using PyPlot

# img = colorview(Gray, rand(120, 120))
# arr1= [1 0.8 0.5; 0.8 0.5 0.3; 0.5 0.3 0.1] 
# arr2= [1 0.8 0.5; 0.8 0.5 0.3; 0.5 0.3 0.1] 
# arr= [[1,0.8,0.5],[0.8,0.5,0.3], [0.5 ,0.3, 0.1]] 



####################################3
####################################3
####################################3
####################################3
####################################3

dist(x,y) = sqrt( (x-500)^2 + (y-1000)^2 )
calcangle(x,y)= atand(y/x)

x_res=1000
y_res=1000


imageArr= []
for y in 1:1000
    rowData = []
    for x in 1:x_res

        theta = calcangle(x-(x_res/2),(y_res)-y);
        range_=(dist(x,y)*20)

        if (range_>20000) ||  ( ( theta < 30) && (theta > -30)) 
            foc=0 # OUT OF RANGE/ANGLE CONDITION
        else
            # println(x," ",y," ",theta)
            if (theta<0)
                foc=0.8
            else
                if theta < 31
                foc=1
                else
                foc=0.1                
                end
            end
        end


        push!(rowData, foc)

    end
    push!(imageArr,rowData)
end

imshow(imageArr)


####################################3
####################################3
####################################3
####################################3
####################################3
    # currentMax = 0;
    # for i in 1:length(imageArr)
    #     imageArr[i]= abs.(imageArr[i]);
    #     currentMax = maximum(imageArr[i]);
    # end

    # for i in 1:length(imageArr)
    #     imageArr[i] = (imageArr[i])/currentMax;
    # end

    # # for i in 1:length(imageArr)
    # #      for j in 1:length(imageArr[1])
    # #         if imageArr[i][j]>0
    # #         imageArr[i][j] = 1
    # #         end
    # #     end
    # # end

    # println("show")
    # global imgArr = hcat(imageArr...)';
    # imshow(imgArr);
    # println("shown")



# for y in 1:1000
#     for x in 1:1000
#         println(x,y)
#     end
# end