
//****************************************************************************************
// m = 16; 
// Polynomial is :
// GF = x^16+x^15+x^11+x^10+x^8+x^7+x^6+x^5+x^3+x^2+x^0;. 101869 (0x18DED)
// Generated by gf_gen.tcl(Written by Ruslan Lepetenok (lepetenokr@yahoo.com))
//****************************************************************************************   

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// GF(8)
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

function automatic [15:0] fn_bch_dec_gf8;
input[254:0] d;

reg [15:0] p;
begin

       p[0] = d[0]^ d[2]^ d[3]^ d[4]^ d[5]^ d[6]^ d[8]^ d[13]^ d[15]^ d[16]^ d[17]^ d[20]^ d[21]^
              d[22]^ d[23]^ d[25]^ d[26]^ d[29]^ d[30]^ d[34]^ d[36]^ d[41]^ d[42]^ d[44]^ d[50]^
              d[51]^ d[52]^ d[53]^ d[54]^ d[56]^ d[60]^ d[61]^ d[62]^ d[63]^ d[64]^ d[65]^ d[66]^
              d[69]^ d[72]^ d[74]^ d[75]^ d[77]^ d[80]^ d[84]^ d[85]^ d[86]^ d[87]^ d[88]^ d[90]^
              d[96]^ d[97]^ d[104]^ d[106]^ d[107]^ d[109]^ d[113]^ d[116]^ d[117]^ d[118]^ d[119]^
              d[120]^ d[121]^ d[123]^ d[124]^ d[126]^ d[128]^ d[129]^ d[130]^ d[132]^ d[135]^ d[138]^
              d[139]^ d[141]^ d[143]^ d[144]^ d[146]^ d[148]^ d[150]^ d[153]^ d[155]^ d[156]^ d[159]^
              d[165]^ d[167]^ d[169]^ d[174]^ d[176]^ d[177]^ d[181]^ d[184]^ d[185]^ d[186]^ d[187]^
              d[189]^ d[198]^ d[201]^ d[203]^ d[204]^ d[205]^ d[207]^ d[209]^ d[211]^ d[212]^ d[213]^
              d[214]^ d[218]^ d[219]^ d[220]^ d[223]^ d[224]^ d[227]^ d[228]^ d[229]^ d[230]^ d[231]^
              d[235]^ d[236]^ d[237]^ d[238]^ d[239];

       p[1] = d[0]^ d[1]^ d[2]^ d[7]^ d[8]^ d[9]^ d[13]^ d[14]^ d[15]^ d[18]^ d[20]^ d[24]^ d[25]^ 
              d[27]^ d[29]^ d[31]^ d[34]^ d[35]^ d[36]^ d[37]^ d[41]^ d[43]^ d[44]^ d[45]^ d[50]^ 
              d[55]^ d[56]^ d[57]^ d[60]^ d[67]^ d[69]^ d[70]^ d[72]^ d[73]^ d[74]^ d[76]^ d[77]^ 
              d[78]^ d[80]^ d[81]^ d[84]^ d[89]^ d[90]^ d[91]^ d[96]^ d[98]^ d[104]^ d[105]^ d[106]^ 
              d[108]^ d[109]^ d[110]^ d[113]^ d[114]^ d[116]^ d[122]^ d[123]^ d[125]^ d[126]^ d[127]^ 
              d[128]^ d[131]^ d[132]^ d[133]^ d[135]^ d[136]^ d[138]^ d[140]^ d[141]^ d[142]^ d[143]^ 
              d[145]^ d[146]^ d[147]^ d[148]^ d[149]^ d[150]^ d[151]^ d[153]^ d[154]^ d[155]^ d[157]^ 
              d[159]^ d[160]^ d[165]^ d[166]^ d[167]^ d[168]^ d[169]^ d[170]^ d[174]^ d[175]^ d[176]^ 
              d[178]^ d[181]^ d[182]^ d[184]^ d[188]^ d[189]^ d[190]^ d[198]^ d[199]^ d[201]^ d[202]^ 
              d[203]^ d[206]^ d[207]^ d[208]^ d[209]^ d[210]^ d[211]^ d[215]^ d[218]^ d[221]^ d[223]^ 
              d[225]^ d[227]^ d[232]^ d[235]^ d[240];

       p[2] = d[1]^ d[2]^ d[3]^ d[8]^ d[9]^ d[10]^ d[14]^ d[15]^ d[16]^ d[19]^ d[21]^ d[25]^ d[26]^ 
              d[28]^ d[30]^ d[32]^ d[35]^ d[36]^ d[37]^ d[38]^ d[42]^ d[44]^ d[45]^ d[46]^ d[51]^ 
              d[56]^ d[57]^ d[58]^ d[61]^ d[68]^ d[70]^ d[71]^ d[73]^ d[74]^ d[75]^ d[77]^ d[78]^ 
              d[79]^ d[81]^ d[82]^ d[85]^ d[90]^ d[91]^ d[92]^ d[97]^ d[99]^ d[105]^ d[106]^ d[107]^ 
              d[109]^ d[110]^ d[111]^ d[114]^ d[115]^ d[117]^ d[123]^ d[124]^ d[126]^ d[127]^ d[128]^ 
              d[129]^ d[132]^ d[133]^ d[134]^ d[136]^ d[137]^ d[139]^ d[141]^ d[142]^ d[143]^ d[144]^ d[146]^ 
              d[147]^ d[148]^ d[149]^ d[150]^ d[151]^ d[152]^ d[154]^ d[155]^ d[156]^ d[158]^ d[160]^ 
              d[161]^ d[166]^ d[167]^ d[168]^ d[169]^ d[170]^ d[171]^ d[175]^ d[176]^ d[177]^ d[179]^ 
              d[182]^ d[183]^ d[185]^ d[189]^ d[190]^ d[191]^ d[199]^ d[200]^ d[202]^ d[203]^ d[204]^ 
              d[207]^ d[208]^ d[209]^ d[210]^ d[211]^ d[212]^ d[216]^ d[219]^ d[222]^ d[224]^ d[226]^ 
              d[228]^ d[233]^ d[236]^ d[241];

       p[3] = d[2]^ d[3]^ d[4]^ d[9]^ d[10]^ d[11]^ d[15]^ d[16]^ d[17]^ d[20]^ d[22]^ d[26]^ d[27]^ 
              d[29]^ d[31]^ d[33]^ d[36]^ d[37]^ d[38]^ d[39]^ d[43]^ d[45]^ d[46]^ d[47]^ d[52]^ d[57]^ d[58]^ 
              d[59]^ d[62]^ d[69]^ d[71]^ d[72]^ d[74]^ d[75]^ d[76]^ d[78]^ d[79]^ d[80]^ d[82]^ d[83]^ d[86]^ 
              d[91]^ d[92]^ d[93]^ d[98]^ d[100]^ d[106]^ d[107]^ d[108]^ d[110]^ d[111]^ d[112]^ d[115]^ d[116]^ 
              d[118]^ d[124]^ d[125]^ d[127]^ d[128]^ d[129]^ d[130]^ d[133]^ d[134]^ d[135]^ d[137]^ d[138]^ d[140]^ 
              d[142]^ d[143]^ d[144]^ d[145]^ d[147]^ d[148]^ d[149]^ d[150]^ d[151]^ d[152]^ d[153]^ d[155]^ 
              d[156]^ d[157]^ d[159]^ d[161]^ d[162]^ d[167]^ d[168]^ d[169]^ d[170]^ d[171]^ d[172]^ d[176]^ 
              d[177]^ d[178]^ d[180]^ d[183]^ d[184]^ d[186]^ d[190]^ d[191]^ d[192]^ d[200]^ d[201]^ d[203]^ 
              d[204]^ d[205]^ d[208]^ d[209]^ d[210]^ d[211]^ d[212]^ d[213]^ d[217]^ d[220]^ d[223]^ d[225]^ 
              d[227]^ d[229]^ d[234]^ d[237]^ d[242];

       p[4] = d[3]^ d[4]^ d[5]^ d[10]^ d[11]^ d[12]^ d[16]^ d[17]^ d[18]^ d[21]^ d[23]^ d[27]^ d[28]^ 
              d[30]^ d[32]^ d[34]^ d[37]^ d[38]^ d[39]^ d[40]^ d[44]^ d[46]^ d[47]^ d[48]^ d[53]^ 
              d[58]^ d[59]^ d[60]^ d[63]^ d[70]^ d[72]^ d[73]^ d[75]^ d[76]^ d[77]^ d[79]^ d[80]^ 
              d[81]^ d[83]^ d[84]^ d[87]^ d[92]^ d[93]^ d[94]^ d[99]^ d[101]^ d[107]^ d[108]^ d[109]^ 
              d[111]^ d[112]^ d[113]^ d[116]^ d[117]^ d[119]^ d[125]^ d[126]^ d[128]^ d[129]^ d[130]^ 
              d[131]^ d[134]^ d[135]^ d[136]^ d[138]^ d[139]^ d[141]^ d[143]^ d[144]^ d[145]^ d[146]^ 
              d[148]^ d[149]^ d[150]^ d[151]^ d[152]^ d[153]^ d[154]^ d[156]^ d[157]^ d[158]^ d[160]^ 
              d[162]^ d[163]^ d[168]^ d[169]^ d[170]^ d[171]^ d[172]^ d[173]^ d[177]^ d[178]^ d[179]^ 
              d[181]^ d[184]^ d[185]^ d[187]^ d[191]^ d[192]^ d[193]^ d[201]^ d[202]^ d[204]^ d[205]^ 
              d[206]^ d[209]^ d[210]^ d[211]^ d[212]^ d[213]^ d[214]^ d[218]^ d[221]^ d[224]^ d[226]^ 
              d[228]^ d[230]^ d[235]^ d[238]^ d[243];

       p[5] = d[0]^ d[2]^ d[3]^ d[8]^ d[11]^ d[12]^ d[15]^ d[16]^ d[18]^ d[19]^ d[20]^ d[21]^ d[23]^ 
              d[24]^ d[25]^ d[26]^ d[28]^ d[30]^ d[31]^ d[33]^ d[34]^ d[35]^ d[36]^ d[38]^ d[39]^ d[40]^ 
              d[42]^ d[44]^ d[45]^ d[47]^ d[48]^ d[49]^ d[50]^ d[51]^ d[52]^ d[53]^ d[56]^ d[59]^ d[62]^ 
              d[63]^ d[65]^ d[66]^ d[69]^ d[71]^ d[72]^ d[73]^ d[75]^ d[76]^ d[78]^ d[81]^ d[82]^ d[86]^ 
              d[87]^ d[90]^ d[93]^ d[94]^ d[95]^ d[96]^ d[97]^ d[100]^ d[102]^ d[104]^ d[106]^ d[107]^ d[108]^ 
              d[110]^ d[112]^ d[114]^ d[116]^ d[119]^ d[121]^ d[123]^ d[124]^ d[127]^ d[128]^ d[131]^ d[136]^ 
              d[137]^ d[138]^ d[140]^ d[141]^ d[142]^ d[143]^ d[145]^ d[147]^ d[148]^ d[149]^ d[151]^ d[152]^ 
              d[154]^ d[156]^ d[157]^ d[158]^ d[161]^ d[163]^ d[164]^ d[165]^ d[167]^ d[170]^ d[171]^ d[172]^ 
              d[173]^ d[176]^ d[177]^ d[178]^ d[179]^ d[180]^ d[181]^ d[182]^ d[184]^ d[187]^ d[188]^ d[189]^ 
              d[192]^ d[193]^ d[194]^ d[198]^ d[201]^ d[202]^ d[204]^ d[206]^ d[209]^ d[210]^ d[215]^ d[218]^ 
              d[220]^ d[222]^ d[223]^ d[224]^ d[225]^ d[228]^ d[230]^ d[235]^ d[237]^ d[238]^ d[244];

       p[6] = d[0]^ d[1]^ d[2]^ d[5]^ d[6]^ d[8]^ d[9]^ d[12]^ d[15]^ d[19]^ d[23]^ d[24]^ d[27]^ d[30]^ 
              d[31]^ d[32]^ d[35]^ d[37]^ d[39]^ d[40]^ d[42]^ d[43]^ d[44]^ d[45]^ d[46]^ d[48]^ d[49]^ 
              d[56]^ d[57]^ d[61]^ d[62]^ d[65]^ d[67]^ d[69]^ d[70]^ d[73]^ d[75]^ d[76]^ d[79]^ d[80]^ 
              d[82]^ d[83]^ d[84]^ d[85]^ d[86]^ d[90]^ d[91]^ d[94]^ d[95]^ d[98]^ d[101]^ d[103]^ d[104]^ 
              d[105]^ d[106]^ d[108]^ d[111]^ d[115]^ d[116]^ d[118]^ d[119]^ d[121]^ d[122]^ d[123]^ d[125]^ 
              d[126]^ d[130]^ d[135]^ d[137]^ d[142]^ d[149]^ d[152]^ d[156]^ d[157]^ d[158]^ d[162]^ d[164]^ d[166]^ 
              d[167]^ d[168]^ d[169]^ d[171]^ d[172]^ d[173]^ d[176]^ d[178]^ d[179]^ d[180]^ d[182]^ d[183]^ 
              d[184]^ d[186]^ d[187]^ d[188]^ d[190]^ d[193]^ d[194]^ d[195]^ d[198]^ d[199]^ d[201]^ d[202]^ 
              d[204]^ d[209]^ d[210]^ d[212]^ d[213]^ d[214]^ d[216]^ d[218]^ d[220]^ d[221]^ d[225]^ d[226]^ 
              d[227]^ d[228]^ d[230]^ d[235]^ d[237]^ d[245];

       p[7] = d[1]^ d[2]^ d[3]^ d[6]^ d[7]^ d[9]^ d[10]^ d[13]^ d[16]^ d[20]^ d[24]^ d[25]^ d[28]^ d[31]^ 
              d[32]^ d[33]^ d[36]^ d[38]^ d[40]^ d[41]^ d[43]^ d[44]^ d[45]^ d[46]^ d[47]^ d[49]^ 
              d[50]^ d[57]^ d[58]^ d[62]^ d[63]^ d[66]^ d[68]^ d[70]^ d[71]^ d[74]^ d[76]^ d[77]^ 
              d[80]^ d[81]^ d[83]^ d[84]^ d[85]^ d[86]^ d[87]^ d[91]^ d[92]^ d[95]^ d[96]^ d[99]^ 
              d[102]^ d[104]^ d[105]^ d[106]^ d[107]^ d[109]^ d[112]^ d[116]^ d[117]^ d[119]^ d[120]^ 
              d[122]^ d[123]^ d[124]^ d[126]^ d[127]^ d[131]^ d[136]^ d[138]^ d[143]^ d[150]^ d[153]^ 
              d[157]^ d[158]^ d[159]^ d[163]^ d[165]^ d[167]^ d[168]^ d[169]^ d[170]^ d[172]^ d[173]^ 
              d[174]^ d[177]^ d[179]^ d[180]^ d[181]^ d[183]^ d[184]^ d[185]^ d[187]^ d[188]^ d[189]^ 
              d[191]^ d[194]^ d[195]^ d[196]^ d[199]^ d[200]^ d[202]^ d[203]^ d[205]^ d[210]^ d[211]^ 
              d[213]^ d[214]^ d[215]^ d[217]^ d[219]^ d[221]^ d[222]^ d[226]^ d[227]^ d[228]^ d[229]^ 
              d[231]^ d[236]^ d[238]^ d[246];

       p[8] = d[0]^ d[5]^ d[6]^ d[7]^ d[10]^ d[11]^ d[13]^ d[14]^ d[15]^ d[16]^ d[20]^ d[22]^ 
              d[23]^ d[30]^ d[32]^ d[33]^ d[36]^ d[37]^ d[39]^ d[45]^ d[46]^ d[47]^ d[48]^ 
              d[52]^ d[53]^ d[54]^ d[56]^ d[58]^ d[59]^ d[60]^ d[61]^ d[62]^ d[65]^ d[66]^ 
              d[67]^ d[71]^ d[74]^ d[78]^ d[80]^ d[81]^ d[82]^ d[90]^ d[92]^ d[93]^ d[100]^ 
              d[103]^ d[104]^ d[105]^ d[108]^ d[109]^ d[110]^ d[116]^ d[119]^ d[125]^ d[126]^ 
              d[127]^ d[129]^ d[130]^ d[135]^ d[137]^ d[138]^ d[141]^ d[143]^ d[146]^ d[148]^ 
              d[150]^ d[151]^ d[153]^ d[154]^ d[155]^ d[156]^ d[158]^ d[160]^ d[164]^ d[165]^ 
              d[166]^ d[167]^ d[168]^ d[170]^ d[171]^ d[173]^ d[175]^ d[176]^ d[177]^ d[178]^ 
              d[180]^ d[182]^ d[187]^ d[188]^ d[190]^ d[192]^ d[195]^ d[196]^ d[197]^ d[198]^ 
              d[200]^ d[205]^ d[206]^ d[207]^ d[209]^ d[213]^ d[215]^ d[216]^ d[219]^ d[222]^ 
              d[224]^ d[231]^ d[232]^ d[235]^ d[236]^ d[238]^ d[247];

       p[9] = d[0]^ d[1]^ d[2]^ d[3]^ d[4]^ d[5]^ d[7]^ d[11]^ d[12]^ d[13]^ d[14]^ 
              d[20]^ d[22]^ d[24]^ d[25]^ d[26]^ d[29]^ d[30]^ d[31]^ d[33]^ d[36]^ 
              d[37]^ d[38]^ d[40]^ d[41]^ d[42]^ d[44]^ d[46]^ d[47]^ d[48]^ d[49]^ 
              d[50]^ d[51]^ d[52]^ d[55]^ d[56]^ d[57]^ d[59]^ d[64]^ d[65]^ d[67]^ 
              d[68]^ d[69]^ d[74]^ d[77]^ d[79]^ d[80]^ d[81]^ d[82]^ d[83]^ d[84]^ 
              d[85]^ d[86]^ d[87]^ d[88]^ d[90]^ d[91]^ d[93]^ d[94]^ d[96]^ d[97]^ 
              d[101]^ d[105]^ d[107]^ d[110]^ d[111]^ d[113]^ d[116]^ d[118]^ d[119]^ 
              d[121]^ d[123]^ d[124]^ d[127]^ d[129]^ d[131]^ d[132]^ d[135]^ d[136]^ 
              d[141]^ d[142]^ d[143]^ d[146]^ d[147]^ d[148]^ d[149]^ d[150]^ d[151]^ 
              d[152]^ d[153]^ d[154]^ d[157]^ d[161]^ d[166]^ d[168]^ d[171]^ d[172]^ 
              d[178]^ d[179]^ d[183]^ d[184]^ d[185]^ d[186]^ d[187]^ d[188]^ d[191]^ 
              d[193]^ d[196]^ d[197]^ d[199]^ d[203]^ d[204]^ d[205]^ d[206]^ d[208]^ 
              d[209]^ d[210]^ d[211]^ d[212]^ d[213]^ d[216]^ d[217]^ d[218]^ d[219]^ 
              d[224]^ d[225]^ d[227]^ d[228]^ d[229]^ d[230]^ d[231]^ d[232]^ d[233]^ 
              d[235]^ d[238]^ d[248];

       p[10] = d[0]^ d[1]^ d[12]^ d[14]^ d[16]^ d[17]^ d[20]^ d[22]^ d[27]^ d[29]^ d[31]^ d[32]^ 
               d[36]^ d[37]^ d[38]^ d[39]^ d[43]^ d[44]^ d[45]^ d[47]^ d[48]^ d[49]^ d[54]^ d[57]^ d[58]^ 
               d[61]^ d[62]^ d[63]^ d[64]^ d[68]^ d[70]^ d[72]^ d[74]^ d[77]^ d[78]^ d[81]^ d[82]^ d[83]^ 
               d[89]^ d[90]^ d[91]^ d[92]^ d[94]^ d[95]^ d[96]^ d[98]^ d[102]^ d[104]^ d[107]^ d[108]^ 
               d[109]^ d[111]^ d[112]^ d[113]^ d[114]^ d[116]^ d[118]^ d[121]^ d[122]^ d[123]^ d[125]^ 
               d[126]^ d[129]^ d[133]^ d[135]^ d[136]^ d[137]^ d[138]^ d[139]^ d[141]^ d[142]^ d[146]^ 
               d[147]^ d[149]^ d[151]^ d[152]^ d[154]^ d[156]^ d[158]^ d[159]^ d[162]^ d[165]^ d[172]^ 
               d[173]^ d[174]^ d[176]^ d[177]^ d[179]^ d[180]^ d[181]^ d[188]^ d[192]^ d[194]^ d[197]^ 
               d[200]^ d[201]^ d[203]^ d[206]^ d[210]^ d[217]^ d[223]^ d[224]^ d[225]^ d[226]^ d[227]^ 
               d[232]^ d[233]^ d[234]^ d[235]^ d[237]^ d[238]^ d[249];

       p[11] = d[0]^ d[1]^ d[3]^ d[4]^ d[5]^ d[6]^ d[8]^ d[16]^ d[18]^ d[20]^ d[22]^ 
               d[25]^ d[26]^ d[28]^ d[29]^ d[32]^ d[33]^ d[34]^ d[36]^ d[37]^ d[38]^ d[39]^ d[40]^ 
               d[41]^ d[42]^ d[45]^ d[46]^ d[48]^ d[49]^ d[51]^ d[52]^ d[53]^ d[54]^ d[55]^ d[56]^ 
               d[58]^ d[59]^ d[60]^ d[61]^ d[66]^ d[71]^ d[72]^ d[73]^ d[74]^ d[77]^ d[78]^ d[79]^ 
               d[80]^ d[82]^ d[83]^ d[85]^ d[86]^ d[87]^ d[88]^ d[91]^ d[92]^ d[93]^ d[95]^ d[99]^ 
               d[103]^ d[104]^ d[105]^ d[106]^ d[107]^ d[108]^ d[110]^ d[112]^ d[114]^ d[115]^ 
               d[116]^ d[118]^ d[120]^ d[121]^ d[122]^ d[127]^ d[128]^ d[129]^ d[132]^ d[134]^ 
               d[135]^ d[136]^ d[137]^ d[140]^ d[141]^ d[142]^ d[144]^ d[146]^ d[147]^ d[152]^ 
               d[156]^ d[157]^ d[160]^ d[163]^ d[165]^ d[166]^ d[167]^ d[169]^ d[173]^ d[175]^ 
               d[176]^ d[178]^ d[180]^ d[182]^ d[184]^ d[185]^ d[186]^ d[187]^ d[193]^ d[195]^ 
               d[202]^ d[203]^ d[205]^ d[209]^ d[212]^ d[213]^ d[214]^ d[219]^ d[220]^ d[223]^ 
               d[225]^ d[226]^ d[229]^ d[230]^ d[231]^ d[233]^ d[234]^ d[237]^ d[250];

       p[12] = d[1]^ d[2]^ d[4]^ d[5]^ d[6]^ d[7]^ d[9]^ d[17]^ d[19]^ d[21]^ d[23]^ 
               d[26]^ d[27]^ d[29]^ d[30]^ d[33]^ d[34]^ d[35]^ d[37]^ d[38]^ d[39]^ d[40]^ 
               d[41]^ d[42]^ d[43]^ d[46]^ d[47]^ d[49]^ d[50]^ d[52]^ d[53]^ d[54]^ d[55]^ 
               d[56]^ d[57]^ d[59]^ d[60]^ d[61]^ d[62]^ d[67]^ d[72]^ d[73]^ d[74]^ d[75]^ 
               d[78]^ d[79]^ d[80]^ d[81]^ d[83]^ d[84]^ d[86]^ d[87]^ d[88]^ d[89]^ d[92]^ 
               d[93]^ d[94]^ d[96]^ d[100]^ d[104]^ d[105]^ d[106]^ d[107]^ d[108]^ d[109]^ 
               d[111]^ d[113]^ d[115]^ d[116]^ d[117]^ d[119]^ d[121]^ d[122]^ d[123]^ d[128]^ 
               d[129]^ d[130]^ d[133]^ d[135]^ d[136]^ d[137]^ d[138]^ d[141]^ d[142]^ d[143]^ 
               d[145]^ d[147]^ d[148]^ d[153]^ d[157]^ d[158]^ d[161]^ d[164]^ d[166]^ d[167]^ 
               d[168]^ d[170]^ d[174]^ d[176]^ d[177]^ d[179]^ d[181]^ d[183]^ d[185]^ d[186]^ 
               d[187]^ d[188]^ d[194]^ d[196]^ d[203]^ d[204]^ d[206]^ d[210]^ 
               d[213]^ d[214]^ d[215]^ d[220]^ d[221]^ d[224]^ d[226]^ d[227]^ d[230]^ 
               d[231]^ d[232]^ d[234]^ d[235]^ d[238]^ d[251];

       p[13] = d[0]^ d[4]^ d[7]^ d[10]^ d[13]^ d[15]^ d[16]^ d[17]^ d[18]^ d[21]^ 
               d[23]^ d[24]^ d[25]^ d[26]^ d[27]^ d[28]^ d[29]^ d[31]^ d[35]^ d[38]^ d[39]^ 
               d[40]^ d[43]^ d[47]^ d[48]^ d[52]^ d[55]^ d[57]^ d[58]^ d[64]^ d[65]^ d[66]^ d[68]^ 
               d[69]^ d[72]^ d[73]^ d[76]^ d[77]^ d[79]^ d[81]^ d[82]^ d[86]^ d[89]^ d[93]^ d[94]^ 
               d[95]^ d[96]^ d[101]^ d[104]^ d[105]^ d[108]^ d[110]^ d[112]^ d[113]^ d[114]^ d[119]^ 
               d[121]^ d[122]^ d[126]^ d[128]^ d[131]^ d[132]^ d[134]^ d[135]^ d[136]^ d[137]^ d[141]^ 
               d[142]^ d[149]^ d[150]^ d[153]^ d[154]^ d[155]^ d[156]^ d[158]^ d[162]^ d[168]^ d[171]^ 
               d[174]^ d[175]^ d[176]^ d[178]^ d[180]^ d[181]^ d[182]^ d[185]^ d[188]^ d[195]^ d[197]^ 
               d[198]^ d[201]^ d[203]^ d[209]^ d[212]^ d[213]^ d[215]^ d[216]^ d[218]^ d[219]^ d[220]^ 
               d[221]^ d[222]^ d[223]^ d[224]^ d[225]^ d[229]^ d[230]^ d[232]^ d[233]^ d[237]^ d[238]^ d[252];

       p[14] = d[0]^ d[1]^ d[2]^ d[3]^ d[4]^ d[6]^ d[11]^ d[13]^ d[14]^ d[15]^ d[18]^ d[19]^ 
               d[20]^ d[21]^ d[23]^ d[24]^ d[27]^ d[28]^ d[32]^ d[34]^ d[39]^ d[40]^ d[42]^ d[48]^ d[49]^ 
               d[50]^ d[51]^ d[52]^ d[54]^ d[58]^ d[59]^ d[60]^ d[61]^ d[62]^ d[63]^ d[64]^ d[67]^ d[70]^ 
               d[72]^ d[73]^ d[75]^ d[78]^ d[82]^ d[83]^ d[84]^ d[85]^ d[86]^ d[88]^ d[94]^ d[95]^ d[102]^ 
               d[104]^ d[105]^ d[107]^ d[111]^ d[114]^ d[115]^ d[116]^ d[117]^ d[118]^ d[119]^ d[121]^ 
               d[122]^ d[124]^ d[126]^ d[127]^ d[128]^ d[130]^ d[133]^ d[136]^ d[137]^ d[139]^ d[141]^ 
               d[142]^ d[144]^ d[146]^ d[148]^ d[151]^ d[153]^ d[154]^ d[157]^ d[163]^ d[165]^ d[167]^ 
               d[172]^ d[174]^ d[175]^ d[179]^ d[182]^ d[183]^ d[184]^ d[185]^ d[187]^ d[196]^ d[199]^ 
               d[201]^ d[202]^ d[203]^ d[205]^ d[207]^ d[209]^ d[210]^ d[211]^ d[212]^ d[216]^ d[217]^ 
               d[218]^ d[221]^ d[222]^ d[225]^ d[226]^ d[227]^ d[228]^ d[229]^ d[233]^ d[234]^ d[235]^ 
               d[236]^ d[237]^ d[253];

       p[15] = d[1]^ d[2]^ d[3]^ d[4]^ d[5]^ d[7]^ d[12]^ d[14]^ d[15]^ d[16]^ d[19]^ 
               d[20]^ d[21]^ d[22]^ d[24]^ d[25]^ d[28]^ d[29]^ d[33]^ d[35]^ d[40]^ d[41]^ d[43]^ 
               d[49]^ d[50]^ d[51]^ d[52]^ d[53]^ d[55]^ d[59]^ d[60]^ d[61]^ d[62]^ d[63]^ d[64]^ 
               d[65]^ d[68]^ d[71]^ d[73]^ d[74]^ d[76]^ d[79]^ d[83]^ d[84]^ d[85]^ d[86]^ 
               d[87]^ d[89]^ d[95]^ d[96]^ d[103]^ d[105]^ d[106]^ d[108]^ d[112]^ d[115]^ 
               d[116]^ d[117]^ d[118]^ d[119]^ d[120]^ d[122]^ d[123]^ d[125]^ d[127]^ 
               d[128]^ d[129]^ d[131]^ d[134]^ d[137]^ d[138]^ d[140]^ d[142]^ d[143]^ 
               d[145]^ d[147]^ d[149]^ d[152]^ d[154]^ d[155]^ d[158]^ d[164]^ d[166]^ 
               d[168]^ d[173]^ d[175]^ d[176]^ d[180]^ d[183]^ d[184]^ d[185]^ d[186]^ 
               d[188]^ d[197]^ d[200]^ d[202]^ d[203]^ d[204]^ d[206]^ d[208]^ d[210]^ 
               d[211]^ d[212]^ d[213]^ d[217]^ d[218]^ d[219]^ d[222]^ d[223]^ d[226]^ 
               d[227]^ d[228]^ d[229]^ d[230]^ d[234]^ d[235]^ d[236]^ d[237]^ d[238]^ d[254];
		 
fn_bch_dec_gf8 = p;
end	

endfunction // fn_bch_dec_gf8