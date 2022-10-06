/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

interface NFTContract {
   function reward(uint256 rewardTotal) external;
}

abstract contract AbsToken is IERC20, Ownable {
    uint256 private _tTotal;

    uint256 private _rTotal;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    address private coinAddress;
    address private fundAddress; 
    address private dividendAddress;

    string private _symbol; 
    string private _name; 
    uint8 private _decimals; 

    // 买滑点8%，卖10%
    uint256 private fundFee = 100;// 1%营销钱包分红
    uint256 private dividendFee = 200;// 2%nft分红
    uint256 private lpFee = 500; // 5%回流
    uint256 private burnFee = 200; // 2%卖出销毁

    address private mainPair; 
    uint256 private constant MAX = ~uint256(0); // 无限大

    ISwapRouter private _swapRouter; 

    uint256 private numTokensSellToFund;

    TokenDistributor private _tokenDistributor;
    address private usdt;

    uint256 private startTradeBlock; 
    mapping(address => bool) private _blackList;

    mapping(address => bool) private _feeWhiteList;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 private aprHour = 85814;
    uint256 private constant AprDivBase = 100000000;

    uint256 private _lastRewardTime;

    uint256 private _startTime;

    bool private inSwap; 
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, 
        uint8 Decimals, uint256 Supply, address CoinAddress,
        address FundAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _startTime = block.timestamp;

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        
        _allowances[address(this)][address(_swapRouter)] = MAX;

        IERC20(usdt).approve(address(_swapRouter), MAX);

        uint256 tTotal = Supply * 10 ** _decimals;
        _tTotal = tTotal;
        
        _rTotal = tTotal;

        _balances[CoinAddress] = _tTotal;
        emit Transfer(address(0), CoinAddress, _tTotal);

        fundAddress = FundAddress;
 
        _feeWhiteList[CoinAddress] = true; 
        _feeWhiteList[FundAddress] = true; 
        _feeWhiteList[msg.sender] = true; 
        _feeWhiteList[address(this)] = true; 
        _feeWhiteList[address(_swapRouter)] = true; 

        numTokensSellToFund = 3000;

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
        return _balances[account] * _rTotal / _tTotal;
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
        bool selling = false; 

        if (from == mainPair || to == mainPair) {
            if (to == mainPair) {
                selling = true;
            }
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
                if (overMinTokenBalance && !inSwap && from != mainPair) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }

            calculateProfit();
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
        uint256 realAmount = tAmount * _tTotal / _rTotal;
        _balances[sender] -= realAmount;

        uint256 feeAmount; 
        uint256 burnAmount;
        if (takeFee) {
            if (selling) {
                feeAmount = realAmount * (fundFee + dividendFee + lpFee + burnFee) / 10000;
                _takeTransfer(sender, address(this), feeAmount);

                burnAmount = realAmount * (burnFee) / 10000;
                _takeTransfer(sender, DEAD, burnAmount);

                feeAmount = realAmount + burnAmount;
            } else {
                feeAmount = realAmount * (fundFee + dividendFee + lpFee) / 10000;
                _takeTransfer(sender, address(this), feeAmount);
            }
        }

        realAmount = realAmount - feeAmount;

        _takeTransfer(sender, recipient, realAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 lpAmount = tokenAmount * lpFee / (lpFee + dividendFee + fundFee) / 2;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0, // accept any amount of usdt
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 totalUsdtFee = dividendFee + fundFee + lpFee/2;

        uint256 usdtFund = usdtBalance * fundFee / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), fundAddress, usdtFund);

        uint256 usdtDividend = usdtBalance * dividendFee / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), dividendAddress, usdtDividend);

        if (dividendAddress != address(0)) {
            NFTContract(dividendAddress).reward(usdtDividend);
        }

        uint usdtLP = usdtBalance - usdtFund - usdtDividend;
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            lpAmount,
            usdtLP,
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

    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    function setFeeBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }

    function claimBalance() external onlyOwner{
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external onlyOwner{
        IERC20(token).transfer(coinAddress, amount);
    }

    function setNFTAddress(address addr) external onlyOwner{
        dividendAddress = addr;
    }

    function getNFTAddress() external view onlyOwner returns(address addr){
        return dividendAddress;
    }

    function calculateProfit() public onlyOwner {
        if (block.timestamp > (_startTime + 365 days)){
            return;
        }
        
        uint256 blockTime = block.timestamp;
        uint256 lastRewardTime = _lastRewardTime;
        if (blockTime < lastRewardTime + 1 hours) {
            return;
        }

        uint256 deltaTime = blockTime - lastRewardTime;

        uint256 times = deltaTime / 1 hours;

        uint256 total = _rTotal;
        for (uint256 i=0; i < times; i++) {
            unchecked {
                total *= (AprDivBase + aprHour) / AprDivBase;
                if (total < _rTotal) {
                    return;
                }
            }
        }

        _rTotal = total;
        _lastRewardTime = lastRewardTime + times * (1 hours);
    }
}

contract LaEeb is AbsToken {
    constructor() AbsToken(
        "LaEeb FlKing",
        "LaEeb",
        18,
        1 * 10 ** 8,
        address(0x40bf1703b12A98507e9a696c7479681B74678CA4),
        address(0xCA2cE3c0dc486526cf3EBd06c7066A4e2E30e4eb)
    ){

    }
}