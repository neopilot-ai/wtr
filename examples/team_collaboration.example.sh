#!/bin/bash
# wtr Team Collaboration Example
# Demonstrates team workflows and shared configurations
#
# This example shows how to:
# - Use shared .wtrconfig for team consistency
# - Coordinate on features across team
# - Share worktree setups
# - Track team workflows

set -e

echo "👥 wtr Team Collaboration Example"
echo "=================================="
echo ""

# Example team members
TEAM_MEMBERS=("alice" "bob" "carol" "dave")

# Example team tasks
declare -A TASKS=(
    [PROJ-101]="Feature: User authentication"
    [PROJ-102]="Bug: Login redirect"
    [PROJ-103]="Feature: API v2"
    [PROJ-104]="Refactor: Database layer"
)

# Step 1: Show team configuration
echo "📋 Step 1: Viewing team configuration (.wtrconfig)..."
echo ""

if [ -f ".wtrconfig" ]; then
    echo "Current team configuration:"
    echo "---"
    cat .wtrconfig 2>/dev/null | head -20
    echo "---"
else
    echo "No .wtrconfig found. Example configuration:"
    cat <<'EOF'
[defaults]
    editor = cursor
    ai = claude

[copy]
    include = .env.example
    include = .npmrc

[hooks]
    postCreate = npm install
    postCreate = npm run build
    preRemove = git push origin
EOF
fi
echo ""

# Step 2: Show all team members' worktrees
echo "👥 Step 2: Team workspaces"
echo ""
echo "Current worktrees in repository:"
wtr list 2>/dev/null || echo "  (none created yet)"
echo ""

# Step 3: Create task-based worktree
echo "📌 Step 3: Assign tasks to team members"
echo ""
echo "Available tasks:"
for task_id in "${!TASKS[@]}"; do
    echo "  $task_id: ${TASKS[$task_id]}"
done
echo ""

read -p "Assign a task (enter task ID, e.g., PROJ-101): " chosen_task
if [[ -v TASKS[$chosen_task] ]]; then
    echo ""
    echo "Task: $chosen_task"
    echo "Description: ${TASKS[$chosen_task]}"
    echo ""
    
    # Create worktree for task
    worktree_name="${chosen_task,,}"  # Convert to lowercase
    branch_name="task/$chosen_task"
    
    echo "Creating worktree: $worktree_name"
    wtr new "$worktree_name" -b "$branch_name" 2>/dev/null || echo "  (worktree may already exist)"
    
    echo ""
    echo "Team members can now:"
    echo "  1. Pick up this task by accessing the worktree"
    echo "  2. Collaborate on the same branch"
    echo "  3. Use shared configuration"
fi

echo ""

# Step 4: Show shared context
echo "🔄 Step 4: Team collaboration patterns"
echo ""

cat <<'EOF'
Pattern 1: Feature Development
------------------------------
1. Create feature worktree: wtr new feature-name
2. Share the worktree ID with team: feature-name
3. Other members can access: wtr go feature-name
4. Multiple people work on same branch/worktree (sequentially or with git merges)

Pattern 2: Task Assignment
---------------------------
1. Create task worktree: wtr new PROJ-123
2. Assign to team member: "charlie, can you handle PROJ-123?"
3. They work in: cd $(wtr go PROJ-123)
4. Commit and push when done
5. Original person removes: wtr remove PROJ-123

Pattern 3: Code Review
----------------------------
1. PR opened: PR #42
2. Create review worktree: wtr new pr-42
3. Team members test: wtr run pr-42 npm test
4. Review comments can reference: pr-42 worktree
5. Cleanup when merged: wtr remove pr-42

Pattern 4: Hotfix Coordination
------------------------------
1. Critical bug discovered
2. Create hotfix worktree: wtr new hotfix-emergency
3. All hands on deck in that worktree
4. Once merged, cleanup: wtr remove hotfix-emergency

Pattern 5: Parallel Streams
---------------------------
1. Main development: wtr new feature-1 && wtr new feature-2
2. Assign alice to feature-1: alice works in that worktree
3. Assign bob to feature-2: bob works in that worktree
4. Both operate independently, share only .git
5. Zero coordination needed until merge
EOF

echo ""

# Step 5: Show synchronization workflow
echo "🔄 Step 5: Keeping team in sync"
echo ""

cat <<'EOF'
Option 1: Shared Configuration in Git
--------------------------------------
git add .wtrconfig .worktreeinclude .wtr/
git commit -m "team: Standard wtr setup"
git push

All team members pull → same setup for all

Option 2: Slack/Discord Updates
------------------------------
"I created worktree for PROJ-123, join me!"
Others: wtr go PROJ-123 && cd $(wtr go PROJ-123)

Option 3: Automated Status Reports
---------------------------------
# In CI/CD or scheduled task:
echo "Active worktrees:" >> team-status.md
wtr list >> team-status.md

Option 4: Standup Briefing
---------------------------
# Each morning:
wtr list                     # What's in progress?
git log --oneline -10        # Recent commits
wtr run worktree-id git status  # Per-worktree status
EOF

echo ""

# Step 6: Troubleshooting team issues
echo "🆘 Step 6: Common team issues and solutions"
echo ""

cat <<'EOF'
Issue: "Someone deleted my worktree!"
Solution: 
  - It's fine, worktree is just a directory
  - Commits are on the branch in shared .git
  - Recreate: wtr new branch-name

Issue: "Two people working same branch, conflicts!"
Solution 1: Use sequentially (communicate over chat)
Solution 2: Create separate wt: wtr new feature-alice vs wtr new feature-bob
Solution 3: Pull and stage changes for other person

Issue: "My worktree is huge, slowing down machine"
Solution:
  - wtr remove <id> to free space
  - Or manually delete: rm -rf worktrees/<id>
  - Commits are preserved on branch

Issue: "Out of sync with main"
Solution:
  - Git pull in worktree: wtr run <id> git pull origin main
  - Or manually: cd $(wtr go <id>) && git pull

Issue: "Lost track of all my worktrees"
Solution:
  - List all: wtr list
  - Pick one: cd $(wtr go feature-name)
  - Show all paths: wtr list | xargs -I {} wtr go {}
EOF

echo ""

# Step 7: Best practices
echo "✨ Step 7: Team best practices"
echo ""

cat <<'EOF'
✓ DO:
  - Commit often, push regularly
  - Use descriptive worktree names (task IDs, feature names)
  - Update .wtrconfig in git for team consistency
  - Clean up old worktrees
  - Use worktree name in commit messages for traceability

✗ DON'T:
  - Leave worktrees running forever
  - Create worktree per person-day (cleanup periodically)
  - Force-push without coordination
  - Ignore .wtrconfig when it exists
  - Work on same branch in two separate worktrees without git knowledge

🎯 TEAM WORKFLOW EXAMPLE:
  Mon:  alice creates wtr for PROJ-123 ← alice works all day
  Tue:  alice adds bob to pair on it
  Wed:  alice finishes, creates PR, removes wtr
  Thu:  Someone reviews PR, creates pr-##### wtr, tests
  Fri:  PR merged, cleanup complete
EOF

echo ""
echo "✅ Team collaboration setup complete!"
echo ""
echo "Next steps:"
echo "  1. Share .wtrconfig with your team"
echo "  2. Create first task worktree together"
echo "  3. Document your team standards in a DEVELOPMENT.md file"
echo "  4. Use README.md link to point to documentation"
echo ""
