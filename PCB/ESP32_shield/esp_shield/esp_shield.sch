EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector_Generic:Conn_01x12 J3
U 1 1 5F17CCCE
P 3800 3350
F 0 "J3" H 3880 3342 50  0000 L CNN
F 1 "Conn_01x12" H 3880 3251 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x12_P2.54mm_Vertical" H 3800 3350 50  0001 C CNN
F 3 "~" H 3800 3350 50  0001 C CNN
	1    3800 3350
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_01x16 J1
U 1 1 5F17ED80
P 2550 3150
F 0 "J1" H 2468 4067 50  0000 C CNN
F 1 "Conn_01x16" H 2468 3976 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x16_P2.54mm_Vertical" H 2550 3150 50  0001 C CNN
F 3 "~" H 2550 3150 50  0001 C CNN
	1    2550 3150
	-1   0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_01x10 J2
U 1 1 5F182893
P 3200 4650
F 0 "J2" V 3325 4596 50  0000 C CNN
F 1 "Conn_01x10" V 3416 4596 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x10_P2.54mm_Vertical" H 3200 4650 50  0001 C CNN
F 3 "~" H 3200 4650 50  0001 C CNN
	1    3200 4650
	0    -1   1    0   
$EndComp
$Comp
L power:GND #PWR0101
U 1 1 5F1847DE
P 3700 4450
F 0 "#PWR0101" H 3700 4200 50  0001 C CNN
F 1 "GND" V 3705 4322 50  0000 R CNN
F 2 "" H 3700 4450 50  0001 C CNN
F 3 "" H 3700 4450 50  0001 C CNN
	1    3700 4450
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 5F184F27
P 2750 2750
F 0 "#PWR0102" H 2750 2500 50  0001 C CNN
F 1 "GND" V 2755 2622 50  0000 R CNN
F 2 "" H 2750 2750 50  0001 C CNN
F 3 "" H 2750 2750 50  0001 C CNN
	1    2750 2750
	0    -1   -1   0   
$EndComp
Text GLabel 2750 3650 2    50   Input ~ 0
MISO
NoConn ~ 2750 3750
NoConn ~ 2750 3850
NoConn ~ 2750 3950
Text GLabel 3600 2850 0    50   Input ~ 0
BAT
Text GLabel 2750 2550 2    50   Input ~ 0
3.3V
NoConn ~ 2750 2450
NoConn ~ 2750 2650
Text GLabel 2750 3550 2    50   Input ~ 0
MOSI
Text GLabel 2750 3450 2    50   Input ~ 0
SCK
Text GLabel 3600 3750 0    50   Input ~ 0
CS_ADC
Text GLabel 3600 3650 0    50   Input ~ 0
CS_DAC
Text GLabel 3600 3550 0    50   Input ~ 0
CS_IMU2
Text GLabel 3600 3450 0    50   Input ~ 0
CS_IMU1
NoConn ~ 2750 2850
NoConn ~ 2750 2950
NoConn ~ 2750 3050
NoConn ~ 2750 3150
NoConn ~ 2750 3250
NoConn ~ 2750 3350
NoConn ~ 3600 2950
NoConn ~ 3600 3050
NoConn ~ 3600 3150
NoConn ~ 3600 3250
NoConn ~ 3600 3350
NoConn ~ 3600 3850
NoConn ~ 3600 3950
Text GLabel 3600 4450 1    50   Input ~ 0
BAT
Text GLabel 3500 4450 1    50   Input ~ 0
3.3V
Text GLabel 3400 4450 1    50   Input ~ 0
CS_IMU1
Text GLabel 3300 4450 1    50   Input ~ 0
CS_IMU2
Text GLabel 3200 4450 1    50   Input ~ 0
CS_DAC
Text GLabel 3100 4450 1    50   Input ~ 0
CS_ADC
Text GLabel 2800 4450 1    50   Input ~ 0
MOSI
Text GLabel 2900 4450 1    50   Input ~ 0
MISO
Text GLabel 3000 4450 1    50   Input ~ 0
SCK
$EndSCHEMATC
