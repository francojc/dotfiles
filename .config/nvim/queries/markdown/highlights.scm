; queries/markdown/highlights.scm
;
; Block-level CriticMarkup highlights for nvim-treesitter.
; Same approach as markdown_inline/highlights.scm: matches the
; enclosing block when the source contains a CriticMarkup pattern.
; Most CriticMarkup is inline, so the markdown_inline queries
; catch the common cases. This file handles block-level cases
; where the pattern spans the whole paragraph.

((paragraph) @critic.insert
  (#match? @critic.insert ".*{\\+%+.*\\+%+}.*"))

((paragraph) @critic.delete
  (#match? @critic.delete ".*{\\-%-.*\\-%-}.*"))

((paragraph) @critic.subst
  (#match? @critic.subst ".*{~~.*~>.*~~}.*"))

((paragraph) @critic.highlight
  (#match? @critic.highlight ".*{==.*==}.*"))

((paragraph) @critic.comment
  (#match? @critic.comment ".*{>>.*<<}.*"))
