{*------------------------------------------------------------------------------
  Form that shows and allows to edit a lasershow frame
  @Author    Patrick M. Kolla
  @Version   2009-06-24   Patrick M. Kolla	Now open source
-------------------------------------------------------------------------------}
// *****************************************************************************
// Copyright: © 1999,2000,2009-2010 Patrick Michael Kolla. All rights reserved.
// License:   GNU Public License v3
// Project:   Heathcliff
// File:      FormUnitPad.pas
// Compiler:  Borland Delphi 2006
// Purpose:   Form that shows and allows to edit a lasershow frame
// Author:    Patrick M. Kolla (pk)
// *****************************************************************************
//  This file is part of Heathcliff for Catweazle LC1 - Yoghurt Mixer.
//
//  Heathcliff is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Heathcliff is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Heathcliff.  If not, see <http://www.gnu.org/licenses/>.
// *****************************************************************************

unit FormUnitPad;

{$MODE Delphi}

interface

uses
   LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   ExtCtrls, ComCtrls, StdCtrls, FileUtil, Math, uLaserFrames,
   UnitHeathcliffHelpers;

type
   TFormSketchpad = class(TForm)
      iLeftRuler: TImage;
      iTopRuler: TImage;
      pad: TPaintBox;
      panel4pad: TPanel;
      panelCorner: TPanel;
      panelDown: TPanel;
      panelFrameSwitcher: TPanel;
      panelXsb: TPanel;
      panelYsb: TPanel;
      sbFrames: TScrollBar;
      sbX: TScrollBar;
      sbY: TScrollBar;
      procedure FormActivate(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure FormKeyPress(Sender: TObject; var Key: Char);
      procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
      procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
      procedure FormShow(Sender: TObject);
      procedure iLeftRulerDblClick(Sender: TObject);
      procedure iLeftRulerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure iLeftRulerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure iLeftRulerMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure iTopRulerDblClick(Sender: TObject);
      procedure iTopRulerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure iTopRulerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure iTopRulerMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure padMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure padMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure padMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure padPaint(Sender: TObject);
      procedure panelCornerClick(Sender: TObject);
      procedure sbFramesChange(Sender: TObject);
      procedure sbXChange(Sender: TObject);
      procedure sbYChange(Sender: TObject);
   private
   public
      MultiSelect: boolean;
      MouseDownPos: TPoint;
      procedure ZoomIn(x,y: word);
      procedure ZoomOut(x,y: word);
   end;

var
   FormSketchpad: TFormSketchpad;

implementation

uses
   FormUnitMain,
   FormUnitHelpLines;

{$R *.lfm}

procedure TFormSketchpad.FormCreate(Sender: TObject);
begin
   FormSketchpad.pad.cursor := crMovePoint;
   FormSketchpad.Icon.Handle := FormMain.MyIcons[0];
   FormSketchpad.WindowState := wsMaximized;
   MultiSelect := false;
   FormMain.aNewFileExecute(nil);
   if FormMain.Tag=1 then begin
      if ParamCount>0
       then if FileExistsUTF8(ParamStr(1)) { *Converted from FileExists* }
        then FormMain.LoadFromFile(ParamStr(1),FormMain.FFile,true);
      FormMain.Tag := 0;
   end;
   //FormMain.ReDraw;
end;

procedure TFormSketchpad.ZoomIn(x,y: word);
var cps: TPoint;
begin
   if FormMain.ZoomFactor<8 then with FormMain do begin
      Inc(ZoomFactor);
      cps.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
      cps.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
      if FormSketchpad.pad.Width<256*ZoomFactor then FormSketchpad.sbX.Max := 256*ZoomFactor-FormSketchpad.pad.Width else FormSketchpad.sbX.Max := 0;
      if FormSketchpad.pad.Height<256*ZoomFactor then FormSketchpad.sbY.Max := 256*ZoomFactor-FormSketchpad.pad.Height else FormSketchpad.sbY.Max := 0;
      FormSketchpad.sbX.Position := ((cps.x - (128 div ZoomFactor)) * ZoomFactor);
      FormSketchpad.sbY.Position := ((cps.y - (128 div ZoomFactor)) * ZoomFactor);
      case FormMain.ZoomFactor of
         1 : FormMain.miZoom1.Checked := true;
         2 : FormMain.miZoom2.Checked := true;
         3 : FormMain.miZoom3.Checked := true;
         4 : FormMain.miZoom4.Checked := true;
         5 : FormMain.miZoom5.Checked := true;
         6 : FormMain.miZoom6.Checked := true;
         7 : FormMain.miZoom7.Checked := true;
         8 : FormMain.miZoom8.Checked := true;
         else begin
            FormMain.miZoom2.Checked := true;
            FormMain.ZoomFactor := 2;
         end;
      end;
      FormMain.miZoom.Caption := 'Zoom: '+IntToStr(ZoomFactor)+'x...';
   end;
   FormMain.Redraw;
end;

procedure TFormSketchpad.ZoomOut(x,y: word);
begin
   if FormMain.ZoomFactor>1 then Dec(FormMain.ZoomFactor);
   case FormMain.ZoomFactor of
      1 : FormMain.miZoom1.Checked := true;
      2 : FormMain.miZoom2.Checked := true;
      3 : FormMain.miZoom3.Checked := true;
      4 : FormMain.miZoom4.Checked := true;
      5 : FormMain.miZoom5.Checked := true;
      6 : FormMain.miZoom6.Checked := true;
      7 : FormMain.miZoom7.Checked := true;
      8 : FormMain.miZoom8.Checked := true;
      else begin
         FormMain.miZoom2.Checked := true;
         FormMain.ZoomFactor := 2;
      end;
   end;
   FormMain.miZoom.Caption := 'Zoom: '+IntToStr(FormMain.ZoomFactor)+'x...';
   FormMain.Redraw;
end;

procedure TFormSketchpad.padMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,j: integer;
    cps: TPoint;
    found: boolean;
    myf,mytf: TLaserFrame;
    myp,myoldp: TSmallPoint;
    oldpoint: integer;
    ox,oy: byte;
    newlink: array of array of boolean;
    circlefactor: integer;
    dp: TPoint;
begin
   myf := FormMain.FFile.Frames[FormMain.currentframe];
   if (myf.Bits and 2)=0 then begin
      circlefactor := 2; //zoomfactor
      FormMain.Dontdraw := true;
      with FormMain do begin
         found := false;
         if (WorkState=sMoveRotateFrame) and (not(ssAlt in Shift)) then begin
            if Button=mbLeft then begin
               FormSketchpad.pad.tag := 3;
               FormMain.RotStart.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
               FormMain.RotStart.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
               dp.x := FormMain.RotStart.x-myf.RotCenter.x;
               dp.y := FormMain.RotStart.y-myf.RotCenter.y;
               FormMain.tbPointTools.Tag := 0;
            end else if Button=mbRight then begin
               FormSketchpad.pad.tag := 2;
               FormMain.RotStart.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
               FormMain.RotStart.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
               dp.x := FormMain.RotStart.x-myf.RotCenter.x;
               dp.y := FormMain.RotStart.y-myf.RotCenter.y;
               FormMain.tbPointTools.Tag := 0;
            end;
         end else if (WorkState=sEquilateral) then begin
            if (Button=mbLeft) then begin
               EquilateralCenter.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
               EquilateralCenter.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
               EquilateralFinished := false;
            end else if (Button=mbRight) then begin
               EquilateralStart.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
               EquilateralStart.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
               EquilateralFinished := true;
               Equilateral(EquilateralCenter,EquilateralStart);
            end;
         end else if (WorkState=sAuxPoints) or ((WorkState=sMoveRotateFrame) and (ssAlt in Shift)) then begin
            if (Button=mbLeft) then begin
               myf.RotCenter.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
               myf.RotCenter.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
               if FormMain.miSnapGrid.Checked then begin
                  //ox := myf.RotCenter.x; oy := myf.RotCenter.y;
                  myf.RotCenter.x := (myf.RotCenter.x+(FormMain.GridWidth div 2)) div FormMain.GridWidth * FormMain.GridWidth;
                  myf.RotCenter.y := (myf.RotCenter.y+(FormMain.GridWidth div 2)) div FormMain.GridWidth * FormMain.GridWidth;
               end;
            end else if (Button=mbRight) then begin
               myf.AuxCenter.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
               myf.AuxCenter.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
               if FormMain.miSnapGrid.Checked then begin
                  //ox := myf.RotCenter.x; oy := myf.RotCenter.y;
                  myf.AuxCenter.x := (myf.AuxCenter.x+(FormMain.GridWidth div 2)) div FormMain.GridWidth * FormMain.GridWidth;
                  myf.AuxCenter.y := (myf.AuxCenter.y+(FormMain.GridWidth div 2)) div FormMain.GridWidth * FormMain.GridWidth;
               end;
            end;
         end else
         if (((WorkState=sMove) or (WorkState=sDel)) and ((Button=mbLeft) and (not (ssAlt in Shift))))
         or ((Button=mbRight) and (WorkState=sAdd))
         or (WorkState=sPointType)
         or ((WorkState=sAnim) and (Button=mbLeft)) then begin
            for i := 0 to myf.Points.count-1 do if ((WorkState<>sDel) or (not found)) then begin
               myp := myf.Points[i];
               if sbFlipY.Down then
                cps.x := 256*ZoomFactor-myp.x*ZoomFactor-FormSketchpad.sbX.Position
                 else cps.x := myp.x*ZoomFactor-FormSketchpad.sbX.Position;
               if sbFlipX.Down then
                cps.y := 256*ZoomFactor-myp.y*ZoomFactor-FormSketchpad.sbY.Position
                 else cps.y := myp.y*ZoomFactor-FormSketchpad.sbY.Position;
               if (Abs(cps.x-x)<CircleFactor*CircleSize) and (Abs(cps.y-y)<CircleFactor*CircleSize) then begin
                  if (ssShift in Shift) then begin
                     MouseDownPos.x := x;
                     MouseDownPos.y := y;
                     if not multiselect then
                        for j := 0 to myf.Points.count-1 do
                           TSmallPoint(myf.Points[j]).p := 0;
                     multiselect := true;
                     if ((myp.p and 1)=0) then Inc(myp.p) else Dec(myp.p);
                  end else begin
                     multiselect := false;
                     for j := 0 to myf.Points.count-1 do
                        TSmallPoint(myf.Points[j]).p := 0;
                  end;
                  if (not found) and not (multiselect) then begin
                     SelectedPoint := i;
                     myp := myf.Points[i];
                     FormMain.sbFrame.panels[1].Text := 'Point: '+IntToStr(i)+' ('+IntToStr(myp.x)+'/'+IntToStr(myp.y)+')';
                     if (WorkState=sMove) then begin
                        FormSketchpad.pad.tag := 1;
                        FormMain.Undo.x := myp.x;
                        FormMain.Undo.y := myp.y;
                     end;
                     found := true;
                     if (WorkState=sDel) then begin
                        FormMain.Undo.Op := sDel;
                        FormMain.Undo.Pos := SelectedPoint;
                        FormMain.Undo.Point := myp;
                        myf.Points.delete(SelectedPoint);
                        FormMain.FileChanged := true;
                     end;
                     if (WorkState=sPointType) then begin
                        FormMain.FileChanged := true;
                        if (Button=mbLeft) then if ((myp.bits and 1)=0) then Inc(myp.bits) else Dec(myp.bits);
                        if (Button=mbRight) then if ((myp.bits and 2)=0) then Inc(myp.bits,2) else Dec(myp.bits,2);
                     end;
                     FormMain.sbSharpen.Down := ((myp.bits and 1)=1);
                     FormMain.sbBlank.Down := ((myp.bits and 2)=2);
                  end;
               end;
            end; // for
         end // sbMove
         else if (WorkState=sAdd) or ((WorkState=sMove) and ((Button=mbRight) or (ssAlt in Shift))) then begin
            FormMain.FileChanged := true;
            if (((x+FormSketchpad.sbX.Position) div ZoomFactor) < 256)
            and (((y+FormSketchpad.sbY.Position) div ZoomFactor) < 256) then begin
               myp := TSmallPoint.Create;
               myp.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
               myp.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
               if FormMain.miSnapGrid.Checked then begin
                  ox := myp.x; oy := myp.y;
                  myp.x := (myp.x+(FormMain.GridWidth div 2)) div FormMain.GridWidth * FormMain.GridWidth;
                  myp.y := (myp.y+(FormMain.GridWidth div 2)) div FormMain.GridWidth * FormMain.GridWidth;
                  if (ox>FormMain.GridWidth) and (myp.x<FormMain.GridWidth) then myp.x := 255;
                  if (oy>FormMain.GridWidth) and (myp.y<FormMain.GridWidth) then myp.y := 255;
               end;
               if FormMain.miFlipY.Checked then myp.x := 255 - myp.x;
               if FormMain.miFlipX.Checked then myp.y := 255 - myp.y;
               myp.Caption := IntToStr(myf.Points.Count);
               FormMain.undo.op := sAdd;
               if ((SelectedPoint<myf.Points.count) and (SelectedPoint>-1)) and (not (ssShift in Shift)) then begin
                  myf.Points.insert(SelectedPoint+1,myp);
                  FormMain.undo.pos := SelectedPoint+1;
                  Inc(SelectedPoint);
               end else begin
                  SelectedPoint := myf.Points.add(myp);
                  FormMain.undo.pos := myf.Points.count-1;
               end;
               RenumberList;
               if CurrentFrame>0 then begin
                  mytf := FFile.Frames[CurrentFrame-1];
                  SetLength(myf.links,myf.Points.count,mytf.Points.count);
               end;
            end;
         end // sbAdd
         else if (WorkState=sAnim) and (Button=mbRight) and (currentframe>0) then begin
            //myp := myf.points[SelectedPoint];
            FormMain.FileChanged := true;
            myf := FormMain.FFile.Frames[FormMain.currentframe-1];
            mytf := FormMain.FFile.Frames[FormMain.currentframe];
            found := false;
            for i := 0 to myf.Points.count-1 do if not found then begin
               myoldp := myf.Points[i];
               if miFlipY.Checked then
                cps.x := 256*ZoomFactor-myoldp.x*ZoomFactor-FormSketchpad.sbX.Position
                 else cps.x := myoldp.x*ZoomFactor-FormSketchpad.sbX.Position;
               if miFlipX.checked then
                cps.y := 256*ZoomFactor-myoldp.y*ZoomFactor-FormSketchpad.sbY.Position
                 else cps.y := myoldp.y*ZoomFactor-FormSketchpad.sbY.Position;
               if (Abs(cps.x-x)<CircleFactor*CircleSize) and (Abs(cps.y-y)<CircleFactor*CircleSize) then begin
                  oldpoint := i;
                  mytf.Links[SelectedPoint,OldPoint] := not mytf.Links[SelectedPoint,OldPoint];
                  found := true;
               end;
            end;
         end // sAnim
         else if ((WorkState=sZoom) and (Button=mbLeft)) and (ZoomFactor<8) then begin
            ZoomIn(x,y);
         end // zoom in
         else if ((WorkState=sZoom) and (Button=mbRight)) and (ZoomFactor>1) then begin
            ZoomOut(x,y);
         end // zoom out
      end; // with
      FormMain.Dontdraw := false;
      FormMain.Redraw;
   end;
end;

procedure TFormSketchpad.padMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var myf: TLaserFrame;
    myp: TSmallPoint;
    ox,oy: byte;
    p1,p2: TPoint;
    winkel: real;
begin
   with FormMain do begin
      myf := FFile.Frames[FormMain.currentframe];
      sbFrame.panels[0].Text := 'X:'+IntToStr((x+FormSketchpad.sbX.Position) div ZoomFactor)
                           + '  Y:'+IntToStr((y+FormSketchpad.sbY.Position) div ZoomFactor);
      if FormSketchpad.pad.tag = 1 then begin
         FormMain.Undo.Op := sMove;
         FormMain.FileChanged := true;
         if ((SelectedPoint<myf.Points.count) and (SelectedPoint>-1)) then begin
            myp := myf.Points[SelectedPoint];
            if FormMain.sbFlipY.Down
             then myp.x :=256*FormMain.ZoomFactor - ((x+FormSketchpad.sbX.Position) div FormMain.ZoomFactor)
              else myp.x :=(x+FormSketchpad.sbX.Position) div FormMain.ZoomFactor;
            if FormMain.sbFlipX.Down
             then myp.y :=256*FormMain.ZoomFactor - ((y+FormSketchpad.sbY.Position) div FormMain.ZoomFactor)
              else myp.y :=(y+FormSketchpad.sbY.Position) div FormMain.ZoomFactor;
            if FormMain.miSnapGrid.Checked then begin
               ox := myp.x; oy := myp.y;
               myp.x := (myp.x+(FormMain.GridWidth div 2)) div FormMain.GridWidth * FormMain.GridWidth;
               myp.y := (myp.y+(FormMain.GridWidth div 2)) div FormMain.GridWidth * FormMain.GridWidth;
               if (ox>FormMain.GridWidth) and (myp.x<FormMain.GridWidth) then myp.x := 255;
               if (oy>FormMain.GridWidth) and (myp.y<FormMain.GridWidth) then myp.y := 255;
            end;
            if not miMoveNoReDraw.Checked then Redraw;
            FormMain.sbFrame.panels[1].Text := 'Point: '+IntToStr(myp.x)+'/'+IntToStr(myp.y);
         end;
      end else if FormSketchpad.pad.tag = 2 then begin
        FormMain.Redraw;
         with pad.canvas do begin
            Pen.Color := MyOtherColors[myoc_rotcenter];
            Pen.Width := 1;
            Pen.Style := psSolid;
            p1.x :=(myf.RotCenter.x*ZoomFactor)-FormSketchpad.sbX.Position;
            if FormMain.sbFlipY.Down then p1.x := 256*FormMain.ZoomFactor - p1.x;
            p1.y :=(myf.RotCenter.y*ZoomFactor)-FormSketchpad.sbY.Position;
            if FormMain.sbFlipX.Down then p1.y := 256*FormMain.ZoomFactor - p2.y;
            p2.x :=(FormMain.RotStart.x*ZoomFactor)-FormSketchpad.sbX.Position;
            if FormMain.sbFlipY.Down then p2.x := 256*FormMain.ZoomFactor - p2.x;
            p2.y := (FormMain.RotStart.y*ZoomFactor)-FormSketchpad.sbY.Position;
            if FormMain.sbFlipX.Down then p2.y := 256*FormMain.ZoomFactor - p2.y;
            FormMain.RotEnd.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
            FormMain.RotEnd.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
            MoveTo(p1.x,p1.y); LineTo(p2.x,p2.y);
            Pen.Style := psDash;
            MoveTo(p1.x,p1.y); LineTo(x,y);
            //## winkel berechnen und anzeigen
            p1.x := Integer(FormMain.RotStart.x)-Integer(myf.RotCenter.x);
            p1.y := Integer(FormMain.RotStart.y)-Integer(myf.RotCenter.y);
            p2.x := Integer(FormMain.RotEnd.x)-Integer(myf.RotCenter.x);
            p2.y := Integer(FormMain.RotEnd.y)-Integer(myf.RotCenter.y);
            winkel := arg(p2.x,p2.y)-arg(p1.x,p1.y);
            FormMain.sbFrame.panels[1].Text := IntToStr(Round(winkel * 180 / Pi))+'°';
         end;
      end else if FormSketchpad.pad.tag = 3 then begin
        FormMain.Redraw;
         with pad.canvas do begin
            Pen.Color := MyOtherColors[myoc_rotcenter];
            Pen.Width := 1;
            p2.x :=(FormMain.RotStart.x*ZoomFactor)-FormSketchpad.sbX.Position;
            if FormMain.sbFlipY.Down then p2.x := 256*FormMain.ZoomFactor - p2.x;
            p2.y := (FormMain.RotStart.y*ZoomFactor)-FormSketchpad.sbY.Position;
            if FormMain.sbFlipX.Down then p2.y := 256*FormMain.ZoomFactor - p2.y;
            FormMain.RotEnd.x := (x+FormSketchpad.sbX.Position) div ZoomFactor;
            FormMain.RotEnd.y := (y+FormSketchpad.sbY.Position) div ZoomFactor;
            Pen.Style := psDot;
            MoveTo(p2.x,p2.y); LineTo(x,y);
            p1.x := Integer(FormMain.RotEnd.x)-Integer(FormMain.RotStart.x);
            p1.y := Integer(FormMain.RotEnd.y)-Integer(FormMain.RotStart.y);
            FormMain.sbFrame.panels[1].Text := 'dX:'+IntToStr(p1.x)+' dY:'+IntToStr(-p1.y);
         end;
      end;
   end;
end;

procedure TFormSketchpad.padMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var myf: TLaserFrame;
    winkel: real;
    wp1,wp2: TPoint;
    myp: TSmallPoint;
    p1,erg: TPoint;
    i: integer;
begin
   with FormMain do begin
      if FormSketchpad.pad.tag = 1 then begin
         if miMoveNoReDraw.Checked then Redraw;
         FormMain.FileChanged := true;
      end else if FormSketchpad.pad.tag = 2 then begin
         myf := FormMain.FFile.Frames[CurrentFrame];
         wp1.x := Integer(FormMain.RotStart.x)-Integer(myf.RotCenter.x);
         wp1.y := Integer(FormMain.RotStart.y)-Integer(myf.RotCenter.y);
         wp2.x := Integer(FormMain.RotEnd.x)-Integer(myf.RotCenter.x);
         wp2.y := Integer(FormMain.RotEnd.y)-Integer(myf.RotCenter.y);
         winkel := arg(wp2.x,wp2.y)-arg(wp1.x,wp1.y);
         FormMain.RotateFrame(FormMain.FFile.Frames[CurrentFrame],winkel);
         FormMain.FileChanged := true;
         FormMain.Redraw;
      end else if FormSketchpad.pad.tag = 3 then begin
         myf := FormMain.FFile.Frames[CurrentFrame];
         p1.x := Integer(FormMain.RotEnd.x)-Integer(FormMain.RotStart.x);
         p1.y := Integer(FormMain.RotEnd.y)-Integer(FormMain.RotStart.y);
         for i := 0 to myf.Points.count-1 do begin
            myp := myf.Points[i];
            erg.x := myp.x + p1.x;
            if erg.x>255 then erg.x := 255; if erg.x<0 then erg.x := 0;
            myp.x := erg.x;
            erg.y := myp.y + p1.y;
            if erg.y>255 then erg.y := 255; if erg.y<0 then erg.y := 0;
            myp.y := erg.y;
         end;
         FormMain.FileChanged := true;
         FormMain.Redraw;
      end;
      FormSketchpad.pad.tag := 0;
      ReCreatePreview;
   end;
end;

procedure TFormSketchpad.sbYChange(Sender: TObject);
begin
   FormMain.Redraw;
end;

procedure TFormSketchpad.sbXChange(Sender: TObject);
begin
   FormMain.Redraw;
end;

procedure TFormSketchpad.panelCornerClick(Sender: TObject);
begin
   FormMain.Redraw;
end;

procedure TFormSketchpad.FormActivate(Sender: TObject);
begin
   FormMain.ReDraw;
end;

procedure TFormSketchpad.FormShow(Sender: TObject);
begin
   FormMain.Redraw;
end;

procedure TFormSketchpad.padPaint(Sender: TObject);
begin
   FormMain.Redraw;
end;

procedure TFormSketchpad.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key='+') then begin
      if FormMain.ZoomFactor<8 then Inc(FormMain.ZoomFactor);
      case FormMain.ZoomFactor of
         1 : FormMain.miZoom1.Checked := true;
         2 : FormMain.miZoom2.Checked := true;
         3 : FormMain.miZoom3.Checked := true;
         4 : FormMain.miZoom4.Checked := true;
         5 : FormMain.miZoom5.Checked := true;
         6 : FormMain.miZoom6.Checked := true;
         7 : FormMain.miZoom7.Checked := true;
         8 : FormMain.miZoom8.Checked := true;
         else begin
            FormMain.miZoom2.Checked := true;
            FormMain.ZoomFactor := 2;
         end;
      end;
      FormMain.miZoom.Caption := 'Zoom: '+IntToStr(FormMain.ZoomFactor)+'x...';
      FormMain.Redraw;
   end;
   if (Key='-') then begin
      if FormMain.ZoomFactor>1 then Dec(FormMain.ZoomFactor);
      case FormMain.ZoomFactor of
         1 : FormMain.miZoom1.Checked := true;
         2 : FormMain.miZoom2.Checked := true;
         3 : FormMain.miZoom3.Checked := true;
         4 : FormMain.miZoom4.Checked := true;
         5 : FormMain.miZoom5.Checked := true;
         6 : FormMain.miZoom6.Checked := true;
         7 : FormMain.miZoom7.Checked := true;
         8 : FormMain.miZoom8.Checked := true;
         else begin
            FormMain.miZoom2.Checked := true;
            FormMain.ZoomFactor := 2;
         end;
      end;
      FormMain.miZoom.Caption := 'Zoom: '+IntToStr(FormMain.ZoomFactor)+'x...';
      FormMain.Redraw;
   end;
