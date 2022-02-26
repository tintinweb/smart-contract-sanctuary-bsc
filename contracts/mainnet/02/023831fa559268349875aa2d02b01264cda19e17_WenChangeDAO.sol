/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

/*
20k Collection of ERC-720 stored on the Etherium Blockchain. A DAO created as a movement by multiple 
communities from this space in order to support the current situation in Ukraine.100% of the 
proceeds are going towards multiple charity organisations directly from the contract.
 _  _  _ _______ __   _      _______ _     _ _______ __   _  ______ _______      ______  _______  _____
 |  |  | |______ | \  |      |       |_____| |_____| | \  | |  ____ |______      |     \ |_____| |     |
 |__|__| |______ |  \_|      |_____  |     | |     | |  \_| |_____| |______      |_____/ |     | |_____|
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

contract WenChangeDAO {
    string public name = "WenChangeDAO";
    string public symbol = "WEN";
    uint256 public totalSupply = 1000000000000000000000000000;
    uint8 public decimals = 9;
    
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

     /**
     * @dev Emitted when the allowance of a `_spenderWEN` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed _ownerWEN,
        address indexed __spenderWEN,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

     /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
     /**
     * @dev Sets `amount` as the allowance of `_spenderWEN` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: BeWENe that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the _spenderWEN's allowance to 0 and set the
     * desired value afterWENds:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
 
    function approve(address __spenderWEN, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][__spenderWEN] = _value;
        emit Approval(msg.sender, __spenderWEN, _value);
        return true;
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
        emit Transfer(_from, _to, _value);
        return true;
    }
}