
OSCFunc.trace(false); // prints every incoming message to SC

OSCdef.freeAll; // help, purge !!

(  /* SYNTHDEFS */

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

/* THE FREQUENCY ARRAY */

~x_size = 8;
~y_size = 4;

~abs_depths = Array.fill(~x_size * ~y_size, { 0.0 });

)

(  /* OSC LISTENERS */

~scale = [0,2,4,5,7,9,11,12];

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
	var note = (48 + msg[1]).degreeToKey(~scale);
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

s.scope

(
l = [0, 1, 5, 9, 11]; // pentatonic scale
(1, 2..15).collect{|i|
    i.degreeToKey(l, 12)
};
)