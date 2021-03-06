# High Frequency Radar Simulator 
# University of Capetown, Electrical and Engieering Undergraduate Honours Thesis 2018
# Charles Schleich 
# SCHCHA027

using PyPlot

# Helping functions 
rect(x)=(1.0*(abs.(x).<=0.5)); # rect Function 
freq_to_wavelen(f) = (299792458/f)
myWindow(x)= rect(x).*cos.(x*pi).*cos.(x*pi) 

# Triangle Calculations.
# calc 3rd side given s1 s2 and angle
calcSide(s1,s2,a)= ( (s1^2+s2^2) -2*s1*s2*cosd(a) )^0.5

#calc angle given 3 sides.
calcAngle(opposite,adj1,adj2)=acosd((opposite^2-adj1^2-adj2^2)/(-2*adj2*adj1))

 #  _____  _   _  _____  _______ 
 # |_   _|| \ | ||_   _||__   __|
 #   | |  |  \| |  | |     | |   
 #   | |  | . ` |  | |     | |   
 #  _| |_ | |\  | _| |_    | |   
 # |_____||_| \_||_____|   |_|   
                              

function initializeSim(centreF, bandW, sampleRate,pulseT, sW)

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
    global  rangeRes =  c/(2*B)
    global  sWind    = ceil(Int,sW/2)

    global  K = B/T;    # Chirp rate
    # global td = 0.6*T; # Chirp delay
    global td = 0; # Chirp delay



    global v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);
end




function defaultSimParams()
    # Constants 
    global c = 299792458;      # speed of wave through Medium (here its speed of light in air)
    global sf = 2 ;            # distance Scaling Factor
    global r_max = 200E3;      # Maximum range to which to simulate in (meters)
    global t_max = 2*r_max/c;  # Time delay to max range

    # Variables
    # global f0 = 4E6; # Center frequency 
    global f0 = 4E6; # Center frequency 
    global B  = 2E6; # Chirp bandwidth
    global fs = 30E6; # This is the sample rate required for 30MHz.
     # global fs =  300E6; # This is the sample rate required for 30MHz.
    # global fs =  600E6; # This is the sample rate required for 30MHz.
    
    # Dependents
    global dt = 1/fs;  # This is the sample spacing
    global t  = 0:dt:t_max; # define a time vector containing the time values of the samples
    global r  = (c*t/2)/1000 ;  # range vector containing the range values of the samples . 
    
    global T = (100E-6); # Chirp pulse length
    # global T = (10E-6); # Chirp pulse length

    global K  = B/T;    # Chirp rate
    # global td = 0.6*T; #0.6*T; # Chirp delay
    global td = 0; # Chirp delay

    global  r_Blind  =  (T*c)/2
    global  rangeRes =  c/(2*B)
    global  sWind    = 20

    #Creating reference Pulse
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
    # v_baseband = v_analytic.*exp.((-im)*2*pi*f0*t)
    return(v_analytic)
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

    # Matched Filtering
    H = conj(V_TX);
    V_MF  = H.*V_RX;
    v_mf  = ifft(V_MF) 

    scale = r.^sf
    v_mf=v_mf.*(scale)


    return(v_mf)
end


function basebandedIQdata(v_mf) # Distance is in meters
    V_MF = fft(v_mf)
    
    V_ANALYTIC = 2*V_MF
    N = length(V_MF);
    V_ANALYTIC[floor(Int,N/2)+1:Int(N)] = 0;
    v_analytic = ifft(V_ANALYTIC)

    # BaseBanded
    v_baseband = v_analytic.*exp.((-im)*2*pi*f0*t)
    return(v_baseband)
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
        println(angleDept_intRad)
        println("Angle: ", angleDept_intRad ," +-3 degrees")
        xCoord = distA*sind(angleDept_intRad);
        yCoord = distA*cosd(angleDept_intRad);
        println("x: ",xCoord,"\ny: ",yCoord) 
    else
        # use Ext angle
        println("--Angle: ", angleDept_extRad, " +-3 degrees")
        xCoord = distA*sind(90-angleDept_intRad);
        yCoord = distA*cosd(90-angleDept_intRad);
        println("x: ",-xCoord,"\ny: ",yCoord) 
    end

