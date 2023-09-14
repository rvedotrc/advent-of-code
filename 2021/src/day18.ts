import * as Base from "./base";

type Raw = number | [Raw, Raw];

class SnailfishNumber {
  private value: string;

  static fromString(input: string) {
    return new SnailfishNumber(input);
  }

  static add(input: (SnailfishNumber | string)[]) {
    const numbers = input.map(line =>
      typeof line === "string" ? SnailfishNumber.fromString(line) : line
    );
    return numbers.reduce((a, b) => a.add(b));
  }

  static largestMagnitude(input: (SnailfishNumber | string)[]) {
    const numbers = input.map(line =>
      typeof line === "string" ? SnailfishNumber.fromString(line) : line
    );

    let max = -1;

    numbers.forEach(a =>
      numbers.forEach(b => {
        if (!a.equals(b)) {
          const mag = a.add(b).magnitude();
          if (mag > max) max = mag;
        }
      })
    );

    return max;
  }

  constructor(input: string) {
    this.value = input;
  }

  public toString(): string {
    return this.value;
  }

  public reduce(): void {
    while (true) {
      // console.debug(`reduce ${this}`);
      if (this.tryExplode()) continue;
      if (this.trySplit()) continue;
      break;
    }
  }

  public tryExplode(): boolean {
    // Find pair at depth 4 (if any)
    let pairStart: number | undefined = undefined;
    let depth = 0;
    for (let pos = 0; pos < this.value.length; ++pos) {
      if (this.value[pos] === "[") {
        if (depth === 4) {
          pairStart = pos;
          break;
        }

        ++depth;
      } else if (this.value[pos] === "]") {
        --depth;
      }
    }
    if (!pairStart) return false;

    const pairEnd = this.value.indexOf("]", pairStart);

    const pair = this.value
      .substring(pairStart + 1, pairEnd)
      .split(",")
      .map(s => parseInt(s));
    let prefix = this.value.substring(0, pairStart);
    let suffix = this.value.substring(pairEnd + 1);

    // add left to number to left
    let match = prefix.match(/(\d+)(?=\D*$)/);
    if (match && match.index) {
      prefix =
        prefix.substr(0, match.index) +
        (parseInt(match[1]) + pair[0]).toString() +
        prefix.substr(match.index + match[1].length);
    }

    // add right to number to right
    match = suffix.match(/(\d+)/);
    if (match && match.index) {
      suffix =
        suffix.substr(0, match.index) +
        (parseInt(match[1]) + pair[1]).toString() +
        suffix.substr(match.index + match[1].length);
    }

    // replace by 0
    this.value = prefix + "0" + suffix;

    return true;
  }

  public trySplit(): boolean {
    const match = this.value.match(/(\d\d+)/);
    if (!match) return false;

    const n = parseInt(match[1]);
    const n0 = Math.floor(n / 2);
    const n1 = Math.ceil(n / 2);

    this.value = this.value.replace(match[1], `[${n0},${n1}]`);

    return true;
  }

  public magnitude(): number {
    const data = JSON.parse(this.value);

    const mag = (value: Raw): number =>
      typeof value === "number" ? value : 3 * mag(value[0]) + 2 * mag(value[1]);

    return mag(data);
  }

  public add(b: SnailfishNumber): SnailfishNumber {
    const answer = new SnailfishNumber(`[${this.value},${b.value}]`);
    answer.reduce();
    return answer;
  }

  public equals(other: SnailfishNumber): boolean {
    return this.value === other.value;
  }
}

export class Part1 extends Base.BasePart implements Base.Part {
  calculate(lines: string[]): string {
    return SnailfishNumber.add(lines).magnitude().toString();
  }

  private testExplode(
    testName: string,
    input: string,
    expected: string
  ): boolean {
    const n = new SnailfishNumber(input);
    n.tryExplode();
    const actual = n.toString();
    return this.checkResult(testName, actual, expected);
  }

