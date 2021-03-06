globals [ crops bee-message-printed spray-countdown ]  ; keep track of how much crops there is
; Humans and bees are both breeds of turtle.
breed [ humans human ]
breed [ bees bee ]
turtles-own [ energy toxicity]       ; Humans and bees own energy and toxicity
patches-own [ countdown patch-toxicity]

to setup
  clear-all
  set bee-message-printed 0
  ask patches [ set pcolor green ]
  ask patches [
     set pcolor one-of [ green brown yellow]
     set patch-toxicity random-float pesticide-saturation
     if pcolor = yellow
       [ set countdown random-float crops-regrowth-time ] ; initialize crops grow clocks randomly for brown patches
   ]
  set-default-shape humans "person"
  create-humans initial-number-humans  ; create the humans, then initialize their variables
  [
    set color blue
    set size 2.5  ; easier to see
    set label-color blue - 2
    setxy random-xcor random-ycor
  ]
  set-default-shape bees "bug"
  create-bees initial-number-bees  ; create the bees, then initialize their variables
  [
    set color black
    set size .5  ; easier to see
    set energy random (2 * bee-gain-from-food)
    set toxicity 0 ; no bee has toxicity in their system in the beginning
    setxy random-xcor random-ycor
  ]
  display-labels
  set crops count patches with [pcolor = green]
  set spray-countdown crops-spray-time
  reset-ticks
end

to go
  if not any? turtles [ user-message "Humanity has become extinct." stop ]
  if not any? bees [
    ifelse bee-message-printed = 1
    [  ]
    [
      user-message "The bees are gone. There is no more food."
      set bee-message-printed 1
    ]
  ]
  ask humans [
    move
    set energy energy - 1
    eat-crops
    death
    reproduce-humans
  ]
  ask bees [
    move
    set energy energy - 1  ; bees lose energy as they move
    pollinate-crops
    death
    reproduce-bees
  ]
  ask patches [
    set patch-toxicity patch-toxicity - random-float patch-toxicity ; take off a random amount of toxicity
    ; Since there are so many factors like rain that can wash off pesticide and it's easier to take off random amounts
    ; rather than doing a half-life, we just take off a random amount.
    grow-crops
    spray
  ]
  set crops count patches with [pcolor = green]
  tick
  display-labels
end

to move  ; turtle procedure
  rt random 50
  lt random 50
  fd 1
end

to pollinate-crops ; bee procedure
  if pcolor = brown [
    set pcolor yellow
    set energy energy + bee-gain-from-food ; bees gain energy by pollinating
    set toxicity (toxicity + random-float patch-toxicity) ; bees are unlikely to get the full dose of pesticide on them just from pollinating
  ]
end

to eat-crops  ; humans procedure
  ; humans eat crops, turn the patch brown
  ; this is the apocalyptic version where we assume that humans are running out of energy
  if pcolor = green [
    set pcolor brown
    set energy energy + humans-gain-from-food  ; humans gain energy by eating
  ]
end

to reproduce-bees  ; bee procedure
  if random-float 100 < bee-reproduce [  ; throw "dice" to see if you will reproduce
    set energy (energy / 2)               ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]  ; hatch an offspring and move it forward 1 step
  ]
end

to reproduce-humans  ; human procedure
  if random-float 100 < human-reproduce [  ; throw "dice" to see if you will reproduce
    set energy (energy / 2)               ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]  ; hatch an offspring and move it forward 1 step
  ]
end

to death  ; turtle procedure
  ; when energy dips below zero, die
  if energy < 0 [ die ]
  ; if you're affected by toxicity at all, roll the dice to see if you die
  if toxicity > 0 [
    ifelse random-float 100 < bee-sensitivity [
      die
    ]
    [set toxicity toxicity - 1] ; if you don't, reduce your toxicity by 1
  ]
end

to grow-crops  ; patch procedure
  ; countdown on yellow patches: if reach 0, grow some crops
  if pcolor = yellow [
    ifelse countdown <= 0
      [ set pcolor green
        set countdown crops-regrowth-time ]
      [ set countdown countdown - 1 ]
  ]
end

