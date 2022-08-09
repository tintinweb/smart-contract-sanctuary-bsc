// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/IGuilderFi.sol";
import "./interfaces/ISafeExitFund.sol";
import "./interfaces/ILocker.sol";
import "./interfaces/IDexRouter.sol";
import "./interfaces/IPreSale.sol";
import "./interfaces/ISafeExitFund.sol";
import "./Locker.sol";

contract PreSale is IPreSale {

  using SafeMath for uint256;

  struct Tier {
    uint256 tierId;
    uint256 minAmount;
    uint256 maxAmount;
    uint256 tokensPerEth;
  }

  // tiers
  Tier private publicSale = Tier(0, 0.25 ether, 10 ether, 54 ether);
  
  // tiers array
  Tier[] private tiers;

  // constants
  uint256 private constant MAX_UINT256 = ~uint256(0);

  // maps/arrays
  mapping(address => uint256) private whitelist;
  mapping(address => ILocker) private _lockers;
  mapping(address => uint256) private _purchaseAmount;
  mapping(address => bool) private _refundClaimed;
  mapping(address => bool) private _hasMintedSafeExit;

  // settings
  mapping(uint256 => bool) private _isSaleOpen;
  mapping(uint256 => uint256) private _saleCaps;
  mapping(uint256 => uint256) private _saleCloseDates;

  uint256 private _softCap = 1500 ether;
  uint256 private _lockDuration = 30 days;

  // flags
  bool private _isRefundActivated = false;
  uint256 private _tokensSold = 0;
  bool private _isSaleClosed = false;
  uint256 private _saleCloseDate;

  uint256 constant private MIN_SAFE_EXIT_PURCHASE_AMOUNT = 0.5 ether; 

  // contracts
  IGuilderFi private _token;

  modifier onlyTokenOwner() {
    require(msg.sender == address(_token.getOwner()), "Sender is not token owner");
    _;
  }

  constructor(address tokenAddress) {
    _token = IGuilderFi(tokenAddress);

    // add sales tiers
    tiers.push(publicSale);
  }

  /**
   * Given a wallet address, return the tier information for that wallet
   * If tierId = 0, this means the wallet is not white listed and should
   * be treated as a public sale participant.
   */
  function getTier(address _address) public view returns (
    uint256 tierId,
    uint256 minAmount,
    uint256 maxAmount,
    uint256 tokensPerEth
  ) {
    uint256 _tierId = whitelist[_address];

    // loop through tiers
    for (uint256 i = 0; i< tiers.length; i++) {
      Tier memory tier = tiers[i];

      // find matching tier
      if (tier.tierId == _tierId) {
        return (
          tier.tierId,
          tier.minAmount,
          tier.maxAmount,
          tier.tokensPerEth
        );
      }
    }

    // default to public sale if no matching tier found
    return (
      publicSale.tierId,
      publicSale.minAmount,
      publicSale.maxAmount,
      publicSale.tokensPerEth
    );
  }

  /**
   * Buy tokens - number of tokens determined by tier
   */
  function buyTokens() public payable {
    require(!_isSaleClosed, "Sale is closed");

    (uint256 tierId, uint256 minAmount, uint256 maxAmount, uint256 tokensPerEth) = getTier(msg.sender);

    bool _isSaleActive = _isSaleOpen[tierId] &&
      (_saleCloseDates[tierId] == 0 || block.timestamp < _saleCloseDates[tierId]);

    require(_isSaleActive, tierId == 0 ? "Public sale is not open" : "Whitelist sale is not open");
    require(msg.value >= minAmount, "Purchase amount too low");
    require(msg.value <= maxAmount, "Purchase amount too high");
    require(_purchaseAmount[msg.sender].add(msg.value) <= maxAmount, "Total purchases exceed limit");

    uint256 tokenAmount = msg.value.mul(tokensPerEth).div(1 ether);
    _tokensSold = _tokensSold.add(tokenAmount);

    require(_token.balanceOf(address(this)) >= tokenAmount, "Presale requires more tokens");

    // increment total purchase amount
    _purchaseAmount[msg.sender] = _purchaseAmount[msg.sender].add(msg.value);

    // check if locker exists
    ILocker userLocker = _lockers[msg.sender];

    if (address(userLocker) == address(0)) {
      // create a new locker
      userLocker = new Locker(address(this), address(_token));
      _lockers[msg.sender] = userLocker;
    }

    // calculate tokens to lock (50%)
    uint256 tokensToLock = tokenAmount.div(2);
    uint256 tokensToTransfer = tokenAmount.sub(tokensToLock);

    // deposit half tokens into the locker
    _token.transfer(address(userLocker), tokensToLock);

    // sending half tokens to the user
    _token.transfer(msg.sender, tokensToTransfer);

    // safe exit
    ISafeExitFund _safeExit = ISafeExitFund(_token.getSafeExitFundAddress());
    
    // gift a safe exit NFT if its the first time buying
    if (
      !_hasMintedSafeExit[msg.sender] &&
      _purchaseAmount[msg.sender] >= MIN_SAFE_EXIT_PURCHASE_AMOUNT &&
      _safeExit.issuedTokens() < _safeExit.maxSupply()
    ) { 
        _safeExit.mintRandom(msg.sender);
        _hasMintedSafeExit[msg.sender] = true;
    }

    _safeExit.capturePresalePurchase(msg.sender, msg.value);    
  }

  /**
   * Finalise pre-sale and distribute funds:
   * - Liquidity pool: 60%
   * - Treasury: 16%
   * - Safe Exit Fund: 12%
   * - Liquidity Relief Fund: 12%
   * 
   * If soft cap is not reached, allow participants to claim a refund
   */
  function finalizeSale() override external onlyTokenOwner {
    // if soft cap reached, distribute to other contracts
    uint256 totalEth = address(this).balance;

    _isSaleClosed = true;
    _saleCloseDate = block.timestamp;

    if (totalEth < _softCap) {
      _isRefundActivated = true;
    }
    else {
      // distribute 60% to liquidity pool
      uint256 liquidityEthAmount = totalEth.mul(60 ether).div(100 ether);
      uint256 liquidityTokenAmount = _tokensSold.mul(60 ether).div(100 ether);

      require(liquidityTokenAmount <= _token.balanceOf(address(this)), "Insufficient liquidity tokens");

      IDexRouter router = IDexRouter(_token.getRouter());
      router.addLiquidityETH{value: liquidityEthAmount} (
        address(_token),
        liquidityTokenAmount,
        0,
        0,
        _token.getTreasuryAddress(),
        block.timestamp
      );

      ISafeExitFund safeExitFund = ISafeExitFund(_token.getSafeExitFundAddress());

      // distribute 12% to safe exit fund
      uint256 safeExitEthAmount = totalEth.mul(12 ether).div(100 ether);
      payable(address(safeExitFund)).transfer(safeExitEthAmount);

      // set safe exit activation date for 90 days
      safeExitFund.setActivationDate(block.timestamp + 90 days);

      // distribute 12% to liquidity relief fund (LRF)
      uint256 lrfEthAmount = totalEth.mul(12 ether).div(100 ether);
      payable(_token.getLrfAddress()).transfer(lrfEthAmount);

      // distribute remaining 16% to treasury
      uint256 treasuryEthAmount = totalEth.sub(liquidityEthAmount).sub(safeExitEthAmount).sub(lrfEthAmount);
      payable(_token.getTreasuryAddress()).transfer(treasuryEthAmount);

      // refund remaining tokens to treasury
      _token.transfer(_token.getTreasuryAddress(), _token.balanceOf(address(this)));
    }
  }

  /**
   * Claim refund
   */
  function claimRefund() override external returns (bool) {
    require(_isSaleClosed, "Sale is not closed");
    require(_isRefundActivated, "Refunds are not available");
    require(!_refundClaimed[msg.sender], "Refund already claimed");
    
    uint256 refundEthAmount = _purchaseAmount[msg.sender];
    (bool success,) = payable(msg.sender).call{ value: refundEthAmount }("");
    return success;
  }

  /**
   * Unlock tokens in user locker
   */
  function unlockTokens() override external {
    require(_isSaleClosed, "Sale is not closed yet");
    require(block.timestamp >= _saleCloseDate + _lockDuration, "Tokens cannot be unlocked yet");

    ILocker userLocker = _lockers[msg.sender];
    userLocker.withdraw(msg.sender);
  }

  /**
   * Cancel sale
   */
  function cancelSale() override external onlyTokenOwner {
    _isSaleClosed = true;
    _saleCloseDate = block.timestamp;
    _isRefundActivated = true;
  }

  /**
   * Public getter functions
   */
  function token() public view override returns (address) { return address(_token); }
  function isPublicSaleOpen() public view override returns (bool) { return _isSaleOpen[0]; }
  function isWhitelistSaleOpen(uint256 tierId) public view override returns (bool) { return _isSaleOpen[tierId]; }
  function softCap() public view override returns (uint256) { return _softCap; }
  function publicSaleCloseDate() public view override returns (uint256) { return _saleCloseDates[0]; }
  function whitelistSaleCloseDate(uint256 tierId) public view override returns (uint256) { return _saleCloseDates[tierId]; }
  function lockerUnlockDate() public view override returns (uint256) { return _isSaleClosed ? _saleCloseDate + _lockDuration : 0; }
  function isRefundActivated() public view override returns (bool) { return _isRefundActivated; }
  function purchaseAmount(address _address) public view override returns (uint256) { return _purchaseAmount[_address]; }
  function refundClaimed(address _address) public view override returns (bool) { return _refundClaimed[_address]; }
  function locker(address _address) public view override returns (address) { return address(_lockers[_address]); }
  function tokensSold() public view override returns (uint256) { return _tokensSold; }
  function lockDuration() public view override returns (uint256) { return _lockDuration; }
  function isSaleClosed() public view override returns (bool) { return _isSaleClosed; }
  
  /**
   * External setter functions
   */
  function openPublicSale(bool isOpen) override external onlyTokenOwner {
    _isSaleOpen[0] = isOpen;
  }

  function openWhitelistSale(uint256 tierId, bool isOpen) override external onlyTokenOwner {
    _isSaleOpen[tierId] = isOpen;
  }

  function setSoftCap(uint256 softCapAmount) override external onlyTokenOwner {
    _softCap = softCapAmount;
  }

  function setPublicSaleCloseDate(uint256 date) override external onlyTokenOwner {
    _saleCloseDates[0] = date;
  }

  function setWhitelistSaleCloseDate(uint256 tierId, uint256 date) override external onlyTokenOwner {
    _saleCloseDates[tierId] = date;
  }

  function setLockDuration(uint256 duration) override external onlyTokenOwner {
    _lockDuration = duration;
  }

  function addToWhitelist(address[] memory _addresses, uint256 _tierId) override external onlyTokenOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      whitelist[_addresses[i]] = _tierId;
    }
  }

  function removeFromWhitelist(address[] memory _addresses) override external onlyTokenOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      whitelist[_addresses[i]] = 0;
    }
  }

  function addCustomTier (
    uint256 tierId,
    uint256 minPurchaseAmount,
    uint256 maxPurchaseAmount,
    uint256 tokensPerEth
  ) external override onlyTokenOwner {
    tiers.push(Tier(tierId, minPurchaseAmount, maxPurchaseAmount, tokensPerEth));
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

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

pragma solidity 0.8.9;

interface IGuilderFi {
  // Events
  event LogRebase(uint256 indexed epoch, uint256 totalSupply, uint256 pendingRebases);

  // Fee struct
  struct Fee {
    uint256 treasuryFee;
    uint256 lrfFee;
    uint256 liquidityFee;
    uint256 safeExitFee;
    uint256 burnFee;
    uint256 totalFee;
  }

  // Rebase functions
  function rebase() external;
  function getRebaseRate() external view returns (uint256);
  function maxRebaseBatchSize() external view returns (uint256);

  // Transfer
  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  // Allowance
  function allowance(address owner_, address spender) external view returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);

  // Launch token
  function launchToken() external;

  // Set on/off flags
  function setAutoSwap(bool _flag) external;
  function setAutoLiquidity(bool _flag) external;
  function setAutoLrf(bool _flag) external;
  function setAutoSafeExit(bool _flag) external;
  function setAutoRebase(bool _flag) external;

  // Set frequencies
  function setAutoLiquidityFrequency(uint256 _frequency) external;
  function setLrfFrequency(uint256 _frequency) external;
  function setSwapFrequency(uint256 _frequency) external;

  // Address settings
  function setFeeExempt(address _address, bool _flag) external;
  function setBlacklist(address _address, bool _flag) external;

  // Read only functions
  function hasLaunched() external view returns (bool);

  // Addresses
  function getOwner() external view returns (address);
  function getTreasuryAddress() external view returns (address);
  function getSwapEngineAddress() external view returns (address);
  function getLrfAddress() external view returns (address);
  function getAutoLiquidityAddress() external view returns (address);
  function getSafeExitFundAddress() external view returns (address);
  function getPreSaleAddress() external view returns (address);

  // Setup functions
  function setSwapEngine(address _address) external;
  function setLrf(address _address) external;
  function setLiquidityEngine(address _address) external;
  function setSafeExitFund(address _address) external;
  function setPreSaleEngine(address _address) external;
  function setTreasury(address _address) external;
  function setDex(address routerAddress) external;

  // Setup fees
  function setFees(
    bool _isSellFee,
    uint256 _treasuryFee,
    uint256 _lrfFee,
    uint256 _liquidityFee,
    uint256 _safeExitFee,
    uint256 _burnFee
  ) external;

  // Getters - setting flags
  function isAutoSwapEnabled() external view returns (bool);
  function isAutoRebaseEnabled() external view returns (bool);
  function isAutoLiquidityEnabled() external view returns (bool);
  function isAutoLrfEnabled() external view returns (bool);
  function isAutoSafeExitEnabled() external view returns (bool);

  // Getters - frequencies
  function autoSwapFrequency() external view returns (uint256);
  function autoLiquidityFrequency() external view returns (uint256);
  function autoLrfFrequency() external view returns (uint256);

  // Date/time stamps
  function initRebaseStartTime() external view returns (uint256);
  function lastRebaseTime() external view returns (uint256);
  function lastAddLiquidityTime() external view returns (uint256);
  function lastLrfExecutionTime() external view returns (uint256);
  function lastSwapTime() external view returns (uint256);
  function lastEpoch() external view returns (uint256);

  // Dex addresses
  function getRouter() external view returns (address);
  function getPair() external view returns (address);

  // Standard ERC20 functions
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external pure returns (uint8);
  function manualSync() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface ISafeExitFund {
  function captureTransaction(
    address sender,
    address recipient,
    uint256 tokenAmount
  ) external;

  function capturePresalePurchase(address _walletAddress, uint256 _amount) external;
  function claimSafeExit() external;
  function mintRandom(address _walletAddress) external;
  function mint(address _walletAddress, uint256 maxInsuranceAmount) external;

  // Public getter functions
  function maxSupply() external view returns (uint256);
  function activationDate() external view returns (uint256);
  function tokenURI(uint256 _nftId) external view returns (string memory);
  function issuedTokens() external view returns (uint256);

  function getPackage(uint256 _nftId) external view returns (
    uint256 packageId,
    string memory name,
    uint256 maxInsuranceAmount,
    string memory metadataUriActive,
    string memory metadataUriReady,
    string memory metadataUriDead
  );

  function createPackage(
    uint256 _packageId,
    string memory _name,
    uint256 _maxInsuranceAmount,
    string memory _uriActive,
    string memory _uriReady,
    string memory _uriDead) external;

  function getInsuranceStatus(address _walletAddress) external view returns (
    uint256 totalPurchaseAmount,
    uint256 maxInsuranceAmount,
    uint256 payoutAmount,
    uint256 premiumAmount,
    uint256 finalPayoutAmount    
  );

  // External setter functions
  function launchSafeExitNft(uint256 _randomSeed) external;
  function setMetadataUri(uint256 _packageId, string memory _uriActive, string memory _uriReady, string memory _uriDead) external;
  function setPresaleMetadataUri(string memory _uri) external;
  function setActivationDate(uint256 _date) external;
  function setMaxSupply(uint256 newMaxSupply) external;
  
  function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface ILocker {
  function withdraw(address _walletAddress) external;
  function burn() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDexRouter {
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
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IPreSale {
  // arrays
  function purchaseAmount(address _address) external returns (uint256);
  function refundClaimed(address _address) external returns (bool);
  function locker(address _address) external returns (address);
  
  // public getter functions
  function token() external view returns (address);
  function isPublicSaleOpen() external view returns (bool);
  function isWhitelistSaleOpen(uint256 tierId) external view returns (bool);
  function publicSaleCloseDate() external view  returns (uint256);
  function whitelistSaleCloseDate(uint256 tierId) external view  returns (uint256);
  function softCap() external view  returns (uint256);
  function lockerUnlockDate() external view  returns (uint256);
  function isRefundActivated() external returns (bool);
  function tokensSold() external returns (uint256);
  function lockDuration() external returns (uint256);
  function isSaleClosed() external returns (bool);

  function getTier(address _address) external view returns (
    uint256 tierId,
    uint256 minAmount,
    uint256 maxAmount,
    uint256 tokensPerEth
  );

  // external setter functions
  function openPublicSale(bool isOpen) external;
  function openWhitelistSale(uint256 tierId, bool isOpen) external;
  function setPublicSaleCloseDate(uint256 date) external;
  function setWhitelistSaleCloseDate(uint256 tierId, uint256 date) external;
  function setSoftCap(uint256 softCapAmount) external;
  function addToWhitelist(address[] memory _addresses, uint256 _tierId) external;
  function removeFromWhitelist(address[] memory _addresses) external;
  function setLockDuration(uint256 _duration) external;

  // functions
  function buyTokens() external payable;
  function finalizeSale() external;
  function claimRefund() external returns (bool);
  function unlockTokens() external;
  function cancelSale() external;

  function addCustomTier(
    uint256 tierId,
    uint256 minPurchaseAmount,
    uint256 maxPurchaseAmount,
    uint256 tokensPerEth
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./interfaces/ILocker.sol";
import "./interfaces/IGuilderFi.sol";

contract Locker is ILocker {
  address public presaleAddress;
  IGuilderFi public token;

  // CONSTANTS
  address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

  constructor(
    address _presaleAddress,
    address _tokenAddress
  ) {
    presaleAddress = _presaleAddress;
    token = IGuilderFi(_tokenAddress);
  }

  function withdraw(address _walletAddress) external {
    require(msg.sender == presaleAddress, "Sender is not presale contract");

    uint256 balance = token.balanceOf(address(this));
    token.transfer(_walletAddress, balance);
  }

  function burn() external {
    require(msg.sender == token.getSafeExitFundAddress(), "Sender is not SafeExit contract");
  
    uint256 tokenBalance = token.balanceOf(address(this));
    if (tokenBalance > 0) {
      token.transfer(DEAD, tokenBalance);
    }
  }
}