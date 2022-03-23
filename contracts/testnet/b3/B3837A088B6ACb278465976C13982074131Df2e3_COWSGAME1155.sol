// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {Address} from './Address.sol';
import {IERC1155} from './IERC1155.sol';
import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IVerifySignature} from './IVerifySignature.sol';
import './ReentrancyGuard.sol';

contract COWSGAME1155 is ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    address public operator;
    address public owner;
    bool public _paused = false;

    address public POOL_GAME;
    address public VERIFY_SIGNATURE;
    address public USER_COWSBOY;

    uint256 public constant DECIMAL_18 = 10 ** 18;
    uint256 public constant PERCENTS_DIVIDER = 1000000000;

    struct UserInfo {
        mapping(address => uint256) nftDeposit;
        uint256 lastUpdatedAt;
        mapping(address => uint256) nftRewardClaimed;
        uint8 status;  // 0 : not active ; 1 active ; 2 is lock ; 2 is ban
    }

    struct DepositedNFT {
        uint256[] depositedTokenIds;
        mapping(uint256 => uint256) tokenIdToAmount;
        mapping(uint256 => uint256) tokenIdToIndex;
    }

    mapping(address => UserInfo) public userInfo;
    //nft => user => DepositedNFT
    mapping(address => mapping(address => DepositedNFT)) nftUserInfo;
    //NFT support
    address[] public supportedNFTList;
    mapping(address => bool) public supportedNFTMapping;
    //user => sign => status
    mapping(address => mapping(bytes => bool)) userSigned;
    //events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ChangeOperator(address indexed previousOperator, address indexed newOperator);


    event NFTDeposit(address nft, address depositor, bytes tokenIds, uint256 amount);
    event NFTWithdraw(address nft, address withdrawer, bytes tokenIds, uint256 amount);
    event NFTClaim(address nft, address withdrawer, bytes tokenIds, uint256 amount);
    event NFTSupported(address nft, bool val);

    modifier onlyOwner() {
        require(msg.sender == owner, 'INVALID owner');
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, 'INVALID operator');
        _;
    }

    //constructor(address _user, address _sign, address _nft) public 
    constructor() public 
    {
        //address _user = 0x009fbfe571f29c3b994a0cd84b2f47b7e7d73cdc;
        //address _sign = 0x4f0736236903e5042abcc5f957fd0ae32f142405;
        //address _nft = 0x40C86ce37BBb861c42D007Fa81461Bc5F6136327;
        owner = tx.origin;
        operator = tx.origin;
        POOL_GAME = tx.origin;
        USER_COWSBOY = 0x009fbfe571f29c3b994a0cd84B2f47b7e7D73CDC;
        VERIFY_SIGNATURE = 0x4f0736236903E5042abCc5F957fD0ae32f142405;  
        address[] memory _nfts = new address[](1);
        _nfts[0] = 0x40C86ce37BBb861c42D007Fa81461Bc5F6136327;
        _setSupportedNFTs(_nfts);
    }

    fallback() external {

    }

    receive() payable external {

    }

    function pause() public onlyOwner {
        _paused = true;
    }

    function unpause() public onlyOwner {
        _paused = false;
    }


    modifier ifPaused(){
        require(_paused, "");
        _;
    }

    modifier ifNotPaused(){
        require(!_paused, "");
        _;
    }

    modifier onlySupportedNFT(address _nft) {
        require(supportedNFTMapping[_nft], "not supported nft");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`operator`).
     * Can only be called by the current owner.
     */
    function transferOperator(address _operator) public onlyOwner {
        emit ChangeOperator(operator, _operator);
        operator = _operator;
    }

    /**
    * @dev Withdraw Token to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
    function clearToken(address recipient, address token, uint256 amount) public onlyOwner {
        require(IERC20(token).balanceOf(address(this)) >= amount, "INVALID balance");
        IERC20(token).transfer(recipient, amount);
    }

    /**
    * @dev Withdraw  BNB to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
    function clearBNB(address payable recipient) public onlyOwner {
        _safeTransferBNB(recipient, address(this).balance);
    }

    /**
    * @dev transfer BNB to an address, revert if it fails.
    * @param to recipient of the transfer
    * @param value the amount to send
    */
    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'BNB_TRANSFER_FAILED');
    }


    /**
    * @dev Update update_POOL_WALLET
    */
    function updatePool(address _pool) public onlyOwner {
        POOL_GAME = _pool;
    }

    function setSupportedNFTs(address[] memory _nfts) external onlyOwner {
        _setSupportedNFTs(_nfts);
    }

    function _setSupportedNFTs(address[] memory _nfts) private {
        //diminish the current list
        for (uint256 i = 0; i < supportedNFTList.length; i++) {
            supportedNFTMapping[supportedNFTList[i]] = false;
            emit NFTSupported(supportedNFTList[i], false);
        }
        supportedNFTList = _nfts;
        for (uint256 i = 0; i < supportedNFTList.length; i++) {
            supportedNFTMapping[supportedNFTList[i]] = true;
            emit NFTSupported(_nfts[i], true);
        }
    }

    function _isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function isContract(address account) internal view returns (bool)
    {
        return _isContract(account);
    }

    function depositNFTsToGame(address _nft, uint256 _tokenId,
        uint256 _amount)
    external onlySupportedNFT(_nft) ifNotPaused returns (bool)
    {
        require(_isContract(msg.sender) == false, "depositNFTsToGame: anti bot");
        require(IERC1155(_nft).isApprovedForAll(msg.sender, address(this)) == true, "depositNFTsToGame: Check the nft approve ");

        DepositedNFT storage _userNFT = nftUserInfo[_nft][msg.sender];

        IERC1155(_nft).safeTransferFrom(
            msg.sender,
            POOL_GAME,
            _tokenId,
            _amount,
            ""
        );

        _userNFT.depositedTokenIds.push(_tokenId);
        _userNFT.tokenIdToIndex[_tokenId] = _userNFT.depositedTokenIds.length;
        _userNFT.tokenIdToAmount[_tokenId] += _amount;

        userInfo[msg.sender].nftDeposit[_nft] += _amount;
        userInfo[msg.sender].lastUpdatedAt = block.timestamp;
        emit NFTDeposit(_nft, msg.sender, abi.encodePacked(_tokenId), _amount);
        return true;
    }

    function withdrawNFTs(
        address _nft,
        uint256 _tokenId,
        uint256 _amount,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) external onlySupportedNFT(_nft) ifNotPaused returns (bool) {
        require(_isContract(msg.sender) == false, "withdrawNFTs: anti bot");
        require(userSigned[msg.sender][signature] == false, "withdrawNFTs: invalid signature");
        require(block.timestamp < _expiredTime, "withdrawNFTs: !expired");

        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _amount, _message, _expiredTime, signature) == true,
            "withdrawNFTs: invalid operator"
        );

        DepositedNFT storage _user = nftUserInfo[_nft][msg.sender];

        require(_user.tokenIdToIndex[_tokenId] > 0, "withdrawNFTs: invalid tokenId");
        require(_amount > 0, "withdrawNFTs: invalid amount");
        require(_user.tokenIdToAmount[_tokenId] >= _amount, "withdrawNFTs: invalid amount");

        IERC1155(_nft).safeTransferFrom(
            POOL_GAME,
            msg.sender,
            _tokenId,
            _amount,
            ""
        );

        _user.tokenIdToAmount[_tokenId] -= _amount;

        if (_user.tokenIdToAmount[_tokenId] <= 0) {
            uint256 _index = _user.tokenIdToIndex[_tokenId] - 1;
            _user.depositedTokenIds[_index] = _user.depositedTokenIds[
            _user.depositedTokenIds.length - 1
            ];
            _user.tokenIdToIndex[_user.depositedTokenIds[_index]] = _index + 1;
            _user.depositedTokenIds.pop();
            delete _user.tokenIdToIndex[_tokenId];
        }

        userInfo[msg.sender].nftDeposit[_nft] -= _amount;
        userInfo[msg.sender].lastUpdatedAt = block.timestamp;
        emit NFTWithdraw(_nft, msg.sender, abi.encodePacked(_tokenId), _amount);
        userSigned[msg.sender][signature] = true;
        return true;
    }

    function claimNFTRewards(
        address _nft,
        uint256 _tokenId,
        uint256 _amount,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) external onlySupportedNFT(_nft) ifNotPaused returns (uint256)
    {
        require(_isContract(msg.sender) == false, "claimNFTRewards: anti bot");
        require(userSigned[msg.sender][signature] == false, "claimNFTRewards: invalid signature");
        require(block.timestamp < _expiredTime, "claimNFTRewards: !expired");
        require(_amount > 0, "claimNFTRewards: invalid amount");
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, _amount , _message, _expiredTime, signature) == true,
            "claimNFTRewards: invalid operator"
        );

        IERC1155(_nft).safeTransferFrom(
            POOL_GAME,
            msg.sender,
            _tokenId,
            _amount,
            ""
        );

        emit NFTClaim(_nft, msg.sender, abi.encodePacked(_tokenId), _amount);
        userSigned[msg.sender][signature] = true;
        return _tokenId;
    }


    function getDepositedNFTs(address _nft, address _user)
    external
    view
    returns (uint256[] memory depositeNFTs)
    {
        return nftUserInfo[_nft][_user].depositedTokenIds;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    require(c / a == b, 'SafeMath: multiplication overflow');

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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
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
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
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
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        
        _notEntered = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the SellToken standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IVerifySignature {
  
  function verify( address _signer, address _to, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) 
  external view returns (bool);
  
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the SellToken standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IUserCowsBoy {
  /**
   * @dev Returns the  info of user in existence.
   */
  function isRegister(address account) external view returns (bool);
  function getReff(address account) external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
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
pragma solidity ^0.6.12;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)
pragma solidity ^0.6.12;

import "./IERC165.sol"; 
/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
// 
/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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