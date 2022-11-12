/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface Fee {
    function feeDistribution(uint256 amount, uint256 [6] memory fees, address [4] memory feesAddresses, bool inBNB) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SM: AOF");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SM: SOF");
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
        require(c / a == b, "SM: MOF");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SM: DB0");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SM: MB0");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Add: IB");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Add: UTS, RMHR");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Add: LLCF");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Add: LLCwFV");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Add: IBFC");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Add: CTNC");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Own: CNO");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Own: NO = 0 addy");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract Bep20 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _tLocked;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromMaxTx;
    mapping(address => bool) public _isExcludedFromWalletCap;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) public unallowedPairs;
    mapping(address => bool) private blacklist;

    address[] private _excluded;

    address payable _devAddress;
    address public _tokenFeeAddress;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 4700000000  * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public MAX_PER_WALLET = _tTotal.mul(100).div(100);

    string private _name = "Compare Test Token 1";
    string private _symbol = "CTT1";
    uint8 private _decimals = 9;
    
    // Taxes
    uint256 public _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 100;
    uint256 private _previousLiquidityFee = _liquidityFee;
    
    uint256 public _devFee = 400;
    uint256 private _previousDevFee = _devFee;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public busd;
    address public feeManager;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyInBNB = true;
    
    uint256 public _maxTxAmount = 4700000000 * 10**9;
    uint256 public numTokensSellToAddToLiquidity = 4700 * 10**9;
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapAndSend(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokens
    );
    
    constructor (address router, address stablecoin) {
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router); 
    
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        busd = address(stablecoin);

        uniswapV2Router = _uniswapV2Router;
    
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[address(0x000000000000000000000000000000000000dEaD)] = true;
        _isExcludedFromMaxTx[address(0)] = true;

        _isExcludedFromWalletCap[owner()] = true;
        _isExcludedFromWalletCap[address(this)] = true;
        _isExcludedFromWalletCap[uniswapV2Pair] = true;
        _isExcludedFromWalletCap[0x000000000000000000000000000000000000dEaD] = true;

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
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(block.timestamp > _tLocked[_msgSender()] , "Wallet locked");
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
        require(block.timestamp > _tLocked[sender] , "Wallet locked");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: trans > allow"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: - allow < 0"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amt must be < tax");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function isExcludedFromMaxTx(address account) public view returns(bool) {
        return _isExcludedFromMaxTx[account];
    }

    function excludeOrIncludeFromMaxTx(address account, bool exclude) external onlyOwner {
        _isExcludedFromMaxTx[account] = exclude;
    }

    function excludeOrIncludeFromWalletCap(address account, bool exclude) external onlyOwner {
        _isExcludedFromWalletCap[account] = exclude;
    }
    function setMaxPerWallet(uint256 maxPerWallet) external onlyOwner() {
        MAX_PER_WALLET = maxPerWallet * 10 ** 9;
    }

    function setDevAddress(address payable dev) public onlyOwner {
        _devAddress = dev;
    }

    function setTokenFeeAddress(address tokenFee) public onlyOwner {
        _tokenFeeAddress = tokenFee;
        _isExcludedFromWalletCap[tokenFee] = true;
    }
    
    function setMinTokensToSwap(uint256 _minTokens) external onlyOwner() {
        numTokensSellToAddToLiquidity = _minTokens * 10 ** 9;
    }

    function toggleSwapAndLiqBNB(bool enable) public {
        require(owner() == _msgSender(), "CCE");
        if (enable) {
            address pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
                .getPair(address(this), uniswapV2Router.WETH());

            if (pairAddress == address(0)) {
                pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
                    .createPair(address(this), uniswapV2Router.WETH());
            }

            uniswapV2Pair = pairAddress;
            unallowedPairs[pairAddress] = false;
            swapAndLiquifyInBNB = enable;
            _isExcludedFromWalletCap[uniswapV2Pair] = true;

        } else {
            address pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
                .getPair(address(this), busd);

            if (pairAddress == address(0)) {
                pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
                    .createPair(address(this), busd);
            }

            uniswapV2Pair = pairAddress;
            swapAndLiquifyInBNB = false;
        }
    }

    function setMainAllowedPair(address allowed) public {
        require(owner() == _msgSender(), "CCE");
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router); //Pancake V2 Swap's address
        address pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
            .getPair(address(this), allowed);
            if (pairAddress == address(0)) {
                pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), allowed);
            
            }
            unallowedPairs[pairAddress] = false;
            uniswapV2Pair = pairAddress;
            _isExcludedFromWalletCap[uniswapV2Pair] = true;
    }

    function toggleUnallowedPair(address coinAddress, bool disable) public {
        require(owner() == _msgSender(), "CCE");
        address pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
            .getPair(address(this), coinAddress);

            if (pairAddress == address(0)) {
                pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), coinAddress);
            }
        unallowedPairs[pairAddress] = disable;
    }

    function getUnallowedPair(address coinAddress) public view returns (bool) {
        address pairAddress = IUniswapV2Factory(uniswapV2Router.factory())
            .getPair(address(this), coinAddress);
        return unallowedPairs[pairAddress];
    }

    function setFeeManager(address manager) public {
        require(owner() == _msgSender(), "CCE");
        feeManager = manager;
        _isExcludedFromFee[manager] = true;
        _isExcludedFromMaxTx[manager] = true;
        _isExcludedFromWalletCap[manager] = true;
    }

    function showDevAddress() public view returns(address payable) {
        return _devAddress;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setDevFeePercent(uint256 devFee) external onlyOwner {
        _devFee = 400;
        if(devFee <= 400) {
	        _devFee = devFee;
	    }  
    }
    
    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = 500;
        if(taxFee <= 500) {
	        _taxFee = taxFee;
	    }  
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = 1;
        if(liquidityFee <= 100) {
	        _liquidityFee = liquidityFee;
	    }  
    }
    
    function setMaxTx(uint256 maxTx) external onlyOwner() {
        _maxTxAmount = maxTx * 10 ** 9;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function rescueLockContractBNB(uint256 weiAmount) external {
        require(owner() == _msgSender(), "CCE");
        (bool sent, ) = payable(_msgSender()).call{value: weiAmount}("");
        require(sent, "FTR");
    }

    function rescueLockTokens(address tokenAddress, uint256 amount) external {
        require(owner() == _msgSender(), "CCE");
        IERC20(tokenAddress).transfer(_msgSender(), amount);
    }
    
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityPlusFees(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
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
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**4
        );
    }

    function calculateLiquidityPlusFees(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee + _devFee).div(
            10**4
        );
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: A0A");
        require(spender != address(0), "ERC20: A0A");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: T0A");
        require(to != address(0), "ERC20: T0A");
        require(unallowedPairs[to] == false, "PNA");
        require(amount > 0, "Trans must = > 0");
        if(!_isExcludedFromWalletCap[to]) {
            require(balanceOf(to).add(amount) <= MAX_PER_WALLET, "Rec at Max Limit");
        }
        if (_isExcludedFromMaxTx[from] == false && _isExcludedFromMaxTx[to] == false) {
            require(amount <= _maxTxAmount, "TEML");
        }

        require(!(blacklist[from] || blacklist[to]), "Blacklisted Acct");

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;

        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            inSwapAndLiquify = true;
        }
        
        bool takeFee = true;
        
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
    
    }

    function _getFeeInfo() private view returns (uint256 [6] memory fees, address [4] memory feeAddresses) {
        fees[1] = _devFee;
        fees[2] = _liquidityFee;

        feeAddresses[1] = _devAddress;
        feeAddresses[2] = _tokenFeeAddress;
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function getBlacklisted(address account) view external returns (bool) {
        return blacklist[account];
    }
}