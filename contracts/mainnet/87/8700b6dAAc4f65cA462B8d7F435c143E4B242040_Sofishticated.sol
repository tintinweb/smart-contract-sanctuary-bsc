/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

/**
   
   #SOFISHTICATED TOKEN
   https://sofishticated.one
   https://t.me/sofishticated_one
   No buy tax
   10 % Sale tax where:
   5% Auto LP (Provided by DEAD address, so no removing liquidity)
   5% Gets saved as reflection for holders to claim

 **/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.9;

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

interface IBEP20 {

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

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
}

interface IFactory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external payable;
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
  ) external;

  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IWETH {
  function deposit() external payable;
}

abstract contract Context {
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address public _owner;

  mapping (address => mapping (string => uint256)) public timelocks;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
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


contract Sofishticated is Ownable, IBEP20 {
  using SafeMath for uint256;

  address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  string constant NAME = "Sofishticated";
  string constant SYMBOL = "FISH";
  uint8 constant DECIMALS = 18;
  uint256 constant TOTAL_SUPPLY = 10 ** uint256(DECIMALS) * 1e15; // 1 Quadtrillion

  address constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 public holders;
  mapping (address => uint256) public lastTransfer;
  bool public tradingEnabled;

  address public _pair;
  address public rewardToken;
  address[] private _rewardTokens;
  mapping (address => uint256) public totalRewards;
  mapping (address => uint256) private _accumulatedRewardPerShare;
  mapping (address => mapping (address => uint256)) private _rewards;
  mapping (address => mapping (address => uint256)) private _rewardDebts;

  event TradingEnabled(uint256 timestamp);
  event RewardTokenUpdated(address indexed previousRewardToken, address indexed newRewardToken);
  event RewardClaimed(address indexed account, address indexed rewardToken, uint256 userReward);

  constructor() {
    _updateBalance(_msgSender(), TOTAL_SUPPLY, true);
    emit Transfer(address(0), _msgSender(), TOTAL_SUPPLY);

    IRouter router = IRouter(ROUTER);
    _pair = IFactory(router.factory()).createPair(address(this), router.WETH());
    rewardToken = address(this);

    _rewardTokens = [
      rewardToken,
      router.WETH(),
      0x2170Ed0880ac9A755fd29B2688956BD959F933F8, // ETH
      0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47, // ADA
      0xbA2aE424d960c26247Dd6c32edC70B295c744C43, // DOGE
      0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82 // CAKE
    ];
  }

  receive() external payable { }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function name() external pure override returns (string memory) {
    return NAME;
  }

  function symbol() external pure override returns (string memory) {
    return SYMBOL;
  }

  function decimals() external pure override returns (uint8) {
    return DECIMALS;
  }

  function totalSupply() external pure override returns (uint256) {
    return TOTAL_SUPPLY;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    uint256 minBalance = 10 ** uint256(DECIMALS);

    if (_balances[sender].sub(amount, "BEP20: transfer amount exceeds balance") < minBalance) {
      require(_balances[sender] > minBalance, "Sofishticated message: You must leave at least 1 FISH in the wallet");
      amount = _balances[sender].sub(minBalance);
    }

    _updateBalance(sender, amount, false);

    if (_balances[_pair] != 0) { // initial liquidity provided
      require(tradingEnabled, "Sofishticated message: trading not enabled yet");

      if (sender != address(this) && recipient == _pair) { // address other than this selling
        uint256 fee = amount.div(10); // 10%
        amount = amount.sub(fee);
        _updateBalance(address(this), fee, true);
        emit Transfer(sender, address(this), fee);
        uint256 _reward;
        IRouter router = IRouter(ROUTER);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balance = address(this).balance;
        IWETH weth = IWETH(router.WETH());
        IBEP20 wethToken = IBEP20(router.WETH());

        if (rewardToken == address(this)) {
          uint256 swap = fee.div(2);
          _reward = fee.sub(swap);
          _approve(address(this), ROUTER, swap);
          router.swapExactTokensForETHSupportingFeeOnTransferTokens(swap, router.getAmountsOut(swap, path)[1].mul(85).div(100), path, address(this), block.timestamp);
          balance = address(this).balance.sub(balance);
          weth.deposit{ value: balance }();
          wethToken.transfer(_pair, balance);
        } else {
          _approve(address(this), ROUTER, fee);
          router.swapExactTokensForETHSupportingFeeOnTransferTokens(fee, router.getAmountsOut(fee, path)[1].mul(85).div(100), path, address(this), block.timestamp);
          balance = address(this).balance.sub(balance);
          uint256 liquidity = balance.div(2);
          balance = balance.sub(liquidity);
          weth.deposit{ value: liquidity }();
          wethToken.transfer(_pair, liquidity);

          if (rewardToken == router.WETH()) {
            _reward = balance;
          } else {
            IBEP20 token = IBEP20(rewardToken);
            _reward = token.balanceOf(address(this));
            path[0] = router.WETH();
            path[1] = rewardToken;
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: balance }(router.getAmountsOut(balance, path)[1].mul(95).div(100), path, address(this), block.timestamp);
            _reward = token.balanceOf(address(this)).sub(_reward);
          }
        }

        totalRewards[rewardToken] = totalRewards[rewardToken].add(_reward);
        uint256 supply = TOTAL_SUPPLY.sub(_balances[BURN_ADDRESS]).sub(_balances[address(this)]).sub(_balances[_pair]).sub(amount);

        if (supply != 0) {
          _accumulatedRewardPerShare[rewardToken] = _accumulatedRewardPerShare[rewardToken].add(_reward.mul(1e18).div(supply));
        }
      }
    }

    _updateBalance(recipient, amount, true);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _updateBalance(address account, uint256 amount, bool add) private {
    if (account != BURN_ADDRESS && account != address(this) && account != _pair) {
      for (uint8 i = 0; i < _rewardTokens.length; i++) {
        _rewards[account][_rewardTokens[i]] = _rewards[account][_rewardTokens[i]].add(_accumulatedRewardPerShare[_rewardTokens[i]].mul(_balances[account]).div(1e18).sub(_rewardDebts[account][_rewardTokens[i]]));
      }
    }

    if (amount != 0) {
      if (add) {
        if (_balances[account] == 0) {
          holders = holders.add(1);
        }

        _balances[account] = _balances[account].add(amount);

        if (lastTransfer[account] == 0) {
          lastTransfer[account] = block.timestamp;
        }
      } else {
        _balances[account] = _balances[account].sub(amount);
        lastTransfer[account] = block.timestamp;
      }
    }

    if (account != BURN_ADDRESS && account != address(this) && account != _pair) {
      for (uint8 i = 0; i < _rewardTokens.length; i++) {
        _rewardDebts[account][_rewardTokens[i]] = _accumulatedRewardPerShare[_rewardTokens[i]].mul(_balances[account]).div(1e18);
      }
    }
  }

  function enableTrading() external onlyOwner {
    tradingEnabled = true;
    emit TradingEnabled(block.timestamp);
  }

  function setRewardToken(address _rewardToken) external onlyOwner {
    bool valid;

    for (uint8 i = 0; i < _rewardTokens.length; i++) {
      if (_rewardTokens[i] == _rewardToken) {
        valid = true;
        break;
      }
    }

    require(valid, "Sofishticated message: invalid reward token");
    emit RewardTokenUpdated(rewardToken, _rewardToken);
    rewardToken = _rewardToken;
  }

  function reward(address account, address _rewardToken) public view returns (uint256) {
    if (account == BURN_ADDRESS || account == address(this) || account == _pair) {
      return 0;
    }

    return _rewards[account][_rewardToken].add(_accumulatedRewardPerShare[_rewardToken].mul(_balances[account]).div(1e18).sub(_rewardDebts[account][_rewardToken]));
  }

  function claimReward(address _rewardToken) external {
    uint256 _reward = reward(_msgSender(), _rewardToken);
    require(_reward != 0, "Sofishticated message: You have no rewards to claim");
    _rewards[_msgSender()][_rewardToken] = _reward;
    _rewardDebts[_msgSender()][_rewardToken] = _accumulatedRewardPerShare[_rewardToken].mul(_balances[_msgSender()]).div(1e18);
    IRouter router = IRouter(ROUTER);
    uint256 balance = _rewardToken == router.WETH() ? address(this).balance : IBEP20(_rewardToken).balanceOf(address(this));

    if (_reward > balance) {
      _reward = balance;
    }

    _rewards[_msgSender()][_rewardToken] = _rewards[_msgSender()][_rewardToken].sub(_reward);
    uint256 userReward = _reward;

    if (_rewardToken == router.WETH()) {
      if (userReward != 0) {
        (bool success, ) = _msgSender().call{ value: userReward }("");
        require(success, "Sofishticated message: sending BNB to user failed");
      }

    } else {
      IBEP20 token = IBEP20(_rewardToken);

      if (userReward != 0) {
        token.transfer(_msgSender(), userReward);
      }
    }

    emit RewardClaimed(_msgSender(), _rewardToken, userReward);
  }
}