end;

procedure TFormSketchpad.sbFramesChange(Sender: TObject);
begin
   if FormMain.FFile<>nil then if FormMain.FFile.Count>0 then begin
      panelFrameSwitcher.Caption := IntToStr(sbFrames.Position);
      sbFrames.Max := Pred(FormMain.FFile.Count);
      while FormMain.lbThumbs.Items.Count>FormMain.FFile.Count
        do FormMain.lbThumbs.Items.Delete(FormMain.lbThumbs.Items.Count-1);
      if sbFrames.Position<FormMain.FFile.Count then begin
         FormMain.miPartImg.Enabled := FileExistsUTF8(TLaserFrame(FormMain.FFile.Frames[sbFrames.Position]).ImgName); { *Converted from FileExists* }
         FormMain.miFullImg.Enabled := FormMain.miPartImg.Enabled;
         FormMain.miChoosePart.Enabled := FormMain.miPartImg.Enabled;
         FormMain.sbPartImg.Enabled := FormMain.miPartImg.Enabled;
         FormMain.sbFullImg.Enabled := FormMain.miPartImg.Enabled;
         case TLaserFrame(FormMain.FFile.Frames[sbFrames.Position]).Effect of
            0 : FormMain.miEffectSlide.Checked := true;
            1 : FormMain.miEffectMorph.Checked := true;
            2 : FormMain.miEffectPlode.Checked := true;
            3 : FormMain.miEffectXFlip.Checked := true;
            4 : FormMain.miEffectYFlip.Checked := true;
         end;
         if (TLaserFrame(FormMain.FFile.Frames[sbFrames.Position]).Bits and 1)=0 then
           FormMain.miColor0.Checked := true
         else FormMain.miColor1.Checked := true;
         FormMain.sbLock.Down := (TLaserFrame(FormMain.FFile.Frames[sbFrames.Position]).Bits and 2)=2;
         FormMain.lbThumbs.ItemIndex := sbFrames.Position;
         FormMain.ReCreatePreview;
      end;
      FormMain.Redraw;
   end;
