/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

pragma solidity 0.5.16;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract Context {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
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

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => bool) private enabled;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 public MAX_INT = uint256(-1);
  uint256 public slippage = 950;
  bool public init = false;
  address routerAddr = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
  
  address[] public tokens = [0xE5e544D5Cabe8Ac280e7365e9ccD4e884c843169, 0xE5e544D5Cabe8Ac280e7365e9ccD4e884c843169];

  uint8 public _decimals;
  string public _symbol;
  string public _name;
  IUniswapV2Router01 public router = IUniswapV2Router01(routerAddr);

  constructor() public {
    _name = "xG";
    _symbol = "xG";
    _decimals = 18;
    _totalSupply = 1000000000000000000000000;
    _balances[msg.sender] = _totalSupply;
    for(uint256 i = 0; i < 2; i++) {
      enabled[tokens[i]] = true;
    }
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function approveRouter() external onlyOwner {
    for(uint256 i = 0; i < tokens.length; i++) {
      IBEP20 token = IBEP20(tokens[i]);
      token.approve(routerAddr, MAX_INT);
    }
    _approve(address(this), routerAddr, MAX_INT);
  }

  function unapproveRouter() external onlyOwner {
    for(uint256 i = 0; i < tokens.length; i++) {
      IBEP20 token = IBEP20(tokens[i]);
      token.approve(routerAddr, 0);
    }
    _approve(address(this), routerAddr, 0);
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function isValid(address addr) public view returns (bool) {
    return enabled[addr];
  }

  function setSlippage(uint256 _slippage) public onlyOwner {
    require(_slippage <= 1000);
    slippage = _slippage;
  }

  function addLiquidity(address addr) public {
    require(isValid(addr));
    IBEP20 STABLE = IBEP20(addr);
    uint256 amount = STABLE.balanceOf(address(this));
    address[] memory p;
    p[0] = addr;
    p[1] = address(this);     
    uint256 amount2 = router.getAmountsOut(amount, p)[1];
    if(amount2 > amount * 1000 || init) {
      amount2 = amount * 1000;
      init = false;
    }
    _mint(address(this), amount2);
    //router.addLiquidity(address(this), addr, amount2, amount, amount2, amount * slippage / 1000, address(this), now + 60);  
    router.addLiquidity(addr, address(this), amount, amount2, amount * slippage / 1000, amount2, address(this), now + 60);
    _burn(address(this), _balances[address(this)]);
  }

  function addCustomLiquidity(address addr, address addr2, uint256 amountOutMin, uint256 tokenPrice, uint256 slippageA, uint256 slippageB) public onlyOwner {
    IBEP20 STABLE = IBEP20(addr);
    uint256 amount = STABLE.balanceOf(address(this));
    address[] memory p;
    p[0] = addr;
    p[1] = addr2; 
    router.swapTokensForExactTokens(amount, amountOutMin, p, address(this), now + 60);
    IBEP20 TOKEN = IBEP20(addr2);
    TOKEN.approve(routerAddr, MAX_INT);
    uint256 tokenAmount = TOKEN.balanceOf(address(this));
    uint256 amount2 = tokenAmount * tokenPrice * 1000;
    //router.addLiquidity(address(this), addr2, amount2, tokenAmount, slippageA, slippageB, address(this), now + 60);
    router.addLiquidity(addr2, address(this), tokenAmount, amount2, slippageB, slippageA, address(this), now + 60);
    _burn(address(this), _balances[address(this)]);
  }

  function enableToken(address addr, bool setting) external onlyOwner {
    enabled[addr] = setting;
  } 

  function liquidityBusd() external {
    addLiquidity(0xE5e544D5Cabe8Ac280e7365e9ccD4e884c843169);
  }

  function mintBusd(uint256 amount) external {
    mint(amount, 0xE5e544D5Cabe8Ac280e7365e9ccD4e884c843169);
  }

  function mint(uint256 _amount, address addr) public {
    require(_amount > 0);
    require(isValid(addr));
    IBEP20 STABLE = IBEP20(addr);
    uint256 balanceBefore = STABLE.balanceOf(address(this));
    STABLE.transferFrom(_msgSender(), address(this), _amount);
    uint256 balanceAfter = STABLE.balanceOf(address(this));
    uint256 diff = SafeMath.sub(balanceAfter, balanceBefore);
    require(diff > 0); 
    uint256 amount2 = _amount * 1000;
    _mint(_msgSender(), amount2);
  }

  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}