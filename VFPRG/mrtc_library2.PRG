PROC Rconnect
SET PROCEDURE TO Mrtc_library2
=connect2Sql()


PROCEDURE _GetMaster2 
 SET TALK OFF
 SET SAFETY OFF
 CLOSE DATABASES 
 CLEAR

 ANS_YN=MESSAGEBOX('Download Master Data',4+64+256,'SQL Server Master Data')

 IF ans_yn # 6 THEN 
   CLOSE DATABASES
   RETURN
 ENDIF 
 SET CENTURY ON 
 IF dataconn <= 0 THEN
   MESSAGEBOX('Unable to connect Database Server',0+16+0,'SQL Server Connect Error')
   CLOSE DATABASES
   RETURN
 ENDIF


 WAIT WINDOW "Retriving Master Data from STN " NOWAIT 
 sqlcmd   = "select * from Stn with (nolock)"
 retval   = sqlexec(dataconn,sqlcmd,'Tmp')
 IF retval <= 0
	 =AERROR(errorarray)
	 MESSAGEBOX(errorarray[2])
	 RETURN 
 ENDIF
* SET FILTER TO ISACTIVE
 COPY TO F:\VFPRG\STN

*F7
FUNCTION GetStnstateId
PARAMETERS mSTNId
RTVAL = SQLEXEC(dataconn," SELECT ISNULL(stn.StateId,0) AS  StateId FROM State STT  WITH(NOLOCK) LEFT JOIN STN  WITH(NOLOCK) ON STN.StateId=STT.StateId  WHERE STN.BranchId =?mSTNId ","GetTmpBr")
IF RTVAL<0
   =MESSAGEBOX('- Connection Error -')
   RETURN 0
ENDIF 
SELECT GetTmpBr
mStateId = StateId
RETURN mStateId

*F6
FUNCTION   StationaryChk
PARAMETERS FromNo,ToNo ,mBrid,mStype
SQLCMD = "EXEC StationaryIssued ?FromNo,?mBrid,?FromNo,?ToNo,?mStype "
IF SQLEXEC (dataconn,SQLCMD,"TEMP") > 0
	IF RECCOUNT() = 0
		_mValidStationary = .F.
		=MESSAGEBOX("Stationary Not Issued For "+_mBrName )
		RETURN 0
	ELSE
		_mValidStationary = .T.
	ENDIF
ELSE
	=MESSAGEBOX("Data Retrival Error. ")	
ENDIF

*F6
FUNCTION   StationaryStkChk
PARAMETERS mStype,FromNo,ToNo 
SQLCMD = "EXEC StationaryStkChk ?mStype ,?FromNo,?ToNo"
IF SQLEXEC (dataconn,SQLCMD,"TEMP") > 0
	IF RECCOUNT() = 0
		_mValidStationary = .F.
		=MESSAGEBOX("Stationary Not Issued For "+_mBrName )
		RETURN 0
	ELSE
		_mValidStationary = .T.
	ENDIF
ELSE
	=MESSAGEBOX("Data Retrival Error. ")	
ENDIF



*F5
FUNCTION   SelectClient
PARAMETERS mClientGST,mbr
PUBLIC _mGstClientId  ,_mClientName   ,_mclientGstNo ,_mClientPan ,_mClientAadharNo ,_mAdd1 ,_Madd2 , _mvalGst 
STORE 0 TO _mGstClientId
STORE '' TO _mClientName,_mclientGstNo,_mClientPan,_mClientAadharNo,_mAdd1 ,_Madd2

**xg="RelatedStn='SRT' "
xg = "RelatedStn='"+mbr+"'"
IF mClientGST=' ' 
	DO FORM FaSprocGst4 WITH 'GST_ClientReg','ClientName','StateId','RegistrationNo','Address1','Address2','Address3','RegistrationId','RelatedStn','PanNumber','AadharNo',xg ,590,200,30 , "<< Select Party Name >>"," "     
	IF recc('searchcurs') > 0
		SELECT searchcurs
		*GO TOP
		_mGstClientId  = RegId
		_mClientName   = ALLTRIM(Name)
		_mclientGstNo = ALLTRIM(GstNo)
		_mClientPan = ALLTRIM(PanNumber)
		_mClientAadharNo = ALLTRIM(AadharNo)
		_mAdd1 = ALLTRIM(Address1)
		_Madd2 = ALLTRIM(Address2)
	ENDIF 
ELSE
	x1=" select  RegistrationId as  Regid , ClientName as Name ,StateId,RegistrationNo as Gstno ,isnull(Address1,'') as Address1 ,isnull(Address2,' ') as Address2 , "
	x2=" isnull(Address3,'') as Address3 ,RegistrationId,RelatedStn,isnull(PanNumber,'') as PanNumber , isnull( AadharNo,' ') as AadharNo "
    X3=" From  GST_ClientReg with (nolock) where RegistrationNo= ?mClientGST "
	cmd = x1+x2+x3
	SELECT 0
	Rtval = SQLEXEC(dataconn,cmd,'Tmp')
	IF rtval <0
	   =AERROR(errorarray)
	   MESSAGEBOX(errorarray[2])
	   RETURN 
	ENDIF 
    SELECT Tmp
		_mGstClientId  = RegId
		_mClientName   = ALLTRIM(Name)
		_mclientGstNo = ALLTRIM(GstNo)
		_mClientPan = ALLTRIM(PanNumber)
		_mClientAadharNo = ALLTRIM(AadharNo)
		_mAdd1 = ALLTRIM(Address1)
		_Madd2 = ALLTRIM(Address2)
   	use 
ENDIF 


*F4
FUNCTION PanVeryFy
PARAMETERS mPan
	mPan = ALLTRIM(mPan)
	IF LEN(mGst) < 10
	   =MESSAGEBOX("Invalid Pan Lenth ",0+64+256,'MATA')
	   RETURN 0
	ENDIF
	IF ISALPHA(SUBSTR(mPan,1,1))=.F.
		=MESSAGEBOX('1st Letter must be Alpha ')
	ENDIF  
	IF ISALPHA(SUBSTR(mPan,2,1))=.F.
		=MESSAGEBOX('2nd Letter must be Alpha ')
	ENDIF  
	IF ISALPHA(SUBSTR(mPan,3,1))=.F.
		=MESSAGEBOX('3rd Letter must be Alpha ')
	ENDIF  
	IF ISALPHA(SUBSTR(mPan,4,1))=.F.
		=MESSAGEBOX('4th Letter must be Alpha ')
	ENDIF  
	IF ISALPHA(SUBSTR(mPan,5,1))=.F.
		=MESSAGEBOX('5th Letter must be Alpha ')
	ENDIF  
	IF inlist(SUBSTR(mPan,6,1),'0','2','1','3','4','5','6','7','8','9')=.F.
		=MESSAGEBOX('6th Letter must be numeric ')
	ENDIF  
	IF inlist(SUBSTR(mPan,7,1),'0','2','1','3','4','5','6','7','8','9')=.F.
		=MESSAGEBOX('7th Letter must be numeric')
	ENDIF  
	IF inlist(SUBSTR(mPan,8,1),'0','2','1','3','4','5','6','7','8','9')=.F.
		=MESSAGEBOX('8th Letter must be numeric')
	ENDIF  
	IF inlist(SUBSTR(mPan,9,1),'0','2','1','3','4','5','6','7','8','9')=.F.
		=MESSAGEBOX('9th Letter must be numeric')
	ENDIF  
	IF ISALPHA(SUBSTR(mPan,10,1))=.F.
	   =MESSAGEBOX('10th Letter must be Alpha ')
	ENDIF  
	*---------------------    
	Cmd1 = " EXEC FOX_GetPan_ClientReg ?Pan "
	Rtv1  = SQLEXEC(DATACONN,Cmd1,'TmpPan')
	IF Rtv1 < 0
		=MESSAGEBOX( "Connection Failed.")
		RETURN 0
	ENDIF 
	SELECT TmpPan
	PUBLIC _Pname  , _Pid , _Pgst
	
	IF RECCOUNT() > 0  && For GST Reg Consignor
		_Pname = TmpPan.ClientName
		_Pid = TmpPan.RegId
		_Pgst = ALLTRIM(TmpPan.PanNo)
	ELSE  
		_Pname = SPACE(30)
		_Pid = 0
		_Pgst = SPACE(10)
	ENDIF 

*F3

FUNCTION GstVeryFy
PARAMETERS mGst
	mGst = ALLTRIM(mGst)
	_mvalGst=.T.
	_mvalGst=.T.
	IF LEN(mGst) <> 15
	   =MESSAGEBOX("Invalid GSTIN Lenth ",0+64+256,'MATA')
	   _mvalGst=.F.
	ENDIF
	er = "         E R R O R     I N "+CHR(13)
	er = er+"---------------------------------------"+CHR(13)
	IF !BETWEEN( VAL(LEFT(mGst,2)) , 1,37)
		er= er +' 1st Letter '+CHR(13)
	   _mvalGst=.F.
	ENDIF 
	IF !BETWEEN( VAL(LEFT(mGst,2)) , 1,37)
		er= er +' 2nd Letter '+CHR(13)
	   _mvalGst=.F.
	ENDIF 
	IF ISALPHA(SUBSTR(mGst,3,1))=.F.
		er= er +' 3rd Letter must be Alpha '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF ISALPHA(SUBSTR(mGst,4,1))=.F.
		er= er +' 4th Letter must be Alpha  '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF ISALPHA(SUBSTR(mGst,5,1))=.F.
		er= er +' 5th Letter must be Alpha '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF ISALPHA(SUBSTR(mGst,6,1))=.F.
		er= er +' 6th Letter must be Alpha '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF ISALPHA(SUBSTR(mGst,7,1))=.F.
		er= er +' 7th Letter must be Alpha  '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF inlist(SUBSTR(mGst,8,1),'0','2','1','3','4','5','6','7','8','9')=.F.
		er= er +' 8th Letter must be numeric   '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF inlist(SUBSTR(mGst,9,1),'0','2','1','3','4','5','6','7','8','9')=.F.
		er= er +' 9th Letter must be numeric '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF inlist(SUBSTR(mGst,10,1),'0','2','1','3','4','5','6','7','8','9')=.F.
		er= er +' 10th Letter must be numeric '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF inlist(SUBSTR(mGst,11,1),'0','2','1','3','4','5','6','7','8','9')=.F.
		er= er +' 11th Letter must be numeric '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
	IF ISALPHA(SUBSTR(mGst,12,1))=.F.
		er= er +' 12th Letter must be Alpha '+CHR(13)
	   _mvalGst=.F.
	ENDIF  
