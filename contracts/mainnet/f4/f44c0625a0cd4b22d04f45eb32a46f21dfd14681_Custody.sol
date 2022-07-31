// SPDX-License-Identifier: GPL-3
// © Siadyr Team
// written by Hermes ([email protected])
// gpg:395D4A5087DA0FF3861376CA1A450A54DA6C7F84

pragma solidity >=0.8.8 <0.9.0;

import "./SafeERC20.sol";

import "./recover.sol";

contract Custody is RecoverERC20 {
    using SafeERC20 for IERC20;

    address public beneficiary;

    IERC20  public siadyr;
    uint256 public released;

    event Released(uint256 amount);


    //////////////////////////////
    // Init

    constructor(address beneficiary_,
                address siadyr_)
    {
        beneficiary = beneficiary_;
        siadyr      = IERC20(siadyr_);
    }


    //////////////////////////////
    // Administration

    function release(uint256 amount) public can("release") {
        uint256 balance = siadyr.balanceOf(address(this));
        require(amount <= balance, "Not enough balance");

        uint256 initial = siadyr.balanceOf(beneficiary);
        siadyr.transfer(beneficiary, amount);
        uint256 got     = siadyr.balanceOf(beneficiary);

        require(got == initial + amount, "Can't release while taxed");
        emit Released(amount);
    }

    function recoverERC20(address lostToken) external override can("recoverERC20") {
        require(lostToken != address(siadyr), "Not so fast, cowboy!");
        unrestrictedRecoverERC20(lostToken);
    }

    function destroy() external can("destroy") {
        uint256 balance = IERC20(siadyr).balanceOf(address(this));
        require(balance == 0, "There are still tokens to be released");
        selfdestruct(payable(msg.sender));
    }
}