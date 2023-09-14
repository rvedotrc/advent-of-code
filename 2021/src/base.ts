export type Part = {
  calculate(lines: string[]): string;
  test(): boolean;
};

export type PartBuilder = {
  new (): Part;
};

export class BasePart {
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
}

export type Day = Record<string, PartBuilder>;