end




function calculateIncommingAngle2(sigA_bb,sigB_bb)

    # Separate baseband and angle waveforms 
    figure()
    plot(sigA_bb)
    plot(sigB_bb)

    # scale = r.^sf
    # sigA_bb_scaled , sigB_bb_scaled = abs.(sigA_bb.*(scale)),abs.(sigB_bb.*(scale))
    # sigA_bb_angle , sigB_bb_angle = angle.(sigA_bb),angle.(sigB_bb)
    # #Find peaks
    # sigA_peaks = findPeaks(sigA_bb_scaled)
    # sigB_peaks = findPeaks(sigB_bb_scaled)


    # # Wavelength at centre Frequency
    # wl = (ceil(Int,freq_to_wavelen(f0)))

    # totalSamples = length(t)

    # # distances to first peak
    # distA = r_max*sigA_peaks[1]/totalSamples
    # distB = r_max*sigB_peaks[1]/totalSamples

    # # Phases 
    # phaseA = findPhases(sigA_bb_angle,sigA_peaks)
    # phaseB = findPhases(sigB_bb_angle,sigB_peaks)

end


function fromDistCalc(dist1,dist2)
    sigA_bb = waveformAtDistance(dist1) 
    sigB_bb = waveformAtDistance(dist2)
    calculateIncommingAngle2(sigA_bb,sigB_bb)
end

 #  ______                        _                           _                      _  _    _                
 # |  ____|                      (_)                   /\    | |                    (_)| |  | |               
 # | |__  ___    ___  _   _  ___  _  _ __    __ _     /  \   | |  __ _   ___   _ __  _ | |_ | |__   _ __ ___  
 # |  __|/ _ \  / __|| | | |/ __|| || '_ \  / _` |   / /\ \  | | / _` | / _ \ | '__|| || __|| '_ \ | '_ ` _ \ 
 # | |  | (_) || (__ | |_| |\__ \| || | | || (_| |  / ____ \ | || (_| || (_) || |   | || |_ | | | || | | | | |
 # |_|   \___/  \___| \__,_||___/|_||_| |_| \__, | /_/    \_\|_| \__, | \___/ |_|   |_| \__||_| |_||_| |_| |_|
 #                                           __/ |                __/ |                                       
 #                                          |___/                |___/                                        


function focusingAlgorithm(txArr,rxArr,rl,ru,al,au)

    numSamples = length(rxArr[1].wf)  
    N_antennas = length(rxArr)  
    firstAntenna = rxArr[1]
    lastAntenna  = rxArr[length(rxArr)]

    centerx = (lastAntenna.ex + firstAntenna.ex)/2
    centery = (lastAntenna.ey + firstAntenna.ey)/2

    println("Centre: ",centerx ," ---- ", centery)

    distBetwAnennas = (freq_to_wavelen(f0))/2;
    
    global RthetaMatrix = [];
    # rangeRes
    # use Range
    for i in rl:10:ru  # Range ROWS
    # for i in 90000:10:100000  # Range ROWS

        if((i-1)%20000==0)
            println( i/2000,"% ");
        end

        intermediate = [];
        # for j in -90:1:90 # Theta     Cols
        # for j in -60:1:60 # Theta     Cols
        for j in al:1:au # Theta     Cols
            # println(j)
            tref = (2*i)/c;  # Calc Every Time
            vfoc = 0;

            for n in 1:N_antennas

                exn=rxArr[n].ex
                eyn=rxArr[n].ey

                a2rp = dist2(exn,eyn,centerx,centery); # dist Antenna to ref point

                if n>(N_antennas/2)
                    a2rp=a2rp*(-1)
                end

                r_Antenna_focalpoint = calcSide(a2rp ,i, 90+j)
       
                tdAnt = (i + r_Antenna_focalpoint)/c
                tindex = tdAnt / t_max;

                if tindex>1 
                    vfoc = vfoc + 0;
                else
                    upperIndex = ceil(Int, numSamples* tindex );
                    lowerIndex = floor(Int, numSamples* tindex );

                    if j>0
                        UpperSample = (rxArr[n].wf)[upperIndex]*exp(im*2*pi*f0*(tdAnt-tref));
                    else 
                        UpperSample = (rxArr[n].wf)[upperIndex]*exp(im*2*pi*f0*(tdAnt-tref));
                    end

                    vfoc = vfoc + UpperSample;

                end

            end # End antennas
            
            push!(intermediate,vfoc) ;

        end # End Cols
        
        push!(RthetaMatrix,intermediate);
    end
     println("End");

    global glRTM = RthetaMatrix;

    rtMatrix=hcat(RthetaMatrix...)'

    println("show")
    global imgArrRTheta = abs.(rtMatrix);

    figure();
    imshow(imgArrRTheta);
    title("R-Theta Matrix");
    tight_layout();  


    return(rtMatrix);
