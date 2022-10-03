import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.2 

import org.kde.kirigami 2.8 as Kirigami

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.faces 1.0 as Faces

Kirigami.FormLayout {
    id: root
    Layout.fillWidth: true
    // wideMode: false

    property alias cfg_showLegend: showSensorsLegendCheckbox.checked
    property alias cfg_glow: glowCheckbox.checked


    Row {
        spacing: 15
        Text {
            anchors.verticalCenter: parent.verticalCenter 
            color: Kirigami.Theme.textColor
            text: i18n("Gradient Angle")
        }
        
        TextField {
            placeholderText: i18n(controller.faceConfiguration.angle)
            width: parent.width - units.gu(25)
            height: parent.height - units.gu(25)
            onTextChanged: {
                controller.faceConfiguration.angle = text
            }
        }
    }

    CheckBox {
        id: showSensorsLegendCheckbox
        text: i18n("Show Sensors Legend")
    }

    CheckBox {
        id: glowCheckbox
        text: i18n("Glow")
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Look and Feel"
    }

    ColorWheel {
        id: wheel
    }


    Row {
        spacing: 15
        CheckBox {
            anchors.verticalCenter: parent.verticalCenter 
            text: i18n("Cursor  Color")
            onCheckedChanged: {
                cursorColor.visible = (checked) ?true:false; 
            }
        }
        


        Image {
            id: cursorColor
            source: Qt.resolvedUrl("../images/color_chooser.png")
            width: 20
            visible: false
            height: 20
            MouseArea {
                anchors.fill: parent
                onClicked: wheel.open()
            }   
        }
    }

    Row {
        spacing: 15
        Text {
            anchors.verticalCenter: parent.verticalCenter 
            color: Kirigami.Theme.textColor
            text: i18n("   Gradient    Color")
        }



        Image {
            source: Qt.resolvedUrl("../images/color_chooser.png")
            width: 20
            height: 20
            MouseArea {
                anchors.fill: parent
                onClicked: wheel.open()
            }   
        }
    }

}

