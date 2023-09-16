import * as Base from "./base";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    let srcChars = 0;
    let outputChars = 0;

    for (const line of lines) {
      const p = this.parse(line);
      srcChars += p.srcChars;
      outputChars += p.outputChars;
    }

    return (srcChars - outputChars).toString();
  }

  parse(line: string): { srcChars: number; outputChars: number } {
    if (!line.startsWith('"') || !line.endsWith('"')) throw `? ${line}`;

    const srcChars = line.length;
    let outputChars = 0;

    let index = 1;

    while (index < line.length - 1) {
      if (line.substr(index, 2) === "\\\\") {
        ++outputChars;
        index += 2;
        continue;
      }

      if (line.substr(index, 2) === '\\"') {
        ++outputChars;
        index += 2;
        continue;
      }

      if (line.substr(index, 4).match(/^\\x[0-9a-fA-F][0-9a-fA-F]$/)) {
        ++outputChars;
        index += 4;
        continue;
      }

      ++outputChars;
      ++index;
    }

    return { srcChars, outputChars };

    // or:
    // return { srcChars: line.length, outputChars: eval(line).length };
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check("example", ['""', '"abc"', '"aaa\\"aaa"', '"\\x27"'], "12"),
    ];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    return lines
      .reduce((n, line) => {
        const needsBackslash = [...line.matchAll(/["\\]/g)].length;
        return n + needsBackslash + 2;

        // or:
        // return n + JSON.stringify(line).length - line.length;
      }, 0)
      .toString();
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [this.check("example", ['"\\x27"'], "5")];
  }
}
