// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "../common/ReentrancyGuard.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {GetterSetter} from "./GetterSetter.sol";
import {SignatureUtils} from "../utils/SignatureUtils.sol";
// import {SaleOrder, MintRequest} from "../common/Structs.sol";

contract Implementation is GetterSetter {
    // function initialize() initializer public {
    //   __Ownable_init();
    //   __UUPSUpgradeable_init();
    //   _status = _NOT_ENTERED;
    // }

    // function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * @dev handle create collection
     * @param (0) name, (1) symbol
     * @param 0: 721, 1: 1155
     * @param 0: transactionId
     */
    function createCollection(
        string[] memory,
        uint8,
        bytes memory
    ) public {
        _delegatecall(createCollectionHandler);
    }


    /**
     * @dev Handler buy request
     * @param (0) token id, (1) onSaleQuantity, (2) price, (3) token type, (4) amount, (5) isOffer, (6) royalty fee, (7) total copies
     * @param (0) buyer, (1) seller, (2) signer, (3) collectionAddress, (4) tokenAddress
     * @param (0) nftId, (1) saleOrderId, (2) transactionId
     * @param (0) saleOrderSignature, (1) requestSignature
     **/
    function buy(
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
    function cancelSaleOrder(
        uint256[] memory,
        address[] memory,
        bytes[] memory,
        bytes[] memory
    ) public {
        _delegatecall(cancelOrder);
    }

    /**
     * @dev Handle cancel offer request
     * @param (0) offerId, (1) transactionId
     * @param (0) signature
     */
    function cancelOffer(
        uint256[] memory,
        bytes[] memory,
        bytes[] memory
    ) public {
        _delegatecall(cancelOfferHandler);
    }

    function buyFromOwner(
        uint256[] memory,
        address[] memory,
        bytes[] memory,
        bytes[] memory
    ) public payable {
        _delegatecall(buyFromOwnerHandler);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Upgradeable} from "../common/Upgradeable.sol";

contract GetterSetter is Upgradeable {
    /**
     * @dev Set the system fee
     * @param _feeRatio the fee ratio (1% input 1000)
     */
    function setSystemFee(uint256 _feeRatio)
        public
        onlyOwner
    {
        systemFee = _feeRatio;
        emit SetServiceFee(systemFee);
    }

    /**
     * @dev Set the create collection handler's address
     * @param _createCollectionHandler the address of create collection handler
     */
    function setCreateCollectionHandler(address _createCollectionHandler)
        public
        notCurrentAddress(createCollectionHandler, _createCollectionHandler)
        notZeroAddress(_createCollectionHandler)
        onlyOwner
    {
        createCollectionHandler = _createCollectionHandler;
    }

    // /**
    //  * @dev Set the mint handler's address
    //  * @param _mintHandler the address of mint handler
    //  */
    // function setMintHandler(address _mintHandler)
    //     public
    //     notCurrentAddress(mintHandler, _mintHandler)
    //     notZeroAddress(_mintHandler)
    //     onlyOwner
    // {
    //     mintHandler = _mintHandler;
    // }

    /**
     * @dev Set the buy handler's address
     * @param _buyHandler the address of buy handler
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
     * @dev Set the cancel sale order handler's address
     * @param _cancelSaleOrder the address of cancel handler
     */
    function setCancelSaleOrder(address _cancelSaleOrder)
        public
        notCurrentAddress(cancelOrder, _cancelSaleOrder)
        notZeroAddress(_cancelSaleOrder)
        onlyOwner
    {
        cancelOrder = _cancelSaleOrder;
    }

    /**
     * @dev Set the cancel offer handler's address
     * @param _cancelOffer the address of cancel handler
     */
    function setCancelOffer(address _cancelOffer)
        public
        notCurrentAddress(cancelOfferHandler, _cancelOffer)
        notZeroAddress(_cancelOffer)
        onlyOwner
    {
        cancelOfferHandler = _cancelOffer;
    }

    /**
     * @dev Set the buy from owner handler's address
     * @param _buyFromOwnerHandler the address of handler
     */
    function setBuyFromOwnerHandler(address _buyFromOwnerHandler)
        public
        notCurrentAddress(buyFromOwnerHandler, _buyFromOwnerHandler)
        notZeroAddress(_buyFromOwnerHandler)
        onlyOwner
    {
        buyFromOwnerHandler = _buyFromOwnerHandler;
    }

    /**
     * @dev Set the collection 721's address
     * @param _collection721Address the address of collection 721
     */
    function setCollection721Address(address _collection721Address)
        public
        notCurrentAddress(collection721Address, _collection721Address)
        notZeroAddress(_collection721Address)
        onlyOwner
    {
        collection721Address = _collection721Address;
    }

    /**
     * @dev Set the collection 1155's address
     * @param _collection1155Address the address of collection 1155
     */
    function setCollection1155Address(address _collection1155Address)
        public
        notCurrentAddress(collection1155Address, _collection1155Address)
        notZeroAddress(_collection1155Address)
        onlyOwner
    {
        collection1155Address = _collection1155Address;
    }

    /**
     * @dev Approve an account to admin list
     * @param _account the wallet address
     */
    function setAdmin(address _account) public onlyOwner {
        adminList[_account] = true;

        emit SetAdminEvent(_account, true);
    }

    /**
     * @dev Remove an account from admin list
     * @param _account the wallet address
     */
    function revokeAdmin(address _account) public onlyOwner {
        adminList[_account] = false;

        emit SetAdminEvent(_account, false);
    }

    /**
     * @dev Add an account to the blacklist
     * @param _account the wallet address
     */
    function setToBlackList(address _account) public onlyAdmins {
        blackList[_account] = true;
    }

    /**
     * @dev Add an account to the blacklist
     * @param _account the wallet address
     */
    function removeFromBlackList(address _account) public onlyAdmins {
        blackList[_account] = false;
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
        return adminList[_account] || _account == owner();
    }

    /**
     * @dev Return an account is blacklisted or not
     */
    function isBlacklisted(address _account) public view returns (bool) {
        return blackList[_account];
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

import {SaleOrder, BuyRequest, OfferRequest} from "../common/Structs.sol";
import {HashUtils} from "./HashUtils.sol";

library SignatureUtils {
    using HashUtils for bytes32;
    using HashUtils for SaleOrder;
    using HashUtils for OfferRequest;
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
     * @param _offerRequest the offer request item
     * @param _signature the signature of the offer request
     * @param _signer the input address
     * @return result true/false
     */
    function verifyOfferRequest(
        OfferRequest memory _offerRequest,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _offerRequest.hashOfferRequest();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Structs.sol";

contract Upgradeable is Ownable {
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;

    uint256 internal _status;

    address public createCollectionHandler;
    address public mintHandler;
    address public buyHandler;
    address public cancelOrder;
    address public cancelOfferHandler;
    address public recipient;
    address public signer;
    address public collection721Address;
    address public collection1155Address;

    uint256 public systemFee;

    mapping(address => bool) adminList;
    mapping(address => bool) blackList;

    mapping(bytes => bool) public invalidSaleOrder;
    mapping(bytes => uint256) public soldQuantityBySaleOrder;   // signature sale order -> sold quantity
    mapping(bytes => uint256) public soldQuantity;              // nftId -> sold quantity

    mapping(bytes => uint256) public tokenIdByNFT;             // nftId -> tokenId

    address public buyFromOwnerHandler;
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

    modifier onlyAdmins() {
        require(
            adminList[msg.sender] || msg.sender == owner(),
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

    event CreateCollectionEvent(
        bytes transactionId,
        address caller,
        address collection,
        uint8 collectionType,
        string name,
        string symbol
    );

    event MintNFTEvent(
        bytes transactionId,
        address buyer,
        uint256 tokenId,
        uint256 amount
    );

    event BuyNFTEvent(
        bytes transactionId
    );

    event CancelOrderEvent(
        bytes transactionId
    );

    event CancelOfferEvent(
        bytes transactionId
    );

    event SetServiceFee(
        uint256 serviceFee
    );

    event BuyFromOwnerEvent(
        bytes transactionId,
        uint256 mintedAmount,
        uint256 transferedAmount,
        uint256 tokenId
    );

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


struct SaleOrder {
    uint256 onSaleQuantity;
    uint256 price;
    uint256 tokenType;
    address seller;
    address collectionAddress;
    bytes saleOrderId;      // internalTxId
}

struct BuyRequest {
    uint256 amount;
    uint256 royaltyFee;
    address buyer;
    address tokenAddress;
    bytes nftId;
    bytes transactionId;    // internalTxId
}

struct OfferRequest {
    uint256 expiredTime;
    address addr;
    bytes offerId;
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Utils} from "./Utils.sol";
import {AssemblyUtils} from "./AssemblyUtils.sol";
import {SaleOrder, BuyRequest, OfferRequest} from "../common/Structs.sol";

library HashUtils {
    // using Utils for MintRequest;
    using Utils for SaleOrder;
    using Utils for BuyRequest;
    using Utils for OfferRequest;
    using AssemblyUtils for uint256;


    /**
     * @dev Returns the hash of a offer request
     * @param _offerRequest the offer request item
     * @return hash the hash of offer request
     */
    function hashOfferRequest(OfferRequest memory _offerRequest)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _offerRequest.sizeOfOfferRequest();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }
        index = index.writeUint256(_offerRequest.expiredTime);
        index = index.writeAddress(_offerRequest.addr);
        index = index.writeBytes(_offerRequest.offerId);

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
        index = index.writeUint256(_buyRequest.amount);
        index = index.writeUint256(_buyRequest.royaltyFee);
        index = index.writeAddress(_buyRequest.buyer);
        index = index.writeAddress(_buyRequest.tokenAddress);
        index = index.writeBytes(_buyRequest.nftId);
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
        index = index.writeAddress(_saleOrder.collectionAddress);
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
    function recoverSigner_old(bytes32 _hash, bytes memory _signature)
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

        return ecrecover(_hash, v, r, s);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {SaleOrder, BuyRequest, OfferRequest} from "../common/Structs.sol";

library Utils {
    /**
     * @dev Returns the size of a sale order struct
     */
    function sizeOfSaleOrder(SaleOrder memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 3) + (0x14 * 2) + _item.saleOrderId.length);
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
            _item.nftId.length +
            _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a offer request struct
     */
    function sizeOfOfferRequest(OfferRequest memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 1) + (0x14 * 1) + _item.offerId.length);
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