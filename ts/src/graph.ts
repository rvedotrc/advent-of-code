import { Edges } from "./edges";
import { Nodes } from "./nodes";

export type Position = string;
export type What = string;
export type Cost = number;

export class Graph {
  public readonly nodes: Nodes;
  public readonly edges: Edges;

  public static empty(): Graph {
    return new Graph(Nodes.empty(), Edges.empty());
  }

  private constructor(nodes: Nodes, edges: Edges) {
    this.nodes = nodes;
    this.edges = edges;
  }

  public toString(): string {
    return `<graph with ${this.nodes.size} nodes and ${this.edges.size} edges>`;
  }

  public [Symbol.toStringTag](): string {
    return this.toString();
  }

  public dump(): void {
    console.log(this.toString());
  }

  public addNode(position: Position, what: What): Graph {
    return new Graph(this.nodes.add(position, what), this.edges);
  }

  public removeNode(position: Position): Graph {
    if (this.edges.getByPosition(position).size > 0) throw "";

    return new Graph(this.nodes.remove(position), this.edges);
  }

  public addEdge(
    fromPosition: Position,
    toPosition: Position,
    cost: Cost,
  ): Graph {
    if (!this.nodes.has(fromPosition) || !this.nodes.has(toPosition)) throw "";

    return new Graph(
      this.nodes,
      this.edges.add(fromPosition, toPosition, cost),
    );
  }

  public addEdgeIfBetter(
    fromPosition: Position,
    toPosition: Position,
    cost: Cost,
  ): Graph {
    if (!this.nodes.has(fromPosition) || !this.nodes.has(toPosition)) throw "";

    return new Graph(
      this.nodes,
      this.edges.addIfBetter(fromPosition, toPosition, cost),
    );
  }

  public removeEdge(from: Position, to: Position): Graph {
    return new Graph(this.nodes, this.edges.remove(from, to));
  }
}
