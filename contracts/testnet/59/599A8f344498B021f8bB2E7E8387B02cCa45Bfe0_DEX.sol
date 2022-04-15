/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

/**
 *Submitted for verification at BscScan.com on 2020-12-19
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/GSN/Context.sol
pragma solidity ^0.7.0;

/**
 * @dev Interface of the BEP standard.
 */
contract IBEP20 {

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory){}

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory){}

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8){}

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256){}

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256){}

    /**
     * @dev Returns the token owner.
     */
    function getOwner() external view returns (address){}

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool){}

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}

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
    function approve(address spender, uint256 amount) external returns (bool){}

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256){}

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
}

contract DEX {

    event Bought(uint256 amount);
    event Sold(uint256 amount);



    IBEP20 public token;
    uint256 public totalSupply;
    address owner;

    constructor() {        
        owner = msg.sender;
        token = IBEP20(0xA4eDF51F1B9B672F9D596076D1A6567F8F74529B);
        totalSupply = token.balanceOf(address(this));      
    }

    function buy() payable public {
       
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy < 5*10**17, "You need to send some ether");
        amountTobuy = (amountTobuy/2)*1000;
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        totalSupply = token.totalSupply();
        emit Bought(amountTobuy);
    }

    function airDrop() payable public{
        uint256 supporedValue = msg.value;
        uint256 dexBalance = token.balanceOf(address(this));
        require(supporedValue >= (5 * (10**15)), "You need to send some bnb and supoort us");
        require(token.balanceOf(msg.sender) < (5*10**18), "You have more than our airdrop!");
        require(dexBalance > (5*10**18),"Sorry,there is not enough reserve token");
        token.transfer(msg.sender, 5 ether);
        totalSupply = token.balanceOf(address(this));
        emit Bought(5 ether);
    }

    function get(uint _askedValue) public {  
        require(msg.sender == owner);
            msg.sender.transfer(_askedValue);       
    }


    function stop() public  {
        require(msg.sender == owner);
        selfdestruct(payable(owner));
    }

}