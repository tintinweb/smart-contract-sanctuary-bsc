// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "../interfaces/ILiquidityPool.sol";
import "../interfaces/IReferralManager.sol";
import "../libraries/LibSubAccount.sol";
import "../libraries/LibOrder.sol";
import "../orderbook/Types.sol";

interface IInternalFlashTaker {
    function internalFlashTake(FlashTakeParam calldata order) external;
}

library LibFlashTake {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // keccak256(abi.encodePacked("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"))
    bytes32 internal constant FLASH_TAKE_DOMAIN_HASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    // keccak256(bytes("MUX Protocol"))
    bytes32 internal constant FLASH_TAKE_NAME_HASH = 0x095b39c6e1c90d875997697322803685b422ef81f122ae9e1b3fa7d00be00155;
    // keccak256(bytes("v1"))
    bytes32 internal constant FLASH_TAKE_VERSION_HASH =
        0x0984d5efd47d99151ae1be065a709e56c602102f24c1abc4008eb3f815a8d217;
    // keccak256(abi.encodePacked("FlashTake(bytes32 subAccountId,uint96 collateral,uint96 size,uint96 gasFee,bytes32 referralCode,uint8 orderType,uint8 flags,uint8 profitTokenId,uint32 placeOrderTime,uint32 salt)"))
    bytes32 internal constant FLASH_TAKE_TYPE_HASH = 0xd8c31d819b70be06a8d8983e9a7f567c7786030cef350957d3a42d2eb321cc55;

    event FillingFlashTake(uint64 indexed flashTakeSequence);
    event FillFlashTake(
        bytes32 indexed subAccountId,
        uint64 indexed flashTakeSequence,
        uint96 collateral, // erc20.decimals
        uint96 size, // 1e18
        uint96 gasFee, // 1e18
        uint8 profitTokenId,
        uint8 flags,
        string errorMessage // errorMessage = "" if success
    );

    function flashTake(
        FlashTakeParam[] calldata orders,
        address orderBook,
        uint64 previousFlashTakeSequence,
        mapping(bytes32 => uint64) storage filledFlashTakeOrder
    ) public returns (uint64 newSequence) {
        uint256 orderLength = orders.length;
        newSequence = previousFlashTakeSequence;
        for (uint256 i = 0; i < orderLength; i++) {
            FlashTakeParam calldata order = orders[i];
            newSequence += 1;
            require(order.flashTakeSequence == newSequence, "SEQ"); // invalid SEQuence
            // signature
            {
                address account = LibSubAccount.getSubAccountOwner(order.order.subAccountId);
                (bytes32 flashTakeOrderHash, address recovered) = recoveryFlashTakeSigner(order.order, order.signature);
                require(account == recovered, "712"); // EIP712 signature mismatched
                require(filledFlashTakeOrder[flashTakeOrderHash] == 0, "OID"); // already filled. keep the meaning the same as "can not find this OrderID" in fillPositionOrder
                filledFlashTakeOrder[flashTakeOrderHash] = order.flashTakeSequence; // prevent replay attack
            }
            // trade
            emit FillingFlashTake(order.flashTakeSequence);
            string memory errorMessage;
            try IInternalFlashTaker(orderBook).internalFlashTake(order) {} catch Error(string memory reason) {
                errorMessage = reason;
            } catch (bytes memory) {
                errorMessage = "RVT"; // unknown ReVerT reason
            }
            emit FillFlashTake(
                order.order.subAccountId,
                order.flashTakeSequence,
                order.order.collateral,
                order.order.size,
                order.order.gasFee,
                order.order.profitTokenId,
                order.order.flags,
                errorMessage
            );
        }
    }

    function internalFlashTake(
        FlashTakeParam calldata order,
        ILiquidityPool pool,
        uint256 blockTimestamp,
        uint256 marketOrderTimeout,
        address referralManager
    ) public {
        require(order.order.size != 0, "S=0"); // order Size Is Zero
        require(order.order.orderType == uint8(OrderType.FlashTakePositionOrder), "TYP"); // order TYPe mismatch
        require(blockTimestamp <= order.order.placeOrderTime + marketOrderTimeout, "EXP"); // EXPired
        require((order.order.flags & LibOrder.POSITION_MARKET_ORDER) != 0, "MKT"); // only MarKeT order is supported
        if (order.order.profitTokenId > 0) {
            // note: profitTokenId == 0 is also valid, this only partially protects the function from misuse
            require((order.order.flags & LibOrder.POSITION_OPEN) == 0, "T!0"); // opening position does not need a Token id
        }
        LibSubAccount.DecodedSubAccountId memory account = LibSubAccount.decodeSubAccountId(order.order.subAccountId);
        if (order.order.referralCode != bytes32(0) && referralManager != address(0)) {
            IReferralManager(referralManager).setReferrerCodeFor(account.account, order.order.referralCode);
        }
        if ((order.order.flags & LibOrder.POSITION_OPEN) != 0) {
            // auto deposit
            if (order.order.collateral > 0) {
                IERC20Upgradeable collateral = IERC20Upgradeable(pool.getAssetAddress(account.collateralId));
                collateral.safeTransferFrom(account.account, address(pool), order.order.collateral);
                pool.depositCollateral(order.order.subAccountId, order.order.collateral);
            }
            pool.openPosition(
                order.order.subAccountId,
                order.order.size,
                order.collateralPrice,
                order.assetPrice,
                order.order.gasFee
            );
        } else {
            pool.closePosition(
                order.order.subAccountId,
                order.order.size,
                order.order.profitTokenId,
                order.collateralPrice,
                order.assetPrice,
                order.profitAssetPrice,
                order.order.gasFee
            );
            // auto withdraw
            if (order.order.collateral > 0) {
                pool.withdrawCollateral(
                    order.order.subAccountId,
                    order.order.collateral,
                    order.collateralPrice,
                    order.assetPrice
                );
            }
            if ((order.order.flags & LibOrder.POSITION_WITHDRAW_ALL_IF_EMPTY) != 0) {
                (uint96 remainingCollateral, uint96 size, , , ) = pool.getSubAccount(order.order.subAccountId);
                if (size == 0 && remainingCollateral > 0) {
                    pool.withdrawAllCollateral(order.order.subAccountId);
                }
            }
        }
    }

    /**
     * Recovery FlashTake signer from signature.
     *
     * @param req FlashTake order
     * @param signature {bytes32 r}{bytes32 s}{uint8 v}
     *        if v is 27 or 28, treat signature as EIP712
     *        if v is 31 or 32, treat signature as eth_sign
     */
    function recoveryFlashTakeSigner(FlashTakeEIP712 calldata req, bytes calldata signature)
        public
        view
        returns (bytes32 eip712Hash, address signer)
    {
        bytes32 typedMessageHash = keccak256(
            abi.encode(
                FLASH_TAKE_TYPE_HASH,
                req.subAccountId,
                req.collateral,
                req.size,
                req.gasFee,
                req.referralCode,
                req.orderType,
                req.flags,
                req.profitTokenId,
                req.placeOrderTime,
                req.salt
            )
        );
        eip712Hash = ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), typedMessageHash);
        (uint8 v, bytes32 r, bytes32 s) = _splitSignature(signature);
        if (v > 30) {
            signer = ECDSAUpgradeable.recover(ECDSAUpgradeable.toEthSignedMessageHash(eip712Hash), v - 4, r, s);
        } else {
            signer = ECDSAUpgradeable.recover(eip712Hash, v, r, s);
        }
    }

    function _domainSeparatorV4() private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    FLASH_TAKE_DOMAIN_HASH,
                    FLASH_TAKE_NAME_HASH,
                    FLASH_TAKE_VERSION_HASH,
                    block.chainid,
                    address(this)
                )
            );
    }

    function _splitSignature(bytes memory signature)
        private
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        require(signature.length == 65, "RSV"); // only {r}{s}{v} is supported
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

