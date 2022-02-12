// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./openzeppelin/SafeMath.sol";
import "./openzeppelin/IERC20.sol";
import "./openzeppelin/Initializable.sol";
import "./AggregatorV3Interface.sol";

contract ArcProtocol is Initializable {
  using SafeMath for uint256;

  // Nodes structure
  struct NodeType {
    uint256 rewards;
    uint256 price;
    uint256 maintenanceFeesPerMonth;
    bool disabled;
  }
  struct Node {
    uint256 id;
    string name;
    uint256 nodeType;
    uint256 createTimestamp;
    uint256 lastClaimTimestamp;
    uint256 lastUpgradeTimestamp;
    uint256 lastMaintenanceFeesTimestamp;
    uint256 maintenanceFeesDeadlineTimestamp;
    uint256 availableRewards;
    bool disabled;
  }

  // Interfaces
  IERC20 internal arcToken;
  AggregatorV3Interface internal priceFeed;

  // Settings
  bool public initDone;
  address public admin;
  uint256 public maxNodes;

  // Addresses
  address rewardsPool;
  address treasuryPool;
  address teamMarketingPool;
  address liquidityPool;

  // Claim tax
  uint256 claim24hTaxRate;
  uint256 claim24h7jTaxRate;
  uint256 claim7jTaxRate;

  // Nodes Creation Fees
  uint256 rewardPoolFees;
  uint256 liquidityPoolFees;
  uint256 treasuryFees;
  uint256 teamMarketingFees;

  // Nodes
  mapping(address => Node[]) private usersNodes;
  NodeType[] nodeTypes;

  // Security
  mapping(address => bool) public isBlacklisted;
  mapping(address => bool) private isExcludedFromFees;

  // Datas
  uint256 public totalCreatedNodes;

  /**
   * Initialization of the contract via TransparentUpgradeableProxy
   */
  function initialize(address arcTokenAddress, address _admin) public {
    require(!initDone, "Init done");
    admin = _admin;
    priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    arcToken = IERC20(arcTokenAddress);
    nodeTypes.push(
      NodeType({
        rewards: 0.045 * (10**8),
        price: 5 * (10**8),
        maintenanceFeesPerMonth: 2.5 * (10**8),
        disabled: false
      })
    );
    nodeTypes.push(
      NodeType({
        rewards: 0.095 * (10**8),
        price: 10 * (10**8),
        maintenanceFeesPerMonth: 5 * (10**8),
        disabled: false
      })
    );
    nodeTypes.push(
      NodeType({
        rewards: 0.525 * (10**8),
        price: 50 * (10**8),
        maintenanceFeesPerMonth: 15 * (10**8),
        disabled: false
      })
    );
    claim24hTaxRate = 20;
    claim24h7jTaxRate = 10;
    claim7jTaxRate = 5;
    rewardPoolFees = 70;
    liquidityPoolFees = 10;
    treasuryFees = 18;
    teamMarketingFees = 2;
    maxNodes = 100;
    totalCreatedNodes = 0;
    rewardsPool = 0x20Cb5177508d3E1cB5946961E4501010DF5579b4;
    treasuryPool = 0x498A9F9cf36251834Db6a5413Fe37F63E5014484;
    teamMarketingPool = 0x936df92Ae882C880ee699627f7304bd52fa27ab9;
    liquidityPool = 0x57f7f1cC17D3343FF9E62221b23826D8764Ae9f4;
    initDone = true;
  }

  /**
   * Returns the latest BNB price
   */
  function getLatestBNBPrice() public view returns (int256) {
    (uint80 roundID, int256 price, uint256 startedAt, uint256 timeStamp, uint80 answeredInRound) = priceFeed.latestRoundData();
    return price;
  }

  /**
   * Buy a node
   */
  function buyNode(string memory name, uint256 nodeTypeId) public {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");
    require(bytes(name).length >= 3 && bytes(name).length <= 32, "Name size must be between 3 and 32 length");
    require(nodeTypeId < nodeTypes.length, "Not a node type");
    require(usersNodes[msg.sender].length < maxNodes, "The maximum of nodes is reached");

    // get nodeType
    NodeType storage nodeType = nodeTypes[nodeTypeId];
    require(arcToken.balanceOf(msg.sender) >= nodeType.price, "You have not the balance to buy this node");

    // increment total created node
    uint256 id = ++totalCreatedNodes;

    // Add the node in the usersNodes mapping
    usersNodes[msg.sender].push(
      Node({
        id: id,
        name: name,
        nodeType: nodeTypeId,
        createTimestamp: block.timestamp,
        lastClaimTimestamp: block.timestamp,
        lastUpgradeTimestamp: block.timestamp,
        lastMaintenanceFeesTimestamp: block.timestamp,
        maintenanceFeesDeadlineTimestamp: block.timestamp + 30 days,
        availableRewards: 0,
        disabled: false
      })
    );

    // Split the $ARC on the different wallets
    arcToken.transferFrom(msg.sender, rewardsPool, nodeType.price.mul(rewardPoolFees).div(100));
    arcToken.transferFrom(msg.sender, liquidityPool, nodeType.price.mul(liquidityPoolFees).div(100));
    arcToken.transferFrom(msg.sender, treasuryPool, nodeType.price.mul(treasuryFees).div(100));
    arcToken.transferFrom(msg.sender, teamMarketingPool, nodeType.price.mul(teamMarketingFees).div(100));
  }

  /**
   * upgrade to a superior node type
   */
  function upgradeNode(uint256 nodeId, uint256 nodeTypeId) public {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");

    // get all users nodes
    Node[] storage nodes = usersNodes[msg.sender];
    // get the node index
    (uint256 nodeIndex, bool finded) = getNodeIndexWithId(nodes, nodeId);
    require(finded, "Cannot find the node");

    // get the node
    Node storage node = nodes[nodeIndex];
    // get current nodeType and nodeType to upgrade
    NodeType storage nodeTypeFrom = nodeTypes[node.nodeType];
    NodeType storage nodeTypeTo = nodeTypes[nodeTypeId];
    require(node.nodeType < nodeTypes.length && nodeTypeId < nodeTypes.length, "Not a node type");
    require(node.nodeType < nodeTypeId, "Cannot downgrade a node");
    require(block.timestamp < (node.maintenanceFeesDeadlineTimestamp + 30 days), "You didn't paid the maintenance fees");
    require(arcToken.balanceOf(msg.sender) >= (nodeTypeTo.price - nodeTypeFrom.price), "You have not the balance to buy this node");

    uint256 availableRewards;
    uint256 claimFees;
    (availableRewards, claimFees) = calculateRewards(node.id);
    node.availableRewards = availableRewards;
    node.lastUpgradeTimestamp = block.timestamp;
    node.nodeType = nodeTypeId;

    // Split the $ARC on the different wallets
    arcToken.transferFrom(msg.sender, rewardsPool,(nodeTypeTo.price - nodeTypeFrom.price).mul(rewardPoolFees).div(100));
    arcToken.transferFrom(msg.sender, liquidityPool, (nodeTypeTo.price - nodeTypeFrom.price).mul(liquidityPoolFees).div(100));
    arcToken.transferFrom(msg.sender, treasuryPool, (nodeTypeTo.price - nodeTypeFrom.price).mul(treasuryFees).div(100));
    arcToken.transferFrom(msg.sender, teamMarketingPool, (nodeTypeTo.price - nodeTypeFrom.price).mul(teamMarketingFees).div(100));
  }

  /**
   * Compound a node 
   */
  function compoundNode(uint256 nodeId, uint256 nodeTypeId) public {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");

    Node[] storage nodes = usersNodes[msg.sender];
    (uint256 nodeIndex, bool finded) = getNodeIndexWithId(nodes, nodeId);
    require(finded, "Cannot find the node");

    Node storage node = nodes[nodeIndex];
    NodeType storage nodeTypeFrom = nodeTypes[node.nodeType];
    NodeType storage nodeTypeTo = nodeTypes[nodeTypeId];
    require(node.nodeType < nodeTypes.length && nodeTypeId < nodeTypes.length, "Not a node type");
    require(node.nodeType < nodeTypeId, "Cannot downgrade a node");
    require(block.timestamp < (node.maintenanceFeesDeadlineTimestamp + 30 days), "You didn't paid the maintenance fees");
    
    uint256 availableRewards;
    uint256 claimFees;
    (availableRewards, claimFees) = calculateRewards(node.id);
    require(availableRewards >= (nodeTypeTo.price - nodeTypeFrom.price), "You have not enough rewards to compound");

    node.nodeType = nodeTypeId;
    node.lastUpgradeTimestamp = block.timestamp;
    node.availableRewards = availableRewards.sub(nodeTypeTo.price - nodeTypeFrom.price);

    // Split the $ARC on the different wallets
    arcToken.transferFrom(msg.sender, rewardsPool,(nodeTypeTo.price - nodeTypeFrom.price).mul(rewardPoolFees).div(100));
    arcToken.transferFrom(msg.sender, liquidityPool, (nodeTypeTo.price - nodeTypeFrom.price).mul(liquidityPoolFees).div(100));
    arcToken.transferFrom(msg.sender, treasuryPool, (nodeTypeTo.price - nodeTypeFrom.price).mul(treasuryFees).div(100));
    arcToken.transferFrom(msg.sender, teamMarketingPool, (nodeTypeTo.price - nodeTypeFrom.price).mul(teamMarketingFees).div(100));
  }

  /**
   * Pay maintenance fees
   */
  function payMaintenancefees(uint256 nodeId) public payable {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");

    Node[] storage nodes = usersNodes[msg.sender];
    (uint256 nodeIndex, bool finded) = getNodeIndexWithId(nodes, nodeId);
    require(finded, "Cannot find the node");
    Node storage node = nodes[nodeIndex];
    require(block.timestamp > node.lastMaintenanceFeesTimestamp, "Need to wait to pay the maintenance fees");
    NodeType storage nodeType = nodeTypes[node.nodeType];

    // get bnb price in $
    int256 BNBPrice = getLatestBNBPrice() / 100000000;
    // maintenance fees to pay
    uint256 maintenanceFees = nodeType.maintenanceFeesPerMonth;
    
    if (block.timestamp > node.maintenanceFeesDeadlineTimestamp) {
      // Need to pay the previous and current month
      maintenanceFees += nodeType.maintenanceFeesPerMonth;
      node.lastMaintenanceFeesTimestamp = node.lastMaintenanceFeesTimestamp + 60 days;
      node.maintenanceFeesDeadlineTimestamp = node.maintenanceFeesDeadlineTimestamp + 60 days;
    } else {
      // Pay the current month
      node.lastMaintenanceFeesTimestamp = node.lastMaintenanceFeesTimestamp + 30 days;
      node.maintenanceFeesDeadlineTimestamp = node.maintenanceFeesDeadlineTimestamp + 30 days;
    }
    
    // check if the amount is corrct (allow 3% difference)
    require((msg.value >(maintenanceFees.mul(10000000000).div(uint256(BNBPrice))).mul(97).div(100)) &&
            (msg.value < (maintenanceFees.mul(10000000000).div(uint256(BNBPrice))).mul(103).div(100)),
            "Incorrect amount sent to the contract");

    // send payment to treasury wallet
    payable(treasuryPool).transfer(msg.value);
  }

  /**
   * Return the rewards of a node and claim tax
   */
  function calculateRewards(uint256 nodeId) public view returns (uint256, uint256)
  {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");
    Node[] storage nodes = usersNodes[msg.sender];
    (uint256 nodeIndex, bool finded) = getNodeIndexWithId(nodes, nodeId);
    require(finded, "Cannot find the node");
    Node storage node = nodes[nodeIndex];
    NodeType storage nodeType = nodeTypes[node.nodeType];
    uint256 rewards = node.availableRewards;
    uint256 timeStampEndToUse = block.timestamp;
    uint256 timeStampStartToUse = node.lastClaimTimestamp;

    if (node.lastUpgradeTimestamp > node.lastClaimTimestamp) {
      timeStampStartToUse = node.lastUpgradeTimestamp;
    }
    if ((node.maintenanceFeesDeadlineTimestamp + 30 days) < block.timestamp) {
      timeStampEndToUse = node.maintenanceFeesDeadlineTimestamp + 30 days;
    }

    uint256 differenceTimestamp = (timeStampEndToUse - timeStampStartToUse);
    rewards += differenceTimestamp.mul(nodeType.rewards).div(86400);
    uint256 claimFees;

    if (block.timestamp <= (node.lastClaimTimestamp + 24 hours)) {
      claimFees = claim24hTaxRate;
    } else if (block.timestamp <= (node.lastClaimTimestamp + 7 days)) {
      claimFees = claim24h7jTaxRate;
    } else {
      claimFees = claim7jTaxRate;
    }
    return (rewards, claimFees);
  }

  /**
   * Returns the rewards, claim tax and maintenances fees of a node
   */
  function calculateRewardsAndFees(uint256 nodeId) public view returns (uint256, uint256, uint256)
  {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");
    Node[] storage nodes = usersNodes[msg.sender];
    (uint256 nodeIndex, bool finded) = getNodeIndexWithId(nodes, nodeId);
    require(finded, "Cannot find the node");

    Node storage node = nodes[nodeIndex];
    NodeType storage nodeType = nodeTypes[node.nodeType];
    uint256 rewards = node.availableRewards;
    uint256 maintenanceFees = nodeType.maintenanceFeesPerMonth;
    uint256 timeStampEndToUse = block.timestamp;
    uint256 timeStampStartToUse = node.lastClaimTimestamp;
    
    if (node.lastUpgradeTimestamp > node.lastClaimTimestamp) {
      timeStampStartToUse = node.lastUpgradeTimestamp;
    }
    if (block.timestamp > (node.maintenanceFeesDeadlineTimestamp + 30 days)) {
      timeStampEndToUse = node.maintenanceFeesDeadlineTimestamp + 30 days;
      maintenanceFees += nodeType.maintenanceFeesPerMonth;
    } else if (block.timestamp > node.maintenanceFeesDeadlineTimestamp) {
      maintenanceFees += nodeType.maintenanceFeesPerMonth;
    }
    
    uint256 differenceTimestamp = (timeStampEndToUse - timeStampStartToUse);
    rewards += differenceTimestamp.mul(nodeType.rewards).div(86400);
    uint256 claimFees;

    if (block.timestamp <= (node.lastClaimTimestamp + 24 hours)) {
      claimFees = claim24hTaxRate;
    } else if (block.timestamp <= (node.lastClaimTimestamp + 7 days)) {
      claimFees = claim24h7jTaxRate;
    } else {
      claimFees = claim7jTaxRate;
    }
    return (rewards, claimFees, maintenanceFees);
  }

  /**
   * Returns the sum of all the rewards nodes
   */
  function calculateAllRewards() public view returns (uint256, uint256) {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");
    Node[] storage nodes = usersNodes[msg.sender];
    uint256 nodesCount = nodes.length;
    require(nodesCount > 0, "No nodes");
    uint256 rewards;
    uint256 claimFees;
    uint256 allRewards;
    uint256 allClaimFees;
    uint256 i;
    for (i = 0; i < nodesCount; i++) {
      // if the node is not disabled (maintenance fees not pay during 60 days)
      if ((nodes[i].maintenanceFeesDeadlineTimestamp + 30 days) > block.timestamp)
      {
        (rewards, claimFees) = calculateRewards(nodes[i].id);
        allClaimFees += claimFees;
        allRewards += rewards;
      }
    }
    // average of all the claim taxes
    allClaimFees = allClaimFees / i;
    return (allRewards, allClaimFees);
  }

  /**
   * claim rewards of a node
   */
  function claimRewards(uint256 nodeId) public {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");
    Node[] storage nodes = usersNodes[msg.sender];
    (uint256 nodeIndex, bool finded) = getNodeIndexWithId(nodes, nodeId);
    require(finded, "Cannot find the node");
    Node storage node = nodes[nodeIndex];
    
    (uint256 availableRewards, uint256 claimFees) = calculateRewards(nodeId);
    require(availableRewards > 0, "No rewards");
    uint256 rewards = 0;

    // rewards amount less the claim tax
    rewards = availableRewards.mul(100-claimFees).div(100);
    node.availableRewards = 0;
    node.lastClaimTimestamp = block.timestamp;

    // send rewards to the sender
    arcToken.transferFrom(rewardsPool, msg.sender, rewards);
  }

  /**
   * Claim all the rewards
   */
  function claimAllRewards() public {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");
    Node[] storage nodes = usersNodes[msg.sender];
    uint256 nodesCount = nodes.length;
    require(nodesCount > 0, "No nodes");

    uint256 availableRewards;
    uint256 claimFees;
    (availableRewards, claimFees) = calculateAllRewards();
    require(availableRewards > 0, "No rewards");

    uint256 rewards = 0;
    rewards = availableRewards.mul(100-claimFees).div(100);
    uint256 i;
    for (i = 0; i < nodesCount; i++) {
      if ((nodes[i].maintenanceFeesDeadlineTimestamp + 30 days) > block.timestamp) {
        nodes[i].availableRewards = 0;
        nodes[i].lastClaimTimestamp = block.timestamp;
      }
    }
    arcToken.transferFrom(rewardsPool, msg.sender, rewards);
  }

  /**
   * Returns the nodes of a user
   */
  function getNodes() public view returns (Node[] memory) {
    require(msg.sender != address(0), "Cannot be a zero address");
    require(!isBlacklisted[msg.sender], "Blacklisted address");
    return usersNodes[msg.sender];
  }

  /**
   * Get the index of a node
   */
  function getNodeIndexWithId(Node[] storage nodes, uint256 id) private view returns (uint256, bool)
  {
    for (uint256 i = 0; i < nodes.length; i++) { 
      if (nodes[i].id == id) return (i, true);
    }
    return (0, false);
  }

  /**
   * Admin can give a node
   */
  function giveNode(address user, uint256 nodeTypeId, string memory name) public {
    require(msg.sender == admin, "Only Admin can access");
    require(nodeTypeId < nodeTypes.length, "Not a node type");
    require(bytes(name).length >= 3 && bytes(name).length <= 32, "Name size must be between 3 and 32 length");

    uint256 id = ++totalCreatedNodes;

    usersNodes[user].push(
      Node({
        id: id,
        name: name,
        nodeType: nodeTypeId,
        createTimestamp: block.timestamp,
        lastClaimTimestamp: block.timestamp,
        lastUpgradeTimestamp: block.timestamp,
        lastMaintenanceFeesTimestamp: block.timestamp,
        maintenanceFeesDeadlineTimestamp: block.timestamp + 30 days,
        availableRewards: 0,
        disabled: false
      })
    );
  }

  /**
   * Admin can give nodes
   */
  function giveNodes(address[] memory users, uint256[] memory nbNodes, uint256 nodeTypeId, string memory name) public {
    require(msg.sender == admin, "Only Admin can access");
    require(nodeTypeId < nodeTypes.length, "Not a node type");
    require(users.length == nbNodes.length, "The array have not the same size");
    require(bytes(name).length >= 3 && bytes(name).length <= 32, "Name size must be between 3 and 32 length");

    for (uint256 i = 0; i < users.length; i++) {
      for (uint256 j = 0; j < nbNodes[i]; j++) {
        uint256 id = ++totalCreatedNodes;
        usersNodes[users[i]].push(
        Node({
          id: id,
          name: name,
          nodeType: nodeTypeId,
          createTimestamp: block.timestamp,
          lastClaimTimestamp: block.timestamp,
          lastUpgradeTimestamp: block.timestamp,
          lastMaintenanceFeesTimestamp: block.timestamp,
          maintenanceFeesDeadlineTimestamp: block.timestamp + 30 days,
          availableRewards: 0,
          disabled: false
          })
        );
      }
    }
  }

  /**
   * Blacklist an address
   */
  function blacklistMalicious(address account, bool value) external {
    require(msg.sender == admin, "Only Admin can access");
    isBlacklisted[account] = value;
  }

  /**
   * All functions to modify class variables
   */
  function changeAdmin(address _admin) public {
    require(msg.sender == admin, "Only Admin can access");
    admin = _admin;
  }

  function changeClaimTaxes(uint256 _claim24hTaxRate, uint256 _claim24h7jTaxRate, uint256 _claim7jTaxRate) public {
    require(msg.sender == admin, "Only Admin can access");
    claim24hTaxRate = _claim24hTaxRate;
    claim24h7jTaxRate = _claim24h7jTaxRate;
    claim7jTaxRate = _claim7jTaxRate;
  }

  function changePools(address _rewardsPool, address _treasuryPool, address _teamMarketingPool, address _liquidityPool) public {
    require(msg.sender == admin, "Only Admin can access");
    rewardsPool = _rewardsPool;
    treasuryPool = _treasuryPool;
    teamMarketingPool = _teamMarketingPool;
    liquidityPool = _liquidityPool;
  }

  function changePoolsFees(uint256 _rewardPoolFees, uint256 _treasuryFees, uint256 _teamMarketingFees, uint256 _liquidityPoolFees) public {
    require(msg.sender == admin, "Only Admin can access");
    rewardPoolFees = _rewardPoolFees;
    treasuryFees = _treasuryFees;
    teamMarketingFees = _teamMarketingFees;
    liquidityPoolFees = _liquidityPoolFees;
  }

  function changeMaxNodes(uint256 _maxNodes) public {
    require(msg.sender == admin, "Only Admin can access");
    maxNodes = _maxNodes;
  }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "./AddressUpgradeable.sol";

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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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