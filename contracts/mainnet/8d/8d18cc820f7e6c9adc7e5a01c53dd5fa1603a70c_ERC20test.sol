/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

// SPDX-License-Identifier: MIT

// ----------------------------------------------------------------------------
// Token Standard
// By cyphersapiens
// ----------------------------------------------------------------------------

pragma solidity ^0.8.0;

interface ERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library UnsafeMath {
    function unsafe_add(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }
 
    function unsafe_sub(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a - b;
        }
    }
 
    function unsafe_div(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 result;
            assembly {
                result := div(a, b)
            }
            return result;
        }
    }
 
    function unsafe_mul(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a * b;
        }
    }
 
    function unsafe_increment(uint256 a) internal pure returns (uint256) {
        unchecked {
            return ++a;
        }
    }
 
    function unsafe_decrement(uint256 a) internal pure returns (uint256) {
        unchecked {
            return --a;
        }
    }
}

contract ERC20test is ERC20 {
    using UnsafeMath for uint256;

    string public constant name = "ERC20BasicTest";
    string public constant symbol = "ERCT";
    uint8 public constant decimals = 1;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_ = 100000;

    uint256 private _liquidityFee = 1;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public buyLiquidityFee = _liquidityFee;

    uint256 public SellLiquidityFee = 1;



   constructor() {
    balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}