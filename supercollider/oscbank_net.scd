
OSCFunc.trace(false); // prints every incoming message to SC

OSCdef.freeAll; // help, purge !!

(  /* SYNTHDEF */

SynthDef.new(\osc, {
	arg freq=100, pan=0, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	//env = EnvGen.kr(Env.perc(0.01,1), doneAction:2); // sig = osc * env
	sig = SinOsc.ar(freq, 0, 0.1);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef.new(\tri, {
	arg freq=100, pan=0, out=0;
	var sig, env;
	freq = freq.clip(20, 20000);
	pan = pan.clip(-1, 1);
	//env = EnvGen.kr(Env.perc(0.01,1), doneAction:2); // sig = osc * env
	sig = VarSaw.ar(freq, 0, 0.5, 0.1);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

)

(  /* THE SYNTHS */
~oscbank = Array.fill(8, {
	arg i;
	Synth.new(\tri);
});
s.scope
)

~oscbank.do({
	arg item, i;
	item.get(\freq, {arg value; value.postln});
});

(  /* OSC LISTENERS */

OSCdef.new(\abs, {
	arg msg, time, addr, port;
	~oscbank.do({
		arg item, i;
		item.set(\freq, (msg[i+1]**2) * 20000);
		//[i, item].postln;
	});
}, '/absolute');

OSCdef.new(\rel, {
	arg msg, time, addr, port;
	//msg.postln;
}, '/relative');

OSCdef.new(\ids, {
	arg msg, time, addr, port;
	msg.postln;
	~oscbank.do({
		arg item, i;
		item.set(\pan, -1 + (2 * msg[i+1]));
	});
}, '/ids');

)