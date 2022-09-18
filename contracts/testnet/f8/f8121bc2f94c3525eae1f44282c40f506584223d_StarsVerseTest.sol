/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: GPL-3.0-or-later
// Includes openzeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/) code with MIT license

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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


contract StarsVerseTest {
    string _creator;

    constructor(string memory _name) {
        _creator = _name;
    }

    function creator() public view virtual returns (string memory) {
        return _creator;
    }

    function TransferEther(address[] calldata recipients, uint256[] calldata values) external payable returns (bool){

        for (uint256 i = 0; i < recipients.length; i++)
            payable(recipients[i]).transfer(values[i]);

        uint256 balance = address(this).balance;
        require(balance > 0, "Failed: Not enough balance");
        payable(msg.sender).transfer(balance);

        return true;
    }

    function StarTransferToken(IERC20 token, address[] calldata recipients, uint256[] calldata values) external returns (bool) {
        
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.balanceOf(msg.sender) >= total, "Failed: Not enough balance");
        require(token.allowance(msg.sender, address(this)) >= total, "Failed: Not enough allowance");
        require(token.transferFrom(msg.sender, address(this), total), "Token: Failed to transfer tokens to StarVerse");
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]), "Token: Failed to transfer tokens to recipients");
        
        return true;
    }

    function StarTransferTokenSimple(IERC20 token, address[] calldata recipients, uint256[] calldata values) external returns (bool) {
        
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.balanceOf(msg.sender) >= total, "Failed: Not enough balance");
        require(token.allowance(msg.sender, address(this)) >= total, "Failed: Allowance is less than transfer amount");
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transferFrom(msg.sender, recipients[i], values[i]), "Token: Failed to transfer tokens to recipients");
        
        return true;
    }

}