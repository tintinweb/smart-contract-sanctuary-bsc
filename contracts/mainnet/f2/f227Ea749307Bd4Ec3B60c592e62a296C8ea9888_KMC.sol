/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
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
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
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

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyDestroyFee = 100;
    uint256 public _buyLPDividendFee = 200;

    uint256 public _sellDestroyFee = 100;
    uint256 public _sellLPDividendFee = 100;
    uint256 public _sellHoldDividendFee = 100;

    uint256 public startTradeBlock;
    address public _mainPair;
    uint256 public startAddLPBlock;

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;

        _usdt = usdt;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
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

        _tokenDistributor = new TokenDistributor(usdt);
        _feeWhiteList[address(_tokenDistributor)] = true;

        excludeLPHolder[address(0)] = true;
        excludeLPHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        lpRewardCondition = 2000000 * tokenUnit;
        lpCondition = 1000000;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        holderCondition = 2000000 * tokenUnit;
        holderRewardCondition = 2000000 * tokenUnit;
        _addHolder(ReceiveAddress);
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

    mapping(address => uint256) private _userLPAmount;
    address private _lastMaybeAddLPAddress;
    uint256 private _lastMaybeAddLPAmount;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

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
                        excludeLPHolder[lastMaybeAddLPAddress] = true;
                    } else {
                        _addLpProvider(lastMaybeAddLPAddress);
                        _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                    }
                }
            }
        }

        bool takeFee;
        bool isAddLP;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
            if (_swapPairList[from] || _swapPairList[to]) {
                if (to == _mainPair) {
                    isAddLP = _isAddLiquidity(amount);
                }
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP, "!T");
                }
                if (!isAddLP && block.number < startTradeBlock + 10) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        }

        if (0 == startAddLPBlock && to == mainPair && _feeWhiteList[from]) {
            startAddLPBlock = block.timestamp;
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            } else if (balanceOf(to) >= holderCondition) {
                _addHolder(to);
            }

            if (!_feeWhiteList[from] && !isAddLP) {
                uint256 rewardGas = _rewardGas;
                processLPReward(rewardGas);
                if (progressLPRewardBlock != block.number) {
                    processHolderReward(rewardGas);
                }
            }
        }
    }

    function _isAddLiquidity(uint256 amount) internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        uint256 rToken;
        if (tokenOther < address(this)) {
            r = r0;
            rToken = r1;
        } else {
            r = r1;
            rToken = r0;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        if (rToken == 0) {
            isAdd = bal > r;
        } else {
            isAdd = bal > r + r * amount / rToken / 2;
        }
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
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 destroyFeeAmount;
            uint256 lpDividendFeeAmount;
            uint256 holdDividendFeeAmount;
            if (_swapPairList[sender]) {//Buy
                destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                lpDividendFeeAmount = tAmount * _buyLPDividendFee / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                destroyFeeAmount = tAmount * _sellDestroyFee / 10000;
                lpDividendFeeAmount = tAmount * _sellLPDividendFee / 10000;
                holdDividendFeeAmount = tAmount * _sellHoldDividendFee / 10000;
            } else {//Transfer
                destroyFeeAmount = tAmount * _buyDestroyFee / 10000;
                lpDividendFeeAmount = tAmount * _buyLPDividendFee / 10000;
            }
            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
            }
            if (lpDividendFeeAmount > 0) {
                feeAmount += lpDividendFeeAmount;
                _takeTransfer(sender, address(_tokenDistributor), lpDividendFeeAmount);
            }
            if (holdDividendFeeAmount > 0) {
                feeAmount += holdDividendFeeAmount;
                _takeTransfer(sender, address(this), holdDividendFeeAmount);
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

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
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

    function claimDistributorToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    receive() external payable {}

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;

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

    uint256 public _rewardGas = 500000;

    mapping(address => bool)  public excludeLPHolder;
    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public lpCondition;
    uint256 public progressLPRewardBlock;
    uint256 public progressLPBlockDebt = 100;

    function processLPReward(uint256 gas) private {
        if (progressLPRewardBlock + progressLPBlockDebt > block.number) {
            return;
        }

        address sender = address(_tokenDistributor);
        uint256 rewardCondition = lpRewardCondition;
        if (balanceOf(sender) < rewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (0 == holdTokenTotal) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if(!excludeLPHolder[shareHolder]){
                tokenBalance = holdToken.balanceOf(shareHolder);
                lpAmount = _userLPAmount[shareHolder];
                if (lpAmount < tokenBalance) {
                    tokenBalance = lpAmount;
                } else if (lpAmount > tokenBalance) {
                    _userLPAmount[shareHolder] = tokenBalance;
                }
                if (tokenBalance >= holdCondition) {
                    amount = rewardCondition * tokenBalance / holdTokenTotal;
                    if (amount > 0) {
                        _tokenTransfer(sender,shareHolder,amount,false);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPRewardBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount) external onlyWhiteList {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyWhiteList {
        progressLPBlockDebt = debt;
    }

    function setLPCondition(uint256 amount) external onlyWhiteList {
        lpCondition = amount;
    }

    function setExcludeLPHolder(address addr, bool enable) external onlyWhiteList {
        excludeLPHolder[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    address[] public holders;
    mapping(address => uint256) public holderIndex;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function _addHolder(address adr) private {
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

    mapping(address => bool) public excludeHolder;
    uint256 public currentHolderIndex;
    uint256 public holderRewardCondition;
    uint256 public holderCondition;
    uint256 public progressHolderBlock;
    uint256 public progressHolderBlockDebt = 0;

    function processHolderReward(uint256 gas) private {
        if (progressHolderBlock + progressHolderBlockDebt > block.number) {
            return;
        }

        address sender = address (this);
        uint256 rewardCondition = holderRewardCondition;
        if (balanceOf(sender) < rewardCondition) {
            return;
        }

        uint256 totalLockAmount = totalSupply();

        address shareHolder;
        uint256 lockAmount;
        uint256 rewardAmount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = holderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentHolderIndex >= shareholderCount) {
                currentHolderIndex = 0;
            }
            shareHolder = holders[currentHolderIndex];
            if (!excludeHolder[shareHolder]) {
                lockAmount = balanceOf(shareHolder);
                if (lockAmount >= holdCondition) {
                    rewardAmount = rewardCondition * lockAmount / totalLockAmount;
                    if (rewardAmount > 0) {
                        _tokenTransfer(sender,shareHolder,rewardAmount,false);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentHolderIndex++;
            iterations++;
        }
        progressHolderBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyWhiteList {
        holderRewardCondition = amount;
    }

    function setHolderBlockDebt(uint256 debt) external onlyWhiteList {
        progressHolderBlockDebt = debt;
    }

    function setHolderCondition(uint256 amount) external onlyWhiteList {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyWhiteList {
        excludeHolder[addr] = enable;
    }
}

contract KMC is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "KMC",
        "KMC",
        18,
        10000000000,
    //Fund
        address(0x77eA1A4F22f994c7D9Cdb90A62E693fb774E47E4),
    //Received
        address(0x6D4602eC66E138EceF4F584F4eC56490fb54b8A0)
    ){

    }
}