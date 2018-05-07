
# Helping functions 
rect(x)=(1.0*(abs.(x).<=0.5)); # rect Function 
freq_to_wavelen(f) = (299792458/f)
myWindow(x)= rect(x).*cos.(x*pi).*cos.(x*pi) 

# Triangle Calculations.
# calc 3rd side given s1 s2 and angle
calcSide(s1,s2,a)= ( (s1^2+s2^2)-2*s1*s2*cosd(a) )^0.5

#calc angle given 3 sides.
calcAngle(opposite,adj1,adj2)= acosd((opposite^2-adj1^2-adj2^2)/(-2*adj2*adj1))


 #  _____  _   _  _____  _______ 
 # |_   _|| \ | ||_   _||__   __|
 #   | |  |  \| |  | |     | |   
 #   | |  | . ` |  | |     | |   
 #  _| |_ | |\  | _| |_    | |   
 # |_____||_| \_||_____|   |_|   
                              

function initializeSim(centreF, bandW, sampleRate,pulseT)

    # Constants 
    global c = 299792458;      # speed of wave through Medium (here its speed of light in air)
    global sf = 2 ;            # distance Scaling Factor
    global r_max = 200E3;      # Maximum range to which to simulate in (meters)
    global t_max = 2*r_max/c;  # Time delay to max range

    # Variables
    global f0 = centreF; # Center frequency 
    global B  = bandW; # Chirp bandwidth
    global fs = sampleRate; # This is the sample rate required for 30MHz.


    # Dependents
    global dt = 1/fs;  # This is the sample spacing
    global t = 0:dt:t_max; # define a time vector containing the time values of the samples
    global r = (c*t/2)/1000 ;  # range vector containing the range values of the samples . 
    # divided by 1000 for km

    # global  T = (2E-4); # Chirp pulse length
    # global  T = (5E-5); # Chirp pulse length
    global  T = pulseT/(10^6)
    global  r_Blind =  (T*c)/2

    global  K = B/T;    # Chirp rate
    global td = 0.6*T; # Chirp delay

    global v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);
end


function defaultSimParams()

    # Constants 
    global c = 299792458;      # speed of wave through Medium (here its speed of light in air)
    global sf = 2 ;            # distance Scaling Factor
    global r_max = 200E3;      # Maximum range to which to simulate in (meters)
    global t_max = 2*r_max/c;  # Time delay to max range

    # Variables
    global f0 = 4E6; # Center frequency 
    global B  = 4E6; # Chirp bandwidth
    global fs =  30E6; # This is the sample rate required for 30MHz.

    # Dependents
    global dt = 1/fs;  # This is the sample spacing
    global t = 0:dt:t_max; # define a time vector containing the time values of the samples
    global r = (c*t/2)/1000 ;  # range vector containing the range values of the samples . 
                        # divided by 1000 for km
    
    #Creating Initial Pulse
    # global T = (2E-4); # Chirp pulse length
    global  T = (1E-5); # Chirp pulse length

    global  r_Blind =  (T*c)/2

    global K = B/T;    # Chirp rate
    global td = 0 #0.6*T; # Chirp delay
    global v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);

end


 # __          __  __      __ ______      _____  _____   ______         _______  _____  ____   _   _ 
 # \ \        / //\\ \    / /|  ____|    / ____||  __ \ |  ____|    /\ |__   __||_   _|/ __ \ | \ | |
 #  \ \  /\  / //  \\ \  / / | |__      | |     | |__) || |__      /  \   | |     | | | |  | ||  \| |
 #   \ \/  \/ // /\ \\ \/ /  |  __|     | |     |  _  / |  __|    / /\ \  | |     | | | |  | || . ` |
 #    \  /\  // ____ \\  /   | |____    | |____ | | \ \ | |____  / ____ \ | |    _| |_| |__| || |\  |
 #     \/  \//_/    \_\\/    |______|    \_____||_|  \_\|______|/_/    \_\|_|   |_____|\____/ |_| \_|



# This function creates a waveform that gets processed through a matched  filter
# then gets turned into an analytic signal and pushed down to base band.
function waveformAtDistance(distance) 

    R1 = distance
    td1 = R1/c;# Two way delay to target.
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

    # Analytic Signal 
    V_ANALYTIC = 2*V_MF 
    N = length(V_MF);
    V_ANALYTIC[floor(Int,N/2)+1:Int(N)] = 0;
    v_analytic = ifft(V_ANALYTIC)

    # BaseBanded
    v_baseband = v_analytic.*exp.((-im)*2*pi*f0*t)
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
    return(v_mf_window)
end

# This is made to create chirp waveforms similar to what would be recieved by 
# an RX antenna
function wavRaw(tx_Targ, rx_Targ) 
    R1 = tx_Targ+rx_Targ

    if (tx_Targ > r_Blind) && (rx_Targ > r_Blind) 
        A1 = 1/R1^sf;
    else  
        A1=0;
    end
    
    td1 = R1/c;# R is the total delay to the target

    #Chirp Signal
    v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);
    return(v_rx)
end


function matchedFilter(v_rx) # Distance is in meters

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
    # V_MF_Window = V_MF.*myWindow((f_axes-f0)/B)
    # v_mf_window= ifft(V_MF_Window)

    return(v_mf_window)
end





# This function was used to test whether there was any numeric Difference
# between adding the raw waveforms then matched filtering the summation
# and matched filtering each waveform and adding them post match waveform
# i.e. Matched_Filter(a + b) vs Matched_Filter(a) +  Matched_Filter(b)
function testRaw() 
    a = wavAtDist_AfterMF(150000);
    b = wavAtDist_AfterMF(175000);
    b2= wavAtDist_AfterMF(200000);
    f = a + b + b2

    c = wavRaw(150000);
    d = wavRaw(175000);
    d2 = wavRaw(200000);
    e = matchedFilter(d + c + d2); 

    close("all")
    plot(r, abs.(e))
    plot(r, abs.(f))
    println(f[1])
    println(e[1])
    g=f -e 
    figure()
    plot((g))