end;

procedure TFormSketchpad.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
   ZoomOut(MousePos.x,MousePos.y);
end;

procedure TFormSketchpad.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
   ZoomIn(MousePos.x,MousePos.y);
end;

procedure TFormSketchpad.iTopRulerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var myx: integer;
    myf: TLaserFrame;
    i,found: integer;
begin
   with pad.Canvas do begin
      Pen.Style := psDash;
      Pen.Color := clGreen;
      Pen.Width := 1;
      MoveTo(x-iLeftRuler.Width,0); LineTo(x-iLeftRuler.Width,pad.height);
      Pen.Style := psSolid;
   end;
   myf := FormMain.FFile.Frames[FormMain.CurrentFrame];
   myx := (((x-iLeftRuler.Width)+FormSketchpad.sbX.Position) div FormMain.ZoomFactor);
   if FormMain.miFlipY.Checked then myx := 256*FormMain.ZoomFactor-myx;
   found := -1;
   if Length(myf.HelpLines.x)>0 then for i := 0 to Length(myf.HelpLines.x)-1 do
      if (Abs(myx-myf.HelpLines.x[i])<5) then found := i;
   if (Button=mbLeft) and (found>-1) then begin
      pad.Tag := found;
      iTopRuler.Tag := 1;
   end else if (Button=mbRight) then begin
      if found>-1 then begin // löschen
         myf.HelpLines.x[found] := myf.HelpLines.x[Length(myf.HelpLines.x)-1];
         SetLength(myf.HelpLines.x,Length(myf.HelpLines.x)-1);
      end else begin // hinzufügen
         SetLength(myf.HelpLines.x,Length(myf.HelpLines.x)+1);
         myf.HelpLines.x[Length(myf.HelpLines.x)-1] := myx;
      end;
   end;
