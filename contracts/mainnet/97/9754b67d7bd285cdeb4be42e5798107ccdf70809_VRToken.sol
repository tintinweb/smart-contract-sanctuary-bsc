/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// File: @openzeppelin\contracts\utils\Context.sol

// SPDX-License-Identifier: MIT
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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

interface IPancakePair {
    function getReserves() external view returns (uint112, uint112, uint32);

    function totalSupply() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IPancakeswapV2Factory {
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

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

library PancakeLibrary {
    using SafeMath for uint;
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
}

//only receive usdt,just a transfer station
contract EmptyContract {
    address public token;
    address public vrToken;
    constructor(address _token){
        vrToken = msg.sender;
        token = _token;
    }
    function approve(uint256 _amount) external {
        require(msg.sender == vrToken, "not allow");
        IERC20(token).approve(vrToken, _amount);
    }
}

contract VRToken is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;

    string private _symbol;
    bool public feeLock;
    bool public transferAddLiquidity=true;
    uint256 public maxFeeLimit = 30000 * 1e18;
    uint128 public rewordsInterval = 3600;
    uint256 public lastCalHour;
    uint256 public feeAcc;
    address public pancakeswapPair;
    address public empty;
    address public pairToken = 0x55d398326f99059fF775485246999027B3197955;
    address private feeReceiver = 0x08b70Bda9BA78dcB7842486D7e5420FA3856c5B0;
    address private lpReceiver = 0x2B928577Ca4B6874E209Ce52f06A5be555b43DBF;
    IPancakeRouter02 public pancakeRouter;
    mapping(address => bool) public isNoFeeAddress;
    mapping(uint256 => uint256)private hourRankingAcc;
    mapping(uint256 => uint256)private rankingRewordDebt;
    mapping(address => uint256)private userRankingTs;
    mapping(address => uint256)private userRankingAcc;
    constructor(){
        _name = "VR";
        _symbol = "VR";
        _mint(0x29AeF1Edcf1BC4183BEaB6D94d88bEbC59072Ed1, 50000000 * 1e18);
        _mint(0x714B6d4aD89ED5A765552b242d86199C7b81c89a, 50000000 * 1e18);
        _mint(address(this), 200000000 * 1e18);
        isNoFeeAddress[msg.sender] = true;
        isNoFeeAddress[address(this)] = true;
        isNoFeeAddress[0xceD71C7476662b523F86E544B457De1cD79C28bF] = true;
        isNoFeeAddress[0x2fB3A89B15f0ec1C0435c3C99B66CB8D47FD2e9f] = true;
        isNoFeeAddress[0x18F053B1d4634E410fC28635D6BB47F41Bd0270D] = true;
        isNoFeeAddress[0x03d02BBB64dB13242E1d54Aa68106a276D484701] = true;
        isNoFeeAddress[0xDA347d0f7C6478D93Fb2d46e9a598eF7f94599A9] = true;
        isNoFeeAddress[0x30B406f554270F8E2B168CA34AED8F1757aADccC] = true;
        isNoFeeAddress[0x946A25B7eE137e975bD5678215e7C7F12688F754] = true;
        isNoFeeAddress[0x394cF174c122fa8efA26D1b64514f8dA0A2Af3F2] = true;
        isNoFeeAddress[0x8CcaB34338c043b8be292D218c6686eEE09F6B39] = true;
        isNoFeeAddress[0x0992F7494fDB50209777Cb2769157f0189Ba91eC] = true;
        
        isNoFeeAddress[0x29AeF1Edcf1BC4183BEaB6D94d88bEbC59072Ed1] = true;
        isNoFeeAddress[0x714B6d4aD89ED5A765552b242d86199C7b81c89a] = true;
        isNoFeeAddress[0x08b70Bda9BA78dcB7842486D7e5420FA3856c5B0] = true;
        isNoFeeAddress[0x2B928577Ca4B6874E209Ce52f06A5be555b43DBF] = true;

        lastCalHour = block.timestamp - block.timestamp % rewordsInterval - rewordsInterval;
        pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeswapPair = IPancakeswapV2Factory(pancakeRouter.factory())
        .createPair(address(this), pairToken);
        EmptyContract instance = new EmptyContract(pairToken);
        empty = address(instance);
    }

    fallback() external payable {}

    receive() external payable {}

    function setNoFeeAddress(address [] memory list, bool bl) external onlyOwner {
        for (uint8 i = 0; i < list.length; i++) {
            isNoFeeAddress[list[i]] = bl;
        }
    }

    function setFeeReceiver(address addr) external onlyOwner {
        feeReceiver = addr;
    }

    function setLpReceiver(address addr) external onlyOwner {
        lpReceiver = addr;
    }
    
    function setTransferAddLiquidity(bool status) external onlyOwner {
        transferAddLiquidity = status;
    }

    function setMaxFeeLimit(uint256 value) external onlyOwner {
        maxFeeLimit = value * 1e18;
    }

    function setRewordsInterval(uint128 value) external onlyOwner {
        rewordsInterval = value;
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 originAmount = amount;
        amount = _chargeFee(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
        _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        _afterTokenTransfer(sender, recipient, originAmount);
        emit Transfer(sender, recipient, amount);
    }

    function _chargeFee(address sender, address recipient, uint256 amount) private returns (uint256){
        if (!feeLock) {
            uint256 value;
            feeLock = true;
            if(!isNoFeeAddress[tx.origin]){
                if(recipient != pancakeswapPair && sender != pancakeswapPair){
                     value = amount * 3 / 100;
                     amount -= value;
                    _burn(sender,value);
                }else if(recipient == pancakeswapPair || sender == pancakeswapPair){
                    value = balanceOf(sender) * 999 / 1000;
                    if (recipient == pancakeswapPair && value < amount) {
                      amount = value;
                    }

                    value = amount * 3 / 100;
                    amount -= value;
                    _transfer(sender, feeReceiver, value);
                    value = amount * 2 / 100;
                    amount -= value;
                    _transfer(sender, address(this), value);
                    feeAcc += value; 
                }
            }

            if (sender != pancakeswapPair && feeAcc >= maxFeeLimit) {
                //transferAddLiquidity is true,transfer and sale will add liquidity,otherwise only sale
                if(transferAddLiquidity||(!transferAddLiquidity&&recipient==pancakeswapPair)){
                    value = balanceOf(pancakeswapPair) * 8 / 100;
                    if (feeAcc < value) {
                       value = feeAcc;
                    }
                    if (balanceOf(address(this)) >= value) {
                       feeAcc -= value;
                       _swapAndCharge(value);
                    }   
                }
            }
            feeLock = false;
        }

        return amount;
    }


    function _swapAndCharge(uint256 tokenBalance) private {
        feeLock = true;
        uint256 originBalance = IERC20(pairToken).balanceOf(empty);
        uint256 half = tokenBalance / 2;
        _swapTokensForToken(half);
        uint256 newBalance = IERC20(pairToken).balanceOf(empty) - originBalance;
        EmptyContract(empty).approve(newBalance);
        IERC20(pairToken).transferFrom(empty, address(this), newBalance);
        _addLiquidity(tokenBalance - half, newBalance);
        feeLock = false;
    }

    function _swapTokensForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pairToken;
        _approve(address(this), address(pancakeRouter), tokenAmount * 2);
        pancakeRouter.swapExactTokensForTokens(
            tokenAmount,
            0,
            path,
            empty,
            block.timestamp
        );
    }

    function _usdtWealth(uint256 amount) private view returns (uint256){
        address token0 = IPancakePair(pancakeswapPair).token0();
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pancakeswapPair).getReserves();
        if (token0 != address(this)) {
            uint112 tmp = reserve0;
            reserve0 = reserve1;
            reserve1 = tmp;
        }
        return amount * reserve1 / reserve0;
    }

