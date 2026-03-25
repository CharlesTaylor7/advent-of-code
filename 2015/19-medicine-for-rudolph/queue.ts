import {assertEquals} from "jsr:@std/assert";

const MAX_ITERATIONS: number = 1_000_000;

/**
/* Fibonacci Heap
 * Implementation based on 
 * https://en.wikipedia.org/wiki/Fibonacci_heap#Implementation_of_operations
 */
export class FibHeap<T> {
  private min?: FibNode<T>

  constructor(items?: Iterable<[number, T]>) {
    if (items) {
      for (const [key, item] of items) { 
        this.insert(key, item);
      }
    }
  }

  insert(key: number, item: T): void {
    // console.log(`Insert: ${key}, ${item}`)
    const node = new FibNode<T>(key, item)
    if (!this.min) {
      this.min = node
    } else {
      this.min.append(node)
      if (key < this.min.key) {
        this.min = node
      }
    }
  }

  findMin(): [number, T] | null {
    return this.min ? [this.min.key, this.min.value] : null
  }

  merge(heap: FibHeap<T>): void {
    if (!heap.min) {
      return
    }
    if (!this.min) {
      this.min = heap.min
    }

    // determine new min
    this.min.mergeChains(heap.min)

    // link new min
    this.min = heap.min.key < this.min.key ? heap.min : this.min
  }

  deleteMin() {
    // already empty
    if (!this.min) return 
    // exactly 1 element
    // console.log(`Phase 0:`, this.min);
    // console.log(`Delete:`, this.min.display())
    if (this.min === this.min.prev) {
      this.min = undefined
      return
    }

    // Phase 1
    // merge old min's child into the root chain
    
    const newRoots = [...this.min.iterateSiblings()];
    if (this.min.child) {
      newRoots.push(this.min.child, ...this.min.child.iterateSiblings())
    }

    this.min.child?.mergeChains(this.min.next)
    this.min.unlink()
    // console.log(`Phase 1:`, newRoots.map(node => node.display()));

    // Phase 2
    // root node degrees
    const roots = new Map<number, FibNode<T>>()

    for (let root of newRoots) {
      while (true) {
        const existing = roots.get(root.degree) 
        if (!existing) {
          roots.set(root.degree, root)
          break
        }
        roots.delete(root.degree)
        root = this.linkRoots(root, existing)
      }
    } 


    // Phase 3
    let minValue = Number.POSITIVE_INFINITY
    roots.forEach(root => {
      if (root.key < minValue) {
        this.min = root
        minValue = root.key
      }
    }) 

    // console.log(`Phase 3:`, this.min);
    // this.verify();
  }

  /**
   * Returns the parent node
   */
  linkRoots(a: FibNode<T>, b: FibNode<T>): FibNode<T> {
    let root, child;
    if (a.key < b.key) {
      root = a
      child = b
    }
    else {
      child = a
      root = b
    }
    child.unlink()
    if (root.child) {
      root.child.append(child)
    }
    else {
      root.child = child
    }
    root.degree++

    // console.log("Link:", child.display(), "under", root.display())
    return root
  }

  toArray(): Array<[number, T]> {
    const array: Array<[number, T]> = []
    while (this.min) {
      const { key, value } = this.min
      array.push([key, value])
      this.deleteMin()
    }
    return array
  }

  verify() {
    this.min?.verify();
  }
}


class FibNode<T> {
  key: number
  value: T
  prev: FibNode<T>
  next: FibNode<T>
  child?: FibNode<T>
  // the number of children
  degree: number = 0
  marked: boolean = false

  constructor(key: number, value: T) {
    this.key = key
    this.value = value
    this.prev = this
    this.next = this
  }

  /**
   * mergeChains based on 
   */
  mergeChains(fibNode: FibNode<T>) {
    const A = this
    const A2 = A.next 
    const B = fibNode
    const B2 = B.next 
    // insert B into the gap between A & A2
    A.next = B2
    B2.prev = A
    A2.prev = B
    B.next = A2
  }

  // insert node into chain right after this one, but ignore its existing links
  append(node: FibNode<T>) {
    const neighbor = this.next

    // link to this
    this.next = node
    node.prev = this

    // link to the neighbor
    node.next = neighbor
    neighbor.prev = node
  }

  unlink() {
    const A = this.prev;
    const B = this.next;
    A.next = B
    B.prev = A
    this.prev = this
    this.next = this
  }

  *iterateSiblings(): Generator<FibNode<T>, undefined> {
    const initial = this
    let current: FibNode<T> = this.next
    for (let i = 0; i< MAX_ITERATIONS; i++){
      if (current === initial) return
      yield current
      current = current.next
    }
    throw new Error(`MAX ITERATIONS exceeded`);
  }

  *iterateSiblingsBackwards(): Generator<FibNode<T>, undefined> {
    const initial = this
    let current: FibNode<T> = this.prev
    for (let i = 0; i < MAX_ITERATIONS; i++){
      if (current === initial) return
      yield current
      current = current.prev
    }
  }

  verifySiblings() {
    const array = new Array(...this.iterateSiblings()).map(node => node.value);
    const backwards = new Array(...this.iterateSiblingsBackwards()).map(node => node.value);
    backwards.reverse();
    assertEquals(array, backwards);
  }

  verifyDegree() {
    let count = 0;
    if (this.child !== undefined) {
      count++
      for (const _ of this.child.iterateSiblings()) {
        count++
      }
    }
    assertEquals(this.degree, count, JSON.stringify(this.display()));
  }

  verify() {
    this.verifySiblings();
    this.verifyDegree();

    if (this.child !== undefined) {
      for (const node of this.child.iterateSiblings()) {
        node.verify()
      }
    }
  }

  display(): object {
    const {key, value, degree} = this
    return ({ key,value,degree});
  }
}
