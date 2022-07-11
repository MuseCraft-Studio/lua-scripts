local a,b,c,d=(function(e)local f={[{}]=true}local g;local h={}local require;local i={}g=function(j,k)if not h[j]then h[j]=k end end;require=function(j)local l=i[j]if l then if l==f then return nil end else if not h[j]then if not e then local m=type(j)=='string'and'\"'..j..'\"'or tostring(j)error('Tried to require '..m..', but no such module has been registered')else return e(j)end end;i[j]=f;l=h[j](require,i,g,h)i[j]=l end;return l end;return require,i,g,h end)(require)c("__root",function(require,n,c,d)function plugindef()finaleplugin.Author="Robert Patterson"finaleplugin.Copyright="CC0 https://creativecommons.org/publicdomain/zero/1.0/"finaleplugin.Version="1.0"finaleplugin.Date="June 21, 2020"finaleplugin.CategoryTags="Measure"return"Measure Numbers Move Up","Measure Numbers Move Up","Moves selected measure numbers up by one staff space."end;local o=require("library.general_library")local p=24;function measure_numbers_move_up()local q=finale.FCStaffSystems()q:LoadAll()local r=finale.FCMeasureNumberRegions()r:LoadAll()local s=finale.FCParts()s:LoadAll()local t=s:GetCurrent()local u=not t:IsScore()local v=o.get_selected_region_or_whole_doc()local w=finale.FCCells()w:ApplyRegion(v)for x in each(w)do local y=q:FindMeasureNumber(x.Measure)local z=r:FindMeasure(x.Measure)if nil~=y and nil~=z then if o.is_default_measure_number_visible_on_cell(z,x,y,u)then local A=finale.FCSeparateMeasureNumbers()A:LoadAllInCell(x)if A.Count>0 then for B in each(A)do B.VerticalPosition=B.VerticalPosition+p;B:Save()end else local B=finale.FCSeparateMeasureNumber()B:ConnectCell(x)B:AssignMeasureNumberRegion(z)B.VerticalPosition=B.VerticalPosition+p;if B:SaveNew()then local C=finale.FCMeasure()C:Load(x.Measure)C:SetContainsManualMeasureNumbers(true)C:Save()end end end end end end;measure_numbers_move_up()end)c("library.general_library",function(require,n,c,d)local o={}function o.finale_version(D,E,F)local G=bit32.bor(bit32.lshift(math.floor(D),24),bit32.lshift(math.floor(E),20))if F then G=bit32.bor(G,math.floor(F))end;return G end;function o.group_overlaps_region(H,I)if I:IsFullDocumentSpan()then return true end;local J=false;local K=finale.FCSystemStaves()K:LoadAllForRegion(I)for L in each(K)do if H:ContainsStaff(L:GetStaff())then J=true;break end end;if not J then return false end;if H.StartMeasure>I.EndMeasure or H.EndMeasure<I.StartMeasure then return false end;return true end;function o.group_is_contained_in_region(H,I)if not I:IsStaffIncluded(H.StartStaff)then return false end;if not I:IsStaffIncluded(H.EndStaff)then return false end;return true end;function o.staff_group_is_multistaff_instrument(H)local M=finale.FCMultiStaffInstruments()M:LoadAll()for N in each(M)do if N:ContainsStaff(H.StartStaff)and N.GroupID==H:GetItemID()then return true end end;return false end;function o.get_selected_region_or_whole_doc()local v=finenv.Region()if v:IsEmpty()then v:SetFullDocument()end;return v end;function o.get_first_cell_on_or_after_page(O)local P=O;local Q=finale.FCPage()local R=false;while Q:Load(P)do if Q:GetFirstSystem()>0 then R=true;break end;P=P+1 end;if R then local S=finale.FCStaffSystem()S:Load(Q:GetFirstSystem())return finale.FCCell(S.FirstMeasure,S.TopStaff)end;local T=finale.FCMusicRegion()T:SetFullDocument()return finale.FCCell(T.EndMeasure,T.EndStaff)end;function o.get_top_left_visible_cell()if not finenv.UI():IsPageView()then local U=finale.FCMusicRegion()U:SetFullDocument()return finale.FCCell(finenv.UI():GetCurrentMeasure(),U.StartStaff)end;return o.get_first_cell_on_or_after_page(finenv.UI():GetCurrentPage())end;function o.get_top_left_selected_or_visible_cell()local v=finenv.Region()if not v:IsEmpty()then return finale.FCCell(v.StartMeasure,v.StartStaff)end;return o.get_top_left_visible_cell()end;function o.is_default_measure_number_visible_on_cell(z,x,V,u)local W=finale.FCCurrentStaffSpec()if not W:LoadForCell(x,0)then return false end;if z:GetShowOnTopStaff()and x.Staff==V.TopStaff then return true end;if z:GetShowOnBottomStaff()and x.Staff==V:CalcBottomStaff()then return true end;if W.ShowMeasureNumbers then return not z:GetExcludeOtherStaves(u)end;return false end;function o.is_default_number_visible_and_left_aligned(z,x,y,u,X)if z.UseScoreInfoForParts then u=false end;if X and z:GetShowOnMultiMeasureRests(u)then if finale.MNALIGN_LEFT~=z:GetMultiMeasureAlignment(u)then return false end elseif x.Measure==y.FirstMeasure then if not z:GetShowOnSystemStart()then return false end;if finale.MNALIGN_LEFT~=z:GetStartAlignment(u)then return false end else if not z:GetShowMultiples(u)then return false end;if finale.MNALIGN_LEFT~=z:GetMultipleAlignment(u)then return false end end;return o.is_default_measure_number_visible_on_cell(z,x,y,u)end;function o.update_layout(Y,Z)Y=Y or 1;Z=Z or false;local _=finale.FCPage()if _:Load(Y)then _:UpdateLayout(Z)end end;function o.get_current_part()local s=finale.FCParts()s:LoadAll()return s:GetCurrent()end;function o.get_page_format_prefs()local t=o.get_current_part()local a0=finale.FCPageFormatPrefs()local a1=false;if t:IsScore()then a1=a0:LoadScore()else a1=a0:LoadParts()end;return a0,a1 end;local a2=function(a3)local a4=finenv.UI():IsOnWindows()local a5=function(a6,a7)if finenv.UI():IsOnWindows()then return a6 and os.getenv(a6)or""else return a7 and os.getenv(a7)or""end end;local a8=a3 and a5("LOCALAPPDATA","HOME")or a5("COMMONPROGRAMFILES")if not a4 then a8=a8 .."/Library/Application Support"end;a8=a8 .."/SMuFL/Fonts/"return a8 end;function o.get_smufl_font_list()local a9={}local aa=function(a3)local a8=a2(a3)local ab=function()if finenv.UI():IsOnWindows()then return io.popen('dir "'..a8 ..'" /b /ad')else return io.popen('ls "'..a8 ..'"')end end;local ac=function(ad)local ae=finale.FCString()ae.LuaString=ad;return finenv.UI():IsFontAvailable(ae)end;for ad in ab():lines()do if not ad:find("%.")then ad=ad:gsub(" Bold","")ad=ad:gsub(" Italic","")local ae=finale.FCString()ae.LuaString=ad;if a9[ad]or ac(ad)then a9[ad]=a3 and"user"or"system"end end end end;aa(true)aa(false)return a9 end;function o.get_smufl_metadata_file(af)if not af then af=finale.FCFontInfo()af:LoadFontPrefs(finale.FONTPREF_MUSIC)end;local ag=function(ah,af)local ai=ah..af.Name.."/"..af.Name..".json"return io.open(ai,"r")end;local aj=ag(a2(true),af)if aj then return aj end;return ag(a2(false),af)end;function o.is_font_smufl_font(af)if not af then af=finale.FCFontInfo()af:LoadFontPrefs(finale.FONTPREF_MUSIC)end;if finenv.RawFinaleVersion>=o.finale_version(27,1)then if nil~=af.IsSMuFLFont then return af.IsSMuFLFont end end;local ak=o.get_smufl_metadata_file(af)if nil~=ak then io.close(ak)return true end;return false end;function o.simple_input(al,am)local an=finale.FCString()an.LuaString=""local ao=finale.FCString()local ap=160;function format_ctrl(aq,ar,as,at)aq:SetHeight(ar)aq:SetWidth(as)ao.LuaString=at;aq:SetText(ao)end;title_width=string.len(al)*6+54;if title_width>ap then ap=title_width end;text_width=string.len(am)*6;if text_width>ap then ap=text_width end;ao.LuaString=al;local au=finale.FCCustomLuaWindow()au:SetTitle(ao)local av=au:CreateStatic(0,0)format_ctrl(av,16,ap,am)local aw=au:CreateEdit(0,20)format_ctrl(aw,20,ap,"")au:CreateOkButton()au:CreateCancelButton()function callback(aq)end;au:RegisterHandleCommand(callback)if au:ExecuteModal(nil)==finale.EXECMODAL_OK then an.LuaString=aw:GetText(an)return an.LuaString end end;function o.is_finale_object(ax)return ax and type(ax)=="userdata"and ax.ClassName and ax.GetClassID and true or false end;function o.system_indent_set_to_prefs(y,a0)a0=a0 or o.get_page_format_prefs()local ay=finale.FCMeasure()local az=y.FirstMeasure==1;if not az and ay:Load(y.FirstMeasure)then if ay.ShowFullNames then az=true end end;if az and a0.UseFirstSystemMargins then y.LeftMargin=a0.FirstSystemLeft else y.LeftMargin=a0.SystemLeft end;return y:Save()end;function o.calc_script_name(aA)local aB=finale.FCString()if finenv.RunningLuaFilePath then aB.LuaString=finenv.RunningLuaFilePath()else aB:SetRunningLuaFilePath()end;local aC=finale.FCString()aB:SplitToPathAndFile(nil,aC)local G=aC.LuaString;if not aA then G=G:match("(.+)%..+")if not G or G==""then G=aC.LuaString end end;return G end;return o end)return a("__root")