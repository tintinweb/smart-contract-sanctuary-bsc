/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.6.8;

interface IBEP20 {
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

interface IWBNB {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    receive() external payable;

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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
                revert(errorMessage);
            }
        }
    }
}

contract Initializable {

    bool private initialized;
    bool private initializing;

    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

contract Ownable is Context, Initializable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {}

    function initOwner(address owner_) public initializer {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
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
}

interface IPancakePair {
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

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountETHDesired,
        uint256 amountAMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountETH,
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
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountETH);

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
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountETH);

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
    ) external pure returns (uint256 amountETH);

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

// File: contracts/protocols/bep/Utils.sol

pragma solidity >=0.6.8;

library Utils {
    using SafeMath for uint256;

    function random(
        uint256 from,
        uint256 to,
        uint256 salty
    ) private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number +
                        salty
                )
            )
        );
        return seed.mod(to - from) + from;
    }

    function calculateBNBReward(
        // uint256 _tTotal,
        uint256 currentBalance,
        uint256 currentBNBPool,
        uint256 totalSupply,
        // address ofAddress,
        uint256 rewardHardcap
    ) public pure returns (uint256) {
        uint256 bnbPool = currentBNBPool > rewardHardcap ? rewardHardcap : currentBNBPool;
        return bnbPool.mul(currentBalance).div(totalSupply);
        /*
        if (bnbPool > rewardHardcap) {
            bnbPool = rewardHardcap;
        }

        // calculate reward to send
        uint256 multiplier = 100;

        // now calculate reward
        
        uint256 reward = bnbPool
            .mul(100)
            .mul(currentBalance)
            .div(100)
            .div(totalSupply);
        

        return bnbPool
            .mul(100)
            .mul(currentBalance)
            .div(100)
            .div(totalSupply);
            */
        
    }

    function calculateTopUpClaim(
        uint256 currentRecipientBalance,
        uint256 basedRewardCycleBlock,
        uint256 threshHoldTopUpRate,
        uint256 amount
    ) public pure returns (uint256) {
        uint256 rate = amount.mul(100).div(currentRecipientBalance);

        if (rate >= threshHoldTopUpRate) {
            uint256 incurCycleBlock = basedRewardCycleBlock
                .mul(rate)
                .div(100);

            if (incurCycleBlock >= basedRewardCycleBlock) {
                incurCycleBlock = basedRewardCycleBlock;
            }

            return incurCycleBlock;
        }

        return 0;
    }

    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        public
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function swapETHForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function swapTokensForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            ethAmount, // wbnb input
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function getAmountsout(uint256 amount, address routerAddress)
        public
        view
        returns (uint256 _amount)
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // fetch current rate
        uint256[] memory amounts = pancakeRouter.getAmountsOut(amount, path);
        return amounts[1];
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 360
        );
    }

    function getAntiFlipTaxNo(uint256 firstBuy) public view returns(uint8 taxNo) {
        if (block.timestamp - firstBuy < 1 days) {
            return 0;
        } 
        else if (block.timestamp - firstBuy < 7 days) {
            return 1;
        } 
        else if (block.timestamp - firstBuy < 30 days) {
            return 2;
        } 
        else if (block.timestamp - firstBuy < 60 days) {
           return 3;
        } 
        else if (block.timestamp - firstBuy < 90 days) {
           return 4;
        } 
        else 
            return 5;
    }

}

library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(
            IPancakeFactory(factory).getPair(tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountETH) {
        require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountETH = amountA.mul(reserveB) / reserveA;
    }
}

// File: contracts/protocols/bep/ReentrancyGuard.sol

pragma solidity >=0.6.8;

