/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

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

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

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

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract Spire is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;


    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public buyAAddress = 0x12A054BDAE030501c222ceCc7D1B759AA95Fd106;
    address public buyBAddress = 0x549424F7fe0e5DCa9BFD9888A1eE783fAFE669a5;
    address public buyCAddress = 0xcA7c70c5f9A6f229dcB33F9d2f5Bb4fF6dcB186A;

    address public sellAAddress = 0xa1557ACc68c4863C3C4Ac9A9DA287E38864Bd433;
    address public sellBAddress = 0x4A3C7FF4e33B3e16D5d6AF2084bccA9608B31067;
    address public sellCAddress = 0xA414660500710E124dc93E49BD6EbB9a08e537a9;

    address public defaultAddress = 0xEde29C1E09a643176a03A681319f60361a00Ed4f;

    IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);

    string private _name = "Spire";
    string private _symbol = "Spire";
    uint8 private _decimals = 18;

    uint256 private _tTotal = 30000 * 10**18;
    uint256 public maxAmount = 10 * 10 ** 18;

    bool public maxAmountSwitch = true;
    bool public isNinetyNine = true;

    mapping (address => bool) public holdingsLimited;
    mapping(address => address) public inviter;
    mapping (address => bool) public automatedMarketMakerPairs;
    
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;


    constructor() {
        address assgin = 0xE79AB38F72E964bEA4E48a2c3dA56B7D6Fb8a180;
        _tOwned[assgin] = _tTotal;
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(usdt));
        uniswapV2Router = _uniswapV2Router;

        automatedMarketMakerPairs[uniswapV2Pair] = true;
        addExcluded(assgin);
        
        emit Transfer(address(0), assgin, _tTotal);
    }

    function addExcluded(address assgin) private {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromFee[buyAAddress] = true;
        _isExcludedFromFee[buyBAddress] = true;
        _isExcludedFromFee[buyCAddress] = true;
        _isExcludedFromFee[sellAAddress] = true;
        _isExcludedFromFee[sellBAddress] = true;
        _isExcludedFromFee[sellCAddress] = true;

        _isExcludedFromFee[defaultAddress] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(assgin)] = true;

        holdingsLimited[owner()] = true;
        holdingsLimited[deadAddress] = true;
        holdingsLimited[address(this)] = true;
        holdingsLimited[address(uniswapV2Pair)] = true;
        holdingsLimited[address(uniswapV2Router)] = true;

        holdingsLimited[buyAAddress] = true;
        holdingsLimited[buyBAddress] = true;
        holdingsLimited[buyCAddress] = true;
        holdingsLimited[sellAAddress] = true;
        holdingsLimited[sellBAddress] = true;
        holdingsLimited[sellCAddress] = true;
        holdingsLimited[defaultAddress] = true;
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
        holdingsLimited[account] = true;
    }
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        automatedMarketMakerPairs[pair] = value;
        holdingsLimited[pair] = true;
    }

    function setBuyABCAddress(address accountA,address accountB,address accountC) public onlyOwner {
        buyAAddress = accountA;
        buyBAddress = accountB;
        buyCAddress = accountC;
    }
    function setSellABCAddress(address accountA,address accountB,address accountC) public onlyOwner {
        sellAAddress = accountA;
        sellBAddress = accountB;
        sellCAddress = accountC;
    }
    function setDefaultAddress(address account) public onlyOwner {
        defaultAddress = account;
    }
    function setHoldingsLimited(address account,bool success) public onlyOwner {
        holdingsLimited[account] = success;
    }
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
	function withdraw()  external onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
    function withdrawToken(address token, address to)  external onlyOwner {
        uint256 bablance = IERC20(token).balanceOf(address(this));
		IERC20(token).transfer(to, bablance);
	}
	function withdrawCoin(address recipient, uint256 amount) external onlyOwner {
		_tOwned[address(this)] = _tOwned[address(this)].sub(amount);
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        emit Transfer(address(this), recipient, amount);
	}

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve( address owner, address spender, uint256 amount ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMaxAmountSwitch(bool success) public onlyOwner {
            maxAmountSwitch = success;
    }
    function setMaxAmount(uint256 amount) public onlyOwner {
            maxAmount = amount;
    }

    function setIsNinetyNine(bool success) public onlyOwner {
	    isNinetyNine = success;
	}

    mapping(address => mapping(address => uint256)) public interconvertibility;

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            return;
        }

        if(!holdingsLimited[to] && maxAmountSwitch){
            uint256 balance = balanceOf(to);
            if(balance.add(amount) > maxAmount){    
                revert("Each wallet address can hold a maximum of 10 million");
            }
        }

        if(!_isExcludedFromFee[from] && isNinetyNine){
            uint256 balance = balanceOf(from).mul(999).div(1000);
            if(amount > balance){
                amount = balance;
            }
        }

        bool shouldSetInviter = inviter[to] == address(0) && !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to];
        if(shouldSetInviter){
            interconvertibility[from][to] = amount;
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        if(automatedMarketMakerPairs[from] && takeFee){
            _buyTokenTransfer(from, to, amount);
        }else if(automatedMarketMakerPairs[to] && takeFee){
            _sellTokenTransfer(from, to, amount);
		}else{
			_tOwned[from] = _tOwned[from].sub(amount);
            _tOwned[to] = _tOwned[to].add(amount);
            emit Transfer(from, to, amount);
		}

        if (inviter[from] == address(0) && interconvertibility[to][from] > 0) {
            inviter[from] = to;
        }

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  

         if(_tOwned[address(this)] >= swapProcess && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas);
             LPFeefenhong = block.timestamp;
        }

    }

    mapping (address => bool) isDividendExempt;
    mapping(address => bool) public _updated;
    uint256 currentIndex;  
    uint256 public swapProcess = 100 * 10**18;
    uint256 public bounProcess = 1 * 10**9;

    uint256 distributorGas = 300000;
    uint256 public minPeriod = 600;
    uint256 public LPFeefenhong;
    address private fromAddress;
    address private toAddress;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }
    function setSwapProcess(uint256 number) public onlyOwner {
        swapProcess = number;
    }
    function setBounProcess(uint256 number) public onlyOwner {
        bounProcess = number;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0)return;
        uint256 nowbanance = _tOwned[address(this)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
          uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
         if( amount < bounProcess) {
             currentIndex++;
             iterations++;
             return;
         }
         if(_tOwned[address(this)]  < amount )return;
            distributeDividend(shareholders[currentIndex], amount);
            
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
   
    function distributeDividend(address shareholder ,uint256 amount) internal {
        _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
        _tOwned[shareholder] = _tOwned[shareholder].add(amount);
        emit Transfer(address(this), shareholder, amount);
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


    function _buyTokenTransfer(address sender,address recipient,uint256 amount) private {
        _tOwned[sender] = _tOwned[sender].sub(amount);

        uint256 AFee = amount.div(1000).mul(20);
        _takewlletFee(sender,buyAAddress, AFee);

        uint256 BFee = amount.div(1000).mul(5);
        _takewlletFee(sender,buyBAddress, BFee);

        uint256 CFee = amount.div(1000).mul(5);
        _takewlletFee(sender,buyCAddress, CFee);

        uint256 inviterFee = amount.div(1000).mul(90);
        _buyTakeInviterFee(sender,recipient, inviterFee);

        amount = amount.sub(amount.div(12));
        _takewlletFee(sender,recipient, amount);
    }

    function _sellTokenTransfer(address sender,address recipient,uint256 amount) private {
        _tOwned[sender] = _tOwned[sender].sub(amount);

        uint256 sellAFee = amount.div(1000).mul(20);
        _takewlletFee(sender, sellAAddress, sellAFee);

        uint256 sellBFee = amount.div(1000).mul(5);
        _takewlletFee(sender, sellBAddress, sellBFee);

        uint256 sellCFee = amount.div(1000).mul(5);
        _takewlletFee(sender, sellCAddress, sellCFee);

        uint256 deadFee = amount.div(1000).mul(20);
        _takewlletFee(sender, deadAddress, deadFee);

        uint256 coinFee = amount.div(1000).mul(20);
        _takewlletFee(sender, address(this), coinFee);

        uint256 inviterFee = amount.div(1000).mul(50);
        _sellTakeInviterFee(sender, inviterFee);

        amount = amount.sub(amount.div(12));
        _takewlletFee(sender, recipient, amount);
    }

	
    function _takewlletFee(address sender,address away,uint256 tAmount) private {
        _tOwned[away] = _tOwned[away].add(tAmount);
        emit Transfer(sender, away, tAmount);
    }


    function _buyTakeInviterFee(address sender, address recipient, uint256 tAmount) private {
        address cur = recipient;
        uint256 totalFee = 90;
		uint8[5] memory inviteRate = [50, 10, 10, 10, 10];
        for (uint256 i = 0; i < inviteRate.length; i++) {
            uint256 rate = inviteRate[i];
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }

            totalFee = totalFee.sub(rate);
            uint256 curTAmount = tAmount.div(1000).mul(rate);
            _takewlletFee(sender, cur, curTAmount);
        }
        tAmount = tAmount.div(1000).mul(totalFee);
        _takewlletFee(sender, defaultAddress, tAmount);
    }

    function _sellTakeInviterFee(address sender, uint256 tAmount) private {
        address cur = sender;
        uint256 totalFee = 50;
		uint8[5] memory inviteRate = [30, 5, 5, 5, 5];
        for (uint256 i = 0; i < inviteRate.length; i++) {
            uint256 rate = inviteRate[i];
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }

            totalFee = totalFee.sub(rate);
            uint256 curTAmount = tAmount.div(1000).mul(rate);
            _takewlletFee(sender, cur, curTAmount);
        }
        tAmount = tAmount.div(1000).mul(totalFee);
        _takewlletFee(sender, defaultAddress, tAmount);
    }

}