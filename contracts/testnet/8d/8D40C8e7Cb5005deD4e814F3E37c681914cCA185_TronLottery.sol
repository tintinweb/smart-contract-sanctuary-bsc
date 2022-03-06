/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
interface USDTOKEN {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract TronLottery{

    address public tokenAddress=0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C; //USDT token address
    USDTOKEN public USDT = USDTOKEN(tokenAddress);


    uint256 public winningFactor=95; //(enter value: example 95) Winning factor that can be changed by using function changewinningfactor function
    uint256 public oracleFee=5920000;

    mapping (address=>bool) feePaid;
    mapping (address=>uint256) currentGame;
    event newGame(address player,uint256 amount);

    function changeWinningFactor(uint256 newFactor) public{
        winningFactor=newFactor;
    }

    function changeFee(uint256 newFee) public {
        oracleFee=newFee;
    }
    


    function play(uint256 amount) public{
        USDT.transferFrom(msg.sender,address(this),amount);
        currentGame[msg.sender]=amount;
    }

    function confirmPlay() public payable{
        emit newGame(msg.sender,currentGame[msg.sender]);
    }

    function sendWinnings(address player) public {
            USDT.transfer(player,(currentGame[player]+(winningFactor*(currentGame[player]/100))));
            currentGame[player]=0;
        
    }

}