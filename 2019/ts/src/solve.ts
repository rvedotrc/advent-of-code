import * as Immutable from "immutable";

import { CURRENT, isKey, SPACE } from "./cells";
import * as djikstra from "./djikstra";
import { graphBuilder } from "./graphBuilder";
import { reduceSpaces } from "./reduceSpaces";

type Graph = ReturnType<typeof graphBuilder>;

const getCurrentPositions = (g: Graph): Immutable.Set<number> =>
  g.nodes.byValue.get(CURRENT) || Immutable.Set();

const SOLVED: SolvedState = { solved: true };

type SolvedState = { solved: true };

type UnsolvedState = {
  solved: false;
  graph: Graph;
  keysRemaining: Immutable.Set<string>;
  currentPositions: Immutable.Set<number>;
};

type State = UnsolvedState | SolvedState;

const reduceGraph = (g: Graph) =>
  reduceSpaces(
    g,
    SPACE,
    (a: number, b: number) => a + b,
    (a: number, b: number) => a < b,
  );

const stateToKey = (s: State) =>
  s.solved
    ? "solved"
    : `unsolved/${[...s.keysRemaining].sort().join("")}/${[
        ...s.currentPositions,
      ]
        .sort((a, b) => a - b)
        .join(",")}`;

const getNextStates = (state: State): { state: State; distance: number }[] => {
  if (state.solved) return [];

  const out: ReturnType<typeof getNextStates> = [];

  for (const fromPosition of state.currentPositions) {
    const edges = state.graph.edges.getByPosition(fromPosition);
    if (!edges) throw "";

    for (const [toPosition, distance] of edges.entries()) {
      const what = state.graph.nodes.byPosition.get(toPosition);
      if (what === undefined) throw "";
      if (!isKey(what)) continue;

      const newKeysRemaining = state.keysRemaining.delete(what);

      if (newKeysRemaining.size === 0) {
        out.push({ state: SOLVED, distance });
      } else {
        const newGraph = state.graph
          .changeNode(fromPosition, SPACE)
          .changeNode(toPosition, CURRENT)
          .changeAll(what.toUpperCase(), SPACE);

        out.push({
          state: {
            solved: false,
            graph: reduceGraph(newGraph),
            keysRemaining: newKeysRemaining,
            currentPositions: state.currentPositions
              .delete(fromPosition)
              .add(toPosition),
          },
          distance,
        });
      }
    }
  }

  return out;
};

export const solve = (initialGraph: Graph): number | undefined =>
  djikstra.solve(
    {
      solved: false,
      graph: reduceGraph(initialGraph),
      keysRemaining: Immutable.Set(
        [...initialGraph.nodes.byValue.keys()].filter(isKey),
      ),
      currentPositions: getCurrentPositions(initialGraph),
    },
    stateToKey,
    getNextStates,
    (s: State) => ({ stop: s.solved }),
  );
