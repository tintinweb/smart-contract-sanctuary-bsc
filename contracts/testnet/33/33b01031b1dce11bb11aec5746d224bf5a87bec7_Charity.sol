/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
/**
   * @title Context
   * @dev ContractDescription
   * @custom:dev-run-script dbme_purchase.sol
   */
contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
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

// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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

// pragma solidity >=0.6.2;

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


interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Charity is Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;

    uint256 public utilityPrice;
    address public charityAddress;
    uint256 public divisor = 10000;
    uint256 public priceDivisor = 100000000;
    address public corporateAddress;
    uint public corporatePercent = 300;
    uint public burnPercent = 9000;
    uint public charityPercent = 1000;
    address public bnbToUsdAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
    // address public bnbToUsdAddress = 0x14e613AC84a31f709eadbdF89C6CC390fDc9540A; /* mainnet */
    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;
    AggregatorV3Interface internal priceFeed;

    IUniswapV2Router02 public immutable uniswapV2Router;

    address public DBME;

    mapping(uint256 => uint256) public products;
    mapping(address => string) private _referralCodeFromAddress;
    mapping(string => address) public addressFromReferralCode;

    Counters.Counter private productIds;

    event AddProduct(uint256 index, uint256 amount);
    event BuyProduct(address buyer, uint256 amount);
    event SwapETHForTokens(uint256 amountIn, address[] path);

    constructor() {
        priceFeed = AggregatorV3Interface(bnbToUsdAddress);
        charityAddress = 0xa469310139D3F389b67b600FF13771FEbCbB5Dd8;
        corporateAddress = 0x91e73431B8b8Bd3ea8Ff2294eeCF5565B2293517;
        utilityPrice = 762000000000000;

        // DBME = 0x6a9AB0D83Fdbb71f591864ebA267c92c9Bf98E8d /* mainnet */;
        DBME = 0x4314973717DFD89213a19Ef262A955B9F5D4a811; /* testnet */
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        ); /* testnet */

        uniswapV2Router = _uniswapV2Router;
        products[productIds.current()] = 1;
        productIds.increment();

        string memory key = generateReferralCode();
        _referralCodeFromAddress[msg.sender] = key;
        addressFromReferralCode[key] = msg.sender;

    }

    function setProduct(uint256 index, uint256 amount) external onlyOwner {
        products[index] = amount;
    }

    function addProduct(uint256 amount) external onlyOwner {
        productIds.increment();
        emit AddProduct(productIds.current(), amount);
        products[productIds.current()] = amount;
    }

    function setDBME(address _dbme) external onlyOwner {
        DBME = _dbme;
    }

    function setCharity(address _charity) external onlyOwner {
        charityAddress = _charity;
    }

    function setCorporate(address _corporate) external onlyOwner {
        corporateAddress = _corporate;
    }

    function setUtility(uint256 _utilityPrice) external onlyOwner{
        utilityPrice = _utilityPrice;
    }

    function buyProduct(address _sponsorAddress, uint256 amount) external payable {
        int256 price = getLatestPrice();
        uint256 balanceInUSD = (msg.value * uint256(price)).div(priceDivisor);

        require(balanceInUSD >= amount.mul(10 ** 18), "Insufficient balance");
        address sponsorAddress = address(0);
        if(_sponsorAddress != address(0)) {
            sponsorAddress = _sponsorAddress;
        }else {
            require(_sponsorAddress != address(0), "Invalid address");
        }

        uint256 amountInEth = amount.mul(10 ** 18) / uint256(price).div(priceDivisor);

        uint256 sponsorAmount = amountInEth.div(100).mul(70);
        uint256 swapAmount = amountInEth.div(100).mul(15);
        //uint256 swapAmount = msg.value - sponsorAmount - corporateAmount;
        uint256 corporateAmount = amountInEth - sponsorAmount - swapAmount;
        

        
        payable(sponsorAddress).transfer(sponsorAmount);
        payable(corporateAddress).transfer(corporateAmount);
        payable(address(this)).call{value: swapAmount};

        swapETHForTokens(swapAmount);

        uint256 utilityDBME = amount / utilityPrice.div(10 ** 18);
        //uint256 clientDBME = IERC20(DBME).balanceOf(address(this));
        IERC20(DBME).transfer(
            deadAddress,
            utilityDBME.mul(burnPercent).div(divisor)
        );

        IERC20(DBME).transfer(
            charityAddress,
            utilityDBME.mul(charityPercent).div(divisor)
        );
    }

    /*function buyProduct(address _sponsorAddress, uint256 amount) external payable {
        int256 price = getLatestPrice();
        uint256 balanceInUSD = (msg.value * uint256(price)).div(priceDivisor);
        //uint256 balanceInUSD = (amount * uint256(price)).div(priceDivisor);

        require(balanceInUSD >= amount.mul(10 ** 18), "Insufficient balance");
        address sponsorAddress = address(0);
        if(_sponsorAddress != address(0)) {
            sponsorAddress = _sponsorAddress;
        }else {
            require(_sponsorAddress != address(0), "Invalid address");
        }

        uint256 amountInEth = amount.mul(10 ** 18) / uint256(price).div(priceDivisor);

        uint256 sponsorAmount = amountInEth.div(100).mul(70);
        uint256 swapAmount = amountInEth.div(100).mul(15);
        //uint256 swapAmount = msg.value - sponsorAmount - corporateAmount;
        uint256 corporateAmount = amount - sponsorAmount - swapAmount - (uint256(3).mul(10 ** 18) / uint256(price).div(priceDivisor));
        

        
        payable(sponsorAddress).transfer(sponsorAmount);
        payable(corporateAddress).transfer(corporateAmount);
        payable(address(this)).call{value: swapAmount};
        
        swapETHForTokens(swapAmount);

        
        //uint256 utilityDBME = amount.mul(10 ** 18) / utilityPrice.div(10 ** 18);
        //uint256 clientDBME = IERC20(DBME).balanceOf(address(this));
        IERC20(DBME).transfer(
            deadAddress,
            utilityDBME.mul(burnPercent).div(divisor)
        );

        IERC20(DBME).transfer(
            charityAddress,
            utilityDBME.mul(charityPercent).div(divisor)
        );
    }*/

    function generateReferralCode() public view returns (string memory)  {

        uint256 timeNow = block.timestamp;
        string memory code = string(abi.encodePacked("dbme_", timeNow.toString()));
        return code;
    }

    function getReferralCode(address account) public view /* onlyOwner */ returns (string memory) {
        return _referralCodeFromAddress[account];
    }

    function getProductCount() public view /* onlyOwner */ returns (uint256) {
        return productIds.current();
    }

    function swapETHForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = DBME;

        // make the swap
        try
            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: amount
            }(
                0, // accept any amount of Tokens
                path,
                address(this), // recipient address
                block.timestamp + 100
            )
        {
            emit SwapETHForTokens(amount, path);
        } catch {}
    }

    function getBalancePrice() external view returns (uint256) {
        return (address(msg.sender).balance *
            uint256(getLatestPrice())).div(priceDivisor);
    }

    
    /**
     * Returns the latest price.
     */
    function getLatestPrice() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}