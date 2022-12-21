#!/usr/bin/env python

import json
import sys
import numpy as np

import matplotlib

matplotlib.use('Agg') # For headless use

import matplotlib.pyplot as plt

progname = sys.argv[1]
data_sizes = list(map(int, sys.argv[2:]))
# number of matrices
ks = data_sizes[:len(data_sizes)//2]
# size of matrices
ns = data_sizes[len(data_sizes)//2:]

untuned_filename = '{}-untuned.json'.format(progname)
tuned_filename = '{}-tuned.json'.format(progname)

untuned_json = json.load(open(untuned_filename))
tuned_json = json.load(open(tuned_filename))

untuned_measurements = untuned_json['{}.fut'.format(progname)]['datasets']
tuned_measurements = tuned_json['{}.fut'.format(progname)]['datasets']

untuned_runtimes = list([ np.mean(untuned_measurements['[{}][{}][{}]f32'.format(k,n,n)]['runtimes']) / 1000
                         for k,n in zip(ks,ns) ])
tuned_runtimes = list([ np.mean(tuned_measurements['[{}][{}][{}]f32'.format(k,n,n)]['runtimes']) / 1000
                         for k,n in zip(ks,ns) ])

fig, ax1 = plt.subplots()
untuned_runtime_plot = ax1.plot(ks, untuned_runtimes, 'b-', label='Untuned runtime')
tuned_runtime_plot = ax1.plot(ks, tuned_runtimes, 'g-', label='Tuned runtime')
ax1.set_xlabel('Number of matrices')
ax1.set_ylabel('Runtime (ms)', color='k')
ax1.tick_params('y', colors='k')
plt.xticks(ks, rotation='vertical')
ax1.set_xscale('log', basex=2) 

plots = untuned_runtime_plot + tuned_runtime_plot
labels = [p.get_label() for p in plots]
ax1.legend(plots, labels, loc=0)

fig.tight_layout()
#plt.show()

plt.rc('text')
plt.savefig('{}.pdf'.format(progname), bbox_inches='tight')