*!*		IF inlist(SUBSTR(mGst,13,1),'0','2','1','3','4','5','6','7','8','9')=.F.
*!*			er= er +' 13th Letter must be Numeric '+CHR(13)
*!*		   _mvalGst=.F.
*!*		ENDIF  
*!*		IF ISALPHA(SUBSTR(mGst,14,1))=.F.
*!*			er= er +' 14th Letter must be Alpha '+CHR(13)
*!*		   _mvalGst=.F.
*!*		ENDIF  
*!*		IF ISALPHA(SUBSTR(mGst,15,1))=.F.
*!*			er= er +' 15th Letter must be Alpha '+CHR(13)
*!*		   _mvalGst=.F.
*!*		ENDIF  
	   IF _mvalGst=.F.
	      =MESSAGEBOX(er)
	   ENDIF 

	*---------------------    
IF 	_mvalGst=.T.	
	Cmd1 = " EXEC FOX_GetGST_ClientReg ?mGst "
	Rtv1  = SQLEXEC(DATACONN,Cmd1,'TmpGst')
	IF Rtv1 < 0
		=MESSAGEBOX( "Connection Failed.")
		RETURN 0
	ENDIF 
	SELECT TmpGst
	PUBLIC _Pname  , _Pid , _Pgst
	
	IF RECCOUNT() > 0  
		_Pname = TmpGst.ClientName
		_Pid = TmpGst.RegId
		_Pgst = ALLTRIM(TmpGst.PanNo)
	ELSE  
		_Pname = SPACE(30)
		_Pid = TmpGst.RegId
		_Pgst = ALLTRIM(TmpGst.PanNo)
	ENDIF 
ENDIF 
RETURN _mvalGst

*F2
FUNCTION BranchSelection
PARAMETERS mBr ,mRow,mCol
	IF Used("Stn")
	   SELECT Stn
	ELSE 
	   	USE Stn IN 0
	ENDIF
	SELECT stn
	LOCATE FOR Acode == ALLTRIM(mBr)  
	IF FOUND()
	   _mBrName = BranchName
	   _mBrId   = BranchId 
	   _mAcode = Acode
	ELSE 
	   _mBrName = '   '
	   _mBrId   = 0
	   _mAcode = '   '
	ENDIF 
	IF EMPTY(_mBrId) OR _mBrId=0 OR EMPTY(mBr)
		DO FORM sproc1  WITH 'STN','BranchName','BranchId','Acode','',mRow,mCol,20, "Select Station Name ","251,132,162"    
		IF recc('searchcurs')>0
			SELECT searchcurs
	        _mBrName = Name
	        _mBrId   = CODE_ID
	        _mAcode = Acode
			RETURN .T.
		ELSE 
			=MESSAGEBOX("Invalid Branch Selection" ) 
			RETURN .f.
		ENDIF 
	ENDIF 

*F1
FUNCTION PublicVariable
PUBLIC _mBrName , _mBrId , _mAcode , _mValidStationary,_mvalGst,mCoName , abold , bbold
_mBrId=0
mConame='M A A    R U D R A     T R A N S P O R T   C O M P A N Y '
abold = chr(27)+chr(69)
bbold = chr(27)+chr(70)
RETURN 



CANCEL
*--------------------------------------------
FUNCTION WebConn
PARAMETERS AA
X = "SELECT WEB_CONN FROM WEB_SERVER WITH (NOLOCK) WHERE ISNULL(SIP_VPN,'') =?AA "
RTVAL = SQLEXEC(DATACONN , X ,'T')
IF RTVAL<0
   =MESSAGEBOX('-Connection Failed In Web_Server-')
ELSE 
	SELECT t
	 s= ALLTRIM(t.Web_conn)   
     WebConn=&s
ENDIF 
RETURN Webconn 

NOTE  * For Direct Connect 
      * WebConn=SQLSTRINGCONNECT("Driver=SQL SERVER;SERVER=103.16.140.37,1433;Database=TranSOFTMata;UID=matasql;pwd=mata@123")	
	  * ---- For Calling 
      * PUBLIC webconn
      * =WebConn()
	  * ---- For DISCONNECT  SQLDISCONNECT(webconn)


FUNCTION connect2Sql	  
	  public Dataconn
	  RESTORE FROM c:\windows\mrtc.xps2 ADDITIVE
      Dataconn = &MrtcConn
	  ValidUser =IIF(Dataconn>0,.T.,.F.)
	 RETURN dataconn



FUNCTION OffLineConn2Online	  
	  RESTORE FROM c:\windows\mrtcv1.xps ADDITIVE 
		  IF On_Line=.F. 
			DECLARE INTEGER GetRTTAndHopCount IN Iphlpapi;
			        INTEGER DestIpAddress, LONG @HopCount,;
						INTEGER MaxHops, LONG @RTT
					DECLARE INTEGER inet_addr IN ws2_32 STRING cp
					LOCAL nDst, nHop, nRTT,nAirtel
					nAirtel = inet_addr('182.71.172.69') && Airtel
					nDst = inet_addr('27.251.4.147')     && AirCel
					STORE 0 TO nHop, nRTT
				IF GetRTTAndHopCount(nAirtel, @nHop, 50, @nRTT) <> 0
				   Hsconn = &AirTelConn
				ELSE
				   IF GetRTTAndHopCount(nDst, @nHop, 50, @nRTT) <> 0
					  Hsconn = &AirCelConn
					ELSE
					  WAIT WINDOW " Not Connected To HO Server " 
					  RETURN 0 
					ENDIF
				ENDIF
	         ENDIF
	  localconn  =' '
	  Tulipconn =' ' 
	  Sanjayconn =' '
	  pps=' '
	  AirCelConn=' ' 
	  RETURN Hsconn 
	  
	  
PROCEDURE connect3Sql
dataconn= &Sanjayconn 
RETURN dataconn 


PROCEDURE  connect4Sql
&TulipConn
RETURN dataconn 



FUNCTION createsearchcurs
	CREATE CURSOR searchcurs;
		(valuefld c(50),keyfld c(50))	

FUNCTION ChkStn
	sqlcmd ="select * from stn " 
	retval = SQLEXEC(dataconn,sqlcmd,'tmpstn') 
	IF retval >0
		SELECT tmpstn
		SET FILTER TO 
		SET FILTER TO acode = mbcd 
		GO TOP
		mstn = branchid
		StnName = ALLTRIM(branchName)
	 	*FindStn = .T.
	 ELSE
	    *FindStn = .F.
	    mstn    = 0	       
    ENDIF
      
RETURN mstn


PROCEDURE  calendar
Activate Window 'calendar'
PROCEDURE  calculator
*-----------
DO calc

*--------------------------------- Start of _printer()
FUNCTION _printer()
PARAMETERS fil
DEFINE POPUP Printmenu SHORTCUT RELATIVE FROM MROW(),MCOL()

DEFINE BAR  1 OF Printmenu PROMPT  "\<1.LOCAL PRINTER  "
DEFINE BAR  2 OF Printmenu PROMPT  "\<2.TBB PRINTER    "
DEFINE BAR  3 OF Printmenu PROMPT  "\<3.FA PRINTER     "
DEFINE BAR  4 OF Printmenu PROMPT  "\<4.CLAIM PRINTER  "
DEFINE BAR  5 OF Printmenu PROMPT  "\<5.TEA PRINTER    "
DEFINE BAR  6 OF Printmenu PROMPT  "\<6.STOCK PRINTER  "
DEFINE BAR  7 OF Printmenu PROMPT  "\<7.LEDGER PRINTER "
DEFINE BAR  8 OF Printmenu PROMPT  "\<8.Print Preview  "
DEFINE BAR  9 OF Printmenu PROMPT  "\<9.File Save In F:\Internet\. "
DEFINE BAR 10 OF Printmenu PROMPT  "\<A.Re-Print from F:\internet\ "
DEFINE BAR 11 OF Printmenu PROMPT  "\<0.EXIT           "

ON SELECTION BAR 01 OF Printmenu LocalPrinter()
ON SELECTION BAR 02 OF Printmenu TbbPrinter()
ON SELECTION BAR 03 OF Printmenu FAPrinter()
ON SELECTION BAR 04 OF Printmenu ClaimPrinter()
ON SELECTION BAR 05 OF Printmenu TeaPrinter()
ON SELECTION BAR 06 OF Printmenu StockPrinter()
ON SELECTION BAR 07 OF Printmenu LedgerPrinter()
ON SELECTION BAR 08 OF Printmenu mPreview() 
ON SELECTION BAR 09 OF Printmenu mSave() 
ON SELECTION BAR 10 OF Printmenu Reprint()
ON SELECTION BAR 11 OF Printmenu Exita()



ACTIVATE POPUP Printmenu

FUNCTION LocalPrinter()
	RUN Type &fil >prn
	DEACTIVATE POPUP prinmenu 

FUNCTION TbbPrinter()
	fill = '/D:\\SUNIL-50\WIPROLQ2 '+fil
	RUN C:\windows\system32\PRINT &fill 		
	DEACTIVATE POPUP prinmenu 

FUNCTION FAPrinter()
	fill = '/D:\\VICKY\EPSON-PAIR '+fil
	RUN C:\windows\system32\PRINT &fill 
	DEACTIVATE POPUP prinmenu 

FUNCTION ClaimPrinter()
 	fill = '/D:\\MADHU\WEP-INT5235 '+fil
	RUN C:\windows\system32\PRINT &fill 
	DEACTIVATE POPUP prinmenu 

FUNCTION TeaPrinter()
	fill = '/D:\\MATA-NODE102\MTPL-EPSON '+fil
	RUN C:\windows\system32\PRINT &fill 
	DEACTIVATE POPUP prinmenu 

