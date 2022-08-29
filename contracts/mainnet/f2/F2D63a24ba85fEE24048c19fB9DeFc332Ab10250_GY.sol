/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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
}

interface ISwapPair {
    function sync() external;
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

    uint256 private constant MAX = ~uint256(0);

    uint256 public _txFee = 700;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;

    address public _mainPair;

    uint256 public _limitAmount;

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
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

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
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 3 * 10 ** Decimals;
        _limitAmount = 30 * 10 ** Decimals;
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
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (to == _mainPair && _feeWhiteList[from] && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    _checkLimit(to);
                    return;
                }
                takeFee = true;
            }

            if (_swapPairList[to]) {
                isSell = true;
            }
        } else {
            if (0 == balanceOf(to) && amount >= 10 ** (_decimals - 5) && from != to) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
        _checkLimit(to);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _checkLimit(address to) private view {
        if (0 == _limitAmount) {
            return;
        }
        if (!_swapPairList[to] && !_feeWhiteList[to]) {
            if (0 < startTradeBlock) {
                require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
            }
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 9500 / 10000;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    mapping(address => uint256) public _adrFeeAmount;

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            feeAmount = tAmount * _txFee / 10000;
            if (feeAmount > 0) {
                uint256 fundAmount = feeAmount;
                uint256 lpDividendAmount = feeAmount * 60 / 100;
                fundAmount -= lpDividendAmount;
                _takeTransfer(sender, address(this), lpDividendAmount);

                address current;
                if (isSell) {
                    current = sender;
                } else {
                    current = recipient;
                }

                address invitor;
                uint256 perInviteAmount = feeAmount * 10 / 100;
                for (uint256 i; i < 2;) {
                    invitor = _inviter[current];
                    if (address(0) == invitor) {
                        break;
                    }
                    _takeTransfer(sender, invitor, perInviteAmount);
                    fundAmount -= perInviteAmount;
                    current = invitor;
                unchecked{
                    ++i;
                }
                }
                _takeTransfer(sender, fundAddress, fundAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setTxFee(uint256 txFee) external onlyOwner {
        _txFee = txFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
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

    function getHolderLength() external view returns (uint256){
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
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (progressRewardBlock + progressRewardBlockDebt > block.number) {
            return;
        }

        address sender = address(this);
        uint256 rewardBalance = balanceOf(sender);
        if (rewardBalance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

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
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = rewardBalance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    _tokenTransfer(sender, shareHolder, amount, false, false);
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

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyOwner {
        progressRewardBlockDebt = blockDebt;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }
}

contract GY is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "GY",
        "GY",
        18,
        3600,
    //Fund
        address(0xa38457478a8ab23B6337237F3BD842e767284D26),
    //Received
        address(0x1Ba38558A39E9de889f8E8e934eD49b42eB3D1Be)
    ){

    }
}