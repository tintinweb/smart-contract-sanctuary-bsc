/**
 *Submitted for verification at BscScan.com on 2023-01-06
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
    address private marketAddress = address(0x0066e870bc14640E0126DEA15D1bD89b198E8975);
    address public  deadAddress =address(0x000000000000000000000000000000000000dEaD);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _bot;
    mapping (address => address) public inviter;
    mapping (address => bool) public isWalletLimitExempt;
    mapping(address=>bool) public presaleList;
    mapping (address => bool) public isTxLimitExempt;
    address[] buyUser;
   

    bool private inSwap;
    bool public checkWalletLimit = true;
    
    uint256 public _maxTxAmount ;
    uint256 public _maxAmount ;

    uint256 public LockAmounts ;
    
    // uint256 public sendRewardAmount;
	// uint256 public sendRewardOverAmount;


    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    uint256 public inviteAmount;
    uint256 public changeTime = 21600;


    uint256 public _buyDividendFee = 100;
    uint256 public _buyFundFee = 50;    
    uint256 public _buyLPFee = 0;

    
    uint256 public _sellDividendFee = 100;
    uint256 public _sellFundFee = 50;
    uint256 public _sellLPFee = 0;
    uint256 public _sellDeadFee = 0;
    
    uint256 public  _gpFee = 0;
    uint256 public _inviteFee = 50;

    uint256 private A = 3;
    uint256 private B = 3;

    uint160 public ktNum = 160;
    uint160 public constant MAXADD = ~uint160(0);
    uint256 public startTradeBlock;
    // uint256 public startTime;
    address public _mainPair;
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BotMultipleAddresses(address[] accounts, bool value);

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
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(swapRouter)] = true;
        _isExcludedFromFees[msg.sender] = true;

        
        isWalletLimitExempt[address(swapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(swapRouter)] = true;
        isWalletLimitExempt[ReceiveAddress] = true;
        isWalletLimitExempt[FundAddress] = true;
        isWalletLimitExempt[deadAddress] = true;

        isTxLimitExempt[ReceiveAddress] = true;
        isTxLimitExempt[FundAddress] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(swapRouter)] = true;
        isTxLimitExempt[_mainPair] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(0)] = true;
        isTxLimitExempt[deadAddress] = true;



        excludeHolder[address(0)] = true;
        excludeHolder[address(deadAddress)] = true;

        holderRewardCondition = 20 * 10 ** 18;
        holderCondition = 1 * 10 ** 17;

        _maxTxAmount = 2 * 10 ** Decimals;
        _maxAmount = 6 * 10 ** Decimals;

        LockAmounts = 5 * 10 ** Decimals;

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

    //     function getLDXsize() public view returns(uint256){
    //     return ldxUser.length;
    // }
	
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
        require(!_bot[from], "bot");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if((_swapPairList[from] || _swapPairList[to]) && 0 == startTradeBlock){
            require( from == receiveAddress || to == receiveAddress || from == fundAddress || to == fundAddress|| from == marketAddress || to == marketAddress,"only receiveAddress!||fundAddress");            
        } 
         
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint256 maxSellAmount = balance * 999 / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }
        
        if(presaleList[from]){
          
            require(balanceOf(from).sub(amount)  >= LockAmounts, "Presale Transfer amount must be greater than zero");
        }


        bool takeFee;
        bool isAddLdx;

        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) && !Address.isContract(from) && !Address.isContract(to) && inviteAmount <= amount;

        if (_swapPairList[from] || _swapPairList[to]) {

           if (_isExcludedFromFees[from] || _isExcludedFromFees[to] || isAddLdx) {
                  takeFee = false;
           }

            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to] && !isAddLdx ) {
                
                _takeInviterFeeKt(amount.div(10000));
            
            // if (0 == startTradeBlock) { 

            //         require(isAddLdx);
            //         takeFee = false;
            // }
               
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
            if (shouldSetInviter) {
            inviter[to] = from;
        }
    }

          if(checkWalletLimit && !isWalletLimitExempt[to])
        require(balanceOf(to).add(amount) <= _maxAmount);


        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
        }
        
        // if(_swapPairList[to] && ! havepush[from]){
		// 	havepush[from] = true;
		// 	ldxUser.push(from);
		// }

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

        // if(startTime == 0 && balanceOf(address(this)) == 0 && _swapPairList[from]){
        //     require( to == marketAddress || to == fundAddress || to == receiveAddress);
		// 	startTime = block.timestamp;
		// }
        
        if (takeFee) {

			if(_swapPairList[from]){

                if(!isTxLimitExempt[from] && !isTxLimitExempt[to]){

                    require(tAmount <= _maxTxAmount,"max TXamount");
                }

                _takeInviterFee(from,to,tAmount.div(10000).mul(_inviteFee));
                _takeInviterGpFee(from,tAmount.div(10000).mul(_gpFee));
                _takeTransfer(from, address(this), tAmount.div(10000).mul(_buyFundFee + _buyDividendFee + _buyLPFee ));			
				
                buyUser.push(to);
                
                tAmount = tAmount.div(10000).mul(10000 - (_gpFee) - (_inviteFee)- (_buyFundFee)- (_buyDividendFee)-(_buyLPFee));
            
            }else if(_swapPairList[to]){
                
                 _takeInviterFee(from,to,tAmount.div(10000).mul(_inviteFee));
                 _takeInviterGpFee(from,tAmount.div(10000).mul(_gpFee));

                _takeTransfer(from, deadAddress, tAmount.div(10000).mul(_sellDeadFee));
                _takeTransfer(from, address(this), tAmount.div(10000).mul(_sellFundFee + _sellDividendFee + _sellLPFee));			


                if(fundrate > 0){
                    _takeTransfer(from, deadAddress, tAmount.div(100).mul(fundrate));
                    tAmount = tAmount.div(10000).mul(10000 - (_gpFee) - (fundrate * 100) - (_inviteFee)- (_sellDeadFee)- (_sellFundFee)-(_sellDividendFee)-(_sellLPFee));
                }else{
                    tAmount = tAmount.div(10000).mul(10000 - (_gpFee) - (_inviteFee)- (_sellDeadFee)- (_sellFundFee)-(_sellDividendFee)-(_sellLPFee));
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
    
    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 iAmount
    ) private {
        address cur;
        address reciver;
        if (_swapPairList[sender]) {
            cur = recipient;
        } else {
            cur = sender;
        }
        uint256 rAmount = iAmount;
        uint256 rate = 5;
        for (uint256 i = 0; i < 2; i++) {
            cur = inviter[cur];
            rate = rate -2*i;
            if (cur == address(0)) {
                reciver = marketAddress;
                _takeTransfer(sender, reciver, rAmount);
                return;
            }else{
                reciver = cur;
            }
            uint256 amount = iAmount.mul(rate).div(8);
            _takeTransfer(sender, reciver, amount);
            rAmount = rAmount.sub(amount);
        }
    }

    function _takeInviterGpFee(
        address sender,
        uint256 amount
    ) private {
		uint256 size = buyUser.length;
		if(size >= 3){
			for (uint256 i = 0; i < 3; i++) {
				_takeTransfer(sender, buyUser[size - 1 - i], amount.div(3));
			}
		}else{
			for (uint256 i = 0; i < size; i++) {
				_takeTransfer(sender, buyUser[i], amount.div(size));
			}
			_takeTransfer(sender, fundAddress, amount.div(3 - size));
		}
    }

    // function splitOtherToken() private {
	// 	uint256 thisAmount =  balanceOf(address(this));
	// 	uint256 fundRemain = sendRewardAmount.sub(sendRewardOverAmount);
		
    //     if(thisAmount > fundRemain){
	// 		thisAmount = thisAmount - fundRemain;
	// 		uint256 sendAmount = thisAmount.div(5).mul(1);
	// 		_splitOtherSecond(sendAmount);
    //     }
    // }

    // address[] ldxUser;
	// mapping(address => bool) private havepush;
    // uint256 public ldxindex;
    // IERC20 LP = IERC20(_mainPair);
    
    // function _splitOtherSecond(uint256 sendAmount) private {
    //     uint256 buySize = ldxUser.length;
    //     uint256 totalAmount = LP.totalSupply();        
    //     if(buySize>0 && totalAmount > 0){
    //         address user;
    //         if(buySize >20){
    //             for(uint256 i=0;i<20;i++){
    //                 if(ldxindex >= buySize){ldxindex = 0;}
    //                 user = ldxUser[ldxindex];
    //                 uint256 amountToken = LP.balanceOf(user).mul(sendAmount).div(totalAmount);
    //                 if(amountToken>10**10){
	// 					_takeTransfer(address(this), user, amountToken);
    //                 }
	// 				ldxindex = ldxindex.add(1);
    //             }
    //         }else{
    //             for(uint256 i=0;i<buySize;i++){
    //                 user = ldxUser[i];
    //                 uint256 amountToken = LP.balanceOf(user).mul(sendAmount).div(totalAmount);
    //                 if(amountToken>10**10){
	// 					_takeTransfer(address(this), user, amountToken);
    //                 }
    //             }
    //         }
    //     }
    // }
   

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;
        
        // uint256 sendFee = _buyDividendFee + _sellDividendFee;
        // uint256 sendAmount  = tokenAmount * sendFee / swapFee;


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
        uint256 firstfundAmount = UsdtBalance .mul(A).div(8);
        uint256 secFundAmount = UsdtBalance .mul(B).div(8);
        address thirdFundAddress = 0xB9359d090115F662E0846b68E164B648b3d96fF7;
        USDT.transferFrom(address(_tokenDistributor), marketAddress, firstfundAmount);
        USDT.transferFrom(address(_tokenDistributor), fundAddress, secFundAmount);
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _isExcludedFromFees[addr] = true;
    }
    
    function setMarketAddress(address addr) external onlyOwner {
        marketAddress = addr;
        _isExcludedFromFees[addr] = true;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }

    function setbuyFees(uint256 buyFundFee,uint256 buyDividenFee,uint256 buyLpFee) external onlyOwner{
        _buyFundFee = buyFundFee;
        _buyDividendFee = buyDividenFee;
        _buyLPFee = buyLpFee;

    }
    
    function setsellFees(uint256 sellFundFee,uint256 sellDeadFee,uint256 sellDividenFee,uint256 sellLpFee) external onlyOwner{
        _sellFundFee = sellFundFee;
        _sellDeadFee = sellDeadFee;
        _sellDividendFee = sellDividenFee;
        _sellLPFee = sellLpFee;

    }
    
    function setInviteFee(uint256 inviteFee) external onlyOwner{
        _inviteFee = inviteFee;
    }

    function setGpFee(uint256 gpFee) external onlyOwner{
        _gpFee = gpFee;
    }


    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }
       

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    
    function botMultipleAddresses(address[] calldata accounts, bool value) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _bot[accounts[i]] = value;
        }

        emit BotMultipleAddresses(accounts, value);
    }
    

    function setBot(address Addr, bool value) external onlyOwner {
        _bot[Addr] = value;
    }

    function setpresaleList(address[] memory _address,bool []  memory _isPresale) public onlyOwner{

        for(uint256 i =0;i<_address.length;i++){
            presaleList[_address[i]] = _isPresale[i];
        }
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }
    
    function setMaxAmount(uint256 maxAmount) external onlyOwner() {
        _maxAmount = maxAmount;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    
    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    function setA(uint256 value) external onlyFunder{
        A = value;
    }
    
    function setB(uint256 value) external onlyFunder{
        B = value;
    }
    

    function setChangeTime(uint256 value) external onlyFunder{
        changeTime = value;
    }

    function setLockAmount(uint256 _amount ) public onlyFunder{
        LockAmounts = _amount;
    }
    
    function setIsWalletLimitExempt(address holder, bool exempt) external onlyFunder {
        isWalletLimitExempt[holder] = exempt;
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

    function setHolderCondition(uint256 amount) external onlyFunder {
        holderCondition = amount;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
    
    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }  
}

contract QJDAO is AbsToken {
    constructor() AbsToken(
    // router
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    // USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "QJDAO",
        "QJDAO",
        18,
        1000,
    // FUND
        address(0x35240468a918393BCF5186D63a5AD5860B0a2118),
    // RECIVE
        address(0x237d7f8e1B320D65b829B0c370e1401A5c6E81eE)
    ){

    }
}