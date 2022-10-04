

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.8 as Kirigami

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.faces 1.0 as Faces

import org.kde.quickcharts 1.0 as Charts
import org.kde.quickcharts.controls 1.0 as ChartControls

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: chart

    Layout.minimumWidth: root.formFactor != backgrounds.Sensorbackground.Vertical ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit
    Layout.minimumHeight: root.formFactor == backgrounds.Sensorbackground.Vertical ? width : Kirigami.Units.gridUnit
    Layout.maximumHeight: width / gaugeSvg.ratio
    
    
    PlasmaCore.Svg {
        id: gaugeSvg
        imagePath: Qt.resolvedUrl("../images/gauge.svg")
        property real ratio
        onRepaintNeeded: {
            ratio = gaugeSvg.elementSize("hint-boundingrect").width / gaugeSvg.elementSize("hint-boundingrect").height
        }
    }

    PlasmaCore.SvgItem {
        id: background
        width: foreground.width
        height: foreground.height

        anchors.horizontalCenter: root.horizontalCenter
        svg: gaugeSvg
        elementId: "background"
    }

    Item {
        id: renderParent
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        height:  parent.height * gaugeSvg.ratio
        //layer.enabled: true

        PlasmaCore.SvgItem {
            id: foreground
            visible: false
            width: Math.min(parent.width, parent.height)
            height: width

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            svg: gaugeSvg
            elementId: "foreground"
            readonly property real ratioX: foreground.width/gaugeSvg.elementRect("foreground").width
            readonly property real ratioY: foreground.height/gaugeSvg.elementRect("foreground").height

            function elementPos(element) {
                var rect = gaugeSvg.elementRect(element);
                return Qt.point(rect.x * ratioX, rect.y * ratioY);
            }

            function elementCenter(element) {
                var rect = gaugeSvg.elementRect(element);
                return Qt.point(rect.x * ratioX + (rect.width * ratioX)/2, rect.y * ratioY + (rect.height * ratioY)/2);
            }

            function elementSize(element) {
                var rect = gaugeSvg.elementRect(element);
                return Qt.size(rect.width * ratioX, rect.height * ratioY);
            }
        }

        ChartControls.PieChartControl {
            id: pie
            visible: false
            anchors.fill: foreground
            property alias sensors: sensorsModel.sensors
            property alias sensorsModel: sensorsModel

            Layout.minimumWidth: root.formFactor != Faces.SensorFace.Vertical ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit
            Layout.minimumHeight: root.formFactor == Faces.SensorFace.Vertical ? width : Kirigami.Units.gridUnit

            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            chart.smoothEnds: false
            chart.fromAngle: -110
            chart.toAngle: 110
            chart.filled: true

            range {
                from: root.controller.faceConfiguration.rangeFrom
                to: root.controller.faceConfiguration.rangeTo
                automatic: root.controller.faceConfiguration.rangeAuto
            }

            text: root.controller.totalSensors.length == 1 ? sensor.formattedValue : ""

            valueSources: Charts.ModelSource {
                model: Sensors.SensorDataModel {
                    id: sensorsModel
                    sensors: root.controller.highPrioritySensorIds
                }
                roleName: "Value"
                indexColumns: true
            }
            chart.nameSource: Charts.ModelSource {
                roleName: "Name";
                model: valueSources[0].model;
                indexColumns: true
            }
            chart.shortNameSource: Charts.ModelSource {
                roleName: "ShortName";
                model: valueSources[0].model;
                indexColumns: true
            }
            // chart.colorSource: root.colorSource
            
            LinearGradient {
                id: gradientSetup
                property var radius: Math.sqrt(parent.width * parent.width + parent.height * parent.height)
                property var angle: controller.faceConfiguration.angle/360
                
                anchors.fill: parent
                end: Qt.point((radius* Math.sin(Math.PI * angle)), (angle != 0) ? radius - radius*Math.cos(Math.PI * angle):0)
                start: Qt.point(Kirigami.Units.gridUnit, (angle != 0) ? 0:radius*Math.cos(Math.PI * angle))
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.colorSource.map[root.controller.highPrioritySensorIds[0]] }
                    GradientStop { position: 1.0; color: controller.faceConfiguration.gradientColor }
                }

                onAngleChanged: {

                    // gradientSetup.radius = 0
                }
            }
        }

        OpacityMask {
            cached: true
            anchors.fill: foreground
            source: pie
            maskSource: foreground
        }

        Item {
            id: pointersContainer
            anchors.fill: foreground
            property var sensorRate: 0.1
            Repeater {
                id: handleRepeater
                model: root.controller.highPrioritySensorIds

                Item {
                    id: pointer
                    x: foreground.elementCenter("rotatecenter").x - width/2
                    y: foreground.elementCenter("rotatecenter").y //- height/2
                    width: foreground.elementSize("pointer").width
                    height: foreground.elementSize("pointer").height
                    transformOrigin: Item.Top
                    // only 7.5 degrees increments
                    rotation: index === 0
                        ? Math.round((75 + sensor.sensorRate * 210) / 7.5) * 7.5
                        : Math.round((sensor.sensorRate * 210 + pointersContainer.children[index-1].rotation) / 7.5) * 7.5
                    Sensors.Sensor {
                        id: sensor
                        property real sensorRate: value/Math.max(value, maximum) || 50
                        sensorId: modelData
                        onSensorRateChanged: {

                            if (sensorRate  <= Math.round(gradientSetup.angle * 2))
                                handColor.color = root.colorSource.map[modelData]
                            else if (sensorRate  <= Math.round(gradientSetup.angle * 2 + gradientSetup.angle * .5)) {
                                handColor.color = controller.faceConfiguration.gradientColor
                                handColor.color.r += root.colorSource.map[modelData].r 
                                handColor.color.r /=2;
                                handColor.color.g += root.colorSource.map[modelData].g 
                                handColor.color.g /=2;
                                handColor.color.b += root.colorSource.map[modelData].b 
                                handColor.color.b /=2;
                            }
                            else  
                                handColor.color = controller.faceConfiguration.gradientColor
                        }
                    }

                    PlasmaCore.SvgItem {
                        id: pointerSvg
                        visible: false
                        anchors.fill: parent
                        svg: gaugeSvg
                        elementId: "pointer"
                    }
                    Rectangle {
                        id: handColor
                        visible: false
                        anchors.fill: parent
                        color: root.colorSource.map[modelData] 
                     }
                    OpacityMask {
                        cached: true
                        anchors.fill: parent
                        source: handColor
                        maskSource: pointerSvg
                    }
                }
            }

            Controls.Label {
                color: root.controller.highPrioritySensorIds.length > 0 ? root.colorSource.map[root.controller.highPrioritySensorIds[0]] : Kirigami.Theme.highlightColor
                x: foreground.elementCenter("label0").x - width/2
                y: foreground.elementCenter("label0").y - height/2
                text: totalSensor.formattedValue
                font.pixelSize: foreground.elementSize("label0").height
            }
        }
    }

    FastBlur {
        z: -1
        visible: controller.faceConfiguration.glow
        anchors.fill: renderParent
        source: renderParent
        radius: Kirigami.Units.gridUnit/2
    }

    Sensors.Sensor {
        id: totalSensor
        sensorId: root.controller.totalSensors[0]
    }
}

