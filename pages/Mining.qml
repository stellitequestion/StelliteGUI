// Copyright (c) 2014-2018, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../components" as MoneroComponents
import moneroComponents.Wallet 1.0

Rectangle {
    id: root
    color: "transparent"
    property double currentHashRate: 0

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40 * scaleRatio
        spacing: 20 * scaleRatio
        Layout.fillWidth: true

        MoneroComponents.Label {
            id: soloTitleLabel
            fontSize: 24 * scaleRatio
            text: qsTr("Solo mining") + translationManager.emptyString
        }

        MoneroComponents.Label {
            id: soloLocalDaemonsLabel
            fontSize: 18 * scaleRatio
            color: "#D02020"
            text: qsTr("(only available for local daemons)") + translationManager.emptyString
            visible: !walletManager.isDaemonLocal(appWindow.currentDaemonAddress)
        }

        MoneroComponents.Label {
            id: soloSyncedLabel
            fontSize: 18 * scaleRatio
            color: "#D02020"
            text: qsTr("Your daemon must be synchronized before you can start mining") + translationManager.emptyString
            visible: walletManager.isDaemonLocal(appWindow.currentDaemonAddress) && !appWindow.daemonSynced
        }

        Text {
            id: soloMainLabel
            text: qsTr("Mining with your computer helps strengthen the Monero network. The more that people mine, the harder it is for the network to be attacked, and every little bit helps.<br> <br>Mining also gives you a small chance to earn some Monero. Your computer will create hashes looking for block solutions. If you find a block, you will get the associated reward. Good luck!") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14 * scaleRatio
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.WarningBox {
            id: warningLabel
            Layout.topMargin: 8 * scaleRatio
            Layout.bottomMargin: 8 * scaleRatio
            text: qsTr("Mining may reduce the performance of other running applications and processes.") + translationManager.emptyString
        }

        RowLayout {
            id: soloMinerThreadsRow

            MoneroComponents.Label {
                id: soloMinerThreadsLabel
                color: MoneroComponents.Style.defaultFontColor
                text: qsTr("CPU threads") + translationManager.emptyString
                fontSize: 16 * scaleRatio
                Layout.preferredWidth: 120 * scaleRatio
            }

            MoneroComponents.LineEdit {
                id: soloMinerThreadsLine
                Layout.preferredWidth:  200 * scaleRatio
                text: "1"
                validator: IntValidator { bottom: 1; top: numberMiningThreadsAvailable }
            }
        }

        Text {
            id: numAvailableThreadsText
            text: qsTr("Max # of CPU threads available for mining: ") + numberMiningThreadsAvailable + translationManager.emptyString
            wrapMode: Text.wrapMode
            Layout.leftMargin: 125 * scaleRatio
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14 * scaleRatio
            color: MoneroComponents.Style.defaultFontColor
        }

        RowLayout {
            Layout.leftMargin: 125 * scaleRatio

            MoneroComponents.StandardButton {
                id: autoRecommendedThreadsButton
                small: true
                text: qsTr("Use recommended # of threads") + translationManager.emptyString
                enabled: startSoloMinerButton.enabled
                onClicked: {
                        soloMinerThreadsLine.text = Math.floor(numberMiningThreadsAvailable / 2);
                        appWindow.showStatusMessage(qsTr("Set to use recommended # of threads"),3)
                }
            }

            MoneroComponents.StandardButton {
                id: autoSetMaxThreadsButton
                small: true
                text: qsTr("Use all threads") + translationManager.emptyString
                enabled: startSoloMinerButton.enabled
                onClicked: {
                    soloMinerThreadsLine.text = numberMiningThreadsAvailable
                    appWindow.showStatusMessage(qsTr("Set to use all threads"),3)
                }
            }
        }

        RowLayout {
            Layout.leftMargin: 125 * scaleRatio
            MoneroComponents.CheckBox {
                id: backgroundMining
                enabled: startSoloMinerButton.enabled
                checked: persistentSettings.allow_background_mining
                onClicked: {persistentSettings.allow_background_mining = checked}
                text: qsTr("Background mining (experimental)") + translationManager.emptyString
            }
        }

        RowLayout {
            // Disable this option until stable
            visible: false
            Layout.leftMargin: 125 * scaleRatio
            MoneroComponents.CheckBox {
                id: ignoreBattery
                enabled: startSoloMinerButton.enabled
                checked: !persistentSettings.miningIgnoreBattery
                onClicked: {persistentSettings.miningIgnoreBattery = !checked}
                text: qsTr("Enable mining when running on battery") + translationManager.emptyString
            }
        }

        RowLayout {
            MoneroComponents.Label {
                id: manageSoloMinerLabel
                color: MoneroComponents.Style.defaultFontColor
                text: qsTr("Manage miner") + translationManager.emptyString
                fontSize: 16 * scaleRatio
                Layout.preferredWidth: 120 * scaleRatio
            }

            MoneroComponents.StandardButton {
                visible: true
                id: startSoloMinerButton
                width: 110 * scaleRatio
                small: true
                text: qsTr("Start mining") + translationManager.emptyString
                onClicked: {
                    var success = walletManager.startMining(appWindow.currentWallet.address(0, 0), soloMinerThreadsLine.text, persistentSettings.allow_background_mining, persistentSettings.miningIgnoreBattery)
                    if (success) {
                        update()
                    } else {
                        errorPopup.title  = qsTr("Error starting mining") + translationManager.emptyString;
                        errorPopup.text = qsTr("Couldn't start mining.<br>")
                        if (!walletManager.isDaemonLocal(appWindow.currentDaemonAddress))
                            errorPopup.text += qsTr("Mining is only available on local daemons. Run a local daemon to be able to mine.<br>")
                        errorPopup.icon = StandardIcon.Critical
                        errorPopup.open()
                    }
                }
            }

            MoneroComponents.StandardButton {
                visible: true
                id: stopSoloMinerButton
                width: 110 * scaleRatio
                small: true
                text: qsTr("Stop mining") + translationManager.emptyString
                onClicked: {
                    walletManager.stopMining()
                    update()
                }
            }
        }

        RowLayout {
            id: statusRow

            MoneroComponents.Label {
                id: statusLabel
                color: MoneroComponents.Style.defaultFontColor
                text: qsTr("Status") + translationManager.emptyString
                fontSize: 10 * scaleRatio
                Layout.preferredWidth: 120 * scaleRatio
            }

            MoneroComponents.LineEdit {
                id: statusText
                Layout.preferredWidth:  200 * scaleRatio
                text: qsTr("Not mining") + translationManager.emptyString
                borderDisabled: true
                readOnly: true
            }
        }
    }

    function updateStatusText() {
        if (walletManager.isMining()) {
            statusText.text = qsTr("Mining at %1 H/s").arg(walletManager.miningHashRate()) + translationManager.emptyString;
        }
        else {
            statusText.text = qsTr("Not mining") + translationManager.emptyString;
        }
    }

    function update() {
        updateStatusText()
        startSoloMinerButton.enabled = !walletManager.isMining()
        stopSoloMinerButton.enabled = !startSoloMinerButton.enabled
        appWindow.isMining = walletManager.isMining()
    }

    MoneroComponents.StandardDialog {
        id: errorPopup
        cancelVisible: false
    }

    Timer {
        id: timer
        interval: 2000; running: false; repeat: true
        onTriggered: update()
    }

    function onPageCompleted() {
        console.log("Mining page loaded");
        update()
        timer.running = walletManager.isDaemonLocal(appWindow.currentDaemonAddress)
    }

    function onPageClosed() {
        timer.running = false
    }
}
