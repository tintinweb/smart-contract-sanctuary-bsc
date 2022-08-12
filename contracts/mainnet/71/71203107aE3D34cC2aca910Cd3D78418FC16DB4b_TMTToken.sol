/**
 *Submitted for verification at BscScan.com on 2022-08-12
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

interface IBtcNFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function addReward(address account, uint256 reward) external;

    function addInviteReward(address invitor, uint256 reward) external;
}

interface IEthNFT {
    function activeSupply() external view returns (uint256);

    function initIdInfo(uint256 initId) external view returns (uint256 lastId, bool isActive, address nftOwner);

    function addReward(address account, uint256 reward) external;

    function addInviteReward(address invitor, uint256 reward) external;
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public defaultInvitor;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _buyInviteFee = 3;
    uint256 public _buyDestroyFee = 2;

    uint256 public _sellLPFee = 2;
    uint256 public _sellFundFee = 2;
    uint256 public _sellEthNFTFee = 3;
    uint256 public _sellBtcNFTFee = 8;

    uint256 public _transferFee = 5;

    uint256 public startTradeBlock;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _excludeRewardList;

    mapping(address => uint256) public _rOwned;
    mapping(address => uint256) public _tOwned;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 public _rTotal;

    mapping(address => bool) public _swapPairList;

    uint256  public apr15Minutes = 20630;
    uint256 private constant AprDivBase = 100000000;
    uint256 public _lastRewardTime;
    bool public _autoApy;
    uint256 private _invitorHoldCondition;
    uint256 private _invitorHoldCondition2;

    bool private inSwap;

    address public _usdt;
    address public _usdtPair;
    ISwapRouter public _swapRouter;

    address public _ethNFTAddress;
    address public _btcNFTAddress;

    TokenDistributor public _tokenDistributor;
    TokenDistributor public _ethNFTTokenDistributor;
    TokenDistributor public _btcNFTTokenDistributor;

    mapping(address => uint256) public _teamAmount;
    //
    mapping(address => uint256) public _statisticsAmount;

    constructor (address RouteAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceivedAddress, address FundAddress,
        address EthNFTAddress, address BtcNFTAddress, address NFTDefaultInvitor, address DefaultInvitor
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        address swapPair = ISwapFactory(swapRouter.factory()).createPair(address(this), USDTAddress);
        _swapPairList[swapPair] = true;
        _excludeRewardList[swapPair] = true;
        _usdtPair = swapPair;

        uint256 tTotal = Supply * 10 ** Decimals;
        uint256 base = AprDivBase * 100;
        uint256 rTotal = MAX / base - (MAX / base % tTotal);
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;
        _addHolder(ReceivedAddress);

        fundAddress = FundAddress;
        _ethNFTAddress = EthNFTAddress;
        _btcNFTAddress = BtcNFTAddress;
        _nftDefaultInvitor = NFTDefaultInvitor;
        defaultInvitor = DefaultInvitor;

        _feeWhiteList[DefaultInvitor] = true;
        _feeWhiteList[NFTDefaultInvitor] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;

        _inProject[msg.sender] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _ethNFTTokenDistributor = new TokenDistributor(USDTAddress);
        _btcNFTTokenDistributor = new TokenDistributor(USDTAddress);

        _invitorHoldCondition = 30 * 10 ** Decimals;
        _invitorHoldCondition2 = 50 * 10 ** Decimals;

        //BTCNFT
        btcNftRewardCondition = 300 * 10 ** IERC20(USDTAddress).decimals();
        _btcNftHolderCondition = 200 * 10 ** Decimals;
        excludeBtcNFTHolder[address(0)] = true;
        excludeBtcNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        //ETHNFT
        ethNftRewardCondition = 300 * 10 ** IERC20(USDTAddress).decimals();
        excludeEthNFTHolder[address(0)] = true;
        excludeEthNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
    }

    uint256 public  calApyTimes;

    function calApy() public {
        if (!_autoApy) {
            return;
        }
        uint256 total = _tTotal;
        uint256 maxTotal = _rTotal;
        if (total == maxTotal) {
            return;
        }
        uint256 blockTime = block.timestamp;
        uint256 lastRewardTime = _lastRewardTime;
        if (blockTime < lastRewardTime + 15 minutes) {
            return;
        }
        uint256 deltaTime = blockTime - lastRewardTime;
        uint256 times = deltaTime / 15 minutes;

        for (uint256 i; i < times;) {
            total = total * (AprDivBase + apr15Minutes) / AprDivBase;
            if (total > maxTotal) {
                total = maxTotal;
                break;
            }
        unchecked{
            ++i;
            if (1042 != apr15Minutes) {
                calApyTimes++;
                if (calApyTimes == 1920) {
                    calApyTimes = 0;
                    apr15Minutes = apr15Minutes / 2;
                    if (apr15Minutes < 5157) {
                        apr15Minutes = 1042;
                    }
                }
            }
        }
        }
        _tTotal = total;
        _lastRewardTime = lastRewardTime + times * 15 minutes;
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
        if (_excludeRewardList[account]) {
            return _tOwned[account];
        }
        return tokenFromReflection(_rOwned[account]);
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

    function tokenFromReflection(uint256 rAmount) public view returns (uint256){
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _getRate() public view returns (uint256) {
        if (_rTotal < _tTotal) {
            return 1;
        }
        return _rTotal / _tTotal;
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
        calApy();

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                if (_feeWhiteList[from] && _swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                    _startAutoApy();
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!trade");
                if (block.number < startTradeBlock + 4) {
                    _fundTransfer(from, to, amount, 90);
                    return;
                }
            }
        }
        _tokenTransfer(from, to, amount);

        if (from != address(this)) {
            processBtcNFT(500000);
            if (progressBtcNFTBlock != block.number) {
                processEthNFT(500000);
            }
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_feeWhiteList[sender] || _feeWhiteList[recipient]) {
            _fundTransfer(sender, recipient, tAmount, 0);
            return;
        }

        uint256 currentRate = _getRate();
        _subToken(sender, tAmount, currentRate);

        uint256 feeAmount;
        if (_swapPairList[sender]) {//Buy
            uint256 totalInviteAmount = tAmount * _buyInviteFee / 100;
            feeAmount += totalInviteAmount;
            uint256 fundAmount = totalInviteAmount;
            if (totalInviteAmount > 0) {
                address current = recipient;
                address invitor;
                uint256 inviterAmount;
                uint256 perInviteAmount = totalInviteAmount / 3;
                uint256 invitorHoldCondition;
                for (uint256 i; i < 2;) {
                    invitor = _inviter[current];
                    if (address(0) == invitor) {
                        break;
                    }
                    if (0 == i) {
                        inviterAmount = perInviteAmount * 2;
                        invitorHoldCondition = _invitorHoldCondition;
                    } else {
                        inviterAmount = perInviteAmount;
                        invitorHoldCondition = _invitorHoldCondition2;
                    }
                    if (0 == invitorHoldCondition || balanceOf(invitor) >= invitorHoldCondition) {
                        fundAmount -= inviterAmount;
                        _addToken(sender, invitor, inviterAmount, currentRate);
                    }
                    current = invitor;
                unchecked{
                    ++i;
                }
                }
            }
            if (fundAmount > 1000) {
                _addToken(sender, defaultInvitor, fundAmount, currentRate);
            }
            uint256 destroyAmount = tAmount * _buyDestroyFee / 100;
            if (destroyAmount > 0) {
                feeAmount += destroyAmount;
                _addToken(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount, currentRate);
            }
        } else if (_swapPairList[recipient]) {//Sell
            uint256 sellLPFee = _sellLPFee;
            uint256 sellFundFee = _sellFundFee;
            uint256 sellEthNFTFee = _sellEthNFTFee;
            uint256 sellBtcNFTFee = _sellBtcNFTFee;
            uint256 taxFee = sellLPFee + sellFundFee + sellEthNFTFee + sellBtcNFTFee;
            uint256 taxAmount = tAmount * taxFee / 100;
            feeAmount += taxAmount;
            _addToken(sender, address(this), taxAmount, currentRate);

            if (!inSwap) {
                inSwap = true;
                taxFee += taxFee;
                uint256 addLPAmount = taxAmount * sellLPFee / taxFee;
                address tokenDistributor = address(_tokenDistributor);
                address usdt = _usdt;
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = usdt;
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    taxAmount - addLPAmount,
                    0,
                    path,
                    tokenDistributor,
                    block.timestamp
                );
                _distributeUSDT(
                    usdt, tokenDistributor,
                    taxFee, sellLPFee, sellFundFee, sellEthNFTFee, sellBtcNFTFee,
                    addLPAmount
                );
                inSwap = false;
            }
        } else {//Transfer
            uint256 transferFeeAmount = tAmount * _transferFee / 100;
            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _addToken(sender, address(0x000000000000000000000000000000000000dEaD), transferFeeAmount, currentRate);
            }
        }
        _addToken(sender, recipient, tAmount - feeAmount, currentRate);
    }

    function _calTeamAmount(address account) private {
        uint256 lastStatisticsAmount = _statisticsAmount[account];
        uint256 balance = balanceOf(account);
        if (lastStatisticsAmount == balance) {
            return;
        }
        _statisticsAmount[account] = balance;

        if (lastStatisticsAmount > balance) {//minus teamAmount
            uint256 debtAmount = lastStatisticsAmount - balance;
            address invitor;
            uint256 teamAmount;
            for (uint256 i; i < 20;) {
                invitor = _inviter[account];
                if (address(0) == invitor) {
                    break;
                }
                account = invitor;
                teamAmount = _teamAmount[invitor];
            unchecked{
                if (teamAmount > debtAmount) {
                    _teamAmount[invitor] = teamAmount - debtAmount;
                } else {
                    _teamAmount[invitor] = 0;
                }
                ++i;
            }
            }
        } else {//add teamAmount
            uint256 debtAmount = balance - lastStatisticsAmount;
            address invitor;
            for (uint256 i; i < 20;) {
                invitor = _inviter[account];
                if (address(0) == invitor) {
                    break;
                }
                account = invitor;
            unchecked{
                _teamAmount[invitor] += debtAmount;
                ++i;
            }
            }
        }
    }

    function _distributeUSDT(
        address usdt, address tokenDistributor,
        uint256 taxFee, uint256 sellLPFee, uint256 sellFundFee, uint256 sellEthNFTFee, uint256 sellBtcNFTFee,
        uint256 addLPAmount
    ) private {
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        taxFee -= sellLPFee;

        uint256 fundUSDT = usdtBalance * sellFundFee * 2 / taxFee;
        USDT.transferFrom(tokenDistributor, fundAddress, fundUSDT);

        uint256 ethNFTUSDT = usdtBalance * sellEthNFTFee * 2 / taxFee;
        USDT.transferFrom(tokenDistributor, address(_ethNFTTokenDistributor), ethNFTUSDT);
        _ethRewardUsdt += ethNFTUSDT;

        uint256 btcNFTUSDT = usdtBalance * sellBtcNFTFee * 2 / taxFee;
        USDT.transferFrom(tokenDistributor, address(_btcNFTTokenDistributor), btcNFTUSDT);
        _btcRewardUsdt += btcNFTUSDT;

        _addLP(tokenDistributor, usdt, usdtBalance, sellLPFee, taxFee, addLPAmount);
    }

    function _addLP(address tokenDistributor, address usdt, uint256 usdtBalance, uint256 sellLPFee, uint256 taxFee, uint256 addLPAmount) private {
        uint256 addLPUSDT = usdtBalance * sellLPFee / taxFee;
        if (addLPUSDT > 0 && addLPAmount > 0) {
            IERC20(usdt).transferFrom(tokenDistributor, address(this), addLPUSDT);
            _swapRouter.addLiquidity(
                address(this), usdt, addLPAmount, addLPUSDT, 0, 0, fundAddress, block.timestamp
            );
        }
    }

    function _fundTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fundFee
    ) private {
        uint256 currentRate = _getRate();
        _subToken(sender, tAmount, currentRate);
        uint256 fundAmount = tAmount * fundFee / 100;
        if (fundAmount > 0) {
            _addToken(sender, fundAddress, fundAmount, currentRate);
        }
        _addToken(sender, recipient, tAmount - fundAmount, currentRate);
    }

    function _subToken(address sender, uint256 tAmount, uint256 currentRate) private {
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _calTeamAmount(sender);
    }

    function _addToken(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _tOwned[to] += tAmount;

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        emit Transfer(sender, to, tAmount);
        _addHolder(to);
        _calTeamAmount(to);
    }

    receive() external payable {}

    function claimBalance() external onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDefaultInvitor(address addr) external onlyOwner {
        defaultInvitor = addr;
        _feeWhiteList[addr] = true;
    }

    function setNftDefaultInvitor(address addr) external onlyOwner {
        _nftDefaultInvitor = addr;
        _feeWhiteList[addr] = true;
    }

    function setEthNFTAddress(address addr) external onlyOwner {
        _ethNFTAddress = addr;
    }

    function setBtcNFTAddress(address addr) external onlyOwner {
        _btcNFTAddress = addr;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
        if (enable) {
            _setExcludeReward(addr, true);
        }
    }

    function setExcludeReward(address addr, bool enable) external onlyOwner {
        _setExcludeReward(addr, enable);
    }

    function _setExcludeReward(address addr, bool enable) private {
        _tOwned[addr] = balanceOf(addr);
        _rOwned[addr] = _tOwned[addr] * _getRate();
        _excludeRewardList[addr] = enable;
    }

    function startAutoApy() external onlyOwner {
        require(!_autoApy, "autoAping");
        _startAutoApy();
    }

    function _startAutoApy() private {
        _autoApy = true;
        _lastRewardTime = block.timestamp;
    }

    function emergencyCloseAutoApy() external onlyOwner {
        _autoApy = false;
    }

    function closeAutoApy() external onlyOwner {
        calApy();
        _autoApy = false;
    }

    function setApr15Minutes(uint256 apr) external onlyOwner {
        calApy();
        apr15Minutes = apr;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyOwner {
        _invitorHoldCondition = amount * 10 ** _decimals;
    }

    function setInvitorHoldCondition2(uint256 amount) external onlyOwner {
        _invitorHoldCondition2 = amount * 10 ** _decimals;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => uint256) public _teamNum;
    mapping(address => bool) public _inProject;
    
    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notInProj");
        _bindInvitor(account, invitor);
    }

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(invitor)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
                _teamNum[invitor] += 1;
                for (uint256 i = 1; i < 20;) {
                    invitor = _inviter[invitor];
                    if (address(0) == invitor) {
                        break;
                    }
                unchecked{
                    _teamNum[invitor] += 1;
                    ++i;
                }
                }
            }
        }
    }

    function setInProject(address adr, bool enable) external onlyOwner {
        _inProject[adr] = enable;
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    address[] private _holders;
    mapping(address => uint256) private _holderIndex;

    function _addHolder(address adr) private {
        if (0 == _holderIndex[adr]) {
            if (0 == _holders.length || _holders[0] != adr) {
                _holderIndex[adr] = _holders.length;
                _holders.push(adr);
            }
        }
    }

    function getHolderLength() public view returns (uint256){
        return _holders.length;
    }

    function getHolderList(uint256 start, uint256 length) external view returns (
        uint256 returnLen, address[] memory holders,
        uint256[] memory balances, uint256[] memory teamAmounts
    ){
        uint256 holderLength = getHolderLength();
        if (0 == length) {
            length = holderLength;
        }
        returnLen = length;

        holders = new address[](length);
        balances = new uint256[](length);
        teamAmounts = new uint256[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= holderLength)
                return (index, holders, balances, teamAmounts);
            address holder = _holders[i];
            holders[index] = holder;
            balances[index] = balanceOf(holder);
            teamAmounts[index] = _teamAmount[holder];
            ++index;
        }
    }

    //BTCNFT
    uint256 public currentBtcNFTIndex;
    uint256 public btcNftRewardCondition;
    uint256 public _btcNftHolderCondition;
    uint256 public progressBtcNFTBlock;
    mapping(address => bool) public excludeBtcNFTHolder;
    uint256 public progressBtcNFTBlockDebt = 200;
    uint256 public _btcNftBaseId = 1;

    uint256 private _ethRewardUsdt;
    uint256 private _btcRewardUsdt;
    address public _nftDefaultInvitor;

    function processBtcNFT(uint256 gas) private {
        if (progressBtcNFTBlock + progressBtcNFTBlockDebt > block.number) {
            return;
        }
        IBtcNFT btcNft = IBtcNFT(_btcNFTAddress);
        uint totalNFT = btcNft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        address tokenDistributor = address(_btcNFTTokenDistributor);
        IERC20 USDT = IERC20(_usdt);
        uint256 tokenBalance = USDT.balanceOf(tokenDistributor);
        if (tokenBalance < btcNftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;
        if (100 > amount) {
            return;
        }
        uint256 totalRewardAmount;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = _btcNftBaseId;
        uint256 btcNftHolderCondition = _btcNftHolderCondition;

        uint256 invitorHoldCondition = _invitorHoldCondition;
        uint256 invitorHoldCondition2 = _invitorHoldCondition2;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentBtcNFTIndex >= totalNFT) {
                currentBtcNFTIndex = 0;
            }
            address shareHolder = btcNft.ownerOf(nftBaseId + currentBtcNFTIndex);
            if (!excludeBtcNFTHolder[shareHolder] && balanceOf(shareHolder) >= btcNftHolderCondition) {
                totalRewardAmount += amount;
                _progressBtcReward(btcNft, shareHolder, amount, invitorHoldCondition, invitorHoldCondition2);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentBtcNFTIndex++;
            iterations++;
        }

        progressBtcNFTBlock = block.number;
        if (totalRewardAmount > 0) {
            USDT.transferFrom(tokenDistributor, _btcNFTAddress, totalRewardAmount);
        }
    }

    function _progressBtcReward(IBtcNFT btcNft, address shareHolder, uint256 amount, uint256 invitorHoldCondition, uint256 invitorHoldCondition2) private {
        uint256 rewardAmount = amount * 92 / 100;
        btcNft.addReward(shareHolder, rewardAmount);
        address current = shareHolder;
        address invitor;
        uint256 fundAmount = amount - rewardAmount;
        uint256 inviteAmount = amount * 5 / 100;
        uint256 inviteAmount2 = fundAmount - inviteAmount;
        for (uint256 i; i < 2;) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }
            if (0 == i) {
                if (balanceOf(invitor) >= invitorHoldCondition) {
                    fundAmount -= inviteAmount;
                    btcNft.addInviteReward(invitor, inviteAmount);
                }
            } else {
                if (balanceOf(invitor) >= invitorHoldCondition2) {
                    fundAmount -= inviteAmount2;
                    btcNft.addInviteReward(invitor, inviteAmount2);
                }
            }
            current = invitor;
        unchecked{
            ++i;
        }
        }
        if (fundAmount > 0) {
            btcNft.addInviteReward(_nftDefaultInvitor, fundAmount);
        }
    }

    function setBtcNFTRewardCondition(uint256 amount) external onlyOwner {
        btcNftRewardCondition = amount;
    }

    function setBtcNFTHoldCondition(uint256 amount) external onlyOwner {
        _btcNftHolderCondition = amount;
    }

    function setBtcExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeBtcNFTHolder[addr] = enable;
    }

    function setProgressBtcNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        progressBtcNFTBlockDebt = blockDebt;
    }

    function setBtcNftBaseId(uint256 baseId) external onlyOwner {
        _btcNftBaseId = baseId;
    }

    //ETHNFT
    uint256 public currentEthNFTIndex;
    uint256 public ethNftRewardCondition;
    uint256 public progressEthNFTBlock;
    mapping(address => bool) public excludeEthNFTHolder;
    uint256 public progressEthNFTBlockDebt = 20;
    uint256 public _ethNftBaseId = 1;

    function processEthNFT(uint256 gas) private {
        if (progressEthNFTBlock + progressEthNFTBlockDebt > block.number) {
            return;
        }
        IEthNFT ethNft = IEthNFT(_ethNFTAddress);
        uint totalNFT = ethNft.activeSupply();
        if (0 == totalNFT) {
            return;
        }
        address tokenDistributor = address(_ethNFTTokenDistributor);
        IERC20 USDT = IERC20(_usdt);
        uint256 tokenBalance = USDT.balanceOf(tokenDistributor);
        if (tokenBalance < ethNftRewardCondition) {
            return;
        }

        uint256 amount = tokenBalance / totalNFT;

        if (100 > amount) {
            return;
        }
        uint256 totalRewardAmount;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 nftBaseId = _ethNftBaseId;

        uint256 invitorHoldCondition = _invitorHoldCondition;
        uint256 invitorHoldCondition2 = _invitorHoldCondition2;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentEthNFTIndex >= totalNFT) {
                currentEthNFTIndex = 0;
            }
            (, bool isActive, address shareHolder) = ethNft.initIdInfo(nftBaseId + currentEthNFTIndex);
            if (!excludeEthNFTHolder[shareHolder] && isActive) {
                totalRewardAmount += amount;
                _progressEthReward(ethNft, shareHolder, amount, invitorHoldCondition, invitorHoldCondition2);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentEthNFTIndex++;
            iterations++;
        }

        progressEthNFTBlock = block.number;
        if (totalRewardAmount > 0) {
            USDT.transferFrom(tokenDistributor, _ethNFTAddress, totalRewardAmount);
        }
    }

    function _progressEthReward(IEthNFT ethNft, address shareHolder, uint256 amount, uint256 invitorHoldCondition, uint256 invitorHoldCondition2) private {
        uint256 rewardAmount = amount * 92 / 100;
        ethNft.addReward(shareHolder, rewardAmount);
        address current = shareHolder;
        address invitor;
        uint256 fundAmount = amount - rewardAmount;
        uint256 inviteAmount = amount * 5 / 100;
        uint256 inviteAmount2 = fundAmount - inviteAmount;
        for (uint256 i; i < 2;) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }
            if (0 == i) {
                if (balanceOf(invitor) >= invitorHoldCondition) {
                    fundAmount -= inviteAmount;
                    ethNft.addInviteReward(invitor, inviteAmount);
                }
            } else {
                if (balanceOf(invitor) >= invitorHoldCondition2) {
                    fundAmount -= inviteAmount2;
                    ethNft.addInviteReward(invitor, inviteAmount2);
                }
            }
            current = invitor;
        unchecked{
            ++i;
        }
        }
        if (fundAmount > 0) {
            ethNft.addInviteReward(_nftDefaultInvitor, fundAmount);
        }
    }

    function setEthNFTRewardCondition(uint256 amount) external onlyOwner {
        ethNftRewardCondition = amount;
    }

    function setEthExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeEthNFTHolder[addr] = enable;
    }

    function setProgressEthNFTBlockDebt(uint256 blockDebt) external onlyOwner {
        progressEthNFTBlockDebt = blockDebt;
    }

    function setEthNftBaseId(uint256 baseId) external onlyOwner {
        _ethNftBaseId = baseId;
    }

    function getTokenInfo() external view returns (
        uint256 tokenDecimals, string memory tokenSymbol,
        address usdt, uint256 usdtDecimals, string memory usdtSymbol
    ){
        tokenDecimals = _decimals;
        tokenSymbol = _symbol;
        usdt = _usdt;
        usdtDecimals = IERC20(usdt).decimals();
        usdtSymbol = IERC20(usdt).symbol();
    }

    function getTotalInfo() external view returns (
        uint256 ethRewardUsdt, uint256 btcRewardUsdt,
        uint256 invitorHoldCondition, uint256 invitorHoldCondition2, uint256 btcNftHolderCondition,
        uint256 tokenPrice, uint256 lpValue, uint256 validTotal, uint256 total
    ){
        ethRewardUsdt = _ethRewardUsdt;
        btcRewardUsdt = _btcRewardUsdt;
        invitorHoldCondition = _invitorHoldCondition;
        invitorHoldCondition2 = _invitorHoldCondition2;
        btcNftHolderCondition = _btcNftHolderCondition;
        uint256 lpU = IERC20(_usdt).balanceOf(_usdtPair);
        lpValue = lpU * 2;
        uint256 lpTokenAmount = balanceOf(_usdtPair);
        if (lpTokenAmount > 0) {
            tokenPrice = 10 ** _decimals * lpU / lpTokenAmount;
        }
        total = totalSupply();
        validTotal = total - balanceOf(address(0)) - balanceOf(address(0x000000000000000000000000000000000000dEaD));
    }

    function getAllInvitor(address account) external view returns (address[] memory invitors){
        invitors = new address[](20);
        address current = account;
        address invitor;
        for (uint256 i; i < 20; ++i) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }
            invitors[i] = invitor;
            current = invitor;
        }
    }
}

contract TMTToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "TMT Token",
        "TMT",
        6,
        13000000,
        address(0xD9E1326497970C541c2fEc65Ea190411e52729E5),
        address(0xb78d7b977e62B09Cd3934ba37404d8261B4b84D3),
        address(0xB7dC2FD542Fb373255CB4c493b51808F1b2F18e7),
        address(0x6477F5D55E8cd3a9a2d85DccF6B3aB09AAc47547),
        address(0xf2cab01D0344c024378cc6A9Edf6D3089936dF36),
        address(0x23bDd3bAf49dd13fC43A9AC084cC8b4AB776F677)
    ){

    }
}