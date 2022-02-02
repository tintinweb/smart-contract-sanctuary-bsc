/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/access/Ownable.sol

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// File: contracts/interface/IRegistry.sol

interface IRegistry {

    // base and research
    function base() external view returns (address);
    function research() external view returns (address);

    // fleets and ships
    function account() external view returns (address);
    function fleets() external view returns (address);
    function explore() external view returns (address);
    function battle() external view returns (address);
    function ship() external view returns (address);
    function hero() external view returns (address);

    // staking and burning
    function staking() external view returns (address);
    function burning() external view returns (address);
    function uniswapV2Router() external view returns (address);
    function stableToken() external view returns (address);
    function treasury() external view returns (address);

    // fleets config and ships config
    function shipConfig() external view returns (address);
    function heroConfig() external view returns (address);
    function fleetsConfig() external view returns (address);
    function exploreConfig() external view returns (address);
    function battleConfig() external view returns (address);
    function shipAttrConfig() external view returns (address);
    function heroAttrConfig() external view returns (address);

    // base config and research config
    function baseConfig() external view returns (address);
    function researchConfig() external view returns (address);
    function miningConfig() external view returns (address);
    function claimConfig() external view returns (address);

    // tokens
    function tokenIron() external view returns (address);
    function tokenGold() external view returns (address);
    function tokenEnergy() external view returns (address);
    function tokenSilicate() external view returns (address);
    function tokenLightCoin() external view returns (address);

    // access
    function canMintCommodity(address) external view returns (bool);
}

// File: contracts/Registry.sol

// Registry will be managed by timelock and a governance contract.
contract Registry is Ownable, IRegistry {

    // base and research
    address public override base;
    address public override research;

    // fleets and ships
    address public override fleets;
    address public override account;
    address public override battle;
    address public override explore;
    address public override ship;
    address public override hero;

    // staking and burning
    address public override staking;
    address public override burning;
    address public override uniswapV2Router;
    address public override stableToken;  // WBNB is the best choice.
    address public override treasury;

    // fleets config and ships config
    address public override shipConfig;
    address public override heroConfig;
    address public override fleetsConfig;
    address public override exploreConfig;
    address public override battleConfig;
    address public override shipAttrConfig;
    address public override heroAttrConfig;

    // base config and research config
    address public override baseConfig;
    address public override researchConfig;
    address public override miningConfig;
    address public override claimConfig;

    // tokens
    address public override tokenIron;
    address public override tokenGold;
    address public override tokenEnergy;
    address public override tokenSilicate;
    address public override tokenLightCoin;

    // access
    mapping(address => bool) public override canMintCommodity;

    constructor() public {}

    // base and research
    function setBase(address base_) external onlyOwner {base = base_;}
    function setResearch(address research_) external onlyOwner {research = research_;}

    // fleets and ships
    function setFleets(address addr_) public onlyOwner {fleets = addr_;}
    function setAccount(address addr_) public onlyOwner {account = addr_;}
    function setExplore(address addr_) public onlyOwner {explore = addr_;}
    function setBattle(address addr_) public onlyOwner {battle = addr_;}
    function setShip(address addr_) public onlyOwner {ship = addr_;}
    function setHero(address addr_) public onlyOwner {hero = addr_;}

    // staking and burning
    function setStaking(address addr_) external onlyOwner {staking = addr_;}
    function setBurning(address addr_) external onlyOwner {burning = addr_;}
    function setUniswapV2Router(address addr_) external onlyOwner {uniswapV2Router = addr_;}
    function setStableToken(address addr_) external onlyOwner {stableToken = addr_;}
    function setTreasury(address addr_) external onlyOwner {treasury = addr_;}

    // fleets config and ships config
    function setShipConfig(address addr_) external onlyOwner {shipConfig = addr_;}
    function setHeroConfig(address addr_) external onlyOwner {heroConfig = addr_;}
    function setFleetsConfig(address addr_) external onlyOwner {fleetsConfig = addr_;}
    function setExploreConfig(address addr_) external onlyOwner {exploreConfig = addr_;}
    function setBattleConfig(address addr_) external onlyOwner {battleConfig = addr_;}
    function setShipAttrConfig(address addr_) external onlyOwner {shipAttrConfig = addr_;}
    function setHeroAttrConfig(address addr_) external onlyOwner {heroAttrConfig = addr_;}

    // base config and research config
    function setBaseConfig(address addr_) external onlyOwner {baseConfig = addr_;}
    function setResearchConfig(address addr_) external onlyOwner {researchConfig = addr_;}
    function setMiningConfig(address addr_) external onlyOwner {miningConfig = addr_;}
    function setClaimConfig(address addr_) external onlyOwner {claimConfig = addr_;}

    // tokens
    function setTokenIron(address addr_) external onlyOwner {tokenIron = addr_;}
    function setTokenGold(address addr_) external onlyOwner {tokenGold = addr_;}
    function setTokenEnergy(address addr_) external onlyOwner {tokenEnergy = addr_;}
    function setTokenSilicate(address addr_) external onlyOwner {tokenSilicate = addr_;}
    function setTokenLightCoin(address addr_) external onlyOwner {tokenLightCoin = addr_;}

    // access
    function setCanMintCommodity(address addr_, bool value_) external onlyOwner {
        canMintCommodity[addr_] = value_;
    }
}