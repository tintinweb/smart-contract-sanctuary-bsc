/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// File: contracts/libs/IterableMapping.sol


pragma solidity ^0.8.0;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
        public
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
// File: contracts/libs/Context.sol


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
// File: contracts/libs/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts/libs/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
// File: contracts/libs/IFactory.sol

pragma solidity ^0.8.0;

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
// File: contracts/libs/IRouter.sol

pragma solidity ^0.8.0;

interface IRouter02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: contracts/libs/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// File: contracts/NodeManager.sol


/*
 *
 *    Web:      https://www.aerarium.finance/
 *    Discord:  
 *    Twitter:  
 *
 */





pragma solidity 0.8.4;

contract NodeManager is Ownable, Pausable {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    struct NodeEntity {
        string name;
        uint creationTime;
        uint lastClaimTime;
        uint256 amount;
    }

    IterableMapping.Map private nodeOwners;
    mapping(address => NodeEntity[]) private _nodesOfUser;

    address public token;
    uint8 public rewardPerNode;
    uint256 public minPrice;

    uint256 public totalNodesCreated = 0;
    uint256 public totalStaked = 0;
    uint256 public totalClaimed = 0;

    uint8[] private _boostMultipliers = [105, 120, 140];
    uint8[] private _boostRequiredDays = [3, 7, 15];

    event NodeCreated(
        uint256 indexed amount,
        address indexed account,
        uint indexed blockTime
    );

    modifier onlyGuard() {
        require(owner() == _msgSender() || token == _msgSender(), "NOT_GUARD");
        _;
    }

    modifier onlyNodeOwner(address account) {
        require(isNodeOwner(account), "NOT_OWNER");
        _;
    }

    constructor(
        uint8 _rewardPerNode,
        uint256 _minPrice
    ) {
        rewardPerNode = _rewardPerNode;
        minPrice = _minPrice;
    }

    // Private methods

    function _isNameAvailable(address account, string memory nodeName)
        private
        view
        returns (bool)
    {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        for (uint256 i = 0; i < nodes.length; i++) {
            if (keccak256(bytes(nodes[i].name)) == keccak256(bytes(nodeName))) {
                return false;
            }
        }
        return true;
    }

    function _getNodeWithCreatime(
        NodeEntity[] storage nodes,
        uint256 _creationTime
    ) private view returns (NodeEntity storage) {
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        bool found = false;
        int256 index = _binarySearch(nodes, 0, numberOfNodes, _creationTime);
        uint256 validIndex;
        if (index >= 0) {
            found = true;
            validIndex = uint256(index);
        }
        require(found, "NODE SEARCH: No NODE Found with this blocktime");
        return nodes[validIndex];
    }

    function _binarySearch(
        NodeEntity[] memory arr,
        uint256 low,
        uint256 high,
        uint256 x
    ) private view returns (int256) {
        if (high >= low) {
            uint256 mid = (high + low).div(2);
            if (arr[mid].creationTime == x) {
                return int256(mid);
            } else if (arr[mid].creationTime > x) {
                return _binarySearch(arr, low, mid - 1, x);
            } else {
                return _binarySearch(arr, mid + 1, high, x);
            }
        } else {
            return -1;
        }
    }

    function _uint2str(uint256 _i)
        private
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function _calculateNodeRewards(uint _lastClaimTime, uint256 amount_) private view returns (uint256 rewards) {
        uint256 elapsedTime_ = (block.timestamp - _lastClaimTime);
        uint256 boostMultiplier = _calculateBoost(elapsedTime_).div(100);
        uint256 rewardPerDay = amount_.mul(rewardPerNode).div(100);
        return ((rewardPerDay.mul(10000).div(1440) * (elapsedTime_ / 1 minutes)) / 10000) * boostMultiplier;
    }

    function _calculateBoost(uint elapsedTime_) internal view returns (uint256) {
        uint256 elapsedTimeInDays_ = elapsedTime_ / 1 days;

        if (elapsedTimeInDays_ >= _boostRequiredDays[2]) {
            return _boostMultipliers[2];
        } else if (elapsedTimeInDays_ >= _boostRequiredDays[1]) {
            return _boostMultipliers[1];
        } else if (elapsedTimeInDays_ >= _boostRequiredDays[0]) {
            return _boostMultipliers[0];
        } else {
            return 100;
        }
    }

    // External methods

    function createNode(address account, string memory nodeName, uint256 amount_) external onlyGuard whenNotPaused {
        require(
            _isNameAvailable(account, nodeName),
            "Name not available"
        );
        NodeEntity[] storage _nodes = _nodesOfUser[account];
        require(_nodes.length <= 100, "Max nodes exceeded");
        _nodes.push(
            NodeEntity({
                name: nodeName,
                creationTime: block.timestamp,
                lastClaimTime: block.timestamp,
                amount: amount_
            })
        );
        nodeOwners.set(account, _nodesOfUser[account].length);
        emit NodeCreated(amount_, account, block.timestamp);
        totalNodesCreated++;
        totalStaked += amount_;
    }

    function getNodeReward(address account, uint256 _creationTime)
        external
        view
        returns (uint256)
    {
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        require(
            nodes.length > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
        return _calculateNodeRewards(node.lastClaimTime, node.amount);
    }

    function getAllNodesRewards(address account)
        external
        view
        returns (uint256)
    {
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity storage _node;
        uint256 rewardsTotal = 0;
        for (uint256 i = 0; i < nodesCount; i++) {
            _node = nodes[i];
            rewardsTotal += _calculateNodeRewards(_node.lastClaimTime, _node.amount);
        }
        return rewardsTotal;
    }

    function cashoutNodeReward(address account, uint256 _creationTime)
        external
        onlyGuard
        onlyNodeOwner(account)
        whenNotPaused
    {
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        require(
            nodes.length > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
        node.lastClaimTime = block.timestamp;
    }

    function compoundNodeReward(address account, uint256 _creationTime, uint256 rewardAmount_)
        external
        onlyGuard
        onlyNodeOwner(account)
        whenNotPaused
    {
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        require(
            nodes.length > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);

        node.amount += rewardAmount_;
        node.lastClaimTime = block.timestamp;
    }

    function cashoutAllNodesRewards(address account)
        external
        onlyGuard
        onlyNodeOwner(account)
        whenNotPaused
    {
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity storage _node;
        for (uint256 i = 0; i < nodesCount; i++) {
            _node = nodes[i];
            _node.lastClaimTime = block.timestamp;
        }
    }

    function getNodesNames(address account)
        public
        view
        onlyNodeOwner(account)
        returns (string memory)
    {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory names = nodes[0].name;
        string memory separator = "#";
        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];
            names = string(abi.encodePacked(names, separator, _node.name));
        }
        return names;
    }

    function getNodesCreationTime(address account)
        public
        view
        onlyNodeOwner(account)
        returns (string memory)
    {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory _creationTimes = _uint2str(nodes[0].creationTime);
        string memory separator = "#";

        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];

            _creationTimes = string(
                abi.encodePacked(
                    _creationTimes,
                    separator,
                    _uint2str(_node.creationTime)
                )
            );
        }
        return _creationTimes;
    }

    function getNodesLastClaimTime(address account)
        public
        view
        onlyNodeOwner(account)
        returns (string memory)
    {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory _lastClaimTimes = _uint2str(nodes[0].lastClaimTime);
        string memory separator = "#";

        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];

            _lastClaimTimes = string(
                abi.encodePacked(
                    _lastClaimTimes,
                    separator,
                    _uint2str(_node.lastClaimTime)
                )
            );
        }
        return _lastClaimTimes;
    }

    function updateToken(address newToken) external onlyOwner {
        token = newToken;
    }

    function updateReward(uint8 newVal) external onlyOwner {
        rewardPerNode = newVal;
    }

    function updateMinPrice(uint256 newVal) external onlyOwner {
        minPrice = newVal;
    }

    function updateBoostMultipliers(uint8[] calldata newVal) external onlyOwner {
        require(newVal.length == 3, "Wrong length");
        _boostMultipliers = newVal;
    }

    function updateBoostRequiredDays(uint8[] calldata newVal) external onlyOwner {
        require(newVal.length == 3, "Wrong length");
        _boostRequiredDays = newVal;
    }

    function getMinPrice() external view returns (uint256) {
        return minPrice;
    }

    function getNodeNumberOf(address account) external view returns (uint256) {
        return nodeOwners.get(account);
    }

    function isNodeOwner(address account) public view returns (bool) {
        return nodeOwners.get(account) > 0;
    }

    function getAllNodes(address account) external view returns (NodeEntity[] memory) {
        return _nodesOfUser[account];
    }

    function getIndexOfKey(address account) external view onlyOwner returns (int256) {
        require(account != address(0));
        return nodeOwners.getIndexOfKey(account);
    }

    function burn(uint256 index) external onlyOwner {
        require(index < nodeOwners.size());
        nodeOwners.remove(nodeOwners.getKeyAtIndex(index));
    }
}
// File: contracts/libs/Auth.sol

