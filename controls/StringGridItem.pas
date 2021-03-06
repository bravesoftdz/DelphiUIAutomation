{***************************************************************************}
{                                                                           }
{           DelphiUIAutomation                                              }
{                                                                           }
{           Copyright 2015 JHC Systems Limited                              }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
unit StringGridItem;

interface

uses
  ActiveX,
  types,
  UIAutomationCore_TLB, classes;

type
  TAutomationStringGridItem = class (TInterfacedPersistent,
                                    IRawElementProviderSimple,
                                    ISelectionItemProvider,
                                    IValueProvider,
                                    IRawElementProviderFragment,
                                    IGridItemProvider)
  strict private
    FValue: string;
    FRow: integer;
    FColumn: integer;
    FSelected : boolean;
    FCellRect : TRect;

  private
    procedure SetColumn(const Value: integer);
    procedure SetRow(const Value: integer);
    procedure SetTheValue(const Value: string);
    procedure SetSelected(const Value: boolean);
    function GetSelected : boolean;
    function GetTheValue: string;

  public
    property Row : integer read FRow write SetRow;
    property Column : integer read FColumn write SetColumn;
    property Value : string read GetTheValue write SetTheValue;
    property Selected : boolean read GetSelected write SetSelected;
    property CellRect : TRect read FCellRect write FCellRect;

    // IRawElementProviderSimple
    function Get_ProviderOptions(out pRetVal: ProviderOptions): HResult; stdcall;
    function GetPatternProvider(patternId: SYSINT; out pRetVal: IUnknown): HResult; stdcall;
    function GetPropertyValue(propertyId: SYSINT; out pRetVal: OleVariant): HResult; stdcall;
    function Get_HostRawElementProvider(out pRetVal: IRawElementProviderSimple): HResult; stdcall;

    // ISelectionItemProvider
    function Select: HResult; stdcall;
    function AddToSelection: HResult; stdcall;
    function RemoveFromSelection: HResult; stdcall;
    function Get_IsSelected(out pRetVal: Integer): HResult; stdcall;
    function Get_SelectionContainer(out pRetVal: IRawElementProviderSimple): HResult; stdcall;

    // IValueProvider
    function Get_Value(out pRetVal: WideString): HResult; stdcall;
    function SetValue(val: PWideChar): HResult; stdcall;
    function Get_IsReadOnly(out pRetVal: Integer): HResult; stdcall;

    // IGridItemProvider
    function Get_row(out pRetVal: SYSINT): HResult; stdcall;
    function Get_column(out pRetVal: SYSINT): HResult; stdcall;
    function Get_RowSpan(out pRetVal: SYSINT): HResult; stdcall;
    function Get_ColumnSpan(out pRetVal: SYSINT): HResult; stdcall;
    function Get_ContainingGrid(out pRetVal: IRawElementProviderSimple): HResult; stdcall;

    // IRawElementProviderFragment
    function Navigate(direction: NavigateDirection; out pRetVal: IRawElementProviderFragment): HResult; stdcall;
    function GetRuntimeId(out pRetVal: PSafeArray): HResult; stdcall;
    function get_BoundingRectangle(out pRetVal: UiaRect): HResult; stdcall;
    function GetEmbeddedFragmentRoots(out pRetVal: PSafeArray): HResult; stdcall;
    function SetFocus: HResult; stdcall;
    function Get_FragmentRoot(out pRetVal: IRawElementProviderFragmentRoot): HResult; stdcall;

    constructor Create(AOwner: TComponent; ACol, ARow : integer; AValue : String; ACellRect : TRect);
  end;

implementation

uses
  AutomatedStringGrid,
  sysutils;

{ TAutomationStringGridItem }

function TAutomationStringGridItem.AddToSelection: HResult;
begin
  result := (self as ISelectionItemProvider).Select;
end;

constructor TAutomationStringGridItem.Create(AOwner: TComponent; ACol, ARow : integer; AValue : String; ACellRect : TRect);
begin
  inherited create;

  self.CellRect := ACellRect;
  self.Column := ACol;
  self.Row := ARow;
  self.Value := AValue;
  self.Selected := false;
end;

function TAutomationStringGridItem.GetEmbeddedFragmentRoots(
  out pRetVal: PSafeArray): HResult;
begin
  result := S_FALSE;
end;

function TAutomationStringGridItem.GetPatternProvider(patternId: SYSINT;
  out pRetVal: IInterface): HResult;
begin
  pRetval := nil;
  result := S_FALSE;

  if ((patternID = UIA_SelectionItemPatternId) or
      (patternID = UIA_GridItemPatternId) or
      (patternID = UIA_ValuePatternId)) then
  begin
    pRetVal := self;
    result := S_OK;
  end
end;

function TAutomationStringGridItem.GetPropertyValue(propertyId: SYSINT;
  out pRetVal: OleVariant): HResult;
