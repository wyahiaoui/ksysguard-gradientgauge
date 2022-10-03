
import QtQuick 2.9
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.faces 1.0 as Faces
import org.kde.quickcharts 1.0 as Charts
import org.kde.quickcharts.controls 1.0 as ChartsControls
import org.kde.kirigami 2.8 as Kirigami

Faces.SensorFace {
    id: root
    readonly property bool showLegend: controller.faceConfiguration.showLegend

        
    contentItem:  ColumnLayout {
            // Arbitrary minimumWidth to make easier to align plasmoids in a predictable way
            Layout.minimumWidth: Kirigami.Units.gridUnit * 8

            Kirigami.Heading {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: root.controller.title
                visible: text.length > 0
                level: 2
            }

            Gauge {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 5 * Kirigami.Units.gridUnit
            }
        }
        ColumnLayout {
            visible: root.showLegend

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Repeater {
                model: root.controller.highPrioritySensorIds.concat(root.controller.lowPrioritySensorIds)

                ChartsControls.LegendDelegate {
                    readonly property bool isTextOnly: index >= root.controller.highPrioritySensorIds.length

                    Layout.fillWidth: true
                    Layout.minimumHeight: isTextOnly ? 0 : implicitHeight

                    name: sensor.shortName
                    value: sensor.formattedValue
                    colorVisible: !isTextOnly
                    color: !isTextOnly ? root.colorSource.map[modelData] : "transparent"

                    layoutWidth: root.width
                    valueWidth: Kirigami.Units.gridUnit * 2

                    Sensors.Sensor {
                        id: sensor
                        sensorId: modelData
                    }
                }
        }

        Item { Layout.fillWidth: true; Layout.fillHeight: true }
    }

    Item {
        Layout.fillHeight: true
    }
}

