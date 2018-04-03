# using PyPlot

# close("all")

c = 299792458;    # speed of wave through Medium (here its speed of light in air)
# c = 340;

# HF waves are 3 MHz to 30 MHz
# chirp 3MHz -> 5MHz 
# Nyquist sampling f >= 2*(highest frequency)

# fs = 441000 ;# This is the sample rate of the sonar.
# fs =  60000000; # This is the sample rate required for 30MHz.
fs =  60E6; # This is the sample rate required for 30MHz.
# 125MHz
        
dt = 1/fs;  # This is the sample spacing

# r_max = 400000; # Maximum range to which to simulate in (meters)
# r_max = 600000; # Maximum range to which to simulate in (meters)
r_max = 600E3; # Maximum range to which to simulate in (meters)

#r_max= 200km

t_max = 2*r_max/c; # Time delay to max range

t = 0:dt:t_max; # define a time vector containing the time values of the samples

r = (c*t/2)/1000 ;  # range vector containing the range values of the samples . 
                    # divided by 1000 for km

# NOW create the chirp pulse, shifted by an amount td, to start at
# some time td-T/2>0.

f_start = 3E6 # Lower Bound Frequency 3MHz 
f_stop  = 5E6 # Upper Bound Frequency 5MHz

f0      = (f_start+f_stop)/2;   # Center frequency 
B       = f_stop-f_start;       # Chirp bandwidth

T = (2E-4); # Chirp pulse length
K = B/T;    # Chirp rate

# The rect(t/T) function spans the interval (-T/2,T/2)
# We must therefore delay the chirp pulse so that it starts after t=0.
# Shift the chirp pulse by 0.6T units to the right, so that it starts at 0.1*T

# td = 0.6*T; # Chirp delay
# td = 0.00012; # Chirp delay
td = 0.0; # Chirp delay

rect(x)=(1.0*(abs.(x).<=0.5)); # rect Function 

# v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);

v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);

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
    
    noise = A1*randn(length(t))
    v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);

    return(v_rx+noise)
end


# FIRST TARGET
# R1 = 100000; # My range to target.
# td1 = 2*R1/c;# Two way delay to target.
# A1 = 1/R1^2;
# v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);

# plot(t,v_rx)

# figure()
# title("Chirp: after first target")
# xlabel("Range (km)")
# ylabel("Amplitude")
# grid("on")
# plot(r,v_rx)

# FFT
# V_TX= fft(v_tx)
# V_RX= fft(v_rx)


# N=length(t)
# freq = ((fs*2)*(0:N-1)/N)-(fs/2) # frequency axis
# #           
# figure()
# title("FFT of original chirp ")
# grid("on")
# plot(freq , abs.(V_TX))

# figure()
# title("FFT of chirp at first target ")
# grid("on")
# plot(freq , abs.(V_RX))


# # Matched Filtering

# H = conj(V_TX)

# V_MF  = H.*V_RX

# myWindow(x)= rect(x).*cos.(x*pi).*cos.(x*pi) 

# V_MF_Window = V_MF.*myWindow((freq-f0)/B)
# v_mf  = ifft(V_MF)
# v_mf_window= ifft(V_MF_Window)

# figure()
# title("The window function")
# grid("on")
# plot(freq,myWindow((freq-f0)/B))


# figure()
# title("inverse FFT post window ")
# grid("on")
# plot(r,real(v_mf))

# figure()
# title("Window MF in Frequency")
# grid("on")
# plot(abs.(V_MF_Window))

# # figure()
# # title("Window")
# # plot((-1:0.1:1),myWindow(-1:0.1:1))

# figure()
# title("Window MF in time")
# grid("on")
# plot(r,real(v_mf_window))

# figure()
# title("Absolute Window MF in time")
# grid("on")
# plot(r,abs.(v_mf_window))
