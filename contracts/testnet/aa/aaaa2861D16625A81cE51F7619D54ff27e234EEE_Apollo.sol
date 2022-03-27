/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

// SPDX-License-Identifier: MIT
// File @uniswap/v2-core/contracts/interfaces/[email protected]

pragma solidity >=0.5.0;

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


// File contracts/apollo/Ownable.sol


pragma solidity ^0.8.0;



abstract contract Ownable  {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }



    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "onlyOwner");
        _;
    }


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
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

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


// File contracts/apollo/IApollo.sol


// Apollo PROTOCOL COPYRIGHT (C) 2022

pragma solidity ^0.8.0;

interface IApollo is IERC20, IERC20Metadata {
    function getCirculatingSupply() external view returns (uint256);
}


// File contracts/apollo/Apollo.sol


// Apollo PROTOCOL COPYRIGHT (C) 2022

pragma solidity ^0.8.0;
// import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";


// import "hardhat/console.sol";

contract Vault is Ownable {
    IUniswapV2Router02 public router;
    IERC20[] public tokens;

    constructor(address _router) {
        router = IUniswapV2Router02(_router);
    }

    function addToken(address token) public onlyOwner {
        uint256 len = tokens.length;
        IERC20 erc20 = IERC20(token);
        for (uint256 i; i < len; i++) {
            require(tokens[i] != erc20, "duplicated token");
        }
        erc20.approve(address(router), type(uint256).max);
        erc20.approve(owner, type(uint256).max);

        tokens.push(erc20);
    }

    function approveFor(address token, address spender) public onlyOwner {
        IERC20 erc20 = IERC20(token);
        erc20.approve(spender, type(uint256).max);
        erc20.approve(owner, type(uint256).max);
    }

    // fallback() external payable {
    //     assembly {
    //         let _target := sload(router.slot)
    //         calldatacopy(0x0, 0x0, calldatasize())
    //         let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
    //         returndatacopy(0x0, 0x0, returndatasize())
    //         switch result
    //         case 0 {
    //             revert(0, 0)
    //         }
    //         default {
    //             return(0, returndatasize())
    //         }
    //     }
    // }

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
        public
        virtual
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (amountA, amountB, liquidity) = router.addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    fallback() external {
        // console.log("Apollo::Vault::fallback:entry");
        // console.logBytes4(msg.sig);
        // console.logBytes(msg.data);
        (bool success, bytes memory data) = address(router).call(msg.data);
        require(success, "forward router faild");
        // console.log("Apollo::Vault::fallback:end");
    }
}

