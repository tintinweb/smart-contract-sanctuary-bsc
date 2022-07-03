/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

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

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20Metadata is IBEP20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

contract BEP20 is Context, IBEP20, IBEP20Metadata {
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 10;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    public
    virtual
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
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(
      currentAllowance >= amount,
      "BEP20: transfer amount exceeds allowance"
    );
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender] + addedValue
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(
      currentAllowance >= subtractedValue,
      "BEP20: decreased allowance below zero"
    );
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _beforeTokenTransfer(sender, recipient, amount);

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
    unchecked {
      _balances[sender] = senderBalance - amount;
    }
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);

    _afterTokenTransfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "BEP20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "BEP20: burn from the zero address");

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);

    _afterTokenTransfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    _setOwner(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(
      owner() == _msgSender(),
      "Only admin can do this! and You are not the owner"
    );
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _setOwner(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownership has been transferred");
    _setOwner(newOwner);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      uint256 c = a + b;
      if (c < a) return (false, 0);
      return (true, c);
    }
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b > a) return (false, 0);
      return (true, a - b);
    }
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (a == 0) return (true, 0);
      uint256 c = a * b;
      if (c / a != b) return (false, 0);
      return (true, c);
    }
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a / b);
    }
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a % b);
    }
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

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

library Clones {
  function clone(address implementation) internal returns (address instance) {
    assembly {
      let ptr := mload(0x40)
      mstore(
        ptr,
        0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
      )
      mstore(add(ptr, 0x14), shl(0x60, implementation))
      mstore(
        add(ptr, 0x28),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )
      instance := create(0, ptr, 0x37)
    }
    require(instance != address(0), "BEP1167: create failed");
  }

  function cloneDeterministic(address implementation, bytes32 salt)
    internal
    returns (address instance)
  {
    assembly {
      let ptr := mload(0x40)
      mstore(
        ptr,
        0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
      )
      mstore(add(ptr, 0x14), shl(0x60, implementation))
      mstore(
        add(ptr, 0x28),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )
      instance := create2(0, ptr, 0x37, salt)
    }
    require(instance != address(0), "BEP1167: create2 failed");
  }

  function predictDeterministicAddress(
    address implementation,
    bytes32 salt,
    address deployer
  ) internal pure returns (address predicted) {
    assembly {
      let ptr := mload(0x40)
      mstore(
        ptr,
        0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
      )
      mstore(add(ptr, 0x14), shl(0x60, implementation))
      mstore(
        add(ptr, 0x28),
        0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000
      )
      mstore(add(ptr, 0x38), shl(0x60, deployer))
      mstore(add(ptr, 0x4c), salt)
      mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
      predicted := keccak256(add(ptr, 0x37), 0x55)
    }
  }

  function predictDeterministicAddress(address implementation, bytes32 salt)
    internal
    view
    returns (address predicted)
  {
    return predictDeterministicAddress(implementation, salt, address(this));
  }
}

interface IDEXV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IDEXV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

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

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

interface IDEXV2Router02 is IDEXV2Router01 {
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

interface IBEP20Upgradeable {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

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

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20MetadataUpgradeable is IBEP20Upgradeable {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}

abstract contract Initializable {
  bool private _initialized;

  bool private _initializing;

  modifier initializer() {
    require(
      _initializing || !_initialized,
      "Initialization: The contract is already initialized"
    );

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
}

abstract contract ContextUpgradeable is Initializable {
  function __Context_init() internal initializer {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal initializer {}

  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }

  uint256[50] private __gap;
}

contract BEP20Upgradeable is
  Initializable,
  ContextUpgradeable,
  IBEP20Upgradeable,
  IBEP20MetadataUpgradeable
{
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  function __BEP20_init(string memory name_, string memory symbol_)
    internal
    initializer
  {
    __Context_init_unchained();
    __BEP20_init_unchained(name_, symbol_);
  }

  function __BEP20_init_unchained(string memory name_, string memory symbol_)
    internal
    initializer
  {
    _name = name_;
    _symbol = symbol_;
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 10;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    public
    virtual
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
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(
      currentAllowance >= amount,
      "BEP20: transfer amount exceeds allowance"
    );
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender] + addedValue
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(
      currentAllowance >= subtractedValue,
      "BEP20: decreased allowance below zero"
    );
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _beforeTokenTransfer(sender, recipient, amount);

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
    unchecked {
      _balances[sender] = senderBalance - amount;
    }
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);

    _afterTokenTransfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "BEP20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "BEP20: burn from the zero address");

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);

