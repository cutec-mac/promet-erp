unit uordertest;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,uOrder,uBaseERPDBClasses;

type

  { OrderTest }

  OrderTest= class(TTestCase)
  published
    procedure CreateOrder;
    procedure FillAddress;
    procedure FillPosition1;
    procedure CheckVatCalculation;
    procedure CheckQuantityCalculation;
    procedure FillPosition2;
    procedure CheckSumCalculation;
    procedure CheckPriceCalculation;
    procedure CheckPost;
    procedure ConvertAU;
    procedure ConvertLI;
    procedure Free;
  end;

implementation
uses uData,uPerson,uMasterdata;
var
  aOrder : TOrder;
procedure OrderTest.CreateOrder;
begin
  aOrder := TOrder.Create(nil);
  aOrder.Insert;
end;

procedure OrderTest.FillAddress;
var
  aPerson: TPerson;
  a: Int64;
begin
  aPerson := TPerson.Create(nil);
  aPerson.Open;
  Randomize;
  a := Random(aPerson.Count-1);
  if a>0 then
    aPerson.DataSet.MoveBy(a);
  aOrder.Address.Assign(aPerson);
  aPerson.Free;
  Check(aOrder.Address.Count=1,'Person insert failed')
end;

procedure OrderTest.FillPosition1;
var
  aMD: TMasterdata;
  a: Int64;
begin
  aMD := TMasterdata.Create(nil);
  aMD.Open;
  Randomize;
  a := Random(aMD.Count-1);
  if a>0 then
    aMD.DataSet.MoveBy(a);
  aOrder.Positions.Insert;
  aOrder.Positions.Assign(aMD);
  Check(aOrder.Positions.FieldByName('POSNO').AsString = '1');
  aMd.Free;
end;

procedure OrderTest.CheckVatCalculation;
begin
  aOrder.Positions.FieldByName('SELLPRICE').AsString:='5';
  Check(aOrder.Positions.FieldByName('GROSSPRICE').AsString = StringReplace('5.95','.',DecimalSeparator,[rfReplaceAll]),'MwSt from 5 is:'+aOrder.Positions.FieldByName('GROSSPRICE').AsString);
end;

procedure OrderTest.CheckQuantityCalculation;
begin
  aOrder.Positions.FieldByName('QUANTITY').AsString:='5';
  Check(aOrder.Positions.FieldByName('POSPRICE').AsFloat = 25);
end;

procedure OrderTest.FillPosition2;
begin
  aOrder.Positions.Insert;
  aOrder.Positions.FieldByName('SHORTTEXT').AsString:='Position 2';
  Check(aOrder.Positions.FieldByName('POSNO').AsString = '2');
  aOrder.Positions.FieldByName('SELLPRICE').AsString:='5';
  aOrder.Positions.PosCalc.Append;
  aOrder.Positions.PosCalc.FieldByName('TYPE').AsString:='SAP';
  aOrder.Positions.PosCalc.FieldByName('PRICE').AsFloat:=5;
  aOrder.Positions.PosCalc.Append;
  aOrder.Positions.PosCalc.FieldByName('MINCOUNT').AsInteger:=5;
  aOrder.Positions.PosCalc.FieldByName('TYPE').AsString:='SAP';
  aOrder.Positions.PosCalc.FieldByName('PRICE').AsFloat:=2.5;
  aOrder.Positions.FieldByName('QUANTITY').AsString:='2';
end;

procedure OrderTest.CheckSumCalculation;
begin
  aOrder.DataSet.Post;
  Check(aOrder.FieldByName('NETPRICE').AsFloat = 35);
  aOrder.CascadicPost;
end;

procedure OrderTest.CheckPriceCalculation;
begin
  aOrder.Positions.Edit;
  aOrder.Positions.FieldByName('QUANTITY').AsString:='10';
  aOrder.Positions.Post;
  //Check(aOrder.FieldByName('NETPRICE').AsFloat = 50);
end;

procedure OrderTest.CheckPost;
begin
  Check(aOrder.DoPost=prSuccess,'Order post failed');
end;

procedure OrderTest.ConvertAU;
begin
  aOrder.ChangeStatus('AU');
  Check(aOrder.Count=2,'Order Count='+IntToStr(aOrder.Count));
  Check(aOrder.DoPost=prSuccess,'Order post failed');
end;

procedure OrderTest.ConvertLI;
begin
  aOrder.ChangeStatus('LI');
  Check(aOrder.Count=3,'Order Count='+IntToStr(aOrder.Count));
  Check(aOrder.DoPost=prSuccess,'Order post failed');
end;

procedure OrderTest.Free;
begin
  aOrder.Free;
end;



initialization

  RegisterTest(OrderTest);
end.

