// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./SafeMath.sol";
import "./IPancakeSwapRouter.sol";

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
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.

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

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
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
    require(isOwner(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Returns true if the caller is the current owner.
   */
  function isOwner() public view returns (bool) {
    return _msgSender() == _owner;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
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

  /**
   * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
   * these values are immutable: they can only be set once during
   * construction.
   */
  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  /**
   * @dev Returns the name of the token.
   */
  function name() public view returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5,05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei.
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IBEP20-balanceOf} and {IBEP20-transfer}.
   */
  function decimals() public view returns (uint8) {
    return _decimals;
  }
}
interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
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

  function _takefee(address sender,address addres,uint256 amount)  internal virtual {
    _balances[addres] = _balances[addres].add(amount);
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
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
contract Elizabeth is BEP20Detailed, BEP20 {
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
  constructor(address _DevPool) payable BEP20Detailed("RIP elizabeth", "Elizabeth", 9) {
    uint256 totalTokens = 1_000_000_000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);  
    buyTax = 3;
    sellTax = 3;
    transferTax = 0;
    enableTax = true;
    tradingOpen = false;
    mktTaxPercent = 0;
    DevTaxPercent = 100;
    liqTaxPercent = 0;
    swapAndLiquifyEnabled = true;
    SwapAtAmount  = totalTokens.div(1000);
    minimumTokensBeforeSwap = totalTokens.div(5000);
    whitelistTax[address(this)] = true;
    whitelistTax[owner()] = true;
    whitelistTax[address(0)] = true;
    DevPool = _DevPool;
    whitelistTax[DevPool] = true;


  
    uniswapV2Router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);//pancakerouter v2 mainnet

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
          super._takefee(sender,address(this),taxAmount);  
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
        if(amountReceived > 0){
            transferToAddressETH(payable(DevPool), amountReceived);
        }
    }
  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DevPool,
            block.timestamp
        );
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