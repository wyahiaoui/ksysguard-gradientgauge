import QtQuick 2.15
import QtQuick.Controls 2.15 
import QtQuick.Dialogs 1.2

Dialog {
    id: colorDialog
    readonly property color color: Qt.hsva(mousearea.angle, 1.0, 1.0, 1.0)
    Column {
        id: columnDialog
        spacing: 5

        CheckBox {
            id: maxGradient
            text:  i18n("Color Picker")
            checked: controller.faceConfiguration.gradientActive
            onCheckedChanged: {
                control.visible = checked ?  true:false;
            }
        }

        Control {
            x: parent.width * 3/4
            id: control
            visible: false
            property real ringWidth: 15
            property real hsvValue: 1.0
            property real hsvSaturation: 1.0
            



            contentItem: Item {
                implicitWidth: 155
                implicitHeight: width

                ShaderEffect {
                    id: shadereffect
                    width: parent.width; height: parent.height
                    readonly property real ringWidth: control.ringWidth / width / 2
                    readonly property real s: control.hsvSaturation 
                    readonly property real v: control.hsvValue

                    fragmentShader: "
                        #version 330
                        varying highp vec2 qt_TexCoord0;
                        uniform highp float qt_Opacity;
                        uniform highp float ringWidth;
                        uniform highp float s;
                        uniform highp float v;

                        vec3 hsv2rgb(vec3 c) {
                            vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                            vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                            return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
                        }

                        void main() {
                            highp vec2 coord = qt_TexCoord0 - vec2(0.5);
                            highp float ring = smoothstep(0, 0.01, -abs(length(coord) - 0.5 + ringWidth) + ringWidth);
                            gl_FragColor = vec4(hsv2rgb(vec3(-atan(coord.x, coord.y) / 6.2831 + 0.5, s, v)),1);
                            gl_FragColor *= ring;
                        }"
                }

                Rectangle {
                    id: indicator
                    x: (parent.width - width)/2
                    y: control.ringWidth * 0.1

                    width: control.ringWidth * 0.8; height: width
                    radius: width/2

                    color: 'white'
                    border {
                        width: mousearea.containsPress ? 3 : 1
                        color: Qt.lighter(colorDialog.color)
                        Behavior on width { NumberAnimation { duration: 50 } }
                    }

                    transform: Rotation {
                        angle: mousearea.angle * 360
                        origin.x: indicator.width/2
                        origin.y: control.availableHeight/2 - indicator.y
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: control.availableWidth * 0.3
                    height: width
                    radius: width

                    color: colorDialog.color
                    border {
                        width: 5
                        color: Qt.lighter(colorDialog.color, 1.8)
                    }
                }

                MouseArea {
                    id: mousearea
                    anchors.fill: parent
                    property real angle: Math.atan2(width/2 - mouseX, mouseY - height/2) / 6.2831 + 0.5
                }
            }
        }
    }
}