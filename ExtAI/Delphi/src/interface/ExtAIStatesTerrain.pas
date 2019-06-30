unit ExtAIStatesTerrain;
interface
uses
  Classes, SysUtils,
  ExtAIMsgStates, ExtAISharedInterface;


// Storage for terrain of the KP
type
  TExtAIStatesTerrain = class
  private
    // Method for callbacks from message
    procedure TerrainSize(aX, aY: Word);
    procedure TerrainPassability(aPassability: TBoolArr);
    procedure TerrainFertility(aFertility: TBoolArr);
  public
    // Terrain variables
    MapHeight: Word;
    MapWidth: Word;
    Passability: TBoolArr;
    Fertility: TBoolArr;
	
    constructor Create(aMsgStates: TExtAIMsgStates);
    destructor Destroy; override;
  end;


implementation


{ TExtAIStatesTerrain }
constructor TExtAIStatesTerrain.Create(aMsgStates: TExtAIMsgStates);
begin
  Inherited Create;
  // Init values
  MapHeight := 0;
  MapWidth := 0;
  SetLength(Passability,0);
  SetLength(Fertility,0);
  // Connect callbacks
  aMsgStates.OnTerrainSize := TerrainSize;
  aMsgStates.OnTerrainPassability := TerrainPassability;
  aMsgStates.OnTerrainFertility := TerrainFertility;
end;


destructor TExtAIStatesTerrain.Destroy();
begin
  Inherited;
end;


procedure TExtAIStatesTerrain.TerrainSize(aX, aY: Word);
begin
  MapHeight := aY;
  MapWidth := aX;
end;


procedure TExtAIStatesTerrain.TerrainPassability(aPassability: TBoolArr);
begin
  Passability := aPassability;
end;


procedure TExtAIStatesTerrain.TerrainFertility(aFertility: TBoolArr);
begin
  Fertility := aFertility;
end;


end.
