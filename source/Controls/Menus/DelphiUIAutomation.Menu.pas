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
unit DelphiUIAutomation.Menu;

interface

uses
  generics.collections,
  DelphiUIAutomation.MenuItem,
  DelphiUIAutomation.Base,
  UIAutomationClient_TLB;

type
  /// <summary>
  ///  Represents a menu
  /// </summary>
  TAutomationMenu = class (TAutomationBase)
  strict private
    FParentElement : IUIAutomationElement;
  public
    /// <summary>
    ///  Constructor for menu.
    /// </summary>
    constructor Create(parent: IUIAutomationElement; element : IUIAutomationElement); reintroduce;

    /// <summary>
    ///  Destructor for menu.
    /// </summary>
    destructor Destroy; override;

    ///<summary>
    ///  Gets the menu associated with the given path
    ///</summary>
    /// <remarks>
    ///  Currently working to 2 levels i.e. 'Help|About';
    /// </remarks>
    function MenuItem (const path : string) : TAutomationMenuItem;

  end;

  /// <summary>
  ///  Represents a popup menu
  /// </summary>
  TAutomationPopupMenu = class (TAutomationMenu)
  end;

  /// <summary>
  ///  Represents a main menu
  /// </summary>
  TAutomationMainMenu = class (TAutomationMenu)
  end;

implementation

uses
  System.RegularExpressions,
  sysutils,
  Generics.Defaults,
  DelphiUIAutomation.Automation,
  DelphiUIAutomation.PatternIDs,
  DelphiUIAutomation.ControlTypeIDs;

{ TAutomationMenu }

constructor TAutomationMenu.Create(parent: IUIAutomationElement; element: IUIAutomationElement);
begin
  inherited create(element);

  self.FParentElement := parent;
end;

destructor TAutomationMenu.Destroy;
begin
  inherited;
end;

function TAutomationMenu.MenuItem(const path: string): TAutomationMenuItem;
var
  regexpr : TRegEx;
  matches : TMatchCollection;
  match : TMatch;
  group : TGroup;
  i : integer;
  value, value1 : string;

  condition : IUIAutomationCondition;
  collection, icollection : IUIAutomationElementArray;
  lLength, iLength: Integer;
  count, icount : integer;
  menuElement, imenuElement: IUIAutomationElement;
  retVal: Integer;
  name : widestring;
  pattern : IUIAutomationExpandCollapsePattern;

begin
  result := nil;

  regexpr := TRegEx.Create('(.*)\|(.*)',[roIgnoreCase,roMultiline]);
  matches := regexpr.Matches(path);

  for match in matches do
  begin
    if match.success then
    begin
      if match.Groups.Count > 1 then
      begin
          value := match.Groups.Item[1].Value;
          value1 := match.Groups.Item[2].Value;

          // 1. Find top level and expand
          condition := TUIAuto.CreateTrueCondition;

          self.FElement.FindAll(TreeScope_Descendants, condition, collection);

          collection.Get_Length(lLength);

          for count := 0 to lLength - 1 do
          begin
            collection.GetElement(Count, menuElement);
            menuElement.Get_CurrentControlType(retVal);

            if (retVal = UIA_MenuItemControlTypeId) then
            begin
              menuElement.Get_CurrentName(name);

              if name = value then
              begin
                // 2. Find leaf level and click
                menuElement.GetCurrentPattern(UIA_ExpandCollapsePatternId, IInterface(pattern));
                if Assigned(pattern) then
                begin
                  pattern.Expand;
                  sleep(750);

                  // Now do it all again
                  self.FParentElement.FindAll(TreeScope_Descendants, condition, icollection);

                  icollection.Get_Length(iLength);

                  for icount := 0 to iLength - 1 do
                  begin
                    icollection.GetElement(icount, imenuElement);
                    imenuElement.Get_CurrentControlType(retVal);

                    if (retVal = UIA_MenuItemControlTypeId) then
                    begin
                      imenuElement.Get_CurrentName(name);

                      writeln ('Inner name = ' + name);

                      if name = value1 then
                      begin
                        writeln ('Found it');
                        result := TAutomationMenuItem.Create(imenuElement);
                        break;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
  end;
end;

end.

