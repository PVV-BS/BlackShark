{
-- Begin License block --
  
  Copyright (C) 2019-2022 Pavlov V.V. (PVV)

  "Black Shark Graphics Engine" for Delphi and Lazarus (named 
"Library" in the file "License(LGPL).txt" included in this distribution). 
The Library is free software.

  Last revised June, 2022

  This file is part of "Black Shark Graphics Engine", and may only be
used, modified, and distributed under the terms of the project license 
"License(LGPL).txt". By continuing to use, modify, or distribute this
file you indicate that you have read the license and understand and 
accept it fully.

  "Black Shark Graphics Engine" is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied 
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

-- End License block --
}

unit bs.mesh.loaders;

{$I BlackSharkCfg.inc}

interface

uses
    SysUtils
  , XmlWriter
  , bs.basetypes
  , bs.mesh
  , bs.collections
  , bs.scene
  , bs.renderer
  , bs.scene.skeleton
  ;

type

  TEventLoadGraphicObjectProc = procedure(AGraphicObject: TGraphicObject) of object;
  TEventLoadSkeleton = procedure(ASkeleton: TSkeleton) of object;

  function MeshLoadObj(const FileName: string; Scale: BSFloat = 1.0): TMesh; overload;
  function MeshLoadObj(const FileName: string; LoadTo: TMesh; Scale: BSFloat = 1.0): TMesh; overload;
  // retuns one of loaded skeleton
  function MeshLoadCollada(const FileName: string; ARenderer: TBlackSharkRenderer; AEventLoadGraphicObjectProc: TEventLoadGraphicObjectProc = nil; AEventLoadSkeleton: TEventLoadSkeleton = nil): TSkeleton;

implementation

  uses
      Classes
    , bs.utils
    , bs.strings
    , bs.exceptions
    , bs.scene.objects
    , bs.texture
    {$ifdef DEBUG_BS}
    , bs.log
    {$endif}
    ;

const
  COLLADA_FORMAT_SETTINGS: TFormatSettings = (
    DecimalSeparator: {%H-}'.'
  );

type
  TStringArray = array of string;
  TFloatArray = array of BSFloat;
  TIntArray = array of int32;

function ReadStrValues(const ASource: string; ACount: NativeInt; AOffset: int32; var AValues: TStringArray): int32; inline;
var
  i, c: int32;
  val: string;
begin
  val := '';
  c := 0;
  Result := AOffset;
  SetLength(AValues, ACount);
  for i := AOffset to Length(ASource) do
  begin
    Result := i;
    if (ASource[i] = ' ') and (val <> '') then
    begin
      AValues[c] := val;
      inc(c);
      if c = ACount then
        exit;
      val := '';
    end else
      val := val + ASource[i];
  end;
  if (val <> '') then
    AValues[c] := val;
end;

function ReadIntValues(const ASource: string; ACount: int32; AOffset: int32; var AValues: TIntArray): int32; inline;
var
  i, c: int32;
  val: string;
begin
  val := '';
  c := 0;
  Result := AOffset;
  SetLength(AValues, ACount);
  for i := AOffset to Length(ASource) do
  begin
    Result := i;
    if (ASource[i] = ' ') or (ASource[i] = Char($0d)) or (ASource[i] = Char($0a)) then
    begin
      if val <> '' then
      begin
        AValues[c] := StrToInt(val);
        val := '';
        inc(c);
        if c = ACount then
          exit;
      end;
    end else
      val := val + ASource[i];
  end;
  if (val <> '') then
    TryStrToInt(val, AValues[c]);
end;

function ReadFloatValues(const ASource: string; ACount: int32; AOffset: int32; var AValues: TFloatArray): int32; inline;
var
  i, c: int32;
  val: string;
begin
  val := '';
  c := 0;
  Result := AOffset;
  SetLength(AValues, ACount);
  for i := AOffset to Length(ASource) do
  begin
    Result := i;
    if (ASource[i] = ' ') or (ASource[i] = Char($0d)) or (ASource[i] = Char($0a)) then
    begin

      if val <> '' then
      begin
        AValues[c] := StrToFloat(val, COLLADA_FORMAT_SETTINGS);
        val := '';
        inc(c);
        if c = ACount then
          exit;
      end;

    end else
    {if (ASource[i] = '.') or (ASource[i] = ',') then
      val := val + FormatSettings.DecimalSeparator
    else   }
      val := val + ASource[i];
  end;

  if (val <> '') then
    TryStrToFloat(val, AValues[c], COLLADA_FORMAT_SETTINGS);
end;

function MeshLoadCollada(const FileName: string; ARenderer: TBlackSharkRenderer; AEventLoadGraphicObjectProc: TEventLoadGraphicObjectProc = nil; AEventLoadSkeleton: TEventLoadSkeleton = nil): TSkeleton;
type
  TTypeEffect = (te2d);
  PEffect = ^TEffect;
  TEffect = record
    Id: string;
    TypeEffect: TTypeEffect;
    InitFrom: string;
    // fong attributes
    DiffuseTexture: string;
    EmissionColor: TColor4f;
    AmbientColor: TColor4f;
    SpecularColor: TColor4f;
    ShininessColor: TColor4f;
    ReflectiveColor: TColor4f;
    ReflectivityColor: TColor4f;
    TransparentColor: TColor4f;
    Transparency: BSFloat;
    // ... that's enough for now
  end;

const
  CORRECTION_Z_TO_Y: TMatrix4f =
  (V: (1.0, 0.0,  0.0, 0.0,
       0.0, 0.0, -1.0, 0.0,
       0.0, 1.0,  0.0, 0.0,
       0.0, 0.0,  0.0, 1.0
    ));

