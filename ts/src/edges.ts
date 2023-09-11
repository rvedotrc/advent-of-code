import * as Immutable from "immutable";

import { Cost, Position } from "./graph";

export class Edges {
  public readonly map: Immutable.Map<Position, Immutable.Map<Position, Cost>>;

  public static empty(): Edges {
    return new Edges(Immutable.Map());
  }

  private constructor(
    map: Immutable.Map<Position, Immutable.Map<Position, Cost>>,
  ) {
    this.map = map;
  }

  public get size(): number {
    return [...this.map.values()]
      .map((s) => s.size)
      .reduce((prev, curr) => prev + curr, 0);
  }

  public getByPosition(position: Position): Immutable.Map<Position, Cost> {
    return this.map.get(position) || Immutable.Map();
  }

  public add(fromPosition: Position, toPosition: Position, cost: Cost): Edges {
    if (fromPosition === toPosition) throw "";

    if (this.map.get(fromPosition)?.get(toPosition) !== undefined) throw "";

    return this.set(fromPosition, toPosition, cost);
  }

  public addIfBetter(
    fromPosition: Position,
    toPosition: Position,
    cost: Cost,
  ): Edges {
    const existingCost = this.map.get(fromPosition)?.get(toPosition);
    if (existingCost !== undefined && existingCost < cost) return this;

    return this.set(fromPosition, toPosition, cost);
  }

  private set(fromPosition: Position, toPosition: Position, cost: Cost): Edges {
    return new Edges(
      this.map
        .set(
          fromPosition,
          (this.map.get(fromPosition) || Immutable.Map()).set(toPosition, cost),
        )
        .set(
          toPosition,
          (this.map.get(toPosition) || Immutable.Map()).set(fromPosition, cost),
        ),
    );
  }

  public remove(fromPosition: Position, toPosition: Position): Edges {
    if (this.map.get(fromPosition)?.get(toPosition) === undefined) throw "";

    return new Edges(
      this.map
        .set(
          fromPosition,
          (this.map.get(fromPosition) || Immutable.Map()).delete(toPosition),
        )
        .set(
          toPosition,
          (this.map.get(toPosition) || Immutable.Map()).delete(fromPosition),
        ),
    );
  }
}
