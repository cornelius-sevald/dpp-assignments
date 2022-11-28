#!/usr/bin/env python

import json
import sys
import numpy as np

import matplotlib

matplotlib.use('Agg') # For headless use

import matplotlib.pyplot as plt

progname = sys.argv[1]
benchmarks = sys.argv[2].split(' ')
data_sizes = list(map(int, sys.argv[3:]))

fn = '{}-opencl.json'.format(progname)
bench_data = json.load(open(fn))

runtimes = dict()
for bench in benchmarks:
    measurements = bench_data['{}.fut:{}'.format(progname,bench)]['datasets']
    runtimes[bench] = list([np.mean(measurements['[{}]i32 [{}]bool'.format(n,n)]['runtimes']) / 1000
                            for n in data_sizes ])

fig, ax1 = plt.subplots()
ax1.set_xlabel('Input size')
ax1.set_ylabel('Runtime (ms)', color='k')
ax1.tick_params('y', colors='k')
plt.xticks(data_sizes, rotation='vertical')
ax1.semilogx()

plots = []
for bench in benchmarks:
    plot = ax1.plot(data_sizes, runtimes[bench], label=bench)
    plots += plot

labels = [p.get_label() for p in plots]
ax1.legend(plots, labels, loc=0)

fig.tight_layout()
#plt.show()

plt.rc('text')
plt.savefig('{}.pdf'.format(progname), bbox_inches='tight')
