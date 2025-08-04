/*
 * Copyright 2021  Dimitri Bouras <dimitrios.bouras@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kio 1.0 as Kio

Item {
    id: main
    
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    
    property bool showPercent: plasmoid.configuration.showPercent
    
    property double parentHeight: parent === null ? 0 : parent.height
    property double itemWidth:  parentHeight
    property double itemHeight: itemWidth
    property double fontPixelSize: itemHeight * 0.26
    property int graphRes: 30
    property int graphMargin: 2
    property double graphHeight: itemHeight - 2*graphMargin
    property double fSysLoad: 0.0
    property double fTotLoad: 0.0
    
    property color warningColor: Qt.tint(theme.textColor, '#60FF0000')
    property color sysColor: '#800002' // '#6F0000'
    property color totColor: '#074080' // '#3DAEE9'
    property string textFontFamily: theme.defaultFont.family
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
    anchors.fill: parent
    
    Kio.KRun {
        id: kRun
    }
    
    // We need to get the full path to KSysguard to be able to run it
    PlasmaCore.DataSource {
        id: apps
        engine: 'apps'
        property string ksysguardSource: 'org.kde.ksysguard.desktop'
        connectedSources: [ ksysguardSource ]
    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: "systemmonitor"

        property string cpuSystem: "cpu/system/"
        property string userLoad: cpuSystem + "user"
        property string totalLoad: cpuSystem + "TotalLoad"

        property double usrCpuLoad: 0.0
        property double sysCpuLoad: 0.0
        property double totCpuLoad: 0.0
        property double beta: plasmoid.configuration.filterBeta

        connectedSources: [userLoad, totalLoad]
        
        onNewData: {
            if (data.value === undefined) {
                return
            }
            else if (sourceName == userLoad) {
                usrCpuLoad = data.value / 100.0
            }
            else if (sourceName == totalLoad) {
                totCpuLoad = data.value / 100.0
                sysCpuLoad = totCpuLoad - usrCpuLoad
                fTotLoad = totCpuLoad*beta + fTotLoad*(1.0-beta)
                fSysLoad = sysCpuLoad*beta + fSysLoad*(1.0-beta)
                updateGraph()
            }
        }
        interval: 1000 * plasmoid.configuration.updateInterval
    }
    
    ListModel {
        id: cpuGraphModel
    }
    
    function updateGraph() {
        
        //var sysCpuRatio = dataSource.sysCpuLoad
        //var totCpuRatio = dataSource.totCpuLoad
        var sysCpuRatio = fSysLoad
        var totCpuRatio = fTotLoad
        
        cpuPercentText.text = Math.round(totCpuRatio * 100) + '%'
        cpuPercentText.color = totCpuRatio > 0.9 ? warningColor : theme.textColor
        
        addGraphData(cpuGraphModel, sysCpuRatio*graphHeight, totCpuRatio*graphHeight)
    }
    
    function addGraphData(model, system, total) {
        
        // Fill left to right
        while (model.count < graphRes) {
            model.append({'graphSys': 0, 'graphTot': 0})
        }
        // Load new data point
        var newItem = {
            'graphSys': system,
            'graphTot': total
        }
        // Scroll left: append new item, remove leftmost one
        model.append(newItem)
        model.remove(0)
    }
    
    onShowPercentChanged: {
        cpuPercentText.visible = showPercent
    }
    
    Item {
        id: cpuMonitor
        width: itemWidth
        height: itemHeight
        
        visible: true
        
        HistoryGraph {
            anchors.fill: parent
            listViewModel: cpuGraphModel
            sColor: sysColor
            tColor: totColor
        }
        
        Item {
            id: cpuTextContainer
            anchors.fill: parent
            
            PlasmaComponents.Label {
                id: cpuPercentText
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                text: '...'
                font.pixelSize: fontPixelSize
                visible: showPercent
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            kRun.openService("org.kde.ksysguard")
        }
    }
}

