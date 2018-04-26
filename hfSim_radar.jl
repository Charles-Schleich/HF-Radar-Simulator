using PyPlot

close("all")

c = 299792458;    # speed of wave through Medium (here its speed of light in air)
# c = 340;
sf = 2 ; # distance Scaling Factor

# HF waves are 3 MHz to 30 MHz
# chirp 3MHz -> 5MHz 
# Nyquist sampling f >= 2*(highest frequency)

# fs = 441000 ;# This is the sample rate of the sonar.
# fs = 60000000; # This is the sample rate required for 30MHz.
# fs = 60E6; # This is the sample rate required for 30MHz.
fs =  30E6; # This is the sample rate required for 30MHz.
# 125MHz
        
dt = 1/fs;  # This is the sample spacing

r_max = 300E3; # Maximum range to which to simulate in (meters)

# Mega x10^3
# Mega x10^6
# Giga x10^9

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

v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);
# cosWave = cos.( 2*pi*(f0*(t)));


function waveformAtDistance(distance) # Distance is in meters
    # println("Dist ",distance)

    R1 = floor(Int,distance)
    td1 = R1/c;# Two way delay to target.
    A1 = 1/R1^sf;
    #Chirp Signal
    v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);
    # v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);
    #FFT of Chirp
    V_TX= (fft(v_tx));
    V_RX= (fft(v_rx));

    # Frequency Axes
    N=length(t);
    f_axes = ((fs*2)*(0:N-1)/N);# frequency axis

    # Matched Filtering
    H = conj(V_TX);
    V_MF  = H.*V_RX;

    # Window function ????
    # V_MF_Window = V_MF.*myWindow((f_axes-f0)/B)
    # v_mf  = ifft(V_MF)
    # v_mf_window= ifft(V_MF_Window)

    # Analytic Signal 
    V_ANALYTIC = 2*V_MF 
    N = length(V_MF);
    V_ANALYTIC[floor(Int,N/2)+1:Int(N)] = 0;
    v_analytic = ifft(V_ANALYTIC)

    # BaseBanded
    v_baseband = v_analytic.*exp.((-im)*2*pi*f0*t)


    figure("Analytic Signal time Domain")
    title("Analytic Signal time Domain")
    grid("on")
    subplot(2,1,1)
    plot(r,abs.(v_analytic))
    subplot(2,1,2)
    plot(r,abs.(v_baseband))

    # print(v_analytic==abs.(v_baseband))

    # scale = r.^sf
    # v_bb_amp_scaled = abs.(v_baseband.*(scale))
    # v_bb_angle = angle.(v_baseband)

    return(v_baseband)
end


function wavAtDist_AfterMF(distance) # Distance is in meters

    R1 = floor(Int,distance)
    td1 = R1/c;# R is the total delay to the target
    A1 = 1/R1^sf;
    #Chirp Signal
    v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);

    #FFT of Chirp
    V_TX= (fft(v_tx));
    V_RX= (fft(v_rx));

    # Frequency Axes
    N=length(t);
    f_axes = ((fs*2)*(0:N-1)/N);# frequency axis

    # Matched Filtering
    H = conj(V_TX);
    V_MF  = H.*V_RX;
    v_mf  = ifft(V_MF)

    # Window function
    V_MF_Window = V_MF.*myWindow((f_axes-f0)/B)
    v_mf  = ifft(V_MF)
    v_mf_window= ifft(V_MF_Window)


    # figure("Before and after window")
    # title("Before and after window")
    # grid("on")
    # subplot(2,1,1)
    # plot(r,abs.(v_mf))
    # subplot(2,1,2)
    # plot(r,abs.(v_mf_window))

    # figure()
    # title("Angle")
    # grid("on")
    # subplot(2,1,1)
    # plot(r,angle.(v_mf))
    # subplot(2,1,2)
    # plot(r,angle.(v_mf_window))
    

    return(v_mf_window)
end


freq_to_wavelen(f) = (299792458/f)

# figure("Original chirp")
# title("Original chirp ")
# grid("on")
# plot(t,v_tx)


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