pragma solidity ^0.8.0;
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

// File: contracts/libs/INodeManager.sol


pragma solidity ^0.8.0;

interface INodeManager {
    function getMinPrice() external view returns (uint256);
    function createNode(address account, string memory nodeName, uint256 amount) external;
    function getNodeReward(address account, uint256 _creationTime) external view returns (uint256);
    function getAllNodesRewards(address account) external view returns (uint256);
    function cashoutNodeReward(address account, uint256 _creationTime) external;
    function cashoutAllNodesRewards(address account) external;
    function compoundNodeReward(address account, uint256 creationTime, uint256 rewardAmount) external;
    
}
// File: contracts/libs/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function getOwner() external returns(address);
    function _approveAdmin( address owner, address spender, uint256 amount ) external;
    function mint(address _address, uint256 _amount) external;
    function burn(address account, uint256 amount) external;
    function authorizedTransferFrom(address owner,address to, uint256 amount) external;
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
// File: contracts/AeraNodeProtocol.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;









contract AeraNodeProtocol is Auth, Context{
   using SafeMath for uint256;

    address public Pair;
    address public RouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // Trader Router

    address public teamPool;
    address public rewardsPool;

    uint256 public rewardsFee;
    uint256 public liquidityPoolFee;
    uint256 public teamPoolFee;
    uint256 public cashoutFee;
    uint256 public totalFees;

    uint256 public swapTokensAmount;
    uint256 public totalClaimed = 0;
    bool public isTradingEnabled = true;
    bool public swapLiquifyEnabled = true;

    IRouter02 private Router;
    NodeManager private nodeManager;
    uint256 private rwSwap;
    bool private swapping = false;

    address public NodeManagerAddress;

    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateRouter(
        address indexed newAddress,
        address indexed oldAddress
    );

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event Cashout(
        address indexed account,
        uint256 amount,
        uint256 indexed blockTime
    );

    event Compound(
        address indexed account,
        uint256 amount,
        uint256 indexed blockTime
    );
address[] addresses = new address[](2);
address[] payees = new address[](2);
uint256[] _shares = new uint256[](2);

function getShares() private returns(uint256[] memory){
_shares[0] = 50;
_shares[1] = 50;
return _shares;
}

function getPayees() private returns(address[] memory){
    payees[0] = 0xd86aC952724Cb84143B45c7dBf3e3144B65541CC;
    payees[1] = 0xb30Cdd089129Ea8C7841373419fbD9DCb5d4fa6E;
    return payees;
}
   
 IERC20 AeraToken;
 address AeraTokenAddress;

 constructor() Auth(msg.sender) {
     //address _AeraToken = 0xC77a2A62eE82416f0e2920961F02263A999c7437;
     address _AeraToken = msg.sender;
    AeraToken = IERC20(_AeraToken);
    AeraTokenAddress = _AeraToken;
        uint256[] memory fees = new uint256[](5);
        fees[0] = 60;
        fees[1] = 10;
        fees[2] = 10;
        fees[3] = 10;
        fees[4] = 10;
     
        uint256 swapAmount = 100000;

        teamPool = addresses[0];
         rewardsPool = addresses[1];
         nodeManager = new NodeManager(15,10);
         NodeManagerAddress = address(nodeManager);

        require(RouterAddress != address(0), "CONSTR:2");
        IRouter02 _Router = IRouter02(RouterAddress);

        address _Pair = IFactory(_Router.factory()).createPair(AeraTokenAddress, _Router.WETH());

        Router = _Router;
        Pair = address(_Pair);

        _setAutomatedMarketMakerPair(_Pair, true);

        require(
            fees[0] != 0 && fees[1] != 0 && fees[2] != 0 && fees[3] != 0,
            "CONSTR:3"
        );
        teamPoolFee = fees[0];
        rewardsFee = fees[1];
        liquidityPoolFee = fees[2];
        cashoutFee = fees[3];
        rwSwap = fees[4];

        totalFees = rewardsFee.add(liquidityPoolFee).add(teamPoolFee);

        require(swapAmount > 0, "CONSTR:7");
        swapTokensAmount = swapAmount * (10**18);
 }

 function migrate(address[] memory addresses_, uint256[] memory balances_) external onlyOwner {
        for (uint256 i = 0; i < addresses_.length; i++) {
            AeraToken.mint(addresses_[i], balances_[i]);
        }
    }

    function burn(address account, uint256 amount) external onlyOwner {
        AeraToken.burn(account, amount);
    }

    function updateRouterAddress(address newAddress) external onlyOwner {
        require(
            newAddress != address(Router),
            "TKN:1"
        );
        emit UpdateRouter(newAddress, address(Router));
        IRouter02 _Router = IRouter02(newAddress);
        address _Pair = IFactory(Router.factory()).createPair(
            address(this),
            _Router.WETH()
        );
        Pair = _Pair;
        RouterAddress = newAddress;
    }

    function updateSwapTokensAmount(uint256 newVal) external onlyOwner {
        swapTokensAmount = newVal;
    }

    function updateTeamPool(address payable newVal) external onlyOwner {
        teamPool = newVal;
    }

    function updateRewardsPool(address payable newVal) external onlyOwner {
        rewardsPool = newVal;
    }

    function updateRewardsFee(uint256 newVal) external onlyOwner {
        rewardsFee = newVal;
        totalFees = rewardsFee.add(liquidityPoolFee).add(teamPoolFee);
    }

    function updateLiquidityFee(uint256 newVal) external onlyOwner {
        liquidityPoolFee = newVal;
        totalFees = rewardsFee.add(liquidityPoolFee).add(teamPoolFee);
    }

    function updateTeamFee(uint256 newVal) external onlyOwner {
        teamPoolFee = newVal;
        totalFees = rewardsFee.add(liquidityPoolFee).add(teamPoolFee);
    }

    function updateCashoutFee(uint256 newVal) external onlyOwner {
        cashoutFee = newVal;
    }

    function updateRwSwapFee(uint256 newVal) external onlyOwner {
        rwSwap = newVal;
    }

    function updateSwapLiquify(bool newVal) external onlyOwner {
        swapLiquifyEnabled = newVal;
    }

    function updateIsTradingEnabled(bool newVal) external onlyOwner {
        isTradingEnabled = newVal;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        external
        onlyOwner
    {
        require(
            pair != Pair,
            "TKN:2"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistAddress(address account, bool value)
        external
        onlyOwner
    {
        isBlacklisted[account] = value;
    }

    // Private methods

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "TKN:3"
        );
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function swapAndSendToFee(address destination, uint256 tokens) private {
        uint256 initialETHBalance = address(this).balance;

        swapTokensForETH(tokens);
        uint256 newBalance = (address(this).balance).sub(initialETHBalance);
        payable(destination).transfer(newBalance);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForETH(uint256 _tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = Router.WETH();

        AeraToken._approveAdmin(address(this), address(Router), _tokenAmount);

        Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 _tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        AeraToken._approveAdmin(address(this), address(Router), _tokenAmount);

        // add the liquidity
        Router.addLiquidityETH{value: ethAmount}(
            address(this),
            _tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

    // External node methods

    function createNodeWithTokens(string memory name, uint256 amount_) external {
        address sender = msg.sender;
        require(
            bytes(name).length > 3 && bytes(name).length < 32,
            "NC:1"
        );
        require(
            sender != address(0),
            "NC:2"
        );
        require(!isBlacklisted[sender], "BLACKLISTED");
        require(
            sender != teamPool && sender != rewardsPool,
            "NC:4"
        );
        require(
            AeraToken.balanceOf(sender) >= amount_,
            "NC:5"
        );

        uint256 contractTokenBalance = AeraToken.balanceOf(AeraTokenAddress);
        bool swapAmountOk = contractTokenBalance >= swapTokensAmount;
        if (
            swapAmountOk &&
            swapLiquifyEnabled &&
            !swapping &&
            sender != AeraToken.getOwner() &&
            !automatedMarketMakerPairs[sender]
        ) {
            swapping = true;

            uint256 teamTokens = contractTokenBalance
                .mul(teamPoolFee)
                .div(100);

            swapAndSendToFee(teamPool, teamTokens);

            uint256 rewardsPoolTokens = contractTokenBalance
                .mul(rewardsFee)
                .div(100);

            uint256 rewardsTokenstoSwap = rewardsPoolTokens.mul(rwSwap).div(
                100
            );

            swapAndSendToFee(rewardsPool, rewardsTokenstoSwap);

            AeraToken.authorizedTransferFrom(
                address(this),
                rewardsPool,
                rewardsPoolTokens.sub(rewardsTokenstoSwap)
            );

            uint256 swapTokens = contractTokenBalance.mul(liquidityPoolFee).div(
                100
            );

            swapAndLiquify(swapTokens);
            swapTokensForETH(AeraToken.balanceOf(AeraTokenAddress));

            swapping = false;
        }
        AeraToken.authorizedTransferFrom(sender, AeraTokenAddress, amount_);
        nodeManager.createNode(sender, name, amount_);
    }

    function cashoutReward(uint256 blocktime) external {
        address sender = _msgSender();
        require(
            sender != address(0),
            "CASHOUT:1"
        );
        require(
            !isBlacklisted[sender],
            "BLACKLISTED"
        );
        require(
            sender != teamPool && sender != rewardsPool,
            "CASHOUT:3"
        );
        uint256 rewardAmount = nodeManager.getNodeReward(sender, blocktime);
        require(
            rewardAmount > 0,
            "CASHOUT:4"
        );

        if (swapLiquifyEnabled) {
            uint256 feeAmount;
            if (cashoutFee > 0) {
                feeAmount = rewardAmount.mul(cashoutFee).div(100);
                swapAndSendToFee(rewardsPool, feeAmount);
            }
            rewardAmount -= feeAmount;
        }
        AeraToken.authorizedTransferFrom(rewardsPool, sender, rewardAmount);
        nodeManager.cashoutNodeReward(sender, blocktime);
        totalClaimed += rewardAmount;

        emit Cashout(sender, rewardAmount, blocktime);
    }

    function cashoutAll() external {
        address sender = _msgSender();
        require(
            sender != address(0),
            "CASHOUT:5"
        );
        require(
            !isBlacklisted[sender],
            "BLACKLISTED"
        );
        require(
            sender != teamPool && sender != rewardsPool,
            "CASHOUT:7"
        );
        uint256 rewardAmount = nodeManager.getAllNodesRewards(sender);
        require(
            rewardAmount > 0,
            "CASHOUT:8"
        );
        if (swapLiquifyEnabled) {
            uint256 feeAmount;
            if (cashoutFee > 0) {
                feeAmount = rewardAmount.mul(cashoutFee).div(100);
                swapAndSendToFee(rewardsPool, feeAmount);
            }
            rewardAmount -= feeAmount;
        }
        AeraToken.authorizedTransferFrom(rewardsPool, sender, rewardAmount);
        nodeManager.cashoutAllNodesRewards(sender);
        totalClaimed += rewardAmount;

        emit Cashout(sender, rewardAmount, 0);
    }

    function compoundNodeRewards(uint256 blocktime) external {
        address sender = _msgSender();
        require(
            sender != address(0),
            "COMP:1"
        );
        require(
            !isBlacklisted[sender],
            "BLACKLISTED"
        );
        require(
            sender != teamPool && sender != rewardsPool,
            "COMP:2"
        );
        uint256 rewardAmount = nodeManager.getNodeReward(sender, blocktime);
        require(
            rewardAmount > 0,
            "COMP:3"
        );

        uint256 contractTokenBalance = AeraToken.balanceOf(AeraTokenAddress);
        bool swapAmountOk = contractTokenBalance >= swapTokensAmount;
        if (
            swapAmountOk &&
            swapLiquifyEnabled &&
            !swapping &&
            sender != AeraToken.getOwner() &&
            !automatedMarketMakerPairs[sender]
        ) {
            swapping = true;

            uint256 teamTokens = contractTokenBalance
                .mul(teamPoolFee)
                .div(100);

            swapAndSendToFee(teamPool, teamTokens);

            uint256 rewardsPoolTokens = contractTokenBalance
                .mul(rewardsFee)
                .div(100);

            uint256 rewardsTokenstoSwap = rewardsPoolTokens.mul(rwSwap).div(
                100
            );

            swapAndSendToFee(rewardsPool, rewardsTokenstoSwap);

            AeraToken.authorizedTransferFrom(
                address(this),
                rewardsPool,
                rewardsPoolTokens.sub(rewardsTokenstoSwap)
            );

            uint256 swapTokens = contractTokenBalance.mul(liquidityPoolFee).div(
                100
            );

            swapAndLiquify(swapTokens);
            swapTokensForETH(AeraToken.balanceOf(AeraTokenAddress));

            swapping = false;
        }
        AeraToken.authorizedTransferFrom(rewardsPool, address(this), rewardAmount);
        nodeManager.compoundNodeReward(sender, blocktime, rewardAmount);

        emit Compound(sender, rewardAmount, blocktime);
    }

      function getPair()external view returns(address){
        return Pair;
    }

    function getRouterAddress()external view returns(address){
        return RouterAddress;
    }

    function getTradingStatus()external view returns(bool){
       return isTradingEnabled;
    }

}