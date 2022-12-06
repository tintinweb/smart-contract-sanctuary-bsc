//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../libs/LibAssetData.sol";
contract ExternalFunctions
{
    // @dev Decode AssetProxy identifier
    // @param assetData AssetProxy-compliant asset data describing an ERC-20, ERC-721, ERC1155, or MultiAsset asset.
    // @return The AssetProxy identifier
    function decodeAssetProxyId(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId
        )
    {
        return LibAssetData.decodeAssetProxyId(assetData);
    }

    // @dev Encode ERC-20 asset data into the format described in the AssetProxy contract specification.
    // @param tokenAddress The address of the ERC-20 contract hosting the asset to be traded.
    // @return AssetProxy-compliant data describing the asset.
    function encodeERC20AssetData(address tokenAddress)
        public
        pure
        returns (bytes memory assetData)
    {
        return LibAssetData.encodeERC20AssetData(tokenAddress);
    }

    // @dev Decode ERC-20 asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing an ERC-20 asset.
    // @return The AssetProxy identifier, and the address of the ERC-20
    // contract hosting this asset.
    function decodeERC20AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress
        )
    {
        return LibAssetData.decodeERC20AssetData(assetData);
    }

    // @dev Encode ERC-721 asset data into the format described in the AssetProxy specification.
    // @param tokenAddress The address of the ERC-721 contract hosting the asset to be traded.
    // @param tokenId The identifier of the specific asset to be traded.
    // @return AssetProxy-compliant asset data describing the asset.
    function encodeERC721AssetData(address tokenAddress, uint256 tokenId)
        public
        pure
        returns (bytes memory assetData)
    {
        return LibAssetData.encodeERC721AssetData(tokenAddress, tokenId);
    }

    // @dev Decode ERC-721 asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing an ERC-721 asset.
    // @return The ERC-721 AssetProxy identifier, the address of the ERC-721
    // contract hosting this asset, and the identifier of the specific
    // asset to be traded.
    function decodeERC721AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress,
            uint256 tokenId
        )
    {
        return LibAssetData.decodeERC721AssetData(assetData);
    }

    // @dev Encode ERC-1155 asset data into the format described in the AssetProxy contract specification.
    // @param tokenAddress The address of the ERC-1155 contract hosting the asset(s) to be traded.
    // @param tokenIds The identifiers of the specific assets to be traded.
    // @param tokenValues The amounts of each asset to be traded.
    // @param callbackData Data to be passed to receiving contracts when a transfer is performed.
    // @return AssetProxy-compliant asset data describing the set of assets.
    function encodeERC1155AssetData(
        address tokenAddress,
        uint256[] memory tokenIds,
        uint256[] memory tokenValues,
        bytes memory callbackData
    )
        public
        pure
        returns (bytes memory assetData)
    {
        return LibAssetData.encodeERC1155AssetData(
            tokenAddress,
            tokenIds,
            tokenValues,
            callbackData
        );
    }

    // @dev Decode ERC-1155 asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing an ERC-1155 set of assets.
    // @return The ERC-1155 AssetProxy identifier, the address of the ERC-1155
    // contract hosting the assets, an array of the identifiers of the
    // assets to be traded, an array of asset amounts to be traded, and
    // callback data.  Each element of the arrays corresponds to the
    // same-indexed element of the other array.  Return values specified as
    // `memory` are returned as pointers to locations within the memory of
    // the input parameter `assetData`.
    function decodeERC1155AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress,
            uint256[] memory tokenIds,
            uint256[] memory tokenValues,
            bytes memory callbackData
        )
    {
        return LibAssetData.decodeERC1155AssetData(assetData);
    }

    // @dev Encode data for multiple assets, per the AssetProxy contract specification.
    // @param amounts The amounts of each asset to be traded.
    // @param nestedAssetData AssetProxy-compliant data describing each asset to be traded.
    // @return AssetProxy-compliant data describing the set of assets.
    function encodeMultiAssetData(uint256[] memory amounts, bytes[] memory nestedAssetData)
        public
        pure
        returns (bytes memory assetData)
    {
        return LibAssetData.encodeMultiAssetData(amounts, nestedAssetData);
    }

    // @dev Decode multi-asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant data describing a multi-asset basket.
    // @return The Multi-Asset AssetProxy identifier, an array of the amounts
    // of the assets to be traded, and an array of the
    // AssetProxy-compliant data describing each asset to be traded.  Each
    // element of the arrays corresponds to the same-indexed element of the other array.
    function decodeMultiAssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            uint256[] memory amounts,
            bytes[] memory nestedAssetData
        )
    {
        return LibAssetData.decodeMultiAssetData(assetData);
    }

    // @dev Encode StaticCall asset data into the format described in the AssetProxy contract specification.
    // @param staticCallTargetAddress Target address of StaticCall.
    // @param staticCallData Data that will be passed to staticCallTargetAddress in the StaticCall.
    // @param expectedReturnDataHash Expected Keccak-256 hash of the StaticCall return data.
    // @return AssetProxy-compliant asset data describing the set of assets.
    function encodeStaticCallAssetData(
        address staticCallTargetAddress,
        bytes memory staticCallData,
        bytes32 expectedReturnDataHash
    )
        public
        pure
        returns (bytes memory assetData)
    {
        return LibAssetData.encodeStaticCallAssetData(
            staticCallTargetAddress,
            staticCallData,
            expectedReturnDataHash
        );
    }

    // @dev Decode StaticCall asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing a StaticCall asset
    // @return The StaticCall AssetProxy identifier, the target address of the StaticCAll, the data to be
    // passed to the target address, and the expected Keccak-256 hash of the static call return data.
    function decodeStaticCallAssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address staticCallTargetAddress,
            bytes memory staticCallData,
            bytes32 expectedReturnDataHash
        )
    {
        return LibAssetData.decodeStaticCallAssetData(assetData);
    }

    // @dev Decode ERC20Bridge asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing an ERC20Bridge asset
    // @return The ERC20BridgeProxy identifier, the address of the ERC20 token to transfer, the address
    // of the bridge contract, and extra data to be passed to the bridge contract.
    function decodeERC20BridgeAssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress,
            address bridgeAddress,
            bytes memory bridgeData
        )
    {
        return LibAssetData.decodeERC20BridgeAssetData(assetData);
    }

    // @dev Reverts if assetData is not of a valid format for its given proxy id.
    // @param assetData AssetProxy compliant asset data.
    function revertIfInvalidAssetData(bytes memory assetData)
        public
        pure
    {
        return LibAssetData.revertIfInvalidAssetData(assetData);
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "./LibBytes.sol";
import "../interface/IAssetData.sol";
library LibAssetData {

    using LibBytes for bytes;

    // @dev Decode AssetProxy identifier
    // @param assetData AssetProxy-compliant asset data describing an ERC-20, ERC-721, ERC1155, or MultiAsset asset.
    // @return The AssetProxy identifier
    function decodeAssetProxyId(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId
        )
    {
        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == IAssetData(address(0)).ERC20Token.selector ||
            assetProxyId == IAssetData(address(0)).ERC721Token.selector ||
            assetProxyId == IAssetData(address(0)).ERC1155Assets.selector ||
            assetProxyId == IAssetData(address(0)).MultiAsset.selector ||
            assetProxyId == IAssetData(address(0)).StaticCall.selector,
            "WRONG_PROXY_ID"
        );
        return assetProxyId;
    }

    // @dev Encode ERC-20 asset data into the format described in the AssetProxy contract specification.
    // @param tokenAddress The address of the ERC-20 contract hosting the asset to be traded.
    // @return AssetProxy-compliant data describing the asset.
    function encodeERC20AssetData(address tokenAddress)
        public
        pure
        returns (bytes memory assetData)
    {
        assetData = abi.encodeWithSelector(IAssetData(address(0)).ERC20Token.selector, tokenAddress);
        return assetData;
    }

    // @dev Decode ERC-20 asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing an ERC-20 asset.
    // @return The AssetProxy identifier, and the address of the ERC-20
    // contract hosting this asset.
    function decodeERC20AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress
        )
    {
        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == IAssetData(address(0)).ERC20Token.selector,
            "WRONG_PROXY_ID"
        );

        tokenAddress = assetData.readAddress(16);
        return (assetProxyId, tokenAddress);
    }

    // @dev Encode ERC-721 asset data into the format described in the AssetProxy specification.
    // @param tokenAddress The address of the ERC-721 contract hosting the asset to be traded.
    // @param tokenId The identifier of the specific asset to be traded.
    // @return AssetProxy-compliant asset data describing the asset.
    function encodeERC721AssetData(address tokenAddress, uint256 tokenId)
        public
        pure
        returns (bytes memory assetData)
    {
        assetData = abi.encodeWithSelector(
            IAssetData(address(0)).ERC721Token.selector,
            tokenAddress,
            tokenId
        );
        return assetData;
    }

    // @dev Decode ERC-721 asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing an ERC-721 asset.
    // @return The ERC-721 AssetProxy identifier, the address of the ERC-721
    // contract hosting this asset, and the identifier of the specific
    // asset to be traded.
    function decodeERC721AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress,
            uint256 tokenId
        )
    {
        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == IAssetData(address(0)).ERC721Token.selector,
            "WRONG_PROXY_ID"
        );

        tokenAddress = assetData.readAddress(16);
        tokenId = assetData.readUint256(36);
        return (assetProxyId, tokenAddress, tokenId);
    }

    // @dev Encode ERC-1155 asset data into the format described in the AssetProxy contract specification.
    // @param tokenAddress The address of the ERC-1155 contract hosting the asset(s) to be traded.
    // @param tokenIds The identifiers of the specific assets to be traded.
    // @param tokenValues The amounts of each asset to be traded.
    // @param callbackData Data to be passed to receiving contracts when a transfer is performed.
    // @return AssetProxy-compliant asset data describing the set of assets.
    function encodeERC1155AssetData(
        address tokenAddress,
        uint256[] memory tokenIds,
        uint256[] memory tokenValues,
        bytes memory callbackData
    )
        public
        pure
        returns (bytes memory assetData)
    {
        assetData = abi.encodeWithSelector(
            IAssetData(address(0)).ERC1155Assets.selector,
            tokenAddress,
            tokenIds,
            tokenValues,
            callbackData
        );
        return assetData;
    }

    // @dev Decode ERC-1155 asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing an ERC-1155 set of assets.
    // @return The ERC-1155 AssetProxy identifier, the address of the ERC-1155
    // contract hosting the assets, an array of the identifiers of the
    // assets to be traded, an array of asset amounts to be traded, and
    // callback data.  Each element of the arrays corresponds to the
    // same-indexed element of the other array.  Return values specified as
    // `memory` are returned as pointers to locations within the memory of
    // the input parameter `assetData`.
    function decodeERC1155AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress,
            uint256[] memory tokenIds,
            uint256[] memory tokenValues,
            bytes memory callbackData
        )
    {
        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == IAssetData(address(0)).ERC1155Assets.selector,
            "WRONG_PROXY_ID"
        );

        assembly {
            // Skip selector and length to get to the first parameter:
            assetData := add(assetData, 36)
            // Read the value of the first parameter:
            tokenAddress := mload(assetData)
            // Point to the next parameter's data:
            tokenIds := add(assetData, mload(add(assetData, 32)))
            // Point to the next parameter's data:
            tokenValues := add(assetData, mload(add(assetData, 64)))
            // Point to the next parameter's data:
            callbackData := add(assetData, mload(add(assetData, 96)))
        }

        return (
            assetProxyId,
            tokenAddress,
            tokenIds,
            tokenValues,
            callbackData
        );
    }

    // @dev Encode data for multiple assets, per the AssetProxy contract specification.
    // @param amounts The amounts of each asset to be traded.
    // @param nestedAssetData AssetProxy-compliant data describing each asset to be traded.
    // @return AssetProxy-compliant data describing the set of assets.
    function encodeMultiAssetData(uint256[] memory amounts, bytes[] memory nestedAssetData)
        public
        pure
        returns (bytes memory assetData)
    {
        assetData = abi.encodeWithSelector(
            IAssetData(address(0)).MultiAsset.selector,
            amounts,
            nestedAssetData
        );
        return assetData;
    }

    // @dev Decode multi-asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant data describing a multi-asset basket.
    // @return The Multi-Asset AssetProxy identifier, an array of the amounts
    // of the assets to be traded, and an array of the
    // AssetProxy-compliant data describing each asset to be traded.  Each
    // element of the arrays corresponds to the same-indexed element of the other array.
    function decodeMultiAssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            uint256[] memory amounts,
            bytes[] memory nestedAssetData
        )
    {
        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == IAssetData(address(0)).MultiAsset.selector,
            "WRONG_PROXY_ID"
        );

        // solhint-disable indent
        (amounts, nestedAssetData) = abi.decode(
            assetData.slice(4, assetData.length),
            (uint256[], bytes[])
        );
        // solhint-enable indent
    }

    // @dev Encode StaticCall asset data into the format described in the AssetProxy contract specification.
    // @param staticCallTargetAddress Target address of StaticCall.
    // @param staticCallData Data that will be passed to staticCallTargetAddress in the StaticCall.
    // @param expectedReturnDataHash Expected Keccak-256 hash of the StaticCall return data.
    // @return AssetProxy-compliant asset data describing the set of assets.
    function encodeStaticCallAssetData(
        address staticCallTargetAddress,
        bytes memory staticCallData,
        bytes32 expectedReturnDataHash
    )
        public
        pure
        returns (bytes memory assetData)
    {
        assetData = abi.encodeWithSelector(
            IAssetData(address(0)).StaticCall.selector,
            staticCallTargetAddress,
            staticCallData,
            expectedReturnDataHash
        );
        return assetData;
    }

    // @dev Decode StaticCall asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing a StaticCall asset
    // @return The StaticCall AssetProxy identifier, the target address of the StaticCAll, the data to be
    // passed to the target address, and the expected Keccak-256 hash of the static call return data.
    function decodeStaticCallAssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address staticCallTargetAddress,
            bytes memory staticCallData,
            bytes32 expectedReturnDataHash
        )
    {
        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == IAssetData(address(0)).StaticCall.selector,
            "WRONG_PROXY_ID"
        );

        (staticCallTargetAddress, staticCallData, expectedReturnDataHash) = abi.decode(
            assetData.slice(4, assetData.length),
            (address, bytes, bytes32)
        );
    }

    // @dev Decode ERC20Bridge asset data from the format described in the AssetProxy contract specification.
    // @param assetData AssetProxy-compliant asset data describing an ERC20Bridge asset
    // @return The ERC20BridgeProxy identifier, the address of the ERC20 token to transfer, the address
    // of the bridge contract, and extra data to be passed to the bridge contract.
    function decodeERC20BridgeAssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress,
            address bridgeAddress,
            bytes memory bridgeData
        )
    {
        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == IAssetData(address(0)).ERC20Bridge.selector,
            "WRONG_PROXY_ID"
        );

        (tokenAddress, bridgeAddress, bridgeData) = abi.decode(
            assetData.slice(4, assetData.length),
            (address, address, bytes)
        );
    }

    // @dev Reverts if assetData is not of a valid format for its given proxy id.
    // @param assetData AssetProxy compliant asset data.
    function revertIfInvalidAssetData(bytes memory assetData)
        public
        pure
    {
        bytes4 assetProxyId = assetData.readBytes4(0);

        if (assetProxyId == IAssetData(address(0)).ERC20Token.selector) {
            decodeERC20AssetData(assetData);
        } else if (assetProxyId == IAssetData(address(0)).ERC721Token.selector) {
            decodeERC721AssetData(assetData);
        } else if (assetProxyId == IAssetData(address(0)).ERC1155Assets.selector) {
            decodeERC1155AssetData(assetData);
        } else if (assetProxyId == IAssetData(address(0)).MultiAsset.selector) {
            decodeMultiAssetData(assetData);
        } else if (assetProxyId == IAssetData(address(0)).StaticCall.selector) {
            decodeStaticCallAssetData(assetData);
        } else if (assetProxyId == IAssetData(address(0)).ERC20Bridge.selector) {
            decodeERC20BridgeAssetData(assetData);
        } else {
            revert("WRONG_PROXY_ID");
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./LibBytesRichErrors.sol";
import "./LibRichErrors.sol";

library LibBytes {
    using LibBytes for bytes;

    // @dev Gets the memory address for a byte array.
    // @param input Byte array to lookup.
    // @return memoryAddress Memory address of byte array. This
    //         points to the header of the byte array which contains
    //         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    // @dev Gets the memory address for the contents of a byte array.
    // @param input Byte array to lookup.
    // @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    // @dev Copies `length` bytes from memory location `source` to `dest`.
    // @param dest memory address to copy bytes to.
    // @param source memory address to copy bytes from.
    // @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    ) internal pure {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {

                    } lt(source, sEnd) {

                    } {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {

                    } slt(dest, dEnd) {

                    } {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    // @dev Returns a slices from a byte array.
    // @param b The byte array to take a slice from.
    // @param from The starting index for the slice (inclusive).
    // @param to The final index for the slice (exclusive).
    // @return result The slice containing bytes at indices [from, to)
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    ) internal pure returns (bytes memory result) {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            revert("SLICE:FROM_GRT_TO");
        }
        if (to > b.length) {
            revert("SLICE:TO_GRT_B_LENTH");
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    // @dev Returns a slice from a byte array without preserving the input.
    // @param b The byte array to take a slice from. Will be destroyed in the process.
    // @param from The starting index for the slice (inclusive).
    // @param to The final index for the slice (exclusive).
    // @return result The slice containing bytes at indices [from, to)
    // @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    ) internal pure returns (bytes memory result) {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            revert("SLICED_FROM_GT_TO");
        }
        if (to > b.length) {
            revert("SLICED_TO_GT_B_LENGTH");
        }

        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    // @dev Pops the last byte off of a byte array by modifying its length.
    // @param b Byte array that will be modified.
    // @return The byte that was popped off.
    function popLastByte(bytes memory b) internal pure returns (bytes1 result) {
        if (b.length == 0) {
            revert("PLB_B_LENGTH_IS_ZERO");
        }

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    // @dev Tests equality of two byte arrays.
    // @param lhs First byte array to compare.
    // @param rhs Second byte array to compare.
    // @return True if arrays are the same. False otherwise.
    function equals(bytes memory lhs, bytes memory rhs)
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    // @dev Reads an address from a position in a byte array.
    // @param b Byte array containing an address.
    // @param index Index in byte array of address.
    // @return address from byte array.
    function readAddress(bytes memory b, uint256 index)
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            revert("RA_B_LENGTH_LT_INDEX");
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
        return result;
    }

    // @dev Writes an address into a specific position in a byte array.
    // @param b Byte array to insert address into.
    // @param index Index in byte array of address.
    // @param input Address to put into byte array.
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    ) internal pure {
        if (b.length < index + 20) {
            revert("WA_B_LENGTH_LT_INDEX");
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    // @dev Reads a bytes32 value from a position in a byte array.
    // @param b Byte array containing a bytes32 value.
    // @param index Index in byte array of bytes32 value.
    // @return bytes32 value from byte array.
    function readBytes32(bytes memory b, uint256 index)
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            revert("RB32_B_LENGTH_LT_INDEX");
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    // @dev Writes a bytes32 into a specific position in a byte array.
    // @param b Byte array to insert <input> into.
    // @param index Index in byte array of <input>.
    // @param input bytes32 to put into byte array.
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    ) internal pure {
        if (b.length < index + 32) {
            revert("WB32_B_LENGTH_LT_INDEX");
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    // @dev Reads a uint256 value from a position in a byte array.
    // @param b Byte array containing a uint256 value.
    // @param index Index in byte array of uint256 value.
    // @return uint256 value from byte array.
    function readUint256(bytes memory b, uint256 index)
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    // @dev Writes a uint256 into a specific position in a byte array.
    // @param b Byte array to insert <input> into.
    // @param index Index in byte array of <input>.
    // @param input uint256 to put into byte array.
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    ) internal pure {
        writeBytes32(b, index, bytes32(input));
    }

    // @dev Reads an unpadded bytes4 value from a position in a byte array.
    // @param b Byte array containing a bytes4 value.
    // @param index Index in byte array of bytes4 value.
    // @return bytes4 value from byte array.
    function readBytes4(bytes memory b, uint256 index)
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            revert("RB4_B_LENGTH_LT_INDEX");
        }

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(
                result,
                0xFFFFFFFF00000000000000000000000000000000000000000000000000000000
            )
        }
        return result;
    }

    // @dev Writes a new length to a byte array.
    //      Decreasing length will lead to removing the corresponding lower order bytes from the byte array.
    //      Increasing length may lead to appending adjacent in-memory bytes to the end of the byte array.
    // @param b Bytes array to write new length to.
    // @param length New length of byte array.
    function writeLength(bytes memory b, uint256 length) internal pure {
        assembly {
            mstore(b, length)
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;


// @dev Interface of the asset proxy's assetData.
// The asset proxies take an ABI encoded `bytes assetData` as argument.
// This argument is ABI encoded as one of the methods of this interface.
interface IAssetData {

    // @dev Function signature for encoding ERC20 assetData.
    // @param tokenAddress Address of ERC20Token contract.
    function ERC20Token(address tokenAddress)
        external;

    // @dev Function signature for encoding ERC721 assetData.
    // @param tokenAddress Address of ERC721 token contract.
    // @param tokenId Id of ERC721 token to be transferred.
    function ERC721Token(
        address tokenAddress,
        uint256 tokenId
    )
        external;

    // @dev Function signature for encoding ERC1155 assetData.
    // @param tokenAddress Address of ERC1155 token contract.
    // @param tokenIds Array of ids of tokens to be transferred.
    // @param values Array of values that correspond to each token id to be transferred.
    //        Note that each value will be multiplied by the amount being filled in the order before transferring.
    // @param callbackData Extra data to be passed to receiver's `onERC1155Received` callback function.
    function ERC1155Assets(
        address tokenAddress,
        uint256[] calldata tokenIds,
        uint256[] calldata values,
        bytes calldata callbackData
    )
        external;

    // @dev Function signature for encoding MultiAsset assetData.
    // @param values Array of amounts that correspond to each asset to be transferred.
    //        Note that each value will be multiplied by the amount being filled in the order before transferring.
    // @param nestedAssetData Array of assetData fields that will be be dispatched to their correspnding AssetProxy contract.
    function MultiAsset(
        uint256[] calldata values,
        bytes[] calldata nestedAssetData
    )
        external;

    // @dev Function signature for encoding StaticCall assetData.
    // @param staticCallTargetAddress Address that will execute the staticcall.
    // @param staticCallData Data that will be executed via staticcall on the staticCallTargetAddress.
    // @param expectedReturnDataHash Keccak-256 hash of the expected staticcall return data.
    function StaticCall(
        address staticCallTargetAddress,
        bytes calldata staticCallData,
        bytes32 expectedReturnDataHash
    )
        external;

    // @dev Function signature for encoding ERC20Bridge assetData.
    // @param tokenAddress Address of token to transfer.
    // @param bridgeAddress Address of the bridge contract.
    // @param bridgeData Arbitrary data to be passed to the bridge contract.
    function ERC20Bridge(
        address tokenAddress,
        address bridgeAddress,
        bytes calldata bridgeData
    )
        external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library LibBytesRichErrors {

    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    // bytes4(keccak256("InvalidByteOperationError(uint8,uint256,uint256)"))
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    // solhint-disable func-name-mixedcase
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library LibRichErrors {
    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    uint256 internal constant AlmostOneWord = 0x1f;
    uint256 internal constant OneWord = 0x20;
    uint256 internal constant FreeMemoryPointerSlot = 0x40;
    uint256 internal constant CostPerWord = 3;
    uint256 internal constant MemoryExpansionCoefficient = 0x200; // 512
    uint256 internal constant ExtraGasBuffer = 0x20;

    // solhint-disable func-name-mixedcase
    // @dev ABI encode a standard, string revert error payload.
    //      This is the same payload that would be included by a `revert(string)`
    //      solidity statement. It has the function signature `Error(string)`.
    // @param message The error string.
    // @return The ABI encoded error.
    function StandardError(string memory message)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(STANDARD_ERROR_SELECTOR, bytes(message));
    }

    // solhint-enable func-name-mixedcase

    // @dev Reverts an encoded rich revert reason `errorData`.
    // @param errorData ABI encoded error data.
    function rrevert(bytes memory errorData) internal pure {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }

    function revertWithReasonIfOneIsReturned() internal view {
        assembly {
            // If it returned a message, bubble it up as long as sufficient gas
            // remains to do so:
            if returndatasize() {
                // Ensure that sufficient gas is available to copy returndata
                // while expanding memory where necessary. Start by computing
                // the word size of returndata and allocated memory.
                let returnDataWords := div(
                    add(returndatasize(), AlmostOneWord),
                    OneWord
                )

                // Note: use the free memory pointer in place of msize() to work
                // around a Yul warning that prevents accessing msize directly
                // when the IR pipeline is activated.
                let msizeWords := div(mload(FreeMemoryPointerSlot), OneWord)

                // Next, compute the cost of the returndatacopy.
                let cost := mul(CostPerWord, returnDataWords)

                // Then, compute cost of new memory allocation.
                if gt(returnDataWords, msizeWords) {
                    cost := add(
                        cost,
                        add(
                            mul(sub(returnDataWords, msizeWords), CostPerWord),
                            div(
                                sub(
                                    mul(returnDataWords, returnDataWords),
                                    mul(msizeWords, msizeWords)
                                ),
                                MemoryExpansionCoefficient
                            )
                        )
                    )
                }

                // Finally, add a small constant and compare to gas remaining;
                // bubble up the revert data if enough gas is still available.
                if lt(add(cost, ExtraGasBuffer), gas()) {
                    // Copy returndata to memory; overwrite existing memory.
                    returndatacopy(0, 0, returndatasize())

                    // Revert, specifying memory region with copied returndata.
                    revert(0, returndatasize())
                }
            }
        }
    }
}