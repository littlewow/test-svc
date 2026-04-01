#!/bin/bash
# Claude Code 이벤트 JSON 읽기
if [[ -n "$CLAUDE_EVENT_FILE" && -f "$CLAUDE_EVENT_FILE" ]]; then
 rawInput=$(cat "$CLAUDE_EVENT_FILE")
else
 rawInput=$(cat)
fi
# JSON에서 특정 키값 추출 (jq 없이, PowerShell이나 grep/sed 사용)
extract_json_field() {
 local key=$1
 echo "$rawInput" | sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n 1
}

 toolName=$(extract_json_field "tool_name")
url=$(extract_json_field "url")
prompt=$(extract_json_field "prompt")
result=$(extract_json_field "result")

timestamp=$(date +"%Y-%m-%d %H:%M:%S")


# 로그 파일 경로
logDir=".claude/logs"
logFile="$logDir/webfetch.log"
mkdir -p "$logDir"


# 로그 기록
{
 echo "[$timestamp]"
 echo "Tool: $toolName"
 echo "URL: $url"
 echo "Prompt: $prompt"
 echo "Result: $result"
 echo ""
} >> "$logFile"