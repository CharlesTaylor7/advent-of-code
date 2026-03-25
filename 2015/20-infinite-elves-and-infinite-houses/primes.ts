const wheel: number[] = [4, 2, 4, 2, 4, 6, 2, 6];

// optimized for low space usage and prime number iteration
export class Sieve {
  bound: number;
  primes: number[];

  sieve: boolean[] = [];

  constructor(bound: number) {
    this.bound = bound;
    this.primes = [2, 3, 5];
    let k = 7;
    for (let i = 0; k < bound; i = (i + 1) % wheel.length) {
      if (!this.sieve[k]) {
        this.primes.push(k);
        for (let x = 2 * k; x < bound; x += k) {
          this.sieve[x] = true;
        }
      }

      k += wheel[i];
    }
  }

  isPrime(n: number): boolean {
    // sieve is a partial cache of composites
    if (n < this.bound && this.sieve[n]) return false;
    for (let p of this.primes) {
      if (n % p == 0) return false;
      if (p * p > n) return true;
    }
    const bound = this.bound;
    if (n < bound * bound) return true;
    throw new Error(
      `cannot determine if ${n} is a prime with sieve bound of ${this.bound}`,
    );
  }

  *factors(n: number): Generator<PrimeFactor> {
    if (n < 1) throw new Error();
    for (let p of this.primes) {
      if (n == 1) return;
      let e = 0;
      while (n % p == 0) {
        e++;
        n = n / p;
      }
      if (e > 0) {
        yield new PrimeFactor(p, e);
      }
    }
    if (n == 1) return;
    if (n < this.bound * this.bound) yield new PrimeFactor(n, 1);
    else throw new Error("cannot factor without sieving more primes");
  }
}

export class PrimeFactor {
  prime: number;
  power: number;

  constructor(prime: number, power: number) {
    this.prime = prime;
    this.power = power;
  }
}
