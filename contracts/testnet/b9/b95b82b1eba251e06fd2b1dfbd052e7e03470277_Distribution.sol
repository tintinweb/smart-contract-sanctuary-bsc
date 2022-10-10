/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
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
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
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
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * opcode (which leaves remaining gas untouched) while Solidity uses an
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
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

// main parennt contract used
interface ILinkedParentContract{  
  function ClaimMainReward (  ) external;
  function ClaimMiscReward ( address tokenAddress ) external;
  function IncludeMeToStaking (  ) external;
  function MAX_TAX (  ) external view returns ( uint8 );
  function PancakeRouter (  ) external view returns ( address );
  function _buyTaxes (  ) external view returns ( uint8 first, uint8 second, uint8 third );
  function _limitRatios (  ) external view returns ( uint16 wallet, uint16 sell, uint16 buy, uint16 divisor );
  function _limits (  ) external view returns ( uint256 maxWallet, uint256 maxSell, uint256 maxBuy );
  function _pancakePairAddress (  ) external view returns ( address );
  function _sellTaxes (  ) external view returns ( uint8 first, uint8 second, uint8 third );
  function _taxRatios (  ) external view returns ( uint8 burn, uint8 buyback, uint8 dev, uint8 liquidity, uint8 events, uint8 marketing, uint8 rewards );
  function _taxWallet (  ) external view returns ( address dev, address events, address marketing );
  function accountTotalClaimed ( address ) external view returns ( uint256 );
  function addBlacklist ( address addr ) external;
  function addedToTokenHolderHistory ( address ) external view returns ( bool );
  function allowance ( address _owner, address spender ) external view returns ( uint256 );
  function approve ( address spender, uint256 amount ) external returns ( bool );
  function balanceOf ( address account ) external view returns ( uint256 );
  function changeMainReward ( address newReward ) external;
  function createLPandBNB ( uint16 permilleOfPancake, bool ignoreLimits ) external;
  function decimals (  ) external pure returns ( uint8 );
  function decreaseAllowance ( address spender, uint256 subtractedValue ) external returns ( bool );
  function dynamicSettings ( bool burn, bool limits, bool liquidity, bool sells ) external;
  function enableBlacklist ( bool enabled ) external;
  function enableManualSwap ( bool enabled ) external;
  function excludeAccountFromFees ( address account, bool exclude ) external;
  function getBlacklistInfo (  ) external view returns ( uint256 _launchBlock, uint8 _blacklistBlocks, uint8 _snipersRekt, bool _blacklistEnabled, bool _revertSameBlock );
  function getDynamicInfo (  ) external view returns ( bool _dynamicBurn, bool _dynamicLimits, bool _dynamicLiquidity, bool _dynamicSells, uint16 _targetLiquidity );
  function getLiquidityRatio (  ) external view returns ( uint256 );
  function getLiquidityUnlockInSeconds (  ) external view returns ( uint256 );
  function getMainBalance ( address addr ) external view returns ( uint256 );
  function getMiscBalance ( address addr ) external view returns ( uint256 );
  function getOwner (  ) external view returns ( address );
  function getSupplyInfo (  ) external view returns ( uint256 initialSupply, uint256 circulatingSupply, uint256 burntTokens );
  function getTotalUnclaimed (  ) external view returns ( uint256 );
  function getWithdrawBalances (  ) external view returns ( uint256 buyback, uint256 dev, uint256 events, uint256 marketing );
  function increaseAllowance ( address spender, uint256 addedValue ) external returns ( bool );
  function isBlacklisted ( address ) external view returns ( bool );
  function isExcludedFromStaking ( address addr ) external view returns ( bool );
  function isLaunched (  ) external view returns ( bool );
  function isWhitelisted ( address ) external view returns ( bool );
  function launch (  ) external;
  function limitExempt ( address ) external view returns ( bool );
  function lockLiquidityTokens ( uint256 lockTimeInSeconds ) external;
  function mainReward (  ) external view returns ( address );
  function manualSwap (  ) external view returns ( bool );
  function name (  ) external view returns ( string memory);
  function owner (  ) external view returns ( address );
  function recoverBNB (  ) external;
  function recoverMiscToken ( address tokenAddress ) external;
  function releaseLP (  ) external;
  function removeBlacklist ( address addr ) external;
  function removeLP (  ) external;
  function renounceOwnership (  ) external;
  function sameBlockRevert ( bool enabled ) external;
  function setDevWallet ( address addr ) external;
  function setLimitExemptionStatus ( address account, bool exempt ) external;
  function setMarketingWallet ( address addr ) external;
  function setStakingExclusionStatus ( address addr, bool exclude ) external;
  function setTaxExemptionStatus ( address account, bool exempt ) external;
  function setTier1 ( address[] memory addresses ) external;
  function setTier2 ( address[] memory addresses ) external;
  function setTier3 ( address[] memory addresses ) external;
  function setWhitelistStatus ( address[] memory addresses, bool status ) external;
  function seteventsWallet ( address addr ) external;
  function swapThreshold (  ) external view returns ( uint16 );
  function symbol (  ) external view returns ( string memory);
  function taxExempt ( address ) external view returns ( bool );
  function tier2 ( address ) external view returns ( bool );
  function tier3 ( address ) external view returns ( bool );
  function tokenHolderHistory ( uint256 ) external view returns ( address );
  function totalPayouts (  ) external view returns ( uint256 );
  function totalRewards (  ) external view returns ( uint256 );
  function totalSupply (  ) external view returns ( uint256 );
  function totalTokenHolderHistory (  ) external view returns ( uint256 );
  function transfer ( address recipient, uint256 amount ) external returns ( bool );
  function transferFrom ( address sender, address recipient, uint256 amount ) external returns ( bool );
  function transferOwnership ( address newOwner ) external;
  function triggerBuyback ( uint256 amount ) external;
  function updateBuyTaxes ( uint8 first, uint8 second, uint8 third ) external;
  function updateLaunchTransferTax ( uint8 newLaunchTransferTax ) external;
  function updateLimits ( uint16 newMaxWalletRatio, uint16 newMaxSellRatio, uint16 newMaxBuyRatio, uint16 newDivisor, bool ofCurrentSupply ) external;
  function updateRatios ( uint8 newBurn, uint8 newBuyback, uint8 newDev, uint8 newLiquidity, uint8 newevents, uint8 newMarketing, uint8 newRewards ) external;
  function updateRewardSplit ( uint8 mainSplit, uint8 miscSplit ) external;
  function updateSellTaxes ( uint8 first, uint8 second, uint8 third ) external;
  function updateSwapThreshold ( uint16 threshold ) external;
  function updateTargetLiquidity ( uint16 target ) external;
  function updateTokenDetails ( string memory newName, string memory newSymbol ) external;
  function withdrawDev (  ) external;
  function withdrawMarketing (  ) external;
  function withdrawevents (  ) external;
}


