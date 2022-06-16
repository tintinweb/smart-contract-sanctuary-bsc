// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./IERC20.sol";

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IERC20 {
    function getDecimal() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IPancakeSwapPair {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IPancakeSwapRouter {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IPancakeSwapFactory {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IMoonBoxAffiliate {
    function setAffiliateRevenue(
        address from,
        uint256 amount,
        bool isBuy
    ) external;

    function claim() external;

    function getAffiliate(address _address) external view returns (uint256, uint256);

    function getF0(address _address) external view returns (address);

    function getTotalAffiliateBuy() external view returns (uint256);

    function getTotalAffiliateSell() external view returns (uint256);

    event SetF0(address f0, address f1);
    event SetAffiliateRevenue(address from, address to, uint32 level, uint256 amount);
    event Claim(address addr, uint256 amount, uint256 amountBnb);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IERC20.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapPair.sol";
import "./IMoonBoxAffiliate.sol";
import "./IMoonBoxLottery.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract MoonBoxAffiliate is Ownable, ReentrancyGuard, IMoonBoxAffiliate {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Affiliate {
        uint256 amount;
        uint256 totalClaim;
        uint256 totalClaimBnb;
    }

    mapping(address => bool) public _operators;
    uint256 totalAffiliateBuy = 140;
    uint256 totalAffiliateSell = 80;
    uint256[] affiliateBuyLevel = [80, 30, 10, 10, 5, 3, 2];
    uint256[] affiliateSellLevel = [50, 10, 10, 4, 3, 2, 1];
    uint256 holdAmountInBnb = 0.001 * 10**18;
    uint256 constant denominator = 1000;
    mapping(address => address) affiliateLevels;
    mapping(address => Affiliate) affiliates;
    IPancakeSwapPair public pair;
    IPancakeSwapRouter public router;
    uint256 public totalReceived;
    IERC20 public token;
    address public treasuryWallet;
    IMoonBoxLottery public moonboxLottery;

    modifier onlyOperator() {
        require(_operators[msg.sender], "Forbidden");
        _;
    }

    constructor(address _treasuryWallet) {
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        treasuryWallet = _treasuryWallet;
        _operators[msg.sender] = true;
        _operators[address(router)] = true;
    }

    function setF0(address _f1) external {
        require(_f1 != address(0), "0 address");
        require(_f1 != msg.sender, "Add yourself");
        require(affiliateLevels[msg.sender] == address(0), "Already add");
        require(!isContract(_f1), "Invalid address");

        address parentF = _f1;
        for (uint32 i = 1; i <= 8; i++) {
            parentF = affiliateLevels[parentF];
            require(parentF == address(0) || parentF != msg.sender, "Circle");
        }
        affiliateLevels[msg.sender] = _f1;
        emit SetF0(msg.sender, _f1);
    }

    function setAffiliateRevenue(
        address from,
        uint256 amount,
        bool isBuy
    ) external override onlyOperator {
        address f1 = affiliateLevels[from];
        uint256 totalFee = isBuy ? totalAffiliateBuy : totalAffiliateSell;
        uint256 payoutAmount = 0;
        for (uint32 i = 0; i <= 6; i++) {
            if (f1 != address(0)) {
                uint256 levelFee = isBuy
                    ? affiliateBuyLevel[i]
                    : affiliateSellLevel[i];
                if (levelFee == 0) {
                    f1 = affiliateLevels[f1];
                    continue;
                }
                uint256 f1Amount = amount
                    .mul(levelFee.mul(denominator).div(totalFee))
                    .div(denominator);
                affiliates[f1].amount = affiliates[f1].amount.add(f1Amount);
                emit SetAffiliateRevenue(from, f1, i + 1, f1Amount);
                f1 = affiliateLevels[f1];
                payoutAmount = payoutAmount.add(f1Amount);
            } else {
                break;
            }
        }
        totalReceived = totalReceived.add(payoutAmount);
        uint256 unRefAmount = amount.sub(payoutAmount);
        if (unRefAmount > 0) {
            try moonboxLottery.donate(unRefAmount.div(2)) {} catch {}
        }
    }

    function claim() external override nonReentrant {
        uint256 claimAmount = affiliates[msg.sender].amount;
        require(claimAmount > 0, "Not enough balance to claim");
        affiliates[msg.sender].amount = 0;
        affiliates[msg.sender].totalClaim = affiliates[msg.sender]
            .totalClaim
            .add(claimAmount);

        uint256 amountBnbPayout = swapTokenToBnb(claimAmount, msg.sender);
        affiliates[msg.sender].totalClaimBnb = affiliates[msg.sender]
            .totalClaimBnb
            .add(amountBnbPayout);
        emit Claim(msg.sender, claimAmount, amountBnbPayout);
    }

    function setPair(address _pair) external onlyOwner {
        pair = IPancakeSwapPair(pair);
    }

    function setHoldAmountInBnb(uint256 value) external onlyOwner {
        holdAmountInBnb = value;
    }

    function setAffiliateBuyLevel(
        uint256 _totalAffBuy,
        uint256[] calldata _affBuyLevel
    ) external onlyOwner {
        totalAffiliateBuy = _totalAffBuy;
        for (uint32 i = 0; i < 7; i++) {
            affiliateBuyLevel[i] = _affBuyLevel[i];
        }
    }

    function setAffiliateSellLevel(
        uint256 _totalAffSell,
        uint256[] calldata _affSellLevel
    ) external onlyOwner {
        totalAffiliateSell = _totalAffSell;
        for (uint32 i = 0; i < 7; i++) {
            affiliateSellLevel[i] = _affSellLevel[i];
        }
    }

    function getAffiliate(address _address)
        external
        view
        override
        returns (uint256, uint256)
    {
        return (affiliates[_address].amount, affiliates[_address].totalClaim);
    }

    function getF0(address _address) external view override returns (address) {
        return affiliateLevels[_address];
    }

    function getTotalAffiliateBuy() external view override returns (uint256) {
        return totalAffiliateBuy;
    }

    function getTotalAffiliateSell() external view override returns (uint256) {
        return totalAffiliateSell;
    }

    function getAffiliateBuyLevel(uint256 index)
        external
        view
        returns (uint256)
    {
        return affiliateBuyLevel[index];
    }

    function getAffiliateSellLevel(uint256 index)
        external
        view
        returns (uint256)
    {
        return affiliateSellLevel[index];
    }

    function swapTokenToBnb(uint256 amountToSwap, address to)
        internal
        returns (uint256 amountEthPayout)
    {
        uint256 balanceBefore = to.balance;
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            to,
            block.timestamp
        );
        amountEthPayout = to.balance.sub(balanceBefore);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setOperator(address operatorAddress, bool value)
        external
        onlyOwner
    {
        require(
            operatorAddress != address(0),
            "operatorAddress is zero address"
        );
        _operators[operatorAddress] = value;
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "zero address");
        token = IERC20(_token);
    }

    function setTreasuryWallet(address _treasuryWallet) external onlyOwner {
        require(_treasuryWallet != address(0), "zero address");
        treasuryWallet = _treasuryWallet;
    }

    function setLottery(address _moonboxLottery) external onlyOwner {
        require(_moonboxLottery != address(0), "zero address");
        moonboxLottery = IMoonBoxLottery(_moonboxLottery);
    }

    function approveToken(address token, address spender) external onlyOwner {
        IERC20(token).approve(spender, uint256(-1));
    }

    function withdrawToTreasury() external onlyOwner {
        uint256 swapAmount = token.balanceOf(address(this)).sub(totalReceived);
        require(
            swapAmount > 0,
            "There is no token deposited in token contract"
        );
        swapTokenToBnb(swapAmount, treasuryWallet);
    }

    function withdrawToken(address tokenAddress, address recepient)
        external
        onlyOwner
    {
        IERC20 erc20 = IERC20(tokenAddress);
        require(
            erc20.transfer(recepient, erc20.balanceOf(address(this))),
            "Failure withdraw"
        );
    }

    function withdrawBnb() external onlyOwner {
        address payable sender = payable(msg.sender);
        sender.transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IMoonBoxLottery {
    function donate(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}