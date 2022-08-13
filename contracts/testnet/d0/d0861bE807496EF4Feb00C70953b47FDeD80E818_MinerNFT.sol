// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IMinerNFT.sol";
import "./ERC721Base.sol";

contract MinerNFT is ERC721Base, OwnableUpgradeable, IMinerNFT, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 lastMinerId;
    address municipalityAddress;

    modifier onlyMunicipality() {
        require(msg.sender == municipalityAddress, "Only municipality is allowed to mint");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(string memory _tokenBaseURI, address _municipalityAddress, uint256 _maxSupply)
        external
        initializer
    {
        __Ownable_init();
        __ReentrancyGuard_init();
        municipalityAddress = _municipalityAddress;
        _name = "MinerV1";
        _symbol = "MV1";
        _baseURI = _tokenBaseURI;
        _setMaxSupply(_maxSupply);
    }


    function setTransferActivation(bool _transferActivation) external onlyOwner {
        _setTransferActivation(_transferActivation);
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        _setMaxSupply(_maxSupply);
    }


    /// @notice IMinerNFT interface methods
    function mint(address user) external onlyMunicipality returns (uint256) {
        _mintFor(++lastMinerId, user);
        return lastMinerId;
    }

    function hashrate() external pure returns (uint256) {
        return 1000;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IMinerNFT {
    function mint(address) external returns (uint256);
    function hashrate() external pure returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interfaces/IERC721Base.sol";
import "../interfaces/IERC721TokenReceiver.sol";

contract ERC721Base is IERC721Base {
    /// @dev This contract uses SafeMath library functionality with type
    using SafeMath for uint256;

    /// @dev Calculated by "bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))"
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    /// @dev Id of the ERC165 interface
    bytes4 private constant InterfaceId_ERC165 = 0x01ffc9a7;

    /// @dev Id of the ERC721 interface
    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

    string internal _name;

    string internal _symbol;

    string internal _baseURI;

    /// @dev Amount of nft tokens in circulation
    uint256 internal _tokensCount;

    uint256 internal _maxSupply;

    bool internal _isTransferActive;

    /// @dev Index of the token inside owner's tokens array
    mapping(uint256 => uint256) internal _indexOfToken;

    /// @dev Reflets weather token is locked
    mapping(uint256 => bool) internal _isLocked;

    /// @dev Reflects owner of a token
    mapping(uint256 => address) internal _tokenOwner;

    /// @dev Reflects operator of a token
    mapping(uint256 => address) internal _tokenOperator;

    /// @dev Array of the user's tokens in holding
    mapping(address => uint256[]) internal _userTokens;

    /// @dev Reflects weather an address can operate all of the user's tokens
    mapping(address => mapping(address => bool)) internal _operatorForAll;

    mapping(address => uint256) public _userPurchaseDate;

    /// @dev Modifier that reverts if caller is not authorized for given token
    modifier onlyAuthorized(uint256 _tokenId) {
        require(
            _isAuthorized(msg.sender, _tokenId),
            "ERC721Base: You are not authorized to call this function"
        );
        _;
    }

    /// @dev Modifier that reverts if token is locked
    modifier onlyUnlockedToken(uint256 _tokenId) {
        require(!_isLocked[_tokenId], "ERC721Base: This token is locked and can not be used");
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function baseURI() external view returns (string memory) {
        return _baseURI;
    }

    /**
     * @notice Returns weather contract supports fiven interface
     * @dev This contract supports ERC165 and ERC721 interfaces
     * @param _interfaceId id of the interface which is checked to be supported
     * @return true - given interface is supported, false - given interface is not supported
     */
    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        return _interfaceId == InterfaceId_ERC165 || _interfaceId == InterfaceId_ERC721;
    }

    /// @notice Total amount of nft tokens in circulation
    function totalSupply() external view returns (uint256) {
        return _tokensCount;
    }

    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @notice Gives the number of nft tokens that a given user owns
     * @param _owner address of the user who's token's count will be returned
     * @return amount of tokens given user owns
     */
    function balanceOf(address _owner) external view returns (uint256) {
        return _userTokens[_owner].length;
    }

    function tokensOf(address _owner) external view returns (uint256[] memory) {
        return _userTokens[_owner];
    }

    /**
     * @notice Tells weather a token exists
     * @param _tokenId id of the token who's existence is returned
     * @return true - exists, false - does not exist
     */
    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint256 _tokenId) external view returns (bool) {
        return _isLocked[_tokenId];
    }

    /**
     * @notice Gives owner address of a given token
     * @param _tokenId id of the token who's owner address is returned
     * @return address of the given token owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _ownerOf(_tokenId);
    }

    /**
     * @notice Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function getApproved(uint256 _tokenId) external view returns (address) {
        return _getApproved(_tokenId);
    }

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId) external view returns (bool) {
        return _isAuthorized(_operator, _tokenId);
    }

    /**
     * @notice Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _isApprovedForAll(_owner, _operator);
    }

    function getUserPurchaseTime(address _user) external view returns (uint256[2] memory) {
        uint256 _time = uint256(_userPurchaseDate[_user]);
        return [_time, _time + 30 days];
    }

    /**
     * @notice Approves an address to use given token
     *         Only authorized users can call this function
     * @dev Only one user can be approved at any given moment
     * @param _approved address of the user who gets approved
     * @param _tokenId id of the token the given user get aproval on
     */
    function approve(address _approved, uint256 _tokenId) external onlyAuthorized(_tokenId) {
        require(
            _approved != _tokenOperator[_tokenId],
            "ERC721Base: Address is already an operator"
        );
        _tokenOperator[_tokenId] = _approved;
        emit Approval(_tokenOwner[_tokenId], _approved, _tokenId);
    }

    /**
     * @notice Approves or disapproves an address to use all tokens of the caller
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    function setApprovalForAll(address _operator, bool _approved) external {
        require(
            _operatorForAll[msg.sender][_operator] != _approved,
            "ERC721Base: Address already has this approval status"
        );
        _operatorForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes "_data" from this function arguments
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external {
        _transferToken(_from, _to, _tokenId, _data, true);
    }

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes an empty string for "data" parameter
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        _transferToken(_from, _to, _tokenId, "", true);
    }

    /**
     * @notice Transfers token without checking weather it was recieved
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev Does not call "onERC721Received" function even if the reciver is ERC721TokenReceiver
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        _transferToken(_from, _to, _tokenId, "", false);
    }

    function _setName(string memory _newName) internal {
        _name = _newName;
    }

    function _setSymbol(string memory _newSymbol) internal {
        _symbol = _newSymbol;
    }

    function _setBaseURI(string memory _newBaseURI) internal {
        _baseURI = _newBaseURI;
    }

    /**
     * @dev Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function _isAuthorized(address _operator, uint256 _tokenId) internal view returns (bool) {
        require(_operator != address(0), "ERC721Base: Operator address can not be address 0");
        address tokenOwner = _tokenOwner[_tokenId];
        return
            _operator == tokenOwner ||
            _isApprovedForAll(tokenOwner, _operator) ||
            _getApproved(_tokenId) == _operator;
    }

    function _mintFor(uint256 _tokenId, address _owner) internal {
        require(_tokensCount + 1 <= _maxSupply, "ERC721Base: Max supply reached");
        require(_tokenOwner[_tokenId] == address(0), "ERC721Base: Token has already been minted");
        _addTokenTo(_owner, _tokenId);
        emit Transfer(address(0), _owner, _tokenId);
    }

    function _setTransferActivation(bool _transferActivation) internal {
        _isTransferActive = _transferActivation;
    }

    function _setMaxSupply(uint256 _supply) internal {
        _maxSupply = _supply;
    }

    /**
     * @dev Adds or removes locking on given token
     *         Locked tokens can not be transfered by anyone
     * @param _tokenId token which will be locked or unlocked
     * @param _lock true- lock the token, false - unlock the token
     */
    function _changeTokenLocking(uint256 _tokenId, bool _lock) internal {
        require(
            _isLocked[_tokenId] != _lock,
            "ERC721Base: This token already has this locking status"
        );
        _isLocked[_tokenId] = _lock;
        emit LockStatusSet(_tokenId, _lock);
    }

    /**
     * @dev Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function _isApprovedForAll(address _owner, address _operator) internal view returns (bool) {
        return _operatorForAll[_owner][_operator];
    }

    /**
     * @dev Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function _getApproved(uint256 _tokenId) internal view returns (address) {
        return _tokenOperator[_tokenId];
    }

    /**
     * @dev This function is called from all the different transfer functions
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function _transferToken(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data,
        bool _check
    ) internal onlyAuthorized(_tokenId) onlyUnlockedToken(_tokenId) {
        require(_isTransferActive, "ERC721Base: Transfers are deactivated now");
        require(_to != address(0), "ERC721Base: Can not transfer to address 0");
        address tokenOwner = _tokenOwner[_tokenId];
        require(_to != tokenOwner, "ERC721Base: Can not transfer token to its owner");
        require(_from == tokenOwner, "ERC721Base: Address from does not match token owner");

        _resetApproval(_tokenId);
        _removeTokenFrom(_from, _tokenId);
        _addTokenTo(_to, _tokenId);
        emit Transfer(tokenOwner, _to, _tokenId);

        if (_check && _isContract(_to)) {
            require(
                IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) ==
                    ERC721_RECEIVED,
                "ERC721Base: Token was not received"
            );
        }
    }

    /**
     * @dev Resets approval of the given token
     * @param _tokenId id of the tokens who's approval will be resetn
     */
    function _resetApproval(uint256 _tokenId) private {
        _tokenOperator[_tokenId] = address(0);
        emit Approval(_tokenOwner[_tokenId], address(0), _tokenId);
    }

    /**
     * @dev Removes given token from the given addrese's ownership
     * @param _from address of the user from whom the token will be removed
     * @param _tokenId id of the tokens that will be removed
     */
    function _removeTokenFrom(address _from, uint256 _tokenId) internal {
        uint256 tokenIndex = _indexOfToken[_tokenId];
        uint256 lastTokenIndex = _userTokens[_from].length.sub(1);
        uint256 lastTokenId = _indexOfToken[lastTokenIndex];

        _userTokens[_from][tokenIndex] = lastTokenId;
        _indexOfToken[lastTokenId] = tokenIndex;
        _userTokens[_from].pop();

        _tokenOwner[_tokenId] = address(0);
        _tokensCount = _tokensCount.sub(1);

        if (_userTokens[_from].length == 0) {
            delete _userTokens[_from];
        }
    }

    /**
     * @dev Sets given address as owner for the given token
     * @param _to address to which token will be tranfered
     * @param _tokenId id of the tokens that will be transfered
     */
    function _addTokenTo(address _to, uint256 _tokenId) internal {
        _tokenOwner[_tokenId] = _to;
        _userTokens[_to].push(_tokenId);
        _indexOfToken[_tokenId] = _userTokens[_to].length;
        _tokensCount = _tokensCount.add(1);
        _userPurchaseDate[_to] = block.timestamp;
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        return _tokenOwner[_tokenId];
    }

    function _exists(uint256 _tokenId) internal view returns (bool) {
        return _tokenOwner[_tokenId] != address(0);
    }

    /**
     * @dev Tells weather given address is contract or not
     * @param _to address which will be checked to be contract address
     * @return true - is a contract address, false - is not a contract address
     */
    function _isContract(address _to) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_to)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

import "./IERC165.sol";
import "./IERC721Lockable.sol";
import "./IERC721Metadata.sol";

pragma solidity ^0.8.15;

interface IERC721Base is IERC165, IERC721Lockable, IERC721Metadata {
    /**
     * @dev This event is emitted when token is transfered
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /**
     * @dev This event is emitted when user is approved for token
     * @param _owner address of the owner of the token
     * @param _approval address of the user who gets approved
     * @param _tokenId id of the token that gets approved
     */
    event Approval(address indexed _owner, address indexed _approval, uint256 indexed _tokenId);

    /**
     * @dev This event is emitted when an address is approved/disapproved for another user's tokens
     * @param _owner address of the user whos tokens are being approved/disapproved to be used
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Total amount of nft tokens in circulation
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gives the number of nft tokens that a given user owns
     * @param _owner address of the user who's token's count will be returned
     * @return amount of tokens given user owns
     */
    function balanceOf(address _owner) external view returns (uint256);

    /**
     * @notice Tells weather a token exists
     * @param _tokenId id of the token who's existence is returned
     * @return true - exists, false - does not exist
     */
    function exists(uint256 _tokenId) external view returns (bool);

    /**
     * @notice Gives owner address of a given token
     * @param _tokenId id of the token who's owner address is returned
     * @return address of the given token owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address);

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes "_data" from this function arguments
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external;

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes an empty string for "data" parameter
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Transfers token without checking weather it was recieved
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev Does not call "onERC721Received" function even if the reciver is ERC721TokenReceiver
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Approves an address to use given token
     *         Only authorized users can call this function
     * @dev Only one user can be approved at any given moment
     * @param _approved address of the user who gets approved
     * @param _tokenId id of the token the given user get aproval on
     */
    function approve(address _approved, uint256 _tokenId) external;

    /**
     * @notice Approves or disapproves an address to use all tokens of the caller
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
     * @notice Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function getApproved(uint256 _tokenId) external view returns (address);

    /**
     * @notice Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId) external view returns (bool);

    /// @notice Returns the purchase date for this NFT
    function getUserPurchaseTime(address _user) external view returns (uint256[2] memory);

    /// @notice Returns all the token IDs belonging to this user
    function tokensOf(address _owner) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC721TokenReceiver {
    /**
     * @notice Returns data which is used to understand weather contract has recived given token
     * @param _operator address of the operator
     * @param _from address of the token owner
     * @param _tokenId id of the token for which was transfered
     * @param _data additional data with no specific format
     * @return Returns `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
     */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC165 {
    /**
     * @notice Returns weather contract supports fiven interface
     * @dev This contract supports ERC165 and ERC721 interfaces
     * @param _interfaceId id of the interface which is checked to be supported
     * @return true - given interface is supported, false - given interface is not supported
     */
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC721Lockable {
    /**
     * @dev Event that is emitted when token lock status is set
     * @param _tokenId id of the token who's lock status is set
     * @param _lock true - is locked, false - is not locked
     */
    event LockStatusSet(uint256 _tokenId, bool _lock);

    /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint256 _tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function baseURI() external view returns (string memory);
}