contract Distribution is Ownable {
    
    // Safe math
    using SafeMath for uint256;
    using SafeMathInt for int256;

    // Info of each distribution user.
    struct UserDistributionInfo {
        uint256 distributionId;     // Unique identifier of distribution
        uint256 parentTokenBalance; // How many LP tokens the user has provided.
        uint256 rewardPercentage;   // Reward percentage
        bool claimed;               // Has the distribution token bee fully claimed
        uint256 claimedTime;        // Claimed time
    }

    // Info of each distribution.
    struct DistributionInfo {
        uint256 distributionId;             // Unique identifier
        IERC20 token;                       // Address of token contract.
        uint256 totalDistributionTokens;    // Total number of parent tokens
        uint256 totalParentTokensHeld;      // Total number of parent tokens held
        uint256 numOfDistributions;         // Number of distributions
        address[] distributionAddresses;    // Address distribution list
        uint256 creationTime;               // Creation time
    }

    // The Linked Distribution Token
    ILinkedParentContract public PARENT_TOKEN;
    
    // Info of each user that stakes LP tokens.
    mapping (address => uint256[])  public usersDistributionIds;  // Users distributions
    mapping (address => UserDistributionInfo[]) public userDistributionStatus; // List of users distributions

    // blacklisted details (used to remove users, contracts, team wallets etc)
    mapping(address => bool) public blackListed;

    // some contract stats
    uint256 public totalDistributionTokens = 0;  // Total number of distributions     
    uint256 public totalTokensDistributed = 0;   // Total number of tokens distributed
    uint256 public totalClaimedTokens = 0;       // Total number of tokens claimed
    
    // events    
    event Withdraw(address indexed user, uint256 indexed distributionId, uint256 amount);
    
    // Info of each distribution token.
    DistributionInfo[] private distributionTokens;  // list of distribution tokens

    
    constructor(address _linkedParentContractAddress
    ) {
        PARENT_TOKEN = ILinkedParentContract(_linkedParentContractAddress);
    }

  	// @dev Owner functions start -------------------------------------

    // Add a new lp to the pool. Can only be called by the owner.
    function addNewTokenForDistribution(
        IERC20 _token,
        uint256 _distributionAmount
    ) external onlyOwner {

        IERC20 distributionContract = IERC20(_token);
        totalTokensDistributed += _distributionAmount;

        // Confirm there are holders
        require(PARENT_TOKEN.totalTokenHolderHistory()  > 0, "addNewTokenForDistribution: Address list cannot be empty");

        // value to hold total address wallets total to work percentages
        uint256 totalParentTokensHeld = 0; 
        uint256 numOfDistributions = 0;

        // Work out total held tokens amoung holders           
        for (uint i = 0; i < PARENT_TOKEN.totalTokenHolderHistory(); i++) {

            // get wallet
            address holder = PARENT_TOKEN.tokenHolderHistory(i);

            // if not blacklisted and balance greater than 0 -- add to total / total accounts
            if(!isBlacklisted(holder)){
                uint256 addressBalance = PARENT_TOKEN.balanceOf(holder);

                if(addressBalance > 0){
                    totalParentTokensHeld += addressBalance;
                    numOfDistributions += 1;
                }
            }
        }         
  	
        // Confirm there are applicable holders
        require(totalParentTokensHeld > 0, "addNewTokenForDistribution: There doesnt appear to be any holders");

        address[] memory totalAccounts = new address[](numOfDistributions);

        // Deter claimable amount
        for (uint i = 0; i < PARENT_TOKEN.totalTokenHolderHistory(); i++) {

            address holder = PARENT_TOKEN.tokenHolderHistory(i);
            // if not blacklisted and balance greater than 0 -- add to total / total accounts
            if(!isBlacklisted(holder)){

                uint256 addressBalance = PARENT_TOKEN.balanceOf(holder);

                // recheck balance - encase of sell during method
                if(addressBalance > 0){
                    
                    // determine claimable percentage e.g.  (100 / 2000) * 100 = 5 (%)
                    uint256 percentageClaimable = (addressBalance / totalParentTokensHeld) * 100;

                    // Add distribution token
                    userDistributionStatus[holder].push(
                        UserDistributionInfo({
                            distributionId: (totalDistributionTokens + 1),
                            parentTokenBalance: addressBalance,
                            rewardPercentage: percentageClaimable,
                            claimed: false,
                            claimedTime: 0
                        })
                    );    

                    totalAccounts[i] = holder;
                    usersDistributionIds[holder].push((totalDistributionTokens + 1));
                }
            }
        } 

        // Add distribution token
        distributionTokens.push(
            DistributionInfo({
                distributionId: (totalDistributionTokens + 1),
                token: distributionContract,
                totalDistributionTokens: _distributionAmount,
                totalParentTokensHeld: totalParentTokensHeld,
                numOfDistributions: numOfDistributions,
                distributionAddresses: totalAccounts,
                creationTime: block.timestamp
            })
        );
    }

    
    // @dev User Callable Functions start here! ---------------------------------------------  	
    function setBlacklist(address _address, bool _isBlacklisted) external onlyOwner {
        blackListed[_address] = _isBlacklisted;
    }

    function isBlacklisted(address _address) public view returns (bool){
        return blackListed[_address];
    }

    // Withdraw distribution tokens
    function withdraw(uint256 _distributionId) public {

        // check account can claim
        require(isWalletPartOfDistribution(_distributionId, msg.sender), "withdraw: you are not part of the distribution list");

        // load accounts distribution information
        DistributionInfo storage distribution = distributionTokens[_distributionId];
        uint256 usersInfoIndex = getUserDistributionStatusId(_distributionId, msg.sender);      
        UserDistributionInfo storage userDistribution = userDistributionStatus[msg.sender][usersInfoIndex];
        require(!userDistribution.claimed, "withdraw: you have already claimed this token");  
        
        // set claimed as true to stop re-entry
        userDistribution.claimed = true;
        userDistribution.claimedTime = block.timestamp;  
        
        // send distribution
        // formaula e.g (2000 * 5) / 100 = 100 tokens
        uint256 _amount = (distribution.totalDistributionTokens*userDistribution.rewardPercentage)/100; 
        safeTokenTransfer(distribution.token, msg.sender, _amount);
        
        // set timestamp       
        emit Withdraw(msg.sender, _distributionId, _amount);
    }
    
    // @dev Interal Callable Functions start here! ---------------------------------------------

    // get users distribution status Id
    function getUserDistributionStatusId(uint256 _distributionId, address _account) internal view returns (uint256) {
        
        // conditions - exists and active
        uint256  requestedIndex = 0;
        bool foundIndex = false;

        UserDistributionInfo[] storage usersInfo = userDistributionStatus[_account];
        uint256 distributionCount = usersInfo.length; 

        for (uint256 i = 0; i < distributionCount; i++) {
            if(usersInfo[i].distributionId == _distributionId){
                requestedIndex = i;
                foundIndex = true;
                break;
            }
        } 
        
        require(foundIndex, "getUserDistributionStatus: user distribution status not found"); 
        return requestedIndex; 
    }    
 

    // check address can distribution    
    function isWalletPartOfDistribution(uint256 _distributionId, address _account) internal view returns (bool) {
        
        uint256[] storage usersInfo = usersDistributionIds[_account];
        uint256 distributionCount = usersInfo.length;        
        bool canClaim = false; 
        for (uint256 i = 0; i < distributionCount; i++) {
            if(usersInfo[i] == _distributionId){
                canClaim = true;
                break;
            }
        } 
        return canClaim;
    }    

    // Safe transfer function, just in case if rounding error causes pool to not have enough tokens.
    function safeTokenTransfer(IERC20 _distributionToken, address _to, uint256 _amount) internal {

        uint256 availableTokens = _distributionToken.balanceOf(address(this));
        
        if (_amount > availableTokens) {
            _distributionToken.transfer(_to, availableTokens);
            totalClaimedTokens+= availableTokens;
        } else {
            _distributionToken.transfer(_to, _amount);
            totalClaimedTokens+= _amount;
        }
    }

}