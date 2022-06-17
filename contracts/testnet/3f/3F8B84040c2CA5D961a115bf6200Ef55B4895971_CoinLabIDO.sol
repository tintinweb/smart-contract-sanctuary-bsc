// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title CoinLab IDO 
 * @author KhoaGit
 * @notice Contract for buy ft from inos on launchpad
 * @dev This contract includes 2 main actors:
 1. WhitelistedUser who can:
    1.1 depositBUSD()
    1.2 claimFT()
 2. Owner who can:
    2.1 setWhitelistAddress()
    2.2 unSetWhitelistedAddress()
    2.3 addIDO()
    2.4 updateIDOPrice()
    2.5 pause/unPauseContract()
 */
contract CoinLabIDO is Pausable, Ownable {
    using Counters for Counters.Counter;

    /// The number of idos are created in contract
    Counters.Counter public _idoIds;

    /// The number of package of idos are created in contract
    Counters.Counter public _packageIds;

    /// BUSD token address
    IERC20 public _busd;

    /// CoinLab's wallet address
    address public _coinlabPool;

    // Mapping ido's Id to whitelist user address to true/false
    mapping(uint256 => mapping(address => bool)) private _whitelistedUser;

    enum Stages {
        COMING,
        DEPOSIT,
        CLAIM,
        FINISH
    }

    // Structure of IDO type
    struct IDO {
        // IDO's ID
        uint256 id;
        // Common price of all ft in each ido
        uint256 price;
        // Total tokens that user can claim
        uint256 totalFTsWillReceive;
        // Total times user can claim
        uint256 totalClaimTimes;
        // The address of ft ino
        address ftAddress;
        // Stage of this IDO
        Stages stage;
    }

    struct Package {
        uint256 id;
        uint256 totalFTsClaimed;
        uint256 currentClaimTime;
        address owner;
    }

    // Mapping id to ido information
    mapping(uint256 => IDO) private _idToIDO;

    // Mapping id to ido information
    mapping(uint256 => Package) private _idToPackage;

    // Mapping ido's Id to package id to Claimer address that claimer can claim ft
    mapping(uint256 => mapping(uint256 => address)) private _ftClaimer;

    // Mapping package's Id to the time to total token Claimer can claim ft
    mapping(uint256 => mapping(uint256 => uint256)) public _ftClaimTime;

    /**
     * @dev Emitted when `user` deposit BUSD successfully.
     */
    event BUSDDeposited(address user, uint256 ftAddress);

    /**
     * @dev Emitted when `ftId` token is claimed by `claimer`.
     */
    event FTClaimed(address claimer, uint256 claimTime, uint256 totalFTClaimed);

    /**
     * @dev Emitted when contract's owner adds new porject with `ftAddress` and `price` to `_allIDOs` successfully.
     */
    event IDOAdded(
        uint256 idoId,
        uint256 price,
        uint256 totalFTsWillReceive,
        Stages stage,
        address ftAddress
    );

    /**
     * @dev Emitted when contract's owner updates `newPrice` of a specific `idoId` successfully.
     */
    event IDOPriceUpdated(uint256 idoId, uint256 newPrice);

    /**
     * @dev Emitted when contract's owner updates `totalFT` in specific `time` of an `idoId` successfully.
     */
    event FTClaimTimeSet(uint256 idoId, uint256 time, uint256 totalFT);

    /**
     * @dev Emitted when contract's owner updates new IDO stage.
     */
    event newStageSet(Stages previousStage, Stages newStage);

    /**
     * @dev Emitted when new `addressToWhitelist` is set to true.
     */
    event WhitelistedAddress(uint256 idoId, address addressToWhitelist);

    /**
     * @dev Emitted when a WhitelistedAddress is set to false.
     */
    event UnSetWhitelistedAddress(uint256 idoId, address addressToUnSet);

    /**
     * @dev Emitted when new `_coinlabPool` address is set.
     */
    event CoinLabPoolSet(address previousAddress, address newAddress);

    /**
     * @dev Initializes the contract by setting a `busd` and a `coinlab` address.
     * @param busd is the address of busd token on bsc 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56.
     * @param coinlab is the coinlab wallet addrress.
     */
    constructor(address busd, address coinlab) {
        _busd = IERC20(busd);
        _coinlabPool = coinlab;
    }

    /**
     * @dev Whitelisted user deposits BUSD to buy FT.
     *
     * @notice User have to approve this {IDO-contract} transfer BUSD from his wallet to another wallet, like coinlab's wallet.
     *
     * @param idoId is the index of ido infor in `_allIDOs` array.
     *
     * Requirements:
     *
     * - Whitelisted user must call {appove} function in BUSD contract to appove this contract use BUSD in user's wallet first. 
     Then we can call {transferFrom} function to transfer BUSD to coinlab's wallet.
     * - The msg.sender must be a Whitelisted User
     *
     * Emits a {BUSDDeposited} event.
     */
    function depositBUSD(uint256 idoId)
        public
        whenNotPaused
        onlyWhitelistedUsers(idoId)
    {
        IDO memory ido = _idToIDO[idoId];
        require(ido.stage == Stages.DEPOSIT, "The current stage must be DEPOSIT stage");

        uint256 price;
        uint256 totalFTsWillReceive;
        price = ido.price;
        totalFTsWillReceive = ido.totalFTsWillReceive;
        _busd.transferFrom(_msgSender(), _coinlabPool, price);

        uint256 newPackageId = _newPackage();
        _ftClaimer[idoId][newPackageId] = _msgSender();

        emit BUSDDeposited(_msgSender(), idoId);
    }

    function _newPackage()
        internal
        returns (uint256)
    {
        _packageIds.increment();

        uint256 packageId = _packageIds.current();
        Package storage newPackage = _idToPackage[packageId];

        newPackage.id = packageId;
        newPackage.totalFTsClaimed = 0;
        newPackage.currentClaimTime = 0;
        newPackage.owner = _msgSender();

        return packageId;
    }

    /**
     * @dev `_ftClaimer` claims ft after deposit BUSD successfully.
     *
     * @notice User can claim ft after call {depositBUSD} function successfully.
     *
     * @param idoId is the index of ido infor in `_allIDOs` array.
     * @param claimTime is the time that `msg.sender` claim tokens.
     *
     * Requirements:
     *
     * - `ftId` token must exist.
     * - The times of `_ftClaimer` can claim must greater than 0.
     * - Coinlab've already approved this {IDO-contract} to move FT from its wallet to `_ftClaimer` address.
     If not, CoinLab have to call {setApprovalForAll} or {approve} function on FT contract address to allow this {IDO-contract} move ft from CoinLab's wallet to `_ftClaimer` address.
     *
     * Emits a {FTClaimed} event.
     */
    function claimFT(
        uint256 idoId,
        uint256 packageId,
        uint256 claimTime
    ) external whenNotPaused onlyWhitelistedUsers(idoId) {
        require(_ftClaimer[idoId][packageId] == _msgSender(), "The sender must be the owner of this package");

        IDO memory ido = _idToIDO[idoId];
        require(ido.stage == Stages.CLAIM, "The current stage must be CLAIM stage");

        Package storage package = _idToPackage[packageId];
        require(package.currentClaimTime < claimTime, "currentClaimTime must be less than claimTime");
        require(claimTime <= ido.totalClaimTimes, "claimtime must be less than totalClaimTimes");

        uint256 tokensClaim = _ftClaimTime[idoId][claimTime];
        require(tokensClaim > 0, "Total tokens can claim must be greater than 0");
        require((tokensClaim + package.totalFTsClaimed) <= ido.totalFTsWillReceive, "No claiming tokens must be less than totalFTsCanClaim");

        IERC20 FT = IERC20(ido.ftAddress);

        package.totalFTsClaimed += tokensClaim;
        package.currentClaimTime += 1;

        FT.transferFrom(
            _coinlabPool,
            _msgSender(),
            tokensClaim
        );

        emit FTClaimed(_msgSender(), claimTime, tokensClaim);
    }

    function setTotalFTsInClaimTime(
        uint256 idoId,
        uint256 time,
        uint256 totalFTs
    ) external onlyOwner {
        IDO memory ido = _idToIDO[idoId];
        require(ido.stage == Stages.CLAIM, "The current stage must be CLAIM stage");
        require(totalFTs <= ido.totalFTsWillReceive, "The number of tokens user can claim one time must be less than total tokens thay can claim");

        _ftClaimTime[idoId][time] = totalFTs;

        emit FTClaimTimeSet(idoId, time, totalFTs);
    }

    function nextIDOStage(uint256 idoId) external onlyOwner {
        IDO storage ido = _idToIDO[idoId];
        require(ido.stage != Stages.FINISH, "The current stage must not be FINISH stage");
        Stages newStage;
        newStage = Stages(uint(ido.stage) + 1);

        emit newStageSet(ido.stage, newStage);

        ido.stage = newStage;
    }

    /**
     * @dev Contract's owner set a address to whitelisted address.
     *
     * @param idoId is the index of ido infor in `_allIDOs` array.
     * @param addressToWhitelist is a new address will be mapped to true.
     *
     * Emits a {WhitelistedAddress} event.
     */
    function setWhitelistAddress(uint256 idoId, address addressToWhitelist)
        external
        onlyOwner
    {
        require(_idToIDO[idoId].stage == Stages.COMING, "The current stage must be COMING stage");

        _whitelistedUser[idoId][addressToWhitelist] = true;

        emit WhitelistedAddress(idoId, addressToWhitelist);
    }

    /**
     * @dev Contract's owner deletes an address from whitelisted address.
     *
     * @param idoId is the index of ido infor in `_allIDOs` array.
     * @param addressToUnset is an address will be mapped to false.
     *
     * Emits a {UnSetWhitelistedAddress} event.
     */
    function unSetWhitelistedAddress(uint256 idoId, address addressToUnset)
        external
        onlyOwner
    {
        require(_idToIDO[idoId].stage == Stages.COMING, "The current stage must be COMING stage");

        _whitelistedUser[idoId][addressToUnset] = false;

        emit UnSetWhitelistedAddress(idoId, addressToUnset);
    }

    /**
     * @dev Returns if the `user` is allowed to call function {depositBUSD} with specific `idoId`.
     */
    function isWhitelistedUser(uint256 idoId, address user)
        public
        view
        returns (bool)
    {
        return _whitelistedUser[idoId][user];
    }

    /**
     * @dev Throws if called by any account other than the whitelisted users.
     */
    modifier onlyWhitelistedUsers(uint256 idoId) {
        require(isWhitelistedUser(idoId, _msgSender()), "Address must be whitelisted");
        _;
    }

    /**
     * @dev Contract's owner adds new ido's information to `_allIDOs` array. The `_idoIds` will increase before new ido is added to.
     *
     * @param ftAddress is an address of new FT ido.
     * @param price is common price of all ntfs in this ido.
     *
     * Emits a {IDOAdded} event.
     */
    function addIDO(
        address ftAddress,
        uint256 price,
        uint256 totalFTsWillReceive,
        uint256 totalClaimTimes
    ) external onlyOwner {
        _idoIds.increment();

        uint256 idoId = _idoIds.current();
        IDO storage newIDO = _idToIDO[idoId];

        newIDO.id = idoId;
        newIDO.price = price;
        newIDO.totalFTsWillReceive = totalFTsWillReceive;
        newIDO.totalClaimTimes = totalClaimTimes;
        newIDO.stage = Stages.COMING;
        newIDO.ftAddress = ftAddress;

        emit IDOAdded(idoId, price, totalFTsWillReceive, Stages.COMING, ftAddress);
    }

    /**
     * @dev Contract's owner updates new price in a specific ido.
     *
     * @param idoId is the index of ido infor in `_allIđOs` array.
     * @param newPrice is new common price of all ntfs in this ido.
     *
     * Emits a {IDOPriceUpdated} event.
     */
    function updateIDOPrice(uint256 idoId, uint256 newPrice)
        external
        onlyOwner
    {
        IDO storage ido = _idToIDO[idoId];
        require(ido.stage == Stages.COMING, "The current stage must be COMING stage");

        ido.price = newPrice;

        emit IDOPriceUpdated(idoId, newPrice);
    }

    /**
     * @dev Returns information of `idoId`.
     */
    function getIDO(uint256 idoId)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            Stages
        )
    {
        IDO storage ido = _idToIDO[idoId];
        return (
            ido.ftAddress,
            ido.price,
            ido.totalFTsWillReceive,
            ido.totalClaimTimes,
            ido.stage
        );
    }

    /**
     * @dev Returns all IDOs.
     */
    function getIDOs() public view returns (IDO[] memory) {
        uint256 idoCount = _idoIds.current();

        IDO[] memory idos = new IDO[](idoCount);
        for (uint256 i = 0; i < idoCount; i++) {
            uint256 currentId = i + 1;
            IDO storage currentIDO = _idToIDO[currentId];
            idos[i] = currentIDO;
        }

        return idos;
    }

    /**
     * @dev Returns ftAddress and price of `idoId`.
     */
    function getPackage(uint256 packageId)
        public
        view
        returns (
            uint256,
            uint256,
            address
        )
    {
        Package storage package = _idToPackage[packageId];
        return (
            package.totalFTsClaimed,
            package.currentClaimTime,
            package.owner
        );
    }

    /**
     * @dev Contract's owner updates new `_coinlabPool` address.
     *
     * @param newAddress is the new address of `_coinlabPool`.
     *
     * Emits a {CoinLabPoolSet} event.
     */
    function setCoinLabPoolAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0x0));

        emit CoinLabPoolSet(_coinlabPool, newAddress);
        _coinlabPool = newAddress;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pauseContract() external onlyOwner {
        super._pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unPauseContract() external onlyOwner {
        super._unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
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
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
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