/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Test(uint256 value);
    event Test(string topic, uint256 v1, uint256 v2, uint256 v3, uint256 v4);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}


abstract contract TTCToken is IERC20, Ownable {
    uint256 private _tTotal;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress; 
    address private dividendAddress; 

    string private _symbol;
    string private _name; 
    uint8 private _decimals; 

    uint256 private fundFee = 100; 
    uint256 private dividendFee = 100;
    uint256 private lpFee = 100; 
    uint256 private burnFee = 100; 

    address private mainPair; 
    uint256 private constant MAX = ~uint256(0); 

    ISwapRouter private _swapRouter;

    uint256 private numTokensSellToFund;

    TokenDistributor private _tokenDistributor;
    address private usdt;

    mapping(address => bool) private _blackList; 

    mapping(address => bool) private _feeWhiteList; 
    address DEAD = 0x000000000000000000000000000000000000dEaD; 

    mapping(address => uint256) private _addressAmount; 

    mapping(address => uint256) private _addressLastSwapTime;

    mapping(address => uint256) private _addressProfit; 

    uint256 private _daySecond = 86400; 

    uint256 private _dayProfitRate = 208; 

    uint256 private constant _dayProfitDivBase = 10000;

    uint256 private _startTimeDeploy;

    bool private inSwap; 
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _startTimeDeploy = block.timestamp;

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            usdt
        );

        _allowances[address(this)][address(_swapRouter)] = MAX;

        IERC20(usdt).approve(address(_swapRouter), MAX);

        uint256 tTotal = Supply * 10**_decimals;
        _tTotal = tTotal;

        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _feeWhiteList[msg.sender] = true; 
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

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

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
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
        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false; 
        bool selling = false;

        if (from == mainPair || to == mainPair) {
            if (to == mainPair) {
                selling = true;
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >=
                    numTokensSellToFund;
                if (overMinTokenBalance && !inSwap && from != mainPair) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }
        _tokenTransfer(from, to, amount, takeFee, selling);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool selling
    ) private {
        uint256 realAmount = tAmount;
        _balances[sender] -= realAmount;

        uint256 feeAmount; 
        uint256 burnAmount; 
        if (takeFee && tAmount > 0) {
            if (selling) {
                feeAmount =(realAmount * (fundFee + dividendFee + lpFee)) /10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(this), feeAmount);
                }
                burnAmount = (realAmount * burnFee) / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, DEAD, burnAmount);
                }

                feeAmount += burnAmount;
            } else {
                feeAmount =(realAmount * (fundFee + dividendFee + lpFee)) /10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(this), feeAmount);
                }
            }
        }

        uint256 recipientRealAmount = realAmount - feeAmount;

        countProfit(sender, recipient, realAmount, recipientRealAmount);

        _takeTransfer(sender, recipient, recipientRealAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {

        uint256 lpAmount = (tokenAmount * lpFee) / (lpFee + dividendFee + fundFee) / 2;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 totalUsdtFee = dividendFee + fundFee + lpFee / 2;

        uint256 usdtFund = (usdtBalance * fundFee) / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), fundAddress, usdtFund);

        uint256 usdtDividend = (usdtBalance * dividendFee) / totalUsdtFee;
        USDT.transferFrom(
            address(_tokenDistributor),
            dividendAddress,
            usdtDividend
        );

        uint256 lpUsdt = usdtBalance - usdtFund - usdtDividend;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            lpAmount,
            lpUsdt,
            0,
            0,
            fundAddress,
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

    function isFeeWhiteList(address addr) external view returns (bool) {
        return _feeWhiteList[addr];
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function isBlackList(address addr) external view returns (bool) {
        return _blackList[addr];
    }

    function setNumTokensSellToFund(uint256 num) external onlyOwner {
        numTokensSellToFund = num;
    }

    function getNumTokensSellToFund() external view returns (uint256) {
        return numTokensSellToFund;
    }

    function setFundAddress(address addr) external onlyOwner {
        _feeWhiteList[addr] = true;
        fundAddress = addr;
    }

    function getFundAddress() external view returns (address) {
        return fundAddress;
    }

    function setDividendAddress(address addr) external onlyOwner {
        _feeWhiteList[addr] = true;
        dividendAddress = addr;
    }

    function getDividendAddress() external view returns (address) {
        return dividendAddress;
    }
    
    function claimBalance() external onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    function countProfit(
        address from,
        address to,
        uint256 amount,
        uint256 recipientRealAmount
    ) private {
        if (block.timestamp - _startTimeDeploy > 31536000){
            return;
        }     
        if (to==address(this) && amount == 0 && recipientRealAmount == 0) {
            if (block.timestamp - _addressLastSwapTime[from] > 1 && _addressLastSwapTime[from]>0) {
                _addressProfit[from] = _addressProfit[from] + _addressAmount[from] * (block.timestamp - _addressLastSwapTime[from]) * _dayProfitRate / _dayProfitDivBase / _daySecond;
                              
                _balances[from] = _balances[from] + _addressProfit[from];
                emit Transfer(address(0), from, _addressProfit[from]);
                _addressProfit[from]=0;
                if (block.timestamp - _addressLastSwapTime[from] >=86400){
                    _addressAmount[from] = balanceOf(from);
                }               
                _addressLastSwapTime[from] = block.timestamp;
            }      
        } else {
            if (from == mainPair || to == mainPair) {
                if (from == mainPair) {
                    if ( block.timestamp - _addressLastSwapTime[to] > 1 ) {
                        _addressProfit[to] = _addressProfit[to] + _addressAmount[to] * (block.timestamp - _addressLastSwapTime[to]) * _dayProfitRate / _dayProfitDivBase / _daySecond;
                        _addressAmount[to] = _addressAmount[to] + recipientRealAmount;
                        _addressLastSwapTime[to] = block.timestamp;
                    }
                }
                if (to == mainPair) {
                    if ( block.timestamp - _addressLastSwapTime[from] > 1 ) {
                        _addressProfit[from] = _addressProfit[from] + _addressAmount[from] * (block.timestamp - _addressLastSwapTime[from]) * _dayProfitRate / _dayProfitDivBase /  _daySecond;
                        if(_addressAmount[from]>=amount){
                            _addressAmount[from] = _addressAmount[from] - amount;
                        }else{
                            _addressAmount[from] = balanceOf(from) - amount;
                        }                      
                        _addressLastSwapTime[from] = block.timestamp;
                    }
                }
            } else {
                if (block.timestamp - _addressLastSwapTime[from] > 1) {
                    _addressProfit[from] =  _addressProfit[from] + _addressAmount[from] * (block.timestamp - _addressLastSwapTime[from]) * _dayProfitRate / _dayProfitDivBase / _daySecond;
                    if(_addressAmount[from]>=amount){
                        _addressAmount[from] = _addressAmount[from] - amount;
                    }else{
                        _addressAmount[from] = balanceOf(from) - amount;
                    }
                    _addressLastSwapTime[from] = block.timestamp;
                }
                if (block.timestamp - _addressLastSwapTime[to] > 1) {
                    _addressProfit[to] = _addressProfit[to] + _addressAmount[to] * (block.timestamp - _addressLastSwapTime[to]) * _dayProfitRate / _dayProfitDivBase / _daySecond;
                    _addressAmount[to] = _addressAmount[to] + recipientRealAmount;
                    _addressLastSwapTime[to] = block.timestamp;
                }
            }
        }
    }
}

contract Twitter is TTCToken {
    constructor()
        TTCToken(
            "Twitter Coin",
            "TTC",
            18,
            100 * 10**8
        )
    {}
}