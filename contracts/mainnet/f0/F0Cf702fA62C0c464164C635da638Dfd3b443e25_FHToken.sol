/**
 *Submitted for verification at BscScan.com on 2022-07-07
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
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

contract SellRewardBuyPool {

}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public _devAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _buyDevFee = 2;
    uint256 public _buyInviteFee = 3;
    uint256 public _buyLPFee = 3;
    uint256 public _buyDestroyFee = 1;

    uint256 public _sellLPFee = 3;
    uint256 public _sellDestroyFee = 1;
    uint256 public _sellNFTFee = 3;
    uint256 public _sellRewardBuyFee = 2;

    uint256 public _transferFundFee = 5;
    uint256 public _transferNFTFee = 4;

    uint256 public startTradeBlock;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _excludeRewardList;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 public _rTotal;

    mapping(address => bool) public _swapPairList;

    uint256  public apr15Minutes = 21651;
    uint256 private constant AprDivBase = 100000000;
    uint256 public _lastRewardTime;
    bool public _autoApy;

    bool private inSwap;

    address public _usdt;
    ISwapRouter public _swapRouter;

    address public _nftAddress;

    TokenDistributor public _tokenDistributor;

    SellRewardBuyPool public _sellRewardBuyPool;
    uint256 public _rewardBuyPoolCondition;

    mapping(address => bool) public _minterList;

    uint256 public  calApyTimes;
    address[] public _rewardBuyAddress;
    address public _usdtPair;

    constructor (address RouteAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals,
        address ReceivedAddress, address FundAddress, address DevAddress, address NFTAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        address swapPair = ISwapFactory(swapRouter.factory()).createPair(address(this), USDTAddress);
        _usdtPair = swapPair;
        _swapPairList[swapPair] = true;
        _excludeRewardList[swapPair] = true;

        emit Transfer(address(0), ReceivedAddress, 0);

        fundAddress = FundAddress;
        _nftAddress = NFTAddress;
        _devAddress = DevAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[NFTAddress] = true;
        _feeWhiteList[DevAddress] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;

        _inProject[msg.sender] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _sellRewardBuyPool = new SellRewardBuyPool();
        _feeWhiteList[address(_tokenDistributor)] = true;
        _feeWhiteList[address(_sellRewardBuyPool)] = true;

        _rewardBuyPoolCondition = 100 * 10 ** IERC20(USDTAddress).decimals();

        _minterList[msg.sender] = true;
    }

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
            ++calApyTimes;
            if (calApyTimes == 35040) {
                _autoApy = false;
                return;
            }
            ++i;
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

    function totalSupply() external view override returns (uint256) {
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

    //铸造代币，尽量在第一次铸造时，就确认了代币发行量的量级
    //不要第一次铸造1枚，然后后面铸造1万枚，尽量避免这种情况，虽然预留了1万倍的容差
    //第一次铸造100万，后面铸造200万，1000万这样。量级差别不要太大，否则，会导致后面增发不出来代币
    function mint(address account, uint256 amount) external {
        require(_minterList[msg.sender], "not minter");
        amount = amount * 10 ** _decimals;
        if (_tTotal == 0) {
            uint256 tTotal = amount;
            uint256 base = AprDivBase * 100 * 10000;
            uint256 rTotal = MAX / base - (MAX / base % tTotal);
            _rOwned[account] = rTotal;
            _tOwned[account] = tTotal;

            _rTotal = rTotal;
            _tTotal = tTotal;
        } else {
            uint256 currentRate = _getRate();
            uint256 rTotal = currentRate * amount;
            _rOwned[account] = _rOwned[account] + rTotal;
            _tOwned[account] = _tOwned[account] + amount;

            _tTotal = _tTotal + amount;
            _rTotal = _tTotal * currentRate;
        }
        emit Transfer(address(0), account, amount);
    }

    function setMinter(address addr, bool enable) external onlyOwner {
        _minterList[addr] = enable;
    }

    function _getRate() public view returns (uint256) {
        if (0 == _tTotal) {
            return 0;
        }
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
                if (_swapPairList[to] && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                    _startAutoApy();
                }
            }
        }
        _tokenTransfer(from, to, amount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        _subToken(sender, tAmount, currentRate);
        if (_feeWhiteList[sender] || _feeWhiteList[recipient]) {
            _addToken(sender, recipient, tAmount, currentRate);
            return;
        }

        uint256 feeAmount;
        if (_swapPairList[sender]) {//Buy
            uint256 totalInviteAmount = tAmount * _buyInviteFee / 100;
            feeAmount += totalInviteAmount;
            uint256 fundAmount = totalInviteAmount;

            address current = recipient;
            address invitor;
            uint256 inviterAmount;
            uint256 perInviteAmount = totalInviteAmount / 3;
            for (uint256 i; i < 2;) {
                invitor = _inviter[current];
                if (address(0) == invitor) {
                    break;
                }
                if (0 == i) {
                    inviterAmount = perInviteAmount * 2;
                } else if (1 == i) {
                    inviterAmount = perInviteAmount;
                }
                fundAmount -= inviterAmount;
                _addToken(sender, invitor, inviterAmount, currentRate);
                current = invitor;
            unchecked{
                ++i;
            }
            }
            if (fundAmount > 1000) {
                _addToken(sender, fundAddress, fundAmount, currentRate);
            }

            uint256 destroyAmount = tAmount * _buyDestroyFee / 100;
            feeAmount += destroyAmount;
            _addToken(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount, currentRate);

            uint256 lpAmount = tAmount * _buyLPFee / 100;
            feeAmount += lpAmount;
            _addToken(sender, address(this), lpAmount, currentRate);

            uint256 devAmount = tAmount * _buyDevFee / 100;
            feeAmount += devAmount;
            _addToken(sender, address(this), devAmount, currentRate);

            _calBuyReward(recipient, tAmount, currentRate);
        } else if (_swapPairList[recipient]) {//Sell
            uint256 lpAmount = tAmount * _sellLPFee / 100;
            feeAmount += lpAmount;
            _addToken(sender, address(this), lpAmount, currentRate);

            uint256 destroyAmount = tAmount * _sellDestroyFee / 100;
            feeAmount += destroyAmount;
            _addToken(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount, currentRate);

            uint256 nftAmount = tAmount * _sellNFTFee / 100;
            feeAmount += nftAmount;
            _addToken(sender, _nftAddress, nftAmount, currentRate);

            uint256 sellRewardBuyAmount = tAmount * _sellRewardBuyFee / 100;
            feeAmount += sellRewardBuyAmount;
            _addToken(sender, address(_sellRewardBuyPool), sellRewardBuyAmount, currentRate);

            if (!inSwap) {
                inSwap = true;
                address usdt = _usdt;
                uint256 swapAmount = lpAmount * 4;
                uint256 thisAmount = balanceOf(address(this));
                if (swapAmount > thisAmount) {
                    swapAmount = thisAmount;
                }
                uint256 lpFee = _sellLPFee + _buyLPFee;
                uint256 devFee = _buyDevFee;
                uint256 allFee = lpFee + devFee;
                allFee += allFee;
                uint256 addLpAmount = swapAmount * lpFee / allFee;
                allFee -= lpFee;
                address tokenDistributor = address(_tokenDistributor);
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = usdt;
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    swapAmount - addLpAmount,
                    0,
                    path,
                    tokenDistributor,
                    block.timestamp
                );
                uint256 usdtBalance = IERC20(usdt).balanceOf(tokenDistributor);
                uint256 addLPUsdt = usdtBalance * lpFee / allFee;
                IERC20(usdt).transferFrom(tokenDistributor, _devAddress, usdtBalance - addLPUsdt);
                IERC20(usdt).transferFrom(tokenDistributor, address(this), addLPUsdt);
                _swapRouter.addLiquidity(
                    address(this), usdt, addLpAmount, addLPUsdt, 0, 0, fundAddress, block.timestamp
                );

                uint256 swapFundAmount = lpAmount * 2;
                if (balanceOf(tokenDistributor) >= swapFundAmount) {
                    _tokenTransfer(tokenDistributor, address(this), swapFundAmount);
                    _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        swapFundAmount,
                        0,
                        path,
                        fundAddress,
                        block.timestamp
                    );
                }
                inSwap = false;
            }
        } else {//Transfer
            uint256 transferNFTAmount = tAmount * _transferNFTFee / 100;
            feeAmount += transferNFTAmount;
            _addToken(sender, _nftAddress, transferNFTAmount, currentRate);

            uint256 transferFundAmount = tAmount * _transferFundFee / 100;
            feeAmount += transferFundAmount;
            _addToken(sender, address(_tokenDistributor), transferFundAmount, currentRate);
        }

        _addToken(sender, recipient, tAmount - feeAmount, currentRate);
    }

    function _calBuyReward(address recipient, uint256 tAmount, uint256 currentRate) private {
        address sellRewardBuyPool = address(_sellRewardBuyPool);
        uint256 rewardBuyPoolBalance = balanceOf(sellRewardBuyPool);
        if (rewardBuyPoolBalance > 5 && recipient == tx.origin) {
            address[] memory path = new address[](2);
            path[0] = _usdt;
            path[1] = address(this);
            uint256[] memory amountsOuts = _swapRouter.getAmountsOut(_rewardBuyPoolCondition, path);
            if (tAmount >= amountsOuts[1]) {
                _rewardBuyAddress.push(recipient);
                if (5 == _rewardBuyAddress.length) {
                    uint256 perRewardAmount = rewardBuyPoolBalance / 5;
                    _subToken(sellRewardBuyPool, perRewardAmount * 5, currentRate);
                    for (uint256 i; i < 5;) {
                        _addToken(sellRewardBuyPool, _rewardBuyAddress[i], perRewardAmount, currentRate);
                    unchecked{
                        ++i;
                    }
                    }
                    delete _rewardBuyAddress;
                }
            }
        }
    }

    function _subToken(address sender, uint256 tAmount, uint256 currentRate) private {
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;
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
    }

    receive() external payable {}

    function claimBalance() external onlyFunder {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setNFTAddress(address addr) external onlyOwner {
        _nftAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setDevAddress(address addr) external onlyOwner {
        _devAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
        if (enable) {
            _excludeRewardList[addr] = true;
        }
    }

    function setExcludeReward(address addr, bool enable) external onlyFunder {
        _tOwned[addr] = balanceOf(addr);
        _rOwned[addr] = _tOwned[addr] * _getRate();
        _excludeRewardList[addr] = enable;
    }

    function startAutoApy() external onlyFunder {
        require(!_autoApy, "autoAping");
        _startAutoApy();
    }

    function _startAutoApy() private {
        _autoApy = true;
        _lastRewardTime = block.timestamp;
    }

    function emergencyCloseAutoApy() external onlyFunder {
        _autoApy = false;
    }

    function closeAutoApy() external onlyFunder {
        calApy();
        _autoApy = false;
    }

    function setApr15Minutes(uint256 apr) external onlyFunder {
        calApy();
        apr15Minutes = apr;
    }

    function setRewardBuyPoolCondition(uint256 amount) external onlyFunder {
        _rewardBuyPoolCondition = amount * 10 ** IERC20(_usdt).decimals();
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => bool) public _inProject;

    //其他业务合约调用绑定用户的上级
    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notInProj");
        _bindInvitor(account, invitor);
    }

    //用户主动绑定上级
    function bindInvitor(address invitor) public {
        address account = msg.sender;
        _bindInvitor(account, invitor);
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

    function setInProject(address adr, bool enable) external onlyFunder {
        _inProject[adr] = enable;
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }
}

contract FHToken is AbsToken {
    constructor() AbsToken(
    //路由地址
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT 合约地址
        address(0x55d398326f99059fF775485246999027B3197955),
    //名称
        "FH Token",
    //符号
        "FH",
    //精度
        18,
    //代币接收钱包
        address(0xE7C7D9B930d6072601E3B5c31560Ab42c0CAD6e7),
    //营销地址
        address(0xbCeBeCC9fF677E8EC19338aB5Dd11499aBd895bA),
    // 买入税的指定钱包地址
        address(0xf67533b3EB1Ee1B5edb33D94dc0EBD1E46c3837f),
    //NFT 合约地址
        address(0xf0E31159d711b8037e6A7A6f9Ef9e24D54a53f2B)

    ){

    }
}