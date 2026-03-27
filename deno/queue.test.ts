import { assertEquals } from "jsr:@std/assert";
import { FibHeap } from "@/queue.ts";

Deno.test("fib heap", () => {
  const heap = new FibHeap(true);
  heap.insert(0, "e");
  const min1 = heap.findMin();
  heap.deleteMin();
  heap.insert(1, "pn");
  heap.insert(1, "qh");
  heap.insert(1, "ab");

  const min2 = heap.findMin();
  heap.deleteMin();
  heap.insert(2, "abc");
  heap.insert(2, "def");
  heap.insert(2, "ghi");
  const min3 = heap.findMin();
  heap.deleteMin();
  heap.size();

  assertEquals(min1, [0, "e"]);
  assertEquals(min2![0], 1);
  assertEquals(min3![0], 1);
  assertEquals(heap.size(), 4);
});
