export type PartBuilder = {
  new (): Part;
};

export class Part {
  async calculate(_lines: string[]): Promise<string> {
    return "not implemented";
  }
  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
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

  protected async check(
    exampleName: string,
    input: string | string[],
    expected: string
  ): Promise<boolean> {
    const actual = await this.calculate(
      typeof input === "string" ? [input] : input
    );
    return this.checkResult(exampleName, actual, expected);
  }
}

export type Day = Record<string, PartBuilder>;