import "../core/Types.sol";

interface ILiquidityPool {
    /////////////////////////////////////////////////////////////////////////////////
    //                                 getters

    function getAssetInfo(uint8 assetId) external view returns (Asset memory);

    function getAllAssetInfo() external view returns (Asset[] memory);

    function getAssetAddress(uint8 assetId) external view returns (address);

    /**
     * @return numbers [ 0] shortFundingBaseRate8H
     *                 [ 1] shortFundingLimitRate8H
     *                 [ 2] lastFundingTime
     *                 [ 3] fundingInterval
     *                 [ 4] liquidityBaseFeeRate
     *                 [ 5] liquidityDynamicFeeRate
     *                 [ 6] sequence. note: will be 0 after 0xffffffff
     *                 [ 7] strictStableDeviation
     *                 [ 8] mlpPriceLowerBound
     *                 [ 9] mlpPriceUpperBound
     *                 [10] brokerGasRebate
     */
    function getLiquidityPoolStorage() external view returns (uint256[11] memory numbers);

    function getSubAccount(bytes32 subAccountId)
        external
        view
        returns (
            uint96 collateral,
            uint96 size,
            uint32 lastIncreasedTime,
            uint96 entryPrice,
            uint128 entryFunding
        );

    /////////////////////////////////////////////////////////////////////////////////
    //                             for Trader / Broker

    function withdrawAllCollateral(bytes32 subAccountId) external;

    /////////////////////////////////////////////////////////////////////////////////
    //                                 only Broker

    function depositCollateral(
        bytes32 subAccountId,
        uint256 rawAmount // NOTE: OrderBook SHOULD transfer rawAmount collateral to LiquidityPool
    ) external;

    function withdrawCollateral(
        bytes32 subAccountId,
        uint256 rawAmount,
        uint96 collateralPrice,
        uint96 assetPrice
    ) external;

    function withdrawProfit(
        bytes32 subAccountId,
        uint256 rawAmount,
        uint8 profitAssetId, // only used when !isLong
        uint96 collateralPrice,
        uint96 assetPrice,
        uint96 profitAssetPrice // only used when !isLong
    ) external;

