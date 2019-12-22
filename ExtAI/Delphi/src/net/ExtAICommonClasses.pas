unit ExtAICommonClasses;
interface
uses
  Classes, SysUtils,
  ExtAISharedNetworkTypes;


type
  // Extended with custom Read/Write commands which accept various types without asking for their length
  TKMemoryStream = class(TMemoryStream)
  public
    // Legacy format for campaigns info, maxlength 65k ansichars
    procedure ReadA(out Value: AnsiString); reintroduce; overload;
    procedure WriteA(const Value: AnsiString); reintroduce; overload;
    // Assert for savegame sections
    procedure ReadAssert(const Value: AnsiString);

    // Ansistrings saved by PascalScript into savegame
    procedure ReadHugeString(out Value: AnsiString); overload;
    procedure WriteHugeString(const Value: AnsiString); overload;

    procedure ReadHugeString(out Value: UnicodeString); overload;
    procedure WriteHugeString(const Value: UnicodeString); overload;

    // Replacement of ReadAnsi for legacy use (campaign Ids (short names) in CMP)
    procedure ReadBytes(out Value: TBytes);
    procedure WriteBytes(const Value: TBytes);

    // Unicode strings
    procedure ReadW(out Value: UnicodeString); reintroduce; overload;
    procedure WriteW(const Value: UnicodeString); reintroduce; overload;

    // ZLib's decompression streams don't work with the normal TStreams.CopyFrom since
    // it uses ReadBuffer. This procedure will work when Source is a TDecompressionStream
    procedure CopyFromDecompression(Source: TStream);

    function Write(const Value:Single   ): Longint; reintroduce; overload;
    function Write(const Value:Integer  ): Longint; reintroduce; overload;
    function Write(const Value:Cardinal ): Longint; reintroduce; overload;
    function Write(const Value:Byte     ): Longint; reintroduce; overload;
    function Write(const Value:Boolean  ): Longint; reintroduce; overload;
    function Write(const Value:Word     ): Longint; reintroduce; overload;
    function Write(const Value:ShortInt ): Longint; reintroduce; overload;
    function Write(const Value:SmallInt ): Longint; reintroduce; overload;
    function Write(const Value:TDateTime): Longint; reintroduce; overload;

    function Read(out Value:Single      ): Longint; reintroduce; overload;
    function Read(out Value:Integer     ): Longint; reintroduce; overload;
    function Read(out Value:Cardinal    ): Longint; reintroduce; overload;
    function Read(out Value:Byte        ): Longint; reintroduce; overload;
    function Read(out Value:Boolean     ): Longint; reintroduce; overload;
    function Read(out Value:Word        ): Longint; reintroduce; overload;
    function Read(out Value:ShortInt    ): Longint; reintroduce; overload;
    function Read(out Value:SmallInt    ): Longint; reintroduce; overload;
    function Read(out Value:TDateTime   ): Longint; reintroduce; overload;
  end;

  // This solution does not provide compatibility with older versions
  TKExtAIMsgStream = class(TKMemoryStream)
  public
    procedure WriteHead(aRecipient: TExtAIMsgRecipient; aSender: TExtAIMsgSender; aLengthMsg: TExtAIMsgLengthMsg);
    procedure ReadHead(out aRecipient: TExtAIMsgRecipient; out aSender: TExtAIMsgSender; out aLengthMsg: TExtAIMsgLengthMsg);

    procedure WriteMsgType(aKind: TExtAIMsgKind; aType: Cardinal; aLengthData: TExtAIMsgLengthData);
    procedure ReadMsgType(out aKind: TExtAIMsgKind; out aType: Cardinal; out aLengthData: TExtAIMsgLengthData);

    procedure WriteMsg(const aCfg: TExtAIMsgTypeCfgAI; const aValue: Cardinal);// overload;

  end;


implementation
uses
  Math;


{ TKMemoryStream }
procedure TKMemoryStream.ReadA(out Value: AnsiString);
var I: Word;
begin
  Read(I, SizeOf(I));
  SetLength(Value, I);
  if I > 0 then
    Read(Pointer(Value)^, I);
end;

procedure TKMemoryStream.WriteA(const Value: AnsiString);
var I: Word;
begin
  I := Length(Value);
  Inherited Write(I, SizeOf(I));
  if I = 0 then Exit;
  Inherited Write(Pointer(Value)^, I);
end;

procedure TKMemoryStream.ReadHugeString(out Value: AnsiString);
var I: Cardinal;
begin
  Read(I, SizeOf(I));
  SetLength(Value, I);
  if I > 0 then
    Read(Pointer(Value)^, I);
end;

procedure TKMemoryStream.WriteHugeString(const Value: AnsiString);
var I: Cardinal;
begin
  I := Length(Value);
  Inherited Write(I, SizeOf(I));
  if I = 0 then Exit;
  Inherited Write(Pointer(Value)^, I);
end;

procedure TKMemoryStream.ReadHugeString(out Value: UnicodeString);
var I: Cardinal;
begin
  Read(I, SizeOf(I));
  SetLength(Value, I);
  if I > 0 then
    Read(Pointer(Value)^, I * SizeOf(WideChar));
end;

procedure TKMemoryStream.WriteHugeString(const Value: UnicodeString);
var I: Cardinal;
begin
  I := Length(Value);
  Inherited Write(I, SizeOf(I));
  if I = 0 then Exit;
  Inherited Write(Pointer(Value)^, I * SizeOf(WideChar));
end;