abstract contract ReentrancyGuard {
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

// File: contracts/protocols/HODL.sol

pragma solidity >=0.8.7;
pragma experimental ABIEncoderV2;

contract HODL is Context, IBEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromMaxTx;

    // trace BNB claimed rewards and reinvest value
    mapping(address => uint256) public userClaimedBNB;
    uint256 public totalClaimedBNB;

    mapping(address => uint256) public userreinvested;
    uint256 public totalreinvested;

    // trace gas fees distribution
    uint256 public totalgasfeesdistributed;
    mapping(address => uint256) public userrecievedgasfees;

    address public deadAddress;

    address[] private _excluded;

    uint256 private MAX;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;

    bool private _inSwapAndLiquify;

    uint256 private daySeconds;

    struct WalletAllowance {
        uint256 timestamp;
        uint256 amount;
    }

    mapping(address => WalletAllowance) userWalletAllowance;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event ClaimBNBSuccessfully(
        address recipient,
        uint256 ethReceived,
        uint256 nextAvailableClaimDate
    );

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor() {}

    mapping(address => bool) isBlacklisted;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
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
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
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
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Pancake router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to receive BNB from pancakeRouter when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {      
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**3);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256){
        return _amount.mul(_liquidityFee).div(10**3);
    }

    /*
    function checkTaxAndLiquidityFees() private view returns (bool) {
         return block.timestamp > disruptiveTransferEnabledFrom.add(daySeconds.mul(2));
    }
    */

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        //require(!isBlacklisted[from], "Sender is backlisted");
        //require(!isBlacklisted[to], "Recipient is backlisted");
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            reflectionFeesDisabled
        ) {
            takeFee = false;
        }

        // take sell fee
        if (
            pairAddresses[to] &&
            from != address(this) &&
            from != owner()
        ) {
            uint256 _antiFlipTax = antiFlipTax[Utils.getAntiFlipTaxNo(antiFlip[from])];
            ensureMaxTxAmount(from, to, amount);
            _taxFee = selltax.add(_antiFlipTax).mul(_Reflection).div(100); 
            _liquidityFee = selltax.add(_antiFlipTax).mul(_Tokenomics).div(100);
            if (!_inSwapAndLiquify) {
                swapAndLiquify(from, to);
            }
        }
        
        // take buy fee
        else if (
            pairAddresses[from] && to != address(this) && to != owner()
        ) {
                /*
            if (!checkTaxAndLiquidityFees()) {
                _taxFee = buytax.mul(_Reflection).div(100).div(2);
                _liquidityFee = buytax.mul(_Tokenomics).div(100).div(2);
            } else {
                */
                if (balanceOf(to) == 0) {
                    antiFlip[to] = block.timestamp;
                }
                _taxFee = buytax.mul(_Reflection).div(100);
                _liquidityFee = buytax.mul(_Tokenomics).div(100);
            //}
        }
        
        // take transfer fee
        else {
            if (takeFee && from != owner() && from != address(this)) {
                _taxFee = transfertax.mul(_Reflection).div(100);
                _liquidityFee = transfertax.mul(_Tokenomics).div(100);
            }
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

        // top up claim cycle for recipient and sender
        topUpClaimCycleAfterTransfer(sender, recipient, amount);

        // top up claim cycle for sender
        //topUpClaimCycleAfterTransfer(sender, amount);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // Innovation for protocol by HODL Team
    uint256 public rewardCycleBlock;
    uint256 private stackingCounterStart;
    uint256 public threshHoldTopUpRate;
    uint256 public _maxTxAmount;
    uint256 public bnbStackingLimit;
    mapping(address => uint256) public nextAvailableClaimDate;
    bool public swapAndLiquifyEnabled;
    uint256 private reserve_5;
    uint256 private reserve_6;

    bool public reflectionFeesDisabled;

    uint256 private _taxFee;
    uint256 private _previousTaxFee;

    uint256[6] public antiFlipTax;

    LayerTax public bnbClaimTax;

    struct LayerTax {
        uint256 layer1;
        uint256 layer2;
        uint256 layer3;
        uint256 layer4;
        uint256 layer5;
        uint256 layer6;
    }

    uint256 public selltax;
    uint256 public buytax;
    uint256 public transfertax;

    uint256 public claimBNBLimit;
    uint256 public reinvestLimit;
    uint256 private reserve_1;

    address public reservewallet;
    address public teamwallet;
    address public marketingwallet;
    address public stackingWallet;
    
    uint256 private _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public minTokenNumberToSell; 
    uint256 public minTokenNumberUpperlimit;

    uint256 public rewardHardcap;

    Tokenomics public tokenomics;
    
    struct Tokenomics {
        uint256 bnbReward;
        uint256 liquidity;
        uint256 marketing;
        uint256 reflection;
        uint256 reserve;
    }

    uint256 private _Reflection;
    uint256 private _Tokenomics;

    address public triggerwallet;

    mapping(address => bool) public pairAddresses;

    address public HodlMasterChef;

    //Stacking
    struct stacking {
        uint256 stackingLimit;
        uint256 stackingCounter;
        uint256 amount;
        uint256 hardcap;
        uint256 cycle;
        bool enabled;
    }
    mapping(address => stacking) public rewardStacking;
    bool public stackingEnabled;

    mapping(address => uint256) private antiFlip;

    //LayerTax public antiFlipTax;

    function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(100000);
    }

    function setExcludeFromMaxTx(address _address, bool value) public onlyOwner{
        _isExcludedFromMaxTx[_address] = value;
    }

    function calculateBNBReward(address ofAddress) public view returns (uint256){
        uint256 totalsupply = uint256(_tTotal)
            .sub(balanceOf(address(0)))
            .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        
        return Utils.calculateBNBReward(
                balanceOf(address(ofAddress)),
                address(this).balance,
                totalsupply,
                rewardHardcap
            );
    }

    /*
    function getRewardCycleBlock() public view returns (uint256) {
        if (block.timestamp >= disableEasyRewardFrom) return rewardCycleBlock;
        return easyRewardCycleBlock;
    }
    */

    function redeemRewards(uint256 perc) public isHuman nonReentrant {
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: next available not reached");
        require(balanceOf(msg.sender) >= 0, "Error: must own HODL to claim reward");
        require(!rewardStacking[msg.sender].enabled, "Error: stacking enabled");

        //uint256 reward = calculateBNBReward(msg.sender); test -> calculate here saved 2 function calls
        uint256 totalsupply = uint256(_tTotal)
            .sub(balanceOf(address(0)))
            .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        uint256 currentBNBPool = address(this).balance;

        uint256 reward = currentBNBPool > rewardHardcap ? rewardHardcap.mul(balanceOf(msg.sender)).div(totalsupply) : currentBNBPool.mul(balanceOf(msg.sender)).div(totalsupply);

        uint256 rewardreinvest;
        uint256 rewardBNB;

        if (perc == 100) {
            require(reward > claimBNBLimit, "Reward below gas fee");
            rewardBNB = reward;
        } else if (perc == 0) {     
            rewardreinvest = reward;
        } else {
            rewardBNB = reward.mul(perc).div(100);
            rewardreinvest = reward.sub(rewardBNB);
        }

        // BNB REINVEST
        if (perc < 100) {
            
            require(reward > reinvestLimit, "Reward below gas fee");

            // Re-InvestTokens
            uint256 expectedtoken = Utils.getAmountsout(rewardreinvest, address(pancakeRouter));

            // update reinvest rewards
            userreinvested[msg.sender] += expectedtoken;
            totalreinvested += expectedtoken;

            _transfer(address(this), msg.sender, expectedtoken);

            // buy tokens
            /*
            if (_isExcludedFromFee[msg.sender]) {
                Utils.swapETHForTokens(address(pancakeRouter), msg.sender, rewardreinvest);  
            } else {
                _isExcludedFromFee[msg.sender] = true;
                Utils.swapETHForTokens(address(pancakeRouter), msg.sender, rewardreinvest);
                _isExcludedFromFee[msg.sender] = false;
            }
            */
        }

        // BNB CLAIM
        if (rewardBNB > 0) {
            uint256 rewardfee;
            bool success;
            // deduct tax
            if (rewardBNB < 0.1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer1).div(100);
            } else if (rewardBNB < 0.25 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer2).div(100);
            } else if (rewardBNB < 0.5 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer3).div(100);
            } else if (rewardBNB < 0.75 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer4).div(100);
            } else if (rewardBNB < 1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer5).div(100);
            } else {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer6).div(100);
            }
            rewardBNB -= rewardfee;
            (success, ) = address(reservewallet).call{value: rewardfee}("");
            require(success, " Error: Cannot send reward");

            // send bnb to user
            (success, ) = address(msg.sender).call{value: rewardBNB}("");
            require(success, "Error: Cannot withdraw reward");

            // update claimed rewards
            userClaimedBNB[msg.sender] += rewardBNB;
            totalClaimedBNB += rewardBNB;
        }

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimBNBSuccessfully(msg.sender,reward,nextAvailableClaimDate[msg.sender]);
    }

    function topUpClaimCycleAfterTransfer(address _sender, address _recipient, uint256 amount) private {
        //_recipient
        uint256 currentBalance = balanceOf(_recipient);
        if ((_recipient == owner() && nextAvailableClaimDate[_recipient] == 0) || currentBalance == 0) {
                nextAvailableClaimDate[_recipient] = block.timestamp + rewardCycleBlock;
        } else {
            nextAvailableClaimDate[_recipient] += Utils.calculateTopUpClaim(
                                                currentBalance,
                                                rewardCycleBlock,
                                                threshHoldTopUpRate,
                                                amount);
            if (nextAvailableClaimDate[_recipient] > block.timestamp + rewardCycleBlock) {
                nextAvailableClaimDate[_recipient] = block.timestamp + rewardCycleBlock;
            }
        }

        //sender
        if (_recipient != HodlMasterChef) {
            currentBalance = balanceOf(_sender);
            if ((_sender == owner() && nextAvailableClaimDate[_sender] == 0) || currentBalance == 0) {
                    nextAvailableClaimDate[_sender] = block.timestamp + rewardCycleBlock;
            } else {
                nextAvailableClaimDate[_sender] += Utils.calculateTopUpClaim(
                                                    currentBalance,
                                                    rewardCycleBlock,
                                                    threshHoldTopUpRate,
                                                    amount);
                if (nextAvailableClaimDate[_sender] > block.timestamp + rewardCycleBlock) {
                    nextAvailableClaimDate[_sender] = block.timestamp + rewardCycleBlock;
                }                                     
            }
        }
    }

    function ensureMaxTxAmount(address from, address to, uint256 amount) private {
        if (
            _isExcludedFromMaxTx[from] == false && // default will be false
            _isExcludedFromMaxTx[to] == false // default will be false
        ) {
            //if (value < disruptiveCoverageFee && block.timestamp >= disruptiveTransferEnabledFrom) { 
                WalletAllowance storage wallet = userWalletAllowance[from];

                if (block.timestamp > wallet.timestamp.add(daySeconds)) {
                    wallet.timestamp = 0;
                    wallet.amount = 0;
                }

                uint256 totalAmount = wallet.amount.add(amount);

                require(
                    totalAmount <= _maxTxAmount,
                    "Amount is more than the maximum limit"
                );

                if (wallet.timestamp == 0) {
                    wallet.timestamp = block.timestamp;
                }

                wallet.amount = totalAmount;
            //}
        }
    }

    /*
    function disruptiveTransfer(address recipient, uint256 amount) public payable returns (bool){
        _transfer(_msgSender(), recipient, amount, msg.value);
        return true;
    }
    */

    function swapAndLiquify(address from, address to) private lockTheSwap {

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 initialBalance = address(this).balance;

        if (contractTokenBalance >= minTokenNumberUpperlimit &&
            initialBalance <= rewardHardcap &&
            swapAndLiquifyEnabled &&
            from != pancakePair &&
            !(from == address(this) && to == address(pancakePair))
            ) {             
                Utils.swapTokensForEth(address(pancakeRouter), minTokenNumberToSell);       
                uint256 deltaBalance = address(this).balance.sub(initialBalance);

                if (tokenomics.marketing > 0) {
                    // send marketing rewards
                    (bool sent, ) = payable(address(marketingwallet)).call{value: deltaBalance.mul(tokenomics.marketing).div(_Tokenomics)}("");
                    require(sent, "Error: Cannot send reward");
                }

                if (tokenomics.reserve > 0) {
                    // send resere rewards
                    (bool succ, ) = payable(address(reservewallet)).call{value: deltaBalance.mul(tokenomics.reserve).div(_Tokenomics)}("");
                    require(succ, "Error: Cannot send reward");
                }   

                if (tokenomics.liquidity > 0) {
                    // add liquidity to pancake
                    uint256 liquidityToken = minTokenNumberToSell.mul(tokenomics.liquidity).div(_Tokenomics);
                    Utils.addLiquidity(
                        address(pancakeRouter),
                        owner(),
                        liquidityToken,
                        deltaBalance.mul(tokenomics.liquidity).div(_Tokenomics)
                    ); 
                    emit SwapAndLiquify(liquidityToken, deltaBalance, liquidityToken);
                }          
            }
    }

    function triggerSwapAndLiquify() public lockTheSwap {
        require(((_msgSender() == address(triggerwallet)) || (_msgSender() == owner())) && swapAndLiquifyEnabled, "Wrong caller or swapAndLiquify not enabled");

        uint256 initialBalance = address(this).balance;

        //check triggerwallet balance
        if (address(triggerwallet).balance < 0.1 ether && initialBalance > 0.1 ether) {
            (bool sent, ) = payable(address(triggerwallet)).call{value: 0.1 ether}("");
            require(sent, "Error: Cannot send gas fee");
            initialBalance = address(this).balance;
        }

        Utils.swapTokensForEth(address(pancakeRouter), minTokenNumberToSell);       
        uint256 deltaBalance = address(this).balance.sub(initialBalance);

        if (tokenomics.marketing > 0) {
            // send marketing rewards
            (bool sentm, ) = payable(address(marketingwallet)).call{value: deltaBalance.mul(tokenomics.marketing).div(_Tokenomics)}("");
            require(sentm, "Error: Cannot send reward");
        }

        if (tokenomics.reserve > 0) {
            // send resere rewards
            (bool sentr, ) = payable(address(reservewallet)).call{value: deltaBalance.mul(tokenomics.reserve).div(_Tokenomics)}("");
            require(sentr, "Error: Cannot send reward");
        }

        if (tokenomics.liquidity > 0) {
            // add liquidity to pancake
            uint256 liquidityToken = minTokenNumberToSell.mul(tokenomics.liquidity).div(_Tokenomics);
            Utils.addLiquidity(
                address(pancakeRouter),
                owner(),
                liquidityToken,
                deltaBalance.mul(tokenomics.liquidity).div(_Tokenomics)
            ); 
            emit SwapAndLiquify(liquidityToken, deltaBalance, liquidityToken);
        }
    }

    function changerewardCycleBlock(uint256 newcycle) public onlyOwner {
        rewardCycleBlock = newcycle;
    }

    function changereservewallet(address payable _newaddress) public onlyOwner {
        reservewallet = _newaddress;
    }

    function changemarketingwallet(address payable _newaddress) public onlyOwner {
        marketingwallet = _newaddress;
    }

    function changeStackingWallet(address payable _newaddress) public onlyOwner {
        stackingWallet = _newaddress;
    }

    function changetriggerwallet(address payable _newaddress) public onlyOwner {
        triggerwallet = _newaddress;
    }

    // disable enable reflection fee , value == false (enable)
    function reflectionfeestartstop(bool _value) public onlyOwner {
        reflectionFeesDisabled = _value;
    }

    function migrateToken(address _newadress, uint256 _amount) public onlyOwner{
        removeAllFee();
        _transferStandard(address(this), _newadress, _amount);
        restoreAllFee();
    }

    function migrateWBnb(address _newadress, uint256 _amount) public onlyOwner {
        IWBNB(payable(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c))).transfer(_newadress,_amount);
    }

    function migrateBnb(address payable _newadd, uint256 amount) public onlyOwner{
        (bool success, ) = address(_newadd).call{value: amount}("");
        require(success, "Address: unable to send value, charity may have reverted");
    }

    function changeThreshHoldTopUpRate(uint256 _newrate) public onlyOwner {
        threshHoldTopUpRate = _newrate;
    }

    function changeSelltax(uint256 _selltax) public onlyOwner {
        selltax = _selltax;  
    }

    function changeBuytax(uint256 _buytax) public onlyOwner {
        buytax = _buytax;
    }

    function changeTransfertax(uint256 _transfertax) public onlyOwner {
        transfertax = _transfertax;
    }

    function changeTokenomics(uint256 bnbReward, uint256 liquidity, uint256 marketing, uint256 reflection, uint256 reserve) public onlyOwner {
        require(bnbReward + liquidity + marketing + reflection + reserve == 100, "Have to be 100 in total");
        tokenomics = Tokenomics(bnbReward, liquidity, marketing, reflection, reserve);
        updateTokenomics();
    }

    function changebnbclaimtax(uint256 _layer1, uint256 _layer2, uint256 _layer3, uint256 _layer4, uint256 _layer5, uint256 _layer6) public onlyOwner {
        bnbClaimTax = LayerTax(_layer1, _layer2, _layer3, _layer4, _layer5, _layer6);
    }           

    /*
    function changereinvesttax(uint256 _layer1, uint256 _layer2, uint256 _layer3, uint256 _layer4, uint256 _layer5, uint256 _layer6) public onlyOwner {
        reinvestTax = LayerTax(_layer1, _layer2, _layer3, _layer4, _layer5, _layer6);
    }
    */

    function changeminTokenNumberToSell(uint256 _newvalue) public onlyOwner {
        require(_newvalue <= minTokenNumberUpperlimit, "Incorrect Value");
        minTokenNumberToSell = _newvalue;
    }

    function changeminTokenNumberUpperlimit(uint256 _newvalue) public onlyOwner {
        require(_newvalue >= minTokenNumberToSell, "Incorrect Value");
        minTokenNumberUpperlimit = _newvalue;
    }

    function changerewardHardcap(uint256 _newvalue) public onlyOwner {
        rewardHardcap = _newvalue;
    }

    function updateTokenomics() private {
        _Reflection = tokenomics.reflection;
        _Tokenomics = tokenomics.bnbReward.add
                      (tokenomics.marketing).add
                      (tokenomics.liquidity).add
                      (tokenomics.reserve);
    }

    function updatePairAddress(address _pairAddress, bool _enable) public onlyOwner {
        require(pairAddresses[_pairAddress] != _enable, "Will have no effect..");
        pairAddresses[_pairAddress] = _enable;
    }

    function initializeUpgradedContract() public onlyOwner {
        stackingCounterStart = block.timestamp;
        stackingEnabled = true;
        antiFlipTax[0] = 150;
        antiFlipTax[1] = 125;
        antiFlipTax[2] = 100;
        antiFlipTax[3] = 50;
        antiFlipTax[4] = 25;
        antiFlipTax[5] = 0;
    }

    function changeclaimBNBLimit(uint256 _newvalue) public onlyOwner {
        claimBNBLimit = _newvalue;
    }

    function changereinvestLimit(uint256 _newvalue) public onlyOwner {
        reinvestLimit = _newvalue;
    }

    function changeHODLMasterChef(address _newaddress) public onlyOwner {
        HodlMasterChef = _newaddress;
    }

    function getStackingCounter(uint256 cycle) private view returns (uint256) {
        return (block.timestamp-stackingCounterStart) / cycle;
    }

    function enableStacking(bool _value) public onlyOwner {
        stackingEnabled = _value;
    }

    function changeBNBstackingLimit(uint256 _newvalue) public onlyOwner {
        bnbStackingLimit = _newvalue;
    }

    function startStacking() public {
        
        uint256 balance = balanceOf(msg.sender)-1;

        require(stackingEnabled && !rewardStacking[msg.sender].enabled, "Not available");
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: next available not reached");
        require(balance > 0, "Error: Wrong amount");
        require(calculateBNBReward(msg.sender) < bnbStackingLimit, "Reward higher than stacking limit");

        rewardStacking[msg.sender] = stacking(bnbStackingLimit, (block.timestamp-stackingCounterStart) / rewardCycleBlock, balance, rewardHardcap, rewardCycleBlock, true);
        removeAllFee();
        _transferStandard(msg.sender, stackingWallet, balance);
    }

    function getStacked(address _address) public view returns (uint256) {
        //require(rewardStacking[_address].enabled, "Stacking not enabled");
        uint256 reward;
        if (rewardStacking[_address].enabled) {
            uint256 stacked = getStackingCounter(rewardStacking[_address].cycle) - rewardStacking[_address].stackingCounter;

            uint256 totalsupply = uint256(_tTotal)
                .sub(balanceOf(address(0)))
                .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
                .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet

            uint256 currentBNBPool;
            for(uint256 i = 1; i<=stacked; i++) {
                currentBNBPool = address(this).balance - reward;
                reward += currentBNBPool > rewardStacking[_address].hardcap ? rewardStacking[_address].hardcap.mul(rewardStacking[_address].amount).div(totalsupply) : currentBNBPool.mul(rewardStacking[_address].amount).div(totalsupply);
            }

        }
        return reward > rewardStacking[_address].stackingLimit ? rewardStacking[_address].stackingLimit : reward;
    }

    function stopStackingAndClaim(uint256 perc) public nonReentrant {
        require(rewardStacking[msg.sender].enabled, "Stacking not enabled");
        uint256 stacked = getStackingCounter(rewardStacking[msg.sender].cycle) - rewardStacking[msg.sender].stackingCounter;
        require(stacked > 0, "Error: Nothing stacked");

        uint256 rewardBNB;
        uint256 rewardreinvest;

        uint256 reward = getStacked(msg.sender);

        if (perc == 100) {
            //require(reward > claimBNBLimit, "Reward below gas fee");
            rewardBNB = reward;
        } else if (perc == 0) {     
            rewardreinvest = reward;
        } else {
            rewardBNB = reward.mul(perc).div(100);
            rewardreinvest = reward.sub(rewardBNB);
        }

        // BNB REINVEST
        if (perc < 100) {
            
            //require(reward > reinvestLimit, "Reward below gas fee");

            // Re-InvestTokens
            uint256 expectedtoken = Utils.getAmountsout(rewardreinvest, address(pancakeRouter));

            // update reinvest rewards
            userreinvested[msg.sender] += expectedtoken;
            totalreinvested += expectedtoken;
            _tokenTransfer(address(this), msg.sender, expectedtoken, false);

        }

        // BNB CLAIM
        if (rewardBNB > 0) {
            uint256 rewardfee;
            bool success;
            // deduct tax
            if (rewardBNB < 0.1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer1).div(100);
            } else if (rewardBNB < 0.25 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer2).div(100);
            } else if (rewardBNB < 0.5 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer3).div(100);
            } else if (rewardBNB < 0.75 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer4).div(100);
            } else if (rewardBNB < 1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer5).div(100);
            } else {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer6).div(100);
            }
            rewardBNB -= rewardfee;
            (success, ) = address(reservewallet).call{value: rewardfee}("");
            require(success, " Error: Cannot send reward");

            // send bnb to user
            (success, ) = address(msg.sender).call{value: rewardBNB}("");
            require(success, "Error: Cannot withdraw reward");

            // update claimed rewards
            userClaimedBNB[msg.sender] += rewardBNB;
            totalClaimedBNB += rewardBNB;
        }

        _tokenTransfer(stackingWallet, msg.sender, rewardStacking[msg.sender].amount, false);

        stacking memory tmpStack;
        tmpStack.enabled = false;
        tmpStack.amount = 0;
        rewardStacking[msg.sender] = tmpStack;

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimBNBSuccessfully(msg.sender,reward,nextAvailableClaimDate[msg.sender]);
    }

    function changeAntiFlipTax(uint256 _value, uint8 _layer) public onlyOwner {
        require(_value >= 0 && _value <= 1000, "Error: value");
        require(_layer >= 0 && _value <= 5, "Error: layer");
        antiFlipTax[_layer] = _value;
    }

}