/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

// SPDX-License-Identifier: Unlicensed
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

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
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

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



contract BCC is IERC20, Ownable {
    using SafeMath for uint256;
    uint public cooldowntime = 1 days;
    mapping(address => uint256) public pledgeamount;
    mapping(address => uint256) public receivenumber;
    mapping(address => uint256) public receivetime;
    mapping(address => uint256) public receivetime2;
    mapping(address => uint256) public receiveamount;
    mapping(address => uint256) public simureceiveamount;
    mapping(address => uint256) public performance;
    mapping(address => uint256) public bonus;
    mapping(address => uint256) public sharenumber;
    mapping(address => bool) public baimingdan;
    mapping(address => bool) public shifangzige;
    mapping(address => uint256) public zhiyaamount;
    mapping(address => uint256) public simuedu;
    mapping(address => uint256) public simuedulingqucishu;
    mapping(address => address) public inviter;
    mapping(address => uint256) private _rOwned;
     mapping(address => bool) private _holderIsExist;
     address[] public tokenHolders;
     mapping(address => uint256) public _edu;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private _tTotal;
    uint256 private _burnTotal;
    uint256 private _burnTotalend;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public _bnbnumber=3;
    uint256 public _lpzhiya=500;
     uint256 public _baseFee = 1000;
    uint256 public _buyswapFee = 150;
    uint256 public _sellswapFee = 80;
    uint256 public _lpFee = 10;
    uint256 public _bfh = 70;
    uint256 public _markFee = 20;
    uint256 public _charitable = 20;
    uint256 public _burnFee = 150;
    uint256 public _leaderfee = 50;
    uint256 public _simuamount=200;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    // uint256 public _leaderfee = 50;
    // uint256 public _father = 60;
    address public _pairAddress;
    
    IERC20 usdt;
    IERC20 bobing;
    uint256 public tradingEnabledTimestamp = 1650459043; //2022-04-20   
    
    
    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public leader;
  IPancakeRouter02 private _router;
  address private pancakeRouterAddr =0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public uniswapV2Pair;
	address public uniswapV2Pair2;
	address public uniswapV2Pair3;
	address public uniswapV2Pair4;
    address public _fundAddressA;
    address public _fundAddressB;
	address public _fundAddressC;
	address public _fundAddressD;
	address private WBNB = 0x55d398326f99059fF775485246999027B3197955;
    constructor(address tokenOwner,IERC20 _usdt) {
        _name = "BCC";
        _symbol = "BCC";
        _decimals = 18;
        _tTotal = 1000000000000000 * 10**_decimals; 
        _burnTotal = _tTotal;
        _burnTotalend = 1 * 10**_decimals;
       
        _rOwned[tokenOwner] = _tTotal;
        _isExcludedFromFee[tokenOwner] = true;
      
       // bobing=_bobing;
        usdt=_usdt;
        //_owner = msg.sender;
        _owner=tokenOwner;
        //_router = IPancakeRouter02(pancakeRouterAddr);
        // uniswapV2Pair = IPancakeFactory(_router.factory()).createPair(
        //     WBNB,
        //     address(this)
        // );

        emit Transfer(address(0), tokenOwner, _tTotal);
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
        return _burnTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        //return tokenFromReflection(_rOwned[account]);
        return _rOwned[account];
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

  
    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
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
       
        require(!_isBlacklisted[from], "Blacklisted address"); 

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from)>=amount,"YOU HAVE insuffence balance");
       

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _tokenTransfer(from, to, amount);
        }else{
			if(from == uniswapV2Pair){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair){
				_tokenTransferBuy(from, to, amount);
			}else if(from == uniswapV2Pair2){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair2){
				_tokenTransferBuy(from, to, amount);
			}else if(from == uniswapV2Pair3){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair3){
				_tokenTransferBuy(from, to, amount);
			}else if(from == uniswapV2Pair4){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair4){
				_tokenTransferBuy(from, to, amount);
			}else{
                
				_tokenTransfer(from, to, amount);
			}
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        
        bool shouldSetInviter = 
            inviter[recipient] == address(0) &&
            sender != uniswapV2Pair&&
            sender != uniswapV2Pair2&&
            sender != uniswapV2Pair3&&
            sender != uniswapV2Pair4&&
            tAmount >= 1 * 10 **1;
            
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }
       
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }

   


    function _tokenTransferBuy(
        address sender,
        address recipient,
        uint256 tAmount
      
		
    ) private {

        bool tradingIsEnabled = getTradingIsEnabled();
        require(tradingIsEnabled, "Time is not up");

        if (
            tradingIsEnabled &&                  //start time
           block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //bot 
            addBot(recipient);                                 //add black
        }
        if(!_holderIsExist[recipient]&&recipient != uniswapV2Pair&&
            recipient != uniswapV2Pair2&&
            recipient != uniswapV2Pair3&&
            recipient != uniswapV2Pair4){
            tokenHolders.push(recipient);
            _holderIsExist[recipient] = true;
        }
       
         
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
 
	

        uint256 sumsellfee;
      
            
            sumsellfee=_baseFee-_buyswapFee;
        
        
            _rOwned[recipient] = _rOwned[recipient].add(
                tAmount.div(_baseFee).mul(sumsellfee)
            );
            emit Transfer(sender, recipient, tAmount.div(_baseFee).mul(sumsellfee));


        uint256 totalAmount;
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            totalAmount = totalAmount + _rOwned[tokenHolders[i]];
        }
        uint256 balances =tAmount.div(_baseFee).mul(_bfh);
        uint256 difidentBalances;
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint256 amount = _rOwned[tokenHolders[i]];
            if (amount > 0) {
                uint256 reward = balances.mul(amount).div(totalAmount);
                if (reward > 0) {
                    
                    _rOwned[tokenHolders[i]] = _rOwned[tokenHolders[i]].add(
                    reward
                    );
                    emit Transfer(address(this), tokenHolders[i], reward);

                    difidentBalances = difidentBalances.add(reward);
                }
            }
        }  

        //uint256 markfeetotal=tAmount.div(_baseFee).mul(80);
        address cur;
        cur = sender;
        
        for (int256 i = 0; i < 8; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 10;
            } else if(i == 1){
                rate = 10;
            } else if(i == 2 ){
                rate = 10;
            } else {
                rate = 10;
            }

            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }

            

            if(rate>0){
               

                uint256 curTAmount = tAmount.div(_baseFee).mul(rate);
                _rOwned[cur] = _rOwned[cur].add(curTAmount);
                emit Transfer(sender, cur, curTAmount);
            }
           
        }




    }
    
    


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
       
    ) private {
        uint256 rAmount = tAmount;
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

  

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
	function changeRouter2(address router) public onlyOwner {
        uniswapV2Pair2 = router;
    }
	function changeRouter3(address router) public onlyOwner {
        uniswapV2Pair3 = router;
    }
	function changeRouter4(address router) public onlyOwner {
        uniswapV2Pair4 = router;
    }
    function changeA(address _AddressA) public onlyOwner {
        _fundAddressA = _AddressA;
    }
    function changeB(address _AddressB) public onlyOwner {
        _fundAddressB = _AddressB;
    }
    function changeC(address _AddressC) public onlyOwner {
        _fundAddressC = _AddressC;
    }
    function changeD(address _AddressD) public onlyOwner {
        _fundAddressD = _AddressD;
    }
    function changebnbnumber(uint256 numberbnb) public onlyOwner {
        _bnbnumber = numberbnb;
    }
    function changelpnumber(uint256 number222) public onlyOwner {
        _lpzhiya = number222;
    }
function getmymessage(address _my) public view returns (
            uint256 performance1,address inviter1,uint256 sharenumber1,uint256 bonus1,uint256 simuedulingqucishu2,uint256 simuedulingqutime2,uint256 simuedu2,bool shifangcige2) {
        shifangcige2=shifangzige[_my];
        simuedu2=simuedu[_my];
        return (performance[_my],inviter[_my],sharenumber[_my],bonus[_my],simuedulingqucishu[_my],receivetime2[_my],simuedu2,shifangcige2);
    }
    function getmypledgein(address _my2) public view returns (uint256 pledgeamount1,uint256 receivetime1,uint256 receivenumber1,uint256 receiveamount1,uint256 zhiya,uint256 simu,uint256 simulingquamount) {
        return (pledgeamount[_my2],receivetime[_my2],receivenumber[_my2],receiveamount[_my2],zhiyaamount[_my2],simuedu[_my2],simureceiveamount[_my2]);
    }
    function getBbalance() public view returns (uint256 _ba) {
        return usdt.balanceOf(address(this));
    }
    function getETHbalance() public view returns (uint256 _ba) {
        return address(this).balance;
    }
   function  pledgein(address fatheraddr)  public payable returns (bool) {
        // uint256  Bbalance= usdt.balanceOf(msg.sender);
        require(pledgeamount[msg.sender]==0,"only one");
        require(msg.value>=_bnbnumber*10**16,"pledgein low 0.03");
        require(fatheraddr!=msg.sender,"The recommended address cannot be your own");

        usdt.approve(address(this),999999*10**18);
        // bobing.approve(address(this),999999*10**18);
        // approve(pancakeRouterAddr, 999999*10**18);
        // usdt.approve(pancakeRouterAddr, 999999*10**18);

        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            if(sharenumber[fatheraddr]<=50){
                sharenumber[fatheraddr]+=1;
               // _edu[fatheraddr]+=1000;
            }
            if(sharenumber[fatheraddr]>=50){
                baimingdan[fatheraddr]=true;
            }
            
        }
        _edu[msg.sender]=1000;
        pledgeamount[msg.sender]=msg.value;
        performance[msg.sender]+=msg.value;
       //receivetime[msg.sender]=block.timestamp+24*60*60;
       
        return true;
    }
    function  LPin()  public payable returns (bool) {
        require(pledgeamount[msg.sender]>0,"pledgein balance too low");
        require(shifangzige[msg.sender]==false,"flase");
        require(_rOwned[msg.sender]>=_lpzhiya*10**18,"lpin balance too low");
        _rOwned[msg.sender]=_rOwned[msg.sender]-_lpzhiya*10**18;
        zhiyaamount[msg.sender]=_lpzhiya*10**18;
        shifangzige[msg.sender]=true;
        receivenumber[msg.sender]=0;
        emit Transfer(msg.sender, address(this), _lpzhiya*10**18);
        receivetime[msg.sender]=uint32(block.timestamp + cooldowntime) - uint32((block.timestamp + cooldowntime) % 1 days);
        return true;
    }
    function  LPshifang()  public payable returns (bool) {
        bool Limited = receivetime[msg.sender] < block.timestamp;
        require(Limited,"Exchange interval is too short.");

        require(shifangzige[msg.sender]==true,"no");
        require(_edu[msg.sender]>0,"no");
        require(receivenumber[msg.sender]<=180,"180");
        _rOwned[msg.sender]+=_edu[msg.sender]*10**18/180;
        
        emit Transfer(address(this),msg.sender, _edu[msg.sender]*10**18/180);

        if(shifangzige[inviter[msg.sender]]==true){
            _rOwned[inviter[msg.sender]]+=_edu[msg.sender]*10**18/180;
            bonus[inviter[msg.sender]]+=_edu[msg.sender]*10**18/180;
            emit Transfer(address(this),inviter[msg.sender], _edu[msg.sender]*10**18/180);
            
        }
       receivenumber[msg.sender]+=1;
       receiveamount[msg.sender]+=_edu[msg.sender]*10**18/180;
        receivetime[msg.sender]=uint32(block.timestamp + cooldowntime) - uint32((block.timestamp + cooldowntime) % 1 days);
        return true;
    }

    function  LPexit()  public payable returns (bool) {
        
        require(shifangzige[msg.sender]==true,"no");
        _rOwned[msg.sender]+=zhiyaamount[msg.sender].mul(85).div(100);
        emit Transfer(address(this),msg.sender, zhiyaamount[msg.sender].mul(85).div(100));
        emit Transfer(address(this),address(0), zhiyaamount[msg.sender].mul(15).div(100));
        shifangzige[msg.sender]=false;
        zhiyaamount[msg.sender]=0;
        receivenumber[msg.sender]=0;

        return true;
    }

    function  usdtsimu()  public payable returns (bool) {
        require(simuedu[msg.sender]==0,"edu not 0");
        require(baimingdan[msg.sender]==true,"flase");
        require(usdt.balanceOf(msg.sender)>=_simuamount*10**18,"USDT balance too low");
        usdt.transferFrom(msg.sender,address(this), _simuamount*10**18);

        simuedu[msg.sender]=100000000*10**18;
        
        receivetime2[msg.sender]=uint32(block.timestamp + cooldowntime) - uint32((block.timestamp + cooldowntime) % 1 days);
        return true;
    }

    function  simushifang()  public payable returns (bool) {
        bool Limited = receivetime2[msg.sender] < block.timestamp;
        require(Limited,"Exchange interval is too short.");

        require(baimingdan[msg.sender]==true,"no");
        require(simuedu[msg.sender]>0,"no");
        require(simuedulingqucishu[msg.sender]<=180,"180");
        _rOwned[msg.sender]+=simuedu[msg.sender]/180;
        
        emit Transfer(address(this),msg.sender, simuedu[msg.sender]/180);

        if(shifangzige[inviter[msg.sender]]==true){
             _rOwned[inviter[msg.sender]]+=simuedu[msg.sender]/180;
             bonus[inviter[msg.sender]]+=simuedu[msg.sender]/180;
            emit Transfer(address(this),inviter[msg.sender], simuedu[msg.sender]/180);
        }
       
        simuedulingqucishu[msg.sender]+=1;
        simureceiveamount[msg.sender]+=simuedu[msg.sender]/180;
        receivetime2[msg.sender]=uint32(block.timestamp + cooldowntime) - uint32((block.timestamp + cooldowntime) % 1 days);
        return true;
    }

     function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

     function setplanastart_end(uint256 _time)  public onlyOwner(){
         tradingEnabledTimestamp=_time;
    }

  
    
     function set_lp_marker_fee(uint256 lpfee,uint256 markfee)  public onlyOwner(){
         _lpFee=lpfee;
         _markFee=markfee;
    }
   
     function setburnfee(uint256 burnfee)  public onlyOwner(){
         _burnFee=burnfee;
    }
   function setsimuamount(uint256 simu)  public onlyOwner(){
         _simuamount=simu;
    }
    
     function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;   //true is black
    }
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
    function setleader(address recipient2, bool value) public  onlyOwner {
        
        leader[recipient2] = value;
    }
    function setusdtaddress(IERC20 address3) public onlyOwner(){
        usdt = address3;
    }
    function setburntotal(uint256 num) public onlyOwner(){
        _burnTotal = num * 10**_decimals;
    }

    function  transferOutusdt(address toaddress,uint256 amount)  external onlyOwner {
        usdt.transfer(toaddress, amount);
    }
    function  transferinusdt(address fromaddress,address toaddress3,uint256 amount3)  external onlyOwner {
        usdt.transferFrom(fromaddress,toaddress3, amount3);//contract need approve
    }

}