FUNCTION StockPrinter()
	fill = '/D:\\wipro\wep-bip '+fil
	RUN C:\windows\system32\PRINT &fill 
	DEACTIVATE POPUP prinmenu 

FUNCTION LedgerPrinter()
	set print off
	_lmargin = 5
	=getprinter()
	set device to print
	set print on
	set consol off
	type &FIL
	set print to
	set print off
	DEACTIVATE POPUP prinmenu 

FUNCTION Exita()
	DEACTIVATE POPUP prinmenu 
     
FUNCTION mPreview()
     KEYBOARD "{ctrl+F10}"
     MODIFY COMMAND &fil
     
FUNCTION mSave()
	mfl=input('Enter File Name : ' ,' ')
    IF !EMPTY(mfl)
        Newfile = ALLTRIM(mfl)+'.txt'
    ELSE
    	Newfile = fil
    ENDIF 
    !copy &fil f:\internet\&newfile
     WAIT WINDOW  " File Saved in F:\internet\&Newfile" 
     
FUNCTION Reprint()
	mfl=input('Enter File Name : ' ,' ')
    Newfile = 'F:\internet\'+ALLTRIM(mfl)
   	KEYBOARD "{ctrl+F10}"
    MODIFY comm &Newfile
   	RUN Type Newfile >prn
	DEACTIVATE POPUP prinmenu 
    
     
*--------------------------------- End of _printer()

*---------------------- _printer2()
FUNCTION _printer2
PARAMETERS ii
fil =ii
set stat off
PrintForm = CREATEOBJECT('Form')  && Create a Form
PrintForm.Closable = .F.  && Disable the Control menu box 
PRINTFORM.CAPTION='Select Printer '
printform.titlebar=1
printform.Height=45
PRINTFORM.TOP =600
PRINTFORM.Autocenter = .T.
PRINTFORM.LEFT =150
PRINTFORM.WIDTH =810
** PRINTFORM.AlwaysOnTop= .T.
printform.icon="f:\vfprg\image\printfld.ico"


PrintForm.AddObject('cmdCmndBtn1','cmdMyCmndBtn1')  && Up Cmnd button
PrintForm.AddObject('cmdCmndBtn2','cmdMyCmndBtn2')  && Down Cmnd button
PrintForm.AddObject('cmdCmndBtn3','cmdMyCmndBtn3')  && Quit Cmnd button
PrintForm.AddObject('cmdCmndBtn4','cmdMyCmndBtn4')  && Quit Cmnd button
PrintForm.AddObject('cmdCmndBtn5','cmdMyCmndBtn5')  && Quit Cmnd button
PrintForm.AddObject('cmdCmndBtn6','cmdMyCmndBtn6')  && Quit Cmnd button
PrintForm.AddObject('cmdCmndBtn7','cmdMyCmndBtn7')  && Quit Cmnd button
PrintForm.AddObject('cmdCmndBtn8','cmdMyCmndBtn8')  && Quit Cmnd button

PrintForm.cmdCmndBtn1.Visible =.T.  
PrintForm.cmdCmndBtn2.Visible =.T.  
PrintForm.cmdCmndBtn3.Visible =.T.  
PrintForm.cmdCmndBtn4.Visible =.T.  
PrintForm.cmdCmndBtn5.Visible =.T.  
PrintForm.cmdCmndBtn6.Visible =.T.  
PrintForm.cmdCmndBtn7.Visible =.T.  
PrintForm.cmdCmndBtn8.Visible =.T.  


PrintForm.SHOW  && Display the form
READ EVENTS     && Start event processing

DEFINE CLASS cmdMyCmndBtn1 AS CommandButton  && Create Command button
   Caption = 'TBB Printer -\<1'  && Caption on the Command button
   Left    = 5  && Command button column
   Top     = 5  && Command button row
   Height  = 35  && Command button height
   
   PROCEDURE Click
	fill = '/D:\\SUNIL-50\WIPROLQ2 '+fil
	RUN C:\windows\system32\PRINT &fill 		
ENDDEFINE


DEFINE CLASS cmdMyCmndBtn2 AS CommandButton  && Create Command button
   Caption = 'FA Printer -\<2'  && Caption on the Command button
   Left = 105  && Command button column
   Top = 5  && Command button row
   Height = 35  && Command button height

   PROCEDURE Click
	fill = '/D:\\VICKY\EPSON-PAIR '+fil
	RUN C:\windows\system32\PRINT &fill 
ENDDEFINE

DEFINE CLASS cmdMyCmndBtn3 AS CommandButton  && Create Command button
   Caption = 'Claim Printer -\<3'  && Caption on the Command button
   Left = 205  && Command button column
   Top = 5  && Command button row
   Height = 35  && Command button height

   PROCEDURE Click
	fill = '/D:\\MADHU\WEP-INT5235 '+fil
	RUN C:\windows\system32\PRINT &fill 
ENDDEFINE

DEFINE CLASS cmdMyCmndBtn4 AS CommandButton  && Create Command button
   Caption = 'Tea Printer -\<4'  && Caption on the Command button
   Left = 305  && Command button column
   Top = 5  && Command button row
   Height = 35  && Command button height

   PROCEDURE Click
	fill = '/D:\\MATA-NODE102\MTPL-EPSON '+fil
	RUN C:\windows\system32\PRINT &fill 
ENDDEFINE

DEFINE CLASS cmdMyCmndBtn5 AS CommandButton  && Create Command button
   Caption = 'Stock Printer -\<5'  && Caption on the Command button
   Left = 405  && Command button column
   Top = 5  && Command button row
   Height = 35  && Command button height

   PROCEDURE Click
	fill = '/D:\\wipro\wep-bip '+fil
	RUN C:\windows\system32\PRINT &fill 
ENDDEFINE



DEFINE CLASS cmdMyCmndBtn6 AS CommandButton  && Create Command button
   Caption = 'Laser - \<6'  && Caption on the Command button
   Left = 505  && Command button column
   Top = 5  && Command button row
   Height = 35  && Command button height

   PROCEDURE Click
	set print off
	_lmargin = 5
	=getprinter()
	set device to print
	set print on
	set consol off
	type &FIL
	set print to
	set print off
ENDDEFINE



DEFINE CLASS cmdMyCmndBtn7 AS CommandButton  && Create Command button
   Caption = 'Print Pre\<view'  && Caption on the Command button
   Left = 605  && Command button column
   Top = 5  && Command button row
   Height = 35  && Command button height

   PROCEDURE Click
	keyb '{ctrl+f10}'
	MODIFY FILE &fil

ENDDEFINE

DEFINE CLASS cmdMyCmndBtn8 AS CommandButton  && Create Command button
   Caption = '\<Cancel '  && Caption on the Command button
   Cancel = .T.  && Default Cancel Command button (Esc)
   Left = 705  && Command button column
   Top = 5  && Command button row
   Height = 35  && Command button height

   PROCEDURE Click
      CLEAR EVENTS  && Stop event processing, close Form
      RETURN

ENDDEFINE


FUNCTION chknullDate
PARAMETERS iidt
IF iidt=Null
   RETURN 
ENDIF 
IF iidt={} or YEAR(iidt)=1900
   iidt=Null   
ENDIF 
RETURN Iidt 

FUNCTION chknullTime
PARAMETERS itm
IF itm=Null
   RETURN 
ENDIF 
IF EMPTY(itm) or ALLTRIM(itm)=':' OR ALLTRIM(itm)='00:00' OR ALLTRIM(itm)='0:00' OR ALLTRIM(itm)='0:0'
   itm=Null   
ENDIF 
RETURN itm





