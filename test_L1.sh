#!/usr/bin/env python3

import pexpect
import getopt
import sys

runopts=""
cpu="POWER10"

opts, args = getopt.getopt(sys.argv[1:], '12', ['v1', 'v2', 'p9', 'p10'])
for o, v in opts:
	if o in ('-1', '--v1'):
		runopts += "--v1 "
	if o in ('-2', '--v2'):
		runopts += "--v2 "
	if o in ('--p9'):
		runopts += "--p9 "
		cpu="POWER9"
	if o in ('--p10'):
		runopts += "--p10 "
		cpu="POWER10"

child = pexpect.spawn ('./run_L1.sh %s' % runopts)
#child.logfile = open("/tmp/mylog", "w")
child.logfile = sys.stdout.buffer

child.expect ("Hardware name: IBM pSeries \(emulated by qemu\) %s" % cpu, timeout=300)
child.expect (' login: ', timeout=300)
child.sendline ('root')
child.expect ('# ', timeout=300)

# start a few guests one at a time
for i in range(4):
    child.sendline ('./tests/run_L2.sh')
    child.expect ("Hardware name: IBM pSeries \(emulated by qemu\) %s" % cpu, timeout=300)
    child.expect (' login: ', timeout=300)
    child.sendline ('root')
    child.expect ('# ')
    child.sendline ('halt')
    child.expect ('System halted')
    child.expect ('# ')


# run parallel guests
child.sendline ('cd tests')
child.expect ('# ')
child.sendline ('./run_all_L2.sh 2')
child.expect ('# ')
child.sendline ('./check_all_L2.sh 2')
child.expect ('# ', timeout=600)
child.sendline ('pkill qemu-system-ppc -9; sleep 5')
child.expect ('# ', timeout=300)

child.sendline ('halt -f')
child.expect('System halted')
#child.interact()
