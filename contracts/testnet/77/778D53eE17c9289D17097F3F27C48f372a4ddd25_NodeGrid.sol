/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IUniswapV2Factory {
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

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

contract NODERewardManagement {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    modifier onlyManager() {
        require(_managers[msg.sender] == true, "Only managers can call this function");
        _;
    }

    struct NodeEntity {
        uint256 nodeId;
        uint32 tierId;
        uint256 creationTime;
        uint256 lastClaimTime;
        uint256 rewardNotClaimed;
    }

    struct TierInfo {
        string nodeName;
        uint256 nodePrice;
        uint256 rewardsPerTime;
        uint256 claimInterval;
    }

    IterableMapping.Map private nodeOwners;
    mapping(address => NodeEntity[]) private _nodesOfUser;
    mapping(address => bool) public _managers;

    TierInfo[] public tierInfo;
    // uint256 public nodePrice = 0; // 10
    // uint256 public rewardsPerTime = 0; // 1
    // uint256 public claimInterval = 0; // 5 min

    uint256 public lastIndexProcessed = 0;
    uint256 public totalNodesCreated = 0;
    uint256 public totalRewardStaked = 0;

    bool public createSingleNodeEnabled = false;
    bool public createMultiNodeEnabled = false;
    bool public cashoutEnabled = false;

    uint256 public gasForDistribution = 30000;

    event NodeCreated(address indexed from, uint256 nodeId, uint256 index, uint256 totalNodesCreated);

    constructor(
    ) {
        _managers[msg.sender] = true;
        
    }

    function updateManagers(address manager, bool newVal) external onlyManager {
        require(manager != address(0),"new manager is the zero address");
        _managers[manager] = newVal;
    }

    // string memory nodeName, uint256 expireTime ignored, just for match with old contract
    function createNode(address account, string memory nodeName, uint256 expireTime) external onlyManager {

        require(createSingleNodeEnabled,"createSingleNodeEnabled disabled");

        _nodesOfUser[account].push(
            NodeEntity({
        nodeId : totalNodesCreated + 1,
        tierId: 0, 
        creationTime : block.timestamp,
        lastClaimTime : block.timestamp,
        rewardNotClaimed : 0
        })
        );

        nodeOwners.set(account, _nodesOfUser[account].length);
        totalNodesCreated++;
        emit NodeCreated(account, totalNodesCreated, _nodesOfUser[account].length, totalNodesCreated);
    }

    function createNodesWithRewardsAndClaimDates(address account, uint256 numberOfNodes, uint256[] memory rewards, uint256[] memory claimsTimes) external onlyManager {

        require(createMultiNodeEnabled,"createcreateMultiNodeEnabledSingleNodeEnabled disabled");
        require(numberOfNodes > 0,"createNodes numberOfNodes cant be zero");
        require(rewards.length > 0 ? rewards.length == numberOfNodes: true,"rewards length not equal numberOfNodes");
        require(claimsTimes.length > 0 ? claimsTimes.length == numberOfNodes: true,"claimsTimes length not equal numberOfNodes");
        require(rewards.length > 0 && claimsTimes.length > 0 ? rewards.length == numberOfNodes && claimsTimes.length == numberOfNodes: true,"rewards and claimsTimes length not equal numberOfNodes");

        for (uint256 i = 0; i < numberOfNodes; i++) {
            _nodesOfUser[account].push(
                NodeEntity({
            nodeId : totalNodesCreated + 1,
            tierId: 0,
            creationTime : block.timestamp + i,
            lastClaimTime : claimsTimes.length > 0 ? claimsTimes[i] : 0,
            rewardNotClaimed : rewards.length > 0 ? rewards[i] : 0
            })
            );

            nodeOwners.set(account, _nodesOfUser[account].length);
            totalNodesCreated++;
            emit NodeCreated(account, totalNodesCreated, _nodesOfUser[account].length, totalNodesCreated);
        }
    }

    function addTierInfo(string memory _nodeName, uint256 _nodePrice, uint256 _rewardsPerTime, uint256 _claimInterval) public onlyManager {
        tierInfo.push(TierInfo({
            nodeName: _nodeName,
            nodePrice: _nodePrice,
            rewardsPerTime: _rewardsPerTime,
            claimInterval: _claimInterval
        }));
    }

    function updateTierInfo(uint256 _index, string memory _nodeName, uint256 _nodePrice, uint256 _rewardsPerTime, uint256 _claimInterval) public onlyManager{
        require(_index < tierInfo.length, "Invalid Node Type Key");
        tierInfo[_index].nodeName = _nodeName;
        tierInfo[_index].nodePrice = _nodePrice;
        tierInfo[_index].rewardsPerTime = _rewardsPerTime;
        tierInfo[_index].claimInterval = _claimInterval;
    }

    function removeTierInfo(uint256 _index) public onlyManager{
        require(_index < tierInfo.length, "Invalid Node Type Key");

        for (uint i = _index; i < tierInfo.length - 1; i++) {
            tierInfo[i] = tierInfo[i + 1];
        }
        tierInfo.pop();
    }

    function createNodes(address account, uint256 numberOfNodes, uint32 tid) external onlyManager {
        require(tid < tierInfo.length, "Invalid nodeTier");
        require(createMultiNodeEnabled,"createcreateMultiNodeEnabledSingleNodeEnabled disabled");
        require(numberOfNodes > 0,"createNodes numberOfNodes cant be zero");

        for (uint256 i = 0; i < numberOfNodes; i++) {
            _nodesOfUser[account].push(
                NodeEntity({
            nodeId : totalNodesCreated + 1,
            tierId : tid,
            creationTime : block.timestamp + i,
            lastClaimTime : block.timestamp + i,
            rewardNotClaimed : 0
            })
            );

            nodeOwners.set(account, _nodesOfUser[account].length);
            totalNodesCreated++;
            emit NodeCreated(account, totalNodesCreated, _nodesOfUser[account].length, totalNodesCreated);
        }
    }

    function burn(address account, uint256 _creationTime) external onlyManager {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");

        int256 nodeIndex = getNodeIndexByCreationTime(_nodesOfUser[account], _creationTime);

        require(uint256(nodeIndex) < _nodesOfUser[account].length, "NODE: CREATIME must be higher than zero");
        nodeOwners.remove(nodeOwners.getKeyAtIndex(uint256(nodeIndex)));
    }

    function getNodeIndexByCreationTime(
        NodeEntity[] storage nodes,
        uint256 _creationTime
    ) private view returns (int256) {
        bool found = false;
        int256 index = binary_search(nodes, 0, nodes.length, _creationTime);
        int256 validIndex;
        if (index >= 0) {
            found = true;
            validIndex = int256(index);
        }
        return validIndex;
    }

    function getNodeInfo(
        address account,
        uint256 _creationTime
    ) public view returns (NodeEntity memory) {

        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");

        int256 nodeIndex = getNodeIndexByCreationTime(_nodesOfUser[account], _creationTime);

        require(nodeIndex != -1, "NODE SEARCH: No NODE Found with this blocktime");
        return _nodesOfUser[account][uint256(nodeIndex)];
    }

    
    function getNodePriceFromTierInfo(uint32 tid) external view returns (uint256) {
        require(tid < tierInfo.length, "Invalide TierId");
        return tierInfo[tid].nodePrice;
    }

    function _getNodeWithCreatime(
        NodeEntity[] storage nodes,
        uint256 _creationTime
    ) private view returns (NodeEntity storage) {

        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        int256 nodeIndex = getNodeIndexByCreationTime(nodes, _creationTime);

        require(nodeIndex != -1, "NODE SEARCH: No NODE Found with this blocktime");
        return nodes[uint256(nodeIndex)];
    }

    function updateRewardsToNode(address account, uint256 _creationTime, uint256 amount, bool increaseOrDecrease)
    external onlyManager
    {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        require(amount > 0, "amount must be higher than zero");

        int256 nodeIndex = getNodeIndexByCreationTime(_nodesOfUser[account], _creationTime);
        require(nodeIndex != -1, "NODE SEARCH: No NODE Found with this blocktime");

        increaseOrDecrease ? _nodesOfUser[account][uint256(nodeIndex)].rewardNotClaimed += amount : _nodesOfUser[account][uint256(nodeIndex)].rewardNotClaimed -= amount;
    }

    function _cashoutNodeReward(address account, uint256 _creationTime)
    external
    returns (uint256)
    {
        require(cashoutEnabled, "cashoutEnabled disabled");
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");

        NodeEntity storage node = _getNodeWithCreatime(_nodesOfUser[account], _creationTime);
        require(isNodeClaimable(node), "too early to claim from this node");

        int256 nodeIndex = getNodeIndexByCreationTime(_nodesOfUser[account], _creationTime);
        uint256 rewardNode = availableClaimableAmount(node.tierId, node.lastClaimTime) + node.rewardNotClaimed;

        _nodesOfUser[account][uint256(nodeIndex)].rewardNotClaimed = 0;
        _nodesOfUser[account][uint256(nodeIndex)].lastClaimTime = block.timestamp;

        return rewardNode;
    }

    function _cashoutAllNodesReward(address account)
    external onlyManager
    returns (uint256)
    {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        require(cashoutEnabled, "cashoutEnabled disabled");

        uint256 rewardsTotal = 0;
        for (uint256 i = 0; i < _nodesOfUser[account].length; i++) {
            rewardsTotal += availableClaimableAmount(_nodesOfUser[account][i].tierId, _nodesOfUser[account][i].lastClaimTime) + _nodesOfUser[account][i].rewardNotClaimed;
            _nodesOfUser[account][i].rewardNotClaimed = 0;
            _nodesOfUser[account][i].lastClaimTime = block.timestamp;
        }
        return rewardsTotal;
    }

    function isNodeClaimable(NodeEntity memory node) private view returns (bool) {
        uint256 claimInterval = tierInfo[node.tierId].claimInterval;
        return node.lastClaimTime + claimInterval <= block.timestamp;
    }

    function _getRewardAmountOf(address account)
    external
    view
    returns (uint256)
    {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");

        uint256 rewardCount = 0;

        for (uint256 i = 0; i < _nodesOfUser[account].length; i++) {
            rewardCount += availableClaimableAmount(_nodesOfUser[account][i].tierId, _nodesOfUser[account][i].lastClaimTime) + _nodesOfUser[account][i].rewardNotClaimed;
        }

        return rewardCount;
    }

    function _getRewardAmountOf(address account, uint256 _creationTime)
    external
    view
    returns (uint256)
    {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");

        NodeEntity storage node = _getNodeWithCreatime(_nodesOfUser[account], _creationTime);
        return availableClaimableAmount(node.tierId, node.lastClaimTime) + node.rewardNotClaimed;
    }

    function _pendingClaimableAmount(uint32 nodeTierId, uint256 nodeLastClaimTime) private view returns (uint256 availableRewards) {
        uint256 currentTime = block.timestamp;
        uint256 timePassed = (currentTime).sub(nodeLastClaimTime);
        uint256 intervalsPassed = timePassed.div(tierInfo[nodeTierId].claimInterval);
        if (intervalsPassed < 1) {
            return timePassed.mul(tierInfo[nodeTierId].rewardsPerTime).div(tierInfo[nodeTierId].claimInterval);
        }

        return 0;
    }

    function availableClaimableAmount(uint32 nodeTierId, uint256 nodeLastClaimTime) private view returns (uint256 availableRewards) {
        uint256 currentTime = block.timestamp;
        uint256 intervalsPassed = (currentTime).sub(nodeLastClaimTime).div(tierInfo[nodeTierId].claimInterval);
        return intervalsPassed.mul(tierInfo[nodeTierId].rewardsPerTime);
    }

    function _getNodesPendingClaimableAmount(address account)
    external
    view
    returns (string memory)
    {
        require(isNodeOwner(account), "GET CREATIME: NO NODE OWNER");

        string memory pendingClaimableAmount = uint2str(_pendingClaimableAmount(_nodesOfUser[account][0].tierId, _nodesOfUser[account][0].lastClaimTime));

        for (uint256 i = 1; i < _nodesOfUser[account].length; i++) {
            pendingClaimableAmount = string(abi.encodePacked(pendingClaimableAmount,"#", uint2str(_pendingClaimableAmount(_nodesOfUser[account][i].tierId, _nodesOfUser[account][i].lastClaimTime))));
        }

        return pendingClaimableAmount;
    }

    function _getNodesCreationTime(address account)
    external
    view
    returns (string memory)
    {
        require(isNodeOwner(account), "GET CREATIME: NO NODE OWNER");

        string memory _creationTimes = uint2str(_nodesOfUser[account][0].creationTime);

        for (uint256 i = 1; i < _nodesOfUser[account].length; i++) {
            _creationTimes = string(abi.encodePacked(_creationTimes,"#",uint2str(_nodesOfUser[account][i].creationTime)));
        }

        return _creationTimes;
    }

    function _getNodesRewardAvailable(address account)
    external
    view
    returns (string memory)
    {
        require(isNodeOwner(account), "GET REWARD: NO NODE OWNER");

        string memory _rewardsAvailable = uint2str(availableClaimableAmount(_nodesOfUser[account][0].tierId, _nodesOfUser[account][0].lastClaimTime) + _nodesOfUser[account][0].rewardNotClaimed);

        for (uint256 i = 1; i < _nodesOfUser[account].length; i++) {
            _rewardsAvailable = string(
                abi.encodePacked(
                    _rewardsAvailable,
                    "#",
                    uint2str(availableClaimableAmount(_nodesOfUser[account][i].tierId, _nodesOfUser[account][i].lastClaimTime) + _nodesOfUser[account][i].rewardNotClaimed)
                )
            );
        }
        return _rewardsAvailable;
    }
    // not used, just for be compatible, with old contract
    function _getNodesExpireTime(address account)
    external
    view
    returns (string memory)
    {
        return "";
    }

    function _getNodesLastClaimTime(address account)
    external
    view
    returns (string memory)
    {

        require(isNodeOwner(account), "GET REWARD: NO NODE OWNER");

        string memory _lastClaimTimes = uint2str(_nodesOfUser[account][0].lastClaimTime);

        for (uint256 i = 1; i < _nodesOfUser[account].length; i++) {
            _lastClaimTimes = string(abi.encodePacked(_lastClaimTimes,"#",uint2str(_nodesOfUser[account][i].lastClaimTime)));
        }
        return _lastClaimTimes;
    }

    function _refreshNodeRewards(uint256 gas) private
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        uint256 numberOfnodeOwners = nodeOwners.keys.length;
        require(numberOfnodeOwners > 0, "DISTRI REWARDS: NO NODE OWNERS");
        if (numberOfnodeOwners == 0) {
            return (0, 0, lastIndexProcessed);
        }

        uint256 iterations = 0;
        uint256 claims = 0;
        uint256 localLastIndex = lastIndexProcessed;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 newGasLeft;

        while (gasUsed < gas && iterations < numberOfnodeOwners) {

            localLastIndex++;
            if (localLastIndex >= nodeOwners.keys.length) {
                localLastIndex = 0;
            }

            address account = nodeOwners.keys[localLastIndex];
            for (uint256 i = 0; i < _nodesOfUser[account].length; i++) {

                int256 nodeIndex = getNodeIndexByCreationTime(_nodesOfUser[account], _nodesOfUser[account][i].creationTime);
                require(nodeIndex != -1, "NODE SEARCH: No NODE Found with this blocktime");

                uint256 rewardNotClaimed = availableClaimableAmount(_nodesOfUser[account][i].tierId, _nodesOfUser[account][i].lastClaimTime) + _pendingClaimableAmount(_nodesOfUser[account][i].tierId, _nodesOfUser[account][i].lastClaimTime);
                _nodesOfUser[account][uint256(nodeIndex)].rewardNotClaimed += rewardNotClaimed;
                _nodesOfUser[account][uint256(nodeIndex)].lastClaimTime = block.timestamp;
                totalRewardStaked += rewardNotClaimed;
                claims++;
            }
            iterations++;

            newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }
        lastIndexProcessed = localLastIndex;
        return (iterations, claims, lastIndexProcessed);
    }

    function _updateRewardsToAllNodes(uint256 gas, uint256 rewardAmount, bool increaseOrDecrease) private
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        uint256 numberOfnodeOwners = nodeOwners.keys.length;
        require(numberOfnodeOwners > 0, "DISTRI REWARDS: NO NODE OWNERS");
        if (numberOfnodeOwners == 0) {
            return (0, 0, lastIndexProcessed);
        }

        uint256 iterations = 0;
        uint256 claims = 0;
        uint256 localLastIndex = lastIndexProcessed;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 newGasLeft;

        while (gasUsed < gas && iterations < numberOfnodeOwners) {

            localLastIndex++;
            if (localLastIndex >= nodeOwners.keys.length) {
                localLastIndex = 0;
            }

            address account = nodeOwners.keys[localLastIndex];

            for (uint256 i = 0; i < _nodesOfUser[account].length; i++) {

                int256 nodeIndex = getNodeIndexByCreationTime(_nodesOfUser[account], _nodesOfUser[account][i].creationTime);

                increaseOrDecrease ? _nodesOfUser[account][uint256(nodeIndex)].rewardNotClaimed += rewardAmount : _nodesOfUser[account][uint256(nodeIndex)].rewardNotClaimed -= rewardAmount;
                _nodesOfUser[account][uint256(nodeIndex)].lastClaimTime = block.timestamp;
                totalRewardStaked += rewardAmount;
                claims++;
            }
            iterations++;

            newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }
        lastIndexProcessed = localLastIndex;
        return (iterations, claims, lastIndexProcessed);
    }

    function updateRewardsToAllNodes(uint256 gas, uint256 amount, bool increaseOrDecrease) external onlyManager
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        return _updateRewardsToAllNodes(gas, amount, increaseOrDecrease);
    }

    function refreshNodeRewards(uint256 gas) external onlyManager
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        return _refreshNodeRewards(gas);
    }

    function _changeGasDistri(uint256 newGasDistri) external onlyManager {
        gasForDistribution = newGasDistri;
    }

    function _changeCreateSingleNodeEnabled(bool newVal) external onlyManager {
        createSingleNodeEnabled = newVal;
    }

    function _changeCashoutEnabled(bool newVal) external onlyManager {
        cashoutEnabled = newVal;
    }

    function _changeCreateMultiNodeEnabled(bool newVal) external onlyManager {
        createMultiNodeEnabled = newVal;
    }

    function _getNodeNumberOf(address account) public view returns (uint256) {
        return nodeOwners.get(account);
    }

    function isNodeOwner(address account) private view returns (bool) {
        return nodeOwners.get(account) > 0;
    }

    function _isNodeOwner(address account) external view returns (bool) {
        return isNodeOwner(account);
    }

    function uint2str(uint256 _i)
    internal
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

    function binary_search(
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
                return binary_search(arr, low, mid - 1, x);
            } else {
                return binary_search(arr, mid + 1, high, x);
            }
        } else {
            return -1;
        }
    }
}

