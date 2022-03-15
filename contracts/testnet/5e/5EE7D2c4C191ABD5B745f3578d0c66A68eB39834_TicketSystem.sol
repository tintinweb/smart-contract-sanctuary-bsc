/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/*
BNB <=> BUSD pair (0xe0e92035077c39594793e61802a350347c320cf2)
BNB <=> LANDS pair (0x5AEC3068b4b35731b178793709b4f2B62D7aae83)
New LANDS => 0x720cd1E4E12b58bAbA1A0Cd491501C950E156544
Router Address => 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

=> Exclude from fees
=> Exclude from reward
*/

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

interface IPancakeRouter01 {
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

interface IBEP20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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
}

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

// LANDS <=> BNB <=> BUSD
contract TicketSystem is Ownable {
    // BNB <=> BUSD pair
    IUniswapV2Pair public BNB_BUSDPair;

    // BNB <=> LANDS pair
    IUniswapV2Pair public BNB_LANDSPair;

    // Ticket price in dollars
    uint256 public ticketPrice;

    uint256 public immutable decimals = 10**18;

    // Total number of tickets sold
    uint256 public ticketsSold;

    // Total LANDS deposited to purchase tickets
    uint256 public LANDSDeposited;

    uint256 public rewardPool = 96;
    uint256 public teamPool = 1;
    uint256 public holdersAirdrop = 2;
    uint256 public liquidityPool = 1;

    // LANDS contract address
    IBEP20 public _LANDS;
    address public LANDSAddress;
    IPancakeRouter02 internal _pancakeRouter;

    // Liquidity pool provider router
    address _routerAddress;

    event PurchaseTicket(
        address beneficiary,
        uint256 quantity,
        uint256 pricePerTicketInBUSD,
        uint256 pricePerTicketInLANDS,
        uint256 totalAmountInLANDS
    );
    event SetDistribution(
        uint256 rewardPool_,
        uint256 teamPool_,
        uint256 holdersAirdrop_,
        uint256 liquidityPool_
    );
    event SetTicketPrice(uint256 ticketPrice_);
    event SetRouterAddress(address routerAddress_);
    event SetLANDSAddress(address LANDSAddress_);
    event SetBNB_LANDSPair(address BNB_LANDSPair_);
    event SetBNB_BUSDPair(address BNB_BUSDPair_);

    constructor(
        address BNB_BUSDPair_,
        address BNB_LANDSPair_,
        address LANDS_,
        address routerAddress_
    ) {
        // Setting router address
        setRouterAddress(routerAddress_);

        // Setting LANDS address
        setLANDSAddress(LANDS_);

        // BNB <=> BUSD pair address
        setBNB_BUSDPair(BNB_BUSDPair_);

        // BNB <=> LANDS pair addess
         setBNB_LANDSPair(BNB_LANDSPair_);

        // Initial ticket price will be $1 worth of LANDS
        setticketPrice(1);
    }

    function getLANDS_BUSDPrice() public view returns (uint256) {
        // IBEP20 BNB_BUSD = IBEP20(BNB_BUSDPair.token1());
        // IBEP20 BNB_LANDS = IBEP20(BNB_LANDSPair.token1());
        (uint256 ResBNB1, uint256 ResBUSD, ) = BNB_BUSDPair.getReserves();
        (uint256 ResBNB2, uint256 ResLANDS, ) = BNB_LANDSPair.getReserves();

        uint256 resBUSD = ResBNB1 * decimals; // 10**18
        uint256 resLANDS = ResBNB2 * decimals; // 10**18
        uint256 BNB_BUSD_tokenCount = ((1 * resBUSD) / ResBUSD);
        uint256 BNB_LANDS_tokenCount = ((1 * resLANDS) / ResLANDS);
        uint256 LANDS_BUSDPrice = (BNB_LANDS_tokenCount * ticketPrice) / BNB_BUSD_tokenCount;
        return (LANDS_BUSDPrice);
    }

    function purchaseTicket(uint256 numberOfTickets) public {
        require(
            numberOfTickets > 0,
            "Purchase Ticket: Number of tickets has to be greater than zero!"
        );
        uint256 pricePerTicketInLANDS = getLANDS_BUSDPrice();
        uint256 totalTicketAmount = numberOfTickets * pricePerTicketInLANDS;
        // Check whether the LANDS balance of user is greater than the amount
        require(
            _LANDS.balanceOf(_msgSender()) >= totalTicketAmount,
            "Insufficient LANDS Balance, Add Funds to Purchase Tickets!"
        );
        _LANDS.transferFrom(_msgSender(), address(this), totalTicketAmount);
        _LANDS.approve(address(this), totalTicketAmount);

        LANDSDeposited += totalTicketAmount;
        ticketsSold += numberOfTickets;

        emit PurchaseTicket(
            _msgSender(),
            numberOfTickets,
            ticketPrice,
            pricePerTicketInLANDS,
            totalTicketAmount
        );

        // LANDS liquidity pool distribution => 1%
        _LANDS.transfer(
            LANDSAddress,
            (totalTicketAmount * liquidityPool) / 100
        );
        _LANDS.approve(LANDSAddress, (totalTicketAmount * liquidityPool) / 100);

        // Holders percentage distribution => 2%
         airdrop((totalTicketAmount * holdersAirdrop) / 100);

        // Swapping tokens for BNB
        swapTokensForEth(_LANDS.balanceOf(address(this)));
    }

    function airdrop(uint256 amount) private {
        (bool success, ) = LANDSAddress.call(abi.encodeWithSignature("airdrop(uint256)",amount));

        require(success, "Airdrop: airdrop failed");
        // bytes memory data
    }

    receive() external payable {}

    function swapTokensForEth(uint256 amount) private {
        // Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = LANDSAddress;
        path[1] = _pancakeRouter.WETH();

        _LANDS.approve(address(_pancakeRouter), amount);

        // Swap tokens to ETH
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this), // this contract will receive the eth that were swapped from the token
            block.timestamp
        );
    }

    function setDistribution(
        uint256 rewardPool_,
        uint256 teamPool_,
        uint256 holdersAirdrop_,
        uint256 liquidityPool_
    ) public onlyOwner {
        require(
            rewardPool_ + teamPool_ + holdersAirdrop_ + liquidityPool_ == 100,
            "Set Reward Pool: Distribution have to be equal to 100"
        );

        rewardPool = rewardPool_;
        teamPool = teamPool_;
        holdersAirdrop = holdersAirdrop_;
        liquidityPool = liquidityPool_;

        emit SetDistribution(
            rewardPool_,
            teamPool_,
            holdersAirdrop_,
            liquidityPool_
        );
    }

    function Withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Failed to send BNB");
    }

    function setticketPrice(uint256 ticketPrice_) public onlyOwner {
        ticketPrice = ticketPrice_ * decimals;
        emit SetTicketPrice(ticketPrice_ * decimals);
    }

    function setRouterAddress(address routerAddress_) public onlyOwner {

        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress_);

        _routerAddress = routerAddress_;

        _pancakeRouter = pancakeRouter;

        emit SetRouterAddress(routerAddress_);
    }

    function setLANDSAddress(address LANDS_) public onlyOwner {
        LANDSAddress = LANDS_;
        _LANDS = IBEP20(LANDS_);
        emit SetLANDSAddress(LANDS_);
    }

    function setBNB_BUSDPair(address BNB_BUSDPair_) public {
        BNB_BUSDPair = IUniswapV2Pair(BNB_BUSDPair_);
        emit SetBNB_BUSDPair(BNB_BUSDPair_);
    }

    function setBNB_LANDSPair(address BNB_LANDSPair_) public {
    BNB_LANDSPair = IUniswapV2Pair(BNB_LANDSPair_);
     emit SetBNB_LANDSPair(BNB_LANDSPair_);
    }

    /*
     95 % reward pools BUSD
     1 % REWARDED in BUSD (reward pool)
     1% DEVELOPMENT / TEAM in BUSD (some wallet)
     1 % LIQUIDITY POOL in LANDS
     2% HOLDERS in LANDS (Airdrop)

     Withdraw function
     Automatic swap function
     */
}