PROCEDURE getmaster 
 PUBLIC dataconn
 PUBLIC hoconn

 SET TALK OFF
 SET SAFETY OFF
 CLOSE DATABASES 
 CLEAR

 ANS_YN=MESSAGEBOX('Download Master Data',4+64+256,'SQL Server Master Data')

 IF ans_yn # 6 THEN 
   CLOSE DATABASES
   RETURN
 ENDIF 
  

 SET CENTURY ON 


 IF dataconn <= 0 THEN
   MESSAGEBOX('Unable to connect Database Server',0+16+0,'SQL Server Connect Error')
   CLOSE DATABASES
   RETURN
 ENDIF


 WAIT WINDOW "Control FIle " NOWAIT 
 sqlcmd   = "select * from FaControl with (nolock) order by OpfyDate desc "
 retval   = sqlexec(dataconn,sqlcmd,'Tmp')
 IF retval <= 0
	 =AERROR(errorarray)
	 MESSAGEBOX(errorarray[2])
	 RETURN 
 ENDIF

 SET DATE ANSI     && DONT MAKE ANY CHANGES IN THIS LINE

 SELECT Tmp
 SET FILTER TO ISACTIVE
 COPY TO F:\VFPRG\FACONTROL
 USE
 USE F:\VFPRG\FACONTROL EXCLUSIVE
 ALTER TABLE facontrol ALTER COLUMN opfydate D
 ALTER TABLE facontrol ALTER COLUMN clfydate D
 USE
 
 WAIT WINDOW "Retriving Master Data from FaGrMaster" NOWAIT 
 sqlcmd   = "select * from FaGrMaster with (nolock)"
 retval   = sqlexec(dataconn,sqlcmd,'TMPGR')
 IF retval <= 0
   =AERROR(errorarray)
   MESSAGEBOX(errorarray[2])
   RETURN 
 ENDIF


 SELECT TMPGR
 SORT ON GRNAME TO F:\VFPRG\TMPGR
 USE
 
 USE F:\VFPRG\TMPGR EXCL 
 INDEX ON GRNAME TO F:\VFPRG\GRNAME
 INDEX ON GRCODE TO F:\VFPRG\GRCODE
 USE
 
 WAIT WINDOW "Retriving Master Data from FaAcMaster" NOWAIT 
 sqlcmd   = "select * from FaAcMaster with (nolock)  WHERE ISACTIVE=1 "
 retval   = sqlexec(dataconn,sqlcmd,'TmpAcm')
 IF retval <= 0
	 =AERROR(errorarray)
	 MESSAGEBOX(errorarray[2])
	 RETURN 
 ENDIF

 SELECT TmpAcm
 SORT ON ACNAME TO F:\VFPRG\TMPAC
 USE
 
 USE F:\VFPRG\TMPAC
 INDEX ON ACCODE TO F:\VFPRG\ACCODE
 INDEX ON ACNAME TO F:\VFPRG\ACNAME
 USE

 WAIT WINDOW "Retriving Master Data from FaAcInfo" NOWAIT 
 sqlcmd   = "select * from FaAcInfo with (nolock)"
 retval   = sqlexec(dataconn,sqlcmd,'TMPACI')
 IF retval <= 0
   =AERROR(errorarray)
   MESSAGEBOX(errorarray[2])
   RETURN 
 ENDIF

 SELECT TMPACI
 COPY TO F:\VFPRG\TMPACINFO
 USE
 
 USE F:\VFPRG\TMPACINFO 
 INDEX ON ACCODE TO F:\VFPRG\ACI_CODE
 USE

 WAIT WINDOW "Retriving Master Data from FaDocType" NOWAIT 
 sqlcmd   = "select * from FaDocType with (nolock)"
 retval   = sqlexec(dataconn,sqlcmd,'Tmp')
 IF retval <= 0
	 =AERROR(errorarray)
	 MESSAGEBOX(errorarray[2])
	 RETURN 
 ENDIF

 SELECT Tmp
 COPY TO F:\VFPRG\DocType
 USE
 
 WAIT WINDOW "Retriving Master Data from STN" NOWAIT 
 sqlcmd   = "select * from STN with (nolock)"
 retval   = sqlexec(dataconn,sqlcmd,'Tmp')
 IF retval <= 0
	 =AERROR(errorarray)
	 MESSAGEBOX(errorarray[2])
	 RETURN 
 ENDIF

 SELECT Tmp
 COPY TO F:\VFPRG\FASTN
 USE

 USE F:\VFPRG\FASTN EXCL
 ALTER TABLE FASTN ALTER COLUMN BRANCHNAME C(30)
 DELETE ALL FOR ISNULL(ACODE) OR ACODE='   '
 PACK
 USE
 USE F:\VFPRG\FASTN EXCLUSIVE
 INDEX ON ACODE TO F:\VFPRG\ACODE
 INDEX ON BRANCHNAME TO F:\VFPRG\BRANCH
 USE 


 WAIT WINDOW "Retriving Data from Voucher Transaction" NOWAIT 
 sqlcmd   = "select * from FaDtrans with (nolock) where VouDate=getdate()"
 retval   = sqlexec(dataconn,sqlcmd,'Tmp')
 IF retval <= 0
	 =AERROR(errorarray)
	 MESSAGEBOX(errorarray[2])
	 RETURN 
 ENDIF

 SET DATE ANSI
 SELECT Tmp
 COPY STRUCTURE TO F:\VFPRG\TMPFADT
 USE
 USE F:\VFPRG\TMPFADT EXCLUSIVE IN 0
 ALTER TABLE TMPFADT ADD COLUMN ACNAME C(30) null
 ALTER TABLE TMPFADT ALTER COLUMN VOUDATE D
 ALTER TABLE TMPFADT ALTER COLUMN TRANSDATE D
 ALTER TABLE TMPFADT ALTER COLUMN BANKDATE D
 USE
 SET DATE BRITISH 
 USE F:\VFPRG\TMPFADT EXCLUSIVE 
 ZAP
 USE


 WAIT WINDOW "Retriving Data from Lorry Challan Payment " NOWAIT 
 sqlcmd   = "select * from FaLhpc with (nolock) where TransDate=getdate()"
 retval   = sqlexec(dataconn,sqlcmd,'Tmp')
 IF retval <= 0
	 =AERROR(errorarray)
	 MESSAGEBOX(errorarray[2])
	 RETURN 
 ENDIF

 SET DATE ANSI
 SELECT Tmp
 COPY STRUCTURE TO F:\VFPRG\TMPLHPC
 USE
 USE F:\VFPRG\TMPLHPC EXCLUSIVE IN 0
 ALTER TABLE TMPLHPC ALTER COLUMN TRANSDATE D
 ALTER TABLE TMPLHPC ALTER COLUMN ChallanDt D
 USE
 SET DATE BRITISH 
 USE F:\VFPRG\TMPLHPC EXCLUSIVE 
 ZAP
 USE

 SET DATE BRITISH 
 CLOSE DATABASES 
 MESSAGEBOX('Master Data Retrived Sucessfully !')
 WAIT clear
 CLEAR

  MasterDir="Vfprg"
  x1 ="Select BranchId,BranchCode,Acode,convert(char(30), BranchName) as BranchName,StateId,convert(char(30),Address1) as Address1 ,convert(char(30),Address2) as Address2,convert(char(30),Address3) as Address3,Phone1,Phone2,division,booking,delivery,Transit , "
  x2 =" convert(varchar(1) , ISNULL(billing,' '))  as billing   from STN where IsBranchActive='1' "
  sqlcmd = x1+x2
  IF SQLEXEC(dataconn,sqlcmd,"Tmp")>0
   SELECT Tmp
   COPY TO F:\&MasterDir\Stn
  ENDIF 
RETURN


FUNCTION ServerDate  
*--------------
SQLEXEC(dataconn,'Select  getdate() as Today',"Tmp")




*-------------- ------------------------------- ---------------------------------  -------------------------------------------------------
FUNCTION encrypt
LPARAMETERS _UserID, _Password
RETURN pps(_UserID, _Password)

FUNCTION decrypt
LPARAMETERS _UserID, _Password
RETURN pps(_UserID, _Password)

FUNCTION pps 
LPARAMETERS _UserID, _Password
#define   PWMINLEN   3		&&  /* min  number of characters in the password */
#define   PWMINNUM   1000		&&  /* min value for the password seed */
 
LOCAL lnStrLen, lnPassLen, lnPassNum, laPassword[1,2], lcPassword
LOCAL lcStrOut, lnPassPos, lnNum01, lcStrOut, lnInPos, lnPassPos
 
IF TYPE("_UserID") <> "C" ;
		OR TYPE("_Password") <> "C" ;
		OR LEN(_Password) < PWMINLEN
	=MESSAGEBOX("Invalid Password")
ENDIF
lnStrLen = LEN(_UserID)
 
* Because of the bug in the original C code we've to add CHR(0) to the password and use it later
lcPassword = _Password + CHR(0)
lnPassLen = LEN(lcPassword)
DIMENSION laPassword[lnPassLen+1,2]
FOR lnPassPos=1 TO lnPassLen
	laPassword[lnPassPos,2] = SUBSTR(lcPassword,lnPassPos,1)
	laPassword[lnPassPos,1] = ASC(laPassword[lnPassPos,2])
ENDFOR
 
* Get value
lnPassNum = INT((((ss(lcPassword)/997) - 1) % 254) + 1 )
lcStrOut = ""
lnPassPos = 1
 
* Encode/decode each character
FOR lnInPos=0 TO lnStrLen-1
	lnNum01 = (( lnPassNum + (lnInPos - lnStrLen)) - 1)
	lnPassNum = (ABS(lnNum01) % 254) * SIGN(lnNum01) + 1
	lnByte = BITXOR( ASC(SUBSTR(_UserID,lnInPos+1,1)), ;
	BITXOR(lnPassNum, laPassword[lnPassPos,1]))
	lnByte = BITAND(lnByte, 0xFF)
	lcStrOut = lcStrOut + IIF(lnByte = 0, SUBSTR(_UserID,lnInPos+1,1), CHR(lnByte))
	lnPassPos = IIF( lnPassPos => lnPassLen, 1, lnPassPos + 1)
ENDFOR
RETURN lcStrOut
 
FUNCTION ss (_UserID)
LOCAL liRet, lnPos
liRet = 1
FOR lnPos=0 TO LEN(_UserID ) - 1
	liRet = liRet + ASC(SUBSTR(_UserID,lnPos+1,1)) + lnPos
ENDFOR
DO WHILE (liRet < PWMINNUM)
	liRet = BITLSHIFT(liRet,1)
ENDDO
RETURN liRet
*-------------- ------------------------------- ---------------------------------  -------------------

**---- Export or Show Document Type 
FUNCTION DocType
PARAMETERS moptii
moptii = ALLTRIM(moptii)
DEFINE POPUP Showmenu SHORTCUT RELATIVE FROM MROW(),MCOL()
DEFINE BAR 1 OF Showmenu PROMPT moptii+" In \<Default"
DEFINE BAR 3 OF Showmenu PROMPT moptii+" In \<XLS    "
DEFINE BAR 2 OF Showmenu PROMPT moptii+" In \<PDF    "
DEFINE BAR 4 OF Showmenu PROMPT moptii+" In \<Word   "
DEFINE BAR 5 OF Showmenu PROMPT moptii+" In \<HTML   "
ACTIVATE POPUP Showmenu
IF BAR()=0
	DEACTIVATE POPUP Showmenu
    RETURN 
ENDIF 
DEACTIVATE POPUP Showmenu
mbar = BAR()

IF mabr=1
	mRptType =0
	mExtn='TXT'
ENDIF  

IF mabr=2
	mRptType =13     && 13 = XLS 
	mExtn='XLS'
ENDIF  

IF mabr=3
	mRptType =10     && 10 OR 11 = PDF
	mExtn='PDF'
ENDIF  

IF mabr=4
	mRptType =12    && 12 = RTF
	mExtn='RTF'
ENDIF  

IF mabr=5
	mRptType =14    && 14 HTML 
	mExtn='HTML' 
ENDIF  
**** RETURN mRptType,mExtn

FUNCTION GetGoodsGRId
PARAMETERS iii
sqlcmd = "select * from ViewGoodGroup  with (nolock) where GoodsId =?iii "
mGoodGrp = SQLEXEC(dataconn,sqlcmd,"GetTmpBr")
mGoodGrp = GoodGroupId
RETURN mGoodGrp

*---- GetStn
FUNCTION GetStn
PARAMETERS mAcode
mAcode = UPPER(ALLTRIM(mAcode))
PUBLIC _rAcode , _rId , _rName  , _rBilling

_rBilling=' '
IF USED('STN')
	SELECT STN 
ELSE
	USE F:\vfprg\STN IN 0 
	SELECT STN 
