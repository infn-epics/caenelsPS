#!../../bin/linux-x86_64/CaenelsPS

< envPaths

epicsEnvSet ("PATH", "${PATH}:${TOP}/bin")
epicsEnvSet ("STREAM_PROTOCOL_PATH", ".:../../protocols")
epicsEnvSet("P","SPARC-SBN:MAG:FAST:")
epicsEnvSet("R","PTLQUA03:")

cd "${TOP}"

## Register all support components
dbLoadDatabase("dbd/CaenelsPS.dbd",0,0)
CaenelsPS_registerRecordDeviceDriver(pdbbase)

## Configure device
drvAsynIPPortConfigure("L0","192.168.0.123:10001",0,0,0)

## Load record instances
dbLoadRecords("db/fastps.db", "P=$(P),R=$(R),PORT=L0,RANGEI=30,RANGEV=20,RAMPI=0,RAMPV=0")
dbLoadRecords("db/unimag-fastps.db", "P=$(P),R=$(R),PORT=L0")

cd "${TOP}/iocBoot/${IOC}"
iocInit()
