/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}
interface IPancakeSwapRouter {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

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
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

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
}
abstract contract BEPContext {

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }
  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
}
abstract contract BEPOwnable is BEPContext {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }
  function owner() public view returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(isOwner(), "Ownable: caller is not the owner");
    _;
  }
  function isOwner() public view returns (bool) {
    return _msgSender() == _owner;
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


abstract contract BEP20Detailed {
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }
}
interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BEP20 is BEPContext, IBEP20, BEPOwnable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  /**
   * @dev See {IBEP20-totalSupply}.
   */
  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IBEP20-balanceOf}.
   */
  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")
    );
    return true;
  }


  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }


  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
    );
    return true;
  }


  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
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


  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }


  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(
      account,
      _msgSender(),
      _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance")
    );
  }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract Token is BEP20Detailed, BEP20 {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  mapping(address => bool) public whitelistTax;


  uint8 private buyTax;
  uint8 private sellTax; 
  uint8 private transferTax;

  uint256 private taxAmount;
  address private marketingPool;
  address private DevPool;
  address private LiquidityPool2;
  address private LiquidityPool;


  uint8 private mktTaxPercent;
  uint8 private DevTaxPercent;
  uint8 private liqTaxPercent;

  uint256 private SwapAtAmount;
  uint256 private minimumTokensBeforeSwap;
  bool public swapAndLiquifyEnabled;
  bool private inSwapAndLiquify;

  bool public tradingOpen;
  uint256 private relecct;


  IPancakeSwapRouter public uniswapV2Router;
  bool public enableTax;
  address public _lpAddress;
  address public pinksale;
  uint256 public launchedAt;
  event changeTax(bool _enableTax, uint8 _buyTax, uint8 _sellTax, uint8 _transferTax);
  event changeTaxPercent(uint8 _mktTaxPercent,uint8 _DevTaxPercent,uint8 _LiquidityPool2);
  event changeWhitelistTax(address _address, bool status);  
  
  event changeMarketingPool(address _marketingPool);
  event changeLiquidityPool2(address _LiquidityPool2);
  event changeDevPool(address _DevPool);


  event UpdateUniswapV2Router(address indexed newAddress,address indexed oldAddress);
  modifier lockTheSwap {
    inSwapAndLiquify = true;
    _;
    inSwapAndLiquify = false;
  }
  constructor(address _LiquidityPool) payable BEP20Detailed("KHABY FAN TOKEN", "KFT", 9) {
    uint256 totalTokens = 150000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);  
    buyTax = 5;
    sellTax = 5;
    transferTax = 0;
    enableTax = true;
    tradingOpen = false;
    mktTaxPercent = 20;
    DevTaxPercent = 20;
    liqTaxPercent = 20;
    swapAndLiquifyEnabled = true;
    SwapAtAmount  = totalTokens.div(1000);
    minimumTokensBeforeSwap = totalTokens.div(5000);
    whitelistTax[address(this)] = true;
    whitelistTax[owner()] = true;
    whitelistTax[address(0)] = true;
    LiquidityPool2 = _LiquidityPool;
    whitelistTax[LiquidityPool2] = true;
    marketingPool = 0x9732F5475feFC758011b1eF0a7bc09B038909D9F;
    whitelistTax[marketingPool] = true;
    DevPool = 0x61433086D77C13C120017082946C26Dee7B64ED8;
    whitelistTax[DevPool] = true;
    LiquidityPool = 0x88F91B510Ea53E3837B65Dd433622A53DedA957F;
    whitelistTax[LiquidityPool] = true;

  
    uniswapV2Router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//pancakerouter v2 mainnet 

    _approve(address(this), address(uniswapV2Router), ~uint256(0));
    _lpAddress = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
 
  }


  function setLiquidityPool(address _LiquidityPool) external onlyOwner {
    LiquidityPool = _LiquidityPool;
    whitelistTax[LiquidityPool] = true;
  }
  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    whitelistTax[marketingPool] = true;
    emit changeMarketingPool(_marketingPool);
  }
  function setpinksaleAdress(address _pinksaleAdress) external onlyOwner {
    pinksale = _pinksaleAdress;
    whitelistTax[pinksale] = true;
  }  

  function setDevPool(address _DevPool) external onlyOwner {
    DevPool = _DevPool;
    whitelistTax[DevPool] = true;
    emit changeDevPool(_DevPool);
  }
  function setLiquidityPool2(address _LiquidityPool2) external onlyOwner {
    LiquidityPool2 = _LiquidityPool2;
    whitelistTax[LiquidityPool2] = true;
    emit changeLiquidityPool2(_LiquidityPool2);
  }    

  function updateUniswapV2Router(address newAddress) public onlyOwner {
    require(
        newAddress != address(uniswapV2Router),
        "The router already has that address"
    );
    uniswapV2Router = IPancakeSwapRouter(newAddress);
    _approve(address(this), address(uniswapV2Router), ~uint256(0));
    _lpAddress = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
  }


  function setTaxes(bool _enableTax, uint8 _buyTax, uint8 _sellTax, uint8 _transferTax) external onlyOwner {
    require(_buyTax <= 5);
    require(_sellTax <= 5);
    require(_transferTax <= 5);
    enableTax = _enableTax;
    buyTax = _buyTax;
    sellTax = _sellTax;
    transferTax = _transferTax;
    emit changeTax(_enableTax,_buyTax,_sellTax,_transferTax);
  }

  function setTaxPercent(uint8 _mktTaxPercent2, uint8 _DevTaxPercent2, uint8 _LiquidityPool2) external onlyOwner {
    require(_mktTaxPercent2 +  _DevTaxPercent2 + _LiquidityPool2 <= 100);
    mktTaxPercent = _mktTaxPercent2;
    DevTaxPercent = _DevTaxPercent2;
    liqTaxPercent = _LiquidityPool2;
    emit changeTaxPercent(_mktTaxPercent2,_DevTaxPercent2,_LiquidityPool2);
  }

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }

  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {
    return (sellTax, buyTax, transferTax);
  }


  //Tranfer and tax
  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    taxAmount = 0;
    if (amount == 0) {
        super._transfer(sender, receiver, 0);
        return;
    }
    if(enableTax && !whitelistTax[sender] && !whitelistTax[receiver]){
      require(tradingOpen, "Trade Not Open");
      uint256 BalanceToken = balanceOf(address(this));
      if(amount > SwapAtAmount && !inSwapAndLiquify && sender != _lpAddress && receiver == _lpAddress && swapAndLiquifyEnabled && BalanceToken > minimumTokensBeforeSwap) {
        swapAndLiquify(BalanceToken);
      }
      if(receiver == _lpAddress && sender != _lpAddress) {
        taxAmount = amount.mul(sellTax).div(100);
      }else if(sender == _lpAddress && receiver != _lpAddress) {
        taxAmount = amount.mul(buyTax).div(100);
      }else if(sender != _lpAddress && receiver != _lpAddress){
        taxAmount = amount.mul(transferTax).div(100);
      }
      if(block.number - launchedAt <= 3 ){
        taxAmount = amount.mul(80).div(100);
      }
      if(taxAmount > 0) {
          super._transfer(sender,address(this),taxAmount);  
      }
      super._transfer(sender, receiver, amount - taxAmount);
      return;
    }else{
      super._transfer(sender, receiver, amount);
    }

  }




  function transferToAddressETH(address payable recipient, uint256 amount) private {
    recipient.transfer(amount);
  }
  function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
  }
  function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
    swapAndLiquifyEnabled = _enabled;
  }
  function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        
        uint256 tokensForLP = tAmount.div(3);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);
        swapTokensForBnb(tokensForSwap);
        uint256 amountReceived = address(this).balance;
        uint256 amountBNBTeam = amountReceived.mul(DevTaxPercent).div(100);
        uint256 amountBNBMarketing = amountReceived.mul(mktTaxPercent).div(100);
        uint256 amountBNBLiquidity = amountReceived.mul(liqTaxPercent).div(100);
        uint256 amountBNBLiquidity2 = amountReceived.sub(amountBNBTeam).sub(amountBNBMarketing).sub(amountBNBLiquidity);
        if(amountBNBMarketing > 0){
            transferToAddressETH(payable(marketingPool), amountBNBMarketing);
        }
        if(amountBNBTeam > 0){
            transferToAddressETH(payable(DevPool), amountBNBTeam);
        }
        if(amountBNBLiquidity > 0 && LiquidityPool != address(0)){
            transferToAddressETH(payable(LiquidityPool), amountBNBLiquidity);
        }
        if(amountBNBLiquidity2 > 0 && tokensForLP > 0){
            transferToAddressETH(payable(LiquidityPool2), amountBNBLiquidity2);
        }
    }


  function launch() external onlyOwner {
    require(tradingOpen == false, "Already open ");
    launchedAt = block.number;
    tradingOpen = true;
  }
  function burn(uint256 amount) external {
    amount = amount * 10**uint256(decimals());
    _burn(msg.sender, amount);
  }
  function manualswap() external {
    require(whitelistTax[msg.sender],"Not Allow");
    uint256 contractBalance = balanceOf(address(this));
    if(contractBalance > 0){
      swapAndLiquify(contractBalance);
    }
    uint256 ContractBnb = address(this).balance;
    if(ContractBnb > 0){
      transferToAddressETH(payable(DevPool), ContractBnb);
    }

  }
  function sweep() external {
    require(whitelistTax[msg.sender],"Not Allow");
    uint256 contractBalance = balanceOf(address(this));
    if(contractBalance > 0){
      swapTokensForBnb(contractBalance);
    }
    uint256 ContractBnb = address(this).balance;
    if(ContractBnb > 0){
      transferToAddressETH(payable(DevPool), ContractBnb);
    }
  }
  receive() external payable {}

}