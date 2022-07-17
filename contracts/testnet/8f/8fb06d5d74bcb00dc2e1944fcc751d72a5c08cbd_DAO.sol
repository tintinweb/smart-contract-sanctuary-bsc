/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

contract DAO {
    constructor() {}

    function batchTransferFromToken(
        address token,
        address[] calldata recipients,
        uint256 amount
    ) external {
        uint256 count = recipients.length;
        for (uint256 i = 0; i < count; i++) {
            TransferHelper.safeTransferFrom(
                token,
                msg.sender,
                recipients[i],
                amount
            );
        }
    }

    function batchTransferFromTokenWithAmount(
        address token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        uint256 count = recipients.length;
        for (uint256 i = 0; i < count; i++) {
            TransferHelper.safeTransferFrom(
                token,
                msg.sender,
                recipients[i],
                amounts[i]
            );
        }
    }

    function batchTransferToken(
        address token,
        address[] calldata recipients,
        uint256 amount
    ) external {
        uint256 count = recipients.length;
        for (uint256 i = 0; i < count; i++) {
            TransferHelper.safeTransfer(token, recipients[i], amount);
        }
    }

    function batchTransferTokenWithAmount(
        address token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        uint256 count = recipients.length;
        for (uint256 i = 0; i < count; i++) {
            TransferHelper.safeTransfer(token, recipients[i], amounts[i]);
        }
    }

    function batchTransferETH(address[] calldata recipients, uint256 amount)
        external
        payable
    {
        uint256 count = recipients.length;
        for (uint256 i = 0; i < count; i++) {
            TransferHelper.safeTransferETH(recipients[i], amount);
        }
    }

    function batchTransferETHWithAmount(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external payable {
        uint256 count = recipients.length;
        for (uint256 i = 0; i < count; i++) {
            TransferHelper.safeTransferETH(recipients[i], amounts[i]);
        }
    }

    function batchTransferTokenAndETH(
        address token,
        address[] calldata recipients,
        uint256 amountETH,
        uint256 amountToken
    ) external payable {
        uint256 count = recipients.length;
        for (uint256 i = 0; i < count; i++) {
            TransferHelper.safeTransferETH(recipients[i], amountETH);
            TransferHelper.safeTransferFrom(
                token,
                msg.sender,
                recipients[i],
                amountToken
            );
        }
    }

    function transferFromTokenAndETH(
        address token,
        address recipient,
        uint256 amountToken
    ) external payable {
        TransferHelper.safeTransferETH(recipient, msg.value);
        TransferHelper.safeTransferFrom(
            token,
            msg.sender,
            recipient,
            amountToken
        );
    }

    function transferETH(address recipient) external payable {
        TransferHelper.safeTransferETH(recipient, msg.value);
    }
}