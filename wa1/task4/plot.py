#!/usr/bin/env python

import json
import sys
import numpy as np

import matplotlib

matplotlib.use('Agg') # For headless use

import matplotlib.pyplot as plt

progname = sys.argv[1]
benchmark = sys.argv[2]
data_sizes = list(map(int, sys.argv[3:]))

opencl_filename = '{}-opencl.json'.format(progname)
multicore_filename = '{}-multicore.json'.format(progname)
c_filename = '{}-c.json'.format(progname)

opencl_json = json.load(open(opencl_filename))
multicore_json = json.load(open(multicore_filename))
c_json = json.load(open(c_filename))

opencl_measurements = opencl_json['{}.fut:{}'.format(progname,benchmark)]['datasets']
multicore_measurements = multicore_json['{}.fut:{}'.format(progname,benchmark)]['datasets']
c_measurements = c_json['{}.fut:{}'.format(progname,benchmark)]['datasets']

measurements_key = '#{0} ("{1}i64")'
print(str(opencl_measurements.keys()))
opencl_runtimes = list([ np.mean(opencl_measurements[measurements_key.format(i,n)]['runtimes']) / 1000
                         for i,n in enumerate(data_sizes) ])
multicore_runtimes = list([ np.mean(multicore_measurements[measurements_key.format(i,n)]['runtimes']) / 1000
                         for i,n in enumerate(data_sizes) ])
c_runtimes = list([ np.mean(c_measurements[measurements_key.format(i,n)]['runtimes']) / 1000
                    for i,n in enumerate(data_sizes) ])

fig, ax1 = plt.subplots()
opencl_runtime_plot = ax1.plot(data_sizes, opencl_runtimes, 'b-', label='OpenCL runtime')
multicore_runtime_plot = ax1.plot(data_sizes, multicore_runtimes, 'r-', label='Multicore runtime')
c_runtime_plot = ax1.plot(data_sizes, c_runtimes, 'g-', label='Sequential runtime')
ax1.set_xlabel('Input size')
ax1.set_ylabel('Runtime (ms)', color='k')
ax1.tick_params('y', colors='k')
plt.xticks(data_sizes, rotation='vertical')
ax1.semilogx()

plots = multicore_runtime_plot + opencl_runtime_plot + c_runtime_plot
labels = [p.get_label() for p in plots]
ax1.legend(plots, labels, loc=0)

fig.tight_layout()
plt.show()

plt.rc('text')
plt.savefig('{}.pdf'.format(benchmark), bbox_inches='tight')
