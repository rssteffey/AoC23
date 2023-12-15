# Advent of Code - 2023
## This time it's Elixir

I've never done Elixir before, so this felt like a good time to start

## Additional Notes

Due to never doing Elixir, I don't have great sense of what good practices or formatting are yet.  Go look at [Jamin](https://github.com/jaminthorns/advent-of-code-2023/tree/main) if you want that real good terse stuff

## Journal of Shawn's daily feelings on the matter

### Day 1 
- Learning curve, but doable
### Day 2 
- still incomplete as of this writing (though pretty confident I can get it now)
- 12/5 update: Did it, easiest part 2 change yet. Just piped the max to a different function to find the set power
### Day 3 
- I hate everything why didn't I just do this in Python and go enjoy the rest of my life.  (Although slight ray of hope when Star #2 was actually an easy shift due to the function piping)
### Day 4 
- pattern matching on recursion suddenly clicked, and I am feeling GOOD. 20 minute first star, another hour for the second. Still no where near my JS/Php/C#/Basic-on-a-TI84 speeds, but I no longer feel like throwing my laptop
### Day 5 
- The first day where the actual problem was hard and wasn't just from me slamming my head against Elixir.  Started off on the *terrible* foot of generating whole maps for each level. Had to take a step back after an hour when my real-data run instantly bogged; immediately realized the easy algorithm and rewrote.  Part 2 I fell for the same naive assumption but thankfully only dug that hole for a few minutes.  I came up with the reverse traversal from location -> seed and felt REAL clever until I discovered it was running just as slow.  Technically still a brute force, but it wasn't memory bound so I just let it run until I woke up today. Proper solution is figuring out range intersections(?), but I don't have the slightest idea how to get that going today (and I already got the answer :wink:)
### Day 6
- Blissfully simple. Part 2 just required swapping out one pipe. (I should have just made a second spaceless input file manually)
### Day 7
- Super fun, and I'm finally starting to get better structures and organization. Also very encouraging to feel a lot of the flows that were tripping me up before (reducing, maps, etc) have now started feeling secondhand and I don't have to think much about them.  This was a great easy problem for me to dip my toe into sorting.  Not using a comparator is weird, but I don't hate precalculating the rank values and just letting it go from there
### Day 8
- The first day I feel good at Elixir because it was my reading comprehension that screwed me, not the language.  Part 1 took me an hour and a half because I interpreted the input data instructions as "First row = starting point" and that just happened to be "AAA" in the test data.  15 minutes coding everything, follow by an hour+ debugging and verifying that I was definitely in a closed cycle with no end before it finally clicked.  (I maintain the puzzle is misleadingly worded, even if the final direction is clear)  
- Weirdly Part 2 was a much quicker 20-minute push.  I think I got lucky with my assumption that each cycle closed immediately after Z back to A, because I just blindly counted the Least Common Multiple of all routes A->Z and threw it in AoC on a whim to a surprised second star.  I just now validated that at least some of my A's never have a link back, so I suspect the input generator is benevolent and purposely generating lead-in-paths that are the same length as the extra bits of main cycles afterwards.  I _should_ have counted only the Z to Z cycle; ie, length of A to X was designed to match Z to X in the diagram below? 

  ```
    A---X---\
       /     |
       \__Z_/
  ```

  (That much benevolence in design feels wrong, so that may just be my sleep deprived brain misunderstanding how I got it right the first time)
### Day 9
- Recursion is fn
### Day 10
- Part 1, easy peasy. Proud of my conditionless and confusing math for determining where a pipe leads (ie, `newCol = currCol + (currRow - oldRow)`)
- Part 2, slept on it, drove to church on it, did not listen to the sermon, and then rubber ducked to Alexandria in the car for the 3 hour trip home and finally clicked on a simple solution.  Took a while to implement because I am *bogged* down in some poor syntax choices. But also proud of the basic `|` pair counting algorithm
- Takeaways to improve:
    - My structure finally bit me bad.  Parts 1 and 2 blurred and got unwieldy by the end.  I can't find the balance between preserving my part1 history and not ending up with chunks of redundancy (because planning ahead to part 2 is near impossible when first making part 1)
    - I think I should be using maps and atoms more.  The elem(elem(elem())) nesting is a marshy pit of despair by the time I get down in the lower levels of these 2D arrays
    - Part1 represents the grid as a tuple of tuples since I wanted consistent indexing, but Part2 does the same via nested lists.  I *think* this is probably more expected since `List.replace_at` exists and lists feel more correct?  Still not entirely sure where the line should be if I have a known size object (like this grid)
### Day 11
- My most Elixir-y solution yet.  Clean chains, no condition paths.  Maybe a tad off-track when generating the row and column expansion indices, but overall felt *great*.  Especially with such an easy switch to Part 2
### Day 12 \[INCOMPLETE\]
- Part 1: I thought I was incredibly equipped to handle this one, given that I've made a nonogram solver (to aid with a nonogram generator) in the past. I remembered the key being to create combinations based on the potential blank spaces. Unfortunately I wasted entirely too much time trying to do pattern matching on the resulting tuples (this is Elixir, after all) before finally caving and just using a regex.
- Part 2: Currently the part 2 to stump me most.  Clearly the naive approach isn't going to complete, and I don't have the slightest idea what the quick algorithm is to count valid arrangements
### Day 13 \[INCOMPLETE\]
- Part 1: I'm Clever King reigning from Clever mountain. You others are fools. Counting up your reflection rows one by one. Binary checksums rool, everything else droolz
- Part 2: Mr. Moron residing at 37 Moron Ct.  What am I even doing with my life?  Spending literal hours chasing an edge case in input data that I cannot possibly track down for the life of me.  For fun?  I'm stubborn enough to finish this one, just like I will Part 12 eventually.  But it may be the end of my 2023 AoC
### Day 14
- Part 1: Very fun (and now in lower_jamin_blood_pressure_format \[snake_case\])
- Part 2: Despite still not completing Day 13 from whatever edge case I'm missing, I liked my checksums too much to abandon.  Using them here to keep my history list more human-readable. (Not fully, just *more*)
### Day 15
- So simple that I was paranoid the entire time