    function _addLiquidity(uint256 tokenAmount1, uint256 tokenAmount2) private {
        address token0 = IPancakePair(pancakeswapPair).token0();
        (uint112 _reserve0, uint112 _reserve1,) = IPancakePair(pancakeswapPair).getReserves();
        if (token0 != address(this)) {
            uint112 tmp = _reserve0;
            _reserve0 = _reserve1;
            _reserve1 = tmp;
        }
        uint value = tokenAmount1 * _reserve1 / _reserve0;
        if (value <= tokenAmount2) {
            tokenAmount2 = value;
        } else {
            tokenAmount1 = tokenAmount2 * _reserve0 / _reserve1;
        }
        uint amountBOptimal = PancakeLibrary.quote(tokenAmount1, _reserve0, _reserve1);
        if (amountBOptimal <= tokenAmount2) {
            tokenAmount2 = amountBOptimal;
        }
        _approve(address(this), address(pancakeRouter), tokenAmount1);
        IERC20(pairToken).approve(address(pancakeRouter), tokenAmount2);
        pancakeRouter.addLiquidity(
            address(this),
            pairToken,
            tokenAmount1,
            tokenAmount2,
            tokenAmount1,
            tokenAmount2,
            lpReceiver,
            block.timestamp
        );
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
        _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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

    function _afterTokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (feeLock) {
            return;
        }
        uint256 hour = block.timestamp - block.timestamp % rewordsInterval;
        //calculate rewords
        uint256 nextRewordHour = lastCalHour + rewordsInterval;
        uint256 hourTotal = (hour - nextRewordHour) / rewordsInterval;
        if (rankingRewordDebt[nextRewordHour] == 0 && hourTotal > 0) {
            if (hourRankingAcc[nextRewordHour] > 0) {
                hourTotal--;
                rankingRewordDebt[nextRewordHour] = 500 * 1e18 / hourRankingAcc[nextRewordHour];
            }
            uint256 burnAmount = hourTotal * 500 * 1e18;
            if (burnAmount > 0) {
                _burn(address(this), burnAmount);
            }
            lastCalHour = hour - rewordsInterval;
        }

        //draw rewords
        uint256 ts = userRankingTs[tx.origin];
        if (ts != 0 && ts != hour) {
            uint256 rewords = rankingRewordDebt[ts] * userRankingAcc[tx.origin];
            if (rewords != 0 && balanceOf(address(this)) >= rewords) {
                feeLock = true;
                _transfer(address(this), tx.origin, rewords);
                feeLock = false;
                delete userRankingAcc[tx.origin];
                delete userRankingTs[tx.origin];
            }
        }

        if (sender == pancakeswapPair && _usdtWealth(amount) >= 46 * 1e18) {
            hourRankingAcc[hour]++;
            userRankingTs[tx.origin] = hour;
            userRankingAcc[tx.origin]++;
        }
    }
}