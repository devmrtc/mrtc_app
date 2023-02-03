close all
clear all
SET EXCLUSIVE OFF

SET LIBRARY TO LOCFILE("vfpcompression.fll") ADDITIVE 

with _screen
	.windowstate 	= 2
	.icon        	= "images\gsico.ico"
	.caption 		= "GreenSoft Application Launcher 1.0.0.1"
ENDWITH
SET DATE BRITISH
SET CENTURY ON
SET PROCEDURE TO ftp.prg 
DO FORM frmapplauncher
 
