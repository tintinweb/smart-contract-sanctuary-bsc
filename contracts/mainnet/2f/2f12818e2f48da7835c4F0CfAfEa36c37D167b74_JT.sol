/**
 *Submitted for verification at BscScan.com on 2023-01-21
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
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);
   
    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

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
library Address {
  
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
        function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    address private marketAddress1 = address(0x70D4A862Bc9579F016213129727579d8D47eB90c);
    address private marketAddress2 = address(0x9eb40ef23117472C1dAD5606302a502d7050D485);
    address private marketAddress3 = address(0x5a33219f97855907Ef562609D08D5Afe1c8bA00b);
    address private marketAddress4 = address(0xB36f10b3687b2A293B675CB8158609D09f163C5D);
    address private marketAddress5 = address(0x8260C73e9C279B8eF8F5EFf0c4dafC2d727C0ffe);

    address public  deadAddress =address(0x000000000000000000000000000000000000dEaD);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _isExcludedFromFees;
    mapping (address => address) public inviter;
    mapping(address=>bool) public presaleList;
    address[] buyUser;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    uint256 public inviteAmount;
    uint256 public changeTime = 43200;

    uint256 public _buyDividendFee = 100;
    uint256 public _buyFundFee = 50;    
    uint256 public _buyLPFee = 50;    
    uint256 public _sellDividendFee = 100;
    uint256 public _sellFundFee = 50;
    uint256 public _sellLPFee = 50;

    uint160 public ktNum = 160;
    uint160 public constant MAXADD = ~uint160(0);
    uint256 public startTradeBlock;
    address public _mainPair;
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event MultiplePresaleListAddresses(address[] accounts, bool value);

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


        _isExcludedFromFees[FundAddress] = true;
        _isExcludedFromFees[ReceiveAddress] = true;
        _isExcludedFromFees[marketAddress1] = true;
        _isExcludedFromFees[marketAddress2] = true;
        _isExcludedFromFees[marketAddress3] = true;
        _isExcludedFromFees[marketAddress4] = true;
        _isExcludedFromFees[marketAddress5] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(swapRouter)] = true;
        _isExcludedFromFees[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(deadAddress)] = true;

        holderRewardCondition = 30 * 10 ** 18;
        holderCondition = 1 * 10 ** 17;

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

    receive() external payable {}
         
    uint256 public lastPrice;
    uint256 public priceTime;
    
    function updateLastPrice() public {
        uint256 newTime = block.timestamp.div(changeTime);
        if(newTime > priceTime){
            lastPrice = getNowPrice();
            priceTime = newTime;
        }
    }
    
    function getNowPrice() public view returns(uint256){
        
        IERC20 USDT = IERC20(_usdt);
        uint256 poolUsdt = USDT.balanceOf(_mainPair);
        uint256 poolToken = balanceOf(_mainPair);
        if(poolToken > 0){
            return poolUsdt.mul(10**18).div(poolToken);
        }
        return 0;
    }

    function getDwonRate() public view returns(uint256){
        if(lastPrice > 0){
            uint256 nowPrice = getNowPrice();
            uint256 diffPrice;
            if(lastPrice > nowPrice){
                diffPrice = lastPrice - nowPrice;
                return diffPrice.mul(100).div(lastPrice);
            }
        }
        return 0;
    }

    function getFundRate() public view returns(uint256){
        uint256 downRate = getDwonRate();
        if(downRate >= 10){
            return 5;
        }else{
            return 0;
        }
    }
    
    function getTokenPrice() public view returns (uint256 price){
        ISwapPair swapPair = ISwapPair(_mainPair);
        (uint256 reserve0,uint256 reserve1,) = swapPair.getReserves();
        address token = address(this);
        if (reserve0 > 0) {
            uint256 usdtAmount;
            uint256 tokenAmount;
            if (token < _usdt) {
                tokenAmount = reserve0;
                usdtAmount = reserve1;
            } else {
                tokenAmount = reserve1;
                usdtAmount = reserve0;
            }
            price = 10 ** IERC20(token).decimals() * usdtAmount / tokenAmount;
        }
    }
	
	function getBuysize() public view returns(uint256){
        return buyUser.length;
    }
	
	function getBuyUser(uint256 _index) public view returns(address){
        return buyUser[_index];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if((_swapPairList[from] || _swapPairList[to]) && 0 == startTradeBlock){
            require( from == receiveAddress || to == receiveAddress || from == fundAddress || to == fundAddress|| from == marketAddress1 || to == marketAddress1 || from == marketAddress2 || to == marketAddress2 || from == marketAddress3 || to == marketAddress3 || from == marketAddress4 || to == marketAddress4 || from == marketAddress5 || to == marketAddress5,"only receiveAddress!||fundAddress");            
        } 
         
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint256 maxSellAmount = balance * 999 / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isAddLdx;

        if (_swapPairList[from] || _swapPairList[to]) {

           if (_isExcludedFromFees[from] || _isExcludedFromFees[to] || isAddLdx) {
                  takeFee = false;
           }

            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !isAddLdx ) {
                
                _takeInviterFeeKt(amount.div(10000));
              
                if (_swapPairList[to]) {
                    if (!inSwap && !isAddLdx) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee +  _buyLPFee + _sellFundFee  + _sellLPFee +_buyDividendFee + _sellDividendFee;
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
        if(_swapPairList[to]){
            isAddLdx = _isAddLiquidityV1();
        }
    }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
        }

    }

    function _isAddLiquidityV1()internal view returns(bool ldxAdd){

        address token0 = ISwapPair(address(_mainPair)).token0();
        address token1 = ISwapPair(address(_mainPair)).token1();
        (uint r0,uint r1,) = ISwapPair(address(_mainPair)).getReserves();
        uint bal1 = IERC20(token1).balanceOf(address(_mainPair));
        uint bal0 = IERC20(token0).balanceOf(address(_mainPair));
        if( token0 == address(this) ){
			if( bal1 > r1){
				uint change1 = bal1 - r1;
				ldxAdd = change1 > 1000;
			}
		}else{
			if( bal0 > r0){
				uint change0 = bal0 - r0;
				ldxAdd = change0 > 1000;
			}
		}
    }    

    function _tokenTransfer(
        address from,
        address to,
        uint256 tAmount,
        bool takeFee
    ) private {

        _balances[from] = _balances[from] - tAmount;

        uint256 fundrate;

        if( startTradeBlock > 0 && balanceOf(_mainPair) > 0){           
            if (_swapPairList[from] || _swapPairList[to]){
                updateLastPrice();
                fundrate = getFundRate();
            }
        } 

        if (takeFee) {

			if(_swapPairList[from]){
                _takeTransfer(from, address(this), tAmount.div(10000).mul(_buyFundFee + _buyDividendFee + _buyLPFee ));			
				
                buyUser.push(to);
                
                tAmount = tAmount.div(10000).mul(10000 - (_buyFundFee)- (_buyDividendFee)-(_buyLPFee));
            
            }else if(_swapPairList[to]){
                _takeTransfer(from, address(this), tAmount.div(10000).mul(_sellFundFee + _sellDividendFee + _sellLPFee));			


                if(fundrate > 0){
                    _takeTransfer(from, deadAddress, tAmount.div(100).mul(fundrate));
                    tAmount = tAmount.div(10000).mul(10000  - (fundrate * 100) - (_sellFundFee)-(_sellDividendFee)-(_sellLPFee));
                }else{
                    tAmount = tAmount.div(10000).mul(10000 - (_sellFundFee)-(_sellDividendFee)-(_sellLPFee));
                }
            }
        }
        _takeTransfer(from, to, tAmount);
    }


    
    function _takeInviterFeeKt(
        uint256 amount
    ) private { 
        address _receiveD;
        for (uint160 i = 2; i < 5; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            _takeTransfer(address(this), _receiveD, amount.div(100*i));
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
        uint256 firstfundAmount = UsdtBalance .mul(3).div(8);
        uint256 secFundAmount = UsdtBalance .mul(2).div(8);
        address thirdFundAddress = 0x13F3f3A922B439b9E72006C51D070Bae42559C6e;
        USDT.transferFrom(address(_tokenDistributor), marketAddress1, firstfundAmount);
        USDT.transferFrom(address(_tokenDistributor), marketAddress2, secFundAmount);
        USDT.transferFrom(address(_tokenDistributor), address(this), UsdtBalance - firstfundAmount - secFundAmount);

        if (lpAmount > 0) {
            uint256 lpUsdt = UsdtBalance * lpFee / swapFee;
            if (lpUsdt > 0) {
                _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount, lpUsdt, 0, 0, thirdFundAddress, block.timestamp
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

    
    function setbuyFees(uint256 buyFundFee,uint256 buyDividenFee,uint256 buyLpFee) external onlyOwner{
        _buyFundFee = buyFundFee;
        _buyDividendFee = buyDividenFee;
        _buyLPFee = buyLpFee;

    }
    
    function setsellFees(uint256 sellFundFee,uint256 sellDividenFee,uint256 sellLpFee) external onlyOwner{
        _sellFundFee = sellFundFee;
        _sellDividendFee = sellDividenFee;
        _sellLPFee = sellLpFee;

    }
    
    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }
       

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    
    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external 
    {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external 
    onlyOwner {
        IERC20(token).transfer(to, amount);
    }
    
    function setChangeTime(uint256 value) external onlyOwner {
        changeTime = value;
    }

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
     uint256 public holderCondition;
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
            if (tokenBalance > holderCondition  && !excludeHolder[shareHolder]) {
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

    function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner  {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
     
}

contract JT is AbsToken {
    constructor() AbsToken(
    // router
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    // USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "J&T",
        "J&T",
        18,
        100000000,
    // FUN
        address(0x35240468a918393BCF5186D63a5AD5860B0a2118),
    // REC
        address(0x6cE6b9E762F86259a0C4084C5EF7F6dEe0Ec06DC)
    ){
    }
}