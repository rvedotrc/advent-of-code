import * as Base from "./base";
import * as Immutable from "immutable";
import * as djikstra from "./djikstra";

type State =
  | "start"
  | { visited: Immutable.Set<string>; current: string }
  | "end";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    const distances = this.readDistances(lines);
    const best = this.shortest(distances);
    if (best === undefined) throw "no solution";

    return best.toString();
  }

  readDistances(lines: string[]): Map<string, Map<string, number>> {
    const distances = new Map<string, Map<string, number>>();

    for (const line of lines) {
      const m = line.match(
        /^(?<from>.*?) to (?<to>.*?) = (?<distance>[0-9]+)$/
      );
      if (!m?.groups) throw `? ${line}`;

      const from = m.groups["from"];
      const to = m.groups["to"];
      const distance = Number(m.groups["distance"]);

      if (!distances.has(from)) distances.set(from, new Map());
      if (!distances.has(to)) distances.set(to, new Map());

      distances.get(from)?.set(to, distance);
      distances.get(to)?.set(from, distance);
    }

    return distances;
  }

  makeKey(s: State): string {
    return s === "start" || s === "end"
      ? s
      : `${[...s.visited.values()].sort().join(",")}/${s.current}`;
  }

  shortest(
    distances: Map<string, Map<string, number>>
  ): ReturnType<typeof djikstra.solve> {
    return djikstra.solve(
      "start" as State,
      s => this.makeKey(s),
      s => {
        if (s === "start") {
          return [...distances.keys()].map(city => ({
            state: {
              visited: Immutable.Set<string>().add(city),
              current: city,
            },
            distance: 0,
          }));
        } else if (s === "end") {
          return [];
        } else {
          const d = distances.get(s.current);
          if (!d) throw "";
          return [...d.entries()]
            .filter(([k]) => !s.visited.has(k))
            .map(([k, v]) =>
              s.visited.add(k).size === distances.size
                ? { state: "end" as State, distance: v }
                : {
                    state: { visited: s.visited.add(k), current: k },
                    distance: v,
                  }
            );
        }
      },
      s => ({ stop: s === "end" })
    );
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check(
        "example",
        [
          "London to Dublin = 464",
          "London to Belfast = 518",
          "Dublin to Belfast = 141",
        ],
        "605"
      ),
    ];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    const distances = this.readDistances(lines);

    const hops = distances.size - 1;

    const allDistances = [...distances.values()].flatMap(m => [...m.values()]);
    const maxDistance = allDistances.sort((a, b) => b - a)[0];

    for (const [_k0, v0] of distances.entries()) {
      for (const [k1, v1] of v0) {
        v0.set(k1, maxDistance - v1);
      }
    }

    const best = this.shortest(distances);
    if (!best) throw "no solution";

    const longest = maxDistance * hops - best;
    return longest.toString();
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check(
        "example",
        [
          "London to Dublin = 464",
          "London to Belfast = 518",
          "Dublin to Belfast = 141",
        ],
        "982"
      ),
    ];
  }
}
