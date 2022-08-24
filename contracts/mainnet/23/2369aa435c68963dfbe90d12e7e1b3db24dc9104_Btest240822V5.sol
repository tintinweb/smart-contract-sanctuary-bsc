/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address 
    sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}

interface IPancakeFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address token0, address token1) external view returns (address);

}


interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _previousOwner = _owner ;
        _owner = newOwner;
    }

    function previousOwner() public view returns (address) {
        return _previousOwner;
    }
}


contract Btest240822V5 is Context, IBEP20, Ownable {
    
    struct FeeExcluded { 
            bool bothFee;
            bool buyFeeOnly;
            bool sellFeeOnly;
    }

    using SafeMath for uint256;

    IPancakeRouter02 private pancakeV2Router;
    address public pancakeswapPair;


    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public previousRouterAddress;


    string private constant _name = "Btest240822V5";
    string private constant _symbol = "Bt240822V5";
    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _BEACHBurned;
    bool public tradeAllowed = false;
    bool private liquidityAdded = false;
    bool private inSwap = false;
    bool public swapEnabled = false;
    bool public feeEnabled = false;
    
    bool public buyFeeEnabled = false;
    bool public sellFeeEnabled = false;
    

    bool private limitTX = false;
    uint256 private _maxTxAmount = _tTotal;

    uint256 private _contractFee ;
    uint256 private _tempContractFee ;
    
    uint256 private _burn ;
    uint256 private _boostFee ;
    uint256 private _futureFee ;
    uint256 private _conduitFee; 


    uint256 private _buyContractFee;
    uint256 private _buyBurn;
    uint256 private _buyBoostFee ;
    uint256 private _buyFutureFee ;
    uint256 private _buyConduitFee ;


    uint256 private _sellContractFee;
    uint256 private _sellBurn;
    uint256 private _sellBoostFee ;
    uint256 private _sellFutureFee ;
    uint256 private _sellConduitFee ;
    

    uint public currentBuyFee ;
    uint public currentSellFee ;


    uint256 private _maxBuyAmount;
    address payable private _development;
    address payable private _boost;
    address payable private _conduitAddress;


    
    address public targetToken = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3; 
    address public boostFund = 0xa638F4Bb8202049eb4A6782511c3b8A64A2F90a1;


    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => FeeExcluded) private _isExcludedFromFee;
    mapping(address => bool) private _isBlacklisted;

    struct User {
        uint256 buy;
        uint256 sell;
        bool exists;
    }

    event MaxBuyAmountUpdated(uint _maxBuyAmount);
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    
    event ContractBalanceEvent(uint256 newAmount,uint256 oldAmount);
    event ContractTokenBalanceEvent(uint256 newTAmount);
    event AmountDistributEvent(uint256 Amount);
    event FeeDirstributEvent(uint256 futureFee,uint256 boostFee);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;

    }

    constructor(address payable addr1, address payable addr2,address payable addr3 ,address addr4) {
        _development = addr1;
        _boost = addr2;
        _conduitAddress = addr3;
        _rOwned[_msgSender()] = _rTotal;

        _isExcludedFromFee[owner()] = FeeExcluded(true,true,true);
        _isExcludedFromFee[address(this)] = FeeExcluded(true,true,true);
        _isExcludedFromFee[_development] = FeeExcluded(true,true,true);
        _isExcludedFromFee[_boost] = FeeExcluded(true,true,true);
        _isExcludedFromFee[addr4] = FeeExcluded(true,true,true);
        _isExcludedFromFee[_conduitAddress] = FeeExcluded(true,true,true);


        IPancakeRouter02 _pancakeV2Router = IPancakeRouter02(routerAddress);
        pancakeV2Router = _pancakeV2Router;
        pancakeswapPair = IPancakeFactory(pancakeV2Router.factory()).createPair(address(this), pancakeV2Router.WETH());
        _isExcludedFromFee[routerAddress] = FeeExcluded(true,true,true);
        emit Transfer(address(0), _msgSender(), _tTotal);


        _sellContractFee = 12;
        _sellBurn = 3; 
        _sellConduitFee = _sellContractFee.div(3);
        _tempContractFee = 9;
        _sellBoostFee = _tempContractFee.div(4); 
        _sellFutureFee = _tempContractFee.div(1);
        currentSellFee = 15;
        sellFeeEnabled = true;



        _buyContractFee = 8; 
        _buyBurn = 2;
         _buyConduitFee = _buyContractFee.div(2);
        _tempContractFee = 6;
        _buyBoostFee = _tempContractFee.div(4); 
        _buyFutureFee = _tempContractFee.div(1);
        currentBuyFee = 10;
        buyFeeEnabled = true;



    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function setTargetAddress(address target_adr) external onlyOwner {
        targetToken = target_adr;
    }

    function changeDevelopmentAddress(address payable _addy) external onlyOwner {
        _development = _addy;
        _isExcludedFromFee[_development] = FeeExcluded(true,true,true);

    }

    function changeBoostAddress(address payable _addy) external onlyOwner {        
        _boost = _addy;
        _isExcludedFromFee[_boost] = FeeExcluded(true,true,true);
    }
    
    function changeConduitAddress(address payable _address) external onlyOwner {        
        _conduitAddress = _address;
        _isExcludedFromFee[_conduitAddress] = FeeExcluded(true,true,true);
    }

    function setExcludeFromBothFees(address _address) external  onlyOwner {
        _isExcludedFromFee[_address] = FeeExcluded(true,true,true);
    }
    
    function setExcludeFromBuyFeeOnlyFees(address _address) external  onlyOwner {
        _isExcludedFromFee[_address] = FeeExcluded(false,true,false);
    }

    function setExcludeFromSellFeeOnlyFees(address _address) external  onlyOwner {
        _isExcludedFromFee[_address] = FeeExcluded(false,false,true);
    }

    function setIncludeInFees(address _address) external  onlyOwner {
        _isExcludedFromFee[_address] = FeeExcluded(false,false,false);
    }

    function checkExcludedAddress(address _address) public view returns(bool bothFee,bool buyFeeOnly,bool sellFeeOnly){
       FeeExcluded memory feeObj = _isExcludedFromFee[_address];
       return (feeObj.bothFee,feeObj.buyFeeOnly,feeObj.sellFeeOnly);

    }



    function setAddressIsBlackListed(address _address, bool _bool) external onlyOwner {
        _isBlacklisted[_address] = _bool;
    }

    function viewIsBlackListed(address _address) public view returns(bool) {
        return _isBlacklisted[_address];
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
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function setFeeEnabled(bool enable) external onlyOwner {
        feeEnabled = enable;
    }

    
    function enableBuyFee() external onlyOwner {
        buyFeeEnabled = true;
    }

    function disableBuyFee() external onlyOwner {
        buyFeeEnabled = false;
    }

    function enableSellFee() external onlyOwner {
        sellFeeEnabled = true;
    }

    function disableSellFee() external onlyOwner {
        sellFeeEnabled = false;
    }

    function setLimitTx(bool enable) external onlyOwner {
        limitTX = enable;
    }

    function enableTrading(bool enable) external onlyOwner {
        require(liquidityAdded);
        tradeAllowed = enable;
    }

    function changeRouterAddress(address _addr) external onlyOwner {
        previousRouterAddress = routerAddress;
        routerAddress = _addr;
        _isExcludedFromFee[previousRouterAddress] = FeeExcluded(false,false,false);


        IPancakeRouter02 _pancakeV2Router = IPancakeRouter02(routerAddress);
        pancakeV2Router = _pancakeV2Router;    
        _isExcludedFromFee[routerAddress] = FeeExcluded(true,true,true);
    }

    

    function addLiquidity() external onlyOwner() {
        
        _approve(address(this), address(pancakeV2Router), _tTotal);
        pancakeV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        swapEnabled = true;
        liquidityAdded = true;
        feeEnabled = true;
        tradeAllowed  = true;
        limitTX = true;
        _maxTxAmount = 100000000 * 10**9; 
        _maxBuyAmount = 20000000 * 10**9; 
        IBEP20(pancakeswapPair).approve(address(pancakeV2Router),type(uint256).max);
    }


    function manualSwapTokensForEth() external onlyOwner() {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualDistributeETH() external onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        distributeETH(contractETHBalance);
    }

    function manualSwapEthForTargetToken(uint amount) external onlyOwner() {
        swapETHfortargetToken(amount);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        require(maxTxPercent > 0, "Amount must be greater than 0");
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
        emit MaxTxAmountUpdated(_maxTxAmount);
    }


    function amountInPool() public view returns (uint) {
        return balanceOf(pancakeswapPair);
    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal,"Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool  chargeTax = true;
        bool _exludeFee = false;
    
        if (from != owner() && to != owner() && !_isExcludedFromFee[from].bothFee && !_isExcludedFromFee[to].bothFee) {
            require(tradeAllowed);
            require(!_isBlacklisted[from] && !_isBlacklisted[to]);

            if (from == pancakeswapPair && to != address(pancakeV2Router)) {
                if (limitTX) {
                    require(amount <= _maxTxAmount,"Amount is greater then maxTxAmount");
                }
                chargeTax = buyFeeEnabled;
                setBuyFeeOnTrancation();

                _exludeFee = _isExcludedFromFee[to].buyFeeOnly;
                

                uint contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    swapETHfortargetToken(address(this).balance);
                }
            }

            if(to == address(pancakeswapPair) || to == address(pancakeV2Router) ) {
                
                chargeTax = sellFeeEnabled;
                setSellFeeOnTrancation();
                _exludeFee = _isExcludedFromFee[from].sellFeeOnly;


                uint contractTokenBalance = balanceOf(address(this));
                if (!inSwap && from != pancakeswapPair && swapEnabled) {
                    
                    if (limitTX) {
                    require(amount <= balanceOf(pancakeswapPair).mul(3).div(100) && amount <= _maxTxAmount,"Amount is greater then maxTxAmount and 3% of liquidity pool");
                    }

                    uint initialETHBalance = address(this).balance;

                    if (contractTokenBalance > 0){
                        emit ContractTokenBalanceEvent(contractTokenBalance);
                        if(_conduitFee > 0){
                            uint conduitShare = contractTokenBalance.div(_conduitFee);
                            contractTokenBalance = contractTokenBalance.sub(conduitShare);
                            _transfer(address(this), _conduitAddress, conduitShare);
                        }

                    emit ContractTokenBalanceEvent(contractTokenBalance);

                    swapTokensForEth(contractTokenBalance);
                    uint newETHBalance = address(this).balance;
                    emit ContractBalanceEvent( newETHBalance, initialETHBalance);

                    uint ethToDistribute = newETHBalance.sub(initialETHBalance);
                    if (ethToDistribute > 0) {
                        distributeETH(ethToDistribute);
                    }

                    }
                    
                }
                chargeTax = sellFeeEnabled;
                setSellFeeOnTrancation();
                _exludeFee = _isExcludedFromFee[from].sellFeeOnly;

            }
        }
    
        
        
        bool takeFee = true;

        if (_isExcludedFromFee[from].bothFee || _isExcludedFromFee[to].bothFee || !feeEnabled || !chargeTax || _exludeFee) {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
        removeAllFee;
    }


    function removeAllFee() private {
        if (_contractFee == 0 && _burn == 0) return;
        _contractFee = 0;
        _burn = 0;
        _boostFee = 0 ;
        _futureFee =0 ;
        _conduitFee = 0;
    }

    function setBuyFeeOnTrancation() private {
        _contractFee = _buyContractFee;
        _burn = _buyBurn;
        _boostFee = _buyBoostFee ;
        _futureFee =_buyFutureFee ;
        _conduitFee = _buyConduitFee;
    }

    function setSellFeeOnTrancation() private {
        _contractFee = _sellContractFee;
        _burn = _sellBurn;
        _boostFee = _sellBoostFee ;
        _futureFee =_sellFutureFee ;
        _conduitFee = _sellConduitFee;
    }


    function setBuyFee(uint256  _per ) external onlyOwner() {

        if (_per == 0 )
        {
        _buyContractFee = 0;
        _buyBurn = 0;
        _buyBoostFee =0;
        _buyFutureFee = 0;
        _buyConduitFee = 0;
        currentBuyFee = 0;

        buyFeeEnabled = false;
        
        }else if (_per == 5){
        _buyContractFee = 4;
        _buyBurn = 1;
        _buyConduitFee = _buyContractFee.div(1);
        _tempContractFee = 3;
        _buyBoostFee = _tempContractFee.div(2); 
        _buyFutureFee = _tempContractFee.div(1);

        currentBuyFee = 5;

        buyFeeEnabled = true;

        }else if (_per == 10){
        _buyContractFee = 8;
        _buyBurn = 2;
         _buyConduitFee = _buyContractFee.div(2);
        _tempContractFee = 6;
        _buyBoostFee = _tempContractFee.div(4); 
        _buyFutureFee = _tempContractFee.div(1);
        currentBuyFee = 10;
        buyFeeEnabled = true;


        }else {
            revert(" Invalid input for buy tax. supported input are  5% and 10%");
        }
 
    }

    function setSellFee(uint256  _per ) external onlyOwner() {
        if (_per == 0 )
        {
        _sellContractFee = 0;
        _sellBurn = 0;
        _sellBoostFee = 0;
        _sellFutureFee = 0;
        _sellConduitFee = 0;
        currentSellFee = 0;

        sellFeeEnabled = false;
        }else if (_per == 10){
        _sellContractFee = 8; 
        _sellBurn = 2;
        _sellConduitFee = _sellContractFee.div(2);
        _tempContractFee = 6;
        _sellBoostFee = _tempContractFee.div(4); 
        _sellFutureFee = _tempContractFee.div(1); 

        currentSellFee = 10;

        sellFeeEnabled = true;
        }else if (_per == 15){
        _sellContractFee = 12;
        _sellBurn = 3; 
        _sellConduitFee =_sellContractFee.div(3);
        _tempContractFee = 9;
        _sellBoostFee = _tempContractFee.div(4); 
        _sellFutureFee = _tempContractFee.div(1);

        currentSellFee = 15;
        sellFeeEnabled = true;
        }
        else {
            revert(" Invalid input for sell tax. supported input are  10% and 15%");
        }
 
    }


    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) removeAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        (uint256 tAmount, uint256 tBurn) = _BEACHEthBurn(amount); 
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 tTeam) = _getValues(tAmount, tBurn); 
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
        _takeTeam(tTeam);
        emit Transfer(sender, recipient, tTransferAmount); 
    }

    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate = _getRate(); 
        uint256 rTeam = tTeam.mul(currentRate); 
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam); 
    }

    function _BEACHEthBurn(uint amount) private returns (uint, uint) {
        uint orgAmount = amount; 
        uint256 currentRate = _getRate(); 
        uint256 tBurn = amount.mul(_burn).div(100); 
        uint256 rBurn = tBurn.mul(currentRate); 
        _tTotal = _tTotal.sub(tBurn);  
        _rTotal = _rTotal.sub(rBurn);  
        _BEACHBurned = _BEACHBurned.add(tBurn); 
        return (orgAmount, tBurn);
    }


    function _getValues(uint256 tAmount, uint256 tBurn) private view returns (uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tTeam) = _getTValues(tAmount, _contractFee, tBurn);
        uint256 currentRate = _getRate(); 
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tTeam, tBurn, currentRate);
        return (rAmount, rTransferAmount, tTransferAmount, tTeam); 
    }

    function _getTValues(uint256 tAmount, uint256 teamFee, uint256 tBurn) private pure returns (uint256,  uint256) {
        uint256 tTeam = tAmount.mul(teamFee).div(100); 
        uint256 tTransferAmount = tAmount.sub(tTeam).sub(tBurn); 
        return (tTransferAmount, tTeam); 
    }

 
    function _getRValues(uint256 tAmount, uint256 tTeam,uint256 tBurn, uint256 currentRate) private pure returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rBurn =  tBurn.mul(currentRate); 
        uint256 rTransferAmount = rAmount.sub(rTeam).sub(rBurn); 
        return (rAmount, rTransferAmount); 
    }


    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal; 
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();
        _approve(address(this), address(pancakeV2Router), tokenAmount);
        pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

     function swapETHfortargetToken(uint ethAmount) private {
        address[] memory path = new address[](2);
        path[0] = pancakeV2Router.WETH();
        path[1] = address(targetToken);

        _approve(address(this), address(pancakeV2Router), ethAmount);
        pancakeV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(ethAmount,path,address(boostFund),block.timestamp);
    }

    function distributeETH(uint256 amount) private {
            emit FeeDirstributEvent( _futureFee, _boostFee);
            emit AmountDistributEvent(amount);
            if(_futureFee > 0 && _boostFee > 0){
            _development.transfer(amount.div(_futureFee));   
            _boost.transfer(amount.div(_boostFee));
            }
        }
    

    receive() external payable {}
}