# Advent of Code 2021

https://adventofcode.com/2021

In Ruby / Typescript.

To run with your test data,
```
mkdir -p input
````
then save each day's input to `input/day1`, `input/day2` and so on.

## Ruby

Setup / tests:

```
bundle
bundle exec rspec
````

Running a specific day / part with your input data, e.g. day 3 part 1:

```
bundle exec ./bin/ruby 3 1
```

## Typescript

Setup:

```shell
yarn
yarn build
```

Running all tests, and all days + parts:

```
./bin/ts
```

Running a specific day / part with your input data, e.g. day 15 part 2:

```
./bin/ts 15 2
```
