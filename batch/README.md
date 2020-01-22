# Some Script for Windows Batch
## WinPEMount 
mount patch the Startnet.cmd and commit
mount a new WindowsPE Image in D:\WinPE_amd64, patch the Startnet.cmd and commit
```
WinPEMount c 
```
## StartWinPE 
is called from the patched Startnet.cmd
## restore 
restores an Image on a brand new Disk
## FindeLW 
find a Driveletter and is setting the Variable %DRIVE%
find the Drive with the Path \wim 
```
FindeLW.cmd \wim
```
## CreatePartition-xxxx 
Files will be used as Script Input for Diskpart
