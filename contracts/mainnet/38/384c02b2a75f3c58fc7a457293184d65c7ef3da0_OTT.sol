/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.8.14;
// SPDX-License-Identifier: MIT
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

interface ISwapPair {
    function sync() external;
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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

contract OTT is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public _recoverAddress;

    address public specifiedAddress = 0xC011504520c0453C2E73E4062617473434f1afF5;
    address public usdtChargeAddress = 0xB0ab490ef4f41F23da8ceA36D49FA74DE2BDEFF3;
    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 distributorGas = 300000;
    uint256 public minPeriod = 600;
    uint256 public LPFeefenhong;
    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public _updated;
    uint256 currentIndex;  
    uint256 public swapProcess = 1000 * 10**18;
    uint256 public bounProcess = 1 * 10**9;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    uint256 public swapUsdtAmount = 0;

    uint256 private _tTotal;

    mapping(address => bool) public _swapPairList;

    bool private swapping;
    bool public tradeSwitsh = true;
    bool public isSwapAll = true;
    uint256 public swapTokensAtAmount = 1000;
    uint256 public deadAmount = 21000000 * 10 ** 18;
    bool public deadAmountSwitch = true;

    address public _mainPair;
    ISwapRouter public swapRouter;

    constructor (){
        _name = "OLD TESTAMENT";
        _symbol = "OTT";
        _decimals = 18;

        address assgin = 0x67047ce748bf2fe7b6f510E48219Db860780209a;
        _recoverAddress = 0x599D3E90f0456E84B2B1A552926BB2d8B3e3d62C;

        swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _mainPair = mainPair;
        _swapPairList[mainPair] = true;

        uint256 total = 2100000000 * 10 ** _decimals;
        _tTotal = total;

        _balances[assgin] = total * 99 / 100;
        _balances[_recoverAddress] = total / 100;

        emit Transfer(address(0), _recoverAddress, total * 99 / 100);
        emit Transfer(address(0), assgin, total / 100);

        _feeWhiteList[owner()] = true;
        _feeWhiteList[_recoverAddress] = true;
        _feeWhiteList[assgin] = true;
        _feeWhiteList[specifiedAddress] = true;
        _feeWhiteList[usdtChargeAddress] = true;

        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true; 
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[assgin] = true;
        isDividendExempt[_recoverAddress] = true;
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == address(0) || account == address(0x000000000000000000000000000000000000dEaD)) {
            return 0;
        }
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
        if (_allowances[sender][msg.sender] != ~uint256(0)) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer( address from, address to, uint256 amount ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 contractTokenBalance = balanceOf(address(this)) - swapUsdtAmount;
        uint256 totalAmount = totalSupply();
        uint256 swapTokensAtAmountFee = totalAmount / swapTokensAtAmount;
        bool canSwap = contractTokenBalance >= swapTokensAtAmountFee;

        if ( tradeSwitsh && canSwap && !swapping && !_swapPairList[from]) { 
			if(isSwapAll){
                contractTokenBalance = swapTokensAtAmountFee;
            }
            swapping = true;

            swapTokensForUSDT(contractTokenBalance, usdtChargeAddress);
			
            swapping = false;
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to] && (_swapPairList[from] || _swapPairList[to])) {
            if(_swapPairList[from]){
                uint256 coinAmount = amount * 2 / 100; 
                uint256 specifiedAmount = amount * 1 / 100; 
                swapUsdtAmount += specifiedAmount;

                _tokenTransfer(from, address(this), coinAmount);
                _tokenTransfer(from, specifiedAddress, specifiedAmount);

                amount = amount - coinAmount - specifiedAmount;
            }else if(_swapPairList[to]){
                uint256 coinAmount = amount * 2 / 100; 
                uint256 specifiedAmount = amount * 1 / 100; 
                swapUsdtAmount += specifiedAmount;

                _tokenTransfer(from, address(this), coinAmount);
                _tokenTransfer(from, specifiedAddress, specifiedAmount);
                
                amount = amount - coinAmount - specifiedAmount;
                if(totalAmount > deadAmount && deadAmountSwitch){
                    _tokenTransfer(to, address(0), amount);
                    ISwapPair(to).sync();
                }
            }
        }
        _tokenTransfer(from, to, amount);

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != _mainPair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != _mainPair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  
        uint256 balance = _balances[address(this)] - swapUsdtAmount;
         if(balance >= swapProcess && from !=address(this) && LPFeefenhong + minPeriod <= block.timestamp) {
             process(distributorGas);
             LPFeefenhong = block.timestamp;
        }
    }
    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }
    function setSwapProcess(uint256 number) public onlyOwner {
        swapProcess = number;
    }
    function setBounProcess(uint256 number) public onlyOwner {
        bounProcess = number;
    }
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0)return;
        uint256 nowbanance = _balances[address(this)] - swapUsdtAmount;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
          uint256 amount = (nowbanance * (IERC20(_mainPair).balanceOf(shareholders[currentIndex]))) / (IERC20(_mainPair).totalSupply());
         if( amount < bounProcess) {
             currentIndex++;
             iterations++;
             return;
         }
         uint256 balance = _balances[address(this)] - swapUsdtAmount;
         if(balance  < amount )return;
            distributeDividend(shareholders[currentIndex],amount);
            
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
   

    function distributeDividend(address shareholder ,uint256 amount) internal {
            
            _balances[address(this)] = _balances[address(this)] - amount;
            _balances[shareholder] = _balances[shareholder] + amount;
             emit Transfer(address(this), shareholder, amount);
    }
	

    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(_mainPair).balanceOf(shareholder) == 0) quitShare(shareholder);           
                return;  
           }
           if(IERC20(_mainPair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);	
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _tokenTransfer( address sender, address recipient, uint256 tAmount ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }
    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        swapTokensAtAmount = amount;
    }
    function setDeadAmount(uint256 amount) external onlyFunder {
        deadAmount = amount;
    }
    function setDeadAmountSwitch(bool success) external onlyFunder {
        deadAmountSwitch = success;
    }
    
    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }
    function setTradeSwitsh(bool _tradeSwitsh) external onlyOwner {
        tradeSwitsh = _tradeSwitsh;
    }
    function claimBalance(address to) external {
        payable(to).transfer(address(this).balance);
    }

    function claimToken(address token, address to) external {
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));
    }
    function setIsSwapAll(bool success) external onlyOwner {
        isSwapAll = success;
    }
    function swapTokensForUSDT(uint256 tokenAmount, address account) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        path[2] = address(usdt);

        _approve(address(this), address(swapRouter), tokenAmount);

        // make the swap
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || _recoverAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}