/**
 *Submitted for verification at BscScan.com on 2022-11-19
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

    function WETH() external pure returns (address);

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
        require(_owner == msg.sender, "!owner");
        _;
    }

    //放弃权限
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private marketAddress;
    address private desAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private startTradeBlock;
    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) private _blackList;

    mapping(address => bool) private _swapPairList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    bool private inSwap;
    uint256 private numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    address private usdt;
    TokenDistributor private _tokenDistributor;
    uint256 public _txFee = 300;
    uint256 public _funFee = 200;
    uint256 public _marketFee = 100;
    uint256 public _lpFee = 0;

    IERC20 private _usdtPair;

    uint256 private limitAmount;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress, address MarketAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _usdtPair = IERC20(usdtPair);

        _swapPairList[usdtPair] = true;

        _allowances[address(this)][address(_swapRouter)] = MAX;

        _tTotal = Supply * 10 ** Decimals;
        _balances[address(0x7316BA34584544DA3DD2332cAe1e4C1E2c3eb308)] = _tTotal;
        emit Transfer(address(0), address(0x7316BA34584544DA3DD2332cAe1e4C1E2c3eb308), _tTotal);

        fundAddress = FundAddress;
        marketAddress = MarketAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[MarketAddress] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        numTokensSellToFund =  100000000 * 10 ** Decimals;
        _tokenDistributor = new TokenDistributor(usdt);

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        limitAmount = _tTotal;
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
        require(!_blackList[from], "blackList");

        uint256 txFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                startTradeBlock = block.number;
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                txFee = _txFee;

                if (block.number <= startTradeBlock + 3) {
                    if (!_swapPairList[to]) {
                        _blackList[to] = true;
                    }
                }

                uint256 contractTokenBalance = balanceOf(address(this));
                if (
                    contractTokenBalance >= numTokensSellToFund &&
                    !inSwap &&
                    _swapPairList[to]
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }

            if (_swapPairList[from]) {
                addLpProvider(to);
            } else {
                addLpProvider(from);
            }
        }
        _tokenTransfer(from, to, amount, txFee);

        if (!_swapPairList[to] && !_feeWhiteList[to]) {
            require(limitAmount >= balanceOf(to), "exceed LimitAmount");
        }

        if (
            from != address(this)
            && startTradeBlock > 0) {
            processLP(500000);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 10000;
        if (fee > 0) {
            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
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

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        USDT.transferFrom(address(_tokenDistributor), fundAddress, usdtBalance * _funFee / _txFee);
        USDT.transferFrom(address(_tokenDistributor), marketAddress, usdtBalance * _marketFee / _txFee);
        if(_lpFee > 0){
            USDT.transferFrom(address(_tokenDistributor), desAddress, usdtBalance * _lpFee / _txFee);
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setMarketAddress(address addr) external onlyOwner {
        marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDesAddress(address addr) external onlyOwner {
        desAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundSellAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setTxFee(uint256 fee,uint256 funFee,uint256 marketFee,uint256 lpFee) external onlyOwner {
        _txFee = fee;
        _funFee = funFee;
        _marketFee = marketFee;
        _lpFee = lpFee;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }

    receive() external payable {}

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
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
    uint256 private lpRewardCondition = 10000000000000000000000000;
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
        if (usdtBalance <= lpRewardCondition) {
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

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        limitAmount = amount * 10 ** _decimals;
    }
}

contract Argentina is AbsToken {
    constructor() AbsToken(
        "Argentina-10",
        "Argentina-10",
        18,
        100000000,
        address(0x2Ed2024f4970c7169Bb6995B016696D19991fa85),
        address(0xf8fCA7714BdC38321542f4f7a594c7d962500ec0)
    ){

    }
}