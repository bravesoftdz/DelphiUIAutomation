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
unit DelphiUIAutomation.RadioButton;

interface

uses
  DelphiUIAutomation.Base,
  UIAutomationClient_TLB;

type
  IAutomationRadioButton = interface (IAutomationBase)
  ['{B40E22FF-6E10-4E9C-8900-48C4D1F83F19}']
    ///<summary>
    ///  Selects the control
    ///</summary>
    function Select: HRESULT;
  end;

  /// <summary>
  ///  Represents a radio button control
  /// </summary>
  TAutomationRadioButton = class (TAutomationBase, IAutomationRadioButton)
  public
    ///<summary>
    ///  Selects the control
    ///</summary>
    function Select: HRESULT;
  end;

implementation

uses
  DelphiUIAutomation.PatternIDs;

{ TAutomationRadioButton }

function TAutomationRadioButton.Select: HRESULT;
var
  Inter: IInterface;
  pattern : IUIAutomationSelectionItemPattern;

begin
  result := -1;

  fElement.GetCurrentPattern(UIA_SelectionItemPatternId, inter);

  if (inter <> nil) then
  begin
    if Inter.QueryInterface(IID_IUIAutomationSelectionItemPattern, pattern) = S_OK then
    begin
      result := pattern.Select;
    end;
  end;
end;

end.