procedure TKMemoryStream.ReadAssert(const Value: AnsiString);
var S: AnsiString;
begin
  ReadA(s);
  Assert(s = Value, 'TKMemoryStream.Read <> Value: '+Value);
end;


procedure TKMemoryStream.WriteW(const Value: UnicodeString);
var I: Word;
begin
  I := Length(Value);
  Inherited Write(I, SizeOf(I));
  if I = 0 then Exit;
  Inherited Write(Pointer(Value)^, I * SizeOf(WideChar));
end;

procedure TKMemoryStream.ReadBytes(out Value: TBytes);
var
  I: Word;
begin
  Read(I, SizeOf(I));
  SetLength(Value, I);
  if I > 0 then
    Read(Pointer(Value)^, I);
end;

procedure TKMemoryStream.WriteBytes(const Value: TBytes);
var
  I: Word;
begin
  I := Length(Value);
  Inherited Write(I, SizeOf(I));
  if I = 0 then Exit;
  Inherited Write(Pointer(Value)^, I);
end;

function TKMemoryStream.Write(const Value:single): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;

function TKMemoryStream.Write(const Value:integer): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;

function TKMemoryStream.Write(const Value:cardinal): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;

function TKMemoryStream.Write(const Value:byte): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;

function TKMemoryStream.Write(const Value:boolean): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;

function TKMemoryStream.Write(const Value:word): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;

function TKMemoryStream.Write(const Value:shortint): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;

function TKMemoryStream.Write(const Value:smallint): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;

function TKMemoryStream.Write(const Value:TDateTime): Longint;
begin Result := Inherited Write(Value, SizeOf(Value)); end;


procedure TKMemoryStream.ReadW(out Value: UnicodeString);
var I: Word;
begin
  Read(I, SizeOf(I));
  SetLength(Value, I);
  if I > 0 then
    Read(Pointer(Value)^, I * SizeOf(WideChar));
end;


function TKMemoryStream.Read(out Value:single): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;

function TKMemoryStream.Read(out Value:integer): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;

function TKMemoryStream.Read(out Value:cardinal): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;

function TKMemoryStream.Read(out Value:byte): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;

function TKMemoryStream.Read(out Value:boolean): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;

function TKMemoryStream.Read(out Value:word): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;

function TKMemoryStream.Read(out Value:shortint): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;

function TKMemoryStream.Read(out Value:smallint): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;

function TKMemoryStream.Read(out Value:TDateTime): Longint;
begin Result := Inherited Read(Value, SizeOf(Value)); end;


procedure TKMemoryStream.CopyFromDecompression(Source: TStream);
const
  MaxBufSize = $F000;
var
  Count: Integer;
  Buffer: PByte;
begin
  Source.Position := 0;
  GetMem(Buffer, MaxBufSize);
  try
    Count := Source.Read(Buffer^, MaxBufSize);
    while Count > 0 do
    begin
      WriteBuffer(Buffer^, Count);
      Count := Source.Read(Buffer^, MaxBufSize);
    end;
  finally
    FreeMem(Buffer, MaxBufSize);
  end;
end;


{ TKExtAIMsgStream }
procedure TKExtAIMsgStream.WriteHead(aRecipient: TExtAIMsgRecipient; aSender: TExtAIMsgSender; aLengthMsg: TExtAIMsgLengthMsg);
begin
  Write(aRecipient, SizeOf(aRecipient));
  Write(aSender, SizeOf(aSender));
  Write(aLengthMsg, SizeOf(aLengthMsg));
end;

procedure TKExtAIMsgStream.ReadHead(out aRecipient: TExtAIMsgRecipient; out aSender: TExtAIMsgSender; out aLengthMsg: TExtAIMsgLengthMsg);
begin
  Read(aRecipient, SizeOf(aRecipient));
  Read(aSender, SizeOf(aSender));
  Read(aLengthMsg, SizeOf(aLengthMsg));
end;

procedure TKExtAIMsgStream.WriteMsgType(aKind: TExtAIMsgKind; aType: Cardinal; aLengthData: TExtAIMsgLengthData);
begin
  Write(aKind, SizeOf(aKind));
  //Write(aType, 1);
  Write(aType, MSG_KIND2TYPE_SIZE[aKind]);
  Write(aLengthData, SizeOf(aLengthData));
end;

procedure TKExtAIMsgStream.ReadMsgType(out aKind: TExtAIMsgKind; out aType: Cardinal; out aLengthData: TExtAIMsgLengthData);
begin
  Read(aKind, SizeOf(aKind));
  //Read(aType, 1);
  Read(aType, MSG_KIND2TYPE_SIZE[aKind]);
  Read(aLengthData, SizeOf(aLengthData));
end;


procedure TKExtAIMsgStream.WriteMsg(const aCfg: TExtAIMsgTypeCfgAI; const aValue: Cardinal);
const
  MSG_KIND_ExtAI_CFG:  TExtAIMsgKind = mkExtAICfg;
var
  LengthData: TExtAIMsgLengthData;
begin
  LengthData := SizeOf(acfg) + SizeOf(aValue);
  Write(MSG_KIND_ExtAI_CFG, SizeOf(MSG_KIND_ExtAI_CFG));
  Write(LengthData,         SizeOf(LengthData));
  Write(aCfg,               SizeOf(aCfg));
  Write(aValue,             SizeOf(aValue));
end;
   {
function TKExtAIMsgStream.ReadMsg(const aCfg: TExtAIAICfg; const aLength: Cardinal): pointer;
begin
  Position := aIdx;
  pCardinal( @aClient.fBuffer[aIdx + SizeOf(TExtAIAICfg)] )^
end;    }

end.
