//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.2;

import "../interface/IERC20.sol";
import "../library/safemath.sol";
import "./Ownable.sol";
// import "../library/address.sol";

import "../interface/IUniswapV2Factory.sol";
import "../interface/IUniswapV2Router02.sol";
import "../interface/IUniswapV2Pair.sol";

import "../interface/IFomo.sol";
import "../interface/IWrap.sol";

contract CatToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    // using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1 * 10**18 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    string private _name = "Current Assets"; 
    string private _symbol = "CAT"; 
    uint8 private _decimals = 9;
    
    bool private feeIt = true;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public _maxTxAmount = 20 * 10**12 * 10**9; 
    uint256 public _maxTotalBuyAmount = 200 * 10**12 * 10**9;
    uint256 private numTokensSellToAddToLiquidity = 5000 * 10**8 * 10**9; 
    uint    public  _minLiquidAmount = 10000000000000000*10**9;

    address public constant blackHole = 0x0000000000000000000000000000000000000001;
    address private devReceiver;
    address public fomoReceiver;
    uint256 private enterCount = 0;
    uint256 public fomoMin = 1000000 * 10**9; 
    IERC20 public immutable usdt;// = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IWrap public wrap;


    bool public _openTrade;
    address public projectAddr;

    mapping (address => address) public teamLevelup;
    mapping (address => bool) public teams;
    
    enum TransferType {TransferStandard, TransferToExcluded, TransferFromExcluded,TransferBothExcluded}

    struct TransferInfo{
        address sender;
        address recipient;
        uint256 tAmount;
        TransferType transferType;
    }

    struct FeeInfo {
        uint tTransferAmount;
        uint tFomo;
        uint tDev;
        uint tLiquidity;
        uint tFee;
    }
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier transferCounter {
        enterCount = enterCount.add(1);
        _;
        enterCount = enterCount.sub(1, "transfer counter");
    }
    
    constructor (address _routeAddr, address _usdtAddr, address _devReceiver) {
        _openTrade = false;

        _rOwned[_msgSender()] = _rTotal;
        devReceiver = _devReceiver;

        usdt = IERC20(_usdtAddr);
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routeAddr);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _usdtAddr);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_devReceiver] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
 
    function setDev(address _dev) public {
        require(_msgSender() == devReceiver || _msgSender() == owner(), "fail");
        devReceiver = _dev;
        _isExcludedFromFee[_dev] = true;
    }

    function setFomo(address _fomo) public {
        require(_msgSender() == owner(), "fail");
        fomoReceiver = _fomo;
        _isExcludedFromFee[_fomo] = true;
    }

    function setWrap(IWrap _wrap) public {
        require(_msgSender() == owner(), "fail");
        wrap = _wrap;
        _isExcludedFromFee[address(_wrap)] = true;
    }

    function setProjectAddr(address _projectAddr) public {
        require(_msgSender() == owner(), "fail");

        projectAddr = _projectAddr;
        _isExcludedFromFee[_projectAddr] = true;
    }

    function name() public override view  returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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
        return _isExcluded[account];
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        uint256 rAmount = tAmount.mul(_getRate());
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        return rAmount.div(_getRate());
    }

    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
   
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function openTrade() public onlyOwner {
        _openTrade = true;
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function getLiquidUSDTAmount() public view returns (uint){
        (uint112 r0, uint112 r1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        if(IUniswapV2Pair(uniswapV2Pair).token0() == address(usdt)){
            return uint(r0);
        }
        return uint(r1);
    }

    function calcTotalFee(TransferInfo memory transferInfo) public returns(uint, uint){
        uint usdtAmount = getLiquidUSDTAmount();
        uint amount = usdtAmount / 1 ether;
        uint fee = 0;
        uint rate = 0;

        if(amount <= 1000000){
            rate = 200;
        } else if(amount <= 2000000){
            rate = 190;
        } else if(amount <= 4000000){
            rate = 180;
        } else if(amount <= 6000000){
            rate = 170;
        } else if(amount <= 8000000){
            rate = 160;
        } else if(amount <= 10000000){
            rate = 150;
        } else if(amount <= 20000000){
            rate = 140;
        } else if(amount <= 30000000){
            rate = 130;
        } else if(amount <= 40000000){
            rate = 120;
        } else if(amount <= 50000000){
            rate = 110;
        } else if(amount <= 60000000){
            rate = 100;
        } else if(amount <= 70000000){
            rate = 90;
        } else if(amount <= 80000000){
            rate = 80;
        } else if(amount <= 100000000){
            rate = 70;
        } else if(amount <= 300000000){
            rate = 60;
        } else if(amount <= 500000000){
            rate = 50;
        } else if(amount <= 1000000000){
            rate = 40;
        } else if(amount <= 3000000000){
            rate = 30;
        } else if(amount <= 5000000000){
            rate = 20;
        } else if(amount <= 10000000000){
            rate = 10;
        } else if(amount > 10000000000){
            rate = 5;
        } 

        fee = transferInfo.tAmount.mul(rate).div(1000);
        if(isStopFee()){
            fee = 0;
        }
        
        
        //卖
        uint returnFee = 0;
        if(transferInfo.recipient == uniswapV2Pair){
            address parent1 =teamLevelup[transferInfo.sender];

            if(parent1!=address(0)) {
                //myself
                _returnUSDCFee(transferInfo.sender, fee.mul(10).div(100));
                returnFee = returnFee.add(fee.mul(10).div(100));

                //10% up1
                _returnUSDCFee(parent1, fee.mul(10).div(100));
                returnFee = returnFee.add(fee.mul(10).div(100));

                address parent2 =teamLevelup[parent1];
                if(parent2!=address(0)){
                    //3% up2
                    _returnUSDCFee(parent2, fee.mul(3).div(100));
                    returnFee = returnFee.add(fee.mul(3).div(100));
                }
            }
        } else if(transferInfo.sender == uniswapV2Pair){ //buy
            address parent1 =teamLevelup[transferInfo.recipient];

            if(parent1!=address(0)) {
                //myself
                _returnUSDCFee(transferInfo.recipient, fee.mul(10).div(100));
                returnFee = returnFee.add(fee.mul(10).div(100));

                //10% up1
                _returnUSDCFee(parent1, fee.mul(10).div(100));
                returnFee = returnFee.add(fee.mul(10).div(100));

                address parent2 =teamLevelup[parent1];
                if(parent2!=address(0)){
                    //3% up2
                    _returnUSDCFee(parent2, fee.mul(3).div(100));
                    returnFee = returnFee.add(fee.mul(3).div(100));
                }
            }
        }


        return (fee, returnFee);
    }

    function isStopFee() private view returns(bool){
        return totalSupply().sub(balanceOf(blackHole))<= _minLiquidAmount;
    }

    function _reflectFee(uint256 rFee) private {
        _rTotal = _rTotal.sub(rFee, "reflect fee");
    }

    function _getTValues(TransferInfo memory transferInfo) private returns (FeeInfo memory feeInfo) {
        if (!feeIt) {
            feeInfo.tTransferAmount = transferInfo.tAmount;
            return feeInfo;
        }

        
        (uint totalFee,uint returnFee) = calcTotalFee(transferInfo);

        feeInfo.tFomo = totalFee.sub(returnFee).mul(40).div(100); 
        feeInfo.tDev = totalFee.sub(returnFee).mul(10).div(100);   
        feeInfo.tLiquidity = totalFee.sub(returnFee).mul(40).div(100);
        feeInfo.tFee = totalFee.sub(returnFee).mul(10).div(100);

        feeInfo.tTransferAmount = transferInfo.tAmount.sub(totalFee);
    }

    function _getRValues(uint256 tAmount, uint256 tTransferAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = tTransferAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]], "sub rSupply");
            tSupply = tSupply.sub(_tOwned[_excluded[i]], "sub tSupply");
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }


    function _returnFee(address account,uint tFee) private {
        uint256 currentRate =  _getRate();
        uint256 rFee = tFee.mul(currentRate);

        _rOwned[account] = _rOwned[account].add(rFee);
        if(_isExcluded[account]) {
            _tOwned[account] = _tOwned[account].add(tFee);
        }
    }

    //换成usdc再打过去
    function _returnUSDCFee(address account, uint tFee) private{
        swapTokensForUsdt(tFee, account);
    }
    
    function _takeTax(uint256 tFomo, uint256 tDev, uint256 tLiquidity) private {
        _returnUSDCFee(address(this), tLiquidity);

        //运营 1 半token, 一半usdc
        _returnFee(devReceiver, tDev.div(2));
        _returnUSDCFee(devReceiver, tDev.div(2));

        _returnUSDCFee(fomoReceiver, tFomo);
    }
    
    function removeAllFee() private {
        if (!feeIt) return;
        feeIt = false;
    }
    
    function restoreAllFee() private {
        feeIt = true;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve zero address");
        require(spender != address(0), "ERC20: approve zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isRealBuy(address from, address to)private view returns(bool){
        return from == uniswapV2Pair && from != owner() && to != owner() && to != fomoReceiver;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private transferCounter {
        require(from != address(0), "ERC20: transfer zero address");
        require(to != address(0), "ERC20: transfer zero address");
        require(amount > 0, "Transfer amount greater than zero");
        if(isRealBuy(from, to)){
            require(amount + balanceOf(to) <= _maxTotalBuyAmount, "Transfer amount exceeds the maxTotalBuyAmount.");
            if(!_openTrade){
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }
        }
            
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        // if(contractTokenBalance >= _maxTxAmount)
        // {
        //     contractTokenBalance = _maxTxAmount;
        // }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        if (enterCount == 1) {
            if (takeFee && from == uniswapV2Pair && amount >= fomoMin) {
                IFomo(fomoReceiver).transferNotify(to);

                if(!isStopFee()){
                    IFomo(fomoReceiver).lottery(to);
                }
                
            }
            if (!inSwapAndLiquify && from != uniswapV2Pair && from != fomoReceiver) {
                IFomo(fomoReceiver).swap();
            }
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half, "sub half");

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        //uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForUsdt(half, address(wrap)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        // uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 usdtBalance = usdt.balanceOf(address(this));

        // add liquidity to uniswap
        addLiquidityUsdt(otherHalf, usdtBalance);
        
        emit SwapAndLiquify(half, usdtBalance, otherHalf);
    }

    function swapTokensForUsdt(uint256 tokenAmount, address to) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(to),
            block.timestamp
        );

        if(to==address(wrap)){
            wrap.withdraw();
        }
    }

    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        usdt.approve(address(uniswapV2Router), usdtAmount);

        uniswapV2Router.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            usdtAmount,
            0,
            0,
            blackHole,
            block.timestamp
        );
    }

    
     //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();


        TransferInfo memory transferInfo ;
        transferInfo.sender = sender;
        transferInfo.recipient = recipient;
        transferInfo.tAmount = amount;

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            // _transferFromExcluded(sender, recipient, amount);
            transferInfo.transferType = TransferType.TransferFromExcluded;
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            // _transferToExcluded(sender, recipient, amount);
            transferInfo.transferType = TransferType.TransferToExcluded;
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            // _transferStandard(sender, recipient, amount);
            transferInfo.transferType = TransferType.TransferStandard;
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            // _transferBothExcluded(sender, recipient, amount);
            transferInfo.transferType = TransferType.TransferBothExcluded;
        } else {
            // _transferStandard(sender, recipient, amount);
            transferInfo.transferType = TransferType.TransferStandard;
        }

        __transferToken(transferInfo);
        
        if(!takeFee)
            restoreAllFee();
    }

    function processAirport(address from, address to, uint tAmount) private {
        if(teamLevelup[to] == address(0) && tAmount >= (10000* 10**decimals() ) ){
            teamLevelup[to] = from;
            teams[to] = true;
            if(!teams[from]){
                teams[from] = true;
            }
        }
    }

    function __transferToken(TransferInfo memory transferInfo) private {
        processAirport(transferInfo.sender, transferInfo.recipient, transferInfo.tAmount);

        FeeInfo memory feeInfo = _getTValues(transferInfo);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(transferInfo.tAmount, feeInfo.tTransferAmount, feeInfo.tFee, _getRate());

        _rOwned[transferInfo.sender] = _rOwned[transferInfo.sender].sub(rAmount, "sub1 rAmount");
        _rOwned[transferInfo.recipient] = _rOwned[transferInfo.recipient].add(rTransferAmount);

        if(transferInfo.transferType == TransferType.TransferToExcluded)  {
            _tOwned[transferInfo.recipient] = _tOwned[transferInfo.recipient].add(feeInfo.tTransferAmount);
        }else if(transferInfo.transferType == TransferType.TransferFromExcluded){
            _tOwned[transferInfo.sender] = _tOwned[transferInfo.sender].sub(transferInfo.tAmount, "sub3 tAmount");
        }else if(transferInfo.transferType == TransferType.TransferBothExcluded){
            _tOwned[transferInfo.sender] = _tOwned[transferInfo.sender].sub(transferInfo.tAmount, "sub4 tAmount");
            _tOwned[transferInfo.recipient] = _tOwned[transferInfo.recipient].add(feeInfo.tTransferAmount);
        }

        _takeTax(feeInfo.tFomo, feeInfo.tDev, feeInfo.tLiquidity);
        _reflectFee(rFee);
        emit Transfer(transferInfo.sender, transferInfo.recipient, feeInfo.tTransferAmount);
        if (feeInfo.tFee > 0) {
            emit Transfer(transferInfo.sender, fomoReceiver, feeInfo.tFomo);
            emit Transfer(transferInfo.sender, devReceiver, feeInfo.tDev);
        }

    }
}

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.2;

interface IERC20 {

    function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;


interface IFomo {
    function transferNotify(address user) external;
    function lottery(address user) external;
    function swap() external;
}

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;


interface IWrap {
    function withdraw() external;
}

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.2;

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