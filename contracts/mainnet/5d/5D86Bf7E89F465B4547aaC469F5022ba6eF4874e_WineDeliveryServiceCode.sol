// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./interfaces/IWineManager.sol";
import "./interfaces/IWineFactory.sol";
import "./interfaces/IWinePool.sol";
import "./interfaces/IWinePoolFull.sol";
import "./interfaces/IWineDeliveryService.sol";
import "./vendors/access/ManagerLikeOwner.sol";
import "./vendors/security/ReentrancyGuardInitializable.sol";
import "./vendors/utils/ERC721OnlySelfInitHolder.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./interfaces/IBordeauxCityBondIntegration.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract WineDeliveryServiceCode is
    ManagerLikeOwner,
    Initializable,
    ReentrancyGuardInitializable,
    ERC721OnlySelfInitHolder,
    IWineDeliveryService
{
    using SafeERC20 for IERC20;

    function initialize(
        address manager_
    )
        override
        public
        initializer
    {
        _initializeManager(manager_);
        _initializeReentrancyGuard();
    }

//////////////////////////////////////// fields definition

    // poolId => UnixTime(BeginOfDelivery)
    mapping(uint256 => uint256) public override getPoolDateBeginOfDelivery;

    uint256 private availableDeliveryTaskId = 1;
    // poolId => tokenId => deliveryTaskId`s
    mapping(uint256 => mapping(uint256 => uint256[])) private deliveryTasksHistory;
    // deliveryTaskId => deliveryTask
    mapping(uint256 => DeliveryTask) private deliveryTasks;
    uint256 bcbAmountSum = 0;

//////////////////////////////////////// DeliverySettings

    modifier allowedDelivery(uint256 poolId) {
        require(getPoolDateBeginOfDelivery[poolId] != 0, "allowedDelivery: DateBeginOfDelivery not set yet");
        require(getPoolDateBeginOfDelivery[poolId] < block.timestamp, "allowedDelivery: not allowed yet");
        _;
    }

    function _editPoolDateBeginOfDelivery(
        uint256 poolId,
        uint256 dateBegin
    )
        override
        public
        onlyManager
    {
        require(IWineManager(manager()).getPoolAddress(poolId) != address(0), "editPoolDateBeginOfDelivery - poolIdNotExists");
        getPoolDateBeginOfDelivery[poolId] = dateBegin;
    }

//////////////////////////////////////// DeliveryTasks inner methods
    function _getLastDeliveryTaskId(uint256 poolId, uint256 tokenId)
        internal
        view
        returns (uint256)
    {
        uint256 deliveryTasksHistoryLength = deliveryTasksHistory[poolId][tokenId].length;
        if (deliveryTasksHistoryLength == 0) {
            return 0;
        }
        return deliveryTasksHistoryLength - 1;
    }

    function _createDeliveryTask(
        uint256 poolId,
        uint256 tokenId,
        address tokenOwner,
        bool isInternal,
        string memory deliveryData
    )
        internal
        returns (uint256 deliveryTaskId)
    {
        availableDeliveryTaskId++;
        deliveryTaskId = availableDeliveryTaskId - 1;

        deliveryTasks[deliveryTaskId] = DeliveryTask({
            tokenOwner: tokenOwner,
            isInternal: isInternal,
            deliveryData: deliveryData,
            supportResponse: "",
            status: DeliveryTaskStatus.New,
            amount: 0,
            bcbAmount: 0
        });
        deliveryTasksHistory[poolId][tokenId].push(deliveryTaskId);

        emit CreateDeliveryRequest(
            deliveryTaskId,
            poolId,
            tokenId,
            tokenOwner,
            isInternal
        );
    }

    function _getDeliveryTask(
        uint256 deliveryTaskId
    )
        internal
        view
        returns (DeliveryTask memory)
    {
        DeliveryTask memory deliveryTask = deliveryTasks[deliveryTaskId];
        require(deliveryTask.tokenOwner != address(0), "showSingleDelivery: deliveryTask not exists");
        require(
            _msgSender() == manager() || (deliveryTask.isInternal == false && _msgSender() == deliveryTask.tokenOwner),
            "showSingleDelivery: Permission denied"
        );
        return deliveryTask;
    }

//////////////////////////////////////// DeliveryTasks view methods

    function showSingleDeliveryTask(
        uint256 deliveryTaskId
    )
        override
        public
        view
        returns (DeliveryTask memory)
    {
        return _getDeliveryTask(deliveryTaskId);
    }

    function showLastDeliveryTask(
        uint256 poolId,
        uint256 tokenId
    )
        override
        public
        view
        returns (uint256, DeliveryTask memory)
    {
        uint256 deliveryTaskId = _getLastDeliveryTaskId(poolId, tokenId);
        return (deliveryTaskId, _getDeliveryTask(deliveryTaskId));
    }

    function showFullHistory(
        uint256 poolId,
        uint256 tokenId
    )
        override
        public
        view
        onlyManager
        returns (uint256, DeliveryTask[] memory)
    {
        uint256 historyLength = deliveryTasksHistory[poolId][tokenId].length;
        DeliveryTask[] memory history = new DeliveryTask[](historyLength);

        for (uint256 i = 0; i < historyLength; i++) {
            history[i] = _getDeliveryTask(deliveryTasksHistory[poolId][tokenId][i]);
        }

        return(historyLength, history);
    }

//////////////////////////////////////// BCB methods

    function getCurrency()
        public
        view
        returns (IERC20)
    {
        return __getIBordeauxCityBondIntegration().getCurrency();
    }

    function calculateStoragePrice(
        uint256 poolId,
        uint256 tokenId
    )
        public
        view
        returns (uint256)
    {
        return __getIBordeauxCityBondIntegration().calculateStoragePrice(poolId, tokenId, true);
    }

    function __getIBordeauxCityBondIntegration()
        private
        view
        returns (IBordeauxCityBondIntegration)
    {
        return IBordeauxCityBondIntegration(IWineManager(manager()).bordeauxCityBond());
    }

//////////////////////////////////////// DeliveryTasks edit methods

    function requestDelivery(
        uint256 poolId,
        uint256 tokenId,
        string memory deliveryData
    )
        override
        public
        returns (uint256 deliveryTaskId)
    {
        IWinePoolFull pool = IWineManager(manager()).getPoolAsContract(poolId);

        address tokenOwner = _msgSender();
        pool.safeTransferFrom(tokenOwner, address(this), tokenId);

        deliveryTaskId = _createDeliveryTask(
            poolId,
            tokenId,
            tokenOwner,
            false,
            deliveryData
        );
    }

    function requestDeliveryForInternal(
        uint256 poolId,
        uint256 tokenId,
        string memory deliveryData
    )
        override
        public
        onlyManager
        returns (uint256 deliveryTaskId)
    {
        IWinePoolFull pool = IWineManager(manager()).getPoolAsContract(poolId);

        address tokenOwner = pool.internalOwnedTokens(tokenId);
        pool.transferInternalToOuter(tokenOwner, address(this), tokenId);

        deliveryTaskId = _createDeliveryTask(
            poolId,
            tokenId,
            tokenOwner,
            true,
            deliveryData
        );
    }

    function setDeliveryTaskAmount(
        uint256 poolId,
        uint256 tokenId,
        uint256 amount
    )
        override
        public
        onlyManager nonReentrant
    {
        uint256 deliveryTaskId = _getLastDeliveryTaskId(poolId, tokenId);
        DeliveryTask storage deliveryTask = deliveryTasks[deliveryTaskId];
        require(deliveryTask.tokenOwner != address(0), "setSupportResponse: deliveryTask not exists");
        require(deliveryTask.status == DeliveryTaskStatus.New || deliveryTask.status == DeliveryTaskStatus.WaitingForPayment, "setSupportResponse: status not allowed");

        deliveryTask.amount = amount;
        deliveryTask.bcbAmount = calculateStoragePrice(poolId, tokenId);
        deliveryTask.status = DeliveryTaskStatus.WaitingForPayment;

        emit SetDeliveryTaskAmount(
            deliveryTaskId,
            poolId,
            tokenId,
            deliveryTask.amount,
            deliveryTask.bcbAmount
        );
    }

    function payDeliveryTaskAmount(
        uint256 poolId,
        uint256 tokenId
    )
        override
        public
        nonReentrant
    {
        uint256 deliveryTaskId = _getLastDeliveryTaskId(poolId, tokenId);
        DeliveryTask storage deliveryTask = deliveryTasks[deliveryTaskId];
        require(deliveryTask.tokenOwner != address(0), "setSupportResponse: deliveryTask not exists");
        require(deliveryTask.isInternal == false, "payDeliveryTaskAmountInternal: only for isInternal = false allowed");
        require(deliveryTask.status == DeliveryTaskStatus.WaitingForPayment, "payDeliveryTaskAmount: status not allowed");
        
        deliveryTask.status = DeliveryTaskStatus.DeliveryInProcess;

        emit PayDeliveryTaskAmount(
            deliveryTaskId,
            poolId,
            tokenId,
            deliveryTask.isInternal,
            deliveryTask.amount,
            deliveryTask.bcbAmount
        );

        IERC20 currency = getCurrency();
        currency.safeTransferFrom(_msgSender(), address(this), deliveryTask.amount + deliveryTask.bcbAmount);
        bcbAmountSum += deliveryTask.bcbAmount;
    }

    function payDeliveryTaskAmountInternal(
        uint256 poolId,
        uint256 tokenId
    )
        override
        public
        onlyManager nonReentrant
    {
        uint256 deliveryTaskId = _getLastDeliveryTaskId(poolId, tokenId);
        DeliveryTask storage deliveryTask = deliveryTasks[deliveryTaskId];
        require(deliveryTask.tokenOwner != address(0), "payDeliveryTaskAmountInternal: deliveryTask not exists");
        require(deliveryTask.isInternal == true, "payDeliveryTaskAmountInternal: only for isInternal = true allowed");
        require(deliveryTask.status == DeliveryTaskStatus.WaitingForPayment, "payDeliveryTaskAmountInternal: status not allowed");

        deliveryTask.status = DeliveryTaskStatus.DeliveryInProcess;

        emit PayDeliveryTaskAmount(
            deliveryTaskId,
            poolId,
            tokenId,
            deliveryTask.isInternal,
            deliveryTask.amount,
            deliveryTask.bcbAmount
        );
    }

    function cancelDeliveryTask(
        uint256 poolId,
        uint256 tokenId,
        string memory supportResponse
    )
        override
        public
        nonReentrant
    {
        uint256 deliveryTaskId = _getLastDeliveryTaskId(poolId, tokenId);
        DeliveryTask storage deliveryTask = deliveryTasks[deliveryTaskId];
        require(deliveryTask.tokenOwner != address(0), "cancelDeliveryTask: deliveryTask not exists");
        require(
            deliveryTask.status == DeliveryTaskStatus.New ||
            deliveryTask.status == DeliveryTaskStatus.WaitingForPayment ||
            deliveryTask.status == DeliveryTaskStatus.DeliveryInProcess
            ,
            "cancelDeliveryTask: status not allowed"
        );
        require(
            deliveryTask.status != DeliveryTaskStatus.DeliveryInProcess || _msgSender() == manager() 
            ,
            "cancelDeliveryTask: cancel of Task in status DeliveryInProcess allowed only to Manager"
        );

        IWinePoolFull pool = IWineManager(manager()).getPoolAsContract(poolId);
        if (deliveryTask.isInternal) {
            pool.transferOuterToInternal(address(this), deliveryTask.tokenOwner, tokenId);
        } else {
            pool.safeTransferFrom(address(this), deliveryTask.tokenOwner, tokenId);
            if (deliveryTask.status == DeliveryTaskStatus.DeliveryInProcess) {
                getCurrency().safeTransfer(deliveryTask.tokenOwner, deliveryTask.amount + deliveryTask.bcbAmount);
            }
        }
        
        deliveryTask.supportResponse = supportResponse;
        deliveryTask.status = DeliveryTaskStatus.Canceled;

        emit CancelDeliveryTask(
            deliveryTaskId,
            poolId,
            tokenId
        );
    }

    function finishDeliveryTask(
        uint256 poolId,
        uint256 tokenId,
        string memory supportResponse
    )
        override
        public
        onlyManager nonReentrant
    {
        uint256 deliveryTaskId = _getLastDeliveryTaskId(poolId, tokenId);
        DeliveryTask storage deliveryTask = deliveryTasks[deliveryTaskId];
        require(deliveryTask.tokenOwner != address(0), "showSingleDelivery: deliveryTask not exists");
        require(deliveryTask.status == DeliveryTaskStatus.DeliveryInProcess, "finishDeliveryTask: status not allowed");

        deliveryTask.supportResponse = supportResponse;
        deliveryTask.status = DeliveryTaskStatus.Executed;
        if (!deliveryTask.isInternal) {
            getCurrency().safeTransfer(address(__getIBordeauxCityBondIntegration()), deliveryTask.bcbAmount);
            bcbAmountSum -= deliveryTask.bcbAmount;
        }

        IWinePoolFull pool = IWineManager(manager()).getPoolAsContract(poolId);
        pool.burn(tokenId);
    }

//////////////////////////////////////// DeliveryTasks withdraw payment amount

    function withdrawPaymentAmount(address to)
        override
        public
        onlyManager nonReentrant
    {
        IERC20 currency = getCurrency();
        uint256 balance = currency.balanceOf(address(this));
        currency.safeTransfer(to, balance - bcbAmountSum);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts only self initiated token transfers.
 */
abstract contract ERC721OnlySelfInitHolder is IERC721Receiver {

    function onERC721Received(
        address operator,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (operator == address(this)) {
            return this.onERC721Received.selector;
        }
        return bytes4(0);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuardInitializable {
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

    function _initializeReentrancyGuard()
        internal
    {
        _status = _NOT_ENTERED;
    }


    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an manager) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the manager account will be the one that deploys the contract. This
 * can later be changed with {transferManagership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyManager`, which can be applied to your functions to restrict their use to
 * the manager.
 */
contract ManagerLikeOwner is Context {
    address private _manager;

    event ManagershipTransferred(address indexed previousManager, address indexed newManager);

    /**
     * @dev Initializes the contract setting the deployer as the initial manager.
     */
    function _initializeManager(address manager_)
        internal
    {
        _transferManagership(manager_);
    }

    /**
     * @dev Returns the address of the current manager.
     */
    function manager()
        public view
        returns (address)
    {
        return _manager;
    }

    /**
     * @dev Throws if called by any account other than the manager.
     */
    modifier onlyManager() {
        require(_manager == _msgSender(), "ManagerIsOwner: caller is not the manager");
        _;
    }

    /**
     * @dev Leaves the contract without manager. It will not be possible to call
     * `onlyManager` functions anymore. Can only be called by the current manager.
     *
     * NOTE: Renouncing managership will leave the contract without an manager,
     * thereby removing any functionality that is only available to the manager.
     */
    function renounceManagership()
        virtual
        public
        onlyManager
    {
        _beforeTransferManager(address(0));

        emit ManagershipTransferred(_manager, address(0));
        _manager = address(0);
    }

    /**
     * @dev Transfers managership of the contract to a new account (`newManager`).
     * Can only be called by the current manager.
     */
    function transferManagership(address newManager)
        virtual
        public
        onlyManager
    {
        _transferManagership(newManager);
    }

    function _transferManagership(address newManager)
        virtual
        internal
    {
        require(newManager != address(0), "ManagerIsOwner: new manager is the zero address");
        _beforeTransferManager(newManager);

        emit ManagershipTransferred(_manager, newManager);
        _manager = newManager;
    }

    /**
     * @dev Hook that is called before manger transfer. This includes initialize and renounce
     */
    function _beforeTransferManager(address newManager)
        virtual
        internal
    {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IWinePool.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";


interface IWinePoolFull is IERC165, IERC721, IERC721Metadata, IWinePool
{
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWinePool
{
//////////////////////////////////////// DescriptionFields

    function updateAllDescriptionFields(
        string memory wineName,
        string memory wineProductionCountry,
        string memory wineProductionRegion,
        string memory wineProductionYear,
        string memory wineProducerName,
        string memory wineBottleVolume,
        string memory linkToDocuments
    ) external;
    function editDescriptionField(bytes32 param, string memory value) external;

//////////////////////////////////////// System fields

    function getPoolId() external view returns (uint256);
    function getMaxTotalSupply() external view returns (uint256);
    function getWinePrice() external view returns (uint256);

    function editMaxTotalSupply(uint256 value) external;
    function editWinePrice(uint256 value) external;

//////////////////////////////////////// Pausable

    function pause() external;
    function unpause() external;

//////////////////////////////////////// Initialize

    function initialize(
        string memory name,
        string memory symbol,

        address manager,

        uint256 poolId,
        uint256 maxTotalSupply,
        uint256 winePrice
    ) external payable returns (bool);

//////////////////////////////////////// Disable

    function disabled() external view returns (bool);

    function disablePool() external;

//////////////////////////////////////// default methods

    function tokensCount() external view returns (uint256);

    function burn(uint256 tokenId) external;

    function mint(address to) external;

//////////////////////////////////////// internal users and tokens


    event WinePoolMintToken(address to, uint256 tokenId, uint256 poolId);
    event WinePoolMintTokenToInternal(address to, uint256 tokenId, uint256 poolId);
    event OuterToInternalTransfer(address from, address to, uint256 tokenId, uint256 poolId);
    event InternalToInternalTransfer(address from, address to, uint256 tokenId, uint256 poolId);
    event InternalToOuterTransfer(address from, address to, uint256 tokenId, uint256 poolId);

    function internalUsersExists(address) external view returns (bool);
    function internalOwnedTokens(uint256) external view returns (address);

    function mintToInternalUser(address internalUser) external;

    function transferInternalToInternal(address internalFrom, address internalTo, uint256 tokenId) external;

    function transferOuterToInternal(address outerFrom, address internalTo, uint256 tokenId) external;

    function transferInternalToOuter(address internalFrom, address outerTo, uint256 tokenId) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerPoolIntegration {

    function allowMint(address) external view returns (bool);
    function allowInternalTransfers(address) external view returns (bool);
    function allowBurn(address) external view returns (bool);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerMarketPlaceIntegration {

    function marketPlace() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerFirstSaleMarketIntegration {

    function firstSaleMarket() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IWinePoolFull.sol";

interface IWineManagerFactoryIntegration {

    event WinePoolCreated(uint256 poolId, address winePool);

    function factory() external view returns (address);

    function getPoolAddress(uint256 poolId) external view returns (address);

    function getPoolAsContract(uint256 poolId) external view returns (IWinePoolFull);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerDeliveryServiceIntegration {

    function deliveryService() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerBordeauxCityBondIntegration {

    function bordeauxCityBond() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IWineManagerFactoryIntegration.sol";
import "./IWineManagerFirstSaleMarketIntegration.sol";
import "./IWineManagerMarketPlaceIntegration.sol";
import "./IWineManagerDeliveryServiceIntegration.sol";
import "./IWineManagerPoolIntegration.sol";
import "./IWineManagerBordeauxCityBondIntegration.sol";

interface IWineManager is
    IWineManagerFactoryIntegration,
    IWineManagerFirstSaleMarketIntegration,
    IWineManagerMarketPlaceIntegration,
    IWineManagerDeliveryServiceIntegration,
    IWineManagerPoolIntegration,
    IWineManagerBordeauxCityBondIntegration
{

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineFactory {

    function winePoolCode() external view returns (address);
    function baseUri() external view returns (string memory);
    function baseSymbol() external view returns (string memory);

    function initialize(
        address proxyAdmin_,
        address winePoolCode_,
        address manager_,
        string memory baseUri_,
        string memory baseSymbol_
    ) external;

    function getPool(uint256 poolId) external view returns (address);

    function allPoolsLength() external view returns (uint);

    function createWinePool(
        string memory name_,

        uint256 maxTotalSupply_,
        uint256 winePrice_
    ) external returns (uint256 poolId, address winePoolAddress);

    function disablePool(uint256 poolId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineDeliveryService {

    function initialize(
        address manager_
    ) external;

//////////////////////////////////////// DeliverySettings

    function getPoolDateBeginOfDelivery(uint256 poolId) external view returns (uint256);

    function _editPoolDateBeginOfDelivery(uint256 poolId, uint256 dateBegin) external;

//////////////////////////////////////// structs

    enum DeliveryTaskStatus {
        New,
        Canceled,
        Executed,
        WaitingForPayment,
        DeliveryInProcess
    }

    struct DeliveryTask {
        address tokenOwner;
        bool isInternal;
        string deliveryData;
        string supportResponse;
        DeliveryTaskStatus status;
        uint256 amount;
        uint256 bcbAmount;
    }

//////////////////////////////////////// events

    event CreateDeliveryRequest(
        uint256 deliveryTaskId,
        uint256 poolId,
        uint256 tokenId,
        address tokenOwner,
        bool isInternal
    );

    event SetDeliveryTaskAmount(
        uint256 deliveryTaskId,
        uint256 poolId,
        uint256 tokenId,
        uint256 amount,
        uint256 bcbAmount
    );

    event PayDeliveryTaskAmount(
        uint256 deliveryTaskId,
        uint256 poolId,
        uint256 tokenId,
        bool isInternal,
        uint256 amount,
        uint256 bcbAmount
    );

    event CancelDeliveryTask(
        uint256 deliveryTaskId,
        uint256 poolId,
        uint256 tokenId
    );

//////////////////////////////////////// DeliveryTasks public methods

    function requestDelivery(uint256 poolId, uint256 tokenId, string memory deliveryData) external returns (uint256 deliveryTaskId);

    function requestDeliveryForInternal(uint256 poolId, uint256 tokenId, string memory deliveryData) external returns (uint256 deliveryTaskId);

    function showSingleDeliveryTask(uint256 deliveryTaskId) external view returns (DeliveryTask memory);

    function showLastDeliveryTask(uint256 poolId, uint256 tokenId) external view returns (uint256, DeliveryTask memory);

    function showFullHistory(uint256 poolId, uint256 tokenId) external view returns (uint256, DeliveryTask[] memory);

    function setDeliveryTaskAmount(uint256 poolId, uint256 tokenId, uint256 amount) external;

    function payDeliveryTaskAmount(uint256 poolId, uint256 tokenId) external;

    function payDeliveryTaskAmountInternal(uint256 poolId, uint256 tokenId) external;

    function cancelDeliveryTask(uint256 poolId, uint256 tokenId, string memory supportResponse) external;

    function finishDeliveryTask(uint256 poolId, uint256 tokenId, string memory supportResponse) external;

//////////////////////////////////////// DeliveryTasks withdraw payment amount

    function withdrawPaymentAmount(address to) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBordeauxCityBondIntegration {

    function BCBOutFee() external view returns (uint256);
    function BCBFixedFee() external view returns (uint256);
    function BCBFlexedFee() external view returns (uint256);

    function initialize(
        address manager_,
        uint256 BCBOutFee_,
        uint256 BCBFixedFee_,
        uint256 BCBFlexedFee_
    ) external;

//////////////////////////////////////// Settings
    function _editBCBOutFee(uint256 BCBOutFee_) external;

    function _editBCBFixedFee(uint256 BCBFixedFee_) external;

    function _editBCBFlexedFee(uint256 BCBFlexedFee_) external;

//////////////////////////////////////// Owner

    function getCurrency() external view returns (IERC20);

    function calculateStoragePrice(uint256 poolId, uint256 tokenId, bool withBCBOut) external view returns (uint256);

    function onMint(uint256 poolId, uint256 tokenId) external;

    function onOrderExecute(uint256 poolId, uint256 tokenId) external;

    function onRequestDelivery(uint256 poolId, uint256 tokenId) external;

//////////////////////////////////////// Owner

    function withdrawBCBFee(address to, uint256 amount) external;

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

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}