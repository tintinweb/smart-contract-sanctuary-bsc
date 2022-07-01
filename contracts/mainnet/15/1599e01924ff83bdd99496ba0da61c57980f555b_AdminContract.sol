/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
/*♻️♻️♻️♻️https://reutilizetudo.com/
                                    
.___________.  ______    __  ___  _______ .__   __.    .______       _______  __    __       _______. _______ 
|           | /  __  \  |  |/  / |   ____||  \ |  |    |   _  \     |   ____||  |  |  |     /       ||   ____|
`---|  |----`|  |  |  | |  '  /  |  |__   |   \|  |    |  |_)  |    |  |__   |  |  |  |    |   (----`|  |__   
    |  |     |  |  |  | |    <   |   __|  |  . `  |    |      /     |   __|  |  |  |  |     \   \    |   __|  
    |  |     |  `--'  | |  .  \  |  |____ |  |\   |    |  |\  \----.|  |____ |  `--'  | .----)   |   |  |____ 
    |__|      \______/  |__|\__\ |_______||__| \__|    | _| `._____||_______| \______/  |_______/    |_______|
                                                                                                              
   ♻️♻️♻️♻️✅Tokeconomics Token Reuse
   ♻️♻️♻️♻️✅All market transactions retain 6% for project maintenance 
   ♻️♻️♻️♻️✅All market transactions retain 2% for token repurchase
   ♻️♻️♻️♻️✅Option repurchase with or without automated burning
   ♻️♻️♻️♻️✅Anti dump controls
   ♻️♻️♻️♻️✅Audited contract
   ♻️♻️♻️♻️✅reutilizetudo.com

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
  address public immutable Dist4;

  address public immutable BUSD;

  
  //start
  constructor() {
    Dist1 = 0xD0b52863699c47D1BcecFB2034261A435b7386Ff;     // 1.25%
    Dist2 = 0x48001c7A94f0C55BdEe30f063C43C720dc762Cd0;     // 1.25%
    Dist3 = 0x4e8A42b481454C689B2779A048b3F176372a515f;     // 1%
    Dist4 = 0x91bC4eAEF4e0EE82a4126d0eC78B8476dC229D33;     // 8.5%

    BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;  
  }
  
  //receiver
  //receive() external payable {}


  function AdminDistribute() external {

  /*
   ♻️♻️♻️♻️✅Total Fees 8% Buy and 8% Sell to distributed as a below
   ♻️♻️♻️♻️♻️✅2.5% Tecnology
   ♻️♻️♻️♻️♻️✅5.5% Ecosystem
   ♻️♻️♻️♻️♻️✅1% Listing
   ♻️♻️♻️♻️♻️✅2% Marketing
   ♻️♻️♻️♻️♻️✅5% Buyback and Liquidity
   */

    uint Saldo = IERC20(BUSD).balanceOf(address(this));

    // integral 160  8% + 8% - 4% burn = 12%
    Saldo = Saldo.div(1200);

    uint cota1 = Saldo.mul(125); //♻️♻️♻️♻️♻️✅1.5%
    uint cota2 = Saldo.mul(125); //♻️♻️♻️♻️♻️✅1.5%
    uint cota3 = Saldo.mul(100); //♻️♻️♻️♻️♻️✅1% 
    uint cota4 = Saldo.mul(850); //♻️♻️♻️♻️♻️✅8.5%

    IERC20(BUSD).transfer(Dist1, cota1);
    IERC20(BUSD).transfer(Dist2, cota2);
    IERC20(BUSD).transfer(Dist3, cota3);
    IERC20(BUSD).transfer(Dist4, cota4);

    
  }


   
}