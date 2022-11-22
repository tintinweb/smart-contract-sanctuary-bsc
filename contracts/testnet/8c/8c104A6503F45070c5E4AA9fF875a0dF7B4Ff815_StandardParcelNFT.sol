// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IParcelInterface.sol";
import "./ERC721Base.sol";
import "../Municipality.sol";

contract StandardParcelNFT is
    ERC721Base,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 constant PARCEL_TYPE = 10;

    address public municipalityAddress;
    address public minerPublicBuilding;
    mapping(uint256 => bool) private upgradedParcelsMapping;

    uint8 private constant PARCEL_LAND_TYPE_NEXT_TO_OCEAN = 10;
    uint8 private constant PARCEL_LAND_TYPE_NEAR_OCEAN = 20;
    uint8 private constant PARCEL_LAND_TYPE_INLAND = 30;

    event TransferActivationSet(bool indexed transferActivation);
    event MaxSupplySet(uint256 indexed amount);
    event MunicipalityAddressSet(address indexed municipalityAddress);
    event MinerPublicBuildingSet(address indexed minerPublicBuildingAddress);
    event StandardParcelUpgraded(address indexed user, uint256 indexed parcelId);

    modifier onlyAuthorizedContracts() {
        require(minerPublicBuilding == msg.sender || msg.sender == municipalityAddress, "MinerNFT: Only authorized contracts can call this function");
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
        _name = "StandardParcel";
        _symbol = "SP";
        _baseURI = _tokenBaseURI;
        _setMaxSupply(_maxSupply);
    }

    function setTransferActivation(bool _transferActivation) public onlyOwner {
        _setTransferActivation(_transferActivation);
        emit TransferActivationSet(_transferActivation);
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        _setMaxSupply(_maxSupply);
        emit MaxSupplySet(_maxSupply);
    }

    function setMunicipalityAddress(address _municipalityAddress) external onlyOwner {
        municipalityAddress = _municipalityAddress;
        emit MunicipalityAddressSet(municipalityAddress);
    }

    function setMinerPublicBuildingAddress(address _minerPublicBuilding) external onlyOwner {
        minerPublicBuilding = _minerPublicBuilding;
        emit MinerPublicBuildingSet(minerPublicBuilding);
    }

    /// @notice IParcelInterface functions
    function mint(address _user, uint256 _x, uint256 _y, uint256 _lt) public onlyAuthorizedContracts returns (uint256) {
        uint256 parcelId = _getParcelId(_x, _y, _lt);
        require(!_exists(parcelId), "StandardParcelNFT: Parcel already exists as a standard parcel");
        _mintFor(parcelId, _user);
        return parcelId;
    }

    function upgradeParcel(uint256 tokenId) external onlyAuthorizedContracts  {
        upgradedParcelsMapping[tokenId] = true;
        emit StandardParcelUpgraded(msg.sender, tokenId);
    }
    function upgradeParcels(uint256[] memory tokenIds) external onlyAuthorizedContracts  {
        for(uint256 i = 0; i < tokenIds.length; ++i) {
            upgradedParcelsMapping[tokenIds[i]] = true;
            emit StandardParcelUpgraded(msg.sender, tokenIds[i]);
        }
    }

    function parcelExists(uint256 _x, uint256 _y, uint256 _lt) external view returns(bool) {
        return _parcelExists(_x, _y, _lt);
    }

    function getParcelId(uint256 _x, uint256 _y, uint256 _lt) external pure returns (uint256) {
        return _getParcelId(_x, _y, _lt);
    }

    function isParcelUpgraded(uint256 tokenId) external view returns (bool) {
        return upgradedParcelsMapping[tokenId];
    }

    function getParcelInfo(uint256 token)  public pure returns (uint256, uint256, uint256, uint256) { //private pure
        uint256 x = token & 65535;
        uint256 y = (token >> 16) & 65535;
        uint256 pt = (token >> 32) & 255;
        uint256 lt = token >> 40;
        return (x, y, pt, lt);
    }

    // Private interface
    function _getParcelId(uint256 _x, uint256 _y, uint256 _lt) private pure returns (uint256) {
        uint256 token = _lt;
        token = (token << 8) | PARCEL_TYPE;
        token = (token << 16) | _y;
        token = (token << 16) | _x;
        return token;
    }

    function _parcelExists(uint256 _x, uint256 _y, uint256 _lt) private view returns(bool) {
        uint256 parcelId = _getParcelId(_x, _y, _lt);
        return _exists(parcelId);
    }

    function mintParcels(address _user, Municipality.Parcel[] calldata parcels) external onlyAuthorizedContracts returns(uint256[] memory) {
        uint256[] memory parcelIds = new uint256[](parcels.length);
        for (uint256 i = 0; i < parcels.length; ++i) {
            Municipality.Parcel memory parcel = parcels[i];
            require(
                parcel.parcelLandType == PARCEL_LAND_TYPE_NEXT_TO_OCEAN ||
                    parcel.parcelLandType == PARCEL_LAND_TYPE_NEAR_OCEAN ||
                    parcel.parcelLandType == PARCEL_LAND_TYPE_INLAND,
                "Municipality: Invalid parcel land type"
            );
            uint256 parcelId = mint(
                _user,
                parcel.x,
                parcel.y,
                parcel.parcelLandType
            );
            parcelIds[i] = parcelId;
        }
        return parcelIds;
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

pragma solidity ^0.8.0;

import "../Municipality.sol";

interface IParcelInterface {
    function mint(address user, uint256 x, uint256 y, uint256 landType) external returns (uint256);
    function parcelExists(uint256 x, uint256 y, uint256 landType) external view returns(bool);
    function getParcelId(uint256 x, uint256 y, uint256 landType) external pure returns (uint256);
    function isParcelUpgraded(uint256 tokenId) external view returns (bool);
    function upgradeParcel(uint256 tokenId) external;
    function mintParcels(address _user, Municipality.Parcel[] calldata parcels) external returns(uint256[] memory);
    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external;
    function upgradeParcels(uint256[] memory tokenIds) external;
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
    // This mapping will not be used in the future, It is kept not to create a storage clash, in future it will be removed
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
    modifier onlyUnlockedToken(uint256 _tokenId) virtual {
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

    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external view {
        for (uint32 i = 0; i < nftIds.length; i++) {
            require(_ownerOf(nftIds[i]) == userWalletAddress, "ERC721Base: Invalid NFT owner");
        }
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
        uint256 lastTokenId = _userTokens[_from][_userTokens[_from].length - 1];

        _userTokens[_from][tokenIndex] = lastTokenId;
        delete _indexOfToken[_tokenId];
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
        _indexOfToken[_tokenId] = _userTokens[_to].length - 1;
        _tokensCount = _tokensCount.add(1);
        // _userPurchaseDate[_to] = block.timestamp;
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
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/ISignatureValidator.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IParcelInterface.sol";
import "./interfaces/IERC721Base.sol";
import "./interfaces/IMinerNFT.sol";
import "./interfaces/IMining.sol";

contract Municipality is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct Parcel {
        uint16 x;
        uint16 y;
        uint8 parcelLandType;
    }

    // Used to keep Parcel information
    struct ParcelInfo {
        bool isUpgraded;
        uint8 parcelType;
        uint8 parcelLandType;
        bool isValid;
    }

    struct SuperBundleInfo {
        uint256 parcelsAmount;
        uint256 minersAmount;
        uint256 upgradesAmount;
        uint256 discountPct;
    }

    struct ParcelsMintSignature {
        Parcel[] parcels;
        bytes[] signatures;
    }

    struct UserMintableNFTAmounts {
        uint256 parcels;
        uint256 miners;
        uint256 upgrades;
    }

    struct LastPurchaseData {
        uint256 lastPurchaseDate;
        uint256 expirationDate;
        uint256 dollarValue;
    }

    uint8 private constant PARCEL_TYPE_STANDARD = 10;

    uint8 private constant PARCEL_LAND_TYPE_NEXT_TO_OCEAN = 10;
    uint8 private constant PARCEL_LAND_TYPE_NEAR_OCEAN = 20;
    uint8 private constant PARCEL_LAND_TYPE_INLAND = 30;

    uint8 private constant BUNDLE_TYPE_SUPER_1 = 1;
    uint8 private constant BUNDLE_TYPE_SUPER_2 = 2;
    uint8 private constant BUNDLE_TYPE_SUPER_3 = 3;
    uint8 private constant BUNDLE_TYPE_SUPER_4 = 4;

    uint8 private constant PURCHASE_TYPE_BUSD = 10;
    uint8 private constant PURCHASE_TYPE_BUSD_METAVIE = 20;

    mapping(address => UserMintableNFTAmounts) public usersMintableNFTAmounts;
    mapping(address => uint256) public userToPurchasedAmountMapping;
    mapping(address => LastPurchaseData) public lastPurchaseData;
    mapping(address => uint256) public userToAvailableSlots;
    mapping(address => mapping(uint256 => uint256)) public userToMinerBalancesByLevel;

    /// @notice Pricing information (in BUSD)
    uint256 public parcelUpgradePrice;
    uint256 public minerUpgradePrice;
    uint256 public minerPrice;

	/// @notice Parcels pricing changes per percentage
    uint256 public currentlySoldStandardParcelsCount;

    /// @notice Addresses of Kabutocho smart contracts
    address public amountsDistributorAddress;
    address public signatureValidatorAddress;
    address public standardParcelNFTAddress;
    address public minerV1NFTAddress;
    address public metavieAddress;
    address public miningAddress;
    address public routerAddress;
    address public wbnbAddress;
    address public busdAddress;

    /// @notice Parcel <=> Miner attachments and Parcel/Miner properties
    uint8 public standardParcelSlotsCount;
    uint8 public upgradedParcelSlotsCount;

    /// @notice Indicator if the sales can happen
    bool public isSaleActive;

    SuperBundleInfo[4] public superBundlesInfos;
    
    // ------------------------------------ EVENTS ------------------------------------ //

    event SuperBundlesSet(SuperBundleInfo[4] indexed bundles);
    event ParcelsSlotsCountSet(
        uint8 indexed standardParcelSlotsCount,
        uint8 indexed upgradedParcelSlotsCount
    );
    event PurchasePricesSet(
        uint256 parcelUpgradePrice,
        uint256 minerUpgradePrice,
        uint256 minerPrice
    );
    event SaleActivationSet(bool indexed saleActivation);
    event BundlePurchased(address indexed user, uint256 indexed bundleType);
    event SuperBundlePurchased(address indexed user, uint256 indexed bundleType);
    event StandardParcelUpgraded(address indexed user, uint256 indexed parcelId);
    event MinerUpgraded(address indexed user, uint256 indexed minerId, uint256 indexed level);
    event MinersUpgraded(address indexed user, uint256[] indexed minersIds, uint256[] indexed levels);
    event NFTContractAddressesSet(address[9] indexed _nftContractAddresses);

    /// @notice Modifier for 0 address check
    modifier notZeroAddress() {
        require(address(0) != msg.sender, "Municipality: Caller can not be address 0");
        _;
    }

    /// @notice Modifier not to allow sales when it is made inactive
    modifier onlySaleActive() {
        require(isSaleActive, "Municipality: Sale is deactivated now");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    receive() external payable {}

    fallback() external payable {}

    /// @notice Public interface

    /// @notice Set Super Bundles
    function setSuperBundles(SuperBundleInfo[4] calldata _bundles) external onlyOwner notZeroAddress {
        superBundlesInfos = _bundles;
        emit SuperBundlesSet(_bundles);
    }

    /// @notice Set contract addresses for all NFTs we currently have
    function setNFTContractAddresses(address[9] calldata _nftContractAddresses) external onlyOwner {
        standardParcelNFTAddress = _nftContractAddresses[0];
        minerV1NFTAddress = _nftContractAddresses[1];
        miningAddress = _nftContractAddresses[2];
        wbnbAddress = _nftContractAddresses[3];
        busdAddress = _nftContractAddresses[4];
        metavieAddress = _nftContractAddresses[5];
        signatureValidatorAddress = _nftContractAddresses[6];
        routerAddress = _nftContractAddresses[7];
        amountsDistributorAddress = _nftContractAddresses[8];
        emit NFTContractAddressesSet(_nftContractAddresses);
    }
    
    /// @notice Set the number of slots available for the miners for standard and upgraded parcels
    function setParcelsSlotsCount(uint8[2] calldata _parcelsSlotsCount) external onlyOwner {
        standardParcelSlotsCount = _parcelsSlotsCount[0];
        upgradedParcelSlotsCount = _parcelsSlotsCount[1];

        emit ParcelsSlotsCountSet(_parcelsSlotsCount[0], _parcelsSlotsCount[1]);
    }

    /// @notice Set the prices for all different entities we currently sell
    function setPurchasePrices(uint256[3] calldata _purchasePrices) external onlyOwner {
        parcelUpgradePrice = _purchasePrices[0];
        minerUpgradePrice = _purchasePrices[1];
        minerPrice = _purchasePrices[2];

        emit PurchasePricesSet(
            _purchasePrices[0],
            _purchasePrices[1],
            _purchasePrices[2]
        );
    }

    /// @notice Activate/Deactivate sales
    function setSaleActivation(bool _saleActivation) external onlyOwner {
        isSaleActive = _saleActivation;
        emit SaleActivationSet(_saleActivation);
    }

    // @notice (Purchase) Generic minting functionality for parcels, regardless the currency
    function mintParcels(ParcelsMintSignature memory _mintingSignature, uint8 _purchaseType)
        external
        onlySaleActive
        notZeroAddress
    {
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        uint256 parcelsLength = _mintingSignature.parcels.length;
        require(parcelsLength > 0, "Municipality: Can not mint 0 parcels");
        uint256[2] memory busdAndMetavie = _getUserPriceForParcels(msg.sender, parcelsLength, _purchaseType);
        if(busdAndMetavie[0] > 0) {
            if(busdAndMetavie[1] > 0) 
                _transferToContract(busdAndMetavie[1], metavieAddress);
            _transferToContract(busdAndMetavie[0], busdAddress);
            userToPurchasedAmountMapping[msg.sender] += busdAndMetavie[0] + busdAndMetavie[1];
            lastPurchaseData[msg.sender].dollarValue += busdAndMetavie[0] + busdAndMetavie[1];

            _lastPurchaseDateUpdate(msg.sender);
            usersMintableNFTAmounts[msg.sender].parcels = 0;
        } else 
            usersMintableNFTAmounts[msg.sender].parcels -= parcelsLength;
        _updateHashrateAfterParcelPurchase(msg.sender, parcelsLength * standardParcelSlotsCount);
        userToAvailableSlots[msg.sender] += parcelsLength * standardParcelSlotsCount;
        IParcelInterface(standardParcelNFTAddress).mintParcels(msg.sender, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += parcelsLength;
    }

    // @notice (Purchase) Mint the given amount of miners
    function mintMiners(uint256 _count, uint8 _purchaseType) external onlySaleActive notZeroAddress returns(uint256, uint256)
    {
        require(_count > 0, "Municipality: Can not mint 0 miners");
        uint256[2] memory busdAndMetavie = _getUserPriceForMiners(msg.sender, _count, _purchaseType);
        if(busdAndMetavie[0] > 0) {
            if(busdAndMetavie[1] > 0) 
                _transferToContract(busdAndMetavie[1], metavieAddress);
            _transferToContract(busdAndMetavie[0], busdAddress);
            userToPurchasedAmountMapping[msg.sender] += busdAndMetavie[0] + busdAndMetavie[1];
            lastPurchaseData[msg.sender].dollarValue += busdAndMetavie[0] + busdAndMetavie[1];
            _lastPurchaseDateUpdate(msg.sender);
            usersMintableNFTAmounts[msg.sender].miners = 0;
        } else {
            usersMintableNFTAmounts[msg.sender].miners -= _count;
        }
        userToMinerBalancesByLevel[msg.sender][0] += _count;
        _updateHashrateAfterMinerPurchase(msg.sender,_count);
        return IMinerNFT(minerV1NFTAddress).mintMiners(msg.sender, _count);
    }
    function purchaseSuperBundle(uint8 _bundleType, uint8 _purchaseType) external onlySaleActive notZeroAddress
    {
        _validateSuperBundleType(_bundleType);
        SuperBundleInfo memory bundle = superBundlesInfos[_bundleType - BUNDLE_TYPE_SUPER_1];
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        uint256[2] memory busdAndMetavie = _getPriceForSuperBundle(_bundleType,_purchaseType);
        if(busdAndMetavie[1] > 0) 
            _transferToContract(busdAndMetavie[1], metavieAddress);
        _transferToContract(busdAndMetavie[0], busdAddress);
        userToPurchasedAmountMapping[msg.sender] += busdAndMetavie[0] + busdAndMetavie[1];
        lastPurchase.dollarValue += busdAndMetavie[0] + busdAndMetavie[1];
        _lastPurchaseDateUpdate(msg.sender);
        usersMintableNFTAmounts[msg.sender].parcels += bundle.parcelsAmount;
        usersMintableNFTAmounts[msg.sender].upgrades += bundle.upgradesAmount;
        usersMintableNFTAmounts[msg.sender].miners += bundle.minersAmount;
        emit SuperBundlePurchased(msg.sender, _bundleType);
    }

    // granting free Parcels to selected user 
    function grantParcels(ParcelsMintSignature calldata _mintingSignature,
     address _user) external onlyOwner {
        require(_mintingSignature.parcels.length <= 240, "Municipality: The amount of miners should be less or equal to 240");
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        _updateHashrateAfterParcelPurchase(msg.sender, _mintingSignature.parcels.length * (upgradedParcelSlotsCount - standardParcelSlotsCount));
        userToAvailableSlots[msg.sender] += _mintingSignature.parcels.length * (upgradedParcelSlotsCount - standardParcelSlotsCount);
        IParcelInterface(standardParcelNFTAddress).mintParcels(_user, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += _mintingSignature.parcels.length;
    }

    // granting free Miners to selected user
    function grantMiners(uint8 _minersAmount, address _user) external onlyOwner returns(uint256, uint256) {
        require(_minersAmount <= 240, "Municipality: The amount of miners should be less than or equal to 240");
        userToMinerBalancesByLevel[_user][0] += _minersAmount;
        _updateHashrateAfterMinerPurchase(msg.sender,_minersAmount);
        (uint256 firstMinerId, uint256 count) = IMinerNFT(minerV1NFTAddress).mintMiners(_user, _minersAmount);
        return (firstMinerId, count);
    }

    /// @notice Upgrade a group of standard parcels
    function upgradeStandardParcelsGroup(uint256[] memory _parcelIds, uint8 _purchaseType) external onlySaleActive {
        uint256 totalUpgradePrice = _parcelIds.length * parcelUpgradePrice;
        for(uint256 i = 0; i < _parcelIds.length; ++i) {
            require(
                IERC721Base(standardParcelNFTAddress).ownerOf(_parcelIds[i]) == msg.sender,
                "Municipality: Invalid NFT owner"
            );
            require(!IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelIds[i]),
                "Municipality: Parcel is already upgraded");
            if(usersMintableNFTAmounts[msg.sender].upgrades > 0) {
                usersMintableNFTAmounts[msg.sender].upgrades--;
                totalUpgradePrice -= parcelUpgradePrice;
            }
        }
        if(totalUpgradePrice > 0) {
            uint256 busdAmount = totalUpgradePrice;
            uint256 metavieAmount;
            if(_purchaseType == PURCHASE_TYPE_BUSD_METAVIE) {
                metavieAmount = busdAmount * _getMetaviePriceInBUSD() / 10 ether;
                busdAmount -= busdAmount / 10;
                _transferToContract(metavieAmount, metavieAddress);
            }
            _transferToContract(totalUpgradePrice, busdAddress);
            LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
            userToPurchasedAmountMapping[msg.sender] += totalUpgradePrice;
            lastPurchase.dollarValue += totalUpgradePrice;
            _lastPurchaseDateUpdate(msg.sender);
        }
        _updateHashrateAfterParcelPurchase(msg.sender, _parcelIds.length * (upgradedParcelSlotsCount - standardParcelSlotsCount));
        userToAvailableSlots[msg.sender] += _parcelIds.length * (upgradedParcelSlotsCount - standardParcelSlotsCount);
        IParcelInterface(standardParcelNFTAddress).upgradeParcels(_parcelIds);
    }

    /// @notice Upgrade the standard parcel
    function upgradeStandardParcel(uint256 _parcelId, uint8 _purchaseType) external onlySaleActive {
        require(
            IERC721Base(standardParcelNFTAddress).ownerOf(_parcelId) == msg.sender,
            "Municipality: Invalid NFT owner"
        );
        bool isParcelUpgraded = IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelId);
        require(!isParcelUpgraded, "Municipality: Parcel is already upgraded");
        uint256 amount = parcelUpgradePrice;
        if(_purchaseType == PURCHASE_TYPE_BUSD_METAVIE) {
            uint256 metavieAmountBUSD = amount / 10;
            amount = amount * 9 / 10;
            address[] memory path = new address[](2);

            path[0] = busdAddress;
            path[1] = metavieAddress;

            uint metavieAmount = IPancakeRouter02(routerAddress).getAmountsOut(metavieAmountBUSD, path)[1];
            _transferToContract(metavieAmount, metavieAddress);
        }
        _transferToContract(amount, busdAddress);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToPurchasedAmountMapping[msg.sender] += amount;
        lastPurchase.dollarValue += amount;
        _lastPurchaseDateUpdate(msg.sender);
        _updateHashrateAfterParcelPurchase(msg.sender, upgradedParcelSlotsCount - standardParcelSlotsCount);
        userToAvailableSlots[msg.sender] += upgradedParcelSlotsCount - standardParcelSlotsCount;
        IParcelInterface(standardParcelNFTAddress).upgradeParcel(_parcelId);
        emit StandardParcelUpgraded(msg.sender, _parcelId);
    }

    function upgradeMiner(uint256 _minerId, uint8 _purchaseType) external onlySaleActive {
        require(
            IERC721Base(minerV1NFTAddress).ownerOf(_minerId) == msg.sender,
            "Municipality: Invalid NFT owner"
        );
        uint256 minerCurrentLevel = IMinerNFT(minerV1NFTAddress).minerIdToLevelMapping(_minerId);
        require(minerCurrentLevel <= 9,"Municipality: Miner level maxed");
        uint256 amount = minerUpgradePrice;
        if(_purchaseType == PURCHASE_TYPE_BUSD_METAVIE) {
            uint256 metavieAmountBUSD = amount / 10;
            amount = amount * 9 / 10;
            address[] memory path = new address[](2);

            path[0] = busdAddress;
            path[1] = metavieAddress;

            uint metavieAmount = IPancakeRouter02(routerAddress).getAmountsOut(metavieAmountBUSD, path)[1];
            _transferToContract(metavieAmount, metavieAddress);
        }
        _transferToContract(amount, busdAddress);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToPurchasedAmountMapping[msg.sender] += amount;
        lastPurchase.dollarValue += amount;
        _lastPurchaseDateUpdate(msg.sender);
        userToMinerBalancesByLevel[msg.sender][minerCurrentLevel] -= 1;
        userToMinerBalancesByLevel[msg.sender][minerCurrentLevel+1] += 1;
        IMinerNFT(minerV1NFTAddress).upgradeMinerLevels(_minerId, 1);
        _updateHashrateAfterMinerUpgrade(msg.sender);
        emit MinerUpgraded(msg.sender, _minerId, IMinerNFT(minerV1NFTAddress).minerIdToLevelMapping(_minerId));
    }

    function upgradeAllMiners(uint8 _purchaseType) external onlySaleActive {
        uint256 amount = _getPriceForUpgradingAllMiners(msg.sender);
        uint256[] memory miners = IERC721Base(minerV1NFTAddress).tokensOf(msg.sender);
        if(_purchaseType == PURCHASE_TYPE_BUSD_METAVIE) {
            uint256 metavieAmountBUSD = amount / 10;
            amount = amount * 9 / 10;
            address[] memory path = new address[](2);

            path[0] = busdAddress;
            path[1] = metavieAddress;

            uint metavieAmount = IPancakeRouter02(routerAddress).getAmountsOut(metavieAmountBUSD, path)[1];
            _transferToContract(metavieAmount, metavieAddress);
        }
        _transferToContract(amount, busdAddress);
        LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
        userToPurchasedAmountMapping[msg.sender] += amount;
        lastPurchase.dollarValue += amount;
        _lastPurchaseDateUpdate(msg.sender);
        uint256[] memory upgradedMiners;
        uint256[] memory levels;
        for(uint i; i < miners.length; i++){
            uint256 minerLevel = IMinerNFT(minerV1NFTAddress).minerIdToLevelMapping(miners[i]);
            if(minerLevel < 9){
                userToMinerBalancesByLevel[msg.sender][minerLevel] -= 1;
                userToMinerBalancesByLevel[msg.sender][minerLevel+1] += 1;
                IMinerNFT(minerV1NFTAddress).upgradeMinerLevels(miners[i], 1);
                upgradedMiners[upgradedMiners.length] = miners[i];
                levels[levels.length] = minerLevel+1;
            }
        }
        _updateHashrateAfterMinerUpgrade(msg.sender);
        emit MinersUpgraded(msg.sender, upgradedMiners, levels);
    }

    function getPriceForSuperBundle(uint8 _bundleType, uint8 _purchaseType) external view returns(uint256[2] memory) {
        return _getPriceForSuperBundle(_bundleType, _purchaseType);
    }
    function getUserPriceForParcels(address _user, uint256 _parcelsCount, uint8 _purchaseType) external view returns(uint256[2] memory) {
        return(_getUserPriceForParcels(_user, _parcelsCount, _purchaseType));
    }
    function getUserPriceForMiners(address _user, uint256 _minersCount, uint8 _purchaseType) external view returns(uint256[2] memory) {
        return(_getUserPriceForMiners(_user, _minersCount, _purchaseType));
    }


    // @notice App will use this function to get the price for the selected parcels
    function getPriceForParcels(Parcel[] calldata parcels) external view returns (uint256, uint256) {
        (uint256 price, uint256 unitPrice) = _getPriceForParcels(parcels.length);
        return (price, unitPrice);
    }
    
    function getUserMiners(address _user) external view returns (uint256[] memory) {
        return IERC721Base(minerV1NFTAddress).tokensOf(_user);
    }

    function getMetaviePriceInBUSD() external view returns (uint256) {
        return _getMetaviePriceInBUSD();
    }

    function getUserMinersCountUnderLevel(address _user, uint256 _level) external view returns (uint256) {
        uint256 totalMiners;
        for(uint i = 0; i <= _level - 1; i++){
            totalMiners +=  userToMinerBalancesByLevel[_user][i];
        }
        return totalMiners;
    }

    function _getPriceForSuperBundle(uint8 _bundleType, uint8 _purchaseType) private view returns(uint256[2] memory) {
        _validateSuperBundleType(_bundleType);
        SuperBundleInfo memory bundle = superBundlesInfos[_bundleType- BUNDLE_TYPE_SUPER_1];
        (uint256 parcelPrice, ) = _getPriceForParcels(bundle.parcelsAmount);
        uint256 bundlePrice = parcelPrice + bundle.minersAmount * minerPrice;
        uint256 discountedPrice = _discountPrice(bundlePrice, bundle.discountPct);
        uint256[2] memory busdAndMetavie = [discountedPrice, 0];
        if(_purchaseType == PURCHASE_TYPE_BUSD_METAVIE) {
            busdAndMetavie[0] = discountedPrice * 9 / 10;
            busdAndMetavie[1] = discountedPrice / 10 * _getMetaviePriceInBUSD();
        }
        return busdAndMetavie;
    }
    function _getUserPriceForParcels(address _user, uint256 _parcelsCount, uint8 _purchaseType) private view returns(uint256[2] memory) {
        if(usersMintableNFTAmounts[_user].parcels >= _parcelsCount)
            return [uint256(0),uint256(0)];
        else {
            uint256 unpaidCount = _parcelsCount - usersMintableNFTAmounts[_user].parcels;
            (uint256 price,) = _getPriceForParcels(unpaidCount);
            uint256 percentage;
            if(unpaidCount >= 90) {
                percentage = 35187;
            } else if(unpaidCount >= 35) {
                percentage = 28577;
            } else if(unpaidCount >= 16) {
                percentage = 21875;
            } else if(unpaidCount >= 3) {
                percentage = 16667;
            }
            uint256 discountedPrice = _discountPrice(price, percentage);
            uint256[2] memory busdAndMetavie = [discountedPrice, 0];
            if(_purchaseType == PURCHASE_TYPE_BUSD_METAVIE) {
                busdAndMetavie[0] = discountedPrice * 9 / 10;
	            busdAndMetavie[1] = discountedPrice * _getMetaviePriceInBUSD() / 10 ether;            }
            return busdAndMetavie;
        }
    }
    function _getUserPriceForMiners(address _user, uint256 _minersCount, uint8 _purchaseType) private view returns(uint256[2] memory) {
        if(usersMintableNFTAmounts[_user].miners >= _minersCount)
            return [uint256(0),uint256(0)];
        else {
            uint256 unpaidCount = _minersCount - usersMintableNFTAmounts[_user].miners;
            uint256 price = unpaidCount * minerPrice;
            uint256 percentage;
            if(unpaidCount >= 360) {
                percentage = 35187;
            } else if(unpaidCount >= 140) {
                percentage = 28577;
            } else if(unpaidCount >= 64) {
                percentage = 21875;
            } else if(unpaidCount >= 12) {
                percentage = 16667;
            }
            uint256 discountedPrice = _discountPrice(price, percentage);
            uint256[2] memory busdAndMetavie = [discountedPrice, 0];
            if(_purchaseType == PURCHASE_TYPE_BUSD_METAVIE) {
                busdAndMetavie[0] = discountedPrice * 9 / 10;
	            busdAndMetavie[1] = discountedPrice * _getMetaviePriceInBUSD() / 10 ether;            
            }
            return busdAndMetavie;
        }
    }

    function _getPriceForUpgradingAllMiners(address _user) private view returns(uint256){
        return (IMinerNFT(minerV1NFTAddress).balanceOf(_user) - userToMinerBalancesByLevel[_user][9]) * minerUpgradePrice;
    }

    // @notice Private interface
	
    function _updateHashrateAfterParcelPurchase(address _user, uint256 newSlotsAmount) private {
        uint256 minersAmount = IMinerNFT(minerV1NFTAddress).balanceOf(_user);
        if(userToAvailableSlots[_user] < minersAmount) {
            uint finalSlotsCount = userToAvailableSlots[_user] + newSlotsAmount;
            if(finalSlotsCount < minersAmount)
                IMining(miningAddress).increaseHashrate(_user, newSlotsAmount * 1000);
            else 
                IMining(miningAddress).increaseHashrate(_user, (minersAmount - userToAvailableSlots[msg.sender]) * 1000);
        } 
    }

	function _updateHashrateAfterMinerPurchase(address _user, uint256 minersCount) private {
        uint256 minersAmount = IMinerNFT(minerV1NFTAddress).balanceOf(_user);
        if(minersAmount < userToAvailableSlots[_user]) {
            uint finalMinersCount = minersAmount + minersCount;
            if(finalMinersCount < userToAvailableSlots[_user])
                IMining(miningAddress).increaseHashrate(_user, (finalMinersCount - minersAmount)* 1000);
            else 
                IMining(miningAddress).increaseHashrate(_user, minersCount * 1000);
        } 
    }

    function _updateHashrateAfterMinerUpgrade(address _user) private {
        uint256 userAvailableSlots = userToAvailableSlots[_user];
        uint256 userHashrate = IMining(miningAddress).userHashrate(_user);
        uint256 newHashrate;
        if(userAvailableSlots == 0) 
            return;
        for(uint i = 9; i >= 0; i--){
            uint256 levelMiners =  userToMinerBalancesByLevel[_user][i];
            if(levelMiners >= userAvailableSlots){
                newHashrate += userAvailableSlots * i * 1000;
                break;
            } else {
                newHashrate += levelMiners * i * 1000;
                userAvailableSlots -= levelMiners;
            }
        }
        if(userHashrate < newHashrate){
            IMining(miningAddress).increaseHashrate(_user, newHashrate - userHashrate);
        }
    }


    /// @notice Transfers the given BUSD amount to distributor contract
    function _transferToContract(uint256 _amount, address _token) private {
        IERC20Upgradeable(_token).safeTransferFrom(
            address(msg.sender),
            address(amountsDistributorAddress),
            _amount
        );
    }

    function _validateSuperBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_SUPER_1 ||
            _bundleType == BUNDLE_TYPE_SUPER_2 ||
            _bundleType == BUNDLE_TYPE_SUPER_3 ||
            _bundleType == BUNDLE_TYPE_SUPER_4,
            "Municipality: Invalid super bundle type"
        );
    }

    /// @notice Returns the price of a given parcels
    function _getPriceForParcels(uint256 parcelsCount) private view returns (uint256, uint256) {
        uint256 price = parcelsCount * 100000000000000000000;
        uint256 unitPrice = 100000000000000000000;
        uint256 priceBefore = 0;
        uint256 totalParcelsToBuy = currentlySoldStandardParcelsCount + parcelsCount;
        if(totalParcelsToBuy > 157500) {
            unitPrice = 301000000000000000000;
            if (currentlySoldStandardParcelsCount > 157500) {
                price = parcelsCount * 301000000000000000000;
            } else {
                price = (parcelsCount + currentlySoldStandardParcelsCount - 157500) * 301000000000000000000;
                priceBefore = (157500 - currentlySoldStandardParcelsCount) * 209000000000000000000;
            }
        } else if(totalParcelsToBuy > 105000) {
            unitPrice = 209000000000000000000;
             if (currentlySoldStandardParcelsCount > 105000) {
                price = parcelsCount * 209000000000000000000;
            } else {
                price = (parcelsCount + currentlySoldStandardParcelsCount - 105000) * 209000000000000000000;
                priceBefore = (105000 - currentlySoldStandardParcelsCount) * 144000000000000000000;
            }
        } else if(totalParcelsToBuy > 52500) {
            unitPrice = 144000000000000000000;
            if (currentlySoldStandardParcelsCount > 52500) {
                price = parcelsCount * 144000000000000000000;
            } else {
                price = (parcelsCount + currentlySoldStandardParcelsCount - 52500) * 144000000000000000000;
                priceBefore = (52500 - currentlySoldStandardParcelsCount) * 116000000000000000000;
            }
        } else if(totalParcelsToBuy > 21000) {
             unitPrice = 116000000000000000000;
            if (currentlySoldStandardParcelsCount > 21000) {
                price = parcelsCount * 116000000000000000000; 
            } else {
                price = (parcelsCount + currentlySoldStandardParcelsCount - 21000) * 116000000000000000000;
                priceBefore = (21000 - currentlySoldStandardParcelsCount) * 100000000000000000000;
            }
            
        }
        return (priceBefore + price, unitPrice);
    }


    /// @notice Returns the discounted price of the bundle
    function _discountPrice(uint256 _price, uint256 _percentage) private pure returns (uint256) {
        return _price - (_price * _percentage) / 100000;
    }

    /**
     * @notice Private function to update last purchase date
     * @param _user: user address
     */
    function _lastPurchaseDateUpdate(address _user) private {
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        lastPurchase.lastPurchaseDate = block.timestamp;
        uint256 _lastDate = _checkPurchaseDate(_user);
        if (lastPurchase.expirationDate < _lastDate + 30 days) {
            lastPurchase.expirationDate = _lastDate + 30 days;
        }
        if(lastPurchase.expirationDate < block.timestamp) {
            lastPurchase.expirationDate = lastPurchase.lastPurchaseDate;
        }
        if (lastPurchase.dollarValue >= (100 * 1e18)) {
            lastPurchase.expirationDate = lastPurchase.lastPurchaseDate + 30 days;
            lastPurchase.dollarValue = 0;     
        }
    }

    function _checkPurchaseDate(address _user) private view returns (uint256) {
        uint256 _lastDate = IERC721Base(standardParcelNFTAddress).getUserPurchaseTime(_user)[0];
        if (IERC721Base(minerV1NFTAddress).getUserPurchaseTime(_user)[0] >  _lastDate) {
            _lastDate = IERC721Base(minerV1NFTAddress).getUserPurchaseTime(_user)[0];
        }
        return _lastDate;

    }

    function _getMetaviePriceInBUSD() private view returns (uint256) {
        address[] memory path = new address[](2);

        path[0] = metavieAddress;
        path[1] = wbnbAddress;
        uint256[] memory metaviePriceInWBNB = IPancakeRouter02(routerAddress).getAmountsOut(
            1000000000000000000,
            path
        );
        path[0] = wbnbAddress;
        path[1] = busdAddress;
        uint256[] memory wbnbPriceInBUSD = IPancakeRouter02(routerAddress).getAmountsOut(
            1,
            path
        );
        return metaviePriceInWBNB[1] * wbnbPriceInBUSD[1];
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

pragma solidity ^0.8.15;

import "../Municipality.sol";

interface ISignatureValidator {
    function verifySigner(Municipality.ParcelsMintSignature memory mintParcelSignature) external view returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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

interface IMinerNFT {
    function mintMiners(address _user, uint256 _count) external returns(uint256, uint256);
    function upgradeMinerLevels(uint256 _minerId, uint256 _levels) external;
    function balanceOf(address _owner) external view returns (uint256);
    function minerIdToLevelMapping(uint256 _tokenId) external view returns(uint256);
    function hashrate() external pure returns (uint256);
    function mint(address) external returns (uint256);
    function lastMinerId() external returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IMining {
    struct UserInfo {
        uint256 hashrate; 
        uint256 totalClaims;
        uint256 rewardDebt;
    }
    function deposit(address _user, uint256 _miner, uint256 _hashRate) external;
    function depositMiners(address _user, uint256 _firstMinerId, uint256 _minersCount, uint256 _hashRate) external;
    function withdraw(address _user,uint256 _miner) external;
    function applyVouchers(address _user, uint256[] calldata _minerIds) external;
    function getMinersCount(address _user) external view returns (uint256);
    function repairMiners(address _user) external;
    function increaseHashrate(address _userAddress, uint256 _hashrate) external;
    function decreaseHashrate(address _userAddress, uint256 _hashrate) external;
    function userHashrate(address _user) external view returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
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