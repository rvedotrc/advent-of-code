import * as Immutable from "immutable";

// An immutable set of nodes (uniquely identified by their Position),
// where each node has a Value. You can query for all nodes with
// a specific value.

// Position and Value must be types which can be used as Map keys or
// Set members.

export class Nodes<Position, Value> {
  public static empty<P, V>(): Nodes<P, V> {
    return new Nodes(Immutable.Map(), Immutable.Map());
  }

  public readonly byPosition: Immutable.Map<Position, Value>;
  public readonly byValue: Immutable.Map<Value, Immutable.Set<Position>>;

  private constructor(
    byPosition: Immutable.Map<Position, Value>,
    byValue: Immutable.Map<Value, Immutable.Set<Position>>,
  ) {
    this.byPosition = byPosition;
    this.byValue = byValue;
  }

  public get size(): number {
    return this.byPosition.size;
  }

  public has(position: Position): boolean {
    return this.byPosition.has(position);
  }

  public getByValue(value: Value): Immutable.Set<Position> {
    return this.byValue.get(value) || Immutable.Set();
  }

  public add(position: Position, value: Value): Nodes<Position, Value> {
    if (this.byPosition.has(position)) throw "";

    return new Nodes(
      this.byPosition.set(position, value),
      this.byValue.set(
        value,
        (this.byValue.get(value) || Immutable.Set()).add(position),
      ),
    );
  }

  public remove(position: Position): Nodes<Position, Value> {
    const oldValue = this.byPosition.get(position);
    if (oldValue === undefined) throw "";

    return new Nodes(
      this.byPosition.delete(position),
      this.byValue.set(
        oldValue,
        (this.byValue.get(oldValue) || Immutable.Set()).remove(position),
      ),
    );
  }

  public change(position: Position, newValue: Value): Nodes<Position, Value> {
    const oldValue = this.byPosition.get(position);
    if (oldValue === undefined) throw "";
    if (oldValue === newValue) return this;

    return new Nodes(
      this.byPosition.set(position, newValue),
      this.byValue
        .set(
          oldValue,
          (this.byValue.get(oldValue) || Immutable.Set()).remove(position),
        )
        .set(
          newValue,
          (this.byValue.get(newValue) || Immutable.Set()).add(position),
        ),
    );
  }
}
