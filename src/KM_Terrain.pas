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
  public
    Passability: TBoolArr;
    Fertility: TBoolArr;

    constructor Create;

    property MapX: Word read fMapX;
    property MapY: Word read fMapY;
  end;

var
  // Terrain is a globally accessible resource
  gTerrain: TKMTerrain;


implementation


{ TKMTerrain }
constructor TKMTerrain.Create;
begin
  inherited;

  fMapX := 128;
  fMapY := 256;
  SetLength(Passability, fMapX*fMapY);
  SetLength(Fertility, fMapX*fMapY);
end;


end.
