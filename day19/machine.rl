package main

import (
  "fmt"
)

%%{
  machine oracle;
  write data;
}%%
func ParseLine(data string) (bool, error) {
  cs, p, pe := 0, 0, len(data)
  %%{
rule57 =  'b';
rule83 =  'a';
rule95 =  rule83 | rule57;
rule108 =  rule57 rule95 | rule83 rule83;
rule41 =  rule57 rule83;
rule98 =  rule108 rule57 | rule41 rule83;
rule124 =  rule57 rule57 | rule83 rule83;
rule138 =  rule57 rule57 | rule83 rule57;
rule14 =  rule57 rule124 | rule83 rule138;
rule74 =  rule98 rule57 | rule14 rule83;
rule12 =  rule57 rule57;
rule127 =  rule41 rule57 | rule12 rule83;
rule85 =  rule95 rule57 | rule57 rule83;
rule80 =  rule83 rule41 | rule57 rule85;
rule20 =  rule57 rule127 | rule83 rule80;
rule131 =  rule20 rule83 | rule74 rule57;
rule45 =  rule83 rule57 | rule83 rule83;
rule54 =  rule57 rule57 | rule57 rule83;
rule51 =  rule83 rule45 | rule57 rule54;
rule18 =  rule83 rule57 | rule57 rule83;
rule110 =  rule85 rule57 | rule18 rule83;
rule7 =  rule57 rule110 | rule83 rule51;
rule47 =  rule83 rule95 | rule57 rule57;
rule72 =  rule57 rule83 | rule83 rule83;
rule37 =  rule47 rule57 | rule72 rule83;
rule105 =  rule95 rule95;
rule112 =  rule138 rule83 | rule105 rule57;
rule70 =  rule83 rule37 | rule57 rule112;
rule30 =  rule83 rule7 | rule57 rule70;
rule87 =  rule131 rule57 | rule30 rule83;
rule134 =  rule95 rule83 | rule83 rule57;
rule36 =  rule57 rule134 | rule83 rule41;
rule19 =  rule83 rule83;
rule21 =  rule45 rule83 | rule19 rule57;
rule96 =  rule36 rule57 | rule21 rule83;
rule97 =  rule138 rule57 | rule12 rule83;
rule93 =  rule12 rule57;
rule135 =  rule83 rule93 | rule57 rule97;
rule13 =  rule57 rule135 | rule83 rule96;
rule92 =  rule95 rule138;
rule78 =  rule41 rule83 | rule19 rule57;
rule77 =  rule83 rule78 | rule57 rule92;
rule100 =  rule41 rule83 | rule138 rule57;
rule120 =  rule83 rule105 | rule57 rule18;
rule118 =  rule100 rule57 | rule120 rule83;
rule79 =  rule57 rule118 | rule83 rule77;
rule133 =  rule57 rule79 | rule83 rule13;
rule66 =  rule87 rule83 | rule133 rule57;
rule136 =  rule57 rule105 | rule83 rule108;
rule121 =  rule134 rule57 | rule108 rule83;
rule29 =  rule136 rule83 | rule121 rule57;
rule101 =  rule83 rule41 | rule57 rule72;
rule40 =  rule57 rule101 | rule83 rule93;
rule89 =  rule57 rule29 | rule83 rule40;
rule55 =  rule124 rule57 | rule45 rule83;
rule28 =  rule72 rule57 | rule124 rule83;
rule34 =  rule55 rule83 | rule28 rule57;
rule111 =  rule54 rule83 | rule18 rule57;
rule39 =  rule83 rule18 | rule57 rule138;
rule119 =  rule39 rule57 | rule111 rule83;
rule22 =  rule83 rule34 | rule57 rule119;
rule35 =  rule83 rule22 | rule57 rule89;
rule58 =  rule108 rule57 | rule72 rule83;
rule26 =  rule57 rule12 | rule83 rule124;
rule49 =  rule58 rule57 | rule26 rule83;
rule129 =  rule57 rule138 | rule83 rule108;
rule86 =  rule57 rule12 | rule83 rule85;
rule94 =  rule83 rule129 | rule57 rule86;
rule73 =  rule49 rule83 | rule94 rule57;
rule68 =  rule134 rule57 | rule19 rule83;
rule106 =  rule41 rule83 | rule85 rule57;
rule3 =  rule68 rule57 | rule106 rule83;
rule91 =  rule83 rule108 | rule57 rule72;
rule33 =  rule108 rule83 | rule45 rule57;
rule137 =  rule33 rule83 | rule91 rule57;
rule52 =  rule83 rule3 | rule57 rule137;
rule53 =  rule57 rule52 | rule83 rule73;
rule15 =  rule35 rule83 | rule53 rule57;
rule42 =  rule15 rule83 | rule66 rule57;
rule8 =  rule42;
rule16 =  rule12 rule83 | rule47 rule57;
rule65 =  rule83 rule72 | rule57 rule108;
rule117 =  rule83 rule16 | rule57 rule65;
rule107 =  rule83 rule134 | rule57 rule72;
rule123 =  rule105 rule83 | rule134 rule57;
rule76 =  rule107 rule57 | rule123 rule83;
rule24 =  rule83 rule117 | rule57 rule76;
rule104 =  rule18 rule83 | rule124 rule57;
rule64 =  rule18 rule83 | rule19 rule57;
rule5 =  rule104 rule83 | rule64 rule57;
rule61 =  rule57 rule19 | rule83 rule47;
rule38 =  rule58 rule57 | rule61 rule83;
rule113 =  rule5 rule83 | rule38 rule57;
rule60 =  rule113 rule83 | rule24 rule57;
rule125 =  rule83 rule124 | rule57 rule72;
rule59 =  rule55 rule83 | rule125 rule57;
rule102 =  rule19 rule57 | rule72 rule83;
rule103 =  rule134 rule57 | rule45 rule83;
rule43 =  rule83 rule102 | rule57 rule103;
rule10 =  rule59 rule83 | rule43 rule57;
rule116 =  rule83 rule18 | rule57 rule72;
rule1 =  rule57 rule116 | rule83 rule93;
rule62 =  rule83 rule134 | rule57 rule18;
rule109 =  rule134 rule83 | rule124 rule57;
rule32 =  rule62 rule57 | rule109 rule83;
rule63 =  rule83 rule1 | rule57 rule32;
rule44 =  rule83 rule63 | rule57 rule10;
rule71 =  rule60 rule57 | rule44 rule83;
rule114 =  rule83 rule72 | rule57 rule45;
rule50 =  rule123 rule83 | rule114 rule57;
rule46 =  rule83 rule47 | rule57 rule138;
rule84 =  rule98 rule57 | rule46 rule83;
rule130 =  rule57 rule84 | rule83 rule50;
rule2 =  rule83 rule57;
rule88 =  rule41 rule57 | rule2 rule83;
rule17 =  rule83 rule88 | rule57 rule93;
rule6 =  rule83 rule2 | rule57 rule138;
rule82 =  rule83 rule41 | rule57 rule138;
rule56 =  rule82 rule83 | rule6 rule57;
rule48 =  rule17 rule83 | rule56 rule57;
rule90 =  rule83 rule130 | rule57 rule48;
rule122 =  rule18 rule83 | rule41 rule57;
rule9 =  rule57 rule124 | rule83 rule105;
rule81 =  rule122 rule57 | rule9 rule83;
rule126 =  rule54 rule83 | rule45 rule57;
rule27 =  rule83 rule41;
rule69 =  rule126 rule83 | rule27 rule57;
rule23 =  rule81 rule57 | rule69 rule83;
rule128 =  rule45 rule57 | rule2 rule83;
rule75 =  rule108 rule83 | rule105 rule57;
rule132 =  rule128 rule57 | rule75 rule83;
rule4 =  rule41 rule83 | rule12 rule57;
rule25 =  rule4 rule83 | rule62 rule57;
rule115 =  rule83 rule132 | rule57 rule25;
rule99 =  rule115 rule57 | rule23 rule83;
rule67 =  rule90 rule83 | rule99 rule57;
rule31 =  rule83 rule71 | rule57 rule67;
rule11 =  rule42 rule31;
rule0 =  rule8 rule11;

    main := rule0 + '\n'?;

    write init;
    write exec;
  }%%
  if cs < oracle_first_final {
    return false, fmt.Errorf("oracle parse error: %s", data)
  }

  return true, nil
}
