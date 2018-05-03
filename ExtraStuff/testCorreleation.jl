include("hfSim_radar.jl")

# Pkg.add("StatsBase")
using StatsBase
# using GR
using PyPlot

# close("all")

td = 0.0005+T/2; # Chirp delay

sig1 = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);

td1 = 0.001+T/2;
noise = 0.6*randn(length(t))

sig2 = cos.( 2*pi*(f0*(t-td1) + 0.5*K*(t-td1).^2) ).*rect((t-td1)/T);

# subplot(YXN), Y = number of columns, X = number of rows, N = number of axis being created
# r=Array{Float64,1}
s1= [0,0,0,0,1,0.5,0,0]
s2= [0,1,0.5,0,0,0,0,0]
lags= 1:-1:-(length(t)-1)

a = crosscor(sig2,sig1,lags; demean=true)
# b = crosscor(s2, s1; demean=true)

function pythonPlot()
    figure()
    subplot(311)
    title("sig1")
    plot(sig1)
    subplot(312)
    title("sig2")
    plot(sig2)
    subplot(313)
    title("cross Corr")
    plot(a)
end



subplot(3,1,1)
title("sig1")
plot(sig1)
subplot(3,1,2)
title("sig2")
plot(sig2)
subplot(3,1,3)
title("cross Corr")
plot(a)

# figure()
# plot(b)

# 7100784752
# 7100/784/752
# 2224440/9