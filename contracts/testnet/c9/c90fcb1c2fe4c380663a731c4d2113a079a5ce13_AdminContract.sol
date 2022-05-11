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
  address public immutable Dist5;

  address public immutable BUSD;

  
  //start
  constructor() {
    Dist1 = 0x73a21A4F77DfD4C232AA9a851eAA5ED1FbB4F9bF;
    Dist2 = 0x73a21A4F77DfD4C232AA9a851eAA5ED1FbB4F9bF;
    Dist3 = 0x73a21A4F77DfD4C232AA9a851eAA5ED1FbB4F9bF;
    Dist4 = 0x73a21A4F77DfD4C232AA9a851eAA5ED1FbB4F9bF;
    Dist5 = 0x73a21A4F77DfD4C232AA9a851eAA5ED1FbB4F9bF;

    BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;  
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

    // integral 160  8% + 8% - 4% = 12%
    Saldo = Saldo.div(120);

    uint cota1 = Saldo.mul(25); //♻️♻️♻️♻️♻️✅2.5% Tecnology
    uint cota2 = Saldo.mul(55); //♻️♻️♻️♻️♻️✅5.5% Ecosystem 
    uint cota3 = Saldo.mul(10); //♻️♻️♻️♻️♻️✅1% Listing
    uint cota4 = Saldo.mul(20); //♻️♻️♻️♻️♻️✅2% Marketing
    uint cota5 = Saldo.mul(10); //♻️♻️♻️♻️♻️✅5% Buyback and Liquidity 4 no contrato + 1 % aqui

    IERC20(BUSD).transfer(Dist1, cota1);
    IERC20(BUSD).transfer(Dist2, cota2);
    IERC20(BUSD).transfer(Dist3, cota3);
    IERC20(BUSD).transfer(Dist4, cota4);
    IERC20(BUSD).transfer(Dist5, cota5);

    
  }


   
}