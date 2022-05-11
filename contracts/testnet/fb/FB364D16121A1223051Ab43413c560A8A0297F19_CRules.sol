// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./interfaces/ICopyStaking.sol";
import "./interfaces/IParticipationManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CRules is Ownable {
    /* ========== ENUM ========== */
    enum Tier {
        FREEMIUM,
        BRONZE,
        SILVER,
        GOLD,
        DIAMOND
    }

    /* ========== STRUCTS ========== */

    struct MaxPerTier {
        uint256 maxAllocations;
        uint256 maxPools;
    }

    /* ========== STATE VARIABLES ========== */

    mapping(Tier => MaxPerTier) private maxPerTier;
    mapping(address => bool) public tradersWhiteList;
    mapping(address => bool) public tokenWhiteList;
    mapping(address => bool) public poolWhiteList;

    ICopyStaking public stakingContract;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _stakingContract) {
        stakingContract = ICopyStaking(_stakingContract);
        _loadTiers();
    }

    function _loadTiers() private {
        maxPerTier[Tier.FREEMIUM] = MaxPerTier(500 * (10**18), 1);
        maxPerTier[Tier.BRONZE] = MaxPerTier(3000 * (10**18), 3);
        maxPerTier[Tier.SILVER] = MaxPerTier(7000 * (10**18), 7);
        maxPerTier[Tier.GOLD] = MaxPerTier(15000 * (10**18), 15);
        maxPerTier[Tier.DIAMOND] = MaxPerTier(1000000 * (10**18), 1000);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function modifyMaxPerTier(
        uint8 _tier,
        uint256 _maxAllocations,
        uint256 _maxPools
    ) external onlyOwner {
        require(_tier <= uint8(Tier.DIAMOND));

        MaxPerTier storage maxs = maxPerTier[Tier(_tier)];

        maxs.maxAllocations = _maxAllocations;
        maxs.maxPools = _maxPools;
    }

    function addPoolToWhiteList(address _poolAddress) external {
        poolWhiteList[_poolAddress] = true;
    }

    function removePoolFromWhiteList(address _poolAddress) external {
        if (poolWhiteList[_poolAddress]) {
            delete poolWhiteList[_poolAddress];
        }
    }

    function addTraderToWhiteList(address _traderAddress) external onlyOwner {
        tradersWhiteList[_traderAddress] = true;
    }

    function removeTraderFromWhiteList(address _traderAddress)
        external
        onlyOwner
    {
        if (tradersWhiteList[_traderAddress]) {
            delete tradersWhiteList[_traderAddress];
        }
    }

    function addTokenToWhiteList(address _tokenAddress) external onlyOwner {
        tokenWhiteList[_tokenAddress] = true;
    }

    function removeTokenFromWhiteList(address _tokenAddress)
        external
        onlyOwner
    {
        if (tokenWhiteList[_tokenAddress]) {
            delete tokenWhiteList[_tokenAddress];
        }
    }

    /* ========== VIEWS ========== */
    function isPoolInWhiteList(address _poolAddress)
        external
        view
        returns (bool)
    {
        return poolWhiteList[_poolAddress];
    }

    function isTraderInWhiteList(address _traderAddress)
        external
        view
        returns (bool)
    {
        return tradersWhiteList[_traderAddress];
    }

    function isTokenInWhiteList(address _tokenAddress)
        external
        view
        returns (bool)
    {
        return tokenWhiteList[_tokenAddress];
    }

    function getMaxAllocationPerStaking(address _copier)
        public
        view
        returns (MaxPerTier memory)
    {
        return maxPerTier[getTier(_copier)];
    }

    function getTier(address _copier) public view returns (Tier) {
        uint256 stakedTokens = stakingContract.balanceOf(_copier);
        if (stakedTokens >= 200000 * (10**18)) {
            return Tier.DIAMOND;
        } else if (stakedTokens >= 70000 * (10**18)) {
            return Tier.GOLD;
        } else if (stakedTokens >= 40000 * (10**18)) {
            return Tier.SILVER;
        } else if (stakedTokens >= 20000 * (10**18)) {
            return Tier.BRONZE;
        }
        return Tier.FREEMIUM;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICopyStaking {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function stakingToken() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IParticipationManager {
    /* ========== STRUCTS ========== */

    struct Copier {
        uint256 allocation;
        uint256 pools;
        uint256 averagePriceIn;
    }

    function copiers(address _copierAddress)
        external
        view
        returns (Copier memory);
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