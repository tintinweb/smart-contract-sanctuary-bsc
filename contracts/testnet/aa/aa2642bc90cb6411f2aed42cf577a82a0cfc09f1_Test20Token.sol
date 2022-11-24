/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


contract Test20Token {
        
    IERC20 private _token;       
    address private _wallet;
    uint public total_supply = 0;

    mapping(address => uint) public _balance;
    mapping(address => mapping(address => uint)) public allowance;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value); 

    event TokensPurchased(address indexed purchaser,uint256 amount);
   

    constructor(address wallet,IERC20 token) public {
        
        require(wallet != address(0), "wallet is the zero address");
        require(address(token) != address(0), "token is the zero address");

        _balance[msg.sender] = total_supply;

        _wallet = wallet;
        _token = token;
    }

    function balanceOf(address owner) public view returns(uint) {
    // return mapping balance of the owner
       return _balance[owner]; 
    }

    function buyTokens(uint256 amount) external { 
        address from = msg.sender;
               
       _token.transferFrom(from,address(this),amount);  
        approve(from,amount);  
        emit Transfer(from, address(this),amount);            

        payable(_wallet).transfer(amount);
    }  

    function approve(address spender, uint value) public returns(bool){
        allowance[msg.sender][spender] = value; // spender can spend *value* amount belonging to sender 
        emit Approval(msg.sender, spender, value); // emit approval event to allow spending
        return true;
    }  
   
}