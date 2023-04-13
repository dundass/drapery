# drapery

an experimental instrument that maps the movement of hanging textiles to oscillator/filter banks

current tech pipeline: Kinect > Processing > OSC > SuperCollider/Pure Data

the KinectV2 obtains a depth map of the cloth which is then analysed by Processing to create arrays of both absolute and delta depth values. the textile is reduced to 32 block averages, ie it is divided into 8 blocks on the x axis and 4 on the y axis. these are then sent via OSC over to the sound engine.

the sound engine can either be SuperCollider or Pure Data. either one maps the 32 blocks to a bank of 32 oscillators or filters, with the x axis mapped to pan and the absolute depth values mapped to oscillator/filter frequency. the delta or 'relative' values are mapped differently depending on the patch. in one patch, they act as a trigger value to create notes above a threshold. in another, they are mapped to the amplitude of droning oscillators, and/or the duty cycle of each triangle/pulse oscillator.

# todo

try quantising the frequency to chromatic or diatonic scales
buy lots of fans
explore different fabrics
explore using sensors woven into the fabric using Bela Craft
refactor use of 'clone' PD object to allow porting to Organelle/HVCC devices