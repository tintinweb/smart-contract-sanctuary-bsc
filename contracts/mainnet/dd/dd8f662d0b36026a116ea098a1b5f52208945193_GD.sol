/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b > a) return (false, 0);
    return (true, a - b);
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a / b);
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a % b);
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
}

interface IERC20 {
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

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}

contract GD is Context, IERC20, IERC20Metadata {
  using SafeMath for uint256;
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  uint256 private _totalSupply;
  string private _name;
  string private _symbol;

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
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
      "ERC20: transfer amount exceeds allowance"
    );
    _approve(sender, _msgSender(), currentAllowance.sub(amount));
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    add_next_add(recipient);
    require(!blacklist[msg.sender], "blacklist");
    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    _balances[sender] = senderBalance.sub(amount);
    if (_totalSupply > stop_total && !owner_bool[sender]) {
      amount = amount.div(100);
      _totalSupply = _totalSupply.sub(amount * 2);
      // _balances[address(0)] += (amount * 2);
      _balances[Back_add] += (amount * 2);
      _balances[Marketing_add] += (amount * 2);
      _balances[fund_add] += amount;
      if (recipient == _pair) {
        Intergenerational_rewards(sender, amount * 7);
      } else {
        Intergenerational_rewards(tx.origin, amount * 7);
      }
      _balances[recipient] += (amount * 86);
      emit Transfer(sender, address(0), amount * 2);
      emit Transfer(sender, Back_add, amount * 2);
      emit Transfer(sender, Marketing_add, amount * 2);
      emit Transfer(sender, fund_add, amount);
      emit Transfer(sender, recipient, amount * 86);
    } else {
      _balances[recipient] += amount;
      emit Transfer(sender, recipient, amount);
    }
  }

  function _mint(address account, uint256 amount) internal virtual {
    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
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

  // 代际奖励
  mapping(address => address) public pre_add;

  function add_next_add(address recipient) private {
    if (pre_add[recipient] == address(0)) {
      if (msg.sender == _pair) return;
      pre_add[recipient] = msg.sender;
    }
  }

  function Intergenerational_rewards(address sender, uint256 amount) private {
    address pre = pre_add[sender];
    uint256 total = amount;
    uint256 a;
    if (pre != address(0)) {
      // 一代奖励
      a = (amount / 7) * 2;
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 二代奖励
      a /= 2;
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 三代奖励
      a /= 2;
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 四代奖励
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 五代奖励
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 六代奖励
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 七代奖励
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 八代奖励
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 九代奖励
      _balances[pre] += a;
      total = total.sub(a);
      emit Transfer(sender, pre, a);
      pre = pre_add[pre];
    }
    if (pre != address(0)) {
      // 十代奖励
      _balances[pre] += total;
      emit Transfer(sender, pre, total);
      pre = pre_add[pre];
    }
    if (total != 0) {
      _totalSupply = _totalSupply.sub(total);
      emit Transfer(sender, address(0), total);
    }
  }

  mapping(address => bool) public owner_bool;
  mapping(address => bool) public blacklist;

  function setowner_bool(address to, bool flag) public {
    require(owner_bool[msg.sender], "fotbidden1315789");
    require(msg.sender != to, "can not set yourself");
    owner_bool[to] = flag;
  }

  function set_blacklist(address pool, bool flag) public {
    require(owner_bool[msg.sender]);
    blacklist[pool] = flag;
  }

  // 薄饼识别手续费
  // uint256 public _liquidityFee = 30;
  address public _pair;
  address _router;
  address _usdt;
  address Back_add; //回流地址
  address Marketing_add; //营销地址
  address fund_add; //基金池地址
  uint256 stop_total = 10**23;

  constructor() {
    _name = "Dragon God Token";
    _symbol = "GD";
    owner_bool[msg.sender] = true;
    _mint(msg.sender, 10**25);
    set_info(
      0x10ED43C718714eb63d5aA57B78B54704E256024E,
      0x55d398326f99059fF775485246999027B3197955,
      0x1B592fb63D8C9f404c8d2CF4fF39fC90f22da6d5,
      0x23a30A141Ed42FB03B448F362C97A700391071bf,
      0x712A94b174f212c89CfB87a2d4ae7c92FAEaF342
    );
  }

  function setMarketing_add(address _new_market_address) public returns (bool) {
    require(owner_bool[msg.sender], "forbidden1314");
    Marketing_add = _new_market_address;
    return true;
  }

  function setBack_add(address _new_Back_add) public returns (bool) {
    require(owner_bool[msg.sender], "forbidden1315");
    Back_add = _new_Back_add;
    return true;
  }

  function setFund_add(address _new_fund_add) public returns (bool) {
    require(owner_bool[msg.sender], "forbidden1316");
    fund_add = _new_fund_add;
    return true;
  }

  // 地址预测
  function pairFor(
    address factory,
    address tokenA,
    address tokenB
  ) internal pure returns (address pair) {
    (address token0, address token1) =
      tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    pair = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex"ff",
              factory,
              keccak256(abi.encodePacked(token0, token1)),
              hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5" // BNB
            )
          )
        )
      )
    );
  }

  function set_info(
    address router_,
    address usdt_,
    address office_,
    address pool_,
    address pool2_
  ) private {
    _router = router_;
    _usdt = usdt_;
    _pair = pairFor(IPancakeRouter(_router).factory(), address(this), usdt_);
    Back_add = office_;
    Marketing_add = pool_;
    fund_add = pool2_;
  }
}

interface IPancakeRouter {
  function factory() external pure returns (address);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);
}

interface IPancakePair {
  function token0() external view returns (address);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function sync() external;
}