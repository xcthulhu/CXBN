/* ACS Machine Interface Primitives */

/**** Sensors ****/

/*** Geometry Convention ***/
/*  * The center of the coordinate system is the center of mass

    * Z-axis determined by spacecraft center
      through face with mounted sun sensors

    * X-axis determined by line orthogonal to Z-axis
      through face with mounted Canopus pipper
    
    * Y-axis orthogonal X-axis and Z-axis */


///// Mems Gyros Output
// OUTPUT: signed 16 bit integer
// UNIT: 0.05 Degrees/Second
// NOTES:
//   X gyro measures rotation around Y-Z plane
//   Y gyro measures rotation around X-Z plane
//   Z gyro measures rotation around X-Y plane
int16 xgyro();
int16 ygyro();
int16 zgyro();

///// Accelerometer Output
// OUTPUT: signed 16 bit integer
// UNIT: 10^(-3) * g (earth's gravitation)
// NOTES:
//   The instantaneous angular vector for 
//   the spacecraft is:
//   <xaccl(), yaccl(), zaccl()> 
int16 xaccl();
int16 yaccl();
int16 zaccl();

///// Accelerometer Output
// OUTPUT: signed 16 bit integer
// UNIT: 10^(-3) * mgauss
int16 xmagn();
int16 ymagn();
int16 zmagn();

///// Sun Sensor

/// Two sensors: Coarse and Fine
/// Aligned along X and Y axes


// Acquire quadrant of sun
// OUTPUT: Unsigned Int
// UNIT: Quadrant
// NOTES: 
//   Quadrant follows integer code
//   Spec:
//   Quadrant   |   Sign of X   |   Sign of Y
//   ---------------------------------------- 
//        1     |      +X       |    +Y
//        2     |      -X       |    +Y
//        3     |      -X       |    -Y
//        4     |      +X       |    -Y

unsigned int quadcoarse();
unsigned int quadfine();

// Acquire angle of sun from sensor center
// OUTPUT: Unsigned Int
// UNIT: .5 Degrees
// NOTES:
//   Coarse range: 0 to 45 Degrees
//   Fine range: 0 to 15 Degrees
unsigned int coarseangle();
unsigned int fineangle();


/**** Actuators ****/

//// Magtorquer PWM
// (Effective) range: 0 to 5 Volts
// INPUT: Unsigned 16 bit integer
// UNIT: PWM duty cycle

void setxmagt(uint16 xduty);
void setymagt(uint16 yduty);
void setzmagt(uint16 zduty);