end


#  ______  _             _   _____              _         
# |  ____|(_)           | | |  __ \            | |        
# | |__    _  _ __    __| | | |__) |___   __ _ | | __ ___ 
# |  __|  | || '_ \  / _` | |  ___// _ \ / _` || |/ // __|
# | |     | || | | || (_| | | |   |  __/| (_| ||   < \__ \
# |_|     |_||_| |_| \__,_| |_|    \___| \__,_||_|\_\|___/ 


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

 #   _____        _            _                                           _                                           _       
 #  / ____|      | |          (_)                                         (_)                     /\                  | |      
 # | |      __ _ | |  ___      _  _ __    ___  ___   _ __ ___   _ __ ___   _  _ __    __ _       /  \    _ __    __ _ | |  ___ 
 # | |     / _` || | / __|    | || '_ \  / __|/ _ \ | '_ ` _ \ | '_ ` _ \ | || '_ \  / _` |     / /\ \  | '_ \  / _` || | / _ \
 # | |____| (_| || || (__     | || | | || (__| (_) || | | | | || | | | | || || | | || (_| |    / ____ \ | | | || (_| || ||  __/
 #  \_____|\__,_||_| \___|    |_||_| |_| \___|\___/ |_| |_| |_||_| |_| |_||_||_| |_| \__, |   /_/    \_\|_| |_| \__, ||_| \___|
 #                                                                                    __/ |                      __/ |         
 #                                                                                   |___/                      |___/          

function calculateIncommingAngle(sigA_bb,sigB_bb)

    # V_ANALYTIC = 2*V_MF 
    # N = length(V_MF);
    # V_ANALYTIC[floor(Int,N/2)+1:Int(N)] = 0;
    # v_analytic = ifft(V_ANALYTIC)

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
        phasediff = phasediff - pi
    end
    # Distance between antennas
    d=37.5;

    angleDept_ext = asin.(wl*phasediff/(d*2*pi))
    angleDept_int=pi/2-angleDept_ext

    angleDept_extRad= rad2deg(angleDept_ext)
    angleDept_intRad= rad2deg(angleDept_int)

  
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

#  _____                                _____               __  _  _        
# |  __ \                              |  __ \             / _|(_)| |       
# | |__) | __ _  _ __    __ _   ___    | |__) |_ __  ___  | |_  _ | |  ___  
# |  _  / / _` || '_ \  / _` | / _ \   |  ___/| '__|/ _ \ |  _|| || | / _ \ 
# | | \ \| (_| || | | || (_| ||  __/   | |    | |  | (_) || |  | || ||  __/ 
# |_|  \_\\__,_||_| |_| \__, | \___|   |_|    |_|   \___/ |_|  |_||_| \___| 
#                        __/ |                                              
#                       |___/                                               

function rangeProfileFinder(waveMatrix)
    arrlength = length(waveMatrix[1])
    N_antennas = length(waveMatrix)
    endTime = last(t)
    numTSamples = length(t)
    distBetwAnennas= (freq_to_wavelen(f0))/2

    for i in 1:r_max  # Range 
        for j in -60:60 # Theta
            tref = (i + calcSide(i,distBetwAnennas,j))/c;  # Calc Every Time.            
            vfoc = 0;

            for n in 1:N_antennas
                xoffRef = n * distBetwAnennas
                td = calctimeDelay(i, j, xoffRef) # calculates total time delay

                tindex= td / t_max

                indexLocation = round(Int,(tindex/endTime)*(length(t)))

                vfoc = vfoc  + waveMatrix[n,indexLocation]*exp(im*2*pi*f0(td-tref))
            end

        end
    end
end

calctimeDelay(Range, ang, xoffRef) = (Range + calcSide(Range, xoffRef,ang))/c


function gen6AntennaData()

end

# a= [[1,2,3],[4,5,6],[7,8,9]]
# append!(c,[b])


function meeting1()
    wf = waveformAtDistance(150E3)
    figure("")
    title("")
    grid("on")
    plot(r,abs.(wf))
    
    figure("Angle")
    title("Angle")
    grid("on")
    plot(r,angle.(wf))
end

function meeting2()
    # 45 Degree Example 
    println("45 Deg \n----------")
    dist1 = 100026.1667449112 + 100000
    dist2 = 100026.1667449112 + 99973.8404724917
    fromDistCalc(dist1,dist2)

    # println("\n30 Deg \n----------")
    # # 30 Degree Example working
    # dist1 = 100032.04465064185 + 100000
    # dist2 = 100032.04465064185 + 99967.9582
    # fromDistCalc(dist1,dist2)

    # 15 Degree
    # dist1 = 100036.22268931974 + 100E3
    # dist2 = 100036.22268931974 + 99963.77825268927
    # fromDistCalc(dist1,dist2)

    # # 89.98925704127836 Degree
    # dist1 = 100000.01406249902 + 100E3
    # dist2 = 100000.01406249902 + 100E3
    # fromDistCalc(dist1,dist2)

    # # -20 Degree STILL GOTTA UNDERSTAND
    # println("\n-20 Deg \n----------")
    # dist1 = 99987.18045417151 + 100E3
    # dist2 = 99987.18045417151 + 100012.8319633283
    # fromDistCalc(dist1,dist2)

    # # -45 Degree
    # println("\n-45 Deg \n----------")
    # dist1 = 99973.48701226292 + 100E3
    # dist2 = 99973.48701226292 + 100026.52001898746
    # fromDistCalc(dist1,dist2)

end
