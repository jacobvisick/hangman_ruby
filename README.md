Hangman written in Ruby

This game is meant to be played from the terminal (i.e. using `ruby play.rb`).

It is far from a novel idea, but I wrote this quick game to practice I/O and
serialization. Here, I use MessagePack to save the state of a game and write
it to a file. Then, when a user wants to continue playing the game, I unpack
the data from that file and initialize a new Hangman instance using the same
state as when they left off.

I used MessagePack because 1) it's new to me and 2) we don't want a user to
be able to "cheat" and just open their save game in a text editor to see
what the word they are supposed to be guessing is. In other quick  methods
for serialization (i.e. JSON) it is purposely designed to be human-readable
but that is specifically *not* what I want here.
