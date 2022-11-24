/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

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
   
    IERC20 public busd;     
    address private _wallet;
    address private owner;
      
     event Deposit(address user, uint256 amount);
   

    constructor(address wallet,address _busdContract){   
         _wallet = wallet;
         busd =IERC20(_busdContract);
         owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function buyTokens(uint256 _busd) external {
        busd.allowance(address(this),msg.sender);		
		_deposit(_busd);		
        emit Deposit(msg.sender,_busd);
    }

    function _deposit(uint256 _amount) private {        
            busd.transferFrom(msg.sender, address(this),_amount);   
			busd.approve(msg.sender,_amount);  			
    }  

    function GetUserTokenBalance() public view returns(uint256){ 
       return busd.balanceOf(msg.sender);
    }

    function GetAllowance() public view returns(uint256){
       return busd.allowance(msg.sender, address(this));
    }
   
   function AcceptPayment(uint256 _tokenamount) public returns(bool) {
       // _tokenAmount cannot exceed allowance. In this case I put equals symbol to prevent require error
       require(_tokenamount >= GetAllowance(), "Please approve tokens before transferring");
       // Use transferFrom() function if you want to transfer from user to smart contract a specific amount of tokens.
       busd.transferFrom(msg.sender, address(this), _tokenamount);
       return true;
   }
   
   function GetContractTokenBalance() public OnlyOwner view returns(uint256){
       return busd.balanceOf(address(this));
   }
   
}