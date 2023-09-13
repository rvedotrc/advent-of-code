import * as Immutable from "immutable";

export class Edges<Position, Value> {
  public readonly map: Immutable.Map<Position, Immutable.Map<Position, Value>>;
  public readonly size: number;

  public static empty<P, V>(): Edges<P, V> {
    return new Edges(Immutable.Map(), 0);
  }

  private constructor(
    map: Immutable.Map<Position, Immutable.Map<Position, Value>>,
    size: number,
  ) {
    this.map = map;
    this.size = size;
  }

  public getByPosition(position: Position): Immutable.Map<Position, Value> {
    return this.map.get(position) || Immutable.Map();
  }

  public add(
    fromPosition: Position,
    toPosition: Position,
    cost: Value,
  ): Edges<Position, Value> {
    if (fromPosition === toPosition) throw "";

    if (this.map.get(fromPosition)?.get(toPosition) !== undefined) throw "";

    return this.set(fromPosition, toPosition, cost, 1);
  }

  public addIfBetter(
    fromPosition: Position,
    toPosition: Position,
    value: Value,
    better: (a: Value, b: Value) => boolean,
  ): Edges<Position, Value> {
    const existingValue = this.map.get(fromPosition)?.get(toPosition);
    if (existingValue !== undefined && !better(value, existingValue))
      return this;

    return this.set(
      fromPosition,
      toPosition,
      value,
      existingValue === undefined ? 1 : 0,
    );
  }

  private set(
    fromPosition: Position,
    toPosition: Position,
    cost: Value,
    sizeDelta: 0 | 1,
  ): Edges<Position, Value> {
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

  public remove(
    fromPosition: Position,
    toPosition: Position,
  ): Edges<Position, Value> {
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
