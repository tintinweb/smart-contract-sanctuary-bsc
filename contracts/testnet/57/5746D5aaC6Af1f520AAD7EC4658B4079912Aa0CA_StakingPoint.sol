pragma solidity ^0.8.0;

import "./interfaces/IStakingPoint.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IKabyHero.sol";
import "./common/interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract StakingPoint is IStakingPoint, Ownable {

    mapping(uint256 => mapping(address => uint256)) public erc20DepositPoint;
    mapping(uint256 => mapping(address => uint256)) public erc20BurnPoint;
    mapping(uint256 => mapping(address => uint256)) public lpTokenDepositPoint;
    mapping(uint256 => mapping(address => uint256)) public starPoint;

    uint256 public constant onePoint = 1e18;

    IERC20 immutable public USD;

    constructor(IERC20 _usd) {
        USD = _usd;
    }

    function setERC20DepositPoint(uint256 pid, address token, uint256 point) external onlyOwner {
        erc20DepositPoint[pid][token] = point;
    }

    function setERC20BurnPoint(uint256 pid, address token, uint256 point) external onlyOwner {
        erc20BurnPoint[pid][token] = point;
    }

    function setLpTokenDepositPoint(uint256 pid, address token, uint256 point) external onlyOwner {
        IUniswapV2Pair pair = IUniswapV2Pair(token);
        address token0 = pair.token0();
        address token1 = pair.token1();
        require(token0 == address(USD) || token1 == address(USD), "SP: lp token is not include usd");
        lpTokenDepositPoint[pid][token] = point;
    }

    function setStarPoint(uint256 pid, address nft, uint256 point) external onlyOwner {
        starPoint[pid][nft] = point;
    }

    function getPointForBurnERC20(uint256 pid, address token, uint256 amount) external view override returns(uint256 point) {
        return erc20BurnPoint[pid][token] * amount / (10**IERC20(token).decimals());
    }

    function getPointForDepositERC20(uint256 pid, address token, uint256 amount) external view override returns(uint256 point) {
        if (lpTokenDepositPoint[pid][token] != 0) {
            return depositLpToken(pid, token, amount);
        } else {
            return erc20DepositPoint[pid][token] * amount / (10**IERC20(token).decimals());
        }
    }

    function getPointForBurnNFT(uint256 pid, address nft, uint256 tokenId) external view override returns(uint256 point) {
        uint256 star = IKabyHero(nft).getHeroStar(tokenId);
        if (_isGenesisNFT(nft, tokenId)) {
            return starPoint[pid][nft] * star * 2;
        } else {
            return starPoint[pid][nft] * star;
        }
    }

    function depositLpToken(uint256 pid, address token, uint256 amount) public view returns(uint256) {
        (uint256 amount, uint8 decimals) = _calculateTokenInLp(token, amount);
        return amount * lpTokenDepositPoint[pid][token] / (10**decimals);
    }

    function _calculateTokenInLp(address lpToken, uint256 liquidity) private view returns(uint256, uint8) {
        IUniswapV2Pair pair = IUniswapV2Pair(lpToken);
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint balance0 = IERC20(token0).balanceOf(lpToken);
        uint balance1 = IERC20(token1).balanceOf(lpToken);
        uint256 totalSupply = pair.totalSupply();
        uint256 amount0 = liquidity * balance0 / totalSupply;
        uint256 amount1 = liquidity * balance1 / totalSupply;
        if (token0 == address(USD)) {
            return (amount1, IERC20(token1).decimals());
        } else if (token1 == address(USD)) {
            return (amount0, IERC20(token0).decimals());
        } else {
            return (0, 0);
        }
    }

    function _isGenesisNFT(address nft, uint256 tokenId) private view returns(bool) {
        (uint currentSell,,,,,,,,) = IKabyHero(nft).versions(0);
        if (tokenId < currentSell) {
            return true;
        } else {
            return false;
        }

    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity ^0.8.0;

interface IStakingPoint {
  function getPointForBurnERC20(uint256 pid, address token, uint256 amount) external returns(uint256 point);
  function getPointForDepositERC20(uint256 pid, address token, uint256 amount) external returns(uint256 point);
  function getPointForBurnNFT(uint256 pid, address nft, uint256 amount) external returns(uint256 point);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKabyHero {
    struct Hero {
        uint star;
        uint gem1;
        uint gem2;
        uint gem3;
        uint gem4;
        uint gem5;
    }

    struct Version {
        uint currentSell;
        uint currentReserve;
        uint maxSupply;
        uint maxForSell;
        uint salePrice;
        uint startTime;
        uint endTime;
        string provenance; // This is the provenance record of all Hero artworks in existence.
        bool useSummonStaking;
    }
    
    struct VersionConstructorParams {
        uint maxSupply;
        uint maxForSell;
        uint salePrice;
        uint startTime;
        uint endTime;
        string provenance;
    }

    event HeroCreated(uint indexed heroId, uint star, address ownerOfHero);
    event HeroListed(uint indexed heroId, uint price, address ownerOfHero);
    event HeroDelisted(uint indexed heroId, address ownerOfHero);
    event HeroStarUpgraded(uint indexed heroId, uint newStar, uint amount);
    event HeroBought(uint indexed heroId, address buyer, address seller, uint price);
    event HeroOffered(uint indexed heroId, address buyer, uint price);
    event HeroOfferCanceled(uint indexed heroId, address buyer);
    event HeroPriceIncreased(uint indexed heroId, uint floorPrice, uint increasedAmount);
    event ItemsEquipped(uint indexed heroId, uint[] itemIds);
    event ItemsUnequipped(uint indexed heroId, uint[] itemIds);
    event NewVersionAdded(uint versionId);
    event UpdateRandomGenerator(address newRandomGenerator);
    event SetStar(uint indexed heroId, uint star, address ownerOfHero);
    event UpdateStakingPool(address newStakingPool);
    event UpdateSummonStakingPool(address newSummonStakingPool);
    event UpdateGem(address newGem);
    event UpdateMaxStar(uint newMaxStar);
    event UpdateMarketFee(uint newMarketFee);
    event UpdateEndTime(uint endTime);
    event UpdateMaxSupply(uint newMaxSupply);
    
    /**
     * @notice Claims Heros when it's on presale phase.
     */
    function claimHero(uint versionId, uint amount) external;

    /**
     * @notice Upgrade star for hero
     */
    function upgradeStar(uint heroId, uint amount) external;

    /**
     * @notice Mint Heros from Minter to user.
     */
    function mintHero(uint versionId, uint amount, address account) external;

    /**
     * @notice Owner equips items to their Hero by burning ERC1155 Gem NFTs.
     *
     * Requirements:
     * - caller must be owner of the Hero.
     */
    function equipItems(uint heroId, uint[] memory itemIds) external;

    /**
     * @notice Owner removes items from their Hero. ERC1155 Gem NFTs are minted back to the owner.
     *
     * Requirements:
     * - caller must be owner of the Hero.
     */
    function removeItems(uint heroId, uint[] memory itemIds) external;

    /**
     * @notice Burns a Hero `.
     *
     * - Not financial advice: DONT DO THAT.
     * - Remember to remove all items before calling this function.
     */
    function sacrificeHero(uint heroId) external;

    /**
     * @notice Lists a Hero on sale.
     *
     * Requirements:
     * - `price` cannot be under Hero's `floorPrice`.
     * - Caller must be the owner of the Hero.
     */
    function list(uint heroId, uint price) external;

    /**
     * @notice Delist a Hero on sale.
     */
    function delist(uint heroId) external;

    /**
     * @notice Instant buy a specific Hero on sale.
     *
     * Requirements:
     * - Target Hero must be currently on sale.
     * - Sent value must be exact the same as current listing price.
     */
    function buy(uint heroId) external;

    /**
     * @notice Gives offer for a Hero.
     *
     * Requirements:
     * - Owner cannot offer.
     */
    function offer(uint heroId, uint offerValue) external;

    /**
     * @notice Owner take an offer to sell their Hero.
     *
     * Requirements:
     * - Cannot take offer under Hero's `floorPrice`.
     * - Offer value must be at least equal to `minPrice`.
     */
    function takeOffer(uint heroId, address offerAddr, uint minPrice) external;

    /**
     * @notice Cancels an offer for a specific Hero.
     */
    function cancelOffer(uint heroId) external;

    /**
     * @notice Finalizes the battle aftermath of 2 Heros.
     */
    // function finalizeDuelResult(uint winningheroId, uint losingheroId, uint penaltyInBps) external;

    /**
     * @notice Gets Hero information.
     */
    function getHero(uint heroId) external view returns (
        uint star,
        uint[5] memory gem
    );
    
     /**
     * @notice Gets current star of given hero.
     */
    function getHeroStar(uint heroId) external view returns (uint);

     /**
     * @notice Gets current total hero was created.
     */
    function totalSupply() external view returns (uint);

    /**
     * @notice Set random star
     */
    function setRandomStar(uint heroId, uint randomness) external;

    /**
     * @notice Get version
     */
    function versions(uint versionId) external view returns(
        uint currentSell,
        uint currentReserve,
        uint maxSupply,
        uint maxForSell,
        uint salePrice,
        uint startTime,
        uint endTime,
        string memory provenance,
        bool useSummonStaking
    );
}

pragma solidity ^0.8.0;

interface IERC20Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;
import "./IERC20Metadata.sol";

interface IERC20 is IERC20Metadata {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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