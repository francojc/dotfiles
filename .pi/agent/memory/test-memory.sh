#!/bin/bash
# Test script for the memory extension

echo "Memory Extension Test"
echo "====================="
echo ""

# Check directories
echo "Checking memory directories..."
mkdir -p ~/.pi/memory/episodes
mkdir -p ~/.pi/memory/semantic/projects

echo "✓ Episodes directory: ~/.pi/memory/episodes"
echo "✓ Semantic directory: ~/.pi/memory/semantic"
echo ""

# Check extension file
echo "Checking extension..."
if [ -f ~/.pi/agent/extensions/memory.ts ]; then
    echo "✓ memory.ts extension exists"
else
    echo "✗ memory.ts not found"
fi

# Check session-end processor
echo ""
echo "Checking session-end processor..."
if [ -f ~/.pi/agent/session-end-processor.mjs ]; then
    echo "✓ session-end-processor.mjs exists"
else
    echo "✗ session-end-processor.mjs not found"
fi

# Check skill
echo ""
echo "Checking skill..."
if [ -f ~/.pi/agent/skills/memory-recall/SKILL.md ]; then
    echo "✓ memory-recall skill exists"
else
    echo "✗ memory-recall skill not found"
fi

echo ""
echo "Memory system is ready!"
echo ""
echo "Next steps:"
echo "1. Restart Pi to load the extension"
echo "2. Use 'memory_working' tool to add facts/goals/context"
echo "3. Use 'memory_recall' tool to search past sessions"
echo "4. Say 'Remember when...' to trigger the recall skill"
echo ""
echo "To test session-end processing:"
echo "  node ~/.pi/agent/session-end-processor.mjs <session-jsonl-path>"
