debImport "-f" "filelist.f" "-sverilog"
debLoadSimResult /home/zjh/ic_prj/asic/fft/sim/tb.fsdb
wvCreateWindow
debExit
                                                                                                                                                                                                                                       srcDeselectAll -win $_nTrace1
debReload
wvSetCursor -win $_nWave2 17948.019264 -snap {("G2" 0)}
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetRadix -win $_nWave2 -2Com
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetRadix -win $_nWave2 -format UDec
wvBusWaveform -win $_nWave2 -analog
wvSetPosition -win $_nWave2 {("G1" 1)}
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
debReload
wvSetCursor -win $_nWave2 13047.688568 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 13060.841480 -snap {("G1" 1)}
wvZoom -win $_nWave2 12666.254124 13231.829334
wvSetCursor -win $_nWave2 13000.467218 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 12994.998659 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 12960.151840 -snap {("G2" 0)}
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 21551.630549 -snap {("G2" 0)}
debExit