ENDIF 
LOCATE FOR acode == mAcode 
_rAcode  = Acode
_rId  = BranchId 
_rName = BranchName 
_rBilling = Billing


*---- GetBranchId
FUNCTION GetBranchId
PARAMETERS iii
MM = UPPER(ALLTRIM(III))
mGetBrId = SQLEXEC(dataconn,"Select * from Stn with (nolock) where acode=?iii","GetTmpBr")
mGetBrId = Branchid
RETURN mGetBrId 

*---- GetStateId
FUNCTION GetstateId
PARAMETERS iii
MM = UPPER(ALLTRIM(III))
CMD = " SELECT ISNULL(stn.StateId,0) AS  StateId,CONVERT(VARCHAR(50),STT.StateName) As DlvSt FROM STN WITH(NOLOCK) LEFT JOIN STATE STT WITH(NOLOCK) ON STT.StateId=STN.StateId WHERE ACODE =?III "
rr = SQLEXEC(dataconn,cmd,"GetTmpBr")
GetstateId = StateId
RETURN GetstateId

*---- GetBranchAcId
FUNCTION GetBranchAcId
PARAMETERS iii
MM = UPPER(ALLTRIM(III))
mGetBrAcId = SQLEXEC(dataconn,"select * from FaAcMaster  with (nolock) where AcName like ?mm+'%' and GrCode ='BS0014' ","GetTmpBr")
mGetBrAcId = AcCode
RETURN mGetBrAcId 


*---- GetBranchAccode
FUNCTION GetBranchAcode
PARAMETERS iii
MM = UPPER(ALLTRIM(III))
mGetBrAcId = SQLEXEC(dataconn,"select * from FaAcMaster  with (nolock) where AcName like ?mm+'%' and GrCode ='BS0014' ","GetTmpBr")
mGetBrAcId = AcCode
RETURN mGetBrAcId 


FUNCTION GetEmailId
PARAMETERS iii
MM = UPPER(ALLTRIM(III))
mEmailId = SQLEXEC(dataconn,"Select isnull(BranchEmailid,'') as Emailid from Stn where acode=?iii","GetTmpBr")
mEmailId = ALLTRIM(Emailid)
RETURN mEmailId

**-------------------



*---- GetDlvPty
FUNCTION GetDlvPty
PARAMETERS mgp,mcn
mGetBrId = SQLEXEC(dataconn,"select CustomerId  from GatePass with (nolock)  where GatePassNumber ='0012980005' and ConsignmentNumber = ?mcn and IsGatePassActive =1 ","GetTmpgp")
mGetptyId = CustomerId  
RETURN mGetptyId

*---- GetDlvPty
FUNCTION Cash_Credit
PARAMETERS mBrid,mcustId
mC_R = SQLEXEC(dataconn,"select upper(isnull(Cashcredit,'')) as C_R  from CashCreditControll where Branchid = ?mBrid and Customerid = ?mcustId and IsActive =1 ","GetTmpgp")
mC_R = C_R
RETURN mC_R

*---- GetDlvPty
FUNCTION GetDivision
PARAMETERS mBrid
mdiv = SQLEXEC(dataconn,"select upper(isnull(Division,'')) as Division  from stn where Branchid = ?mBrid and IsBranchActive =1 ","tt")
mdiv = ALLTRIM(Division)
RETURN mdiv

*---- GetDrTotal
FUNCTION GetFaTotal
PARAMETERS mBrid,fdt,ldt,mdrcr,maccode
x1=" Select sum(VAmount)as Amt  from FaDtrans with (nolock) where BranchId =?mBrid and "
x2=" CONVERT(DateTime,CONVERT (varchar(10),TransDate ,103),103) BETWEEN CONVERT (char(10),CONVERT(DateTime,?Fdt,103),101) "
x3=" AND CONVERT (char(10), CONVERT(DateTime,?Ldt,103),101)  and DrCr=?mDrcr  and AcCode =?maccode and IsActive = 1 "
sqlcmd = x1+x2+x3
Rtval = SQLEXEC(dataconn,sqlcmd,"tt")
mFaTotal = Amt
RETURN mFaTotal





PROCEDURE Download
*-- Opens the Browser for Direct DownLoad    
loIE = NEWOBJECT("InternetExplorer.Application")
loIE.Navigate("www.matagroup.in/mataonline.zip")
loIE.Visible = .T.

MESSAGEBOX("         << Plz. Note It. >>  " + CHR(13) + CHR(13)+ ;
 		   "Step : 1.  Files Save on Desktop  " +chr(13) +; 
		   "           2. Unzip on Desktop  " +CHR(13) +; 
		   "           3. Mataonline.exe Copy to F:\Vfprg\ " +CHR(13) +; 
		   "           4. File Mataonline.exe remove from Desktop " +CHR(13) +; 
		   "           5. Close all Window and Re-Login   " )  


FUNCTION UrlOpen
LPARAMETERS pcURL 
**DO gotoURL WITH "http://www.matagroup.in/pdfs/Userguide.pdf"    && CALL AS IN SIDE 
LOCAL loHyperlink
m.loHyperlink = CREATEOBJECT("Hyperlink")   && opens users browser
IF VARTYPE(loHyperlink) = "O" then
    m.loHyperlink.navigateto(pcURL)          && go to the url
ELSE
    MESSAGEBOX("Web browser application not found!",32, "Some caption")
ENDIF
m.loHyperlink = Null
RETURN


FUNCTION GetNotice
	Sqlcmd = "Select * from Notice "
	SQLEXEC(dataconn,sqlcmd,"Tmp")
	SELECT Tmp
	IF LEN(ALLTRIM((Message)))>0
		*@32,25 SAY 'Notice : - ' font "Times New Roman", 20 style 'TN' color R+
		*@32,43 say Message  font "Times New Roman", 20 style 'B' 
    	=MESSAGEBOX("Notice : - "+ Message,48 , "Notice")
	 ENDIF 
	
	

FUNCTION GetStaxRate
PARAMETERS Mdt 
SQLCMD  = "[dbo].[USP_GetServiceTaxRate] ?mdt "
IF SQLEXEC (dataconn,SQLCMD,"TEMP") > 0
	IF RECCOUNT() > 0
		_mstaxRt = VAL(TEMP.ServiceTaxRate)
	ELSE
		WAIT WINDOW("S.Tax Rate NOT Found. ") NOWAIT
	ENDIF	
ENDIF
RETURN _mstaxRt 


	
PROCEDURE CMD1
sqlcmd=x1+x2+x3+x4
rtval = SQLEXEC(dataconn,sqlcmd,'TmpFa')
IF rtval<0
	=AERROR(errorarray)
	 MESSAGEBOX(errorarray[2])	  
	 WAIT WINDOW "Retrival Eeeor " NOWAIT 	    
ELSE

ENDIF 



FUNCTION WebDoc
LPARAMETERS pcURL 
LOCAL loHyperlink
m.loHyperlink = CREATEOBJECT("Hyperlink")   && opens users browser
IF VARTYPE(loHyperlink) = "O" then
    m.loHyperlink.navigateto(pcURL)          && go to the url
ELSE
    MESSAGEBOX("Web browser application not found!",32, "Some caption")
ENDIF
m.loHyperlink = Null
RETURN



*---- GetNewAcID
FUNCTION GetNewAcID
PARAMETERS iii
MM = UPPER(ALLTRIM(III))
GetNewAcID = SQLEXEC(dataconn,"Select * from FaAcMaster where OldCode =?iii","GetTmpBr")
GetNewAcID = AcCode
RETURN GetNewAcID

 

PROCEDURE Error
PARAMETER merror, mess, mess1, mprog, mlineno
 nAnswer =  messagebox(  'Error Number         :-      ' + LTRIM(STR(merror)) +  CHR(13) +;
			    'Error Message        :-      ' + mess  + CHR(13) + ;
			    'Error in Line No     :-      ' + LTRIM(STR(mlineno)) + CHR(13) +; 
			    'Program Name     :-      ' + mprog  , 2 , ' Error '  )

IF merror=1466
	=connect2Sql()
ENDIF 

IF nAnswer = 3  && Abort
   Thisform.release()
ENDIF 

IF nAnswer = 4
	IF merror=1466
	   =connect2Sql()
	ENDIF 
	RETURN 0 
ENDIF 

IF nAnswer = 5
   Thisform.release() 
ENDIF 




FUNCTION GetDrvObCB
PARAMETERS mBr,mBRID,Mlrid,Mlr,LLdt,MobCb 
	*-- GetDrvObCB('FRL',1078,374,'HR55M7810',MDT,'OB')
x1="select *  from Fleetcontrol where controllingbr=?mBr "
rtval = SQLEXEC(dataconn,x1,'x')

SELECT X
mStartDate = ALLTRIM(StartDate)
a = ALLTRIM(StartDate)
msdt=CTOD( right(a,2)+'/'+SUBSTR(a,6,2)+'/'+left(a,4) )

IF MobCb='OB'
	LLdt = LLdt-1
	MSDT = MSDT-1
ELSE
	LLdt = LLdt
ENDIF 

x1=" SELECT ISNULL((driverdr-DriverCr),0) AS Bal1  FROM TripSummary WITH(NOLOCK) WHERE TruckId = ?mbrid  AND ControllingBranchId=?mlrId "
x2=" AND FaBookDate BETWEEN ?msdt AND ?LLdt "
x3=" SELECT CASE WHEN DrCr = 'D' THEN VAmount ELSE 0 END AS Dr,CASE WHEN DrCr = 'C' THEN VAmount ELSE 0 END AS Cr "
x4=" FROM FaVoucher WITH(NOLOCK)WHERE AcCode= '005712'AND BranchId=?mbr AND TransDate BETWEEN ?msdt AND ?LLdt AND LorryNo=?mlr "
sqlcmd= x1+x2+x3+x4
rtval = SQLEXEC(dataconn,sqlcmd,'x')
SELECT x
mbal1 = bal1
SELECT x1
SUM Dr-cr TO mbal2 
mDrvOpbal = mBal1+mbal2
RETURN mBal1+mbal2
 
 
 
 
FUNCTION Getdoordlvamt
PARAMETERS mcn
Sqlcmd=" SELECT isnull( SUM(DdlvAmount ), 0)  as DoorDlvamt  FROM FaDoorDlv  WITH (NOLOCK) WHERE CnmtNo =?mcn  and IsActive =1 "
rtval = SQLEXEC(Dataconn,Sqlcmd,'x')
RETURN DoorDlvamt 


