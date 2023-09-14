import * as base from "./base";
import * as day01 from "./day01";
import * as day02 from "./day02";
import * as day03 from "./day03";
import * as day04 from "./day04";
import * as day99 from "./day99";
import * as fs from "fs";

const partBuilders: Record<string, base.Day> = {
  day01,
  day02,
  day03,
  day04,
  day99,
};

const runTest = async (
  part: base.PartBuilder,
  _dayNum: string,
  partNum: string,
  inputBase: string
): Promise<boolean> => {
  const inputFile = inputBase;

  let inputText: string[];
  try {
    inputText = fs.readFileSync(inputFile).toString("utf-8").trim().split("\n");
  } catch (e: unknown) {
    if ((e as { code: unknown }).code === "ENOENT") {
      console.info(`  skip ${inputFile} # no input`);
      return true;
    }
    throw e;
  }

  const actual = await new part().calculate(inputText);

  const outputFile = `${inputBase}.answer.part${partNum.toLowerCase()}`;

  let expected = "";
  try {
    expected = fs.readFileSync(outputFile).toString("utf-8").trim();
  } catch (e: unknown) {
    if ((e as { code: unknown }).code === "ENOENT") {
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

const test = async (): Promise<void> => {
  let ok = true;

  for (const dayKey of Object.keys(partBuilders)) {
    const day = partBuilders[dayKey];
    const daySuffix = dayKey.replace("day", "");

    for (const partKey of Object.keys(day)) {
      const part = day[partKey];
      const partSuffix = partKey.replace("Part", "");
      console.log(`${dayKey} ${partKey}`);

      ok &&= await new part()
        .test()
        .then(r => (Array.isArray(r) ? r : [r]))
        .then(r => Promise.all(r))
        .then(r => r.every(t => t));
      ok &&= await runTest(part, daySuffix, partSuffix, `input/${dayKey}`);
      ok &&= await runTest(
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
