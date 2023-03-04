/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface ILpHolder {
    function distributeUsdt(uint256 usdtAmount, uint256 lpAmount) external;
}

interface IDapp {
    function clearOrder(address userAddress) external;
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract BaseToken is IERC20, Ownable {
    
    event ProcessLP(uint64 time);

    bool private inSwap;
    uint8 private _decimals;  
    uint32 public _startTradeBlock;
    uint32 public _currentIndex;
    uint32 public _progressLPTime;

    uint256 private _totalSupply;
    uint256 private constant MAX = ~uint256(0);
    uint256 public _waitForSwapAmount;
    uint256 public _waitForBackToPoolAmount;
    uint256 public _limitAmount;
    uint256 public _addPriceTokenAmount; 

    ISwapRouter private _swapRouter;
    TokenDistributor public _tokenDistributor;
    IDapp public _dapp;
    address private _marketAddress;
    address private _usdtAddress;
    address private _mainPairAddress;
    address public _lpHolderContractAddress;

    string private _name;
    string private _symbol;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) private _swapPairMap;
    mapping(address => uint256) _lpProviderIndex;
    mapping(address => bool) _excludeLpProvider;


    address[] private _lpProviders;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint256 Supply, address RouterAddress, address UsdtAddress, address marketAddress, address receiveAddress, address dappAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = 18;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdtAddress = UsdtAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _mainPairAddress = swapFactory.createPair(address(this), UsdtAddress);
        _swapPairMap[_mainPairAddress] = true;

        uint256 total = Supply * 1e18;
        _totalSupply = total;

        _balances[receiveAddress] = 1e20;
        emit Transfer(address(0), receiveAddress, _balances[receiveAddress]);

        _balances[dappAddress] = total - _balances[receiveAddress];
        emit Transfer(address(0), dappAddress, _balances[dappAddress]);   
        _dapp = IDapp(dappAddress);
        _addLpProvider(receiveAddress); 

        _marketAddress = marketAddress;

        _feeWhiteList[marketAddress] = true;
        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[dappAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _excludeLpProvider[address(0)] = true;
        _excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = 10*1e18;
        _addPriceTokenAmount = 1e14;
        _tokenDistributor = new TokenDistributor(UsdtAddress);
        _startTradeBlock = 0;
    }

    function pairAddress() external view returns (address) {
        return _mainPairAddress;
    }
    
    function routerAddress() external view returns (address) {
        return address(_swapRouter);
    }
    
    function usdtAddress() external view returns (address) {
        return _usdtAddress;
    }
    
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _isLiquidity(address from,address to) internal view returns(bool isAdd,bool isDel){
        address token0 = IUniswapV2Pair(_mainPairAddress).token0();
        (uint r0,,) = IUniswapV2Pair(_mainPairAddress).getReserves();
        uint bal0 = IERC20(token0).balanceOf(_mainPairAddress);
        if( _swapPairMap[to] ){
            if( token0 != address(this) && bal0 > r0 ){
                isAdd = bal0 - r0 > _addPriceTokenAmount;
            }
        }
        if( _swapPairMap[from] ){
            if( token0 != address(this) && bal0 < r0 ){
                isDel = r0 - bal0 > 0; 
            }
        }
    }




    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {       
        require(amount > 0, "VB: transfer amount must be >0");
        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);
        