end;

procedure TFormSketchpad.iTopRulerMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   iTopRuler.Tag := 0;
   pad.tag := -1;
   FormMain.Redraw;
end;

procedure TFormSketchpad.iTopRulerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var mx: integer;
    myf: TLaserFrame;
    found,i: integer;
begin
   myf := FormMain.FFile.Frames[FormMain.CurrentFrame];
   mx := (((x-iLeftRuler.Width)+FormSketchpad.sbX.Position) div FormMain.ZoomFactor);
   if FormMain.miFlipY.Checked then mx := 256*FormMain.ZoomFactor-mx;

   found := -1;
   if Length(myf.HelpLines.x)>0 then for i := 0 to Length(myf.HelpLines.x)-1 do
      if (Abs(mx-myf.HelpLines.x[i])<5) then found := i;
   if found>-1 then iTopRuler.Cursor := crHandPoint else iTopRuler.Cursor := crDefault;

   if (iTopRuler.Tag = 1) then begin
      FormMain.Redraw;
      with pad.Canvas do begin
         if mx>255 then mx := 255; if mx<0 then mx := 0;
         FormMain.sbFrame.Panels[0].Text := 'X:'+IntToStr(mx);
         if (pad.tag>-1) and (pad.tag<Length(myf.HelpLines.x)) then begin
            myf.HelpLines.x[pad.tag] := mx;
         end;
      end;
      FormMain.Redraw;
   end;
