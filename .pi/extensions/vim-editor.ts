/**
 * Vim-mode editor extension for Pi
 *
 * Modes: Normal / Insert
 *
 * Mode switching
 *   i        Insert before cursor
 *   I        Insert at line start
 *   a        Append after cursor
 *   A        Append at line end
 *   Esc      Insert → Normal  (in Normal mode: passes through to abort agent)
 *
 * Normal-mode motions
 *   h / l    Left / right
 *   j / k    Down / up
 *   w / W    Word right
 *   b / B    Word left
 *   0        Line start
 *   $        Line end
 *
 * Normal-mode operators  (pending state: operator key → motion key)
 *   x        Delete char forward
 *   d        Delete operator
 *     dw     Delete word forward
 *     db     Delete word backward
 *     dd     Delete whole line  (ctrl+u then ctrl+k)
 *     d0     Delete to line start
 *     d$     Delete to line end
 *   D        Delete to line end  (alias for d$)
 *   c        Change operator (delete then enter Insert)
 *     cw     Change word forward
 *     cb     Change word backward
 *     cc     Change whole line
 *     c0     Change to line start
 *     c$     Change to line end
 *   C        Change to line end  (alias for c$)
 *   y        Yank operator
 *     yy     Yank whole line  (ctrl+a, ctrl+k — puts line in kill ring)
 *   p        Paste (ctrl+y — yank from kill ring)
 *   u        Undo
 */

