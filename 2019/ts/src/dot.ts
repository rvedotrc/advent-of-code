import { Graph } from "./graph";

const positionToId = (position: number) => `"${position}"`;

export const graphToDot = (g: Graph<number, string, number>): string => {
  const s: string[] = [];

  s.push("graph {");

  for (const [position, what] of g.nodes.byPosition) {
    s.push(`  ${positionToId(position)} [label="${what}"]`);
  }

  for (const [fromPosition, neighbours] of g.edges.map) {
    for (const [toPosition, cost] of neighbours) {
      if (fromPosition < toPosition) {
        s.push(
          `  ${positionToId(fromPosition)} -- ${positionToId(
            toPosition,
          )} [label="${cost}"]`,
        );
      }
    }
  }

  s.push("}");

  s.push("");
  return s.join("\n");
};
