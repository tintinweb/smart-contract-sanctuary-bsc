/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.12;

library SafeMath {    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FeeDistribute {
    using SafeMath for uint256; 
    IBEP20 public busd;

    uint256 public baseDivider = 200;
    address[6] public feeReceivers;
    uint256[6] public feeRates = [40, 40, 40, 40, 30, 10];

    constructor() public {
        busd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        feeReceivers[0] = 0xc49120F9e8b7592A9ee6bE451C464D4f60339a2c;
        feeReceivers[1] = 0x255f3409B2d91C943bF909fB1d9a666B0cEB23eA;
        feeReceivers[2] = 0xD14A016832Ac0CEB2b8677634F51793de77a7525;
        feeReceivers[3] = 0xBf4c63a6207b9308333542057E104166f6ec89fB;
        feeReceivers[4] = 0xD0a48f8Bb5181199fa5d02f0dF17A5f3ECd8EE3a;
        feeReceivers[5] = 0x2CDd27B02F7E435483e4490539e17B3109EAcb50;
    }

    function distribute() public {
        uint256 balNow = busd.balanceOf(address(this));
        if(balNow > 0){
            for(uint256 i = 0; i < feeReceivers.length; i++){
                uint256 fee = balNow.mul(feeRates[i]).div(baseDivider);
                busd.transfer(feeReceivers[i], fee);
            }
        }
    }
}