/**
 *Submitted for verification at BscScan.com on 2023-01-15
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

    address public fundAddress = 0x99d8Fc197b7d7338316b1ea2365CeaE37374A9c9;
    address public LpAddress = 0x67B1B1751510f1d48e0f5f451F727968534Ab4D3;
    address public blackAddress = 0xBdf21ce292b978c4C353863dC8a5908CE8E8C78E;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping (address => bool) public isWalletLimitExempt;
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _tradeAddress;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;
    bool public limitEnable = true;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyfundFee = 200;
    uint256 public _buyLPDividendFee = 50;
    uint256 public _buyLPFee = 50;
    uint256 public _buyBlackFee = 200;

    uint256 public _sellfundFee = 200;
    uint256 public _sellLPDividendFee = 50;
    uint256 public _sellLPFee = 50;
    uint256 public _sellBlackFee = 200;
    
    uint256 public numTokensSellToFund = 20000;

    uint256 public maxTXAmount;
    uint256 public walletLimit; 



    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address TradeAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(TradeAddress).approve(address(swapRouter), MAX);

        _tradeAddress = TradeAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), TradeAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        maxTXAmount = 1000000000 * 10 ** Decimals;
        walletLimit = 1000000000 * 10** Decimals;
        
        _tTotal = total;
        numTokensSellToFund = numTokensSellToFund * 10 ** Decimals;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[blackAddress] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[fundAddress] = true;
        isWalletLimitExempt[ReceiveAddress] = true;
        isWalletLimitExempt[address(swapRouter)] = true;
        isWalletLimitExempt[address(_mainPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[blackAddress] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[blackAddress] = true;

        holderRewardCondition = 10000 * 10 ** IERC20(TradeAddress).decimals();

        _tokenDistributor = new TokenDistributor(TradeAddress);
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
        require(!_blackList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 10000 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance >= numTokensSellToFund) {
                            swapTokenForFund(numTokensSellToFund);
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
            processReward(300000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 95 / 100;
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
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            uint256 blackFee;
            if (isSell) {
                swapFee = _sellfundFee + _sellLPDividendFee + _sellLPFee;
                blackFee = _sellBlackFee;
            } else {
                require(tAmount <= maxTXAmount);
                swapFee = _buyfundFee + _buyLPDividendFee + _buyLPFee;
                blackFee = _buyBlackFee;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
            uint256 blackAmount = tAmount * blackFee / 10000;
            if(blackAmount > 0){
                feeAmount += blackAmount;
                _takeTransfer(
                    sender,
                    blackAddress,
                    blackAmount
                );
            }
        }

        if(!isWalletLimitExempt[recipient] && limitEnable)
        require((balanceOf(recipient) + tAmount - feeAmount) <= walletLimit,"over max wallet limit");


        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
    	uint256 swapFee = _buyfundFee + _buyLPDividendFee + _sellfundFee + _sellLPDividendFee + _sellLPFee + _buyLPFee;
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _tradeAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        swapFee -= lpFee;

        IERC20 FIST = IERC20(_tradeAddress);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = fistBalance * (_buyfundFee + _sellfundFee) * 2 / swapFee;
        FIST.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance - fundAmount);

        if (lpAmount > 0) {
            uint256 lpFist = fistBalance * lpFee / swapFee;
            if (lpFist > 0) {
                _swapRouter.addLiquidity(
                    address(this), _tradeAddress, lpAmount, lpFist, 0, 0, LpAddress, block.timestamp
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


    function setBuyLPDividendFee(uint256 dividendFee) external onlyFunder {
        _buyLPDividendFee = dividendFee;
    }

    function setBuyfundFee(uint256 fundFee) external onlyFunder {
        _buyfundFee = fundFee;
    }

    function setBuyBlackFee(uint256 buyBlackFee) external onlyFunder {
        _buyBlackFee = buyBlackFee;
    }

    function setBuyLPFee(uint256 buyLPFee) external onlyFunder {
        _buyLPFee = buyLPFee;
    }

    function setSellLPDividendFee(uint256 dividendFee) external onlyFunder {
        _sellLPDividendFee = dividendFee;
    }

    function setSellfundFee(uint256 fundFee) external onlyFunder {
        _sellfundFee = fundFee;
    }

    function setSellBlackFee(uint256 buyBlackFee) external onlyFunder {
        _sellBlackFee = buyBlackFee;
    }

    function setSellLPFee(uint256 buyLPFee) external onlyFunder {
        _sellLPFee = buyLPFee;
    }

    function setfundAddress(address addr) external onlyFunder {
        fundAddress = addr;
    }

    function setLPAddress(address addr) external onlyFunder {
        LpAddress = addr;
    }

    function setMaxTxAmount(uint256 max) public onlyFunder {
        maxTXAmount = max;
    }

    function setWalletLimit(uint256 _walletLimit) public onlyFunder{
        walletLimit = _walletLimit;
    }

    function setLimitEnable(bool status) public onlyFunder {
        limitEnable = status;
    }

    function setisWalletLimitExempt(address holder, bool exempt) external onlyFunder {
        isWalletLimitExempt[holder] = exempt;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyFunder {
        _blackList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(LpAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    function setHolderRewardCondition(uint256 amount) external onlyFunder {
        holderRewardCondition = amount;
    }

    function setNumTokenSellToFund(uint256 amount) external onlyFunder {
        numTokensSellToFund = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || LpAddress == msg.sender, "!Funder");
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
    uint256 public holderRewardCondition;

    function processReward(uint256 gas) private {
        IERC20 FIST = IERC20(_tradeAddress);

        uint256 balance = FIST.balanceOf(address(this));
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
                amount = holderRewardCondition * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    FIST.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
}

contract Token is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    
        address(0x55d398326f99059fF775485246999027B3197955),
        "SHEN SHOPU",
        "ShenShou",
        9,
    
        1000000000,
    
        address(0xe6f78098C40b78e96cDEA95bD3be2AaC949440f6)
    ){

    }
}