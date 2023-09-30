import * as Base from "./base";

const atomRe = /(?:e|[A-Z][a-z]?)/g;

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    const { molecule, elementPattern, replacements } = this.setup(lines);
    return this.iterate(molecule, elementPattern, replacements).size.toString();
  }

  setup(lines: string[]): {
    atoms: Set<string>;
    molecule: string;
    elementPattern: RegExp;
    replacements: Map<string, string[]>;
  } {
    const atoms = new Set(
      [...lines.join(" ").matchAll(atomRe)].flatMap(m => m[0]).filter(Boolean)
    );

    const replacementSpecs = [...lines];
    const molecule = replacementSpecs.pop();
    replacementSpecs.pop();
    if (!molecule) throw "";

    const replacements = new Map<string, string[]>();

    for (const spec of replacementSpecs) {
      const [left, _ignore, right] = spec.split(" ");
      const list = replacements.get(left);
      if (list !== undefined) {
        list.push(right);
      } else {
        replacements.set(left, [right]);
      }
    }

    const elementPattern = new RegExp([...replacements.keys()].join("|"), "g");
    console.log({ elementPattern });

    return { atoms, molecule, elementPattern, replacements };
  }

  iterate(
    molecule: string,
    elementPattern: RegExp,
    replacements: Map<string, string[]>
  ): Set<string> {
    const seen = new Set<string>();

    for (const m of molecule.matchAll(elementPattern)) {
      const element = m[0];
      if (element === "") continue;

      const index = m.index;
      if (index === undefined) throw "";

      const list = replacements.get(element) || [];

      for (const r of list) {
        const makes =
          molecule.substr(0, index) +
          r +
          molecule.substr(index + element.length);

        seen.add(makes);
      }
    }

    return seen;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    const { atoms, molecule, replacements } = this.setup(lines);

    const flatReplacements = [...replacements.entries()].flatMap(
      ([lhs, list]) => list.map(rhs => ({ lhs, rhs }))
    );
    const reverseFlatReplacements = flatReplacements.map(({ lhs, rhs }) => ({
      lhs: rhs,
      rhs: lhs,
    }));

    const reverseReplacements = new Map<string, string[]>();
    flatReplacements.forEach(({ lhs, rhs }) => {
      [lhs, rhs] = [rhs, lhs];
      const e = reverseReplacements.get(lhs);
      if (e === undefined) {
        reverseReplacements.set(lhs, [rhs]);
      } else {
        e.push(rhs);
      }
    });

    const chainRe = new RegExp(
      `(?<chain>${[...reverseReplacements.keys()].join("|")})(?![a-z])`,
      "g"
    );
    console.log({ chainRe });

    console.log({ atoms: [...atoms].sort().join("/") });

    // const inert = [...atoms].filter(atom => !replacements.has(atom)).sort();
    //
    // for (const g of inert) {
    //   console.log(`inert: ${g}`);
    //   for (const l of lines) {
    //     console.log(
    //       `  ${l.replace(
    //         new RegExp(`${g}(?![a-z])`, "g"),
    //         s => `\x1b[31m${s}\x1b[0m`
    //       )}`
    //     );
    //   }
    // }

    // molecule;
    reverseFlatReplacements;
    let chain = molecule;
    while (true) {
      const all: { index: number; s: string }[] = [...chain.matchAll(chainRe)]
        .map(match => {
          const x = match.groups?.chain;
          if (x && match.index !== undefined)
            return { index: match.index, s: x };
          return undefined as unknown as { index: number; s: string };
        })
        .filter(s => s !== undefined);
      console.log({ chain, all });
      if (all.length === 0) break;

      const byLength = all.sort((a, b) => {
        if (a.s.length !== b.s.length) return a.s.length - b.s.length;
        return a.index - b.index;
      });
      console.log({ byLength });

      const best = byLength[byLength.length - 1];
      const possibleRhs = reverseReplacements.get(best.s);
      if (possibleRhs === undefined) throw "";

      console.log({ best, possibleRhs });
      const rhs = possibleRhs[0];

      chain =
        chain.substr(0, best.index) +
        rhs +
        chain.substr(best.index + best.s.length);
    }

    // const targetDiff = this.atomDiff("e", molecule);
    // const availableDiffs = [...replacements.entries()].flatMap(([k, list]) =>
    //   list.map(v => this.atomDiff(k, v))
    // );
    //
    // const atomCompare = (a: string, b: string) =>
    //   a === b ? 0 : a === "e" ? -1 : b === "e" ? +1 : a.localeCompare(b);
    //
    // const showDiff = (d: typeof targetDiff) =>
    //   [...d.entries()]
    //     .sort((a, b) => atomCompare(a[0], b[0]))
    //     .map(([k, v]) => `${v > 0 ? "+" : ""}${v} ${k}`)
    //     .join("; ");
    //
    // console.log(showDiff(targetDiff));
    // for (const av of availableDiffs) {
    //   console.log(showDiff(av));
    // }

    return "0";

    //
    // // e.g.OH => O
    // const reverseReplacements = new Map<string, string>();
    // for (const [k, vList] of replacements) {
    //   for (const v of vList) {
    //     if (reverseReplacements.has(v)) throw "";
    //
    //     reverseReplacements.set(v, k);
    //   }
    // }
    //
    // const m2 = this.split(molecule, lhsRe);
    // console.log({ m2: m2.join(","), l: m2.length });
    //
    // const r2 = new Map<string, string[][]>();
    //
    // for (const [k, v] of replacements.entries()) {
    //   r2.set(
    //     k,
    //     v.map(to => this.split(to, lhsRe))
    //   );
    // }
    //
    // // console.log({ r2: JSON.stringify(r2.get("e")) });
    //
    // // const rhsPattern =
    //
    // let n = 0;
    //
    // const answer = solve(
    //   molecule,
    //   state => state,
    //   state => {
    //     const out: { state: string; distance: number; how: unknown }[] = [];
    //
    //     for (const [lhs, rhs] of reverseReplacements.entries()) {
    //       for (const m of state.matchAll(new RegExp(lhs, "g"))) {
    //         const { index } = m;
    //         if (index === undefined) continue;
    //
    //         out.push({
    //           state: `${state.substr(0, index)}${rhs}${state.substr(
    //             index + lhs.length
    //           )}`,
    //           distance: 1,
    //           how: `@${index} ${lhs} => ${rhs}`,
    //         });
    //       }
    //     }
    //
    //     console.log({ state, out });
    //     return out;
    //   },
    //   (state, distance) => {
    //     distance;
    //     ++n;
    //     if (n >= 1000) {
    //       console.log({ l: state.length, distance });
    //       n = 0;
    //     }
    //     return { stop: state === "e" };
    //   }
    // );
    //
    // if (answer === undefined) throw "no solution";
    //
    // return answer.toString();
  }

  split(molecule: string): string[] {
    const o = [...molecule.matchAll(atomRe)].map(r => r[0]).filter(Boolean);
    console.log({ split: [molecule, o] });
    return o;
  }

  iterate2(
    molecule: string[],
    replacements: Map<string, string[][]>
  ): Set<string[]> {
    const seen = new Set<string[]>();

    molecule.forEach((item, index) => {
      const list = replacements.get(item);
      if (list === undefined) throw "";

      for (const to of list) {
        seen.add([
          ...molecule.slice(0, index),
          ...to,
          ...molecule.slice(index + 1),
        ]);
      }
    });

    return seen;
  }

  atomDiff(a: string, b: string): Map<string, number> {
    const as = this.split(a);
    const bs = this.split(b);

    const diff = new Map<string, number>();
    const apply = (items: string[], adjustment: number) => {
      for (const atom of items) {
        diff.set(atom, (diff.get(atom) || 0) + adjustment);
        if (diff.get(atom) === 0) diff.delete(atom);
      }
    };

    apply(as, -1);
    apply(bs, +1);

    return diff;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}
