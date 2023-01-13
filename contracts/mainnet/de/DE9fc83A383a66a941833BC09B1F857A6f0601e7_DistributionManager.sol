// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;

import "../common/AbstractDependant.sol";
import "../interfaces/IGhostMinter.sol";
import "../interfaces/IDistributionManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DistributionManager is IDistributionManager, AbstractDependant, Ownable {

  address public minter;

  uint256 public defaultLiquidityPercent;
  address public liquidityRecipient;

  address public profitRecipient;
  address public donationRecipient;

  mapping (bytes32 => uint256) donationPercentage;

  event DonationPercentageUpdated(bytes32 slug, uint256 oldPercentage, uint256 newPercentage);
  event DefaultLiquidityPercentageUpdated(uint256 oldPercentage, uint256 newPercentage);

  modifier onlyMinter() {
    require(msg.sender == minter, "DistributionManager: Caller is not minter");
    _;
  }

  function setDependencies(IRegistry _registry) external override onlyInjectorOrZero {
    minter = _registry.getGhostMinterContract();
    liquidityRecipient = _registry.getLiquidityRecipient();
    donationRecipient = _registry.getDonationRecipient(); // @todo custom getters or consts?
    profitRecipient = _registry.getProfitRecipient();
  }

  function getLiquidityRewards(bytes32 /*slug*/, uint256 /*tokenId*/) external view
    returns(IGhostMinter.Distribution memory distribution)
  {
    distribution.recipient = liquidityRecipient;
    distribution.amount = defaultLiquidityPercent; // potentially may implement custom liquidity % by token

    return(distribution);
  }

  function getDonationRewards(bytes32 slug) external view
    returns(IGhostMinter.Distribution memory distribution)
  {
    if (donationPercentage[slug] > 0) {
      distribution.recipient = donationRecipient;
      distribution.amount = donationPercentage[slug];
    }

    return(distribution);
  }

  function setDonationPercentage(bytes32 slug, uint256 percentage) external onlyOwner
  {
    emit DonationPercentageUpdated(slug, donationPercentage[slug], percentage);
    donationPercentage[slug] = percentage;
  }

  function setDefaultLiquidityPercentage(uint256 percentage) external onlyOwner
  {
    emit DefaultLiquidityPercentageUpdated(defaultLiquidityPercent, percentage);
    defaultLiquidityPercent = percentage;
  }

  function getProfitRecipient(bytes32 /*slug*/) external view
    returns(address)
  {
    // potentially could return different addresses for different token collections
    return(profitRecipient);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IRegistry.sol";

abstract contract AbstractDependant {
  /// @dev keccak256(AbstractDependant.setInjector(address)) - 1
  bytes32 private constant _INJECTOR_SLOT =
  0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

  modifier onlyInjectorOrZero() {
    address _injector = injector();

    require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
    _;
  }

  function setInjector(address _injector) external onlyInjectorOrZero {
    bytes32 slot = _INJECTOR_SLOT;

    assembly {
      sstore(slot, _injector)
    }
  }

  /// @dev has to apply onlyInjectorOrZero() modifier
  function setDependencies(IRegistry) external virtual;

  function injector() public view returns (address _injector) {
    bytes32 slot = _INJECTOR_SLOT;

    assembly {
      _injector := sload(slot)
    }
  }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;

interface IGhostMinter {
  struct Distribution {
    address recipient;
    uint256 amount;
  }

  struct NftIncomeDistribution {
    Distribution RefRewards;
    Distribution Liquidity;
    Distribution Donation;
    Distribution Profit;
  }

  function mintNft(bytes32 slug, uint256 tokenId, address recipient, uint256 amount) external;

  function mintNft(bytes32 slug, uint256 tokenId, address recipient, uint256 amount, address referrer) external;

  function mintOneRandomNft(bytes32 slug, address recipient) external returns(uint256);

  function addReferal(bytes32 slug, address referrer) external;

  function isERC1155(bytes32 slug) external returns(bool);
  
  function isERC721(bytes32 slug) external returns(bool);

  function getNftIncomeDistribution(
    bytes32 slug,
    uint256 tokenId,
    address referrer,
    bytes32 referrerTokenSlug,
    uint256 referrerTokenId
  ) external view returns (NftIncomeDistribution memory nftIncomeDistribution);
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;

import "./IGhostMinter.sol";

interface IDistributionManager {

  function getLiquidityRewards(bytes32 slug, uint256 tokenId) external view returns(IGhostMinter.Distribution memory);

  function getDonationRewards(bytes32 slug) external view returns(IGhostMinter.Distribution memory);

  function getProfitRecipient(bytes32 slug) external view returns(address);

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

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;

interface IRegistry {
    function getERC2981ReceiverAddress() external view returns (address);

    function getGhostMinterContract() external view returns (address);

    function getReferalRewardsContract() external view returns (address);

    function getDistributionManagerContract() external view returns (address);

    function getLiquidityRecipient() external view returns (address);

    function getDonationRecipient() external view returns (address);

    function getProfitRecipient() external view returns (address);

    function getContract(bytes32 slug) external view returns (address);

    function getShops() external view returns (bytes32[] memory);

    function getNfts() external view returns (bytes32[] memory);
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