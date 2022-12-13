/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.9;

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

// File: swap.sol


pragma solidity 0.8.9;


contract TokenSwaps {
    address payable owner;
    uint256 ratio;
    uint256 times;
    mapping (address => uint256) public converted;
    mapping (address => uint256) public convertedToken;
    IERC20 public constant token1 = IERC20(0x7f629f02e0E9529887146d04efa633f2219Bb5b4);
    IERC20 public constant token2 = IERC20(0xBB350e13819543cf3b35A2AafBc3a4f801401Fa0);
    uint256 swapLockTime;

    constructor(){
        owner = payable(msg.sender);
        times = block.timestamp + 15 days;
        ratio = 0.5 ether;
        swapLockTime =  block.timestamp + 105 days;
    }

    modifier onlyOwner() {
        payable(msg.sender) == owner;
        _;
    }

    function setRatio(uint256 paraRatio) public onlyOwner {
        ratio = paraRatio;
    }

    function getRatio() public view onlyOwner returns (uint256) {
        return ratio;
    }

    function setTime(uint256 paraTime) external onlyOwner{
        times = block.timestamp +  paraTime * 86400;
    }

    function getTime() external view onlyOwner returns(uint256){
        return times;
    }

    function swapCitrus(address walletAddress, uint256 amount) public returns (uint256) {
        require(block.timestamp < times, "time over");
        require(amount > 0, "amount must be greater then zero");
        require(
            token1.balanceOf(walletAddress) >= amount,
            "sender doesn't have enough Tokens"
        );

        uint256 exchange = (amount * ratio) / 10**18;

        require(
            exchange > 0,
            "exchange Amount must be greater then zero"
        );

        require(
            token2.balanceOf(address(this)) > exchange,
            "currently the exchange doesnt have enough TestToken Tokens, please retry later :=("
        );

        require(
            token1.transferFrom(walletAddress, address(this), amount), 
            "failed transfer to the contract"
            );
        require(token2.approve(address(this), exchange), "fail to approve");
        require(token2.transferFrom(
            address(this),
            address(walletAddress),
            exchange
        ), "failed transfer to the user");

        converted[walletAddress] = swapLockTime;
        convertedToken[walletAddress] = exchange;
        return exchange;
    }

    function withdrawTokens(address paraTo, uint paraAmount) external onlyOwner(){
        require(token1.transfer(paraTo, paraAmount), "failed withdrawal");

    }
}