to spray ; patch procedure
  ; countdown on all patches: if reach 0, spray all patches
  ifelse spray-countdown <= 0
  [
     set patch-toxicity (patch-toxicity + random-float pesticide-saturation) ; add patch
     set spray-countdown crops-spray-time
  ]
  [
     set spray-countdown spray-countdown - 1
  ]
end

to display-labels
  ask turtles [ set label "" ]
  if show-toxicity? [
    ask bees [ set label round toxicity ]
    ;ask humans [ set label round toxicity ]
  ]
end


; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
446
22
913
490
-1
-1
9.0
1
14
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

SLIDER
3
93
177
126
initial-number-humans
initial-number-humans
0
250
100.0
1
1
NIL
HORIZONTAL

SLIDER
3
130
206
163
humans-gain-from-food
humans-gain-from-food
0.0
50.0
4.0
1.0
1
units
HORIZONTAL

SLIDER
238
92
403
125
initial-number-bees
initial-number-bees
0
250
250.0
1
1
NIL
HORIZONTAL

SLIDER
238
128
426
161
bee-gain-from-food
bee-gain-from-food
0.0
100.0
20.0
1.0
1
units
HORIZONTAL

SLIDER
238
164
403
197
bee-reproduce
bee-reproduce
0.0
20.0
20.0
1.0
1
%
HORIZONTAL

SLIDER
928
38
1140
71
crops-regrowth-time
crops-regrowth-time
0
100
24.0
1
1
days
HORIZONTAL

BUTTON
8
28
77
61
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
90
28
157
61
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
26
304
342
501
populations
time
pop.
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"humans" 1.0 0 -13345367 true "" "plot count humans"
"bees" 1.0 0 -2674135 true "" "plot count bees"
"crops / 4" 1.0 0 -10899396 true "" "plot crops / 4"

MONITOR
61
249
132
294
humans
count humans
3
1
11

MONITOR
136
249
218
294
bees
count bees
3
1
11

MONITOR
222
249
298
294
NIL
crops / 4
0
1
11

TEXTBOX
8
71
148
90
Human settings
11
0.0
0

TEXTBOX
243
72
356
90
Bee settings
11
0.0
0

TEXTBOX
934
15
1086
33
Crop settings
11
0.0
0

SWITCH
167
28
303
61
show-toxicity?
show-toxicity?
1
1
-1000

SLIDER
1146
38
1318
71
crops-spray-time
crops-spray-time
1
20
7.0
1
1
days
HORIZONTAL

SLIDER
929
78
1121
111
pesticide-saturation
pesticide-saturation
0
100
50.0
1
1
units
HORIZONTAL

SLIDER
238
203
442
236
bee-sensitivity
bee-sensitivity
1
100
100.0
1
1
%
HORIZONTAL

SLIDER
5
167
177
200
human-reproduce
human-reproduce
1
20
4.0
1
1
%
HORIZONTAL

@#$#@#$#@
##WHAT IS IT?

This model explores the effects of pesticides on bees and how that plays a role in an ecosystem dependent on them.

##THE WORLD OF THE MODEL

The world for this model starts with a few assumptions. First, we assume that every patch in this world is made entirely of fertile soil that can have crops planted on it. Second, we assume that all of these crops require bees - by way of pollination - to grow. Thirdly, we assume the pesticides of this world do not affect humans. Finally, we assume that the humans who live in this world need to consume fully grown crops to keep an imaginary energy value above zero, or they will expire.

These assumptions leave us with a collection of facts. First, it tells us we have two turtle species that are defined: bees and humans. There is also a third type of turtle called patches that simulates the crops of the world. If bees do not pollinate these patches while passing over them, the crops for those patches will not grow. By extension, the humans will eventually starve because there is nothing for them to eat in order to gain their energy back from moving around the map.

##HOW IT WORKS

During each timestep, both humans and bees will take a single step in a random direction. This move costs them one energy, but they can still replenish that energy if they successfully eat or pollinate the patch they stop at. Humans can only eat patches if those patches are green, thereby turning them brown. Bees can only pollinate brown patches, thereby turning them yellow. If the energy of either bees or humans ever drops below zero, they die. If not, they have a chance to reproduce on every tick.

