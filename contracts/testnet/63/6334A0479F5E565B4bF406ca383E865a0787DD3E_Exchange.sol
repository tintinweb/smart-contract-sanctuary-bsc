// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Exchange{
     IERC20 _token1;
    IERC20 _token2;
    address owner;
    mapping(address =>uint) tokenOneBalance;
    mapping(address =>uint) balances;
    mapping(address =>uint) tokenTwoBalance;
    uint public tokensPerBNB = 10;
     constructor(address token1 ,address token2 ,address _owner) {
        _token1 = IERC20(token1);
        _token2 = IERC20(token2);
        owner=_owner;
    }
     function buyTokenOneUsingTokenTwo(uint amount) public{
      require(_token2.balanceOf(msg.sender) >= amount,"Insufficient token1 balance");
      _token2.transferFrom(msg.sender,address(this), amount);
      _token1.transfer(msg.sender, amount);
    }
     function buyTokenTwoUsignTokenOne(uint amount) external{
        require(_token1.balanceOf(msg.sender) >= amount,"Insufficient token1 balance");
      _token1.transferFrom(msg.sender,address(this), amount);
      _token2.transfer(msg.sender, amount);
    }
    function buyTokenOne() public payable returns (uint256 tokenAmount) {
     require(msg.value > 0 , "Send ETH to buy some tokens");
     uint256 tokensToBuy = msg.value  * tokensPerBNB;
      uint256 ownerBalance = _token1.balanceOf(address(this));
      require(ownerBalance >= tokensToBuy, "Owner has insufficient tokens");
      //  _token1.transferFrom(address(this), msg.sender, tokensToBuy);
        _token1.transfer(msg.sender, tokensToBuy);
    //    payable(address(this)).transfer(msg.value);
       _token1.transfer(address(this),tokenAmount);
       balances[msg.sender]+=tokensToBuy;
       return tokensToBuy;
   }
   function sellTokenOneToBuyBNB() external payable  returns (uint256 amountToken){
       require(balances[msg.sender] > 0, "No tokens to sell");
       require(_token1.balanceOf(msg.sender) > 0, "No tokens to sell");
       uint256 amount = _token1.balanceOf(msg.sender) / tokensPerBNB;
       _token1.transferFrom(msg.sender,address(this),_token1.balanceOf(msg.sender));
       payable(msg.sender).transfer(amount);
       balances[msg.sender] -= _token1.balanceOf(msg.sender);
       return amount;
   }
}