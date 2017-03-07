DISCLAIMERS! PLEASE READ!

This is a work in progress and I don't pretend to understand all of the calculations!

It's based on my own tcl/Tk version (see: http://wiki.tcl.tk/12389) from 2005,
itself based on an web-article called "Lunar Phase Computation" by Stephen R. Schmitt from 2004
(that can be found on the google cache, but else, could be difficult to find nowdays...)
itself based on "Sky & Telescope, Astronomical Computing", April 1994

IT IS PROBABLY AN APPROXIMATION FOR A FLAT SURFACE.

Hence it seems to be a bit off on the transition phase (new, full and half moon look OK).
Moreover, almost no testing has been done yet (I cannot guarantee that the shown values are
close from the fact).

Also in the Processing version I have to put a visible slider and add a better day-offset handling algo.
(currently you'll see negative days and days above the 31st of the month!!)

INTERACTIVITY:
* Current day: position the mouse right in the middle of the canvas. Date should be today's date.
* Futur days: move the mouse to the right 
 - (note: days currently can be shown as being over the 31st instead of correct day in next month/year)
* Past days: move to the left
 - (note: days can be shown as negative instead of correct day in previous month/year).

Being aware of all that, still a nice effect! I feel it would be even easier to build a 3D moonobject
and rotate a light source around, but hey, that a project for another rainy day!

Could add many things, like resizing depending on the distance from Earth, put the moon image with the correct rotation, etc.

Do whatever you want with it, but it'd be kind of you to send me corrections if you find any.

Fred Limouzin, 2017