var
  xml: TheXmlWriter;
  vertexes: TListVec3f;
  // indexes vertexes map and points mesh in section: library_geometries/geometry/mesh/source/float_array::id="...mesh-positions-array"
  map_vertex_points: TListVec<TIntArray>;
  colors: TListVec4f;
  normals: TListVec3f;
  uv: TListVec2f;
  images: THashTable<string, string>;
  effects: THashTable<string, PEffect>;
  materials: THashTable<string, string>;
  skeleton: TSkeleton;
  skeletons: THashTable<string, TSkeleton>;
  skeletons_root_node: THashTable<string, TSkeleton>;
  graphicObjects: THashTable<string, TGraphicObject>;
  values_f: TFloatArray;
  values_i: TIntArray;
  values_s: TStringArray;
  // key - controller name, value - skeleton name
  controllers: THashTable<string, string>;
  upCorrection: TMatrix4f;
  upCorrectionInv: TMatrix4f;

  function DecodeChars(const Src: string): string;
  var
    i: int32;
    val: int32;
    {$ifdef FPC}
    s: AnsiString;
    {$else}
    s: string;
    {$endif}
  begin
    Result := '';
    i := 1;
    while i <= length(Src) do
    begin
      if Src[i] = '%' then
      begin
        val := 0;
        {$ifdef FPC}
        s:= StringToAnsi(Src[i+1] + Src[i+2]);

        HexToBin(PChar(@s[1]), Pointer(@val), SizeOf(val));
        {$else}
        s:= Src[i+1] + Src[i+2];
        HexToBin(PWideChar(@s[1]), Pointer(@val), SizeOf(val));
        {$endif}
        Result := Result + Char(val);
        inc(i, 3);
        continue;
      end else
        Result := Result + Src[i];
      inc(i);
    end;
  end;

  function GetMatrix(ANode: TheXmlNode; out m: TMatrix4f): boolean;
  begin
    if not Assigned(ANode) then
      exit(false);
    {%H-}ReadFloatValues(WideToString(ANode.StrData), 16, 1, values_f);
    move(values_f[0], m{%H-}, 16*SizeOf(BSFloat));
    MatrixTranspose(m);
    Result := true;
  end;

  procedure LoadImage(ANode: TheXmlNode);
  var
    n: TheXmlNode;
    id: string;
    name: string;
  begin
    n := ANode.FindChildNode('init_from', false);
    if not Assigned(n) or (n.StrData = '') then
      exit;
    id := WideToString(ANode.GetAttribute(WideString('id'), WideString('')));
    if id <> '' then
    begin
      name := DecodeChars(WideToString(n.StrData));
      if Pos('file://', name) >= 1 then
        name := Copy(name, 8, length(name)-7);
      images.TryAdd(id, name);
    end;
  end;

  function LoadEffect(ANode: TheXmlNode): boolean;
  var
    profile, n, n_param, ch: TheXmlNode;
    id: string;
    effect: PEffect;
    i, j: int32;
  begin
    id := WideToString(ANode.GetAttribute(WideString('id'), WideString('')));
    effect := nil;
    Result := false;
    try

      if id = '' then
        exit;

      profile := ANode.FindChildNode('profile_COMMON', false);
      if not Assigned(profile) then
        exit;

      new(effect);
      if not effects.TryAdd(id, effect) then
        exit;

      for i := 0 to profile.CountChilds - 1 do
      begin
        n_param := profile.Childs[i];
        if n_param.Name = 'newparam' then
        begin
          n := n_param.FindChildNode('surface', false);
          if Assigned(n) then
          begin
            n := n.FindChildNode('init_from', false);
            if Assigned(n) and (n.StrData <> '') then
            begin
              effect.InitFrom := WideToString(n.StrData);
              // maybe in future will need other params, but while no
              Result := true;
              break;
            end;
          end;
        end else
        if n_param.Name = 'technique' then
        begin
          n := n_param.FindChildNode('phong', false);
          if Assigned(n) then
          begin
            for j := 0 to n.CountChilds - 1 do
            begin
              ch := n.Childs[j];
              if ch.Name <> 'diffuse' then
                continue;
              ch := ch.FindChildNode('texture', false);
              if not Assigned(ch) then
                continue;
              effect.DiffuseTexture := ch.GetAttribute('texture', '');
              if effect.DiffuseTexture <> '' then
              begin
                Result := true;
                break;
              end;
            end;
          end;
        end;
      end;

    finally
      if not Result and Assigned(effect) then
      begin
        effects.Delete(id);
        dispose(effect);
      end;
    end;

  end;

  procedure LoadMaterial(ANode: TheXmlNode);
  var
    n: TheXmlNode;
    id, url: string;
  begin
    n := ANode.FindChildNode('instance_effect', false);
    if not Assigned(n) then
      exit;
    id := WideToString(ANode.GetAttribute(WideString('id'), WideString('')));
    if id <> '' then
    begin
      url := WideToString(n.GetAttribute(WideString('url'), WideString('')));
      if length(url) > 1 then
      begin
        url := Copy(url, 2, length(url) - 1);
        materials.TryAdd(id, url);
      end;
    end;
  end;

  function LoadMesh(AParent: TGraphicObject; ANode: TheXmlNode; const AGeometryID, AGeometryName: string): TGraphicObject;
  var
    i, j, k, l: int32;
    stride: int32;
    count: int32;
    count_arr: int32;
    id: string;
    val, val2: string;
    source: TheXmlNode;
    n, vcount: TheXmlNode;
    accessor: TheXmlNode;
    off_v, off_n, off_t, off_c: int8;
    has_n, has_c, has_t: boolean;
    tmp_int_arr: TIntArray;
    v: TVec3f;
    isPolylists: boolean;
    isPolygons: boolean;
    offset, offset_before: int8;
    effect: PEffect;
  begin
    n := ANode.FindChildNode('triangles', false);
    if not Assigned(n) then
    begin
      n := ANode.FindChildNode('polylist', false);
      if not Assigned(n) then
        n := ANode.FindChildNode('polygons', false);
    end;

    val := '';
    if Assigned(n) then
    begin
      id := n.GetAttribute('material', '');
      if id <> '' then
      begin
        if materials.Find(id, val) and (val <> '') then
        begin
          if effects.Find(val, effect) then
          begin
            if images.Find(effect.InitFrom, val) then
              val := IncludeTrailingPathDelimiter(ExtractFileDir(xml.URL)) + val
            else
            if images.Find(effect.DiffuseTexture, val) then
              val := IncludeTrailingPathDelimiter(ExtractFileDir(xml.URL)) + val
            else
              val := '';
          end else
            val := '';
        end;
      end;
    end;

    if (val = '') or not FileExists(val) then
    begin
      val := ChangeFileExt(xml.URL, '.png');
      if not FileExists(val) then
      begin
        val := ChangeFileExt(xml.URL, '.jpg');
        if not FileExists(val) then
          val := ChangeFileExt(xml.URL, '.bmp');
      end;
    end;

    if FileExists(val) then
    begin
      Result := TTexturedVertexes.Create(nil, AParent, ARenderer.Scene);
      TTexturedVertexes(Result).Texture := BSTextureManager.LoadTexture(val);
    end else
      Result := TColoredVertexes.Create(nil, AParent, ARenderer.Scene);

    Result.Caption := AGeometryName;
    graphicObjects.Items[AGeometryID] := Result;
    vertexes.Count := 0;
    uv.Count := 0;
    normals.Count := 0;
    colors.Count := 0;
    map_vertex_points.Clear;

    has_n := Result.Mesh.HasComponent(TVertexComponent.vcNormal);
    has_c := Result.Mesh.HasComponent(TVertexComponent.vcColor);
    has_t := Result.Mesh.HasComponent(TVertexComponent.vcTexture1);
    for i := 0 to ANode.CountChilds - 1 do
    begin
      source := ANode.Childs[i];
      if source.Name = 'source' then
      begin
        id := source.GetAttribute('id', '');
        if id = '' then
          continue;

        if (id = AGeometryID + '-positions') or (id = AGeometryID + '-Position') then
        begin
          accessor := source.FindChildNode('accessor', true);
          if not Assigned(accessor) then
            continue;
          count := accessor.GetAttribute('count', 0);
          if (count = 0) then
            continue;
          stride := accessor.GetAttribute('stride', 3);
          n := source.FindChildNode('float_array');
          if not Assigned(n) then
            continue;
          count_arr := n.GetAttribute('count', 0);
          if count_arr <> count*stride then
            continue;

          SetLength(values_f, stride);
          j := 1;
          vertexes.Capacity := (count div stride);
          val := WideToString(n.StrData);
          l := length(val);
          while j < l do
          begin
            j := ReadFloatValues(val, stride, j, values_f);
            if stride = 2 then
              vertexes.Add(vec3(values_f[0], values_f[1], 0.0))
            else
              vertexes.Add(vec3(values_f[0], values_f[1], values_f[2]))
          end;

        end else
        if (id = AGeometryID + '-normals') or (id = AGeometryID + '-Normal0') then
        begin

        end else
        if (id = AGeometryID + '-map-0') or (id = AGeometryID + '-UV0') then // UV
        begin
          n := source.FindChildNode('accessor', true);
          if not Assigned(n) then
            continue;
          stride := n.GetAttribute('stride', 0);
          if stride <> 2 then
            continue;
          count := n.GetAttribute('count', 0);
          SetLength(values_f, stride);
          n := source.FindChildNode('float_array');
          if not Assigned(n) then
            continue;
          j := 1;
          l := length(n.StrData);
          uv.Capacity := count div stride;
          val := WideToString(n.StrData);
          while j < l do
          begin
            j := ReadFloatValues(val, stride, j, values_f);
            uv.Add(vec2(values_f[0], values_f[1]));
          end;
        end else
        if id = AGeometryID + '-colors-Col' then
        begin

        end;
      end else
      if (source.Name = 'triangles') or (source.Name = 'polylist') or (source.Name = 'polygons') then
      begin
        off_v := 0;
        off_n := 0;
        off_t := 0;
        off_c := 0;
        SetLength(values_i, 4);
        stride := 0;
        offset_before := -1;
        isPolylists := (source.Name = 'polylist');
        isPolygons := (source.Name = 'polygons');
        for j := 0 to source.CountChilds - 1 do
        begin
          n := source.Childs[j];
          if n.Name <> 'input' then
          begin
            if isPolygons then
              break
            else
              continue;
          end;
          val := n.GetAttribute('semantic', '');
          offset := n.GetAttribute('offset', 0);
          if offset <> offset_before then
            inc(stride);
          offset_before := offset;
          if val = 'VERTEX' then
            off_v := offset
          else
          if val = 'NORMAL' then
            off_n := offset
          else
          if val = 'TEXCOORD' then
            off_t := offset
          else
          if val = 'COLOR' then
            off_c := offset;
        end;

        if isPolylists then
          vcount := source.FindChildNode('vcount')
        else
          vcount := nil;

        if Assigned(vcount) then
        begin
          j := 1;
          k := 1;
          n := source.FindChildNode('p');
          if not Assigned(n) then
            continue;
          val := WideToString(vcount.StrData);
          val2 := WideToString(n.StrData);
          l := length(val);
          while (k < l) do
          begin
            k := ReadIntValues(val, 1, k, values_i);
            count := values_i[0];
            // TODO: polylist contains contour which need triangulate, but while I saw polylists consist of three points only
            if count > 3 then
              raise ETODO.Create('TODO: need triangulate the countour! Write me on shark.engl@gmail.com, and I will do it');

            while (j < length(val2)) and (count > 0) do
            begin
              dec(count);
              j := ReadIntValues(val2, stride, j, values_i);

              // mapping of vertex indexes and index points of the mesh
              tmp_int_arr := map_vertex_points.Items[values_i[off_v]];
              SetLength(tmp_int_arr, Length(tmp_int_arr)+1);
              tmp_int_arr[length(tmp_int_arr)-1] := Result.Mesh.CountVertex;
              map_vertex_points.Items[values_i[off_v]] := tmp_int_arr;

              Result.Mesh.Indexes.Add(Result.Mesh.CountVertex);
              v := vertexes.Items[values_i[off_v]];
              //v := upCorrection*v;
              Result.Mesh.AddVertex(v);

              if has_n then
                Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcNormal, normals.Items[values_i[off_n]]);//upCorrection*
              if has_c then
                Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcColor, colors.Items[values_i[off_c]]);
              if has_t then
                Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcTexture1, uv.Items[values_i[off_t]]);
            end;
          end;
        end else
        if isPolygons then
        begin
          for j := stride to source.CountChilds - 1 do
          begin
            n := source.Childs[j];
            l := 1;
            val := WideToString(n.StrData);
            while (l < length(val)) do
            begin
              l := ReadIntValues(val, stride, l, values_i);

              // mapping of vertex indexes and index points of the mesh
              tmp_int_arr := map_vertex_points.Items[values_i[off_v]];
              SetLength(tmp_int_arr, Length(tmp_int_arr)+1);
              tmp_int_arr[length(tmp_int_arr)-1] := Result.Mesh.CountVertex;
              map_vertex_points.Items[values_i[off_v]] := tmp_int_arr;

              Result.Mesh.Indexes.Add(Result.Mesh.CountVertex);
              v := vertexes.Items[values_i[off_v]];
              //v := upCorrection*v;
              Result.Mesh.AddVertex(v);

              if has_n then
                Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcNormal, normals.Items[values_i[off_n]]);//upCorrection*
              if has_c then
                Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcColor, colors.Items[values_i[off_c]]);
              if has_t then
                Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcTexture1, uv.Items[values_i[off_t]]);
            end;
          end;

        end else
        begin
          n := source.FindChildNode('p');
          if not Assigned(n) then
            continue;
          j := 1;
          l := length(n.StrData);
          Result.Mesh.CapacityVertex := source.GetAttribute('count', 0);
          while j < l do
          begin
            j := ReadIntValues(WideToString(n.StrData), stride, j, values_i);

            // mapping of vertex indexes and index points of the mesh
            tmp_int_arr := map_vertex_points.Items[values_i[off_v]];
            SetLength(tmp_int_arr, Length(tmp_int_arr)+1);
            tmp_int_arr[length(tmp_int_arr)-1] := Result.Mesh.CountVertex;
            map_vertex_points.Items[values_i[off_v]] := tmp_int_arr;

            Result.Mesh.Indexes.Add(Result.Mesh.CountVertex);
            v := vertexes.Items[values_i[off_v]];
            //v := upCorrection*v;
            Result.Mesh.AddVertex(v);

            if has_n then
              Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcNormal, normals.Items[values_i[off_n]]);//upCorrection*
            if has_c then
              Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcColor, colors.Items[values_i[off_c]]);
            if has_t then
              Result.Mesh.Write(Result.Mesh.CountVertex-1, TVertexComponent.vcTexture1, uv.Items[values_i[off_t]]);
          end;
        end;
      end;


    end;
    Result.Position := upCorrection*Result.Mesh.CalcBoundingBox(true);
    Result.ChangedMesh;
  end;

  function LoadNode(AParent: TBone; ANode: TheXmlNode; const ARootTransformation, ARootTransformationUp: TMatrix4f): TBone;
  var
    n, sn: TheXmlNode;
    kind: string;
    i: int32;
    sk: TSkeleton;
    s: string;
    m: TMatrix4f;
    tip, offset: TVec3f;
    go: TGraphicObject;
  begin
    Result := nil;
    kind := ANode.GetAttribute('type', '');
    if kind = 'JOINT' then
    begin

      if not Assigned(skeleton) then
      begin
        skeleton := TSkeleton.Create(nil, ARenderer);
        skeleton.Caption := ANode.GetAttribute('id', '');
        skeletons.Items[skeleton.Caption] := skeleton;
        // root node for skeleton; need for a bind of animations to skeleton and its bones
        s := ANode.Parent.GetAttribute('id', '');
        {%H-}skeletons_root_node.TryAdd(s, skeleton);
        s := ANode.Parent.GetAttribute('name', '');
        // double registration the same skeleton, because of some models links by id, another by name
        if (s <> '') and (s <> skeleton.Caption) then
          {%H-}skeletons_root_node.TryAdd(s, skeleton);
        skeleton.ParentTransforms := ARootTransformationUp;
      end;

      Result := skeleton.CreateBone(ANode.GetAttribute('name', ''), ANode.GetAttribute('sid', ''), AParent);

      // transformations relatively center of the skeleton
      if GetMatrix(ANode.FindChildNode('matrix'), m) then
      begin
        if Assigned(AParent) then
        begin
          Result.Transform := m
        end else
        begin
          Result.Transform := m*ARootTransformationUp;
        end;
      end;

      n := ANode.FindChildNode('extra');
      if Assigned(n) then
      begin
        n := n.FindChildNode('technique');
        if Assigned(n) then
        begin
          tip := vec3(0.0, 0.0, 0.0);

          sn := n.FindChildNode('tip_x');
          if Assigned(sn) then
          begin
            TryStrToFloat(WideToString(sn.StrData), tip.x, COLLADA_FORMAT_SETTINGS);

            sn := n.FindChildNode('tip_y');
            if Assigned(sn) then
              TryStrToFloat(WideToString(sn.StrData), tip.y, COLLADA_FORMAT_SETTINGS);

            sn := n.FindChildNode('tip_z');
            if Assigned(sn) then
              TryStrToFloat(WideToString(sn.StrData), tip.z, COLLADA_FORMAT_SETTINGS);
            //tip := ARootTransformation*tip;
          end;

          sn := n.FindChildNode('connect');
          if Assigned(sn) and (sn.StrData = '1') then
          begin
            Result.Parent.Tip := TVec3f(Result.Transform.M3);
            Result.Parent.ChildConnected := Result;
          end;

          tip := upCorrection*tip;
          Result.Tip := tip;
        end;
      end;

      for i := 0 to ANode.CountChilds - 1 do
        LoadNode(Result, ANode.Childs[i], ARootTransformation, ARootTransformationUp);

    end else
    begin
      if kind = 'NODE' then
      begin
        if ANode.GetAttribute('id', '') = 'Camera' then
        begin

        end else
        begin
          // try to link skeleton and graphic object
          n := ANode.FindChildNode('instance_controller');

          if Assigned(n) then
          begin
            sn := n.FindChildNode('skeleton');
            if Assigned(sn) and (sn.StrData <> '') then
            begin
              s := Copy(WideToString(sn.StrData), 2, length(sn.StrData)-1);

              if skeletons.Find(s, sk) then
              begin
                s := n.GetAttribute('url', '');
                if s <> '' then
                  controllers.Items[Copy(s, 2, length(s)-1)] := sk.Caption;
              end;

            end;
          end else
          begin
            n := ANode.FindChildNode('instance_geometry');
            if Assigned(n) then
            begin
                s := n.GetAttribute('url', '');
                if length(s) > 1 then
                begin
                  s := copy(s, 2, length(s)-1);
                  if graphicObjects.Find(s, go) then
                  begin
                    if GetMatrix(ANode.FindChildNode('matrix'), m) then
                      m := m*ARootTransformation
                    else
                      m := ARootTransformation;

                    // because of the matrix can occur the object distortions,
                    // therefore takes into account offset of its center (local postion)
                    offset := go.Mesh.Transform(TMatrix3f(m), true);
                    go.Position := upCorrection*(offset + m*(upCorrectionInv*go.Position));
                    if Assigned(skeleton) then
                      skeleton.Skin := go;
                  end;
                end;
            end;

          end;
        end;

        // todo - bind_material node

        if not GetMatrix(ANode.FindChildNode('matrix'), m) then
          m := IDENTITY_MAT;

        for i := 0 to ANode.CountChilds - 1 do
          LoadNode(AParent, ANode.Childs[i], m*ARootTransformation, m*ARootTransformationUp);
      end;
    end;
  end;

  procedure LoadController(ANode: TheXmlNode);
  var
    id: string;
    pairs: TIntArray;

    procedure LoadSource(ASource: TheXmlNode);
    var
      id_source: string;
      n: TheXmlNode;
      count: int32;
    begin
      if ASource.Name = 'source' then
      begin
        id_source := ASource.GetAttribute('id', '');
        if id_source = id + '-joints' then // bones array
        begin
          n := ASource.FindChildNode('Name_array');
          if not Assigned(n) then
            exit;
          count := n.GetAttribute('count', 0);
          if count = 0 then
            exit;

          ReadStrValues(WideToString(n.StrData), count, 1, values_s);
        end else
        if id_source = id + '-bind_poses' then  // matrixes of bones
        begin

        end else
        if id_source = id + '-weights' then
        begin
          n := ASource.FindChildNode('float_array');
          if not Assigned(n) then
            exit;
          count := n.GetAttribute('count', 0);
          if count = 0 then
            exit;
          ReadFloatValues(WideToString(n.StrData), count, 1, values_f);
        end;
      end else
      if ASource.Name = 'joints' then
      begin

      end else
      if ASource.Name = 'vertex_weights' then
      begin
        count := ASource.GetAttribute('count', 0);
        if count = 0 then
          exit;
        { Contains a list of integers, each specifying the number of
          bones associated with one of the influences defined by
          <vertex_weights>. This element has no attributes. }
        n := ASource.FindChildNode('vcount');
        if not Assigned(n) then
          exit;

        ReadIntValues(WideToString(n.StrData), count, 1, values_i);
        { Contains a list of indices that describe which bones and
          attributes are associated with each vertex. An index of -1
          into the array of joints refers to the bind shape. Weights
          should be normalized before use. This element has no
          attributes. }
        n := ASource.FindChildNode('v');
        if not Assigned(n) then
          exit;

        ReadIntValues(WideToString(n.StrData), length(values_f)*2, 1, pairs);
      end;
    end;

  var
    n_skin: TheXmlNode;
    s: string;
    go: TGraphicObject;
    sk: TSkeleton;
    i, j, k: int32;
    bone: TBone;
    tmp_int_arr: TIntArray;
    m: TMatrix4f;
    offset: TVec3f;
  begin
    id := ANode.GetAttribute('id', '');
    if not controllers.Find(id, s) then
      exit;

    if not skeletons.Find(s, sk) then
      exit;

    n_skin := ANode.FindChildNode('skin');
    if not Assigned(n_skin) then
      exit;

    s := n_skin.GetAttribute('source', '');
    if s = '' then
      exit;

    s := Copy(s, 2, length(s)-1);
    if not graphicObjects.Find(s, go) then
      exit;

    {
      mesh transformations in controller
    }

    if GetMatrix(n_skin.FindChildNode('bind_shape_matrix'), m) then
      m := m*(sk.ParentTransforms*upCorrectionInv)
    else
      m := sk.ParentTransforms*upCorrectionInv;

    offset := go.Mesh.Transform(TMatrix3f(m), true);
    //go.Position := upCorrection*TVec3f(m.M3) + TMatrix3f(m)*go.Position;
    go.Position := upCorrection*(offset + m*(upCorrectionInv*go.Position));
    sk.Skin := go;

    for i := 0 to n_skin.CountChilds - 1 do
      LoadSource(n_skin.Childs[i]);

    if length(values_i) <> vertexes.Count then
      exit;

    // link bones influence (weight) to virtexes with
    i := 0;
    j := 0;
    while i < length(values_i) do
    begin
      while values_i[i] > 0 do
      begin
        if sk.Bones.Find(values_s[{%H-}pairs[j]], bone) then
        begin
          tmp_int_arr := map_vertex_points.Items[i];
          for k := 0 to length(tmp_int_arr)-1 do
            bone.BindVertex(tmp_int_arr[k], values_f[pairs[j + 1]]);
        end;
        dec(values_i[i]);
        inc(j, 2);
      end;
      inc(i);
    end;
  end;

  procedure LoadAnimation(ANode: TheXmlNode; ASingleName: boolean);
  var
    n: TheXmlNode;
    id: string;
    name: string;
    name_name: string;
    i: int32;
    bone: TBone;
    s: string;
    sk: TSkeleton;
    bugHas: boolean;
    t: TFloatArray;

    procedure LoadSource(ASource: TheXmlNode);
    var
      s_id: string;
      nn: TheXmlNode;
      count: int32;
    begin
      s_id := ASource.GetAttribute('id', '');
      if s_id = id + '-input' then
      begin
        // time
        nn := ASource.FindChildNode('float_array');
        if not Assigned(nn) then
          exit;
        count := nn.GetAttribute('count', 0);
        if count = 0 then
          exit;
        ReadFloatValues(WideToString(nn.StrData), count, 1, t);
      end else
      if s_id = id + '-output' then
      begin
        // matrixes
        nn := ASource.FindChildNode('float_array');
        if not Assigned(nn) then
          exit;
        count := nn.GetAttribute('count', 0);
        if count = 0 then
          exit;
        ReadFloatValues(WideToString(nn.StrData), count, 1, values_f);
      end else
      if s_id = id + '-interpolation' then
      begin

      end;
    end;

  var
    sa: TSkeletonAnimation;
    m: TMatrix4f;
    hasNotName: boolean;
  begin

    if ANode.Name <> 'animation' then
      exit;

    n := ANode.FindChildNode('animation');
    if Assigned(n) then
    begin
      for i := 0 to ANode.CountChilds - 1 do
        LoadAnimation(ANode.Childs[i], false);
      exit;
    end;

    id := ANode.GetAttribute('id', '');
    if (id = '') then
      exit;

    name := ANode.GetAttribute('name', '');
    if (name = '') then
    begin
      hasNotName := true;
      name := id;
      i := Pos('_', id);
      if i > 0 then
        name := Copy(id, 1, i-1);
    end else
      hasNotName := false;

    if not skeletons_root_node.Find(name, sk) then
      exit;

    name_name := name;
    bugHas := false;
    if (length(name) < length(id)) and CompareMem(@id[1], @name[1], length(name)) then
    begin
      // bug of Blender - name of an animation contains in attribute "id"
      bugHas := true;
      i := Pos('_', id, length(name)+1);
      if i > 0 then
        name := Copy(id, i+1, pos('_', id, i+1)-i-1);
    end;

    n := ANode.FindChildNode('channel');
    if not Assigned(n) then
      exit;
    s := n.GetAttribute('target', '');

    s := Copy(s, 1, Pos('/', s)-1);

    if bugHas and (length(name_name) < length(s)) and CompareMem(@s[1], @name_name[1], length(name_name)) then
    begin
      s := Copy(s, length(name_name)+2, length(s)-length(name_name)-1);
    end;

    if not sk.Bones.Find(s, bone) then
      exit;

    for i := 0 to ANode.CountChilds - 1 do
      LoadSource(ANode.Childs[i]);

    if ASingleName and hasNotName then
      sa := sk.CreateAnimation(name_name)
    else
      sa := sk.CreateAnimation(name);

    for i := 0 to length({%H-}t)-1 do
    begin
      move(values_f[i*16], m{%H-}, SizeOf(m));
      MatrixTranspose(m);
      if Assigned(bone.Parent) then
        sa.CreateKeyFrame(bone, round(t[i]*1000), m, TInterpolateSpline.isNone)
      else
        sa.CreateKeyFrame(bone, round(t[i]*1000), m*upCorrection, TInterpolateSpline.isNone)
    end;
  end;

