using PyPlot

close("all")
f0      = 4;   # Center frequency 
fs      = 100;
dt=1/fs;
t_max   = 10;
t       = 0:dt:t_max;
cwave = cos.( 2*pi*(f0*(t)));

figure();
plot(t,cwave);

cFFT = fftshift(fft(cwave));

N=length(t);
df=fs/N
f_axes = -fs/2+df:df:(fs/2)
# f_axes = fft(t)

# -(N-1)/2 : 1 : (N-1)/2

print(length(f_axes)," ", length(cFFT))
figure()
plot(f_axes,cFFT)
