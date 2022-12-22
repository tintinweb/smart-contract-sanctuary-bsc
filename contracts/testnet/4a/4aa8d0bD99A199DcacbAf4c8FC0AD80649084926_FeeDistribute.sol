/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT
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

interface IERC20 
{
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
    IERC20 public dai;

    uint256 public baseDivider = 200;
    address[4] public feeReceivers;
    uint256[4] public feeRates = [50, 50, 50, 50];

    constructor() public {
        dai = IERC20(0xD593ef3D4f6121a7a3e470937E650733FD7e1E16);
        feeReceivers[0] = 0xf2c4C27C29dce028390Ac8737Aa5BB4F52f1fB07;
        feeReceivers[1] = 0x84522E6FA5D0ff8831F5b0098887068e95555a7C;
        feeReceivers[2] = 0x99D49fd00f7c0b39e36277eBeFC3E8d74b88584C;
        feeReceivers[3] = 0x6c26B2b8126262a1C62bab878965954a971aD91f;
    }

    function distribute() public {
        uint256 balNow = dai.balanceOf(address(this));
        if(balNow > 0){
            for(uint256 i = 0; i < feeReceivers.length; i++){
                uint256 fee = balNow.mul(feeRates[i]).div(baseDivider);
                dai.transfer(feeReceivers[i], fee);
            }
        }
    }
}