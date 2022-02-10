# FPGA Smart Home
### Digital System Design **- Mechatronics course -**  project  
The aim of the project is to design two system models controlled by
the Spartan3E FPGA board for smart home automation: fire detection
and door passcode detection models. The FPGA board is
programmed using VHDL to work as the core control of the two models
based on external inputs.
## Project Components and sensors

| Component code |no. used | description |
| ------------- | ------------- | ------------- |
| SG90 servo |2 |Micro servo motor 9g high accuracy with feed correction contains its gear box for higher torque small in size  |
|HLS-407-H-DC3v| 1 | 3v relay to open the 220V valve|
| LM35NZ | 1 | Analog heat sensor |
| water valve| 1| Responsible for open or close according to sensor read|
| 4x4 keypad| 1| Used to enter the password to open the door through a signal to the motor|

## Circuit connection
### Fire alarm system:
the temperature sensor is an analog outputsignal sensor
The analog LM35 sensor outputs a change of 10 mV per degree
Celsius and thus the output had to be amplified by an external
amplifying circuit of gain 6.25 and then supplied into the ADC
of the Xilinx to read an analog signal and convert it into a 14
bit signal to be used further in our project. The 14 bit signal
is then referenced to a certain temperature value we chose to
be convenient for the use of the model, but in real life applica-
tion this value should be much larger. When the temperature
exceeds the reference temperature, the FPGA sends signals to
the alarm system, consisting of a buzzer and LEDs, and the
water valve, these signals remain on until the temperature de-
creases below the reference. The water valve is controlled by
the means of a relay
### Lock system :
keypad has a 4 in 4 out pins responsible for the
columns and rows. one servo is responsible to open the door and
another work as a lock
once a button is pressed the row and the columns connected
through this button a high logic one and throw the VHDL
code we detect this signal and take it as a password number
once the password is correct and the servos get it’s signals
from the FPGA and a button will close the door.
## FPGA Connections
To replicate this project use the [pin out map](https://github.com/s3dky/FPGA_Smart_Home/blob/main/pin_out_map.md) as a guide 