interface BalanceAble {
    function balanceOf(address user) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Apollo is IApollo, Ownable {
    string public constant override name = "apl";
    string public constant override symbol = "APL";
    uint8 public constant override decimals = 5;

    uint8 public constant RATE_DECIMALS = 7;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 300000 * 10**decimals;
    uint256 private constant PRESALE_FRAGMENTS_SUPPLY = 250000 * 10**decimals;
    uint256 private constant TOTAL_GONS = type(uint256).max - (type(uint256).max % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = 6000000000 * 10**decimals;

    uint256 public override totalSupply;

    uint256 public liquidityFee = 40;
    uint256 public treasuryFee = 25;
    uint256 public apolloInsuranceFundFee = 50;
    uint256 public sellFee = 20;
    uint256 public burnFee = 25;
    uint256 public totalFee = liquidityFee + treasuryFee + apolloInsuranceFundFee + burnFee;
    uint256 public constant feeDenominator = 1000; // ‰

    uint256 public immutable deployedAt;

    uint256 public initRebaseStartTime;
    uint256 public lastRebasedTime;
    uint256 public lastAddLiquidityTime;
    uint256 private _gonsPerFragment;

    // Anti the bots and whale on fair launch
    uint256 public maxSafeSwapAmount;
    uint256 public safeSwapInterval;
    uint256 public botTaxFee;
    uint256 public whaleTaxFee;
    // ------------------------------

    // circuit breaker Anti dump for panic selling
    uint256 public circuitBreakerEpochDuration;
    uint256 public circuitBreakerPriceThreshold;
    uint256 public circuitBreakerBuyTaxFee;
    uint256 public circuitBreakerSellTaxFee;
    // ------------------------

    IERC20 public usdcToken;
    IUniswapV2Router02 public router;
    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public apolloInsuranceFundReceiver;
    address public burnPool;
    address public pair;
    Vault public apolloVault;
    BalanceAble public apolloNft;

    bool _inSwap;
    bool public autoRebase;
    bool public autoAddLiquidity;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isFeeExemptOrigin;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    mapping(address => uint256) public lastSwapAt;
    mapping(uint256 => uint256) public priceBycircuitBreakerEpoch;
    mapping(uint256 => bool) public shouldCircuitBreakerByEpoch;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    modifier validRecipient(address to) {
        require(to != address(0));
        _;
    }
    modifier swapping() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor(
        IERC20 usdc,
        IUniswapV2Router02 _router,
        address presaleAddress
    ) {
        deployedAt = block.timestamp;

        maxSafeSwapAmount = 100 * 10**decimals;
        safeSwapInterval = 1 minutes;
        whaleTaxFee = 350; // ‰
        botTaxFee = 400; // ‰

        // circuit breaker
        circuitBreakerEpochDuration = 10 minutes;
        circuitBreakerPriceThreshold = 100; // ‰
        circuitBreakerBuyTaxFee = 70; // ‰
        circuitBreakerSellTaxFee = 320; // ‰

        usdcToken = usdc;
        router = _router;
        pair = IUniswapV2Factory(_router.factory()).createPair(address(usdc), address(this));

        autoLiquidityReceiver = 0xE1A0b2a8FF9C17b80f558eC002e7E857c0D062FD; //2
        treasuryReceiver = 0xfFde24E2Ab5f2c9cbc95118777cD68a4aAF05647; //1
        apolloInsuranceFundReceiver = 0x6e1D3DD0fC635805bEE48eFDad5D6f4A3a4508BE; //3
        burnPool = address(0xdead); //4

        _allowedFragments[address(this)][address(_router)] = type(uint256).max;
        _allowedFragments[presaleAddress][address(_router)] = type(uint256).max;
        usdc.approve(address(_router), type(uint256).max);

        totalSupply = INITIAL_FRAGMENTS_SUPPLY;

        // save gas
        uint256 initalGonPerFragment = TOTAL_GONS / totalSupply;
        _gonsPerFragment = initalGonPerFragment;
        _gonBalances[treasuryReceiver] = (INITIAL_FRAGMENTS_SUPPLY - PRESALE_FRAGMENTS_SUPPLY) * initalGonPerFragment;
        _gonBalances[presaleAddress] = PRESALE_FRAGMENTS_SUPPLY * initalGonPerFragment;

        initRebaseStartTime = block.timestamp;
        lastRebasedTime = block.timestamp;
        autoRebase = true;
        autoAddLiquidity = true;
        isFeeExempt[treasuryReceiver] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[presaleAddress] = true;
        isFeeExempt[tx.origin] = true;

        // _transferOwnership(treasuryReceiver);
        emit Transfer(address(0), presaleAddress, PRESALE_FRAGMENTS_SUPPLY);
        emit Transfer(address(0), treasuryReceiver, INITIAL_FRAGMENTS_SUPPLY - PRESALE_FRAGMENTS_SUPPLY);
    }

    function initlizeVault() public onlyOwner {
        Vault vault = new Vault(address(router));
        isFeeExempt[address(vault)] = true;
        apolloVault = vault;
        vault.addToken(address(usdcToken));
        vault.addToken(address(this));
    }

    function rebase() internal {
        if (_inSwap) return;
        // console.log("Apollo::rebase", block.number, block.timestamp);
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - initRebaseStartTime;
        uint256 deltaTime = block.timestamp - lastRebasedTime;
        uint256 times = deltaTime / 15 minutes;
        uint256 epoch = times * 15;

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = 2355;
        } else if (deltaTimeFromInit >= (7 * 365 days)) {
            rebaseRate = 2;
        } else if (deltaTimeFromInit >= ((15 * 365 days) / 10)) {
            rebaseRate = 14;
        } else if (deltaTimeFromInit >= (365 days)) {
            rebaseRate = 211;
        }

        for (uint256 i = 0; i < times; i++) {
            totalSupply = (totalSupply * (10**RATE_DECIMALS + rebaseRate)) / (10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS / totalSupply;
        lastRebasedTime += times * 15 minutes;

        IUniswapV2Pair(pair).sync();

        emit LogRebase(epoch, totalSupply);
    }

    function transfer(address to, uint256 value) public override validRecipient(to) returns (bool) {
        return _transferFrom(msg.sender, to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override validRecipient(to) returns (bool) {
        // console.log("Apollo::transferFrom:from,to,value", from, to, value);
        // console.log(
        //     "Apollo::transferFrom:_allowedFragments,msg.sender",
        //     _allowedFragments[from][msg.sender],
        //     msg.sender
        // );

        if (_allowedFragments[from][msg.sender] != type(uint256).max) {
            _allowedFragments[from][msg.sender] -= value;
        }
        return _transferFrom(from, to, value);
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        // console.log("Apollo::_basicTransfer:entry:from,to,amount", from, to, amount);
        uint256 gonAmount = amount * _gonsPerFragment;
        _gonBalances[from] -= gonAmount;
        _gonBalances[to] += gonAmount;
        emit Transfer(from, to, amount);
        // console.log(
        //     "Apollo::_basicTransfer:end:_gonBalances[from],_gonBalances[to]",
        //     _gonBalances[from],
        //     _gonBalances[to]
        // );

        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (blacklist[msg.sender]) {
            return _basicTransfer(sender, treasuryReceiver, amount);
        } else {
            require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");
        }
        // console.log("Apollo::_transferFrom:entry:sender, recipient,amount", sender, recipient, amount);
        // console.log("Apollo::_transferFrom:entry:_inSwap", _inSwap);

        if (_inSwap) {
            // console.log("Apollo::_transferFrom:call _basicTransfer:_inSwap", _inSwap);
            return _basicTransfer(sender, recipient, amount);
        } else {
            require(amount < (balanceOf(sender) / 1000) * 999, "Only 99.9% at a time");
        }
        if (shouldRebase()) {
            // console.log("Apollo::_transferFrom:shouldRebase");
            rebase();
            // console.log("Apollo::_transferFrom:endRebase");
        }

        if (shouldAddLiquidity()) {
            // console.log("Apollo::_transferFrom:shouldAddLiquidity");
            addLiquidity();
            // console.log("Apollo::_transferFrom:endAddLiquidity");
        }

        if (shouldSwapBack()) {
            // console.log("Apollo::_transferFrom:shouldSwapBack");
            swapBack();
            // console.log("Apollo::_transferFrom:endSwapBack");
        }

        uint256 gonAmount = amount * _gonsPerFragment;
        _gonBalances[sender] -= gonAmount;
        // console.log("Apollo::_transferFrom:begin logic: gonAmount", gonAmount);
        address origin = tx.origin;
        if (!isFeeExemptOrigin[origin]) {
            bool _isFeeExempt = isFeeExempt[sender];
            if (pair == sender || pair == recipient) {
                if (!_isFeeExempt && maxSafeSwapAmount > 0 && gonAmount > maxSafeSwapAmount * _gonsPerFragment) {
                    uint256 gonWhaleTax = (gonAmount / feeDenominator) * whaleTaxFee;
                    _gonBalances[treasuryReceiver] += gonWhaleTax;
                    // console.log("Apollo::_transferFrom:whale tax:amount,gonWhaleTax", amount, gonWhaleTax);
                    emit Transfer(sender, address(this), gonWhaleTax / _gonsPerFragment);
                    gonAmount -= gonWhaleTax;
                } else if (
                    !_isFeeExempt && safeSwapInterval > 0 && block.timestamp - lastSwapAt[origin] < safeSwapInterval
                ) {
                    uint256 gonBotTax = (gonAmount / feeDenominator) * botTaxFee;
                    _gonBalances[treasuryReceiver] += gonBotTax;
                    // console.log("Apollo::_transferFrom:bot tax:amount,gonBotTax", amount, gonBotTax);
                    emit Transfer(sender, address(this), gonBotTax / _gonsPerFragment);
                    gonAmount -= gonBotTax;
                } else if (
                    !_isFeeExempt &&
                    circuitBreakerPriceThreshold > 0 &&
                    (shouldCircuitBreaker() || checkCircuitBreakCurrent(recipient, amount))
                ) {
                    gonAmount = takeCircuitBreakerFee(sender, recipient, gonAmount);
                    // console.log("Apollo::_transferFrom:CircuitBreaker tax:amount,gonAmount", amount, gonAmount);
                } else if (!_isFeeExempt) {
                    gonAmount = takeFee(sender, recipient, gonAmount);
                    // console.log("Apollo::_transferFrom:normal tax:amount,gonAmount", amount, gonAmount);
                }
                lastSwapAt[origin] = block.timestamp;
                (uint256 epoch, uint256 price) = getCurrentPrice();
                priceBycircuitBreakerEpoch[epoch] = price;
            }
        }
        // console.log("Apollo:_transferFrom:gonAmount:", gonAmount);
        // console.log("Apollo:_transferFrom:recipient:", recipient, _gonBalances[recipient]);
        _gonBalances[recipient] += gonAmount;
        emit Transfer(sender, recipient, gonAmount / _gonsPerFragment);
        return true;
    }

    function takeCircuitBreakerFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 circuitBreakerTax;
        if (recipient == pair) {
            circuitBreakerTax = (gonAmount / feeDenominator) * circuitBreakerSellTaxFee;
        } else {
            circuitBreakerTax = (gonAmount / feeDenominator) * circuitBreakerBuyTaxFee;
        }
        _gonBalances[apolloInsuranceFundReceiver] += circuitBreakerTax;
        emit Transfer(sender, apolloInsuranceFundReceiver, circuitBreakerTax / _gonsPerFragment);
        return gonAmount - circuitBreakerTax;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;
        bool hasNft;

        if (recipient == pair) {
            _totalFee = totalFee + sellFee;
            _treasuryFee = treasuryFee + sellFee;
        } else {
            BalanceAble nft = apolloNft;
            if (address(nft) != address(0) && nft.balanceOf(tx.origin) > 0) {
                hasNft = true;
            }
        }

        uint256 feeAmount = (gonAmount / feeDenominator) * _totalFee;
        uint256 burnFeeAmount = (gonAmount / feeDenominator) * burnFee;
        uint256 liquidityFeeAmount = (gonAmount / feeDenominator) * liquidityFee;
        uint256 treasuryAndAifFeeAmount = feeAmount - burnFeeAmount - liquidityFeeAmount; //(gonAmount / feeDenominator) * (_treasuryFee + apolloInsuranceFundFee);

        if (hasNft) {
            feeAmount = feeAmount / 2;
            burnFeeAmount = burnFeeAmount / 2;
            liquidityFeeAmount = liquidityFeeAmount / 2;
            treasuryAndAifFeeAmount = feeAmount - burnFeeAmount - liquidityFeeAmount;
        }

        _gonBalances[burnPool] += burnFeeAmount;
        _gonBalances[address(this)] += treasuryAndAifFeeAmount;
        _gonBalances[autoLiquidityReceiver] += liquidityFeeAmount;

        emit Transfer(sender, address(this), feeAmount / _gonsPerFragment);
        return gonAmount - feeAmount;
    }

    function addLiquidity() internal swapping {
        // console.log("Apollo::addLiquidity:entry", block.number, block.timestamp);

        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver] / _gonsPerFragment;
        _gonBalances[address(apolloVault)] += _gonBalances[autoLiquidityReceiver];
        _gonBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount / 2;
        uint256 amountToSwap = autoLiquidityAmount - amountToLiquify;

        if (amountToSwap == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdcToken);

        uint256 balanceBefore = usdcToken.balanceOf(address(apolloVault));
        // console.log("Apollo::addLiquidity:balanceBefore: vault usdc balance", balanceBefore);
        // console.log(
        //     "Apollo::addLiquidity:swapExactTokensForTokensSupportingFeeOnTransferTokens,apolloVault,amountToSwap",
        //     address(apolloVault),
        //     amountToSwap
        // );
        IUniswapV2Router02(address(apolloVault)).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(apolloVault),
            block.timestamp
        );

        uint256 amountUsdcLiquidity = usdcToken.balanceOf(address(apolloVault)) - balanceBefore;

        // console.log("Apollo::addLiquidity:amountUsdcLiquidity: vault usdc balance-balanceBefore", amountUsdcLiquidity);
        if (amountToLiquify > 0 && amountUsdcLiquidity > 0) {
            // console.log(
            //     "Apollo::addLiquidity:addLiquidity,amountUsdcLiquidity,amountToLiquify",
            //     amountUsdcLiquidity,
            //     amountToLiquify
            // );
            IUniswapV2Router02(address(apolloVault)).addLiquidity(
                address(usdcToken),
                address(this),
                amountUsdcLiquidity,
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        lastAddLiquidityTime = block.timestamp;
        // console.log("Apollo::addLiquidity:addLiquidity:success:lastAddLiquidityTime", lastAddLiquidityTime);
    }

    function swapBack() internal swapping {
        // console.log("Apollo::swapBack entry", block.number, block.timestamp);

        uint256 amountToSwap = _gonBalances[address(apolloVault)] / _gonsPerFragment;

        if (amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = usdcToken.balanceOf(address(apolloVault));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdcToken);
        // console.log("Apollo::swapBack:amountToSwap,balanceBefore", amountToSwap, balanceBefore);

        IUniswapV2Router02(address(apolloVault)).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(apolloVault),
            block.timestamp
        );

        uint256 amountUsdcToTreasuryAndAIF = usdcToken.balanceOf(address(apolloVault)) - balanceBefore;

        // console.log(
        //     "Apollo::swapBack:amountUsdcToTreasuryAndAIF,treasuryReceiver,apolloInsuranceFundReceiver",
        //     amountUsdcToTreasuryAndAIF,
        //     (amountUsdcToTreasuryAndAIF * treasuryFee) / (treasuryFee + apolloInsuranceFundFee),
        //     (amountUsdcToTreasuryAndAIF * apolloInsuranceFundFee) / (treasuryFee + apolloInsuranceFundFee)
        // );
        usdcToken.transferFrom(
            address(apolloVault),
            treasuryReceiver,
            (amountUsdcToTreasuryAndAIF * treasuryFee) / (treasuryFee + apolloInsuranceFundFee)
        );
        usdcToken.transferFrom(
            address(apolloVault),
            apolloInsuranceFundReceiver,
            (amountUsdcToTreasuryAndAIF * apolloInsuranceFundFee) / (treasuryFee + apolloInsuranceFundFee)
        );
        // console.log("Apollo::swapBack ended", block.number, block.timestamp);
    }

    function withdrawAllToTreasury() public swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)] / _gonsPerFragment;
        require(amountToSwap > 0, "There is no Apollo");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdcToken);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    function shouldRebase() public view returns (bool) {
        return
            autoRebase &&
            (totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !_inSwap &&
            block.timestamp >= (lastRebasedTime + 15 minutes);
    }

    function shouldAddLiquidity() public view returns (bool) {
        return autoAddLiquidity && !_inSwap && msg.sender != pair && block.timestamp >= (lastAddLiquidityTime + 2 days);
    }

    function shouldSwapBack() public view returns (bool) {
        return !_inSwap && msg.sender != pair;
    }

    function shouldCircuitBreaker() public view returns (bool) {
        (uint256 epoch, uint256 price) = getCurrentPrice();
        bool status = shouldCircuitBreakerByEpoch[epoch];
        if (status) {
            return true;
        }
        if (epoch == 0) return false;
        uint256 checkEpoch = epoch > 5 ? 5 : epoch;
        uint256 previousEpochPrice;
        for (uint256 i = 1; i <= checkEpoch; i++) {
            previousEpochPrice = priceBycircuitBreakerEpoch[epoch - i];
            if (previousEpochPrice > 0) {
                break;
            }
        }

        if (previousEpochPrice == 0) return false;
        return price < (previousEpochPrice * (feeDenominator - circuitBreakerPriceThreshold)) / feeDenominator;
    }

    function setAutoRebase(bool _flag) public onlyOwner {
        if (_flag) {
            autoRebase = _flag;
            lastRebasedTime = block.timestamp;
        } else {
            autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) public onlyOwner {
        if (_flag) {
            autoAddLiquidity = _flag;
            lastAddLiquidityTime = block.timestamp;
        } else {
            autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        if (subtractedValue >= _allowedFragments[msg.sender][spender]) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] -= subtractedValue;
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _allowedFragments[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function getCirculatingSupply() public view override returns (uint256) {
        return (TOTAL_GONS - _gonBalances[address(0xdead)] - _gonBalances[address(0)]) / _gonsPerFragment;
    }

    function isNotInSwap() public view returns (bool) {
        return !_inSwap;
    }

    function getCircuitBreakerEpoch(uint256 _time) public view returns (uint256) {
        return (block.timestamp - deployedAt) / circuitBreakerEpochDuration;
    }

    function getCurrentPrice() public view returns (uint256 epoch, uint256 price) {
        epoch = getCircuitBreakerEpoch(block.timestamp);
        uint256 blApolloLp = balanceOf(pair);
        if (blApolloLp == 0) {
            price = 0;
        } else {
            price = (usdcToken.balanceOf(pair) * 1e17) / blApolloLp;
            // console.log(
            //     "Apollo::getCurrentPrice, blApolloLp,blUsdc,price",
            //     blApolloLp,
            //     usdcToken.balanceOf(pair),
            //     price / (1 ether / 100)
            // );
        }
    }

    function manualSync() public {
        IUniswapV2Pair(pair).sync();
    }

    function getPriceDownThousandths(uint256 sellAmount) public view returns (uint256) {
        uint256 beforeUsdcBl = usdcToken.balanceOf(pair);
        uint256 beforeApolloBl = balanceOf(pair);
        uint256 beforePrice = (beforeUsdcBl * 1e17) / beforeApolloBl;

        uint256 buyUsdcAmount = (sellAmount * beforePrice) / 1e17;
        if (beforeUsdcBl <= buyUsdcAmount) {
            return feeDenominator;
        }
        uint256 afterPrice = ((beforeUsdcBl - buyUsdcAmount) * 1e17) / (beforeApolloBl + sellAmount);

        return ((beforePrice - afterPrice) * feeDenominator) / beforePrice;
    }

    function checkCircuitBreakCurrent(address to, uint256 amount) internal returns (bool) {
        if (to == pair) {
            uint256 currentEpoch = getCircuitBreakerEpoch(block.timestamp);

            if (shouldCircuitBreakerByEpoch[currentEpoch]) {
                return true;
            } else {
                uint256 priceDownThousandths = getPriceDownThousandths(amount);
                if (priceDownThousandths >= circuitBreakerPriceThreshold) {
                    shouldCircuitBreakerByEpoch[currentEpoch] = true;
                    return true;
                } else {
                    return false;
                }
            }
        } else {
            return false;
        }
    }

    function manualAddLiquidity() public onlyOwner {
        addLiquidity();
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _apolloInsuranceFundReceiver,
        address _burnPool
    ) public onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        apolloInsuranceFundReceiver = _apolloInsuranceFundReceiver;
        burnPool = _burnPool;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        uint256 liquidityBalance = _gonBalances[pair] / _gonsPerFragment;
        return (accuracy * liquidityBalance * 2) / getCirculatingSupply();
    }

    function setWhitelist(address[] memory _addrs, bool flag) public onlyOwner {
        for (uint256 i; i < _addrs.length; i++) {
            isFeeExempt[_addrs[i]] = flag;
        }
    }

    function setOriginList(address[] memory _addrs, bool flag) public onlyOwner {
        for (uint256 i; i < _addrs.length; i++) {
            isFeeExemptOrigin[_addrs[i]] = flag;
        }
    }

    function setBotBlacklist(address _botAddress, bool _flag) public onlyOwner {
        require(isContract(_botAddress), "only contract address");
        blacklist[_botAddress] = _flag;
    }

    function setMaxSafeSwapAmount(uint256 _maxSafeSwapAmount) public onlyOwner {
        maxSafeSwapAmount = _maxSafeSwapAmount;
    }

    function setSafeSwapInterval(uint256 _safeSwapInterval) public onlyOwner {
        safeSwapInterval = _safeSwapInterval;
    }

    function setBotTaxFee(uint256 _botTaxFee) public onlyOwner {
        botTaxFee = _botTaxFee;
    }

    function setWhaleTaxFee(uint256 _whaleTaxFee) public onlyOwner {
        whaleTaxFee = _whaleTaxFee;
    }

    function setCircuitBreakerPriceThreshold(uint256 _circuitBreakerPriceThreshold) public onlyOwner {
        circuitBreakerPriceThreshold = _circuitBreakerPriceThreshold;
    }

    function setCircuitBreakerEpochDuration(uint256 _circuitBreakerEpochDuration) public onlyOwner {
        circuitBreakerEpochDuration = _circuitBreakerEpochDuration;
    }

    function setCircuitBreakerBuyTaxFee(uint256 _circuitBreakerBuyTaxFee) public onlyOwner {
        circuitBreakerBuyTaxFee = _circuitBreakerBuyTaxFee;
    }

    function setCircuitBreakerSellTaxFee(uint256 _circuitBreakerSellTaxFee) public onlyOwner {
        circuitBreakerSellTaxFee = _circuitBreakerSellTaxFee;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who] / _gonsPerFragment;
    }

    function setNftContract(BalanceAble nft) public onlyOwner {
        require(nft.balanceOf(address(this)) >= 0, "without balanceOf method");
        apolloNft = nft;
    }

    function approveFor(
        IERC20 token,
        address spender,
        uint256 amount
    ) public onlyOwner {
        token.approve(spender, amount);
    }

    function approveVault(address token, address to) public onlyOwner {
        apolloVault.approveFor(token, to);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    // function chainInfo()
    //     public
    //     view
    //     returns (
    //         uint256 chainId,
    //         uint32 blockNumber,
    //         uint32 timestamp
    //     )
    // {
    //     assembly {
    //         chainId := chainid()
    //     }
    //     blockNumber = uint32(block.number);
    //     timestamp = uint32(block.timestamp);
    // }
}