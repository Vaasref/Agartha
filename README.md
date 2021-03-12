# Agartha
Agartha is a Godot addon for narration heavy games.


Agartha's goal is to bring all of Ren'Py's killer features to Godot in a non-invasive way (it is not a framework).

Ren'Py is great when you are making a game with little game logic and interactivity. But when you start to have actual gameplay, all hells break loose and at best you will get headaches, at worst your game will became unplayably slow.

Still, it is difficult to move away from it due to how user friendly its rollback, saving systems and lightness are.
That where Godot and Agartha come into play.

## Agartha's focus
Agartha focuses on narration heavy games.

To do so it is designed to facilitate creation, maintenance and use of a large corpus.

It divides the naration into :
- Scene, regular Godot scenes that can or not be loaded by Agartha as a child of a set "stage"
- Dialogue, nodes that execute fragments on a thread with the needed logic for handling rolling
- Fragment, methods of a Dialogue that repect certain constrains allowing for light scripting and rolling
- Shard, pieces of text using a minimalistic scripting format used to store your game's corpus

The shards are themselves stored into libraries that can be edited using a editor plugin: 
![shard_editor](https://user-images.githubusercontent.com/2769215/110909758-bf789c00-8310-11eb-8028-9cee2d1ebdee.png)

This editor includes syntax check and colorisation.
It can import from text file and convert them shard libraries and vice versa, allowing you to also use external editors.

You can also include, in shards, links to other resources that will appear as shortcut button to speed up the process of implementing the shards into fragments then dialogues.

## How to interface your game logic with Agartha
Agartha make use of signals and virtual methods.

The signals are more geared toward the UI while the virtual methods are meant to be used to synchronize your gamelogic with Agartha's timeline and store.

Other than that, Agartha doesn't force any structure on your game. However, if you want to use Agartha as your primary mean of saving, you will have to come up with a way to restore the state of your scenes, if you don't want or cannot use Agartha's built-in tools (geared toward VN).
