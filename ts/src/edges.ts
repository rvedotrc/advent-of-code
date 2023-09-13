import * as Immutable from "immutable";

import { Cost, Position } from "./graph";

export class Edges {
  public readonly map: Immutable.Map<Position, Immutable.Map<Position, Cost>>;
  public readonly size: number;

  public static empty(): Edges {
    return new Edges(Immutable.Map(), 0);
  }

  private constructor(
    map: Immutable.Map<Position, Immutable.Map<Position, Cost>>,
    size: number,
  ) {
    this.map = map;
    this.size = size;
  }

  public getByPosition(position: Position): Immutable.Map<Position, Cost> {
    return this.map.get(position) || Immutable.Map();
  }

  public add(fromPosition: Position, toPosition: Position, cost: Cost): Edges {
    if (fromPosition === toPosition) throw "";

    if (this.map.get(fromPosition)?.get(toPosition) !== undefined) throw "";

    return this.set(fromPosition, toPosition, cost, 1);
  }

  public addIfBetter(
    fromPosition: Position,
    toPosition: Position,
    cost: Cost,
  ): Edges {
    const existingCost = this.map.get(fromPosition)?.get(toPosition);
    if (existingCost !== undefined && existingCost < cost) return this;

    return this.set(
      fromPosition,
      toPosition,
      cost,
      existingCost === undefined ? 1 : 0,
    );
  }

  private set(
    fromPosition: Position,
    toPosition: Position,
    cost: Cost,
    sizeDelta: 0 | 1,
  ): Edges {
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
      this.size + sizeDelta,
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
      this.size - 1,
    );
  }
}
