// The login screen, run by greetd inside a bare Hyprland (see ../greetd.nix).
// It looks like the shell's lock screen: the wallpaper you last picked,
// blurred, with the time and a password field. Logging in writes the marker
// greetd.nix checks, then launches the session.
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Greetd
import Quickshell.Wayland

ShellRoot {
    id: root

    readonly property string user: Quickshell.env("OZ_GREETER_USER")
    readonly property string session: Quickshell.env("OZ_GREETER_SESSION")
    readonly property string wallpaper: Quickshell.env("OZ_GREETER_WALLPAPER")
    readonly property string avatar: Quickshell.env("OZ_GREETER_AVATAR")

    // Held until greetd asks for it, then dropped.
    property string pending: ""
    property bool checking: false
    property string error: ""

    readonly property color text: scheme.base05
    readonly property color dim: Qt.tint(scheme.base05, Qt.alpha(scheme.base01, 0.35))
    readonly property color faint: Qt.tint(scheme.base05, Qt.alpha(scheme.base01, 0.55))
    readonly property color panel: scheme.base01
    readonly property color danger: scheme.base08
    // The wallpaper's most vivid color, lifted for the dark panels.
    property color accent: scheme.base0E

    function submit(password: string): void {
        if (root.checking || password === "")
            return;
        if (!Greetd.available) {
            root.fail("Can't reach greetd");
            return;
        }
        root.pending = password;
        root.checking = true;
        root.error = "";
        if (Greetd.state !== GreetdState.Inactive)
            Greetd.cancelSession();
        Greetd.createSession(root.user);
    }

    function fail(message: string): void {
        root.checking = false;
        root.pending = "";
        root.error = message;
    }

    Scheme {
        id: scheme
    }

    ColorQuantizer {
        source: root.wallpaper ? `file://${root.wallpaper}` : ""
        depth: 3
        rescaleSize: 128

        onColorsChanged: {
            const vivid = [...colors].filter(c => c.hslSaturation > 0.25 && c.hslLightness > 0.15 && c.hslLightness < 0.9).sort((a, b) => b.hslSaturation - a.hslSaturation);
            if (vivid.length > 0)
                root.accent = Qt.hsla(vivid[0].hslHue, Math.max(vivid[0].hslSaturation, 0.55), Math.min(Math.max(vivid[0].hslLightness, 0.68), 0.82), 1);
        }
    }

    Connections {
        target: Greetd

        function onAuthMessage(message: string, error: bool, responseRequired: bool, echoResponse: bool): void {
            if (responseRequired) {
                Greetd.respond(root.pending);
                root.pending = "";
            } else if (error) {
                root.fail(message);
            }
        }

        function onAuthFailure(message: string): void {
            root.fail("Wrong password");
        }

        function onError(error: string): void {
            root.fail(error);
        }

        function onReadyToLaunch(): void {
            done.setText("launched");
            Greetd.launch([root.session], ["XDG_SESSION_DESKTOP=Hyprland", "XDG_CURRENT_DESKTOP=Hyprland"], true);
        }
    }

    // Tells greetd.nix the greeter launched a session, rather than failed.
    FileView {
        id: done

        path: Quickshell.env("OZ_GREETER_DONE")
        blockWrites: true
        printErrors: false
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: surface

            required property var modelData

            // The login form goes where the cursor is; other screens only
            // show the wallpaper.
            readonly property bool main: (Hyprland.focusedMonitor?.name ?? Quickshell.screens[0].name) === modelData.name

            screen: modelData
            color: root.panel

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "oz-greeter"
            WlrLayershell.keyboardFocus: main ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            Image {
                id: wallpaper

                anchors.fill: parent

                source: root.wallpaper ? `file://${root.wallpaper}` : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: false
            }

            MultiEffect {
                anchors.fill: wallpaper

                source: wallpaper
                blurEnabled: true
                blur: 1
                blurMax: 64
                brightness: -0.2
            }

            ColumnLayout {
                anchors.centerIn: parent

                visible: surface.main
                spacing: 10

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: root.text

                    font.family: "Maple Mono NF"
                    font.pixelSize: 112
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 40

                    text: Qt.formatDateTime(clock.date, "dddd d MMMM")
                    color: root.dim

                    font.family: "Inter"
                    font.pixelSize: 20
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter

                    implicitWidth: 96
                    implicitHeight: 96

                    radius: width / 2
                    color: Qt.alpha(root.panel, 0.82)
                    border.width: 2
                    border.color: root.accent

                    Image {
                        id: avatar

                        anchors.fill: parent
                        anchors.margins: 3

                        source: root.avatar ? `file://${root.avatar}` : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        layer.enabled: true
                    }

                    MultiEffect {
                        anchors.fill: avatar

                        source: avatar
                        maskEnabled: true
                        maskSource: avatarMask
                    }

                    Rectangle {
                        id: avatarMask

                        anchors.fill: avatar

                        radius: width / 2
                        visible: false
                        layer.enabled: true
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10

                    text: root.user
                    color: root.text

                    font.family: "Inter"
                    font.pixelSize: 18
                    font.bold: true
                }

                Rectangle {
                    id: field

                    Layout.alignment: Qt.AlignHCenter

                    implicitWidth: 320
                    implicitHeight: 46

                    radius: height / 2
                    color: Qt.alpha(root.panel, 0.82)
                    border.width: 1
                    border.color: root.error !== "" ? root.danger : root.accent

                    transform: Translate {
                        id: shake
                    }

                    SequentialAnimation {
                        id: shakeAnimation

                        loops: 2

                        NumberAnimation {
                            target: shake
                            property: "x"
                            to: 10
                            duration: 50
                        }

                        NumberAnimation {
                            target: shake
                            property: "x"
                            to: -10
                            duration: 80
                        }

                        NumberAnimation {
                            target: shake
                            property: "x"
                            to: 0
                            duration: 50
                        }
                    }

                    Connections {
                        target: root

                        function onErrorChanged(): void {
                            if (root.error !== "") {
                                input.clear();
                                shakeAnimation.restart();
                            }
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter

                        text: root.checking ? "hourglass_top" : "lock"
                        color: root.dim

                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 20
                    }

                    TextInput {
                        id: input

                        anchors.fill: parent
                        anchors.leftMargin: 44
                        anchors.rightMargin: 20

                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        focus: surface.main
                        enabled: !root.checking
                        clip: true

                        color: root.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        font.letterSpacing: 2

                        cursorDelegate: Rectangle {
                            width: 2
                            radius: 1
                            color: root.accent
                        }

                        onAccepted: root.submit(text)

                        Keys.onEscapePressed: clear()
                    }

                    Text {
                        anchors.left: input.left
                        anchors.verticalCenter: parent.verticalCenter

                        visible: input.text === ""

                        text: root.checking ? "Logging in…" : "Password"
                        color: root.faint

                        font.family: "Inter"
                        font.pixelSize: 14
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    opacity: root.error !== "" ? 1 : 0

                    text: root.error || " "
                    color: root.danger

                    font.family: "Inter"
                    font.pixelSize: 12
                }
            }

            RowLayout {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 32

                visible: surface.main
                spacing: 8

                Repeater {
                    model: [
                        { icon: "restart_alt", label: "Restart", run: () => Quickshell.execDetached(["systemctl", "reboot"]) },
                        { icon: "power_settings_new", label: "Shut down", run: () => Quickshell.execDetached(["systemctl", "poweroff"]) }
                    ]

                    Rectangle {
                        id: button

                        required property var modelData

                        implicitWidth: row.implicitWidth + 24
                        implicitHeight: 34

                        radius: height / 2
                        color: Qt.alpha(root.panel, area.containsMouse ? 0.95 : 0.7)

                        RowLayout {
                            id: row

                            anchors.centerIn: parent

                            spacing: 6

                            Text {
                                text: button.modelData.icon
                                color: area.containsMouse ? root.accent : root.dim

                                font.family: "Material Symbols Rounded"
                                font.pixelSize: 18
                            }

                            Text {
                                text: button.modelData.label
                                color: area.containsMouse ? root.text : root.dim

                                font.family: "Inter"
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            id: area

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: button.modelData.run()
                        }
                    }
                }
            }
        }
    }
}
