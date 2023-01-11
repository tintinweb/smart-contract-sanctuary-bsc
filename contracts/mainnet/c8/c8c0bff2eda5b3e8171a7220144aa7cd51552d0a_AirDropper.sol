/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


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
    function transferFrom(
        address sender,
        address recipient,
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

contract AirDropper {

    constructor() {}

    function airdrop(address _token, address[] memory _receivers, uint256[] memory _amounts) public payable {
        require(_receivers.length == _amounts.length, "Receivers not match amounts");

        if (_token == address(0)) {
            uint256 totalAmount;
        unchecked {
            for (uint i = 0; i < _amounts.length; i++) {
                totalAmount += _amounts[i];
            }
        }//unchecked
            require(totalAmount <= msg.value, "Eth not enough");
            //refund
            if (msg.value - totalAmount > 0) {
                payable(msg.sender).transfer(msg.value - totalAmount);
            }
        }

        for (uint i = 0; i < _receivers.length; i++) {
            if (_amounts[i] == 0) {
                continue;
            }
            if (_token == address(0)) {
                payable(_receivers[i]).transfer(_amounts[i]);
            } else {
                try IERC20(_token).transferFrom(msg.sender, _receivers[i], _amounts[i]) returns (bool success){
                    (success);
                } catch Error(string memory revertReason){
                    revert(revertReason);
                }catch {
                    revert("Not ERC20");
                }
            }
        }
    }


}