
# import Images 

# import ImageView 

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


# beam pattern  plot DO IT 


# f(x) = abs.( sin(2*x)/(4*sin(x/2))  )
# t = -2*pi:0.1:2*pi
# vals = map(f,t)



# resolution falls off at the extreme angles due to wider beamwidth therefore less accuracy (info from more sources so it cannot hone in on smaller sources)




# With a higher range resolution the chance of ambiguity associated with closely spaced objects diminishes. 
# This effectively translate to: if there are two point scatterers closely spaced, with a low range resolution the scatterers may add constructively or destructively, in the case of constructively there will appear to the antenna array, a single highly reflective point scatterer. 
# In the case of destructive interference, the reflected waves from the 2 or more point scatterers add out of phase, and so cancel the effects of each other out, and so the radar receives a flat return waveform, i.e. no data indicating presence of a point scatterer.


# http://www.radartutorial.eu/01.basics/Angular%20Resolution.en.html

# Along with range resolution the concept of angular resolution also plays a role into the accuracy of data sampled from a scene. Angular resolution is determined by the width of the beam created by the phased antenna array, as well as the number of jumps in angle.
# The wider the beam created the more information is simultaneously read in about the portion of the scene that is being 'viewed' by the beam, and larger bins are effectively created.
# -------------------------- add from here
# This means that the antenna array is effectively reading data from a number of points and adding them constructively or destructively. In the case of constructive addition, it's possible to only pick up one point target when in the area being viewed, there are more than one point targets, i.e. ships at sea, there could be a number of ships in proximity close enough to eachother for the radar system to only see one ships.
# by the same merit, destructively interference means that depeneding on the positions of the ships, their reflected waveforms could add out of phase and as such, add destructively and not appear on the radar system 

# Depending on the use case, a radar and antenna engineer effectively wants to achieve a certain angular resolution and so it is in the best interest of the engineer to keep the beam width of the main lobe moderately thin with a higher number of smaller anglular jumps. 
# \Illustration Of this \

# Angular Resolution falls off at the extreme angles off \color{red} bore sight\color{black} due to wider beamwidth therefore larger scan area and as such less accuracy


# rpdabs=[]
# a = (1:4:200000)
# for i in a
	  
# 	if((i-1)%4000==0)
#     	println(i-1);
# 	end
# end

# The waveform that comes out of an antenna is unfiltered, and it can be used to get a general sense about a scene, but not derive accurate information for analysis and understanding regarding the scene. 

# in order to use the data of this waveform we must filter and manipulate it such that we can explot certain characteristics about the nature of the echos, and about the setup of antennas to derive proper meaning from the scene. 

# The first stage that 


# A matched filter is used to

# The end goal of the filtering chain is to achieve IQ Data regarding the waveform i.e. data that shows magnitude and phase.

