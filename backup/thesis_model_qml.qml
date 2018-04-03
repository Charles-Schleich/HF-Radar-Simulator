
// import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    id: appRoot
    title: "High Frequency Radar Simulator"
    visible: true
    width: 1000
    height: 1000
    // ColumnLayout {
        // anchors.fill : parent
       
        Rectangle {
            anchors.fill: parent
            color: "white"
        
            Repeater {// Repeat for each object

                anchors.fill: parent
                model: objectModel
                
                Rectangle {
                    color: colour
                    x: ex*appRoot.width
                    y: ey*appRoot.height

                    width :5
                    height:5

                    Text {
                        text:name
                        width: parent.width
                        height: parent.height
                    }
                }
            } //end Repeater
             
    }
}
