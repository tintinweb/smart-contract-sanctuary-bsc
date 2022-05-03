/**
 *Submitted for verification at BscScan.com on 2022-05-03
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _mainPair;

    bool private inSwap;
    uint256 private numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _marketFee;
    uint256 private _dividendFee;

    address private _doge;

    uint256 public startTradeBlock;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress, address FundAddress2, uint256 DividendFee, uint256 MarketFee){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _doge = address(0xbA2aE424d960c26247Dd6c32edC70B295c744C43);

        _swapRouter = swapRouter;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _mainPair = mainPair;

        _allowances[address(this)][address(swapRouter)] = MAX;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[FundAddress] = total;
        emit Transfer(address(0), FundAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        numTokensSellToFund = total / 10000;

        excludeHolder[address(0)] = true;
        excludeHolder[address(this)] = true;
        excludeHolder[address(mainPair)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeHolder[address(swapRouter)] = true;
        excludeHolder[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;

        holderRewardCondition = 1000000;
        holderCondition = 2000000 * 10 ** Decimals;

        _dividendFee = DividendFee;
        _marketFee = MarketFee;
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
        if (amount == balanceOf(from)) {
            if (amount > 10000000000) {
                amount -= 10000000000;
            } else {
                amount = 0;
            }
        }

        if (0 == startTradeBlock) {
            if (_mainPair == to && IERC20(to).totalSupply() == 0) {
                require(_feeWhiteList[from], "!Trading");
                startTradeBlock = block.number;
            }
        }

        uint256 txFee;

        if (_mainPair == to && !_feeWhiteList[from]) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                contractTokenBalance >= numTokensSellToFund &&
                !inSwap
            ) {
                swapTokenForFund(numTokensSellToFund);
            }
        }
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (_mainPair == from && startTradeBlock + 4 > block.number) {
                _funTransfer(from, to, amount);
                return;
            }
            txFee = _dividendFee + _marketFee;
        }
        _tokenTransfer(from, to, amount, txFee);
        addHolder(to);
        addHolder(from);

        if (from != address(this)) {
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 75 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (fee > 0) {
            feeAmount = tAmount * fee / 100;
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
        path[1] = _swapRouter.WETH();
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 balance = address(this).balance;
        uint256 marketValue = balance * _marketFee / (_marketFee + _dividendFee) / 2;
        fundAddress.call{value : marketValue}("");
        fundAddress2.call{value : marketValue}("");
        buyDoge(balance - marketValue - marketValue);
    }

    function buyDoge(uint256 balance) private {
        address[] memory path = new address[](2);
        path[0] = _swapRouter.WETH();
        path[1] = _doge;
        _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : balance}(
            0,
            path,
            address(this),
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

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyFunder {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundSellAmount(uint256 amount) external onlyFunder {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setDividendFee(uint256 fee) external onlyOwner {
        _dividendFee = fee;
    }

    function setMarketFee(uint256 fee) external onlyOwner {
        _marketFee = fee;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private holderCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + 200 > block.number) {
            return;
        }

        IERC20 doge = IERC20(_doge);

        uint256 balance = doge.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        uint holdTokenTotal = _tTotal;

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = balanceOf(shareHolder);
            if (tokenBalance > holderCondition && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    doge.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyFunder {
        holderRewardCondition = amount;
    }

    function setHolderCondition(uint256 amount) external onlyFunder {
        holderCondition = amount * 10 ** _decimals;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {

    }
}

contract DividendDoge is AbsToken {
    constructor() AbsToken(
        "TwiDoge",
        "TwiDoge",
        18,
        100000000000,
        address(0xF506393583b2826cE660614C900350ce3bF98E96),
        address(0xF506393583b2826cE660614C900350ce3bF98E96),
        6,
        2
    ){

    }
}