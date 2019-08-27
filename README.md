# SixthSense
WoW addon to alert you when party members are targeted by hostile players

SixthSense works by subscribing to changes within the current targeting state of all visible 
hostile, arena units and targets of friendly players via the "target" unit ID suffix. 

This information is used to construct an internal representation of the current targeting map
(who is targeting who), this representation is then used to draw icons onto the screen to
show at a glance which group or raid members are about to suffer damage spikes. SixthSense 
also supports periodic repolling to ensure that the targeting map does not grow stale or 
inaccurate.