end;

procedure TFormSketchpad.iLeftRulerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var myy: integer;
    myf: TLaserFrame;
    i,found: integer;
begin
   with pad.Canvas do begin
      Pen.Style := psDash;
      Pen.Color := clGreen;
      Pen.Width := 1;
      MoveTo(0,y); LineTo(pad.Width,y);
      Pen.Style := psSolid;
   end;
   myf := FormMain.FFile.Frames[FormMain.CurrentFrame];
   myy := ((y+FormSketchpad.sbY.Position) div FormMain.ZoomFactor);
   if FormMain.miFlipX.Checked then myy := 256*FormMain.ZoomFactor-myy;
   found := -1;
   if Length(myf.HelpLines.y)>0 then for i := 0 to Length(myf.HelpLines.y)-1 do
      if (Abs(myy-myf.HelpLines.y[i])<5) then found := i;
   if (Button=mbLeft) and (found>-1) then begin
      pad.Tag := found;
      iLeftRuler.Tag := 1;
   end else if Button=mbRight then begin
      if found>-1 then begin
         myf.HelpLines.y[found] := myf.HelpLines.y[Length(myf.HelpLines.y)-1];
         SetLength(myf.HelpLines.y,Length(myf.HelpLines.y)-1);
      end else begin
         SetLength(myf.HelpLines.y,Length(myf.HelpLines.y)+1);
         myf.HelpLines.y[Length(myf.HelpLines.y)-1] := myy;
      end;
   end;
