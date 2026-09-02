# 주간 자동 실행 설정

매주 월요일 오전 10:00 에 파이프라인 1~3단계(스캔 → 노션 기록 → 주제 선별)가 자동 실행됩니다.
원고 작성(4단계)은 사람이 주제를 확정한 뒤 직접 진행합니다.
그 시각 PC가 꺼져 있었으면 → **다음에 PC를 켜서 로그인한 뒤 자동으로 따라잡아 실행**됩니다.

## 파일 구성

| 파일 | 역할 |
|------|------|
| `register-task.ps1` | 작업 스케줄러에 등록 (한 번만 실행) |
| `run-weekly.ps1` | 스케줄러가 매주 실행하는 러너 (영문 전용) |
| `weekly-prompt.txt` | claude에게 줄 한국어 지시문 (러너가 이 파일을 읽게 함) |

> 한글은 `.ps1` 이 아니라 `weekly-prompt.txt` 에만 둡니다. PowerShell 5.1 이 `.ps1` 을
> CP949로 읽어 한글이 깨지는 문제를 피하려는 구조입니다. 세 파일을 함께 두세요.

## 등록 방법 (한 번만)

1. 시작 메뉴 → **PowerShell** → 오른쪽 클릭 → **관리자 권한으로 실행**
2. 아래 한 줄 붙여넣고 Enter:

```
powershell -NoProfile -ExecutionPolicy Bypass -File "c:\Users\hahahoho\Desktop\content\scripts\register-task.ps1"
```

3. `Registered: Heerim Weekly Pipeline` 과 다음 실행 시각이 나오면 완료.

시간을 바꾸려면 `register-task.ps1` 의 `-At 10:00am` 을 고친 뒤 위 명령을 다시 실행하세요.

## 바로 한 번 테스트

```
schtasks /run /tn "Heerim Weekly Pipeline"
```

또는 러너 직접 실행:

```
powershell -NoProfile -ExecutionPolicy Bypass -File "c:\Users\hahahoho\Desktop\content\scripts\run-weekly.ps1"
```

## 결과 / 로그

- 로그: `outputs/_logs/weekly-<날짜>.log`
- 결과물: `outputs/` 에 `주간다이제스트`, `주제선정` 파일 + 노션 3개 DB 반영

## 상태 확인 / 해제

```
schtasks /query /tn "Heerim Weekly Pipeline"
schtasks /delete /tn "Heerim Weekly Pipeline" /f
```

## 알아둘 것

- 따라잡기 실행은 **부팅 + 로그인** 후 동작합니다.
- 무인 실행이라 러너가 `--dangerously-skip-permissions` 로 claude를 실행합니다
  (이 폴더 작업만 하도록 지시문이 고정돼 있음).
- 노션 로그인이 만료되면 노션 기록 단계가 멈춥니다 → Claude Code에서 `/mcp` → notion → 재인증.
