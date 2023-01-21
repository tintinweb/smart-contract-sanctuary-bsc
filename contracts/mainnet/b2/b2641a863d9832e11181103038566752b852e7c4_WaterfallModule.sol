// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Class with helper read functions for clone with immutable args.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Clone.sol)
/// @author Adapted from clones with immutable args by zefram.eth, Saw-mon & Natalie
/// (https://github.com/Saw-mon-and-Natalie/clones-with-immutable-args)
abstract contract Clone {
    /// @dev Reads an immutable arg with type bytes.
    function _getArgBytes(uint256 argOffset, uint256 length) internal pure returns (bytes memory arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            // Grab the free memory pointer.
            arg := mload(0x40)
            // Store the array length.
            mstore(arg, length)
            // Copy the array.
            calldatacopy(add(arg, 0x20), add(offset, argOffset), length)
            // Allocate the memory, rounded up to the next 32 byte boudnary.
            mstore(0x40, and(add(add(arg, 0x3f), length), not(0x1f)))
        }
    }

    /// @dev Reads an immutable arg with type address.
    function _getArgAddress(uint256 argOffset) internal pure returns (address arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint256
    function _getArgUint256(uint256 argOffset) internal pure returns (uint256 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @dev Reads a uint256 array stored in the immutable args.
    function _getArgUint256Array(uint256 argOffset, uint256 length) internal pure returns (uint256[] memory arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            // Grab the free memory pointer.
            arg := mload(0x40)
            // Store the array length.
            mstore(arg, length)
            // Copy the array.
            calldatacopy(add(arg, 0x20), add(offset, argOffset), shl(5, length))
            // Allocate the memory.
            mstore(0x40, add(add(arg, 0x20), shl(5, length)))
        }
    }

    /// @dev Reads an immutable arg with type uint64.
    function _getArgUint64(uint256 argOffset) internal pure returns (uint64 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xc0, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint8.
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }

    /// @return offset The offset of the packed immutable args in calldata.
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        assembly {
            offset := sub(calldatasize(), shr(0xf0, calldataload(sub(calldatasize(), 2))))
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Caution! This library won't check that a token has code, responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error ETHTransferFailed();

    error TransferFromFailed();

    error TransferFailed();

    error ApproveFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function safeTransferETH(address to, uint256 amount) internal {
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(0x00, 0x23b872dd)
            mstore(0x20, from) // Append the "from" argument.
            mstore(0x40, to) // Append the "to" argument.
            mstore(0x60, amount) // Append the "amount" argument.

            if iszero(
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    // We use 0x64 because that's the total length of our calldata (0x04 + 0x20 * 3)
                    // Counterintuitively, this call() must be positioned after the or() in the
                    // surrounding and() because and() evaluates its arguments from right to left.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }
    }

    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(0x00, 0xa9059cbb)
            mstore(0x20, to) // Append the "to" argument.
            mstore(0x40, amount) // Append the "amount" argument.

            if iszero(
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    // We use 0x44 because that's the total length of our calldata (0x04 + 0x20 * 2)
                    // Counterintuitively, this call() must be positioned after the or() in the
                    // surrounding and() because and() evaluates its arguments from right to left.
                    call(gas(), token, 0, 0x1c, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x40, memPointer) // Restore the memPointer.
        }
    }

    function safeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(0x00, 0x095ea7b3)
            mstore(0x20, to) // Append the "to" argument.
            mstore(0x40, amount) // Append the "amount" argument.

            if iszero(
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    // We use 0x44 because that's the total length of our calldata (0x04 + 0x20 * 2)
                    // Counterintuitively, this call() must be positioned after the or() in the
                    // surrounding and() because and() evaluates its arguments from right to left.
                    call(gas(), token, 0, 0x1c, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `ApproveFailed()`.
                mstore(0x00, 0x3e3f8f73)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x40, memPointer) // Restore the memPointer.
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {Clone} from "solady/utils/Clone.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

/// @title WaterfallModule
/// @author 0xSplits
/// @notice A maximally-composable waterfall contract allowing multiple
/// recipients to receive preferential payments before residual funds flow to a
/// final address.
/// @dev Only one token can be waterfall'd for a given deployment. There is a
/// recovery method for non-target tokens sent by accident.
/// Target ERC20s with very large decimals may overflow & cause issues.
/// This contract uses token = address(0) to refer to ETH.
contract WaterfallModule is Clone {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using SafeTransferLib for address;

    /// -----------------------------------------------------------------------
    /// errors
    /// -----------------------------------------------------------------------

    /// Invalid token recovery; cannot recover the waterfall token
    error InvalidTokenRecovery_WaterfallToken();

    /// Invalid token recovery recipient
    error InvalidTokenRecovery_InvalidRecipient();

    /// Invalid distribution
    error InvalidDistribution_TooLarge();

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    /// Emitted after each successful ETH transfer to proxy
    /// @param amount Amount of ETH received
    /// @dev embedded in & emitted from clone bytecode
    event ReceiveETH(uint256 amount);

    /// Emitted after funds are waterfall'd to recipients
    /// @param recipients Addresses receiving payouts
    /// @param payouts Amount of payout
    /// @param pullFlowFlag Flag for pushing funds to recipients or storing for pulling
    event WaterfallFunds(
        address[] recipients, uint256[] payouts, uint256 pullFlowFlag
    );

    /// Emitted after non-waterfall'd tokens are recovered to a recipient
    /// @param nonWaterfallToken Recovered token (cannot be waterfall token)
    /// @param recipient Address receiving recovered token
    /// @param amount Amount of recovered token
    event RecoverNonWaterfallFunds(
        address nonWaterfallToken, address recipient, uint256 amount
    );

    /// Emitted after funds withdrawn using pull flow
    /// @param account Account withdrawing funds for
    /// @param amount Amount withdrawn
    event Withdrawal(address account, uint256 amount);

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants
    /// -----------------------------------------------------------------------

    address internal constant ETH_ADDRESS = address(0);

    uint256 internal constant PUSH = 0;
    uint256 internal constant PULL = 1;

    uint256 internal constant ONE_WORD = 32;
    uint256 internal constant THRESHOLD_BITS = 96;
    uint256 internal constant ADDRESS_BITS = 160;
    uint256 internal constant ADDRESS_BITMASK = uint256(~0 >> THRESHOLD_BITS);

    /// -----------------------------------------------------------------------
    /// storage - cwia offsets
    /// -----------------------------------------------------------------------

    // token (address, 20 bytes), nonWaterfallRecipient (address, 20 bytes),
    // numTranches (uint64, 8 bytes), tranches (uint256[], numTranches * 32 bytes)

    // 0; first item
    uint256 internal constant TOKEN_OFFSET = 0;
    // 20 = token_offset (0) + token_size (address, 20 bytes)
    uint256 internal constant NON_WATERFALL_RECIPIENT_OFFSET = 20;
    // 40 = nonWaterfallRecipient_offset (20) + nonWaterfallRecipient_size (address, 20 bytes)
    uint256 internal constant NUM_TRANCHES_OFFSET = 40;
    // 48 = numTranches_offset (40) + numTranches_size (uint64, 8 bytes)
    uint256 internal constant TRANCHES_OFFSET = 48;

    /// Address of ERC20 to waterfall (0x0 used for ETH)
    /// @dev equivalent to address public immutable token;
    function token() public pure returns (address) {
        return _getArgAddress(TOKEN_OFFSET);
    }

    /// Address to recover non-waterfall tokens to
    /// @dev equivalent to address public immutable nonWaterfallRecipient;
    function nonWaterfallRecipient() public pure returns (address) {
        return _getArgAddress(NON_WATERFALL_RECIPIENT_OFFSET);
    }

    /// Number of waterfall tranches
    /// @dev equivalent to uint64 internal immutable numTranches;
    /// clones-with-immutable-args limits uint256[] array length to uint64
    function numTranches() internal pure returns (uint256) {
        return uint256(_getArgUint64(NUM_TRANCHES_OFFSET));
    }

    /// Get waterfall tranche `i`
    /// @dev emulates to uint256[] internal immutable tranche;
    function _getTranche(uint256 i) internal pure returns (uint256) {
        unchecked {
            // shouldn't overflow
            return _getArgUint256(TRANCHES_OFFSET + i * ONE_WORD);
        }
    }

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    /// Amount of distributed waterfall token
    /// @dev ERC20s with very large decimals may overflow & cause issues
    uint128 public distributedFunds;

    /// Amount of active balance set aside for pulls
    /// @dev ERC20s with very large decimals may overflow & cause issues
    uint128 public fundsPendingWithdrawal;

    /// Mapping to account balances for pulling
    mapping(address => uint256) internal pullBalances;

    /// -----------------------------------------------------------------------
    /// constructor
    /// -----------------------------------------------------------------------

    // solhint-disable-next-line no-empty-blocks
    /// clone implementation doesn't use constructor
    constructor() {}

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    /// emit event when receiving ETH
    /// @dev implemented w/i clone bytecode
    /* receive() external payable { */
    /*     emit ReceiveETH(msg.value); */
    /* } */

    /// Waterfalls target token inside the contract to next-in-line recipients
    /// @dev pushes funds to recipients
    function waterfallFunds() external payable {
        _waterfallFunds(PUSH);
    }

    /// Waterfalls target token inside the contract to next-in-line recipients
    /// @dev backup recovery if any recipient tries to brick the waterfall for
    /// remaining recipients
    function waterfallFundsPull() external payable {
        _waterfallFunds(PULL);
    }

    /// Recover non-waterfall'd tokens to a recipient
    /// @param nonWaterfallToken Token to recover (cannot be waterfall token)
    /// @param recipient Address to receive recovered token
    function recoverNonWaterfallFunds(
        address nonWaterfallToken,
        address recipient
    ) external payable {
        /// checks

        // revert if caller tries to recover waterfall token
        if (nonWaterfallToken == token()) {
            revert InvalidTokenRecovery_WaterfallToken();
        }

        // if nonWaterfallRecipient is set, recipient must match it
        // else, recipient must be one of the waterfall's recipients

        address _nonWaterfallRecipient = nonWaterfallRecipient();
        if (_nonWaterfallRecipient == address(0)) {
            // ensure txn recipient is a valid waterfall recipient
            (address[] memory recipients,) = getTranches();
            bool validRecipient = false;
            uint256 _numTranches = numTranches();
            for (uint256 i; i < _numTranches;) {
                if (recipients[i] == recipient) {
                    validRecipient = true;
                    break;
                }
                unchecked {
                    // shouldn't overflow
                    ++i;
                }
            }
            if (!validRecipient) {
                revert InvalidTokenRecovery_InvalidRecipient();
            }
        } else if (recipient != _nonWaterfallRecipient) {
            revert InvalidTokenRecovery_InvalidRecipient();
        }

        /// effects

        /// interactions

        // recover non-target token
        uint256 amount;
        if (nonWaterfallToken == ETH_ADDRESS) {
            amount = address(this).balance;
            recipient.safeTransferETH(amount);
        } else {
            amount = ERC20(nonWaterfallToken).balanceOf(address(this));
            nonWaterfallToken.safeTransfer(recipient, amount);
        }

        emit RecoverNonWaterfallFunds(nonWaterfallToken, recipient, amount);
    }

    /// Withdraw token balance for account `account`
    /// @param account Address to withdraw on behalf of
    function withdraw(address account) external {
        address _token = token();
        uint256 tokenAmount = pullBalances[account];
        unchecked {
            // shouldn't underflow; fundsPendingWithdrawal = sum(pullBalances)
            fundsPendingWithdrawal -= uint128(tokenAmount);
        }
        pullBalances[account] = 0;
        if (_token == ETH_ADDRESS) {
            account.safeTransferETH(tokenAmount);
        } else {
            _token.safeTransfer(account, tokenAmount);
        }

        emit Withdrawal(account, tokenAmount);
    }

    /// -----------------------------------------------------------------------
    /// functions - view & pure
    /// -----------------------------------------------------------------------

    /// Return unpacked tranches
    /// @return recipients Addresses to waterfall payments to
    /// @return thresholds Absolute payment thresholds for waterfall recipients
    function getTranches()
        public
        pure
        returns (address[] memory recipients, uint256[] memory thresholds)
    {
        uint256 numRecipients = numTranches();
        uint256 numThresholds;
        unchecked {
            // shouldn't underflow
            numThresholds = numRecipients - 1;
        }
        recipients = new address[](numRecipients);
        thresholds = new uint256[](numThresholds);

        uint256 i = 0;
        uint256 tranche;
        for (; i < numThresholds;) {
            tranche = _getTranche(i);
            recipients[i] = address(uint160(tranche));
            thresholds[i] = tranche >> ADDRESS_BITS;
            unchecked {
                ++i;
            }
        }
        // recipients has one more entry than thresholds
        recipients[i] = address(uint160(_getTranche(i)));
    }

    /// Returns the balance for account `account`
    /// @param account Account to return balance for
    /// @return Account's balance waterfall token
    function getPullBalance(address account) external view returns (uint256) {
        return pullBalances[account];
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    /// Waterfalls target token inside the contract to next-in-line recipients
    /// @dev can PUSH or PULL funds to recipients
    function _waterfallFunds(uint256 pullFlowFlag) internal {
        /// checks

        /// effects

        // load storage into memory

        address _token = token();
        uint256 _startingDistributedFunds = uint256(distributedFunds);
        uint256 _endingDistributedFunds;
        uint256 _memoryFundsPendingWithdrawal = uint256(fundsPendingWithdrawal);
        unchecked {
            // shouldn't overflow
            _endingDistributedFunds = _startingDistributedFunds
            // fundsPendingWithdrawal is always <= _startingDistributedFunds
            - _memoryFundsPendingWithdrawal
            // recognizes 0x0 as ETH
            // shouldn't need to worry about re-entrancy from ERC20 view fn
            + (
                _token == ETH_ADDRESS
                    ? address(this).balance
                    : ERC20(_token).balanceOf(address(this))
            );
        }

        (address[] memory recipients, uint256[] memory thresholds) =
            getTranches();

        // determine the first and last payout tranches based on previously distributed
        // funds & funds to be distributed

        uint256 _firstPayoutTranche;
        uint256 _lastPayoutTranche;
        unchecked {
            // shouldn't underflow; numTranches() >= 2
            uint256 finalTranche = numTranches() - 1;
            // shouldn't overflow; finalTranche << 2^64
            // (contract would exceed byte limit well before then)
            for (; _firstPayoutTranche < finalTranche; ++_firstPayoutTranche) {
                if (thresholds[_firstPayoutTranche] > _startingDistributedFunds)
                {
                    break;
                }
            }
            _lastPayoutTranche = _firstPayoutTranche;
            // shouldn't overflow; finalTranche << 2^64
            // (contract would exceed byte limit well before then)
            for (; _lastPayoutTranche < finalTranche; ++_lastPayoutTranche) {
                if (thresholds[_lastPayoutTranche] >= _endingDistributedFunds) {
                    break;
                }
            }
        }

        // construct the payout arrays

        uint256 _payoutsLength;
        unchecked {
            // shouldn't underflow; _lastPayoutTranche >= _firstPayoutTranche
            _payoutsLength = _lastPayoutTranche - _firstPayoutTranche + 1;
        }
        address[] memory _payoutAddresses = new address[](_payoutsLength);
        uint256[] memory _payouts = new uint256[](_payoutsLength);

        // scope allows compiler to discard vars on stack to avoid stack-too-deep
        {
            uint256 _paidOut = _startingDistributedFunds;
            uint256 _index;
            uint256 _threshold;
            uint256 i; // = 0
            uint256 loopLength;
            unchecked {
                // shouldn't underflow; _payoutsLength >= 1
                loopLength = _payoutsLength - 1;
            }
            for (; i < loopLength;) {
                unchecked {
                    // shouldn't overflow
                    _index = _firstPayoutTranche + i;

                    _payoutAddresses[i] = recipients[_index];
                    _threshold = thresholds[_index];
                    // shouldn't underflow;
                    // _paidOut = _startingDistributedFunds < thresholds[_firstPayoutTranche],
                    // _paidOut = thresholds[i] < thresholds[i + 1],
                    // thresholds are monotonically increasing
                    _payouts[i] = _threshold - _paidOut;
                    _paidOut = _threshold;

                    // shouldn't overflow
                    ++i;
                }
            }
            // i = _payoutsLength - 1, i.e. last payout
            unchecked {
                // shouldn't overflow
                _payoutAddresses[i] = recipients[_firstPayoutTranche + i];
                // shouldn't underflow;
                // _paidOut = threshold[_payoutsLength - 1] < _endingDistributedFunds
                _payouts[i] = _endingDistributedFunds - _paidOut;
            }

            if (_endingDistributedFunds > type(uint128).max) {
                revert InvalidDistribution_TooLarge();
            }
            distributedFunds = uint128(_endingDistributedFunds);
        }

        /// interactions

        // pay outs
        // earlier tranche recipients may try to re-enter but will cause fn to revert
        // when later external calls fail (bc balance is emptied early)
        for (uint256 i; i < _payoutsLength;) {
            if (pullFlowFlag == PULL) {
                pullBalances[_payoutAddresses[i]] += _payouts[i];
                _memoryFundsPendingWithdrawal += _payouts[i];
            } else if (_token == ETH_ADDRESS) {
                (_payoutAddresses[i]).safeTransferETH(_payouts[i]);
            } else {
                _token.safeTransfer(_payoutAddresses[i], _payouts[i]);
            }

            unchecked {
                // shouldn't overflow
                ++i;
            }
        }

        if (pullFlowFlag == PULL) {
            fundsPendingWithdrawal = uint128(_memoryFundsPendingWithdrawal);
        }

        emit WaterfallFunds(_payoutAddresses, _payouts, pullFlowFlag);
    }
}