; queries/markdown_inline/highlights.scm
;
; Extend nvim-treesitter highlights for CriticMarkup in markdown.
; Loaded automatically from ~/.config/nvim/queries/markdown_inline/.
;
; Highlights the *entire* inline node whose text contains a
; CriticMarkup annotation. Granular per-character highlighting
; isn't possible at query level (text isn't re-parsed). If you
; want a more visual cue, add a Lua query (query.lua) that uses
; the treesitter API to mark specific byte ranges.

; Insertion: {++text++}
((inline) @critic.insert
  (#match? @critic.insert "^{\\+%+.*\\+%+}.*"))

; Deletion: {--text--}
((inline) @critic.delete
  (#match? @critic.delete "^{\\-%-.*\\-%-}.*"))

; Substitution: {~~old~>new~~}
((inline) @critic.subst
  (#match? @critic.subst "^{~~.*~>.*~~}.*"))

; Highlight: {==text==}
((inline) @critic.highlight
  (#match? @critic.highlight "^{==.*==}.*"))

; Comment: {>>text<<}
((inline) @critic.comment
  (#match? @critic.comment "^{>>.*<<}.*"))
