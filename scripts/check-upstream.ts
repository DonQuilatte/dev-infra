#!/usr/bin/env bun
/**
 * Check upstream repos for updates
 * 
 * Usage: bun run scripts/check-upstream.ts
 */

import { $ } from "bun";
import { readFileSync } from "fs";
import { parse } from "yaml";

interface UpstreamRepo {
  path: string;
  watch: string[];
  sync_to: string;
  check_frequency: string;
}

async function getLastCommit(repoPath: string): Promise<{ hash: string; date: string; message: string } | null> {
  try {
    const result = await $`git -C ${repoPath} log -1 --format='%H|%ci|%s'`;
    const [hash, date, message] = result.text().trim().split("|");
    return { hash, date, message };
  } catch (error) {
    console.error(`Git error for ${repoPath}:`, error);
    return null;
  }
}

async function getLocalSync(repoName: string): Promise<string | null> {
  try {
    const trackingFile = `/Users/jederlichman/Development/Projects/dev-infra/.upstream/${repoName}.sync`;
    return readFileSync(trackingFile, "utf-8").trim();
  } catch {
    return null;
  }
}

async function main() {
  const configPath = "/Users/jederlichman/Development/Projects/dev-infra/config/upstream-deps.yml";
  const config = parse(readFileSync(configPath, "utf-8"));

  console.log("\n🔄 Upstream Dependency Check\n");
  console.log("─".repeat(60));

  const updates: string[] = [];

  for (const [name, repo] of Object.entries(config.upstream_repos as Record<string, UpstreamRepo>)) {
    const latest = await getLastCommit(repo.path);
    const synced = await getLocalSync(name);

    if (!latest) {
      console.log(`❌ ${name}: repo not found at ${repo.path}`);
      continue;
    }

    const status = synced === latest.hash ? "✅" : "🟡";
    console.log(`${status} ${name}`);
    console.log(`   Latest: ${latest.hash.substring(0, 7)} - ${latest.message}`);
    console.log(`   Date: ${latest.date}`);

    if (synced !== latest.hash) {
      console.log(`   ⚠️  Behind upstream (last sync: ${synced?.substring(0, 7) || "never"})`);
      updates.push(name);
    }
    console.log();
  }

  if (updates.length > 0) {
    console.log("─".repeat(60));
    console.log(`\n📋 ${updates.length} repo(s) need review:`);
    updates.forEach(name => console.log(`   - ${name}`));
    console.log("\nRun: bun run scripts/sync-upstream.ts <repo-name>");
  } else {
    console.log("✅ All upstream repos synced\n");
  }
}

main().catch(console.error);
