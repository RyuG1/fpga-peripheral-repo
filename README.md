# fpga-peripheral-repo

재사용 가능한 FPGA peripheral 저장소입니다.  
공부, 프로토타이핑, 프로젝트 초기 구성에 활용하는 것을 목표로 합니다.

## 개요

이 저장소는 재사용 가능한 RTL 소스와 툴별 프로젝트, 생성 산출물을 분리해서 관리합니다.

현재는 `rtl/` 구조를 우선 정리하며, 이후 `address_map/`, `apps/`, `docs/`, `sw/`를 쉽게 추가할 수 있도록 구성합니다.

## 디렉토리 구조

```text
fpga-peripheral-repo/
├─ rtl/
│  ├─ src/				◇재사용 가능한 RTL 원본 소스를 보관하는 영역입니다.
│  │  ├─ common/		 : 공통 유틸리티 모듈
│  │  ├─ bus/			 : address decode 및 interconnect 로직
│  │  ├─ peripherals/	 : LED, UART, SPI 등의 재사용 가능한 peripheral 블록
│  │  ├─ top/			 : 상위 통합용 top 소스
│  │  └─ pkg/			 : 공통 정의, package, include 파일
│  ├─ projects/			◇툴 및 보드별 프로젝트 작업 공간입니다.
│  │  ├─ quartus/		 : Quartus 프로젝트
│  │  ├─ vivado/		 : Vivado 프로젝트
│  │  └─ modelsim/		 : 시뮬레이션 및 testbench 환경
│  ├─ artifacts/		◇툴에서 생성되는 산출물을 보관하는 영역입니다.
│  │  ├─ quartus/		 : synthesis 결과물
│  │  ├─ vivado/		 : bitstream / sof / pof
│  │  └─ modelsim/		 : simulation 결과물
│  └─ scripts/			◇빌드, 실행, 생성, 프로젝트 설정에 사용하는 보조 스크립트를 보관합니다.
├─ docs/				◇관리 원칙
├─ sw/					 1. 재사용 가능한 소스는 rtl/src/에 둡니다.
├─ apps/				 2. 툴별 설정과 프로젝트 파일은 rtl/projects/에 둡니다.
├─ constraints/			 3. 생성 산출물은 rtl/artifacts/에 둡니다.
└─ address_map/			 4. docs/, sw/, apps/, address_map/는 필요에 따라 확장합니다.
```

## 주소 기반 모듈 선택 (MMIO)
□ memory-mapped peripheral interface
1) 주변장치 레지스터를 특정 주소 범위에 매핑해, CPU가 해당 주소로 읽기/쓰기하면 장치가 동작
2) CPU 입장에서는 RAM/ROM/Peripheral을 모두 메모리처럼 보고 접근하므로, 주소만 알면 쉽게 연결할 수 있다

```text
Master(CPU/SW/Test Logic)
    │
    │ clk, rst_n, wr, rd, addr, wdata, rdata, 
    ▼
Top / Bus Decoder
    │
    ├─ peripheral 0 select
    ├─ peripheral 1 select
    ├─ peripheral 2 select
    │
    ▼
Each Peripheral
    - 내부 register 보유
    - write면 값 저장
    - read면 값 반환
```

3) TOP 구조
	- 주소 decode 	: 현재 addr가 어느 peripheral 영역인지 판단
	- write routing	: wr=1이면 해당 peripheral에만 write enable 전달
	- read mux		: rd=1이면 선택된 peripheral의 rdata를 최종 출력

## Interface Rule
This repository uses a memory-mapped interface structure.
시스템 주소는 다음 두 부분으로 나뉩니다:

	- peripheral select address
	- local register offset

상위 주소 해석은 top/bus에서 수행합니다.
각 peripheral은 전체 시스템 주소를 해석하지 않고, 전달받은 local offset(`ifaddr`)만 사용합니다.

### 규칙
- 전체 주소 decode는 top/bus의 역할입니다.
- peripheral은 global base address에 의존하지 않습니다.
- peripheral은 local offset만 해석합니다.
- 선택된 모듈만 read/write에 응답해야 합니다.


### 예시: UART 통신
```text
rtl/
└─ src/
   ├─ peripherals/
   │  └─ uart/						◇UART 자체 기능, 다른 프로젝트에서도 재사용 가능
   │     ├─ uart_rx.vhd
   │     ├─ uart_tx.vhd
   │     └─ uart_if.vhd
   ├─ bus/
   │  └─ if_bridge/					◇UART 명령을 외부 IF 동작으로 바꾸는 프로젝트 기능
   │     ├─ uart_cmd_parser.vhd		 : 수신 바이트를 명령으로 해석(cmd)
   │     └─ if_master_ctrl.vhd		 : cmd 로 interface 를 생성
   └─ top/
      └─ top_uart_if_bridge.vhd		◇IfData의 inout 처리
```









## 참고 자료
□ address_map/
1) 핵심 주소 정의 파일 (addr_pkg.vhd)
	시스템 내의 모든 주변 장치(Peripheral)의 베이스 주소와 레지스터 오프셋을 정의하는 VHDL Package 파일입니다.
	포함 내용: * 각 모듈의 Base Address (예: UART, Timer, GPIO)
		- 각 모듈 내부의 Register Offset
		- 데이터 폭(Data Width) 및 주소 폭(Address Width) 상수
			
2) 레지스터 비트 필드 정의 (reg_def_pkg.vhd)
	단순 주소뿐만 아니라, 특정 레지스터 내부의 비트 의미를 정의합니다.
	포함 내용: * Bitchart
		- Control Register의 Enable 비트 위치 (예: index 0)
		- Status Register의 Busy 플래그 위치 등

3) 근원 파일 (address_map.py 또는 address_map.csv)
	나중에 프로젝트가 커지면 VHDL 코드뿐만 아니라 펌웨어(C언어)나 문서에서도 동일한 주소를 써야한다
	이를 위해 마스터 데이터를 CSV나 Python으로 관리하고 VHDL을 자동 생성하도록 한다.
	
4) 프로젝트 별 폴더를 구분하는 것을 추천




□ rtl/src/
1) pkg/bus_pkg.vhd : 버스 신호 묶음(Record) 정의
2) bus/bus_interconnect.vhd: 디코더들을 포함하여 Master 주소를 보고 각 Peripheral로 신호를 분배해주는 중간 관리자
3) address_map/proj_v1/: 상위 비트(BASE_ADDR)를 결정하는 상수 파일



■ 인터페이스 정의 (Bus Interface)
1) 인터페이스 구조체(Record) : *rtl/src/pkg/bus_pkg.vhd
	- 마스터(CPU/Top)에서 슬레이브(Peripheral)로 가는 신호
	- 슬레이브에서 마스터로 오는 신호

