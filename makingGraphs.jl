using PyPlot

close("all")

plotThings = true

c = 299792458;    # speed of wave through (here its speed of light in air)
sf = 2 ; # distance Scaling Factor
r_max = 200E3; # Maximum range to which to simulate in (meters)
t_max = 2*r_max/c; # Time delay to max range

f0      = 4E6; # Center frequency 
B       = 4E6; # Chirp bandwidth
fs      = 30E6; # This is the sample rate required for 30MHz.


dt = 1/fs;  # This is the sample spacing
t = 0:dt:t_max; # time vector containing the time values of the samples
r = (c*t/2)/1000 ;  # range vector containing the range values of the samples . 

T = (2E-4); # Chirp pulse length
K = B/T;    # Chirp rate
td = 0.6*T; # Chirp delay

rect(x)=(1.0*(abs.(x).<=0.5)); # rect Function 
myWindow(x)= rect(x).*cos.(x*pi).*cos.(x*pi) 

v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);

# waveScaling(R::Float64, G::Float64, σ::Float64 , λ::Float64) = sqrt( ((G^2)*σ*λ)/( ((4*pi)^3)*R^4)) 

if  false == true 
    figure("Original chirp")
    title("Original chirp ")
    grid("on")
    plot(t,v_tx)
end

# FIRST TARGET
R1 = 100E3; # My range to target (m)
td1 = 2*R1/c;# Two way delay to target.
A1 = 1/R1^sf;
v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T)

if  false == true 
    figure("Chirp: after first target")
    title("Chirp: after first target")
    xlabel("Range (km)")
    ylabel("Amplitude")
    grid("on")
    plot(r,v_rx)
end
# FFT
# FFT
# FFT
# FFT

V_TX= (fft(v_tx));
V_RX= (fft(v_rx));


N=length(t);
f_axes=(-N/2:N/2-1)*fs/(N);


if false ==true   
    figure("FFT of original chirp")
    title("FFT of original chirp")
    grid("on")
    plot(f_axes , abs.(V_TX))

    figure("FFT of chirp at first target")
    title("FFT of chirp at first target")
    grid("on")
    plot(f_axes , abs.(V_RX))
end

# # Matched Filtering

H = conj(V_TX);
V_MF  = H.*V_RX;

if plotThings ==true 
    figure("post Matched Filter in frequency domain")
    title("post Matched Filter in frequency domain")
    grid("on")
    plot(f_axes , abs.( fftshift(V_MF)))

    xlabel("Frequency axes")
end

V_MF_Window = V_MF.*myWindow((f_axes-f0)/B)
v_mf  = ifft(V_MF)
v_mf_window= ifft(V_MF_Window)

# Analytic Signal
# Analytic Signal
# Analytic Signal

V_ANALYTIC = 2*V_MF 
N = length(V_MF);

V_ANALYTIC[Int(floor(N/2))+1:Int(N)] = 0;

v_analytic = ifft(V_ANALYTIC)

if plotThings ==true 
    figure("Analytic Signal F Domain")
    title("Analytic Signal F Domain")
    grid("on")
    plot(r,abs.(fftshift(V_ANALYTIC)))

    figure("Analytic Signal time Domain")
    title("Analytic Signal time Domain")
    grid("on")
    plot(r,abs.(v_analytic))
end

# Baseband Translation
# Baseband Translation
# Baseband Translation

v_baseband = v_analytic.*exp.((-im)*2*pi*f0*t)

if plotThings ==true 
    figure()
    subplot(2,1,1)
    plot(r,abs.(v_baseband))
    subplot(2,1,2)
    plot(r,angle.(v_baseband))
end