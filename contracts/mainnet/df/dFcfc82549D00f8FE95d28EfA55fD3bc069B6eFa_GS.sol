/**
 *Submitted for verification at BscScan.com on 2023-01-06
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

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public _destroyFee = 100;
    uint256 public _lpDividendFee = 0;
    uint256 public _fund1 = 300;
    uint256 public _fund2 = 200;
    uint256 public startTradeBlock;

    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = ReceiveAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 3 * 10 ** Decimals;
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
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 balance = balanceOf(from);
            require(balance >= amount, "balanceNotEnough");

            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!startTrade");

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 95 / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
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
            uint256 destroyAmount = tAmount * _destroyFee / 10000;
            if (destroyAmount > 0) {
                feeAmount += destroyAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }
             uint256 fund1amount = tAmount * _fund1 / 10000;
            if (fund1amount > 0) {
                feeAmount += fund1amount;
                _takeTransfer(sender, address(0x73d774119B5a8F3Ed863B06C7E9B3aa65825F6c8), fund1amount);
            }
               uint256 fund2amount = tAmount * _fund2 / 10000;
            if (fund2amount > 0) {
                feeAmount += fund2amount;
                _takeTransfer(sender, address(0xd336789Bc7e3aACcb245584BE99Ddc38D01Eb2a8), fund2amount);
            }

            uint256 lpDividendAmount = tAmount * _lpDividendFee / 10000;
            if (lpDividendAmount > 0) {
                feeAmount += lpDividendAmount;
                _takeTransfer(sender, address(this), lpDividendAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        if (_owner == msg.sender || fundAddress == msg.sender) {
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
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        address sender = address(this);
        uint256 balance = balanceOf(sender);
        if (balance < holderRewardCondition) {
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
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    _tokenTransfer(sender, shareHolder, amount, false);
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

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyOwner {
        _progressBlockDebt = progressBlockDebt;
    }

    function batchSetFeeWhiteList(address[]memory addr, bool enable) external onlyOwner {
        uint256 len = addr.length;
        for (uint256 i; i < len; ++i) {
            _feeWhiteList[addr[i]] = enable;
        }
    }
}

contract GS is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
    //0x10ED43C718714eb63d5aA57B78B54704E256024E
    
        address(0x55d398326f99059fF775485246999027B3197955),
        "GS",
        "GS",
        18,
        4000000,
    //Receive
        address(0x02eC99616c541A8d43ac1C4fde60F02d73eb70E1)
    ){

    }
}