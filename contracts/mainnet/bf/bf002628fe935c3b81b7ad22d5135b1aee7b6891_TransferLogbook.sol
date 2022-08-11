// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

import "../utils/ITransferLogbook.sol";

contract TransferLogbook is ITransferLogbook {
    mapping(address => mapping(address => bool)) public permission;

    mapping(address => uint256) public lastIndex;

    function logEvent(
        address token,
        uint256 amount,
        uint256 amountIn,
        uint256 amountOut,
        string calldata message
    ) external returns (uint256 index) {
        return
            _logEvent(msg.sender, token, amount, amountIn, amountOut, message);
    }

    function _logEvent(
        address sender,
        address token,
        uint256 amount,
        uint256 amountIn,
        uint256 amountOut,
        string calldata message
    ) internal returns (uint256 index) {
        lastIndex[sender] = lastIndex[sender] + 1;
        index = lastIndex[sender];
        emit LoggedEvent(
            sender,
            index,
            token,
            amount,
            amountIn,
            amountOut,
            message
        );
    }

    function logEventUpdate(
        uint256 index,
        uint256 amountUpdate,
        uint256 amountInUpdate,
        uint256 amountOutUpdate,
        string calldata messageUpdate
    ) public {
        _logEventUpdate(
            msg.sender,
            index,
            amountUpdate,
            amountInUpdate,
            amountOutUpdate,
            messageUpdate
        );
    }

    function _logEventUpdate(
        address sender,
        uint256 index,
        uint256 amountUpdate,
        uint256 amountInUpdate,
        uint256 amountOutUpdate,
        string calldata messageUpdate
    ) internal {
        emit LoggedEventUpdate(
            sender,
            index,
            amountUpdate,
            amountInUpdate,
            amountOutUpdate,
            messageUpdate
        );
    }

    function commissionedSwap(
        address sender,
        address recipient,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        string calldata message
    ) external override returns (uint256 index) {
        require(
            permission[sender][msg.sender],
            "TransferLogbook: permission required."
        );
        lastIndex[sender] = lastIndex[sender] + 1;
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

    function commissionedEvent(
        address sender,
        address token,
        uint256 amount,
        uint256 amountIn,
        uint256 amountOut,
        string calldata message
    ) external override returns (uint256 index) {
        require(
            permission[sender][msg.sender],
            "TransferLogbook: permission required."
        );
        return _logEvent(sender, token, amount, amountIn, amountOut, message);
    }

    function commissionedEventUpdate(
        address sender,
        uint256 index,
        uint256 amountUpdate,
        uint256 amountInUpdate,
        uint256 amountOutUpdate,
        string calldata messageUpdate
    ) public override {
        require(
            permission[sender][msg.sender],
            "TransferLogbook: permission required."
        );
        _logEventUpdate(
            sender,
            index,
            amountUpdate,
            amountInUpdate,
            amountOutUpdate,
            messageUpdate
        );
    }

    function setPermission(address instance, bool allowed) external {
        permission[msg.sender][instance] = allowed;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

interface ITransferLogbook {
    event LoggedEvent(
        address indexed sender,
        uint256 indexed index,
        address indexed token,
        uint256 amount,
        uint256 amountIn,
        uint256 amountOut,
        string message
    );
    event LoggedEventUpdate(
        address indexed sender,
        uint256 indexed index,
        uint256 amountUpdate,
        uint256 amountInUpdate,
        uint256 AmountOutUpdate,
        string messageUpdate
    );
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

    function commissionedSwap(
        address sender,
        address recipient,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        string calldata message
    ) external returns (uint256 index);

    function commissionedEvent(
        address sender,
        address token,
        uint256 amount,
        uint256 amountIn,
        uint256 amountOut,
        string memory message
    ) external returns (uint256 index);

    function commissionedEventUpdate(
        address sender,
        uint256 index,
        uint256 amountUpdate,
        uint256 amountInUpdate,
        uint256 amountOutUpdate,
        string memory message
    ) external;

    function setPermission(address instance, bool allowed) external;
}