The major caveat of this model that allows the representation of pesticides is the "death" function. Every timestep, bees are subjected to an additional condition not present for humans. If they have any amount of toxin on them from pollinating the plant, they must roll a death die in order to determine if they survive. Their chance of death is proportional to their sensitivity toward the poison. If luck favors them, they live and lose a small amount of the pesticide on them.

Pesticide is sprayed at set intervals and with a set saturation. The saturation is randomized for each patch in order to account for uneven spraying patterns or just drift in general. The concentration applied to each patch will stick to that patch, but decay randomly in order to roughly simulate wash off and removal by other means. Whenever a bee pollinates a brown patch with pesticide on it, however, some of that pesticide will get on the bee. Depending on this bee's sensitivity, that amount will either be fatal or not quite enough to kill it. If the amount is insufficient, the bee loses some of the pesticide on it with every tick.

If ever there arises a point where the pesticide is strong enough to kill off all bees, a message will denote that event. Humans will gradually die off without food until another message declares their extinction and stops the simulation.

##HOW TO USE IT

Each dial in the simulation window will affect something in the model.

**Human settings:**
Here you can change the initial number of humans at setup, how many energy units they gain from eating crops, and what percent chance they have to reproduce after every time step. These will all affect the survivability of humans in the model.

**Bee settings:**
Here you can change the initial number of bees at setup, how many energy units they gain from pollinating crops, what percent chance they have to reproduce after every time step and how sensitive they are to poison. A higher sensitivity will increase the lethality of the poison dramatically. 100% sensitivity at 1 unit of saturation will put bees on an extinction path.

**Crop settings:**
Here we find dials to affect how often crops are sprayed, how quickly they grow after pollination and how much pesticide is sprayed during every cycle. Increasing the frequency drastically affects bee mortality rate. Increased saturation will have a similar effect, but not as noticeable.

**Other elements:**

**Picture:**
Bees are the black bugs.
Humans are the blue people.
Yellow patches are pollinated crops.
Brown patches are unpollinated crops.
Green patches are edible crops.

**Graph:**
The lines show the populations of bees, humans and crops over time.

**Extra setting:**
Show Toxicity will show what level of pesticide each bee is carrying, but, given how numerous the bees normally get, good luck seeing their labels.

##HOW TO EXTEND

This model is just a baseline, and can easily be extended based on other behaviors of real life poisons. For example, we could introduce a hive effect where each bee belongs to a hive, and poison getting into that hive kills all bees related to it. We could also create a sterility option where the poison doesn't outright kill the bees but does prevent them from reproducing. Obviously, to notice an effect with that, we would need to give bees a set life-span.

##WHAT I LEARNED

Primarily what I learned from this project is how difficult it is to accurately model pesticides. I originally tried to do a half-life model, only to discover that it was a massive rabbit hole that I didn't want to jump into. The biggest issue was what to do with new poison if it was sprayed just before the half-life on old poison occurred? I can't just take off half of that new poison when its half-life wouldn't even occur for quite a bit longer. Therefore, I could never figure out how to cleanly keep track of half-lives.

At the same time, the random deduction method I used for patch-toxicity is probably not the most accurate for pesticides. You could essentially deduct 100% with the current setup, which isn't normal for any of the widely used pesticides. The 1 particle deduction on bees is probably not all that accurate either, though it depends on how inert the poison is in the system of the bee. Therefore, while I managed to get a rough estimate of the behavior of pesticides, my math is not completely in line with every aspect of reality.

During this project, I also learned how to use NetLogo extensively. The random call as opposed to random-float got me mixed up quite a bit in the beginning and gave me anomalous behaviors during the first rough draft. Instead of subtracting percentages from certain values like I meant to, I was actually setting high values down to low numbers incredibly fast or doing comparisons that were not my intention. Bee-sensitivity had no effect with the initial setup I used, though anyone using the current model can see that that has been fixed.

##SUMMARY

I had a lot of fun making this model, and may come back to it later to introduce hives. Practical applications of computing on this level are always fascinating to me, so this project was probably the most fun I've had all semester long.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
set grass? true
setup
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