# figure("Chirp: after first target")
# title("Chirp: after first target")
# xlabel("Range (km)")
# ylabel("Amplitude")
# grid("on")
# plot(r,v_rx)

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
# figure("FFT of original chirp")
# title("FFT of original chirp")
# grid("on")
# plot(f_axes , abs.(V_TX))

# figure("FFT of chirp at first target")
# title("FFT of chirp at first target")
# grid("on")
# plot(f_axes , abs.(V_RX))

# # Matched Filtering

H = conj(V_TX);

# figure()
# title("Conjugate V_TX")
# grid("on")
# plot(f_axes , abs.(H))

V_MF  = H.*V_RX;

# figure("post Matched Filter in frequency domain")
# title("post Matched Filter in frequency domain")
# grid("on")
# plot(f_axes , abs.(V_MF))
# plot(f_axes , imag(V_MF))

myWindow(x)= rect(x).*cos.(x*pi).*cos.(x*pi) 

V_MF_Window = V_MF.*myWindow((f_axes-f0)/B)
v_mf  = ifft(V_MF)
v_mf_window= ifft(V_MF_Window)


# figure("post Matched Filter in time domain")
# title("post Matched Filter in time domain")
# grid("on")
# plot(t, abs.(v_mf))

# figure("The window function ")
# title("The window function")
# grid("on")
# plot(f_axes,myWindow((f_axes-f0)/B))

# figure("inverse FFT post window ")
# title("inverse FFT post window ")
# grid("on")
# plot(r,real(v_mf))

# figure("Window MF in Frequency")
# title("Window MF in Frequency")
# grid("on")
# plot(abs.(V_MF_Window))

# # figure()
# # title("Window")
# # plot((-1:0.1:1),myWindow(-1:0.1:1))

# figure("Window MF in time")
# title("Window MF in time")
# grid("on")
# plot(r,real(v_mf_window))

# figure("Absolute Window MF in time")
# title("Absolute Window MF in time")
# grid("on")
# plot(r,abs.(v_mf_window))

# Analytic Signal
# Analytic Signal
# Analytic Signal

V_ANALYTIC = 2*V_MF 
N = length(V_MF);
V_ANALYTIC[floor(Int,N/2)+1:Int(N)] = 0;
v_analytic = ifft(V_ANALYTIC)

# figure("Analytic Signal F Domain")
# title("Analytic Signal F Domain")
# grid("on")
# plot(r,abs.(V_ANALYTIC))

# figure("Analytic Signal time Domain")
# title("Analytic Signal time Domain")
# grid("on")
# plot(r,abs.(v_analytic))

# Baseband Translation
# Baseband Translation
# Baseband Translation

v_baseband = v_analytic.*exp.((-im)*2*pi*f0*t)

scale = r.^sf
v_bb_amp_scaled = abs.(v_baseband.*(scale))
v_bb_angle = angle.(v_baseband)

# baseBandProcessor



function findPeaks(wf_abs) # Needs to be take the v_bb_scaled 
    max = maximum(wf_abs)

    ss_pairs =[];
    strt = false
    p1 = 0 
    startStops = []
    bound = 0.8
    for i in 1:length(wf_abs)
        if ((wf_abs[i] > bound*max) && strt==false)
            p1 = i;
            strt = true ;
        end
        if ((wf_abs[i] < bound*max) && strt==true)
            p2 = i ;
            strt =false
            push!(startStops,(p1,p2))
        end
    end

    peaks = []
    for j in startStops
        p1 = j[1]
        p2 = j[2]
        subarr = wf_abs[p1:p2]
        maax=maximum(subarr)
        loc= (findin(subarr,maax))[1]
        push!(peaks,p1+loc)
    end
    return peaks
end


function findPhases(wf_angle,peaks)
    peakPhases = []
    for i in peaks
        push!(peakPhases,(wf_angle[i])) 
    end
    return peakPhases
end

# testExample
# testExample
# testExample


