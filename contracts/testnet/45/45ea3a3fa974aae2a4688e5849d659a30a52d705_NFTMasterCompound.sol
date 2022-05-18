/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
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

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

interface INFTcustom {
    function mintItem(address recipient) external returns (uint256);
    function burnItem(uint256 tokenId) external returns (uint256);
}

contract NFTMasterCompound is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    address[] public adminList;

    // group id
    Counters.Counter public _groupsId;

    // group info
    struct GroupInfo {
        address[] InputToken;
        address[] OutputToken;
        uint256[] OutputTokenAmount;
        bool OpenStatus;
    }

    // group info list (group id > groupInfo)
    mapping(uint256 => GroupInfo) public groupInfoList;

    // group id list (groupId > time)
    mapping(uint256 => uint256) public groupIdList;

    // input token type (token > type:0-burn,1-transfer)
    mapping(address => uint256) public inputTokenType;

    // output token type (token > type:0-mint,1-transfer)
    mapping(address => uint256) public outputTokenType;

    address public transferNftAddress;

    address public recipientNftAddress;

    constructor() public {
        adminList.push(msg.sender);

        recipientNftAddress = address(1);

        transferNftAddress = _msgSender();
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

    /* token type */
    function setInputTokenType(address[] memory _inputToken, uint256[] memory _typeList) public nonReentrant onlyAdmin {
        require(_inputToken.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_inputToken.length == _typeList.length, "INCONSISTENT_ARRAY");

        for ( uint256 _dd = 0; _dd < _inputToken.length; _dd++) {
            require(_inputToken[_dd] != address(0), "NONEMPTY_ADDRESS");
            inputTokenType[_inputToken[_dd]] = _typeList[_dd];
        }
    }

    function setOutputTokenType(address[] memory _outputToken, uint256[] memory _typeList) public nonReentrant onlyAdmin {
        require(_outputToken.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_outputToken.length == _typeList.length, "INCONSISTENT_ARRAY");

        for ( uint256 _dd = 0; _dd < _outputToken.length; _dd++) {
            require(_outputToken[_dd] != address(0), "NONEMPTY_ADDRESS");
            outputTokenType[_outputToken[_dd]] = _typeList[_dd];
        }
    }

    /* group */
    // add group info
    function addGroupInfo(address[] memory _inputToken, address[] memory _outputToken, uint256[] memory _outputTokenAmount, bool _openStatus) public nonReentrant onlyAdmin {
        require(_inputToken.length > 0, "NONEMPTY_INPUT_ADDRESS_LIST");
        require(_outputToken.length > 0, "NONEMPTY_OUTPUT_ADDRESS_LIST");
        require(_outputToken.length == _outputTokenAmount.length, "INCONSISTENT_ARRAY");

        for ( uint256 _d = 0; _d < _inputToken.length; _d++) {
            require(_inputToken[_d] != address(0), "NONEMPTY_INPUT_ADDRESS");
        }

        for ( uint256 _dd = 0; _dd < _outputToken.length; _dd++) {
            require(_outputToken[_dd] != address(0), "NONEMPTY_OUTPUT_ADDRESS");
            require(_outputTokenAmount[_dd] > 0, "NONEMPTY_OUTPUT_AMOUNT");
        }

        _groupsId.increment();
        uint256 newGroupId = _groupsId.current();

        groupIdList[newGroupId] = block.timestamp;
        groupInfoList[newGroupId] = GroupInfo(_inputToken, _outputToken, _outputTokenAmount, _openStatus);
    }

    // set group info
    function setGroupInfo(uint256 _groupId, address[] memory _inputToken, address[] memory _outputToken, uint256[] memory _outputTokenAmount, bool _openStatus) public nonReentrant onlyAdmin {
        require(checkGroupInfoIsSet(_groupId), "COMPOUND_ERROR");
        require(_inputToken.length > 0, "NONEMPTY_INPUT_ADDRESS_LIST");
        require(_outputToken.length > 0, "NONEMPTY_OUTPUT_ADDRESS_LIST");
        require(_outputToken.length == _outputTokenAmount.length, "INCONSISTENT_ARRAY");

        for ( uint256 _d = 0; _d < _inputToken.length; _d++) {
            require(_inputToken[_d] != address(0), "NONEMPTY_INPUT_ADDRESS");
        }

        for ( uint256 _dd = 0; _dd < _outputToken.length; _dd++) {
            require(_outputToken[_dd] != address(0), "NONEMPTY_OUTPUT_ADDRESS");
            require(_outputTokenAmount[_dd] > 0, "NONEMPTY_OUTPUT_AMOUNT");
        }

        groupInfoList[_groupId] = GroupInfo(_inputToken, _outputToken, _outputTokenAmount, _openStatus);
    }

    // set group status
    function setGroupStatus(uint256 _groupId, bool _status) public nonReentrant onlyAdmin {
        require( checkGroupInfoIsSet(_groupId), "COMPOUND_SETTING_ERROR");
        groupInfoList[_groupId].OpenStatus = _status;
    }

    // check group info is set
    function checkGroupInfoIsSet(uint256 _groupId) public view returns (bool) {
        if ( groupIdList[_groupId] > 0 ) {
            return true;
        } else {
            return false;
        }
    }

    // check group info is open
    function checkGroupIsOpen(uint256 _groupId) public view returns (bool) {
        return groupInfoList[_groupId].OpenStatus;
    }

    // get group info
    function getGroupInfo(uint256 _groupId) public view returns (address[] memory, address[] memory, uint256[] memory, bool) {
        address[] memory _inputToken = groupInfoList[_groupId].InputToken;
        address[] memory _outputToken = groupInfoList[_groupId].OutputToken;
        uint256[] memory _outputTokenAmount = groupInfoList[_groupId].OutputTokenAmount;
        bool _openStatus = groupInfoList[_groupId].OpenStatus;
        return (_inputToken, _outputToken, _outputTokenAmount, _openStatus);
    }

    event Compound(address _user, uint256 _groupId, address[] _inputToken, uint256[] _inputTokenID, address[] _outputToken, uint256[] _outputTokenID, uint256 _at);

    function compound(uint256 _groupId, uint256[] memory _inputTokenID) public nonReentrant {
        require( checkGroupInfoIsSet(_groupId), "COMPOUND_ERROR");
        require( checkGroupIsOpen(_groupId), "COMPOUND_CLOSE");

        (address[] memory _inputToken, address[] memory _outputToken, uint256[] memory _outputTokenAmount, ) = getGroupInfo(_groupId);

        uint256 _inputLen = _inputToken.length;
        require(_inputLen == _inputTokenID.length, "INCONSISTENT_LENGTH");

        // input
        for (uint256 i = 0; i < _inputLen; i++) {
            if ( inputTokenType[_inputToken[i]] > 0 ) {
                // transfer
                IERC721(_inputToken[i]).safeTransferFrom(msg.sender, recipientNftAddress, _inputTokenID[i]);
            } else {
                // burn
                INFTcustom(_inputToken[i]).burnItem(_inputTokenID[i]);
            }
        }

        // output
        uint256 _outputTokenAmountTotal = 0;
        for (uint256 j = 0; j < _outputTokenAmount.length; j++) {
            _outputTokenAmountTotal = _outputTokenAmountTotal.add(_outputTokenAmount[j]);
        }
        uint256[] memory _outputTokenID = new uint256[](_outputTokenAmountTotal);
        uint256 _outputTotalKey = 0;

        uint256 _outputLen = _outputToken.length;
        for (uint256 k = 0; k < _outputLen; k++) {
            address _outputTokenTmp = _outputToken[k];
            uint256 _outputTokenAmountTmp = _outputTokenAmount[k];

            if ( outputTokenType[_outputTokenTmp] > 0 ) {
                // transfer
                require(IERC721(_outputTokenTmp).balanceOf(transferNftAddress) >= _outputTokenAmountTmp, "NFT_BALANCE_ERROR");
                uint256[] memory _tokenIDList = new uint256[](_outputTokenAmountTmp);
                // get tokenID
                for(uint256 _i = 0; _i < _outputTokenAmountTmp; _i++){
                    uint256 _tokenID = IERC721Enumerable(_outputTokenTmp).tokenOfOwnerByIndex(transferNftAddress, _i);
                    _tokenIDList[_i] = _tokenID;
                }
                // transfer token
                for(uint256 _j = 0; _j < _outputTokenAmountTmp; _j++){
                    IERC721(_outputTokenTmp).safeTransferFrom(transferNftAddress, msg.sender, _tokenIDList[_j]);
                    _outputTokenID[_outputTotalKey] = _tokenIDList[_j];
                    _outputTotalKey = _outputTotalKey.add(1);
                }
            } else {
                // mint
                for ( uint256 kk = 0; kk < _outputTokenAmountTmp; kk++ ) {
                    _outputTokenID[_outputTotalKey] = INFTcustom(_outputTokenTmp).mintItem(msg.sender);
                    _outputTotalKey = _outputTotalKey.add(1);
                }
            }
        }

        emit Compound(msg.sender, _groupId, _inputToken, _inputTokenID, _outputToken, _outputTokenID, block.timestamp);
    }

}