// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract BNBDeposit {

    address public taxAddress;

    constructor() {
        taxAddress = payable(msg.sender);
    }

    function pay() external payable returns(bool) {
        IERC20 bnb = IERC20(address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd));
        bnb.transfer(taxAddress, 0.001 ether);
        return true;
    }
}