// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../erc/erc1155/IERC1155Upgradeable.sol";
import "../erc/erc1155/IERC1155ReceiverUpgradeable.sol";
import "./interface/IERC20Token.sol";
import "./interface/ISandwichesERC1155.sol";
import "./interface/ITableclothERC1155.sol";
import "./interface/ITableclothAwardsPool.sol";
import "./access/AccessControlUpgradeable.sol";
import "../proxy/utils/Initializable.sol";
import "./interface/IQualifying.sol";
import "./interface/IRandoms.sol";
import "./random/Random.sol";
import "../lib/SafeERC20.sol";

/**
 * @dev This is the implement of qualifying interface
 */
contract Qualifying is Initializable, AccessControlUpgradeable, IQualifying, IERC1155ReceiverUpgradeable{

    
    struct Invader{
        uint256 bounty;
        string name;
        uint16 race;
        // 0 normal 1 on battle 2 defeated
        uint16 status;
    }

    struct Battle{
        uint256 invaderId;
        uint128[] tableclothTypes;
        uint128 endTime;
        uint256 maxASandwich;
        uint256 maxDSandwich;
        uint256 maxHSandwich;
        uint256 generalSandwich;
        uint256 luckyDog;
        uint16[] attrs;
        uint16[] allowedAttrs;
        uint256[] sandwiches;
    }

    struct BattleMaxPower{
        uint256 maxA;
        uint256 maxD;
        uint256 maxH;
        uint256 maxS;
    }

    struct SandwichInfo{
        uint256 battleId;
        uint256 index;
    }

    uint256 private idIndex;
    uint256 public battleTimelock;
    uint256 public heroNumber;

    bytes32 public constant BATTLE_MANAGER_ROLE = keccak256("BATTLE_MANAGER_ROLE");

    IERC20Token public chiCoinERC20;
    ITableclothERC1155 public tableclothERC1155;
    ISandwichesERC1155 public sandwichERC1155;
    IRandoms public seedBiulder;
    ITableclothAwardsPool public tableClothAwardsPool;

    uint16 public constant STATUS_INVADER_NORMAL = 0;
    uint16 public constant STATUS_INVADER_ONBATTLE = 1;
    uint16 public constant STATUS_INVADER_DEFEATED = 2;
    
    mapping(uint256 => Invader) public invadersMapping;
    mapping(uint256 => Battle) public battlesMapping;
    mapping(uint256 => BattleMaxPower) public battlesMaxPowerMapping;
    // This array will record all battle's id.
    uint256[] public battleIds;
    // battle => remaining bonus
    mapping(uint256 => uint256) public battleAwards;
    // sandwichId => SandwichInfo
    mapping(uint256 => SandwichInfo) public sandwichInfoMapping;
    // sandwichId => holder address
    mapping(uint256 => address) public sandwichHolderMapping;
    // batlle => user address => user sandwichs
    mapping(uint256 => mapping(address => uint256[])) public battleUserSandwichsMapping;
    // This mapping is recording which sandwich was dead.
    mapping(uint256 => bool) private deadSandwichs;

    /**
     * @dev Initialization constructor related parameters
     */
    function initialize(address _tableclothERC1155, address _sandwichERC1155,address _tableClothAwardsPool, address _chiCoinERC20, address _seedBiulder) public initializer{
        tableclothERC1155 = ITableclothERC1155(_tableclothERC1155);
        chiCoinERC20 = IERC20Token(_chiCoinERC20);
        sandwichERC1155 = ISandwichesERC1155(_sandwichERC1155);
        seedBiulder = IRandoms(_seedBiulder);
        tableClothAwardsPool = ITableclothAwardsPool(_tableClothAwardsPool);
        // medalERC1155 = IERC1155Upgradeable(_medalERC1155);

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Set the random seed biulder
     */
    function setRandomSeedBiulder(address _seedBiulder) onlyRole(DEFAULT_ADMIN_ROLE) external {
        seedBiulder = IRandoms(_seedBiulder);
    }


    /**
     * @dev TODO Test code, will be removed.
     */
    function setTimelockAndHeroNumber(uint256 _battleTimelock, uint256 _heroNumber) onlyRole(DEFAULT_ADMIN_ROLE) external {
        battleTimelock = _battleTimelock;
        heroNumber = _heroNumber;
    }

    /**
     *  @dev Create a new battle.
     * only permit admin role
     */
    function create(uint256 invaderId, uint128[] memory tableclothTypes) external override onlyRole(BATTLE_MANAGER_ROLE){
        require(invaderId!= 0 && tableclothTypes.length > 0 && tableclothTypes.length <= 5, "Invalid parameters");
        require(invadersMapping[invaderId].status == STATUS_INVADER_NORMAL, "Invader is on battle or defeated");
        nextId();
        // add battle id to array
        battleIds.push(idIndex);

        battlesMapping[idIndex].invaderId = invaderId;
        battlesMapping[idIndex].tableclothTypes = tableclothTypes;

        for(uint i = 0; i < tableclothTypes.length; ++i){
            (,,,,,,uint16 attrnum,) = tableclothERC1155.getTypeDetails(tableclothTypes[i]);
            battlesMapping[idIndex].attrs.push(attrnum);
            battlesMapping[idIndex].allowedAttrs.push(tableclothERC1155.getAttributesEnemy(attrnum));
        }

        emit BattleCreated(idIndex, invaderId);
    }
    /**
     *  @dev join a battle.
     */
    function join(uint256 battleId, uint256 sandwichId) external override{
        Battle storage battle = battlesMapping[battleId];
        require(battle.endTime == 0, "Member is full, battle has already begun");
        sandwichHolderMapping[sandwichId] = _msgSender();
        battleUserSandwichsMapping[battleId][_msgSender()].push(sandwichId);
        battle.sandwiches.push(sandwichId);

        sandwichInfoMapping[sandwichId].battleId = battleId;
        sandwichInfoMapping[sandwichId].index = battle.sandwiches.length;
        // calculate max value and general
        {
            BattleMaxPower memory battleMaxPower = battlesMaxPowerMapping[battleId];
            ( , , uint256 aggressivity, uint256 defensive, uint256 healthPoint,
             , , , , uint16 attrnum) = sandwichERC1155.getSandwich(sandwichId);

            // judge attrs validity
            for(uint i = 0; i < battle.allowedAttrs.length; ++i)
                if(attrnum == battle.allowedAttrs[i]){
                    attrnum = 0;
                    break;
                }
            require(attrnum == 0, "Sandwich attributes does not fit");
            if(aggressivity > battleMaxPower.maxA){
                battleMaxPower.maxA = aggressivity;
                battle.maxASandwich = sandwichId;
            }
            if(defensive > battleMaxPower.maxD){
                battleMaxPower.maxD = defensive;
                battle.maxDSandwich = sandwichId;
            }
            if(healthPoint > battleMaxPower.maxH){
                battleMaxPower.maxH = healthPoint;
                battle.maxHSandwich = sandwichId;
            }
            // judge general sandwich
            if(battle.sandwiches.length > battleMaxPower.maxS){
                battleMaxPower.maxS = battle.sandwiches.length;
                battle.generalSandwich = sandwichId;
            }

            battlesMaxPowerMapping[battleId] = battleMaxPower;
        }
        if(battle.sandwiches.length >= heroNumber) _startBattle(battleId);

        // transfer sandwich to contract
        IERC1155Upgradeable(address(sandwichERC1155)).safeTransferFrom(_msgSender(), address(this), sandwichId, 1, "");
        emit JoinBattle(battleId, sandwichId);
    }

    function _startBattle(uint256 battleId) internal{
        // endtime = current block timestamp + 4320000 = 3600*24*50 s ;
        battlesMapping[battleId].endTime = uint128(block.timestamp + battleTimelock);
        invadersMapping[battlesMapping[battleId].invaderId].status = STATUS_INVADER_ONBATTLE;
        emit BattleStart(battleId);
    }

    function _battleEnded(uint256 battleId) internal{
        Battle storage battle = battlesMapping[battleId];
        // judge battle status
        if(invadersMapping[battle.invaderId].status == STATUS_INVADER_ONBATTLE){
             _beatInvader(battle.invaderId);
            uint256 seed = seedBiulder.getRandomSeed(_msgSender());
            uint8 luckyIndex = Random.createRandom(1, battle.sandwiches.length, seed, battleId) - 1;
            battle.luckyDog = battle.sandwiches[luckyIndex];
            deadSandwichs[1] = true;
            // init dead sandwich
            // {
            //     uint deadIndex = Random.createRandom(1, 10, seed, luckyIndex) - 1;
            //     for(uint i = 0; i < battle.sandwiches.length; ++i){
            //         deadSandwichs[battle.sandwiches[i * 10 + deadIndex]] = true;
            //     }
            // }
            emit BattleEnd(battleId);
            // get awards number
            battleAwards[battleId] = invadersMapping[battle.invaderId].bounty - 16000000 ether;
            // add awrds to tablecloth awardspool
            SafeERC20.safeApprove(chiCoinERC20, address(tableClothAwardsPool), 16000000 ether);
            tableClothAwardsPool.addAwards(address(this), tableClothAwardsPool.AWARDS_TYPE_BATTLE(), battlesMapping[battleId].tableclothTypes, 16000000 ether);
        }
    }

    function finish(uint256 battleId) external override {
        _battleEnded(battleId);
    }

    /**
     *  @dev withDraw your sandwich and get awards.
     */
    function withDraw(uint256 sandwichId) external override{
        uint256 battleId = sandwichInfoMapping[sandwichId].battleId;
        require(battleId != 0, "The battle is not exist");
        require(block.timestamp >= battlesMapping[battleId].endTime, "The battle is not over");
        require(sandwichHolderMapping[sandwichId] == _msgSender(), "Only owner can withdraw sandwich");
        sandwichHolderMapping[sandwichId] = address(0);
        _battleEnded(battleId);
        if(deadSandwichs[sandwichId]){
            sandwichERC1155.burn(sandwichId, _msgSender());
        }else{
            // transfer sandwich to holder
            IERC1155Upgradeable(address(sandwichERC1155)).safeTransferFrom(address(this), _msgSender(), sandwichId, 1, "");
        }

        uint256 awards = _calculateAwards(battleId, sandwichId);
        // uint256 awards = 2000000 ether;
        battleAwards[battleId] -= awards;
        SafeERC20.safeTransfer(chiCoinERC20, _msgSender(), awards);
        emit WithDraw(battleId, sandwichId, awards);
    }

    /**
     *  @dev get awards amount of sandwich.
     */
    function calculateAwards(uint256 sandwichId) external view override returns(uint256){
        return _calculateAwards(sandwichInfoMapping[sandwichId].battleId, sandwichId);
    }

    function _calculateAwards(uint256 battleId, uint256 sandwichId) internal view returns(uint256 awards){
        Battle storage battle = battlesMapping[battleId];
        if(block.timestamp < battle.endTime) return 0;
        uint256 total = invadersMapping[battle.invaderId].bounty - 16000000 ether;
        // fixed awards total * 50% / sandwichs number 100
        awards += total / 2 / 100;
        // rank awards total * 15% / 40 or 60, this depends on sandwich's index at array
        awards += total * 15 / 100 / (sandwichInfoMapping[sandwichId].index <= 40? 40 : 60);
        // if it's first sandwich, append total * 3%
        if(sandwichInfoMapping[sandwichId].index == 1) awards += total * 3 / 100;
        // if it's lucky dog, append total * 7%
        if(sandwichId == battle.luckyDog) awards += total * 7 / 100;
        // if it's general, append total * 7%
        if(sandwichId == battle.generalSandwich) awards += total * 7 / 100;
        // if it's max aggressivity, append total * 1%
        if(sandwichId == battle.maxASandwich) awards += total / 100;
        // if it's max defensive, append total * 1%
        if(sandwichId == battle.maxDSandwich) awards += total / 100;
        // if it's max healthPoint, append total * 1%
        if(sandwichId == battle.maxHSandwich) awards += total / 100;
    }

    /**
     *  @dev withDraw your sandwich while emergency situations, give up awards.
     */
    function urgentWithDraw(uint256 sandwichId) external override{
        uint256 battleId = sandwichInfoMapping[sandwichId].battleId;
        require(sandwichHolderMapping[sandwichId] == _msgSender(), "Only owner can withdraw sandwich");
        sandwichHolderMapping[sandwichId] = address(0);
        delete sandwichInfoMapping[sandwichId];

        // transfer sandwich to holder
        IERC1155Upgradeable(address(sandwichERC1155)).safeTransferFrom(address(this), _msgSender(), sandwichId, 1, "");
        emit WithDraw(battleId, sandwichId, 0);
    }

    /**
     *  @dev Add a Invader.
     * You need to pay awardsAmounts amount of chi while create invader. awardsAmounts will alloc to player and tablecloth holder when a battle ended.
     * only permit admin role
     */
    function createInvader(uint256 id, uint256 bounty, string memory name, uint16 race) external override onlyRole(BATTLE_MANAGER_ROLE){
        require(id!=0 && invadersMapping[id].bounty == 0, "Id is zero or invader is exist");
        // transfer bounty from creater
        invadersMapping[id].bounty = bounty;
        invadersMapping[id].name = name;
        invadersMapping[id].race = race;
        SafeERC20.safeTransferFrom(chiCoinERC20, _msgSender(), address(this), bounty);
        emit InvaderCreated(id, bounty);
    }

    /**
     *  @dev This function will be called while a battle ended.
     */
    function _beatInvader(uint256 id) internal{
        invadersMapping[id].status = STATUS_INVADER_DEFEATED;
    }

    /**
     *  @dev Get a invader's details.
     */
    function getInvader(uint256 id) external view override returns(uint256 bounty, string memory name, uint16 race, uint16 status){
        bounty= invadersMapping[id].bounty;
        name = invadersMapping[id].name;
        race = invadersMapping[id].race;
        status = invadersMapping[id].status;
    }


    /**
     *  @dev getBattle details
     */
    function getBattle(uint256 id) external view override returns(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint128[] memory,
        uint128,
        uint16[] memory, 
        uint16[] memory, 
        uint256[] memory
    ) {
        Battle storage battle = battlesMapping[id];
        return(battle.invaderId, invadersMapping[battle.invaderId].bounty, battle.maxASandwich, battle.maxDSandwich,
        battle.maxHSandwich, battle.generalSandwich, battle.luckyDog, battle.tableclothTypes, battle.endTime, battle.attrs, battle.allowedAttrs, battle.sandwiches);
    }

    function nextId() private {
         idIndex ++;
    }


    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external override pure returns (bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external override pure returns (bytes4){
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../lib/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../core/interface/IERC20Token.sol";
import "./AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20Token;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Token token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Token token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20Token-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Token token,
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
        IERC20Token token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Token token,
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
    function _callOptionalReturn(IERC20Token token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../erc165/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../erc165//IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Random {
    
    /**
     * @dev Create a random number.
     */
    function createRandom(uint256 min, uint256 max, uint256 seed) internal pure returns (uint8)
    { 
         // inclusive,inclusive (don't use absolute min and max values of uint256)
        // deterministic based on seed provided
        uint diff = max - min + 1;
        uint randomVar = uint(keccak256(abi.encodePacked(seed))) % diff;
        randomVar = randomVar + min;
        return uint8(randomVar);
    }

    /**
     * @dev Create a random number.
     */
    function createRandom(uint256 min, uint256 max, uint256 seed1, uint256 seed2) internal pure returns (uint8)
    { 
        return createRandom(min, max, combineSeeds(seed1, seed2));
    }

    /**
     * @dev combine and refresh seed.
     */
    function combineSeeds(uint seed1, uint seed2) internal pure returns (uint) {
        return uint(keccak256(abi.encodePacked(seed1, seed2)));
    }

    function combineSeeds(uint[] memory seeds) internal pure returns (uint) {
        return uint(keccak256(abi.encodePacked(seeds)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITableclothERC1155 {

    event TableclothPurchase(uint256 indexed id, address indexed owner);
    event ConfigTableclothType(uint256 indexed id, uint256 price, uint256 maximum);

    /**
     *  @dev Buy a tablecloth
     *
     *  Emits a {tableclothPurchase} event.
     */
    function buyTablecloth(
        uint256 cswAmount,
        uint128 typeId
    )  external;

    /**
     * @dev Return details of Tablecloth 
     *
     * Requirements:
     * - tokenId
     */
    function getTablecloth(uint256 _id) external view returns (
        uint256 maximum,
        uint256 soldQuantity,
        uint256 price,
        bool[5] memory _attr,
        uint128 typeId,
        string memory tableclothName,
        string memory tableclothDescribe
    );

    function configTableclothType(
        uint128 id,
        string memory _name,
        string memory _describe,
        uint256 tableclothPrice,
        bool[5] memory _attr,
        uint256 _maximum
    ) external;

    /**
     * @dev Return tablecloth type of token 
     *
     * Requirements:
     * - tokenId
     */
    function getTableclothType(uint256 _id) external view returns(uint128);


    /**
     *  @dev Get tablecloth type details by type id
     */
    function getTypeDetails(uint128 typeId) external view returns (
        string memory tableclothName,
        string memory tableclothDescribe,
        uint256 tableclothPrice,
        uint256 maximum,
        uint256 soldQuantity,
        bool[5] memory attr,
        uint16 attrnum,
        uint256 totalAwards
    );

    /**
     * @dev Get the enemy of attributes
     *
     * Requirements:
     * - attr >= 1 and <= 5
     */
    function getAttributesEnemy(uint16 attr) external view returns(uint16);

    /**
     * @dev Get the token id list of holder
     *
     */
    function getHoldArray(uint128 typeId, address holder) external view returns(uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is the interface about acclocation of chitoken to tablecloth holders
 */
interface ITableclothAwardsPool {

    event AddAwards(uint128 indexed awardsType, uint128 indexed tableclothType, uint256 chiAmount);
    event Withdraw(uint256 indexed tableclothId, address indexed to, uint256 chiAmount);

    function AWARDS_TYPE_BATTLE() external view returns(uint128);
    function AWARDS_TYPE_MERGE() external view returns(uint128);

    /**
     * @dev Add awards in pool.
     * only permit sandwith or qualifying role
     */
    function addAwards(
        address sender,
        uint128 awardsType,
        uint128 tableclothType,
        uint256 chiAmount
    ) external;

    /**
     * @dev Add awards in pool.
     * only permit sandwith or qualifying role
     */
    function addAwards(
        address sender,
        uint128 awardsType,
        uint128[] memory tableclothTypes,
        uint256 chiAmount
    ) external;

    /**
     * @dev Get the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you get
     */
    function getUnaccalimedAmount(uint256 tableclothId) external view returns(uint256);

    function getUnaccalimedAmountByType(uint128 tableclothType, address user) external view returns(uint256 amounts);

    /**
     * @dev Get the pool's historical total awards amount in pool.
     */
    function getPoolTotalAmount(uint128 tableclothType) external view returns(uint256);


    /**
     * @dev Withdraw the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you withdraw
     */
    function withdraw(uint256 tableclothId, address to) external;

    /**
     * @dev Withdraw the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you withdraw
     * This funtion will withdraw all awards of table cloth you hold which typeid = tableclothType
     */
    function withdrawByType(uint128 tableclothType, address to) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev 
 */
interface ISandwichesERC1155 {

    /**
     * @dev Create new sandwich heroes by ingredients, tablecloths, and equipments.
     *
     * The length of ingredient Tokens required for merging must be 4,
     * The length of equipment Tokens required for merging must be greater than 3 and less than 4.
     *
     * CHI coins must be paid as a handling fee when merging, 
     * and CHI coins will be equally distributed to the holders of the tablecloth shares.
     */
    function merge(
        uint256 chiAmount,
        uint256[] calldata ingredients,
        uint256[] calldata equipments, 
        uint128 tableclothType,
        string calldata _name,
        string calldata _describe
    ) external;


    /**
     *  @dev Get sandwich details by token id.
     */
    function getSandwich(uint256 _id) external view returns (
        string memory name,
        string memory describe,
        uint256 aggressivity,
        uint256 defensive,
        uint256 healthPoint,
        uint256 calories,
        uint256 scent,
        uint256 freshness,
        bool[5] memory attributes,
        uint16 attrnum
    );

    /**
     *  @dev Get sandwich parts by token id.
     */
    function getSandwichParts(uint256 _id) external view returns (
        uint256[] memory ingredients,
        uint256[] memory equipments
    );

    /**
     *  @dev Burn your sandwich and the parts will send to receiver.
     *
     *  Requirements: receiver not address(0) and msg.sender have this token
     */
    function burn(uint256 id, address receiver) external;

    /**
     *  @dev Burn your sandwich and the parts will send to you.
     *
     *  Requirements: msg.sender have this token
     */
    function burn(uint256 id) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRandoms {
    function getRandomSeed(address user) external view returns (uint256 seed);
    
    function getRandomSeedUsingHash(address user, bytes32 hash) external view returns (uint256 seed);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is the interface about qualifying
 */
interface IQualifying {

    event BattleCreated(uint256 indexed battleId, uint256 indexed invaderId);
    event BattleStart(uint256 indexed battleId);
    event BattleEnd(uint256 indexed battleId);
    event JoinBattle(uint256 indexed battleId, uint256 indexed sandwichId);
    event WithDraw(uint256 indexed battleId, uint256 indexed sandwichId, uint256 awardsAmount);
    event InvaderCreated(uint256 indexed invaderId, uint256 bounty);

    /**
     *  @dev Create a new battle.
     * only permit admin role
     */
    function create(uint256 invaderId, uint128[] memory tableclothTypes) external;

    /**
     *  @dev join a battle.
     */
    function join(uint256 battleId, uint256 sandwichId) external;

    /**
     *  @dev get awards amount of sandwich.
     */
    function calculateAwards(uint256 sandwichId) external view returns(uint256);

    /**
     *  @dev Finish battle
     *  Note require timestamp > endtime
     */
    function finish(uint256 battleId) external;

    /**
     *  @dev withDraw your sandwich and get awards.
     */
    function withDraw(uint256 sandwichId) external;

    /**
     *  @dev withDraw your sandwich while emergency situations, give up awards.
     */
    function urgentWithDraw(uint256 sandwichId) external;

    /**
     *  @dev Add a Invader.
     * You need to pay bounty amount of chi while create invader. bounty will alloc to player and tablecloth holder when a battle ended.
     * only permit admin role
     */
    function createInvader(uint256 id, uint256 bounty, string memory name, uint16 race) external;

    /**
     *  @dev Get a invader's details.
     */
    function getInvader(uint256 id) external view returns(
        uint256 bounty,
        string memory name,
        uint16 race,
        uint16 status
    );


    /**
     *  @dev get battle details
     */
    function getBattle(uint256 id) external view returns(
        uint256 invaderId,
        uint256 awardsAmounts,
        uint256 maxASandwich,
        uint256 maxDSandwich,
        uint256 maxHSandwich,
        uint256 generalSandwich,
        uint256 luckyDog,
        uint128[] memory tableclothTypes,
        uint128 endTime,
        uint16[] memory attrs, 
        uint16[] memory allowedAttrs, 
        uint256[] memory sandwiches
    );

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Token {
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../../lib/ContextUpgradeable.sol";
import "../../lib/StringsUpgradeable.sol";
import "../../erc/erc165/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {

    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}