// INIT
contract NodeGrid is Context, IERC20, Ownable {
    NODERewardManagement public nodeRewardManagement;

    address public rewardsPoolAddress;
    uint256 public rewardsPoolFee;

    address public treasuryAddress;
    uint256 public treasuryFee;

    address public smoothingReserveAddress;
    uint256 public smoothingReserveFee;

    address public operationPoolAddress;
    uint256 public operationPoolFee;

    uint256 public cashoutFee = 0;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    uint256 public maxNodesAllowed = 100;

    uint256 accumulatedTreasureTokensAmount = 0;
    uint256 accumulatedSmoothingTokensAmount = 0;
    uint256 accumulatedOperationPoolTokensAmount = 0;

    uint256 swapTreasureTokensThreshold = 0;
    uint256 swapSmoothingTokensThreshold = 0;
    uint256 swapOperationTokensThreshold = 0;
    mapping(address => bool) public _isBlacklisted;

    // --- code of token
    using SafeMath for uint256;
    using Address for address;

    address payable public liquidityAddress;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = true;
    bool public limitsInEffect = true;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1 * 1e6 * 1e18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "NODEGRID";
    string private constant _symbol = "NGR";
    uint8 private constant _decimals = 18;

    // these values are pretty much arbitrary since they get overwritten for every txn, but the placeholders make it easier to work with current contract.
    uint256 private _taxFee;
    uint256 private _previousTaxFee = _taxFee;

    uint256 private _liquidityFee;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 private constant BUY = 1;
    uint256 private constant SELL = 2;
    uint256 private constant TRANSFER = 3;
    uint256 private buyOrSellSwitch;

    uint256 public _buyTaxFee = 0;
    uint256 public _buyLiquidityFee = 0;
    uint256 public _buyOperationsFee = 0;

    uint256 public _sellTaxFee = 0;
    uint256 public _sellLiquidityFee = 0;
    uint256 public _sellOperationsFee = 18;
    uint256 private BASE_FEE_PERCENT = 100;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active

    uint256 public _liquidityTokensToSwap;
    uint256 public _operationToSwap;

    uint256 public maxTransactionAmount;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;
    uint256 public maxWallet;

    bool private gasLimitActive = true;
    uint256 private gasPriceLimit = 40000000000; // do not allow over x gwei for launch

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 private minimumTokensBeforeSwap;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public tradingActive = false;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    event SwapETHForTokens(uint256 amountIn, address[] path);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    event SetAutomatedMarketMakerPair(address pair, bool value);
    event ExcludeFromReward(address excludedAddress);
    event IncludeInReward(address includedAddress);
    event ExcludeFromFee(address excludedAddress);
    event IncludeInFee(address includedAddress);
    event SetBuyFee(uint256 marketingFee, uint256 liquidityFee, uint256 reflectFee);
    event SetSellFee(uint256 marketingFee, uint256 liquidityFee, uint256 reflectFee);
    event TransferForeignToken(address token, uint256 amount);
    event UpdatedMarketingAddress(address marketing);
    event UpdatedLiquidityAddress(address liquidity);
    event UpdatedDevAddress(address dev);
    event OwnerForcedSwapBack(uint256 timestamp);
    event UpdateUniswapV2Router(address newAddress);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address[] memory addresses,
        uint256[] memory fees
    ) payable {

        require(
            addresses[0] != address(0) &&
            addresses[1] != address(0) &&
            addresses[2] != address(0) &&
            addresses[3] != address(0),
            "REWARD, TREASURE, OPERATION, SMOOTING OR TREASURY ADDRESS CANNOT BE ZERO"
        );

        rewardsPoolAddress = addresses[0];
        treasuryAddress = addresses[1];
        smoothingReserveAddress = addresses[2];
        operationPoolAddress = addresses[3];

        require(
            fees[0] != 0,
            "CONSTR: Fees equal 0"
        );

        rewardsPoolFee = fees[0];
        treasuryFee = fees[1];
        operationPoolFee = fees[2];
        smoothingReserveFee = fees[3];

        // Working
        //_rOwned[_msgSender()] = _rTotal / 100 * 50;
        //_rOwned[address(this)] = _rTotal / 100 * 50;

        // Test
        _rOwned[_msgSender()] = _rTotal / 100 * 100; // 100%
        _rOwned[address(this)] = 0;

        // lowered due to lower initial liquidity amount.
        maxTransactionAmount = _tTotal * 25 / 10000;
        // 0.25% maxTransactionAmountTxn

        minimumTokensBeforeSwap = _tTotal * 25 / 100000;
        // 0.025% swap tokens amount

        maxWallet = _tTotal * 1 / 100;
        // 1% max wallet

        liquidityAddress = payable(owner());
        // Liquidity Address (switches to dead address once launch happens)

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[liquidityAddress] = true;

        _isExcludedFromFee[addresses[0]] = true;
        _isExcludedFromFee[addresses[1]] = true;
        _isExcludedFromFee[addresses[2]] = true;
        _isExcludedFromFee[addresses[3]] = true;

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);

        excludeFromMaxTransaction(addresses[0], true);
        excludeFromMaxTransaction(addresses[1], true);
        excludeFromMaxTransaction(addresses[2], true);
        excludeFromMaxTransaction(addresses[3], true);

        // Work
        //emit Transfer(address(0), _msgSender(), _tTotal * 50 / 100);
        //emit Transfer(address(0), address(this), _tTotal * 50 / 100);

        emit Transfer(address(0), _msgSender(), _tTotal * 100 / 100);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(
            !_isBlacklisted[from],
            "NODE CREATION: Blacklisted address"
        );

        if (!tradingActive) {
            require(_isExcludedFromFee[from] || _isExcludedFromFee[to], "Trading is not active yet.");
        }

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !inSwapAndLiquify
            ) {
                // only use to prevent sniper buys in the first blocks.
                if (gasLimitActive && automatedMarketMakerPairs[from]) {
                    require(tx.gasprice <= gasPriceLimit, "Gas price exceeds limit.");
                }

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (transferDelayEnabled) {
                    if (to != owner() && to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                        require(_holderLastTransferTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                    }
                }

                //when buy
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
                    require(amount + balanceOf(to) <= maxWallet, "Max Wallet Exceeded");
                }

                //when sell
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
                }

                else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "Max Wallet Exceeded");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;

        // swap and liquify (buy back)
        if (
            !inSwapAndLiquify &&
        swapAndLiquifyEnabled &&
        balanceOf(uniswapV2Pair) > 0 &&
        !_isExcludedFromFee[to] &&
        !_isExcludedFromFee[from] &&
        automatedMarketMakerPairs[to] &&
        overMinimumTokenBalance
        ) {
            doBuyBack();
        }

        removeAllFee();

        buyOrSellSwitch = TRANSFER;

        // if not excluded
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {

            // Buy
            if (automatedMarketMakerPairs[from]) {
                _taxFee = _buyTaxFee;
                _liquidityFee = _buyLiquidityFee + _buyOperationsFee;
                if (_liquidityFee > 0) {
                    buyOrSellSwitch = BUY;
                }
            }

            // Sell
            else if (automatedMarketMakerPairs[to]) {
                _taxFee = _sellTaxFee;
                _liquidityFee = _sellLiquidityFee + _sellOperationsFee;
                if (_liquidityFee > 0) {
                    buyOrSellSwitch = SELL;
                }
            }
        }

        _tokenTransfer(from, to, amount);

        restoreAllFee();

    }

    function doBuyBack() private lockTheSwap {

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = _liquidityTokensToSwap + _operationToSwap;

        // prevent overly large contract sells.
        if (contractBalance >= minimumTokensBeforeSwap * 10) {
            contractBalance = minimumTokensBeforeSwap * 10;
        }

        // check if we have tokens to swap
        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        // Halve the amount of liquidity tokens
        uint256 tokensForLiquidity = contractBalance * _liquidityTokensToSwap / totalTokensToSwap / 2;
        uint256 amountToSwapForETH = contractBalance.sub(tokensForLiquidity);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForETH(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForOperationPool = ethBalance.mul(_operationToSwap).div(totalTokensToSwap);
        uint256 ethForLiquidity = ethBalance - ethForOperationPool;

        _liquidityTokensToSwap = 0;
        _operationToSwap = 0;

         payable(operationPoolAddress).transfer(ethForOperationPool);

        if (tokensForLiquidity > 0 && ethForLiquidity > 0) {
            addLiquidity(tokensForLiquidity, ethForLiquidity);
            emit SwapAndLiquify(amountToSwapForETH, ethForLiquidity, tokensForLiquidity);
        }
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private {

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount,  uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues( tAmount, tFee, tLiquidity, _getRate() );
        return ( rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity );
    }

    function _getTValues(uint256 tAmount) private view returns ( uint256, uint256, uint256 ) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues( uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate ) private pure returns ( uint256, uint256, uint256 ) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {

        if (buyOrSellSwitch == BUY) {
            _liquidityTokensToSwap += tLiquidity * _buyLiquidityFee / _liquidityFee;
            _operationToSwap += tLiquidity * _buyOperationsFee / _liquidityFee;
        } else if (buyOrSellSwitch == SELL) {
            _liquidityTokensToSwap += tLiquidity * _sellLiquidityFee / _liquidityFee;
            _operationToSwap += tLiquidity * _sellOperationsFee / _liquidityFee;
        }

        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
        }
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(BASE_FEE_PERCENT);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(BASE_FEE_PERCENT);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludeFromFee(account);
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludeInFee(account);
    }

    function setBuyFee(uint256 buyTaxFee, uint256 buyLiquidityFee, uint256 buyOperationsFee) external onlyOwner {
        _buyTaxFee = buyTaxFee;
        _buyLiquidityFee = buyLiquidityFee;
        _buyOperationsFee = buyOperationsFee;
        require(_buyTaxFee + _buyLiquidityFee + _buyOperationsFee <= 1500, "Must keep buy taxes below 15%");
        emit SetBuyFee(buyTaxFee, buyLiquidityFee, buyOperationsFee);
    }

    function setSellFee(uint256 sellTaxFee, uint256 sellLiquidityFee, uint256 sellOperationsFee) external onlyOwner {
        _sellTaxFee = sellTaxFee;
        _sellLiquidityFee = sellLiquidityFee;
        _sellOperationsFee = sellOperationsFee;
        require(_sellTaxFee + _sellLiquidityFee + _sellOperationsFee <= 2000, "Must keep sell taxes below 20%");
        emit SetSellFee(sellOperationsFee, sellLiquidityFee, sellTaxFee);
    }

    function setLiquidityAddress(address _liquidityAddress) public onlyOwner {
        require(_liquidityAddress != address(0), "_liquidityAddress address cannot be 0");
        liquidityAddress = payable(_liquidityAddress);
        _isExcludedFromFee[liquidityAddress] = true;
        emit UpdatedLiquidityAddress(_liquidityAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    // To receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    function transferForeignToken(address _token, address _to) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");
        require(_token != address(this), "Can't withdraw native tokens");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }

    function setNodeManagement(address newAddress) external onlyOwner {
        require(newAddress != address(0), "NODE MANAGER CANNOT BE ZERO");
        nodeRewardManagement = NODERewardManagement(newAddress);
    }

    function updateTransferDelayEnabled(bool newVal) external onlyOwner {
        transferDelayEnabled = newVal;
    }

    function updateTreasuryAddress(address payable wall) external onlyOwner {
        require(wall != address(0), "treasuryAddress address cannot be 0");
        _isExcludedFromFee[treasuryAddress] = false;
        treasuryAddress = payable(wall);
        _isExcludedFromFee[treasuryAddress] = true;
    }

    function updateOperationReserveAddress(address payable wall) external onlyOwner {
        require(wall != address(0), "operationPoolAddress address cannot be 0");
        _isExcludedFromFee[operationPoolAddress] = false;
        operationPoolAddress = payable(wall);
        _isExcludedFromFee[operationPoolAddress] = true;
    }

    function updateSmoothingReserveAddress(address payable wall) external onlyOwner {
        require(wall != address(0), "smoothingReserveAddress address cannot be 0");
        _isExcludedFromFee[smoothingReserveAddress] = false;
        smoothingReserveAddress = payable(wall);
        _isExcludedFromFee[smoothingReserveAddress] = true;
    }

    function updateRewardsPoolAddress(address payable wall) external onlyOwner {
        require(wall != address(0), "rewardsPoolAddress address cannot be 0");
        _isExcludedFromFee[rewardsPoolAddress] = false;
        rewardsPoolAddress = payable(wall);
        _isExcludedFromFee[rewardsPoolAddress] = true;
    }

    function updateRewardsFee(uint256 value) external onlyOwner {
        rewardsPoolFee = value;
    }

    function updateCashoutFee(uint256 value) external onlyOwner {
        cashoutFee = value;
    }

    function updateSmoothingReserveFee(uint256 value) external onlyOwner {
        smoothingReserveFee = value;
    }

    function updateOperationPoolFee(uint256 value) external onlyOwner {
        operationPoolFee = value;
    }

    function updateSwapTreasureTokensThreshold(uint256 value) external onlyOwner {
        swapTreasureTokensThreshold = value;
    }

    function updateswapSmoothingTokensThreshold(uint256 value) external onlyOwner {
        swapSmoothingTokensThreshold = value;
    }

    function updateSwapOperationTokensThreshold(uint256 value) external onlyOwner {
        swapOperationTokensThreshold = value;
    }

    function setIsExcluded(address account, bool value) external onlyOwner {
        _isExcluded[account] = value;
    }

    function swapAndSendToAddress(address destination, uint256 tokens) private returns (bool) {
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 newBalance = (address(this).balance).sub(initialETHBalance);
        payable(destination).transfer(newBalance);
        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function cashoutReward(uint256 blocktime) public {
        address sender = msg.sender;
        require(sender != address(0), "CSHT:  creation from the zero address");
        require(
            sender != operationPoolAddress && sender != rewardsPoolAddress,
            "CSHT: futur and rewardsPool cannot cashout rewards"
        );
        uint256 rewardAmount = nodeRewardManagement._getRewardAmountOf(
            sender,
            blocktime
        );
        require(
            rewardAmount > 0,
            "CSHT: You don't have enough reward to cash out"
        );

        if (cashoutFee > 0) {

            removeAllFee();

            uint256 feeTokens = rewardAmount.mul(cashoutFee).div(BASE_FEE_PERCENT);
            uint256 treasuryTokens = feeTokens.mul(75).div(BASE_FEE_PERCENT);
            uint256 operationsTokens = feeTokens.mul(25).div(BASE_FEE_PERCENT);

            swapAndSendToAddress(treasuryAddress, treasuryTokens);
            swapAndSendToAddress(operationPoolAddress, operationsTokens);

            rewardAmount -= feeTokens;
        }

        _tokenTransfer(rewardsPoolAddress, sender, rewardAmount);

        if (cashoutFee > 0) {
            restoreAllFee();
        }

        nodeRewardManagement._cashoutNodeReward(sender, blocktime);
    }

    function cashoutAll() public {
        address sender = msg.sender;
        require(
            sender != address(0),
            "MANIA CSHT:  creation from the zero address"
        );
        require(
            sender != operationPoolAddress && sender != rewardsPoolAddress,
            "MANIA CSHT: futur and rewardsPool cannot cashout rewards"
        );
        uint256 rewardAmount = nodeRewardManagement._getRewardAmountOf(sender);
        require(
            rewardAmount > 0,
            "MANIA CSHT: You don't have enough reward to cash out"
        );

        if (cashoutFee > 0) {

            removeAllFee();

            uint256 feeTokens = rewardAmount.mul(cashoutFee).div(BASE_FEE_PERCENT);
            uint256 treasuryTokens = feeTokens.mul(75).div(BASE_FEE_PERCENT);
            uint256 operationsTokens = feeTokens.mul(25).div(BASE_FEE_PERCENT);

            swapAndSendToAddress(treasuryAddress, treasuryTokens);
            swapAndSendToAddress(operationPoolAddress, operationsTokens);

            rewardAmount -= feeTokens;
        }

        _tokenTransfer(rewardsPoolAddress, sender, rewardAmount);

        if (cashoutFee > 0) {
            restoreAllFee();
        }

        nodeRewardManagement._cashoutAllNodesReward(sender);
    }

    function createNodeWithTokens(uint32 tierId, uint256 numberOfNodes) public {
        address sender = msg.sender;

        require(
            numberOfNodes > 0,
            "NODE CREATION:  number of nodes cant be zero"
        );

        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );

        require(
            !_isBlacklisted[sender],
            "NODE CREATION: Blacklisted address"
        );

        require(
            sender != operationPoolAddress && sender != rewardsPoolAddress,
            "NODE CREATION: operationPoolAddress and rewardsPoolAddress cannot create node"
        );

        uint256 nodePrice = nodeRewardManagement.getNodePriceFromTierInfo(tierId);
        require(
            balanceOf(sender) >= nodePrice.mul(numberOfNodes),
            "NODE CREATION: Balance too low for creation."
        );

        uint256 totalNodesCreatedFromAccount = nodeRewardManagement._getNodeNumberOf(sender);
        require(
            totalNodesCreatedFromAccount + numberOfNodes <= maxNodesAllowed,
            "NODE CREATION: MAX NODES CREATED"
        );

        if (rewardsPoolFee > 0 || treasuryFee > 0 || smoothingReserveFee > 0 || operationPoolFee > 0) {

            removeAllFee();

            // calculate fees amouts
            uint256 rewardsPoolTokens = nodePrice.mul(rewardsPoolFee).div(BASE_FEE_PERCENT);
            uint256 treasureTokens = nodePrice.mul(treasuryFee).div(BASE_FEE_PERCENT);
            uint256 smoothingTokens = nodePrice.mul(smoothingReserveFee).div(BASE_FEE_PERCENT);
            uint256 operationPoolTokens = nodePrice.mul(operationPoolFee).div(BASE_FEE_PERCENT);

            // reward pool
            if (rewardsPoolFee > 0) {
                _tokenTransfer(
                    address(this),
                    rewardsPoolAddress,
                    rewardsPoolTokens.mul(numberOfNodes)
                );
            }

            // treasury
            if (treasuryFee > 0) {
                accumulatedTreasureTokensAmount = accumulatedTreasureTokensAmount.add(treasureTokens.mul(numberOfNodes));
            }

            // smoothing
            if (smoothingReserveFee > 0) {
                accumulatedSmoothingTokensAmount = accumulatedSmoothingTokensAmount.add(smoothingTokens.mul(numberOfNodes));
            }

            // operationPool
            if (operationPoolFee > 0) {
                accumulatedOperationPoolTokensAmount = accumulatedOperationPoolTokensAmount.add(operationPoolTokens.mul(numberOfNodes));
            }
        }

        if (accumulatedTreasureTokensAmount >= swapTreasureTokensThreshold) {
            require(
                swapAndSendToAddress(treasuryAddress, swapTreasureTokensThreshold),
                "swapTreasureTokensThreshold"
            );
            accumulatedTreasureTokensAmount = 0;
        }

        if (accumulatedOperationPoolTokensAmount >= swapOperationTokensThreshold) {
            require(
                swapAndSendToAddress(operationPoolAddress, swapOperationTokensThreshold),
                "swapOperationTokensThreshold"
            );
            accumulatedOperationPoolTokensAmount = 0;
        }

        if (accumulatedSmoothingTokensAmount >= swapSmoothingTokensThreshold) {
            require(
                swapAndSendToAddress(smoothingReserveAddress, swapSmoothingTokensThreshold),
                "swapSmoothingTokensThreshold"
            );
            accumulatedSmoothingTokensAmount = 0;
        }

        _tokenTransfer(sender, address(this), nodePrice.mul(numberOfNodes));
        nodeRewardManagement.createNodes(sender, numberOfNodes, tierId);
        restoreAllFee();
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(0), "ROUTER CANNOT BE ZERO");
        require(
            newAddress != address(uniswapV2Router),
            "TKN: The router already has that address"
        );
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;

        _approve(
            address(this),
            address(uniswapV2Router),
            balanceOf(address(this))
        );

        _approve(
            address(this),
            address(uniswapV2Pair),
            balanceOf(address(this))
        );

        _isExcluded[address(this)] = true;
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        excludeFromMaxTransaction(address(uniswapV2Router), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        emit UpdateUniswapV2Router(address(uniswapV2Router));
    }

    function manualSwap(uint256 amount) public onlyOwner {
        require(balanceOf(address(this)) > 0, "Contract balance is zero");
        if (amount > balanceOf(address(this))) {
            amount = balanceOf(address(this));
        }
        swapTokensForEth(amount);
    }

    function withdrawStuckETH(uint256 amount) external onlyOwner {
        require(address(this).balance > 0, "Contract balance is zero");
        if (amount > address(this).balance) {
            amount = address(this).balance;
        }

        bool success;
        (success,) = address(msg.sender).call{value : address(this).balance}("");
    }

    function withdrawStuckTokens(uint256 amount) public onlyOwner {
        require(balanceOf(address(this)) > 0, "Contract balance is zero");
        if (amount > balanceOf(address(this))) {
            amount = balanceOf(address(this));
        }

        _tokenTransfer(address(this), msg.sender, amount);
    }


    // get info
    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    external
    view
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account)
    external
    view
    returns (bool)
    {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    // update limits after token is stable - 30-60 minutes
    function updateLimits(bool newValue) external onlyOwner returns (bool){
        limitsInEffect = newValue;
        gasLimitActive = newValue;
        transferDelayEnabled = newValue;
        return true;
    }

    // disable Transfer delay
    function disableTransferDelay() external onlyOwner returns (bool){
        transferDelayEnabled = false;
        return true;
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    // once enabled, can never be turned off
    function enableDisableTrading(bool newValue) external onlyOwner {
        tradingActive = newValue;

        if (tradingActiveBlock == 0) {
            tradingActiveBlock = block.number;
        }
    }

    // send tokens and ETH for liquidity to contract directly, then call this (not required, can still use Uniswap to add liquidity manually, but this ensures everything is excluded properly and makes for a great stealth launch)
    function launch(address routerAddress) external onlyOwner {
        require(!tradingActive, "Trading is already active, cannot relaunch.");
        removeAllFee();
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), balanceOf(address(this)));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);
        require(balanceOf(address(this)) > 0, "Must have Tokens on contract to launch");
        require(address(this).balance > 0, "Must have ETH on contract to launch");
        setLiquidityAddress(msg.sender);
        addLiquidity(balanceOf(address(this)), address(this).balance);
        restoreAllFee();
        //enableTrading();
        //setLiquidityAddress(address(0xdead));
    }

    function minimumTokensBeforeSwapAmount() external view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    // change the minimum amount of tokens to sell from fees
    function updateMinimumTokensBeforeSwap(uint256 newAmount) external onlyOwner {
        require(newAmount >= _tTotal * 1 / 100000, "Swap amount cannot be lower than 0.001% total supply.");
        require(newAmount <= _tTotal * 5 / 1000, "Swap amount cannot be higher than 0.5% total supply.");
        minimumTokensBeforeSwap = newAmount;
    }

    function updateMaxAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (_tTotal * 2 / 1000) / 1e18, "Cannot set maxTransactionAmount lower than 0.2%");
        maxTransactionAmount = newNum * (10 ** 18);
    }

    function updateMaxWallet(uint256 newNum) external onlyOwner {
        require(newNum >= (_tTotal * 1 / 100) / 1e18, "Cannot set maxTransactionAmount lower than 0.2%");
        maxWallet = newNum * (10 ** 18);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        _isExcludedMaxTransactionAmount[pair] = value;
        if (value) {excludeFromReward(pair);}
        if (!value) {includeInReward(pair);}
    }

    function setGasPriceLimit(uint256 gas) external onlyOwner {
        require(gas >= 2700000000);
        gasPriceLimit = gas;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
    external
    view
    returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , ,) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , ,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
    public
    view
    returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        require(_excluded.length + 1 <= 50, "Cannot exclude more than 50 accounts.  Include a previously excluded address.");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

        // force Swap back if slippage above 49% for launch.
    function forceBuyBack() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= _tTotal / 10000, "Can only swap back if more than .01% of tokens stuck on contract");
        doBuyBack();
        emit OwnerForcedSwapBack(block.timestamp);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityAddress,
            block.timestamp
        );
    }
}