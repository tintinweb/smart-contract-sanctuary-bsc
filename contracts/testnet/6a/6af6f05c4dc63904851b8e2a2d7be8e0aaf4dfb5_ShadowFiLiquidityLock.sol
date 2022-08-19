/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// File: ShadowFiLiquidityVault.sol


pragma solidity ^0.8.4;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IPancakeRouter {
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

interface IShadowFiToken {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function airdropped(address account) external view returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function burn(address account, uint256 amount) external;
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract ShadowFiLiquidityLock is Ownable, ReentrancyGuard {
    IPancakePair private pancakePairToken;
    IPancakeRouter private pancakeRouter;
    IShadowFiToken private shadowFiToken;
    uint256 private lockTime;
    bool private lockEnded;

    event burntShadowFi(
        uint256 removedAmountFromLiquidity,
        uint256 totalAmountBurnt
    );
    event addedLiquidity(uint256 liquidity);

    constructor(
        address _pancakePairToken,
        address _pancakeRouter,
        address _shadowFiToken,
        uint256 _lockTime
    ) {
        pancakePairToken = IPancakePair(_pancakePairToken);
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        shadowFiToken = IShadowFiToken(_shadowFiToken);
        lockTime = _lockTime;
        lockEnded = false;
    }

    /*******************************************************************************************************/
    /************************************* Admin Functions *************************************************/
    /*******************************************************************************************************/
    function endLock() public onlyOwner {
        require(!lockEnded, "You already claimed all LP tokens.");
        require(block.timestamp >= lockTime, "LP tokens are still locked.");

        pancakePairToken.transfer(
            owner(),
            pancakePairToken.balanceOf(address(this))
        );
        lockEnded = true;
    }

    function extendLockTime(uint256 _extraLockTime) public onlyOwner {
        require(!lockEnded, "You already claimed all LP tokens.");
        require(_extraLockTime > 0, "Invalid extra lock time is provided.");

        lockTime += _extraLockTime;
    }

    function withdrawBNB() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function withdrawTokens(address _token) public onlyOwner {
        require(_token != address(0), "Invalid parameter is provided.");
        require(
            _token != address(pancakePairToken),
            "You can't withdraw LP token."
        );

        IERC20 token = IERC20(_token);
        uint256 amount = token.balanceOf(address(this));
        token.transfer(address(msg.sender), amount);
    }

    function buyAndBurnExcess() public onlyOwner {
        uint256 lpOwnershipPercent = (pancakePairToken.balanceOf(
            address(this)
        ) * 10000) / pancakePairToken.totalSupply();
        uint256 liquidTokens = (shadowFiToken.balanceOf(
            address(pancakePairToken)
        ) * lpOwnershipPercent) / 10000;
        uint256 liquidPercent = ((liquidTokens * 10000) /
            shadowFiToken.totalSupply());

        require(
            liquidPercent > 800,
            "The amount of ShadowFi tokens in liquidity should be 8%+ of the totalSupply."
        );

        uint256 removeAmount = ((liquidPercent - 800) *
            (pancakePairToken.totalSupply() * lpOwnershipPercent)) / 100000000;

        pancakePairToken.approve(address(pancakeRouter), removeAmount);

        (uint256 amountToken, uint256 amountBNB) = pancakeRouter
            .removeLiquidityETH(
                address(shadowFiToken),
                removeAmount,
                0,
                0,
                address(this),
                block.timestamp + 120
            );

        IERC20 wBNB = IERC20(pancakeRouter.WETH());
        wBNB.approve(address(pancakeRouter), amountBNB);

        address receiver = address(this);
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(shadowFiToken);
        uint256[] memory amounts = pancakeRouter.swapExactETHForTokens{
            value: amountBNB
        }(0, path, receiver, block.timestamp + 120);

        uint256 sumAmount = amounts[amounts.length - 1] + amountToken;
        shadowFiToken.burn(address(this), sumAmount);

        emit burntShadowFi(amountToken, sumAmount);
    }

    function buyAndBurnExcessAmount(uint256 percent) public onlyOwner {
        uint256 lpOwnershipPercent = (pancakePairToken.balanceOf(
            address(this)
        ) * 10000) / pancakePairToken.totalSupply();
        uint256 liquidTokens = (shadowFiToken.balanceOf(
            address(pancakePairToken)
        ) * lpOwnershipPercent) / 10000;
        uint256 liquidPercent = ((liquidTokens * 10000) /
            shadowFiToken.totalSupply());

        require(
            liquidPercent > 800,
            "The amount of ShadowFi tokens in liquidity should be 8%+ of the totalSupply."
        );
        require(
            percent - liquidPercent <= 800,
            "The amount compared to liquidi tokens should be less than 8% of the totalSupply."
        );

        uint256 removeAmount = ((percent - liquidPercent) *
            (pancakePairToken.totalSupply() * lpOwnershipPercent)) / 100000000;

        pancakePairToken.approve(address(pancakeRouter), removeAmount);

        (uint256 amountToken, uint256 amountBNB) = pancakeRouter
            .removeLiquidityETH(
                address(shadowFiToken),
                removeAmount,
                0,
                0,
                address(this),
                block.timestamp + 120
            );

        IERC20 wBNB = IERC20(pancakeRouter.WETH());
        wBNB.approve(address(pancakeRouter), amountBNB);

        address receiver = address(this);
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(shadowFiToken);
        uint256[] memory amounts = pancakeRouter.swapExactETHForTokens{
            value: amountBNB
        }(0, path, receiver, block.timestamp + 120);

        uint256 sumAmount = amounts[amounts.length - 1] + amountToken;
        shadowFiToken.burn(address(this), sumAmount);

        emit burntShadowFi(amountToken, sumAmount);
    }

    /*******************************************************************************************************/
    /************************************* Public Functions ************************************************/
    /*******************************************************************************************************/
    function addLiquidity(uint256 _amountToken) external payable {
        require(_amountToken > 0, "Invalid parameter is provided.");
        require(msg.value > 0, "You should fund this contract with BNB.");

        shadowFiToken.transferFrom(
            address(msg.sender),
            address(this),
            _amountToken
        );

        shadowFiToken.approve(address(pancakeRouter), _amountToken);

        (
            uint256 amountToken,
            uint256 amountBNB,
            uint256 liquidity
        ) = pancakeRouter.addLiquidityETH{value: msg.value}(
                address(shadowFiToken),
                _amountToken,
                0,
                0,
                address(this),
                block.timestamp + 120
            );

        // Return excess token and BNB
        uint256 excessAmountToken = _amountToken - amountToken;
        uint256 excessAmountBNB = msg.value - amountBNB;

        if (excessAmountToken > 0) {
            shadowFiToken.transfer(msg.sender, excessAmountToken);
        }

        if (excessAmountBNB > 0) {
            payable(msg.sender).transfer(excessAmountBNB);
        }

        emit addedLiquidity(liquidity);
    }
}