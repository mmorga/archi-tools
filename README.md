Thinking about merging archimate docs

Givens:

1. An ID equivalence between nodes can be either an indicator of identity or an indicator of an ID conflict that needs resolution
2. All ArchiMate node types (except diagram) are uniquely identified by their name and xsi:type attributes
3. Folders under a top level typed folder may differ and should be resolved
4. There are 2 inherent modes: baseless merge and based merge. Based merge is when one doc is an ancestor of the other. The rules are a little different.

Options:

1. Merge type (baseless or based) - for based, indicate older file
2. Ask to resolve folder for matching elements
3. Ask to merge matching elements or rename one

Approach:

* hash1: ID to element hash
* hash2: Element unique name to element hash
* hash3: Mapping of this file's id to final id

For each file...
  Walk the tree, for each node...
    If element not unique (hash2)
      resolve element which is
        1. Same element and location:
          IDs same?
          IDs differ?
        2. Diff elements: rename
        3. Same element diff location:
          Change location?
          Keep location?
    else
      insert element and continue
