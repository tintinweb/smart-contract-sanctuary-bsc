/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: MIT

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface Token {
    function transferFrom(address, address, uint256) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);
}

interface oldStaking {
    function calcWithdraw(address to) external returns (uint256);
}


contract PHXstakingPRO is Ownable { 

     address public tokenAddress = 0x9776191F4ebBBa7f358C1663bF82C0a0906c77Fa;

    address public oldContract = 0xfc3F294CFF2200f8E7a7Cc83d252A730124e2377;

    bool withdrawOld = true;

    mapping(address => bool) public oldWithdrawStatus;


  function transferAnyERC20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        require(_tokenAddr != tokenAddress, "Cannot Transfer Out PHX!");
        Token(_tokenAddr).transfer(_to, _amount);
    }

    function withdrawFromOldContract(address to) public {
        require(withdrawOld == true, "withdrawal is disabled");
        require(
            oldWithdrawStatus[to] == false,
            "you already withdrew from old contract"
        );
        uint256 value = oldStaking(oldContract).calcWithdraw(to);
        if (value > 0) {
            Token(tokenAddress).transfer(to, value);
        }
        oldWithdrawStatus[to] = true;
    }

    function withdrawOldSwitch(bool _value) public onlyOwner {
        withdrawOld = _value;
    }

    function withdrawAdmin(address to, uint256 amount) public onlyOwner {
        uint256 balance = Token(tokenAddress).balanceOf(address(this));
        if (amount > balance) {
            Token(tokenAddress).transfer(to, balance);
        } else {
            Token(tokenAddress).transfer(to, amount);
        }
    }}