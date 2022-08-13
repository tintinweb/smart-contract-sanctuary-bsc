// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// ============ Internal Imports ============
import "./Bridge.sol";
import "./Pool.sol";
import "./interfaces/IYamaReceiver.sol";

// ============ External Imports ============
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Router is Ownable {
  Bridge public bridge;
  Pool[] public pools;

  // Checks if a contract address is a known pool.
  mapping(address => bool) isPool;

  // ============ Modifiers ============
  // @notice Ensures the caller is a pool.
  modifier onlyPool() {
    require(isPool[msg.sender]);
    _;
  }

  // @notice Ensures the caller is the bridge.
  modifier onlyBridge() {
    require(msg.sender == address(bridge));
    _;
  }

  // ============ External functions ============

  // @notice Used to swap to remote chains.
  function swap(
    uint256 srcPoolId,
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 amount,
    bytes32 toAddress,
    bytes calldata data
  ) external payable {
    pools[srcPoolId].token().transferFrom(
      msg.sender,
      address(pools[srcPoolId]),
      amount
    );

    pools[srcPoolId].sendSwap(
      dstChainId,
      dstChainPoolId,
      amount,
      msg.sender,
      toAddress,
      data,
      false
    );
  }

  // @notice Handles LP deposits.
  // @return Amount of LP tokens issued.
  function lpDeposit(
    uint256 poolId,
    uint256 amount
  ) external returns (uint256 issuedAmount) {
    pools[poolId].token().transferFrom(
      msg.sender,
      address(pools[poolId]),
      amount
    );

    return pools[poolId].lpDeposit(msg.sender, amount);
  }

  // @notice Handles LP withdrawals. Withdrawals are swapped to another chain.
  // @return Amount of underlying tokens withdrawn.
  function lpWithdraw(
    uint256 srcPoolId,
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 lpTokenAmount,
    bytes32 toAddress,
    bytes calldata data
  ) external payable returns (uint256 withdrawnAmount) {
    return pools[srcPoolId].lpWithdraw(
      dstChainId,
      dstChainPoolId,
      lpTokenAmount,
      msg.sender,
      toAddress,
      data
    );
  }

  function sendSwapMessage(
    uint256 srcPoolId,
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 amount,
    address fromAddress,
    bytes32 toAddress,
    bytes calldata data
  ) external payable onlyPool {
    bridge.sendSwapMessage{value:msg.value}(
      srcPoolId,
      dstChainId,
      dstChainPoolId,
      amount,
      fromAddress,
      toAddress,
      data
    );
  }

  function receiveSwapMessage(
    uint32 srcChainId,
    uint256 srcPoolId,
    uint256 dstChainPoolId,
    bytes32 fromAddress,
    uint256 amount,
    address toAddress,
    uint256[] memory receivedCredits,
    bytes calldata data
  ) external onlyBridge {
    pools[dstChainPoolId].receiveSwap(
      srcChainId,
      srcPoolId,
      amount,
      fromAddress,
      toAddress,
      data
    );

    pools[dstChainPoolId].updateReceivedCredits(srcChainId, receivedCredits);
  }

  function setBridge(Bridge _bridge) external onlyOwner {
    require(address(bridge) == address(0));
    bridge = _bridge;
  }

  // @notice Returns the number of pools.
  function numPools() external view returns (uint256) {
    return pools.length;
  }

  // @notice Creates a new pool.
  // @param name Name of the LP token.
  // @param symbol Symbol of the LP token.
  function createPool(
    IERC20 token,
    uint8 tokenDecimals,
    uint256 baseFeeMultiplier,
    uint256 equilibriumFeeMultiplier,
    string memory name,
    string memory symbol
  ) external onlyOwner {
    Pool pool = new Pool(
      pools.length,
      token,
      tokenDecimals,
      baseFeeMultiplier,
      equilibriumFeeMultiplier,
      name,
      symbol
    );
    isPool[address(pool)] = true;

    pools.push(pool);
  }

  // @notice Connects a local pool to a remote pool.
  function addRemotePool(
    uint256 localPoolId,
    uint32 chainId,
    uint256 remotePoolId,
    uint256 weight,
    uint8 _tokenDecimals,
    bool ready
  ) external onlyOwner {
    pools[localPoolId].addRemotePool(
      chainId,
      remotePoolId,
      weight,
      _tokenDecimals,
      ready
    );
  }

  function setRemotePoolReady(
    uint256 localPoolId,
    uint256 remotePoolId
  ) external onlyOwner {
    pools[localPoolId].setRemotePoolReady(remotePoolId);
  }

  function setRemotePoolWeight(
    uint256 localPoolId,
    uint256 remotePoolId,
    uint256 weight
  ) external onlyOwner {
    pools[localPoolId].setRemotePoolWeight(remotePoolId, weight);
  }

  function setFeeRates(
    uint256 localPoolId,
    uint256 newBaseFeeMultiplier,
    uint256 newEquilibriumFeeMultiplier
  ) external onlyOwner {
    pools[localPoolId].setFeeRates(
      newBaseFeeMultiplier,
      newEquilibriumFeeMultiplier
    );
  }

  function addBridge(
    uint32 chainId,
    bytes32 bridgeAddress
  ) external onlyOwner {
    bridge.addBridge(chainId, bridgeAddress);
  }

  // @notice Used to call the callback after a swap has been received.
  function callCallback(
    address toAddress,
    address token,
    uint256 amount,
    uint32 srcChainId,
    bytes32 fromAddress,
    bytes calldata data
  ) external onlyPool {
    IYamaReceiver(toAddress).yamaCallback(
      address(token),
      amount,
      srcChainId,
      fromAddress,
      data
    );
  }

  // @notice Used by the bridge to transmit credit information to remote pools.
  // @return An encoded bytes array representing credits data for a remote pool.
  function genCreditsData(
    uint32 dstChainId,
    uint256 dstChainPoolId
  ) external view returns (bytes memory) {
    uint256[] memory credits = new uint256[](pools.length);
    for (uint256 i = 0; i < pools.length; i++) {
      credits[i] = pools[i].getCredits(dstChainId, dstChainPoolId);
    }
    return abi.encodePacked(credits);
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// ============ Internal imports ============
import "./interfaces/IRouter.sol";

// ============ External imports ============
import {IInterchainGasPaymaster} from "@abacus-network/core/interfaces/IInterchainGasPaymaster.sol";
import {IOutbox} from "@abacus-network/core/interfaces/IOutbox.sol";
import {IAbacusConnectionManager} from "@abacus-network/core/interfaces/IAbacusConnectionManager.sol";


contract Bridge {
  // ============ Variables ============
  IRouter public router;

  IAbacusConnectionManager public abacusConnectionManager;
  // Interchain Gas Paymaster contract. The relayer associated with this contract
  // must be willing to relay messages dispatched from the current Outbox contract,
  // otherwise payments made to the paymaster will not result in relayed messages.
  IInterchainGasPaymaster public interchainGasPaymaster;

  // chainId => address
  mapping(uint32 => bytes32) public bridgeAddress;

  // ============ Modifiers ============
  // @notice Ensures the caller is the router.
  modifier onlyRouter() {
    require(msg.sender == address(router));
    _;
  }

  /**
   * @notice Only accept messages from an Abacus Inbox contract
   */
  modifier onlyInbox() {
      require(_isInbox(msg.sender), "!inbox");
      _;
  }

  constructor(
    address _router,
    address _abacusConnectionManager,
    address _interchainGasPaymaster
  ) {
    router = IRouter(_router);
    abacusConnectionManager = IAbacusConnectionManager(_abacusConnectionManager);
    interchainGasPaymaster = IInterchainGasPaymaster(_interchainGasPaymaster);
  }

  // ============ External functions ============
  function sendSwapMessage(
    uint256 srcPoolId,
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 amount,
    address fromAddress,
    bytes32 toAddress,
    bytes calldata data
  ) external payable onlyRouter {
    bytes memory payload = abi.encodePacked(
      srcPoolId,
      dstChainPoolId,
      bytes32(bytes20(fromAddress)),
      amount,
      toAddress,
      router.numPools(),
      router.genCreditsData(dstChainId, dstChainPoolId),
      data
    );

    uint256 leafIndex = _outbox().dispatch(
      dstChainId,
      bridgeAddress[dstChainId],
      payload
    );
    interchainGasPaymaster.payGasFor{value:msg.value}(
      address(_outbox()),
      leafIndex,
      dstChainId
    );
  }

  function handle(
    uint32 origin,
    bytes32 sender,
    bytes calldata payload
  ) external onlyInbox {
    require(sender == bridgeAddress[origin]);

    uint256 numPools = uint256(bytes32(payload[160:192]));

    uint256[] memory receivedCredits = new uint256[](numPools);

    for (uint256 i = 0; i < numPools; i++) {
      receivedCredits[i] = uint256(bytes32(payload[192 + 32 * i:224 + 32 * i]));
    }

    router.receiveSwapMessage(
      origin,
      uint256(bytes32(payload[:32])), // srcPoolId
      uint256(bytes32(payload[32:64])), // dstChainPoolId
      bytes32(payload[64:96]), // fromAddress
      uint256(bytes32(payload[96:128])), // amount
      address(bytes20(payload[128:160])), // toAddress
      receivedCredits,
      payload[192 + 32 * numPools:]
    );
  }

  function addBridge(
    uint32 chainId,
    bytes32 _bridgeAddress
  ) external onlyRouter {
    require(bridgeAddress[chainId] == bytes32(0));
    bridgeAddress[chainId] = _bridgeAddress;
  }

  // ============ Internal functions ============
  /**
   * @notice Determine whether _potentialInbox is an enrolled Inbox from the abacusConnectionManager
   * @return True if _potentialInbox is an enrolled Inbox
   */
  function _isInbox(address _potentialInbox) internal view returns (bool) {
      return abacusConnectionManager.isInbox(_potentialInbox);
  }

  /**
   * @notice Get the local Outbox contract from the abacusConnectionManager
   * @return The local Outbox contract
   */
  function _outbox() internal view returns (IOutbox) {
      return abacusConnectionManager.outbox();
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// ============ Internal imports ============
import "./interfaces/IRouter.sol";

// ============ External imports ============
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Pool is ERC20 {
  // ============ Constants ============
  uint256 public constant BASE_DENOMINATOR = 100000;

  // ============ Structs ============
  struct RemotePool {
    bool ready; // True after the reverse RemotePool is created.
    uint32 chainId;
    uint256 poolId;
    uint256 weight;
    uint8 tokenDecimals;

    // How much money on our pool is allocated to the remote pool. This is
    // the max amount the remote pool can swap to.
    uint256 localBalance;

    // Total amount of credits received, i.e. total amount of money known to
    // have been added to our localBalance on the remote chain.
    uint256 totalReceivedCredits;

    // Total amount of money sent to the remote chain.
    uint256 sentTokenAmount;

    // Total amount of money ever added to localBalance.
    uint256 credits;
  }

  // ============ Variables ============
  IERC20 public token;
  uint256 public poolId;
  uint8 public tokenDecimals;
  uint256 public baseFeeMultiplier;
  uint256 public equilibriumFeeMultiplier;
  uint256 public totalWeight;

  // How much of the token this pool contract possesses and manages.
  // This is the sum of remotePool[i].localBalance for all i.
  uint256 public totalAssets;

  // totalAssets + receivedSwaps - sentSwaps
  uint256 public totalLiquidity;

  RemotePool[] public remotePools;

  IRouter public router;

  // chainId => (poolId => remotePoolId)
  // remotePoolId is the ID of the element in the remotePools array.
  mapping(uint32 => mapping(uint256 => uint256)) public remotePoolIdLookup;

  // chainId => (poolId => exists)
  mapping(uint32 => mapping(uint256 => bool)) public remotePoolExists;

  // ============ Events ============


  // ============ Modifiers ============
  // @notice Ensures the caller is the router.
  modifier onlyRouter() {
    require(msg.sender == address(router));
    _;
  }

  constructor(
    uint256 _poolId,
    IERC20 _token,
    uint8 _tokenDecimals,
    uint256 _baseFeeMultiplier,
    uint256 _equilibriumFeeMultipler,
    string memory _name,
    string memory _symbol
  ) ERC20(_name, _symbol) {
    poolId = _poolId;
    token = _token;
    tokenDecimals = _tokenDecimals;
    equilibriumFeeMultiplier = _equilibriumFeeMultipler;
    baseFeeMultiplier = _baseFeeMultiplier;
    router = IRouter(msg.sender);
  }

  // ============ External functions ============

  // @notice Add a new remote pool.
  // @param ready Whether the reverse remote pool has been created.
  function addRemotePool(
    uint32 chainId,
    uint256 remotePoolId,
    uint256 weight,
    uint8 _tokenDecimals,
    bool ready
  ) external onlyRouter {
    RemotePool memory remotePool;
    remotePool.chainId = chainId;
    remotePool.poolId = remotePoolId;
    remotePool.weight = weight;
    remotePool.tokenDecimals = _tokenDecimals;
    remotePool.ready = ready;
    remotePools.push(remotePool);

    totalWeight += weight;

    remotePoolIdLookup[chainId][remotePoolId] = remotePools.length - 1;
    remotePoolExists[chainId][remotePoolId] = true;
  }

  // @notice Set a remote pool as ready.
  function setRemotePoolReady(uint256 remotePoolId) external onlyRouter {
    remotePools[remotePoolId].ready = true;
  }

  // @notice Set the weight of a remote pool.
  function setRemotePoolWeight(
    uint256 remotePoolId,
    uint256 weight
  ) external onlyRouter {
    totalWeight = totalWeight + weight - remotePools[remotePoolId].weight;
    remotePools[remotePoolId].weight = weight;
  }

  // @notice Sets the fee rates.
  function setFeeRates(
    uint256 newBaseFeeMultiplier,
    uint256 newEquilibriumFeeMultiplier
  ) external onlyRouter {
    baseFeeMultiplier = newBaseFeeMultiplier;
    equilibriumFeeMultiplier = newEquilibriumFeeMultiplier;
  }

  // @notice Send money to a remote pool.
  // @param dstChain The ID of the destination chain.
  // @param dstChainPoolId The ID of the pool on the destination chain.
  // @param amount The amount of money on the local chain that is being sent.
  // @param fromAddress The address the swap is being sent from.
  // @param toAddress The address the swap is being sent to.
  function sendSwap(
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 amount,
    address fromAddress,
    bytes32 toAddress,
    bytes calldata data,
    bool localLiquidityRemoved
  ) public payable onlyRouter {
    if (!localLiquidityRemoved) {
      addLiquidity(amount);
    }
    totalLiquidity -= amount;

    uint256 remotePoolId = remotePoolIdLookup[dstChainId][dstChainPoolId];

    uint256 convertedAmount = convertDecimalAmount(
      amount,
      tokenDecimals,
      remotePools[remotePoolId].tokenDecimals
    );

    require(estimateForeignBalance(remotePoolId) >= convertedAmount,
      "Yama: Insufficient remote pool liquidity");

    remotePools[remotePoolId].sentTokenAmount += convertedAmount;

    router.sendSwapMessage{value:msg.value}(
      poolId,
      dstChainId,
      dstChainPoolId,
      convertedAmount,
      fromAddress,
      toAddress,
      data
    );
  }

  // @notice Receive a swap and distribute fees.
  // @param srcChainId The ID of the source chain.
  // @param srcChainPoolId The ID of the pool on the source chain.
  // @param amount The amount of source tokens deposited.
  // @param fromAddress The address the swap is being sent from.
  // @param toAddress The address the swap is being sent to.
  function receiveSwap(
    uint32 srcChainId,
    uint256 srcChainPoolId,
    uint256 amount,
    bytes32 fromAddress,
    address toAddress,
    bytes calldata data
  ) external onlyRouter {
    uint256 remotePoolId = remotePoolIdLookup[srcChainId][srcChainPoolId];
    uint256 fees = calcBaseFee(amount) + calcEquilibriumFee(amount);
    uint256 distributedAmount = amount - fees;
    removeLocalBalance(remotePoolId, distributedAmount);

    token.transfer(toAddress, distributedAmount);

    try router.callCallback(
      toAddress,
      address(token),
      distributedAmount,
      srcChainId,
      fromAddress,
      data
    ) {} catch {}

    totalLiquidity += amount;
  }

  // @notice Update received credits for all pools on a remote chain.
  function updateReceivedCredits(
    uint32 srcChainId,
    uint256[] memory receivedCredits
  ) external onlyRouter {
    for (uint256 i = 0; i < receivedCredits.length; i++) {
      if (remotePoolExists[srcChainId][i]) {
        uint256 remotePoolId = remotePoolIdLookup[srcChainId][i];
        remotePools[remotePoolId].totalReceivedCredits = receivedCredits[i];
      }
    }
  }

  // @notice Retrieve total credits sent to a remote pool.
  // @param dstChainId Remote pool chain ID.
  // @param dstChainPoolId Remote pool ID on that chain.
  // @return Total money ever added to the remote pool's balance.
  function getCredits(
    uint32 dstChainId,
    uint256 dstChainPoolId
  ) external view returns (uint256) {
    if (!remotePoolExists[dstChainId][dstChainPoolId]) {
      return 0;
    }
    uint256 remotePoolId = remotePoolIdLookup[dstChainId][dstChainPoolId];
    return remotePools[remotePoolId].credits;
  }

  function decimals() public view override returns (uint8) {
    return tokenDecimals;
  }

  // @notice Handles LP deposits.
  // @return Amount of LP tokens issued.
  function lpDeposit(
    address from,
    uint256 amount
  ) external onlyRouter returns (uint256 issuedAmount) {
    issuedAmount = (amount * BASE_DENOMINATOR) / lpTokenPrice();
    addLiquidity(amount);
    _mint(from, issuedAmount);
  }

  // @notice Handles LP withdrawals.
  // @return Amount of underlying tokens withdrawn.
  function lpWithdraw(
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 lpTokenAmount,
    address fromAddress,
    bytes32 toAddress,
    bytes calldata data
  ) external payable onlyRouter returns (uint256 withdrawnAmount) {
    _burn(fromAddress, lpTokenAmount);
    withdrawnAmount = (lpTokenAmount * lpTokenPrice()) / BASE_DENOMINATOR;

    sendSwap(
      dstChainId,
      dstChainPoolId,
      withdrawnAmount,
      fromAddress,
      toAddress,
      data,
      true
    );
  }

  // ============ Internal functions ============

  // @notice Handles the allocation of new liquidity to the balances of remote
  // pools.
  // @param amount The amount of tokens to add.
  function addLiquidity(uint256 amount) internal {
    uint256 numPools = remotePools.length;
    uint256[] memory deficits = new uint256[](numPools);
    uint256 totalDeficit = 0;

    for (uint256 i = 0; i < numPools; i++) {
      uint256 expectedBalance = (
        totalAssets * remotePools[i].weight) / totalWeight;
      uint256 actualBalance = remotePools[i].localBalance;
      if (expectedBalance > actualBalance) {
        deficits[i] = expectedBalance - actualBalance;
        totalDeficit += deficits[i];
      }
    }

    if (totalDeficit > 0) {
      if (totalDeficit >= amount) {
        for (uint256 i = 0; i < numPools; i++) {
          addLocalBalance(i, (amount * deficits[i]) / totalDeficit);
        }
      } else {
        for (uint256 i = 0; i < numPools; i++) {
          addLocalBalance(i, deficits[i]);
        }
        amount -= totalDeficit  ;
        addLiquidityEvenly(amount);
      }
    } else {
      addLiquidityEvenly(amount);
    }
  }

  // @notice Adds liquidity to the local balances of remote pools evenly.
  // @param totalAmount The total amount of liquidity to add.
  function addLiquidityEvenly(uint256 totalAmount) internal {
    uint256 numPools = remotePools.length;
    uint256 individualAmount = totalAmount / numPools;
    for (uint256 i = 0; i < numPools; i++) {
      addLocalBalance(i, individualAmount);
    }
  }

  // @notice Adds to the local balance of a specific remote pool.
  // @param remotePoolId The ID of the remote pool.
  // @param amount The amount of tokens to add.
  function addLocalBalance(uint256 remotePoolId, uint256 amount) internal {
    remotePools[remotePoolId].localBalance += amount;
    remotePools[remotePoolId].credits += amount;
    totalAssets += amount;
    totalLiquidity += amount;
  }

  // @notice Removes from the local balance of a specific remote pool.
  // @param remotePoolId The ID of the remote pool.
  // @param amount The amount of tokens to remove.
  function removeLocalBalance(uint256 remotePoolId, uint256 amount) internal {
    remotePools[remotePoolId].localBalance -= amount;
    totalAssets -= amount;
    totalLiquidity -= amount;
  }

  // @notice Provides an estimate of this pool's localBalance on a remote pool.
  // @param remotePoolId The ID of the remote pool.
  function estimateForeignBalance(
    uint256 remotePoolId
  ) internal view returns (uint256) {
    return remotePools[remotePoolId].totalReceivedCredits
      - remotePools[remotePoolId].sentTokenAmount;
  }

  // @notice Calculate the fee of a swap to this chain.
  // @param swapAmount Amount of money removed from the pool.
  function calcBaseFee(
    uint256 swapAmount
  ) internal view returns (uint256 fee) {
    return (swapAmount * baseFeeMultiplier) / BASE_DENOMINATOR;
  }

  // @notice Calculate the equilibrium fee of a swap to this chain.
  // The equilibrium fee disincentivizes draining liquidity pools.
  // @param swapAmount Amount of money removed from the pool.
  function calcEquilibriumFee(
    uint256 swapAmount
  ) internal view returns (uint256 fee) {
    return
      (swapAmount * equilibriumFeeMultiplier * (totalAssets - swapAmount))
      / (totalAssets * BASE_DENOMINATOR);
  }

  // @notice Convert between token amounts with different decimal points.
  // @param originalDecimals The tokens value for the original amount.
  // @param convertedDecimals The tokens value for the converted amount.
  function convertDecimalAmount(
    uint256 amount,
    uint8 originalDecimals,
    uint8 convertedDecimals
  ) internal pure returns (uint256 convertedAmount) {
    if (convertedDecimals > originalDecimals) {
      return amount * (10 ** (convertedDecimals - originalDecimals));
    } else if (convertedDecimals < originalDecimals) {
      return amount / (10 ** (originalDecimals - convertedDecimals));
    } else {
      return amount;
    }
  }

  // @notice Returns the price of the LP token multiplied by BASE_DENOMINATOR.
  function lpTokenPrice() public view returns (uint256) {
    if (totalLiquidity == 0) {
      return BASE_DENOMINATOR;
    }

    return (totalLiquidity * BASE_DENOMINATOR) / totalSupply();
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;


interface IYamaReceiver {
  // @notice Called by the Yama bridge after money has been received.
  // @dev Verify that the caller is the Yama bridge.
  // @param token Address of the token.
  // @param amount The amount of received tokens.
  // @param srcChainId The source chain ID.
  // @param fromAddress The address the swap is being sent from.
  function yamaCallback(
    address token,
    uint256 amount,
    uint32 srcChainId,
    bytes32 fromAddress,
    bytes calldata data
  ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;


interface IRouter {
  function sendSwapMessage(
    uint256 srcPoolId,
    uint32 dstChainId,
    uint256 dstChainPoolId,
    uint256 amount,
    address fromAddress,
    bytes32 toAddress,
    bytes calldata data
  ) external payable;

  function receiveSwapMessage(
    uint32 srcChainId,
    uint256 srcPoolId,
    uint256 dstChainPoolId,
    bytes32 fromAddress,
    uint256 amount,
    address toAddress,
    uint256[] memory receivedCredits,
    bytes calldata data
  ) external;

  function callCallback(
    address toAddress,
    address token,
    uint256 amount,
    uint32 srcChainId,
    bytes32 fromAddress,
    bytes calldata data
  ) external;

  function numPools() external view returns (uint256);

  function genCreditsData(
    uint32 dstChainId,
    uint256 dstChainPoolId
  ) external view returns (bytes memory);
}

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

/**
 * @title IInterchainGasPaymaster
 * @notice Manages payments on a source chain to cover gas costs of relaying
 * messages to destination chains.
 */
interface IInterchainGasPaymaster {
    function payGasFor(
        address _outbox,
        uint256 _leafIndex,
        uint32 _destinationDomain
    ) external payable;
}

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

import {IMailbox} from "./IMailbox.sol";

interface IOutbox is IMailbox {
    function dispatch(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        bytes calldata _messageBody
    ) external returns (uint256);

    function cacheCheckpoint() external;

    function latestCheckpoint() external view returns (bytes32, uint256);

    function count() external returns (uint256);

    function fail() external;

    function cachedCheckpoints(bytes32) external view returns (uint256);

    function latestCachedCheckpoint()
        external
        view
        returns (bytes32 root, uint256 index);
}

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

import {IOutbox} from "./IOutbox.sol";

interface IAbacusConnectionManager {
    function outbox() external view returns (IOutbox);

    function isInbox(address _inbox) external view returns (bool);

    function localDomain() external view returns (uint32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

interface IMailbox {
    function localDomain() external view returns (uint32);
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