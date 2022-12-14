/**
 *Submitted for verification at BscScan.com on 2022-12-14
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

    uint256 public _lpFee = 100;
    uint256 public _fundFee = 150;
    uint256 public _lpDividendFee = 250;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public _mainPair;
    uint256 public _numToSell;

    uint256 public _startTradeTime;
    uint256 public _removeLPFee = 5000;
    uint256 public _removeLPFeeDuration = 21 days;

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
        _feeWhiteList[address(0x85F839DDF58586388a922e56ECf5876D04AC21B9)] = true;
        _feeWhiteList[address(0xe4372Ce54d88AEE755225a99f8B9185759020fd8)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        lpRewardCondition = 1 * tokenDecimals;
        _numToSell = 1 * tokenDecimals / 10;

        _addLpProvider(FundAddress);
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        address mainPair = _mainPair;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            uint256 lpBalance = IERC20(mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                uint256 lpAmount = _userLPAmount[lastMaybeAddLPAddress];
                if (lpBalance > lpAmount) {
                    uint256 debtAmount = lpBalance - lpAmount;
                    uint256 maxDebtAmount = _lastMaybeAddLPAmount * IERC20(mainPair).totalSupply() / balanceOf(mainPair);
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    } else {
                        _addLpProvider(lastMaybeAddLPAddress);
                        _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                    }
                }
            }
        }

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount;
            uint256 remainAmount = 10 ** (_decimals - 4);
            if (balance > remainAmount) {
                maxSellAmount = balance - remainAmount;
            }
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                bool isAdd;
                if (to == mainPair) {
                    isAdd = _isAddLiquidity();
                    if (isAdd) {
                        takeFee = false;
                    }
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAdd, "!Trade");
                }

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        }

        bool isRemoveLP;
        if (from == mainPair) {
            isRemoveLP = _isRemoveLiquidity();
            if (isRemoveLP) {
                uint256 liquidity = IERC20(mainPair).totalSupply() * amount / (balanceOf(mainPair) - amount);
                require(_userLPAmount[to] >= liquidity, ">userLPAmount");
                _userLPAmount[to] -= liquidity;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (from != address(this)) {
            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            }

            uint256 rewardGas = _rewardGas;
            processLP(rewardGas);
        }
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
            if (isRemoveLP && block.timestamp < _startTradeTime + _removeLPFeeDuration) {
                uint removeFeeAmount = tAmount * _removeLPFee / 10000;
                if (removeFeeAmount > 0) {
                    feeAmount += removeFeeAmount;
                    _takeTransfer(sender, fundAddress, removeFeeAmount);
                }
            } else {
                uint256 lpFee = _lpFee;
                uint256 swapFee = lpFee + _fundFee;
                uint256 swapAmount = tAmount * swapFee / 10000;
                if (swapAmount > 0) {
                    feeAmount += swapAmount;
                    _takeTransfer(sender, address(this), swapAmount);
                }

                uint256 lpDividendFeeAmount = tAmount * _lpDividendFee / 10000;
                if (lpDividendFeeAmount > 0) {
                    feeAmount += lpDividendFeeAmount;
                    _takeTransfer(sender, address(_tokenDistributor), lpDividendFeeAmount);
                }

                if (!inSwap && _swapPairList[recipient]) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 numToSell = _numToSell;
                    if (contractTokenBalance >= numToSell) {
                        swapTokenForFund(numToSell, swapFee, lpFee);
                    }
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee, uint256 lpFee) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        swapFee += swapFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;
        swapFee -= lpFee;

        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 lpUsdt = usdtBalance * lpFee / swapFee;
        uint256 fundUsdt = usdtBalance - lpUsdt;
        address fundAdr = fundAddress;
        if (fundUsdt > 0) {
            USDT.transfer(fundAdr, fundUsdt);
        }

        if (lpUsdt > 0) {
            (,,uint liquidity) = _swapRouter.addLiquidity(
                address(this), usdt, lpAmount, lpUsdt, 0, 0, fundAdr, block.timestamp
            );
            _userLPAmount[fundAdr] += liquidity;
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

        address sender = address(_tokenDistributor);
        uint256 rewardBalance = balanceOf(sender);
        uint256 rewardCondition = lpRewardCondition;
        if (rewardBalance < rewardCondition) {
            return;
        }
        rewardBalance = rewardCondition;

        address shareHolder;
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
            lpAmount = _userLPAmount[shareHolder];
            if (lpAmount >= holdCondition && !excludeLpProvider[shareHolder]) {
                amount = rewardBalance * lpAmount / totalPair;
                if (amount > 0) {
                    _tokenTransfer(sender, shareHolder, amount, false, false);
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

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount;
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

contract CSG is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "CSG",
        "CSG",
        18,
        4999,
    //Receive
        address(0x2BB0D3C8c2aB4162c7552615747450E708996144),
    //Fund
        address(0x2677eeF15ef80c2795C429CdC3dCB299241d446D)
    ){

    }
}