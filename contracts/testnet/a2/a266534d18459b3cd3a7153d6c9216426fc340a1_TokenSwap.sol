/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *  SPDX-License-Identifier: MIT
*/
pragma solidity 0.6.12;


interface IBEP20 {

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

 
contract TokenSwap {
    
    //create state variables
    
    IBEP20 public busd ;
    IBEP20 public time;
    address public salewallet=0xe15505C74B9122185bFC6a27fe3c8D8c144f2e9f;
    
    //when deploying pass in owner 1 and owner 2
    
    constructor(

        ) public {
            busd = IBEP20(0x8516Fc284AEEaa0374E66037BD2309349FF728eA);
            time = IBEP20(0x4C4d752dAcc8ec21ba783285b7a8603560941db0);
        }
        
        //this function will allow 2 people to trade 2 tokens as the same time (atomic) and swap them between accounts
        //Bob holds token 1 and needs to send to alice
        //Alice holds token 2 and needs to send to Bob
        //this allows them to swap an amount of both tokens at the same time
        
        //*** Important ***
        //this contract needs an allowance to send tokens at token 1 and token 2 that is owned by owner 1 and owner 2
        
        function test() public view  returns (address account, uint256 _busd, uint256 _time)
        { 
            account=address(this) ;
            _busd=busd.allowance(msg.sender, address(this));
            _time=time.allowance(msg.sender, address(this))  ;
            return (address(this),busd.allowance(msg.sender, address(this)),time.allowance(msg.sender, address(this))) ;
        }

        function swap( uint _amount1, uint _amount2) public {
            require(busd.allowance(msg.sender, address(this)) >= _amount1, "Token 1 allowance too low");
            require(time.allowance(msg.sender, address(this)) >= _amount1, "Token 2 allowance too low");
            
            //transfer TokenSwap
            //busd, msg.sender, amount 1 -> salewallet.  needs to be in same order as function
            _safeTransferFrom(busd, msg.sender, salewallet, _amount1);
            //time, salewallet, amount 2 -> msg.sender.  needs to be in same order as function
            _safeTransferFrom(time, salewallet, msg.sender, _amount2);
            
            
        }
        //This is a private function that the function above is going to call
        //the result of this transaction(bool) is assigned in a variable called sent
        //then we require the transfer to be successful
        function _safeTransferFrom(IBEP20 token, address sender, address recipient, uint amount) private {bool sent = token.transferFrom(sender, recipient, amount);
            require(sent, "Token transfer failed");
            
        }
}