begin
  if(propertyId = UIA_ControlTypePropertyId) then
  begin
    TVarData(pRetVal).VType := varWord;
    TVarData(pRetVal).VWord := UIA_DataItemControlTypeId;
    result := S_OK;
  end
  else if (propertyId = UIA_NamePropertyId) then
  begin
    TVarData(pRetVal).VType := varOleStr;
    TVarData(pRetVal).VOleStr := PWideChar(self.Value);
    result := S_OK;
  end
  else if(propertyId = UIA_ClassNamePropertyId) then
  begin
    TVarData(pRetVal).VType := varOleStr;
    TVarData(pRetVal).VOleStr := pWideChar(self.ClassName);
    result := S_OK;
  end
  else
    result := S_FALSE;
end;
function TAutomationStringGridItem.GetRuntimeId(
  out pRetVal: PSafeArray): HResult;
begin
  result := S_FALSE;
end;

function TAutomationStringGridItem.GetSelected: boolean;
begin
  result := FSelected;
end;

function TAutomationStringGridItem.GetTheValue: string;
begin
  result := self.FValue;
end;

function TAutomationStringGridItem.get_BoundingRectangle(
  out pRetVal: UiaRect): HResult;
begin
  pRetVal.left := self.FCellRect.Left;
  pRetVal.top := self.FCellRect.Top;

  // Not sure about these
  pRetVal.width := self.FCellRect.Right;
  pRetVal.height := self.FCellRect.Bottom;

  result := S_OK;
end;

function TAutomationStringGridItem.Get_HostRawElementProvider(
  out pRetVal: IRawElementProviderSimple): HResult;
begin
  pRetVal := nil;
  result := S_OK;
end;

function TAutomationStringGridItem.Get_IsReadOnly(
  out pRetVal: Integer): HResult;
begin
  pRetVal := 1;
  result := S_OK;
end;
function TAutomationStringGridItem.Get_IsSelected(
  out pRetVal: Integer): HResult;
begin
  result := S_OK;

  if self.FSelected then
    pRetVal := 0
  else
    pRetVal := 1;
end;

function TAutomationStringGridItem.Get_ProviderOptions(
  out pRetVal: ProviderOptions): HResult;
begin
  pRetVal:= ProviderOptions_ServerSideProvider;
  Result := S_OK;
end;

function TAutomationStringGridItem.Get_Value(out pRetVal: WideString): HResult;
begin
  pRetVal := self.FValue;
  result := S_OK;
end;

function TAutomationStringGridItem.Navigate(direction: NavigateDirection;
  out pRetVal: IRawElementProviderFragment): HResult;
begin
  result := S_FALSE;
end;

function TAutomationStringGridItem.RemoveFromSelection: HResult;
begin
  result := (self as ISelectionItemProvider).RemoveFromSelection;
end;

function TAutomationStringGridItem.Select: HResult;
begin
  self.Selected := true;
  result := S_OK;
end;

procedure TAutomationStringGridItem.SetColumn(const Value: integer);
begin
  FColumn := Value;
end;

function TAutomationStringGridItem.SetFocus: HResult;
begin
  result := S_FALSE;
end;

procedure TAutomationStringGridItem.SetRow(const Value: integer);
begin
  FRow := Value;
end;

procedure TAutomationStringGridItem.SetSelected(const Value: boolean);
begin
//  (FOwner as TAutomationStringGrid).Row := self.Row;

  FSelected := Value;
end;

function TAutomationStringGridItem.SetValue(val: PWideChar): HResult;
begin
  result := S_OK;
  self.FValue := val;
end;

procedure TAutomationStringGridItem.SetTheValue(const Value: string);
begin
  FValue := Value;
end;

function TAutomationStringGridItem.Get_row(out pRetVal: SYSINT): HResult;
begin
  pRetVal := self.Row;
  result := S_OK;
end;

function TAutomationStringGridItem.Get_column(out pRetVal: SYSINT): HResult;
begin
  pRetVal := self.Column;
  result := S_OK;
end;

function TAutomationStringGridItem.Get_RowSpan(out pRetVal: SYSINT): HResult;
begin
  pRetVal := 1;
  result := S_OK;
end;

function TAutomationStringGridItem.Get_SelectionContainer(
  out pRetVal: IRawElementProviderSimple): HResult;
begin
  result := S_FALSE;
//  pRetVal := FOwner as IRawElementProviderSimple;
end;

function TAutomationStringGridItem.Get_ColumnSpan(out pRetVal: SYSINT): HResult;
begin
  pRetVal := 1;
  result := S_OK;
end;

function TAutomationStringGridItem.Get_ContainingGrid(out pRetVal: IRawElementProviderSimple): HResult;
begin
//  pRetVal := FOwner as IRawElementProviderSimple;
  result := S_FALSE;
end;

function TAutomationStringGridItem.Get_FragmentRoot(
  out pRetVal: IRawElementProviderFragmentRoot): HResult;
begin
  result := S_FALSE;
end;

(*
function TAutomationStringGridItem.Get_FragmentRoot(
  out pRetVal: IRawElementProviderFragmentRoot): HResult;
begin
  result := S_FALSE;
end;
*)

//procedure TAutomationStringGridItem.WMGetObject(var Message: TMessage);
//begin
//  ?????
//end;

end.
