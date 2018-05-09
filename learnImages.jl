
import Images 

import ImageView 

# data = [[0.0,0.5,0.0],[0,1,0],[0,0,0]]
# dataMatrix = hcat(data...)'

# img = Images.colorview(Images.Gray, dataMatrix) 

# ImageView.imshow(img)


# for i in 1:10
# 	# println( (i-1)*10+1 ," ",i*10  )
# 	temp = mean(d[ (i-1)*10+1  : i*10])
# 	push!(d_reduced,temp)
# end
# print(d_reduced)

# d = 1:200000

# rpd_reduced = []


# for i in 1:400
# 	# println( (i-1)*500+1 ," ",i*500  )
# 	temp = mean(rpd[ (i-1)*500+1  : i*500])
# 	push!(rpd_reduced,temp)
# end

# rpdabs=[]
a = (1:4:200000)
for i in a
	  
	if((i-1)%4000==0)
    	println(i-1);
	end
end


