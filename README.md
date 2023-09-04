# drapery

an experimental instrument that maps the movement of hanging textiles to oscillator/filter banks

current tech pipeline: Kinect > Processing > OSC > SuperCollider/Pure Data

the KinectV2 obtains a depth map of the cloth which is then analysed by Processing to create arrays of both absolute and delta depth values. the textile is reduced to 32 block averages, ie it is divided into 8 blocks on the x axis and 4 on the y axis. these are then sent via OSC over to the sound engine.

the sound engine can either be SuperCollider or Pure Data, though the former is more developed and tested. either one maps the 32 blocks to a bank of 32 oscillators or filters, with the x axis mapped to pan and the absolute depth values mapped to oscillator/filter frequency. the delta or 'relative' values are mapped differently depending on the patch. in one patch, they act as a trigger value to create notes above a threshold. in another, they are mapped to the amplitude of droning oscillators, and/or the duty cycle of each triangle/pulse oscillator.

# todo

- explore different fabrics
- explore using sensors woven into the fabric using Bela Craft
- try micing up the sheet/fan/floor/voice
- explore crowd participation/installation potential
- see if cellular automata could be integrated
- investigate other SynthDefs eg resonators, chime-like, pitched noise
- refactor use of 'clone' PD object to allow porting to Organelle/HVCC devices

# ways to play

- start with just fan noise and eg a gong
- start with just a sheet drone and no fan
- start with pegging the sheet up
- peg bells onto the sheet to act as anchors and sounds
- move in amongst the sheet
- peg corners of the sheet to things
- make fans oscillate
- ripple the sheet with hands
- wear a long gown to become part of the fabric
- peg garments/ribbons to sheet
- end with throwing hand sporadically in front of kinect sensor to trigger loud noise bursts
- end with unpegging the sheet
- alter mappings and synth params to create long form section changes
- change alignment of sheet/performer/audience to reveal performer or blow air onto audience

# cellular automata

- allow the depth feed to influence CA layer(s) which then evolve and elaborate on the shape of the sheet
- this enables multiple mappings/sound engines to be run from differing but related streams, and altering/toggling these mappings will make it more expressive
- the fact that CA must be clocked can give the performances a rhythmic element, unless the clock speed is super high. alternatively, a threshold of total delta movement could be used to trigger the CA