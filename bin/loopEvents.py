#!/usr/bin/env python
import DRP.Handler as H

h = H.Handler()
w = h.getWorkflow()

# There is surely a smarter way of doing this...?
for e in w['EventLoop']:
  w['Events'].append( e )

if w['Debug']: print("Looping on events")