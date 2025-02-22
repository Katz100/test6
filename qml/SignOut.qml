import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SupaQML
import "userData.js" as Data

Page {
    ColumnLayout {
        anchors.fill: parent

        Image {
            source: "qrc:/imgs/royalty-card.png"
            width: 100
            height: 100
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 50
            sourceSize.width: 100
            sourceSize.height: 100
        }

        Label {
            text: "Are you sure you want to sign out?"
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "Sign Out"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            onClicked: {
                auth.sendAuth()
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    SupaAuth {
        id: auth
        projectId: root.projectId
        key: root.key
        authorization: root.jwt
        method: SupaAuth.POST
        endpoint: SupaAuth.LOGOUT

        onMessageReceived: message => {
                                Data.userDetails = {}
                               root.jwt = ""
                               stackView.pop()
                               stackView.pop()
                               stackView.pop()
                           }
    }

}
