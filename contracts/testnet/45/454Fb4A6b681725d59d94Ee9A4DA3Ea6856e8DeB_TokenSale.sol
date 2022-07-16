pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TokenSale {
    
    IERC20 public tokenContract;  // the token being sold
    uint256 public priceAngleRound;
    uint256 public pricePrivate;              // the price, in wei, per token
    uint256 public pricePublic;
    uint256 public priceSeedRound;
    address owner;
    uint256 public tokensSold;
    event Sold(address buyer, uint256 amount);

    constructor(IERC20 _tokenContract, uint256 _priceSeedRound, uint256 _priceAngleRound, uint256 _pricePrivate, uint256 _pricePublic) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        pricePrivate = _pricePrivate;
        pricePublic = _pricePublic;
        priceSeedRound = _priceSeedRound;
        priceAngleRound = _priceAngleRound;
    }

    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function buyTokensSeedRound(uint256 value) public payable {
        require(value > 0, "You must buy with amount bigger than 0");

        uint256 numberOfTokens = value * 100 / priceSeedRound * 10e18;

        require(tokenContract.balanceOf(owner) >= numberOfTokens, "Not enough tokens");

        payable(owner).transfer(msg.value);

        emit Sold(msg.sender, numberOfTokens);
        
        tokensSold += numberOfTokens;

        require(tokenContract.transferFrom(owner, msg.sender, numberOfTokens));
    }

    function buyTokensAngleRound(uint256 value) public payable {
        require(value > 0, "You must buy with amount bigger than 0");

        uint256 numberOfTokens = value * 100 / priceAngleRound * 10e18;

        require(tokenContract.balanceOf(owner) >= numberOfTokens, "Not enough tokens");

        payable(owner).transfer(msg.value);

        emit Sold(msg.sender, numberOfTokens);
        
        tokensSold += numberOfTokens;

        require(tokenContract.transferFrom(owner, msg.sender, numberOfTokens));
    }

    function buyTokensPrivate(uint256 value) public payable {

        require(value > 0, "You must buy with amount bigger than 0");

        uint256 numberOfTokens = value * 100 / pricePrivate * 10e18;

        require(tokenContract.balanceOf(owner) >= numberOfTokens, "Not enough tokens");

        payable(owner).transfer(msg.value);

        emit Sold(msg.sender, numberOfTokens);
        
        tokensSold += numberOfTokens;

        require(tokenContract.transferFrom(owner, msg.sender, numberOfTokens));
    }

    function buyTokensPublic(uint256 value) public payable {

        require(value > 0, "You must buy with amount bigger than 0");

        uint256 numberOfTokens = value * 100 / pricePublic * 10e18;

        require(tokenContract.balanceOf(owner) >= numberOfTokens, "Not enough tokens");

        payable(owner).transfer(msg.value);

        emit Sold(msg.sender, numberOfTokens);
        
        tokensSold += numberOfTokens;

        require(tokenContract.transferFrom(owner, msg.sender, numberOfTokens));
    }
}

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