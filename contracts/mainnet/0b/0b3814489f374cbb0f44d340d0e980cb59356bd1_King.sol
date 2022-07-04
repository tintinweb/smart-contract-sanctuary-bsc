// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IPancakeRouter02.sol";
import "./IUniswapV2Factory.sol";

contract King is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping(address => address) public inviter;

    string private _name = "KING";
    string private _symbol = "KING";
    uint8  private _decimals = 18;
    uint256 private _tTotal = 8000000 * 10**uint256(_decimals);
    
    address private _burnPool = address(0);
    address private _fundAddress = address(0);
    address private _marketingAddress = address(0);
    address private _exchangePool = address(0);
    address private _inviterDefault = address(0);
    
    uint256 public _inviterFee = 0;
    uint256 private _previousInviterFee = _inviterFee;
    uint256 public _liquidityFee = 0;
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 public _fundFee = 0;
    uint256 private _previousFundFee = _fundFee;
    uint256 public _marketingFee = 0;
    uint256 private _previousMarketingFee = _marketingFee;
    uint256 public _lpDivFee = 0;
    uint256 private _previousLpDivFee = _lpDivFee;
    uint256 public _burnFee = 0;
    uint256 private _previousBurnFee = _burnFee;
    
    uint256 public _buyInviterFee;
    uint256 public _sellInviterFee;
    uint256 public _buyLiquidityFee;
    uint256 public _sellLiquidityFee;
    uint256 public _buyFundFee;
    uint256 public _sellFundFee;
    uint256 public _buyMarketingFee;
    uint256 public _sellMarketingFee;
    uint256 public _buyLpDivFee;
    uint256 public _sellLpDivFee;
    uint256 public _buyBurnFee;
    uint256 public _sellBurnFee;
    
    uint256 private _inviterFeeTotal;
    uint256 private _liquidityFeeTotal;
    uint256 private _fundFeeTotal;
    uint256 private _marketingFeeTotal;
    uint256 private _lpDivFeeTotal;
    uint256 private _burnFeeTotal;
    uint256 private _tFeeTotal;

    uint256 public  MAX_STOP_FEE_TOTAL = 10000 * 10**uint256(_decimals);
    uint256 private numTokensSellToAddToLiquidity = 100 * 10**uint256(_decimals);

    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public liquifyEnabled = false;
    
    struct Tranfee {
        uint256 tAmount;
        uint256 tTransferAmount;
        uint256 tInviter;
        uint256 tLiquidity;
        uint256 tFund;
        uint256 tMarketing;
        uint256 tLpDiv;
        uint256 tBurn;
    }

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
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

    constructor (
        address fundAddress,
        address marketingAddress,
        address inviterDefault,
        uint256[6] memory buyFeeSetting_, // _inviterFee, _liquidityFee, _fundFee, _marketingFee, _lpDivFee, _burnFee
        uint256[6] memory sellFeeSetting_ // _inviterFee, _liquidityFee, _fundFee, _marketingFee, _lpDivFee, _burnFee
    ) {
        
        _fundAddress = fundAddress;
        _marketingAddress = marketingAddress;
        _inviterDefault = inviterDefault;
        
        _buyInviterFee = buyFeeSetting_[0];
        _buyLiquidityFee = buyFeeSetting_[1];
        _buyFundFee = buyFeeSetting_[2];
        _buyMarketingFee = buyFeeSetting_[3];
        _buyLpDivFee = buyFeeSetting_[4];
        _buyBurnFee = buyFeeSetting_[5];
        
        _sellInviterFee = sellFeeSetting_[0];
        _sellLiquidityFee = sellFeeSetting_[1];
        _sellFundFee = sellFeeSetting_[2];
        _sellMarketingFee = sellFeeSetting_[3];
        _sellLpDivFee = sellFeeSetting_[4];
        _sellBurnFee = sellFeeSetting_[5];
        
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _exchangePool = uniswapV2Pair;
        //_setAutomatedMarketMakerPair(uniswapV2Pair, true);

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            payable(address(0)),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if(!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        
        Tranfee memory tranFee = _getValues(tAmount);
        _balances[sender] = _balances[sender].sub(tranFee.tAmount);
        _balances[recipient] = _balances[recipient].add(tranFee.tTransferAmount);
        
         emit Transfer(sender, recipient, tranFee.tTransferAmount);

        if (!takeFee) {
            return;
        }

        if (!_isExcludedFromFee[sender] &&
            !_isExcludedFromFee[recipient] &&
            automatedMarketMakerPairs[sender]
        ) {
            _takeInviterFee(sender, recipient, tranFee.tAmount);
            _takeLiquidity(sender, tranFee.tLiquidity);
        } else {
            if(
                !_isExcludedFromFee[sender] &&
                !_isExcludedFromFee[recipient] &&
                automatedMarketMakerPairs[recipient]
            ){
                _takeFund(sender,tranFee.tFund);
                _takeMarketing(sender,tranFee.tMarketing);
                _takeLpDiv(sender,tranFee.tLpDiv);
                _takeBurn(sender,tranFee.tBurn);
            }
        }
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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function setLiquifyEnabled(bool _enabled) public onlyOwner {
        liquifyEnabled = _enabled;
    }
    
    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function setErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }
    
    function setMaxStopFeeTotal(uint256 total) public onlyOwner {
        MAX_STOP_FEE_TOTAL = total;
        restoreAllFee();
    }
    
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    
     function setExchangePool(address exchangePool) public onlyOwner {
        _exchangePool = exchangePool;
    }
    
    function totalBurnFee() public view returns (uint256) {
        return _burnFeeTotal;
    }
    
    function totalFundFee() public view returns (uint256) {
        return _fundFeeTotal;
    }
    
    function totalMarketingFee() public view returns (uint256) {
        return _marketingFeeTotal;
    }
    
     function totalLpDivFee() public view returns (uint256) {
        return _lpDivFeeTotal;
    }
    
    function totalLiquidityFee() public view returns (uint256) {
        return _liquidityFeeTotal;
    }
    
    function totalInviterFee() public view returns (uint256) {
        return _inviterFeeTotal;
    }
    
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (Tranfee memory) {
        Tranfee memory tranFee;
        tranFee.tAmount = tAmount;
        Tranfee memory mtranFee = _getTValues(tAmount);
        
        tranFee.tTransferAmount = mtranFee.tTransferAmount;
        tranFee.tInviter = mtranFee.tInviter;
        tranFee.tLiquidity = mtranFee.tLiquidity;
        tranFee.tFund = mtranFee.tFund;
        tranFee.tMarketing = mtranFee.tMarketing;
        tranFee.tLpDiv = mtranFee.tLpDiv;
        tranFee.tBurn = mtranFee.tBurn;
        
        return tranFee;
    }

    function _getTValues(uint256 tAmount) private view returns (Tranfee memory) {
        
        uint256 tInviter = calculateInvFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tFund = calculateFundFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tLpDiv = calculateLpDivFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        
        uint256 tTransferAmount = tAmount.sub(tInviter).sub(tLiquidity);
        tTransferAmount = tTransferAmount.sub(tFund).sub(tMarketing);
        tTransferAmount =tTransferAmount.sub(tLpDiv).sub(tBurn);
        return Tranfee(tAmount, tTransferAmount, tInviter, tLiquidity, tFund, tMarketing, tLpDiv, tBurn);
    }
    
    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;

        address cur = sender;
        if (automatedMarketMakerPairs[sender]) {
            cur = recipient;
        } else if (automatedMarketMakerPairs[recipient]) {
            cur = sender;
        }
        if (cur == address(0)) {
            return;
        }

        cur = inviter[cur];
        if (cur == address(0)) {
            cur = _inviterDefault;
        }
        uint256 curTAmount = tAmount.mul(_inviterFee).div(100);
        _balances[cur] = _balances[cur].add(curTAmount);
        
        _inviterFeeTotal = _inviterFeeTotal.add(curTAmount);
        _tFeeTotal = _tFeeTotal.add(curTAmount);
        
        emit Transfer(sender, cur, curTAmount);
    }

    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        _balances[address(this)] = _balances[address(this)].add(tLiquidity);
        _liquidityFeeTotal = _liquidityFeeTotal.add(tLiquidity);
        _tFeeTotal = _tFeeTotal.add(tLiquidity);
        emit Transfer(sender, address(this), tLiquidity);
    }
    
    function _takeFund(address sender, uint256 tFund) private {
        _balances[_fundAddress] = _balances[_fundAddress].add(tFund);
        _fundFeeTotal = _fundFeeTotal.add(tFund);
        _tFeeTotal = _tFeeTotal.add(tFund);
        emit Transfer(sender, _fundAddress, tFund);
    }
    
    function _takeMarketing(address sender, uint256 tMarketing) private {
        _balances[_marketingAddress] = _balances[_marketingAddress].add(tMarketing);
        _marketingFeeTotal = _marketingFeeTotal.add(tMarketing);
        _tFeeTotal = _tFeeTotal.add(tMarketing);
        emit Transfer(sender, _marketingAddress, tMarketing);
    }
    
    function _takeLpDiv(address sender, uint256 tLpDiv) private {
        _balances[_exchangePool] = _balances[_exchangePool].add(tLpDiv);
        _lpDivFeeTotal = _lpDivFeeTotal.add(tLpDiv);
        _tFeeTotal = _tFeeTotal.add(tLpDiv);
        emit Transfer(sender, _exchangePool, tLpDiv);
    }
    
    function _takeBurn(address sender, uint256 tBurn) private {
        _tTotal = _tTotal.sub(tBurn);
        _burnFeeTotal = _burnFeeTotal.add(tBurn);
        _tFeeTotal = _tFeeTotal.add(tBurn);
        emit Transfer(sender, _burnPool, tBurn);
    }
    
    function calculateInvFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(
            10**2
        );
    }
    
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }
    
    function calculateFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fundFee).div(
            10 ** 2
        );
    }
    
    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10 ** 2
        );
    }
    
    function calculateLpDivFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lpDivFee).div(
            10 ** 2
        );
    }
    
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10 ** 2
        );
    }
    
    function removeAllFee() private {
        if(_inviterFee == 0 && _liquidityFee == 0 && _fundFee == 0 && _marketingFee == 0 && _lpDivFee == 0 && _burnFee == 0) return;
        _previousInviterFee = _inviterFee;
        _previousLiquidityFee = _liquidityFee;
        _previousFundFee = _fundFee;
        _previousMarketingFee = _marketingFee;
        _previousLpDivFee = _lpDivFee;
        _previousBurnFee = _burnFee;
        _inviterFee = 0;
        _liquidityFee = 0;
        _fundFee = 0;
        _marketingFee = 0;
        _lpDivFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _inviterFee = _previousInviterFee;
        _liquidityFee = _previousLiquidityFee;
        _fundFee = _previousFundFee;
        _marketingFee = _previousMarketingFee;
        _lpDivFee = _previousLpDivFee;
        _burnFee = _previousBurnFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        
        uint256 senderBalance = balanceOf(from);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        // set invite
        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) 
            && !isContract(from) && !isContract(to) && amount >= 1 * 10**uint256(_decimals-3) &&
            from != owner() && to != owner();
        
        if(automatedMarketMakerPairs[from]){
            _inviterFee = _buyInviterFee;
            _liquidityFee = _buyLiquidityFee;
            _fundFee = _buyFundFee;
            _marketingFee = _buyMarketingFee;
            _lpDivFee = _buyLpDivFee;
            _burnFee = _buyBurnFee;
            
            _previousInviterFee = _inviterFee;
            _previousLiquidityFee = _liquidityFee;
            _previousFundFee = _fundFee;
            _previousMarketingFee = _marketingFee;
            _previousLpDivFee = _lpDivFee;
            _previousBurnFee = _burnFee;
        }else {
            if(automatedMarketMakerPairs[to]){
                _inviterFee = _sellInviterFee;
                _liquidityFee = _sellLiquidityFee;
                _fundFee = _sellFundFee;
                _marketingFee = _sellMarketingFee;
                _lpDivFee = _sellLpDivFee;
                _burnFee = _sellBurnFee;
                
                _previousInviterFee = _inviterFee;
                _previousLiquidityFee = _liquidityFee;
                _previousFundFee = _fundFee;
                _previousMarketingFee = _marketingFee;
                _previousLpDivFee = _lpDivFee;
                _previousBurnFee = _burnFee;
            }
        }
            
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance &&
            !inSwapAndLiquify &&
            automatedMarketMakerPairs[to] &&
            swapAndLiquifyEnabled) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        if(_tTotal <= MAX_STOP_FEE_TOTAL){
            takeFee = false;
            removeAllFee();
            _transferStandard(from,to,amount,takeFee);
        } else{
            //if any account belongs to _isExcludedFromFee account then remove the fee
            if(
                _isExcludedFromFee[from] || 
                _isExcludedFromFee[to] ||
                (!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to])
            ) {
                takeFee = false;
            }

            //transfer amount, it will take transfer fee
            _tokenTransfer(from, to, amount, takeFee);
        }
        
        if (shouldSetInviter) {
            inviter[to] = from;
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        
        uint256 addNumber = contractTokenBalance;
        uint256 half = addNumber.div(2);
        uint256 otherHalf = addNumber.sub(half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the BNB -> KING swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        if (liquifyEnabled) {
            addLiquidity(otherHalf, newBalance);    
        }
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
}