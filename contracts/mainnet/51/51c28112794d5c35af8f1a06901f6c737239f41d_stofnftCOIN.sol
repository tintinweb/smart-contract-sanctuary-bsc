/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

/*
stofnft
stofnft (stofnft)

stofnft  🌐
Official Fan Token of stofnft  🚀
Reduce
Your Exposure to
Crypto Market Risks

Choose a cover pool, select its duration, and enter how much you need to cover. 
Instantly receive your claims payout in stablecoin after incident resolution.

stofnft 
@stofnft
Let's reduce your exposure to crypto market risks
stofnft.com

https://twitter.com/stofnft

Get exclusive access
to the synthetic asset
platform
Mint, trade, and manage synthetic stocks and commodities.
Earn a level 2 founders NFT. Become an OG.
Participate in an incentivized testnet!

Join us: http://linktr.ee/stofnft.com
Science & Technology
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract stofnftCOIN {
    string public name = "stofnft";
    string public symbol = "stofnft";
    uint256 public totalSupply = 10000000000000000000000;
    uint8 public decimals = 9;
    
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

     /**
     * @dev Emitted when the allowance of a `_spenderstofnft` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed _ownerstofnft,
        address indexed __spenderstofnft,
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
     * @dev Sets `amount` as the allowance of `_spenderstofnft` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the _spenderstofnft's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
 
    function approve(address __spenderstofnft, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][__spenderstofnft] = _value;
        emit Approval(msg.sender, __spenderstofnft, _value);
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