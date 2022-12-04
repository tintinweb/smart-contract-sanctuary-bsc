/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/**
 * @dev collections of functions ralted to the address type
 */
library Address {
    
    /**
     * @dev returns true if `account` is a contract
     */
    function isContract(address account) internal view returns(bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly{
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
    
    /**
     * @dev replacement for solidity's `transfer`: sends `amount` wei to `recipient`,
     * forwarding all available gas and reverting on errors;
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance.");
        
        (bool success,) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted.");
    }
    
    /**
     * @dev performs a solidity function call using a low level `call`. A plain `call` is an
     * unsafe replacement for a function call: use this function instead.
     */
    function functionCall(address target, bytes memory data) internal returns(bytes memory) {
        return functionCall(target, data, "Address: low-level call failed.");
    }
    
    function functionCall(address target, bytes memory data, string memory errMsg) internal returns(bytes memory) {
        return _functionCallWithValue(target, data, 0, errMsg);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errMsg) private returns(bytes memory) {
        require(isContract(target), "Address: call to non-contract.");
        
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errMsg);
            }
        }
    }
    
}



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow.");
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        return sub(a, b, "SafeMath: subtraction overflow.");
    }
    
    function sub(uint256 a, uint256 b, string memory errMsg) internal pure returns(uint256) {
        require(b <= a, errMsg);
        uint256 c = a - b;
        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0){
            return 0;
        }
        
        uint256 c = a * b;
        require(c/a == b, "SafeMath: mutiplication overflow.");
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return div(a, b, "SafeMath: division by zero.");
    }
    
    function div(uint256 a, uint256 b, string memory errMsg) internal pure returns(uint256) {
        require(b > 0, errMsg);
        uint256 c = a / b;
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero.");
    }
    
    function mod(uint256 a, uint256 b, string memory errMsg) internal pure returns(uint256) {
        require(b != 0, errMsg);
        return a % b;
    }
    
}



