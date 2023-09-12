import * as Immutable from "immutable";

import { CURRENT, isKey, SPACE } from "./cells";
import * as djikstra from "./djikstra";
import { Cost, Graph, Position } from "./graph";
import { reduceSpaces } from "./reduceSpaces";

const getCurrentPositions = (g: Graph): Immutable.Set<Position> =>
  g.nodes.byWhat.get(CURRENT) || Immutable.Set();

const SOLVED: SolvedState = { solved: true };

type SolvedState = { solved: true };

type UnsolvedState = {
  solved: false;
  graph: Graph;
  keysRemaining: Immutable.Set<string>;
  currentPositions: Immutable.Set<Position>;
};

type State = UnsolvedState | SolvedState;

const stateToKey = (s: State) =>
  s.solved
    ? "solved"
    : `unsolved/${[...s.keysRemaining].sort().join("")}/${[
        ...s.currentPositions,
      ]
        .sort((a, b) => a - b)
        .join(",")}`;

const getNextStates = (state: State): { state: State; distance: Cost }[] => {
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
            graph: reduceSpaces(newGraph),
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
      graph: reduceSpaces(initialGraph),
      keysRemaining: Immutable.Set(
        [...initialGraph.nodes.byWhat.keys()].filter(isKey),
      ),
      currentPositions: getCurrentPositions(initialGraph),
    },
    stateToKey,
    getNextStates,
    (s: State) => ({ stop: s.solved }),
  );
