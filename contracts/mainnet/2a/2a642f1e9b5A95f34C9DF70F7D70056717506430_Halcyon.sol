/*
██   ██  █████  ██       ██████ ██    ██  ██████  ███    ██
██   ██ ██   ██ ██      ██       ██  ██  ██    ██ ████   ██
███████ ███████ ██      ██        ████   ██    ██ ██ ██  ██
██   ██ ██   ██ ██      ██         ██    ██    ██ ██  ██ ██
██   ██ ██   ██ ███████  ██████    ██     ██████  ██   ████

LOYALTY   PROPERITY   CARE

https://halcyoninitiative.com
https://t.me/HalcyonInitiative official chat
https://t.me/halcyontoken announcements
https://t.me/HalcyonInitiativeSupport (app support)
https://t.me/HalcyonCCbot (token checker service)
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

import "../features/Deflationary.sol";
import "../features/Airdroppable.sol";

contract Halcyon is Deflationary, AirDroppable
{
  string constant NAME_ = "Halcyon Initiative";
  string constant SYMBOL_ = "HALCYON";
  uint256 constant DECIMALS_ = 18;
  uint256 constant TOKENSUPPLY_ = 10 ** 9;
  
  
  constructor() ERC20(NAME_, SYMBOL_, DECIMALS_, TOKENSUPPLY_)
  {
    ERC20._mint(_msgSender(), ERC20.totalSupply());
  }
  
  
  function sendAirDrops() external override onlyOwner
  {
    require(_airdropEnabled, "AirDrops are disabled.");
    
    address marketingVault = getVaultByName("Marketing").wallet;
    require(marketingVault != address(0), "Marketing Vault not set.");
    require(ERC20.balanceOf(marketingVault) > 0, "AirDrops are depleted.");
    
    for (uint256 i = 0; i < _accounts.length;)
    {
      address account = _accounts[i];
      
      uint256 amount = _airdrops[account];
      
      if (amount > 0)
      {
        _distributedAirdrops += amount;
        _airdrops[account] = 0;
        
        ERC20._transfer(marketingVault, account, amount);
      }
      
      _accounts[i] = _accounts[_accounts.length - 1];
      _accounts.pop();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

import "../vendor/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ERC20.sol";
import "./Vaultable.sol";
//import "hardhat/console.sol";

abstract contract Deflationary is ERC20, Vaultable
{
  using SafeMath for uint256;
  
  uint256 private $reflection;
  uint256 private $burn;
  uint256 private $liquify;
  uint256 private $distribution;
  uint256 private $maxTransferAmount;
  mapping(address => bool) private _taxable;
  uint256 private $minimumTotalSupply = 10 ** 7 * (10 ** ERC20._decimals);
  
  event MaxTransferSet(uint256 current, uint256 previous);
  event BurnRateSet(uint256 current, uint256 previous);
  event ReflectionRateSet(uint256 current, uint256 previous);
  event LiquifyRateSet(uint256 current, uint256 previous);
  event FeesProcessed(uint256 amount);
  
  error overMaxBalance(uint256 balance, uint256 max);
  
  
  receive() external payable {}
  
  
  function balanceOf(address account) public view virtual override returns (uint256)
  {
    if (account == address(this) || account == address(1))
      return _balances[account];
    
    if (!_taxable[account] && $distribution > 0)
      return reflection(_balances[account]);
    
    return _balances[account];
  }
  
  
  /**
   * @dev
   *
   * proportional staking rewards to non-taxable holders of tokens collected by $reflection tax in deflate()
   */
  function reflection(uint256 amount) private view returns (uint256)
  {
    if (amount == 0)
      return 0;
    
    uint256 $staking = amount.mul($distribution).div(_totalSupply);
    
    return amount + $staking;
  }
  
  
  /**
   * @dev
   *
   * Owner can not receive tokens!
   * No tax fees on buying and regular transfers in+out!
   * +On selling: collect and process fees until $minimumTotalSupply is reached
   *
   * @notice custom error uses less gas compared to require()
   */
  function _transfer(address sender, address recipient, uint256 amount) internal override
  {
    require(sender != address(0) && recipient != address(0) && recipient != owner(),
      "!Sender|Recipient.");
    
    require(amount > 0, "Amount is zero.");
    
    uint256 senderBalance = balanceOf(sender);
    require(senderBalance >= amount, "Amount gt balance.");
    
    uint256 $amountToReceive = amount;
    {
      if (_taxable[recipient] && ERC20._totalSupply > $minimumTotalSupply)
      {
        $amountToReceive = deflate(sender, amount);
        
        if (amount > $amountToReceive)
          _balances[address(this)] += amount.mul($liquify + fees).div(10 ** 2);
        
        processFees(recipient);
      }
      
      _balances[sender] = senderBalance.sub(amount);
      _balances[recipient] += $amountToReceive;
      
      if (!_taxable[recipient])
        if ($maxTransferAmount > 0 && _balances[recipient] > $maxTransferAmount)
          revert overMaxBalance(
          {
          balance : _balances[recipient],
          max : $maxTransferAmount
          });
    }
    
    emit Transfer(sender, recipient, $amountToReceive);
  }
  
  
  function deflate(address sender, uint256 amount) private returns (uint256)
  {
    if (sender == owner() || sender == address(this))
      return amount;
    
    uint256 $tax = 0;
    uint256 $taxAmount = 0;
    uint256 $amountToReceive = amount;
    
    
    if (($reflection + $burn + $liquify + fees) > 0)
    {
      if ($reflection > 0)
        $tax += $reflection;
      if ($burn > 0)
        $tax += $burn;
      if ($liquify > 0)
        $tax += $liquify;
      if (fees > 0)
        $tax += fees;
      
      $taxAmount = amount.mul($tax).div(10 ** 2);
      $amountToReceive = amount.sub($taxAmount);
      
      if ($burn > 0)
      {
        uint256 burnt = amount.mul($burn).div(10 ** 2);
        
        ERC20._totalSupply = ERC20._totalSupply.sub(burnt);
        ERC20._transfer(sender, address(1), burnt);
      }
      
      $distribution += amount.mul($reflection).div(10 ** 2);
    }
    
    return $amountToReceive;
  }
  
  
  /**
   * @dev
   * @param recipient - LP contracts only!
   * Tax fees only on selling!
   * A taxable recipient receives amount minus tax fees, non-taxable recipients (everyone else including this contract!) has max wallet restriction!
   * All LP contracts are recipient on sells and need to be set as _taxable before creating LP.
   * Do not set any contract/wallet besides LP contracts as taxable!
   */
  function setTaxable(address recipient, bool state) external onlyOwner
  {
    _taxable[recipient] = state;
  }
  
  
  /**
   * @dev
   *
   * Burn the tokens collected by $liquify tax.
   * Lowers X in X*Y=K
   *
   * +Vaults are receiving their token share
   * e.g. Marketing, Development vaults
   */
  function processFees(address pair) private
  {
    uint256 amount = _balances[address(this)];
    
    if (amount < ERC20._totalSupply.div(10 ** 2)) return;
    
    uint256 vaultAllocation = fees.mul(amount).div(fees + $liquify);
    
    for (uint256 i = 0; i < _vaults.length; i++)
    {
      Vault memory $vault = getVaultByAddress(_vaults[i]);
      
      uint256 $vaultAmount = $vault.reflection.mul(vaultAllocation).div(fees);
      amount = amount.sub($vaultAmount);
      
      _balances[$vault.wallet] += $vaultAmount;
      _balances[address(this)] = _balances[address(this)].sub($vaultAmount);
    }
    
    {
      _balances[pair] = _balances[pair].sub(amount);
      _balances[address(1)] += amount;
      
      ERC20._totalSupply = ERC20._totalSupply.sub(amount);
      
      //deflation ends
      if (ERC20._totalSupply < $minimumTotalSupply)
        ERC20._totalSupply = $minimumTotalSupply;
    }
    
    emit FeesProcessed(amount);
  }
  
  
  /**
   * @dev
   *
   * divisor is number of wallets holding the set max.
   * e.g. 20 wallets of 5% TOKENSUPPLY. 200 of 0.5%
   * Note: burn address max wallet amount applies only to third party transfers.
   */
  function setMaxWallets(uint256 divisor) external onlyOwner
  {
    require(divisor >= 20, "Divisor must be gte 20 (=5% of TOKENSUPPLY).");
    uint256 previous = $maxTransferAmount;
    $maxTransferAmount = ERC20.TOKENSUPPLY.div(divisor);
    
    emit MaxTransferSet($maxTransferAmount, previous);
  }
  
  
  /**
   * @dev
   *
   * - contract does not implement ERC20Burnable
   * - tokens are sent to address(1)
   * - transfer() rejects address(0) which is a required check.
   */
  function setBurnRate(uint256 amount) external onlyOwner
  {
    require(amount <= 10, "Max burn rate must be lte 10%.");
    uint256 previous = $burn;
    $burn = amount;
    
    emit BurnRateSet($burn, previous);
  }
  
  
  function setReflectionRate(uint256 amount) external onlyOwner
  {
    require(amount <= 10, "Max staking rate must be lte 10%.");
    uint256 previous = $reflection;
    $reflection = amount;
    
    emit ReflectionRateSet($reflection, previous);
  }
  
  
  function setLiquifyRate(uint256 amount) external onlyOwner
  {
    require(amount <= 10, "Max liquify rate must be lte 10%.");
    uint256 previous = $liquify;
    $liquify = amount;
    
    emit LiquifyRateSet($liquify, previous);
  }
  
  
  /**
   * @notice
   *
   * Recover WETH sent to the contract by accident, back to the sender. On request only!
   */
  function sendWeth(address to, uint256 amount) external onlyOwner
  {
    require(to != address(0), "Transfer to zero address.");
    payable(to).transfer(amount);
  }
  
  
  /**
   * @notice
   *
   * Sends tokens sent by accident back to the sender on request!
   * Only common tokens with a long standing history are considered!
   */
  function sendTokens(address token, address to, uint256 amount) external onlyOwner returns (bool success)
  {
    success = IERC20(token).transfer(to, amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

import "../vendor/@openzeppelin/contracts/access/Ownable.sol";

abstract contract AirDroppable is Ownable
{
  mapping(address => uint256) internal _airdrops;
  address[] internal _accounts;
  bool internal _airdropEnabled;
  uint256 internal _distributedAirdrops;
  
  event AirDrop(uint256 amount, address[] accounts);
  event SwitchAirDrop(bool status);
  
  
  /**
   * @dev
   *
   * - abstract, implementation in base contract
   */
  function sendAirDrops() external virtual;
  
  
  function switchAirDrop(bool mode) external onlyOwner
  {
    require(mode != _airdropEnabled, "AirDrop mode already set.");
    
    _airdropEnabled = mode;
    emit SwitchAirDrop(_airdropEnabled);
  }
  
  
  function setAirDrop(address[] memory accounts, uint256 amount) external onlyOwner
  {
    for (uint256 i = 0; i < accounts.length; i++)
    {
      address account = accounts[i];
      
      _airdrops[account] += amount;
      _accounts.push(account);
    }
    
    emit AirDrop(amount, accounts);
  }
  
  
  function unsetAirDrop(address account) external onlyOwner
  {
    _airdrops[account] = 0;
    
    address[] memory accounts = new address[](1);
    accounts[0] = account;
    
    emit AirDrop(0, accounts);
  }
  
  
  function getDistributedAirDrops() external view returns (uint256)
  {
    return _distributedAirdrops;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;

library SafeMath {
  
  function sub(uint256 a, uint256 b) internal pure returns (uint256)
  {
  unchecked
  {
    require(b <= a, 'SafeMath.sub(): negative result.');
    return a - b;
  }
  }
  
  
  function mul(uint256 a, uint256 b) internal pure returns (uint256)
  {
    return a * b;
  }
  
  
  function div(uint256 a, uint256 b) internal pure returns (uint256)
  {
  unchecked
  {
    require(b > 0, 'SafeMath.div(): division by zero.');
    return a / b;
  }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

import "../vendor/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../vendor/@openzeppelin/contracts/utils/Context.sol";
import "../vendor/@openzeppelin/contracts/access/Ownable.sol";
import "../vendor/@openzeppelin/contracts/utils/math/SafeMath.sol";
//import "hardhat/console.sol";

contract ERC20 is Context, IERC20, IERC20Metadata, Ownable
{
  using SafeMath for uint256;
  
  mapping(address => uint256) internal _balances;
  mapping(address => mapping(address => uint256)) internal _allowances;
  
  string internal _name;
  string internal _symbol;
  uint256 internal _decimals;
  uint256 internal _totalSupply;
  uint256 internal TOKENSUPPLY;
  
  constructor(string memory name_, string memory symbol_, uint256 decimals_,
    uint256 totalSupply_)
  {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
    TOKENSUPPLY = _totalSupply = totalSupply_ * (10 ** decimals_);
  }
  
  
  // IERC20Metadata
  function name() external view virtual override returns (string memory)
  {
    return _name;
  }
  
  function symbol() external view virtual override returns (string memory)
  {
    return _symbol;
  }
  
  function decimals() external view virtual override returns (uint256)
  {
    return _decimals;
  }
  
  
  // IERC20
  function totalSupply() public view override returns (uint256)
  {
    return _totalSupply;
  }
  
  function balanceOf(address account) public view virtual override returns (uint256)
  {
    return _balances[account];
  }
  
  function transfer(address recipient, uint256 amount) external override returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  
  function allowance(address sender, address spender) external view override returns (uint256)
  {
    return _allowances[sender][spender];
  }
  
  
  // ERC20
  function approve(address spender, uint256 amount) external override returns (bool)
  {
    //save gas (non standard ECR20!)
    if (amount != 0 && _allowances[_msgSender()][spender] >= amount)
      return true;
    
    _approve(_msgSender(), spender, amount);
    return true;
  }
  
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool)
  {
    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "Transfer amount exceeds allowance");
    
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), currentAllowance.sub(amount));
    
    return true;
  }
  
  function _transfer(address sender, address recipient, uint256 amount) internal virtual
  {
    require(sender != address(0) && recipient != address(0), "Transfer from/to zero address.");
    require(amount > 0, "Transfer amount is zero.");
    
    uint256 senderBalance = balanceOf(sender);
    require(senderBalance >= amount, "Amount too high.");
    
    _balances[sender] = senderBalance.sub(amount);
    _balances[recipient] += amount;
    
    emit Transfer(sender, recipient, amount);
  }
  
  function _mint(address account, uint256 amount) internal
  {
    require(account != address(0), "Mint to zero address");
    
    //_totalSupply set in constructor, _mint() is used once.
    
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }
  
  function _approve(address sender, address spender, uint256 amount) internal
  {
    require(sender != address(0) && spender != address(0), "Approve zero address.");
    
    _allowances[sender][spender] = amount;
    
    emit Approval(sender, spender, amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

import "../vendor/@openzeppelin/contracts/access/Ownable.sol";
import "../vendor/@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract Vaultable is Ownable
{
  using SafeMath for uint256;
  
    struct Vault {
        string name;
        address wallet;
        uint256 reflection;
        bool exists;
    }

    mapping(string => Vault) internal byName;
    mapping(address => Vault) internal byAddress;
    address[] internal _vaults;
    uint256 internal fees;

    event VaultAdded(address vault, string name);
    event VaultRemoved(address vault, string name);


    function setVault(string memory name, address vault, uint256 reflection) external onlyOwner
    {
        require(!byAddress[vault].exists, "Already in vaults.");
        require(reflection <= 3, "Vault fee cannot exceed 3%.");
        require(_vaults.length <= 5, "Total vaults cannot exceed 5.");

        fees += reflection;
        Vault memory _vault = Vault(name, vault, reflection, true);
        byAddress[vault] = _vault;
        byName[name] = _vault;

        _vaults.push(vault);

        emit VaultAdded(vault, name);
    }

  
    function getVaultByAddress(address vault) internal view returns (Vault memory)
    {
        return byAddress[vault];
    }

  
    function getVaultByName(string memory name) internal view returns (Vault memory)
    {
        return byName[name];
    }

  
    function removeVault(address vault) external onlyOwner
    {
        require(byAddress[vault].exists, "Vault does not exist.");

        uint256 fee = byAddress[vault].reflection;
        string memory name = byAddress[vault].name;
        fees = fees.sub(fee);
        delete byAddress[vault];
        delete byName[name];

        for (uint256 i = 0; i < _vaults.length; i++)
        {
            if (_vaults[i] == vault)
            {
                _vaults[i] = _vaults[_vaults.length - 1];
                _vaults.pop();
                break;
            }
        }

        emit VaultRemoved(vault, name);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;

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
    function decimals() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;

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
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;

import "../utils/Context.sol";

abstract contract Ownable is Context
{
  address private _owner;
  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
  constructor()
  {
    _owner = _msgSender();
    
    emit OwnershipTransferred(address(0), _owner);
  }
  
  function owner() public view virtual returns (address)
  {
    return _owner;
  }
  
  modifier onlyOwner()
  {
    require(_owner == _msgSender(), "Not the owner.");
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;

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