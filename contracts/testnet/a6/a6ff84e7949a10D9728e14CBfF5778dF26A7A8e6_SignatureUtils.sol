// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SaleOrder, BundleSaleOrder, GroupOrder} from "../common/Structs.sol";
import {HashUtils} from "./HashUtils.sol";

contract SignatureUtils is HashUtils {

    function verifySaleOrder(
        SaleOrder memory _saleOrder,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = hashSaleOrder(_saleOrder);
        bytes32 ethSignedHash = getEthSignedHash(hash);
        return recover(ethSignedHash, _signature) == _signer;
    }

    function verifyBundleSaleOrder(
        BundleSaleOrder memory _bundleSaleOrder,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = hashBundleSaleOrder(_bundleSaleOrder);
        bytes32 ethSignedHash = getEthSignedHash(hash);
        return recover(ethSignedHash, _signature) == _signer;
    }

    function verifyGroupOrder(
        GroupOrder memory _groupOrder,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = hashGroupOrder(_groupOrder);
        bytes32 ethSignedHash = getEthSignedHash(hash);
        return recover(ethSignedHash, _signature) == _signer;
    }

    function recover(bytes32 ethSignedHash, bytes memory signature)
        public
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return ecrecover(ethSignedHash, v, r, s);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Structure of SaleOrder 
 * @param id id of the NFT
 * @param saleOrderId 0x + saleOrderId (mongoId)
 * @param price the price for sale of NFT
 * @param seller the address of the NFT owner
 * @param tokenAddress the address of the token used to purchase
 */
struct SaleOrder {
    uint256 id;
    uint256 saleOrderId;
    uint256 price;
    address seller;
    address tokenAddress;
}

/**
 * @dev Structure of SaleOrder 
 * @param ids list of NFT ids
 * @param saleOrderId 0x + saleOrderId (mongoId)
 * @param price the price for sale of bundle
 * @param seller the address of the NFT owner
 * @param tokenAddress the address of the token used to purchase
 * @param royaltyPercentage the royalty fee percentage of sale order
 */
struct BundleSaleOrder {
    uint256[] ids;
    uint256 saleOrderId;
    uint256 price;
    address seller;
    address tokenAddress;
    uint256 royaltyPercentage;
}

/**
 * @dev Structure of GroupOrder 
 * @param groupId of the sale orders
 * @param price the price for sale of bundle
 * @param seller the address of the NFT owner
 * @param tokenAddress the address of the token used to purchase
 */
struct GroupOrder{
    uint256 groupId;
    uint256 price;
    address seller;
    address tokenAddress;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Utils} from "./Utils.sol";
import {AssemblyUtils} from "./AssemblyUtils.sol";
import {BundleSaleOrder, SaleOrder, GroupOrder} from "../common/Structs.sol";

contract HashUtils {
    
    function hashBundleSaleOrder(BundleSaleOrder memory _bundleSaleOrder)
        public
        pure
        returns (bytes32 hash)
    {
        uint256 size = Utils.sizeOfBundleSaleOrder(_bundleSaleOrder);
        bytes memory array = new bytes(size);
        uint256 index;
        assembly {
            index := add(array, 0x20)
        }

        uint256 idsLength = _bundleSaleOrder.ids.length;
        for (uint256 i = 0; i < idsLength; i++) {
            index = AssemblyUtils.writeUint256(index, _bundleSaleOrder.ids[i]);
        }
        index = AssemblyUtils.writeUint256(index, _bundleSaleOrder.saleOrderId);
        index = AssemblyUtils.writeUint256(index, _bundleSaleOrder.price);
        index = AssemblyUtils.writeAddress(index, _bundleSaleOrder.seller);
        index = AssemblyUtils.writeAddress(index, _bundleSaleOrder.tokenAddress);
        index = AssemblyUtils.writeUint256(index, _bundleSaleOrder.royaltyPercentage);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    function hashSaleOrder(SaleOrder memory _saleOrder)
        public
        pure
        returns (bytes32 hash)
    {
        uint256 size = Utils.sizeOfSaleOrder();
        bytes memory array = new bytes(size);
        uint256 index;
        assembly {
            index := add(array, 0x20)
        }

        index = AssemblyUtils.writeUint256(index, _saleOrder.id);
        index = AssemblyUtils.writeUint256(index, _saleOrder.saleOrderId);
        index = AssemblyUtils.writeUint256(index, _saleOrder.price);
        index = AssemblyUtils.writeAddress(index, _saleOrder.seller);
        index = AssemblyUtils.writeAddress(index, _saleOrder.tokenAddress);
        
        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    function hashGroupOrder(GroupOrder memory _groupOrder)
        public
        pure
        returns (bytes32 hash)
    {
        uint256 size = Utils.sizeOfGroupOrder();
        bytes memory array = new bytes(size);
        uint256 index;
        assembly {
            index := add(array, 0x20)
        }

        index = AssemblyUtils.writeUint256(index, _groupOrder.groupId);
        index = AssemblyUtils.writeUint256(index, _groupOrder.price);
        index = AssemblyUtils.writeAddress(index, _groupOrder.seller);
        index = AssemblyUtils.writeAddress(index, _groupOrder.tokenAddress);
        
        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    function getEthSignedHash(bytes32 hash) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { BundleSaleOrder} from "../common/Structs.sol";

library Utils {
    function sizeOfSaleOrder() internal pure returns (uint256) {
        return ((0x20 * 3) + (0x14 * 2));
    }

    function sizeOfBundleSaleOrder(BundleSaleOrder memory _item) internal pure returns (uint256) {
        return ((0x20 * 3) + (0x20 * _item.ids.length) + (0x14 * 2));
    }

    function sizeOfGroupOrder() internal pure returns (uint256) {
        return ((0x20 * 2) + (0x14 * 2));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library AssemblyUtils {
    function writeUint8(uint256 index, uint8 source)
        internal
        pure
        returns (uint256)
    {
        assembly {
            mstore8(index, source)
            index := add(index, 0x1)
        }
        return index;
    }

    function writeAddress(uint256 index, address source)
        internal
        pure
        returns (uint256)
    {
        uint256 conv = uint256(uint160(source)) << 0x60;
        assembly {
            mstore(index, conv)
            index := add(index, 0x14)
        }
        return index;
    }

    function writeUint256(uint256 index, uint256 source)
        internal
        pure
        returns (uint256)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }

    function writeBytes(uint256 index, bytes memory source)
        internal
        pure
        returns (uint256)
    {
        if (source.length > 0) {
            assembly {
                let length := mload(source)
                let end := add(source, add(0x20, length))
                let arrIndex := add(source, 0x20)
                let tempIndex := index
                for {

                } eq(lt(arrIndex, end), 1) {
                    arrIndex := add(arrIndex, 0x20)
                    tempIndex := add(tempIndex, 0x20)
                } {
                    mstore(tempIndex, mload(arrIndex))
                }
                index := add(index, length)
            }
        }
        return index;
    }
}