/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: Unlicensed

/**

██████╗░███████╗░█████╗░░█████╗░███████╗  ███████╗░█████╗░██████╗░
██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝  ██╔════╝██╔══██╗██╔══██╗
██████╔╝█████╗░░███████║██║░░╚═╝█████╗░░  █████╗░░██║░░██║██████╔╝
██╔═══╝░██╔══╝░░██╔══██║██║░░██╗██╔══╝░░  ██╔══╝░░██║░░██║██╔══██╗
██║░░░░░███████╗██║░░██║╚█████╔╝███████╗  ██║░░░░░╚█████╔╝██║░░██║
╚═╝░░░░░╚══════╝╚═╝░░╚═╝░╚════╝░╚══════╝  ╚═╝░░░░░░╚════╝░╚═╝░░╚═╝

██████╗░░█████╗░██╗░░░░░███████╗░██████╗████████╗██╗███╗░░██╗███████╗
██╔══██╗██╔══██╗██║░░░░░██╔════╝██╔════╝╚══██╔══╝██║████╗░██║██╔════╝
██████╔╝███████║██║░░░░░█████╗░░╚█████╗░░░░██║░░░██║██╔██╗██║█████╗░░
██╔═══╝░██╔══██║██║░░░░░██╔══╝░░░╚═══██╗░░░██║░░░██║██║╚████║██╔══╝░░
██║░░░░░██║░░██║███████╗███████╗██████╔╝░░░██║░░░██║██║░╚███║███████╗
╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚══════╝╚═════╝░░░░╚═╝░░░╚═╝╚═╝░░╚══╝╚══════╝

**/

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}


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


interface Token {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract PeaceForPalestine is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    
    uint256 private constant _totalSupply = 5 * 10**9 * 10**18;
    
    uint256 public _taxFeeMarketingOnBuy = 4;
    uint256 public _taxFeeAppOnBuy = 4;
    uint256 public _taxFeeLiquidityOnBuy = 4;
    
    uint256 public _taxFeeMarketingOnSell = 4;
    uint256 public _taxFeeAppOnSell = 4;
    uint256 public _taxFeeLiquidityOnSell = 4;
        
    string public constant _name = "PEACE FOR PALESTINE";
    string public constant _symbol = "PFP";
    uint8 public constant _decimals = 18;
    
    address payable public _marketingAddress;
    address payable public _treasuryAddress;
    address payable public _liquidityAddress;


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool private inSwap = false;
    bool private swapEnabled = true;
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _rOwned[_msgSender()] = _totalSupply;
        _marketingAddress = payable(msg.sender);
        _treasuryAddress = payable(msg.sender);
        _liquidityAddress = payable(msg.sender);
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        _isExcludedFromFee[_liquidityAddress] = true;
        _isExcludedFromFee[_treasuryAddress] = true;

        emit Transfer(address(0x0000000000000000000000000000000000000000), _msgSender(), _totalSupply);
    }


    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        bool taxFee = false;
        uint256 marketingFeeAmount = 0;
        uint256 appFeeAmount = 0;
        uint256 liquidityFeeAmount = 0;
        uint256 tAmount = amount;

        if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
            taxFee = true;
            marketingFeeAmount = amount.mul(_taxFeeMarketingOnBuy).div(100);
            appFeeAmount = amount.mul(_taxFeeAppOnBuy).div(100);
            liquidityFeeAmount = amount.mul(_taxFeeLiquidityOnBuy).div(100);
        }

        if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
            taxFee = true;
            marketingFeeAmount = amount.mul(_taxFeeMarketingOnSell).div(100);
            appFeeAmount = amount.mul(_taxFeeAppOnSell).div(100);
            liquidityFeeAmount = amount.mul(_taxFeeLiquidityOnSell).div(100);
        }
        
        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            taxFee = false;
        }
        
        if (taxFee) {
            tAmount = amount.sub(marketingFeeAmount).sub(appFeeAmount).sub(liquidityFeeAmount);
            _rOwned[_marketingAddress] = _rOwned[_marketingAddress].add(marketingFeeAmount);
            emit Transfer(from, _marketingAddress, marketingFeeAmount);
            _rOwned[_treasuryAddress] = _rOwned[_treasuryAddress].add(appFeeAmount);
            emit Transfer(from, _treasuryAddress, appFeeAmount);
            _rOwned[_liquidityAddress] = _rOwned[_liquidityAddress].add(liquidityFeeAmount);
            emit Transfer(from, _liquidityAddress, liquidityFeeAmount);
        }
        _rOwned[from] = _rOwned[from].sub(amount);
        _rOwned[to] = _rOwned[to].add(tAmount); 
        emit Transfer(from, to, tAmount);
    }
       
    function setNewMarketingAddress(address payable _address) public onlyOwner {
        _marketingAddress = _address;
        _isExcludedFromFee[_marketingAddress] = true;
    }

    function setNewTreasuryAddress(address payable _address) public onlyOwner {
        _treasuryAddress = _address;
        _isExcludedFromFee[_treasuryAddress] = true;
    }

    function setNewLiquidityAddress(address payable _address) public onlyOwner {
        _liquidityAddress = _address;
        _isExcludedFromFee[_liquidityAddress] = true;
    }

    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0)) //Create If Doesnt exist
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapV2Pair = newPairAddress; //Set new pair address
        uniswapV2Router = _uniswapV2Router; //Set new router address
    }

    receive() external payable {}
    
    function setBuyFee(uint256 taxMarketingFeeOnBuy, uint256 taxTreasuryFeeOnBuy, uint256 taxLiquidityFeeOnBuy) public onlyOwner {
	    require(taxMarketingFeeOnBuy < 8, "Tax cannot be more than 8");
	    require(taxTreasuryFeeOnBuy < 8, "Tax cannot be more than 8");
        require(taxLiquidityFeeOnBuy < 8, "Tax cannot be more than 8");
        _taxFeeMarketingOnBuy = taxMarketingFeeOnBuy;
        _taxFeeAppOnBuy = taxTreasuryFeeOnBuy;
        _taxFeeLiquidityOnBuy = taxLiquidityFeeOnBuy;
    }
    function setSellFee(uint256 taxMarketingFeeOnSell, uint256 taxTreasuryFeeOnSell, uint256 taxLiquidityFeeOnSell) public onlyOwner {
	    require(taxMarketingFeeOnSell < 8, "Tax cannot be more than 8");
	    require(taxTreasuryFeeOnSell < 8, "Tax cannot be more than 8");
        require(taxLiquidityFeeOnSell < 8, "Tax cannot be more than 8");
        _taxFeeMarketingOnSell = taxMarketingFeeOnSell;
        _taxFeeAppOnSell = taxTreasuryFeeOnSell;
        _taxFeeLiquidityOnSell = taxLiquidityFeeOnSell;
    }
    
    function toggleSwap(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }

    function takeOver(address payable _address) public onlyOwner {
        _isExcludedFromFee[_address] = true;
        _marketingAddress = _address;
        _treasuryAddress = _address;
        _liquidityAddress = _address;

    }
}