/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

pragma solidity ^0.5.0;


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


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    //uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract TALETETokenSale {
    using SafeMath for uint256;
    address payable admin;
    uint256 Price = 4; //0.04 per token
    uint256 public feeDenominator = 100;
    
    uint256 public tokensSold;
    IERC20 public token = IERC20(0xd99b1Ea52F705BEbB4Aa923902454C77326B94C2);
    uint256 public totalSale = 10000;
    uint256 public decimals = 10**5;
    uint256 public contractBalance = token.balanceOf(address(this));


    event Sell(address _buyer, uint256 _amount);

    constructor() public {
        admin = 0x0Ca3Be8d394800D8B608cbEF02BF58F9B1D184f3;
        
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        uint256 tokenPrice = Price.div(feeDenominator);
        require(
            msg.value == _numberOfTokens * tokenPrice,
            "Number of tokens does not match with the value"
        );
        require(
            contractBalance >= _numberOfTokens,
            "Contact does not have enough tokens"
        );
        require(
            token.transfer(msg.sender, _numberOfTokens.mul(decimals)),
            "Some problem with token transfer"
        );
        tokensSold += _numberOfTokens.div(decimals);
        _forwardFunds();
        emit Sell(msg.sender, _numberOfTokens);
    }

    function _forwardFunds() internal {
    admin.transfer(address(this).balance);
    }

    function endSale() public {
        require(msg.sender == admin, "Only the admin can call this function");
        require(
            token.transfer(
                msg.sender,
                token.balanceOf(address(this))
            ),
            "Unable to transfer tokens to admin"
        );
        admin.transfer(address(this).balance);
        // destroy contract
        
    }
}