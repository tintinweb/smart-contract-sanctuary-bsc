// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SaleOrder, MintRequest, BuyRequest, RentOrder, RentRequest } from "../common/Structs.sol";
import {HashUtils} from "./HashUtils.sol";

library SignatureUtils {
    using HashUtils for bytes32;
    using HashUtils for SaleOrder;
    using HashUtils for MintRequest;
    using HashUtils for BuyRequest;
    using HashUtils for RentOrder;
    using HashUtils for RentRequest;


    /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _saleOrder the sale order item
     * @param _signature the signature of the sale order
     * @param _signer the input address
     * @return result true/false
     */
    function verifySaleOrder(
        SaleOrder memory _saleOrder,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _saleOrder.hashSaleOrder();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }

    /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _rentOrder the rent order item
     * @param _signature the signature of the rent order
     * @param _signer the input address
     * @return result true/false
     */
    function verifyRentOrder(
        RentOrder memory _rentOrder,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _rentOrder.hashRentOrder();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }
    /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _buyRequest the buy request item
     * @param _signature the signature of the buy request
     * @param _signer the input address
     * @return result true/false
     */
    function verifyBuyRequest(
        BuyRequest memory _buyRequest,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _buyRequest.hashBuyRequest();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }

     /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _mintRequest the mint request item
     * @param _signature the signature of the mint request
     * @param _signer the input address
     * @return result true/false
     */
    function verifyMintRequest(
        MintRequest memory _mintRequest,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _mintRequest.hashMintRequest();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }

    /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _rentRequest the rent request item
     * @param _signature the signature of the rent request
     * @param _signer the input address
     * @return result true/false
     */
    function verifyRentRequest(
        RentRequest memory _rentRequest,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _rentRequest.hashRentRequest();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct SaleOrder {
    uint256 onSaleQuantity;
    uint256 price;
    uint256 tokenType;
    address seller;
    bytes saleOrderId;      // internalTxId
}

struct MintRequest {
    uint256 totalCopies;
    uint256 amount;
    uint256 priceConvert;
    address buyer;
    address tokenAddress;
    bytes nftId;
    bytes saleOrderSignature;
    bytes transactionId;    // internalTxId
}

struct BuyRequest {
    uint256 tokenId;
    uint256 amount;
    address buyer;
    address tokenAddress;
    bytes saleOrderSignature;
    bytes transactionId;    // internalTxId
}

struct RentOrder {
    uint256 tokenId;
    uint256 fee; //per day
    uint256 expirationDate;
    address owner;
    address tokenAddress;
    bytes rentOrderSignature;
    bytes transactionId;    // internalTxId
}

struct RentRequest {
    uint256 tokenId;
    uint64 dayRent;
    uint256 rentFee;
    address renter;
    address tokenAddress;
    bytes rentRequestSignature;
    bytes transactionId;    // internalTxId
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Utils} from "./Utils.sol";
import {AssemblyUtils} from "./AssemblyUtils.sol";
import {SaleOrder, MintRequest, BuyRequest, RentOrder, RentRequest} from "../common/Structs.sol";

library HashUtils {
    using Utils for MintRequest;
    using Utils for SaleOrder;
    using Utils for BuyRequest;
    using Utils for RentOrder;
    using Utils for RentRequest;
    using AssemblyUtils for uint256;


    /**
     * @dev Returns the hash of a mint request
     * @param _mintRequest the mint request item
     * @return hash the hash of mint request
     */
    function hashMintRequest(MintRequest memory _mintRequest)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _mintRequest.sizeOfMintRequest();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }

        index = index.writeUint256(_mintRequest.totalCopies);
        index = index.writeUint256(_mintRequest.amount);
        index = index.writeUint256(_mintRequest.priceConvert);
        index = index.writeAddress(_mintRequest.buyer);
        index = index.writeAddress(_mintRequest.tokenAddress);
        index = index.writeBytes(_mintRequest.nftId);
        index = index.writeBytes(_mintRequest.saleOrderSignature);
        index = index.writeBytes(_mintRequest.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the hash of a buy request
     * @param _buyRequest the buy request item
     * @return hash the hash of buy request
     */
    function hashBuyRequest(BuyRequest memory _buyRequest)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _buyRequest.sizeOfBuyRequest();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }
        index = index.writeUint256(_buyRequest.tokenId);
        index = index.writeUint256(_buyRequest.amount);
        index = index.writeAddress(_buyRequest.buyer);
        index = index.writeAddress(_buyRequest.tokenAddress);
        index = index.writeBytes(_buyRequest.saleOrderSignature);
        index = index.writeBytes(_buyRequest.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the hash of a rent request
     * @param _rentRequest the rent request item
     * @return hash the hash of rent request
     */
    function hashRentRequest(RentRequest memory _rentRequest)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _rentRequest.sizeOfRentRequest();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }
        index = index.writeUint256(_rentRequest.tokenId);
        index = index.writeUint64(_rentRequest.dayRent);
        index = index.writeUint256(_rentRequest.rentFee);
        index = index.writeAddress(_rentRequest.renter);
        index = index.writeAddress(_rentRequest.tokenAddress);
        index = index.writeBytes(_rentRequest.rentRequestSignature);
        index = index.writeBytes(_rentRequest.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the hash of a rent order
     * @param _rentOrder the rent request item
     * @return hash the hash of rent order
     */
    function hashRentOrder(RentOrder memory _rentOrder)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _rentOrder.sizeOfRentOrder();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }
        index = index.writeUint256(_rentOrder.tokenId);
        index = index.writeUint256(_rentOrder.expirationDate);
        index = index.writeUint256(_rentOrder.fee);
        index = index.writeAddress(_rentOrder.owner);
        index = index.writeAddress(_rentOrder.tokenAddress);
        index = index.writeBytes(_rentOrder.rentOrderSignature);
        index = index.writeBytes(_rentOrder.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }
    
    /**
     * @dev Returns the hash of a sale order
     * @param _saleOrder the mint request item
     * @return hash the hash of sale order
     */
    function hashSaleOrder(SaleOrder memory _saleOrder)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _saleOrder.sizeOfSaleOrder();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }

        index = index.writeUint256(_saleOrder.onSaleQuantity);
        index = index.writeUint256(_saleOrder.price);
        index = index.writeUint256(_saleOrder.tokenType);
        index = index.writeAddress(_saleOrder.seller);
        index = index.writeBytes(_saleOrder.saleOrderId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the eth-signed hash of the hash data
     * @param hash the input hash data
     * @return ethSignedHash the eth signed hash of the input hash data
     */
    function getEthSignedHash(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    /**
     * @dev Returns the address which is recovered from the signature and the hash data
     * @param _hash the eth-signed hash data
     * @param _signature the signature which was signed by the admin
     * @return signer the address recovered from the signature and the hash data
     */
    function recoverSigner(bytes32 _hash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (_signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(_hash, v, r, s);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {SaleOrder, MintRequest, BuyRequest, RentOrder, RentRequest} from "../common/Structs.sol";

library Utils {
    /**
     * @dev Returns the size of a sale order struct
     */
    function sizeOfSaleOrder(SaleOrder memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 3) + (0x14 * 1) + _item.saleOrderId.length);
    }

    /**
     * @dev Returns the size of a mint request struct
     */
    function sizeOfMintRequest(MintRequest memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 3) +
            (0x14 * 2) +
            _item.nftId.length +
            _item.saleOrderSignature.length +
            _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a buy request struct
     */
    function sizeOfBuyRequest(BuyRequest memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 2) +
            (0x14 * 2) +
            _item.saleOrderSignature.length +
            _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a rent order struct
     */
    function sizeOfRentOrder(RentOrder memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 3) +
            (0x14 * 2) +
            _item.rentOrderSignature.length +
            _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a rent request struct
     */
    function sizeOfRentRequest(RentRequest memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 2) +
            (0x14 * 2) +
            0x8 +
            _item.rentRequestSignature.length +
            _item.transactionId.length);
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

    function writeUint64(uint256 index, uint64 source)
        internal
        pure
        returns (uint256)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x8)
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