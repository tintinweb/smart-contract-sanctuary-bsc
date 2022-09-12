/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.7.1;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

  
    contract KhinkaliToken {

        string public name = "KhinkaliToken";
        string public symbol = "KHT";
        string public _totalSupply;
        uint8 public decimals = 18;
        
        uint256 public totalSupply;
        uint256 public _address;
        event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value,
        uint256 _tTax,
        uint256 _buytax,
        uint256 _charitytax,
        uint256 _owneraddress 
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public addressToAmountFunded;
    mapping(uint256 => address) public AmmountToaddressFunded;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */

    constructor (uint256 totalSupply) public {
        balanceOf[msg.sender] = totalSupply;
    }
      /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    }