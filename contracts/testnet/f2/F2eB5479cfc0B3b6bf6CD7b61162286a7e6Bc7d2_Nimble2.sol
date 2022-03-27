// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Transferable.sol";
import "./NbmHistory.sol";
import "./Rollback.sol";

contract Nimble2 is ERC721, Ownable, NbmHistory, Rollback {
    using Address for address;
    using Strings for uint256;

    // mapping tokens for account
    mapping(address => uint256[]) internal _tokensOfOwner;

    constructor() ERC721("Nimble", "NMB") {}

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ERC721.sol";

abstract contract Whitelistable is ERC721{
    using Address for address;
    using Strings for uint256;

    event Whitelist(uint256 tokenId, address indexed account, uint256 permission);

    // mapping who can see the asset
    mapping(uint256 => mapping(address => uint256)) internal _whitelist;

    // mapping token blocked
    mapping(uint256 => bool) private _blocked;

    //------------------------------------------- Whitelist Functions ------------------------------------------
    // @todo clear whitelist before tranfer?
    // @todo create function to remove all whitelist
    /**
     * @dev Add Account to Whitelist
     *
     * Requirements:
     *
     * - `tokenId` must be minted
     * - `history Struct` must be correct
     *
     */
    function setWhitelist(uint256 tokenId, address account, uint256 permission) public {
        require(_exists(tokenId), "ACT1");
        require(ownerOf(tokenId) == _msgSender(), "History: Only Owner can add a History");
        _whitelist[tokenId][account] = permission;

        emit Whitelist(tokenId, account, permission);
    }

    /**
     * @dev Create History Item
     *
     * Requirements:
     *
     * - `tokenId` must be minted
     * - `history Struct` must be correct
     *
     */
    function getWhitelist(uint256 tokenId, address account) public virtual view returns(uint256) {
        require(_exists(tokenId), "ACT1");
        return _whitelist[tokenId][account];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ERC721.sol";

import "./AssetContract.sol";
import "./NbmUser.sol";
import "./Whitelistable.sol";

abstract contract Transferable is AssetContract {
    using Address for address;
    using Strings for uint256;

    /**
     * @dev Emitted when the transfer is started
     */
    event PreTransfer(uint256 transferId, uint256 tokenId, address indexed to, address indexed from, address indexed sender);

    /**
     * @dev Emitted when the transfer is started
     */
    event TokenTransfer(uint256 indexed transferId, uint256 indexed tokenId, TransactionStatus status, string message);

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account, uint256 indexed tokenId);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account, uint256 indexed tokenId);

    // mapping Transfer Id prepared transfers
    mapping(uint256 => TransferStruct) internal _transferPending;

    // mapping token => owners
    mapping(uint256 => address[]) internal _tokenOwners;

    // mapping if account was owner of token
    mapping(uint256 => mapping(address => bool)) internal _ownershipRight;

    // mapping TokenId => TransferId
    mapping(uint256 => uint256[]) internal _transferIds;

    // mapping token blocked
    mapping(uint256 => bool) internal _blocked;

    // mapping token rollback date
    mapping(uint256 => uint256[]) internal _rollbackDate;

    // Transfer Struct
    struct TransferStruct {
        address from;
        address to;
        address sender;
        string code;
        uint256 tokenId;
        string message;
        bool toAccept;
        bool fromAccept;
        uint256 finalDate;
        uint256 transferRollbackDate;
        address rejectedBy;
        TransactionStatus status;
    }

    // Enum of Status
    enum TransactionStatus{ PENDING, NACK, ACK, EXPIRED, ROLLBACK }

    /**
      * @dev Modifier to make a function callable only when the contract is not paused.
      *
      * Requirements:
      *
      * - The contract must not be paused.
      */
    modifier whenNotPaused(uint transferId) {
        require(!paused(transferId), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused(uint transferId) {
        require(paused(transferId), "Pausable: not paused");
        _;
    }

    //------------------------------------------- Transfer Functions ------------------------------------------
    // @todo add Stop Mint

    function getTokenOwners(uint256 tokenId) public view returns(address[] memory) {
        require(_exists(tokenId), "ACT1");
        return _tokenOwners[tokenId];
    }

    function isTokenOwner(uint256 tokenId, address account) public view returns(bool) {
        return _ownershipRight[tokenId][account];
    }

    function getWhitelist(uint256 tokenId, address account) public view override returns(uint256) {
        require(_exists(tokenId), "ACT1");

        if(isTokenOwner(tokenId, account)) {
            return uint256(2**256 - 1);
        }

        return _whitelist[tokenId][account];
    }

    /**
      * @dev get the transfer status
      *
      * Requirements:
      *
      * `_msgSender` must to be sender, to or from
      */
    function transferStatus(uint256 transferId) external view returns(TransferStruct memory){
        //require(_isToOrFrom(transferId), "NFT7"); // @todo add whitelist
        //require(_whitelist[_transferPending[transferId].tokenId][_msgSender()] > 0, 'NFT20'); //tALVEZ 18

        return _transferPending[transferId];
    }

    /**
      * @dev get the transfer ids of a token
      */
    function tokenTransfers(uint256 tokenId) external view returns(uint256[] memory){
        return _transferIds[tokenId];
    }

    /**
      * @dev prepare Transfer
      *
      * Requirements:
      *
      * `_msgSender()` cannot be 0 and must be allowed or Owner
      * `from` cannot be 0 and must be Owner
      * `to` cannot be 0 and cannot be Owner
      * `from` needs to be registered
      * `to` needs to be registered
      * `_msgSender()` needs to be registered
      *
      */
    function prepareTransfer(
        address from,
        address to,
        uint256 tokenId,
        string memory message,
        uint256 finalDate,
        uint256 rollbackDate,
        string memory code
    ) external {
        _usersAllowed(to, from, tokenId);

        uint256 time = block.timestamp + (finalDate * 1 days); //Set transfer expiration date
        uint256 transferId = _hashTransfer(to, from, tokenId); // Create Transfer hash

        _setRollbackDate(rollbackDate, time, tokenId); // Set rollbackDate

        _transferPending[transferId] = TransferStruct(from, to, _msgSender(), code, tokenId, message, false, false, time, rollbackDate, address(0), TransactionStatus.PENDING);
        _transferIds[tokenId].push(transferId);

        _pause(transferId); //blocked token

        emit PreTransfer(transferId, tokenId, to, from, _msgSender());
    }

    /**
      * @dev cancel the transfer if is expired
      *
      * Requirements:
      *
      * `tokenId` transaction must no to be valid
      */
    function cancelIfExpired(uint256 transferId) external whenPaused(_transferPending[transferId].tokenId) {
        require(_isApprovedOrOwner(_msgSender(), _transferPending[transferId].tokenId), "NFT2");

        if (!_isValid(_transferPending[transferId].tokenId)) {
            _resolveTransfer(transferId, "Transaction has expired and will be canceled", TransactionStatus.EXPIRED);
        }
    }

    /**
      * @dev accept the transfer
      *
      * Requirements:
      *
      * `_msgSender` must to be Owner, allowed ou receiver
      * `transaction' must be valid
      */
    function acceptTransfer(uint256 transferId) external whenPaused(transferId) {
        require(_isToOrFrom(transferId), "NFT7");
        require(_isValid(transferId), "NFT13");
        require(_transferPending[transferId].status == TransactionStatus.PENDING, "TRANSFERABLE: The transactions is not pending");

        if (_msgSender() == _transferPending[transferId].to) {
            _transferPending[transferId].toAccept = true;
        } else {
            _transferPending[transferId].fromAccept = true;
        }
    }

    /**
      * @dev reject Transfer
      *
      * Requirements:
      *
      * `_msgSender` must to be Owner, allowed ou receiver
      * `_msgSender' must be Owner or Allowed and not accept or be To and no Accept
      */
    function rejectTransfer(uint256 transferId, string memory message) external whenPaused(transferId) {
        require(
            (_isApprovedOrOwner(_msgSender(), _transferPending[transferId].tokenId) && !_transferPending[transferId].fromAccept) ||
            (_transferPending[transferId].to == _msgSender() && !_transferPending[transferId].toAccept),
            "NFT15");

        _transferPending[transferId].rejectedBy = _msgSender();
        _resolveTransfer(transferId, message, TransactionStatus.NACK);
    }

    /**
      * @dev send Transfer
      *
      * Requirements:
      *
      * `_msgSender` must to be Owner, allowed ou receiver
      * `to' must be Accept
      * `from' must be Accept
      * Transfer cannot be rejected
      */
    function sendTransfer(uint256 transferId) external whenPaused(transferId) {
        require(_isToOrFrom(transferId), "NFT7");
        require(_transferPending[transferId].toAccept, "NFT8");
        require(_transferPending[transferId].fromAccept, "NFT9");
        require(_notRejected(transferId), "NFT14");
        require(_transferPending[transferId].status == TransactionStatus.PENDING, "TRANSFERABLE: The transactions is not pending");

        uint256 tokenId = _transferPending[transferId].tokenId;
        address to = _transferPending[transferId].to;
        address from = _transferPending[transferId].from;

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, "");

        _tokenOwners[tokenId].push(from);

        _ownershipRight[tokenId][from] = true;

        _resolveTransfer(transferId, "Successful transfer", TransactionStatus.ACK);
    }

    /**
      * @dev create rollback date
      *
      * Requirements:
      *
      * @param from {address} Sender of NFT
      * @param to {address} Receiver of NFT
      * @param tokenId {uint256} NFT code
      * @return transfer hash {uint256}
      */
    function _hashTransfer(address from, address to, uint256 tokenId) internal pure returns(uint256) {
        bytes32 hash = keccak256(abi.encode(from, to, tokenId));

        return uint256(hash);
    }

    function _usersAllowed(address to, address from, uint256 tokenId) internal view returns(bool) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "NFT2"); // Quem envia a mensagem tem quer ser dono ou autorizado
        require(ownerOf(tokenId) == from, "NFT18" ); // From tem que ser o dono
        require(ownerOf(tokenId) != to, "NFT10"); // To nao pode ser o Dono

        require(_active[from], "NFT4"); // Tem que estar cadastrados
        require(getWhitelist(tokenId, to) > 0, "NTF20"); // Must be whitelisted
        require(_active[to], "NFT5"); // To must exist
        require(_active[_msgSender()], "NFT6"); // sender must exist

        return true;
    }

    /**
      * @dev check if transaction is not rejected
      *
      * @return bool
      */
    function _notRejected(uint256 transferId) whenPaused(transferId) internal view returns(bool) {
        return _transferPending[transferId].rejectedBy == address(0);
    }

    /**
      * @dev check is is owner of token or receiver
      *
      * Requirements:
      *
      * `rollbackDate` must be greater than time or 0 (no set)
      * `rollbackDate` must be smaller or equal than last `rollbackDate`
      *
      * @return bool
      */
    function _isToOrFrom(uint256 transferId) internal view returns(bool)  {
        require(_msgSender() != address(0), "NFT11");

        uint256 tokenId = _transferPending[transferId].tokenId;

        return _isApprovedOrOwner(_msgSender(), tokenId) || _transferPending[transferId].to == _msgSender();
    }

    /**
     * @dev check if is valid
     *
     * Requirements:
     *
     * `tokenId` check to or from is in the transaction
     *
     * return bool
     */
    function _isValid(uint256 transferId) internal view returns(bool) {
        require(_isToOrFrom(transferId), "NFT7");

        uint256 time = block.timestamp;

        if (time > _transferPending[transferId].finalDate) {
            return false;
        }

        return true;
    }

    /**
      * @dev create rollback date
      *
      * Requirements:
      *
      * `rollbackDate` must be greater than time or 0 (no set)
      * `rollbackDate` must be smaller or equal than last `rollbackDate`
      */
    function _setRollbackDate(uint256 rollbackDate, uint256 time, uint256 tokenId) internal {
        //@todo usar struct ao inves do mapping
        require(rollbackDate / 1000 > time || rollbackDate == 0, "NFT16"); // Rollback must be greater than time or 0

        uint len = _rollbackDate[tokenId].length;

        if (len > 0) {
            require(_rollbackDate[tokenId][len-1] > block.timestamp, "Transferable: The validity is expired");
            require(_rollbackDate[tokenId][len-1] >= rollbackDate, "NFT17");
        }

        if (rollbackDate > 0) {
            _rollbackDate[tokenId].push(rollbackDate);
        }
    }

    /**
      * @dev resolve the transfer
      *
      * return bool
      */
    function _resolveTransfer(uint256 transferId, string memory message, TransactionStatus status) internal {
        _unpause(transferId);

        _transferPending[transferId].status = status;

        emit TokenTransfer(transferId, _transferPending[transferId].tokenId, _transferPending[transferId].status, message);

    }


    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause(uint transferId) internal whenNotPaused(transferId) {
        // @todo must use tokenId
        _blocked[_transferPending[transferId].tokenId] = true;
        emit Paused(_msgSender(), _transferPending[transferId].tokenId);
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _unpause(uint transferId) internal whenPaused(transferId) {
        _blocked[_transferPending[transferId].tokenId] = false;
        emit Unpaused(_msgSender(), _transferPending[transferId].tokenId);
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused(uint transferId) public view  returns (bool) {
        return _blocked[_transferPending[transferId].tokenId];
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ERC721.sol";

import "./Transferable.sol";

abstract contract Rollback is Transferable {
    using Address for address;
    using Strings for uint256;

    /**
      * @dev return all rollback dates
      *
      * Requirements:
      *
      * - The token must exist
      * - Account cannot be 0
      * - Account cannot be a contract
      * - The account must be whitelisted
      */
    function _getRollbackDates(uint256 tokenId) public view returns(uint256[] memory) {
        address sender = _msgSender();

        require(sender != address(0), "Rollback: Account cannot be 0");
        require(!sender.isContract(), "Rollback: Cannot be a contract");
        require(getWhitelist(tokenId, sender) > 0 || _isApprovedOrOwner(_msgSender(), tokenId), "Rollback: Your account is not whitelisted");

        return _rollbackDate[tokenId];
    }

    /**
      * @dev Make the rollback action
      *
      * Requirements:
      *
      * - The token must exist
      * - Account cannot be 0
      * - Account cannot be a contract
      * - The account must be whitelisted
      */
    function rollback(uint256 tokenId) external {
        uint256[] memory transferList = _transferIds[tokenId];
        uint256 len = _transferIds[tokenId].length;

        for (uint256 i = len; i > 0; i--) {
            uint256 transferId = _getTransfer(tokenId, i-1);

            TransferStruct memory transfer = _transferPending[transferId];

            require(_isApprovedOrOwner(_msgSender(), tokenId) ||
                isTokenOwner(tokenId, _msgSender()),
                "Rollback: You are not allowed to request the return");

            //require(transfer.transferRollbackDate < block.timestamp, "Rollback: The return date has not yet been reached");

            if (transfer.transferRollbackDate < block.timestamp * 1000) {
                if (transfer.status == TransactionStatus.PENDING) {
                     _resolveTransfer(transferList[i-1], "Transaction has expired and will be canceled", TransactionStatus.EXPIRED);
                }

                if (transfer.status == TransactionStatus.ACK) {
                    _rollback(transferList[i-1], tokenId);
                }
            }


        }
    }

    /**
      * @dev Get transfer by position
      *
      * Requirements:
      *
      * - the position cannot be bigger than length
      * - The sender must be to or from, or whitelisted
      */
    function _getTransfer(uint256 tokenId, uint256 deep) internal view returns(uint256){
        uint256 len = _transferIds[tokenId].length;

        require(deep <= len, "Rollback: Panic - negative overflow");

        uint256 transferId = _transferIds[tokenId][deep];

        require(_isToOrFrom(transferId) || getWhitelist(tokenId, _msgSender()) > 0 , "NFT19");

        return transferId;
    }

    /**
     * @dev rollback the transfer
     */
    function _rollback(uint256 transferId, uint256 tokenId) internal {
        address to = _transferPending[transferId].from;
        address from = _transferPending[transferId].to;

        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _transferPending[transferId].status = TransactionStatus.ROLLBACK;

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        _rollbackDate[tokenId].pop();
        _tokenOwners[tokenId].pop();
        _ownershipRight[tokenId][from] = false;

        emit Transfer(from, to, tokenId);

        emit TokenTransfer(transferId, tokenId, TransactionStatus.ROLLBACK, "Token Rollback");
    }

    /**_rollbackDate[tokenId]
  *
  *
function _getLastTransaction(uint256 tokenId) internal view returns(uint256) {
    uint256 len = _transferIds[tokenId].length;
    uint256 transferId = _transferIds[tokenId][len - 1];

    require(_isToOrFrom(transferId) || getWhitelist(tokenId, _msgSender()) > 0 , "NFT19");

    return transferId;
}

function _rollback(uint256 tokenId) external returns(bool) {
    uint256 transferId = _getLastTransaction(tokenId);
    TransferStruct memory transfer = _transferPending[transferId];

    require(transfer.status == TransactionStatus.ACK, "Not ACK");
    require(_isToOrFrom(transferId), "NFT7");

    if (transfer.transferRollbackDate > block.timestamp) {
        transfer.status = TransactionStatus.ROLLBACK;
        _rollbackTransfer(transferId);
        return true;
    }
    else {
        return false;
    }
}*/

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ERC721.sol";

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract NbmUser is Context, Ownable {
    using Address for address;
    using Strings for uint256;

    event CreateUser(address indexed account, address indexed sender, string name, string residence);

    // mapping User data
    mapping(address => UserData) private _users;

    // mapping User status
    mapping(address => uint256) private _status;

    // mapping User active
    mapping(address => bool) internal _active;

    address[] private _userPending;

    address[] private _approvedUsers;

    struct UserData {
        string name;
        string residence;
    }

    /**
      * @dev get User Status
      */
    function getStatus(address account) external view returns(uint256) {
        return _getStatus(account);
    }

    /**
      * @dev bool if user is active
      */
    function isActive(address account) external view returns(bool) {
        require(_userExists(account), "USER: Must exist");

        return _active[account];
    }

    /**
      * @dev return user pending list
      */
    function userPendingList() external view onlyOwner returns(address[] memory){
        return _userPending;
    }

    /**
      * @dev Get User onChain
      *
      * Requirements:
      *
      * - user must exist
      *
      */
    function getUser(address account) public view returns(UserData memory) {
        require(_userExists(account), "USER: Must exist");
        return _users[account];
    }

    /**
     * @dev Create an User
     * by contract Owner
     *
     * Requirements:
     *
     * - `user` must have all information
     *
     */
    function proxyCreateUser(address account, UserData memory user) external onlyOwner {
        require(!account.isContract(), "USER: Sender can not be a contract!" );

        _create(account, user);
    }

    /**
     * @dev Owner can change account status
     *
     * Requirements:
     *
     * - user must exist
     */
    function changeStatus(address account, uint256 status) external onlyOwner {
        require(_userExists(account), "USER: Must exist");

        _status[account] = status;
    }

    /**
     * @dev Owner can change account active
     *
     * Requirements:
     *
     * - user must exist
     */
    function toggleActivity(address account, bool active) external onlyOwner {
        require(_userExists(account), "USER: Must exist");

        _active[account] = active;
    }


    /**
     * @dev Owner can approve User
     *
     * Requirements:
     *
     * - user must exist
     */
    function approveUser(address account) external onlyOwner {
        _removeByValue(account);

        _status[account] = 1;
        _active[account] = true;

        _approvedUsers.push(account);
    }

    /**
     * @dev Owner can reject User
     *
     * Requirements:
     *
     * - user must exist
     */
    function rejectUser(address account) external onlyOwner {
        _removeByValue(account);
    }

    /**
     * @dev Create an User
     * The user creates its own account
     *
     * Requirements:
     *
     * - `user` must have all information
     *
     */
    function createUser(UserData memory user) external {
        address account = _msgSender();
        require(!account.isContract(), "USER: Sender can not be a contract!" );

        _create(account, user);
    }

    /**
      * @dev Get User
      *
      * Requirements:
      *
      * `account` cannot be 0
      *
      */
    function _userExists(address account) internal view virtual returns (bool) {
        require(account != address(0), "USER: Address can not be 0");
        return (bytes(_users[account].name).length != bytes('').length);
    }

    /**
     * @dev Create an User
     *
     * Requirements:
     *
     * - `account` cannot be 0
     * - `user` must have all information
     *
     */
    function _create(address account, UserData memory user) internal {
        require(account != address(0), "USER: Address can not be 0");
        _users[account] = user;
        _userPending.push(account);

        address sender = _msgSender();

        emit CreateUser(account, sender, user.name, user.residence);
    }

    function _getStatus(address account) internal view returns(uint256) {
        return _status[account];
    }

    function _find(address value) internal view returns(uint256) {
        uint256 i = 0;
        while (_userPending[i] != value) {
            i++;
        }
        return i;
    }

    function _removeByValue(address value) internal {
        uint256 i = _find(value);
        _removeByIndex(i);
    }

    function _removeByIndex(uint256 i) internal  {
        while (i<_userPending.length-1) {
            _userPending[i] = _userPending[i+1];
            i++;
        }
        _userPending.pop();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ERC721.sol";

abstract contract NbmHistory is ERC721 {
    using Address for address;
    using Strings for uint256;

    event addHistory(address indexed sender, uint256 tokenId, string date, string note);

       // mapping asset historic
    mapping(uint256 => History[]) private _history;

    // History Struct
    struct History {
        string date;
        string note;
    }

    // @todo event change history (put, remove)
    // @todo editar / remover historico (EVENTO)

    /**
     * @dev Create History Item
     *
     * Requirements:
     *
     * - `tokenId` must be minted
     * - `history Struct` must be correct
     *
     */
    function setHistory(uint256 tokenId, History memory historyItem) public {
        require(_exists(tokenId), "ACT1");
        require(ownerOf(tokenId) == _msgSender(), "History: Only Owner can add a History");
        _history[tokenId].push(historyItem);

        address sender = _msgSender();

        emit addHistory(sender, tokenId, historyItem.date, historyItem.note);
    }

    /**
     * @dev Get History Item
     *
     * Requirements:
     *
     * - `tokenId` must be minted
     *
     */
    function getHistory(uint256 tokenId) public view returns(History[] memory) {
        require(_exists(tokenId), "ACT1");
        return _history[tokenId];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _owners;

    // Mapping owner address to token count
    mapping(address => uint256) internal _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
    * @dev See {IERC721Metadata-tokenURI}.
    */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(false, "ECR721: Method not allowed");
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(false, "ECR721: Method not allowed");
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(false, "ECR721: Method not allowed");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721.sol";

import "./Whitelistable.sol";
import "./NbmUser.sol";

abstract contract AssetContract is ERC721, Whitelistable, NbmUser {
    using Strings for uint256;

    /**
     * @dev Emitted when `asset` is attached to token
     */
    event AttachInfo(uint256 indexed tokenId, Asset asset, address indexed sender, string code);

    // mapping token info
    mapping(uint256 => Asset) private _tokenInfo;

    struct Asset {
        string name; // from custody
        string code; // from custody
        uint256 value; // from custody
        string currency; // from custody
        address bankCustody; //out
        string bankClient; //from custody
        string bankClientName; // out
        string bankClientDocument; //out
        string description; // out
        string additionalInfo; //out
        string securityHouse; //out
        uint256 createdAt; //from custody
        string callbackUrl;
    }

    /**
     * @dev Mint an Asset
     *
     * Requirements:
     *
     * - `to` must be minted
     * - `Asset Struct` must be correct
     *
     */
    function mintAsset(address to, Asset memory asset) external {
        require(_active[_msgSender()], "ASSET: User must be active");

        uint256 tokenId = uint256(_hashToken(asset));
        _safeMint(to, tokenId);
        _createAsset(tokenId, asset);
    }

    function _hashToken(Asset memory asset) internal pure returns(uint256) {
        bytes32 assetSeparator = keccak256(
            abi.encode(asset.name, keccak256(bytes(asset.code)))
        );

        bytes32 valueSeparator = keccak256(
            abi.encode(asset.value.toString(), asset.currency)
        );

        bytes32 senderSeparator = keccak256(
            abi.encode(asset.bankCustody, asset.bankClient)
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                assetSeparator,
                valueSeparator,
                senderSeparator
            )
        );

        return uint256(digest);
    }

    /**
     * @dev Create info for minted Token
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     * - `asset` needs to be correct.
     *
     * Emits a {AttachInfo} event.
     */
    function _createAsset(uint256 tokenId, Asset memory asset) internal virtual {
        require(_exists(tokenId), "ASSET: The token do not exist");
        require(_assetValidator(asset), "ASSET: Asset data is not valid");

        _tokenInfo[tokenId] = asset;

        emit AttachInfo(tokenId, asset, _msgSender(), asset.code);
    }

    /**
     * @dev get info from the Token
     *
     * - `tokenId` must exist.
     * - `tokenId`must be mapping
     *
     */
    function getAsset(uint256 tokenId) public view virtual returns(Asset memory) {
        require(_exists(tokenId), "ASSET: The token do not exist");

        return _tokenInfo[tokenId];
    }

    /**
     * @dev validate the asset info
     *
     * - `asset` must be correct
     */
    function _assetValidator(Asset memory asset) internal pure virtual returns(bool){
        require(bytes(asset.name).length > 0, "ASSET: Name is wrong");

        return true;
    }

    function _isOwner(uint256 tokenId) internal view returns(bool) {
        require(_isApprovedOrOwner(_msgSender(), tokenId) || getWhitelist(tokenId, _msgSender()) > 0, "NFT21" );
        return true;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}