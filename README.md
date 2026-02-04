# DevOps Utility Scripts

> 🇰🇷 [한국어](#한국어) | 🇺🇸 [English](#english)

---

## 한국어

### 📋 개요

개발 및 운영 환경에서 자주 사용되는 유틸리티 스크립트 모음입니다.

### 📁 스크립트 목록

| 스크립트 | 설명 |
|---------|------|
| `gen_ecdsa_rsa_jks.sh` | Java Keystore(JKS) 자동 생성 스크립트 (RSA/ECDSA 선택) |
| `run_tomcat.sh` | Tomcat 서비스 관리 스크립트 |
| `run_pgsql.sh` | PostgreSQL 서비스 관리 스크립트 |

---

### 🔐 gen_ecdsa_rsa_jks.sh

Java Keystore를 ECDSA 또는 RSA 알고리즘으로 자동 생성하는 스크립트입니다.

#### 주요 기능
- **알고리즘 선택**: 커맨드 라인에서 `ec` 또는 `rsa` 선택 가능
- ECDSA `secp256r1` 곡선 사용 (RSA 대비 경량화, 권장)
- RSA 2048-bit 키 지원 (레거시 호환)
- 10년 유효기간 설정
- 기존 파일 덮어쓰기 확인
- 생성 후 인증서 정보 자동 출력

#### 사용법

```bash
# 실행 권한 부여
chmod +x gen_ecdsa_rsa_jks.sh

# ECDSA 키스토어 생성 (기본값, 권장)
./gen_ecdsa_rsa_jks.sh ec
./gen_ecdsa_rsa_jks.sh        # 인자 없으면 ec로 동작

# RSA 키스토어 생성
./gen_ecdsa_rsa_jks.sh rsa
```

#### 출력 파일

| 알고리즘 | Alias | 파일명 |
|---------|-------|--------|
| ECDSA | `tomcat_ec` | `keystore_ec.jks` |
| RSA | `tomcat_rsa` | `keystore_rsa.jks` |

#### 설정 변경

스크립트 상단의 변수를 수정하여 환경에 맞게 커스터마이징할 수 있습니다:

```bash
STOREPASS="changeME!"    # Store 비밀번호
VALIDITY=365            # 유효 기간 (일)
CN="your.domain.com"     # Common Name (도메인)
OU="Engineering"         # 부서
O="DEV"                  # 조직
```

---

### 🐱 run_tomcat.sh

Tomcat 서비스를 관리하는 마스터 컨트롤러 스크립트입니다.

#### 주요 기능
- 서비스 시작/중지/재시작
- **자동 로그 아카이빙**: 시작 전 `catalina.out` 및 액세스 로그 자동 정리
- **30일 경과 로그 자동 삭제**
- 상세한 상태 리포트 (프로세스, 포트, SSL 인증서)
- SSL 인증서 만료일 D-Day 표시 (30일 이내 경고)
- 컬러 출력 및 로딩 애니메이션

#### 사용법

```bash
# 실행 권한 부여
chmod +x run_tomcat.sh

# Tomcat 시작 (로그 자동 아카이빙 후 시작)
./run_tomcat.sh start

# Tomcat 중지
./run_tomcat.sh stop

# Tomcat 재시작
./run_tomcat.sh restart

# 상태 확인 (포트 + SSL 인증서 정보)
./run_tomcat.sh status
```

#### 환경 설정

```bash
CATALINA_HOME="/sw/TOMCAT/apache-tomcat-8.5.99"  # Tomcat 설치 경로
KEYSTORE_PATH="$CATALINA_HOME/ssl/keystore_ec.jks"  # SSL 인증서 경로
CHECK_PORTS=(18080 18443 18005)  # 점검할 포트 목록
```

---

### 🐘 run_pgsql.sh

PostgreSQL 서비스를 관리하는 스크립트입니다.

#### 주요 기능
- 서비스 시작/중지/재시작
- 상세한 Listen 상태 표시 (TCP/Unix Socket)
- 로그 조회
- 네트워크 설정 확인
- 컬러 출력

#### 사용법

```bash
# 실행 권한 부여
chmod +x run_pgsql.sh

# PostgreSQL 시작
./run_pgsql.sh start

# PostgreSQL 중지
./run_pgsql.sh stop

# PostgreSQL 재시작
./run_pgsql.sh restart

# 상태 확인 (Listen 정보 포함)
./run_pgsql.sh status

# 최근 로그 확인
./run_pgsql.sh logs

# 네트워크 설정 확인
./run_pgsql.sh config
```

#### 환경 설정

```bash
PGDATA="/sw/pg_data"     # PostgreSQL 데이터 디렉토리
PGUSER="appuser"            # PostgreSQL 실행 사용자
SOCKETDIR="/tmp/pgsql"   # Unix Socket 디렉토리
```

---

### ⚠️ 요구사항

| 스크립트 | 요구사항 |
|---------|----------|
| `gen_ecdsa_rsa_jks.sh` | Java JDK (keytool 포함) |
| `run_tomcat.sh` | Tomcat, Java, ss 명령어 |
| `run_pgsql.sh` | PostgreSQL, sudo 권한, ss 명령어 |

**공통**: Linux (Ubuntu/CentOS/RHEL 등)

---

### 📄 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능합니다.

---

## English

### 📋 Overview

A collection of utility scripts frequently used in development and operations environments.

### 📁 Script List

| Script | Description |
|--------|-------------|
| `gen_ecdsa_rsa_jks.sh` | Java Keystore (JKS) auto-generation script (RSA/ECDSA selectable) |
| `run_tomcat.sh` | Tomcat service management script |
| `run_pgsql.sh` | PostgreSQL service management script |

---

### 🔐 gen_ecdsa_rsa_jks.sh

A script that automatically generates a Java Keystore using ECDSA or RSA algorithm.

#### Key Features
- **Algorithm Selection**: Choose `ec` or `rsa` from command line
- ECDSA `secp256r1` curve (lighter than RSA, recommended)
- RSA 2048-bit key support (legacy compatible)
- 10-year validity period
- Overwrite confirmation for existing files
- Auto-display certificate info after generation

#### Usage

```bash
# Grant execution permission
chmod +x gen_ecdsa_rsa_jks.sh

# Generate ECDSA keystore (default, recommended)
./gen_ecdsa_rsa_jks.sh ec
./gen_ecdsa_rsa_jks.sh        # Defaults to 'ec' if no argument

# Generate RSA keystore
./gen_ecdsa_rsa_jks.sh rsa
```

#### Output Files

| Algorithm | Alias | Filename |
|-----------|-------|----------|
| ECDSA | `tomcat_ec` | `keystore_ec.jks` |
| RSA | `tomcat_rsa` | `keystore_rsa.jks` |

#### Configuration

Modify the variables at the top of the script:

```bash
STOREPASS="changeME!"    # Store password
VALIDITY=365            # Validity period (days)
CN="your.domain.com"     # Common Name (domain)
OU="Engineering"         # Organizational Unit
O="DEV"                  # Organization
```

---

### 🐱 run_tomcat.sh

A master controller script for managing Tomcat services.

#### Key Features
- Service start/stop/restart
- **Auto Log Archiving**: Automatically cleans `catalina.out` and access logs before start
- **Auto-delete logs older than 30 days**
- Detailed status report (process, ports, SSL certificate)
- SSL certificate expiry D-Day display (warning within 30 days)
- Colored output and loading animation

#### Usage

```bash
# Grant execution permission
chmod +x run_tomcat.sh

# Start Tomcat (auto-archives logs before starting)
./run_tomcat.sh start

# Stop Tomcat
./run_tomcat.sh stop

# Restart Tomcat
./run_tomcat.sh restart

# Check status (ports + SSL certificate info)
./run_tomcat.sh status
```

#### Configuration

```bash
CATALINA_HOME="/sw/TOMCAT/apache-tomcat-8.5.99"  # Tomcat installation path
KEYSTORE_PATH="$CATALINA_HOME/ssl/keystore_ec.jks"  # SSL certificate path
CHECK_PORTS=(18080 18443 18005)  # Ports to check
```

---

### 🐘 run_pgsql.sh

A script for managing PostgreSQL services.

#### Key Features
- Service start/stop/restart
- Detailed listen status display (TCP/Unix Socket)
- Log viewing
- Network configuration check
- Colored output

#### Usage

```bash
# Grant execution permission
chmod +x run_pgsql.sh

# Start PostgreSQL
./run_pgsql.sh start

# Stop PostgreSQL
./run_pgsql.sh stop

# Restart PostgreSQL
./run_pgsql.sh restart

# Check status (including listen info)
./run_pgsql.sh status

# View recent logs
./run_pgsql.sh logs

# Check network configuration
./run_pgsql.sh config
```

#### Configuration

```bash
PGDATA="/sw/pg_data"     # PostgreSQL data directory
PGUSER="appuser"            # PostgreSQL run user
SOCKETDIR="/tmp/pgsql"   # Unix Socket directory
```

---

### ⚠️ Requirements

| Script | Requirements |
|--------|--------------|
| `gen_ecdsa_rsa_jks.sh` | Java JDK (includes keytool) |
| `run_tomcat.sh` | Tomcat, Java, ss command |
| `run_pgsql.sh` | PostgreSQL, sudo privileges, ss command |

**Common**: Linux (Ubuntu/CentOS/RHEL, etc.)

---

### 📄 License

MIT License - Free to use, modify, and distribute.

---

## 🤝 Contributing

Issues and Pull Requests are welcome!

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