    _afterTokenTransfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

  uint256[45] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  function __Ownable_init() internal initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
  }

  function __Ownable_init_unchained() internal initializer {
    _setOwner(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(
      owner() == _msgSender(),
      "Only admin can do this! and You are not the owner"
    );
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _setOwner(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownership has been transferred");
    _setOwner(newOwner);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  uint256[49] private __gap;
}

library SafeMathInt {
  int256 private constant MIN_INT256 = int256(1) << 255;
  int256 private constant MAX_INT256 = ~(int256(1) << 255);

  function mul(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a * b;

    // Detect overflow when multiplying MIN_INT256 with -1
    require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    require(b != -1 || a != MIN_INT256);

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a));
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

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

library IterableMapping {
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

interface DividendPayingTokenInterface {
  function dividendOf(address _owner) external view returns (uint256);

  function withdrawDividend() external;

  event DividendsDistributed(address indexed from, uint256 weiAmount);

  event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

interface DividendPayingTokenOptionalInterface {
  function withdrawableDividendOf(address _owner)
    external
    view
    returns (uint256);

  function withdrawnDividendOf(address _owner) external view returns (uint256);

  function accumulativeDividendOf(address _owner)
    external
    view
    returns (uint256);
}

contract DividendPayingToken is
  BEP20Upgradeable,
  OwnableUpgradeable,
  DividendPayingTokenInterface,
  DividendPayingTokenOptionalInterface
{
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  address public rewardToken;

  uint256 internal constant magnitude = 2**128;

  uint256 internal magnifiedDividendPerShare;

  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;

  uint256 public totalDividendsDistributed;

  function __DividendPayingToken_init(
    address _rewardToken,
    string memory _name,
    string memory _symbol
  ) internal initializer {
    __Ownable_init();
    __BEP20_init(_name, _symbol);
    rewardToken = _rewardToken;
  }

  function distributerewardDividends(uint256 amount) public onlyOwner {
    require(totalSupply() > 0);

    if (amount > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (amount).mul(magnitude) / totalSupply()
      );
      emit DividendsDistributed(msg.sender, amount);

      totalDividendsDistributed = totalDividendsDistributed.add(amount);
    }
  }

  function withdrawDividend() public virtual override {
    _withdrawDividendOfUser(payable(msg.sender));
  }

  function _withdrawDividendOfUser(address payable user)
    internal
    returns (uint256)
  {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[user] = withdrawnDividends[user].add(
        _withdrawableDividend
      );
      emit DividendWithdrawn(user, _withdrawableDividend);
      bool success = IBEP20(rewardToken).transfer(user, _withdrawableDividend);

      if (!success) {
        withdrawnDividends[user] = withdrawnDividends[user].sub(
          _withdrawableDividend
        );
        return 0;
      }

      return _withdrawableDividend;
    }

    return 0;
  }

  function dividendOf(address _owner) public view override returns (uint256) {
    return withdrawableDividendOf(_owner);
  }

  function withdrawableDividendOf(address _owner)
    public
    view
    override
    returns (uint256)
  {
    return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
  }

  function withdrawnDividendOf(address _owner)
    public
    view
    override
    returns (uint256)
  {
    return withdrawnDividends[_owner];
  }

  function accumulativeDividendOf(address _owner)
    public
    view
    override
    returns (uint256)
  {
    return
      magnifiedDividendPerShare
        .mul(balanceOf(_owner))
        .toInt256Safe()
        .add(magnifiedDividendCorrections[_owner])
        .toUint256Safe() / magnitude;
  }

  function _transfer(
    address from,
    address to,
    uint256 value
  ) internal virtual override {
    require(false);

    int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(
      _magCorrection
    );
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(
      _magCorrection
    );
  }

  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
      account
    ].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
  }

  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);

    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
      account
    ].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
  }

  function _setBalance(address account, uint256 newBalance) internal {
    uint256 currentBalance = balanceOf(account);

    if (newBalance > currentBalance) {
      uint256 mintAmount = newBalance.sub(currentBalance);
      _mint(account, mintAmount);
    } else if (newBalance < currentBalance) {
      uint256 burnAmount = currentBalance.sub(newBalance);
      _burn(account, burnAmount);
    }
  }
}

