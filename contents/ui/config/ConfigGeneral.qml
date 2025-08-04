import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_filterBeta: updateBetaSpinBox.value
    property alias cfg_showPercent: showPercent.checked

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        
        Label {
            text: i18n('Update interval:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: updateIntervalSpinBox
            decimals: 1
            stepSize: 0.1
            minimumValue: 0.1
            suffix: i18nc('Abbreviation for seconds', 's')
        }
        
        Label {
            text: i18n('Filter beta:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: updateBetaSpinBox
            decimals: 2
            stepSize: 0.01
            minimumValue: 0.01
            maximumValue: 1.00
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        CheckBox {
            id: showPercent
            Layout.columnSpan: 2
            text: i18n('Show percentage')
            visible: true
        }
    }
}
