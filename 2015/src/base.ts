export type PartBuilder = {
  new (): Part;
};

export class Part {
  calculate(_lines: string[]): string {
    return "not implemented";
  }
  test(): boolean | boolean[] {
    return true;
  }

  protected checkResult(
    testName: string,
    actual: string,
    expected: string
  ): boolean {
    if (actual === expected) {
      console.log(`  pass ${testName} # `, { answer: expected });
      return true;
    } else {
      console.error(`  FAIL ${testName} # `, { expected, actual });
      return false;
    }
  }

  protected check(
    exampleName: string,
    input: string | string[],
    expected: string
  ): boolean {
    const actual = this.calculate(typeof input === "string" ? [input] : input);
    return this.checkResult(exampleName, actual, expected);
  }
}

export type Day = Record<string, PartBuilder>;
