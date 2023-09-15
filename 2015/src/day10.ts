import * as Base from "./base";

const expand = function* (input: Iterator<string>): Iterator<string> {
  let current = "";
  let count = 0;

  while (true) {
    const n = input.next();
    if (n.done) break;

    const c = n.value;
    // console.log({ current, count, c });

    if (c !== current) {
      if (current !== "")
        for (const o of `${count}${current}`.split("")) yield o;
      current = c;
      count = 0;
    }

    ++count;
    // console.log({ end: true, current, count, c });
  }

  if (current != "") {
    for (const o of `${count}${current}`.split("")) yield o;
  }
};

const iterableExpand = (input: Iterator<string>): IterableIterator<string> => {
  const ex = expand(input);
  const t = {
    [Symbol.iterator]: () => t,
    next: () => ex.next(),
  };
  return t;
};

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    return this.lengthOf(
      this.iterateNTimes(lines[0].split("")[Symbol.iterator](), this.iterations)
    ).toString();
  }

  get iterations(): number {
    return 40;
  }

  lengthOf<T>(input: Iterator<T>): number {
    let length = 0;
    while (!input.next().done) ++length;
    return length;
  }

  join(input: IterableIterator<string>): string {
    return Array.from(input).join("");
  }

  iterateNTimes(
    input: IterableIterator<string>,
    n: number
  ): IterableIterator<string> {
    return new Array(n).fill(0).reduce(iter => iterableExpand(iter), input);
  }

  testRunNTimes(input: string, n: number): string {
    const iter = input.split("")[Symbol.iterator]();
    return this.join(this.iterateNTimes(iter, n));
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.checkResult("example a", this.testRunNTimes("1", 1), "11"),
      this.checkResult("example a", this.testRunNTimes("11", 1), "21"),
      this.checkResult("example a", this.testRunNTimes("21", 1), "1211"),
      this.checkResult("example a", this.testRunNTimes("1211", 1), "111221"),
      this.checkResult("example a", this.testRunNTimes("111221", 1), "312211"),
      this.checkResult("example b", this.testRunNTimes("1", 5), "312211"),
    ];
  }
}

export class Part2 extends Part1 {
  get iterations(): number {
    return 50;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return true;
  }
}
