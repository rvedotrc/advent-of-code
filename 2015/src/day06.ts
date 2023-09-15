import * as Base from "./base";

type NumberRange = { from: number; to: number };
type Region = NumberRange[];

type Lights = {
  region: Region;
  on: number;
};

type Command = {
  region: Region;
  raw: string;
  command: { and: 1 | 0; xor: 1 | 0 };
};

const commandMap: Record<string, Command["command"]> = {
  "turn on": { and: 0, xor: 1 },
  "turn off": { and: 0, xor: 0 },
  toggle: { and: 1, xor: 1 },
};

const noOp: Command["command"] = { and: 1, xor: 0 };

const sizeOf = (r: Region): number =>
  r.reduce((a, b) => a * (b.to - b.from), 1);

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    let lights: Lights[] = [
      {
        region: [
          { from: 0, to: 1000 },
          { from: 0, to: 1000 },
        ],
        on: 0,
      },
    ];

    for (const line of lines) {
      // console.log(JSON.stringify({ lightsBefore: lights }, null, 2));
      const command = this.lineToCommand(line);
      const size = lights.reduce((n, l) => sizeOf(l.region) + n, 0);
      // console.log(JSON.stringify({ line, n: lights.length, size, command }));
      // console.log(JSON.stringify({ lightsBefore: lights }, null, 2));
      if (size !== 1000000) {
        throw "abort";
      }
      lights = this.apply(command, lights);
    }

    // console.log(JSON.stringify({ lightsFinal: lights }, null, 2));

    return this.score(lights).toString();
  }

  score(lights: Lights[]): number {
    return lights
      .filter(l => l.on === 1)
      .map(l => sizeOf(l.region))
      .reduce((a, b) => a + b, 0);
  }

  lineToCommand(line: string): Command {
    const m = line.match(
      /^(?<c>turn on|turn off|toggle) (?<x0>[0-9]+),(?<y0>[0-9]+) through (?<x1>[0-9]+),(?<y1>[0-9]+)$/
    );
    if (!m?.groups) throw `? ${line}`;

    return {
      region: [
        { from: Number(m.groups["x0"]), to: Number(m.groups["x1"]) + 1 },
        { from: Number(m.groups["y0"]), to: Number(m.groups["y1"]) + 1 },
      ],
      raw: m.groups["c"],
      command: commandMap[m.groups["c"]] || noOp,
    };
  }

  apply(command: Command, lights: Lights[]): Lights[] {
    return lights.flatMap(l => {
      const r = this.findOverlaps(l.region, command.region);

      // console.log(JSON.stringify({ r }, null, 2));

      return [
        ...r.aAndNotB.map(region => ({ region, on: l.on })),
        ...r.aAndB.map(region => ({
          region,
          on: ((l.on & command.command.and) ^ command.command.xor) as 0 | 1,
        })),
      ];
    });
  }

  findOverlaps(
    a: Region,
    b: Region,
    i = 0
  ): { aAndB: Region[]; aAndNotB: Region[] } {
    // console.log(JSON.stringify({ findOverlaps: { i, a, b } }));
    if (i === a.length) return { aAndB: [a], aAndNotB: [] };

    const xo = this.rangeOverlaps(a[i], b[i]);
    // console.log(JSON.stringify({ a, b, i, xo }));

    const r: ReturnType<Part1["findOverlaps"]> = {
      aAndB: [],
      aAndNotB: [],
    };

    const set = (region: Region, range: NumberRange): Region => [
      ...region.slice(0, i),
      range,
      ...region.slice(i + 1),
    ];

    r.aAndNotB.push(...xo.aAndNotB.map(range => set(a, range)));

    for (const range of xo.aAndB) {
      const o = this.findOverlaps(set(a, range), b, i + 1);
      r.aAndNotB.push(...o.aAndNotB);
      r.aAndB.push(...o.aAndB);
    }

    if (
      sizeOf(a) !==
      [...r.aAndB, ...r.aAndNotB].reduce((s, reg) => s + sizeOf(reg), 0)
    ) {
      console.error(
        JSON.stringify({ badFindOverlaps: { i, a, b, r } }, null, 2)
      );
      throw "abort";
      // } else {
      // console.debug(JSON.stringify({ goodFindOverlaps: { i, a, b, r } }));
    }

    return r;
  }

  rangeOverlaps(
    a: NumberRange,
    b: NumberRange
  ): { aAndB: NumberRange[]; aAndNotB: NumberRange[] } {
    const r =
      a.from >= b.to
        ? {
            // a is after b
            aAndB: [],
            aAndNotB: [a],
          }
        : a.to <= b.from
        ? {
            // a is before b
            aAndB: [],
            aAndNotB: [a],
          }
        : a.from >= b.from && a.to <= b.to
        ? {
            // a is inside b
            aAndB: [a],
            aAndNotB: [],
          }
        : a.from <= b.from && a.to >= b.to
        ? {
            // b is inside a
            aAndB: [b],
            aAndNotB: [
              { from: a.from, to: b.from }, // the part of a before b
              { from: b.to, to: a.to }, // the part of a after b
            ],
          }
        : b.from <= a.from && b.to <= a.to
        ? {
            // b-overlap-a
            aAndB: [{ from: a.from, to: b.to }],
            aAndNotB: [{ from: b.to, to: a.to }],
          }
        : {
            // a-overlap-b
            aAndNotB: [{ from: a.from, to: b.from }],
            aAndB: [{ from: b.from, to: a.to }],
          };

    const inSize = a.to - a.from;
    const outSize = [...r.aAndB, ...r.aAndNotB].reduce(
      (n, range) => n + (range.to - range.from),
      0
    );
    // console.log(
    //   JSON.stringify({ rangeOverlaps: { inSize, outSize, a, b, r } })
    // );
    if (inSize !== outSize) throw "abort";

    return r;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      // 4-8, 4-10
      this.check("example A", ["turn on 4,4 through 7,9"], "24"),
    ];
  }
}

export class Part2 extends Part1 {
  score(lights: Lights[]): number {
    return lights.reduce((a, b) => a + sizeOf(b.region) * b.on, 0);
  }

  apply(command: Command, lights: Lights[]): Lights[] {
    return lights.flatMap(l => {
      const r = this.findOverlaps(l.region, command.region);

      // console.log(JSON.stringify({ r }, null, 2));

      return [
        ...r.aAndNotB.map(region => ({ region, on: l.on })),
        ...r.aAndB.map(region => ({
          region,
          on:
            command.raw === "turn on"
              ? l.on + 1
              : command.raw === "toggle"
              ? l.on + 2
              : l.on > 0
              ? l.on - 1
              : 0,
        })),
      ];
    });
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [this.check("example A", ["turn on 4,4 through 7,9"], "24")];
  }
}