end;

procedure TFormSketchpad.iLeftRulerMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   iLeftRuler.Tag := 0;
   pad.tag := -1;
   FormMain.Redraw;
end;

procedure TFormSketchpad.iLeftRulerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var my: integer;
    myf: TLaserFrame;
    found,i: integer;
begin
   myf := FormMain.FFile.Frames[FormMain.CurrentFrame];
   my := (y+FormSketchpad.sbY.Position) div FormMain.ZoomFactor;
   if FormMain.miFlipX.Checked then my := 256*FormMain.ZoomFactor-my;

   found := -1;
   if Length(myf.HelpLines.y)>0 then for i := 0 to Length(myf.HelpLines.y)-1 do
      if (Abs(my-myf.HelpLines.y[i])<5) then found := i;
   if found>-1 then iLeftRuler.Cursor := crHandPoint else iLeftRuler.Cursor := crDefault;

   if (iLeftRuler.Tag = 1) then begin
      FormMain.Redraw;
      with pad.Canvas do begin
         if my>255 then my := 255; if my<0 then my := 0;
         FormMain.sbFrame.Panels[0].Text := 'Y:'+IntToStr(my);
         if (pad.tag>-1) and (pad.tag<Length(myf.HelpLines.y)) then begin
            myf.HelpLines.y[pad.tag] := my;
         end;
      end;
      FormMain.Redraw;
   end;
end;

procedure TFormSketchpad.iTopRulerDblClick(Sender: TObject);
begin
   iTopRuler.Tag := 0;
   iLeftRuler.Tag := 0;
   FormMain.Redraw;
   FormHelpLines.pcHelplines.ActivePage := FormHelpLines.tsX;
   FormMain.miHelpLinesClick(nil);
end;

procedure TFormSketchpad.iLeftRulerDblClick(Sender: TObject);
begin
   iTopRuler.Tag := 0;
   iLeftRuler.Tag := 0;
   FormMain.Redraw;
   FormHelpLines.pcHelplines.ActivePage := FormHelpLines.tsY;
   FormMain.miHelpLinesClick(nil);
end;

end.