/**
 *Submitted for verification at BscScan.com on 2023-03-31
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

interface IDapp {
    function getBurnAmount() external view returns(uint256);
    function tokenDistributor() external view returns(address);
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


abstract contract BaseToken is IERC20, Ownable {
    uint8 private _decimals;  

    uint256 private _totalSupply;
    uint256 private constant MAX = ~uint256(0);
    uint256 public _totalBuyAmount;
    uint256 public _releasedAmount;
    uint256 public _addPriceTokenAmount;   
    uint256 public _dayLimitAmountForPerson;
    uint256 public _daySoldAmount;

    ISwapRouter private _swapRouter;
    IDapp public _dapp;
    address public _releaseAddress;
    address public _issueAddress;
    address private _marketAddress;
    address private _usdtAddress;
    address private _mainPairAddress;
    address public tokenDistributor;

    string private _name;
    string private _symbol;
    address[] private _dayBuyAddressList;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _swapPairMap;
    
    mapping(uint32 => uint256) public _dayLimitAmount; 
    mapping(address => uint256) public _dayBuyAmountMap;

    constructor (string memory Name, string memory Symbol, uint256 Supply, address RouterAddress, address UsdtAddress, address marketAddress, address issueAddress, address releaseAddress, address dappAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = 18;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdtAddress = UsdtAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _mainPairAddress = swapFactory.createPair(UsdtAddress,address(this));
        _swapPairMap[_mainPairAddress] = true;

        uint256 total = Supply * 1e18;
        _totalSupply = total;
        
        _marketAddress = marketAddress;
        _releaseAddress = releaseAddress;
        _issueAddress = issueAddress;

        _balances[address(0x000000000000000000000000000000000000dEaD)] = total/2; 
        emit Transfer(address(0), address(0x000000000000000000000000000000000000dEaD), _balances[address(0x000000000000000000000000000000000000dEaD)]);
        
        _balances[issueAddress] = total/4; 
        emit Transfer(address(0), issueAddress, _balances[issueAddress]);
        
        _balances[dappAddress] = total/5; 
        emit Transfer(address(0), dappAddress,  _balances[dappAddress]);
        
        _balances[address(this)] = total/20;  
        emit Transfer(address(0), address(this), _balances[address(this)]);


        _dapp = IDapp(dappAddress);

        _marketAddress = marketAddress;

        _addPriceTokenAmount = 1e14;
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
        
        (uint r0,uint r1,) = IUniswapV2Pair(_mainPairAddress).getReserves();
        uint rUsdt = r0;  
        uint bUsdt = IERC20(_usdtAddress).balanceOf(_mainPairAddress);      
        if(address(this)<_usdtAddress){ 
            rUsdt = r1; 
        }
        if( _swapPairMap[to] ){
            if( bUsdt > rUsdt ){
                isAdd = bUsdt - rUsdt > _addPriceTokenAmount; 
            }
        }
        if( _swapPairMap[from] ){
            if( bUsdt < rUsdt ){
                isDel = rUsdt - bUsdt > 0;  
            }
        }
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {       
        require(amount > 0, "UNMS: transfer amount must be >0");
        if(tokenDistributor == address(0)){
            tokenDistributor = address(_dapp.tokenDistributor());
        }
        if(address(this)==from || tokenDistributor==from || address(_dapp)==from || _issueAddress==from || _marketAddress==from ||
           tokenDistributor==to || address(_dapp)==to || _issueAddress==to  || _marketAddress==to) {
            _tokenTransfer(from, to, amount); 
            return;
        }
        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);
        
        if (isAddLiquidity || isDelLiquidity){
            
            _tokenTransfer(from, to, amount);

        }else if(_swapPairMap[from] || _swapPairMap[to]){
            
            if (_swapPairMap[to]) { 
                require(amount <= (_balances[from])*99/100, "UNMS: sell amount exceeds balance 99%");
            }else{ 
                
                _totalBuyAmount += amount; 
                uint32 today = uint32(block.timestamp/86400);   
                if(_dayLimitAmount[today] == 0) resetDayBuyLimit(); 

                require(_daySoldAmount + amount <= _dayLimitAmount[today], "UNMS: exceed day limit amount");
                require(_dayBuyAmountMap[to] == 0, "UNMS: a address can buy one time per day");
                require(amount <= _dayLimitAmountForPerson, "UNMS: exceed day limit amount for person");
                _dayBuyAddressList.push(to); 
                _daySoldAmount += amount;
                _dayBuyAmountMap[to] += amount;

                
               uint256 availableAmount = (_dapp.getBurnAmount() + _totalBuyAmount)/20;
               if(availableAmount > _releasedAmount) {
                   availableAmount = availableAmount - _releasedAmount;
                   if(_balances[address(this)] >= availableAmount){
                        _tokenTransfer(address(this), _releaseAddress, availableAmount);
                        _releasedAmount += availableAmount;
                   }
               }

            }
            _tokenTransfer(from, to, amount*93/100);     
            _tokenTransfer(from, _marketAddress, amount*7/100);              
        }else{
             _tokenTransfer(from, to, amount);
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

    
    function getLockedAmount() external view returns(uint256) {
        return _balances[address(this)];
    }

    
    function getTodayLimitAmount(address addr) external view returns(uint256 todayLimitAmount, uint256 myLimitAmount) {
        todayLimitAmount =  _dayLimitAmount[uint32(block.timestamp/86400)];
        if(_dayLimitAmountForPerson > _dayBuyAmountMap[addr])  myLimitAmount = _dayLimitAmountForPerson - _dayBuyAmountMap[addr];
    }

    
    function resetDayBuyLimit() internal {    
        uint32 today = uint32(block.timestamp/86400);  
        
        if(_dayLimitAmount[today-4] > 0) delete _dayLimitAmount[today-4];
        if(_dayLimitAmount[today-3] > 0) delete _dayLimitAmount[today-3];

        address[] memory addressList = _dayBuyAddressList;
        for(uint i=0;i<addressList.length;i++){
            delete _dayBuyAmountMap[addressList[i]];
        }
        delete _dayBuyAddressList;
        delete _daySoldAmount;
        _dayLimitAmount[today] = _dapp.getBurnAmount()/50; 
        _dayLimitAmountForPerson = _dayLimitAmount[today]/50; 
    }

    function getReleaseAddress() external view returns(address) {
        return _releaseAddress;
    }

    function getMarketAddress() external view returns(address) {
        return _marketAddress;
    }

    function setAddPriceTokenAmount(uint addPriceTokenAmount) external onlyOwner{
        _addPriceTokenAmount = addPriceTokenAmount;
    }

    function getTodayBuyAddressList() external view returns(address[] memory){
        return _dayBuyAddressList;
    }

    function getTodayBuyAmount(address userAddress) external view returns(uint256){
        return _dayBuyAmountMap[userAddress];
    }

    receive() external payable {}
}

contract Unms is BaseToken {
    constructor(address dappAddress) BaseToken(
        "UNMS",
        "UNMS",
        1000000000,
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 
        address(0x55d398326f99059fF775485246999027B3197955), 
        address(0x993Ef42C3d2b0dFF7e2AdA1B83F211BD2025AaFF), 
        address(0x6FEb077fAE31C4ed7788D874ad75Bba22b0ACc60), 
        address(0xD63eD86047853035F3880E8095F0c42e562c06A6), 
        dappAddress
    ){

    }
}