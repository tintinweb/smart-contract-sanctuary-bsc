// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IFeeCollector.sol";
import "./lib/FADERC20.sol";
import "./lib/SQRT.sol";
import "./lib/VirtualBalance.sol";
import "./governance/Governance.sol";

contract Swap is Governance {
  using SQRT for uint256;
  using SafeMath for uint256;
  using FADERC20 for IERC20;
  using VirtualBalance for VirtualBalance.Data;

  struct Balances {
    uint256 src;
    uint256 dst;
  }

  struct Volumes {
    uint128 confirmed;
    uint128 result;
  }
  
  struct Fees {
    uint256 fee;
    uint256 slippageFee;
  }

  event Error(string reason);

  event Deposited(
    address indexed sender,
    address indexed receiver,
    uint256 share,
    uint256 token0Amount,
    uint256 token1Amount
  );

  event Withdrawn(
    address indexed sender,
    address indexed receiver,
    uint256 share,
    uint256 token0Amount,
    uint256 token1Amount
  );

  event Swapped(
    address indexed sender,
    address indexed receiver,
    address indexed srcToken,
    address dstToken,
    uint256 amount,
    uint256 result,
    uint256 srcBalanceAdded,
    uint256 dstBalanceRemoved,
    address referral
  );

  event Sync(
    uint256 srcBalance,
    uint256 dstBalance,
    uint256 fee,
    uint256 slippageFee,
    uint256 referralShare,
    uint256 governanceShare
  );

  uint256 private constant _BASE_SUPPLY = 1000; // Total supply on first deposit

  IERC20 public immutable token0;
  IERC20 public immutable token1;
  mapping(IERC20 => Volumes) public volumes;
  mapping(IERC20 => VirtualBalance.Data) public virtualBalanceToAdd;
  mapping(IERC20 => VirtualBalance.Data) public virtualBalanceToRemove;

  modifier whenNotShutdown {
    require(governanceFactory.isActive(), "Swap: Factory Is Shutdown");
    _;
  }

  constructor(
    IERC20 _token0,
    IERC20 _token1,
    string memory name,
    string memory symbol,
    IGovernanceFactory _governanceFactory
  ) 
    ERC20(name, symbol)
    Governance(_governanceFactory)
  {
    require(bytes(name).length > 0, "Swap: Name Is Empty");
    require(bytes(symbol).length > 0, "Swap: Symbol Is Empty");
    require(_token0 != _token1, "Swap: Two Tokens Is Same");
    token0 = _token0;
    token1 = _token1;
  }

  /** Returns pair of tokens as [token0, token1] */
  function getTokens()
    external
    view
    returns(IERC20[] memory tokens)
  {
    tokens = new IERC20[](2);
    tokens[0] = token0;
    tokens[1] = token1;
  }

  function getToken(uint256 position)
    external
    view
    returns(IERC20)
  {
    if(position == 0 ) {
      return token0;
    } else if(position == 1){
      return token1;
    } else {
      revert("Swap: Pool Have Only Two Tokens");
    }
  }

  function getBalanceToAdd(IERC20 token)
    public
    view
    returns(uint256)
  {
    uint256 balance = token.getBalanceOf(address(this));
    return Math.max(virtualBalanceToAdd[token].current(getDecayPeriod(), balance), balance);
  }

  function getBalanceToRemove(IERC20 token)
    public
    view
    returns(uint256)
  {
    uint256 balance = token.getBalanceOf(address(this));
    return Math.min(virtualBalanceToRemove[token].current(getDecayPeriod(), balance), balance);
  }

  /** Returns how many `dst` tokens will be returned for `amount` of `src` tokens */
  function getQuote(IERC20 src, IERC20 dst, uint256 amount)
    external
    view
    returns(uint256)
  {
    return _getQuote(src, dst, amount, getBalanceToAdd(src), getBalanceToRemove(dst), getFee(), getSlippageFee());
  }

  function deposit(uint256[2] memory maxAmounts, uint256[2] memory minAmounts)
    external
    payable
    returns(uint256 fairSupply, uint256[2] memory receivedAmounts)
  {
    return depositFor(maxAmounts, minAmounts, msg.sender);
  }

  function depositFor(uint256[2] memory maxAmounts, uint256[2] memory minAmounts, address target)
    public
    payable
    nonReentrant
    returns(uint256 fairSupply, uint256[2] memory receivedAmounts)
  {
    IERC20[2] memory _tokens = [token0, token1];
    require(msg.value == (_tokens[0].isBNB() ? maxAmounts[0] : (_tokens[1].isBNB() ? maxAmounts[1] : 0)), "Swap: Wrong Value Usage");
    uint256 totalSupply = totalSupply();
    if(totalSupply == 0) {
      fairSupply = _BASE_SUPPLY.mul(99);
      _mint(address(this), _BASE_SUPPLY); // Donate up to 1%

      for(uint i = 0; i < maxAmounts.length; i++) {
        fairSupply = Math.max(fairSupply, maxAmounts[i]);
        require(maxAmounts[i] > 0, "Swap: Amount Is Zero");
        require(maxAmounts[i] >= minAmounts[i], "Swap: Min Amount Not Reached");
        _tokens[i].fadTransferFrom(payable(msg.sender), address(this), maxAmounts[i]);
        receivedAmounts[i] = maxAmounts[i];
      }
    } else {
      uint256[2] memory realBalances;
      for(uint i = 0; i < realBalances.length; i++) {
        realBalances[i] = _tokens[i].getBalanceOf(address(this)).sub(_tokens[i].isBNB() ? msg.value : 0);
      }

      fairSupply = type(uint256).max;
      for(uint i = 0; i < maxAmounts.length; i++) {
        fairSupply = Math.min(fairSupply, totalSupply.mul(maxAmounts[i]).div(realBalances[i]));
      }

      uint256 fairSupplyCached = fairSupply; 
      for(uint i = 0; i < maxAmounts.length; i++) {
        require(maxAmounts[i] > 0, "Swap: Amount Is Zero");
        uint256 amount = realBalances[i].mul(fairSupplyCached).add(totalSupply - 1).div(totalSupply);
        require(amount >= minAmounts[i], "Swap: Min Amount Not Reached");
        _tokens[i].fadTransferFrom(payable(msg.sender), address(this), amount);
        receivedAmounts[i] = _tokens[i].getBalanceOf(address(this)).sub(realBalances[i]);
        fairSupply = Math.min(fairSupply, totalSupply.mul(receivedAmounts[i]).div(realBalances[i]));
      }

      uint256 _decayPeriod = getDecayPeriod(); // gas saving
      for(uint i = 0; i < maxAmounts.length; i++) {
        virtualBalanceToRemove[_tokens[i]].scale(_decayPeriod, realBalances[i], totalSupply.add(fairSupply), totalSupply);
        virtualBalanceToAdd[_tokens[i]].scale(_decayPeriod, realBalances[i], totalSupply.add(fairSupply), totalSupply);
      }
    }
      
    require(fairSupply > 0, "Swap: Result Is Not Enough");
    _mint(target, fairSupply);

    emit Deposited(msg.sender, target, fairSupply, receivedAmounts[0], receivedAmounts[1]);
  }

  function withdraw(uint256 amount, uint256[] memory minReturns)
    external
    returns(uint256[2] memory withdrawnAmounts)
  {
    return withdrawFor(amount, minReturns, payable(msg.sender));
  }

  /** Withdraws funds from the liquidity pool */
  function withdrawFor(uint256 amount, uint256[] memory minReturns, address payable target)
    public
    nonReentrant
    returns(uint256[2] memory withdrawnAmounts)
  {
    IERC20[2] memory _tokens = [token0, token1];
    uint256 totalSupply = totalSupply();
    uint256 _decayPeriod = getDecayPeriod(); // gas saving
    _burn(msg.sender, amount);

    for(uint i = 0; i < _tokens.length; i++) {
      IERC20 token = _tokens[i];
      uint256 preBalance = token.getBalanceOf(address(this));
      uint256 value = preBalance.mul(amount).div(totalSupply);
      token.fadTransfer(target, value);
      withdrawnAmounts[i] = value;
      require(i >= minReturns.length || value >= minReturns[i], "Swap: Result Is Not Enough");
      virtualBalanceToRemove[token].scale(_decayPeriod, preBalance, totalSupply.add(amount), totalSupply);
      virtualBalanceToAdd[token].scale(_decayPeriod, preBalance, totalSupply.add(amount), totalSupply);
    }

    emit Withdrawn(msg.sender, target, amount, withdrawnAmounts[0], withdrawnAmounts[1]);
  }

  function swap(IERC20 src, IERC20 dst, uint256 amount, uint256 minReturn, address referral)
    external
    payable
    returns(uint256 result)
  {
    return swapFor(src, dst, amount, minReturn, referral, payable(msg.sender));
  }

  function swapFor(IERC20 src, IERC20 dst, uint256 amount, uint256 minReturn, address referral, address payable receiver)
    public
    payable
    nonReentrant
    whenNotShutdown
    returns(uint256 result)
  {
    require(msg.value == (src.isBNB() ? amount : 0), "Swap: Wrong Value");
    Balances memory balances = Balances({
      src: src.getBalanceOf(address(this)).sub(src.isBNB() ? msg.value : 0),
      dst: dst.getBalanceOf(address(this))
    });

    uint256 confirmed;
    Balances memory virtualBalances;
    Fees memory fees = Fees({
      fee: getFee(),
      slippageFee: getSlippageFee()
    });

    (confirmed, result, virtualBalances) = _doTransfers(src, dst, amount, minReturn, receiver, balances, fees);
    emit Swapped(msg.sender, receiver, address(src), address(dst), confirmed, result, virtualBalances.src, virtualBalances.dst, referral);
    
    _mintRewards(confirmed, result, referral, balances, fees);

    // Overflow of uint128 is desired
    volumes[src].confirmed += uint128(confirmed);
    volumes[src].result += uint128(result);
  }

  function _doTransfers(
    IERC20 src, 
    IERC20 dst, 
    uint256 amount, 
    uint256 minReturn, 
    address payable receiver,
    Balances memory balances,
    Fees memory fees
  )
    private
    returns(uint256 confirmed, uint256 result, Balances memory virtualBalances)
  {
    uint256 _decayPeriod = getDecayPeriod();
    virtualBalances.src = virtualBalanceToAdd[src].current(_decayPeriod, balances.src);
    virtualBalances.src = Math.max(virtualBalances.src, balances.src);
    virtualBalances.dst = virtualBalanceToRemove[dst].current(_decayPeriod, balances.dst);
    virtualBalances.dst = Math.min(virtualBalances.dst, balances.dst);
    src.fadTransferFrom(payable(msg.sender), address(this), amount);
    confirmed = src.getBalanceOf(address(this)).sub(balances.src);
    result = _getQuote(src, dst, confirmed, virtualBalances.src, virtualBalances.dst, fees.fee, fees.slippageFee);
    require(result > 0 && result >= minReturn, "Swap: Return Is Not Enough");
    dst.fadTransfer(receiver, result);

    // Update virtual balances to the same direction only at imbalanced state
    if(virtualBalances.src != balances.src) {
      virtualBalanceToAdd[src].set(virtualBalances.src.add(confirmed));
    }

    if(virtualBalances.dst != balances.dst) {
      virtualBalanceToRemove[dst].set(virtualBalances.dst.sub(result));
    }

    // Update virtual balances to the opposite direction
    virtualBalanceToRemove[src].update(_decayPeriod, balances.src);
    virtualBalanceToAdd[dst].update(_decayPeriod, balances.dst);
  }

  function _mintRewards(uint256 confirmed, uint256 result, address referral, Balances memory balances, Fees memory fees)
    private 
  {
    (
      uint256 referralShare, 
      uint256 governanceShare, 
      address governanceWallet, 
      address feeCollector
    ) = governanceFactory.getShareParameters(); 

    uint256 referralReward;
    uint256 governanceReward;
    uint256 invariantRatio = uint256(1e36);
    invariantRatio = invariantRatio.mul(balances.src.add(confirmed)).div(balances.src);
    invariantRatio = invariantRatio.mul(balances.dst.sub(result)).div(balances.dst);

    if(invariantRatio > 1e36){
      // calculate share only if invariant increased
      invariantRatio = invariantRatio.sqrt();
      uint256 invariantIncrease = totalSupply().mul(invariantRatio.sub(1e18)).div(invariantRatio);
      
      referralReward = (referral != address(0)) ? invariantIncrease.mul(referralShare).div(SwapConstants._FEE_DENOMINATOR) : 0;
      governanceReward = (governanceWallet != address(0)) ? invariantIncrease.mul(governanceShare).div(SwapConstants._FEE_DENOMINATOR) : 0;

      if(feeCollector == address(0)) {
        if(referralReward > 0) {
          _mint(referral, referralReward);
        }

        if(governanceReward > 0) {
          _mint(governanceWallet, governanceReward);
        }
      } else if(referralReward > 0 || governanceReward > 0) {
        uint256 length = (referralReward > 0 ? 1 : 0) + (governanceReward > 0 ? 1 : 0);
        address[] memory wallets = new address[](length);
        uint256[] memory rewards = new uint256[](length);

        wallets[0] = referral;
        rewards[0] = referralReward;
        if(governanceReward > 0) {
          wallets[length - 1] = governanceWallet;
          rewards[length - 1] = governanceReward;
        }

        try IFeeCollector(feeCollector).updateRewards(wallets, rewards) {
          _mint(feeCollector, referralReward.add(governanceReward));
        } catch {
          emit Error("Update Rewards Failed");
        }
      }
    }

    emit Sync(balances.src, balances.dst, fees.fee, fees.slippageFee, referralReward, governanceReward);
  }

  /**
    spot_ret = dx * y / x
    uni_ret = dx * y / (x + dx)
    slippage = (spot_ret - uni_ret) / spot_ret
    slippage = dx * dx * y / (x * (x + dx)) / (dx * y / x)
    slippage = dx / (x + dx)
    ret = uni_ret * (1 - slip_fee * slippage)
    ret = dx * y / (x + dx) * (1 - slip_fee * dx / (x + dx))
    ret = dx * y / (x + dx) * (x + dx - slip_fee * dx) / (x + dx)

    x = amount * denominator
    dx = amount * (denominator - fee)
   */
  function _getQuote(
    IERC20 src, 
    IERC20 dst,
    uint256 amount,
    uint256 srcBalance,
    uint256 dstBalance,
    uint256 fee,
    uint256 slippageFee
  )
    internal
    view
    returns(uint256)
  {
    if(src > dst){
      (src, dst) = (dst, src);
    }

    if(amount > 0 && src == token0 && dst == token1) {
      uint256 taxedAmount = amount.sub(amount.mul(fee).div(SwapConstants._FEE_DENOMINATOR));
      uint256 srcBalancePlusTaxedAmount = srcBalance.add(taxedAmount);
      uint256 ret = taxedAmount.mul(dstBalance).div(srcBalancePlusTaxedAmount);
      uint256 feeNumerator = SwapConstants._FEE_DENOMINATOR.mul(srcBalancePlusTaxedAmount).sub(slippageFee.mul(taxedAmount));
      uint256 feeDenominator = SwapConstants._FEE_DENOMINATOR.mul(srcBalancePlusTaxedAmount);

      return ret.mul(feeNumerator).div(feeDenominator);
    }

    return 0;
  }

  /** Allows contract owner to withdraw funds that was send to contract by mistake */
  function rescueFunds(IERC20 token, uint256 amount)
    external
    nonReentrant
    onlyOwner
  {
    uint256 balance0 = token0.getBalanceOf(address(this));
    uint256 balance1 = token1.getBalanceOf(address(this));

    token.fadTransfer(payable(msg.sender), amount);
    require(token0.getBalanceOf(address(this)) >= balance0, "Swap: Rescue Funds Access Denied");
    require(token1.getBalanceOf(address(this)) >= balance1, "Swap: Rescue Funds Access Denied");
    require(balanceOf(address(this)) >= _BASE_SUPPLY, "Swap: Rescue Funds Access Denied");
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
        }
        _balances[to] += amount;

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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
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
pragma solidity ^0.8.4;

interface IFeeCollector {
  
  /** Adds specified `amount` as reward to `receiver` */
  function updateReward(address receiver, uint256 amount) external;

  function updateRewards(address[] calldata receivers, uint256[] calldata amounts) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library FADERC20 {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  function isBNB(IERC20 token)
    internal
    pure
    returns(bool)
  {
    return address(token) == address(0);
  }

  function getBalanceOf(IERC20 token, address account)
    internal
    view
    returns(uint256)
  {
    if(isBNB(token)){
      return account.balance;
    } else {
      return token.balanceOf(account);
    }
  }

  function fadTransfer(IERC20 token, address payable to, uint256 amount) internal
  {
    if(amount > 0){
      if(isBNB(token)){
        to.transfer(amount);
      } else {
        token.safeTransfer(to, amount);
      }
    }
  }

  function fadTransferFrom(IERC20 token, address payable from, address to, uint256 amount) internal
  {
    if(amount > 0){
      if(isBNB(token)){
        require(msg.value >= amount, "Value Is not Enough");
        require(from == msg.sender, "From Is Not The Sender");
        require(to == address(this), "To Is Not this");
        if(msg.value > amount) {
          //Return the remaining to user
          from.transfer(msg.value.sub(amount));
        }
      } else {
        token.safeTransferFrom(from, to, amount);
      }
    }
  }

  function getSymbol(IERC20 token)
    internal
    view
    returns(string memory)
  {
    if(isBNB(token)){
      return "BNB";
    }

    (bool success, bytes memory data) = address(token).staticcall{ gas: 20000}(
      abi.encodeWithSignature("symbol()")
    );

    if(!success){
      (success, data) =  address(token).staticcall{ gas: 20000}(
        abi.encodeWithSignature("SYMBOL()")
      );
    }

    if(success && data.length >= 96) {
      (uint256 offset, uint256 length) = abi.decode(data, (uint256, uint256));
      if(offset == 0x20 && length > 0 && length <= 256) {
        return string(abi.decode(data, (bytes)));
      }
    }

    if(success && data.length == 32) {
      uint length = 0;
      while (length < data.length && data[length] >= 0x20 && data[length] <= 0x7E) {
        length++;
      }

      if(length > 0) {
        bytes memory result = new bytes(length);
        for(uint i = 0; i < length; i++) {
          result[i] = data[i];
        }
        return string(result);
      }
    }

    return _toHex(address(token));
  }

  function _toHex(address token)
    private
    pure
    returns(string memory)
  {
    return _toHex(abi.encodePacked(token));
  }

  function _toHex(bytes memory data)
    private
    pure
    returns(string memory)
  {
    bytes memory str = new bytes(2 + data.length * 2);
    str[0] = "0";
    str[1] = "x";
    uint j = 2;
    for(uint i = 0; i < data.length; i++) {
      uint a = uint8(data[i]) >> 4;
      uint b = uint8(data[i]) & 0x0f;
      str[j++] = bytes1(uint8(a + 48 + (a/10) * 39));
      str[j++] = bytes1(uint8(b + 48 + (b/10) * 39));
    }

    return string(str);
  }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SQRT {
  
  /** https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method */
  function sqrt(uint256 y) 
    internal
    pure
    returns(uint256)
  {
    if(y > 3) {
      uint256 z = y;
      uint256 x = y / 2 + 1;
      while(x < z) {
        z = x;
        x = (y / x + x) / 2;
      }
      return z;
    } else if (y != 0){
      return 1;
    } else {
      return 0;
    }
  }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./SafeCast.sol";

library VirtualBalance {
  using SafeCast for uint256;
  using SafeMath for uint256;

  struct Data {
    uint216 balance;
    uint40 time;
  }

  function set(VirtualBalance.Data storage self, uint256 balance) internal {
    (self.balance, self.time) = (
      balance.toUint216(),
      block.timestamp.toUint40()
    );
  }

  function update(VirtualBalance.Data storage self, uint256 decayPeriod, uint256 realBalance) internal {
    set(self, current(self, decayPeriod, realBalance));
  }

  function scale(VirtualBalance.Data storage self, uint256 decayPeriod, uint256 realBalance, uint256 num, uint256 denom) internal {
    set(self, current(self, decayPeriod, realBalance).mul(num).add(denom.sub(1)).div(denom));
  }

  function current(VirtualBalance.Data memory self, uint256 decayPeriod, uint256 realBalance) 
    internal 
    view
    returns(uint256)
  {
    uint256 timePassed = Math.min(decayPeriod, block.timestamp.sub(self.time));
    uint256 timeRemain = decayPeriod.sub(timePassed);
    return uint256(self.balance).mul(timeRemain).add(
      realBalance.mul(timePassed)
    ).div(decayPeriod);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IGovernanceFactory.sol";
import "../lib/LiquidVoting.sol";
import "../lib/SwapConstants.sol";
import "../lib/SafeCast.sol";


/*
* Swap governance
*/
abstract contract Governance is ERC20, Ownable, ReentrancyGuard {
  using Vote for Vote.Data;
  using LiquidVoting for LiquidVoting.Data;
  using VirtualVote for VirtualVote.Data;
  using SafeCast for uint256;
  using SafeMath for uint256;

  event FeeVoteUpdated(address indexed user, uint256 fee, bool isDefault, uint256 amount);
  event SlippageFeeVoteUpdated(address indexed user, uint256 slippageFee, bool isDefault, uint256 amount);
  event DecayPeriodUpdated(address indexed user, uint256 decayPeriod, bool isDefault, uint256 amount);

  IGovernanceFactory public governanceFactory; 
  LiquidVoting.Data private _fee;
  LiquidVoting.Data private _slippageFee;
  LiquidVoting.Data private _decayPeriod;

  constructor(IGovernanceFactory _governanceFactory)
  {
    governanceFactory = _governanceFactory;
    _fee.data.result = _governanceFactory.getDefaultFee().toUint104();
    _slippageFee.data.result = _governanceFactory.getDefaultSlippageFee().toUint104();
    _decayPeriod.data.result = _governanceFactory.getDefaultDecayPeriod().toUint104();
  }

  function setGovernanceFactory(IGovernanceFactory _governanceFactory)
    external
    onlyOwner
  {
    governanceFactory = _governanceFactory;
    this.discardFeeVote();
    this.discardSlippageFeeVote();
    this.discardDecayPeriodVote();
  }

  /** Return the current fee */
  function getFee()
    public
    view
    returns(uint256)
  {
    return _fee.data.result;
  }

  /** Return the current slippage fee */
  function getSlippageFee()
    public
    view
    returns(uint256)
  {
    return _slippageFee.data.result;
  }

  /** Return the current decay period */
  function getDecayPeriod()
    public
    view
    returns(uint256)
  {
    return _decayPeriod.data.result;
  }

  function getVirtualFee()
    external
    view
    returns(uint104, uint104, uint48)
  {
    return (_fee.data.oldResult, _fee.data.result, _fee.data.time);
  }

  function getVirtualSlippageFee()
    external
    view
    returns(uint104, uint104, uint48)
  {
    return (_slippageFee.data.oldResult, _slippageFee.data.result, _slippageFee.data.time);
  }

  function getVirtualDecayPeriod()
    external
    view
    returns(uint104, uint104, uint48)
  {
    return (_decayPeriod.data.oldResult, _decayPeriod.data.result, _decayPeriod.data.time);
  }

  /** Return the user vote for the preferred fee */
  function getUserFeeVote(address user)
    external
    view
    returns(uint256)
  {
    return _fee.votes[user].get(governanceFactory.getDefaultFee());
  }

  /** Return the user vote for the preferred slippage fee */
  function getUserSlippageFeeVote(address user)
    external
    view
    returns(uint256)
  {
    return _slippageFee.votes[user].get(governanceFactory.getDefaultSlippageFee());
  }

  /** Return the user vote for the preferred decay period */
  function getUserDecayPeriodVote(address user)
    external
    view
    returns(uint256)
  {
    return _decayPeriod.votes[user].get(governanceFactory.getDefaultDecayPeriod());
  }

  /** Records `msg.senders`'s vote for fee */
  function voteFee(uint256 vote) external
  {
    require(vote <= SwapConstants._MAX_FEE, "Fee Vote Is Too High");
    _fee.updateVote(
      msg.sender, 
      _fee.votes[msg.sender], 
      Vote.init(vote), 
      balanceOf(msg.sender), 
      totalSupply(), 
      governanceFactory.getDefaultFee(), 
      _emitVoteFeeUpdate
    );
  }

  /** Records `msg.senders`'s vote for slippage fee */
  function voteSlippageFee(uint256 vote) external
  {
    require(vote <= SwapConstants._MAX_SLIPPAGE_FEE, "Slippage Fee Vote Is Too High");
    _slippageFee.updateVote(
      msg.sender, 
      _slippageFee.votes[msg.sender], 
      Vote.init(vote), 
      balanceOf(msg.sender), 
      totalSupply(), 
      governanceFactory.getDefaultSlippageFee(), 
      _emitVoteSlippageFeeUpdate
    );
  }

  /** Records `msg.senders`'s vote for decay period */
  function voteDecayPeriod(uint256 vote) external
  {
    require(vote <= SwapConstants._MAX_DECAY_PERIOD, "Decay Period Vote Is Too High");
    require(vote >= SwapConstants._MIN_DECAY_PERIOD, "Decay Period Vote Is Too Low");
    _decayPeriod.updateVote(
      msg.sender, 
      _decayPeriod.votes[msg.sender], 
      Vote.init(vote), 
      balanceOf(msg.sender), 
      totalSupply(), 
      governanceFactory.getDefaultDecayPeriod(), 
      _emitVoteDecayPeriodUpdate
    );
  }

  /** Retracts `msg.senders`'s vote for fee */
  function discardFeeVote() external
  {
    _fee.updateVote(
      msg.sender, 
      _fee.votes[msg.sender], 
      Vote.init(), 
      balanceOf(msg.sender), 
      totalSupply(), 
      governanceFactory.getDefaultFee(), 
      _emitVoteFeeUpdate
    );
  }

  /** Retracts `msg.senders`'s vote for slippage fee */
  function discardSlippageFeeVote() external
  {
    _slippageFee.updateVote(
      msg.sender, 
      _slippageFee.votes[msg.sender], 
      Vote.init(), 
      balanceOf(msg.sender), 
      totalSupply(), 
      governanceFactory.getDefaultSlippageFee(), 
      _emitVoteSlippageFeeUpdate
    );
  }

  /** Retracts `msg.senders`'s vote for decay period */
  function discardDecayPeriodVote() external
  {
    _decayPeriod.updateVote(
      msg.sender, 
      _decayPeriod.votes[msg.sender], 
      Vote.init(), 
      balanceOf(msg.sender), 
      totalSupply(), 
      governanceFactory.getDefaultDecayPeriod(), 
      _emitVoteDecayPeriodUpdate
    );
  }

  function _emitVoteFeeUpdate(address user, uint256 fee, bool isDefault, uint256 amount) private
  {
    emit FeeVoteUpdated(user, fee, isDefault, amount);
  }

  function _emitVoteSlippageFeeUpdate(address user, uint256 slippageFee, bool isDefault, uint256 amount) private
  {
    emit SlippageFeeVoteUpdated(user, slippageFee, isDefault, amount);
  }

  function _emitVoteDecayPeriodUpdate(address user, uint256 decayPeriod, bool isDefault, uint256 amount) private
  {
    emit DecayPeriodUpdated(user, decayPeriod, isDefault, amount);
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    override
  {
    if(from == to) {
      return;
    }

    IGovernanceFactory _governanceFactory = governanceFactory;
    bool updateFrom = !(from == address(0) || _governanceFactory.isFeeCollector(from));
    bool updateTo = !(to == address(0) || _governanceFactory.isFeeCollector(to));

    if(!updateFrom && !updateTo) {
      // mint to feeReceiver or burn from feeReceiver
      return;
    }

    uint256 balanceFrom = (from != address(0)) ? balanceOf(from) : 0;
    uint256 balanceTo = (to != address(0)) ? balanceOf(to) : 0;
    uint256 newTotalSupply = totalSupply()
                              .add(from == address(0) ? amount : 0)
                              .sub(to == address(0) ? amount : 0);

    ParamsHelper memory params = ParamsHelper({
      from: from,
      to: to,
      updateFrom: updateFrom,
      updateTo: updateTo,
      amount: amount,
      balanceFrom: balanceFrom,
      balanceTo: balanceTo,
      newTotalSupply: newTotalSupply
    });

    (uint256 defaultFee, uint256 defaultSlippageFee, uint256 defaultDecayPeriod) = _governanceFactory.defaults();

    _updateOntransfer(params, defaultFee, _emitVoteFeeUpdate, _fee);
    _updateOntransfer(params, defaultSlippageFee, _emitVoteSlippageFeeUpdate, _slippageFee);
    _updateOntransfer(params, defaultDecayPeriod, _emitVoteDecayPeriodUpdate, _decayPeriod);
  }

  struct ParamsHelper {
    address from;
    address to;
    bool updateFrom;
    bool updateTo;
    uint256 amount;
    uint256 balanceFrom;
    uint256 balanceTo;
    uint256 newTotalSupply;
  }

  function _updateOntransfer(
    ParamsHelper memory params, 
    uint256 defaultValue,
    function(address, uint256, bool, uint256) internal emitEvent,
    LiquidVoting.Data storage votingData
  ) private
  {
    Vote.Data memory voteFrom = votingData.votes[params.from];
    Vote.Data memory voteTo = votingData.votes[params.to];
    if(voteFrom.isDefault() && voteTo.isDefault() && params.updateFrom && params.updateTo) {
      emitEvent(params.from, voteFrom.get(defaultValue), true, params.balanceFrom.sub(params.amount));
      emitEvent(params.to, voteTo.get(defaultValue), true, params.balanceTo.add(params.amount));
      return;
    }

    if(params.updateFrom) {
      votingData.updateBalance(
        params.from, 
        voteFrom, 
        params.balanceFrom, 
        params.balanceFrom.sub(params.amount), 
        params.newTotalSupply, 
        defaultValue, 
        emitEvent
      );
    }

    if(params.updateTo) {
      votingData.updateBalance(
        params.to, 
        voteTo, 
        params.balanceTo, 
        params.balanceTo.add(params.amount), 
        params.newTotalSupply, 
        defaultValue, 
        emitEvent
      );
    }
  }

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SafeCast {
  
  function toUint216(uint256 value) 
    internal
    pure
    returns(uint216)
  {
    require(value < 2**216, "value does not fit in 216 bits");
    return uint216(value);
  }

  function toUint104(uint256 value) 
    internal
    pure
    returns(uint104)
  {
    require(value < 2**104, "value does not fit in 104 bits");
    return uint104(value);
  }

  function toUint48(uint256 value) 
    internal
    pure
    returns(uint48)
  {
    require(value < 2**48, "value does not fit in 48 bits");
    return uint48(value);
  }

  function toUint40(uint256 value) 
    internal
    pure
    returns(uint40)
  {
    require(value < 2**40, "value does not fit in 40 bits");
    return uint40(value);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** Describes methods that provide all the information about current governance contract state */
interface IGovernanceFactory {
  
  /** Returns information about mooniswap shares */
  function getShareParameters()
    external 
    view 
    returns(uint256, uint256, address, address);

    /** Initial settings that contract was created */
    function defaults()
    external 
    view 
    returns(uint256, uint256, uint256);

    /** Returns the value of default fee */
    function getDefaultFee()
    external 
    view 
    returns(uint256);

    /** Returns the value of default slippage fee */
    function getDefaultSlippageFee()
    external 
    view 
    returns(uint256);

    /** Returns the value of default decay period */
    function getDefaultDecayPeriod()
    external 
    view 
    returns(uint256);

    /** Returns previous default fee that had place, 
    * current one and time on which this changed 
    */
    function getVirtualDefaultFee()
    external 
    view 
    returns(uint104, uint104, uint48);

    /** Returns previous default slippage fee that had place, 
    * current one and time on which this changed 
    */
    function getVirtualDefaultSlippageFee()
    external 
    view 
    returns(uint104, uint104, uint48);

    /** Returns previous default decay period that had place, 
    * current one and time on which this changed 
    */
    function getVirtualDefaultDecayPeriod()
    external 
    view 
    returns(uint104, uint104, uint48);

    /** Returns the value of referral share */
    function getReferralShare()
    external 
    view 
    returns(uint256);

    /** Returns the value of governance share */
    function getGovernanceShare()
    external 
    view 
    returns(uint256);

    /** Returns the value of governance wallet address */
    function governanceWallet()
    external 
    view 
    returns(address);

    /** Returns the value of fee collector wallet address */
    function feeCollector()
    external 
    view 
    returns(address);

    /** Whether the address is current fee collector or was in the past. */
    function isFeeCollector(address)
    external 
    view 
    returns(bool);

    /** Whether the contract is currently working and wasn't stopped. */
    function isActive()
    external 
    view 
    returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./SafeCast.sol";
import "./VirtualVote.sol";
import "./Vote.sol";


library LiquidVoting {
  using SafeMath for uint256;
  using SafeCast for uint256;
  using Vote for Vote.Data;
  using VirtualVote for VirtualVote.Data;

  struct Data {
    VirtualVote.Data data;
    uint256 weightedSum;
    uint256 defaultVote;
    mapping(address => Vote.Data) votes;
  }

  function updateVote(
    LiquidVoting.Data storage self,
    address user,
    Vote.Data memory oldVote,
    Vote.Data memory newVote,
    uint256 balance,
    uint256 totalSupply,
    uint256 defaultVote,
    function(address, uint256, bool, uint256) emitEvent
  ) internal {
    return _update(self, user, oldVote, newVote, balance, balance, totalSupply, defaultVote, emitEvent);
  }

  function updateBalance(
    LiquidVoting.Data storage self,
    address user,
    Vote.Data memory oldVote,
    uint256 oldBalance,
    uint256 newBalance,
    uint256 newTotalSupply,
    uint256 defaultVote,
    function(address, uint256, bool, uint256) emitEvent
  ) internal {
    return _update(self, user, oldVote, newBalance == 0 ? Vote.init() : oldVote, oldBalance, newBalance, newTotalSupply, defaultVote, emitEvent);
  }

  function _update(
    LiquidVoting.Data storage self,
    address user,
    Vote.Data memory oldVote,
    Vote.Data memory newVote,
    uint256 oldBalance,
    uint256 newBalance,
    uint256 totalSupply,
    uint256 defaultVote,
    function(address, uint256, bool, uint256) emitEvent
  ) internal {
    uint256 oldWeightedSum = self.weightedSum;
    uint256 newWeightedSum = oldWeightedSum;
    uint256 oldDefaultVote = self.defaultVote;
    uint256 newDefaultVote = oldDefaultVote;

    if(oldVote.isDefault()) {
      newDefaultVote = newDefaultVote.sub(oldBalance);
    } else {
      newWeightedSum = newWeightedSum.sub(oldBalance.mul(oldVote.get(defaultVote)));
    }

    if(newVote.isDefault()) {
      newDefaultVote = newDefaultVote.add(oldBalance);
    } else {
      newWeightedSum = newWeightedSum.add(newBalance.mul(newVote.get(defaultVote)));
    }

    if(newWeightedSum != oldWeightedSum){
      self.weightedSum = newWeightedSum;
    }

    if(newDefaultVote != oldDefaultVote){
      self.defaultVote = newDefaultVote;
    }

    {
      uint256 newResult = totalSupply == 0 ? defaultVote : newWeightedSum.add(newDefaultVote.mul(defaultVote)).div(totalSupply);
      VirtualVote.Data memory data = self.data;
      if(newResult != data.result){
        VirtualVote.Data memory sdata = self.data;
        (sdata.oldResult, sdata.result, sdata.time) = (
          data.current().toUint104(),
          newResult.toUint104(),
          block.timestamp.toUint48()
        );
      }
    }

    if(!newVote.eq(oldVote)){
      self.votes[user] = newVote;
    }

    emitEvent(user, newVote.get(defaultVote), newVote.isDefault(), newBalance);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SwapConstants {
  
  uint256 internal constant _FEE_DENOMINATOR = 1e18;

  uint256 internal constant _MIN_REFERRAL_SHARE = 0.05e18; // 5%
  uint256 internal constant _MIN_DECAY_PERIOD = 1 minutes;

  uint256 internal constant _MAX_FEE = 0.01e18; // 1%
  uint256 internal constant _MAX_SLIPPAGE_FEE = 1e18; // 100%
  uint256 internal constant _MAX_SHARE = 0.1e18; // 10%
  uint256 internal constant _MAX_DECAY_PERIOD = 5 minutes;

  uint256 internal constant _DEFAULT_FEE = 0;
  uint256 internal constant _DEFAULT_SLIPPAGE_FEE = 1e18; // 100%
  uint256 internal constant _DEFAULT_REFERRAL_SHARE = 0.1e18; // 10%
  uint256 internal constant _DEFAULT_GOVERNANCE_SHARE = 0;
  uint256 internal constant _DEFAULT_DECAY_PERIOD = 1 minutes;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


library VirtualVote {
  using SafeMath for uint256;

  uint256 private constant _VOTE_DECAY_PERIOD = 1 days;

  struct Data {
    uint104 oldResult;
    uint104 result;
    uint48 time;
  }

  function current(VirtualVote.Data memory self) 
    internal 
    view
    returns(uint256)
  {
    uint256 timePassed = Math.min(_VOTE_DECAY_PERIOD, block.timestamp.sub(self.time));
    uint256 timeRemain = _VOTE_DECAY_PERIOD.sub(timePassed);
    return uint256(self.oldResult).mul(timeRemain).add(
      uint256(self.result).mul(timePassed)
    ).div(_VOTE_DECAY_PERIOD);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Vote {

  uint256 private constant _VOTE_DECAY_PERIOD = 1 days;

  struct Data {
    uint256 value;
  }

  function eq(Vote.Data memory self, Vote.Data memory vote) 
    internal 
    pure
    returns(bool)
  {
    return self.value == vote.value;
  }

  function init() 
    internal 
    pure
    returns(Vote.Data memory data)
  {
    return Vote.Data({
      value: 0
    });
  }

  function init(uint256 vote) 
    internal 
    pure
    returns(Vote.Data memory data)
  {
    return Vote.Data({
      value: vote + 1
    });
  }

  function isDefault(Data memory self) 
    internal 
    pure
    returns(bool)
  {
    return self.value == 0;
  }

  function get(Data memory self, uint256 defaultVote) 
    internal 
    pure
    returns(uint256)
  {
    if(self.value > 0){
      return self.value - 1;
    }

    return defaultVote; 
  }

  function get(Data memory self, function () external view returns(uint256) defaultVoteFn) 
    internal 
    view
    returns(uint256)
  {
    if(self.value > 0){
      return self.value - 1;
    }

    return defaultVoteFn();
    
  }

}