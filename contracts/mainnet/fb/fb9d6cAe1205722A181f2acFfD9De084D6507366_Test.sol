// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Test is Ownable {
    using SafeMath for uint256; // ok

    mapping(address => bool) public managers; // ok

    struct NodeInfo {
        string name;
        uint256 createTime;
        uint256 lastClaimTime;
        uint256 rewardedAmount;
        uint256 rewardPerDay;
    } // ok

    // Protocol Stats
    uint256 public totalCount = 0; // ok
    mapping(address => NodeInfo[]) public nodesOfUser; // ok
    mapping(address => uint256) public nodeCountOfUser; // ok

    // Protocol Parameters
    uint256 public nodeLimit = 100; // ok
    uint256 public claimInterval = 1 days; // ok

    // Events
    event CREATE_NODE(
        address _account,
        string _name,
        uint256 _rewardPerDay,
        uint256 _createTime
    ); // ok
    event AIREDROP_NODE(
        address _account,
        string _name,
        uint256 _rewardPerDay,
        uint256 _createTime
    ); // ok

    // Modifiers
    modifier onlyManager() {
        require(managers[msg.sender] == true, "MANAGEMENT: NOT MANAGER");
        _;
    }

    constructor() {
        managers[msg.sender] = true;
    }

    function addManager(address _manager) public onlyOwner {
        managers[_manager] = true;
    }

    function removeManager(address _manager) public onlyOwner {
        managers[_manager] = false;
    }

    function setNodeLimit(uint256 _limit) public onlyOwner {
        nodeLimit = _limit;
    }

    function setClaimInterval(uint256 _interval) public onlyOwner {
        claimInterval = _interval;
    }

    function getNodeLimit() external view onlyManager returns (uint256) {
        return nodeLimit;
    }

    function getClaimInterval() external view onlyManager returns (uint256) {
        return claimInterval;
    }

    function getTotalCount() external view onlyManager returns (uint256) {
        return totalCount;
    }

    function getNodesCountOfUser(address account)
        external
        view
        onlyManager
        returns (uint256)
    {
        return nodeCountOfUser[account];
    }

    function createNode(
        address account,
        string memory _name,
        uint256 _rewardPerDay
    ) external onlyManager {
        require(
            nodeCountOfUser[account] < nodeLimit,
            "MANAGEMENT: CREATE NODE LIMIT ERROR"
        );

        nodesOfUser[account].push(
            NodeInfo({
                name: _name,
                createTime: block.timestamp,
                lastClaimTime: block.timestamp,
                rewardPerDay: _rewardPerDay,
                rewardedAmount: 0
            })
        );

        nodeCountOfUser[account] += 1;
        totalCount += 1;

        emit CREATE_NODE(account, _name, _rewardPerDay, block.timestamp);
    }

    function airdropNode(
        address account,
        string memory _name,
        uint256 _rewardPerDay
    ) external onlyManager {
        require(
            nodeCountOfUser[account] < nodeLimit,
            "MANAGEMENT: AIREDROP NODE LIMIT ERROR"
        );

        nodesOfUser[account].push(
            NodeInfo({
                name: _name,
                createTime: block.timestamp,
                lastClaimTime: block.timestamp,
                rewardPerDay: _rewardPerDay,
                rewardedAmount: 0
            })
        );

        nodeCountOfUser[account] += 1;
        totalCount += 1;

        emit AIREDROP_NODE(account, _name, _rewardPerDay, block.timestamp);
    }

    function calculateAvailableReward(address account)
        external
        view
        onlyManager
        returns (uint256)
    {
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < nodeCountOfUser[account]; i++) {
            totalRewards += _calculateAvailableReward(account, i);
        }

        return totalRewards;
    }

    function calculateAvailableReward(address account, uint256 _index)
        external
        view
        onlyManager
        returns (uint256)
    {
        uint256 reward;

        reward = _calculateAvailableReward(account, _index);

        return reward;
    }

    function compoundNode(address account, uint256 amount)
        external
        onlyManager
        returns (uint256)
    {
        require(isNodeOwner(account), "MANAGEMENT: COMPOUND NO NODE OWNER");

        NodeInfo[] storage nodes = nodesOfUser[account];
        NodeInfo storage node;

        uint256 reward;
        uint256 returnValue = 0;

        for (uint256 i = 0; i < nodes.length; i++) {
            node = nodes[i];

            reward = (block.timestamp - node.createTime)
                .div(claimInterval)
                .mul(node.rewardPerDay)
                .sub(node.rewardedAmount);

            if (returnValue + reward < amount) {
                node.lastClaimTime = block.timestamp;
                node.rewardedAmount = node.rewardedAmount + reward;

                returnValue += reward;
            } else {
                node.lastClaimTime = block.timestamp;
                node.rewardedAmount =
                    node.rewardedAmount +
                    amount -
                    returnValue;

                returnValue += amount - returnValue;
            }
        }

        return returnValue;
    }

    function cashoutAllReward(address account)
        external
        onlyManager
        returns (uint256)
    {
        require(isNodeOwner(account), "MANAGEMENT: CASHOUT ALLL NO NODE OWNER");

        NodeInfo[] storage nodes = nodesOfUser[account];
        NodeInfo storage node;

        uint256 reward;
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < nodes.length; i++) {
            node = nodes[i];

            reward = (block.timestamp - node.createTime)
                .div(claimInterval)
                .mul(node.rewardPerDay)
                .sub(node.rewardedAmount);

            totalRewards += reward;
            node.lastClaimTime = block.timestamp;
            node.rewardedAmount = node.rewardedAmount + reward;
        }

        return totalRewards;
    }

    function cashoutReward(address account, uint256 _index)
        external
        onlyManager
        returns (uint256)
    {
        NodeInfo[] storage nodes = nodesOfUser[account];
        NodeInfo storage node;

        require(isNodeOwner(account), "MANAGEMENT: CASHOUT NO NODE OWNER");
        require(
            nodeCountOfUser[account] >= _index,
            "MANAGEMENT: CASHOUT INDEX ERROR"
        );

        uint256 reward;
        uint256 totalRewards = 0;

        if (isNodeOwner(account)) {
            node = nodes[_index];

            reward = (block.timestamp - node.createTime)
                .div(claimInterval)
                .mul(node.rewardPerDay)
                .sub(node.rewardedAmount);

            totalRewards += reward;
            node.lastClaimTime = block.timestamp;
            node.rewardedAmount = node.rewardedAmount + reward;
        }

        return totalRewards;
    }

    function getNodeNames(address account)
        external
        view
        onlyManager
        returns (string memory)
    {
        require(isNodeOwner(account), "MANAGEMENT: GET NAME ERROR");

        NodeInfo[] memory nodes = nodesOfUser[account];
        NodeInfo memory node;

        uint256 nodesCount = nodeCountOfUser[account];

        string memory separator = "#";

        string memory returnValue = nodes[0].name;

        for (uint256 i = 1; i < nodesCount; i++) {
            node = nodes[i];

            returnValue = string(
                abi.encodePacked(returnValue, separator, node.name)
            );
        }
        return returnValue;
    }

    function getNodeCreateTime(address account)
        external
        view
        onlyManager
        returns (string memory)
    {
        require(isNodeOwner(account), "MANAGEMENT: GET CREATE TIME ERROR");

        NodeInfo[] memory nodes = nodesOfUser[account];
        NodeInfo memory node;

        uint256 nodesCount = nodeCountOfUser[account];

        string memory separator = "#";

        string memory returnValue = uint2str(nodes[0].createTime);

        for (uint256 i = 1; i < nodesCount; i++) {
            node = nodes[i];

            returnValue = string(
                abi.encodePacked(
                    returnValue,
                    separator,
                    uint2str(node.createTime)
                )
            );
        }
        return returnValue;
    }

    function getNodeLastClaimTime(address account)
        external
        view
        onlyManager
        returns (string memory)
    {
        require(isNodeOwner(account), "MANAGEMENT: GET LAST CLAIM TIME ERROR");

        NodeInfo[] memory nodes = nodesOfUser[account];
        NodeInfo memory node;

        uint256 nodesCount = nodeCountOfUser[account];

        string memory separator = "#";

        string memory returnValue = uint2str(nodes[0].lastClaimTime);

        for (uint256 i = 1; i < nodesCount; i++) {
            node = nodes[i];

            returnValue = string(
                abi.encodePacked(
                    returnValue,
                    separator,
                    uint2str(node.lastClaimTime)
                )
            );
        }
        return returnValue;
    }

    function getNoderewardPerDay(address account)
        external
        view
        onlyManager
        returns (string memory)
    {
        require(isNodeOwner(account), "MANAGEMENT: GET REWARD PER DAY ERROR");

        NodeInfo[] memory nodes = nodesOfUser[account];
        NodeInfo memory node;

        uint256 nodesCount = nodeCountOfUser[account];

        string memory separator = "#";

        string memory returnValue = uint2str(nodes[0].rewardPerDay);

        for (uint256 i = 1; i < nodesCount; i++) {
            node = nodes[i];

            returnValue = string(
                abi.encodePacked(
                    returnValue,
                    separator,
                    uint2str(node.rewardPerDay)
                )
            );
        }
        return returnValue;
    }

    function getNodeAvailableReward(address account)
        external
        view
        onlyManager
        returns (string memory)
    {
        require(isNodeOwner(account), "MANAGEMENT: GET AVAILABLE REWARD ERROR");

        uint256 nodesCount = nodeCountOfUser[account];

        string memory separator = "#";

        string memory returnValue = uint2str(
            _calculateAvailableReward(account, 0)
        );

        for (uint256 i = 1; i < nodesCount; i++) {
            returnValue = string(
                abi.encodePacked(
                    returnValue,
                    separator,
                    uint2str(_calculateAvailableReward(account, i))
                )
            );
        }
        return returnValue;
    }

    function isNodeOwner(address account) internal view returns (bool) {
        if (nodeCountOfUser[account] > 0) {
            return true;
        } else {
            return false;
        }
    }

    function _calculateAvailableReward(address account, uint256 _index)
        internal
        view
        returns (uint256)
    {
        NodeInfo[] storage nodes = nodesOfUser[account];
        NodeInfo storage node;

        require(
            nodeCountOfUser[account] >= _index,
            "MANAGEMENT: CALCULATE INDEX ERROR"
        );

        uint256 reward = 0;

        if (!isNodeOwner(account)) {
            return reward;
        }

        node = nodes[_index];
        reward = (block.timestamp - node.createTime)
            .div(claimInterval)
            .mul(node.rewardPerDay)
            .sub(node.rewardedAmount);

        return reward;
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
}