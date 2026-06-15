const fs = require("node:fs");
const path = require("node:path");

const root = process.cwd();
const uiRoot = path.join(root, "lib", "ui");
const exceptionMarker = "ui-drift-ok:";

const rules = [
  {
    name: "direct Flutter color",
    pattern: /\bColors\.[A-Za-z]/,
    hint: "Use AppColors or Theme.of(context).colorScheme.",
  },
  {
    name: "direct TextStyle",
    pattern: /\bTextStyle\s*\(/,
    hint: "Use AppTextStyles or Theme.of(context).textTheme.",
  },
  {
    name: "numeric EdgeInsets",
    pattern:
      /\bEdgeInsets\.(?:all|only|symmetric)\s*\([^)]*(?:^|[^\w.])\d+(?:\.\d+)?/,
    hint: "Use AppSpacing tokens or a named shared inset.",
  },
  {
    name: "manual decoration",
    pattern: /\bBoxDecoration\s*\(/,
    hint: "Prefer shared components, AppBorders, AppColors and AppSpacing.",
  },
];

function walk(dir) {
  if (!fs.existsSync(dir)) {
    return [];
  }

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  return entries.flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      if (entry.name === "design_system") {
        return [];
      }
      return walk(fullPath);
    }

    if (!entry.isFile() || !entry.name.endsWith(".dart")) {
      return [];
    }

    return [fullPath];
  });
}

function hasException(lines, index) {
  return (
    lines[index].includes(exceptionMarker) ||
    (index > 0 && lines[index - 1].includes(exceptionMarker))
  );
}

const findings = [];

for (const file of walk(uiRoot)) {
  const relativePath = path.relative(root, file);
  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);

  lines.forEach((line, index) => {
    if (hasException(lines, index)) {
      return;
    }

    for (const rule of rules) {
      if (rule.pattern.test(line)) {
        findings.push({
          file: relativePath,
          line: index + 1,
          rule,
          text: line.trim(),
        });
      }
    }
  });
}

if (findings.length === 0) {
  console.log("No common UI drift patterns found in lib/ui.");
  process.exit(0);
}

console.log(`Found ${findings.length} possible UI drift pattern(s) in lib/ui:`);
console.log("");

for (const finding of findings) {
  console.log(`${finding.file}:${finding.line} ${finding.rule.name}`);
  console.log(`  ${finding.text}`);
  console.log(`  ${finding.rule.hint}`);
  console.log(
    `  If intentional, add a nearby comment containing "${exceptionMarker}".`
  );
  console.log("");
}

console.log("Advisory only: review findings before UI commits.");
