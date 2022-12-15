/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private devAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor private _tokenDistributor;

    uint256 public _buyInviteFee = 0;
    uint256 public _buyFundFee = 300;
    uint256 public _buyDevFee = 100;
    uint256 public _buyLPDividendFee = 100;
    uint256 public _sellInviteFee = 0;
    uint256 public _sellFundFee = 300;
    uint256 public _sellDevFee = 100;
    uint256 public _sellLPDividendFee = 100;
    uint256 public _transferFee = 500;
    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public _mainPair;
    uint256 public _limitAmount;
    mapping(address => bool) private _feeBlackList;

    mapping(address => address) public _invitor;
    uint256 public _invitorHoldCondition;
    uint256 public _numToSell;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress,address DevAddress, address ReceiveAddress,
        uint256 LimitAmount, uint256 NumToSell
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(address(swapRouter), MAX);

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        devAddress = DevAddress;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[DevAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = LimitAmount * 10 ** Decimals;

        _tokenDistributor = new TokenDistributor(usdt);

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;


        holderRewardCondition = 1000 * 10 ** Decimals;

        _numToSell = NumToSell * 10 ** Decimals;
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        require(!_feeBlackList[from], "Transfer from the feeBlackList address");
        bool takeFee = false;


        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        if (_swapPairList[from] || _swapPairList[to]) {

            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }


            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
 
                if (0 == startTradeBlock) {

                    require(0 < startAddLPBlock && _swapPairList[to], "!startTrade");
                }

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    _checkLimit(to);
                    return;
                }
            }
        } else {

            if (address(0) == _invitor[to] && !_feeWhiteList[to] && 0 == _balances[to] && amount > 0) {
                _invitor[to] = from;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
        _checkLimit(to);

        if (from != address(this)) {
            if (_swapPairList[to]) {
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

        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

 
    function _checkLimit(address to) private view {

        if (0 == _limitAmount || 0 == startTradeBlock) {
            return;
        }

        if (!_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
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
            if (_swapPairList[sender]) {//Buy

                uint256 inviteAmount = tAmount * _buyInviteFee / 10000;
                if (inviteAmount > 0) {
                    feeAmount += inviteAmount;
                    address current = recipient;
                    uint256 perInviteAmount = inviteAmount / 3;
                    uint256 invitorHoldCondition = _invitorHoldCondition;
                    uint256 invitorAmount;
                    for (uint256 i; i < 2; ++i) {
                        address inviter = _invitor[current];
                        if (address(0) == inviter) {
                            break;
                        }
                        if (invitorHoldCondition == 0 || balanceOf(inviter) >= invitorHoldCondition) {
                        if(0==i){
                           invitorAmount = perInviteAmount*2;
                        }else{
                           invitorAmount=perInviteAmount;
                        }
                           inviteAmount -= invitorAmount;
                         _takeTransfer(sender, inviter, invitorAmount);
                      }
                current = inviter;
                 }
                }

                if (inviteAmount > 100) {
                    _takeTransfer(sender, fundAddress, inviteAmount);
                }

                uint256 fundAmount = tAmount * _buyFundFee / 10000;
                address tokenDistributor = address(_tokenDistributor);
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, tokenDistributor, fundAmount);
                }

                uint256 devAmount = tAmount * _buyDevFee / 10000;
                if (devAmount > 0) {
                    feeAmount += devAmount;
                    _takeTransfer(sender, devAddress, devAmount);
                }

                uint256 lpDividendAmount = tAmount * _buyLPDividendFee / 10000;
                if (lpDividendAmount > 0) {
                    feeAmount += lpDividendAmount;
                    _takeTransfer(sender, address(this), lpDividendAmount);
                }
            } else if (_swapPairList[recipient]) {//Sell

               uint256 inviteAmount = tAmount * _sellInviteFee / 10000;
                if (inviteAmount > 0) {
                    feeAmount += inviteAmount;
                    address current = sender;
                    uint256 perInviteAmount = inviteAmount / 3;
                    uint256 invitorHoldCondition = _invitorHoldCondition;
                    uint256 invitorAmount;
                    for (uint256 i; i < 2; ++i) {
                        address inviter = _invitor[current];
                        if (address(0) == inviter) {
                            break;
                        }
                        if (invitorHoldCondition == 0 || balanceOf(inviter) >= invitorHoldCondition) {
                        if(0==i){
                           invitorAmount = perInviteAmount*2;
                        }else{
                           invitorAmount=perInviteAmount;
                        }
                           inviteAmount -= invitorAmount;
                         _takeTransfer(sender, inviter, invitorAmount);
                      }
                current = inviter;
                 }
                }

                if (inviteAmount > 100) {
                    _takeTransfer(sender, fundAddress, inviteAmount);
                }

                uint256 fundAmount = tAmount * _sellFundFee / 10000;
                address tokenDistributor = address(_tokenDistributor);
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, tokenDistributor, fundAmount);
                }

                uint256 devAmount = tAmount * _sellDevFee / 10000;
                if (devAmount > 0) {
                    feeAmount += devAmount;
                    _takeTransfer(sender, devAddress, devAmount);
                }

                uint256 lpDividendAmount = tAmount * _sellLPDividendFee / 10000;
                if (lpDividendAmount > 0) {
                    feeAmount += lpDividendAmount;
                    _takeTransfer(sender, address(this), lpDividendAmount);
                }
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(tokenDistributor); 
                    uint256 numTokensSellToFund = _numToSell;
                    if (contractTokenBalance >= numTokensSellToFund) {
                        _tokenTransfer(tokenDistributor, address(this), contractTokenBalance, false);
                        swapTokenForFund(contractTokenBalance);
                    }
                }
            } else {//Transfer
                feeAmount = tAmount * _transferFee / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), feeAmount);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }
    function setDevAddress(address addr) external onlyOwner {
        devAddress = addr;
        _feeWhiteList[addr] = true;
    }
    function setBuyFee(uint256 buyInviteFee,  uint256 buyFundFee,uint256 buyDevFee,uint256 buyLPDividendFee) external onlyOwner {
        _buyInviteFee = buyInviteFee;
        _buyFundFee = buyFundFee;
        _buyDevFee = buyDevFee;
        _buyLPDividendFee = buyLPDividendFee;
    }

    function setSellFee(uint256 sellInviteFee, uint256 sellFundFee, uint256 sellDevFee,uint256 sellLPDividendFee) external onlyOwner {
        _sellInviteFee = sellInviteFee;
        _sellFundFee = sellFundFee;
        _sellDevFee = sellDevFee;
        _sellLPDividendFee = sellLPDividendFee;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }


    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }
    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }
    function setFeeBlackList(address addr, bool enable) external onlyOwner {
        _feeBlackList[addr] = enable;
    }
    function removeFeeBlackList(address addr) external onlyOwner {
        _feeBlackList[addr] = false;
    }

    function isFeeBlackList(address addr) external view returns (bool){
        return _feeBlackList[addr];
    }

     function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        if (_feeWhiteList[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }

    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
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
        if (0 == startTradeBlock) {
            return;
        }
        if (progressRewardBlock + progressRewardBlockDebt > block.number) {
            return;
        }

        address sender = address(this);
        uint256 balance = balanceOf(sender);
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 mainPair = IERC20(_mainPair);
        uint holdTokenTotal = mainPair.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = holderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = mainPair.balanceOf(shareHolder);
            if (tokenBalance >= holdCondition) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0 && !excludeHolder[shareHolder]) {
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

       function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyOwner {
        progressRewardBlockDebt = blockDebt;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyOwner {
        _invitorHoldCondition = amount;
    }


}

contract TFX is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "TFXToken",
        "TFX",
        18,
        100000000,
        address(0x6CD4E040c4970A7bA4a189Ce1270c02aF210eE34),
        address(0x57414E353a4e413DB36F3f18Cd9067FCc059bB97),
        address(0x5723156cAccD067D0F2e9201f9C70802093Cebf0),
        0,
        300
    ){

    }
}