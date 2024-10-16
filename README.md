# Shoshi Solitaire
A solitaire variant made with love in Godot.

## How to play
The object of the format is to bare off all cards (excepting the **JOKER**) to the **_foundation piles_**.

Each **_foundation pile_** may stack cards in ascending rank order (from **A** to **K**) of the same suit.

On any of the **_tableau piles_**, cards of alternating suit colors may be stacked on top of each other in descending rank order (from **K** to **A**).

The **JOKER** card may, when available, swap places with any other card across the **_tableau piles_**.

The **_JOKER pile_**, may only contain one card at a time; the **JOKER** card or any card that has been swapped out for it.

## Running the WASM build locally
Simply navigate to the root of the project and run the following command:
```console
python3 docs/serve.py --root .
```
