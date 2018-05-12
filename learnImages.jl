using CSV
using DataFrames

type AntennaObject
    _id::String
    typ::String 
    ex::Float64
    ey::Float64
    colour::String
    wf::Array{Complex{Float64},1}
    wfstage::String
end

tar = AntennaObject("id","TAR",1,2,"blue",[],"None")
rx = AntennaObject("id","RX",3,4,"green",[],"None")
tx = AntennaObject("id","RX",5,6,"green",[],"None")

arr = AntennaObject[]
push!(arr,tar)
push!(arr,tx)
push!(arr,rx)
print(arr)


idcol=String[]
typeCol=String[]
xcol=Float64[]
ycol=Float64[]
colourcol=String[]

for i in arr
	push!(idcol,i._id)
	push!(typeCol,i.typ)
	push!(xcol,i.ex)
	push!(ycol,i.ey)
	push!(colourcol,i.colour)
end

# df = DataFrame(id =idcol,typ=typeCol,ex=xcol,ey=ycol,colour=colourcol)

fn=string("out.csv")
dt = CSV.read(fn,types=[String, String, Float64,Float64,String])

print(df)

# CSV.write("out.csv", df)

# DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
# 4×2 DataFrames.DataFrame
# │ Row │ A │ B │
# ├─────┼───┼───┤
# │ 1   │ 1 │ M │
# │ 2   │ 2 │ F │
# │ 3   │ 3 │ F │
# │ 4   │ 4 │ M │
