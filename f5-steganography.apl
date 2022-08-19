⍝ split array into blocks of size 8 8
split←{ia←({0⍪⍨0⍪0,⍨0,⍵}⍣7)⍵⋄{⍵⌷({⊂⍵}⌺8 8)ia}¨,⊃∘.,/{11+8×¯1+⍳⌈⍵÷8}¨⍴⍵}

fdct←{
  ia←⍵
  C←.25×∘.×⍨(2*¯.5),7⍴1
  ⌊C×{
    u v←⍵
    +/,{
      x y←⍵
        ((1+x y)⌷ia)×(2○○u×(16÷⍨1+2×x))×(2○○v×(16÷⍨1+2×y))
    }¨∘.,⍨¯1+⍳8
  }¨∘.,⍨¯1+⍳8
}

codeAC←{
  ACs←⍵
  sACs←0(({⍺+⍵×⍺≠⍵}\1+≠)⊆⊢)ACs
  ⍝ is first not 0
  ifn←0≠⊃⊃sACs
  o←⍬
  nzb←{
    $[0=⍵;⍬;
    nb←1+⌈2⍟|⍵
    max←2*nb-1
    out←1,((4⍴2)⊤nb),((nb⍴2)⊤max+⍵)
    out]
  }
  znzb←{
    z acv←⍵
    outb←nzb¨1↓acv
    nb←1+⌈2⍟|⊃acv
    max←2*nb-1
    out←0,((6⍴2)⊤≢z),((4⍴2)⊤nb),((nb⍴2)⊤max+⊃acv),outb
    out
  }
  o,←,nzb¨↑ifn↑sACs
  o,←znzb¨↓{(⌊2÷⍨≢⍵)2⍴⍵}ifn↓sACs
  ⍝ is last 0
  ilz←0=⊃⊃⌽sACs
  zb←{
    $[0=ilz;⍬;
    out←0,((6⍴2)⊤≢,⍵)
    out]
  }
  ⊃,/o,zb↑ilz↑⌽sACs
}

⍝ discrete cosine transform
dct←{
  ia N←⍵
  ia←fdct⊃ia
  ⍝ compression mask
  cm←N<1+∘.+⍨⌽¯1+⍳8
  ia×←cm
  ⍝ zigzag indices
  zi←⊃,/{(⍵⊃f)⊃⊃⍵⌷r}¨⍳≢f←1 2⍴⍨≢r←(⊂∘⌽,⊂∘⊢)¨{⍸⍵=,↑{¯1+8⍴⍵↓⍳16}¨⍳8}¨⍳15
  l←(,ia)[zi]
  DC←⊃l
  o←(12⍴2)⊤2040+DC
  ACs←1↓l
  o,←codeAC ACs
  o
}

f5sh←{
  i m N M←⍵
  ⎕RL←N×M
  ⍝ append message size to message
  m,⍨←(2⍴⍨4×8)⊤≢m
  ⍝ split image array by channels
  c←↑¨↓[1]↓[2]i
  o←↑,/↑{,/⊃,/{dct ⍵ N}¨split ⍵}¨c
  o
}

f5se←{
  i N M←⍵
  ⎕RL←N×M
m←0 1 1 0 1 0 0 0 0 1 1 0 1 0 0 1 0 1 1 0 0 1 0 0 0 1 1 0 0 1 0 0 0 1 1 0 0 1 0 1 0 1 1 0 1 1 1 0 0 0 1 0 0 0 0 0 0 1 1 1 0 1 0 0 0 1 1 0 0 1 0 1 0 1 1 1 1 0 0 0 0 1 1 1 0 1 0 0 
o←0 1 1 0 1 0 0 0 0 1 1 0 1 0 0 1 0 1 1 0 0 1 0 0 0 1 1 0 0 1 0 0 0 1 1 0 0 1 0 1 0 1 1 0 1 1 1 0 0 0 1 0 0 0 0 0 0 1 1 1 0 1 0 0 0 1 1 0 0 1 0 1 0 1 1 1 1 0 0 0 0 1 1 1 0 1 0 0 
⍝ todo:  o←idct i
  (⊂m),⊂o
}
