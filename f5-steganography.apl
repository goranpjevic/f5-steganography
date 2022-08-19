⍝ split array into blocks of size 8 8
split←{
  ia←({0⍪⍨0⍪0,⍨0,⍵}⍣7)⍵
  ⍝ indices of blocks to take
  ib←,⊃∘.,/{11+8×¯1+⍳⌈⍵÷8}¨⍴⍵
  {⍵⌷({⊂⍵}⌺8 8)ia}¨ib
}

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
  ⍝ get image dimensions
  o←⊃,/(32⍴2)∘⊤¨⍴i
  o,←↑,/↑{,/⊃,/{dct ⍵ N}¨split ⍵}¨c
  m,o
}

parse_block_bits←{
  nums b←⍵
  nz←{
    nums b←⍵
    nums b
    size←2⊥4↑b
    b↓⍨←4
    num←2⊥size↑b
    max←2*size-1
    num-←max
    b↓⍨←size
    (⊂nums,num),⊂b
  }
  z←{
    nums b←⍵
    zlength←2⊥6↑b
    b↓⍨←6
    nums,←zlength⍴0
    $[63=≢nums;nums b;
    size←2⊥4↑b
    b↓⍨←4
    num←2⊥size↑b
    max←2*size-1
    num-←max
    b↓⍨←size
    (⊂nums,num),⊂b
    ]
  }
  out b←$[∨/0 63=≢¨b nums;nums b;
  cb←⊃b
  b↓⍨←1
  $[cb;∇nz nums b;∇z nums b]
  ]
}

ifdct←{
  ia←⍵
  C←∘.×⍨(2*¯.5),7⍴1
  ⌊.25×{
    x y←⍵
    +/,{
      u v←⍵
        ((1+u v)⌷C)×((1+u v)⌷ia)×(2○○u×(16÷⍨1+2×x))×(2○○v×(16÷⍨1+2×y))
    }¨∘.,⍨¯1+⍳8
  }¨∘.,⍨¯1+⍳8
}

idct←{
  l←⍵
  zi←⊃,/{(⍵⊃f)⊃⊃⍵⌷r}¨⍳≢f←1 2⍴⍨≢r←(⊂∘⌽,⊂∘⊢)¨{⍸⍵=,↑{¯1+8⍴⍵↓⍳16}¨⍳8}¨⍳15
  bl←8 8⍴l[⍋zi]
  ifdct bl
}

parse_all_bits←{
  b←⍵
  m_size←2⊥(4×8)↑b
  b↓⍨←4×8
  m←m_size↑b
  b↓⍨←m_size
  dx←2⊥32↑b
  b↓⍨←32
  dy←2⊥32↑b
  b↓⍨←32
  noc←2⊥32↑b
  b↓⍨←32
  img_vals←↑[2]↑[1]{
    all_blocks←{
      DC←2040-⍨2⊥12↑b
      b↓⍨←12
      ACs c←parse_block_bits ⍬ b
      b↓⍨←(≢b)-≢c
      block←{(⍵×1>⍵÷255)+255×1≤⍵÷255}¨|idct DC,ACs
      block
    }¨⍳×/⌈8÷⍨dx dy
    ⊃⍪/,/(⌈8÷⍨dx dy)⍴all_blocks
  }¨⍳noc
  m img_vals
}

f5se←{
  i N M←⍵
  ⎕RL←N×M
  m o←parse_all_bits i
  (⊂m),⊂o
}
