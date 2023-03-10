/**
 *Submitted for verification at BscScan.com on 2023-03-10
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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    
}

contract Presale{
    // Token to be sold
    IERC20 public token = IERC20(0x2B6679118A6a586Fa8e6168CBe8335433A2b5279);
    address public owner;

    // Exchange rates
    uint256 public busdRate = 746; // 1 BUSD = 0.746 ERC20
    uint256 public usdtRate = 746; // 1 USDT = 0.746 ERC20

    // Amount of tokens sold
    uint256 public tokensSold;

    // Minimum and maximum purchase amounts
    uint256 public minPurchaseAmount = 100 * 10 ** 18; // 100 USDT/BUSD minimum purchase
    uint256 public maxPurchaseAmount =10000* 10 ** 18; // 0 means no maximum purchase amount

    // Total amount of BUSD and USDT raised
    uint256 public totalBusdRaised;
    uint256 public totalUsdtRaised;

    // Withdrawal addresses
    IERC20 public busdadd=IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 public usdtadd=IERC20(0x55d398326f99059fF775485246999027B3197955);

    // Total supply of tokens
    uint256 public totalSupply = 21000000 * 10 ** 18;

    // Events
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 rate);
    event FundsWithdrawn(address indexed owner, uint256 busdAmount, uint256 usdtAmount);

    constructor(
    ) {
        
        owner = msg.sender;
    }

    function buyWithBusd(uint256 _busdAmount) external {
        require(_busdAmount < minPurchaseAmount, "Amount too small");
        require(_busdAmount > maxPurchaseAmount, "Amount too large");
        
        uint256 tokenAmount = _busdAmount * busdRate / 1000;
require((tokensSold += tokenAmount) <= totalSupply , "Token Limit Reached" );
        require(busdadd.transferFrom(msg.sender, address(this), _busdAmount), "Transfer failed");
        tokensSold += tokenAmount;
        totalBusdRaised += _busdAmount;
        token.transfer(msg.sender,tokenAmount);

        emit TokensPurchased(msg.sender, tokenAmount, busdRate);
    }

    function buyWithUsdt(uint256 _usdtAmount) external {
      require(_usdtAmount < minPurchaseAmount, "Amount too small");
        require(_usdtAmount > maxPurchaseAmount, "Amount too large");
        
        uint256 tokenAmount = _usdtAmount * usdtRate / 1000;
require((tokensSold += tokenAmount) <= totalSupply , "Token Limit Reached" );

        require(usdtadd.transferFrom(msg.sender, address(this), _usdtAmount), "Transfer failed");
        tokensSold += tokenAmount;
        totalUsdtRaised += _usdtAmount;
        token.transfer(msg.sender,tokenAmount);

        emit TokensPurchased(msg.sender, tokenAmount, usdtRate);
    }
 function withdraw() public payable{
        require(msg.sender == owner, "Only Owner can withdraw");
        usdtadd.transfer(msg.sender,usdtadd.balanceOf(address(this)));
        busdadd.transfer(msg.sender,busdadd.balanceOf(address(this)));

    }
}