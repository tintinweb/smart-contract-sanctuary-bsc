/**
 *Submitted for verification at BscScan.com on 2022-12-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-15
 website:-https://itstradable.info
 telegram: 
*/
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)

pragma solidity  >=0.4.22 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
       // }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
      //  }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
       // }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
       // }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
       // unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
      //  }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
       // unchecked {
            require(b <= a, errorMessage);
            return a - b;
       // }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
       // unchecked {
            require(b > 0, errorMessage);
            return a / b;
        //}
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
       // unchecked {
            require(b > 0, errorMessage);
            return a % b;
       // }
    }
}
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "N-OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
        authorizations[owner] = true;
        emit OwnershipTransferred(owner);
    }

    event OwnershipTransferred(address owner);
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDEXRouter {
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


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
}
//import the uniswap router
//the contract needs to use swapExactTokensForTokens
//this will allow us to import swapExactTokensForTokens into our contract


contract StandardITSTradableContract is Context, IERC20, IERC20Metadata, Auth {

    using SafeMath for uint256;

    string public _name= "";
    string public _symbol = "";
    string public _tg= "";
    string public _website = "";


    uint256 private _totalSupply;
    uint256 public HODLER_TAX_FEE = 5;
    uint256 lastSellTime = 0;   
    uint256 public swapThreshold;
    uint256 transferCount = 1;
    uint256 swapRatio = 40;
    uint256 marketingBuyFee;
    uint256 liquidityBuyFee;
    uint256 devBuyFee;
    uint256 public totalBuyFee = marketingBuyFee.add(liquidityBuyFee).add(devBuyFee);
    uint256 marketingSellFee;
    uint256 liquiditySellFee;
    uint256 devSellFee;
    uint256 public totalSellFee = marketingSellFee.add(liquiditySellFee).add(devSellFee);
    uint256 marketingFee = marketingBuyFee.add(marketingSellFee);
    uint256 liquidityFee = liquidityBuyFee.add(liquiditySellFee);
    uint256 devFee = devBuyFee.add(devSellFee);
    uint256 totalFee = liquidityFee.add(marketingFee).add(devFee);
    uint private unlocked = 1;

    IDEXRouter public router;
    IDEXFactory public factory;

    address internal fiat;
    address public marketingWallet;
    address internal devWal;
    address internal deploywal;
    address public liquidityWallet;
    address public ownerAddr;   

    bool inSwap;

    modifier swapping() { inSwap = true; _; inSwap = false; }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) public _allowances;

 

    constructor(address[] memory account, uint[] memory amount, string[] memory names) Auth(_msgSender())  {
        
        require(account[0] != address(0), "ERC20: mint to the zero address");

        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            
        _name = names[0];
        _symbol = names[1];
        _tg = names[3];
        _website = names[2];
        string memory _fiat = names[4];
        if (keccak256(abi.encodePacked(_fiat)) == keccak256("WBNB")){
            fiat = router.WETH();//0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        } else  if (keccak256(abi.encodePacked(_fiat)) == keccak256("USDT")){
            fiat = 0x55d398326f99059fF775485246999027B3197955;
        } else  if (keccak256(abi.encodePacked(_fiat)) == keccak256("BUSD")){
            fiat = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        }
        IDEXFactory(router.factory()).createPair(fiat,address(this));
        swapThreshold = _totalSupply.mul(50).div(1000); //5 %

        marketingBuyFee = amount[2];
        liquidityBuyFee = amount[4];
        devBuyFee = amount[6];

        totalBuyFee = marketingBuyFee.add(liquidityBuyFee).add(devBuyFee);
        require(totalBuyFee <= 100, "Buy tax too high!"); //10% buy tax

        marketingSellFee = amount[3];
        liquiditySellFee = amount[5];
        devSellFee = amount[7];
        

        totalSellFee = marketingSellFee.add(liquiditySellFee).add(devSellFee);
        require(totalSellFee <= 100, "Sell tax too high!"); //10% sell tax

        marketingFee = marketingBuyFee.add(marketingSellFee);
        liquidityFee = liquidityBuyFee.add(liquiditySellFee);
        devFee = devBuyFee.add(devSellFee);

        totalFee = liquidityFee.add(marketingFee).add(devFee);

        require(amount[1]<=100,"Dev Hold Greater than 10%");
        uint devHodl = amount[1];
        uint tokenSupply = amount[0]*(10**18);
        uint devHoldAmt = tokenSupply.mul(devHodl).div(1000);
        uint deployAmt = tokenSupply.sub(devHoldAmt);

        deploywal = account[0];
        devWal = account[1];
        marketingWallet = account[2];
        liquidityWallet = address(this);

        //_beforeTokenTransfer(address(0), account[0], amount[0]);
        _totalSupply = tokenSupply;
        _balances[deploywal] = deployAmt;
        emit Transfer(address(0), deploywal, deployAmt);
       // _afterTokenTransfer(address(0), account[0], amount[0]);
        _balances[devWal] = devHoldAmt;
        emit Transfer(address(0), devWal, devHoldAmt);

        renounceOwnership();

    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }

//["New Year Inu","NYI","https://itstradable.info/","https://t.me/happyNewYearInu"]
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function Website() public view virtual  returns (string memory) {
        return _website;
    }

    function Telegram() public view virtual  returns (string memory) {
        return _tg;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

  
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    
 

   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

 
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
   
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
       // unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
       // }

        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        //unchecked {
            _balances[account] = accountBalance - amount;
       // }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (owner == msg.sender){
            return _basicTransfer(msg.sender, recipient, amount);
        }
        else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
    function setWallets(address _marketingWallet, address _devWallet) external authorized {
        marketingWallet = _marketingWallet;
        devWal = _devWallet;
    }
    function setBuyFees(uint256 _marketingFee, uint256 _liquidityFee, 
                    uint256 _devFee) external authorized{
        require((_marketingFee.add(_liquidityFee).add(_devFee)) <= 100);
        require(marketingSellFee.add(_marketingFee)>=10);
        marketingBuyFee = _marketingFee;
        liquidityBuyFee = _liquidityFee;
        devBuyFee = _devFee;

        marketingFee = marketingSellFee.add(_marketingFee);
        liquidityFee = liquiditySellFee.add(_liquidityFee);
        devFee = devSellFee.add(_devFee);

        totalBuyFee = _marketingFee.add(_liquidityFee).add(_devFee);
        totalFee = liquidityFee.add(marketingFee).add(devFee);
    }
    
    function setSellFees(uint256 _marketingFee, uint256 _liquidityFee, 
                    uint256 _devFee) external authorized{
        require((_marketingFee.add(_liquidityFee).add(_devFee)) <= 100);
        require(marketingBuyFee.add(_marketingFee)>=10);
        marketingSellFee = _marketingFee;
        liquiditySellFee = _liquidityFee;
        devSellFee = _devFee;

        marketingFee = marketingBuyFee.add(_marketingFee);
        liquidityFee = liquidityBuyFee.add(_liquidityFee);
        devFee = devBuyFee.add(_devFee);

        totalSellFee = _marketingFee.add(_liquidityFee).add(_devFee);
        totalFee = liquidityFee.add(marketingFee).add(devFee);
    }
    function getPair(address token,address xfiat) internal view returns(address) {
        return IDEXFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).getPair(xfiat, token);
    }
    function takeFee(address sender, address recipient,address pair, uint256 amount) internal returns (uint256) {

        uint256 _totalFee;

        _totalFee = (recipient == pair) ? totalSellFee : totalBuyFee;

        uint256 feeAmount = amount.mul(_totalFee).div(1000);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }
    function shouldTokenSwap(uint256 amount, address recipient) internal view returns (bool) {

            bool timeToSell = lastSellTime.add(1) < block.timestamp;

            return recipient == getPair(address(this), fiat)
            && timeToSell
            && _balances[address(this)] >= swapThreshold
            && _balances[address(this)] >= amount.mul(swapRatio).div(100);
    }
    function tokenSwap(uint256 _amount) internal swapping {

        uint256 amount = _amount.mul(swapRatio).div(100);
        //0.5% buy and sell, both sets of taxes added together in swap
        uint256 tokerr = 10;

        (amount > swapThreshold) ? amount : amount = swapThreshold;

        uint256 amountToLiquify = (liquidityFee > 0) ? amount.mul(liquidityFee).div(totalFee).div(2) : 0;

        uint256 amountToSwap = amount.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        bool tmpSuccess;

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = (liquidityFee > 0) ? totalFee.sub(liquidityFee.div(2)) : totalFee;
        

        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        if (devFee > 0){
            uint256 amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);
            
            (tmpSuccess,) = payable(devWal).call{value: amountBNBDev, gas: 100000}("");
            tmpSuccess = false;
        }

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
        //after other fees are allocated, tokerrFee is calculated and taken before marketing
        uint256 tokerrFee = amountBNB.mul(tokerr).div(totalBNBFee);
        (tmpSuccess,) = payable(devWal).call{value: tokerrFee, gas: 100000}("");
        tmpSuccess = false;

        uint256 amountBNBMarketing = address(this).balance;
        if(amountBNBMarketing > 0){
            (tmpSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: 100000}("");
            tmpSuccess = false;
        }

        lastSellTime = block.timestamp;
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        address pair = getPair(address(this), fiat);
        if (authorizations[sender] || authorizations[recipient]){
            return _basicTransfer(sender, recipient, amount);
        }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }


        if(shouldTokenSwap(amount, recipient)){ tokenSwap(amount); }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = (recipient == pair || sender == pair) ? takeFee(sender, recipient,pair, amount) : amount;


        

        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        if ((sender == pair || recipient == pair) && recipient != address(this)){
            transferCount += 1;
        }
        
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
     receive() external payable {
       // assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }
     event AutoLiquify(uint256 amountBNB, uint256 amountCoin);
}
interface iITTFactory {
    function createToken(address[] memory account, uint[] memory amount, string[] memory names) external returns(uint256);
    function getTokeAddress(uint ID) external returns(address);
    function addLiquidity(string memory fiat, uint amount, uint IDs) external returns(bool);
}

