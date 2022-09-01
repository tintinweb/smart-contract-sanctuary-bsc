/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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


contract UnicallTest {
    IERC20 token1;
    IERC20 token2;

    uint256 token1Balance;
    uint256 token2Balance;

    address owner;
    
    event Pay(address indexed sender, uint256 value, string message);
    event TokensSended(address indexed sender, uint256 amount);
    event DoubleTokensSended(address indexed sender, uint256 amount1, uint256 amount2);
    event PayedAndDoubleTokensSended(address indexed sender, uint256 value, uint256 amount1, uint256 amount2);

    constructor (address _tokenAddress1, address _tokenAddress2) {
        token1 = IERC20(_tokenAddress1);
        token2 = IERC20(_tokenAddress2);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function pay(string memory _message) payable public {
        emit Pay(msg.sender, msg.value, _message);
    }

    function sendTokens(uint256 _amount) public {
        token1.transferFrom(msg.sender, address(this), _amount);
        token1Balance += _amount;
        emit TokensSended(msg.sender, _amount);
    }

    function sendTokensDouble(uint256 _amount1, uint256 _amount2) public {
        token1.transferFrom(msg.sender, address(this), _amount1);
        token1Balance += _amount1;
        token2.transferFrom(msg.sender, address(this), _amount2);
        token2Balance += _amount2;
        emit DoubleTokensSended(msg.sender, _amount1, _amount2);
    }

    function payAndSendTokensDouble(uint256 _amount1, uint256 _amount2) payable public {
        token1.transferFrom(msg.sender, address(this), _amount1);
        token1Balance += _amount1;
        token2.transferFrom(msg.sender, address(this), _amount2);
        token2Balance += _amount2;
        emit PayedAndDoubleTokensSended(msg.sender, msg.value, _amount1, _amount2);
    }

    function withdrawTokens(address _to) public onlyOwner() {
        token1.transfer(_to, token1Balance);
        token1Balance = 0;
        token2.transfer(_to, token2Balance);
        token2Balance = 0;
    }

}