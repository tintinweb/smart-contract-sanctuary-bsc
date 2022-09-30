// contracts/Limoverse.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Distribute {
    IERC20 public token;
    event SendToken(address indexed tokenAddress, address[] recipients, uint[] amounts);
    event SendBNB(address[] recipients, uint[] amounts,uint count);

    function sendBNB(address[] memory _recipients, uint256[] memory _values) external payable {
        require(_recipients.length == _values.length, "Delegate :: length mismatch");
        
        uint count;
        for (uint256 i = 0; i < _recipients.length; i++){
            (bool sent,) = _recipients[i].call{value: _values[i]}("");
            if(sent) count++;
        }
        uint256 balance = address(this).balance;
        if (balance > 0){
            (bool sentBalance,) = msg.sender.call{value: balance}("");
            require(sentBalance, "unable to send the balance");
        }
        emit SendBNB(_recipients, _values, count);
    }

    function sendToken(
        address _tokenAddress,
        address[] memory _recipients,
        uint[] memory _amounts
    ) external {
        require(_recipients.length == _amounts.length, "Delegate :: length mismatch");
        token = IERC20(_tokenAddress);
        for (uint i = 0; i < _recipients.length; i++) {
          token.transferFrom(msg.sender, _recipients[i], _amounts[i]);
        }
        emit SendToken(_tokenAddress, _recipients, _amounts);
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