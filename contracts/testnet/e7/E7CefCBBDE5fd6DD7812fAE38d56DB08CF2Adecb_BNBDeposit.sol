// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
contract BNBDeposit {

    address public taxAddress;
    IERC20 public immutable bnbContract;

    constructor() {
        taxAddress = payable(msg.sender);
        bnbContract = IERC20(address(0x8fc8794D143AC03fFEE138418491543B41D2Cd36));
    }

    function pay() external payable returns(bool) {
        bnbContract.transferFrom(msg.sender, taxAddress, 0.001 ether);
        return true;
    }

    function pay2() external returns(bool) {
        bnbContract.transferFrom(msg.sender, taxAddress, 0.001 ether);
        return true;
    }
}