end # End function

 #                    _           _____                                
 #                   | |         |_   _|                               
 #  _ __ ___    __ _ | | __ ___    | |   _ __ ___    __ _   __ _   ___ 
 # | '_ ` _ \  / _` || |/ // _ \   | |  | '_ ` _ \  / _` | / _` | / _ \
 # | | | | | || (_| ||   <|  __/  _| |_ | | | | | || (_| || (_| ||  __/
 # |_| |_| |_| \__,_||_|\_\\___| |_____||_| |_| |_| \__,_| \__, | \___|
 #                                                         __/ |      
 #                                                        |___/       
###############################


dist(x,y) = sqrt( (x-(x_Res/2))^2 + (y-y_Res)^2 )
calcangle(x,y)= atand(y/x)


function focusImaging(rtheta) # Matrix
    (rNum,aNum) = size(rtheta)
    global x_Res=1000
    global y_Res=1000

    maxrange=1000
    a_jumps= ceil(Int,aNum/2) 

    imageData = []
    for y in 1:y_Res
        rowData = [];
        for x in 1:x_Res
            foc=0

            if(x==(x_Res/2) && y == (y_Res))
                theta = 90;
            else
                theta = calcangle(x-(x_Res/2),(y_Res)-y);
            end

            range_= (dist2(x,y,(x_Res/2),y_Res));

            if 1 <= range_ <= maxrange && ( -90 < theta < -30 || 30 < theta <=90 )
                range_ = rNum*range_/maxrange

                if (theta<0) # Negative Degrees i.e. First half of angle bins.
                    newtheta = -theta - 90; # convert from -30 -> -90 to -60 -> 0
                    newNewtheta = newtheta + a_jumps; # length of subArray      

                    topTheta , bottomTheta = ceil(Int,newNewtheta) , floor(Int,newNewtheta);
                    topR , bottomR  = ceil(Int,range_) , floor(Int,range_);
                    # println("a: ",y," " ,x, " ",theta," ", topTheta ," ", bottomTheta," ", topR ," ", bottomR) 

                    foc1 = rtheta[topR,topTheta];
                    foc2 = rtheta[topR,bottomTheta];
                    foc3 = rtheta[bottomR,topTheta];
                    foc4 = rtheta[bottomR,bottomTheta];
                    foc  = sum([foc1,foc2,foc3,foc4]);
                
                    # println(foc1," " ,foc2," " ,foc3," " ,foc4)

                else        #Positive Degrees  Second half of angle bings
                    newtheta = -theta + 90; # convert from 90 -> 30 to 0 -> 60
                    newNewtheta = newtheta + a_jumps; 

                    topTheta , bottomTheta = ceil(Int,newNewtheta) , floor(Int,newNewtheta);
                    topR , bottomR  = ceil(Int,range_) , floor(Int,range_);
                    # println("b: ",y," " ,x, " ",theta," ", topTheta ," ", bottomTheta," ", topR ," ", bottomR) 

                    foc1 = rtheta[topR,topTheta];
                    foc2 = rtheta[topR,bottomTheta];
                    foc3 = rtheta[bottomR,topTheta];
                    foc4 = rtheta[bottomR,bottomTheta];
                    foc  = sum([foc1,foc2,foc3,foc4]);

                end
            else
                foc=0

            end

            push!(rowData, foc);  
        end # End x loop
    push!(imageData,rowData);  
    end #end y loop

    imageArr = hcat(imageData...)';
    imgArrScene = abs.(imageArr)
    
    println("show")

    figure();
    imshow(imgArrScene);
    tight_layout();    
    println("shown")
    return(imgArrScene)

