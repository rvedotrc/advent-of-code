import * as base from "./base";
import * as day99 from "./day99";
import * as fs from "fs";

const partBuilders: Record<string, base.Day> = {
  day99,
};

const runTest = (
  part: base.PartBuilder,
  _dayNum: string,
  partNum: string,
  inputBase: string
): boolean => {
  const inputFile = inputBase;

  let inputText: string[];
  try {
    inputText = fs.readFileSync(inputFile).toString("utf-8").trim().split("\n");
  } catch (e) {
    if (e.code === "ENOENT") {
      console.info(`  skip ${inputFile} # no input`);
      return true;
    }
    throw e;
  }

  const actual = new part().calculate(inputText);

  const outputFile = `${inputBase}.answer.part${partNum.toLowerCase()}`;

  let expected = "";
  try {
    expected = fs.readFileSync(outputFile).toString("utf-8").trim();
  } catch (e) {
    if (e.code === "ENOENT") {
      console.info(`  ???? ${inputFile} # `, { answer: actual });
      return true;
    }
    throw e;
  }

  if (actual !== expected) {
    console.error(`  FAIL ${inputFile} # `, { expected, actual });
  } else {
    console.info(`  pass ${inputFile} # `, { answer: actual });
  }

  return actual === expected;
};

const test = (): void => {
  let ok = true;

  for (const dayKey of Object.keys(partBuilders)) {
    const day = partBuilders[dayKey];
    const daySuffix = dayKey.replace("day", "");

    for (const partKey of Object.keys(day)) {
      const part = day[partKey];
      const partSuffix = partKey.replace("Part", "");
      console.log(`${dayKey} ${partKey}`);

      ok &&= new part().test();
      ok &&= runTest(part, daySuffix, partSuffix, `input/${dayKey}`);
      ok &&= runTest(
        part,
        daySuffix,
        partSuffix,
        `input/${dayKey.replace("day", "test")}`
      );
    }
  }

  process.exit(ok ? 0 : 1);
};

const main = (argv: string[]): void => {
  // const key = `day${argv[2]}part${argv[3]}`;
  const day = partBuilders[`day${argv[2]}`];
  if (!day) throw "No such day";

  const partBuilder = day[`Part${argv[3]}`];
  if (!partBuilder) throw "No such part";

  const inputFile = argv[4] || `input/day${argv[2]}`;

  const lines = fs.readFileSync(inputFile).toString("utf-8").trim().split("\n");
  const answer = new partBuilder().calculate(lines);
  console.log(answer);
};

if (process.argv.length == 2) {
  test();
} else {
  main(process.argv);
}
