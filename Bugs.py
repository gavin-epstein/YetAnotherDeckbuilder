
Null units showing up in unit list

freezing on select -- probably a while vs if yield
card 1 in hand onclick not working well
    not focus problem?
    has do do with resizing, clicks aren't registering when resized
    

add number background to status icon numbers
add icons for immune, resistant, vulnerable by type

cleansing water not working?
    Cleansing water select is broken

#Traps render behind

renewal not voiding
Ashes not voiding a card
Dark deeds light whispers not activating part 2



#    -units with linkage/ multitile entities
##Orientation change for units, on attack/move
##    flip
##    topdown
##    frames
#biomes (generated tiles should pick the same texture as their neighbors)

plants/background images for different biomes, (naturally spawning traps)

#Birds of a feather not buffing

#hover text on units

#zoom and scroll on map

#zoom and tooltips on cards
#multitile units should be able to move through themselves
Consumed tile should be telegraphed

tile backgrounds coords based on map coords not screencoords
    or add a viewport for the map, so that they change on shift but not scroll

landing screen

save game

?improve pathfinding of enemies

sounds

add range, speed to unit mouseover
##Unit pieces:
##    head, body, linkage, trap,
##            tiles, other pointer,       is occupant?, has intent?, has healthbar?  should extend unit?
##    head    1      linkages,bodies?head    yes           yes          yes           yes
##    body    1      head                    yes           no           no            yes
##    linkage 0      head,[2]ends            no            no           no            no?
##    trap    1      head                    no            no           yes           yes                                               
##Map.select/getTiles add head if head not in possible
##
##linkage connects to 2 entities, could be units of tiles
##head handles movement policy of all children
##    Snake- child order is relevant
##    Rigid- movement direction then child snaps to tile
##    Spring- none (handled by linkage)
##On move, linkage tiles are reassigned by head
##if either link endpoint is destroyed, destroy the link
##if link is stretched (for more than a threshold time) cause spring behavior in
##    - unit if one end is a tile
##    - tile furthest from head of this link
##when spawning in:
##    components(self, "name","name","othername")
##    linkage("linkname",0,1) #links based on indices in components
##    linkage("linkname",1,2)
##    linkage("linkname",1,-) #to a tile
##Use cases:
##    Void tentacles:
##        Void - head = self
##        tentacles - linkage
##        tentacles: linkage
##    Shambling mound:
##        Center - head
##        body bits, head =center
##        linkage: head, body bits
##        linkage: body bit to other body bit
##    Snek (Hydra):
##        Head- head
##        body- also heads, have a var for $Prev snake, and a link to the next segment
##        if prev snek is null, move
##        if prev snek is null, animate "Head"
##        if prev snek != null, animate "Body"
##        if next snek is null, spawn
##linkage policy: stretch (just y axis), grow (fixed aspect ratio), static (no change)
##    
###TODO
##?head execution
###loading linkages from file
###loading components
###spawning
###testing
##moving