import { CustomEditor, type ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

// Escape sequences understood by Pi's built-in editor ─────────────────────────
const SEQ = {
  left:            "\x1b[D",   // cursorLeft
  right:           "\x1b[C",   // cursorRight
  up:              "\x1b[A",   // cursorUp
  down:            "\x1b[B",   // cursorDown
  wordLeft:        "\x1bb",    // alt+b  → cursorWordLeft
  wordRight:       "\x1bf",    // alt+f  → cursorWordRight
  lineStart:       "\x01",     // ctrl+a → cursorLineStart
  lineEnd:         "\x05",     // ctrl+e → cursorLineEnd
  deleteCharFwd:   "\x1b[3~",  // delete → deleteCharForward
  deleteWordFwd:   "\x1bd",    // alt+d  → deleteWordForward
  deleteWordBwd:   "\x7f",     // backspace seq for deleteWordBackward via ctrl+w…
  deleteWordBwdAlt:"\x17",     // ctrl+w → deleteWordBackward
  deleteToLineEnd: "\x0b",     // ctrl+k → deleteToLineEnd
  deleteToLineStart:"\x15",    // ctrl+u → deleteToLineStart
  yank:            "\x19",     // ctrl+y → paste from kill ring
  undo:            "\x1f",     // ctrl+- → undo
} as const;

type Mode = "normal" | "insert";
type Operator = "d" | "c" | "y" | null;

class VimEditor extends CustomEditor {
  private mode: Mode = "insert";
  private pendingOperator: Operator = null;

  // ── mode helpers ───────────────────────────────────────────────────────────

  private enterInsert(): void {
    this.mode = "insert";
    this.pendingOperator = null;
  }

  private enterNormal(): void {
    this.mode = "normal";
    this.pendingOperator = null;
  }

  // ── execute a resolved operator + motion ──────────────────────────────────

  private applyOperator(op: Operator, motion: string): void {
    switch (op) {
      case "d":
        super.handleInput(motion);
        break;

      case "c":
        super.handleInput(motion);
        this.enterInsert();
        break;

      case "y":
        // Pi has no native "yank without delete"; approximate with
        // kill-to-line-end so the text lands in the kill ring, then undo.
        // For yy we do: line-start, kill-line (kill ring now has the line).
        // After yank the cursor is at line start — move back to where we were
        // by re-issuing the sequence in reverse isn't possible without buffer
        // access, so we accept kill-ring yank semantics (p restores via ctrl+y).
        super.handleInput(motion);
        break;
    }
  }

  // ── input handler ─────────────────────────────────────────────────────────

  handleInput(data: string): void {

    // ── Escape ───────────────────────────────────────────────────────────────
    if (matchesKey(data, "escape")) {
      if (this.mode === "insert") {
        this.enterNormal();
      } else {
        // Normal mode Esc → abort agent (standard Pi behaviour)
        this.enterNormal(); // clear any pending operator first
        super.handleInput(data);
      }
      return;
    }

    // ── Insert mode: pass everything through ─────────────────────────────────
    if (this.mode === "insert") {
      super.handleInput(data);
      return;
    }

    // ── Normal mode ──────────────────────────────────────────────────────────

    // If we have a pending operator, resolve it with the next motion key.
    if (this.pendingOperator !== null) {
      const op = this.pendingOperator;
      this.pendingOperator = null; // consume operator

      switch (data) {
        // word forward
        case "w":
        case "W":
          this.applyOperator(op, SEQ.deleteWordFwd);
          return;

        // word backward
        case "b":
        case "B":
          this.applyOperator(op, SEQ.deleteWordBwdAlt);
          return;

        // to line end
        case "$":
          this.applyOperator(op, SEQ.deleteToLineEnd);
          return;

        // to line start
        case "0":
          this.applyOperator(op, SEQ.deleteToLineStart);
          return;

        // doubled operator (dd / cc / yy)
        case "d":
          if (op === "d") {
            // delete whole line: kill to start, then kill to end
            super.handleInput(SEQ.deleteToLineStart);
            super.handleInput(SEQ.deleteToLineEnd);
          }
          return;

        case "c":
          if (op === "c") {
            // change whole line
            super.handleInput(SEQ.deleteToLineStart);
            super.handleInput(SEQ.deleteToLineEnd);
            this.enterInsert();
          }
          return;

        case "y":
          if (op === "y") {
            // yank whole line: go to start, kill to end (line is now in kill ring)
            super.handleInput(SEQ.lineStart);
            super.handleInput(SEQ.deleteToLineEnd);
          }
          return;

        default:
          // unrecognised motion — swallow silently
          return;
      }
    }

    // No pending operator — handle standalone normal-mode keys.
    switch (data) {

      // ── Mode switching ──────────────────────────────────────────────────────
      case "i":
        this.enterInsert();
        return;

      case "I":
        // Insert at line start
        super.handleInput(SEQ.lineStart);
        this.enterInsert();
        return;

      case "a":
        // Append after cursor
        super.handleInput(SEQ.right);
        this.enterInsert();
        return;

      case "A":
        // Append at line end
        super.handleInput(SEQ.lineEnd);
        this.enterInsert();
        return;

      // ── Motions ─────────────────────────────────────────────────────────────
      case "h": super.handleInput(SEQ.left);      return;
      case "l": super.handleInput(SEQ.right);     return;
      case "j": super.handleInput(SEQ.down);      return;
      case "k": super.handleInput(SEQ.up);        return;
      case "w":
      case "W": super.handleInput(SEQ.wordRight);  return;
      case "b":
      case "B": super.handleInput(SEQ.wordLeft);   return;
      case "0": super.handleInput(SEQ.lineStart);  return;
      case "$": super.handleInput(SEQ.lineEnd);    return;

      // ── Standalone operators ─────────────────────────────────────────────────
      case "x":
        // Delete char forward
        super.handleInput(SEQ.deleteCharFwd);
        return;

      case "D":
        // Delete to line end
        super.handleInput(SEQ.deleteToLineEnd);
        return;

      case "C":
        // Change to line end
        super.handleInput(SEQ.deleteToLineEnd);
        this.enterInsert();
        return;

      // ── Pending operators ────────────────────────────────────────────────────
      case "d":
      case "c":
      case "y":
        this.pendingOperator = data as Operator;
        return;

      // ── Paste / undo ─────────────────────────────────────────────────────────
      case "p":
        super.handleInput(SEQ.yank);
        return;

      case "u":
        super.handleInput(SEQ.undo);
        return;

      // ── Pass control sequences through (ctrl+c, ctrl+d, etc.) ───────────────
      default:
        if (data.length === 1 && data.charCodeAt(0) >= 32) return; // drop printable
        super.handleInput(data);
        return;
    }
  }

  // ── status line ──────────────────────────────────────────────────────────

  render(width: number): string[] {
    const lines = super.render(width);
    if (lines.length === 0) return lines;

    const label =
      this.mode === "normal"
        ? this.pendingOperator
          ? ` NORMAL [${this.pendingOperator}] `
          : " NORMAL "
        : " INSERT ";

    const last = lines.length - 1;
    if (visibleWidth(lines[last]!) >= label.length) {
      lines[last] =
        truncateToWidth(lines[last]!, width - label.length, "") + label;
    }
    return lines;
  }
}

// ── Extension entry point ─────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    ctx.ui.setEditorComponent((tui, theme, kb) => new VimEditor(tui, theme, kb));
  });
}
