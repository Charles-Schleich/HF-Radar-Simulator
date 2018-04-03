
// import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    id: appRoot
    title: "High Frequency Radar Simulator"
    visible: true
    width: 1100
    height: 500
    
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
            height : 500
            width  : 500
            color  : "white"
            Repeater {// Repeat for each object
                id: repeatPlotter
                anchors.fill: parent
                model: startModel

                    Rectangle {
                        color: colour
                        x: 500*ex/400
                        y: 500-500*ey/400

                        width :5
                        height:5

                        Text {
                            text: _id
                            width: parent.width
                            height: parent.height
                        }
                    }
                

            } //end Repeater
        }

    // MENU
    // MENU
    // MENU
        Rectangle {
            id: rect1
            color : "white"
            height : appRoot.height
            width : 600
            
            ColumnLayout
            {
            Label { text: "Targets" }
            RowLayout {
                Label { text: "X-Coordinate"}
                TextField {
                    id: xField
                    placeholderText: qsTr("Enter X")
                    validator: IntValidator {bottom: 0; top: 400;}
                }
                
                Label { text: "Y-Coordinate"}
                TextField {
                    id:yField
                    placeholderText: qsTr("Enter Y")
                    validator: IntValidator {bottom: 0; top: 400;}
                }

                Button  {
                text: "Add Target"
                onClicked : { 
                            if (xField.text!="" && yField.text!="") 
                                {
                                var x = parseInt(xField.text)
                                var y = parseInt(yField.text)
                                if (Julia.targetExists(x,y)==true){
                                    infoTar.text = "object exists at Coords"
                                    infoTar.color = "red"
                                    }
                                else{
                                    var num = Julia.getElemNumber("TAR")
                                    var id= "TAR" + num
                                    Julia.addTarget(xField.text, yField.text)
                                    infoTar.text = "Target Added"
                                    infoTar.color = "black"
                                    }
                                }
                                else{
                                    infoTar.text = "Invalid Coordinates"
                                    infoTar.color = "red"
                                }
                            }
                }
            } // END TOP ROW
            


            // SECOND ROW
            Label { text: "Recieve Antenna" }
            RowLayout {
                
                Label { text: "X-Coordinate"}
                
                TextField {
                    id: xFieldRx
                    placeholderText: qsTr("Enter X")
                    validator: IntValidator {bottom: 0; top: 400;}
                }
                
                Label { text: "Y-Coordinate"}
                
                TextField {
                    id:yFieldRx
                    placeholderText: qsTr("Enter Y")
                    validator: IntValidator {bottom: 0; top: 400;}
                }

                Button  {
                text: "Add Recieve Antenna"
                onClicked : { 
                            if (xFieldRx.text!="" && yFieldRx.text!="") 
                                {
                                var x = parseInt(xFieldRx.text)
                                var y = parseInt(yFieldRx.text)

                                if (Julia.targetExists(x,y)==true){
                                    infoTar.text = "object exists at Coords"
                                    infoTar.color = "red"
                                    }
                                else{
                                    var num = Julia.getElemNumber("RX")
                                    var id= "RX " + num
                                    Julia.addRecieveAntenna(xFieldRx.text, yFieldRx.text)
                                    infoTar.text = "RX Added"
                                    infoTar.color = "orange"
                                    }
                                }
                                else{
                                    infoTar.text = "Invalid Coordinates"
                                    infoTar.color = "red"
                                }
                            }
                }
            } // END SECOND ROW
// //////////////////////////////////////////////////////////////////////////////////////
            RowLayout {
                Layout.fillWidth : true 
          
                TableView {
                    id : tbViewTar
                    Layout.preferredWidth : 400
                    Layout.maximumWidth :400

                        TableViewColumn {
                            role: "typ"
                            title: "typ"
                            width: 98
                        }
                        TableViewColumn {
                            role: "_id"
                            title: "id"
                            width: 100
                        }
                        TableViewColumn {
                            role: "ex"
                            title: "X Coordiante"
                            width: 100
                        }
                        TableViewColumn {
                            role: "ey"
                            title: "Y-Coordinate"
                            width: 100
                        }
                        model: startModel
                    }
                
                ColumnLayout
                {
                    Label {
                        id: infoTar
                        text: "--"
                        }

                    Button  {
                        text: "Clear All Targets"
                        onClicked : { 
                            // tbViewTar.model.clear()
                            // repeatPlotter.model.clear()

                            Julia.emptyArrays()

                                    }   
                    }

                    Button  {
                        text: "Clear Target"
                        onClicked : { 
                                    infoTar.text = "Clicked button"
                                    }   
                    }

                }
        }// END ROW LAYOUT  Tableview

////////////////////////////////////////////////////////////////////////////////////////
        ColumnLayout
        {
            id: loadFile
            Label { text: "Load Target File" }

            RowLayout {
                TextField {
                    id: filePathTarget
                    Layout.preferredWidth : 200
                    Layout.maximumWidth :200
                    placeholderText: qsTr("Enter Filename")
                    validator: RegExpValidator { regExp: /[0-9A-Za-z/.]+/ }
                    onAccepted: {

                        var exists = Julia.isfile(filePathTarget.text)
                        if (exists==true)
                            {
                            ldLabel.text = "Loaded (hopefully)";
                            ldLabel.color = "black";
                            Julia.emptyArrays()
                            //This loads new Model in function readInCSV
                            Julia.readInCSV(filePathTarget.text)
                            }
                        else {
                                ldLabel.text = "File does not exist"
                                ldLabel.color = "red"
                             } 


                    }
                }
                Button  {
                    text: "Load File"
                    onClicked : { 
                        var exists = Julia.isfile(filePathTarget.text)
                        if (exists==true)
                            {
                            ldLabel.text = "Loaded (hopefully)";
                            ldLabel.color = "black";
                            Julia.emptyArrays()
                            //This loads new Model in function readInCSV
                            Julia.readInCSV(filePathTarget.text)
                            }
                        else {
                                ldLabel.text = "File does not exist"
                                ldLabel.color = "red"
                             }  

                        } 
                }

                Label{
                    id : ldLabel
                    text: ""
                }

            }
        }

        RowLayout
        {
            Button  {
                text: "Calc Distances"
                onClicked : { 
                    Julia.outputDistances()
                            }   
            }

            Button  {
                text: "makeWaveforms"
                onClicked : { 
                    if (Julia.checkArrSimulate()==true)
                    {
                        Julia.simulate()
                    }
                    else{
                        ldLabel.color= "red"
                        ldLabel.text="Need 1 Tx, Rx and Target to simulate"
                    }
                            }   
            }

            Button  {
                text: "Test button"
                onClicked : { 
                    Julia.tunnelPrint();
                            }   
            }
        }


////////////////////////////////////////////////////////////////////////////////////////

 //   _______  ______   _____  _______  _____  _   _   _____       _____  ____   _____   ______ 
 //  |__   __||  ____| / ____||__   __||_   _|| \ | | / ____|     / ____|/ __ \ |  __ \ |  ____|
 //     | |   | |__   | (___     | |     | |  |  \| || |  __     | |    | |  | || |  | || |__   
 //     | |   |  __|   \___ \    | |     | |  | . ` || | |_ |    | |    | |  | || |  | ||  __|  
 //     | |   | |____  ____) |   | |    _| |_ | |\  || |__| |    | |____| |__| || |__| || |____ 
 //     |_|   |______||_____/    |_|   |_____||_| \_| \_____|     \_____|\____/ |_____/ |______|

 
////////////////////////////////////////////////////////////////////////////////////////////



            } //END ColumnLayout

        } // END TARGET RECTANGLE

    }// id: rlayout BEGIN

}