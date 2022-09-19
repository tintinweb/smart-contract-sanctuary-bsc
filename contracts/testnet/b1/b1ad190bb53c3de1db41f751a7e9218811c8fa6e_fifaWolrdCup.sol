/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract fifaWolrdCup {

    event Stake(address indexed from, address indexed to, uint256 value, stakeType stake_type, string stake_id,string order_id);
    event Donate(address indexed from, address indexed to, uint256 value, string order_id);
    enum stakeType {matches,teams,players,groups}

    //0x337610d27c682E347C9cD60BD4b3b107C9d34dDd bsc test
    //0x55d398326f99059fF775485246999027B3197955 bsc
    address public constant USDT_ADDRESS = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
    
    address public stakeReceiver;
    address public donateReceiver;
    IERC20 USDT = IERC20(USDT_ADDRESS);

    constructor(address _stakeReceiver,address _donateReceiver) {
        stakeReceiver = _stakeReceiver;
        donateReceiver = _donateReceiver;
    }

    function stake(uint256 _value,stakeType _stakeType,string calldata _stakeId,string calldata _orderId) public returns(bool) {
		bool status = USDT.transferFrom(msg.sender,stakeReceiver,_value);
        emit Stake(msg.sender,stakeReceiver,_value,_stakeType,_stakeId,_orderId);
        return status;
	}

    function donate(uint256 _value,string calldata _orderId) public returns(bool) {
		bool status = USDT.transferFrom(msg.sender,donateReceiver,_value);
        emit Donate(msg.sender,donateReceiver,_value,_orderId);
        return status;
	}

    modifier onlyStakeReceiver() {
        require(msg.sender == stakeReceiver, "Not stakeReceiver");
        _;
    }

    modifier onlyDonateReceiver() {
        require(msg.sender == donateReceiver, "Not donateReceiver");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function setStakeReceiver(address _newStakeReceiver) public onlyStakeReceiver validAddress(_newStakeReceiver) {
        stakeReceiver = _newStakeReceiver;
    }

    function setDonateReceiver(address _newDonateReceiver) public onlyDonateReceiver validAddress(_newDonateReceiver) {
        donateReceiver = _newDonateReceiver;
    }

}