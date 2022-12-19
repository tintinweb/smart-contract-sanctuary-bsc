/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// File: library/SafeMath.sol


pragma solidity 0.8.17;

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
        if (a == 0) {return 0;}
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
}

// File: interfaces/IBONUSADMIN.sol


pragma solidity 0.8.17;

interface IBONUSADMIN{
    function distribute(uint256 sellFeePool, uint256 buyFeePool, uint256 nodeSellBonus, uint256 raiseSellBonus)external;
}

// File: interfaces/ILPADMIN.sol


pragma solidity 0.8.17;

interface ILPADMIN {
    function doLiquidity()external;
}
// File: interfaces/ISwapRouter.sol


pragma solidity 0.8.17;
interface ISwapRouter {
    function factory() external pure returns (address);

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
// File: interfaces/IFactory.sol


pragma solidity 0.8.17;

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        // function getPair(address tokenA, address tokenB) external view returns (address pair);
}
// File: interfaces/ISwapPair.sol


pragma solidity 0.8.17;

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
}
// File: interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.10;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    // function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: interfaces/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: utils/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: HIVE.sol


pragma solidity 0.8.17;












contract HIVE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string constant private _name = "HIVE Token";
    string constant private _symbol = "HIVE";

    address public _lockAccount;
    bool public _activate;
    address public _lpAdmin;
    address public _bonusAdmin;

    mapping(address => bool) public isFeeExempt; 

    uint256 public nodeBuyBonus = 15;
    uint256 public liquidityBuyBonus = 15 ;

    uint256 public nodeSellBonus = 15;
    uint256 public raiseSellBonus = 20;
    uint256 public liquiditySellBonus = 35;


    uint256 public buyFeePool;
    uint256 public sellFeePool;

    address public router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address public pair;
    address public usdt = 0x758c3B41bc9Af877AFccD8e19e55bB0237E75b95;
    
    uint256 public liquifyThreshold = 100;

    bool private inSwapAndLiquify;

    event Activate(bool indexed activate);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address operateAccount_, address lockAccount_, address liquidityAdmin_, address bonusAdmin_) {
        _lockAccount = lockAccount_;

        pair = IFactory(ISwapRouter(router).factory()).createPair(address(this), usdt);

        // isPair[pair] = true;
        _lpAdmin = liquidityAdmin_;
        _bonusAdmin = bonusAdmin_;

        addFeeExempt(_lpAdmin);
        addFeeExempt(_bonusAdmin);
        addFeeExempt(operateAccount_);

        _allowances[address(this)][router] = type(uint256).max;
        
        IERC20(usdt).approve(router, type(uint256).max);

        _mint(operateAccount_, 150000 * 10 ** decimals());
        _mint(lockAccount_, 850000* 10 ** decimals());
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
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
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function liquidityAdmin()public view returns (address){
        return _lpAdmin;
    }

    function getTokenPrice() public view returns (uint256 price){
        ISwapPair swapPair = ISwapPair(pair);
        (uint256 reserve0,uint256 reserve1,) = swapPair.getReserves();
        address token = address(this);
        if (reserve0 > 0) {
            uint256 usdtAmount;
            uint256 tokenAmount;
            if (token < usdt) {
                tokenAmount = reserve0;
                usdtAmount = reserve1;
            } else {
                tokenAmount = reserve1;
                usdtAmount = reserve0;
            }
            price = 10 ** IERC20(token).decimals() * usdtAmount / tokenAmount;
        }
    }


    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), "HIVE: TRANSFER_FAILED");
    }

   function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }
        return _transfer(sender, recipient, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(checkedAccount(sender),"85% of the funds have not been unlocked");
        

        if (isFeeExempt[sender] || isFeeExempt[recipient]) {
            return _basicTransfer(sender, recipient, amount);
            }

        _balances[sender] = _balances[sender].sub(amount);

        uint256 finalAmount = recipient == pair || sender == pair ? extractFee(sender, recipient, amount) : amount;
        //Exchange tokens

        _balances[recipient] =_balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function extractFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 feeLpAdmin;
        uint256 feeBonusAdmin;

        if (recipient == pair){
            feeLpAdmin = amount.mul(liquiditySellBonus).div(1000);
            feeBonusAdmin =  amount.mul(nodeSellBonus.add(raiseSellBonus)).div(1000);

            sellFeePool = sellFeePool.add(feeBonusAdmin);
            
        }else{
            feeLpAdmin = amount.mul(liquidityBuyBonus).div(1000);
            feeBonusAdmin =  amount.mul(nodeBuyBonus).div(1000);

            buyFeePool = buyFeePool.add(feeBonusAdmin);


        }

            _balances[_lpAdmin] = _balances[_lpAdmin].add(feeLpAdmin);

            emit Transfer(sender, _lpAdmin, feeLpAdmin);

            _balances[_bonusAdmin] = _balances[_bonusAdmin].add(feeBonusAdmin);

            emit Transfer(sender,_bonusAdmin, feeBonusAdmin);

            return amount.sub(feeLpAdmin).sub(feeBonusAdmin);
 
    }

    function settlement()public {
        if (_balances[_lpAdmin] > liquifyThreshold){
             ILPADMIN(_lpAdmin).doLiquidity();
        }

        IBONUSADMIN(_bonusAdmin).distribute(sellFeePool, buyFeePool, nodeSellBonus, raiseSellBonus);
       
        buyFeePool = 0;
        sellFeePool = 0;

    }

   
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function activation()external onlyOwner{
        _activate = !_activate;

        emit Activate(_activate);
    }

    function checkedAccount(address account_)internal view returns(bool){
        if(account_ == _lockAccount){
            if (_activate){
                return true;
            }else{
                return false;
            }
        } else{
            return true;
         }
    }


    function addFeeExempt(address account_ )public onlyOwner{
        isFeeExempt[account_] = true;
    }


    function setNodeBuyBonus(uint256 bonus_)external onlyOwner{
        nodeBuyBonus = bonus_;
    }

    function setLiquidityBuyBonus(uint256 bonus_)external onlyOwner{
        liquidityBuyBonus = bonus_;
    }

    function setNodeSellBonus(uint256 bonus_)external onlyOwner{
        liquidityBuyBonus = bonus_;
    }

    function setRaiseSellBonus(uint256 bonus_)external onlyOwner{
        liquidityBuyBonus = bonus_;
    }

    function setLiquiditySellBonus(uint256 bonus_)external onlyOwner{
        liquidityBuyBonus = bonus_;
    }


    function setbonusAdmin(address bonusAdmin_)external onlyOwner{
        _bonusAdmin = bonusAdmin_;
    }


    function setLiquidityAdmin(address liquidityAdmin_)external onlyOwner{
        _lpAdmin = liquidityAdmin_;
    }

    function withdrawToken(address token, address to)external onlyOwner{
        uint256 amount = IERC20(token).balanceOf(address(this));
        _safeTransfer(token, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
    unchecked {
        // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
        _balances[account] += amount;
    }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
        // Overflow not possible: amount <= accountBalance <= totalSupply.
        _totalSupply -= amount;
    }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
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

}