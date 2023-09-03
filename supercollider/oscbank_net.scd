
OSCFunc.trace(false); // prints every incoming message to SC

OSCdef.freeAll; // help, purge !!

(  /* SYNTHDEF */

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

)

(  /* THE SYNTHS */

~x_size = 8;
~y_size = 4;

/*~oscbank.collect({|i|
	i.free;
});*/

~oscbank = Array.fill(~x_size * ~y_size, {
	arg i;
	Synth.new(\drone_tri, [
		freq: 100 + (i * 2),
		duty: 0.25
	]);
});

)

/*~oscbank.do({
	arg item, i;
	item.get(\freq, {arg value; value.postln});
});*/

(  /* OSC LISTENERS */

// absolute depth values - set the synth freqs
OSCdef.new(\abs, {
	arg msg, time, addr, port;
	/*~oscbank.do({
		arg item, i;
		item.set(\freq, (msg[i+1]**2) * 20000);
		//[i, item].postln;
	});*/
	~oscbank[msg[1]].set(\freq, (msg[2]**2) * 20000);
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
	~oscbank[msg[1]].set(\amp, 0.05+(msg[2]/5));

	~oscbank[msg[1]].set(\duty, 0.25+(msg[2]/5));
}, '/relative');

// index array - set the pan values of the synths
OSCdef.new(\ids, {
	arg msg, time, addr, port;
	msg.postln;
	/*~oscbank.do({
		arg item, i;
		item.set(\pan, 1 - (2 * msg[i+1]%~x_size));
	});*/
	~oscbank[msg[1]].set(\pan, 1 - (2 * msg[1]%~x_size));
}, '/ids');

)