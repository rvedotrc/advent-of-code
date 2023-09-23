import * as Base from "./base";

export class Part1 extends Base.Part {
  async calculate(lines: string[], total = 150): Promise<string> {
    const sizes = lines.map(Number).sort((a, b) => b - a);

    let n = 0;
    this.combos(sizes, total, () => ++n);

    return n.toString();
  }

  combos(sizes: number[], total: number, cb: (_: number[]) => void): void {
    if (total === 0) {
      cb([]);
      return;
    }

    if (total < 0) return;
    if (sizes.length === 0) return;

    for (let i = 0; i < sizes.length; ++i) {
      if (sizes[i] <= total) {
        this.combos(sizes.slice(i + 1), total - sizes[i], (sub: number[]) =>
          cb([sizes[i], ...sub])
        );
      }
    }
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.checkResult(
        "example",
        await this.calculate(["20", "15", "10", "5", "5"], 25),
        "4"
      ),
    ];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[], total = 150): Promise<string> {
    const sizes = lines.map(Number).sort((a, b) => b - a);

    let shortest = Infinity;
    let count = 0;

    this.combos(sizes, total, ans => {
      if (ans.length < shortest) {
        shortest = ans.length;
        count = 1;
      } else if (ans.length === shortest) {
        ++count;
      }
    });

    return count.toString();
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.checkResult(
        "example",
        await this.calculate(["20", "15", "10", "5", "5"], 25),
        "3"
      ),
    ];
  }
}
