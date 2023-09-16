import * as base from "./base";
import * as fs from "fs";
import { partBuilders } from "./partBuilders";

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

const test = async (
  dayFilter: string | undefined,
  partFilter: string | undefined
): Promise<void> => {
  let ok = true;

  for (const dayKey of Object.keys(partBuilders)) {
    const daySuffix = dayKey.replace("day", "");
    if (dayFilter !== undefined && daySuffix !== dayFilter) continue;

    const day = partBuilders[dayKey];

    for (const partKey of Object.keys(day)) {
      const partSuffix = partKey.replace("Part", "");
      if (partFilter !== undefined && partSuffix !== partFilter) continue;

      const part = day[partKey];
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

test(process.argv[2], process.argv[3]);
