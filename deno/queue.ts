import { assertEquals } from "@std/assert/equals";
const MAX_ITERATIONS = 1_000_000;

/**
/* Fibonacci Heap
 * Implementation based on 
 * https://en.wikipedia.org/wiki/Fibonacci_heap#Implementation_of_operations
 */
export class FibHeap<T> {
  #min?: FibNode<T>;
  #size: number = 0;
  #debug?: boolean;
// degree -> node
// only maintained as part of delete min operation
// after 2 sequential inserts, there are a multiple degree 1 roots.
  #roots: Map<number, FibNode<T>> = new Map();
  #insertsSinceLastDelete: number = 0;

  constructor(debug?: boolean) {
    this.#debug = debug;
  }

  size(): number {
    return this.#size;
  }

  insert(key: number, item: T): void {
    this.#insertsSinceLastDelete++;
    // console.log("Insert:", key, item);

    const node = new FibNode<T>(key, item);
    if (!this.#min) {
      this.#min = node;
    } else {
      if (key < this.#min.key) {
        this.#min.prev.append(node);
        this.#min = node;
      }
      else {
        this.#min.append(node);
      }
    }
    this.#size++;
    this.verify();
  }

  findMin(): [number, T] | null {
    return this.#min ? [this.#min.key, this.#min.value] : null;
  }

  deleteMin() {
    // console.log("Delete");
    // already empty
    if (!this.#min) {
      // console.log("Empty");
      return;
    }
    const newRootCount = this.#insertsSinceLastDelete + this.#min.degree;
    this.#size--;
    this.#roots.delete(this.#min.degree);
    this.#insertsSinceLastDelete = 0;

    // exactly 1 element
    this.log(`Phase 0:`, this.#min);
    this.log(`Delete:`, this.#min.display())
    if (this.#size === 0) {
      // console.log("Deleting last element");
      this.#min = undefined;
      this.verify();
      return;
    }

    // Phase 1
    // merge old min's child into the root chain

    const newRoots = [...this.#min.iterateSiblings()];
    if (this.#min.child) {
      newRoots.push(this.#min.child, ...this.#min.child.iterateSiblings());
    }

    this.#min.child?.merge(this.#min.next);
    this.#min.unlink();
    // console.log(`Phase 1:`, newRoots.map(node => node.display()));

    // Phase 2
    // root node degrees

    for (let root of newRoots) {
      while (true) {
        const existing = this.#roots.get(root.degree);
        if (!existing) {
          this.#roots.set(root.degree, root);
          break;
        }
        this.#roots.delete(root.degree);
        root = this.linkRoots(root, existing);
      }
    }

    // Phase 3
    let minValue = Number.POSITIVE_INFINITY;
    for (const root of this.#roots.values()) {
      if (root.key < minValue) {
        this.#min = root;
        minValue = root.key;
      }
    }

    this.log(`Phase 3:`, this.#min);
    this.verify();
  }

  /**
   * Returns the parent node
   */
  linkRoots(a: FibNode<T>, b: FibNode<T>): FibNode<T> {
    let root, child;
    if (a.key < b.key) {
      root = a;
      child = b;
    } else {
      child = a;
      root = b;
    }
    child.unlink();
    if (root.child) {
      root.child.append(child);
    } else {
      root.child = child;
    }
    root.degree++;

    // console.log("Link:", child.display(), "under", root.display())
    return root;
  }

  iter(): Generator<FibNode<T>> {
    function* iterRec(
      node: FibNode<T> | undefined,
      siblings: boolean,
    ): Generator<FibNode<T>> {
      if (!node) return;

      yield node;
      yield* iterRec(node.child, true);
      if (siblings) {
        for (const sibling of node.iterateSiblings()) {
          yield* iterRec(sibling, false);
        }
      }
    }
    return iterRec(this.#min, true);
  }

  log(...args: unknown[]) {
    if (!this.#debug) return;
    console.log(...args);
  }

  verifySize() {
    console.log("Size", this.#size, this.#min);
    assertEquals(this.iter().toArray().length, this.#size);
  }

  verify() {
    if (!this.#debug) return;
    this.#min?.verify();
    this.verifySize();
  }
}

class FibNode<T> {
  key: number;
  value: T;
  prev: FibNode<T>;
  next: FibNode<T>;
  child?: FibNode<T>;
  // the number of children
  degree: number = 0;

  constructor(key: number, value: T) {
    this.key = key;
    this.value = value;
    this.prev = this;
    this.next = this;
  }

  merge(fibNode: FibNode<T>) {
    const A = this;
    const A2 = A.next;
    const B = fibNode;
    const B2 = B.next;
    // insert B into the gap between A & A2
    A.next = B2;
    B2.prev = A;
    A2.prev = B;
    B.next = A2;
  }

  // insert node into chain right after this one
  append(node: FibNode<T>) {
    const neighbor = this.next;

    // link to this
    this.next = node;
    node.prev = this;

    // link to the neighbor
    node.next = neighbor;
    neighbor.prev = node;
  }

  unlink() {
    const A = this.prev;
    const B = this.next;
    A.next = B;
    B.prev = A;
    this.prev = this;
    this.next = this;
  }

  *iterateSiblings(): Generator<FibNode<T>, undefined> {
    const initial = this;
    let current: FibNode<T> = this.next;
    for (let i = 0; i < MAX_ITERATIONS; i++) {
      if (current === initial) return;
      yield current;
      current = current.next;
    }
    throw new Error(`MAX ITERATIONS exceeded`);
  }

  *iterateSiblingsBackwards(): Generator<FibNode<T>, undefined> {
    const initial = this;
    let current: FibNode<T> = this.prev;
    for (let i = 0; i < MAX_ITERATIONS; i++) {
      if (current === initial) return;
      yield current;
      current = current.prev;
    }
  }

  verifySiblings() {
    const array = new Array(...this.iterateSiblings()).map(
      (node) => node.value,
    );
    const backwards = new Array(...this.iterateSiblingsBackwards()).map(
      (node) => node.value,
    );
    backwards.reverse();
    assertEquals(array, backwards);
  }

  verifyDegree() {
    let count = 0;
    if (this.child !== undefined) {
      count++;
      for (const _ of this.child.iterateSiblings()) {
        count++;
      }
    }
    assertEquals(this.degree, count, JSON.stringify(this.display()));
  }

  verify() {
    this.verifySiblings();
    this.verifyDegree();

    if (this.child !== undefined) {
      for (const node of this.child.iterateSiblings()) {
        node.verify();
      }
    }
  }

  display(): object {
    const { key, value, degree } = this;
    return { key, value, degree };
  }
}
