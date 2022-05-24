/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );
  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );
  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);
  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);
  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);
  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);
  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);
  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);
  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);
  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);
  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
} interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);
  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
} library Address {
  function isContract(address account) internal view returns (bool) {
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");
    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    return _functionCallWithValue(target, data, value, errorMessage);
  }
  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 weiValue,
    string memory errorMessage
  ) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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
} interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IFeeManager {
  function transferTokenToOperator(
    address _sender,
    uint256 _fee,
    address _token
  ) external;
  function transferFeeToOperator(uint256 _fee) external;
  function transferETHToOperator() external payable;
  function transferFee(address _sender, uint256 _fee) external;
  function transferETH(address _recipient, uint256 _amount) external;
  function claim(address to, uint256 amount) external;
  function transfer(address to, uint256 amount) external;
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external;
  function getAmountETH(uint256 _amount) external view returns (uint256);
  function getTransferFee(uint256 _amount) external view returns (uint256);
  function getClaimFee(uint256 _amount) external view returns (uint256);
  function getRateUpgradeFee(string memory tierNameFrom, string memory tierNameTo) external view returns (uint32);
}

library MerkleProof {
  function verify(
    bytes32[] memory proof,
    bytes32 root,
    bytes32 leaf
  ) internal pure returns (bool) {
    return processProof(proof, leaf) == root;
  }
  function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
    bytes32 computedHash = leaf;
    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];
      if (computedHash <= proofElement) {
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }
    return computedHash;
  }
}
struct Tier {
  uint8 id;
  string name;
  uint256 price;
  uint256 rewardsPerTime;
  uint32 claimInterval;
  uint256 maintenanceFee;
  uint32 maxPurchase;
}
struct Node {
  uint32 id;
  uint8 tierIndex;
  string title;
  address owner;
  uint32 createdTime;
  uint32 claimedTime;
  uint32 limitedTime;
  uint256 multiplier;
}
contract NodeManager {
  // using SafeMath for uint256;
  IFeeManager public feeManager;
  // IAloraNFT public aloraNFT;
  Tier[] private tierArr;
  mapping(string => uint8) public tierMap;
  uint8 public tierTotal;
  Node[] private nodesTotal;
  mapping(address => uint256[]) public nodesOfUser;
  uint32 public countTotal;
  mapping(address => uint32) public countOfUser;
  mapping(string => uint32) public countOfTier;
  uint256 public rewardsTotal;
  mapping(address => uint256) public rewardsOfUser;
  uint32 public maxCountOfUser; // 0-Infinite
  address public feeTokenAddress;
  bool public canNodeTransfer;
  address public owner;
  mapping(address => bool) public blacklist;
  string[] private airdrops;
  mapping(string => bytes32) public merkleRoot;
  mapping(bytes32 => bool) public airdropSupplied;
  mapping(address => uint256) public unclaimed;
  address public minter;
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
  event NodeCreated(address, string, uint32, uint32, uint32, uint32);
  event NodeUpdated(address, string, string, uint32);
  event NodeTransfered(address, address, uint32);
  event SwapIn(address indexed, uint32 indexed, string, uint32, int32);
  event SwapOut(address, uint32, uint32, string, uint32);
    constructor(address _feeManager) {
    owner = msg.sender;
    bindFeeManager(_feeManager);
    addTier("bronze", 10 ether, 0.16 ether, 1 days, 5 ether, 100);
    addTier("silver", 50 ether, 1 ether, 1 days, 15 ether, 20);
    addTier("gold", 100 ether, 2.5 ether, 1 days, 25 ether, 10);
    maxCountOfUser = 130; // 0-Infinite
    canNodeTransfer = true;
  }

  function bindFeeManager(address _feeManager) public onlyOwner {
    feeManager = IFeeManager(_feeManager);
  }
  function setMinter(address _minter) public onlyOwner {
    minter = _minter;
  }
  function setPayTokenAddress(address _tokenAddress) public onlyOwner {
    feeTokenAddress = _tokenAddress;
  }
  function setCanNodeTransfer(bool value) public onlyOwner {
    canNodeTransfer = value;
  }
  function setMaxCountOfUser(uint32 _count) public onlyOwner {
    maxCountOfUser = _count;
  }
  function tiers() public view returns (Tier[] memory) {
    Tier[] memory tiersActive = new Tier[](tierTotal);
    uint8 j = 0;
    for (uint8 i = 0; i < tierArr.length; i++) {
      Tier storage tier = tierArr[i];
      if (tierMap[tier.name] > 0) tiersActive[j++] = tier;
    }
    return tiersActive;
  }
  function addTier(
    string memory name,
    uint256 price,
    uint256 rewardsPerTime,
    uint32 claimInterval,
    uint256 maintenanceFee,
    uint32 maxPurchase
  ) public onlyOwner {
    require(price > 0, "Tier's price has to be positive.");
    require(rewardsPerTime > 0, "Tier's rewards has to be positive.");
    require(claimInterval > 0, "Tier's claim interval has to be positive.");
    tierArr.push(
      Tier({
        id: uint8(tierArr.length),
        name: name,
        price: price,
        rewardsPerTime: rewardsPerTime,
        claimInterval: claimInterval,
        maintenanceFee: maintenanceFee,
        maxPurchase: maxPurchase
      })
    );
    tierMap[name] = uint8(tierArr.length);
    tierTotal++;
  }
  function tierInfo(string memory tierName)
    public
    view
    returns (
      string memory,
      uint256,
      uint256,
      uint32,
      uint256,
      uint32
    )
  {
    uint8 tierId = tierMap[tierName];
    require(tierId > 0, "Tier's name is incorrect.");
    Tier storage tier = tierArr[tierId - 1];
    return (tier.name, tier.price, tier.rewardsPerTime, tier.claimInterval, tier.maintenanceFee, tier.maxPurchase);
  }
  function updateTier(
    string memory tierName,
    string memory name,
    uint256 price,
    uint256 rewardsPerTime,
    uint32 claimInterval,
    uint256 maintenanceFee,
    uint32 maxPurchase
  ) public onlyOwner {
    uint8 tierId = tierMap[tierName];
    require(tierId > 0, "Tier's name is incorrect.");
    require(price > 0, "Tier's price has to be positive.");
    require(rewardsPerTime > 0, "Tier's rewards has to be positive.");
    Tier storage tier = tierArr[tierId - 1];
    tier.name = name;
    tier.price = price;
    tier.rewardsPerTime = rewardsPerTime;
    tier.claimInterval = claimInterval;
    tier.maintenanceFee = maintenanceFee;
    tier.maxPurchase = maxPurchase;
    tierMap[tierName] = 0;
    tierMap[name] = tierId;
  }
  function setTierId(string memory name, uint8 id) public onlyOwner {
    tierMap[name] = id;
  }
  function removeTier(string memory tierName) public onlyOwner {
    require(tierMap[tierName] > 0, "Tier was already removed.");
    tierMap[tierName] = 0;
    tierTotal--;
  }
  function maxNodeIndex() public view returns (uint32) {
    return uint32(nodesTotal.length);
  }
  function burnedNodes() public view returns (Node[] memory) {
    uint256 nodesLen = nodesTotal.length - countTotal;
    Node[] memory nodesBurn = new Node[](nodesLen);
    uint32 j = 0;
    for (uint256 i = 0; i < nodesTotal.length; i++) {
      Node storage node = nodesTotal[i];
      if (node.owner == address(0)) nodesBurn[j++] = node;
    }
    return nodesBurn;
  }
  function nodes(address account) public view returns (Node[] memory) {
    if (account == address(0)) return burnedNodes();
    uint256 nodesLen = countOfUser[account];
    Node[] memory nodesActive = new Node[](nodesLen);
    if (nodesLen > 0) {
      uint256[] storage nodeIndice = nodesOfUser[account];
      uint32 j = 0;
      for (uint32 i = 0; i < nodeIndice.length; i++) {
        uint256 nodeIndex = nodeIndice[i];
        if (nodeIndex > 0) {
          Node storage node = nodesTotal[nodeIndex - 1];
          if (node.owner == account) {
            nodesActive[j] = node;
            nodesActive[j].multiplier = getBoostRate();
            j++;
            if (j >= nodesLen) break;
          }
        }
      }
    }
    return nodesActive;
  }
  function checkHasNodes(address account) public view returns (bool) {
    uint256[] storage nodeIndice = nodesOfUser[account];
    for (uint32 i = 0; i < nodeIndice.length; i++) {
      uint256 nodeIndex = nodeIndice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner == account) {
          return true;
        }
      }
    }
    return false;
  }
  function countOfNodes(address account, string memory tierName) public view returns (uint32) {
    uint8 tierId = tierMap[tierName];
    uint256[] storage nodeIndice = nodesOfUser[account];
    uint32 count = 0;
    for (uint32 i = 0; i < nodeIndice.length; i++) {
      uint256 nodeIndex = nodeIndice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner == account && node.tierIndex == tierId - 1) {
          count++;
        }
      }
    }
    return count;
  }
  function _create(
    address account,
    string memory tierName,
    string memory title,
    uint32 count,
    int32 limitedTimeOffset
  ) private returns (uint256) {
    require(!blacklist[account], "Invalid wallet");
    uint8 tierId = tierMap[tierName];
    Tier storage tier = tierArr[tierId - 1];
    require(countOfUser[account] + count <= maxCountOfUser, "Cannot create node more than MAX.");
    require(countOfNodes(account, tierName) + count <= tier.maxPurchase, "Cannot create node more than MAX");
    for (uint32 i = 0; i < count; i++) {
      nodesTotal.push(
        Node({
          id: uint32(nodesTotal.length),
          tierIndex: tierId - 1,
          title: title,
          owner: account,
          multiplier: 0,
          createdTime: uint32(block.timestamp),
          claimedTime: uint32(block.timestamp),
          limitedTime: uint32(uint256(int256(block.timestamp) + limitedTimeOffset))
        })
      );
      uint256[] storage nodeIndice = nodesOfUser[account];
      nodeIndice.push(nodesTotal.length);
    }
    countOfUser[account] += count;
    countOfTier[tierName] += count;
    countTotal += count;
    uint256 amount = tier.price * count;
    // if (count >= 10) amount = amount.mul(10000 - discountPer10).div(10000);
    return amount;
  }
  function mint(
    address[] memory accounts,
    string memory tierName,
    string memory title,
    uint32 count
  ) public onlyOwner {
    require(accounts.length > 0, "Empty account list.");
    for (uint256 i = 0; i < accounts.length; i++) {
      _create(accounts[i], tierName, title, count, 0);
    }
  }
  function createForUser(
    string memory tierName,
    uint32 count,
    address _user
  ) public onlyOwner {
    // uint256 amount = _create(_user, tierName, "", count, 0);
    _create(_user, tierName, "", count, 0);
    // feeManager.transferFee(msg.sender, amount);
    emit NodeCreated(_user, tierName, count, countTotal, countOfUser[_user], countOfTier[tierName]);
  }
  function create(
    string memory tierName,
    string memory title,
    uint32 count
  ) public {
    uint256 amount = _create(msg.sender, tierName, title, count, 0);
    feeManager.transferFee(msg.sender, amount);
    emit NodeCreated(msg.sender, tierName, count, countTotal, countOfUser[msg.sender], countOfTier[tierName]);
  }
  function getBoostRate() public pure returns (uint256) {
    uint256 multiplier = 1 ether;
    // if (address(aloraNFT) == address(0)) {
    //   return multiplier;
    // }
    // multiplier = aloraNFT.getMultiplier(account, timeFrom, timeTo);
    return multiplier;
  }
  function claimable(address _account) public view returns (uint256) {
    (uint256 claimableAmount, , ) = _iterate(_account, 0, 0);
    return claimableAmount;
  }
  function _iterate(
    address _account,
    uint8 _tierId,
    uint32 _count
  )
    private
    view
    returns (
      uint256,
      uint32,
      uint256[] memory
    )
  {
    uint256 claimableAmount = 0;
    uint256[] storage nodeIndice = nodesOfUser[_account];
    uint256[] memory nodeIndiceResult = new uint256[](nodeIndice.length);
    uint32 count = 0;
    for (uint32 i = 0; i < nodeIndice.length; i++) {
      uint256 nodeIndex = nodeIndice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (_tierId != 0 && node.tierIndex != _tierId - 1) continue;
        if (node.owner == _account) {
          uint256 multiplier = getBoostRate();
          Tier storage tier = tierArr[node.tierIndex];
          claimableAmount =
            (uint256(block.timestamp - node.claimedTime) * tier.rewardsPerTime * multiplier) /
            1 ether /
            tier.claimInterval +
            claimableAmount;
          nodeIndiceResult[count] = nodeIndex;
          count++;
          if (_count != 0 && count == _count) break;
        }
      }
    }
    return (claimableAmount, count, nodeIndiceResult);
  }
  function _claim() private {
    (uint256 claimableAmount, uint32 count, uint256[] memory nodeIndice) = _iterate(msg.sender, 0, 0);
    // require(claimableAmount > 0, 'No claimable tokens.');
    if (claimableAmount > 0) {
      rewardsOfUser[msg.sender] = rewardsOfUser[msg.sender] + claimableAmount;
      rewardsTotal = rewardsTotal + claimableAmount;
      unclaimed[msg.sender] += claimableAmount;
    }
    for (uint32 i = 0; i < count; i++) {
      uint256 index = nodeIndice[i];
      Node storage node = nodesTotal[index - 1];
      node.claimedTime = uint32(block.timestamp);
    }
  }
  function compound(
    string memory tierName,
    string memory title,
    uint32 count
  ) public {
    uint256 amount = _create(msg.sender, tierName, title, count, 0);
    if (unclaimed[msg.sender] < amount) _claim();
    require(unclaimed[msg.sender] >= amount, "Insufficient claimable tokens to compound.");
    unclaimed[msg.sender] -= amount;
    // feeManager.claim(address(msg.sender), claimableAmount - exceptAmount);
    emit NodeCreated(msg.sender, tierName, count, countTotal, countOfUser[msg.sender], countOfTier[tierName]);
  }
  function claim() public {
    require(!blacklist[msg.sender], "Invalid wallet");
    _claim();
    require(unclaimed[msg.sender] > 0, "No claimable tokens.");
    feeManager.claim(address(msg.sender), unclaimed[msg.sender]);
    unclaimed[msg.sender] = 0;
  }
  function upgrade(
    string memory tierNameFrom,
    string memory tierNameTo,
    uint32 count
  ) public payable {
    uint8 tierIndexFrom = tierMap[tierNameFrom];
    uint8 tierIndexTo = tierMap[tierNameTo];
    require(tierIndexFrom > 0, "Invalid tier to upgrade from.");
    require(tierIndexTo > 0, "Invalid tier to upgrade to.");
    Tier storage tierFrom = tierArr[tierIndexFrom - 1];
    Tier storage tierTo = tierArr[tierIndexTo - 1];
    require(tierTo.price > tierFrom.price, "Unable to downgrade.");
    uint32 countNeeded = uint32((count * tierTo.price) / tierFrom.price);
    (uint256 claimableAmount, uint32 countUpgrade, uint256[] memory nodeIndice) = _iterate(msg.sender, tierIndexFrom, countNeeded);
    // require(countUpgrade==countNeeded, 'Insufficient nodes.');
    if (claimableAmount > 0) {
      rewardsOfUser[msg.sender] = rewardsOfUser[msg.sender] + claimableAmount;
      rewardsTotal = rewardsTotal + claimableAmount;
      unclaimed[msg.sender] += claimableAmount;
    }
    int32 limitedTime = 0;
    for (uint32 i = 0; i < countUpgrade; i++) {
      uint256 index = nodeIndice[i];
      Node storage node = nodesTotal[index - 1];
      node.claimedTime = uint32(block.timestamp);
      node.owner = address(0);
      limitedTime += int32(int32(node.limitedTime) - int256(block.timestamp));
    }
    countOfUser[msg.sender] -= countUpgrade;
    countOfTier[tierNameFrom] -= countUpgrade;
    countTotal -= countUpgrade;
    // countOfTier[tierNameTo] += count;
    if (countUpgrade < countNeeded) {
      uint256 price = tierFrom.price * (countNeeded - countUpgrade);
      // if (count >= 10) price = price.mul(10000 - discountPer10).div(10000);
      feeManager.transferFee(msg.sender, price);
    }
    _create(msg.sender, tierNameTo, "", count, int32(int256(limitedTime) / int32(countNeeded)));
    uint256 feeETH = 0;
    uint256 feeToken = 0;
    (feeETH, feeToken) = getUpgradeFee(tierNameFrom, tierNameTo, count);
    // require(amountUpgradeFee<=msg.value, "Insufficient ETH for upgrade fee");
    if (msg.value >= feeETH) {
      feeManager.transferETHToOperator{value: feeETH}();
      if (msg.value > feeETH) payable(msg.sender).transfer(msg.value - feeETH);
    } else {
      feeManager.transferETHToOperator{value: msg.value}();
      uint256 fee = feeToken - ((feeETH - msg.value) * feeToken) / feeETH;
      feeManager.transferFeeToOperator(fee);
    }
    emit NodeUpdated(msg.sender, tierNameFrom, tierNameTo, count);
  }
  function getUpgradeFee(
    string memory tierNameFrom,
    string memory tierNameTo,
    uint32 count
  ) public view returns (uint256, uint256) {
    uint8 tierIndexTo = tierMap[tierNameTo];
    require(tierIndexTo > 0, "Invalid tier to upgrade to.");
    Tier storage tierTo = tierArr[tierIndexTo - 1];
    uint32 rateFee = feeManager.getRateUpgradeFee(tierNameFrom, tierNameTo);
    if (rateFee == 0) return (0, 0);
    uint256 amountToken = (tierTo.price * count * rateFee) / 10000;
    return (feeManager.getAmountETH(amountToken), amountToken);
  }
  function transfer(
    string memory tierName,
    uint32 count,
    address recipient
  ) public {
    require(!blacklist[msg.sender], "Invalid wallet");
    require(canNodeTransfer == true, "Node transfer unavailable!");
    uint8 tierIndex = tierMap[tierName];
    require(tierIndex > 0, "Invalid tier to transfer.");
    Tier storage tier = tierArr[tierIndex - 1];
    require(countOfUser[recipient] + count <= maxCountOfUser, "Cannot transfer node, because recipient will get more than MAX");
    require(countOfNodes(recipient, tierName) + count <= tier.maxPurchase, "Cannot transfer node, because recipient will get more than MAX");
    uint256[] storage nodeIndiceFrom = nodesOfUser[msg.sender];
    uint256[] storage nodeIndiceTo = nodesOfUser[recipient];
    uint32 countTransfer = 0;
    uint256 claimableAmount = 0;
    for (uint32 i = 0; i < nodeIndiceFrom.length; i++) {
      uint256 nodeIndex = nodeIndiceFrom[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner == msg.sender && tierIndex - 1 == node.tierIndex) {
          node.owner = recipient;
          uint256 multiplier = getBoostRate();
          uint256 claimed = (uint256(block.timestamp - node.claimedTime) * tier.rewardsPerTime) / tier.claimInterval;
          claimableAmount = (claimed * multiplier) / 1 ether + claimableAmount;
          node.claimedTime = uint32(block.timestamp);
          countTransfer++;
          nodeIndiceTo.push(nodeIndex);
          nodeIndiceFrom[i] = 0;
          if (countTransfer == count) break;
        }
      }
    }
    require(countTransfer == count, "Not enough nodes to transfer.");
    countOfUser[msg.sender] -= count;
    countOfUser[recipient] += count;
    if (claimableAmount > 0) {
      rewardsOfUser[msg.sender] = rewardsOfUser[msg.sender] + claimableAmount;
      rewardsTotal = rewardsTotal + claimableAmount;
      unclaimed[msg.sender] += claimableAmount;
    }
    uint256 fee = feeManager.getTransferFee(tier.price * count);
    // if (count >= 10) fee = fee.mul(10000 - discountPer10).div(10000);
    if (fee > claimableAmount) feeManager.transferFrom(address(msg.sender), address(this), fee - claimableAmount);
    else if (fee < claimableAmount) {
      unclaimed[msg.sender] += claimableAmount - fee;
    }
    emit NodeTransfered(msg.sender, recipient, count);
  }
  function burnUser(address account) public onlyOwner {
    uint256[] storage nodeIndice = nodesOfUser[account];
    for (uint32 i = 0; i < nodeIndice.length; i++) {
      uint256 nodeIndex = nodeIndice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner == account) {
          node.owner = address(0);
          node.claimedTime = uint32(block.timestamp);
          Tier storage tier = tierArr[node.tierIndex];
          countOfTier[tier.name]--;
        }
      }
    }
    nodesOfUser[account] = new uint256[](0);
    countTotal -= countOfUser[account];
    countOfUser[account] = 0;
  }
  function burnNodes(uint32[] memory indice) public onlyOwner {
    uint32 count = 0;
    for (uint32 i = 0; i < indice.length; i++) {
      uint256 nodeIndex = indice[i];
      if (nodeIndex > 0) {
        Node storage node = nodesTotal[nodeIndex - 1];
        if (node.owner != address(0)) {
          uint256[] storage nodeIndice = nodesOfUser[node.owner];
          for (uint32 j = 0; j < nodeIndice.length; j++) {
            if (nodeIndex == nodeIndice[j]) {
              nodeIndice[j] = 0;
              break;
            }
          }
          countOfUser[node.owner]--;
          node.owner = address(0);
          node.claimedTime = uint32(block.timestamp);
          Tier storage tier = tierArr[node.tierIndex];
          countOfTier[tier.name]--;
          count++;
        }
      }
    }
    countTotal -= count;
  }
  function pay(uint8 count, uint256[] memory selected) public payable {
    require(count > 0 && count <= 12, "Invalid number of months.");
    uint256 fee = 0;
    if (selected.length == 0) {
      uint256[] storage nodeIndice = nodesOfUser[msg.sender];
      for (uint32 i = 0; i < nodeIndice.length; i++) {
        uint256 nodeIndex = nodeIndice[i];
        if (nodeIndex > 0) {
          Node storage node = nodesTotal[nodeIndex - 1];
          if (node.owner == msg.sender) {
            Tier storage tier = tierArr[node.tierIndex];
            node.limitedTime += count * uint32(30 days);
            fee = tier.maintenanceFee * count + fee;
          }
        }
      }
    } else {
      for (uint32 i = 0; i < selected.length; i++) {
        uint256 nodeIndex = selected[i];
        Node storage node = nodesTotal[nodeIndex];
        if (node.owner == msg.sender) {
          Tier storage tier = tierArr[node.tierIndex];
          node.limitedTime += count * uint32(30 days);
          fee = tier.maintenanceFee * count + fee;
        }
      }
    }
    if (feeTokenAddress == address(0)) {
      // pay with ETH
      require(fee == msg.value, "Invalid Fee amount");
      feeManager.transferETHToOperator{value: fee}();
    } else {
      // pay with stable coin BUSD
      require(fee < IERC20(feeTokenAddress).balanceOf(msg.sender), "Insufficient BUSD amount");
      feeManager.transferTokenToOperator(msg.sender, fee, feeTokenAddress);
    }
  }
  function unpaidNodes() public view onlyOwner returns (Node[] memory) {
    uint32 count = 0;
    for (uint32 i = 0; i < nodesTotal.length; i++) {
      Node storage node = nodesTotal[i];
      if (node.owner != address(0) && node.limitedTime < uint32(block.timestamp)) {
        count++;
      }
    }
    Node[] memory nodesInactive = new Node[](count);
    uint32 j = 0;
    for (uint32 i = 0; i < nodesTotal.length; i++) {
      Node storage node = nodesTotal[i];
      if (node.owner != address(0) && node.limitedTime < uint32(block.timestamp)) {
        nodesInactive[j++] = node;
      }
    }
    return nodesInactive;
  }
  function addBlacklist(address _account) public onlyOwner {
    blacklist[_account] = true;
  }
  function removeBlacklist(address _account) public onlyOwner {
    blacklist[_account] = false;
  }
  /*function getAirdrops() public view returns (string[] memory) {
    uint256 _len = airdrops.length;
    for (uint32 i = 0; i < airdrops.length; i++) {
      if(uint256(merkleRoot[airdrops[i]])==0) _len--;
    }
    string[] memory _airdrops = new string[](_len);
    for (uint32 i = 0; i < airdrops.length; i++) {
      _airdrops[i] = airdrops[i];
    }
    return _airdrops;
  }
  function setAirdrop(string memory _name, bytes32 _root) public onlyOwner {
    merkleRoot[_name] = _root;
  }
  function canAirdrop(address _account, string memory _tier, uint32 _amount) public view returns (bool) {
    bytes32 leaf = keccak256(abi.encodePacked(_account, _tier, _amount));
    return !airdropSupplied[leaf];
  }
  function claimAirdrop(string memory _name, string memory _tier, uint32 _amount, bytes32[] calldata _merkleProof) public {
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _tier, _amount));
    bool valid = MerkleProof.verify(_merkleProof, merkleRoot[_name], leaf);
    require(valid, "Invalid airdrop address.");
    require(!airdropSupplied[leaf], "Already claimed.");
    _create(msg.sender, _tier, '', _amount, 0);   
    airdropSupplied[leaf] = true;
  }*/
  function swapIn(
    uint32 _chainId,
    string memory _tierName,
    uint32 _amount
  ) public payable {
    uint8 tierIndex = tierMap[_tierName];
    require(tierIndex > 0, "Invalid tier to swap.");
    (, uint32 count, uint256[] memory nodeIndice) = _iterate(msg.sender, tierIndex, _amount);
    require(count == _amount, "Insufficient node amount.");
    int32 limitedTime = 0;
    for (uint32 i = 0; i < count; i++) {
      uint256 index = nodeIndice[i];
      Node storage node = nodesTotal[index - 1];
      node.claimedTime = uint32(block.timestamp);
      node.owner = address(0);
      limitedTime += int32(int32(node.limitedTime) - int256(block.timestamp));
    }
    if (msg.value > 0) payable(minter).transfer(msg.value);
    emit SwapIn(msg.sender, _chainId, _tierName, _amount, int32(int256(limitedTime) / int32(count)));
  }
  function swapOut(
    address _account,
    string memory _tierName,
    uint32 _amount,
    int32 _limitedTime
  ) public {
    require(msg.sender == minter, "Only minter can call swap.");
    uint8 tierIndex = tierMap[_tierName];
    require(tierIndex > 0, "Invalid tier to swap.");
    Tier storage tier = tierArr[tierIndex - 1];
    require(countOfNodes(_account, _tierName) + _amount <= tier.maxPurchase, "Cannot swap node, because recipient will get more than MAX");
    _create(_account, _tierName, "", _amount, _limitedTime);
    // emit SwapOut(_account, chainId, _tierName, _amount);
  }
}