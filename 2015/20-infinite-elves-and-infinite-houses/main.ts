import { Sieve } from "./primes.ts";

//https://planetmath.org/formulaforsumofdivisors
function part1() {
  const input = Deno.readTextFileSync("./input.txt");

  const N = Number(input) / 10;
  const sieve = new Sieve(Math.sqrt(N));

  for (let house = 1; house < N; house++) {
    let total = 1;
    for (const f of sieve.factors(house)) {
      const numerator = Math.pow(f.prime, f.power + 1) - 1;
      const denominator = f.prime - 1;
      total *= numerator / denominator;
    }
    if (total >= N) return house;
  }
}

//https://planetmath.org/formulaforsumofdivisors
function part2() {
  const input = Deno.readTextFileSync("./input.txt");

  const N = Math.ceil(Number(input) / 11);

  console.log("N", N);
  // const sieve = new Sieve(N);

  const H = Math.ceil(N / 25);
  for (let house = H; ; house++) {
    let total = 0;
    console.log("house", house);
    for (let j = house; j * 50 >= house; j--) {
      if (house % j === 0) {
        total += j;
        // console.log("j", j);
      }
    }
    console.log("total", total);
    if (total >= N) return house;
  }
}
// console.log(part1());
console.log(part2());
