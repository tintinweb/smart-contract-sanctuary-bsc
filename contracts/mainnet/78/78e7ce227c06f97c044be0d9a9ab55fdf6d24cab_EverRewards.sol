/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IUniswapV2Router02 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20 {
  function totalSupply() external view returns (uint);
  function balanceOf(address account) external view returns (uint);
  function transfer(address to, uint amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint amount) external returns (bool);
  function transferFrom(address from, address to, uint amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes calldata){
    this;
    return msg.data;
  }
}

contract Ownable is Context {
  address public ownerAddress = address(0);

  modifier onlyOwner() {
    require(_msgSender() == ownerAddress, "Ownable: caller is not the owner");
    _;
  }

  function setOwner(address newOwnerAddress) public onlyOwner {
    ownerAddress = newOwnerAddress;
  }
}

contract EverRewards is IERC20, Ownable {
  // Token preferences & valiables
  string private constant _name = "EverRewards";
  string private constant _symbol = "EVERREWARDS";
  uint8 private constant _decimals = 18;
  uint private constant _tTotal = 21_000_000 ether;
  uint private _rTotal = (~uint(0) - (~uint(0) % _tTotal));

  // Holders & Allowances
  mapping(address => mapping(address => uint)) private _allowances;
  mapping(address => uint) _rOwned;
  mapping(address => uint) _tOwned;

  // Jackpot preferences
  uint public jackpotTimespan = 30 minutes;
  uint public jackpotWinnerCashoutPct = 5000;
  uint public jackpotMinBuyBnb = 0.1 ether;
  uint public jackpotCapTokens = 500_000 ether;
  uint public jackpotCapBurnPct = 5000;

  // Rewards & burns
  uint public reflectedTotalTokens = 0;
  uint public totalJackpotBurnedTokens = 0;
  uint public totalJackpotRewardedTokens = 0;
  address public lastBuyerAddress = address(0);
  uint public lastBuyTimestamp = 0;
  address public lastAwardedAddress = address(0);
  uint public lastAwardedTokens = 0;
  uint public lastAwardedTimestamp = 0;
  mapping(address => bool) public isExcludedFromRewards;
  address[] private excludedFromRewards;

  // Other
  uint private constant MAX_PCT = 10000;
  IUniswapV2Router02 private immutable _uniswapV2Router;
  address private immutable _uniswapV2Pair;
  address private immutable _usdtAddress;
  address private immutable _wethAddress;

  // Tax
  uint public jackpotTaxPct = 200;
  uint public reflectTaxPct = 500;
  mapping(address => bool) public isExcludedFromTax;

  // Events
  event JackpotAwarded(uint buyerRewardTokens);
  event JackpotCapReached(uint tokensBurned);

  constructor(address uniswapRouterAddress, address usdtAddress) {
    _usdtAddress = usdtAddress;
    _uniswapV2Router = IUniswapV2Router02(uniswapRouterAddress);
    _wethAddress = _uniswapV2Router.WETH();
    _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _wethAddress);
    ownerAddress = _msgSender();
    isExcludedFromTax[ownerAddress] = true;
    isExcludedFromTax[address(this)] = true;
    excludeFromRewards(_uniswapV2Pair);
    _rOwned[ownerAddress] = _tTotal * _getRate();
    emit Transfer(address(0), ownerAddress, _tTotal);
  }

  receive() external payable {}

  // Common functions
  function name() public pure returns (string memory) {return _name;}
  function symbol() public pure returns (string memory) {return _symbol;}
  function decimals() public pure returns (uint8) {return _decimals;}
  function totalSupply() public pure returns (uint) {return _tTotal;}

  // Allowance-related functions
  function allowance(address owner, address spender) public view returns (uint) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint amount) public returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(
    address owner,
    address spender,
    uint amount
  ) private {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  // Staking-related functions
  function balanceOf(address account) public view returns (uint) {
    if (isExcludedFromRewards[account]) return _tOwned[account];
    return _rOwned[account] / _getRate();
  }

  function _getRate() private view returns (uint) {
    uint256 rSupply = _rTotal;
    uint256 tSupply = _tTotal;
    for (uint256 i = 0; i < excludedFromRewards.length; i++) {
      rSupply -= _rOwned[excludedFromRewards[i]];
      tSupply -= _tOwned[excludedFromRewards[i]];
    }
    return rSupply / tSupply;
  }

  // Once address is exluded it can't be included again otherwise that affects rewards
  function excludeFromRewards(address account) public onlyOwner {
    require(!isExcludedFromRewards[account], "Account is already excluded");
    _tOwned[account] = _rOwned[account] / _getRate();
    isExcludedFromRewards[account] = true;
    excludedFromRewards.push(account);
  }

  // Tax functions
  function excludeFromTax(address account) external onlyOwner {
    isExcludedFromTax[account] = true;
  }

  function includeInTax(address account) external onlyOwner {
    isExcludedFromTax[account] = false;
  }

  function setTaxPct(uint jackpotPct, uint reflectPct) external onlyOwner {
    require(jackpotPct + reflectPct <= 1000, "Tax can not exceed 10%");
    jackpotTaxPct = jackpotPct;
    reflectTaxPct = reflectPct;
  }

  // Token transfer functions
  function transfer(address recipient, uint amount) public returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint amount
  ) public returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()] - amount
    );
    return true;
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint tAmount,
    bool takeTax
  ) private {
    if (tAmount == 0) return;
    if (sender == _uniswapV2Pair && _tokensToBnb(tAmount) >= jackpotMinBuyBnb) {
      lastBuyTimestamp = block.timestamp;
      lastBuyerAddress = recipient;
    }

    uint rate = _getRate();
    uint tJackpotTax = _getPct(takeTax ? jackpotTaxPct : 0, tAmount);
    uint tReflectTax = _getPct(takeTax ? reflectTaxPct : 0, tAmount);
    uint tTransferAmount = tAmount - tJackpotTax - tReflectTax;

    _rOwned[sender] -= rate * tAmount;
    _rOwned[recipient] += rate * tTransferAmount;
    if (isExcludedFromRewards[sender]) _tOwned[sender] -= tAmount;
    if (isExcludedFromRewards[recipient])  _tOwned[recipient] += tTransferAmount;

    _rOwned[address(this)] += tJackpotTax * rate;
    _rTotal -= rate * tReflectTax;
    reflectedTotalTokens += tReflectTax;

    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transfer(
    address from,
    address to,
    uint amount
  ) private {
    _processJackpotCap();
    _processJackpot();

    bool ignoreTax = isExcludedFromTax[from] || isExcludedFromTax[to] ||
    (_uniswapV2Pair != from && _uniswapV2Pair != to);

    _tokenTransfer(from, to, amount, !ignoreTax);
  }

  // Jackpot-related functions
  function setJackpotPreferences(
    uint _jackpotWinnerCashoutPct,
    uint _jackpotMinBuyBnb
  ) external onlyOwner {
    require(_isBtw(_jackpotWinnerCashoutPct, 1000, 5000), "Winner cashout percentage should be between 10% and 50%");
    require(_isBtw(_jackpotMinBuyBnb, 0.01 ether, 10 ether), "Min buy should be between 0.01bnb and 10bnb");
    jackpotWinnerCashoutPct = _jackpotWinnerCashoutPct;
    jackpotMinBuyBnb = _jackpotMinBuyBnb;
  }

  function setJackpotCapPreferences(
    uint _jackpotCapBurnPct,
    uint _jackpotCapTokens
  ) external onlyOwner {
    require(_isBtw(_jackpotCapBurnPct, 3000, 7000), "Burn percentage should be between 30% and 70%");
    require(_isBtw(_jackpotCapTokens, 10_000 ether, 1_000_000), "Jackpot cap should be between 10k and 1m tokens");
    jackpotCapBurnPct = _jackpotCapBurnPct;
    jackpotCapTokens = _jackpotCapTokens;
  }

  function setJackpotTimespan(uint _jackpotTimespan) external onlyOwner {
    require(_isBtw(_jackpotTimespan, 30, 30 minutes), "Timespan should be between 30 and 30 minutes");
    jackpotTimespan = _jackpotTimespan;
  }

  function _processJackpot() private {
    if (lastBuyerAddress == address(0) || block.timestamp - lastBuyTimestamp < jackpotTimespan)
      return;

    uint jackpotTokens = balanceOf(address(this));
    uint buyerRewardTokens = _getPct(jackpotWinnerCashoutPct, jackpotTokens);
    _tokenTransfer(address(this), lastBuyerAddress, buyerRewardTokens, false);
    lastAwardedAddress = lastBuyerAddress;
    lastAwardedTimestamp = block.timestamp;
    lastAwardedTokens = buyerRewardTokens;
    lastBuyerAddress = address(0);
    lastBuyTimestamp = 0;
    totalJackpotRewardedTokens += buyerRewardTokens;

    emit JackpotAwarded(buyerRewardTokens);
  }

  function _processJackpotCap() private {
    if (balanceOf(address(this)) < jackpotCapTokens) return;

    uint tokensToBurn = _getPct(jackpotCapBurnPct, balanceOf(address(this)));
    _tokenTransfer(address(this), address(0), tokensToBurn, false);
    totalJackpotBurnedTokens += tokensToBurn;

    emit JackpotCapReached(totalJackpotBurnedTokens);
  }

  // Utility functions
  function _isBtw(uint value, uint min, uint max) private pure returns (bool) {
    return value >= min && value <= max;
  }

  function _tokensToBnb(uint tokenAmount) private view returns (uint) {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = _wethAddress;
    return _getPct(MAX_PCT + 500, _uniswapV2Router.getAmountsOut(tokenAmount, path)[1]);
  }

  function _getPct(uint pct, uint value) private pure returns (uint) {
    return (value * pct) / MAX_PCT;
  }
}