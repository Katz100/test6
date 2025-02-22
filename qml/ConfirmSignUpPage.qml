import QtQuick
import QtQuick.Controls
import SupaQML
import "userData.js" as Data

Page {
    title: qsTr("Confirm Sign Up Page")

    Label {
        id: lbl
        text: "A confirmation has been sent to your email."
        anchors.centerIn: parent
    }

    BusyIndicator {
        id: bi
        anchors {top: lbl.bottom; horizontalCenter: parent.horizontalCenter}
        running: true
    }

    SupaSocket {
        id: socket
        sendHeartbeatMessage: true
        projectId: "affixqvkrgfahaizxrhl"
        key: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmZml4cXZrcmdmYWhhaXp4cmhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyNjE0NTIsImV4cCI6MjA0ODgzNzQ1Mn0.eyahwokwXcpwpWdYGCpskVcswqNh9ZzxHpsdiV8gxoM"
        authorization: ""
        Component.onCompleted: {
            socket.openConnection()
        }
        payload: {
            "event": "phx_join",
            "topic": "realtime:public:profiles",
            "ref": "1",
            "payload": {
                "schema": "public",
                "table": "profiles"
            }
        }

        onMessageReceived: message => {
                               if(message.event === "INSERT") {
                                   if (message.payload.record.id === root.tempId) {
                                       //User is confirmed so sign them in.
                                       socket.closeConnection()
                                       auth.body = {
                                           "email": root.tempEmail,
                                           "password": root.tempPassword
                                       }
                                       auth.sendAuth()
                                   }
                               }
                           }
    }

    SupaAuth {
        id: auth
        projectId: root.projectId
        key: root.key
        method: SupaAuth.POST
        endpoint: SupaAuth.SIGNIN
        onMessageReceived: message => {
                               if(message.supabase_status === 404) {
                                   dialog.open()
                               } else if (message.supabase_status === 200) {
                                   Data.userDetails = message
                                   root.jwt = Data.userDetails.access_token
                                   if (Data.userDetails.user.user_metadata.role === "customer") {
                                       stackView.push("CustomerHomePage.qml")
                                   } else {
                                       server.sendFunctionCall()
                                   }
                               } else {
                                   console.log(JSON.stringify(message))
                               }
                           }
    }

    SupaServer {
        id: server
        projectId: root.projectId
        key: root.key
        authorization: root.jwt
        func: "add_user_company"
        parameters: {
            "c_name": settings.store,
            "c_address" : settings.address,
            "c_phone" : settings.phone,
            "c_website": settings.website,
            "c_reward": settings.reward,
            "c_stamps": settings.stamps
        }

        onMessageReceived: stackView.push("CompanyHomePage.qml")
    }

    Dialog {
        id: dialog
        title: "Connection Error"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
    }
}


