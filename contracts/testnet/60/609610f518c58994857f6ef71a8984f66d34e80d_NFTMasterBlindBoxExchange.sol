/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
contract ReentrancyGuard {
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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

interface INFTcustom {
    function mintItem(address recipient) external returns (uint256);
    function burnItem(uint256 tokenId) external returns (uint256);
    function getBoxNftLog(address nftAddress, uint256 nftTokenID) external returns (uint256);
}

contract NFTMasterBlindBoxExchange is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    address[] public adminList;

    // nft info
    struct NftInfo {
        address[] NFTList;
        uint256[] SupplyList;
        bool OpenStatus;
    }

    // box info list (boxId > nft > NftInfo)
    mapping(uint256 => mapping(address => NftInfo)) public boxInfoList;

    // box at list (boxId > nft > time)
    mapping(uint256 => mapping(address => uint256)) public boxAtList;

    // box id list
    uint256[] public boxIdList;

    // input token type (token > type:0-burn,1-transfer)
    mapping(address => uint256) public inputTokenType;

    // output token type (token > type:0-mint,1-transfer)
    mapping(address => uint256) public outputTokenType;

    address public transferNftAddress;

    address public recipientNftAddress;

    address public boxAddress;

    constructor(address _boxAddress) public {
        adminList.push(msg.sender);

        recipientNftAddress = address(1);

        transferNftAddress = _msgSender();

        boxAddress = _boxAddress;
    }

    /* admin */
    // set admin list
    function setAdminList(address[] memory _list) public nonReentrant onlyOwner {
        require(_list.length > 0, "NONEMPTY_ADDRESS_LIST");

        for (uint256 nIndex = 0; nIndex < _list.length; nIndex++) {
            require(_list[nIndex] != address(0), "ADMIN_NONEMPTY_ADDRESS");
        }

        adminList = _list;
    }

    // get admin list
    function getAdminList() public view returns (address[] memory) {
        return adminList;
    }

    function onlyAdminCheck(address _adminAddress) internal view returns (bool) {
        for (uint256 nIndex = 0; nIndex < adminList.length; nIndex++) {
            if (adminList[nIndex] == _adminAddress) {
                return true;
            }
        }
        return false;
    }

    modifier onlyAdmin() {
        require(onlyAdminCheck(msg.sender) == true, "ONLY_ADMIN_OPERATE");

        _;
    }

    /* other */
    function setRecipientNftAddress(address _address) public nonReentrant onlyAdmin {
        require(_address != address(0), "NONEMPTY_ADDRESS");
        recipientNftAddress = _address;
    }

    function setTransferNftAddress(address _address) public nonReentrant onlyAdmin {
        require(_address != address(0), "NONEMPTY_ADDRESS");
        transferNftAddress = _address;
    }

    function setBoxAddress(address _address) public nonReentrant onlyAdmin {
        require(_address != address(0), "NONEMPTY_ADDRESS");
        boxAddress = _address;
    }

    /* token type */
    event SetInputTokenType(address _user, address[] _nftToken, uint256[] _typeList, uint256 _at);
    event SetOutputTokenType(address _user, address[] _nftToken, uint256[] _typeList, uint256 _at);

    function setInputTokenType(address[] memory _nftToken, uint256[] memory _typeList) public nonReentrant onlyAdmin {
        require(_nftToken.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_nftToken.length == _typeList.length, "INCONSISTENT_ARRAY");

        for ( uint256 _dd = 0; _dd < _nftToken.length; _dd++) {
            require(_nftToken[_dd] != address(0), "NONEMPTY_ADDRESS");
            inputTokenType[_nftToken[_dd]] = _typeList[_dd];
        }

        emit SetInputTokenType(msg.sender, _nftToken, _typeList, block.timestamp);
    }

    function setOutputTokenType(address[] memory _nftToken, uint256[] memory _typeList) public nonReentrant onlyAdmin {
        require(_nftToken.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_nftToken.length == _typeList.length, "INCONSISTENT_ARRAY");

        for ( uint256 _dd = 0; _dd < _nftToken.length; _dd++) {
            require(_nftToken[_dd] != address(0), "NONEMPTY_ADDRESS");
            outputTokenType[_nftToken[_dd]] = _typeList[_dd];
        }

        emit SetOutputTokenType(msg.sender, _nftToken, _typeList, block.timestamp);
    }

    /* box */
    event SetBoxInfo(address _user, uint256 _boxId, address _nftAddress, address[] _nftList, uint256[] _supplyList, bool _openStatus, uint256 _at);
    event SetBoxStatus(address _user, uint256 _boxId, address _nftAddress, bool _openStatus, uint256 _at);
    event BoxExchange(address _user, uint256 _boxId, address _nftToken, uint256 _nftTokenID, address _outputToken, uint256 _outputTokenID, uint256 _at);

    // set box info
    function setBoxInfo(uint256 _boxId, address _nftAddress, address[] memory _nftList, uint256[] memory _supplyList, bool _openStatus) public nonReentrant onlyAdmin {
        require(_boxId > 0, "BOX_ERROR");
        require(_nftAddress != address(0), "NONEMPTY_INPUT_ADDRESS");
        require(_nftList.length > 0, "NONEMPTY_OUTPUT_ADDRESS_LIST");
        require(_nftList.length == _supplyList.length, "INCONSISTENT_ARRAY");

        for ( uint256 _dd = 0; _dd < _nftList.length; _dd++) {
            require(_nftList[_dd] != address(0), "NONEMPTY_OUTPUT_ADDRESS");
        }

        boxInfoList[_boxId][_nftAddress] = NftInfo(_nftList, _supplyList, _openStatus);

        if( checkBoxInfoIsSet(_boxId, _nftAddress) == false ){
            boxAtList[_boxId][_nftAddress] = block.timestamp;
            boxIdList.push(_boxId);
        }

        emit SetBoxInfo(msg.sender, _boxId, _nftAddress, _nftList, _supplyList, _openStatus, block.timestamp);
    }

    // set box status
    function setBoxStatus(uint256 _boxId, address _nftAddress, bool _status) public nonReentrant onlyAdmin {
        require(checkBoxInfoIsSet(_boxId, _nftAddress), "BOX_SETTING_ERROR");
        boxInfoList[_boxId][_nftAddress].OpenStatus = _status;

        emit SetBoxStatus(msg.sender, _boxId, _nftAddress, _status, block.timestamp);
    }

    // check box info is set
    function checkBoxInfoIsSet(uint256 _boxId, address _nftAddress) public view returns (bool) {
        if ( boxAtList[_boxId][_nftAddress] > 0 ) {
            return true;
        } else {
            return false;
        }
    }

    // check box info is open
    function checkBoxIsOpen(uint256 _boxId, address _nftAddress) public view returns (bool) {
        return boxInfoList[_boxId][_nftAddress].OpenStatus;
    }

    // get box info
    function getBoxInfo(uint256 _boxId, address _nftAddress) public view returns (uint256, address, address[] memory, uint256[] memory, bool) {
        address[] memory _nftList = boxInfoList[_boxId][_nftAddress].NFTList;
        uint256[] memory _supplyList = boxInfoList[_boxId][_nftAddress].SupplyList;
        bool _openStatus = boxInfoList[_boxId][_nftAddress].OpenStatus;
        return (_boxId, _nftAddress, _nftList, _supplyList, _openStatus);
    }

    // random
    function psuedoRandomness() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
            block.number
        )));
    }

    // get remainder
    function getRemainder(uint256 _boxId, address _nftAddress) public view returns (uint256) {
        uint256 _tmpSupply = 0;
        uint256[] memory _supplyList = boxInfoList[_boxId][_nftAddress].SupplyList;
        for ( uint256 _dd = 0; _dd < _supplyList.length; _dd++ ) {
            _tmpSupply = _tmpSupply.add(_supplyList[_dd]);
        }
        return _tmpSupply;
    }

    // box exchange
    function boxExchange(address _nftAddress, uint256 _nftTokenID) public payable nonReentrant {
        uint256 _boxId = INFTcustom(boxAddress).getBoxNftLog(_nftAddress, _nftTokenID);
        require( _boxId > 0, "BOX_ERROR");
        require( checkBoxInfoIsSet(_boxId, _nftAddress), "BOX_NONEXISTENT");
        require( checkBoxIsOpen(_boxId, _nftAddress), "BOX_CLOSE");

        ( , , address[] memory _nftList, uint256[] memory _supplyList, ) = getBoxInfo(_boxId, _nftAddress);

        uint256 _remaining = getRemainder(_boxId, _nftAddress);
        require(_remaining > 0, "SUPPLY_INSUFFICIENT");

        uint256 _randomness = psuedoRandomness();
        _randomness = _randomness.mod(_remaining);
 
        address _outputToken;
        for ( uint256 ind = 0; ind < _supplyList.length; ind++ ) {
            if ( _randomness <= _supplyList[ind] && _supplyList[ind] > 0 ) {
                _outputToken = _nftList[ind];
                boxInfoList[_boxId][_nftAddress].SupplyList[ind] = boxInfoList[_boxId][_nftAddress].SupplyList[ind].sub(1);
                break;
            } else {
                _randomness = _randomness.sub(_supplyList[ind]);
            }
        }

        // input
        require(IERC721(_nftAddress).ownerOf(_nftTokenID) == msg.sender, "TOKEN_OWNER_ERROR");
        if ( inputTokenType[_nftAddress] > 0 ) {
            // transfer
            IERC721(_nftAddress).safeTransferFrom(msg.sender, recipientNftAddress, _nftTokenID);
        } else {
            // burn
            INFTcustom(_nftAddress).burnItem(_nftTokenID);
        }

        // output
        uint256 _outputTokenID = 0;
        if ( outputTokenType[_outputToken] > 0 ) {
            // transfer
            require(IERC721(_outputToken).balanceOf(transferNftAddress) > 0, "NFT_BALANCE_ERROR");
            // get tokenID
            _outputTokenID = IERC721Enumerable(_outputToken).tokenOfOwnerByIndex(transferNftAddress, 0);
            // transfer token
            IERC721(_outputToken).safeTransferFrom(transferNftAddress, msg.sender, _outputTokenID);
        } else {
            // mint
            _outputTokenID = INFTcustom(_outputToken).mintItem(msg.sender);
        }

        emit BoxExchange(msg.sender, _boxId, _nftAddress, _nftTokenID, _outputToken, _outputTokenID, block.timestamp);
    }

}