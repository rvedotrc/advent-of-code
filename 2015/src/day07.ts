import * as Base from "./base";

type Source = number | string;
type Destination = string;

type Wire =
  | {
      type: "copy";
      sources: [Source];
      destination: Destination;
    }
  | {
      type: "NOT";
      sources: [Source];
      destination: Destination;
    }
  | {
      type: "AND" | "OR" | "LSHIFT" | "RSHIFT";
      sources: [Source, Source];
      destination: Destination;
    };

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    return (await this.allWires(lines)).get("a")?.toString() || "";
  }

  async allWires(lines: string[]): Promise<Map<string, number>> {
    const wires = this.parseAll(lines);
    const map = new Map<string, number | undefined>();

    while (true) {
      let added = false;

      for (const wire of wires) {
        if (map.get(wire.destination) !== undefined) continue;
        const answer = this.resolve(wire, map);
        if (answer !== undefined) added = true;
        map.set(wire.destination, answer);
      }

      if (!added) throw "stuck";

      if ([...map.values()].every(t => typeof t === "number"))
        return map as Map<string, number>;
    }
  }

  parseAll(lines: string[]): Wire[] {
    return lines.map(t => this.parseLine(t));
  }

  resolve(
    wire: Wire,
    map: Map<string, number | undefined>
  ): number | undefined {
    const sources = wire.sources.map(src => {
      if (typeof src === "number") return src;
      return map.get(src);
    });

    if (!sources.every(src => src !== undefined)) return undefined;
    const numberSources = sources as number[];

    if (wire.type === "copy") return numberSources[0];
    if (wire.type === "NOT") return numberSources[0] ^ 0xffff;
    if (wire.type === "AND") return numberSources[0] & numberSources[1];
    if (wire.type === "OR") return numberSources[0] | numberSources[1];
    if (wire.type === "LSHIFT") return numberSources[0] << numberSources[1];
    if (wire.type === "RSHIFT") return numberSources[0] >> numberSources[1];

    throw "";
  }

  parseLine(t: string): Wire {
    const fail = (): string => {
      throw "fail";
    };
    const src = (s: string) => (s >= "a" && s <= "z" ? s : Number(s));

    let m = t.match(/^(?<s0>[0-9]+|[a-z]+) -> (?<d>[a-z]+)$/);
    if (m?.groups)
      return {
        type: "copy",
        sources: [src(m.groups["s0"] || fail())],
        destination: m.groups["d"],
      };

    m = t.match(/^NOT (?<s0>[0-9]+|[a-z]+) -> (?<d>[a-z]+)$/);
    if (m?.groups)
      return {
        type: "NOT",
        sources: [src(m.groups["s0"] || fail())],
        destination: m.groups["d"],
      };

    m = t.match(
      /^(?<s0>[0-9]+|[a-z]+) (?<op>AND|OR|LSHIFT|RSHIFT) (?<s1>[0-9]+|[a-z]+) -> (?<d>[a-z]+)$/
    );
    if (m?.groups)
      return {
        type: m.groups["op"] as "AND", // for example
        sources: [src(m.groups["s0"] || fail()), src(m.groups["s1"] || fail())],
        destination: m.groups["d"],
      };

    throw `? ${t}`;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    const actual = await this.allWires([
      "123 -> x",
      "456 -> y",
      "x AND y -> d",
      "x OR y -> e",
      "x LSHIFT 2 -> f",
      "y RSHIFT 2 -> g",
      "NOT x -> h",
      "NOT y -> i",
    ]);

    return [
      this.checkResult("example 1 d", (actual.get("d") || -1).toString(), "72"),
      this.checkResult(
        "example 1 e",
        (actual.get("e") || -1).toString(),
        "507"
      ),
      this.checkResult(
        "example 1 f",
        (actual.get("f") || -1).toString(),
        "492"
      ),
      this.checkResult(
        "example 1 g",
        (actual.get("g") || -1).toString(),
        "114"
      ),
      this.checkResult(
        "example 1 h",
        (actual.get("h") || -1).toString(),
        "65412"
      ),
      this.checkResult(
        "example 1 i",
        (actual.get("i") || -1).toString(),
        "65079"
      ),
      this.checkResult(
        "example 1 x",
        (actual.get("x") || -1).toString(),
        "123"
      ),
      this.checkResult(
        "example 1 y",
        (actual.get("y") || -1).toString(),
        "456"
      ),
    ];
  }
}

export class Part2 extends Part1 {
  private part1a: string | undefined;

  async calculate(lines: string[]): Promise<string> {
    this.part1a = await new Part1().calculate(lines);
    return await super.calculate(lines);
  }

  parseAll(lines: string[]): Wire[] {
    return [
      ...super
        .parseAll(lines)
        .filter(w => !(w.type === "copy" && w.destination === "b")),
      { type: "copy", sources: [Number(this.part1a)], destination: "b" },
    ];
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}
