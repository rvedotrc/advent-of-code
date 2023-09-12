import * as Immutable from "immutable";

import { Position, What } from "./graph";

export class Nodes {
  public static empty(): Nodes {
    return new Nodes(Immutable.Map(), Immutable.Map());
  }

  public readonly byPosition: Immutable.Map<Position, What>;
  public readonly byWhat: Immutable.Map<What, Immutable.Set<Position>>;

  private constructor(
    byPosition: Immutable.Map<Position, What>,
    byWhat: Immutable.Map<What, Immutable.Set<Position>>,
  ) {
    this.byPosition = byPosition;
    this.byWhat = byWhat;
  }

  public get size(): number {
    return this.byPosition.size;
  }

  public has(position: Position): boolean {
    return this.byPosition.has(position);
  }

  public getByWhat(what: What): Immutable.Set<Position> {
    return this.byWhat.get(what) || Immutable.Set();
  }

  public add(position: Position, what: What): Nodes {
    if (this.byPosition.has(position)) throw "";

    return new Nodes(
      this.byPosition.set(position, what),
      this.byWhat.set(
        what,
        (this.byWhat.get(what) || Immutable.Set()).add(position),
      ),
    );
  }

  public remove(position: Position): Nodes {
    const oldWhat = this.byPosition.get(position);
    if (oldWhat === undefined) throw "";

    return new Nodes(
      this.byPosition.delete(position),
      this.byWhat.set(
        oldWhat,
        (this.byWhat.get(oldWhat) || Immutable.Set()).remove(position),
      ),
    );
  }

  public change(position: Position, newWhat: What): Nodes {
    const oldWhat = this.byPosition.get(position);
    if (oldWhat === undefined) throw "";
    if (oldWhat === newWhat) return this;

    return new Nodes(
      this.byPosition.set(position, newWhat),
      this.byWhat
        .set(
          oldWhat,
          (this.byWhat.get(oldWhat) || Immutable.Set()).remove(position),
        )
        .set(
          newWhat,
          (this.byWhat.get(newWhat) || Immutable.Set()).add(position),
        ),
    );
  }
}
