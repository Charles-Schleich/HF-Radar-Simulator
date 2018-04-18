using PyPlot

close("all")

# Shame Liz but this is your moment graduating with your peers.

c = 299792458;    # speed of wave through Medium (here its speed of light in air)
# c = 340;

# HF waves are 3 MHz to 30 MHz
# chirp 3MHz -> 5MHz 
# Nyquist sampling f >= 2*(highest frequency)

# fs = 441000 ;# This is the sample rate of the sonar.
# fs =  60000000; # This is the sample rate required for 30MHz.
# fs =  60E6; # This is the sample rate required for 30MHz.
fs =  125E6; # This is the sample rate required for 30MHz.
# 125MHz
        
dt = 1/fs;  # This is the sample spacing

# r_max = 400000; # Maximum range to which to simulate in (meters)
# r_max = 600000; # Maximum range to which to simulate in (meters)
r_max = 300E3; # Maximum range to which to simulate in (meters)

# Mega x10^3
# Mega x10^6
# Giga x10^9

# 2E8 = 200
t_max = 2*r_max/c; # Time delay to max range

t = 0:dt:t_max; # define a time vector containing the time values of the samples

r = (c*t/2)/1000 ;  # range vector containing the range values of the samples . 
                    # divided by 1000 for km

# NOW create the chirp pulse, shifted by an amount td, to start at
# some time td-T/2>0.

# f_start = 3E6 # Lower Bound Frequency 3MHz 
# f_stop  = 5E6 # Upper Bound Frequency 5MHz

f0      = 4E6;   # Center frequency 
B       = 4E6; # Chirp bandwidth

#  mili x10E-3
#  micro x10E-6
#  nano x10E-9
#  pico x10E-12

T = (2E-4); # Chirp pulse length
K = B/T;    # Chirp rate

# The rect(t/T) function spans the interval (-T/2,T/2)
# We must therefore delay the chirp pulse so that it starts after t=0.
# Shift the chirp pulse by 0.6T units to the right, so that it starts at 0.1*T

td = 0.6*T; # Chirp delay
# td = 0.00012; # Chirp delay
# td = 0.0; # Chirp delay

rect(x)=(1.0*(abs.(x).<=0.5)); # rect Function 

# v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);

v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);
cosWave = cos.( 2*pi*(f0*(t)));

# CHIRP FIGURE
# figure()
# title("Chirp")
# xlabel("Time (s)")
# ylabel("Amplitude")
# grid("on")
# plot(t,v_tx)

function waveformAtDistance(distance::Float64)
    R1=floor(Int,distance)
    R1=R1*1000
    td1 = 2*R1/c;# Two way delay to target.
    A1 = 1/R1^2;
    # noise = A1*randn(length(t))
    v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);
    return(v_rx)
end

# waveScaling(R::Float64, G::Float64, σ::Float64 , λ::Float64) = sqrt( ((G^2)*σ*λ)/( ((4*pi)^3)*R^4)) 


figure("Original chirp")
title("Original chirp ")
grid("on")
plot(t,v_tx)


# FIRST TARGET
R1 = 100E3; # My range to target (m)
td1 = 2*R1/c;# Two way delay to target.
A1 = 1/R1^2;
v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T)

# Second TARGET
R2 = 120E3; # My range to target (m)
td2 = 2*R2/c;# Two way delay to target.
A2 = 1/R2^2;
v_rx = v_rx + A2*cos.( 2*pi*(f0*(t-td-td2) + 0.5*K*(t-td-td2).^2) ).*rect((t-td-td2)/T)

# Third TARGET
R3 = 140E3; # My range to target (m)
td3 = 2*R3/c;# Two way delay to target.
A3 = 1/R3^2;
v_rx = v_rx + A3*cos.( 2*pi*(f0*(t-td-td3) + 0.5*K*(t-td-td3).^2) ).*rect((t-td-td3)/T)


figure("Chirp: after first target")
title("Chirp: after first target")
xlabel("Range (km)")
ylabel("Amplitude")
grid("on")
plot(r,v_rx)

# FFT
# FFT
# FFT
# FFT

V_TX= (fft(v_tx));
V_RX= (fft(v_rx));

# Wilkinsons Method
N=length(t);
f_axes = ((fs*2)*(0:N-1)/N);# frequency axis

# To plot FFT on two sided Axes
N=length(t);
df=fs/N;
# f_axes = (-fs/2)+df:df:(fs/2);
# f_axes = (-fs/2)+df/2:df:(fs/2);

#           
figure("FFT of original chirp")
title("FFT of original chirp")
grid("on")
plot(f_axes , abs.(V_TX))

figure("FFT of chirp at first target")
title("FFT of chirp at first target")
grid("on")
plot(f_axes , abs.(V_RX))

# # Matched Filtering

H = conj(V_TX);

# figure()
# title("Conjugate V_TX")
# grid("on")
# plot(f_axes , abs.(H))

V_MF  = H.*V_RX;

figure("post Matched Filter in frequency domain")
title("post Matched Filter in frequency domain")
grid("on")
plot(f_axes , abs.(V_MF))
# plot(f_axes , imag(V_MF))

myWindow(x)= rect(x).*cos.(x*pi).*cos.(x*pi) 

V_MF_Window = V_MF.*myWindow((f_axes-f0)/B)
v_mf  = ifft(V_MF)
v_mf_window= ifft(V_MF_Window)


# figure("post Matched Filter in time domain")
# title("post Matched Filter in time domain")
# grid("on")
# plot(t, abs.(v_mf))

figure("The window function ")
title("The window function")
grid("on")
plot(f_axes,myWindow((f_axes-f0)/B))


figure("inverse FFT post window ")
title("inverse FFT post window ")
grid("on")
plot(r,real(v_mf))

figure("Window MF in Frequency")
title("Window MF in Frequency")
grid("on")
plot(abs.(V_MF_Window))

# # figure()
# # title("Window")
# # plot((-1:0.1:1),myWindow(-1:0.1:1))

figure("Window MF in time")
title("Window MF in time")
grid("on")
plot(r,real(v_mf_window))

figure("Absolute Window MF in time")
title("Absolute Window MF in time")
grid("on")
plot(r,abs.(v_mf_window))

# Analytic Signal
# Analytic Signal
# Analytic Signal

V_ANALYTIC = 2*V_MF 
N = length(V_MF);
V_ANALYTIC[Int(N/2)+1:Int(N)] = 0;
v_analytic = ifft(V_ANALYTIC)

figure("Analytic Signal F Domain")
title("Analytic Signal F Domain")
grid("on")
plot(r,abs.(V_ANALYTIC))

figure("Analytic Signal time Domain")
title("Analytic Signal time Domain")
grid("on")
plot(r,abs.(v_analytic))

# Baseband Translation
# Baseband Translation
# Baseband Translation

v_baseband = v_analytic.*exp((-im)*2*pi*f0*t)

figure()
subplot(2,1,1)
plot(r,abs(v_baseband))
subplot(2,1,2)
plot(r,angle(v_baseband))