PROCEDURE IpMacDisp
lcComputer		= [.]
loWMIService	= GETOBJECT( [winmgmts:\\] + lcComputer + [\root\cimv2] )
loIPConfigSet	= loWMIService.ExecQuery( [Select IPAddress from Win32_NetworkAdapterConfiguration Where IPEnabled = True] )
FOR EACH loIPConfig IN loIPConfigSet
	IF !ISNULL( loIPConfig.IPAddress )
		=MESSAGEBOX(" [IP Address is  : ] " + loIPConfig.IPAddress( 0 ) +CHR(13) ;
		 + " [Mac address is : ] " + MacAddress( loIPConfig.IPAddress( 0 ) ) , 48 )
		 mMacid= MacAddress( loIPConfig.IPAddress( 0 ) ) 
	ENDIF 
ENDFOR 


PROCEDURE MacIdStore 
lcComputer		= [.]
loWMIService	= GETOBJECT( [winmgmts:\\] + lcComputer + [\root\cimv2] )
loIPConfigSet	= loWMIService.ExecQuery( [Select IPAddress from Win32_NetworkAdapterConfiguration Where IPEnabled = True] )
FOR EACH loIPConfig IN loIPConfigSet
	IF !ISNULL( loIPConfig.IPAddress )
		 ** =MESSAGEBOX(" [IP Address is  : ] " + loIPConfig.IPAddress( 0 ) +CHR(13) ;
		 ** + " [Mac address is : ] " + MacAddress( loIPConfig.IPAddress( 0 ) ) , 48 )
		 mMacid= MacAddress( loIPConfig.IPAddress( 0 ) ) 
	ENDIF 
ENDFOR 



FUNCTION MacAddress
LPARAMETERS vIP
        DECLARE INTEGER inet_addr IN ws2_32.dll STRING cIP
        DECLARE INTEGER SendARP IN iphlpapi.dll;
                INTEGER destIP, INTEGER sourceIP,;
                STRING @ pMacAddr, INTEGER @ PhyAddrLen
        LOCAL lnHr, lnIpAddr, lcMacAddr, lnLen
        lnIpAddr	= inet_addr( vIP )
        lcMacAddr	= REPLICATE( CHR( 0 ) , 6 )
        lnLen		= 6
        lnHr		= SendARP( lnIpAddr , 0 , @lcMacAddr , @lnLen )
        RETURN BinaryToMac( lcMacAddr , lnLen )
ENDFUNC

FUNCTION BinaryToMac
LPARAMETERS vMacAddr , vLen
	LOCAL lcMac, xj
	lcMac = []
	FOR xj = 1 TO vLen - 1
		lcMac = lcMac + RIGHT( TRANSFORM( ASC( SUBSTR( vMacAddr , xj , 1 ) ) , [@0] ) , 2 ) + [:]
	ENDFOR
	lcMac = lcMac + RIGHT( TRANSFORM( ASC( SUBSTR( vMacAddr , vLen , 1 ) ) , [@0] ) , 2 )
	RETURN lcMac	
ENDFUNC




PROCEDURE cpuId
*!* Let's get the CPU ID
LOCAL lcComputerName, loWMI, lowmiWin32Objects, lowmiWin32Object
lcComputerName = GETWORDNUM(SYS(0),1)
loWMI = GETOBJECT("WinMgmts://" + lcComputerName)
lowmiWin32Objects = loWMI.InstancesOf("Win32_Processor")
FOR EACH lowmiWin32Object IN lowmiWin32Objects
    WITH lowmiWin32Object
        **? "ProcessorId: " + TRANSFORM(.ProcessorId)
         mCpuId=TRANSFORM(.ProcessorId)
    ENDWITH
ENDFOR



PROCEDURE vsrl
*!* Let's get the Volume Serial Number(s)
LOCAL lcComputerName, loWMIService, loItems, loItem, lcVolumeSerial
lcComputerName = "."
loWMIService = GETOBJECT("winmgmts:\\" + lcComputerName + "\root\cimv2")
loItems = loWMIService.ExecQuery("Select * from Win32_LogicalDisk")
FOR EACH loItem IN loItems
    lcVolumeSerial = loItem.VolumeSerialNumber
    IF !ISNULL(lcVolumeSerial)
        ? "Name: " + loItem.NAME
        ? "Volume Serial Number: " + loItem.VolumeSerialNumber
        ?
    ENDIF
ENDFOR


PROCEDURE email 
*Basic #DEFINE
#DEFINE olFolderCalendar 9
#DEFINE olFolderContacts 10
#DEFINE olFolderDeletedItems 3
#DEFINE olFolderInBox 6
#DEFINE olFolderJournal 11
#DEFINE olFolderNotes 12
#DEFINE olFolderOutBox 4
#DEFINE olFolderSentMail 5
#DEFINE olFolderTask 13
#DEFINE olBusy 2
#DEFINE True .T.
#DEFINE False .F.
#DEFINE olPrivate 2
#DEFINE MAILITEM 0
#DEFINE IMPORTANCELOW 0
#DEFINE IMPORTANCENORMAL 1
#DEFINE IMPORTANCEHIGH 2

PROCEDURE sendemail1
*Send an e-mail without attachment
*CODE
oOutLookObject = CreateObject('Outlook.Application')
oEmailItem = oOutLookObject.CreateItem(MAILITEM)

WITH oEmailItem
   .Recipients.Add('subodh@matagroup.in') && uses the Recipients collection
   .Subject = 'Automation sample'
   .Importance = IMPORTANCENORMAL
   .Body = 'Hi Suman !'
   .Send
ENDWITH

RELEASE oEmailItem
RELEASE oOutLookObject


PROCEDURE sendemail2
PARAMETERS mFile
*Send an e-mail with attachment
*CODE
IF EMPTY(mFile)
	ss = ALLTRIM(GETFILE())
ELSE 
	ss=ALLTRIM(mFile)
ENDIF 
oOutLookObject = CreateObject('Outlook.Application')
oEmailItem = oOutLookObject.CreateItem(MAILITEM)

WITH oEmailItem
   .Recipients.Add('subodh@matagroup.in') && uses the Recipients collection
   .Subject = 'Automation sample'
   .Importance = IMPORTANCENORMAL
   .Body = 'attachment '
   .Attachments.Add('&ss') && Note that the fully qualified path and file is required.
*   .Attachments.Add('f:\mata\led.txt') && Note that the fully qualified path and file is required.
   .Send
ENDWITH
RELEASE oEmailItem
RELEASE oOutLookObject

PROCEDURE saveAttachment
Note this is also found in FAQ184-2838
*Retrieve attachements for all e-mail in the inbox
*CODE
Local lcFilename,lcPath
lcPath='c:\savedattachments\'
If  !Directory('c:\savedAttachments')
    Md 'c:\savedAttachments' && Create the directory if it doesn't exist.
Endif
oOutLookObject = Createobject('Outlook.Application')
olNameSpace = oOutLookObject.GetNameSpace('MAPI')
myAtts=olNameSpace.GetDefaultFolder(olFolderInbox).Items
For Each loItem In myAtts
    If loItem.attachments.Count >0 && Make sure there is an actual attachment.
        For i = 1 To loItem.attachments.Count
            lcFilename=' A.txt '
            lcFilename = loItem.attachments.Item(i).filename
            lcFilename = Alltrim(lcPath)+lcFilename
            loItem.attachments.Item(i).SaveAsFile(lcFilename)
           *loItem.Delete() && The option to delete the message once the attachment has been saved.
        Next
    Endif
Next





PROCEDURE Baackup
CLOSE DATABASES 
CLOSE INDEXES 
lcPath='F:\Backup\'+DTOS(mtoday)+'\'+SYS(2)
If  !Directory('&lcPath')
    Md '&lcpath' && Create the directory if it doesn't exist.
ENDIF
lcPath=lcpath+'\.'
!copy f:\mata\*.S* &lcPath
!copy f:\mata\*.F* &lcPath
!copy f:\mata\*.P* &lcPath
=MESSAGEBOX(" -Backup Successfully Done- "  )


*--- For Current Drive + File Name 
* mFile= SYS(5)+SYS(2003)+'\Chenq.pdf'


FUNCTION PingChk
*--------- Mukesh 
*Ping check of public ip AirTel/AirCel
RESTORE FROM c:\windows\mrtcv1.xps ADDITIVE 
DECLARE INTEGER GetRTTAndHopCount IN Iphlpapi;
		INTEGER DestIpAddress, LONG @HopCount,;
		INTEGER MaxHops, LONG @RTT
	DECLARE INTEGER inet_addr IN ws2_32 STRING cp
	LOCAL nDst, nHop, nRTT,nAirtel
	nAirtel = inet_addr('182.71.172.69') && Airtel
	nDst = inet_addr('27.251.4.147')     && AirCel
	STORE 0 TO nHop, nRTT
IF GetRTTAndHopCount(nDst, @nHop, 50, @nRTT) <> 0
   Hoconn = &AirCelConn
   Dataconn = &AirCelConn
ELSE
   IF GetRTTAndHopCount(nAirtel, @nHop, 50, @nRTT) <> 0
	  Hsconn = &AirTelConn
	  Dataconn = &AirTelConn
	ELSE
	  WAIT WINDOW " Not Connected To HO Server " 
	  RETURN 0 
	ENDIF
ENDIF
*------------------

FUNCTION LastVTno   && New ENtry System Only
** LastVTno('CAL','000492')
PARAMETERS mbrcd,mbookcode
SELECT 0 
sqlcmd =" Select Isnull(MAX(VNUMBER),0) AS Lasvnum from VTrans with (nolock)  where branchid=?mbrcd and bookcode=?mbookcode "
rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx 
mLasvnum=Lasvnum
use
RETURN mLasvnum



