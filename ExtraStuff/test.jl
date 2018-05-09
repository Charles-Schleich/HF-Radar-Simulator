
function test(x)
    global a = x
end

function test2()
    print(a)
end

n = 10
for i in 0:(n-1)
    print(i)
end 

freq_to_wavelen(f) = (299792458/f)
wavelen2Freq(w) = (299792458/w)


# centreFreq
# bandWidth
# sampleF

# noAntenna
# rxAntennaX
# rxAntennaY

# bwStar
# sfStar
# nAStar
# rxStar
# ryStar