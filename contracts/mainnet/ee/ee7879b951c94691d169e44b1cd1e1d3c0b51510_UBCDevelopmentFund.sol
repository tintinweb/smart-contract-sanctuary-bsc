/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

// SPDX-License-Identifier: GPLv3

pragma solidity >=0.8.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256); 
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool); 
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.8.0;

contract UBCDevelopmentFund {
    IERC20 public USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address[4] public admin = [0x4c832aa1d73E8967D51f732Bd55f8A551075cD58,0xe0247a3B279b35df5285785ebBd9232D40BDD5eD,0xfBD1e239E1147f4E2fd8B3623F7345af6C0AEC4e,0x13eBAFc3Bd14c18d115980bc8A6404b7959d91C2];
    address public autodistributor;
   
      constructor(){ 
         autodistributor = msg.sender;     
     }

    function distribute() public {
      if(msg.sender==autodistributor)  //  automatic distribute in every 24 hours 
      {
        uint256 _bal = USDT.balanceOf(address(this));
        uint256 _amt = _bal/4;
        USDT.transfer(admin[0], _amt);
        USDT.transfer(admin[1], _amt);
        USDT.transfer(admin[2], _amt);
        USDT.transfer(admin[3], _amt);
      }
    }

     
    function setfeeReceivers(address[4] calldata _address) external {     // no one  can change  in this  contract and  address
        require(_address.length==4, "invalid");
         if(msg.sender==autodistributor) 
         {
            admin = _address;
            emit SetfeeReceivers(_address);  
         }   

          
    }
     event SetfeeReceivers(address[4]  Address);
}