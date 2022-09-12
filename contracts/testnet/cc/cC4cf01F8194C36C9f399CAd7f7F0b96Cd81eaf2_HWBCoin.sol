// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IPancakeRouter02.sol";
import "./IUniswapV2Factory.sol";

/**
 * @dev contract of the Ghostrunner including 3% fund autotransfer to USDT
 */

contract HWBCoin is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public automatedMarketMakerPairs;
    
    uint256 private _tTotal = 30000 * 10**6;
    string private _name = "HWB Coin";
    string private _symbol = "HWB";
    uint8  private _decimals = 6;
    
    uint256 public _devFee = 3;
    uint256 private _previousDevFee = _devFee;

    //testnet feeaddress:0x43CcC1429EA83aA036FD993aC2165B07cD553D80
    //mainnet feeaddress:
    address public devAddress = address(0x43CcC1429EA83aA036FD993aC2165B07cD553D80);
    
    //mainnet: 0x55d398326f99059fF775485246999027B3197955
    //testnet: 0xB425dA01b4A353fF9f36f6Cae4acD32911046fE5
    address public husdtToken = 0x55d398326f99059fF775485246999027B3197955;

    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapDevEnabled = false;

    uint256 private numTokensSellToAddToLiquidity = 3 * 10**6;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
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

    constructor () {
        //testnet router=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //mainnet router=0x10ED43C718714eb63d5aA57B78B54704E256024E
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        //exclude owner and this contract from fee
        //drop owner address
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
        
        (uint256 tTransferAmount, uint256 tDev) = _getValues(tAmount);
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);
        
         emit Transfer(sender, recipient, tTransferAmount);

        if (!takeFee) {
            return;
        }
        
         if (!_isExcludedFromFee[sender] &&
            !_isExcludedFromFee[recipient] &&
            (automatedMarketMakerPairs[sender] || automatedMarketMakerPairs[recipient])
        ) {
            _takeDev(sender, tDev);
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

    function _takeDev(address sender, uint256 tDev) private {
        if(!swapDevEnabled){
            _balances[devAddress] = _balances[devAddress].add(tDev);
            emit Transfer(sender, devAddress, tDev);
        } else {
            _balances[address(this)] = _balances[address(this)].add(tDev);
            emit Transfer(sender, address(this), tDev);
        }
    }
    
    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapDevEnabled(bool _enabled) public onlyOwner {
        swapDevEnabled = _enabled;
    }
    
    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function setErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }
    
    function setDevFeePercent(uint256 devFee) external onlyOwner {
        _devFee = devFee;
        _previousDevFee = _devFee;
    }
    
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "ERC20: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        (uint256 tTransferAmount,  uint256 tDev) = _getTValues(tAmount);
        return (tTransferAmount, tDev);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {

        uint256 tDev = calculateDevFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tDev);
        return (tTransferAmount, tDev);
    }

    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_devFee).div(100);
    }
    
    function removeAllFee() private {
        if(_devFee == 0) return;
        _previousDevFee = _devFee;
        _devFee = 0;
    }

    function restoreAllFee() private {
        _devFee = _previousDevFee;
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
        require(amount > 0, "Transfer amount must be greater than zero");
        
        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance &&
            !inSwapAndLiquify &&
            automatedMarketMakerPairs[to] &&
            swapAndLiquifyEnabled) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account or transfer between wallet then remove the fee
        if(_isExcludedFromFee[from] || 
           _isExcludedFromFee[to] ||
           (!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to])
        ) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 devNumber = contractTokenBalance;
        swapTokensForDividendToken(devNumber);
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
    
    function swapTokensForDividendToken(uint256 tokenAmount) private {
        if (tokenAmount > 0) {
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            path[2] = husdtToken;
            
            _approve(address(this), address(uniswapV2Router), _tTotal);
    
            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of dividend token
                path,
                address(this),
                block.timestamp
            );
            uint256 dividends = IERC20(husdtToken).balanceOf(address(this));
            IERC20(husdtToken).transfer(address(devAddress), dividends);
        }
    }
}