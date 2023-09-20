import * as Base from "./base";
import * as Immutable from "immutable";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    const diffs = this.parse(lines);
    const allPeople = [...diffs.keys()].sort();
    const firstToBeSeated = allPeople[0];

    const getDiff = (a: string, b: string): number => {
      const s0 = diffs.get(a)?.get(b);
      const s1 = diffs.get(b)?.get(a);
      if (s0 === undefined || s1 === undefined) throw `21 ${a} ${b}`;
      return s0 + s1;
    };

    const queue = [
      {
        score: 0,
        seated: [firstToBeSeated],
        unseated: Immutable.Set.of(...allPeople).remove(firstToBeSeated),
        right: firstToBeSeated,
      },
    ];

    let bestResult = -Infinity;

    while (true) {
      const item = queue.shift();
      if (!item) break;

      if (item.unseated.size === 0) {
        const score = item.score + getDiff(firstToBeSeated, item.right);
        if (score > bestResult) bestResult = score;
      } else {
        queue.push(
          ...[...item.unseated].sort().map(toSeat => ({
            score: item.score + getDiff(item.right, toSeat),
            seated: [...item.seated, toSeat],
            unseated: item.unseated.remove(toSeat),
            right: toSeat,
          }))
        );
      }
    }

    return bestResult.toString();
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }

  protected parse(lines: string[]): Map<string, Map<string, number>> {
    const r: Map<string, Map<string, number>> = new Map();

    for (const line of lines) {
      const m = line.match(
        /^(?<a>\S+) would (?<g>gain|lose) (?<n>[0-9]+) happiness units by sitting next to (?<b>\S+)\.$/
      );
      if (!m?.groups) throw `? ${line}`;

      const { a, b, g, n } = m.groups;
      const diff = Number(n) * (g === "gain" ? 1 : -1);

      if (!r.has(a)) {
        r.set(a, new Map().set(b, diff));
      } else {
        r.get(a)?.set(b, diff);
      }
    }

    return r;
  }
}

export class Part2 extends Part1 {
  protected parse(lines: string[]): Map<string, Map<string, number>> {
    const diffs = super.parse(lines);
    const me = "";
    const allPeople = [...diffs.keys()].sort();

    for (const sub of diffs.values()) {
      sub.set(me, 0);
    }

    diffs.set(
      me,
      allPeople.reduce((sub, other) => sub.set(other, 0), new Map())
    );

    return diffs;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}