end #end function



dist2(x1,y1,x2,y2) = sqrt( (x1-x2)^2 + (y1-y2)^2 )

function intersectionImaging(txArr,rxArr)

    numSamples = length(rxArr[1].wf)  
    print("NumSamples ",numSamples)  
    println("--------------------------")
    global x_Res=1000
    global y_Res=1000
    println("Is this changing ? ",x_Res, " ", y_Res)  
    global imageArr= [];
    rangeBins = 200000/x_Res

    txx = txArr[1].ex
    txy = txArr[1].ey

    imageArr = [] 

    global indexesUsed=[]
    for y in 1:y_Res
        rowData = [];
        if (y%100==0)
            println(y/10)            
        end
        for x in 1:x_Res
            curX= rangeBins*x 
            curY= rangeBins*(y_Res-y)
            rangeTx = dist2(curX,curY,txx,txy)
            foc=0;
            for i in rxArr
                rxx= i.ex 
                rxy= i.ey 
                rangeRx = dist2(curX,curY,rxx,rxy)
                twoWayRange = rangeRx + rangeTx

                if twoWayRange>400000
                    foc = foc +0
                else 
                    t_delay_2Way = (twoWayRange)/c
                    tindex = t_delay_2Way/t_max
                    topIndex = ceil(Int,tindex*numSamples)
                    botIndex = floor(Int,tindex*numSamples)
                    # println(botIndex," ", topIndex, " ", sWind )

                    # if botIndex>sWind
                    #     bot =  sum(i.wf[botIndex-sWind:botIndex])
                    # else
                    #     bot = i.wf[botIndex]
                    # end
                    
                    # if topIndex<(numSamples-sWind)
                    #     top =  sum(i.wf[topIndex:topIndex+sWind])
                    # else
                    #     top = i.wf[topIndex]
                    # end

                    # println(x," ",y," ",topIndex," ",numSamples)
                    if (topIndex>=1)
                        top = i.wf[topIndex]
                        focRx = mean([top])
                        foc = foc + focRx
                    else
                        foc = foc+0
                    end 

                    # BLUURR IN RANGE
                end
            end # END RXs
            push!(rowData,foc) 
        end # END X
            push!(imageArr,rowData) 
    end # END Y
    # SHOWIMAGE    

    global imgArr = hcat(imageArr...)';
    println(size(imgArr))
    imgArr = angle.(imgArr)
    # imgArr = abs.(imgArr)
    currentMax = maximum(imgArr);
    (rows,cols) = size(imgArr)

    return(imgArr)
end




function testSinglePointFinder()
    # 45 Degree Example 
    # println("45 Deg \n----------")
    # dist1 = 100026.1667449112 + 100000
    # dist2 = 100026.1667449112 + 99973.50535169283
    # fromDistCalc(dist1,dist2)

    # 45 Degree Example 

    # initializeSim(4E6, 2E6, 300E6,(100E-6), 20);
    defaultSimParams();
    println("45 Deg \n----------")
    dist1 = 100026.50166983239 + 100000
    dist2 = 100026.50166983239 + 99973.50535169283
    fromDistCalc(dist1,dist2)

    # 30 Degree Example working
    # println("\n30 Deg \n----------")
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

function analysis()
    R1 = 100000
    
    A1 = 1/R1^sf;
    td1 = R1/c;# R is the total delay to the target

    #Chirp Signal
    v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);

    V_TX= (fft(v_tx));
    V_RX= (fft(v_rx));
    # Frequency Axes
    N=length(t);
    f_axes = ((fs*2)*(0:N-1)/N);# frequency axis

    # Matched Filtering
    H = conj(V_TX);
    V_MF  = H.*V_RX;
    v_mf  = ifft(V_MF) 

    scale = r.^sf
    # v_mf=v_mf.*(scale)

    # Window function
    V_MF_Window = V_MF.*myWindow((f_axes-f0)/B)
    v_mf_window= ifft(V_MF_Window)

    figure()
    # subplot(2,1,1)
    plot(abs.(v_mf))
    # subplot(2,1,2)
    plot(abs.(v_mf_window))
end

#END FILE