unit KM_Terrain;
interface
uses
  Windows, System.SysUtils,
  ExtAISharedInterface;


type
  // Dummy class (in KP it store all terrain data, aswell terrain routines)
  TKMTerrain = class
  private
    fMapX: Word;
    fMapY: Word;
    //fTexture: array of array of Word;
  public
    Passability: TBoolArr;
    Fertility: TBoolArr;

    constructor Create();
    destructor Destroy; override;

    //property Fertility: boolean read fMapY;
    property MapX: Word read fMapX;
    property MapY: Word read fMapY;
  end;

var
  // Terrain is a globally accessible resource
  gTerrain: TKMTerrain;


implementation


{ TKMTerrain }
constructor TKMTerrain.Create();
begin
  inherited;
  fMapX := 128;
  fMapY := 256;
  SetLength(Passability, MapX*MapY);
  SetLength(Fertility, MapX*MapY);
end;


destructor TKMTerrain.Destroy;
begin
  inherited;
end;


end.
