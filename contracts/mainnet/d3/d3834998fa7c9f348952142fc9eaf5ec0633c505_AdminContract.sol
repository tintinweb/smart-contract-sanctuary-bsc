/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
/*💰💳💰💳 rightcoin
                                     *********                                  
                                    ***********                                 
                                    ***********                                 
                                    ***********                                 
                               ******  ****   *******                           
                           *************    *************                       
                        *******    ******  *****    ********                    
                    *******         ***********         *******                 
          *****   *******           ***********           *******   ******      
       *********** *****             *********             ***** ***********    
      ************* ********         *********         ******** *************   
       ***********    ***********                 ***********    ***********    
        *********   **************               ***************   ********     
               ******************                 ******************            
             ******    *********                   **********   ******          
              *****                                             *****           
               ****              *               *              ****            
                **            *******         *******          *  **            
                *****      ************     ************      *****             
                 ******  *************       ************** ******              
                  ************ ******         ****** ************               
                   ***        ******           ******                           
                    ********  *****             *****   ********                
                  ***********  *********    * ******  ***********               
                  ************ ***********         *  ************              
                  ***********                          ***********                
                    *******                              *******                      
  ____    _           _       _      ____           _           
 |  _ \  (_)   __ _  | |__   | |_   / ___|   ___   (_)  _ __    
 | |_) | | |  / _` | | '_ \  | __| | |      / _ \  | | | '_ \   
 |  _ <  | | | (_| | | | | | | |_  | |___  | (_) | | | | | | |  
 |_| \_\ |_|  \__, | |_| |_|  \__|  \____|  \___/  |_| |_| |_|  
              |___/                                             

   💰💳💰💳✅Tokeconomics RightCoin
   💰💳💰💳✅All market transactions retain 8% for token maintenance 
   💰💳💰💳✅All market transactions retain 2% for token repurchase
   💰💳💰💳✅Option repurchase with or without automated burning
   💰💳💰💳✅Anti dump control
   💰💳💰💳✅Audited contract
*/
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

contract AdminContract {

  using SafeMath for uint;

  address public immutable Dist1;
  address public immutable Dist2;
  address public immutable Dist3;

  address public immutable BUSD;

  
  //start
  constructor() {
    Dist1 = 0xD0b52863699c47D1BcecFB2034261A435b7386Ff;     // 1.25%
    Dist2 = 0x48001c7A94f0C55BdEe30f063C43C720dc762Cd0;     // 1.25%
    Dist3 = 0x3C6B38EaF1E135395B86dE368B39aac03Bd47b4C;     // 9.5%

    BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;  
  }
  
  //receiver
  //receive() external payable {}


  function AdminDistribute() external {

  /*
   ✅Total Fees 8% Buy and 8% Sell to distributed as a below
   */

    uint Saldo = IERC20(BUSD).balanceOf(address(this));

    // 16% integer = 160  (8% + 8%) - 4% "burn" = 12% fee
    Saldo = Saldo.div(1200);

    uint cota1 = Saldo.mul(125); //✅1.25%
    uint cota2 = Saldo.mul(125); //✅1.25%
    uint cota3 = Saldo.mul(950); //✅9.5% 

    IERC20(BUSD).transfer(Dist1, cota1);
    IERC20(BUSD).transfer(Dist2, cota2);
    IERC20(BUSD).transfer(Dist3, cota3);
    
  }


   
}