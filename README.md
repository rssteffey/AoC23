# Advent of Code - 2023
## This time it's Elixir

I've never done Elixir before, so this felt like a good time to start

## Additional Notes

Due to never doing Elixir, I don't have great sense of what good practices or formatting are yet.  Go look at [Jamin](https://github.com/jaminthorns/advent-of-code-2023/tree/main) if you want that real good terse stuff

## Journal of Shawn's daily feelings on the matter

- Day 1 
    - Learning curve, but doable
- Day 2 
    - still incomplete as of this writing (though pretty confident I can get it now)
    - 12/5 update: Did it, easiest part 2 change yet. Just piped the max to a different function to find the set power
- Day 3 
    - I hate everything why didn't I just do this in Python and go enjoy the rest of my life.  (Although slight ray of hope when Star #2 was actually an easy shift due to the function piping)
- Day 4 
    - pattern matching on recursion suddenly clicked, and I am feeling GOOD. 20 minute first star, another hour for the second. Still no where near my JS/Php/C#/Basic-on-a-TI84 speeds, but I no longer feel like throwing my laptop
- Day 5 
    - The first day where the actual problem was hard and wasn't just from me slamming my head against Elixir.  Started off on the *terrible* foot of generating whole maps for each level. Had to take a step back after an hour when my real-data run instantly bogged; immediately realized the easy algorithm and rewrote.  Part 2 I fell for the same naive assumption but thankfully only dug that hole for a few minutes.  I came up with the reverse traversal from location -> seed and felt REAL clever until I discovered it was running just as slow.  Technically still a brute force, but it wasn't memory bound so I just let it run until I woke up today. Proper solution is figuring out range intersections(?), but I don't have the slightest idea how to get that going today (and I already got the answer :wink:)
- Day 6
    - Blissfully simple. Part 2 just required swapping out one pipe. (I should have just made a second spaceless input file manually)
- Day 7
    - Super fun, and I'm finally starting to get better structures and organization. Also very encouraging to feel a lot of the flows that were tripping me up before (reducing, maps, etc) have now started feeling secondhand and I don't have to think much about them.  This was a great easy problem for me to dip my toe into sorting.  Not using a comparator is weird, but I don't hate precalculating the rank values and just letting it go from there