    /**
     * @dev   Add liquidity.
     *
     * @param trader            liquidity provider address.
     * @param tokenId           asset.id that added.
     * @param rawAmount         asset token amount. decimals = erc20.decimals.
     * @param tokenPrice        token price. decimals = 18.
     * @param mlpPrice          mlp price.  decimals = 18.
     * @param currentAssetValue liquidity USD value of a single asset in all chains (even if tokenId is a stable asset).
     * @param targetAssetValue  weight / Σ weight * total liquidity USD value in all chains.
     */
    function addLiquidity(
        address trader,
        uint8 tokenId,
        uint256 rawAmount, // NOTE: OrderBook SHOULD transfer rawAmount collateral to LiquidityPool
        uint96 tokenPrice,
        uint96 mlpPrice,
        uint96 currentAssetValue,
        uint96 targetAssetValue
    ) external;

    /**
     * @dev   Remove liquidity.
     *
     * @param trader            liquidity provider address.
     * @param mlpAmount         mlp amount. decimals = 18.
     * @param tokenId           asset.id that removed to.
     * @param tokenPrice        token price. decimals = 18.
     * @param mlpPrice          mlp price. decimals = 18.
     * @param currentAssetValue liquidity USD value of a single asset in all chains (even if tokenId is a stable asset). decimals = 18.
     * @param targetAssetValue  weight / Σ weight * total liquidity USD value in all chains. decimals = 18.
     */
    function removeLiquidity(
        address trader,
        uint96 mlpAmount, // NOTE: OrderBook SHOULD transfer mlpAmount mlp to LiquidityPool
        uint8 tokenId,
        uint96 tokenPrice,
        uint96 mlpPrice,
        uint96 currentAssetValue,
        uint96 targetAssetValue
    ) external;

    /**
     * @notice Open a position.
     *
     * @param  subAccountId     check LibSubAccount.decodeSubAccountId for detail.
     * @param  amount           position size. decimals = 18.
     * @param  collateralPrice  price of subAccount.collateral.
     * @param  assetPrice       price of subAccount.asset.
     * @param  brokerGasFee     transfer broker fee from collateral. decimals = 18.
     */
    function openPosition(
        bytes32 subAccountId,
        uint96 amount,
        uint96 collateralPrice,
        uint96 assetPrice,
        uint96 brokerGasFee
    ) external returns (uint96);

    /**
     * @notice Close a position.
     *
     * @param  subAccountId     check LibSubAccount.decodeSubAccountId for detail.
     * @param  amount           position size. decimals = 18.
     * @param  profitAssetId    for long position (unless asset.useStable is true), ignore this argument;
     *                          for short position, the profit asset should be one of the stable coin.
     * @param  collateralPrice  price of subAccount.collateral. decimals = 18.
     * @param  assetPrice       price of subAccount.asset. decimals = 18.
     * @param  profitAssetPrice price of profitAssetId. ignore this argument if profitAssetId is ignored. decimals = 18.
     * @param  brokerGasFee     transfer broker fee from collateral. decimals = 18.
     */
    function closePosition(
        bytes32 subAccountId,
        uint96 amount,
        uint8 profitAssetId, // only used when !isLong
        uint96 collateralPrice,
        uint96 assetPrice,
        uint96 profitAssetPrice, // only used when !isLong
        uint96 brokerGasFee
    ) external returns (uint96);

    /**
     * @notice Broker can update funding each [fundingInterval] seconds by specifying utilizations.
     *
     *         Check _getFundingRate in Liquidity.sol on how to calculate funding rate.
     * @param  stableUtilization    Stable coin utilization in all chains. decimals = 5.
     * @param  unstableTokenIds     All unstable Asset id(s) MUST be passed in order. ex: 1, 2, 5, 6, ...
     * @param  unstableUtilizations Unstable Asset utilizations in all chains. decimals = 5.
     * @param  unstablePrices       Unstable Asset prices.
     */
    function updateFundingState(
        uint32 stableUtilization, // 1e5
        uint8[] calldata unstableTokenIds,
        uint32[] calldata unstableUtilizations, // 1e5
        uint96[] calldata unstablePrices
    ) external;

    function liquidate(
        bytes32 subAccountId,
        uint8 profitAssetId, // only used when !isLong
        uint96 collateralPrice,
        uint96 assetPrice,
        uint96 profitAssetPrice // only used when !isLong
    ) external returns (uint96);

    /**
     * @notice Redeem mux token into original tokens.
     *
     *         Only strict stable coins and un-stable coins are supported.
     */
    function redeemMuxToken(
        address trader,
        uint8 tokenId,
        uint96 muxTokenAmount // NOTE: OrderBook SHOULD transfer muxTokenAmount to LiquidityPool
    ) external;

