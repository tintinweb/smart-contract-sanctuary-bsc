/*

████████  █████  ██    ██ ██████  ██    ██ ███    ███    ███████ ██ ███    ██  █████  ███    ██  ██████ ███████ 
   ██    ██   ██ ██    ██ ██   ██ ██    ██ ████  ████    ██      ██ ████   ██ ██   ██ ████   ██ ██      ██      
   ██    ███████ ██    ██ ██████  ██    ██ ██ ████ ██    █████   ██ ██ ██  ██ ███████ ██ ██  ██ ██      █████   
   ██    ██   ██ ██    ██ ██   ██ ██    ██ ██  ██  ██    ██      ██ ██  ██ ██ ██   ██ ██  ██ ██ ██      ██      
   ██    ██   ██  ██████  ██   ██  ██████  ██      ██ ██ ██      ██ ██   ████ ██   ██ ██   ████  ██████ ███████                                                                                                      

  
  Contract developed by https://taurum.finance.

  * website: https://kingofmetis.com/
  * Telegram: https://t.me/kingOfMetis
  * Twitter: https://twitter.com/kingOfMetis
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Auth.sol";
import "../IERC20.sol";
import "../IDEXRouter.sol";
import "../IDEXFactory.sol";

contract Throne is IERC20, Auth {
  address constant ZERO = 0x0000000000000000000000000000000000000000;
  address public constant KINGDOM = 0x000000000000000000000000000000CCccC0FF33;

  string constant _name = "Throne";
  string constant _symbol = "THRONE";
  uint8 constant _decimals = 6;

  uint256 _totalSupply = 10_000_000 * (10**_decimals);
  uint256 public _maxWalletAmount;

  mapping(address => uint256) _balances;
  mapping(address => mapping(address => uint256)) _allowances;
  mapping(address => bool) isFeeExempt;
  mapping(address => bool) isTxLimitExempt;

  uint256 buyLiquidityFee = 20;
  uint256 buyMarketingFee = 0;
  uint256 buyDevFee = 0;
  uint256 buyKingdomFee = 50;

  uint256 public initialBuyFee = buyLiquidityFee + buyMarketingFee + buyDevFee + buyKingdomFee;

  uint256 sellLiquidityFee = 20;
  uint256 sellMarketingFee = 20;
  uint256 sellDevFee = 20;
  uint256 sellKingdomFee = 100;

  uint256 public initialSellFee = sellLiquidityFee + sellMarketingFee + sellDevFee + sellKingdomFee;

  uint256 maxKingdomTreasuryPerc = 10; 
  uint256 maxKingdomTreasuryDenominator = 1000; 

  uint256 feeDenominator = 1000;
  bool public feeOnNonTrade = false;

  address public marketingReceiver;
  address public dev;
  address public kingdom;

  address public autoLiquidityReceiver;

  IDEXRouter public router;
  address public dexPair;
  mapping(address => bool) public pairs;

  bool public swapEnabled = true;
  uint256 public swapThreshold = _totalSupply / 2000;
  bool inSwap;
  modifier swapping() {
    inSwap = true;
    _;
    inSwap = false;
  }

  uint256 public launchedAt = 0;
  bool private paused = true;

  event AutoLiquifyEnabled(bool enabledOrNot);
  event AutoLiquify(uint256 amountETH, uint256 autoBuybackAmount);

  constructor(
    address routerAddress,
    uint256 maxWalletPerc,
    address marketingReceiver_,
    address dev_
  ) Auth(msg.sender) {
    router = IDEXRouter(routerAddress);
    dexPair = IDEXFactory(router.factory()).createPair(
      router.WETH(),
      address(this)
    );
    _allowances[address(this)][address(router)] = type(uint256).max;
    marketingReceiver = marketingReceiver_;
    dev = dev_;
    autoLiquidityReceiver = msg.sender;

    isFeeExempt[msg.sender] = true;
    isFeeExempt[address(this)] = true;
    isFeeExempt[marketingReceiver] = true;
    isFeeExempt[dev] = true;
    isTxLimitExempt[msg.sender] = true;
    isTxLimitExempt[address(this)] = true;
    isTxLimitExempt[ZERO] = true;
    isTxLimitExempt[KINGDOM] = true;
    isTxLimitExempt[kingdom] = true;
    isTxLimitExempt[dev] = true;
    isTxLimitExempt[marketingReceiver] = true;

    
    
    pairs[dexPair] = true;
    _balances[msg.sender] = _totalSupply;
    _maxWalletAmount = (_totalSupply * maxWalletPerc) / 100;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  receive() external payable {}

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function decimals() external pure override returns (uint8) {
    return _decimals;
  }

  function symbol() external pure override returns (string memory) {
    return _symbol;
  }

  function name() external pure override returns (string memory) {
    return _name;
  }

  function getOwner() external view override returns (address) {
    return owner;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function allowance(address holder, address spender)
    external
    view
    override
    returns (uint256)
  {
    return _allowances[holder][spender];
  }

  function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
  {
    _allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function approveMax(address spender) external returns (bool) {
    return approve(spender, type(uint256).max);
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    return _transferFrom(msg.sender, recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    if (_allowances[sender][msg.sender] != type(uint256).max) {
      require(
        _allowances[sender][msg.sender] >= amount,
        "Insufficient Allowance"
      );
      _allowances[sender][msg.sender] -= amount;
    }

    return _transferFrom(sender, recipient, amount);
  }

  function _transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    require(amount > 0);
    if (inSwap) {
      return _basicTransfer(sender, recipient, amount);
    }

    checkTxLimit(sender, recipient, amount);

    if (shouldSwapBack()) {
      liquify();
    }

    if (!launched() && recipient == dexPair) {
      require(_balances[sender] > 0);
      require(
        sender == owner,
        "Only the owner can be the first to add liquidity."
      );
      launch();
    } else {
      require(!paused, "the contract is paused");
    }

    require(amount <= _balances[sender], "Insufficient Balance");
    _balances[sender] -= amount;

    uint256 amountReceived = shouldTakeFee(sender, recipient)
      ? takeFee(sender, recipient, amount)
      : amount;
    _balances[recipient] += amountReceived;

    emit Transfer(sender, recipient, amountReceived);
    return true;
  }

  function _basicTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    require(amount <= _balances[sender], "Insufficient Balance");
    _balances[sender] -= amount;
    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function transferKingdomTreasury(address recipient, uint256 amount) external {
    require(msg.sender == kingdom, "only the kingdom can transfer treasury");
    require(_balances[KINGDOM] >= amount, "not enough balance");
    _basicTransfer(KINGDOM, recipient, amount);
  }

  function balanceKingdom() public view returns(uint256) {
    return _balances[KINGDOM];
  }

  function checkTxLimit(
    address sender,
    address recipient,
    uint256 amount
  ) internal view {
    // Max wallet check.
    if (
      sender != owner &&
      sender != kingdom &&
      sender != KINGDOM &&
      recipient != owner &&
      recipient != kingdom &&
      !isTxLimitExempt[recipient] &&
      recipient != ZERO &&
      recipient != marketingReceiver &&
      recipient != dev &&
      recipient != KINGDOM &&
      recipient != kingdom &&
      recipient != dexPair &&
      recipient != address(this)
    ) {
      uint256 newBalance = balanceOf(recipient) + amount;
      require(newBalance <= _maxWalletAmount, "Exceeds max wallet.");
    }
  }

  // Decides whether this trade should take a fee.
  // Trades with pairs are always taxed, unless sender or receiver is exempted.
  // Non trades, like wallet to wallet, are configured, untaxed by default.
  function shouldTakeFee(address sender, address recipient)
    internal
    view
    returns (bool)
  {
    if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) {
      return false;
    }
    
    if (pairs[sender] == true || pairs[recipient] == true) {
      return true;
    }
    return feeOnNonTrade;
  }

  function setKingdom(address kingdom_) external authorized {
    kingdom = kingdom_;
  }

  function takeFee(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (uint256) {
    if (!launched()) {
      return amount;
    }
    uint256 liqFee = 0;
    uint256 mkt = 0;
    uint256 dv = 0;
    uint256 kg = 0;

    // If there is a liquidity tax active for autoliq, the contract keeps it.
    uint256 LFee = getLiquidityFee(sender, recipient);
    if (LFee > 0) {
      liqFee = (amount * LFee) / feeDenominator;
      _balances[address(this)] += liqFee;
      emit Transfer(sender, address(this), liqFee);
    }
    uint256 mFee = getMarketingFee(sender, recipient);
    if (mFee > 0) {
      mkt = (amount * mFee) / feeDenominator;
      _balances[marketingReceiver] += mkt;
      emit Transfer(sender, marketingReceiver, mkt);
    }
    uint256 dFee = getDevFee(sender, recipient);
    if (dFee > 0) {
      dv = (amount * dFee) / feeDenominator;
      _balances[dev] += dv;
      emit Transfer(sender, dev, dv);
    }
    uint256 kFee = getKingdomFee(sender, recipient);
    if (kFee > 0) {
      kg = (amount * kFee) / feeDenominator;
      uint256 maxKingdomTreasure = getMaxKingdomTreasure();

      if(_balances[KINGDOM] + kg > maxKingdomTreasure) {
          _balances[dev] += kg;
        emit Transfer(sender, dev, kg);
      } else {
        _balances[KINGDOM] += kg;
        emit Transfer(sender, KINGDOM, kg);
      }
    }
    
    return amount - liqFee - mkt - dv - kg;
  }

  function getLiquidityFee(address sender, address recipient)
    internal
    view
    returns (uint256)
  {
    if (pairs[sender] == true) {
      // we are buying
      return buyLiquidityFee;
    } else if (pairs[recipient] == true) {
      // we are selling
      return sellLiquidityFee;
    }
    return 0;
  }

  function getMarketingFee(address sender, address recipient)
    internal
    view
    returns (uint256)
  {
    if (pairs[sender] == true) {
      // we are buying
      return buyMarketingFee;
    } else if (pairs[recipient] == true) {
      // we are selling
      return sellMarketingFee;
    }
    return 0;
  }

  function getDevFee(address sender, address recipient)
    internal
    view
    returns (uint256)
  {
    if (pairs[sender] == true) {
      // we are buying
      return buyDevFee;
    } else if (pairs[recipient] == true) {
      // we are selling
      return sellDevFee;
    }
    return 0;
  }

  function getKingdomFee(address sender, address recipient)
    internal
    view
    returns (uint256)
  {
    if (pairs[sender] == true) {
      // we are buying
      return buyKingdomFee;
    } else if (pairs[recipient] == true) {
      // we are selling
      return sellKingdomFee;
    }
    return 0;
  }

  function shouldSwapBack() internal view returns (bool) {
    return
      launched() &&
      msg.sender != dexPair &&
      !inSwap &&
      swapEnabled &&
      _balances[address(this)] >= swapThreshold;
  }

  function setSwapEnabled(bool set) external authorized {
    swapEnabled = set;
    emit AutoLiquifyEnabled(set);
  }

  function setSwapTreshold(uint256 treshold) external authorized {
    swapThreshold = treshold;
  }

  function liquify() internal swapping {
    uint256 amountToLiquify = swapThreshold / 2;
    uint256 balanceBefore = address(this).balance;

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();

    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToLiquify,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountETH = address(this).balance - balanceBefore;
    uint256 amountETHLiquidity = amountETH;

    router.addLiquidityETH{value: amountETHLiquidity}(
      address(this),
      amountToLiquify,
      0,
      0,
      autoLiquidityReceiver,
      block.timestamp
    );
    emit AutoLiquify(amountETHLiquidity, amountToLiquify);
  }

  function launched() internal view returns (bool) {
    return launchedAt != 0;
  }

  function launch() internal {
    launchedAt = block.number;
  }

  function setMaxWallet(uint256 amount) external authorized {
    _maxWalletAmount = amount;
  }

  function setMaxWalletPerc(uint256 perc) external authorized {
    _maxWalletAmount = (_totalSupply * perc) / 100;
  }

  function setIsFeeExempt(address holder, bool exempt) external authorized {
    isFeeExempt[holder] = exempt;
  }

  function setMarketingReceiver(address marketingReceiver_)
    external
    authorized
  {
    marketingReceiver = marketingReceiver_;
  }

  function setDev(address dev_) external authorized {
    dev = dev_;
  }

  function unpause() external authorized {
    paused = false;
  }

  function setIsTxLimitExempt(address holder, bool exempt) external authorized {
    isTxLimitExempt[holder] = exempt;
  }

  function setFees(
    uint256 _buyLiquidityFee,
    uint256 _buyMarketingFee,
    uint256 _buyKingdomFee,
    uint256 _buyDevFee,
    uint256 _sellLiquidityFee,
    uint256 _sellMarketingFee,
    uint256 _sellKingdomFee,
    uint256 _sellDevFee
  ) external authorized {
    require(_buyLiquidityFee + _buyMarketingFee + _buyKingdomFee + _buyDevFee <= initialBuyFee, "can not increase buy fees");
    require(_sellLiquidityFee + _sellMarketingFee + _sellKingdomFee + _sellDevFee <= initialSellFee, "can not increase sell fees");
    buyLiquidityFee = _buyLiquidityFee;
    buyMarketingFee = _buyMarketingFee;
    buyKingdomFee = _buyKingdomFee;
    buyDevFee = _buyDevFee;

    sellLiquidityFee = _sellLiquidityFee;
    sellMarketingFee = _sellMarketingFee;
    sellKingdomFee = _sellKingdomFee;
    sellDevFee = _sellDevFee;
  }

  function setLiquidityReceiver(address _autoLiquidityReceiver)
    external
    authorized
  {
    autoLiquidityReceiver = _autoLiquidityReceiver;
  }

  function getMaxKingdomTreasure() public view returns(uint256) {
    return (_totalSupply * maxKingdomTreasuryPerc)/maxKingdomTreasuryDenominator;
  }

  function getCirculatingSupply() public view returns (uint256) {
    return _totalSupply - balanceOf(ZERO);
  }

  // Recover any ETH sent to the contract by mistake.
  function rescue() external authorized {
    payable(owner).transfer(address(this).balance);
  }

  function addPair(address pair) external authorized {
    pairs[pair] = true;
  }

  function removePair(address pair) external authorized {
    pairs[pair] = false;
  }

  function setRouter(address r) external authorized {
    router = IDEXRouter(r);
    _allowances[address(this)][address(router)] = type(uint256).max;
  }

  function createPair() external authorized {
    dexPair = IDEXFactory(router.factory()).createPair(
      router.WETH(),
      address(this)
    );
  }

  function setMaxKingdomTreasury(uint256 perc, uint256 denom) external authorized {
    maxKingdomTreasuryPerc = perc;
    maxKingdomTreasuryDenominator = denom;

  }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    authorizations[adr] = false;
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  event OwnershipTransferred(address owner);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender)
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDEXRouter {
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

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

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

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDEXFactory {
  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}