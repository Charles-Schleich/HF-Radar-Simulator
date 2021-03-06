 
 // High Frequency Radar Simulator 
 // University of Capetown, Electrical and Engieering Undergraduate Honours Thesis
 // Charles Schleich 
 // SCHCHA027

import QtQuick 2.7
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    id: appRoot
    title: "High Frequency Radar Simulator"
    visible: true
    // width: 1100
    width: 1300
    height: 700
    
    ListModel {
        id: emptyModel
    }

    // MAP
    // MAP
    // MAP
    RowLayout { // id: rlayout BEGIN
        id: rlayout
        anchors.fill: parent
                spacing: 1
        Rectangle {
            id: layoutMap
            height : 700
            width  : 700
            color  : "white"

            Repeater {// Repeat for each object
                id: repeatPlotter
                anchors.fill: parent
                model: startModel

                    Rectangle {
                        color: colour
                        x: layoutMap.width*ex/200000
                        y: layoutMap.height*(1-ey/200000)
                        width :10
                        height:10

                    }

            } //end Repeater
        } // END VIEW RECTANGLE

    // MENU
    ColumnLayout {
        id: row1
        Rectangle {
            id: rect1
            color : "white"
            border.width : 1
            border.color :  "light grey"
            // height : appRoot.height 
            height: 450
            width : 320
            
            ColumnLayout
            {
/////Simulation Paramaters

            Label { 
                text: "Simulation Parameters"
                font.underline : true
                 }
            
            RowLayout {
                Label { text: "Centre Frequency f0 (Hz) :" }
                TextField {
                    id:centreFreq
                    placeholderText: qsTr("i.e. 400000Hz")
                    validator: IntValidator { bottom: 0; top: 30000000;}
                }
                Label { id:cfStar; color:"red"; text: "" }
            }

            RowLayout {
                Label { text: "Bandwidth B (Hz):                " }
                TextField {
                    id:bandWidth
                    placeholderText: qsTr("i.e. 400000Hz")
                    validator: IntValidator { bottom: 0; top: 30000000;}
                }
                 Label { id:bwStar; color:"red"; text: "" }
            }

            RowLayout {
                Label { text: "Sample rate fs (1/s):            " }
                TextField {
                    id: sampleR
                    placeholderText: qsTr("i.e. 100000 (/s)")
                    // validator: IntValidator { bottom: 0; top: 125000000;}
                    validator: IntValidator { bottom: 0; top: 600000000;}
                }
                 Label { id:sfStar; color:"red"; text: "" }
            }

            RowLayout {
                Label { text: "Pulse Time T (µs) :                " }
                TextField {
                    id: pulseT
                    placeholderText: qsTr("i.e. 200 (µs)  ")
                    validator: IntValidator { bottom: 0; top: 670;}
                }
                 Label { id:ptStar; color:"red"; text: "" }
            }
            
            RowLayout {
                Label { text: "No* Recv Antennas (N):      " }
                TextField {
                    id: noAntenna
                    placeholderText: qsTr(" 2 - 10 ")
                    validator: IntValidator { bottom: 0; top: 100;}
                }
                 Label { id:nAStar; color:"red"; text: "" }
            }

            RowLayout {
                Label { text: "Antenna Spacing Scale:      " }
                TextField {
                    id: antSS
                    placeholderText: qsTr(" 0 -> 150 ")
                    // validator: IntValidator { bottom: 0; top: 150;}
                    // validator: DoubleValidator { bottom: 0; top: 150;}

                }

                 Label { id:aSSStar; color:"red"; text: "" }
            }

            RowLayout {
                Label { text: "Summation Window:            " }
                TextField {
                    id: sWind
                    placeholderText: qsTr(" 1 -> 150 ")
                    validator: IntValidator { bottom: 0; top: 500;}
                }
                 Label { id:sWStar; color:"red"; text: "" }
            }

/////Simulation Paramaters

/////RECIEVE ANTENNAS
            Label { 
                text: "Antenna Array Center Point" 
                font.underline : true
            }

            RowLayout {
                Label { text: "X-Coordinate:" }
                TextField {
                    id: rxAntennaX
                    placeholderText: qsTr("i.e. 100")
                    validator: IntValidator { bottom: 0; top: 200000;}
                }
                 Label { id:rxStar; color:"red"; text: "" }
            }

            RowLayout {
                Label { text: "Y-Coordinate:" }
                TextField {
                    id: rxAntennaY
                    placeholderText: qsTr("i.e. 100")
                    validator: IntValidator { bottom: 0; top: 200000;}
                }
                 Label { id:ryStar; color:"red"; text: "" }
            }
             
            Label { id: instructRec; text: "Note: RX antennas 1->N will be auto placed at\n 1/2 Wavelength intervals around centre point"; color: "blue"}


            RowLayout {
            Button  {
                text: "Confirm Sim Parameters"
                onClicked : {
                    infoSimParams.text = ""
                    var cfCheck = false
                    var bWCheck = false
                    var sFCheck = false
                    var pTCheck = false
                    var nACheck = false
                    var rXCheck = false
                    var rYCheck = false
                    var antsCheck = false
                    var sWindCheck = false

                    if (centreFreq.text==""){cfStar.text="*"}
                    else{cfStar.text=""; cfCheck=true;}

                    if (bandWidth.text==""){bwStar.text="*"}
                    else{bwStar.text=""; bWCheck=true;}

                    if (sampleR.text==""){sfStar.text="*"}
                    else{sfStar.text=""; sFCheck=true;}
                    
                    if (pulseT.text==""){ptStar.text="*"}
                    else{ptStar.text=""; pTCheck=true;}

                    if (noAntenna.text==""){nAStar.text="*"}
                    else{nAStar.text=""; nACheck=true;}                    

                    if (rxAntennaX.text==""){rxStar.text="*"}
                    else{rxStar.text=""; rXCheck=true;}

                    if (rxAntennaY.text==""){ryStar.text="*"}
                    else{ryStar.text=""; rYCheck=true;}
                    
                    if (antSS.text==""){aSSStar.text="*"}
                    else{aSSStar.text=""; antsCheck=true;}
                    
                    if (sWind.text==""){sWStar.text="*"}
                    else{sWStar.text=""; sWindCheck=true;}
                    
                    
                    // ACCEPTED
                    if (cfCheck==true && bWCheck==true && sFCheck==true && nACheck==true && rXCheck==true && rYCheck==true && pTCheck==true && antsCheck && sWindCheck==true) {
                        

                        var br = Julia.calcBlind(pulseT.text);
                        var antSpe = Julia.calcSpacing(centreFreq.text,antSS.text);
                        blindRange.text = br
                        antennaspacing.text = antSpe


                        var a = Julia.initParams(centreFreq.text,bandWidth.text,sampleR.text,pulseT.text,sWind.text)
                        var b = Julia.addRxAntennas(rxAntennaX.text,rxAntennaY.text,noAntenna.text,antSS.text)

                        infoSimParams.text = "Params Initialized"
                        infoSimParams.color = "Green"
                    }
                    else{
                        infoSimParams.text = "Empty Params"
                        infoSimParams.color = "red"
                    }

                }

                }
                Label { id: infoSimParams; text: "" }         
            }

        Button {
            text: "Load Default Parameters"
            onClicked : {
                // infoSimParams.text = a
            // # Variables
                centreFreq.text = 4000000
                bandWidth.text  = 2000000
                sampleR.text    = 30000000
                pulseT.text     = 100
                noAntenna.text  = 15
                rxAntennaX.text = 100000
                rxAntennaY.text = 5000
                antSS.text      = 1
                sWind.text      = 40
                cfStar.text=""
                bwStar.text=""
                sfStar.text=""
                nAStar.text=""
                rxStar.text=""
                ryStar.text=""
                ptStar.text=""
                aSSStar.text=""
                sWStar.text=""


                var br = Julia.calcBlind(pulseT.text);
                var antSpe = Julia.calcSpacing(centreFreq.text,antSS.text);
                blindRange.text = br
                antennaspacing.text = antSpe

                // var a = Julia.initParams(centreFreq.text,bandWidth.text,sampleR.text,pulseT.text)
                var a = Julia.loadDefaults()
                
                var b = Julia.addRxAntennas(rxAntennaX.text,rxAntennaY.text,noAntenna.text,antSS.text)

                infoSimParams.text = a
                infoSimParams.color = "Green"
                        }
            }

            Label { id: blindRange; text: "Blind Range:" }         
            Label { id: antennaspacing; text: "Antenna Spacing:" }         

            } //End ColumnLayout

        } // End rect1



    Rectangle {
        id: rect12
        color : "white"
        height : 250
        width : 320

        ColumnLayout{

            RowLayout{
                Button {
                text: "Simulate Waveforms"
                onClicked : {
                    if(Julia.checkArrSimulate()==false){
                    checkSim.color = "red";
                    checkSim.text = "missing RX/TX/Target"; 
                    }
                    else
                    {
                    checkSim.color = "blue";
                    checkSim.text = "Simulating...";
                    Julia.simulate()
                    checkSim.color = "green";
                    checkSim.text = "Simulated";
                    }

                }

                }
                Label { id: checkSim; text: "" ;}
                
            }
        RowLayout{

        ColumnLayout{
        Label { id: simwaveform; text: "Simulated Waveforms" ;font.underline : true; }
            
        TableView {
                    id : rxTable
                    Layout.preferredWidth :200
                    Layout.maximumWidth : 200

                        TableViewColumn {
                            role: "_id"
                            title: "id"
                            width: 50
                        }

                        TableViewColumn {
                            role: "wfstage"
                            title: "wfstage"
                            width: 100
                        }

                        model: recieveModel
                    }
        }
     // Label { id: rxRow; text: rxTable.currentRow ;}
     ColumnLayout{

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    Button {
                text: " Matched Filter"
                onClicked : {

                    if(Julia.checkArrSimulate()==false){
                    checkSim.color = "red";
                    checkSim.text = "Cannot process: No WF"; 
                    }
                    else
                    {
                    Julia.mFilter()                   
                    }
                    
                    }
            }

    Button {
                text: "mk IQ data"
                onClicked : {

                    if(Julia.checkArrSimulate()==false){
                    checkSim.color = "red";
                    checkSim.text = "Cannot process: No WF"; 
                    }
                    else
                    {
                    Julia.IQ_bb()                   
                    }

                    }
                }


     Button {
                text: "View Waveform"
                onClicked : {

                    if(Julia.checkArrSimulate()==false){
                    checkSim.color = "red";
                    checkSim.text = "Cannot Display: No Rx"; 
                    }
                    else
                    {
                    Julia.showRXWaveform(rxTable.currentRow)                    
                    }

                    }
                }

      Button {
                text: "View Abs WF"
                onClicked : {

                    if(Julia.checkArrSimulate()==false){
                    checkSim.color = "red";
                    checkSim.text = "Cannot Display: No Rx"; 
                    }
                    else
                    {
                    Julia.showAbsRXWaveform(rxTable.currentRow)                    
                    }

                    }
                }

     Button {
                text: "View Phase "
                onClicked : {

                     if(Julia.checkArrSimulate()==false){
                    checkSim.color = "red";
                    checkSim.text = "Cannot Display: No Rx"; 
                    }
                    else
                    {
                    Julia.viewPhase(rxTable.currentRow)
                    }
                }
            }

     Button {
            text: "Close view "
            onClicked : {
                Julia.clearplot()
                }
            }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }

        }

        }// EnD COL LAYOUT

        } //end rect 12 (bottom rect)

    } // end row1



    Rectangle {
        id: rect2
        color : "white"
        border.width : 0
        border.color :  "light grey"
        height : appRoot.height
        width : 300
        
     ColumnLayout
            {

        Label { text: "Target Coordinates" ; font.underline : true}

        RowLayout {
            Label { text: "X-Coordinate" }
            TextField {
                id: tarX
                placeholderText: qsTr("i.e. 100m")
                validator: IntValidator { bottom: 0; top: 200000;}
                }
                Label { id:txStar; color:"red"; text: "" }
            }

        RowLayout {
            Label { text: "Y-Coordinate" }
            TextField {
                id: tarY
                placeholderText: qsTr("i.e. 100m")
                validator: IntValidator { bottom: 0; top: 200000;}
                }
                Label { id:tyStar; color:"red"; text: "" }
            }

            RowLayout {
                Button {
                    text: "Add Target"
                    onClicked : { 

                        var tXCheck = false
                        var tYCheck = false

                        if (tarX.text==""){txStar.text="*"}
                        else{txStar.text=""; tXCheck=true;}

                        if (tarY.text==""){tyStar.text="*"}
                        else{tyStar.text=""; tYCheck=true;}

                        if (tXCheck==true && tYCheck==true) {
                            var x = (tarX.text)
                            var y = (tarY.text)
                            if (Julia.targetExists(x,y)==true){
                                infoTar.text = "Object exists at Coords"
                                infoTar.color = "red"
                                }
                            else{
                                var num = Julia.getElemNumber("TAR")
                                var id= "TAR" + num
                                Julia.addTarget(tarX.text, tarY.text)
                                infoTar.text = "Target Added"
                                infoTar.color = "green"
                                }
                        }
                        else{ 
                            infoTar.text = "Empty Params"
                            infoTar.color = "red"
                        }
                    }
                }
                Button {
                    text: "1 Target"
                    onClicked : { 
                        
                        if (Julia.targetExists("100000", "100000")==true){
                                infoTar.text = "Object exists at Coords"
                                infoTar.color = "red"
                            }
                        else{
                            var num = Julia.getElemNumber("TAR")
                            var id= "TAR" + num
                            Julia.addTarget("100000", "105000")
                            infoTar.text = "Target Added"
                            infoTar.color = "green"
                            }
                    }
                }
                Button {
                    text: "clear Targets"
                    onClicked : { 
                        Julia.clearTargets();
                        infoTar.text="cleared"
                        infoTar.color="blue"

                    }
                }

                // clearTargets

            }// End Add Target 
                    Label { id: infoTar; text: "" }         

             Button {
                    text: "Generate Random Targets"
                    onClicked : { 
                        Julia.makeRandomTargets()
                    }
                }

            Label { text: "Save Scenario:" }
            
            RowLayout{      
            TextField {
                    id: saveScenarioText
                    placeholderText: qsTr("Filename")
                    }

            Button {
                    text: "Save"
                    onClicked : { 

                        if (saveScenarioText.text=="")
                        {
                            infoScene.text = "Please enter save Filename" 
                            infoScene.color = "red"
                        }
                        else{
                            if( Julia.isfile("scenarios/"+saveScenarioText.text) )
                            {
                                infoScene.text = "File already Exists" 
                                infoScene.color = "red"
                            }
                            else
                            {
                                infoScene.text = "Saving..."
                                infoScene.color = "green"
                                Julia.saveScenario("scenarios/" + saveScenarioText.text)
                                infoScene.text = "Saved"
                                // infoScene.color = "green"
                            }
                        }



                    }
                }

            }

            Label { text: "Load Scenario:" }
            
            RowLayout{
                TextField {
                    id: scenario
                    placeholderText: qsTr("Filename")
                    }
            Button {
                    text: "Load"
                    onClicked : {

                        if (scenario.text=="")
                        {
                            infoScene.text = "No Filename Entered" 
                            infoScene.color = "red"
                        }
                        else{
                            if(Julia.isfile("scenarios/"+scenario.text))
                            {
                                // infoScene.text = "file ! found"
                                Julia.readInCSV(scenario.text);
                                infoScene.text = "File Loaded" 
                                infoScene.color = "green"
                            }
                            else
                            {
                                infoScene.text = "File not found"
                                infoScene.color = "red"
                            }
                        }

                    }
                }  
            }

            Label { id:infoScene; text: "" }

        Label { text: "Scenario objects";  font.underline : true }   

        TableView {
                    id : tbViewTar
                    Layout.preferredWidth :300
                    Layout.maximumWidth :300

                        TableViewColumn {
                            role: "typ"
                            title: "typ"
                            width: 50
                        }
                        TableViewColumn {
                            role: "_id"
                            title: "id"
                            width: 50
                        }
                        TableViewColumn {
                            role: "ex"
                            title: "X-Coordiante"
                            width: 99
                        }
                        TableViewColumn {
                            role: "ey"
                            title: "Y-Coordinate"
                            width: 99
                        }
                        model: startModel
                    }

        Label { text: "Focusing Bounds";  font.underline : true }   

        RowLayout{
            Label { text: "Range:";  font.underline : true }   
            TextField {
                        id: rangeLower
                        placeholderText: qsTr("0m->200000m")
                        validator: IntValidator { bottom: 0; top: 200000;}
                    }
            TextField {
                        id: rangeUpper
                        placeholderText: qsTr("0m->200000m")
                        validator: IntValidator { bottom: 0; top: 200000;}
                    }
        }

        RowLayout{
            Label { text: "Angle:";  font.underline : true }   
            TextField {
                        id: angleLower
                        placeholderText: qsTr("-60->0")
                        validator: IntValidator { bottom: (-60); top: (0);}
                    }
            TextField {
                        id: angleUpper
                        placeholderText: qsTr("0->60")
                        validator: IntValidator { bottom: 0; top: 60;}
                    }
        }


        // Button {
        //         text: "Find Single Point"
        //         onClicked : { 
        //             if(Julia.checkSinglePoint())
        //             {
        //             }
        //             else{

        //                 processInfo.text = "Single Point Target detection requires one target"
        //                 processInfo.color = "red"
        //             }
        //         }
        // }

        Button {
                text: "Process Focusing Algorithm"
                
                style: ButtonStyle {
                    label: Text {
                        color: "blue"
                        text: control.text
                    }
                }

                onClicked : {

                    if(Julia.checkArrSimulate()){
                        Julia.processFocusingAlgorithm(rangeUpper.text,rangeLower.text,angleUpper.text,angleLower.text)
                    }
                    else{
                        processInfo.text = "Can't Sim, Missing RX"
                        processInfo.color = "red"
                    }

                    // if(rangeLower.text =="" || rangeUpper.text=="" || angleLower.text =="" || angleUpper.text=="")
                    // {
                    //     if(Julia.checkArrSimulate()){ Julia.processFocusingAlgorithm("--","","","") }
                    //     else{
                    //         processInfo.text = "Cant Simulate, check elements/targets"
                    //         processInfo.color = "red"
                    //     }
                    // }
                    // else
                    // {
                    //     if( Julia.checkBoundsSize(rangeLower.text,rangeUpper.text)  )
                    //     {
                    //         if(Julia.checkBoundsSize(angleLower.text,angleUpper.text))
                    //         {
                    //             if(Julia.checkArrSimulate()){
                    //                 Julia.processFocusingAlgorithm(rangeUpper.text,rangeLower.text,angleUpper.text,angleLower.text)
                    //             }
                    //             else{
                    //                 processInfo.text = "Can't Sim, Missing RX"
                    //                 processInfo.color = "red"
                    //             }
                    //         }
                    //         else{
                    //             processInfo.text = "Can't Focus with incorrect Angle bounds"
                    //             processInfo.color = "red"
                    //         }
                    //     }
                    //     else{
                    //         processInfo.text = "Can't Focus with incorrect Range bounds"
                    //         processInfo.color = "red"
                    //     }
                    // }

                } // END OF ONCLICKED
        }

        Button {
                text: "View Image Focusing Algorithm"

                style: ButtonStyle {
                    label: Text {
                        color: "blue"
                        text: control.text
                    }
                }

                onClicked : { 

                    if(Julia.viewImageFA()==1)
                    {
                        processInfo.text = "ImageLoaded"
                        processInfo.color = "Green"
                    }
                    else{
                        processInfo.text = "No image processed."
                        processInfo.color = "red"
                    }
                }
        }

        Button {
                text: "Process Intersection Algorithm"
                style: ButtonStyle {
                    label: Text {
                        color: "green"
                        text: control.text
                    }
                }

                onClicked : { 
                    if(Julia.checkArrSimulate())
                    {
                        Julia.processIntersectionAlgorithm()
                    }
                    else{
                        processInfo.text = "Can't Sim, Missing RX"
                        processInfo.color = "red"
                    }
                }
        }

                    // Label { id: nada; text: "" }
        
        Button {
                text: "View Image Intersection Algorithm"
                style: ButtonStyle {
                    label: Text {
                        color: "green"
                        text: control.text
                    }
                }
                onClicked : { 

                    if(Julia.viewImageIA()==1)
                    {
                        processInfo.text = "ImageLoaded"
                        processInfo.color = "Green"
                    }
                    else{
                        processInfo.text = "No image processed."
                        processInfo.color = "red"
                    }
                }
        }



                    Label { id: processInfo; text: "" }
        } //End column Layout
    } // End rect2


        // Rectangle {
        //     id: displayArea
        //     height : 500
        //     width  : 500
        //     color  : "blue"
        //     JuliaDisplay{
        //         id: jdisp
        //         // Layout.fillWidth : true
        //         // Layout.fillHeight : true
        //         width : 500
        //         height: 500

        //     }
        //     // visible: false
        // }

    }// id: rlayout BEGIN

} // end appRoot