        if (_feeWhiteList[from] || _feeWhiteList[to] || isAddLiquidity || isDelLiquidity){
            
            _tokenTransfer(from, to, amount);
        }else if(_swapPairMap[from] || _swapPairMap[to]){
            
            require(_startTradeBlock > 0, "VB: trade don't start");                

            if (_swapPairMap[to]) { 
                
                require(amount <= (_balances[from])*99/100, "VB: sell amount exceeds balance 99%");
                
            }                       
            _tokenTransfer(from, to, amount*97/100);
            _tokenTransfer(from, address(this), amount*3/100); 
            _waitForSwapAmount += amount/50; 
            _waitForBackToPoolAmount += amount/100; 
            
             
        }else{
            
            if (!inSwap && _waitForSwapAmount > _limitAmount){    
                
                swapUSDT() ;
            }
            if(_waitForBackToPoolAmount > _limitAmount){
                _tokenTransfer(address(this), _mainPairAddress, _waitForBackToPoolAmount);
                _waitForBackToPoolAmount = 0;
            }
            _tokenTransfer(from, to, amount);
        }
        if (isAddLiquidity) { 
            _addLpProvider(from); 
        }
        if(isDelLiquidity){
            _dapp.clearOrder(to); 
        }
        if (from != address(this)) {
            _processLP(500000);
        }
    }
    
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    function swapUSDT() internal lockTheSwap {
        address tokenDistributor = address(_tokenDistributor);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _waitForSwapAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );        
        _waitForSwapAmount = 0;
        IERC20 USDT = IERC20(_usdtAddress);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, _marketAddress, usdtBalance/2); 
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance/2); 
    }

    function _addLpProvider(address addr) private {
        if (0 == _lpProviderIndex[addr]) {
            if (0 == _lpProviders.length || _lpProviders[0] != addr) {
                _lpProviderIndex[addr] = _lpProviders.length;
                _lpProviders.push(addr);
            }
        }
    }

    function getLps() external view returns(address [] memory){
        return _lpProviders;
    }

    function processLP(uint256 gas) external onlyOwner{
        _processLP(gas);
    }

    function _processLP(uint256 gas) internal {
        uint256 timestamp = block.timestamp;
        if (_progressLPTime + 86400 > timestamp) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPairAddress);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(_usdtAddress);
        uint256 usdtTokenBalance = USDT.balanceOf(address(this));
        if (usdtTokenBalance < _limitAmount) {
            return;
        }

        address lpHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 lpHolderCount = _lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        
        address lpHolderContractAddress = _lpHolderContractAddress;

        while (gasUsed < gas && iterations < lpHolderCount) {
            if (_currentIndex >= lpHolderCount) {
                _currentIndex = 0;
            }
            lpHolder = _lpProviders[_currentIndex];
            pairBalance = mainpair.balanceOf(lpHolder);
            if (pairBalance > 0 && !_excludeLpProvider[lpHolder]) {
                amount = usdtTokenBalance * pairBalance / totalPair;
                if (amount > 0) {
                    USDT.transfer(lpHolder, amount);
                    if(lpHolder == lpHolderContractAddress){
                        ILpHolder(lpHolderContractAddress).distributeUsdt(amount, pairBalance);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            _currentIndex++;
            iterations++;
        }

        _progressLPTime = uint32(timestamp);
        emit ProcessLP(_progressLPTime);
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 1e18;
    }

    function setLpHolderContractAddress(address lpHolderContractAddress) external onlyOwner {
        _lpHolderContractAddress = lpHolderContractAddress;
        _addLpProvider(lpHolderContractAddress);
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        _excludeLpProvider[addr] = enable;
    }

    function setProgressLPTime(uint32 time) external onlyOwner {
        _progressLPTime=time;
    }

    function manulAddLpProvider(address addr) external{
        require(msg.sender==owner() || msg.sender == _lpHolderContractAddress,"VB: caller should be owner or LpHolder");
        _addLpProvider(addr);
    }

    function setMarketAddress(address addr) external onlyOwner {
        _marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDappAddress(address addr) external onlyOwner {
        _dapp = IDapp(addr);
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == _startTradeBlock, "trading");
        _startTradeBlock = uint32(block.number);
    }

    function closeTrade() external onlyOwner {
        _startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }    

    function setSwapPairMap(address addr, bool enable) external onlyOwner {
        _swapPairMap[addr] = enable;
    }

    function setAddPriceTokenAmount(uint addPriceTokenAmount) external onlyOwner{
        _addPriceTokenAmount = addPriceTokenAmount;
    }

    function releaseBalance() external {
        payable(_marketAddress).transfer(address(this).balance);
    }

    function releaseToken(address token, uint256 amount) external {
        IERC20(token).transfer(_marketAddress, amount);
    }

    receive() external payable {}
}

contract VermilionBird is BaseToken {
    constructor(address dappAddress) BaseToken(
        "Vermilion Bird",
        "VB",
        21000000,
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 
        address(0x55d398326f99059fF775485246999027B3197955), 
        address(0x227ca189E2a1258954d71C7C04eAd4697651749a), 
        address(0xAcD2904782EF03697FD941Acc0Dd394cD5dCC41b), 
        dappAddress
    ){

    }
}