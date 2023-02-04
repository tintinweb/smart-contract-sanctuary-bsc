/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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

contract FeeReceiver {

    address public dev0 = 0x52F4813539e2044a597A5080BfA7e3a2BD08bAef;
    address public dev1 = 0x06fe7eB32a532Bce5a8e63f21DD597927E923B0e;

    function setDev0(address newDev0) external {
        require(msg.sender == dev0, 'Only Dev0');
        dev0 = newDev0;
    }

    function setDev1(address newDev1) external {
        require(msg.sender == dev1, 'Only Dev0');
        dev1 = newDev1;
    }

    function withdraw(address token) external {
        IERC20(token).transfer(dev0, IERC20(token).balanceOf(address(this)));
    }

    function withdrawETH() external {
        (bool s,) = payable(dev0).call{value: address(this).balance}("");
        require(s);
    }

    function trigger(address token, uint256) external {

        bool isETH = token == address(0);

        uint bal = isETH ? address(this).balance : IERC20(token).balanceOf(address(this));
        if (bal == 0) {
            return;
        }

        uint dev0Cut = bal / 2;
        uint dev1Cut = bal - dev0Cut;

        if (isETH) {
            _send(dev0, dev0Cut);
            _send(dev1, dev1Cut);
        } else {
            IERC20(token).transfer(dev0, dev0Cut);
            IERC20(token).transfer(dev1, dev1Cut);
        }
    }

    function _send(address to, uint amount) internal {
        (bool s,) = payable(to).call{value: amount}("");
        require(s);
    }

    receive() external payable {}
}