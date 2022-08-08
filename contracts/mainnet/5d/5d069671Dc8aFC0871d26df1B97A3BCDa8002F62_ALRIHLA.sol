/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _destroyFee = 1;
    uint256 public _dividendFee = 2;
    uint256 public _lpFee = 2;

    uint256 public startTradeBlock;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;

        address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _swapPairList[mainPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 30 * 10 ** IERC20(USDTAddress).decimals();
        holderCondition = 4000 * 10 ** Decimals;
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

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                if (_swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (!inSwap && _swapPairList[to]) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        uint256 swapFee = _lpFee + _dividendFee;
                        uint256 numTokensSellToFund = amount * swapFee / 30;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund, swapFee);
                    }
                }
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

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
        uint256 feeAmount = tAmount * 80 / 100;
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
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 destroyAmount = tAmount * _destroyFee / 100;
            if (destroyAmount > 0) {
                feeAmount += destroyAmount;
                _takeTransfer(
                    sender,
                    address(0x000000000000000000000000000000000000dEaD),
                    destroyAmount
                );
            }

            uint256 swapFee = _lpFee + _dividendFee;
            uint256 swapAmount = tAmount * swapFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _lpFee;

        uint256 lpAmount = tokenAmount * lpFee / swapFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        swapFee -= lpFee;
        uint256 balance = address(this).balance;
        uint256 lpValue = balance * lpFee / swapFee;

        _swapRouter.addLiquidityETH{value : lpValue}(
            address(this),
            lpAmount,
            0,
            0,
            fundAddress,
            block.timestamp
        );

        path[0] = _swapRouter.WETH();
        path[1] = _usdt;
        _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : balance - lpValue}(
            0, path, address(this), block.timestamp
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDividendFee(uint256 dividendFee) external onlyOwner {
        _dividendFee = dividendFee;
    }

    function setDestroyFee(uint256 destroyFee) external onlyOwner {
        _destroyFee = destroyFee;
    }

    function setLPFee(uint256 lpFee) external onlyOwner {
        _lpFee = lpFee;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        if (msg.sender == _owner || msg.sender == fundAddress) {
            IERC20(token).transfer(to, amount);
        }
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public holderCondition;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + progressRewardBlockDebt > block.number) {
            return;
        }

        IERC20 usdt = IERC20(_usdt);

        uint256 balance = usdt.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        uint holdTokenTotal = totalSupply();

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
            if (tokenBalance >= holderCondition && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    usdt.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount * 10 ** _decimals;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyOwner {
        progressRewardBlockDebt = blockDebt;
    }
}

contract ALRIHLA is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "AL RIHLA",
        "AL RIHLA",
        18,
        10000000,
    //Fund
        address(0x53297838d4Ea305F836a2fBE2A2a9a8Ff3Aa1008),
    //Receive
        address(0x26cB26F4d1DB1d91330681C511e204f5b6cCc74d)
    ){

    }
}