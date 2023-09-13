import * as Immutable from "immutable";

import { Edges } from "./edges";
import { Nodes } from "./nodes";

export class Graph<Position, NodeValue, EdgeValue> {
  public readonly nodes: Nodes<Position, NodeValue>;
  public readonly edges: Edges<Position, EdgeValue>;

  public static empty<P, N, E>(): Graph<P, N, E> {
    return new Graph(Nodes.empty(), Edges.empty());
  }

  private constructor(
    nodes: Nodes<Position, NodeValue>,
    edges: Edges<Position, EdgeValue>,
  ) {
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

  public addNode(
    position: Position,
    what: NodeValue,
  ): Graph<Position, NodeValue, EdgeValue> {
    return new Graph(this.nodes.add(position, what), this.edges);
  }

  public removeNode(position: Position): Graph<Position, NodeValue, EdgeValue> {
    if (this.edges.getByPosition(position).size > 0) throw "";

    return new Graph(this.nodes.remove(position), this.edges);
  }

  public addEdge(
    fromPosition: Position,
    toPosition: Position,
    cost: EdgeValue,
  ): Graph<Position, NodeValue, EdgeValue> {
    if (!this.nodes.has(fromPosition) || !this.nodes.has(toPosition)) throw "";

    return new Graph(
      this.nodes,
      this.edges.add(fromPosition, toPosition, cost),
    );
  }

  public addEdgeIfBetter(
    fromPosition: Position,
    toPosition: Position,
    cost: EdgeValue,
    better: (a: EdgeValue, b: EdgeValue) => boolean,
  ): Graph<Position, NodeValue, EdgeValue> {
    if (!this.nodes.has(fromPosition) || !this.nodes.has(toPosition)) throw "";

    return new Graph(
      this.nodes,
      this.edges.addIfBetter(fromPosition, toPosition, cost, better),
    );
  }

  public removeEdge(
    from: Position,
    to: Position,
  ): Graph<Position, NodeValue, EdgeValue> {
    return new Graph(this.nodes, this.edges.remove(from, to));
  }

  public changeNode(
    position: Position,
    newWhat: NodeValue,
  ): Graph<Position, NodeValue, EdgeValue> {
    return new Graph(this.nodes.change(position, newWhat), this.edges);
  }

  public changeAll(
    oldWhat: NodeValue,
    newWhat: NodeValue,
  ): Graph<Position, NodeValue, EdgeValue> {
    const positions = this.nodes.byValue.get(oldWhat) || Immutable.Set();

    return positions.reduce((g, pos) => g.changeNode(pos, newWhat), this);
  }
}
