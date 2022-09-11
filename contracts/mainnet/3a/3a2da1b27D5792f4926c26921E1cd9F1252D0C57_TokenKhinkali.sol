/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.7.1;
  
    contract TokenKhinkali {
        string public name = "TokenKhinkali";
        string public symbol = "TKH";
        uint256 public totalSupply = 1000000000000000000000000000000000000;
        uint8 public decimals = 18;
        
        uint256 public _totalSupply;
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

    constructor () {
        balanceOf[msg.sender] = totalSupply;

    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
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