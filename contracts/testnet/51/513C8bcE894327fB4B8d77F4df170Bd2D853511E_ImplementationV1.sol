// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Implementation} from "./Implementation.sol";
import {SignatureUtils} from "../utils/SignatureUtils.sol";
import {SaleOrder, MintRequest} from "../common/Structs.sol";

contract ImplementationV1 is Implementation {
    constructor(address _proxy) Implementation(_proxy) {}

    /**
     * @dev Handler mint request
     * @param (0) token id, (1) totalCopies, (2) onSaleQuantity, (3) price, (4) amount, (5) token type
     * @param (0) buyer, (1) seller, (2) signer, (3) collectionAddress, (4) tokenAddress
     * @param (0) saleOrderId, (1) transactionId
     * @param (0) saleOrderSignature, (1) mintRequestSignature
     */
    function handleMintRequest(
        uint256[] memory,
        address[] memory,
        bytes[] memory,
        bytes[] memory
    ) public payable {
        _delegatecall(mintHandler);
    }

    /**
     * @dev Handler buy request
     * @param (0) token id, (1) onSaleQuantity, (2) price, (3) token type, (4) amount
     * @param (0) buyer, (1) seller, (2) signer,(3) tokenAddress
     * @param (0) saleOrderId, (1) transactionId
     * @param (0) saleOrderSignature, (1) buyRequestSignature
     */
    function handleBuyRequest(
        uint256[] memory,
        address[] memory,
        bytes[] memory,
        bytes[] memory
    ) public payable  {
        _delegatecall(buyHandler);
    }

    /**
     * @dev Handle cancel sale order request
     * @param (0) onSaleQuantity, (1) price, (2) tokenType
     * @param (0) seller, (1) caller
     * @param (0) saleOrderId
     * @param (0) saleOrderSignature
     */
    function handleCancelOrder(
        uint256[] memory,
        address[] memory,
        bytes[] memory,
        bytes[] memory
    ) public {
        _delegatecall(cancelHandler);
    }

    function handleMintRequestByAdmin(
        address,
        bytes[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory
    ) public {
        _delegatecall(adminMintHandler);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Upgradeable} from "../common/Upgradeable.sol";

contract Implementation is Upgradeable {
    constructor(address _proxy) Upgradeable(_proxy) {}

    // == SETTER == //

    /**
     * @dev Set the collection721's address
     * @param _collection721 the address of collection721
     */
    function setCollection721(address _collection721)
        public
        notCurrentAddress(collection721, _collection721)
        notZeroAddress(_collection721)
        onlyOwner
    {
        collection721 = _collection721;
    }

    /**
     * @dev Set the collection1155's address
     * @param _collection1155 the address of collection1155
     */
    function setCollection1155(address _collection1155)
        public
        notCurrentAddress(collection1155, _collection1155)
        notZeroAddress(_collection1155)
        onlyOwner
    {
        collection1155 = _collection1155;
    }

    /**
     * @dev Set the mint handler's address
     * @param _mintHandler the address of mint handler
     */
    function setMintHandler(address _mintHandler)
        public
        notCurrentAddress(mintHandler, _mintHandler)
        notZeroAddress(_mintHandler)
        onlyOwner
    {
        mintHandler = _mintHandler;
    }

    /**
     * @dev Set the admin mint handler's address
     * @param _adminMintHandler the address of admin mint handler
     */
    function setAdminMintHandler(address _adminMintHandler)
        public
        notCurrentAddress(adminMintHandler, _adminMintHandler)
        notZeroAddress(_adminMintHandler)
        onlyOwner
    {
        adminMintHandler = _adminMintHandler;
    }

    /**
     * @dev Set the buy handler's address
     * @param _buyHandler the address of mint handler
     */
    function setBuyHandler(address _buyHandler)
        public
        notCurrentAddress(buyHandler, _buyHandler)
        notZeroAddress(_buyHandler)
        onlyOwner
    {
        buyHandler = _buyHandler;
    }

    /**
     * @dev Set the cancel handler's address
     * @param _cancelHandler the address of mint handler
     */
    function setCancelHandler(address _cancelHandler)
        public
        notCurrentAddress(cancelHandler, _cancelHandler)
        notZeroAddress(_cancelHandler)
        onlyOwner
    {
        cancelHandler = _cancelHandler;
    }

    /**
     * @dev Approve or rekoke an account from admin list
     * @param _account the wallet address
     * @param _value true/false
     */
    function setAdminList(address _account, bool _value) public onlyOwner {
        adminList[_account] = _value;

        emit SetAdminEvent(_account, _value);
    }

    /**
     * @dev Add or remove an account from the blacklist
     * @param _account the wallet address
     * @param _value true/false
     */
    function setBlackList(address _account, bool _value) public onlyAdmins {
        blackList[_account] = _value;
    }

    /**
     * @dev Add or remove an account from the whitelist
     * @param _account the wallet address
     * @param _value true/false
     */
    function setWhiteList(address _account, bool _value) public onlyAdmins {
        whiteList[_account] = _value;
    }

    /**
     * @dev Add or remove an account from the signer list
     * @param _account the wallet address
     */
    function setSigner(address _account)
        public
        notCurrentAddress(signer, _account)
        notZeroAddress(_account)
        onlyAdmins
    {
        signer = _account;
        emit SetSignerEvent(_account);
    }
    
    /**
     * @dev Add or remove an account from the signer list
     * @param _account the wallet address
     */
    function setRecipient(address _account)
        public
        notCurrentAddress(recipient, _account)
        notZeroAddress(_account)
        onlyAdmins
    {
        recipient = _account;
    }

    // == GETTER == //
    /**
     * @dev Return an account is admin or not
     */
    function isAdmin(address _account) public view returns (bool) {
        return adminList[_account];
    }

    /**
     * @dev Return an account is blacklisted or not
     */
    function isBlacklisted(address _account) public view returns (bool) {
        return blackList[_account];
    }

    /**
     * @dev Return an account is whitelisted or not
     */
    function isWhitelisted(address _account) public view returns (bool) {
        return whiteList[_account];
    }

    /**
     * @dev Return an account is signer or not
     */
    function isSigner(address _account) public view returns (bool) {
        return signer == _account;
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


struct SaleOrder {
    uint256 onSaleQuantity;
    uint256 price;
    uint256 tokenType;
    address seller;
    bytes saleOrderId;      // internalTxId
}

struct MintRequest {
    uint256 tokenId;
    uint256 totalCopies;
    uint256 amount;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import {ReentrancyGuard} from "./ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Structs.sol";
import "../interfaces/IProxy.sol";

contract Upgradeable is ReentrancyGuard {
    constructor(address _proxy) {
        proxy = _proxy;
    }

    // == VARIABLES == //
    address public immutable proxy;

    address public collection721;
    address public collection1155;
    address public mintHandler;
    address public buyHandler;
    address public cancelHandler;
    address public adminMintHandler;
    address public recipient;
    address public signer;

    mapping(address => bool) adminList;
    mapping(address => bool) blackList;
    mapping(address => bool) whiteList;

    mapping(bytes => bool) public invalidSaleOrder;
    mapping(bytes => uint256) public soldQuantityBySaleOrder;

    // == MODIFIERS == //
    modifier onlyOwner() {
        require(
            msg.sender == IProxy(proxy).proxyOwner(),
            "Implementation: Only owner"
        );
        _;
    }

    modifier onlyAdmins() {
        require(
            adminList[msg.sender] || msg.sender == IProxy(proxy).proxyOwner(),
            "Implementation: Only admins"
        );
        _;
    }

    modifier notBlocked() {
        require(!blackList[msg.sender], "Implementation: Caller was blocked");
        _;
    }

    modifier notZeroAddress(address _addr) {
        require(_addr != address(0), "Implemenation: Receive a zero address");
        _;
    }

    modifier notCurrentAddress(address _current, address _target) {
        require(
            _target != _current,
            "Implementation: Cannot set to the current address"
        );
        _;
    }

    modifier notAdmins() {
        require(!adminList[msg.sender], "Implementation: Not for admins");
        _;
    }

    // == EVENTS == //
    event SetAdminEvent(address indexed account, bool value);

    event SetSignerEvent(address indexed account);

    // == COMMON FUNCTIONS == //
    function _delegatecall(address _impl) internal virtual {
        require(
            _impl != address(0),
            "Implementation: impl address is zero address"
        );
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(
                sub(gas(), 10000),
                _impl,
                ptr,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
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

interface IProxy {
    function collection721() external view returns (address);

    function collection1155() external view returns (address);

    function invalidSaleOrder(bytes calldata saleOrderSignature)
        external
        view
        returns (bool);

    function isSigner(address account) external view returns (bool);

    function isAdmin(address account) external view returns (bool);

    function soldQuantityBySaleOrder(bytes calldata saleOrderSignature)
        external
        view
        returns (uint256);

    function proxyOwner() external view returns (address);
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

        index = index.writeUint256(_mintRequest.tokenId);
        index = index.writeUint256(_mintRequest.totalCopies);
        index = index.writeUint256(_mintRequest.amount);
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

import {SaleOrder, MintRequest, BuyRequest} from "../common/Structs.sol";

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