  // private testSplit(
  //   testName: string,
  //   input: string,
  //   expected: string
  // ): boolean {
  //   const n = new SnailfishNumber(input);
  //   n.trySplit();
  //   const actual = n.toString();
  //   return this.checkResult(testName, actual, expected);
  // }

  // private testReduce(
  //   testName: string,
  //   input: string,
  //   expected: string
  // ): boolean {
  //   const n = new SnailfishNumber(input);
  //   n.reduce();
  //   const actual = n.toString();
  //   return this.checkResult(testName, actual, expected);
  // }

  private testAddition(
    testName: string,
    inputs: string[],
    expected: string
  ): boolean {
    const n = SnailfishNumber.add(inputs);
    const actual = n.toString();
    return this.checkResult(testName, actual, expected);
  }

  private testMagnitude(
    testName: string,
    input: string,
    expected: number
  ): boolean {
    const n = new SnailfishNumber(input);
    const actual = n.magnitude().toString();
    return this.checkResult(testName, actual, expected.toString());
  }

  test(): boolean {
    const ok = [
      this.testExplode("e1", "[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"),
      this.testExplode("e2", "[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"),
      this.testExplode("e3", "[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]"),
      this.testExplode(
        "e4",
        "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]",
        "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"
      ),
      this.testExplode(
        "e5",
        "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]",
        "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"
      ),

      this.testAddition(
        "a1",
        ["[1,1]", "[2,2]", "[3,3]", "[4,4]"],
        "[[[[1,1],[2,2]],[3,3]],[4,4]]"
      ),
      this.testAddition(
        "a2",
        ["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]"],
        "[[[[3,0],[5,3]],[4,4]],[5,5]]"
      ),
      this.testAddition(
        "a3",
        ["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]", "[6,6]"],
        "[[[[5,0],[7,4]],[5,5]],[6,6]]"
      ),
      this.testAddition(
        "a4",
        [
          "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]",
          "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]",
          "[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]",
          "[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]",
          "[7,[5,[[3,8],[1,4]]]]",
          "[[2,[2,2]],[8,[8,1]]]",
          "[2,9]",
          "[1,[[[9,3],9],[[9,0],[0,7]]]]",
          "[[[5,[7,4]],7],1]",
          "[[[[4,2],2],6],[8,7]]",
        ],
        "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"
      ),

      this.testMagnitude("m1", "[[1,2],[[3,4],5]]", 143),
      this.testMagnitude("m2", "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", 1384),
      this.testMagnitude("m3", "[[[[1,1],[2,2]],[3,3]],[4,4]]", 445),
      this.testMagnitude("m4", "[[[[3,0],[5,3]],[4,4]],[5,5]]", 791),
      this.testMagnitude("m5", "[[[[5,0],[7,4]],[5,5]],[6,6]]", 1137),
      this.testMagnitude(
        "m6",
        "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]",
        3488
      ),
    ];

    return ok.every(v => v);
  }
}

export class Part2 extends Part1 {
  calculate(lines: string[]): string {
    return SnailfishNumber.largestMagnitude(lines).toString();
  }

  protected testLargestMagnitude(
    testName: string,
    inputs: string[],
    expected: number
  ): boolean {
    const actual = SnailfishNumber.largestMagnitude(inputs);
    return this.checkResult(testName, actual.toString(), expected.toString());
  }

  test(): boolean {
    const ok = [
      this.testLargestMagnitude(
        "l1",
        [
          "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]",
          "[[[5,[2,8]],4],[5,[[9,9],0]]]",
          "[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]",
          "[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]",
          "[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]",
          "[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]",
          "[[[[5,4],[7,7]],8],[[8,3],8]]",
          "[[9,3],[[9,9],[6,[4,9]]]]",
          "[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]",
          "[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]",
        ],
        3993
      ),
    ];
    return ok.every(v => v);
  }
}
