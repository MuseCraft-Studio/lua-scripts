local a,b,c,d=(function(e)local f={[{}]=true}local g;local h={}local require;local i={}g=function(j,k)if not h[j]then h[j]=k end end;require=function(j)local l=i[j]if l then if l==f then return nil end else if not h[j]then if not e then local m=type(j)=='string'and'\"'..j..'\"'or tostring(j)error('Tried to require '..m..', but no such module has been registered')else return e(j)end end;i[j]=f;l=h[j](require,i,g,h)i[j]=l end;return l end;return require,i,g,h end)(require)c("__root",function(require,n,c,d)function plugindef()finaleplugin.Author="Robert Patterson"finaleplugin.Copyright="CC0 https://creativecommons.org/publicdomain/zero/1.0/"finaleplugin.Version="1.0"finaleplugin.Date="June 12, 2020"finaleplugin.CategoryTags="Staff"return"Group Copy Score to Part","Group Copy Score to Part","Copies any applicable groups from the score to the current part in view."end;local o=require("library.general_library")function set_draw_barline_mode(p,q)p.DrawBarlineMode=q.DrawBarlineMode;if p.DrawBarlineMode~=q.DrawBarlineMode then if q.DrawBarlineMode==finale.GROUPBARLINESTYLE_ONLYON then p.DrawBarlineMode=finale.GROUPBARLINESTYLE_ONLYBETWEEN elseif q.DrawBarlineMode==finale.GROUPBARLINESTYLE_ONLYBETWEEN then p.DrawBarlineMode=finale.GROUPBARLINESTYLE_ONLYON end end end;function staff_groups_copy_score_to_part()local r=finale.FCParts()r:LoadAll()local s=r:GetCurrent()if s:IsScore()then finenv.UI():AlertInfo("This script is only valid when viewing a part.","Not In Part View")return end;local t=finale.FCGroups()t:LoadAll()for u in each(t)do if not o.staff_group_is_multistaff_instrument(u)then u:DeleteData()end end;local v=r:GetScore()v:SwitchTo()local w=finale.FCGroups()w:LoadAll()for x in each(w)do local y=x.StartStaff;local z=x.EndStaff;if not o.staff_group_is_multistaff_instrument(x)then v:SwitchBack()if s:IsStaffIncluded(y)and s:IsStaffIncluded(z)then local p=finale.FCGroup()p.StartStaff=x.StartStaff;p.EndStaff=x.EndStaff;p.StartMeasure=x.StartMeasure;p.EndMeasure=x.EndMeasure;p.AbbreviatedNameAlign=x.AbbreviatedNameAlign;p.AbbreviatedNameExpandSingle=x.AbbreviatedNameExpandSingle;p.AbbreviatedNameHorizontalOffset=x.AbbreviatedNameHorizontalOffset;p.AbbreviatedNameJustify=x.AbbreviatedNameJustify;p.AbbreviatedNameVerticalOffset=x.AbbreviatedNameVerticalOffset;p.BarlineShapeID=x.BarlineShapeID;p.BarlineStyle=x.BarlineStyle;p.BarlineUse=x.BarlineUse;p.BracketHorizontalPos=x.BracketHorizontalPos;p.BracketSingleStaff=x.BracketSingleStaff;p.BracketStyle=x.BracketStyle;p.BracketVerticalBottomPos=x.BracketVerticalBottomPos;p.BracketVerticalTopPos=x.BracketVerticalTopPos;set_draw_barline_mode(p,x)p.EmptyStaffHide=x.EmptyStaffHide;p.FullNameAlign=x.FullNameAlign;p.FullNameExpandSingle=x.FullNameExpandSingle;p.FullNameHorizontalOffset=x.FullNameHorizontalOffset;p.FullNameJustify=x.FullNameJustify;p.FullNameVerticalOffset=x.FullNameVerticalOffset;p.ShowGroupName=x.ShowGroupName;p.UseAbbreviatedNamePositioning=x.UseAbbreviatedNamePositioning;p.UseFullNamePositioning=x.UseFullNamePositioning;if x.HasFullName and 0~=x:GetFullNameID()then p:SaveNewFullNameBlock(x:CreateFullNameString())end;if x.HasAbbreviatedName and 0~=x:GetAbbreviatedNameID()then p:SaveNewAbbreviatedNameBlock(x:CreateAbbreviatedNameString())end;p:SaveNew(0)end;v:SwitchTo()end end;v:SwitchBack()end;staff_groups_copy_score_to_part()end)c("library.general_library",function(require,n,c,d)local o={}function o.finale_version(A,B,C)local D=bit32.bor(bit32.lshift(math.floor(A),24),bit32.lshift(math.floor(B),20))if C then D=bit32.bor(D,math.floor(C))end;return D end;function o.group_overlaps_region(x,E)if E:IsFullDocumentSpan()then return true end;local F=false;local G=finale.FCSystemStaves()G:LoadAllForRegion(E)for H in each(G)do if x:ContainsStaff(H:GetStaff())then F=true;break end end;if not F then return false end;if x.StartMeasure>E.EndMeasure or x.EndMeasure<E.StartMeasure then return false end;return true end;function o.group_is_contained_in_region(x,E)if not E:IsStaffIncluded(x.StartStaff)then return false end;if not E:IsStaffIncluded(x.EndStaff)then return false end;return true end;function o.staff_group_is_multistaff_instrument(x)local I=finale.FCMultiStaffInstruments()I:LoadAll()for J in each(I)do if J:ContainsStaff(x.StartStaff)and J.GroupID==x:GetItemID()then return true end end;return false end;function o.get_selected_region_or_whole_doc()local K=finenv.Region()if K:IsEmpty()then K:SetFullDocument()end;return K end;function o.get_first_cell_on_or_after_page(L)local M=L;local N=finale.FCPage()local O=false;while N:Load(M)do if N:GetFirstSystem()>0 then O=true;break end;M=M+1 end;if O then local P=finale.FCStaffSystem()P:Load(N:GetFirstSystem())return finale.FCCell(P.FirstMeasure,P.TopStaff)end;local Q=finale.FCMusicRegion()Q:SetFullDocument()return finale.FCCell(Q.EndMeasure,Q.EndStaff)end;function o.get_top_left_visible_cell()if not finenv.UI():IsPageView()then local R=finale.FCMusicRegion()R:SetFullDocument()return finale.FCCell(finenv.UI():GetCurrentMeasure(),R.StartStaff)end;return o.get_first_cell_on_or_after_page(finenv.UI():GetCurrentPage())end;function o.get_top_left_selected_or_visible_cell()local K=finenv.Region()if not K:IsEmpty()then return finale.FCCell(K.StartMeasure,K.StartStaff)end;return o.get_top_left_visible_cell()end;function o.is_default_measure_number_visible_on_cell(S,T,U,V)local W=finale.FCCurrentStaffSpec()if not W:LoadForCell(T,0)then return false end;if S:GetShowOnTopStaff()and T.Staff==U.TopStaff then return true end;if S:GetShowOnBottomStaff()and T.Staff==U:CalcBottomStaff()then return true end;if W.ShowMeasureNumbers then return not S:GetExcludeOtherStaves(V)end;return false end;function o.is_default_number_visible_and_left_aligned(S,T,X,V,Y)if S.UseScoreInfoForParts then V=false end;if Y and S:GetShowOnMultiMeasureRests(V)then if finale.MNALIGN_LEFT~=S:GetMultiMeasureAlignment(V)then return false end elseif T.Measure==X.FirstMeasure then if not S:GetShowOnSystemStart()then return false end;if finale.MNALIGN_LEFT~=S:GetStartAlignment(V)then return false end else if not S:GetShowMultiples(V)then return false end;if finale.MNALIGN_LEFT~=S:GetMultipleAlignment(V)then return false end end;return o.is_default_measure_number_visible_on_cell(S,T,X,V)end;function o.update_layout(Z,_)Z=Z or 1;_=_ or false;local a0=finale.FCPage()if a0:Load(Z)then a0:UpdateLayout(_)end end;function o.get_current_part()local r=finale.FCParts()r:LoadAll()return r:GetCurrent()end;function o.get_page_format_prefs()local s=o.get_current_part()local a1=finale.FCPageFormatPrefs()local a2=false;if s:IsScore()then a2=a1:LoadScore()else a2=a1:LoadParts()end;return a1,a2 end;local a3=function(a4)local a5=finenv.UI():IsOnWindows()local a6=function(a7,a8)if finenv.UI():IsOnWindows()then return a7 and os.getenv(a7)or""else return a8 and os.getenv(a8)or""end end;local a9=a4 and a6("LOCALAPPDATA","HOME")or a6("COMMONPROGRAMFILES")if not a5 then a9=a9 .."/Library/Application Support"end;a9=a9 .."/SMuFL/Fonts/"return a9 end;function o.get_smufl_font_list()local aa={}local ab=function(a4)local a9=a3(a4)local ac=function()if finenv.UI():IsOnWindows()then return io.popen('dir "'..a9 ..'" /b /ad')else return io.popen('ls "'..a9 ..'"')end end;local ad=function(ae)local af=finale.FCString()af.LuaString=ae;return finenv.UI():IsFontAvailable(af)end;for ae in ac():lines()do if not ae:find("%.")then ae=ae:gsub(" Bold","")ae=ae:gsub(" Italic","")local af=finale.FCString()af.LuaString=ae;if aa[ae]or ad(ae)then aa[ae]=a4 and"user"or"system"end end end end;ab(true)ab(false)return aa end;function o.get_smufl_metadata_file(ag)if not ag then ag=finale.FCFontInfo()ag:LoadFontPrefs(finale.FONTPREF_MUSIC)end;local ah=function(ai,ag)local aj=ai..ag.Name.."/"..ag.Name..".json"return io.open(aj,"r")end;local ak=ah(a3(true),ag)if ak then return ak end;return ah(a3(false),ag)end;function o.is_font_smufl_font(ag)if not ag then ag=finale.FCFontInfo()ag:LoadFontPrefs(finale.FONTPREF_MUSIC)end;if finenv.RawFinaleVersion>=o.finale_version(27,1)then if nil~=ag.IsSMuFLFont then return ag.IsSMuFLFont end end;local al=o.get_smufl_metadata_file(ag)if nil~=al then io.close(al)return true end;return false end;function o.simple_input(am,an)local ao=finale.FCString()ao.LuaString=""local ap=finale.FCString()local aq=160;function format_ctrl(ar,as,at,au)ar:SetHeight(as)ar:SetWidth(at)ap.LuaString=au;ar:SetText(ap)end;title_width=string.len(am)*6+54;if title_width>aq then aq=title_width end;text_width=string.len(an)*6;if text_width>aq then aq=text_width end;ap.LuaString=am;local av=finale.FCCustomLuaWindow()av:SetTitle(ap)local aw=av:CreateStatic(0,0)format_ctrl(aw,16,aq,an)local ax=av:CreateEdit(0,20)format_ctrl(ax,20,aq,"")av:CreateOkButton()av:CreateCancelButton()function callback(ar)end;av:RegisterHandleCommand(callback)if av:ExecuteModal(nil)==finale.EXECMODAL_OK then ao.LuaString=ax:GetText(ao)return ao.LuaString end end;function o.is_finale_object(ay)return ay and type(ay)=="userdata"and ay.ClassName and ay.GetClassID and true or false end;function o.system_indent_set_to_prefs(X,a1)a1=a1 or o.get_page_format_prefs()local az=finale.FCMeasure()local aA=X.FirstMeasure==1;if not aA and az:Load(X.FirstMeasure)then if az.ShowFullNames then aA=true end end;if aA and a1.UseFirstSystemMargins then X.LeftMargin=a1.FirstSystemLeft else X.LeftMargin=a1.SystemLeft end;return X:Save()end;function o.calc_script_name(aB)local aC=finale.FCString()if finenv.RunningLuaFilePath then aC.LuaString=finenv.RunningLuaFilePath()else aC:SetRunningLuaFilePath()end;local aD=finale.FCString()aC:SplitToPathAndFile(nil,aD)local D=aD.LuaString;if not aB then D=D:match("(.+)%..+")if not D or D==""then D=aD.LuaString end end;return D end;return o end)return a("__root")