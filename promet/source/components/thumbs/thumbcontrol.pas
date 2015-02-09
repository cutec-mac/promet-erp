unit thumbcontrol;

//22.6.2010 Theo
//Git push 30.1.2013

{$MODE objfpc}{$H+}

interface

uses
  Classes, SysUtils, scrollingcontrol, ThreadedImageLoader, types,
  Graphics, fpImage, FPReadJPEGthumb, fpthumbresize,LResources,
  FileUtil, Dialogs, GraphType, LCLIntf, Controls;


type
  TLayoutStyle = (LsAuto, LsAutoSize, LsHorizFixed, LsVertFixed, LsHorizAutoSize, LsVertAutoSize, LsGrid);
  TInternalLayoutStyle = (IlsHorz, IlsVert, IlsGrid);

  TSelectItemEvent = procedure(Sender: TObject; Item: TThreadedImage) of object;
  TLoadFileEvent = procedure(Sender: TObject; URL: string; out Stream: TStream) of object;
  TLoadPointerEvent = procedure(Sender: TObject; P: Pointer; out Stream: TStream) of object;
  TDrawItemEvent = procedure(Sender: TObject; Item: TThreadedImage;aRect : TRect) of object;

{ TThumbControl }

  TThumbControl = class(TScrollingControl)
  private
    FAfterDraw: TDrawItemEvent;
    FOnDrawCaption: TDrawItemEvent;
    FArrangeStyle: TLayoutStyle;
    FCaptionHeight: Integer;
    FIls: TInternalLayoutStyle;
    fContentWidth: integer;
    fContentHeight: integer;
    FDirectory: UTF8String;
    fMngr: TImageLoaderManager;
    FOnLoadFile: TLoadFileEvent;
    FOnLoadPointer: TLoadPointerEvent;
    FOnScrolled: TNotifyEvent;
    FShowPictureFrame: Boolean;
    FShowCaptions: Boolean;
    fAutoSort: boolean;
    fThumbWidth: integer;
    fThumbHeight: integer;
    FURLList: TStringList;
    fMouseStartPos: TPoint;
    fDragIDX: Integer;
    fUserThumbWidth: integer;
    fUserThumbHeight: integer;
    fFrame: TBitmap;
    fThumbDist: integer; //Distance between thumbnails
    fPictureFrameBorder: integer; //One Border of blacke picture frame
    fTextExtraHeight: integer;
    fLeftOffset: integer; //first frame left offset
    fTopOffset: integer;
    fOnSelectItem: TSelectItemEvent;
    fWindowCreated: Boolean;
    fColorActiveFrame: TColor;
    fColorFont: TColor;
    fColorFontSelected: TColor;
    fGridThumbsPerLine: integer;
    function GetDraggedItem: TThreadedImage;
    function GetFreeInvisibleImages: boolean;
    function GetMultiThreaded: boolean;
    function GetSelectedList: TList;
    function GetURLList: UTF8String;
    procedure Init;
    procedure SetArrangeStyle(const AValue: TLayoutStyle);
    procedure SetAutoSort(AValue: boolean);
    procedure SetCaptionHeight(AValue: Integer);
    procedure SetDirectory(const AValue: UTF8String);
    procedure SetFreeInvisibleImages(const AValue: boolean);
    procedure SetMultiThreaded(const AValue: boolean);
    procedure SetShowPictureFrame(const AValue: Boolean);
    procedure SetShowCaptions(const AValue: Boolean);
    procedure SetThumbDistance(const AValue: integer);
    procedure SetThumbHeight(const AValue: integer);
    procedure SetThumbWidth(const AValue: integer);
    procedure AsyncFocus(Data: PtrInt);
    procedure SetURLList(const AValue: UTF8String);
    procedure DoClick(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
  protected
    class function GetControlClassDefaultSize: TSize; override;
    procedure BoundsChanged; override;
    procedure Paint; override;
    procedure ImgLoadURL(Sender: TObject);
    procedure ImgLoadPointer(Sender: TObject);
    procedure ImgRepaint(Sender: TObject);
    procedure Search;
    procedure FileFoundEvent(FileIterator: TFileIterator);
    procedure CreateWnd; override;
    procedure DoSelectItem; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure UpdateDims;
    procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {:Use this function when you need the item from control coordinates (Mouse etc.)}
    function ItemFromPoint(APoint: TPoint): TThreadedImage;
    function AddThreadedImage(Image: TThreadedImage): Integer;
    procedure ScrollIntoView;
    procedure LoadSelectedBitmap(ABitmap:TBitmap);
    procedure ClearImageList;
    procedure AddImagePointer(P: Pointer);
    procedure Arrange;
    property URLList: UTF8String read GetURLList write SetURLList;
    property ImageLoaderManager: TImageLoaderManager read fMngr;
  published
    property Directory: UTF8String read FDirectory write SetDirectory stored True nodefault;
    property ThumbWidth: integer read fUserThumbWidth write SetThumbWidth;
    property ThumbHeight: integer read fUserThumbHeight write SetThumbHeight;
    property ThumbDistance: integer read fThumbDist write SetThumbDistance;
    {:If you set MultiThreaded to true, the images will be loaded in the "background" not blocking the application.
      Warning: The debugger GDB may not like this setting. Be careful in OnLoadFile in this mode}
    property MultiThreaded: boolean read GetMultiThreaded write SetMultiThreaded;
    {:Show/Hide the filename captions.}
    property ShowCaptions: Boolean read FShowCaptions write SetShowCaptions;
    {:Show/Hide picture Frame}
    property ShowPictureFrame: Boolean read FShowPictureFrame write SetShowPictureFrame;
    {:Different modes, basically horizontal, vertical and grid plus autosize and auto layout modes, depending on the size of the control}
    property Layout: TLayoutStyle read FArrangeStyle write SetArrangeStyle;
    {:Do not keep in memory the bitmaps that are currently invisble. (Slower but less resource hungry).}
    property FreeInvisibleImages: boolean read GetFreeInvisibleImages write SetFreeInvisibleImages;
    {:Event triggered when a thumbnail is clicked or selected using the enter key.}
    property OnSelectItem: TSelectItemEvent read fOnSelectItem write fOnSelectItem;
    {:Event when image stream data is required. Useful for loading data via http, ftp etc.
      Warning: if MultiThreaded=true, this happens in a separate thread context.}
    property AutoSort : boolean read fAutoSort write SetAutoSort;
    {:Sort URL by name}
    property OnLoadFile: TLoadFileEvent read FOnLoadFile write FOnLoadFile;
    property OnLoadPointer: TLoadPointerEvent read FOnLoadPointer write FOnLoadPointer;
    property OnScrolled : TNotifyEvent read FOnScrolled write FOnScrolled;
    property AfterDraw : TDrawItemEvent read FAfterDraw write FAfterDraw;
    property OnDrawCaption: TDrawItemEvent read FOnDrawCaption write FOnDrawCaption;
    property SelectedList: TList read GetSelectedList;
    property DragedItem: TThreadedImage read GetDraggedItem;
    property ScrollBars;
    property Align;
    property Anchors;
    property AutoSize;
    property BidiMode;
    property BorderSpacing;
    property ChildSizing;
    property ClientHeight;
    property ClientWidth;
    property Color;
    property ColorActiveFrame: TColor read fColorActiveFrame write fColorActiveFrame;
    property ColorFont: TColor read fColorFont write fColorFont;
    property ColorFontSelected: TColor read fColorFontSelected write fColorFontSelected;
    property CaptionHight: Integer read FCaptionHeight write SetCaptionHeight;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChangeBounds;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDockDrop;
    property OnDockOver;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnUTF8KeyPress;


  end;

var frame: TPortableNetworkGraphic;

const StockBorderWidth = 15;

procedure Register;

implementation

uses LCLType, Forms, fontfinder,
fpreadgif,FPReadPSD,FPReadPCX,FPReadTGA; //just register them


function ShortenString(AValue: string; Width: integer; ACanvas: TCanvas): string;
var len, slen: integer;
  NewLen: integer;
begin
  len := ACanvas.TextWidth(AValue);
  if len > width then
  begin
    NewLen := ((Length(AValue) * width) div len) - 1;
    slen := Length(AValue);
//  Result:=Copy(AValue,1,NewLen); //End crop
    Result := Copy(AValue, 1, (NewLen) div 2) + '..' + Copy(AValue, slen - ((NewLen) div 2), slen);
  end else Result := AValue;
end;


{ TThumbControl }

procedure TThumbControl.SetDirectory(const AValue: UTF8String);
begin
  if GetMultiThreaded and (not fMngr.ThreadsIdle) then
  Repeat
    Application.ProcessMessages;
  until fMngr.ThreadsIdle;

  if AValue = '' then fDirectory := 'none' else fDirectory := AValue;
  if (fDirectory <> 'none') and (fDirectory <> '') then
    if DirectoryExistsUTF8(AValue) then
    begin
      if (csLoading in ComponentState) then exit;
      Init;
      Invalidate;
    end;
end;


procedure TThumbControl.Init;
begin
  if not (csDesigning in ComponentState) then
  begin
    fMngr.Clear;
    Search;
    if fAutoSort then fMngr.Sort(0);
    Arrange;
  end else
  begin
    fMngr.Clear;
    fMngr.AddImage('');
    fMngr.AddImage('');
    fMngr.AddImage('');
    Arrange;
  end;
end;



procedure TThumbControl.SetFreeInvisibleImages(const AValue: boolean);
begin
  fMngr.FreeInvisibleImage := AValue;
end;


procedure TThumbControl.SetURLList(const AValue: UTF8String);
var i: integer;
begin
  fMngr.Clear;
  FURLList.Text := AValue;
  for i := 0 to FURLList.Count - 1 do fMngr.AddImage(FURLList[i]);
  if fAutoSort then fMngr.Sort(0);
  Arrange;
end;

procedure TThumbControl.DoClick(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  Idx: Integer;
begin
  Idx := fMngr.ItemIndexFromPoint(Point(X + HScrollPosition, Y + VScrollPosition));
  if Idx > -1 then begin
    if Shift=[] then begin
      fMngr.DeselectAll;
      fMngr.ActiveIndex := Idx;
      DoSelectItem;
      Invalidate;
    end else if Shift=[ssShift] then begin
      fMngr.SetActiveIndexAndSelectBetween(Idx);
      DoSelectItem;
      Invalidate;
    end else if Shift=[ssCtrl] then begin
      fMngr.SetActiveIndexAndChangeSelected(Idx);
      DoSelectItem;
      Invalidate;
    end;
  end;
  SetFocus;
end;

function TThumbControl.GetMultiThreaded: boolean;
begin
  if Assigned(fMngr) then Result := fMngr.MultiThreaded;
end;

function TThumbControl.GetSelectedList: TList;
begin
  if Assigned(fMngr) then Result:=fMngr.SelectedList;
end;

function TThumbControl.GetFreeInvisibleImages: boolean;
begin
  Result := fMngr.FreeInvisibleImage;
end;

function TThumbControl.GetDraggedItem: TThreadedImage;
begin
  fMngr.ItemFromIndex(fDragIDX);
end;

function TThumbControl.GetURLList: UTF8String;
begin
  Result := FURLList.Text;
end;

procedure TThumbControl.SetArrangeStyle(const AValue: TLayoutStyle);
begin
  if FArrangeStyle <> AValue then
  begin
    FArrangeStyle := AValue;
    if not (csLoading in ComponentState) then
    begin
      Arrange;
      Invalidate;
    end;
  end;
end;

procedure TThumbControl.SetAutoSort(AValue: boolean);
begin
  if fAutoSort=AValue then Exit;
  fAutoSort:=AValue;
  fMngr.Sort(0);
end;

procedure TThumbControl.SetCaptionHeight(AValue: Integer);
begin
  if FCaptionHeight=AValue then Exit;
  FCaptionHeight:=AValue;
  fTextExtraHeight := FCaptionHeight;
  Arrange;
end;

procedure TThumbControl.SetMultiThreaded(const AValue: boolean);
begin
  if Assigned(fMngr) then fMngr.MultiThreaded := AValue;
end;

procedure TThumbControl.SetShowPictureFrame(const AValue: Boolean);
begin
  FShowPictureFrame := AValue;
  if FShowPictureFrame then
  begin
    fPictureFrameBorder := StockBorderWidth;
    if FShowCaptions then FTextExtraHeight := 0;
  end else
  begin
    fPictureFrameBorder := 0;
    if FShowCaptions then FTextExtraHeight := FCaptionHeight;
  end;
  if not (csLoading in ComponentState) then
  begin
    Arrange;
    Invalidate;
  end;
end;

procedure TThumbControl.SetShowCaptions(const AValue: Boolean);
begin
  FShowCaptions := AValue;
  if FShowCaptions and (not FShowPictureFrame) then FTextExtraHeight := FCaptionHeight else fTextExtraHeight := 0;
  if not (csLoading in ComponentState) then
  begin
    Arrange;
    Invalidate;
  end;
end;

procedure TThumbControl.SetThumbDistance(const AValue: integer);
begin
  if fThumbDist <> AValue then
  begin
    fThumbDist := AValue;
    if not (csLoading in ComponentState) then
    begin
      Arrange;
      Invalidate;
    end;
  end;
end;

procedure TThumbControl.SetThumbHeight(const AValue: integer);
begin
  if fThumbHeight <> AValue then
  begin
    fThumbHeight := AValue;
    fUserThumbHeight := AValue;
    if not (csLoading in ComponentState) then
    begin
      Arrange;
      Invalidate;
    end;
  end;
end;

procedure TThumbControl.SetThumbWidth(const AValue: integer);
begin
  if fThumbWidth <> AValue then
  begin
    fThumbWidth := AValue;
    fUserThumbWidth := AValue;
    SmallStep := fThumbWidth;
    LargeStep := fThumbWidth * 4;
    if not (csLoading in ComponentState) then
    begin
      Arrange;
      Invalidate;
    end;
  end;
end;


procedure TThumbControl.CreateWnd;
begin
  inherited CreateWnd;
  fWindowCreated := true;
  Init;
end;

procedure TThumbControl.DoSelectItem;
begin
  if Assigned(fOnSelectItem) then OnSelectItem(Self, fMngr.ActiveItem);
end;

procedure TThumbControl.AsyncFocus(Data: PtrInt);
begin
  SetFocus;
end;

procedure TThumbControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case key of
    VK_LEFT: begin fMngr.ActiveIndex := fMngr.ActiveIndex - 1; ScrollIntoView; end;
    VK_RIGHT: begin fMngr.ActiveIndex := fMngr.ActiveIndex + 1; ScrollIntoView; end;

    VK_UP: if FIls = IlsGrid then
      begin
        fMngr.ActiveIndex := fMngr.ActiveIndex - fGridThumbsPerLine; ScrollIntoView;
      end else
      begin fMngr.ActiveIndex := fMngr.ActiveIndex - 1;
        ScrollIntoView;
      end;

    VK_DOWN: if FIls = IlsGrid then
      begin
        fMngr.ActiveIndex := fMngr.ActiveIndex + fGridThumbsPerLine; ScrollIntoView;
      end else
      begin fMngr.ActiveIndex := fMngr.ActiveIndex + 1;
        ScrollIntoView;
      end;
    VK_RETURN: DoSelectItem;
    VK_PRIOR: if (FIls = IlsVert) or (FIls = IlsGrid) then
        VScrollPosition := VScrollPosition - ClientHeight else HScrollPosition := HScrollPosition - ClientWidth;
    VK_NEXT: if (FIls = IlsVert) or (FIls = IlsGrid) then
        VScrollPosition := VScrollPosition + ClientHeight else HScrollPosition := HScrollPosition + ClientWidth;
  end;
  Invalidate;
  Application.QueueAsyncCall(@AsyncFocus, 0);
end;

procedure TThumbControl.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  SetFocus;
end;

procedure TThumbControl.ScrollIntoView;
var itm: TThreadedImage;
  Dum, ARect: TRect;
begin
  itm := fMngr.ActiveItem;
  if itm <> nil then
  begin
    ARect := ClientRect;
    OffsetRect(ARect, HScrollPosition, VScrollPosition);

    if IntersectRect(Dum, ARect, itm.Rect) then exit;

    HScrollPosition := 0;
    VScrollPosition := 0;

    if (FIls = IlsHorz) then
      if Abs(Arect.Left - Itm.Rect.Left) > (Arect.Right - Itm.Rect.Right) then
        HScrollPosition := itm.Rect.Right - ClientWidth + fPictureFrameBorder + fThumbDist else
        HScrollPosition := itm.Rect.Left - ClientWidth - fPictureFrameBorder - fThumbDist + ClientWidth;

    if (FIls = IlsVert) or (FIls = IlsGrid) then
      if Abs(Arect.Top - Itm.Rect.Top) > (Arect.Bottom - Itm.Rect.Bottom) then
        VScrollPosition := itm.Rect.Bottom - ClientHeight + fPictureFrameBorder + fThumbDist else
        VScrollPosition := itm.Rect.Top - ClientHeight - fPictureFrameBorder - fThumbDist + ClientHeight;
    UpdateDims;
  end;
end;



procedure TThumbControl.BoundsChanged;
begin
  inherited BoundsChanged;
  if fWindowCreated and not ((csLoading in ComponentState)) and Visible then
  begin
    Arrange;
    UpdateDims;
    ScrollIntoView;
  end;
end;


procedure TThumbControl.Paint;
var i, tlen: integer;
  aRect, BorderRect, Dum: TRect;
  UrlStr: string;
  Clipped: boolean;
  Cim: TThreadedImage;
begin
  begin
    if Canvas.Clipping {$ifdef LCLQt} and false {$endif} then
    begin
      ARect := Canvas.ClipRect;
      Clipped := not EqualRect(ARect, ClientRect);
    end else
    begin
      ARect := ClientRect;
      Clipped := false;
    end;

    Canvas.Brush.Color := Color;
    Canvas.FillRect(ARect);
    OffsetRect(aRect, HScrollPosition, VScrollPosition);
    if not clipped then fMngr.LoadRect(ARect);

    Canvas.Brush.color :=  $F1F1F1;

    for i := 0 to fmngr.List.Count - 1 do
    begin
      Cim := TThreadedImage(fmngr.List[i]);
      BorderRect := Cim.Rect;
      if IntersectRect(Dum, BorderRect, Arect) then
      begin
        // Paint the Frame around the Thumbs
        //OffSetRect(BorderRect, -HScrollPosition, -VScrollPosition);
        //if fShowPictureFrame then begin
        //  Canvas.Draw(BorderRect.Left - fPictureFrameBorder, BorderRect.Top - fPictureFrameBorder, fFrame);
        //end else begin
        //  InflateRect(BorderRect, 1, 1);
        //  Canvas.Brush.Style := bsClear;
        //  Canvas.Pen.Color := clLtGray;
        //  Canvas.Rectangle(BorderRect);
        //  Canvas.Brush.Style := bsSolid;
        //end;

        if Cim.LoadState = lsLoaded then begin
          // Draw Thumb
          if Cim.Selected then begin
            Canvas.Draw(Cim.Left + Cim.Area.Left - HScrollPosition,
              Cim.Top + Cim.Area.Top - VScrollPosition,
              Cim.BitmapSelected);
          end else begin
            Canvas.Draw(Cim.Left + Cim.Area.Left - HScrollPosition,
              Cim.Top + Cim.Area.Top - VScrollPosition,
              Cim.Bitmap);
          end;
          if i = fMngr.ActiveIndex then
          begin
            BorderRect := Cim.Rect;
            InflateRect(BorderRect, 1, 1);
            OffSetRect(BorderRect, -HScrollPosition, -VScrollPosition);
            Canvas.Brush.Style := bsClear;
            Canvas.Pen.Color := fColorActiveFrame;
            Canvas.Pen.Width := 3;
            Canvas.Rectangle(BorderRect);
            Canvas.Pen.Width := 1;
            Canvas.Brush.Style := bsSolid;
          end;



          //  BorderRect := Cim.Area;
          //  OffSetRect(BorderRect, -HScrollPosition + Cim.Rect.Left,
          //    -VScrollPosition + Cim.Rect.Top);
          //  InflateRect(BorderRect, 1, 1);
          //  Canvas.Brush.Style := bsClear;
          //  Canvas.Pen.Color := fColorActiveFrame;
          //  Canvas.Pen.Width := 2;
          //  Canvas.Rectangle(BorderRect);
          //  Canvas.Pen.Width := 1;
          //  Canvas.Brush.Style := bsSolid;
          //end;
        end;

        if fShowCaptions then begin
          // Draw Caption
          if Assigned(FOnDrawCaption) then begin
            BorderRect:= Rect(Cim.Rect.Left,Cim.Rect.Bottom,Cim.Rect.Right,Cim.Rect.Bottom+fTextExtraHeight);
            OffSetRect(BorderRect, -HScrollPosition, -VScrollPosition);
            OnDrawCaption(Self,Cim,BorderRect);
          end else begin
            if Cim.URL = '' then
              UrlStr := ShortenString('Undefined', Cim.Width, Canvas) else
              UrlStr := ShortenString(ExtractFileName(Cim.URL),
                Cim.Width, Canvas);
            tlen := (Cim.Width - Canvas.TextWidth(UrlStr)) div 2;
            if not FShowPictureFrame then begin
              if i=fMngr.ActiveIndex then begin
                 Canvas.Font.color := fColorFontSelected;
              end else begin
                Canvas.Font.color := fColorFont;
              end;
            end else
            begin
              Canvas.Brush.Style := bsSolid;
              Canvas.Brush.Color := clBlack;
              Canvas.FillRect(Cim.Left - HScrollPosition + tlen - 1,
                Cim.Height + Cim.Top - VScrollPosition + 1,
                Cim.Left - HScrollPosition + 2 + tlen + Canvas.TextWidth(UrlStr),
                Cim.Height + Cim.Top - VScrollPosition + 10);
              if i = fMngr.ActiveIndex then Canvas.Font.color := clWhite else Canvas.Font.color := $448FA2;
            end;
            Canvas.Brush.Style := bsClear;
            Canvas.TextOut(
              Cim.Left - HScrollPosition + 1 + tlen,
              Cim.Height + Cim.Top - VScrollPosition - 1,
              UrlStr);
            Canvas.Brush.Style := bsSolid;
          end;
        end;
      if Assigned(AfterDraw) then
        begin
          BorderRect := Cim.Rect;
          OffSetRect(BorderRect, -HScrollPosition, -VScrollPosition);
          AfterDraw(Self,Cim,BorderRect);
        end;
      end;
    end;
  end;
  inherited Paint;
end;

function GetFPReaderMask: string;
var i, j: integer;
  sl: TStringList;
begin
  Result := '';
  sl := TStringList.Create;
  sl.Delimiter := ';';
  for i := 0 to ImageHandlers.Count - 1 do
  begin
    sl.DelimitedText := ImageHandlers.Extentions[ImageHandlers.TypeNames[i]];
    for j := 0 to sl.Count - 1 do Result := Result + '*.' + sl[j] + ';';
  end;
  sl.free;
end;

procedure TThumbControl.Search;
var fi: TFileSearcher;
begin
  fi := TFileSearcher.Create;
  fi.OnFileFound := @FileFoundEvent;
//fi.Search(FDirectory, GraphicFileMask(TGraphic), false);
  try
    fi.Search(FDirectory, GetFPReaderMask, false);
  finally
    fi.free;
  end;
end;

procedure TThumbControl.FileFoundEvent(FileIterator: TFileIterator);
begin
  fMngr.AddImage(FileIterator.FileName);
end;


procedure TThumbControl.Arrange;
var i, x, y, aDim: integer;
begin
  if FArrangeStyle = LsHorizFixed then FIls := IlsHorz else
    if FArrangeStyle = LsVertFixed then FIls := IlsVert else
      if FArrangeStyle = LsGrid then FIls := IlsGrid;
  if (FArrangeStyle = LsAuto) or (FArrangeStyle = LsAutoSize) then
  begin
    if width > height then FIls := IlsHorz else FIls := IlsVert;
    if (width > 2 * fUserThumbWidth + 4 * fPictureFrameBorder) and
    (Height > 2 * fUserThumbHeight + 4 * fPictureFrameBorder) then FIls := IlsGrid;
  end;

  if (FArrangeStyle = LsHorizFixed) or (FArrangeStyle = LsVertFixed) or
    (FArrangeStyle = LsGrid) or (FArrangeStyle = LsAuto) or (FIls = IlsGrid) then
  begin
    if (fUserThumbWidth <> fThumbWidth) or (fUserThumbHeight <> fThumbHeight) then
    begin
      fThumbHeight := fUserThumbHeight;
      fThumbWidth := fUserThumbWidth;
      fMngr.FreeImages;
      Invalidate;
    end;
  end;

  if (FArrangeStyle = LsHorizAutoSize) or ((FArrangeStyle = LsAutoSize) and (FIls = IlsHorz)) then
  begin
    aDim := fThumbHeight;
    fThumbHeight := ClientHeight - fPictureFrameBorder * 2 - fTextExtraHeight - 2 * fTopOffset - 20;
    fThumbWidth := Round(fThumbHeight / fUserThumbHeight * fUserThumbWidth);
    FIls := IlsHorz;
    if ADim <> fThumbHeight then
    begin
      fMngr.FreeImages;
      Invalidate;
    end;
  end;

  if (FArrangeStyle = LsVertAutoSize) or ((FArrangeStyle = LsAutoSize) and (FIls = IlsVert)) then
  begin
    aDim := fThumbWidth;
    fThumbWidth := ClientWidth - fPictureFrameBorder * 2 - 2 * fLeftOffset - 20;
    fThumbHeight := Round(fThumbWidth / fUserThumbWidth * fUserThumbHeight);
    FIls := IlsVert;
    if ADim <> fThumbWidth then
    begin
      fMngr.FreeImages;
      Invalidate;
    end;
  end;

  if FShowPictureFrame then
  begin
    fFrame.SetSize(fThumbWidth + fPictureFrameBorder * 2, fThumbHeight + fPictureFrameBorder * 2);
    fFrame.Canvas.Brush.FPColor := TColorToFPColor(clWhite);
    fFrame.Canvas.FillRect(0, 0, fFrame.Width, fFrame.Height);
    fFrame.Canvas.StretchDraw(Rect(0, 0, fFrame.Width, fFrame.Height), frame);
  end;

  if FIls = IlsHorz then
  begin
    for i := 0 to fMngr.List.Count - 1 do
    begin
      TThreadedImage(fMngr.List[i]).Width := fThumbWidth;
      TThreadedImage(fMngr.List[i]).Height := fThumbHeight;
      TThreadedImage(fMngr.List[i]).Left := i * (fThumbWidth + fThumbDist +
      fPictureFrameBorder * 2) +  fLeftOffset + fPictureFrameBorder;
      TThreadedImage(fMngr.List[i]).Top := fTopOffset + fPictureFrameBorder;
    end;
    fContentWidth := fMngr.List.Count * (fThumbWidth + fThumbDist + fPictureFrameBorder * 2) + fLeftOffset;
    fContentHeight := fThumbHeight + fPictureFrameBorder * 2 + fTopOffset;
  end;

  if FIls = IlsVert then
  begin
    for i := 0 to fMngr.List.Count - 1 do
    begin
      TThreadedImage(fMngr.List[i]).Width := fThumbWidth;
      TThreadedImage(fMngr.List[i]).Height := fThumbHeight;
      TThreadedImage(fMngr.List[i]).Left := fLeftOffset + fPictureFrameBorder;
      TThreadedImage(fMngr.List[i]).Top := i * (fThumbHeight + fThumbDist +
      fTextExtraHeight + fPictureFrameBorder * 2) + fTopOffset + fPictureFrameBorder;
    end;
    fContentHeight := (fMngr.List.Count) * (fThumbHeight + fTextExtraHeight + fThumbDist +
    fPictureFrameBorder * 2) + fTopOffset;
    fContentWidth := fThumbWidth + fPictureFrameBorder * 2 + fLeftOffset;
  end;

  if FIls = IlsGrid then
  begin
    y := 0;
    x := 0;
    fGridThumbsPerLine := ClientWidth div (fThumbWidth + fThumbDist + fPictureFrameBorder * 2);
    for i := 0 to fMngr.List.Count - 1 do
    begin
      if (i > 0) then
        if (i mod fGridThumbsPerLine = 0) then
        begin
          inc(y, (fThumbHeight + fThumbDist + fTextExtraHeight + fPictureFrameBorder * 2));
          x := 0;
        end
        else inc(x);
      TThreadedImage(fMngr.List[i]).Width := fThumbWidth;
      TThreadedImage(fMngr.List[i]).Height := fThumbHeight;
      TThreadedImage(fMngr.List[i]).Left := x * (fThumbWidth + fThumbDist + fPictureFrameBorder * 2) +
      fLeftOffset + fPictureFrameBorder;
      TThreadedImage(fMngr.List[i]).Top := y + fTopOffset + fPictureFrameBorder;
    end;
    fContentHeight := (fMngr.List.Count div fGridThumbsPerLine + 1) * (fThumbHeight +
    fTextExtraHeight + fThumbDist + fPictureFrameBorder * 2) + fTopOffset;
    fContentWidth := ClientWidth;
  end;


  if fContentWidth <= ClientWidth then HScrollPosition := 0;
  if fContentHeight <= ClientHeight then VScrollPosition := 0;
  UpdateDims;
end;

constructor TThumbControl.Create(AOwner: TComponent);
//var ff: TFontFinder;
begin
  inherited Create(AOwner);

  with GetControlClassDefaultSize do SetInitialBounds(0, 0, CX, CY);

  FURLList := TStringList.create;

  //ff := TFontFinder.Create;
  ////Font.Name := ff.FindAFontFromDelimitedString('Trebuchet MS,Schumacher Clean');
  ////Font.size := 7;
  //Font.Name := ff.FindAFontFromDelimitedString('Arial');
  //Font.size := 14;
  //ff.free;

  //fColorActiveFrame:=$448FA2;
  fColorActiveFrame:=clRed;
  fColorFont:=clwhite;
  fColorFontSelected:=clwhite;
  FCaptionHeight:=8;

  fWindowCreated := false;
  DoubleBuffered := true;
  fThumbWidth := 80;
  fThumbHeight := 80;
  fUserThumbWidth := fThumbHeight;
  fUserThumbHeight := fThumbHeight;

  fContentWidth := GetControlClassDefaultSize.cx;
  fContentHeight := GetControlClassDefaultSize.cy;

  fThumbDist := 10;

  fLeftOffset := fThumbDist;
  fTopOffset := fThumbDist;
  FShowCaptions := true;
  fTextExtraHeight := 0;
  FShowPictureFrame := true;
  fPictureFrameBorder := StockBorderWidth;

  fMngr := TImageLoaderManager.Create;
  fMngr.OnLoadURL := @ImgLoadURL;
  fMngr.OnLoadPointer := @ImgLoadPointer;
  fMngr.OnNeedRepaint := @ImgRepaint;
  fAutoSort:=true;

  SmallStep := fThumbWidth;
  LargeStep := fThumbWidth * 4;

  fFrame := TBitmap.Create;

  fDirectory := GetUserDir;
end;

destructor TThumbControl.Destroy;
begin
  FURLList.Free;
  fMngr.free;
  fFrame.free;
  inherited Destroy;
end;

procedure TThumbControl.UpdateDims;
begin
  if (VScrollInfo.nMax <> fContentHeight) or (VScrollInfo.nPage <> ClientHeight) then
  begin
    fVScrollInfo.nPage := ClientHeight;
    fVScrollInfo.nMax := fContentHeight;
    CanShowV := VScrollInfo.nMax > VScrollInfo.nPage;
    UpdateVScrollInfo;
  end;
  if (HScrollInfo.nMax <> fContentWidth) or (HScrollInfo.nPage <> ClientWidth) then
  begin
    fHScrollInfo.nPage := ClientWidth;
    fHScrollInfo.nMax := fContentWidth;
    CanShowH := HScrollInfo.nMax > HScrollInfo.nPage;
    UpdateHScrollInfo;
  end;
end;

procedure TThumbControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  fMouseStartPos.x:=X;
  fMouseStartPos.y:=Y;
  fDragIDX:= fMngr.ItemIndexFromPoint(Point(X + HScrollPosition, Y + VScrollPosition));
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TThumbControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Shift=[ssLeft] then begin
    if fDragIDX>-1 then begin
      if (ABS(fMouseStartPos.x-X)>20) or (ABS(fMouseStartPos.y-Y)>20) then begin
      if fMngr.SelectedList.Count>1 then begin
        DragCursor:=crMultiDrag;
      end else begin
        DragCursor:=crDrag;
      end;
        //fDoMouseUp:=False;
        BeginDrag(True,0);
      end;
    end;
  end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TThumbControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin

  DoClick(Button,Shift,X,Y);
  inherited MouseUp(Button, Shift, X, Y);
end;

function TThumbControl.ItemFromPoint(APoint: TPoint): TThreadedImage;
begin
  Result := fMngr.ItemFromPoint(Point(APoint.X + HScrollPosition, APoint.Y + VScrollPosition));
end;

function TThumbControl.AddThreadedImage(Image: TThreadedImage): Integer;
begin
  Result:=fMngr.AddThreadedImage(Image);
end;

procedure TThumbControl.LoadSelectedBitmap(ABitmap:TBitmap);
var fi:TFPMemoryImage;
itm:TThreadedImage;
begin
  itm:=fMngr.ActiveItem;
  if itm=nil then exit;
  fi:=TFPMemoryImage.create(0,0);
  fi.UsePalette:=false;
  try
    fi.LoadFromFile(UTF8ToSys(itm.URL));
    ABitmap.Assign(fi);
  finally
    fi.free;
  end;
end;

procedure TThumbControl.ClearImageList;
begin
  fMngr.Clear;
end;

procedure TThumbControl.AddImagePointer(P: Pointer);
begin
  fMngr.AddImagePointer(P);
end;


procedure TThumbControl.ImgLoadURL(Sender: TObject);
var Ext, Fn: string;
  Img, IRes: TFPMemoryImage;
  rdjpegthumb: TFPReaderJPEG;
  area: TRect;
  Strm: TStream;
begin
  Strm := nil;
  TThreadedImage(Sender).LoadState := lsError;
  Fn := TThreadedImage(Sender).URL;
  Ext := LowerCase(ExtractFileExt(LowerCase(Fn)));
  if (Ext = '.jpg') or (Ext = '.jpeg') then
  begin
    Img := TFPMemoryImage.Create(0, 0);
    Img.UsePalette := false;
    rdjpegthumb := TFPReaderJPEG.Create;
    rdjpegthumb.MinHeight := fThumbHeight;
    rdjpegthumb.MinWidth := fThumbWidth;
    try
      if Assigned(FOnLoadFile) then OnLoadFile(Sender, Fn, Strm);
      if Strm <> nil then
      begin
        Img.LoadFromStream(Strm, rdjpegthumb);
        Strm.free;
      end else Img.LoadFromFile(UTF8ToSys(Fn), rdjpegthumb);
      IRes := ThumbResize(Img, fThumbWidth, fThumbHeight, area);
      try
        CSImg.Acquire;
        if TThreadedImage(Sender).Image <> nil
          then
        begin
          TThreadedImage(Sender).Image.Assign(IRes);
          TThreadedImage(Sender).Area := Area;
        end;
      finally
        CSImg.Release;
      end;
    finally
      IRes.free;
      rdjpegthumb.free;
      Img.free;
    end;
  end else
  begin
    Img := TFPMemoryImage.Create(0, 0);
    Img.UsePalette := false;
    try
      if Assigned(FOnLoadFile) then OnLoadFile(Sender, Fn, Strm);
      if Strm <> nil then
      begin
        Img.LoadFromStream(Strm);
        Strm.free;
      end else Img.LoadFromFile(UTF8ToSys(Fn));
      IRes := ThumbResize(Img, fThumbWidth, fThumbHeight, area);
      try
        CSImg.Acquire;
        if TThreadedImage(Sender).Image <> nil then
        begin
          TThreadedImage(Sender).Image.Assign(IRes);
          TThreadedImage(Sender).Area := Area;
        end;
      finally
        CSImg.Release;
      end;
    finally
      IRes.free;
      Img.free;
    end;
  end;
  TThreadedImage(Sender).LoadState := lsLoading;
end;

procedure TThumbControl.ImgLoadPointer(Sender: TObject);
var
  Img, IRes: TFPMemoryImage;
  area: TRect;
  Strm: TStream;
begin
  Strm := nil;
  TThreadedImage(Sender).LoadState := lsError;

  Img := TFPMemoryImage.Create(0, 0);
  Img.UsePalette := false;
  try
    if Assigned(FOnLoadPointer) then OnLoadPointer(Sender,TThreadedImage(Sender).Pointer,Strm);
    if Strm <> nil then
    begin
      Img.LoadFromStream(Strm);
      Strm.free;
    end;
    IRes := ThumbResize(Img, fThumbWidth, fThumbHeight, area);
    try
      CSImg.Acquire;
      if TThreadedImage(Sender).Image <> nil then
      begin
        TThreadedImage(Sender).Image.Assign(IRes);
        TThreadedImage(Sender).Area := Area;
      end;
    finally
      CSImg.Release;
    end;
  finally
    IRes.free;
    Img.free;
  end;
  TThreadedImage(Sender).LoadState := lsLoading;
end;


procedure TThumbControl.ImgRepaint(Sender: TObject);
var aRect: TRect;
begin
  aRect := TThreadedImage(Sender).Rect;
  OffSetRect(aRect, -HScrollPosition, -VScrollPosition);
  InflateRect(ARect, 2, 2);
  InvalidateRect(Handle, @aRect, false);
end;

class function TThumbControl.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 260;
  Result.CY := 140;
end;


procedure Register;
begin
  RegisterComponents('Misc', [TThumbControl]);
end;

initialization
{$I thumbctrl.lrs}
{$I images.lrs}
  frame := TPortableNetworkGraphic.create;
  frame.LoadFromLazarusResource('framecropab');

finalization
  frame.free;

end.

