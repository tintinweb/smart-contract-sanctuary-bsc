// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "../utils/ITransferLogbook.sol";

contract TransferLogbook is ITransferLogbook {
    mapping(address => mapping(address => bool)) public permission;

    mapping(address => uint256) public lastIndex;

    modifier allowed(address sender) {
        lastIndex[sender] = lastIndex[sender] + 1;
        require(
            permission[sender][msg.sender],
            "TransferLogbook: permission required"
        );
        _;
    }

    function commissionedSwap(
        address sender,
        address recipient,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        string calldata message
    ) external override allowed(sender) returns (uint256 index) {
        index = lastIndex[sender];
        emit LoggedSwap(
            sender,
            index,
            recipient,
            tokenA,
            tokenB,
            amountA,
            amountB,
            message
        );
    }

    function commissionedTransfer(
        address sender,
        address recipient,
        address token,
        uint256 amountOut,
        uint256 amountIn,
        string calldata message
    ) external override allowed(sender) returns (uint256 index) {
        index = lastIndex[sender];
        emit LoggedTransfer(
            sender,
            index,
            recipient,
            token,
            amountOut,
            amountIn,
            message
        );
    }

    function setPermission(address instance, bool enabled) external {
        permission[msg.sender][instance] = enabled;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface ITransferLogbook {
    event LoggedSwap(
        address indexed sender,
        uint256 indexed index,
        address recipient,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        string message
    );

    event LoggedTransfer(
        address indexed sender,
        uint256 indexed index,
        address recipient,
        address token,
        uint256 amountOut,
        uint256 amountIn,
        string message
    );

    function commissionedSwap(
        address sender,
        address recipient,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        string calldata message
    ) external returns (uint256 index);

    function commissionedTransfer(
        address sender,
        address recipient,
        address token,
        uint256 amountOut,
        uint256 amountIn,
        string memory message
    ) external returns (uint256 index);
}