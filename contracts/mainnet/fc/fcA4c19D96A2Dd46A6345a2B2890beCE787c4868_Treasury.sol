//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./common/TransferHelper.sol";

contract Treasury {
    address public admin = msg.sender;
    mapping(address => bool) public operators;
    
    event AdminTransfered(
        address oldAdmin,
        address newAdmin
    );

    event OperatorStatusChanged(
        address operator,
        bool status
    );

    event EtherReceive(
        uint256 value
    );

    modifier onlyAdmin {
        require(msg.sender == admin, "Treasury: Only admin");
        _;
    }

    modifier onlyOperator {
        require(operators[msg.sender] || msg.sender == admin, 
            "Treasury: Permission denied");
        _;
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
        emit AdminTransfered(msg.sender, newAdmin);
    }

    function setOperator(address operator, bool status) external onlyAdmin {
        require(operators[operator] != status, "Trasury: Operator already set");
        operators[operator] = status;
        emit OperatorStatusChanged(operator, status);
    }

    function withdraw(address token, address to, uint256 value) external onlyOperator {
        TransferHelper.safeTransfer(token, to, value);
    }

    function withdrawEth(address to, uint256 value) external onlyOperator {
        TransferHelper.safeTransferETH(to, value);
    }

    receive() external payable {
        emit EtherReceive(
            msg.value
        );
    }

    fallback() external payable {
        revert("Treasury: Call undefined func");
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: approve"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: transfer"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: transferFrom"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH transfer");
    }
}