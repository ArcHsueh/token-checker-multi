# Token Checker

macOS のメニューバーに **Claude Code** と **Codex** の使用率を常時表示する個人向け macOS アプリ。

<p align="center">
  <img src=".github/assets/menubar.svg" alt="メニューバーの表示例" width="640"/>
</p>

- ✅ Claude Code と Codex の **5 時間ウィンドウ** 使用率を一目で
- ✅ クリックで詳細ポップオーバー（リセット時刻、週次使用率も）
- ✅ ネイティブ Swift / SwiftUI 製、常駐メモリ **数十 MB**、idle CPU **0 %**
- ✅ Anthropic / OpenAI の API キー不要（既存の `claude login` / `codex login` を間借り）
- ✅ App Store 配布ではない個人ツール。`/Applications` に置いて普通に使う

---

## 目次

- [できること](#できること)
- [動作要件](#動作要件)
- [ビルドとインストール](#ビルドとインストール)
- [使い方](#使い方)
- [仕組み](#仕組み)
- [トラブルシューティング](#トラブルシューティング)
- [プライバシー](#プライバシー)
- [謝辞 / ライセンス](#謝辞--ライセンス)

---

## できること

### メニューバー本体

メニューバーには **2 つのドーナツ + %** が常に表示されます。

| 表示 | 意味 |
| --- | --- |
| 左のドーナツ + % | **Claude Code** の 5 時間ウィンドウ使用率 |
| 右のドーナツ + % | **Codex** の 5 時間ウィンドウ使用率 |
| 色 | 緑 (<50%) → 橙 (50-75%) → 赤 (>75%) |

### ポップオーバー（クリック時）

<p align="center">
  <img src=".github/assets/popover.svg" alt="ポップオーバーの表示例" width="360"/>
</p>

- 各サービスの **5 時間ウィンドウ** 使用率（プログレスバー + リセットまでの残り時間）
- **週次** ウィンドウ使用率（補助情報、Claude は Sonnet 専用枠も）
- 「Claude にログイン」「Codex にログイン」ボタン（必要な時だけ使う）
- 更新間隔の変更（30 秒 〜 10 分）
- ログイン時の自動起動トグル

---

## 動作要件

| 要件 | 内容 |
| --- | --- |
| macOS | **14 Sonoma 以上** |
| Mac | Apple Silicon を想定（Intel でも動くはず） |
| Swift | 5.9 以上（Xcode Command Line Tools か Xcode） |
| Claude Code CLI | `claude` コマンドが `claude login` 済みであること |
| Codex CLI | `/opt/homebrew/bin/codex` 等で `codex login` 済みであること |

> Codex CLI が未インストールでも Claude 側は動きます。逆も同様。

---

## ビルドとインストール
### 1. リポジトリへ移動

```bash
cd ~/Documents/program/token-checker
```

### 2. ビルド + `/Applications` への配置（1 コマンド）

```bash
./Scripts/build.sh --install
```

これだけで以下が走ります：

1. `swift build -c release` — Swift のリリースビルド
2. `.app` バンドル組立（`Contents/MacOS/` `Contents/Info.plist`）
3. `codesign` で署名（自動的に ad-hoc か Developer ID を選択）
4. `/Applications/TokenChecker.app` にコピー

> 自分の `~/Applications/` に入れたい場合は `--install` の代わりに `--user-install`。

### 3. 起動

Finder で **アプリケーション → TokenChecker.app** をダブルクリック。
---

## 使い方

### 前提: CLI でログイン

このアプリは **アプリ内ログイン UI を持ちません**。代わりに、すでにターミナルでログイン済みの Claude Code / Codex の認証情報を借りて使います。

まだログインしていなければ、ターミナルで：

```bash
claude login    # Claude Code (Anthropic) でログイン
codex login     # Codex (OpenAI) でログイン
```

ブラウザが開いて OAuth フローが走ります。完了するとそれぞれ Keychain / `~/.codex/auth.json` にトークンが保存されます。

ポップオーバー内の「ログイン」ボタンは、上の `claude login` / `codex login` を **新しいターミナルで実行する shortcut** です。日常的には使わなくて OK。

---
### アンインストール

```bash
# メニューバーから「終了」してから
rm -rf /Applications/TokenChecker.app
# UserDefaults 残骸（必要なら）
defaults delete com.token-checker.app 2>/dev/null
```