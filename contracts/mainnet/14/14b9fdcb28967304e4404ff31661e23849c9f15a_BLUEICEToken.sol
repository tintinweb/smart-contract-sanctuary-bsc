/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// SPDX-License-Identifier: MIT

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
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface ISwapFactory {
    
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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


contract TokenDistributor {
    
    constructor (address token) {
        
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}


abstract contract Token is IERC20, Ownable {
    
    mapping(address => uint256) private _balances;
    
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public fundFee = 150;
    uint256 public dividendFee = 150;
    uint256 public lpFee = 150;

    address public mainPair;

    mapping(address => bool) private _feeWhiteList;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;

    IERC20 private _usdtPair;

    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;

    TokenDistributor _tokenDistributor;
    address private usdt;

    uint256 private startTradeBlock;
    mapping(address => bool) private _blackList;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        
        _tTotal = Supply * 10 ** _decimals;
        
        _balances[FundAddress] = _tTotal;
        emit Transfer(address(0), FundAddress, _tTotal);

        
        fundAddress = FundAddress;

        
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;


        
        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        
        excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
        
        numTokensSellToFund = _tTotal / 10000;

        _tokenDistributor = new TokenDistributor(usdt);
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
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        
        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;

        
        if (from == mainPair || to == mainPair) {
            
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }

            
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;

                
                if (block.number <= startTradeBlock + 2) {
                    
                    if (to != mainPair) {
                        _blackList[to] = true;
                    }
                }

                
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >= numTokensSellToFund;
                if (
                    overMinTokenBalance &&
                    !inSwap &&
                    from != mainPair
                ) {
                    if(from == mainPair){
                        swapTokenForFund(numTokensSellToFund, true);
                    }else{
                        swapTokenForFund(numTokensSellToFund, false);
                    }
                }
            }
            
            if (from == mainPair) {
                addLpProvider(to);
            } else {
                addLpProvider(from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        
        if (
            from != address(this)
            && startTradeBlock > 0) {
            processLP(500000);
        }
    }

    
    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;
    
    mapping(address => bool) excludeLpProvider;

    
    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 10;
    uint256 private progressLPBlock;

    function processLP(uint256 gas) private {
        
        if (progressLPBlock + 200 > block.number) {
            return;
        }
        
        uint totalPair = _usdtPair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));
        
        if (usdtBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;

        
        uint256 gasLeft = gasleft();

        
        while (gasUsed < gas && iterations < shareholderCount) {
            
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            
            pairBalance = _usdtPair.balanceOf(shareHolder);
            
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = usdtBalance * pairBalance / totalPair;
                
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if (takeFee) {
            feeAmount = tAmount * (lpFee + fundFee + dividendFee) / 10000;
            
            _takeTransfer(sender, address(this), feeAmount);
            
            feeAmount = feeAmount;
        }

        
        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }


    function swapTokenForFund(uint256 tokenAmount, bool isBuy) private lockTheSwap {
        uint256 lpAmount = tokenAmount * lpFee / (lpFee + dividendFee) / 2;
        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));
        swapTokensForUsdt(tokenAmount - lpAmount);
        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) - initialBalance;
        uint256 totalUsdtFee = lpFee / 2 + dividendFee + fundFee;
        if(isBuy){
            uint256 lpUsdt = newBalance * lpFee / 2 / totalUsdtFee;
            USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);
            
            addLiquidityUsdt(lpAmount, lpUsdt);
        }else{
            USDT.transferFrom(address(_tokenDistributor), fundAddress, newBalance * fundFee / totalUsdtFee);
        }
    }

    
    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0,
            0,
            fundAddress,
            block.timestamp
        );
    }

    
    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(_tokenDistributor),
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }


    
    receive() external payable {}

    
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setFundFee(uint256 _fundFee) external onlyOwner{
        fundFee = _fundFee;
    }

    function setDividendFee(uint256 _dividendFee) external onlyOwner{
        dividendFee = _dividendFee;
    }

    function setLpFee(uint256 _lpFee) external onlyOwner{
        lpFee = _lpFee;
    }
    
    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    
    function removeBlackList(address addr) external onlyOwner {
        _blackList[addr] = false;
    }

    
    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }


    
    function claimBalance() public {
        payable(fundAddress).transfer(address(this).balance);
    }

    
    function claimToken(address token, uint256 amount) public {
        IERC20(token).transfer(fundAddress, amount);
    }
}

contract BLUEICEToken is Token {
    constructor() Token(
        "Blue Ice",
        "BlueIce",
        9,
        2100,
        address(0x0F57CDa51AF8391F3ec1ED518D053B89d4957701)
    ){

    }
}