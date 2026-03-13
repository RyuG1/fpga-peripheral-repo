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
│  ├─ src/
│  │  ├─ common/
│  │  ├─ bus/
│  │  ├─ peripherals/
│  │  ├─ top/
│  │  └─ pkg/
│  ├─ projects/
│  │  ├─ quartus/
│  │  ├─ vivado/
│  │  └─ modelsim/
│  ├─ artifacts/
│  │  ├─ quartus/
│  │  ├─ vivado/
│  │  └─ modelsim/
│  └─ scripts/
├─ docs/
├─ sw/
├─ apps/
├─ constraints/
└─ address_map/

rtl/
src/

재사용 가능한 RTL 원본 소스를 보관하는 영역입니다.

common/ : 공통 유틸리티 모듈

bus/ : address decode 및 interconnect 로직

peripherals/ : LED, UART, SPI 등의 재사용 가능한 peripheral 블록

top/ : 상위 통합용 top 소스

pkg/ : 공통 정의, package, include 파일

projects/

툴 및 보드별 프로젝트 작업 공간입니다.

quartus/ : Quartus 프로젝트

vivado/ : Vivado 프로젝트

modelsim/ : 시뮬레이션 프로젝트 및 testbench 환경

artifacts/

툴에서 생성되는 산출물을 보관하는 영역입니다.

synthesis 결과물

bitstream / sof / pof

report

simulation 결과물

scripts/

빌드, 실행, 생성, 프로젝트 설정에 사용하는 보조 스크립트를 보관합니다.

관리 원칙

재사용 가능한 소스는 rtl/src/에 둡니다.

툴별 설정과 프로젝트 파일은 rtl/projects/에 둡니다.

생성 산출물은 rtl/artifacts/에 둡니다.

docs/, sw/, apps/, address_map/는 필요에 따라 확장합니다.