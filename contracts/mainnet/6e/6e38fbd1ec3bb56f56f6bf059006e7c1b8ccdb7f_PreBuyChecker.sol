/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

pragma solidity >=0.7.0 <0.9.0;

// SPDX-License-Identifier: MIT

interface IUniswapV2Router {

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);   
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

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v,
        bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
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
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PreBuyChecker is Ownable {

    using SafeMath for uint256;

    enum TxType{ APPROVE, BUY, SELL }

    mapping (address => bool) public _isAllowlisted;

    mapping (uint256 => address) public nativeTokenMapping;

    
    event PaymentReceived(address from, uint256 amount);
    event TaxCalculated(address token, uint256 expectedAmount, uint256 actualAmount, uint256 diff, uint256 tax, bool isBuy);
    event TxCompleted(TxType txType);

    uint256 private amountToApprove = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    address private WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address private WAVAX_TESTNET = 0xd00ae08403B9bbb9124bB305C09058E32C39A48c;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private WCRO = 0x5C7F8A570d578ED84E63fdFA7b1eE72dEae1AE23;
    address private WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private WFTM = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;
    address private WMETIS = 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;
    address private WONE = 0xcF664087a5bB0237a0BAd6742852ec6c8d69A27a;
    address private WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    constructor() {    
        nativeTokenMapping[43114] = WAVAX;
        nativeTokenMapping[43113] = WAVAX_TESTNET;
        nativeTokenMapping[56] = WBNB;
        nativeTokenMapping[25] = WCRO;
        nativeTokenMapping[1] = WETH;
        nativeTokenMapping[250] = WFTM;
        nativeTokenMapping[1088] = WMETIS;
        nativeTokenMapping[1666600000] = WONE;
        nativeTokenMapping[137] = WMATIC;
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function transferToken(address _recipient, address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transferFrom(address(this), _recipient, _amount);
    }

    function setAllowlist(address account, bool allowlisted) public onlyOwner {
        _isAllowlisted[account] = allowlisted;
    }
    
    function honeyPotWithTaxCheck (
        uint256 _buyAmount,
        address _routerAddress, 
        address _tokenToBuyWith, 
        address _tokenToBuy,
        uint256 _maxBuyTax,
        bool _checkSell) external payable {

        address walletAddress = _msgSender();
        require(_isAllowlisted[walletAddress] || owner() == walletAddress, "You are not allowlisted");

        uint256 buyAmount = _buyAmount;
        address contractAddress = address(this);
        uint256 deadline = block.timestamp + 1000;
    
        // Transfer the token to buy with from wallet to the contract
        if(msg.value > 0) {
            IWETH(nativeTokenMapping[block.chainid]).deposit{value: msg.value}();
            buyAmount = msg.value;
        } else {
            IERC20(_tokenToBuyWith).transferFrom(walletAddress, address(this), buyAmount);
        }

        address[] memory path = new address[](2); 
        path[0] = _tokenToBuyWith; 
        path[1] = _tokenToBuy;

        IUniswapV2Router router = IUniswapV2Router(_routerAddress);

        //uint256 actualAmountBefore = 0;
        uint256 expectedAmount = 0;
        if(_maxBuyTax > 0) {
            // actualAmountBefore = IERC20(token).balanceOf(address(this)); 
            expectedAmount = router.getAmountsOut(buyAmount, path)[1];
        }

        // The buy
        IERC20(_tokenToBuyWith).approve(_routerAddress, amountToApprove);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(buyAmount, 0, path, walletAddress, deadline);
        emit TxCompleted(TxType.BUY);

        uint actualAmount = IERC20(_tokenToBuy).balanceOf(walletAddress); 

        uint actualBuyTax = 0;
        if(_maxBuyTax > 0) {
            // actualAmount = actualAmountAfter - actualAmount
            uint256 diff = expectedAmount.sub(actualAmount).mul(100);
            actualBuyTax = diff.div(expectedAmount);
            emit TaxCalculated(_tokenToBuy, expectedAmount, actualAmount, diff, actualBuyTax, true);
            require(actualBuyTax < _maxBuyTax, "Buy tax is too high");
        }
    
        if(_checkSell) {
            // Transfer the token from wallet to the contract to sell
            IERC20(_tokenToBuy).transferFrom(walletAddress, contractAddress, actualAmount);

            // The approval to sell
            IERC20(_tokenToBuy).approve(_routerAddress, actualAmount);
            emit TxCompleted(TxType.APPROVE);

            // The sell
            path[0] = _tokenToBuy; 
            path[1] = _tokenToBuyWith;
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(actualAmount, 0, path, walletAddress, deadline);
            emit TxCompleted(TxType.SELL);
        }
    }
}