contract ITTFactory is iITTFactory {
    StandardITSTradableContract itt;
    mapping (uint256 => address) public contracts;
    uint256 public ID = 10000;
    address internal fiat = address(0xdead);
    IDEXRouter public router;
    IDEXFactory public factory;
    constructor() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }
    function createToken(address[] memory account, uint[] memory amount, string[] memory names) external override returns (uint256) {
        itt = new StandardITSTradableContract(account,amount,names);
        contracts[ID] = address(itt);

        ID+=1;

        return ID;
    }

    function getTokeAddress(uint256 IDs) external view override returns(address) {
        return contracts[IDs];
    }

    function addLiquidity(string memory _fiat, uint256 amountToLiquify, uint256 IDs) external override returns(bool) {

        if (keccak256(abi.encodePacked(_fiat)) == keccak256("WBNB")){
            fiat = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        } else  if (keccak256(abi.encodePacked(_fiat)) == keccak256("USDT")){
            fiat = 0x55d398326f99059fF775485246999027B3197955;
        } else  if (keccak256(abi.encodePacked(_fiat)) == keccak256("BUSD")){
            fiat = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        }
        address tokenAdd = contracts[IDs];
        uint256 otherFiat = IERC20(fiat).balanceOf(address(this));
        if (amountToLiquify > 0) {
            if (keccak256(abi.encodePacked(_fiat)) == keccak256("WBNB")) {
                router.addLiquidityETH{value: address(this).balance}(
                    tokenAdd,
                    amountToLiquify,
                    0,
                    0,
                    tokenAdd,
                    block.timestamp
                );
            } else {
                router.addLiquidity(
                    fiat,
                    tokenAdd,
                    otherFiat,
                    amountToLiquify,
                    0,
                    0,
                    tokenAdd,
                    block.timestamp
                );
            }            
        }

        return true;

    }
}