contract sumeriyenDividendTracker is OwnableUpgradeable, DividendPayingToken {
  using SafeMath for uint256;
  using SafeMathInt for int256;
  using IterableMapping for IterableMapping.Map;

  IterableMapping.Map private tokenHoldersMap;
  uint256 public lastProcessedIndex;

  mapping(address => bool) public excludedFromDividends;

  mapping(address => uint256) public lastClaimTimes;

  uint256 public claimWait;
  uint256 public minimumTokenBalanceForDividends;

  event ExcludeFromDividends(address indexed account);
  event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

  event Claim(address indexed account, uint256 amount, bool indexed automatic);

  function initialize(
    address rewardToken_,
    uint256 minimumTokenBalanceForDividends_
  ) external initializer {
    DividendPayingToken.__DividendPayingToken_init(
      rewardToken_,
      "sumeriyen Reward Tracker",
      "sumeriyen Reward Tracker"
    );
    claimWait = 1;
    minimumTokenBalanceForDividends = minimumTokenBalanceForDividends_;
  }

  function _transfer(
    address,
    address,
    uint256
  ) internal pure override {
    require(false, "sumeriyen Reward Tracker: Transfers are not allowed");
  }

  function withdrawDividend() public pure override {
    require(
      false,
      "sumeriyen Reward Tracker: Reward withdrawal is disabled! Use the 'claim' function to get your rewards."
    );
  }

  function excludeFromDividends(address account, bool value)
    external
    onlyOwner
  {
    excludedFromDividends[account] = value;
    if (value) {
      _setBalance(account, 0);
      tokenHoldersMap.remove(account);
    }

    emit ExcludeFromDividends(account);
  }

  function isExcludedFromDividends(address account) public view returns (bool) {
    return excludedFromDividends[account];
  }

  function updateClaimWait(uint256 newClaimWait) external onlyOwner {
    require(
      newClaimWait >= 1 && newClaimWait <= 60,
      "sumeriyen Reward Tracker: The claimWait must be updated between 1 to 60 seconds"
    );
    require(
      newClaimWait != claimWait,
      "sumeriyen Reward Tracker: The claimWait cannot update to the same value"
    );
    emit ClaimWaitUpdated(newClaimWait, claimWait);
    claimWait = newClaimWait;
  }

  function updateMinimumTokenBalanceForDividends(uint256 amount)
    external
    onlyOwner
  {
    minimumTokenBalanceForDividends = amount;
  }

  function getLastProcessedIndex() external view returns (uint256) {
    return lastProcessedIndex;
  }

  function getNumberOfTokenHolders() external view returns (uint256) {
    return tokenHoldersMap.keys.length;
  }

  function getAccount(address _account)
    public
    view
    returns (
      address account,
      int256 index,
      int256 iterationsUntilProcessed,
      uint256 withdrawableDividends,
      uint256 totalDividends,
      uint256 lastClaimTime,
      uint256 nextClaimTime,
      uint256 secondsUntilAutoClaimAvailable
    )
  {
    account = _account;

    index = tokenHoldersMap.getIndexOfKey(account);

    iterationsUntilProcessed = -1;

    if (index >= 0) {
      if (uint256(index) > lastProcessedIndex) {
        iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
      } else {
        uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
          lastProcessedIndex
          ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
          : 0;

        iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
      }
    }

    withdrawableDividends = withdrawableDividendOf(account);
    totalDividends = accumulativeDividendOf(account);

    lastClaimTime = lastClaimTimes[account];

    nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;

    secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
      ? nextClaimTime.sub(block.timestamp)
      : 0;
  }

  function getAccountAtIndex(uint256 index)
    public
    view
    returns (
      address,
      int256,
      int256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    if (index >= tokenHoldersMap.size()) {
      return (address(0), -1, -1, 0, 0, 0, 0, 0);
    }

    address account = tokenHoldersMap.getKeyAtIndex(index);

    return getAccount(account);
  }

  function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    if (lastClaimTime > block.timestamp) {
      return false;
    }

    return block.timestamp.sub(lastClaimTime) >= claimWait;
  }

  function setBalance(address payable account, uint256 newBalance)
    external
    onlyOwner
  {
    if (excludedFromDividends[account]) {
      return;
    }
    if (newBalance >= minimumTokenBalanceForDividends) {
      _setBalance(account, newBalance);
      tokenHoldersMap.set(account, newBalance);
    } else {
      _setBalance(account, 0);
      tokenHoldersMap.remove(account);
    }
    processAccount(account, true);
  }

  function process(uint256 gas)
    public
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    if (numberOfTokenHolders == 0) {
      return (0, 0, lastProcessedIndex);
    }

    uint256 _lastProcessedIndex = lastProcessedIndex;

    uint256 gasUsed = 0;

    uint256 gasLeft = gasleft();

    uint256 iterations = 0;
    uint256 claims = 0;

    while (gasUsed < gas && iterations < numberOfTokenHolders) {
      _lastProcessedIndex++;

      if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
        _lastProcessedIndex = 0;
      }

      address account = tokenHoldersMap.keys[_lastProcessedIndex];

      if (canAutoClaim(lastClaimTimes[account])) {
        if (processAccount(payable(account), true)) {
          claims++;
        }
      }

      iterations++;

      uint256 newGasLeft = gasleft();

      if (gasLeft > newGasLeft) {
        gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
      }

      gasLeft = newGasLeft;
    }

    lastProcessedIndex = _lastProcessedIndex;

    return (iterations, claims, lastProcessedIndex);
  }

  function processAccount(address payable account, bool automatic)
    public
    onlyOwner
    returns (bool)
  {
    uint256 amount = _withdrawDividendOfUser(account);

    if (amount > 0) {
      lastClaimTimes[account] = block.timestamp;
      emit Claim(account, amount, automatic);
      return true;
    }

    return false;
  }
}

