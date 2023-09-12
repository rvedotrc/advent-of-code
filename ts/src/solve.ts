import * as Immutable from "immutable";

import { CURRENT, doorFor, isDoor, isKey, keyFor, SPACE } from "./cells";
import { Cost, Graph, Position } from "./graph";
import { reduceSpaces } from "./reduceSpaces";

const SOLVED = "SOLVED";

const getCurrentPositions = (g: Graph): Immutable.Set<Position> =>
  g.nodes.byWhat.get(CURRENT) || Immutable.Set();

type State =
  | typeof SOLVED
  | {
      heldKeys: Immutable.Set<string>;
      currentPositions: Immutable.Set<number>;
    };

const stateToString = (state: State) =>
  state === SOLVED
    ? SOLVED
    : `${[...state.heldKeys].sort().join("")}/${[...state.currentPositions]
        .sort((a, b) => a - b)
        .map(String)
        .join(",")}`;

const stringToState = (s: string): State => {
  if (s === SOLVED) return SOLVED;

  const [keys, positions] = s.split("/");

  return {
    heldKeys: Immutable.Set(keys.split("")),
    currentPositions: Immutable.Set(positions.split(",").map(Number)),
  };
};

const unlockDoors = (
  g: Graph,
  keysHeld: Immutable.Set<string>,
  currentPositions: Immutable.Set<Position>,
) => {
  const toRemove = keysHeld.flatMap((k) => [k, doorFor(k)]);

  const positionsToRemove = toRemove.flatMap(
    (kd): Immutable.Set<Position> => g.nodes.byWhat.get(kd) || Immutable.Set(),
  );

  for (const pos of positionsToRemove) {
    if (!currentPositions.has(pos)) g = g.changeNode(pos, SPACE);
  }

  return reduceSpaces(g);
};

const unvisitedNeighbours = (
  g: Graph,
  numberOfKeys: number,
  currentState: State,
  visited: Set<string>,
): { neighbourState: State; costFromHere: Cost }[] => {
  if (currentState === SOLVED) return [];

  g = unlockDoors(g, currentState.heldKeys, currentState.currentPositions);

  const out: ReturnType<typeof unvisitedNeighbours> = [];

  for (const fromPosition of currentState.currentPositions) {
    const edges = g.edges.getByPosition(fromPosition);
    if (!edges) throw "";

    for (const [toPosition, costFromHere] of edges.entries()) {
      const what = g.nodes.byPosition.get(toPosition);
      if (what === undefined) throw "";

      if (isDoor(what) && !currentState.heldKeys.has(keyFor(what))) continue;

      if (isKey(what)) {
        const newKeysHeld = currentState.heldKeys.add(what);

        if (newKeysHeld.size === numberOfKeys) {
          out.push({ neighbourState: SOLVED, costFromHere });
        } else {
          out.push({
            neighbourState: {
              heldKeys: newKeysHeld,
              currentPositions: currentState.currentPositions
                .delete(fromPosition)
                .add(toPosition),
            },
            costFromHere,
          });
        }
      } else {
        out.push({
          neighbourState: {
            ...currentState,
            currentPositions: currentState.currentPositions
              .delete(fromPosition)
              .add(toPosition),
          },
          costFromHere,
        });
      }
    }
  }

  const r = out.filter(
    (ans) => !visited.has(stateToString(ans.neighbourState)),
  );

  return r;
};

export const solve = (g: Graph): number => {
  let currentState: State = {
    heldKeys: Immutable.Set(),
    currentPositions: getCurrentPositions(g),
  } as State;
  let currentScore = 0;

  const numberOfKeys = [...g.nodes.byWhat.keys()].filter(isKey).length;

  const bestScores = new Map<string, number>().set(
    stateToString(currentState),
    currentScore,
  );
  const visited = new Set<string>();
  const seenUnvisited = new Set<string>();

  while (true) {
    const cs = stateToString(currentState);
    if (visited.has(cs)) throw "124";

    for (const { neighbourState, costFromHere } of unvisitedNeighbours(
      g,
      numberOfKeys,
      currentState,
      visited,
    )) {
      const ns = stateToString(neighbourState);
      if (visited.has(ns)) throw "133";

      seenUnvisited.add(ns);

      const newScore = currentScore + costFromHere;
      const existingScore = bestScores.get(ns);
      if (existingScore === undefined || newScore < existingScore)
        bestScores.set(ns, newScore);
    }

    visited.add(stateToString(currentState));
    seenUnvisited.delete(cs);

    if (currentState === SOLVED) {
      const answer = bestScores.get(SOLVED);
      if (answer === undefined) throw "";
      return answer;
    }

    const nextNodes = [...seenUnvisited]
      .map((state) => {
        const bestScore = bestScores.get(state);
        return {
          stateString: state,
          bestScore: bestScore === undefined ? Infinity : bestScore,
        };
      })
      .sort((a, b) => a.bestScore - b.bestScore);

    const nextNode = nextNodes[0];
    if (!nextNode) throw "No candidate next node";
    if (nextNode.bestScore === Infinity) throw "No solution";

    if (visited.has(nextNode.stateString)) throw "159";

    currentState = stringToState(nextNode.stateString);
    currentScore = nextNode.bestScore;
  }
};
