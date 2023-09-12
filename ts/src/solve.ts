import * as Immutable from "immutable";

import { CURRENT, isKey, SPACE } from "./cells";
import { Cost, Graph, Position } from "./graph";
import { reduceSpaces } from "./reduceSpaces";

const getCurrentPositions = (g: Graph): Immutable.Set<Position> =>
  g.nodes.byWhat.get(CURRENT) || Immutable.Set();

const SOLVED = {
  solved: true as const,
  key: "solved",
};

type SolvedState = typeof SOLVED;

class UnsolvedState {
  public readonly solved: false;
  public readonly graph: Graph;
  public readonly keysHeld: Immutable.Set<string>;
  public readonly currentPositions: Immutable.Set<Position>;
  public readonly key: string;

  constructor(graph: Graph, keysHeld: Immutable.Set<string>) {
    this.graph = reduceSpaces(graph);
    this.keysHeld = keysHeld;
    this.currentPositions = getCurrentPositions(graph);
    this.key = `${[...keysHeld].sort().join("")}/${[...this.currentPositions]
      .sort((a, b) => a - b)
      .join(",")}`;
  }
}

type State = (UnsolvedState & { solved: false }) | SolvedState;

const unvisitedNeighbours = (
  numberOfKeys: number,
  currentState: State,
  visited: Set<string>,
): { neighbourState: State; costFromHere: Cost }[] => {
  if (currentState.solved) return [];

  const out: ReturnType<typeof unvisitedNeighbours> = [];

  for (const fromPosition of currentState.currentPositions) {
    const edges = currentState.graph.edges.getByPosition(fromPosition);
    if (!edges) throw "";

    for (const [toPosition, costFromHere] of edges.entries()) {
      const what = currentState.graph.nodes.byPosition.get(toPosition);
      if (what === undefined) throw "";
      if (!isKey(what)) continue;

      const newKeysHeld = currentState.keysHeld.add(what);

      if (newKeysHeld.size === numberOfKeys) {
        out.push({ neighbourState: SOLVED, costFromHere });
      } else {
        const newGraph = currentState.graph
          .changeNode(fromPosition, SPACE)
          .changeNode(toPosition, CURRENT)
          .changeAll(what.toUpperCase(), SPACE);

        out.push({
          neighbourState: new UnsolvedState(newGraph, newKeysHeld),
          costFromHere,
        });
      }
    }
  }

  const r = out.filter((ans) => !visited.has(ans.neighbourState.key));

  return r;
};

export const solve = (initialGraph: Graph): number => {
  let currentState: State = new UnsolvedState(initialGraph, Immutable.Set());
  let currentScore = 0;

  const numberOfKeys = [...initialGraph.nodes.byWhat.keys()].filter(
    isKey,
  ).length;

  const bestScores = new Map<string, number>().set(
    currentState.key,
    currentScore,
  );
  const visited = new Set<string>();
  const seenUnvisited = new Map<string, State>();

  while (true) {
    if (visited.has(currentState.key)) throw "124";

    for (const { neighbourState, costFromHere } of unvisitedNeighbours(
      numberOfKeys,
      currentState,
      visited,
    )) {
      if (visited.has(neighbourState.key)) throw "133";

      seenUnvisited.set(neighbourState.key, neighbourState);

      const newScore = currentScore + costFromHere;
      const existingScore = bestScores.get(neighbourState.key);
      if (existingScore === undefined || newScore < existingScore)
        bestScores.set(neighbourState.key, newScore);
    }

    visited.add(currentState.key);
    seenUnvisited.delete(currentState.key);

    if (currentState.solved) {
      const answer = bestScores.get(currentState.key);
      if (answer === undefined) throw "";
      return answer;
    }

    const nextNodes = [...seenUnvisited.entries()]
      .map(([key, state]) => {
        const bestScore = bestScores.get(key);
        return {
          state,
          bestScore: bestScore === undefined ? Infinity : bestScore,
        };
      })
      .sort((a, b) => a.bestScore - b.bestScore);

    const nextNode = nextNodes[0];
    if (!nextNode) throw "No candidate next node";
    if (nextNode.bestScore === Infinity) throw "No solution";

    if (visited.has(nextNode.state.key)) throw "159";

    currentState = nextNode.state;
    currentScore = nextNode.bestScore;
  }
};
