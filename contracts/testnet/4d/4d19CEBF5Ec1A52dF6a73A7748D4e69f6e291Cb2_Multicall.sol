// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error ErrorHandler__ExecutionFailed();

library ErrorHandler {
    function handleRevertIfNotSuccess(
        bool ok_,
        bytes memory revertData_
    ) internal pure {
        assembly {
            if iszero(ok_) {
                let revertLength := mload(revertData_)
                if iszero(iszero(revertLength)) {
                    // Start of revert data bytes. The 0x20 offset is always the same.
                    revert(add(revertData_, 0x20), revertLength)
                }

                //  revert ErrorHandler__ExecutionFailed()
                mstore(0x00, 0xa94eec76)
                revert(0x1c, 0x04)
            }
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.10;

error ReentrancyGuard__Locked();

abstract contract ReentrancyGuard {
    uint256 private __locked;

    modifier nonReentrant() {
        __nonReentrantBefore();
        _;
        __nonReentrantAfter();
    }

    constructor() payable {
        assembly {
            sstore(__locked.slot, 1)
        }
    }

    function __nonReentrantBefore() private {
        assembly {
            if eq(sload(__locked.slot), 2) {
                mstore(0x00, 0xc0d27a97)
                revert(0x1c, 0x04)
            }
            sstore(__locked.slot, 2)
        }
    }

    function __nonReentrantAfter() private {
        assembly {
            sstore(__locked.slot, 1)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.17;

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
    function _msgSender() internal view virtual returns (address sender) {
        assembly {
            sender := caller()
        }
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMulticall {
    error Multicall__DelegatecallNotAllowed();

    struct CallData {
        address target;
        uint256 value;
        bytes data;
    }

    event BatchExecuted(
        address indexed account,
        uint256 indexed value,
        CallData[] callData,
        bytes[] results
    );

    function multicall(
        CallData[] calldata calldata_,
        bytes calldata data_
    ) external payable returns (bytes[] memory results);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Context} from "../oz/utils/Context.sol";
import {ReentrancyGuard} from "../oz/security/ReentrancyGuard.sol";

import {IMulticall} from "./interfaces/IMulticall.sol";

import {ErrorHandler} from "../libraries/ErrorHandler.sol";

contract Multicall is Context, IMulticall, ReentrancyGuard {
    using ErrorHandler for bool;
    /**
     * @dev Address of the original contract
     */
    address private immutable __original;

    modifier nonDelegatecall() virtual {
        __nonDelegatecall();
        _;
    }

    /**
     * @dev Constructor that saves the address of the original contract
     */
    constructor() payable ReentrancyGuard() {
        __original = address(this);
    }

    function multicall(
        CallData[] calldata calldata_,
        bytes calldata data_
    ) external payable virtual returns (bytes[] memory results) {
        results = _multicall(calldata_, data_);
    }

    function _multicall(
        CallData[] calldata calldata_,
        bytes calldata
    )
        internal
        virtual
        nonDelegatecall
        nonReentrant
        returns (bytes[] memory results)
    {
        uint256 length = calldata_.length;
        results = new bytes[](length);
        bool ok;
        bytes memory result;
        for (uint256 i; i < length; ) {
            (ok, result) = calldata_[i].target.call{value: calldata_[i].value}(
                calldata_[i].data
            );

            ok.handleRevertIfNotSuccess(result);

            results[i] = result;

            unchecked {
                ++i;
            }
        }

        emit BatchExecuted(_msgSender(), msg.value, calldata_, results);
    }

    function __nonDelegatecall() private view {
        if (address(this) != __original)
            revert Multicall__DelegatecallNotAllowed();
    }
}