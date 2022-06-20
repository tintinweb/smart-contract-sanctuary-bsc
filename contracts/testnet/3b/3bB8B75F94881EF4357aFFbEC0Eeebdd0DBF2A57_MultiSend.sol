/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: MIT
// File: multisend.sol


pragma solidity 0.8.10;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
library ERC20TransferHelper {
    function safeTransfer(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "ERC20TransferHelper: Transfer caller is not owner nor approved");
    }
}
contract MultiSend {

    event TransferHelper(address indexed from, address indexed to, uint256 indexed amount);

    struct Investor {
        address investor;
        uint256 amount;
    }

    address paymentContract;

    constructor(address _erc20Address) {
        paymentContract = _erc20Address;
    }

    function multiSendErc20(Investor[] memory arrInvestor) external {
        for (uint256 i = 0; i < arrInvestor.length; i++) {
            address from = msg.sender;
            address to = arrInvestor[i].investor;
            uint256 amount = arrInvestor[i].amount;
            ERC20TransferHelper.safeTransfer(paymentContract, from, to, amount);
            emit TransferHelper(from, to, amount);
        }
    }
}