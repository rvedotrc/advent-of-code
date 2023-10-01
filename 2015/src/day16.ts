import * as Base from "./base";

type Sue = {
  name: string;
  counts: Partial<Counts>;
};

type Counts = {
  children: number;
  cats: number;
  samoyeds: number;
  pomeranians: number;
  akitas: number;
  vizslas: number;
  goldfish: number;
  trees: number;
  cars: number;
  perfumes: number;
};

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    const sues = lines.map(t => this.parse(t));

    const g = this.goal();
    const matching = sues.filter(s => this.countsMatch(s.counts, g));
    if (matching.length !== 1) throw `Got ${matching.length} matches, not 1`;

    return matching[0].name.replace("Sue ", "");
  }

  parse(line: string): Sue {
    const i = line.indexOf(": ");
    // Why doesn't split(..., 2) work here?
    const [name, countsText] = [line.substr(0, i), line.substr(i + 2)];
    const pairs = countsText.split(", ");
    const c: Partial<Counts> = {};
    for (const pair of pairs) {
      const [key, num] = pair.split(": ");
      c[key as keyof Counts] = Number(num);
    }
    return { name, counts: c };
  }

  goal(): Counts {
    return {
      children: 3,
      cats: 7,
      samoyeds: 2,
      pomeranians: 3,
      akitas: 0,
      vizslas: 0,
      goldfish: 5,
      trees: 3,
      cars: 2,
      perfumes: 1,
    };
  }

  countsMatch(a: Partial<Counts>, b: Counts): boolean {
    for (const ks in a) {
      const k = ks as keyof Counts;
      const av = a[k];
      const bv = b[k];
      if (av !== undefined && av !== bv) return false;
    }
    return true;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}

const equalFields: (keyof Counts)[] = [
  "children",
  "samoyeds",
  "akitas",
  "vizslas",
  "cars",
  "perfumes",
];

export class Part2 extends Part1 {
  countsMatch(candidate: Partial<Counts>, actual: Counts): boolean {
    if (candidate.cats !== undefined && candidate.cats <= actual.cats)
      return false;
    if (candidate.trees !== undefined && candidate.trees <= actual.trees)
      return false;

    if (
      candidate.pomeranians !== undefined &&
      candidate.pomeranians >= actual.pomeranians
    )
      return false;
    if (
      candidate.goldfish !== undefined &&
      candidate.goldfish >= actual.goldfish
    )
      return false;

    for (const k of equalFields) {
      if (candidate[k] !== undefined && actual[k] !== candidate[k])
        return false;
    }
    return true;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}