abstract contract Context {
    function _msgSender() internal view virtual returns(address payable) {
        return payable(msg.sender);
    }
    
    function _msgData() internal view virtual returns(bytes memory){
        this;   // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;
    
    event OwnershipTransferred(address indexed _previousOwner, address indexed newOwner);
    
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns(address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner.");
        _;
    }
    
    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnerShip(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is zero address.");
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}



interface IERC20 {
    
    /**
     * @dev returns the amount of tokens in existence.
     */
    function totalSupply() external view returns(uint256);
    
    /**
     * @dev returns the amount of tokens owned by account 
     */
    function balanceOf(address account) external view returns(uint256);
    
    /**
     * @dev moves amount tokens from the call's account to recipient.
     * returns a bool value indicating whether the operation successed.
     */
    function transfer(address recipient, uint256 amount) external returns(bool);
    
    /**
     * @dev returns the remaining number of tokens that spender will be allowed to spend 
     * on behalf of owner through {transferFrom}. this is zero by default.
     * 
     * his value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns(uint256);
    
    /**
     * @dev sets amount as the allowance of spender over the caller's tokens. 
     * returns a bool value indicating whether the operation is successed.
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
    function approve(address spender, uint256 amount) external returns(bool);
    
    /**
     * @dev moves amount tokens from sender to recipient using the allowance mechanism.
     * amount is then deducted from the caller's allowance.
     * 
     * returns a boolean value indicating whether the operation successed.
     * 
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}




interface IUniswapV2Factory {
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



interface IUniswapV2Pair {
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




interface IUniswapV2Router01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

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



interface IUniswapV2Router02 is IUniswapV2Router01 {
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




contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual returns(string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual returns(uint8) {
        return _decimals;
    }
    
    function totalSupply() public view virtual override returns(uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns(uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns(bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns(uint256) {
       return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns(bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance."));
        return true;
    }
    
    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    
    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decrease allowance bellow zero."));
        return true;
    }
    
    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address.");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance.");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev creates `amount` tokens and assign them to `account`, increasing the total supply.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to zero address.");
        
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    /**
     * @dev destroys `amount` tokens from `account`, reducing the total supply.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address.");
        
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance.");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address.");
        require(spender != address(0), "ERC20: approve to the zero address.");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
    
    /**
     * @dev Hook that is called before any transfer of tokens. This includes minting and burning.
     */
    function _beforeTokenTransfer(address sender, address recipient, uint256 amount) internal virtual { }
    
}




contract CasperToken is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromMaxSell;
    address public tcWbnbPair;// pair of this token and bnb
    IUniswapV2Router02 public uniswapV2Router;

    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address _blackhole = 0x000000000000000000000000000000000000dEaD;
    address public _teamReceiver = 0xCdD7a5Ebea2EeA145509e1af3d7A6Fe3f258b18A;
    address public _seedReceiver = 0x611F968f2f168e8d01bC910291e674F3B0EA3B09;
    address public _nationReceiver = 0x59f2dd9bA741e0f7378cf1a1fc86d26718F46D72;
    
    uint256 public _maxTotal = 1 * 10 ** 7 * 10 ** 18 ;
    uint256 public _maxSell = 1 * 10 ** 4 * 10 ** 18;// max amount to sell
    uint8 public _decimals = 18;
    bool public enableFee = true;// Whether to charge transaction fees
    uint256 public fixSellSlippage = 0;

    constructor() ERC20("CasperToken", "Casper") {
        uniswapV2Router = IUniswapV2Router02(router);
        WBNB = uniswapV2Router.WETH();

        _mint(owner(), _maxTotal);

        uint256 teamAmount = _maxTotal.mul(16).div(100);
        super._transfer(owner(), _teamReceiver, teamAmount.mul(15).div(100));

        uint256 seedAmount = _maxTotal.mul(10).div(100);
        super._transfer(owner(), _seedReceiver, seedAmount.mul(15).div(100));

        uint256 nationAmount = _maxTotal.mul(8).div(100);
        super._transfer(owner(), _nationReceiver, nationAmount.mul(100).div(100));


        _isExcludedFromFee[_blackhole] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(uniswapV2Router)] = true;

        _isExcludedFromMaxSell[owner()] = true;
    }


    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
    
    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != to, "Sender and reciever must be different");
        require(amount > 0, "Transfer amount must be greater than zero");

        //check and update pairs
        _checkLps();

        //check max sell amount when selling
        if(to == tcWbnbPair && !_isExcludedFromMaxSell[from]) {
            require(amount <= _maxSell, "Sell amount reach maximum.");
        }

        if(to == tcWbnbPair){
            if(_isExcludedFromFee[from] || !enableFee){
                super._transfer(from, to, amount);
            } else {
                _transferSellStandard(from, to, amount);
            }
        } else {
            super._transfer(from, to, amount);
        }
        
    }

    function _checkLps() private {
        //create a uniswap pair for this new token
        address _tcWbnbPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), WBNB);
        if (tcWbnbPair != _tcWbnbPair) {
            tcWbnbPair = _tcWbnbPair;
        }
    }
    
    function _getTcWbnbReserves() private view returns(uint256 _tcReserve, uint256 _wbnbReserve) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(tcWbnbPair).getReserves();
        address token0 = IUniswapV2Pair(tcWbnbPair).token0();
        if(token0 == address(this)){
            _tcReserve = uint256(reserve0);
            _wbnbReserve = uint256(reserve1);
        } else {
            _tcReserve = uint256(reserve1);
            _wbnbReserve = uint256(reserve0);
        }
    }

    function _getAmountOutWbnb(uint256 tokenAmount) private view returns (uint256) {
        if (tokenAmount <= 0) return 0;
        (uint256 _tcReserve, uint256 _wbnbReserve) = _getTcWbnbReserves();
        if (_wbnbReserve <= 0 || _tcReserve <= 0) return 0;
        return uint256(_getAmountOut(tokenAmount, _tcReserve, _wbnbReserve));
    }

    function _getAmountInTc(uint256 amountOut) private view returns(uint256){
        (uint256 _tcReserve, uint256 _wbnbReserve) = _getTcWbnbReserves();
        if (_wbnbReserve <= 0 || _tcReserve <= 0) return 0;
        return uint256(_getAmountIn(amountOut, _tcReserve, _wbnbReserve));
    }

    function _getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) private pure returns (uint amountIn) {
        if (amountOut <= 0) return 0;
        if (reserveIn <= 0) return 0;
        if (reserveOut <= 0) return 0;
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    function _getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) private pure returns (uint amountOut) {
        if (amountIn <= 0) return 0;
        if (reserveIn <= 0) return 0;
        if (reserveOut <= 0) return 0;
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function _transferSellStandard(address from, address to, uint256 amount) private {
        uint256 totalFee = _getSellFees(amount);
        uint256 transferAmount = amount.sub(totalFee);

        super._transfer(from, address(0), totalFee);
        super._transfer(from, to, transferAmount);
    }

    function _getSellFees(uint256 amount) private view returns (uint256) {
        uint256 amountOutWbnb = _getAmountOutWbnb(amount);
        uint256 currentSellRate = _convertToSellSlippage(fixSellSlippage);
        uint256 amountOutWbnbAfterFee = amountOutWbnb.sub(amountOutWbnb.mul(currentSellRate).div(10000));
        uint256 amountInTc = _getAmountInTc(amountOutWbnbAfterFee);
        uint256 fee = amount.sub(amountInTc);
        return fee;
    }

    function _convertToSellSlippage(uint256 taxRate) private pure returns(uint256) {
        return uint256(10000).sub(uint256(10000000).div(uint256(1000).add(taxRate)));
    }
    
    function setMaxSell(uint256 __maxSellAmount) public onlyOwner{
        _maxSell = __maxSellAmount;
    }

    function excludeFromFees(address _account, bool _excluded) public onlyOwner {
        require(_isExcludedFromFee[_account] != _excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFee[_account] = _excluded;
        emit ExcludeFromFees(_account, _excluded);
    }

    function getExcludeFromFee(address addr) public view returns(bool) {
        return _isExcludedFromFee[addr];
    }

    function excludeFromMaxSell(address _account, bool _excluded) public onlyOwner {
        require(_isExcludedFromMaxSell[_account] != _excluded, "Account is already the value of 'excluded'");
        _isExcludedFromMaxSell[_account] = _excluded;
        emit ExcludeFromMaxSell(_account, _excluded);
    }

    function getExcludeFromMaxSell(address addr) public view returns(bool) {
        return _isExcludedFromMaxSell[addr];
    }
    
    function setEnableFee(bool _enableFee) public onlyOwner{
        enableFee = _enableFee;
    }

    function updateFixSellSlippage(uint256 _fixSellSlippage) public onlyOwner{
        fixSellSlippage = _fixSellSlippage;
    }


    
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromMaxSell(address indexed account, bool isExcluded);
}