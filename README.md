# Pong-AI
Advancement of the basic Pong code provided by Harvards CS350 introduction to game development course.
This game is programmed to run on LOVE2D which can be downloaded here: [LOVE2D](https://love2d.org/)
-
CONTROLS: 
Move Up: W
Move Down: S
Serve/Advance: Enter/Return
Quit: Esc
-
Main Advancements on the original code include:

1. Development of a functioning AI for the right side paddle. 
  Features:
    -a natural human-like feel to it's play; doesn't jitter or chop.
    -doesn't track the ball when it's moving toward the human player (code is present to return to center in this case, but is disabled)
    -human error variables that operate as a function of ball speed (which increases over time); potential extent of mistakes increase with time but are never guarenteed
    -logic provides systems for adjustments in difficulty--I will add them next as I develop a mechanism for game setting selections.

2. Introduction of conservation of momentum.
   Original code had some drastic/unnatural feeling randomization on the y axis in response to deflections from paddles.
     -I added code to track the collective dx + dy velocity of the ball called 'dm'.
     -Paddle deflections increase the x velocity by a random amount, the max allowance of which is derivative of this momentum variable ('dm').
     -Paddle deflections also increase the overall momentum variable ('dm') by a fixed percentage.
     -dy Velocity is then resolved by the difference of these two values. e.g. dy = dm - dx.
     -Results in more subtle randomization to deflection angles after paddle collisions with more realistic feeling physics.
     -Interesting elaborations would be for paddle movement (or lack thereof) to influence deflection angles in some way.

3. Changes to the Playing Field
   -Added top frame, establishing a playing field and partitioning space between the game & the scoreboard.
   -Updated collision arithmetic to treat this partition as a boundary.

4. Added Audio
   Unique audio queues were added for each of these occurances:
     -Ball Serve sound.
     -Playing field boundary collision.
     -Human Player Paddle Hit
     -AI Player Paddle Hit
     -Human Player Goal
     -Human Player Concedes Goal (AI Goal)
     -Victory (Human player win)
     -Defeat (AI player wins)
