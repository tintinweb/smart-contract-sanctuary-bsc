pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin-4.6.0/contracts/access/Ownable.sol";
import {KeeperCompatibleInterface} from "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import {Vault} from "./utils/Vault.sol";
import {Pottery} from "./utils/Pottery.sol";
import {IPancakeSwapPotteryVault} from "./interfaces/IPancakeSwapPotteryVault.sol";
import {IPancakeSwapPotteryDraw} from "./interfaces/IPancakeSwapPotteryDraw.sol";
import {IPotteryKeeper} from "./interfaces/IPotteryKeeper.sol";

contract PotteryKeeper is KeeperCompatibleInterface, IPotteryKeeper, Ownable {
    IPancakeSwapPotteryVault[] activeVaults;
    IPancakeSwapPotteryDraw potteryDraw;
    address keeperRegistry;

    event SetKeeperRegistry(address registry, address admin);
    event SetPotteryDraw(address pottery, address admin);
    event AddActiveVault(address vault, address admin);
    event RemoveActiveVault(address vault, address admin);

    modifier onlyKeeperRegistry() {
        require(msg.sender == keeperRegistry, "keepers only");
        _;
    }

    modifier onlyPotteryDrawOrOwner() {
        require(msg.sender == address(potteryDraw) || msg.sender == owner(), "pottery or owner only");
        _;
    }

    constructor(address _potteryDraw, address _registry) {
        require(_potteryDraw != address(0) && _registry != address(0), "zero address");

        potteryDraw = IPancakeSwapPotteryDraw(_potteryDraw);
        keeperRegistry = _registry;
    }

    function getActiveVaults() external view returns (IPancakeSwapPotteryVault[] memory) {
        return activeVaults;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    ) external view override returns (bool upkeepNeeded, bytes memory performData) {
        uint256 vaultPosition;
        for (uint256 i = 0; i < activeVaults.length; i++) {
            IPancakeSwapPotteryVault vault = activeVaults[i];
            if (vault.getStatus() == Vault.Status.BEFORE_LOCK) {
                if (vault.getLockTime() > block.timestamp) continue;
            } else if (vault.getStatus() == Vault.Status.LOCK) {
                if (!vault.passLockTime()) {
                    Pottery.Pot memory pot = potteryDraw.getPot(address(vault));
                    if (pot.numOfDraw >= potteryDraw.getNumOfDraw()) continue;
                    if (pot.startDraw) {
                        Pottery.Draw memory draw = potteryDraw.getDraw(pot.lastDrawId);
                        if (!potteryDraw.timeToDraw(address(vault)) && draw.closeDrawTime != 0) continue;
                        if (!potteryDraw.rngFulfillRandomWords(pot.lastDrawId) && draw.closeDrawTime == 0) continue;
                    } else {
                        if (!potteryDraw.timeToDraw(address(vault))) continue;
                    }
                }
            } else {
                continue;
            }

            vaultPosition = i;
            upkeepNeeded = true;
            break;
        }
        if (upkeepNeeded) performData = abi.encode(vaultPosition);
    }

    function performUpkeep(bytes calldata performData) external override onlyKeeperRegistry {
        uint256 vaultPosition = abi.decode(performData, (uint256));

        IPancakeSwapPotteryVault vault = activeVaults[vaultPosition];
        Vault.Status status = vault.getStatus();

        if (status == Vault.Status.BEFORE_LOCK) vault.lockCake();
        if (status == Vault.Status.LOCK) {
            if (!vault.passLockTime()) {
                Pottery.Pot memory pot = potteryDraw.getPot(address(vault));
                if (pot.startDraw) {
                    Pottery.Draw memory draw = potteryDraw.getDraw(pot.lastDrawId);
                    if (draw.startDrawTime != 0 && draw.closeDrawTime == 0) {
                        potteryDraw.closeDraw(pot.lastDrawId);
                    } else {
                        potteryDraw.startDraw(address(vault));
                    }
                } else {
                    potteryDraw.startDraw(address(vault));
                }
            } else {
                vault.unlockCake();
                popActiveVault(vaultPosition);
            }
        }
    }

    function addActiveVault(address _vault) external override onlyPotteryDrawOrOwner {
        require(_vault != address(0), "zero address");
        activeVaults.push(IPancakeSwapPotteryVault(_vault));

        emit AddActiveVault(_vault, msg.sender);
    }

    function removeActiveVault(address _vault, uint256 _pos) external override onlyPotteryDrawOrOwner {
        require(_vault != address(0), "zero address");
        require(_vault == address(activeVaults[_pos]), "address mismatch");
        popActiveVault(_pos);
    }

    function popActiveVault(uint256 _pos) internal {
        address vault = address(activeVaults[_pos]);
        activeVaults[_pos] = activeVaults[activeVaults.length - 1];
        activeVaults.pop();

        emit RemoveActiveVault(vault, msg.sender);
    }

    function setKeeperRegistry(address _registry) public onlyOwner {
        require(_registry != address(0), "zero address");
        keeperRegistry = _registry;

        emit SetKeeperRegistry(_registry, msg.sender);
    }

    function setPotteryDraw(address _potteryDraw) public onlyOwner {
        require(_potteryDraw != address(0), "zero address");
        potteryDraw = IPancakeSwapPotteryDraw(_potteryDraw);

        emit SetPotteryDraw(_potteryDraw, msg.sender);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KeeperBase.sol";
import "./interfaces/KeeperCompatibleInterface.sol";

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

pragma solidity ^0.8.0;

library Vault {
    enum Status {
        BEFORE_LOCK,
        LOCK,
        UNLOCK
    }
}

pragma solidity ^0.8.0;

import {IPancakeSwapPotteryVault} from "../interfaces/IPancakeSwapPotteryVault.sol";

library Pottery {
    struct Pot {
        uint256 numOfDraw;
        uint256 totalPrize;
        uint256 drawTime;
        uint256 lastDrawId;
        bool startDraw;
    }

    struct Draw {
        uint256 requestId;
        IPancakeSwapPotteryVault vault;
        uint256 startDrawTime;
        uint256 closeDrawTime;
        address[] winners;
        uint256 prize;
    }
}

pragma solidity ^0.8.0;

import {IERC4626} from "./IERC4626.sol";
import {Vault} from "../utils/Vault.sol";

interface IPancakeSwapPotteryVault is IERC4626 {
    function lockCake() external;

    function unlockCake() external;

    function draw(uint256[] memory _nums) external view returns (address[] memory users);

    function getNumberOfTickets(address _user) external view returns (uint256);

    function getLockTime() external view returns (uint256);

    function passLockTime() external view returns (bool);

    function getStatus() external view returns (Vault.Status);

    function generateUserId(address _user) external view returns (bytes32);
}

pragma solidity ^0.8.0;

import "../utils/Pottery.sol";

interface IPancakeSwapPotteryDraw {
    function generatePottery(
        uint256 _totalPrize,
        uint256 _lockTime,
        uint256 _drawTime
    ) external;

    function startDraw(address _vault) external;

    function forceRequestDraw(address _vault) external;

    function closeDraw(uint256 _drawId) external;

    function claimReward() external;

    function timeToDraw(address _vault) external view returns (bool);

    function rngFulfillRandomWords(uint256 _drawId) external view returns (bool);

    function getWinners(uint256 _drawId) external view returns (address[] memory);

    function getDraw(uint256 _drawId) external view returns (Pottery.Draw memory);

    function getPot(address _vault) external view returns (Pottery.Pot memory);

    function getNumOfDraw() external view returns (uint8);

    function getNumOfWinner() external view returns (uint8);

    function getPotteryPeriod() external view returns (uint256);

    function getTreasury() external view returns (address);
}

pragma solidity ^0.8.0;

interface IPotteryKeeper {
    function addActiveVault(address _vault) external;

    function removeActiveVault(address _vault, uint256 _pos) external;
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
pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC4626 {
    function asset() external view returns (address assetTokenAddress);

    function totalAssets() external view returns (uint256 totalManagedAssets);

    function convertToShares(uint256 assets) external view returns (uint256 shares);

    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function maxMint(address receiver) external view returns (uint256 maxShares);

    function previewMint(uint256 shares) external view returns (uint256 assets);

    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    function maxRedeem(address owner) external view returns (uint256 maxShares);

    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
}