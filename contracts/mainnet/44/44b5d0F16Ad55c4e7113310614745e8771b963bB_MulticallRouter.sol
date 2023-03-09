// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "../utils/RevertMessageParser.sol";

/**
 * @title A contract that implements the chain of the calls on different contracts
 * @dev All function calls are currently implemented without side effects
 */
contract MulticallRouter is Context {
    /**
     * @notice Implements a chain of external calls
     * @param _amountIn input amount
     * @param _calldata array of encoded methods
     * @param _receiveSides array of contracts on which methods executions will take place
     * @param _path path of tokens
     * @param _offset array of shifts to patch the amount to calldata
     * @param _to address to send the dest token
     */
    function multicall(
        uint256 _amountIn,
        bytes[] memory _calldata,
        address[] memory _receiveSides,
        address[] memory _path,
        uint256[] memory _offset,
        address _to
    ) external {
        TransferHelper.safeTransferFrom(_path[0], _msgSender(), address(this), _amountIn);

        for (uint256 i = 0; i < _calldata.length; i++) {
            uint256 currentAmountIn = IERC20(_path[i]).balanceOf(address(this));
            bytes memory currentCalldata = _calldata[i];

            uint256 offset = _offset[i];
            assembly {
                mstore(add(currentCalldata, offset), currentAmountIn)
            }

            _lazyApprove(_path[i], _receiveSides[i], currentAmountIn);
            (bool success, bytes memory data) = _receiveSides[i].call(currentCalldata);
            if (!success) {
                revert(RevertMessageParser.getRevertMessage(data, "MulticallRouter: call failed"));
            }
        }

        uint256 finalAmountOut = IERC20(_path[_path.length - 1]).balanceOf(address(this));
        if (finalAmountOut != 0) {
            TransferHelper.safeTransfer(_path[_path.length - 1], _to, finalAmountOut);
        }
    }

    /**
     * @notice Implements approve
     * @dev Internal function used to approve the token spending
     * @param _token token address
     * @param _to address to approve
     * @param _amount amount for which approve will be given
     */
    function _lazyApprove(address _token, address _to, uint256 _amount) internal {
        if (IERC20(_token).allowance(address(this), _to) < _amount) {
            TransferHelper.safeApprove(_token, _to, type(uint256).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
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
            'TransferHelper::safeApprove: approve failed'
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
            'TransferHelper::safeTransfer: transfer failed'
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
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

library RevertMessageParser {
    function getRevertMessage(bytes memory _data, string memory _defaultMessage) internal pure returns (string memory) {
        // If the _data length is less than 68, then the transaction failed silently (without a revert message)
        if (_data.length < 68) return _defaultMessage;

        assembly {
            // Slice the sighash
            _data := add(_data, 0x04)
        }
        return abi.decode(_data, (string));
    }
}