// SPDX-License-Identifier: MITmont

pragma solidity ^0.8.0;

import "../interfaces/IContractRegistry.sol";
import "../interfaces/IManageableTreasury.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonthlyPayoutController is Ownable {

    event PayoutMade(uint256 amount);

    //----------------- Access control ------------------------------------------
    IContractRegistry contractRegistry;
    bytes32 constant TREASURY_HASH = keccak256(abi.encodePacked('treasury'));

    modifier onlyReceiver() {
        require(msg.sender == receiver);
        _;
    }
    //---------------------------------------------------------------------------

    uint256 public monthlyPaymentAmount;
    address public receiver;
    address public busdAddress;
    uint256 public totalPaidOut;

    uint256 public deploymentTime;

    uint256 constant averageTimePerMonth = 2628000;

    constructor(
        IContractRegistry _contractRegistry,
        address _busdAddress,
        uint256 _monthlyPaymentAmount,
        address _receiver
    ) {
        contractRegistry = _contractRegistry;
        busdAddress = _busdAddress;
        monthlyPaymentAmount = _monthlyPaymentAmount;
        receiver = _receiver;
        deploymentTime = block.timestamp;
    }

    function doThePayout(uint256 amount) external onlyReceiver {

        require(amount <= fundsAvailable(), "not enough funds available");

        totalPaidOut += amount;

        IManageableTreasury treasury = IManageableTreasury(contractRegistry.getContractAddress(TREASURY_HASH));
        treasury.manage(receiver, busdAddress, amount);

        emit PayoutMade(amount);
    }

    function fundsAvailable() public view returns (uint256) {

        uint256 timePassed = block.timestamp - deploymentTime;
        uint256 index = (timePassed / averageTimePerMonth) + 1;

        return (index * monthlyPaymentAmount) - totalPaidOut;
    }

    function destroy() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IMatrix.sol";
import "./ILiquidityController.sol";
import "./IBuybackController.sol";

interface IContractRegistry {

    function contractAddressExists(bytes32 nameHash) external view returns (bool);
    function matrixExists(uint256 level) external view returns (bool);
    function liquidityControllerExists(string calldata name) external view returns (bool);
    function buybackControllerExists(string calldata name) external view returns (bool);
    function priceCalculatorExists(address currency) external view returns (bool);

    function getContractAddress(bytes32 nameHash) external view returns (address);
    function getMatrix(uint256 level) external view returns (IMatrix);
    function getLiquidityController(string calldata name) external view returns (ILiquidityController);
    function getBuybackController(string calldata name) external view returns (IBuybackController);
    function getPriceCalculator(address currency) external view returns (address);
    function isRealmGuardian(address guardianAddress) external view returns (bool);
    function isCoinMaster(address masterAddress) external view returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IManageableTreasury {

    function manage(address to, address token, uint256 amount) external;

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

interface IMatrix {

    event NodeAdded(uint256 indexed nftId, uint256 indexed parentId, uint256 indexed parentLeg);
    event SubtreeNodeAdded(uint256 indexed nftId, uint256 indexed offset, uint256 indexed level);

    struct Node {
        uint256 ID;
        uint256 ParentID;
        uint256 L0;
        uint256 L1;
        uint256 L2;
        uint256 parentLeg;
    }

    function addNode(uint256 nodeId, uint256 parentId) external;
    function getDistributionNodes(uint256 nodeId) external view returns (uint256[] memory distributionNodes);
    function getUsersInLevels(uint256 nodeId, uint256 numberOfLevels) external view returns (uint256[] memory levels, uint256 totalUsers);
    function getSubNodesToLevel(uint256 nodeId, uint256 toDepthLevel) external view returns (Node memory parentNode, Node[] memory subNodes);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILiquidityController {

    event LiquidityProvided(address indexed tokenUsed, uint256 mfiProvided, uint256 liquidityTokensProvided, uint256 lpTokensReceived);
    event LiquidityRemoved(address indexed tokenUsed, uint256 lpTokensRedeemed, uint256 mfiReceived, uint256 liquidityTokensReceived);

    function getLPTokenAddress(address tokenToUse) external view returns (address);
    function claimableTokensFromTreasuryLPTokens(address tokenToUse) external view returns (uint256);
    function mfiRequiredForProvidingLiquidity(address tokenToUse, uint256 amount, uint256 MFIMin) external view returns (uint256);
    function provideLiquidity(address tokenToUse, uint256 amount, uint256 MFIMin) external;
    function removeLiquidity(address tokenToUse, uint256 lpTokenAmount, uint256 tokenMin) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBuybackController {

    event BoughtBackMFI(address indexed token, uint256 tokenAmount, uint256 mfiReceived);

    function buyBackMFI(address token, uint256 tokenAmount, uint256 minMFIOut) external;

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