    /**
     * @dev  Rebalance pool liquidity. Swap token 0 for token 1.
     *
     *       rebalancer must implement IMuxRebalancerCallback.
     */
    function rebalance(
        address rebalancer,
        uint8 tokenId0,
        uint8 tokenId1,
        uint96 rawAmount0,
        uint96 maxRawAmount1,
        bytes32 userData,
        uint96 price0,
        uint96 price1
    ) external;

    /**
     * @dev Broker can withdraw brokerGasRebate.
     */
    function claimBrokerGasRebate(address receiver) external returns (uint256 rawAmount);

    /////////////////////////////////////////////////////////////////////////////////
    //                            only LiquidityManager

    function transferLiquidityOut(uint8[] memory assetIds, uint256[] memory amounts) external;

    function transferLiquidityIn(uint8[] memory assetIds, uint256[] memory amounts) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

interface IReferralManager {
    struct TierSetting {
        uint8 tier;
        uint64 stakeThreshold;
        uint64 discountRate;
        uint64 rebateRate;
    }

    event RegisterReferralCode(address referralCodeOwner, bytes32 referralCode);
    event SetReferralCode(address trader, bytes32 referralCode);
    event SetHandler(address handler, bool enable);
    event SetTiers(TierSetting[] newTierSettings);
    event SetMaintainer(address previousMaintainer, address newMaintainer);
    event SetRebateRecipient(bytes32 referralCode, address referralCodeOwner, address rebateRecipient);
    event TransferReferralCode(bytes32 referralCode, address previousOwner, address newOwner);

    function isHandler(address handler) external view returns (bool);

    function rebateRecipients(bytes32 referralCode) external view returns (address);

    // management methods
    function setHandler(address handler, bool enable) external;

    function setTiers(TierSetting[] memory newTierSettings) external;

    // methods only available on primary network
    function isValidReferralCode(bytes32 referralCode) external view returns (bool);

    function registerReferralCode(bytes32 referralCode, address rebateRecipient) external;

    function setRebateRecipient(bytes32 referralCode, address rebateRecipient) external;

    function transferReferralCode(bytes32 referralCode, address newOwner) external;

    // methods available on secondary network
    function getReferralCodeOf(address trader) external view returns (bytes32, uint256);

    function setReferrerCode(bytes32 referralCode) external;

