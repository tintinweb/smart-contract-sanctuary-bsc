// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SaleOrder} from "../common/Structs.sol";
import {ReentrancyGuard} from "../common/ReentrancyGuard.sol";
import {SignatureUtils} from "../utils/SignatureUtils.sol";
import {IProxy} from "../interfaces/IProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CancelHandler is Ownable, ReentrancyGuard {
    using SignatureUtils for SaleOrder;
    address public controller;

    event CancelOrderEvent(
        address indexed caller,
        bytes saleOrderSignature,
        bytes saleOrderId
    );

    constructor(address _controller) {
        controller = _controller;
    }

    /**
     * @dev Allows which contract or who can call this contract's functions
     * @param _newController the new controller
     */
    function setController(address _newController) public onlyOwner {
        require(
            _newController != address(0),
            "BuyHandler: New controller is zero address"
        );

        controller = _newController;
    }

    /**
     * @dev Handle cancel sale order request
     * @param _data (0) onSaleQuantity, (1) price, (2) tokenType
     * @param _addr (0) seller, (1) caller, (2) signer
     * @param _internalTxId (0) saleOrderId
     * @param _signatures (0) saleOrderSignature
     */
    function handleCancelOrder(
        uint256[] memory _data,
        address[] memory _addr,
        bytes[] memory _internalTxId,
        bytes[] memory _signatures
    ) public nonReentrant {
        SaleOrder memory saleOrder = SaleOrder({
            onSaleQuantity: _data[0],
            price: _data[1],
            tokenType: _data[2],
            seller: _addr[0],
            saleOrderId: _internalTxId[0]
        });

        if (saleOrder.seller == address(0)) {
            require(
                IProxy(controller).isAdmin(_addr[1]) ||
                    IProxy(controller).owner() == _addr[1],
                "CancelHandler: Only admins"
            );
        } else {
            require(
                _addr[1] == saleOrder.seller,
                "CancelHandler: Only NFT's owner"
            );
        }

        require(
            IProxy(controller).soldQuantityBySaleOrder(_signatures[0]) <
                _data[0],
            "CancelHandler: Sold out"
        );

        require(
            !IProxy(controller).invalidSaleOrder(_signatures[0]),
            "CancelHandler: Sale order has been canceled"
        );

        require(
            saleOrder.verifySaleOrder(_signatures[0], _addr[2]),
            "CancelHandler: Verify sale order failed"
        );

        emit CancelOrderEvent(msg.sender, _signatures[0], _internalTxId[0]);
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
    uint256 nftId;
    uint256 tokenId;
    uint256 totalCopies;
    uint256 amount;
    address buyer;
    address tokenAddress;
    bytes saleOrderSignature;
    bytes transactionId;    // internalTxId
}

struct BuyRequest {
    uint256 tokenId;
    uint256 amount;
    address buyer;
    address tokenAddress;
    bytes saleOrderSignature;
    bytes transactionId;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SaleOrder, MintRequest, BuyRequest } from "../common/Structs.sol";
import {HashUtils} from "./HashUtils.sol";

library SignatureUtils {
    using HashUtils for bytes32;
    using HashUtils for SaleOrder;
    using HashUtils for MintRequest;
    using HashUtils for BuyRequest;


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
     * @param _buyRequest the mint request item
     * @param _signature the signature of the mint request
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IProxy {
    function collection721() external view returns (address);

    function collection1155() external view returns (address);

    function invalidSaleOrder(bytes calldata saleOrderSignature)
        external
        view
        returns (bool);

    function isSigner(address account) external view returns (bool);

    function isAdmin(address account) external view returns (bool);

    function owner() external view returns (address);

    function soldQuantityBySaleOrder(bytes calldata saleOrderSignature)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Utils} from "./Utils.sol";
import {AssemblyUtils} from "./AssemblyUtils.sol";
import {SaleOrder, MintRequest, BuyRequest} from "../common/Structs.sol";

library HashUtils {
    using Utils for MintRequest;
    using Utils for SaleOrder;
    using Utils for BuyRequest;
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

        index = index.writeUint256(_mintRequest.nftId);
        index = index.writeUint256(_mintRequest.tokenId);
        index = index.writeUint256(_mintRequest.totalCopies);
        index = index.writeUint256(_mintRequest.amount);
        index = index.writeAddress(_mintRequest.buyer);
        index = index.writeAddress(_mintRequest.tokenAddress);
        index = index.writeBytes(_mintRequest.saleOrderSignature);
        index = index.writeBytes(_mintRequest.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the hash of a buy request
     * @param _buyRequest the mint request item
     * @return hash the hash of mint request
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
        index = index.writeBytes(bytes(_saleOrder.saleOrderId));

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

import { SaleOrder, MintRequest, BuyRequest } from "../common/Structs.sol";

library Utils {
    /**
     * @dev Returns the size of a sale order struct
     */
    function sizeOfSaleOrder(SaleOrder memory _item) internal pure returns (uint256) {
        return ((0x20 * 3) + (0x14 * 1) + _item.saleOrderId.length);
    }

    /**
     * @dev Returns the size of a mint request struct
     */
    function sizeOfMintRequest(MintRequest memory _item) internal pure returns (uint256) {
        return ((0x20 * 4) + (0x14 * 2) + _item.saleOrderSignature.length + _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a buy request struct
     */
    function sizeOfBuyRequest(BuyRequest memory _item) internal pure returns (uint256) {
        return ((0x20 * 2) + (0x14 * 2) + _item.saleOrderSignature.length + _item.transactionId.length);
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