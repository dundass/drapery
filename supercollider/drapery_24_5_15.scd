
OSCFunc.trace(false); // prints every incoming message to SC

OSCdef.freeAll; // help, purge !!

(  /* SYNTHDEFS */

// drones

SynthDef.new(\drone_osc, {
	arg freq=100, pan=0, amp=0.025, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	//env = EnvGen.kr(Env.perc(0.01,1), doneAction:2); // sig = osc * env
	sig = SinOsc.ar(freq, 0, amp);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\drone_tri, {
	arg freq=100, pan=0, amp=0.025, duty=0.5, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	//env = EnvGen.kr(Env.perc(0.01,1), doneAction:2); // sig = osc * env
	sig = VarSaw.ar(freq, 0, 0.5, amp);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\drone_pulse, {
	arg freq=100, pan=0, amp=0.025, duty=0.5, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	//env = EnvGen.kr(Env.perc(0.1,1), doneAction:2); // sig = osc * env
	sig = Pulse.ar(freq, duty, amp);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\drone_noise_bpf, {
	arg freq=100, pan=0, amp=0.025, res=0.5, out=0;
	var sig;
	freq = freq.clip(20, 20000);
	res = res.clip(0.025, 2);
	sig = BPF.ar(PinkNoise.ar(amp), freq, res);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\drone_fuzz, {
	arg freq=100, pan=0, amp=0.025, out=0;
	var sig;
	freq = freq.clip(50, 200);
	sig = Crackle.ar(freq/100, amp);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\drone_formant, {
	arg freq=100, pan=0, amp=0.025, res=400, out=0;
	var sig;
	freq = freq.clip(20, 2000);
	res = res.clip(20, 20000);
	sig = Formant.ar(freq, res, 2000, amp);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\drone_formant_noisy, {
	arg freq=100, pan=0, amp=0.025, res=400, out=0;
	var sig;
	freq = freq.clip(20, 2000);
	res = res.clip(20, 20000);
	sig = Mix.new([Formant.ar(freq, res, 2000, amp), BPF.ar(PinkNoise.ar(amp), freq, 0.5)]);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\drone_noisering, {
	arg freq=100, pan=0, amp=0.025, res=0.5, out=0;
	// i have no idea how to pitch this lol
	var sig;
	res = res.clip(0,1);
	sig = Demand.ar(Impulse.ar(5000), 0, DNoiseRing(change: res, chance: 0.51, numBits: 32)) * (2**32).reciprocal;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;

// trigs

SynthDef(\fmbell, { arg out=0, amp=0.1, pan=0, freq=200, decay=1;
	var sig;
	var sig1, sig2, sig3, sig4, sig5, sig6;
	freq = freq * EnvGen.kr(Env([1,1.002,0.998,1],[0.1,0.8]), 1, timeScale:decay);
	sig1 = SinOsc.ar(freq * 2.6706 + 0.13) * 2 + 1;
	sig2 = SinOsc.ar(freq * 0.9998 * sig1);
	sig3 = SinOsc.ar(freq * 2.6629 * sig1 + 2.04);
	//sig4 = SinOsc.ar(freq * 0.9991 * sig1 + 2.14);
	//sig = sig2 + sig3 + sig4;
	sig = [sig1, sig2, sig3] * DC.ar([0,0.5,0.5]);
	//sig.debug("sig");
	//sig = sig /34;
	sig = sig * EnvGen.ar(Env.perc(0.1,2),doneAction:2);
	sig = Pan2.ar(sig, pan, amp).sum;
	Out.ar(out, sig);
}).add;

SynthDef.new(\osc, {
	arg freq=100, pan=0, amp=0.05, duty=0, decay=2, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.1,decay), doneAction:2);
	sig = SinOsc.ar(freq, duty, amp) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\tri, {
	arg freq=100, pan=0, amp=0.05, duty=0.5, decay=1, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.1,decay), doneAction:2);
	sig = VarSaw.ar(freq, 0, duty, amp) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\pulse, {
	arg freq=100, pan=0, amp=0.05, duty=0.5, decay=1.5, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.1,decay), doneAction:2);
	sig = Pulse.ar(freq, duty, amp) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\bell, { |out, freq=200, accent=0, pan=0, amp=0.1, decay=2|
    var exc = PinkNoise.ar(amp)
    * Decay2.kr(Impulse.kr(0), 0.01, 0.05),
    sig = Klank.ar(`[
		[freq, ExpRand(freq*2, freq*4), ExpRand(freq*2, freq*4)],
		[1,0.5,0.5],
        { ExpRand(0.1, 0.4) } ! 3
    ], exc, freqscale: accent + 1, decayscale: decay);
    DetectSilence.ar(sig, doneAction: Done.freeSelf);
	sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;

SynthDef.new(\ring, {
	arg freq=100, pan=0, amp=0.05, duty=0, decay=2, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.ar(Env.perc(0.1,decay,amp*5), doneAction:2);
	sig = Ringz.ar(env, freq, decay);
	sig = HPF.ar(sig, freq);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\burst, {
	arg freq=100, pan=0, amp=0.5, duty=1, decay=1, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.step([1, 0], [decay, 0]), doneAction:2);
	sig = PinkNoise.ar(amp) * env;
	sig = BPF.ar(sig, freq, duty);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

/* THE TRIG SYNTH FREQUENCY ARRAY */

~x_size = 8;
~y_size = 4;

~abs_depths = Array.fill(~x_size * ~y_size, { 0.0 });

)

(  /* WIND DRONE */

~x_size = 8;
~y_size = 4;

~dronebank.do({|synth|
	synth.free;
});

~dronebank = Array.fill(~x_size * ~y_size, {
	arg i;
	Synth.new(\drone_noise_bpf, [
		freq: 100 + (i * 2),
		res: (i+1)/32
	]);
});

OSCdef.new(\abs_drone, { // absolute depth values - set the synth freqs
	arg msg, time, addr, port;
	~dronebank[msg[1]].set(\freq, (msg[2]**2) * 20000);
}, '/absolute');

OSCdef.new(\rel_drone, { // delta depth values
	arg msg, time, addr, port;
	// for \drone_noise_bpf:
	~dronebank[msg[1]].set(\amp, 0.7 + (msg[2] * 5));
	~dronebank[msg[1]].set(\res, 0.25 + (msg[2] * 1));
	//~dronebank[msg[1]].set(\duty, 0.25+(msg[2]/5)); // for osc, tri, pulse
}, '/relative');

OSCdef.new(\ids_drone, { // index array - set the pan values of the synths
	arg msg, time, addr, port;
	msg.postln;
	~dronebank[msg[1]].set(\pan, 1 - (2 * msg[1]%~x_size));
}, '/ids');

)

(  /* FORMANT DRONE */

~x_size = 8;
~y_size = 4;

~dronebank.do({|synth|
	synth.free;
});

~dronebank = Array.fill(~x_size * ~y_size, {
	arg i;
	Synth.new(\drone_formant_noisy, [
		freq: 100 + (i * 20),
		res: 200 + (i * 40)
	]);
});

OSCdef.new(\abs_drone, { // absolute depth values - set the synth freqs
	arg msg, time, addr, port;
	~dronebank[msg[1]].set(\freq, (msg[2]**2) * 6000);
	~dronebank[msg[1]].set(\res, (msg[2]**1.25) * 12000);
}, '/absolute');

OSCdef.new(\rel_drone, { // delta depth values
	arg msg, time, addr, port;
	~dronebank[msg[1]].set(\amp, 0.15+(msg[2]/5));
	//~dronebank[msg[1]].set(\res, (msg[2]**1) * 10000); // moved to \abs

	//~dronebank[msg[1]].set(\duty, 0.25+(msg[2]/5)); // for osc, tri, pulse
}, '/relative');

OSCdef.new(\ids_drone, { // index array - set the pan values of the synths
	arg msg, time, addr, port;
	msg.postln;
	~dronebank[msg[1]].set(\pan, 1 - (2 * msg[1]%~x_size));
}, '/ids');

)

(  /* PULSE DRONE */

~x_size = 8;
~y_size = 4;

~dronebank.do({|synth|
	synth.free;
});

~dronebank = Array.fill(~x_size * ~y_size, {
	arg i;
	Synth.new(\drone_pulse, [
		freq: 100 + (i * 20),
		duty: (i * 40) / 40
	]);
});

OSCdef.new(\abs_drone, { // absolute depth values - set the synth freqs
	arg msg, time, addr, port;
	~dronebank[msg[1]].set(\freq, (msg[2]**2) * 25000);
}, '/absolute');

OSCdef.new(\rel_drone, { // delta depth values
	arg msg, time, addr, port;
	~dronebank[msg[1]].set(\amp, 0.16+(msg[2]/5));
	~dronebank[msg[1]].set(\duty, 0.2+(msg[2]/2)); // for osc, tri, pulse
}, '/relative');

OSCdef.new(\ids_drone, { // index array - set the pan values of the synths
	arg msg, time, addr, port;
	msg.postln;
	~dronebank[msg[1]].set(\pan, 1 - (2 * msg[1]%~x_size));
}, '/ids');

)

(  /* TRI DRONE */

~x_size = 8;
~y_size = 4;

~dronebank.do({|synth|
	synth.free;
});

~dronebank = Array.fill(~x_size * ~y_size, {
	arg i;
	Synth.new(\drone_tri, [
		freq: 100 + (i * 20),
		duty: (i * 40) / 40
	]);
});

OSCdef.new(\abs_drone, { // absolute depth values - set the synth freqs
	arg msg, time, addr, port;
	~dronebank[msg[1]].set(\freq, (msg[2]**2) * 10000);
}, '/absolute');

OSCdef.new(\rel_drone, { // delta depth values
	arg msg, time, addr, port;
	~dronebank[msg[1]].set(\amp, 0.05+(msg[2]/5));
	~dronebank[msg[1]].set(\duty, 0.4+(msg[2]/10)); // for osc, tri, pulse
}, '/relative');

OSCdef.new(\ids_drone, { // index array - set the pan values of the synths
	arg msg, time, addr, port;
	msg.postln;
	~dronebank[msg[1]].set(\pan, 1 - (2 * msg[1]%~x_size));
}, '/ids');

)

(  /* KILL DRONES */
~dronebank.do({|synth|
	synth.free;
});
OSCdef.new(\abs_drone, {}, '/absolute');
OSCdef.new(\rel_drone, {}, '/relative');
OSCdef.new(\ids_drone, {}, '/ids');
)

(  /* KILL TRIGS */
OSCdef.new(\abs, {}, '/absolute');
OSCdef.new(\rel, {}, '/relative');
OSCdef.new(\ids, {}, '/ids');
)


(  /* BURST TRIG */

OSCdef.new(\abs, { // absolute depth values - save for trig later
	arg msg, time, addr, port;
	~abs_depths[msg[1]] = msg[2]; // msg[1] = index; msg[2] = abs depth
}, '/absolute');

OSCdef.new(\rel, { // delta depth values - trigger the synths
	arg msg, time, addr, port;
	// msg[1] = index; msg[2] = rel depth
	var y_coordinate = msg[1] / ~y_size;
	y_coordinate = y_coordinate.floor;
	if(msg[2] > 0.04, {
		var freq = 30 + (y_coordinate * 500);
		var decay = 0.1 + (~abs_depths[msg[1]] * 2);
		Synth.new(\burst, [
			freq: freq,
			pan: 1 - (2 * (msg[1]%~x_size) / ~x_size),
			amp: 0.3 + (msg[2] / 10),
			decay: decay
		]);
		msg[2].postln;
	});
	//msg.postln;
}, '/relative');

OSCdef.new(\ids, { // index array - sent as part of init
	arg msg, time, addr, port;
	msg.postln;
}, '/ids');

)

(  /* GLASS TRIG */

OSCdef.new(\abs, { // absolute depth values - save for trig later
	arg msg, time, addr, port;
	~abs_depths[msg[1]] = msg[2]; // msg[1] = index; msg[2] = abs depth
}, '/absolute');

OSCdef.new(\rel, { // delta depth values - trigger the synths
	arg msg, time, addr, port;
	// msg[1] = index; msg[2] = rel depth
	var y_coordinate = msg[1] / ~y_size;
	y_coordinate = y_coordinate.floor;
	if(msg[2] > 0.04, {
		/*var freq = (~abs_depths[msg[1]]*1.75) * 20000;
		Synth.new(\tri, [
			//freq: (~abs_depths[msg[1]]**2) * 20000,
			//freq: (~abs_depths[msg[1]]*0.6) * 20000,
			freq: freq,
			//freq: (~abs_depths[msg[1]]**0.75) * 20000,
			pan: 1 - (2 * (msg[1]%~x_size) / ~x_size),
			amp: 0.025 + (msg[2] / 10),
			duty: 0.1 + (y_coordinate / 10)
		]);*/
		/*var freq = (~abs_depths[msg[1]]*1.75) * 20000;
		Synth.new(\ring, [
			freq: freq,
			pan: 1 - (2 * (msg[1]%~x_size) / ~x_size),
			amp: 0.25 + (msg[2] * 10),
			decay: 0.1 + (y_coordinate * 1)
		]);*/
		//var freq = (~abs_depths[msg[1]]**2) * 20000;
		//var freq = (~abs_depths[msg[1]]*0.075) * 10000;
		var freq = (~abs_depths[msg[1]]*1.75) * 20000;
		Synth.new(\bell, [
			freq: freq,
			pan: 1 - (2 * (msg[1]%~x_size) / ~x_size),
			amp: 0.01 + (msg[2] / 10),
			decay: 0.1 + (y_coordinate * 2)
		]);
		/*var freq = (~abs_depths[msg[1]]*0.2) * 8000;
		//var freq = (~abs_depths[msg[1]]**2) * 20000;
		Synth.new(\fmbell, [
			freq: freq,
			pan: 1 - (2 * (msg[1]%~x_size) / ~x_size),
			amp: 0.025 + (msg[2] / 10),
			decay: 0.1 + (y_coordinate * 2)
		]);*/
		msg[2].postln;
	});
	//msg.postln;
}, '/relative');

OSCdef.new(\ids, { // index array - sent as part of init
	arg msg, time, addr, port;
	msg.postln;
}, '/ids');

)

(  /* BELL TRIG */

//~scale = [0,1,12,13];
//~scale = [0,2,3,7,8,12];
//~scale = [0,2,3,7,8,12,14,15];
//~scale = [0,1,3,4,6,7,9,11,12];
~scale = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
//~noffset = 48;
//~noffset = 36;
~noffset = 60;

OSCdef.new(\abs, { // absolute depth values - save for trig later
	arg msg, time, addr, port;
	~abs_depths[msg[1]] = msg[2]; // msg[1] = index; msg[2] = abs depth
}, '/absolute');

OSCdef.new(\rel, { // delta depth values - trigger the synths if > threshold
	arg msg, time, addr, port; // msg[1] = index; msg[2] = rel depth
	var x_coordinate = msg[1] % ~x_size;
	var y_coordinate = (msg[1] / ~y_size).floor;
	var note = (~noffset + msg[1]).degreeToKey(~scale);
	if(msg[2] > 0.03, {
		Synth.new(\bell, [
			freq: note.midicps,
			pan: 1 - (2 * (msg[1]%~x_size) / ~x_size),
			amp: 0.001 + (~abs_depths[msg[1]] / 10),
			decay: 0.1 + (y_coordinate * 2)
		]);
		note.postln;
	});
	//msg.postln;
}, '/relative');

OSCdef.new(\ids, { // index array - sent as part of init
	arg msg, time, addr, port;
	msg.postln;
}, '/ids');

)