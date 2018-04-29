
// import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    id: appRoot
    title: "High Frequency Radar Simulator"
    visible: true
    // width: 1100
    width: 1200
    height: 600
    
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
            height : 600
            width  : 600
            color  : "white"

            Repeater {// Repeat for each object
                id: repeatPlotter
                anchors.fill: parent
                model: startModel

                    Rectangle {
                        color: colour
                        x: layoutMap.width*ex/200000
                        y: layoutMap.height*(1-ey/200000)
                        width :2
                        height:5

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
            height : appRoot.height/2
            width : 320
            
            ColumnLayout
            {
/////Simulation Paramaters

            Label { 
                text: "Simulation Parameters"
                font.underline : true
                 }
            
            RowLayout {
                Label { text: "Centre Frequency (f0):    " }
                TextField {
                    id:centreFreq
                    placeholderText: qsTr("i.e. 400000Hz")
                    validator: IntValidator { bottom: 0; top: 4000000;}
                }
                Label { id:cfStar; color:"red"; text: "" }
            }

            RowLayout {
                Label { text: "Bandwidth (B):                   " }
                TextField {
                    id:bandWidth
                    placeholderText: qsTr("i.e. 400000Hz")
                    validator: IntValidator { bottom: 0; top: 4000000;}
                }
                 Label { id:bwStar; color:"red"; text: "" }
            }

            RowLayout {

                // Label { text: "Sample Frequency (fs):   " }
                Label { text: "Sample rate (fs):                " }
                TextField {
                    id: sampleR
                    placeholderText: qsTr("i.e. 100000")
                    validator: IntValidator { bottom: 0; top: 200000;}
                }
                 Label { id:sfStar; color:"red"; text: "" }
            }
            
            RowLayout {
                Label { text: "No* Recv Antennas(N):   " }
                TextField {
                    id: noAntenna
                    placeholderText: qsTr(" 2 - 10 ")
                    validator: IntValidator { bottom: 0; top: 10;}
                }
                 Label { id:nAStar; color:"red"; text: "" }
            }
            Label {text: ""  }
/////Simulation Paramaters

/////RECIEVE ANTENNAS
            Label { 
                text: "Antenna Array Start Coordinates" 
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
             
            Label { id: instructRec; text: "Note: RX antennas 2->N will be auto placed at\n 1/2 Wavelength intervals for centre frequency"; color: "blue"}


            RowLayout {
            Button  {
                text: "Confirm Sim Parameters"
                onClicked : {
                    infoSimParams.text = ""
                    var cfCheck = false
                    var bWCheck = false
                    var sFCheck = false
                    var nACheck = false
                    var rXCheck = false
                    var rYCheck = false


                    if (centreFreq.text==""){cfStar.text="*"}
                    else{cfStar.text=""; cfCheck=true;}

                    if (bandWidth.text==""){bwStar.text="*"}
                    else{bwStar.text=""; bWCheck=true;}

                    if (sampleR.text==""){sfStar.text="*"}
                    else{sfStar.text=""; sFCheck=true;}
                    
                    if (noAntenna.text==""){nAStar.text="*"}
                    else{nAStar.text=""; nACheck=true;}

                    if (rxAntennaX.text==""){rxStar.text="*"}
                    else{rxStar.text=""; rXCheck=true;}

                    if (rxAntennaY.text==""){ryStar.text="*"}
                    else{ryStar.text=""; rYCheck=true;}
                    
                    // ACCEPTED
                    if (cfCheck==true && bWCheck==true && sFCheck==true && nACheck==true && rXCheck==true && rYCheck==true) {
                        
                        var a = Julia.initParams(centreFreq.text,bandWidth.text,sampleR.text)
                        var b = Julia.addRxAntennas(rxAntennaX.text,rxAntennaY.text,noAntenna.text)

                        infoSimParams.text = a
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

               

/////RECIEVE ANTENNAS

            } //End ColumnLayout
        } // End rect1

    Rectangle {
        id: rect12
        color : "white"
        height : appRoot.height/2
        width : 320
        }
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
                    Label { id: infoTar; text: "" }         
            }// End Add Target 
        Label { text: "" }   


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


        Button {
            text: "Load Default Parameters"
            onClicked : {var a = Julia.loadDefaults()
                params.text = a
            }
                }
        Label { id: params ; text: "" }    



        }//End column Layout
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