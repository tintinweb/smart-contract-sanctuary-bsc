/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
// File: multisend.sol

pragma solidity 0.8.10;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
}

library ERC20TransferHelper {
    function safeTransfer(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "ERC20TransferHelper: Transfer caller is not owner nor approved"
        );
    }
}

contract WingMultiSend {
    event TransferHelper(
        address indexed paymentContract,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    struct Investor {
        address investor;
        uint256 amount;
    }

    constructor() {}

    function send(
        address paymentContract,
        Investor[] memory arrInvestor
    ) external payable {
        if (paymentContract == address(0) && msg.value > 0) {
            uint256 totalPayout = 0;
            for (uint256 i = 0; i < arrInvestor.length; i++) {
                address to = arrInvestor[i].investor;
                uint256 amount = arrInvestor[i].amount;
                sendValue(payable(to), amount);
                totalPayout += amount;
                emit TransferHelper(paymentContract, msg.sender, to, amount);
            }
            require(msg.value == totalPayout, "Invalid native coin value");
        } else {
            IERC20 erc20Instance = IERC20(paymentContract);
            uint256 decimalsOfToken = erc20Instance.decimals();
            require(decimalsOfToken > 0, "Invalid ERC20 contract");

            for (uint256 i = 0; i < arrInvestor.length; i++) {
                address from = msg.sender;
                address to = arrInvestor[i].investor;
                uint256 amount = arrInvestor[i].amount;
                ERC20TransferHelper.safeTransfer(
                    paymentContract,
                    from,
                    to,
                    amount
                );
                emit TransferHelper(paymentContract, from, to, amount);
            }
        }
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Execute: Insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Execute: Unable to send value, recipient may have reverted"
        );
    }
}