FUNCTION LastVno
** LastVno('CAL','000492','30/09/2013')
PARAMETERS mbrcd,mbookcode,mdt
** Mdt is Date Fotrmate 
SELECT 0 
sqlcmd =" Select Isnull(MAX(VNUMBER),0) AS Lasvnum from FaDtrans with (nolock)  where branchid=?mbrcd and bookcode=?mbookcode and convert(varchar(11),transdate,103)=CONVERT( VARCHAR,?mdt,103) "
rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx 
mLasvnum=Lasvnum
use
RETURN mLasvnum

FUNCTION LastVno2
** LastVno2('CAL','000492','30/09/2013')
PARAMETERS mbrcd,mbookcode,mdt
** Mdt is Date Fotrmate 
SELECT 0 
sqlcmd =" Select Isnull(MAX(VNUMBER),0) AS Lasvnum from FaVoucher with (nolock)  where branchid=?mbrcd and bookcode=?mbookcode and convert(varchar(11),transdate,103)=CONVERT( VARCHAR,?mdt,103) "
rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx 
mLasvnum=Lasvnum
use
RETURN mLasvnum
**********************************************************
FUNCTION LastVnoMata4
** LastVnoMata4('CAL','30/09/2013')
PARAMETERS mbrcd,mdt
** Mdt is Date Fotrmate 
SELECT 0 
sqlcmd =" Select Isnull(MAX(RefNumber),0) AS Lasvnum from MATA4 with (nolock)  where BranchId=?mbrcd  "
rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx 
mLastVnoMata4=Lasvnum
use
RETURN mLastVnoMata4
****************************************************************** LastVnoMata4
FUNCTION LastFundTftRefNo
PARAMETERS mInfoStn
SELECT 0
Cmd = " SELECT ISNULL(MAX(TFTRefNo),0) As LastRefNo FROM FundTft WHERE InfoStn =?mInfoStn "
rtval=SQLEXEC(dataconn,Cmd,'Tx')
SELECT Tx 
mLastFundTftRefNo = LastRefNo
use
RETURN mastFundTftRefNo

*******************************************************************
FUNCTION FaDtChk()
 ** FaDtChk('ABL','000492','30/09/2012')
PARAMETERS mbrcd,mbookcode,mdt
SELECT 0
sqlcmd=" select * from FaMtrans WITH (NOLOCK)  where BookCode =?mbookcode and BranchId=?mbrcd and EndDate=?mdt "
rtval=SQLEXEC(dataconn,sqlcmd,'Tx')

SELECT Tx 
rec= RECCOUNT()
USE 
IF rec>0
	RETURN .T.
ELSE 
	RETURN .F.
ENDIF 



FUNCTION GetFaBrAcCode( )
*GetFaBrAcCode( ALLTRIM(Thisform.drbcd.Value) )
*GetFaBrAcCode( 'ADB' )
PARAMETERS mbcd
SELECT 0 
sqlcmd=" select AcCode  from  FaAcMaster where GrCode='BS0014' and AcName like ?mbcd+'%'  "
rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx
mac = Accode
use
RETURN mac 




FUNCTION GetGp()
PARAMETERS mGPNO,mFld
SELECT 0 
sqlcmd=" SELECT *  FROM GATEPASS  WHERE GatepassNumber=?mGPNO  WITH (NOLOCK)  "
rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx
Mgpinf = &mFld 
USE
RETURN Mgpinf


FUNCTION GetCN()
PARAMETERS mCNNO,mFld
SELECT 0 
X1=" SELECT *  FROM Consignment   WHERE ConsignmentNumber = ?mCNNO WITH (NOLOCK)  "
X2=" UNION ALL  "
X3=" SELECT *  FROM [TMS_HK1.0].DBO.Consignment   WHERE ConsignmentNumber =?mCNNO  WITH (NOLOCK)  "
sqlcmd=X1+X2+X3
rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx
mcninf = &mFld
USE
RETURN mcninf


FUNCTION GetFaDrcrTot()
PARAMETERS mbrid , mbookcode , mdrcr , mtransdate 
*---- only Cash Book 
sqlcmd = " select ISNULL( SUM(VAmount),0) AS Totamt from FaDtrans with (nolock)  where BookCode=?mbookcode and DrCr=?mdrcr and TransDate =?mtransdate  and BranchId=?mbrid  and IsActive=1 "
Rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx
mTotAmt = Totamt
USE
RETURN mTotAmt



FUNCTION Gplock()
Sqlcmd="Select convert(varchar(11),Gp_lock,103) as GpLock from LockEntry with (Nolock) "
Rtval=SQLEXEC(dataconn,sqlcmd,'Tx')
SELECT Tx
mLock = GpLock
RETURN mLock


PROCEDURE Export_xls
		&& DO Export_xls WITH 'tmp_rpt' 
PARAMETERS Mfile
	IF USED('&Mfile')
		SELECT &Mfile
		ELSE 
	    USE &Mfile
	ENDIF 
	lcConnectionString= "OLEDB;Provider=VFPOLEDB;Data Source="+Sys(5)+Curdir()
	Wait Window Nowait "Please wait sending data to Excel..."
	lnTotal = Reccount()
	Use
	oExcel = Createobject("Excel.application")
	With oExcel
	 .Visible = .T.
	 oMasterWorkBook = .workbooks.Add && Add a new workbook
	 lnMaxRows = .ActiveWorkBook.ActiveSheet.Rows.Count && Get max row count from excel  instead of using hardcoded 65536
	 lnNeededSheets = Ceiling( m.lnTotal / (m.lnMaxRows - 1) ) && 1 row header

	 lnCurrentSheetCount = .sheets.Count
	 If m.lnNeededSheets > m.lnCurrentSheetCount
	  .sheets.Add(,.sheets(m.lnCurrentSheetCount),;
	   m.lnNeededSheets - m.lnCurrentSheetCount) && Add new sheets after old ones
	 Endif
	Endwith
	With oMasterWorkBook
	 For ix = 1 To m.lnNeededSheets
	  .sheets.Item(m.ix).Name = "Page "+Padl(ix,3,"0")
	 Endfor

	 For ix = 1 To m.lnNeededSheets
	  lnStart = ( m.ix - 1 ) * (m.lnMaxRows-1) + 1
	  lcSelect = "SELECT * FROM &Mfile where recno() between "+trans(m.lnStart)+" and "+Trans(m.lnStart+m.lnMaxRows-2)
	  With .WorkSheets(m.ix).QueryTables.Add( m.lcConnectionString,.WorkSheets(m.ix).Range("A1"),m.lcSelect)
	   .FieldNames = .T.
	   .RowNumbers = .F.
	   .FillAdjacentFormulas = .F.
	   .PreserveFormatting = .T.
	   .RefreshOnFileOpen = .F.
	   .BackgroundQuery = .T.
	   .SaveData = .T.
	   .AdjustColumnWidth = .T.
	   .RefreshPeriod = 0
	   .PreserveColumnInfo = .T.
	   .Refresh(.F.)

	  Endwith
	 Endfor
	 .WorkSheets(1).Activate
	Endwith
	Wait Clear
*-------------------------------------------------------------------------------



PROCEDURE ScreenDesplay
   ** DO ScreenDesplay WITH 'Expenses With Costing ' ,10,20 , 30, 150
PARAMETERS Parent, mstartR,mstartC,mrw,mcol 
DEFINE WINDOW wParent    FROM mstartR, mstartC TO mrw, mcol    TITLE "&Parent"  
ACTIVATE WINDOW wParent 

*!*	ACTIVATE SCREEN
*!*	WAIT WINDOW 'Press a key to clear the windows'
*!*	RELEASE WINDOW wParent, wChild
*!*	CLEAR




PROCEDURE DataInsertInEmailTable
  * PUBLIC mEmailFromId ,mEmailToId ,mEmailccId ,mEmailBccId ,mEmailSubject ,mEmailMsg ,mEmailType ,mEmailattachment
  * Public Call and Value Put in Variable 
  * do DataInsertInEmailTable in Library 
		*!*	mEmailFromId = 'subodh@matagroup.in'
		*!*	mEmailToId   = 'sumankumarbsws2@gmail.com' 
		*!*	mEmailccId   =  Null  
		*!*	mEmailBccId  = Null 
		*!*	mEmailSubject     = 'Subject : - Test ' 
		*!*	mEmailMsg         = 'Test Msg....................................................................................... ' 
		*!*	mEmailType =' Normal '
		*!*	mEmailattachment = null 
	Sqlcmd = " Insert into Email values ( newid() , ?mEmailFromId , ?mEmailToId , ?mEmailccId ,?mEmailBccId , ?mEmailSubject , ?mEmailMsg  , 1 , 0 , 0 , null , null , Getdate() , ?mUname, ?mEmailType, ?mEmailattachment ) "
	rtval  = SQLEXEC(Dataconn,sqlcmd)
	IF rtval<0
		=AERROR(errorarray)
		 MESSAGEBOX(errorarray[2])	  
		 =MESSAGEBOX('Error in Insert Msg in Main Table ')
		 RETURN 
	ELSE
		  WAIT WINDOW 'Insert in Email Table ' NOWAIT 
	ENDIF 



FUNCTION GetBr
PARAMETERS mString
x1=" select  BranchId , Acode , BranchName  from STN with (nolock) where "
x2=" BranchName like  ?mString+'%' or "
x3=" Acode like ?mString+'%'  "
sqlcmd=X1+X2+X3
rtval=SQLEXEC(dataconn,sqlcmd,'Tmp')
IF rtval>0
	DO ScreenDesplay WITH 'Branch Information ' ,10,20 , 30, 150
	BROWSE 
	ACTIVATE SCREEN
	RELEASE WINDOW wParent, wChild
	CLEAR
ENDIF 



FUNCTION GetNicName
PARAMETERS mGrcode
x1=" select  ISNULL(NickName,'') As NickName from FaGrMaster with (nolock) where "
x2=" Grcode = ?mGrcode  "
sqlcmd=X1+X2
rtval=SQLEXEC(dataconn,sqlcmd,'Tmp')
IF rtval>0
	SELECT Tmp
	mNicName = NickName
	USE
	RETURN mNicName
ENDIF 


