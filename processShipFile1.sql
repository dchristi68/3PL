USE [custom]
GO
/****** Object:  StoredProcedure [dbo].[processShipFile1]    Script Date: 9/11/2015 10:50:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[processShipFile1] 
@file	varchar(500),
@debug	int = 0
as

declare	@cmd				varchar(500),
		@rcnt				int,
		@maxPacknum			int,
		@FirstshipDate		date,
		@ShipmentID			varchar(50),
		@carrierRefNo		varchar(50),
		@WorkOrderNo		varchar(50),
		@OrderDate			date, 
		@lineNumber			int, 
		@PartNum			varchar(50),
		@PartDescription	varchar(255),
		@SysRevID			varchar(50),
		@TotalUnits			numeric(20,2),
		@TFLineNum			varchar(14) --DLC - fix incorrect TFLineNum

if @debug > 0 select @file '@file'

truncate table inputShip
set @cmd = 'bulk insert inputShip from ''' + @file + ''' with (FIRSTROW = 2, FIELDTERMINATOR = '','')'
if @debug > 0 select @cmd '@cmd'
exec(@cmd)
if @@error <> 0
begin
	select 'Error during file BCP'
	return -1
end	
if @debug > 0 select 'inputShip', * from inputShip

insert	ShipLog(
		ShipmentID, WorkOrderNo, OutboundPO, SKUItem, LineNumber,	
		TotalUnits, ShipDate, ShipTime, ReceiptPO, CarrierRefNo,
		Consignee )
select	ShipmentID, WorkOrderNo, OutboundPO, SKUItem, LineNumber,	
		TotalUnits, ShipDate, ShipTime, ReceiptPO, CarrierRefNo,
		Consignee 
from	inputShip			
set @rcnt = @@rowcount if @debug > 0 select  @rcnt 'insert ShipLog' 

set @SysRevID = convert(int, RIGHT(CAST(YEAR(getdate()) AS CHAR(4)),2) + RIGHT('000' + CAST(DATEPART(dy, getdate()) AS varchar(3)),3) + '0000') 
select	@maxPacknum = max(Packnum) + 1 
from	epicor905..TFShipHead

select	@FirstshipDate = min(ShipDate),	
		@ShipmentID = min(ShipmentID),
		@carrierRefNo = min(carrierRefNo),
		@WorkOrderNo = min(WorkOrderNo)
from	InputShip		
if @debug > 0 select @maxPacknum '@maxPacknum', @FirstshipDate '@FirstshipDate', @ShipmentID '@ShipmentID',  @carrierRefNo '@carrierRefNo', @WorkOrderNo '@WorkOrderNo'

select	@OrderDate = Orderdate
from	epicor905..TFOrdHed
where	company = 'SSI'
and		TFOrdNum = @WorkOrderNo

if @debug > 0 select @OrderDate '@OrderDate'

insert	epicor905..TFShipHead(
		Company, PackNum, ShipDate, ShipViaCode, ShipPerson,
		EntryPerson, ShipLog, LabelComment, ShipComment, Character01,
		Character02, Character03, Character04, Character05, Character06,
		Character07, Character08, Character09, Character10, Number01,
		Number02, Number03, Number04, Number05, Number06,

		Number07, Number08, Number09, Number10, Date01,
		Date02, Date03, Date04, Date05, CheckBox01,
		CheckBox02, CheckBox03, CheckBox04, CheckBox05, Plant,
		TrackingNumber, LegalNumber, ExternalDeliveryNote, ExternalID, direct_transfer,
		ToPlant, Shipped, Number11, Number12, Number13,

		Number14, Number15, Number16, Number17, Number18,
		Number19, Number20, Date06, Date07, Date08,
		Date09, Date10, Date11, Date12, Date13,
		Date14, Date15, Date16, Date17, Date18,
		Date19, Date20, CheckBox06, CheckBox07, CheckBox08,

		CheckBox09, CheckBox10, CheckBox11, CheckBox12, CheckBox13,
		CheckBox14, CheckBox15, CheckBox16, CheckBox17, CheckBox18,
		CheckBox19, CheckBox20, ShortChar01, ShortChar02, ShortChar03,
		ShortChar04, ShortChar05, ShortChar06, ShortChar07, ShortChar08,
		ShortChar09, ShortChar10, ResDelivery, SatDelivery, SatPickup,

		Hazmat, DocOnly, RefNotes, ApplyChrg, ChrgAmount,
		COD, CODFreight, CODCheck, CODAmount, GroundType,
		NotifyFlag, NotifyEMail, DeclaredIns, DeclaredAmt, MFTransNum,
		MFCallTag, MFPickupNum, MFDiscFreight, MFTemplate, MFUse3B,
		MF3BAccount, MFDimWeight, MFZone, MFFreightAmt, MFOtherAmt,

		MFOversized, ShipStatus, ShipGroup, [Weight], PkgCode,
		PkgClass, ServSignature, ServAlert, ServHomeDel, DeliveryType,
		ServDeliveryDate, ServPhone, ServInstruct, ServRelease, ServAuthNum,
		ServRef1, ServRef2, ServRef3, ServRef4, ServRef5,
		BinNum, BOLNum, CommercialInvoice, BOLLine, ShipExprtDeclartn,

		CertOfOrigin, LetterOfInstr, HazardousShipment, PayFlag, PayAccount,
		PayBTAddress1, PayBTAddress2, PayBTCity, PayBTState, PayBTZip,
		PayBTCountry, FFID, FFAddress1, FFAddress2, FFCity,
		FFState, FFZip, FFCountry, FFContact, FFCompName,
		FFPhoneNum, IntrntlShip, IndividualPackIDs, FFAddress3, DeliveryConf,

		AddlHdlgFlag, NonStdPkg, FFCountryNum, PayBTAddress3, PayBTCountryNum,
		PayBTPhone, WayBillNbr, FreightedShipViaCode, UPSQuantumView, UPSQVShipFromName,
		UPSQVMemo, PkgLength, PkgWidth, PkgHeight, PhantomPack,
		PkgSizeUOM, WeightUOM, SysRowID, SysRevID, TranDocTypeID,
		DocumentPrinted, BitFlag, DeviceUOM, ManifestSizeUOM, ManifestWtUOM,

		ManifestWeight, ManifestLength, ManifestWidth, ManifestHeight, WarehouseCode,
		AutoPrintReady  )
select	'SSI', @maxPacknum, @FirstshipDate, 'BEST', 'China',     
		'China', @ShipmentID, '', '', '', 
		'', '', '', '', '',
		'', '', '', '', 0, 
		0, 0, 0, 0, 0,
		
		0, 0, 0, 0, NULL,
		NULL, NULL, NULL, NULL, 0, 
		0, 0, 0, 0, 'CHN',
		@carrierRefNo, @maxPacknum, 0, '', 0,
		substring(@WorkOrderNo,1,3), 0, 0, 0, 0,
		 
		0, 0, 0, 0, 0,
		0, 0, NULL, NULL, NULL, 
		NULL, NULL, NULL, NULL, NULL, 
		NULL, NULL, NULL, NULL, NULL, 
		NULL, NULL, 0, 0, 0,
		
		0, 0, 0, 0, 0,
		0, 0, 0, 0, 0,
		0, 0, '', '', '',
		'', '', '', '', '',
		'', '', 0, 0, 0, 
		
		0, 0, '', 0, 0,
		0, 0, 0, 0, '', 
		0, '', 0, 0, '',
		'', '', 0, '', 0,
		'', 0, '', 0, 0, 
		
		0, '', '', 0, '', 
		'', 0, 0 , 0 , '', 
		NULL, '', '', 0, '',
		'', '', '', '', '', 
		'', 0, 0, 0, 0,
		
		0, 0, 0, '', '', 
		'', '', '', '', '', 
		'', '', '', '', '', 
		'', '', '', '', '', 
		'', 0, 0, '', 1, 
		
		0, 0, 0, '', 0, 
		'', '', '', 0, '',
		'', 0, 0, 0, 0, 
		'', '', newid(), @SysRevID, '', 
		1, 8 , '', '', '', 
		
		0, 0, 0, 0, '',
		0 
set @rcnt = @@rowcount if @debug > 0 select @rcnt 'rows inserted TFShipHead'


insert	epicor905..currexchain(
		Company, TableName, Key1, Key2, Key3,
		Key4, Key5, Key6, Key7, Key8,
		TargetCurrCode, Step, FromCurrCode, ToCurrCode, RuleCode,
		ExchangeRate, [Round], RoundDec, DisplayStep, SysRowID,
		SysRevID, BitFlag )
select	'SSI', 'TFShipHead', convert(varchar,@maxPacknum), '', '',
		'', '', '', '', '',
		'USD', 1, 'USD', 'USD',
		1, 1, 0, 0, 1, NEWID(), 
		@SysRevID, 0		
set @rcnt = @@rowcount if @debug > 0 select @rcnt 'rows inserted currexchain'


set @LineNumber = -1 		
while(1 = 1)
begin
	select	@LineNumber = min(convert(int,LineNumber)) 
	from	inputShip
	where	LineNumber > @LineNumber	
	
	if @lineNumber is null or @@rowcount = 0 
		break

	select	@partnum = skuitem,
			@TotalUnits	= totalunits
	from	inputship
	where	LineNumber = @LineNumber
	if @debug > 0 select @LineNumber '@LineNumber', @partnum '@partnum', @TotalUnits '@TotalUnits'
	
	select	@partdescription = 	partdescription
	from	epicor905..part
	where	partnum = @partNum
	and		company = 'SSI'
	if @debug > 0 select @partdescription '@partdescription'

	select	@TFLineNum = TFLineNum  --DLC - fix incorrect TFLineNum
	from	epicor905..TFOrdDtl
	where	company = 'SSI'
	and		TFOrdNum = @WorkOrderNo
	and		TFOrdLine = @LineNumber
	if @debug > 0 select @TFLineNum '@TFLineNum'

	insert	epicor905..TFShipDtl(
			Company, PackNum, PackLine, Packages, PartNum,
			LineDesc, IUM, RevisionNum, ShipComment, ShipCmpl,
			WarehouseCode, BinNum, UpdatedInventory, NetWeightUOM, LotNum,
			Character01, Character02, Character03, Character04, Character05,
			Character06, Character07, Character08, Character09, Character10,

			Number01, Number02, Number03, Number04, Number05,
			Number06, Number07, Number08, Number09, Number10,
			Date01, Date02, Date03, Date04, Date05,
			CheckBox01, CheckBox02, CheckBox03, CheckBox04, CheckBox05,
			Obsolete90DimCode, Obsolete90DUM, Obsolete90DimConvFactor, TotalNetWeight, WIPWarehouseCode,

			WIPBinNum, TFOrdLine, OurStockQty, OurStockShippedQty, request_date,
			TFOrdNum, TFLineNum, Number11, Number12, Number13,
			Number14, Number15, Number16, Number17, Number18,
			Number19, Number20, Date06, Date07, Date08,
			Date09, Date10, Date11, Date12, Date13,

			Date14, Date15, Date16, Date17, Date18,
			Date19, Date20, CheckBox06, CheckBox07, CheckBox08,
			CheckBox09, CheckBox10, CheckBox11, CheckBox12, CheckBox13,
			CheckBox14, CheckBox15, CheckBox16, CheckBox17, CheckBox18,
			CheckBox19, CheckBox20, ShortChar01, ShortChar02, ShortChar03,

			ShortChar04, ShortChar05, ShortChar06, ShortChar07, ShortChar08,
			ShortChar09, ShortChar10, SysRowID, SysRevID, BitFlag,
			DiscountPercent, PricePerCode, Discount, DocDiscount, Rpt1Discount,
			Rpt2Discount, Rpt3Discount, ExtPrice, DocExtPrice, Rpt1ExtPrice,
			Rpt2ExtPrice, Rpt3ExtPrice, UnitPrice, DocUnitPrice, Rpt1UnitPrice,

			Rpt2UnitPrice, Rpt3UnitPrice, PickedAutoAllocatedQty )
	select 	'SSI', @maxPackNum, @LineNumber,  1, @partnum, 
			@PartDescription, 'EA', '', '', 0, 
			'CHN-MAIN', 'MAIN', 0, 'LB', '',
			'', '', '', '', '', 
			'', '', '', '', '', 
			
			0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0, 
			NULL, NULL, NULL, NULL, NULL, 
			0, 0, 0, 0, 0, 
			'', '', 1, 0, '', 
			
			'', @LineNumber, @Totalunits, @Totalunits, @OrderDate, 
			--@WorkOrderNo, @LineNumber, 0, 0 , 0,   --DLC - fix incorrect TFLineNum
			@WorkOrderNo, @TFLineNum, 0, 0 , 0, 
			0, 0, 0, 0, 0, 
			0, 0, NULL, NULL, NULL,
			NULL, NULL, NULL, NULL, NULL, 
			
			NULL, NULL, NULL, NULL, NULL, 	
			NULL, NULL, 0, 0, 0, 
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, '', '', '', 
			
			'', '', '', '', '',
			'', '', NEWID(), @SysRevID, 0, 
			0, '', 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			
			0, 0, 0  
			set @rcnt = @@rowcount if @debug > 0 select @rcnt 'rows inserted TFShipDtl'			
end
if @debug > 0 select Count(*) 'Toatl rows in TFShipDtl' from epicor905..TFSHipDtl where packnum = @maxpacknum 

