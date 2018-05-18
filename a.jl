
using PyPlot

rect(x)=(1.0*(abs.(x).<=0.5)); # rect Function 
freq_to_wavelen(f) = (299792458/f)
myWindow(x)= rect(x).*cos.(x*pi).*cos.(x*pi) 


function defaultSimParams()

    # Constants 
    global c = 299792458;      # speed of wave through Medium (here its speed of light in air)
    global sf = 2 ;            # distance Scaling Factor
    global r_max = 200E3;      # Maximum range to which to simulate in (meters)
    global t_max = 2*r_max/c;  # Time delay to max range

    # Variables
    global f0 = 4E6; # Center frequency 
    global B  = 2E6; # Chirp bandwidth
    global fs =  30E6; # This is the sample rate required for 30MHz.
    # global fs =  600E6; # This is the sample rate required for 30MHz.
    
    # Dependents
    global dt = 1/fs;  # This is the sample spacing
    global t = 0:dt:t_max; # define a time vector containing the time values of the samples
    global r = (c*t/2)/1000 ;  # range vector containing the range values of the samples . 
    
    # global T = (2E-4); # Chirp pulse length
    # global T = (1E-6); # Chirp pulse length
    global T = (100E-6); # Chirp pulse length
    # global T = (10E-6); # Chirp pulse length

    global K = B/T;    # Chirp rate
    global td = 0.6*T; #0.6*T; # Chirp delay

    global  r_Blind =  (T*c)/2
    global  rangeRes =  c/(2*B)

    #Creating reference Pulse
    global v_tx = cos.( 2*pi*(f0*(t-td) + 0.5*K*(t-td).^2) ).*rect((t-td)/T);

end


function aa()
    close("all")
    defaultSimParams()
    R1 = 100000
    
    A1 = 1/R1^sf;
    td1 = R1/c;# R is the total delay to the target

    #Chirp Signal
    v_rx = A1*cos.( 2*pi*(f0*(t-td-td1) + 0.5*K*(t-td-td1).^2) ).*rect((t-td-td1)/T);
    

    R2 = 150000
    A2 = 1/R2^sf;
    td2 = R2/c;# R is the total delay to the target

    v_rx =v_rx + A2*cos.( 2*pi*(f0*(t-td-td2) + 0.5*K*(t-td-td2).^2) ).*rect((t-td-td2)/T);

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
    v_mf=v_mf.*(scale)

    # Window function
    V_MF_Window = V_MF.*myWindow((f_axes-f0)/B)
    v_mf_window= ifft(V_MF_Window)


    figure("Window")
    plot(myWindow((f_axes-f0)/B))
    # figure("BB2")

    # figure()
    # plot(V_MF_Window)

    V_MF = fft(v_mf)
    V_ANALYTIC = 2*V_MF 
    N = length(V_MF);
    V_ANALYTIC[floor(Int,N/2)+1:Int(N)] = 0;
    v_analytic = ifft(V_ANALYTIC)
    v_baseband = v_analytic.*exp.((-im)*2*pi*f0*t)



    V_ANA2= 2*V_MF_Window
    N = length(V_MF);
    V_ANA2[floor(Int,N/2)+1:Int(N)] = 0;
    v_ana2 = ifft(V_ANA2)
    v_baseband2 = v_ana2.*exp.((-im)*2*pi*f0*t)

    # V_BB  = fftshift(fft(v_baseband))

    figure("BB")
    plot(abs.(v_baseband))
    # figure("BB2")
    plot(abs.(v_baseband2))

    figure("V_MF WINDOW")
    # subplot(2,1,1)
    # plot(abs.(V_MF))
    # subplot(2,1,2)
    # plot(abs.(v_mf_window))
    plot(abs.(V_MF_Window))


end

aa()