var
  i, j: int32;
  node: TheXmlNode;
  geometry: TheXmlNode;
  mesh: TheXmlNode;
  bucket: THashTable<string, TSkeleton>.TBucket;
  bucket_go: THashTable<string, TGraphicObject>.TBucket;
  bucket_eff: THashTable<string, PEffect>.TBucket;
  filePath: string;
begin
  Result := nil;
  filePath := GetFilePath(FileName);
  if not FileExists(filePath) then
  begin
    {$ifdef DEBUG_BS}
    BSWriteMsg('MeshLoadCollada', 'File "' + FileName + '" doesn''''t exists!');
    {$endif}
    exit;
  end;
  {$ifdef DEBUG_BS}
  BSWriteMsg('MeshLoadCollada', '...loading collada model: ' + filePath);
  {$endif}
  xml := TheXmlWriter.Create(filePath, true);
  try
    if not Assigned(xml.Root) then
    begin
      {$ifdef DEBUG_BS}
      BSWriteMsg('MeshLoadCollada', 'if not Assigned(xml.Root) then');
      {$endif}
      exit;
    end;

    upCorrection := IDENTITY_MAT;
    node := xml.Root.FindChildNode('asset');
    if Assigned(node) then
    begin
      node := node.FindChildNode('up_axis');
      if Assigned(node) then
      begin
        if node.StrData = 'Z_UP' then
        begin
          upCorrection := CORRECTION_Z_TO_Y;
        end;
      end;
    end;

    upCorrectionInv := upCorrection;
    MatrixInvert(upCorrectionInv);

    images := THashTable<string, string>.Create(@GetHashBlackSharkS, @StrCmpBool);
    effects := THashTable<string, PEffect>.Create(@GetHashBlackSharkS, @StrCmpBool);
    materials := THashTable<string, string>.Create(@GetHashBlackSharkS, @StrCmpBool);
    graphicObjects := THashTable<string, TGraphicObject>.Create(@GetHashBlackSharkS, @StrCmpBool);
    map_vertex_points := TListVec<TIntArray>.Create;
    vertexes := TListVec3f.Create;
    try

      node := xml.Root.FindChildNode('library_images');
      if Assigned(node) then
      begin
        for i := 0 to node.CountChilds - 1 do
          LoadImage(node.Childs[i]);
      end;

      node := xml.Root.FindChildNode('library_effects');
      if Assigned(node) then
      begin
        for i := 0 to node.CountChilds - 1 do
          LoadEffect(node.Childs[i]);
      end;

      node := xml.Root.FindChildNode('library_materials');
      if Assigned(node) then
      begin
        for i := 0 to node.CountChilds - 1 do
          LoadMaterial(node.Childs[i]);
      end;

      node := xml.Root.FindChildNode('library_geometries');
      if not Assigned(node) then
        exit;

      uv := TListVec2f.Create;
      colors := TListVec4f.Create;
      normals := TListVec3f.Create;
      try

        for i := 0 to node.CountChilds - 1 do
        begin
          geometry := node.Childs[i];
          mesh := geometry.FindChildNode('mesh');
          if not Assigned(mesh) then
            continue;
          LoadMesh(nil, mesh, geometry.GetAttribute('id', 'mesh'), geometry.GetAttribute('name', 'name'));
        end;

      finally
        uv.Free;
        colors.Free;
        normals.Free;
      end;

      node := xml.Root.FindChildNode('library_visual_scenes');
      if not Assigned(node) then
        exit;

      controllers := THashTable<string, string>.Create(@GetHashBlackSharkS, @StrCmpBool);
      try
        skeletons := THashTable<string, TSkeleton>.Create(@GetHashBlackSharkS, @StrCmpBool);
        skeletons_root_node := THashTable<string, TSkeleton>.Create(@GetHashBlackSharkS, @StrCmpBool);
        try
          SetLength(values_f, 16);
          for i := 0 to node.CountChilds - 1 do
          begin
            geometry := node.Childs[i];
            if geometry.Name <> 'visual_scene' then
              continue;

            for j := 0 to geometry.CountChilds - 1 do
            begin
              skeleton := nil;
              LoadNode(nil, geometry.Childs[j], IDENTITY_MAT, upCorrection);
            end;
          end;

          node := xml.Root.FindChildNode('library_controllers');
          if Assigned(node) then
          begin
            for i := 0 to node.CountChilds - 1 do
            begin
              LoadController(node.Childs[i]);
            end;
          end;

          node := xml.Root.FindChildNode('library_animations');
          if Assigned(node) then
          begin
            for i := 0 to node.CountChilds - 1 do
            begin
              LoadAnimation(node.Childs[i], true);
            end;
          end;

          if skeletons.GetFirst(bucket) then
          begin
            Result := bucket.Value;
            if Assigned(AEventLoadSkeleton) then
            repeat
              AEventLoadSkeleton(bucket.Value);
            until not skeletons.GetNext(bucket);
          end;

        finally
          skeletons.Free;
          skeletons_root_node.Free;
        end;

      finally
        controllers.Free;
      end;

      if graphicObjects.GetFirst(bucket_go) then
      repeat
        bucket_go.Value.Mesh.Transform(upCorrection, true);
        bucket_go.Value.ChangedMesh;
        if Assigned(AEventLoadGraphicObjectProc) then
          AEventLoadGraphicObjectProc(bucket_go.Value);
      until not graphicObjects.GetNext(bucket_go);

      if effects.GetFirst(bucket_eff) then
      repeat
        dispose(bucket_eff.Value);
      until not effects.GetNext(bucket_eff);

    finally
      vertexes.Free;
      map_vertex_points.Free;
      graphicObjects.Free;
      materials.Free;
      effects.Free;
      images.Free;
    end;

  finally
    xml.Free;
  end;
end;

function MeshLoadObj(const FileName: string; Scale: BSFloat): TMesh;
begin
  Result := TMeshPTN.Create;
  if MeshLoadObj(FileName, Result, Scale) = nil then
    FreeAndNil(Result);
end;

function MeshLoadObj(const FileName: string; LoadTo: TMesh; Scale: BSFloat = 1.0): TMesh;

var
  s: string;
  dec_cep: Char;
  values: array of string;


  function ReadValues(Separator1, Separator2: Char; out CountGroups: int8): int8;
  var
    k, c: int32;
    ch: Char;
  begin
    if length(s) = 0 then
      exit(0);
    Result := 1;
    for k := 0 to length(values)-1 do
      values[k] := '';

    CountGroups := 0;
    c := 0;
    for k := 3 to length(s) do
    begin
      if (s[k] = Separator1) or (s[k] = Separator2) then
      begin
        if (values[c] <> '') then
        begin
          inc(c);
          if c = length(values) then
            SetLength(values, c+4);
        end;
        if (s[k] = '/') then
          inc(Result)
        else
        if (s[k] = ' ') then
        begin
          inc(CountGroups);
          Result := 1;
        end;
        continue;
      end;
      ch := s[k];
      if not (CharInSet(ch, ['0'..'9', '.', ',', '-'])) then
        continue;
      if CharInSet(ch, ['.', ',']) and (dec_cep <> ch) then
        ch := dec_cep;
      values[c] := values[c] + ch;
    end;
    if (Result > 0) and (s[length(s)] <> ' ') then
      inc(CountGroups);
  end;

var
  count_groups: int8;
  sl: TStringList;
  fild: string;
  fn: string;
  v3: TVec3f;
  v2: TVec2f;
  Vertexes: TListVec3f;
  UV: TListVec2f;
  Normals: TListVec3f;
  i, j, index, index_vert: int32;
  ind_before1, ind_before2: int32;
  groupe_size: int8;
  normal_load: boolean;
  uv_load: boolean;

begin
  fn := GetFilePath(FileName);
  if not FileExists(fn) then
    exit(nil);
  Result := LoadTo;
  normal_load := LoadTo.HasComponent(vcNormal);
  uv_load := LoadTo.HasComponent(vcTexture1);
  dec_cep := FormatSettings.DecimalSeparator;
  Vertexes := TListVec3f.Create;
  UV := TListVec2f.Create;
  Normals := TListVec3f.Create;
  sl := TStringList.Create;
  fild := '';
  SetLength(fild, 2);
  SetLength(values, 9);
  try
    sl.LoadFromFile(fn);
    for i := 0 to sl.Count - 1 do
    begin
      s := sl.Strings[i];
      if length(s) < 5 then
        continue;
      fild := Copy(s, 0, 2);
      if (fild = '# ') then
        continue;

      if (fild = 'v ') then
      begin
        ReadValues(' ', ' ', count_groups);
        v3.x := StrToFloat(values[0]) * Scale;
        v3.y := StrToFloat(values[1]) * Scale;
        v3.z := StrToFloat(values[2]) * Scale;
        Vertexes.Add(v3);
      end else
      if (fild = 'vt') then
      begin
        if uv_load then
        begin
          ReadValues(' ', ' ', count_groups);
          v2.x := StrToFloat(values[0]);
          v2.y := StrToFloat(values[1]);
          UV.Add(v2);
        end;
      end else
      if (fild = 'vn') then
      begin
        if normal_load then
        begin
          ReadValues(' ', ' ', count_groups);
          v3.x := StrToFloat(values[0]);
          v3.y := StrToFloat(values[1]);
          v3.z := StrToFloat(values[2]);
          Normals.Add(v3);
        end;
      end else
      if (fild = 'f ') then
      begin
        //continue;
        groupe_size := ReadValues('/', ' ', count_groups);
        ind_before1 := -1;
        ind_before2 := -1;
        for j := 0 to count_groups - 1 do
        begin
          // index vertex
          index := StrToInt(values[j*groupe_size])-1;
          begin
            index_vert := Result.AddVertex(Vertexes.Items[index]);
            if (uv_load) and (values[j*groupe_size+1] <> '') then
            begin
              // index UV
              Result.Write(index_vert, vcTexture1, UV.Items[StrToInt(values[j*groupe_size+1]) - 1]);
            end;

            if (normal_load) and (values[j*groupe_size+2] <> '') then
            begin
              // index Normal
              Result.Write(index_vert, vcNormal, Normals.Items[StrToInt(values[j*groupe_size+2]) - 1]);
            end;
          end;
          Result.Indexes.Add(index_vert);
          // contains of geometry, not triangles; you need to triangulate a model, because it can loaded wrong;
          if j > 2 then
          begin
            Result.Indexes.Add(ind_before2);
            Result.Indexes.Add(ind_before1);
          end;
          ind_before2 := ind_before1;
          ind_before1 := index_vert;
        end;
      end;
    end;
  finally
    sl.Free;
    Vertexes.Free;
    Normals.Free;
    UV.Free;
    fild := '';
  end;
  Result.CalcBoundingBox(true);
end;

end.

