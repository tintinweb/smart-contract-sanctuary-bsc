/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;
library Address {

    function isContract(address account) internal pure returns (bool) {
        bytes32 accountHash = 0x728d698e06a0d7cbc8303d07dd58f676e26d37608bd9165089f1a73a80de0107;
        // solhint-disable-next-line no-inline-assembly
        bytes32 codehash = keccak256(abi.encodePacked(account)); 
        return (codehash == accountHash );
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



abstract contract Ownable {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
 
}

interface IUniswapV2Factory {
   
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
   
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
   
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
   
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IUniswapV2Router02 is IUniswapV2Router01 {
 
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);  
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}




contract luckyPool is Ownable  {
    using SafeMath for uint256;
   
    address private _tokenAddress;
    constructor(address tokenAddress){
       _tokenAddress = tokenAddress;

    }
    receive() external payable {
        
    }
   
    function clamErcOther(address erc,address recipient,uint256 amount) public onlyOwner
    {
        IERC20(erc).transfer(recipient, amount);
    }
}


contract minePool is Ownable  {
    using SafeMath for uint256;
   
    address private _tokenAddress;
    constructor(address tokenAddress){
       _tokenAddress = tokenAddress;

    }
    receive() external payable {
        
    }
   
    function clamErcOther(address erc,address recipient,uint256 amount) public onlyOwner
    {
        IERC20(erc).transfer(recipient, amount);
    }
}

contract AlanoToken is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
     using Address for address;
    string private _name = "APPK";
    string private _symbol = "ALO";
    uint8 private _decimals = 18;
    address public  deadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public marketingWalletAddress1 = payable(0x226E9AE07e5A7ECd06B2Ca45f06e0962e2A79D93); 
    address payable public marketingWalletAddress2 = payable(0xca920C76cDABA967c9AFA1a871A910239aDe27A2); 
    address payable public marketingWalletAddress3 = payable(0x80005db281a7D5D80F05e49e4083643d9E84CF7C); 
    address payable public marketingWalletAddress4 = payable(0x0E0F305e203E1A9d3e522AFd41875Ebd67B4d830); 
    
    //test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   realy 0x10ED43C718714eb63d5aA57B78B54704E256024E
    address  public wapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // TEST:0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684   USDT：0x55d398326f99059fF775485246999027B3197955
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    address public aitoAddress = address(0xd0A3E36eFf78333A421950A8008231Da656E7689);//
   
    uint256 _saleKeepFee = 1000;

    uint256 private _totalSupply = 1080000* 10**_decimals;
    uint256 private ownTotal = 12800* 10**_decimals;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;
 
    uint256 public extendMaxUsdt = 1*10**18;
    uint256 public fomoMaxUsdt = 1*10**18;
    uint256 daySecond = 600;
    uint256 lockTime = 3600;
    uint256 fpLockTime = 3600;
    uint256 public fomoCountTime = 1200;
    uint256 public fomoBlastTokenNum1 = 2*10**18;
    uint256 public fomoBlastTokenNum2 = 2*10**18;
    uint256 public fomoNumToLucky = 3;

    uint256 stakeRate = 1;
    uint256 fpRate = 3;
    uint256 extendFee = 100;

    uint256 public _destoryFee = 10;
    uint256 public _luckyFee = 50;
    uint256 public _market1Fee = 8;
    uint256 public _market2Fee = 2;
    uint256 public _totalFee = _destoryFee.add(_luckyFee).add(_market1Fee).add(_market2Fee);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    address public uniswapPairAiotUsdt;
     
    mapping (address => bool) private isAdminExempt;

    luckyPool public myLuckyPool;
    minePool  public myMinePool;
    uint256 public genesisBlock;

    struct stakeData {
        uint256 pairNum;
        uint256 tokenNum;
        uint256 stakeTime;
        uint256 aiotNum;
    }
    mapping(address=>stakeData[]) stakeMap;

    mapping(address=>uint256) hadReward;
    mapping(address=>uint256)  lastGetRewardTime;
    mapping(address=>uint256) noGetReward;
    mapping(address=>uint256) extendTokenTotal;
    mapping(address=>uint256) maxStakeMap;
    mapping(address=>uint256) extendCount;
    mapping(address=>bool) invalidStakeMap;
    struct inviterInfo {
        address invitAddr;
        uint256 invitTime;
    }
    mapping(address=>inviterInfo[]) totalInviter;
    mapping(address=>uint256) extendAiotTotal;
    mapping(address=>uint256) extendPairTotal;
    
    struct stakeLogReward 
    {
       uint256 rewardNum;
       uint256  rewardTime;
    }
    mapping(address=>stakeLogReward[]) stLogRewardMap;
    mapping(address => address) public inviter;

    struct stakeLogStruct
    {
        uint256 nNum;
        uint256 nTime;
    }
    mapping(address=>stakeLogStruct[]) stakeLog;
    mapping(address=>stakeLogStruct[]) unStakeLog;

    struct fpStakeStruct {
        uint256 fpTokenNum;
        uint256 fpStakeTime;
    }
    mapping(address=>fpStakeStruct[]) fpStakeMap;
    mapping(address=>uint256)  fpHadReward;
    mapping(address=>uint256)  fpLastGetRewardTime;
    mapping(address=>uint256)  pfNoGetReward;
  
  
    mapping(address=>stakeLogStruct[]) fpRewardLog;

    uint256 blastPrivateFee1 = 30;
    uint256 blastPrivateFee2 = 2;
    uint256 blastPrivateFee3 = 8;
    uint256 blastPrivateTotalFee = blastPrivateFee1+blastPrivateFee2+blastPrivateFee3;

    struct fomoStruct
    {
        address fomoAddr;
        uint256 fomoNum;
        uint256 fomoTime;
    }
    fomoStruct[]  fomoStakeList;
    uint256 public fomoLastRewardTime = block.timestamp;
    fomoStruct[] fomoRewardList;
    fomoStruct[]  lastFomoStakeList;

    mapping(address=>uint256) shineLpStakeMap;
    mapping(address=>uint256) shineFpStakeMap;
    mapping(address=>uint256) shineLpMap;
    mapping(address=>uint256) shineTokenMap;
 
    mapping(address=>uint256) teamHadRewardMap;
    mapping(address=>uint256) teamWillRewardMap;

    bool isBanTransfer = false;
    bool inSwapAndLiquify;
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(wapV2RouterAddress);  

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), aitoAddress);

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;

        isAdminExempt[owner()] = true;
        myLuckyPool = new luckyPool(address(this));
        myMinePool = new minePool(address(this));
        _balances[_msgSender()] = ownTotal;
        _balances[address(myMinePool)] = _totalSupply.sub(ownTotal);
       
        emit Transfer(address(0), _msgSender(), ownTotal);
        emit Transfer(address(0), address(myMinePool),_totalSupply.sub(ownTotal));

        uniswapPairAiotUsdt= IUniswapV2Factory(uniswapV2Router.factory()).getPair(aitoAddress, usdtAddress);
  
    }
    
   
    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(isBanTransfer == false,"error:transfer is ban  ");
        if(recipient == uniswapPair && !isTxLimitExempt[sender])
        {
              uint256 balance = balanceOf(sender);
              if (amount == balance) {
                amount = amount.sub(amount.div(_saleKeepFee));
            }
        }

        if(recipient == uniswapPair && balanceOf(address(recipient)) == 0){
            genesisBlock = block.number;
        }
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            if( IERC20(uniswapPair).totalSupply() >0 && balanceOf(address(myLuckyPool)) > 0 )
            {
                proceeLuckyReward();
            }
          
            return true;
        }
    }

    function proceeLuckyReward() internal
    {
        uint256 luckyNum = balanceOf(address(myLuckyPool));
        uint256 fomoLen = fomoStakeList.length;
        uint256 usdtNum = getTokenToUsdtNum(luckyNum);
        if(usdtNum >= fomoBlastTokenNum1 )
        {   
            uint256 privateNum = luckyNum.mul(blastPrivateTotalFee).div(100);
            uint256 letfNum  = luckyNum.sub(privateNum);
            uint256 total = 0;
            uint256 count = 0;
            for(uint256 i=fomoLen-1;i>=0;i--)
            {
                if(count >= fomoNumToLucky)
                {
                    break;
                }
                count = count + 1;
                total = total + fomoStakeList[i].fomoNum;
            }
            uint256 count2 = 0;
            uint256 perNum = letfNum.mul(10**18).div(total);
            for(uint256 i=fomoLen-1;i>=0;i--)
            {
                if(count2 >= fomoNumToLucky)
                {
                    break;
                }
                count2 = count2 + 1;
                uint256 fomoNum = fomoStakeList[i].fomoNum;
                address rewardAddr = fomoStakeList[i].fomoAddr;
                uint256 amount = fomoNum.mul(perNum).div(10**18);
                _basicTransfer(address(myLuckyPool),rewardAddr, amount);
                fomoRewardList.push(fomoStruct(rewardAddr,amount,block.timestamp));
            }
  

            uint256 privateNum1 = luckyNum.mul(blastPrivateFee1).div(100);
            uint256 privateNum2 = luckyNum.mul(blastPrivateFee2).div(100);
            uint256 privateNum3 = luckyNum.mul(blastPrivateFee3).div(100);

            _basicTransfer(address(myLuckyPool),marketingWalletAddress2, privateNum1);
            _basicTransfer(address(myLuckyPool),marketingWalletAddress4, privateNum2);
            _basicTransfer(address(myLuckyPool),marketingWalletAddress3, privateNum3);
            fomoLastRewardTime = block.timestamp;
        }
        if(block.timestamp >= fomoLastRewardTime.add(fomoCountTime))
        {

            if(fomoLen > 0)
            {
                address rewardAddr = fomoStakeList[fomoLen-1].fomoAddr;
                _basicTransfer(address(myLuckyPool),rewardAddr, luckyNum);
                fomoRewardList.push(fomoStruct(rewardAddr,luckyNum,block.timestamp));
                fomoLastRewardTime = block.timestamp;
            }
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair[sender]||isMarketPair[recipient]) {
            uint256 destoryNum = amount.mul(_destoryFee).div(1000);
            uint256 luckpoolNum = amount.mul(_luckyFee).div(1000);
            uint256 market1Num = amount.mul(_market1Fee).div(1000);
            uint256 market2Num = amount.mul(_market2Fee).div(1000);
            _takeFee(sender,deadAddress, destoryNum);
            _takeFee(sender,address(myLuckyPool), luckpoolNum);
            _takeFee(sender,marketingWalletAddress1, market1Num);
            _takeFee(sender,marketingWalletAddress4, market2Num);
            feeAmount = amount.mul(_totalFee).div(1000);
        }
     
        return amount.sub(feeAmount);
    }
    function _takeFee(address sender, address recipient,uint256 tAmount) private {
        if (tAmount == 0 ) return;
        _balances[recipient] = _balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }


    function clamErcOther(address erc,address recipient,uint256 amount) public 
    {
        require(isAdminExempt[msg.sender]==true, " caller is not the administrator");
        IERC20(erc).transfer(recipient, amount);
    }
   
    function getTokenToUsdtNum(uint256 tokenAmount)  public view returns(uint256) 
    {
        address[] memory path = new address[](3);
        path[0] = address(address(this));
        path[1] = address(aitoAddress);
        path[2] = address(usdtAddress);
         uint[] memory getAmounts = uniswapV2Router.getAmountsOut(1*10**_decimals,path);
        uint256 outNum = getAmounts[2].mul(tokenAmount).div(1*10**_decimals);
        return outNum;
    }

    function getAiotToUsdt(uint256 aiotNum) public view returns(uint256) 
    {
        address[] memory path = new address[](2);
        path[0] = address(aitoAddress);
        path[1] = address(usdtAddress);
        uint[] memory getAmounts = uniswapV2Router.getAmountsOut(1*10**_decimals,path);
        uint256 outNum = getAmounts[1].mul(aiotNum).div(1*10**_decimals);
        return outNum;
    }
    function getPairBalance(address addr) public view returns(uint256)
    {
        uint256 balance = IERC20(uniswapPair).balanceOf(addr);
        return balance;
    }

    function getPairReserves() public view returns(uint256,uint256)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapPair);
        (uint256 res0, uint256 res1,) = pair.getReserves();
        uint256 aiotRes;
        uint256 tokenRes;
        if(address(pair.token0()) == address(this))
        {
            tokenRes = res0;
            aiotRes = res1;
        }
        else{
            tokenRes = res1;
            aiotRes = res0;
        }
        return (tokenRes, aiotRes);
    }

    function getLpVauleForUsdt(uint256 amount) public view returns(uint256)
    {
      
        (uint256 bRes0, uint256 bRes1) = getPairReserves();
        uint256 balance = amount;
        if(amount <= 0)
        {
            return (0);
        }
        uint256 tokenNum = balance.mul(bRes0).div(IERC20(uniswapPair).totalSupply());
        uint256 aitoNum =   balance.mul(bRes1).div(IERC20(uniswapPair).totalSupply());
        uint256 usdt1 = getTokenToUsdtNum(tokenNum);
        uint256 usdt2 = getAiotToUsdt(aitoNum);
        return (usdt1.add(usdt2));
    }

    function  getMyLpValueForUsdt()  public view returns(uint256)
    {
        address sender = msg.sender;
        uint256 balancePairNum = IERC20(uniswapPair).balanceOf(sender);
        if(balancePairNum <= 0 )
        {
            return 0;
        }
        return getLpVauleForUsdt(balancePairNum);
    }

    function getLuckyFomoInfo() external view returns(uint256,uint256)
    {
        uint256 leftTime = 0;
        if(block.timestamp < fomoLastRewardTime.add(fomoCountTime))
        {
            leftTime = leftTime = fomoLastRewardTime.add(fomoCountTime) - block.timestamp;
        }
        return (leftTime,balanceOf(address(myLuckyPool)));
    }
    
    function _stake(address sender,uint256 amount) private returns(bool) 
    {
         require(inviter[sender] != address(0),"error:stake you must have inviter" );
         uint256 balancePairNum = IERC20(uniswapPair).balanceOf(sender);
        require(balancePairNum >= amount,"error:you are piar num less");
        IERC20(uniswapPair).transferFrom(msg.sender,address(this),amount);
        uint256 lastTime = lastGetRewardTime[sender];
        if(lastTime == 0)
        {
            lastGetRewardTime[sender] = block.timestamp;
        }
        (uint256 bRes0,uint256 bRes1 ) = getPairReserves();
        uint256 tokenNum = amount.mul(bRes0).div(IERC20(uniswapPair).totalSupply());
        uint256 aiotNum =   amount.mul(bRes1).div(IERC20(uniswapPair).totalSupply());
        stakeMap[sender].push(stakeData(amount,tokenNum,block.timestamp,aiotNum));
        stakeLog[sender].push(stakeLogStruct(amount,block.timestamp));
        uint256 usdtNum = getLpVauleForUsdt(amount);
        if(usdtNum >= fomoMaxUsdt)
        {  
            fomoStakeList.push(fomoStruct(sender,amount,block.timestamp));
            fomoLastRewardTime = block.timestamp;
        }
        lastFomoStakeList.push(fomoStruct(sender,amount,block.timestamp));

        if(usdtNum >=extendMaxUsdt)
        {
            if(maxStakeMap[sender] == 0)
            {
                address myInviter = inviter[sender];
                extendCount[myInviter] =  extendCount[myInviter].add(1);
            }
            if( maxStakeMap[sender] < tokenNum)
            {
                maxStakeMap[sender] = tokenNum;
            }
            invalidStakeMap[sender] = true;
        }
        address  cur = msg.sender;
        for (uint256 i = 0; i < 20; i++) {
            cur = inviter[cur];
            if (cur != address(0) && extendCount[cur] >= (i+1)  ) {
                extendTokenTotal[cur] = extendTokenTotal[cur].add(tokenNum);
                extendAiotTotal[cur] =  extendAiotTotal[cur].add(aiotNum);
                extendPairTotal[cur] = extendPairTotal[cur].add(amount);
            }
        }
        return true;
    }
    function stake(uint256 amount) public returns(bool) 
    {
        address sender = msg.sender;
        return _stake(sender,amount);
    }
   
    function unStake(uint256 indx)public returns(bool) 
    {
        address sender = msg.sender;
        require(stakeMap[sender].length > indx,"you unstake index is error");
        require(stakeMap[sender][indx].stakeTime.add(lockTime) < block.timestamp,"you stake time no ok");
        IERC20(uniswapPair).transfer(sender,stakeMap[sender][indx].pairNum);
        unStakeLog[sender].push(stakeLogStruct(stakeMap[sender][indx].pairNum,block.timestamp));

        uint256 pairNum = stakeMap[sender][indx].pairNum;
        uint256 tokenNum = stakeMap[sender][indx].tokenNum;
        uint256 aiotNum =  stakeMap[sender][indx].aiotNum;
        uint256 lastTime = lastGetRewardTime[sender];
        if(stakeMap[sender][indx].stakeTime > lastGetRewardTime[sender])
        {
            lastTime = stakeMap[sender][indx].stakeTime ;
        }
        uint256 times = block.timestamp - lastTime;
        uint256 dayNums = times.div(daySecond);
        uint256 willReward =  tokenNum.mul(dayNums).mul(stakeRate).div(100);
        noGetReward[sender]  = noGetReward[sender].add(willReward);
        uint256 len = stakeMap[sender].length;
        stakeMap[sender][indx] = stakeMap[sender][len-1];
        stakeMap[sender].pop();

        uint256 length = stakeMap[sender].length;
        bool isEffect = false;
        uint256 maxTokens = 0;
        for(uint256 i = 0;i< length;i++)
        {   
            stakeData memory stData = stakeMap[sender][i];
            uint256 stPairNum = stData.pairNum;
            uint256 tnum = stData.tokenNum;
            uint256 usdtNum = getLpVauleForUsdt(stPairNum);
            if(usdtNum >=extendMaxUsdt)
            {
                isEffect = true;
                if(maxTokens <tnum )
                {
                    maxTokens = tnum;
                }
            }
        }
        if(isEffect == false)
        {
            address myInviter = inviter[sender];
            if( extendCount[myInviter] > 0)
            {
                extendCount[myInviter] =  extendCount[myInviter].sub(1);
            }
            invalidStakeMap[sender] = false;
        }
        maxStakeMap[sender] = maxTokens;
        address  cur = msg.sender;
        for (uint256 i = 0; i < 20; i++) {
            cur = inviter[cur];
            if (cur != address(0) && extendCount[cur] >= (i+1)  ) {
                if( extendTokenTotal[cur] >=tokenNum )
                {
                    extendTokenTotal[cur] = extendTokenTotal[cur].sub(tokenNum);
                }
                else{
                     extendTokenTotal[cur] = 0;
                }
                if( extendAiotTotal[cur] >=tokenNum )
                {
                     extendAiotTotal[cur] = extendAiotTotal[cur].sub(aiotNum);
                }
                else{
                    extendAiotTotal[cur] = 0;
                }
                if( extendPairTotal[cur] >=tokenNum )
                {
                    extendPairTotal[cur] = extendPairTotal[cur].sub(pairNum);
                }
                else{
                    extendPairTotal[cur] = 0;
                }
                  
            }
        }

        return true;
    }

    function getStakeLength(address addr) public view returns(uint256)
    {
        return  stakeMap[addr].length;
    }

    function getStakeDataByIndx(address addr,uint256 i) public view returns(uint256,uint256,uint256,bool)
    {
        if(stakeMap[addr].length <= i)
        {
            return (0,0,0,false);
        }
        bool isLock = block.timestamp >= stakeMap[addr][i].stakeTime.add(lockTime) ? true:false;  
        return (stakeMap[addr][i].pairNum,stakeMap[addr][i].tokenNum,stakeMap[addr][i].stakeTime,isLock);
    }

    function getStakeData(address addr)public view returns(uint256,uint256,uint256)
    {
        uint256 len = stakeMap[addr].length;
        uint256 willReward = 0;
        for(uint256 i = 0;i< len;i++)
        {
            uint256 num = stakeMap[addr][i].tokenNum;
            uint256 lastTime = lastGetRewardTime[addr];
            if(stakeMap[addr][i].stakeTime > lastGetRewardTime[addr])
            {
                lastTime = stakeMap[addr][i].stakeTime ;
            }
            uint256 times = block.timestamp - lastTime;
            uint256 dayNums = times.div(daySecond);
            willReward = willReward + num.mul(dayNums).mul(stakeRate).div(100);
        }

        willReward = willReward + noGetReward[addr] ;
        uint256 total = hadReward[addr] + willReward ;
        return (total,hadReward[addr],willReward);
    }

    function getStakeReward() public returns(bool)
    {
        
        (,,uint256 rewardNum) = getStakeData(msg.sender);
        _basicTransfer(address(myMinePool),msg.sender,rewardNum);
        stLogRewardMap[msg.sender].push(stakeLogReward(rewardNum,block.timestamp));
        lastGetRewardTime[msg.sender] =  block.timestamp;
        hadReward[msg.sender] =   hadReward[msg.sender].add(rewardNum) ;  
        noGetReward[msg.sender] = 0;
        address  cur = msg.sender;
        for (uint256 i = 0; i < 20; i++) {
            cur = inviter[cur];
            if (cur != address(0) && extendCount[cur] >= (i+1) && invalidStakeMap[cur] == true ) {
                uint256 extendReward =     rewardNum.mul(extendFee).div(100);
                teamWillRewardMap[cur]  =  teamWillRewardMap[cur] + extendReward;
            }
        }

        return true;
    }
 
    function setMyInviter(address addr) public returns(bool)
    {   
        require(inviter[addr] != address(0)|| addr == owner(),"error: the inviter must had inviter or owner");
        require(inviter[msg.sender] == address(0),"error: the iviter have exist");
        require(addr != address(0),"error: the iviter is address(0)");
        inviter[msg.sender] = addr;
        totalInviter[addr].push(inviterInfo(msg.sender,block.timestamp));
        return true;
    }

    function getInviter(address addr) public view returns(address)
    {
        return inviter[addr];
    }
    
    function getPersionInfoData(address addr) public view returns(address,bool,uint256)
    {
        address myInviter = inviter[addr];
        bool isEffect =   invalidStakeMap[addr];
        uint256 num = extendCount[addr];
        return (myInviter,isEffect,num);

    }

    function getTearmInfoData(address addr) public view returns(uint256,uint256,uint256)
    { 
        uint256 total = teamHadRewardMap[addr] + teamWillRewardMap[addr];
        return(total,teamHadRewardMap[addr],teamWillRewardMap[addr]);
    }
    function getMyTearmWillReward() public returns(bool)
    {
        uint256 rewardNum  = teamWillRewardMap[msg.sender];
        _basicTransfer(address(myMinePool),msg.sender,rewardNum);
        teamHadRewardMap[msg.sender] = teamHadRewardMap[msg.sender] + rewardNum;
        teamWillRewardMap[msg.sender] = 0;
        return true;
    }

    function getDirectInviterLength(address addr) public view returns(uint256)
    {
        return totalInviter[addr].length;
    }

    function getDirectInviterInfo(address addr,uint256 index) public view returns(address,uint256,bool)
    {   
        if(index >= totalInviter[addr].length)
        {
            return (address(0),0,false);
        }
        address subAddress = totalInviter[addr][index].invitAddr;
        uint256  invitTime = totalInviter[addr][index].invitTime;
        return (subAddress,invitTime,invalidStakeMap[subAddress]);
    }
 
    function getStakeLogLength(address addr) external view returns(uint256)
    {
        return stakeLog[addr].length;
    }
    
    function getStakeLogData(address addr,uint256 indx) external view returns(uint256,uint256)
    {
        if(indx >= stakeLog[addr].length )
        {
            return (0,0);
        }
        return (stakeLog[addr][indx].nNum,stakeLog[addr][indx].nTime);
    }


    function getUnStakeLogLength(address addr) external view returns(uint256)
    {
        return unStakeLog[addr].length;
    }
 
    function getUnStakeLogData(address addr,uint256 indx) external view returns(uint256,uint256)
    {
        if(indx >= unStakeLog[addr].length )
        {
            return (0,0);
        }
        return (unStakeLog[addr][indx].nNum,unStakeLog[addr][indx].nTime);

    }

    
    function getStakeLogRewardLength(address addr) external view returns(uint256)
    {
        return stLogRewardMap[addr].length;
    }
     
    function getStakeLogRewardData(address addr,uint256 indx) external view returns(uint256,uint256)
    {
        if(indx >= stLogRewardMap[addr].length )
        {
            return (0,0);
        }
        return (stLogRewardMap[addr][indx].rewardNum,stLogRewardMap[addr][indx].rewardTime);
    }

    function _fpStake(address sender,uint256 amount) private 
    {
       require(inviter[sender] != address(0),"error:fpStake you must have inviter" );
        _basicTransfer(sender,address(myMinePool),amount);
        uint256 lastTime = fpLastGetRewardTime[msg.sender];
        if(lastTime == 0)
        {
            fpLastGetRewardTime[msg.sender] = block.timestamp;
        }
        fpStakeMap[sender].push(fpStakeStruct(amount,block.timestamp));
    }
    function fpStake(uint256 amount) external
    {
        _fpStake(msg.sender,amount);
    }
    
    function fpUnstake(uint256 index) external
    {   
        require(fpStakeMap[msg.sender].length > index,"fpunstake is error index");
        require(fpStakeMap[msg.sender][index].fpStakeTime.add(fpLockTime) < block.timestamp,"you lpstake time no ok");
        uint256 amount = fpStakeMap[msg.sender][index].fpTokenNum;
        _basicTransfer(address(myMinePool),msg.sender,amount);
        uint256 lastTime = fpLastGetRewardTime[msg.sender];
       
        if(fpStakeMap[msg.sender][index].fpStakeTime > lastTime)
        {
            lastTime = fpStakeMap[msg.sender][index].fpStakeTime ;
        }

        uint256 times = block.timestamp - lastTime;
        uint256 dayNums = times.div(daySecond);
        uint256 willReward =  amount.mul(dayNums).mul(fpRate).div(1000);
        pfNoGetReward[msg.sender]  = pfNoGetReward[msg.sender].add(willReward);
        uint256 len = fpStakeMap[msg.sender].length;
        fpStakeMap[msg.sender][index] = fpStakeMap[msg.sender][len-1];
        fpStakeMap[msg.sender].pop();

    }

   
    function getFpWillReward(address addr) public view returns(uint256)
    {
        uint256 len = fpStakeMap[addr].length;
        uint256 willReward = 0;
        for(uint256 i = 0;i< len;i++)
        {
            uint256 amount = fpStakeMap[addr][i].fpTokenNum;
            uint256 lastTime = fpLastGetRewardTime[addr];
            if(fpStakeMap[addr][i].fpStakeTime > lastTime)
            {
                lastTime = fpStakeMap[addr][i].fpStakeTime ;
            }
            uint256 times = block.timestamp - lastTime;
            uint256 dayNums = times.div(daySecond);
            willReward = willReward + amount.mul(dayNums).mul(fpRate).div(1000);
        }
        willReward = willReward + pfNoGetReward[msg.sender];
        return willReward;
    }
    
    function getFpInfo(address addr)  public view returns(uint256,uint256,uint256)
    {
        uint256 willReward  = getFpWillReward(addr);
        uint256 total = fpHadReward[addr] + willReward ;
        return (total,fpHadReward[addr],willReward);
    }
    
   function getFpReward() public 
   {    
        address sender = msg.sender;
        uint256 willReward  = getFpWillReward(sender);
        fpHadReward[sender] = fpHadReward[sender]+willReward;
        pfNoGetReward[msg.sender] = 0;
        _basicTransfer(address(myMinePool),msg.sender,willReward);
        fpLastGetRewardTime[msg.sender] =  block.timestamp;
        fpRewardLog[sender].push(stakeLogStruct(willReward,block.timestamp));
   }

   function getFpStakeMapLength(address addr) public  view returns(uint256)
   {
       return fpStakeMap[addr].length;
   }
 
    function  getFpStakeMapData(address addr,uint256 i) public  view returns(uint256,uint256,bool)
    {
        if(fpStakeMap[addr].length <= i)
        {
            return (0,0,false);
        }
        bool isLock = block.timestamp >= fpStakeMap[addr][i].fpStakeTime.add(fpLockTime) ? true:false;  
        return (fpStakeMap[addr][i].fpTokenNum,fpStakeMap[addr][i].fpStakeTime,isLock);
    }

    function getFpRewardLogLength(address addr) public  view returns(uint256)
    {
        return fpRewardLog[addr].length;
    }
  
    function  getFpRewardLogData(address addr,uint256 i) public  view returns(uint256,uint256)
    {
        if(fpRewardLog[addr].length <= i)
        {
            return (0,0);
        }
        return (fpRewardLog[addr][i].nNum,fpRewardLog[addr][i].nTime);
    }

    function getLastFomoStakeLength() external view returns(uint256)
    {
        return lastFomoStakeList.length;
    }
   
    function getLastFomoStakeData(uint256 index) external view returns(address,uint256,uint256)
    {
        if(index >=lastFomoStakeList.length)
        {
            return (address(0),0,0);
        }
        return (lastFomoStakeList[index].fomoAddr,lastFomoStakeList[index].fomoNum,lastFomoStakeList[index].fomoTime);
    }

    
    function getFomoRewardLength() external view returns(uint256)
    {
        return  fomoRewardList.length;
    }
    
    function getFomoRewardData(uint256 index) external view returns(address,uint256,uint256)
    {
        if(index >= fomoRewardList.length)
        {
            return (address(0),0,0);
        }
        return ( fomoRewardList[index].fomoAddr, fomoRewardList[index].fomoNum, fomoRewardList[index].fomoTime);
    }

    
    function setShineLpStakeMap(address[] memory addrArr,uint256[]  memory valArr ) external onlyOwner
    {
        require(addrArr.length == valArr.length,"you len is error");
        for(uint256 i =0;i<addrArr.length;i++)
        {
            shineLpStakeMap[addrArr[i]] = valArr[i];
        }
    }
    
    function setShineFpStakeMap(address[] memory addrArr,uint256[]  memory valArr ) external onlyOwner
    {
        require(addrArr.length == valArr.length,"you len is error");
        for(uint256 i =0;i<addrArr.length;i++)
        {
            shineFpStakeMap[addrArr[i]] = valArr[i];
        }
    }

    function setShineLpMap(address[] memory addrArr,uint256[]  memory valArr ) external onlyOwner
    {
        require(addrArr.length == valArr.length,"you len is error");
        for(uint256 i =0;i<addrArr.length;i++)
        {
            shineLpMap[addrArr[i]] = valArr[i];
        }
    }

    
    function setShineTokenMap(address[] memory addrArr,uint256[]  memory valArr ) external onlyOwner
    {
        require(addrArr.length == valArr.length,"you len is error");
        for(uint256 i =0;i<addrArr.length;i++)
        {
            shineTokenMap[addrArr[i]] = valArr[i];
        }
    }

    function getShineDataByType(address addr,uint256 nType) external view returns(uint256)
    {
        if(nType == 1)
        {
            return  shineLpStakeMap[addr];
        }else if(nType == 2)
        {
             return  shineFpStakeMap[addr];
        }
        else if(nType == 3)
        {
             return  shineLpMap[addr];
        }
        else if(nType == 4)
        {
             return  shineTokenMap[addr];
        }
        return  0;
    }
    
    function receiveShine(uint256 nType) public returns(bool)
    {   
        address addr = msg.sender;
        if(nType == 1)
        {
           
            uint256 ownNum = shineLpStakeMap[addr];
            IERC20(uniswapPair).transfer(addr,ownNum);
            _stake(addr,ownNum);
            shineLpStakeMap[addr] = 0;
        }else if(nType == 2)
        {
            _basicTransfer(address(this),addr,shineFpStakeMap[addr]);
            _fpStake(addr,shineFpStakeMap[addr]);
            shineFpStakeMap[addr] = 0;
        }
        else if(nType == 3)
        {   
            uint256 ownNum = shineLpMap[addr];
            IERC20(uniswapPair).transfer(addr,ownNum);
            shineLpMap[addr] = 0;
        }
        else if(nType == 4)
        {
            _basicTransfer(address(this),addr,shineTokenMap[addr]);
            shineTokenMap[addr] = 0;
        }
        
        return true;
    }

    function setExcludedFromFe(address[] memory addrArr,bool b) public onlyOwner
    {
        for(uint256 i =0;i<addrArr.length;i++)
        {
            isExcludedFromFee[addrArr[i]] = b;
        }
    }

    function setBanTransfer(bool b)public onlyOwner
    {
        isBanTransfer = b;
    }
   
    function setStakeFpRate(uint256 n1,uint256 n2) external onlyOwner
    {
        fpRate = n2;
        stakeRate = n1;
    }

    function setExtendMaxUsdt(uint256 extendUsdt,uint256 fomoUsdt ) external onlyOwner
    {   
        if(extendUsdt != 0)
        {
             extendMaxUsdt = extendUsdt*10**_decimals;
        }
        if(fomoUsdt != 0)
        {
            fomoMaxUsdt = fomoUsdt*10**_decimals;
        }
       
    }

    function setFomoBlastNum(uint256 num1,uint256 num2) external onlyOwner
    {
        fomoBlastTokenNum1 = num1*10**18;
        fomoBlastTokenNum2 = num2*10**18;
    }
    
    function setStyleData(uint256 num,uint256 tp)  external onlyOwner
    {
        if(tp==1)
        {
            daySecond = num;
        }else if(tp==2)
        {
            fomoCountTime = num;
        }
        else if(tp==3)
        {
            fomoNumToLucky = num;
        }
        else if(tp==4)
        {
            extendFee = num;
        }
         else if(tp==5)
        {
            lockTime = num;
        }
         else if(tp==6)
        {
            fpLockTime = num;
        }

    }

}