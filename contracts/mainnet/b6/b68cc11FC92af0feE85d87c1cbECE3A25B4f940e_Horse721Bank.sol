/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: contracts/Horse721Bank.sol


pragma solidity ^0.8.0;




interface IHorse {
    function mint(address to, uint8  _level, uint8 _gender) external;
    function burn(uint256 _tokenId) external;
    function crossMint(address to, uint256 _tokenId, uint8  _level, uint8 _gender) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function horseInfoMap(uint256 _tokenId) external view returns (uint256, uint8, uint8);
    function ownerOf(uint256 tokenId) external view returns (address owner);
}
library Signature {
    function getEthSignedMessageHash(bytes32 messageHash)
        private
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    messageHash
                )
            );
    }

    function getSigner(bytes32 messageHash, bytes memory sig)
        internal
        pure
        returns (address)
    {
       
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return ecrecover(getEthSignedMessageHash(messageHash), v, r, s);
    }
}

contract Horse721Bank is Ownable, IERC721Receiver, ReentrancyGuard {
    struct DepositRecord {
        address playerAddress;
        uint256 tokenId;
        uint8   level;
        uint8   gender;
        uint256 depositTime;
    }
    struct WithdrawRecord {
        uint256 orderNumber;
        address playerAddress;
        uint256 tokenId;
        uint256 withdrawTime;
        uint256 blockNumbers;
    }
    struct RechargeRecord {
        uint256 tokenId;
        address playerAddress;
        uint256 blockTime;
        bool    state;
        uint256 withdrawIndex;
    }

    IHorse horse = IHorse(0xc3D43b1c6974bFd695043570DEB2D3a9Abb96cBd);

    uint256 public depositIndex;
    uint256 public withdrawIndex;

    address public signer;

    uint8[9] private _levels  = [0, 10, 20, 30, 40, 50, 51, 60, 61];
    uint8[2] private _genders = [1, 2];

    mapping(uint256=>bool) public orderList;
    mapping(uint256 => DepositRecord)  public depositRecords;
    mapping(uint256 => WithdrawRecord) public withdrawRecords;
    mapping(uint256 => RechargeRecord) public rechargeRecords;

    event Recharge (uint256 orderNumber, uint256 tokenId, address playerAddress, uint256 blockTime);

    constructor () {
        depositIndex  = 1;
        withdrawIndex = 1;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    function setSinger(address _signer) external onlyOwner{
        require(_signer != address(0), "error operator");
        require(!_isContract(_signer), "contract not allowed");
        
        signer = _signer;
    }

    function depositNFT (uint256 _tokenId) external nonReentrant {
        (uint256 _id, uint8 _level, uint8 _gender) = horse.horseInfoMap(_tokenId);
        depositRecords[depositIndex] = DepositRecord(_msgSender(), _id, _level, _gender, block.timestamp);

        depositIndex ++;
        horse.transferFrom(_msgSender(), address(this), _tokenId);
    }
    
    function batchDepositNFT (uint256[] memory _tokenIds) external nonReentrant {
        require (_tokenIds.length >= 1, "array length is too short");

        for (uint256 i = 0; i < _tokenIds.length;) {
            (uint256 _id, uint8 _level, uint8 _gender) = horse.horseInfoMap(_tokenIds[i]);
            depositRecords[depositIndex] = DepositRecord(_msgSender(), _id, _level, _gender, block.timestamp);

            depositIndex ++;
            horse.transferFrom(_msgSender(), address(this), _id);
            unchecked {
                i++;
            }
        }
    }

    function encode(address _playerAddress,uint256 _orderNumber, uint256 _tokenId, uint8 _levelIndex, uint8 _gender) public  view returns (bytes32)  {
        require(!orderList[_orderNumber], "error orderNumber");
        require(_orderNumber > 0, "orderNumber too low");
        require(_playerAddress != address(0), "error address");
        require(!_isContract(_playerAddress), "contract not allowed");
        require(_gender == 1 || _gender == 2, "gender error");
        require(_levelIndex <= 8, "levelIndex error");
        require(horse.ownerOf(_tokenId) == address(0) || horse.ownerOf(_tokenId) == address(this), "tokenId error");

        return keccak256(abi.encodePacked(_playerAddress, _orderNumber, _tokenId, _levelIndex, _gender));
    }

    function claim(address _playerAddress, uint256 _orderNumber, uint256 _tokenId, uint8 _levelIndex, uint8 _gender, bytes memory signature) private view returns(bool) {
        return Signature.getSigner(encode(_playerAddress, _orderNumber, _tokenId, _levelIndex, _gender), signature) == signer;
    }

    function rechargeEncode(uint256 _orderNumber, address _playerAddress, uint256 _tokenId) public  view returns (bytes32)  {
        require(!orderList[_orderNumber], "error orderNumber");
        require(_playerAddress != address(0), "error address");
        require(!_isContract(_playerAddress), "contract not allowed");
        require(horse.ownerOf(_tokenId) == address(0) || horse.ownerOf(_tokenId) == address(this), "tokenId error");

        return keccak256(abi.encodePacked(_orderNumber, _playerAddress, _tokenId));
    }
    
    function rechargeClaim(uint256 _orderNumber, address _playerAddress, uint256 _tokenId, bytes memory signature) private view returns(bool) {
        return Signature.getSigner(rechargeEncode(_orderNumber, _playerAddress, _tokenId), signature) == signer;
    }

    function rechargeNFT(uint256 _orderNumber, address _playerAddress, uint256 _tokenId, bytes memory signature) external nonReentrant{
        require(rechargeClaim(_orderNumber, _playerAddress, _tokenId, signature), "signature verification failed");
        require(!orderList[_orderNumber], "error orderNumber");
        require(_playerAddress != address(0), "error address");
        require(!_isContract(_playerAddress), "contract not allowed");
        require(horse.ownerOf(_tokenId) == address(0) || horse.ownerOf(_tokenId) == address(this), "tokenId error");
       
        rechargeRecords[_orderNumber] = RechargeRecord(_tokenId, _playerAddress, block.timestamp, false, 0);

        emit Recharge(_orderNumber, _tokenId, _playerAddress, block.timestamp);
    }
 
    function withdrawNFT (address _playerAddress, uint256 _orderNumber, uint256 _tokenId, uint8 _levelIndex, uint8 _gender, bytes memory signature) external nonReentrant {
        require(_msgSender() == _playerAddress, "insufficient permissions");
        require(!orderList[_orderNumber], "error orderNumber");
        require(_playerAddress != address(0), "error address");
        require(!_isContract(_playerAddress), "contract not allowed");
        require(horse.ownerOf(_tokenId) == address(0) || horse.ownerOf(_tokenId) == address(this), "tokenId error");
        require(_gender == 1 || _gender == 2, "gender error");
        require(_levelIndex <= 8, "levelIndex error");
        require(claim(_playerAddress, _orderNumber, _tokenId, _levelIndex, _gender, signature), "signature verification failed");

        if (horse.ownerOf(_tokenId) == address(this)){
            horse.transferFrom(address(this), _playerAddress, _tokenId);
        }else{
            if(_tokenId == 0){
            horse.mint(_playerAddress, _levels[_levelIndex], _gender);
            } else {
            horse.crossMint(_playerAddress, _tokenId, _levels[_levelIndex], _gender);
            }
        }

        RechargeRecord storage rechargeRecord = rechargeRecords[_orderNumber];
        rechargeRecord.state = true;
        rechargeRecord.withdrawIndex = withdrawIndex;

        withdrawRecords[withdrawIndex] = WithdrawRecord(_orderNumber, _msgSender(), _tokenId, block.timestamp, block.number);
        withdrawIndex ++;

        orderList[_orderNumber] = true;
    }
    
    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}