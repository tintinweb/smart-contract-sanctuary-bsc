// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/proxy/utils/Initializable.sol';

import '../../interfaces/IWETH.sol';
import '../../swap/libraries/SodSwapLibrary.sol';
import '../../mining/interfaces/IMiningERC20.sol';
import '../../mining/StakeMinerBase.sol';
import '../../community/interfaces/ICommunityNet.sol';

import './interfaces/IStar.sol';
import './interfaces/IStarFactory.sol';

import './Star.sol';

contract Universe is StakeMinerBase, Initializable, IStarFactory {
    using ValueList for ValueList.List;
    using ValueList for ValueList.Value;
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 private INCOMETYPE;
    uint8 private USDT_DECIMALS;
    uint256 private MIN_PLEDGE_VALUE;// = 10000000 * 10 ** USDT_DECIMALS;

    address public WETH;
    address public pairFactory;
    address public override sodToken;
    address public usdtToken;
    address public communityNet;
    address public governor;

    mapping(address => address) public getStar;
    mapping(address => uint256) public incomes;
    mapping(address => mapping(address => uint256)) private _energyAdditions;

    EnumerableSet.AddressSet private originEnergyList;
    EnumerableSet.AddressSet private energyList;

    event PledgeLog(uint256, address, uint256, uint256);
    event TakebackLog(uint256, address, uint256, uint256);

    struct StarInfo {
        uint256 level;
        uint256 baseEnergy;
        uint256 addEnergy;
        uint256 earnValue;
        uint256 income;
    }

    struct PledgeValue {
        uint256 sodAmount;
        uint256 tokenAmount;
    }

    mapping(address => PledgeValue) public pledgeValues;

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function initialize(address _WETH, address _sodToken, address _usdtToken, address _communityNet, address _governor) public initializer {
        WETH = _WETH;
        sodToken = _sodToken;
        usdtToken = _usdtToken;
        communityNet = _communityNet;
        governor = _governor;
        
        INCOMETYPE = keccak256(abi.encodePacked("UNIVERSE"));
        USDT_DECIMALS = 18;
        MIN_PLEDGE_VALUE = 10000000 * 10 ** USDT_DECIMALS;
        IERC20(_sodToken).approve(communityNet, type(uint256).max);
        _transferOwnership(msg.sender);
    }   

    function setPairFactory(address _pairFactory) public onlyOwner {
        pairFactory = _pairFactory;
    }

    function setEnergyToken(address _energyToken, bool _isOrigin) public onlyOwner {
        if(_isOrigin) {
            originEnergyList.add(_energyToken);
        } else {
            originEnergyList.remove(_energyToken);
        }

        energyList.add(_energyToken);
    }

    function getStarInfo(address user) public view returns(StarInfo memory) {
        address star = getStar[user];
        return StarInfo({
            level: IStar(star).level(),
            baseEnergy: pledgesMap[star].currentValue(true), 
            addEnergy: _computeEnergyAdditions(user), 
            earnValue: _caleReward(star),
            income: incomes[user]
        });
    }

    function isOriginEnergy(address token) public view returns(bool) {
        return originEnergyList.contains(token);
    }

    function energyTokens() external view override returns(address[] memory) {
        return energyList.values();
    }

    function wholeEnergies() external view returns(uint) {
        return wholePledge.currentValue(true);
    }

    function withdraw(address to) public onlyOwner {
        TransferHelper.safeTransfer(sodToken, to, IERC20(sodToken).balanceOf(address(this)));
    }

    function harvest() public {
        address star = getStar[msg.sender];
        require(star != address(0), "Universe: STAR_NONEXISTENT");
        uint256 rewardValue = _caleReward(star);
        
        if(rewardValue > 0) {
            pledgesMap[star].clear();

            incomes[msg.sender] += rewardValue;
            IMiningERC20(sodToken).mint(msg.sender, rewardValue * 95 / 100);
            IMiningERC20(sodToken).mint(governor, rewardValue - rewardValue * 95 / 100);
        }
        
        uint256 _energyAddition = pledgesMap[msg.sender].currentValue(true);
        if(_energyAddition > 0) {
            address _mentor = ICommunityNet(communityNet).mentor(msg.sender);
            address _mentorStar = getStar[_mentor];
            if(IStar(_mentorStar).isLive()) {
                rewardValue = _caleReward(msg.sender);
                if(rewardValue >0) {
                    IMiningERC20(sodToken).mint(address(this), rewardValue);
                    ICommunityNet(communityNet).income(INCOMETYPE, sodToken, _mentor, rewardValue * 95 / 100);
                    TransferHelper.safeTransfer(sodToken, governor, rewardValue - rewardValue * 95 / 100);
                }
            } else {
                update(msg.sender, _energyAddition, OPType.SUB);
                address[] memory tokens = energyList.values();
                for(uint i; i < tokens.length; i++) {
                    _energyAdditions[msg.sender][tokens[i]] = 0;
                }
            }
            pledgesMap[msg.sender].clear();
        }
    }

    function pledge(address user, address energyToken, uint energyAmount, uint maxSodAmount) public {
        _pledge(user, energyToken, energyAmount, maxSodAmount);
    }

    function pledgeETH(address user, uint maxSodAmount) public payable {
        IWETH(WETH).deposit{value: msg.value}();
        _pledge(user, WETH, msg.value, maxSodAmount);
    }

    function _pledge(address user, address energyToken, uint energyAmount, uint maxSodAmount) internal {
        require(energyList.contains(energyToken), "Universe: secondEnergyToken not on the energyList");
        
        address star;
        if(getStar[user] == address(0)) {
            star = address(new Star{salt:keccak256(abi.encodePacked(user, address(this)))}());
            getStar[user] = star;
            if(ICommunityNet(communityNet).inactive(user)) {
                ICommunityNet(communityNet).activateByManager(address(0), user);
            }
        } else {
            star = getStar[user];
        }

        uint sodEnergyAmount;
        {
            if(energyToken == sodToken) {
                sodEnergyAmount = energyAmount / 4;
                TransferHelper.safeTransferFrom(sodToken, msg.sender, star, energyAmount + sodEnergyAmount);
            } else {
                sodEnergyAmount = _needSodAmount(energyAmount / 4, energyToken);
                require(sodEnergyAmount <= maxSodAmount, "Universe: more maxSodAmount");
                if(WETH == energyToken) {
                    TransferHelper.safeTransfer(energyToken, star, energyAmount);
                } else {
                    TransferHelper.safeTransferFrom(energyToken, msg.sender, star, energyAmount);
                }
                
                TransferHelper.safeTransferFrom(sodToken, msg.sender, star, sodEnergyAmount);
            }
            pledgeValues[energyToken].tokenAmount += energyAmount;
            pledgeValues[energyToken].sodAmount += sodEnergyAmount;
        }

       
        uint _energies = _amountToEnergies(sodEnergyAmount) * 5;
        if(originEnergyList.contains(energyToken)) {
            _energies = _energies * 6 / 5;
        }
        _energies = IStar(star).assemble(sodEnergyAmount, energyToken, energyAmount, _energies);
        update(star, _energies, OPType.ADD);
        emit PledgeLog(sodEnergyAmount, energyToken, energyAmount, _energies);
       
        address _mentor = ICommunityNet(communityNet).mentor(user);
        address _mentorStar = getStar[_mentor];

        if(_mentorStar != address(0) && IStar(_mentorStar).isLive()) {
            uint _originStarEnergy = pledgesMap[_mentorStar].currentValue(true);
            uint _selfStarEnergy = pledgesMap[star].currentValue(true);

            if(_selfStarEnergy <= _originStarEnergy) {
                _energies = _energies * (IStar(_mentorStar).level() + 7) / 100;
            } else {
                if(_selfStarEnergy - _energies < _originStarEnergy) {
                    _energies = (_originStarEnergy + _energies - _selfStarEnergy) * (IStar(_mentorStar).level() + 7) / 100;
                } else {
                    _energies = 0;
                }
            }

            if(_energies > 0) {
                update(user, _energies, OPType.ADD);
                _energyAdditions[user][energyToken] += _energies;
            }
        }
    }

    function upgrade(uint level, uint maxSodAmount) public {
        address star = getStar[msg.sender];
        require(star != address(0), "Universe: STAR_NONEXISTENT");
        require(level <= 5, "Universe: level error");

        uint currentLevel = IStar(star).level();
        //(level-clevel)*(clevel-1+level)/2
        uint usdtAmount = (level - currentLevel) * (currentLevel + level - 1) * (100 * 10 ** USDT_DECIMALS) / 2;

        uint sodAmount = _convertToken(usdtToken, sodToken, usdtAmount);
        require(sodAmount <= maxSodAmount, "Universe: more maxSodAmount");
        TransferHelper.safeTransferFrom(sodToken, msg.sender, address(this), sodAmount);
        IMiningERC20(sodToken).burn(sodAmount);

        IStar(star).upgrade(level);
    }

    function takeback(address token, address to) public {
        address star = getStar[msg.sender];
        require(star != address(0), "Universe: STAR_NONEXISTENT");
        uint sodAmount; uint tokenAmount; uint _energies;
        
        if(token == WETH) {
            (sodAmount, tokenAmount, _energies) = IStar(star).takeback(token, address(this));
            IWETH(WETH).withdraw(tokenAmount);
            TransferHelper.safeTransferETH(to, tokenAmount);
            TransferHelper.safeTransfer(sodToken, to, sodAmount - sodAmount / 50);
        } else {
            (sodAmount, tokenAmount, _energies) = IStar(star).takeback(token, to);
        }
        
        pledgeValues[token].tokenAmount -= tokenAmount;
        pledgeValues[token].sodAmount -= sodAmount;

        update(star, _energies, OPType.SUB);
        if(_energyAdditions[msg.sender][token] != 0) {
            update(msg.sender, _energyAdditions[msg.sender][token], OPType.SUB);
            _energyAdditions[msg.sender][token] = 0;
        }

        emit TakebackLog(sodAmount, token, tokenAmount, _energies);
    }

    function _hasOutputRatio() internal override pure returns(bool) {
        return false;
    }

    function _outputRatio(uint dayIndex) internal override view returns(uint, uint) {
        uint total = wholePledge.indexValue(dayIndex);
        if(total < MIN_PLEDGE_VALUE) {
            return (total, MIN_PLEDGE_VALUE);
        } else {
            return (1,1);
        }
    }

    function _amountToEnergies(uint sodAmount) internal view returns(uint) {
        return _convertToken(sodToken, usdtToken, sodAmount);
    }

    function _computeEnergyAdditions(address user) private view returns(uint) {
        address star = getStar[user];
        if(!IStar(star).isLive()) {
            return 0;
        }
        
        address[] memory members = ICommunityNet(communityNet).members(user, 0, type(uint256).max);

        uint value;
        for(uint i; i < members.length; i++) {
            value += pledgesMap[members[i]].currentValue(true);
        }
        return value;
    }


    function _needSodAmount(uint energyAmount, address energyToken) internal view returns(uint) {
        if(energyToken == sodToken) {
            return energyAmount;
        }

        return  _convertToken(energyToken, sodToken, energyAmount);
    }

    function _convertToken(address fromToken, address toToken, uint amount) internal view returns(uint) {
        (uint reserveIn, uint reserveOut) = SodSwapLibrary.getReserves(pairFactory, fromToken, toToken);
        require(reserveIn != 0 && reserveOut != 0, "Universe: PAIR_NONEXISTENT");
        return amount * reserveOut / reserveIn;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

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
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "../interfaces/ISodSwapPair.sol";
import "../../libraries/SafeMath.sol";

library SodSwapLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'SodSwapLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'SodSwapLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'db6d69529019dd47b15bfd7e284345a5535d44fc124e0d3de8c88ac458934257' // init code hash
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = ISodSwapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'SodSwapLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'SodSwapLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'SodSwapLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'SodSwapLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'SodSwapLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'SodSwapLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'SodSwapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'SodSwapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

interface IMiningERC20 is IERC20Metadata {
    // function initialize(string memory, string memory, address, uint value) external;
    function mint(address to, uint256 value) external;
    function burn(uint256 value) external;
    function addMiner(address miner) external;
    function removeMiner(address _miner) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import './libraries/ValueList.sol';
import './MiningBase.sol';

contract StakeMinerBase is MiningBase {
    using ValueList for ValueList.List;
    using ValueList for ValueList.Value;

    enum OPType {
        ADD,
        SUB
    }
    event Update(address, uint256, OPType);

    ValueList.List internal wholePledge;
    mapping(address => ValueList.List) internal pledgesMap;

    function update(address target, uint value, OPType opType) internal {
        if(opType == OPType.ADD) {
            wholePledge.add(value);
            pledgesMap[target].add(value);
        } else {
            wholePledge.sub(value);
            pledgesMap[target].sub(value);
        }
        emit Update(target, value, opType);
    }

    function _caleReward(address pledger) internal view returns(uint value) {
        ValueList.List storage selfPledge = pledgesMap[pledger];
        
        uint256 selfIndex = selfPledge.lastIndex;
        uint256 wholeIndex = wholePledge.lastIndex;
        uint256 endIndex = Times.toUTC8Index(block.timestamp);

        if(selfIndex != 0 && selfIndex == endIndex) {
            selfIndex = selfPledge.list[selfIndex].prevIndex;
        }

        if(wholeIndex != 0 && wholeIndex == endIndex) {
            wholeIndex = wholePledge.list[wholeIndex].prevIndex;
        }

        while(true) {
            if(selfIndex == 0) {
                break;
            }

            ValueList.Value storage selfValue = selfPledge.list[selfIndex];
            while(selfIndex < wholeIndex) {
                if(selfValue.nextValue != 0) {
                    value += _calcuRewardByDay(wholeIndex + 1, endIndex) * selfValue.nextValue / wholePledge.list[wholeIndex].nextValue;
                    value += _calcuRewardByDay(wholeIndex, wholeIndex + 1) * selfValue.nextValue / wholePledge.list[wholeIndex].value;
                }

                endIndex = wholeIndex;
                wholeIndex = wholePledge.list[wholeIndex].prevIndex;
            }

            if(selfIndex < endIndex) {
                if(wholePledge.list[wholeIndex].nextValue != 0) {
                    value +=  _calcuRewardByDay(selfIndex + 1, endIndex) * selfValue.nextValue / wholePledge.list[wholeIndex].nextValue;
                }

                if(wholePledge.list[wholeIndex].value != 0) {
                    value +=  _calcuRewardByDay(selfIndex, selfIndex + 1) * selfValue.value / wholePledge.list[wholeIndex].value;
                }
            }

            endIndex = selfIndex;
            selfIndex = selfPledge.list[selfIndex].prevIndex;
            wholeIndex = wholePledge.list[wholeIndex].prevIndex;
        }
    }
}

interface ICommunityNet {

    event ActivateLog(address indexed, address);
    event IncomeLog(bytes32, address, address indexed, uint);

    struct Income {
        uint256 value;
        uint256 totalValue;
    }

    function inactive(address user) external view returns(bool);
    function deadlines(address) external view returns(uint);
    function mentor(address) external view returns(address);
    function communityGovernor() external view returns(address);
    function members(address, uint, uint) external view returns(address[] memory);
    function incomeValue(address, address) external view returns(Income memory);

    function activateByManager(address, address) external;
    function activate(address) external;
    function income(bytes32, address, address, uint) external;
    function withdraw(address token) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

interface IStar {

    function factory() external view returns(address);
    // function owner() external view returns(address);
    function level() external view returns(uint256);
    function isLive() external view returns(bool);
    function assembleEnergy(address) external view returns(uint256, uint256, uint256);
    
    function assemble(uint256, address, uint256, uint256) external returns(uint256);
    function upgrade(uint256) external;
    function takeback(address, address) external returns(uint256, uint256, uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

interface IStarFactory {

    function sodToken() external view returns(address);
    function energyTokens() external view returns(address[] memory);

    // function burnEnergies(uint) external;
    // function harvest() external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "../../mining/interfaces/IMiningERC20.sol";
import "../../libraries/TransferHelper.sol";

import "./interfaces/IStarFactory.sol";
import "./interfaces/IStar.sol";

contract Star is IStar {

    address public override factory;
    uint256 public override level = 1;

    struct AssembleEnergy {
        uint energies;
        uint sodAmount;
        uint tokenAmount;
    }
    mapping(address => AssembleEnergy) private assembleEnergys;

    constructor() {
        factory = msg.sender;
    }

    modifier onlyFactory() {
        require(factory == msg.sender, "caller is not the factory");
        _;
    }

    function assembleEnergy(address token) public view override returns(uint, uint, uint) {
        AssembleEnergy storage ae = assembleEnergys[token];
        return (ae.energies, ae.sodAmount, ae.tokenAmount);
    }

    function isLive() public view override returns(bool) {
        address[] memory tokens = IStarFactory(factory).energyTokens();
        for(uint i; i < tokens.length; i++) {
            AssembleEnergy storage ae = assembleEnergys[tokens[i]];
            if(ae.sodAmount > 0) {
                return true;
            }
        }
        return false;
    }

    function assemble(uint _sodAmount, address token, uint _tokenAmount, uint _energies) external override onlyFactory returns(uint addEnergies) {
        assembleEnergys[token].sodAmount += _sodAmount;
        assembleEnergys[token].tokenAmount += _tokenAmount;

        addEnergies = levelEnergies(_energies);
        assembleEnergys[token].energies += addEnergies;
    }

    function upgrade(uint256 newLevel) external override onlyFactory {
        require(newLevel > level, "Star: newLevel < level");
        level = newLevel;
    }
    
    function takeback(address token, address to) external override onlyFactory returns (uint256 sodAmount, uint256 tokenAmount, uint256 energies) {
        AssembleEnergy storage ae = assembleEnergys[token];
        if(ae.sodAmount > 0) {
            energies = ae.energies;
            sodAmount = ae.sodAmount;
            tokenAmount = ae.tokenAmount;

            delete assembleEnergys[token];

            address sodToken = IStarFactory(factory).sodToken();
            IMiningERC20(sodToken).burn(sodAmount / 50);

            TransferHelper.safeTransfer(token, to, tokenAmount);
            TransferHelper.safeTransfer(sodToken, to, sodAmount - sodAmount / 50);     
        }
    }

    function levelEnergies(uint value) private view returns(uint) {
        return value * _pow(110, level - 1)/ _pow(100, level - 1);
    }

    function _pow(uint x, uint y) private pure returns(uint z) {
        assembly {
            z:= exp(x, y)
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import './ISodSwapERC20.sol';

interface ISodSwapPair is ISodSwapERC20 {
    
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

    function pause() external;
    function unpause() external;
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y != 0, "ds-math-div-zero");
        z = x / y;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

interface ISodSwapERC20 is IERC20Metadata {
    
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '../../libraries/Times.sol';

library ValueList {    
    
    struct Value {
        uint256 value;
        uint256 nextValue;
        uint256 prevIndex;
        bool flag;
    }

    struct List {
        uint256 lastIndex;
        mapping(uint256 => Value) list;
    }

    function add(List storage self, uint256 value) internal {
        uint256 _now = Times.toUTC8(block.timestamp);
        uint256 index = _now / Times.ONE_DAY;

        if (!self.list[index].flag) {
            self.list[index] = Value({
                value: self.list[self.lastIndex].nextValue + value * (Times.ONE_DAY - _now % Times.ONE_DAY) / Times.ONE_DAY,
                nextValue: self.list[self.lastIndex].nextValue + value,
                prevIndex: self.lastIndex,
                flag: true
            });
            self.lastIndex = index;
        } else {
            self.list[index].value = self.list[index].value + value * (Times.ONE_DAY - _now % Times.ONE_DAY) / Times.ONE_DAY;
            self.list[index].nextValue = self.list[index].nextValue + value;
        }
    }

    function sub(List storage self, uint256 value) internal {
        uint256 _now = Times.toUTC8(block.timestamp);
        uint256 index = _now / Times.ONE_DAY;
        if (!self.list[index].flag) {
            self.list[index] = Value({
                value: self.list[self.lastIndex].nextValue - value * (Times.ONE_DAY - _now % Times.ONE_DAY) / Times.ONE_DAY,
                nextValue: self.list[self.lastIndex].nextValue - value,
                prevIndex: self.lastIndex,
                flag: true
            });
            self.lastIndex = index;
        } else {
            self.list[index].value = self.list[index].value - value * (Times.ONE_DAY - _now % Times.ONE_DAY) / Times.ONE_DAY;
            self.list[index].nextValue = self.list[index].nextValue - value;
        }
    }

   function clear(List storage self) internal {
        if(self.lastIndex == 0) {
            return;
        }

        uint256 _now = Times.toUTC8(block.timestamp);
        uint256 index = _now / Times.ONE_DAY;
        
        uint256 _index;
        if(index == self.lastIndex) {
            _index = self.list[self.lastIndex].prevIndex;  
            self.list[self.lastIndex].prevIndex = 0;     
        } else {
            _index = self.lastIndex;
            if(self.list[self.lastIndex].nextValue !=0) {
                self.list[index].value = self.list[self.lastIndex].nextValue;
                self.list[index].nextValue = self.list[self.lastIndex].nextValue;
                self.list[index].flag = true;
                self.lastIndex = index;
            } else{
                delete self.list[self.lastIndex];
                self.lastIndex = 0;
            }
        }
        
        while (_index != 0) {
            uint delIndex = _index;
            _index = self.list[_index].prevIndex;
            delete self.list[delIndex];
        }
    }

    function currentValue(List storage self, bool flag) internal view returns (uint256) {
        if(self.lastIndex == 0) {
            return 0;
        }
        
        if(flag) {
            return self.list[self.lastIndex].nextValue;
        } else {
            uint256 index = Times.toUTC8Index(block.timestamp);
            if(index == self.lastIndex) {
                return self.list[self.lastIndex].value;
            } else {
                return self.list[self.lastIndex].nextValue;
            }
        }
    }

    function indexValue(List storage self, uint index) internal view returns (uint256) {
        if(self.lastIndex == 0) {
            return 0;
        }

        if(self.list[index].flag) {
            return self.list[index].nextValue;
        } else {
            uint256 _index = self.lastIndex;
            while (_index > index) {
                _index = self.list[_index].prevIndex;
            }
            return self.list[_index].nextValue;
        }
    }

    // function all(List storage self) internal view returns (Value[] memory rets) {
    //     uint256 _index = self.lastIndex;
    //     uint256 count;
    //     while (self.list[_index].flag) {
    //         count++;
    //         _index = self.list[_index].prevIndex;
    //     }

    //     rets = new Value[](count);
    //     _index = self.lastIndex;
    //     uint256 len;
    //     while (self.list[_index].flag) {
    //         rets[len] = self.list[_index];
    //         (_index) = (rets[len].prevIndex);
    //         len++;
    //     }
    // }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';

import '../libraries/Times.sol';

import './interfaces/IMiningBase.sol';

abstract contract MiningBase is IMiningBase, Ownable {

    struct DayReward {
        uint dayIndex;
        uint value;
    }

    DayReward[] public dayRewards;
    
    event SetBlockReward(uint, uint);

    function setDayReward(uint time, uint value) external override onlyOwner {
        uint dayIndex = Times.toUTC8Index(time);
        require(dayRewards.length == 0 || dayRewards[dayRewards.length - 1].dayIndex < dayIndex, "MiningBase: time error");
        dayRewards.push(DayReward({
            dayIndex: dayIndex,
            value: value
        }));
    }

    function dayReward(uint dayIndex) public view override returns(uint) {
        uint index = dayRewards.length;
        if(dayIndex == 0) {
            dayIndex = Times.toUTC8Index(block.timestamp);
        }

        while(index > 0) {
            if(dayRewards[index - 1].dayIndex <= dayIndex) {
                (uint a, uint b) = _outputRatio(dayIndex);
                return dayRewards[index - 1].value * a / b;
            }
            index -= 1;
        }
        return 0;
    }

    function calcuRewardByDays(uint startDay, uint endDay) public view returns(uint) {
        return _calcuRewardByDay(startDay, endDay);
    }

    function _hasOutputRatio() internal virtual view returns(bool) {
        return false;
    }

    function _outputRatio(uint dayIndex) internal virtual view returns(uint, uint) {
        return (1, 1);
    }

    function _calcuRewardByDay(uint startDay, uint endDay) internal view returns(uint value) {
        if(startDay >= endDay) {
            return value;
        }

        for(uint i = dayRewards.length; i > 0; i--) {
            DayReward storage _dayReward = dayRewards[i -1];
            if(endDay > _dayReward.dayIndex) {
                if(startDay < _dayReward.dayIndex) {
                    if(_hasOutputRatio()) {
                        for(uint j = _dayReward.dayIndex; j < endDay; j++) {
                            (uint a, uint b) = _outputRatio(j);
                            value = value + _dayReward.value * a / b;
                        }
                    } else {
                        value = value + _dayReward.value * (endDay - _dayReward.dayIndex);
                    }
                    
                    endDay = _dayReward.dayIndex;
                } else {
                    if(_hasOutputRatio()) {
                        for(uint j = startDay; j < endDay; j++) {
                            (uint a, uint b) = _outputRatio(j);
                            value = value + _dayReward.value * a / b;
                        }
                    } else {
                        value = value + _dayReward.value * (endDay - startDay);
                    }

                    return value;
                }
            }
        }
        return value;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

// a library for performing various math operations

library Times {
    uint256 constant ONE_DAY = 3600;//86400;
    uint256 constant ONE_YEAR = 365 * 86400;

    function toUTC8(uint256 time) internal pure returns (uint256) {
        // return (time + 8 * 60 * 60);
        return time;
    }

    function toUTC8Index(uint256 time) internal pure returns (uint256) {
        // return (time + 8 * 60 * 60) / ONE_DAY;
        return (time) / ONE_DAY;
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

interface IMiningBase {

    function dayReward(uint) external view returns(uint);

    function setDayReward(uint time, uint value) external;
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}