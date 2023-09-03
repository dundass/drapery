
OSCFunc.trace(false); // prints every incoming message to SC

OSCdef.freeAll; // help, purge !!

(  /* SYNTHDEFS */

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

SynthDef.new(\osc, {
	arg freq=100, pan=0, amp=0.05, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.1,1), doneAction:2);
	sig = SinOsc.ar(freq, 0, amp) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\tri, {
	arg freq=100, pan=0, amp=0.05, duty=0.5, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.1,1), doneAction:2);
	sig = VarSaw.ar(freq, 0, duty, amp) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\pulse, {
	arg freq=100, pan=0, amp=0.05, duty=0.5, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.1,1), doneAction:2);
	sig = Pulse.ar(freq, duty, amp) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

/* THE TRIG SYNTH FREQUENCY ARRAY */

~x_size = 8;
~y_size = 4;

~abs_depths = Array.fill(~x_size * ~y_size, { 0.0 });

)

(  /* THE DRONE SYNTHS */

~x_size = 8;
~y_size = 4;

~dronebank.do({|synth|
	synth.free;
});

~dronebank = Array.fill(~x_size * ~y_size, {
	arg i;
	Synth.new(\drone_tri, [
		freq: 100 + (i * 2),
		duty: 0.25
	]);
});

)

(  /* OSC LISTENERS - DRONES */

// absolute depth values - set the synth freqs
OSCdef.new(\abs, {
	arg msg, time, addr, port;
	/*~oscbank.do({
		arg item, i;
		item.set(\freq, (msg[i+1]**2) * 20000);
		//[i, item].postln;
	});*/
	~dronebank[msg[1]].set(\freq, (msg[2]**1.75) * 10000);
}, '/absolute');

// delta depth values
OSCdef.new(\rel, {
	arg msg, time, addr, port;
	//msg.postln;
	/*~oscbank.do({
		arg item, i;
		item.set(\amp, 0.05 + msg[i+1]/5);
		item.set(\duty, 0.25 + msg[i+1]/10);
		//[i, item].postln;
	});*/
	~dronebank[msg[1]].set(\amp, 0.05+(msg[2]/5));

	~dronebank[msg[1]].set(\duty, 0.25+(msg[2]/5));
}, '/relative');

// index array - set the pan values of the synths
OSCdef.new(\ids, {
	arg msg, time, addr, port;
	msg.postln;
	/*~oscbank.do({
		arg item, i;
		item.set(\pan, 1 - (2 * msg[i+1]%~x_size));
	});*/
	~dronebank[msg[1]].set(\pan, 1 - (2 * msg[1]%~x_size));
}, '/ids');

)

(  /* OSC LISTENERS - ATONAL TRIG */

~dronebank.do({|synth|
	//synth.free;
	synth.set(\amp, 0);
});

// absolute depth values - save for trig later
OSCdef.new(\abs, {
	arg msg, time, addr, port;
	// msg[1] = index; msg[2] = abs depth
	~abs_depths[msg[1]] = msg[2];
}, '/absolute');

// delta depth values - trigger the synths
OSCdef.new(\rel, {
	arg msg, time, addr, port;
	// msg[1] = index; msg[2] = rel depth
	var y_coordinate = msg[1] / ~y_size;
	y_coordinate = y_coordinate.floor;
	if(msg[2] > 0.025, {
		Synth.new(\pulse, [
			freq: (~abs_depths[msg[1]]**2) * 20000,
			pan: 1 - (2 * (msg[1]%~x_size) / ~x_size),
			amp: 0.025 + (msg[2] / 10),
			duty: 0.1 + (y_coordinate / 10)
		]);
		((~abs_depths[msg[1]]**2) * 20000).postln;
	});
	//msg.postln;
}, '/relative');

// index array - sent as part of init
OSCdef.new(\ids, {
	arg msg, time, addr, port;
	msg.postln;
}, '/ids');

)

(  /* OSC LISTENERS - NOTE TRIG */

~dronebank.do({|synth|
	synth.free;
	//synth.set(\amp, 0);
});

//~scale = [0,2,3,5,7,9,10,12];
~scale = [0,2,4,5,7,9,11,12];
//~noffset = 48;
//~noffset = 36;
~noffset = 48;

// absolute depth values - save for trig later
OSCdef.new(\abs, {
	arg msg, time, addr, port;
	// msg[1] = index; msg[2] = abs depth
	~abs_depths[msg[1]] = msg[2];
}, '/absolute');

// delta depth values
// trigger the synths if over a threshold
OSCdef.new(\rel, {
	arg msg, time, addr, port;
	// msg[1] = index; msg[2] = rel depth
	var x_coordinate = msg[1] % ~x_size;
	var y_coordinate = (msg[1] / ~y_size).floor;
	var note = (~noffset + msg[1]).degreeToKey(~scale);
	if(msg[2] > 0.025, {
		Synth.new(\pulse, [
			freq: note.midicps,
			pan: 1 - (2 * (msg[1]%~x_size) / ~x_size),
			amp: 0.025 + (~abs_depths[msg[1]] / 10),
			duty: 0.1 + (y_coordinate / 10)
		]);
		note.postln;
	});
	//msg.postln;
}, '/relative');

// index array - sent as part of init
OSCdef.new(\ids, {
	arg msg, time, addr, port;
	msg.postln;
}, '/ids');

)