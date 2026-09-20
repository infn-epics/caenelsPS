
[![Build Status](https://travis-ci.org/CAENels/EPICS-CaenelsFastPS.svg?branch=master)](https://travis-ci.org/CAENels/EPICS-CaenelsFastPS)


EPICS IOC for CAENels FAST-PS & HI-STAR
=============================

This is an EPICS IOC for CAENels power supplies:

  * [FAST-PS](http://www.caenels.com/products/fast-ps/),
  * [FAST-PS-M](http://www.caenels.com/products/fast-ps-m/),
  * [FAST-PS1K5](http://www.caenels.com/products/fast-ps-1k5/),
  * [NGPS](http://www.caenels.com/products/ngps/)

Some parts of this IOC are inspired by **Caen A36xx EPICS Device Support** by
Lawrence Berkeley National Laboratory, Accelerator Technology Group,
Engineering Division.


Required modules
================

| Module | Link |
| --- | --- |
| asyn | https://github.com/epics-modules/asyn |
| EPICS 3.14.12.5 | https://launchpad.net/epics-base/3.14/3.14.12.5 |
| stream | https://github.com/epics-modules/stream |
| calc | https://github.com/epics-modules/calc |
| seq | http://www-csr.bessy.de/control/SoftDist/sequencer/Installation.html |
| sscan | https://github.com/epics-modules/sscan |
| stream | https://github.com/epics-modules/stream |


Required firmware
================
Release >= 1.3.x.


Screen for Control System Studio
================================

![Screen for CSS](Documentation/fastps_css_screen.png)

## UNIMAG states and watchdogs

`STATE_RB` uses the state enumeration shared by the UNIMAG power-supply IOCs:

| Value | State | Alarm | Meaning |
|-------|-------|-------|---------|
| 0 | `OFF` | - | Power supply off |
| 1 | `ON` | - | Output on |
| 2 | `STANDBY` | - | Ready, output disabled |
| 3 | `FAULT` | MAJOR | Power supply fault |
| 4 | `EXT_INTLK` | MAJOR | External interlock |
| 5 | `CONN_FAULT` | MAJOR | Communication errors (the status read fails) |
| 6 | `SP_NOT_REACHED` | MINOR | Current setpoint not reached |
| 7 | `ST_NOT_REACHED` | MAJOR | State not reached (UNIMAG failure) |

Faults win over `ST_NOT_REACHED`, which wins over `SP_NOT_REACHED`. Values from 8 up are
additional, device specific states. `STATE_SP` accepts `OFF`, `ON`, `STANDBY` and `RESET`.

Decoded from the status bits: `OFF` when the supply is off, `EXT_INTLK` for the external
interlock, `FAULT` for the generic fault, FET/shunt overtemperature and DC undervoltage,
`CONN_FAULT` when `StatusLSB` cannot be read. There is no standby: `STANDBY` acts as `OFF`.

### UNIMAG configuration

| Parameter | PV | Description | Default | Units |
|-----------|----|-------------|---------|-------|
| `SET_TOLERANCE` | `SET_TOLERANCE` | Current setpoint tolerance (0 disables the setpoint check) | 1.0 | Amperes |
| `ZERO_TOLERANCE` | `ZERO_TOLERANCE` | Zero current tolerance (a zero setpoint counts as reached within it) | 0.5 | Amperes |
| `SET_TIMEOUT_S` | `SET_TIMEOUT_S` | Setpoint / state timeout (restarts on progress) | 30 | Seconds |

They are db macros (same names) and live PVs, so they can also be changed at runtime. The
timeout restarts whenever the readback gets closer to the setpoint, on a new setpoint and on a
new state command. The setpoint check only runs while the supply is `ON`, and the state check
is armed by the first `STATE_SP` command after boot, so a supply left running is not reported.
`SP_NOT_REACHED` and `ST_NOT_REACHED` (and `SP_ERR`, `SP_WDOG`, `ST_WDOG`) are readable PVs.
