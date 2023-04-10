
OSCFunc.trace(false); // prints every incoming message to SC

OSCdef.freeAll; // help, purge !!

(  /* SYNTHDEF */

SynthDef.new(\osc, {
	arg freq=100, pan=0, out=0; // todo - amp arg
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.01,2), doneAction:2); // sig = osc * env
	sig = SinOsc.ar(freq, 0, 0.1) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\tri, {
	arg freq=100, pan=0, out=0; // todo - amp arg
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.01,2), doneAction:2); // sig = osc * env
	sig = VarSaw.ar(freq, 0, 0.5, 0.1) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\glassy, {
	arg freq=100, pan=0, out=0; // todo - amp arg
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	env = EnvGen.kr(Env.perc(0.01,2), doneAction:2); // sig = osc * env
	sig = VarSaw.ar(freq, 0, 0.5, 0.1) * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

/* THE FREQUENCY ARRAY */

~x_size = 8;
~y_size = 4;

~oscfreqs = Array.fill(~x_size * ~y_size, { 0.0 });

)

(  /* OSC LISTENERS */

OSCdef.new(\abs, {
	arg msg, time, addr, port;
	msg.do({
		arg item, i;
		if(i > 0, {
			~oscfreqs[i-1] = (msg[i]**2) * 20000;
		});
		//[i, item].postln;
	});
}, '/absolute');

OSCdef.new(\rel, {
	arg msg, time, addr, port;
	msg.do({
		arg item, i;
		if(i > 0 && item.isNumber, {
			if(item > 0.025, {
				Synth.new(\tri, [
					freq: ~oscfreqs[i-1],
					pan: -1 + (2 * (i%~x_size) / ~x_size)
				]);
				~oscfreqs[i-1].postln;
			});
		});
	});
	//msg.postln;
}, '/relative');

OSCdef.new(\ids, {
	arg msg, time, addr, port;
	msg.postln;
}, '/ids');

)