FUNCTION GetGrcode
PARAMETERS mAcCode
sqlcmd=" Select isnull(Grcode,' ') as Grcode  from FaAcMaster with (nolock) where AcCode =?mAcCode  "
rtval=SQLEXEC(dataconn,sqlcmd,'Tmp')
IF rtval>0
	SELECT Tmp
	mGrcode = Grcode
	USE
	RETURN mGrcode
ENDIF 




FUNCTION GetChBalance
PARAMETERS mch 
mChallan = mch 
mch = RIGHT('0000000000'+ALLTRIM(mch),10)
A1 = " SELECT CH.ChallanNumber,CONVERT(VARCHAR(11),CH.ChallantDate,103)AS ChallantDate,FBR.BranchName AS CHFrom,TBR.BranchName AS ToBr,CH.PackageCount,ISNULL(CH.UnLoadingExtraCharges,0)AS UnLoadingExtraCharges, "
A2 = " CH.ActualWeight,CH.ChargeWeight,CH.Freight,CH.LessAdvance,CH.OtherCharges,ISNULL(CH.LessTDS1,0)AS LessTDS1,CH.LessDiscount,CH.Height,ISNULL(CH.ExtraWeightCharge,0)AS ExtraWeightCharge, "
A3 = " CH.LessTDS2,ISNULL(CH.DetentionCharge,0)AS DetentionCharge,TR.TruckNumber,ISNULL(TRN.TransporterName,'')AS TransporterName,ISNULL(TRN.OwnerName,'')AS OwnerName,TRN.PanNumber,ISNULL(FAL.BranchId,'')AS BranchId, "
A4 = " ISNULL(FAL.ChallanNo,'') AS ChallanNo, ISNULL(FAL.LhpcShtNo,'')AS LhpcShtNo,ISNULL(CONVERT(VARCHAR(11),FAL.TransDate,103),'')AS TransDate,ISNULL(CH.ModifiedBy,'') AS MODBY, "
A5 = " ISNULL(FAL.LhpcAmt,0)AS LhpcAmt,ISNULL(FAL.LhpcDis,0) AS LhpcDis,ISNULL(FAL.PartFinal,'') AS PartFinal,ISNULL(CH.ExtraCharge,0)AS ExtraCharge,ISNULL(CONVERT(VARCHAR(11),CH.CreatedDate,103),'') AS CRTDT, "
A6 = " ((ISNULL(CH.Freight,0)+ISNULL(CH.OtherCharges,0)+ISNULL(CH.ExtraCharge,0)+ISNULL(CH.UnLoadingExtraCharges,0))-(ISNULL(CH.LessAdvance,0)+ISNULL(CH.LessTDS1,0)+ISNULL(CH.LessDiscount,0)))AS BalanceAmt, "
A7 = " ((ISNULL(CH.Freight,0)+ISNULL(CH.OtherCharges,0)+ISNULL(CH.ExtraCharge,0)+ISNULL(CH.UnLoadingExtraCharges,0)+ISNULL(CH.Height,0)+ISNULL(CH.ExtraWeightCharge,0)+ISNULL(CH.DetentionCharge,0))-  "
A8 = " (ISNULL(CH.LessAdvance,0)+ISNULL(CH.LessTDS1,0)+ISNULL(CH.LessDiscount,0)+ISNULL(CH.LessTDS2,0)))AS NetPayable ,ISNULL(CH.GuaranteedWeight,0) AS GWEG, "
A9 = " ((ISNULL(CH.Freight,0)+ISNULL(CH.OtherCharges,0)+ISNULL(CH.ExtraCharge,0)+ISNULL(CH.UnLoadingExtraCharges,0)+ISNULL(CH.Height,0)+ISNULL(CH.ExtraWeightCharge,0)+ISNULL(CH.DetentionCharge,0)) ) as TotFrt,'T' as flag,ISNULL(CH.CreatedBy,'')AS CRTBY, "
AA9 = " CASE WHEN CH.IsChallanActive = 1 THEN 'O.K' ELSE 'C A N C E L' END AS CHLSTAT,ISNULL(FAL.BookType,'') As BookType "
A10 = " FROM Challan CH WITH(NOLOCK)INNER JOIN Branch FBR WITH(NOLOCK)ON FBR.BranchId = CH.FromBranchId INNER JOIN "
A11 = " Branch TBR WITH(NOLOCK)ON TBR.BranchId = CH.ToBranchId INNER JOIN Truck TR WITH(NOLOCK) ON TR.TruckId = CH.TruckId LEFT OUTER JOIN TruckTransporter TT "
A12 = " WITH(NOLOCK)ON TT.TruckId = TR.TruckId LEFT OUTER JOIN Transporter TRN WITH(NOLOCK)ON TRN.TransporterId = TT.TransporterId "
A13 = " LEFT OUTER JOIN FaLhpc FAL WITH(NOLOCK) ON FAL.ChallanNo = CH.ChallanNumber  "
A14 = " WHERE CH.ChallanNumber =?mChallan    "
A15 = " UNION "
A16 = " SELECT CH.ChallanNumber,CONVERT(VARCHAR(11),CH.ChallantDate,103)AS ChallantDate,FBR.BranchName AS CHFrom,TBR.BranchName AS ToBr,CH.PackageCount,ISNULL(CH.UnLoadingExtraCharges,0)AS UnLoadingExtraCharges, "
A17 = " CH.ActualWeight,CH.ChargeWeight,CH.Freight,CH.LessAdvance,CH.OtherCharges,ISNULL(CH.LessTDS1,0)AS LessTDS1,CH.LessDiscount,CH.Height,ISNULL(CH.ExtraWeightCharge,0)AS ExtraWeightCharge, "
A18 = " CH.LessTDS2,ISNULL(CH.DetentionCharge,0)AS DetentionCharge,TR.TruckNumber,ISNULL(TRN.TransporterName,'')AS TransporterName,ISNULL(TRN.OwnerName,'')AS OwnerName,TRN.PanNumber,ISNULL(FAlL.BranchId,'')AS BranchId, "
A19 = " ISNULL(FAlL.ChallanNo,'') AS ChallanNo, ISNULL(FAlL.LhpcShtNo,'')AS LhpcShtNo,ISNULL(CONVERT(VARCHAR(11),FAlL.TransDate,103),'')AS TransDate,ISNULL(CH.ModifiedBy,'') AS MODBY, "
A20 = " ISNULL(FAlL.LhpcAmt,0)AS LhpcAmt,ISNULL(FALl.LhpcDis,0) AS LhpcDis,ISNULL(FALl.PartFinal,'') AS PartFinal,ISNULL(CH.ExtraCharge,0)AS ExtraCharge,ISNULL(CONVERT(VARCHAR(11),CH.CreatedDate,103),'') AS CRTDT, "
A21 = " ((ISNULL(CH.Freight,0)+ISNULL(CH.OtherCharges,0)+ISNULL(CH.ExtraCharge,0)+ISNULL(CH.UnLoadingExtraCharges,0))-(ISNULL(CH.LessAdvance,0)+ISNULL(CH.LessTDS1,0)+ISNULL(CH.LessDiscount,0)))AS BalanceAmt, "
A22 = " ((ISNULL(CH.Freight,0)+ISNULL(CH.OtherCharges,0)+ISNULL(CH.ExtraCharge,0)+ISNULL(CH.UnLoadingExtraCharges,0)+ISNULL(CH.Height,0)+ISNULL(CH.ExtraWeightCharge,0)+ISNULL(CH.DetentionCharge,0))-  "
A23 = " (ISNULL(CH.LessAdvance,0)+ISNULL(CH.LessTDS1,0)+ISNULL(CH.LessDiscount,0)+ISNULL(CH.LessTDS2,0)))AS NetPayable ,ISNULL(CH.GuaranteedWeight,0) AS GWEG, "
A24 = " ((ISNULL(CH.Freight,0)+ISNULL(CH.OtherCharges,0)+ISNULL(CH.ExtraCharge,0)+ISNULL(CH.UnLoadingExtraCharges,0)+ISNULL(CH.Height,0)+ISNULL(CH.ExtraWeightCharge,0)+ISNULL(CH.DetentionCharge,0)) ) as TotFrt,'L' as flag,ISNULL(CH.CreatedBy,'')AS CRTBY, "
AA24 = " CASE WHEN CH.IsChallanActive = 1 THEN 'O.K' ELSE 'C A N C E L' END AS CHLSTAT,ISNULL(FALL.BookType,'') As BookType "
A25 = " FROM Challan CH WITH(NOLOCK)INNER JOIN Branch FBR WITH(NOLOCK)ON FBR.BranchId = CH.FromBranchId INNER JOIN "
A26 = " Branch TBR WITH(NOLOCK)ON TBR.BranchId = CH.ToBranchId INNER JOIN Truck TR WITH(NOLOCK) ON TR.TruckId = CH.TruckId LEFT OUTER JOIN TruckTransporter TT "
A27 = " WITH(NOLOCK)ON TT.TruckId = TR.TruckId LEFT OUTER JOIN Transporter TRN WITH(NOLOCK)ON TRN.TransporterId = TT.TransporterId "
A28 = " LEFT OUTER JOIN FaLlhpc FALL WITH(NOLOCK) ON FALL.ChallanNo = CH.ChallanNumber  "
A29 = " WHERE CH.ChallanNumber =?mChallan   "

SQLCMD = A1 + A2 + A3 + A4 + A5 + A6 + A7 + A8 + A9+AA9+A10+A11 + A12 +a13+a14+A15+A16+A17+A18+A19+A20+A21+A22+A23+A24+AA24+A25+A26+A27+A28+A29

X = SQLEXEC(dataconn,SQLCMD,"TEMP")
IF X =< 0
	=AERROR(errorarray)
	MESSAGEBOX(errorarray[2])
	WAIT WINDOW "Error Occured . " NOWAIT
	RETURN
ENDIF
IF X > 0
	SELECT TEMP
ELSE
	=MESSAGEBOX("Retrival Error. ")
	RETURN 0
ENDIF

sum LhpcAmt to  xx
GO top
Mdues = (totFrt )- xx 
RETURN Mdues


** WebConn=SQLSTRINGCONNECT("Driver=SQL SERVER;SERVER=103.16.141.138,1433;Database=TranSOFTMata;UID=matasql;pwd=mata@123")
* viewconsignment
* viewgatepassvfp