abstract contract BaseToken {
  event TokenCreated(
    address indexed owner,
    address indexed token,
    uint256 version
  );
}

contract sumeriyen is BEP20, Ownable, BaseToken {
  using SafeMath for uint256;

  IDEXV2Router02 public DEXV2Router;
  address public DEXV2Pair;

  bool private swapping;

  sumeriyenDividendTracker public dividendTracker;

  address public rewardToken;
  address public liquiditytoken;

  uint256 public swapTokensAtAmount;

  // Owner can Paused transfer function
  bool public initialDistribution;

  // onTotalSupply
  uint256 public onTotalSupply = 10**10 * 5000;

  uint256 public changeTaxOne = 500;
  uint256 public changeTaxTwo = 900;
  uint256 public changeTaxThree = 600;
  uint256 public changeTaxFour = 1000;
  uint256 public changeTaxFive = 0;
  uint256 public changeTaxReflection = 2000;

  // receiver Wallets will receive tax
  address public walletOne = 0xF4fbF76F58b633B675e7349A4913De006F7E3599;
  address public walletTwo = 0x608Ec0478b95bA26DccEA7916047fe49811e1bc1;
  address public walletThree = 0xe5feFd8029Dc67fa0eD7616aeC132e3fA895c022;
  address public walletFour = 0xeD80418B646A94fC189aa4c17bf3CC7ED6e4793b;
  address public walletFive = 0xB32c13Fbaf32B90f475A1f063585B89916e53D01;

  // percetages for each tex receiver wallet
  uint256 public PercentageOne = 1000;
  uint256 public PercentageTwo = 1800;
  uint256 public PercentageThree = 1200;
  uint256 public PercentageFour = 2000;
  uint256 public PercentageFive = 5000;
  uint256 public percentageReflection = 4000;

  // Divider
  uint256 Divider = 100000;

  uint256 public gasForProcessing;
  bool public enabletransferFee = true;

  //WhiteList Transferables
  mapping(address => bool) public allowtransfer;
  //WhiteList Burn Allowed

  mapping(address => bool) public BurnWhiteList;
  mapping(address => bool) public MintWhiteList;

  mapping(address => bool) private _isExcludedFromFees;

  mapping(address => bool) public automatedMarketMakerPairs;

  event UpdateDividendTracker(
    address indexed newAddress,
    address indexed oldAddress
  );

  event UpdateDEXV2Router(
    address indexed newAddress,
    address indexed oldAddress
  );

  event ExcludeFromFees(address indexed account, bool isExcluded);
  event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

  event LiquidityWalletUpdated(
    address indexed newLiquidityWallet,
    address indexed oldLiquidityWallet
  );

  event GasForProcessingUpdated(
    uint256 indexed newValue,
    uint256 indexed oldValue
  );

  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiqudity
  );

  event SendDividends(uint256 tokensSwapped, uint256 amount);

  event ProcessedDividendTracker(
    uint256 iterations,
    uint256 claims,
    uint256 lastProcessedIndex,
    bool indexed automatic,
    uint256 gas,
    address indexed processor
  );

  constructor(address _cloneadd) BEP20("Reward Token", "RTO") {
    uint256 totalSupply_ = 100000000000000;
    rewardToken = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684; //Reward distribution in $USD
    liquiditytoken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    swapTokensAtAmount = 100000000000; // Minimum balance required in sumeriyen Reward Tracker for reward distribution

    gasForProcessing = 300000;

    dividendTracker = sumeriyenDividendTracker(
      payable(Clones.clone(_cloneadd))
    );
    dividendTracker.initialize(rewardToken, 10000000000);

    IDEXV2Router02 _DEXV2Router = IDEXV2Router02(
      0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    );
    // Create a DEX pair for this new token
    address _DEXV2Pair = IDEXV2Factory(_DEXV2Router.factory()).createPair(
      address(this),
      liquiditytoken
    );
    DEXV2Router = _DEXV2Router;
    DEXV2Pair = _DEXV2Pair;
    _setAutomatedMarketMakerPair(_DEXV2Pair, true);

    // exclude from receiving dividends
    dividendTracker.excludeFromDividends(address(dividendTracker), true);
    dividendTracker.excludeFromDividends(address(this), true);
    dividendTracker.excludeFromDividends(owner(), true);
    dividendTracker.excludeFromDividends(address(0xdead), true);
    dividendTracker.excludeFromDividends(address(_DEXV2Router), true);
    // exclude from paying fees or having max transaction amount
    excludeFromFees(owner(), true);
    allowtransfer[owner()] = true;

    _mint(owner(), totalSupply_);
  }

  receive() external payable {}

  function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
    swapTokensAtAmount = amount;
  }

  function updateDEXV2Router(address newAddress) public onlyOwner {
    require(
      newAddress != address(DEXV2Router),
      "sumeriyen Contract: The router already has that address"
    );
    emit UpdateDEXV2Router(newAddress, address(DEXV2Router));
    DEXV2Router = IDEXV2Router02(newAddress);
    address _DEXV2Pair = IDEXV2Factory(DEXV2Router.factory()).createPair(
      address(this),
      liquiditytoken
    );
    DEXV2Pair = _DEXV2Pair;
  }

  function excludeFromFees(address account, bool excluded) internal {
    _isExcludedFromFees[account] = excluded;

    emit ExcludeFromFees(account, excluded);
  }

  function excludeMultipleAccountsFromFees(
    address[] calldata accounts,
    bool excluded
  ) public onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) {
      _isExcludedFromFees[accounts[i]] = excluded;
    }

    emit ExcludeMultipleAccountsFromFees(accounts, excluded);
  }

  function setWallet(
    address _one,
    address _two,
    address _three,
    address _four,
    address _five
  ) public onlyOwner {
    walletOne = _one;
    walletTwo = _two;
    walletThree = _three;
    walletFour = _four;
    walletFive = _five;
  }

  // set values on basis of 100th e.g. 0.05% will be 5 and 0.5 will be 50 and so on
  function setWalletOnePercentage(
    uint256 _one,
    uint256 _two,
    uint256 _three,
    uint256 _four,
    uint256 _five,
    uint256 _reflection
  ) public onlyOwner {
    PercentageOne = _one;
    PercentageTwo = _two;
    PercentageThree = _three;
    PercentageFour = _four;
    PercentageFive = _five;
    percentageReflection = _reflection;
  }

  // here only owner can set setOnTotalSupply for checking the total Supply if equal to this value tax rates will reduce
  function setOnTotalSupply(uint256 _onTotalSupply) public onlyOwner {
    onTotalSupply = _onTotalSupply;
  }

  // here only owner can set tax rates for reduction
  function updateChangeTax(
    uint256 _one,
    uint256 _two,
    uint256 _three,
    uint256 _four,
    uint256 _five,
    uint256 _reflection
  ) public onlyOwner {
    changeTaxOne = _one;
    changeTaxTwo = _two;
    changeTaxThree = _three;
    changeTaxFour = _four;
    changeTaxFive = _five;
    changeTaxReflection = _reflection;
  }

  // here onlyOwner can burn tokens
  function burn(address account, uint256 amount) public {
    require(
      msg.sender == owner() || BurnWhiteList[msg.sender],
      "Cannot Burn: Your address should be whitelisted before burning the tokens"
    );

    _burn(account, amount);

    uint256 remains = balanceOf(account);

    dividendTracker.setBalance(payable(account), remains);
  }

  function mint(address account, uint256 amount) public {
    require(
      msg.sender == owner() || MintWhiteList[msg.sender],
      "Cannot Mint: Only token bridge can mint the tokens"
    );
    _mint(account, amount);

    uint256 newbal = balanceOf(account);
    dividendTracker.setBalance(payable(account), newbal);
  }

  function setBurnWhiteList(address _address, bool _answer) public onlyOwner {
    BurnWhiteList[_address] = _answer;
  }

  function setMintWhiteList(address _address, bool _answer) public onlyOwner {
    MintWhiteList[_address] = _answer;
  }

  // here onlyOwner can set WhiteList Transferable Addresses
  function setAllowTransfer(address _address, bool _answer) public onlyOwner {
    allowtransfer[_address] = _answer;
  }

  function setAutomatedMarketMakerPair(address pair, bool value)
    public
    onlyOwner
  {
    require(
      pair != DEXV2Pair,
      "sumeriyen Contract: The reward pair cannot be removed from automated market maker pairs"
    );

    _setAutomatedMarketMakerPair(pair, value);
  }

  function _setAutomatedMarketMakerPair(address pair, bool value) private {
    require(
      automatedMarketMakerPairs[pair] != value,
      "sumeriyen Contract: The automated market maker pair is already set to that value"
    );
    automatedMarketMakerPairs[pair] = value;

    if (value) {
      dividendTracker.excludeFromDividends(pair, true);
    }

    emit SetAutomatedMarketMakerPair(pair, value);
  }

  function updateGasForProcessing(uint256 newValue) public onlyOwner {
    require(
      newValue >= 200000 && newValue <= 500000,
      "sumeriyen Contract: The gas fee for processing the transaction must be between 200000 to 500000"
    );
    require(
      newValue != gasForProcessing,
      "sumeriyen Contract: Cannot update the gas fee for processing to the same value"
    );
    emit GasForProcessingUpdated(newValue, gasForProcessing);
    gasForProcessing = newValue;
  }

  function updateClaimWait(uint256 claimWait) external onlyOwner {
    dividendTracker.updateClaimWait(claimWait);
  }

  function getClaimWait() external view returns (uint256) {
    return dividendTracker.claimWait();
  }

  function updateMinimumTokenBalanceForDividends(uint256 amount)
    external
    onlyOwner
  {
    dividendTracker.updateMinimumTokenBalanceForDividends(amount);
  }

  function enableTransferTax(bool _status) public onlyOwner {
    enabletransferFee = _status;
  }

  function setInitialDistribution(bool _status) public onlyOwner {
    initialDistribution = _status;
  }

  function getMinimumTokenBalanceForDividends()
    external
    view
    returns (uint256)
  {
    return dividendTracker.minimumTokenBalanceForDividends();
  }

  function getTotalDividendsDistributed() external view returns (uint256) {
    return dividendTracker.totalDividendsDistributed();
  }

  function isExcludedFromFees(address account) public view returns (bool) {
    return _isExcludedFromFees[account];
  }

  function withdrawableDividendOf(address account)
    public
    view
    returns (uint256)
  {
    return dividendTracker.withdrawableDividendOf(account);
  }

  function dividendTokenBalanceOf(address account)
    public
    view
    returns (uint256)
  {
    return dividendTracker.balanceOf(account);
  }

  function excludeFromDividends(address account, bool value)
    external
    onlyOwner
  {
    dividendTracker.excludeFromDividends(account, value);
  }

  function isExcludedFromDividends(address account) public view returns (bool) {
    return dividendTracker.isExcludedFromDividends(account);
  }

  function getAccountDividendsInfo(address account)
    external
    view
    returns (
      address,
      int256,
      int256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    return dividendTracker.getAccount(account);
  }

  function getAccountDividendsInfoAtIndex(uint256 index)
    external
    view
    returns (
      address,
      int256,
      int256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    return dividendTracker.getAccountAtIndex(index);
  }

  function processDividendTracker(uint256 gas) external {
    (
      uint256 iterations,
      uint256 claims,
      uint256 lastProcessedIndex
    ) = dividendTracker.process(gas);
    emit ProcessedDividendTracker(
      iterations,
      claims,
      lastProcessedIndex,
      false,
      gas,
      tx.origin
    );
  }

  function claim() external {
    dividendTracker.processAccount(payable(msg.sender), false);
  }

  function getLastProcessedIndex() external view returns (uint256) {
    return dividendTracker.getLastProcessedIndex();
  }

  function getNumberOfDividendTokenHolders() external view returns (uint256) {
    return dividendTracker.getNumberOfTokenHolders();
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    require(from != address(0), "BEP20: transfer from the zero address");
    require(to != address(0), "BEP20: transfer to the zero address");

    require(
      initialDistribution || allowtransfer[from] || allowtransfer[to],
      "The transactions are paused! You cannot make any transaction until the team resumes it"
    );

    if (amount == 0) {
      super._transfer(from, to, 0);
      return;
    }

    uint256 contractTokenBalance = balanceOf(address(this));

    bool canSwap = contractTokenBalance >= swapTokensAtAmount;

    if (
      canSwap &&
      !swapping &&
      !automatedMarketMakerPairs[from] &&
      from != owner() &&
      to != owner()
    ) {
      swapping = true;

      uint256 sellTokens = balanceOf(address(this));
      swapAndSendDividends(sellTokens);

      swapping = false;
    }

    bool takeFee = !swapping;

    // if any account belongs to _isExcludedFromFee account then remove the fee
    if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
      takeFee = false;
    } else if (enabletransferFee) {
      takeFee = true;
    }

    uint256 fees;

    if (takeFee) {
      fees = _takeFee(from, amount);

      amount = amount.sub(fees);
    }

    super._transfer(from, to, amount);

    try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
    try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

    if (!swapping) {
      uint256 gas = gasForProcessing;

      try dividendTracker.process(gas) returns (
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex
      ) {
        emit ProcessedDividendTracker(
          iterations,
          claims,
          lastProcessedIndex,
          true,
          gas,
          tx.origin
        );
      } catch {}
    }
  }

  function swapTokensForreward(uint256 tokenAmount) private {
    address[] memory path = new address[](3);
    path[0] = address(this);
    path[1] = liquiditytoken;
    path[2] = rewardToken;

    _approve(address(this), address(DEXV2Router), tokenAmount);

    // make the swap
    DEXV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
      tokenAmount,
      0,
      path,
      address(this),
      block.timestamp
    );
  }

  function _takeFee(address from, uint256 amount)
    internal
    returns (uint256 fees)
  {
    uint256 _one = totalSupply() <= onTotalSupply
      ? changeTaxOne
      : PercentageOne;
    uint256 _two = totalSupply() <= onTotalSupply
      ? changeTaxTwo
      : PercentageTwo;
    uint256 _three = totalSupply() <= onTotalSupply
      ? changeTaxThree
      : PercentageThree;
    uint256 _four = totalSupply() <= onTotalSupply
      ? changeTaxFour
      : PercentageFour;
    uint256 _five = totalSupply() <= onTotalSupply
      ? changeTaxFive
      : PercentageFive;
    uint256 _reflection = totalSupply() <= onTotalSupply
      ? changeTaxReflection
      : percentageReflection;
    // here function calculate Percentage and add into variable
    uint256 one = (amount * _one) / Divider;
    uint256 two = (amount * _two) / Divider;
    uint256 three = (amount * _three) / Divider;
    uint256 four = (amount * _four) / Divider;
    uint256 five = (amount * _five) / Divider;
    uint256 reflectionFee = (amount * _reflection) / Divider;

    super._transfer(from, address(this), reflectionFee);

    super._transfer(from, walletOne, one);
    super._transfer(from, walletTwo, two);
    super._transfer(from, walletThree, three);
    super._transfer(from, walletFour, four);
    super._transfer(from, walletFive, five);

    return (one + two + three + four + five + reflectionFee);
  }

  function swapAndSendDividends(uint256 tokens) private {
    swapTokensForreward(tokens);
    uint256 dividends = IBEP20(rewardToken).balanceOf(address(this));
    bool success = IBEP20(rewardToken).transfer(
      address(dividendTracker),
      dividends
    );

    if (success) {
      dividendTracker.distributerewardDividends(dividends);
      emit SendDividends(tokens, dividends);
    }
  }

  function updaterewrdToken(address _cloneadd, address _rewardToken)
    external
    onlyOwner
  {
    dividendTracker = sumeriyenDividendTracker(
      payable(Clones.clone(_cloneadd))
    );
    dividendTracker.initialize(_rewardToken, 10000000000);
    rewardToken = _rewardToken;
    // exclude from receiving dividends
    dividendTracker.excludeFromDividends(address(dividendTracker), true);
    dividendTracker.excludeFromDividends(address(this), true);
    dividendTracker.excludeFromDividends(owner(), true);
    dividendTracker.excludeFromDividends(address(0xdead), true);
    dividendTracker.excludeFromDividends(address(DEXV2Router), true);
  }
}