function calculateIncommingAngle(sigA_bb,sigB_bb)
    # Separate baseband and angle waveforms 
    scale = r.^sf
    sigA_bb_scaled , sigB_bb_scaled = abs.(sigA_bb.*(scale)),abs.(sigB_bb.*(scale))
    sigA_bb_angle , sigB_bb_angle = angle.(sigA_bb),angle.(sigB_bb)
    #Find peaks
    sigA_peaks = findPeaks(sigA_bb_scaled)
    sigB_peaks = findPeaks(sigB_bb_scaled)

    # Wavelength at centre Frequency
    wl = (ceil(Int,freq_to_wavelen(f0)))

    totalSamples = length(t)

    # distances to first peak
    distA = r_max*sigA_peaks[1]/totalSamples
    distB = r_max*sigB_peaks[1]/totalSamples

    # Phases 
    phaseA = findPhases(sigA_bb_angle,sigA_peaks)
    phaseB = findPhases(sigB_bb_angle,sigB_peaks)
    
    phaseA_rad = (phaseA[1])
    phaseB_rad = (phaseB[1])

    if phaseA_rad <0
        phaseA_rad = - phaseA_rad 
    end
    # Difference in phase 
    phasediff = phaseB_rad - phaseA_rad

    if (phasediff > (pi))
        phasediff = phasediff-pi
    end
    # Distance between antennas
    d=37.5;

    angleDept_ext = asin.(wl*phasediff/(d*2*pi))
    angleDept_int=pi/2-angleDept_ext

    angleDept_extRad= rad2deg(angleDept_ext)
    angleDept_intRad= rad2deg(angleDept_int)

    # println("DistA: ",distA)
    # println("DistB: ",distB)
    # println("ext angle:",angleDept_extRad)
    # println("int angle:",angleDept_intRad)
    
    if (distA>distB)
        #use Internal Angle 
        println("-- Angle: ", angleDept_intRad ," +-3 degrees")
        xCoord = distA*sind(angleDept_intRad);
        yCoord = distA*cosd(angleDept_intRad);
        println("x: ",xCoord,"\ny: ",yCoord) 
    else
        # use Ext angle
        println("-- Angle: ", angleDept_extRad, " +-3 degrees")
        xCoord = distA*sind(90-angleDept_intRad);
        yCoord = distA*cosd(90-angleDept_intRad);
        println("x: ",-xCoord,"\ny: ",yCoord) 
    end

end


function fromDistCalc(dist1,dist2)
    sigA_bb = waveformAtDistance(dist1) 
    sigB_bb = waveformAtDistance(dist2)
    calculateIncommingAngle(sigA_bb,sigB_bb)
end

# println("\n45 Deg \n----------")
# # 45 Degree Example 
# dist1 = 100026.1667449112 + 100000
# dist2 = 100026.1667449112 + 99973.8404724917
# fromDistCalc(dist1,dist2)

# println("\n30 Deg \n----------")
# # # 30 Degree Example working
# dist1 = 100032.04465064185 + 100000
# dist2 = 100032.04465064185 + 99967.9582
# fromDistCalc(dist1,dist2)

# 15 Degree
# dist1 = 100036.22268931974 + 100E3
# dist2 = 100036.22268931974 + 99963.77825268927

# # 89.98925704127836 Degree
# dist1 = 100000.01406249902 + 100E3
# dist2 = 100000.01406249902 + 100E3

# println("\n-20 Deg \n----------")
# # -20 Degree STILL GOTTA UNDERSTAND
# dist1 = 99987.18045417151 + 100E3
# dist2 = 99987.18045417151 + 100012.8319633283
# fromDistCalc(dist1,dist2)

# println("\n-45 Deg \n----------")
# # -45 Degree
# dist1 = 99973.48701226292 + 100E3
# dist2 = 99973.48701226292 + 100026.52001898746
# fromDistCalc(dist1,dist2)


function rangeProfileFinder(signalArray)
    numSignals = length(signalArray)
    # shifts = ?
?    for i in 10
        addedTotal=0
        for sig in signalArray
            addedTotal = addedTotal + (sig[i])
        end
    end
end


function testXcorr()
    a = abs.(wavAtDist_AfterMF(100E3));
    b = abs.(wavAtDist_AfterMF(200E3));
    c = xcorr(a,b)
    d = xcorr(b,a)

    figure()
    subplot(3,1,1)
    plot(a)
    subplot(3,1,2)
    plot(b)
    subplot(3,1,3)
    plot(c)
    plot(d)
end



