#!/bin/zsh
# 切手計算ツールを GitHub Pages に公開する（初回は gh auth login が必要）
set -e
cd "$(dirname "$0")"
REPO=kitte-2609-f121
USER=$(gh api user -q .login 2>/dev/null || true)
if [ -z "$USER" ]; then
  echo "GitHub に未ログインです。先に次を実行してください:"
  echo "  gh auth login -h github.com -p https -w"
  exit 1
fi
git add -A
git commit -qm "update" 2>/dev/null || true
if ! gh repo view "$USER/$REPO" >/dev/null 2>&1; then
  echo "公開リポジトリ $USER/$REPO を作成して push します"
  gh repo create "$REPO" --public --source=. --remote=origin --push
else
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$USER/$REPO.git"
  git push -u origin main
fi
# GitHub Pages を main ブランチ直下から配信
if ! gh api "repos/$USER/$REPO/pages" >/dev/null 2>&1; then
  gh api -X POST "repos/$USER/$REPO/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null
  echo "Pages を有効化しました（反映まで1〜2分）"
fi
echo ""
echo "公開URL: https://$USER.github.io/$REPO/"
echo "iPhone: Safari で開く → 共有 → ホーム画面に追加"