    function setReferrerCodeFor(address trader, bytes32 referralCode) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

import "../core/Types.sol";

/**
 * SubAccountId
 *         96             88        80       72        0
 * +---------+--------------+---------+--------+--------+
 * | Account | collateralId | assetId | isLong | unused |
 * +---------+--------------+---------+--------+--------+
 */
library LibSubAccount {
    bytes32 constant SUB_ACCOUNT_ID_FORBIDDEN_BITS = bytes32(uint256(0xffffffffffffffffff));

    function getSubAccountOwner(bytes32 subAccountId) internal pure returns (address account) {
        account = address(uint160(uint256(subAccountId) >> 96));
    }

    function getSubAccountCollateralId(bytes32 subAccountId) internal pure returns (uint8) {
        return uint8(uint256(subAccountId) >> 88);
    }

    function isLong(bytes32 subAccountId) internal pure returns (bool) {
        return uint8((uint256(subAccountId) >> 72)) > 0;
    }

    struct DecodedSubAccountId {
        address account;
        uint8 collateralId;
        uint8 assetId;
        bool isLong;
    }

    function decodeSubAccountId(bytes32 subAccountId) internal pure returns (DecodedSubAccountId memory decoded) {
        require((subAccountId & SUB_ACCOUNT_ID_FORBIDDEN_BITS) == 0, "AID"); // bad subAccount ID
        decoded.account = address(uint160(uint256(subAccountId) >> 96));
        decoded.collateralId = uint8(uint256(subAccountId) >> 88);
        decoded.assetId = uint8(uint256(subAccountId) >> 80);
        decoded.isLong = uint8((uint256(subAccountId) >> 72)) > 0;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

import "../orderbook/Types.sol";
import "./LibSubAccount.sol";

library LibOrder {
    // position order flags
    uint8 constant POSITION_OPEN = 0x80; // 0x80 means openPosition; otherwise closePosition
    uint8 constant POSITION_MARKET_ORDER = 0x40; // 0x40 means ignore limitPrice
    uint8 constant POSITION_WITHDRAW_ALL_IF_EMPTY = 0x20; // 0x20 means auto withdraw all collateral if position.size == 0
    uint8 constant POSITION_TRIGGER_ORDER = 0x10; // 0x10 means this is a trigger order (ex: stop-loss order). 0 means this is a limit order (ex: take-profit order)

    // order data[1] SHOULD reserve lower 64bits for enumIndex
    bytes32 constant ENUM_INDEX_BITS = bytes32(uint256(0xffffffffffffffff));

    struct OrderList {
        uint64[] _orderIds;
        mapping(uint64 => bytes32[3]) _orders;
    }

    function add(
        OrderList storage list,
        uint64 orderId,
        bytes32[3] memory order
    ) internal {
        require(!contains(list, orderId), "DUP"); // already seen this orderId
        list._orderIds.push(orderId);
        // The value is stored at length-1, but we add 1 to all indexes
        // and use 0 as a sentinel value
        uint256 enumIndex = list._orderIds.length;
        require(enumIndex <= type(uint64).max, "O64"); // Overflow uint64
        // order data[1] SHOULD reserve lower 64bits for enumIndex
        require((order[1] & ENUM_INDEX_BITS) == 0, "O1F"); // bad Order[1] Field
        order[1] = bytes32(uint256(order[1]) | uint256(enumIndex));
        list._orders[orderId] = order;
    }

    function remove(OrderList storage list, uint64 orderId) internal {
        bytes32[3] storage orderToRemove = list._orders[orderId];
        uint64 enumIndexToRemove = uint64(uint256(orderToRemove[1]));
        require(enumIndexToRemove != 0, "OID"); // orderId is not found
        // swap and pop
        uint256 indexToRemove = enumIndexToRemove - 1;
        uint256 lastIndex = list._orderIds.length - 1;
        if (lastIndex != indexToRemove) {
            uint64 lastOrderId = list._orderIds[lastIndex];
            // move the last orderId
            list._orderIds[indexToRemove] = lastOrderId;
            // replace enumIndex
            bytes32[3] storage lastOrder = list._orders[lastOrderId];
            lastOrder[1] = (lastOrder[1] & (~ENUM_INDEX_BITS)) | bytes32(uint256(enumIndexToRemove));
        }
        list._orderIds.pop();
        delete list._orders[orderId];
    }

    function contains(OrderList storage list, uint64 orderId) internal view returns (bool) {
        bytes32[3] storage order = list._orders[orderId];
        // order data[1] always contains enumIndex
        return order[1] != bytes32(0);
    }

    function length(OrderList storage list) internal view returns (uint256) {
        return list._orderIds.length;
    }

    function at(OrderList storage list, uint256 index) internal view returns (bytes32[3] memory order) {
        require(index < list._orderIds.length, "IDX"); // InDex overflow
        uint64 orderId = list._orderIds[index];
        order = list._orders[orderId];
    }

    function get(OrderList storage list, uint64 orderId) internal view returns (bytes32[3] memory) {
        return list._orders[orderId];
    }

    function getOrderType(bytes32[3] memory orderData) internal pure returns (OrderType) {
        return OrderType(uint8(uint256(orderData[0])));
    }

    function getOrderOwner(bytes32[3] memory orderData) internal pure returns (address) {
        return address(bytes20(orderData[0]));
    }

    // check Types.PositionOrder for schema
    function encodePositionOrder(
        uint64 orderId,
        bytes32 subAccountId,
        uint96 collateral, // erc20.decimals
        uint96 size, // 1e18
        uint96 price, // 1e18
        uint8 profitTokenId,
        uint8 flags,
        uint32 placeOrderTime,
        uint24 expire10s
    ) internal pure returns (bytes32[3] memory data) {
        require((subAccountId & LibSubAccount.SUB_ACCOUNT_ID_FORBIDDEN_BITS) == 0, "AID"); // bad subAccount ID
        data[0] = subAccountId | bytes32(uint256(orderId) << 8) | bytes32(uint256(OrderType.PositionOrder));
        data[1] = bytes32(
            (uint256(size) << 160) |
                (uint256(profitTokenId) << 152) |
                (uint256(flags) << 144) |
                (uint256(expire10s) << 96) |
                (uint256(placeOrderTime) << 64)
        );
        data[2] = bytes32((uint256(price) << 160) | (uint256(collateral) << 64));
    }

    // check Types.PositionOrder for schema
    function decodePositionOrder(bytes32[3] memory data) internal pure returns (PositionOrder memory order) {
        order.subAccountId = bytes32(bytes23(data[0]));
        order.collateral = uint96(bytes12(data[2] << 96));
        order.size = uint96(bytes12(data[1]));
        order.flags = uint8(bytes1(data[1] << 104));
        order.price = uint96(bytes12(data[2]));
        order.profitTokenId = uint8(bytes1(data[1] << 96));
        order.expire10s = uint24(bytes3(data[1] << 136));
        order.placeOrderTime = uint32(bytes4(data[1] << 160));
    }

    // check Types.LiquidityOrder for schema
    function encodeLiquidityOrder(
        uint64 orderId,
        address account,
        uint8 assetId,
        uint96 rawAmount, // erc20.decimals
        bool isAdding,
        uint32 placeOrderTime
    ) internal pure returns (bytes32[3] memory data) {
        uint8 flags = isAdding ? 1 : 0;
        data[0] = bytes32(
            (uint256(uint160(account)) << 96) | (uint256(orderId) << 8) | uint256(OrderType.LiquidityOrder)
        );
        data[1] = bytes32(
            (uint256(rawAmount) << 160) |
                (uint256(assetId) << 152) |
                (uint256(flags) << 144) |
                (uint256(placeOrderTime) << 64)
        );
    }

    // check Types.LiquidityOrder for schema
    function decodeLiquidityOrder(bytes32[3] memory data) internal pure returns (LiquidityOrder memory order) {
        order.account = address(bytes20(data[0]));
        order.rawAmount = uint96(bytes12(data[1]));
        order.assetId = uint8(bytes1(data[1] << 96));
        uint8 flags = uint8(bytes1(data[1] << 104));
        order.isAdding = flags > 0;
        order.placeOrderTime = uint32(bytes4(data[1] << 160));
    }

    // check Types.WithdrawalOrder for schema
    function encodeWithdrawalOrder(
        uint64 orderId,
        bytes32 subAccountId,
        uint96 rawAmount, // erc20.decimals
        uint8 profitTokenId,
        bool isProfit,
        uint32 placeOrderTime
    ) internal pure returns (bytes32[3] memory data) {
        require((subAccountId & LibSubAccount.SUB_ACCOUNT_ID_FORBIDDEN_BITS) == 0, "AID"); // bad subAccount ID
        uint8 flags = isProfit ? 1 : 0;
        data[0] = subAccountId | bytes32(uint256(orderId) << 8) | bytes32(uint256(OrderType.WithdrawalOrder));
        data[1] = bytes32(
            (uint256(rawAmount) << 160) |
                (uint256(profitTokenId) << 152) |
                (uint256(flags) << 144) |
                (uint256(placeOrderTime) << 64)
        );
    }

    // check Types.WithdrawalOrder for schema
    function decodeWithdrawalOrder(bytes32[3] memory data) internal pure returns (WithdrawalOrder memory order) {
        order.subAccountId = bytes32(bytes23(data[0]));
        order.rawAmount = uint96(bytes12(data[1]));
        order.profitTokenId = uint8(bytes1(data[1] << 96));
        uint8 flags = uint8(bytes1(data[1] << 104));
        order.isProfit = flags > 0;
        order.placeOrderTime = uint32(bytes4(data[1] << 160));
    }

    // check Types.RebalanceOrder for schema
    function encodeRebalanceOrder(
        uint64 orderId,
        address rebalancer,
        uint8 tokenId0,
        uint8 tokenId1,
        uint96 rawAmount0, // erc20.decimals
        uint96 maxRawAmount1, // erc20.decimals
        bytes32 userData
    ) internal pure returns (bytes32[3] memory data) {
        data[0] = bytes32(
            (uint256(uint160(rebalancer)) << 96) |
                (uint256(tokenId0) << 88) |
                (uint256(tokenId1) << 80) |
                (uint256(orderId) << 8) |
                uint256(OrderType.RebalanceOrder)
        );
        data[1] = bytes32((uint256(rawAmount0) << 160) | (uint256(maxRawAmount1) << 64));
        data[2] = userData;
    }

    // check Types.RebalanceOrder for schema
    function decodeRebalanceOrder(bytes32[3] memory data) internal pure returns (RebalanceOrder memory order) {
        order.rebalancer = address(bytes20(data[0]));
        order.tokenId0 = uint8(bytes1(data[0] << 160));
        order.tokenId1 = uint8(bytes1(data[0] << 168));
        order.rawAmount0 = uint96(bytes12(data[1]));
        order.maxRawAmount1 = uint96(bytes12(data[1] << 96));
        order.userData = data[2];
    }

    function isOpenPosition(PositionOrder memory order) internal pure returns (bool) {
        return (order.flags & POSITION_OPEN) != 0;
    }

    function isMarketOrder(PositionOrder memory order) internal pure returns (bool) {
        return (order.flags & POSITION_MARKET_ORDER) != 0;
    }

    function isWithdrawIfEmpty(PositionOrder memory order) internal pure returns (bool) {
        return (order.flags & POSITION_WITHDRAW_ALL_IF_EMPTY) != 0;
    }

    function isTriggerOrder(PositionOrder memory order) internal pure returns (bool) {
        return (order.flags & POSITION_TRIGGER_ORDER) != 0;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

enum OrderType {
    None, // 0
    PositionOrder, // 1
    LiquidityOrder, // 2
    WithdrawalOrder, // 3
    RebalanceOrder, // 4
    FlashTakePositionOrder // 5
}

//                                  160        152       144         120        96   72   64               8        0
// +----------------------------------------------------------------------------------+--------------------+--------+
// |              subAccountId 184 (already shifted by 72bits)                        |     orderId 64     | type 8 |
// +----------------------------------+----------+---------+-----------+---------+---------+---------------+--------+
// |              size 96             | profit 8 | flags 8 | unused 24 | exp 24  | time 32 |      enumIndex 64      |
// +----------------------------------+----------+---------+-----------+---------+---------+---------------+--------+
// |             price 96             |                    collateral 96                   |        unused 64       |
// +----------------------------------+----------------------------------------------------+------------------------+
struct PositionOrder {
    uint64 id;
    bytes32 subAccountId; // 160 + 8 + 8 + 8 = 184
    uint96 collateral; // erc20.decimals
    uint96 size; // 1e18
    uint96 price; // 1e18
    uint8 profitTokenId;
    uint8 flags; // see LibOrder.POSITION_*
    uint32 placeOrderTime; // 1e0
    uint24 expire10s; // 10 seconds. deadline = placeOrderTime + expire * 10
}

//                                  160       152       144          96          72    64              8        0
// +------------------------------------------------------------------+-----------+--------------------+--------+
// |                        account 160                               | unused 24 |     orderId 64     | type 8 |
// +----------------------------------+---------+---------+-----------+-----------+-----+--------------+--------+
// |             amount 96            | asset 8 | flags 8 | unused 48 |     time 32     |      enumIndex 64     |
// +----------------------------------+---------+---------+-----------+-----------------+-----------------------+
// |                                                 unused 256                                                 |
// +------------------------------------------------------------------------------------------------------------+
struct LiquidityOrder {
    uint64 id;
    address account;
    uint96 rawAmount; // erc20.decimals
    uint8 assetId;
    bool isAdding;
    uint32 placeOrderTime; // 1e0
}

//                                  160        152       144          96   72       64               8        0
// +------------------------------------------------------------------------+------------------------+--------+
// |              subAccountId 184 (already shifted by 72bits)              |       orderId 64       | type 8 |
// +----------------------------------+----------+---------+-----------+----+--------+---------------+--------+
// |             amount 96            | profit 8 | flags 8 | unused 48 |   time 32   |      enumIndex 64      |
// +----------------------------------+----------+---------+-----------+-------------+------------------------+
// |                                                unused 256                                                |
// +----------------------------------------------------------------------------------------------------------+
struct WithdrawalOrder {
    uint64 id;
    bytes32 subAccountId; // 160 + 8 + 8 + 8 = 184
    uint96 rawAmount; // erc20.decimals
    uint8 profitTokenId;
    bool isProfit;
    uint32 placeOrderTime; // 1e0
}

//                                          160       96      88      80        72    64                 8        0
// +---------------------------------------------------+-------+-------+----------+----------------------+--------+
// |                  rebalancer 160                   | id0 8 | id1 8 | unused 8 |      orderId 64      | type 8 |
// +------------------------------------------+--------+-------+-------+----------+----+-----------------+--------+
// |                amount0 96                |                amount1 96              |       enumIndex 64       |
// +------------------------------------------+----------------------------------------+--------------------------+
// |                                                 userData 256                                                 |
// +--------------------------------------------------------------------------------------------------------------+
struct RebalanceOrder {
    uint64 id;
    address rebalancer;
    uint8 tokenId0;
    uint8 tokenId1;
    uint96 rawAmount0; // erc20.decimals
    uint96 maxRawAmount1; // erc20.decimals
    bytes32 userData;
}

struct FlashTakeParam {
    FlashTakeEIP712 order;
    uint64 flashTakeSequence;
    bytes signature;
    uint96 assetPrice; // 1e18
    uint96 collateralPrice; // 1e18
    uint96 profitAssetPrice; // 1e18
}

/**
 * @notice Open/close position. Assembled by Trader.
 *
 *         Market order will expire after marketOrderTimeout seconds.
 * @param  subAccountId       sub account id. see LibSubAccount.decodeSubAccountId.
 * @param  collateral         deposit collateral before open; or withdraw collateral after close. decimals = erc20.decimals.
 * @param  size               position size. decimals = 18.
 * @param  gasFee             transfer broker fee from collateral. decimals = 18.
 * @param  profitTokenId      specify the profitable asset.id when closing a position and making a profit.
 *                            take no effect when opening a position or loss.
 * @param  flags              a bitset of LibOrder.POSITION_*
 *                            POSITION_INCREASING               0x80 means openPosition; otherwise closePosition
 *                            POSITION_MARKET_ORDER             0x40 means ignore limitPrice
 *                            POSITION_WITHDRAW_ALL_IF_EMPTY    0x20 means auto withdraw all collateral if position.size == 0
 *                            POSITION_TRIGGER_ORDER            0x10 means this is a trigger order (ex: stop-loss order). 0 means this is a limit order (ex: take-profit order)
 * @param  referralCode       set referral code of the trading account.
 * @param  placeOrderTime     a UNIX timestamp. Market order will expire after marketOrderTimeout seconds.
 * @param  salt               a random value that keeps EIP712 message hash different.
 * @param  orderType          should be FlashTakePositionOrder
 */
struct FlashTakeEIP712 {
    bytes32 subAccountId;
    uint96 collateral; // erc20.decimals
    uint96 size; // 1e18
    uint96 gasFee; // 1e18
    bytes32 referralCode;
    uint8 orderType;
    uint8 flags;
    uint8 profitTokenId;
    uint32 placeOrderTime;
    uint32 salt;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.10;

struct LiquidityPoolStorage {
    // slot
    address orderBook;
    // slot
    address mlp;
    // slot
    address liquidityManager;
    // slot
    address weth;
    // slot
    uint128 _reserved1;
    uint32 shortFundingBaseRate8H; // 1e5
    uint32 shortFundingLimitRate8H; // 1e5
    uint32 fundingInterval; // 1e0
    uint32 lastFundingTime; // 1e0
    // slot
    uint32 _reserved2;
    // slot
    Asset[] assets;
    // slot
    mapping(bytes32 => SubAccount) accounts;
    // slot
    mapping(address => bytes32) _reserved3;
    // slot
    address _reserved4;
    uint96 _reserved5;
    // slot
    uint96 mlpPriceLowerBound; // safeguard against mlp price attacks
    uint96 mlpPriceUpperBound; // safeguard against mlp price attacks
    uint32 liquidityBaseFeeRate; // 1e5
    uint32 liquidityDynamicFeeRate; // 1e5
    // slot
    address nativeUnwrapper;
    // a sequence number that changes when LiquidityPoolStorage updated. this helps to keep track the state of LiquidityPool.
    uint32 sequence; // 1e0. note: will be 0 after 0xffffffff
    uint32 strictStableDeviation; // 1e5. strictStable price is 1.0 if in this damping range
    uint32 brokerTransactions; // transaction count for broker gas rebates
    // slot
    address vault;
    uint96 brokerGasRebate; // the number of native tokens for broker gas rebates per transaction
    // slot
    address maintainer;
    bytes32[50] _gap;
}

struct Asset {
    // slot
    // assets with the same symbol in different chains are the same asset. they shares the same muxToken. so debts of the same symbol
    // can be accumulated across chains (see Reader.AssetState.deduct). ex: ERC20(fBNB).symbol should be "BNB", so that BNBs of
    // different chains are the same.
    // since muxToken of all stable coins is the same and is calculated separately (see Reader.ChainState.stableDeduct), stable coin
    // symbol can be different (ex: "USDT", "USDT.e" and "fUSDT").
    bytes32 symbol;
    // slot
    address tokenAddress; // erc20.address
    uint8 id;
    uint8 decimals; // erc20.decimals
    uint56 flags; // a bitset of ASSET_*
    uint24 _flagsPadding;
    // slot
    uint32 initialMarginRate; // 1e5
    uint32 maintenanceMarginRate; // 1e5
    uint32 minProfitRate; // 1e5
    uint32 minProfitTime; // 1e0
    uint32 positionFeeRate; // 1e5
    // note: 96 bits remaining
    // slot
    address referenceOracle;
    uint32 referenceDeviation; // 1e5
    uint8 referenceOracleType;
    uint32 halfSpread; // 1e5
    // note: 24 bits remaining
    // slot
    uint128 _reserved1;
    uint128 _reserved2;
    // slot
    uint96 collectedFee;
    uint32 _reserved3;
    uint96 spotLiquidity;
    // note: 32 bits remaining
    // slot
    uint96 maxLongPositionSize;
    uint96 totalLongPosition;
    // note: 64 bits remaining
    // slot
    uint96 averageLongPrice;
    uint96 maxShortPositionSize;
    // note: 64 bits remaining
    // slot
    uint96 totalShortPosition;
    uint96 averageShortPrice;
    // note: 64 bits remaining
    // slot, less used
    address muxTokenAddress; // muxToken.address. all stable coins share the same muxTokenAddress
    uint32 spotWeight; // 1e0
    uint32 longFundingBaseRate8H; // 1e5
    uint32 longFundingLimitRate8H; // 1e5
    // slot
    uint128 longCumulativeFundingRate; // Σ_t fundingRate_t
    uint128 shortCumulativeFunding; // Σ_t fundingRate_t * indexPrice_t
}

uint32 constant FUNDING_PERIOD = 3600 * 8;

uint56 constant ASSET_IS_STABLE = 0x00000000000001; // is a usdt, usdc, ...
uint56 constant ASSET_CAN_ADD_REMOVE_LIQUIDITY = 0x00000000000002; // can call addLiquidity and removeLiquidity with this token
uint56 constant ASSET_IS_TRADABLE = 0x00000000000100; // allowed to be assetId
uint56 constant ASSET_IS_OPENABLE = 0x00000000010000; // can open position
uint56 constant ASSET_IS_SHORTABLE = 0x00000001000000; // allow shorting this asset
uint56 constant ASSET_USE_STABLE_TOKEN_FOR_PROFIT = 0x00000100000000; // take profit will get stable coin
uint56 constant ASSET_IS_ENABLED = 0x00010000000000; // allowed to be assetId and collateralId
uint56 constant ASSET_IS_STRICT_STABLE = 0x01000000000000; // assetPrice is always 1 unless volatility exceeds strictStableDeviation

struct SubAccount {
    // slot
    uint96 collateral;
    uint96 size;
    uint32 lastIncreasedTime;
    // slot
    uint96 entryPrice;
    uint128 entryFunding; // entry longCumulativeFundingRate for long position. entry shortCumulativeFunding for short position
}

enum ReferenceOracleType {
    None,
    Chainlink
}