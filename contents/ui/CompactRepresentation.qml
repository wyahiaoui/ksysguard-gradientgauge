
import QtQuick 2.9
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.8 as Kirigami

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.faces 1.0 as Faces

import org.kde.quickcharts 1.0 as Charts
import org.kde.quickcharts.controls 1.0 as ChartControls

Faces.SensorFace {
    id: root
    contentItem: ColumnLayout {
        Gauge {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
        }
        Controls.Label {
            id: label
            visible: root.formFactor == Faces.SensorFace.Planar
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            text: root.controller.title
        }
    }
}

