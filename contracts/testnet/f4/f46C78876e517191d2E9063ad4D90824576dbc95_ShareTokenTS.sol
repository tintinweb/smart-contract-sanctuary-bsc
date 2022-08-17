/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

     function whaleBurn(uint256 value) external;

     function dAppBurn(uint256 value) external;
    
}

contract ShareTokenTS {

    IERC20 public _tokenTS;  
    address public owner;
  
    constructor(){
        owner = msg.sender;
       _tokenTS = IERC20(0x75d4e628611f26922Ab77352f2246B0ecD9587ab);
    }

    function receiveFees() public payable{
      // receive fees of owner;
    }

    // check quyen owner
    modifier checkOwner{
        require(msg.sender==owner, "you can not make...");
        _;
    } 
  
   
    function shareToken(address addressGet) public{
       _tokenTS.transfer(addressGet, 10*10**18); //share10 token;
    }

    // 
    function burnTokenWhale(uint256 amount) public{
        _tokenTS.approve(msg.sender, amount);
        _tokenTS.transferFrom(msg.sender, address(this), amount);
        _tokenTS.whaleBurn(amount); // _tokenTS need burn;
    }

    // 
    function burnTokenDapp(uint256 amount) public{
        _tokenTS.transferFrom(msg.sender, address(this), amount);
        _tokenTS.dAppBurn(amount); // _tokenTS need burn;
    }

    
}


// 0x75d4e628611f26922Ab77352f2246B0ecD9587ab