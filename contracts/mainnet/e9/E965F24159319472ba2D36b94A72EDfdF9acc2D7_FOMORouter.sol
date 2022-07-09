/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-23
 */

/**
 *Submitted for verification at BscScan.com on 2022-04-25
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "hardhat/console.sol";

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

interface IPancakeRouter {
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

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getamountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getamountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getamountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getamountsIn(uint256 amountOut, address[] calldata path)
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

interface BurningMoon {
    function addFunds(bool boost, bool stake) external payable;
}

interface IFomoLottery {
    function emitOnPlayFomo(address token) external;

    function emitWinnerSelected(
        address token,
        uint256 winAmount,
        address winner,
        bool rewardInToken
    ) external;
}

contract Pool {
    address public token;
    IPancakeRouter router;
    IFomoLottery public immutable fomoLottery;
    uint256 public LastBuyTimestamp;
    address public LastBuyer;
    uint256 public Duration = 10 minutes;
    uint256 public MinBuy = 0.02 ether;
    uint256 public poolPercentage = 500;
    uint256 public Fee = 100;
    uint256 public DevFee = 0;
    address DevAddress;
    uint256 constant DENOMINATOR = 1000;
    uint256 constant BMFee = 10;
    bool public supernova = false;

    function tokenOwner() private view returns (bool) {
        return Ownable(token).owner() == msg.sender;
    }

    modifier onlyTokenOwner() {
        require(tokenOwner());
        _;
    }

    function adjustSettings(
        uint256 _duration,
        uint256 _poolPercentage,
        uint256 _fee,
        bool superNova
    ) external onlyTokenOwner {
        require(_fee <= 150, "Fee too high");
        require(_poolPercentage >= 100 && _poolPercentage < 1000);
        require(_duration > 30, "Duration needs to be at least 30 seconds");
        Duration = _duration;
        Fee = _fee;
        poolPercentage = _poolPercentage;
        supernova = superNova;
        if (timeLeft() < 20) LastBuyTimestamp = block.timestamp;
    }

    function setDevFee(address recipient, uint256 amount)
        external
        onlyTokenOwner
    {
        require(amount <= 100, "Fee too high");
        DevAddress = recipient;
        DevFee = amount;
    }

    constructor() {
        fomoLottery = IFomoLottery(msg.sender);
        LastBuyTimestamp = block.timestamp;
    }

    function init(address _token, address _router) external {
        require(token == address(0) && address(router) == address(0));
        router = IPancakeRouter(_router);
        token = _token;
    }

    function withdrawPool(address recipient) private returns (bool successful) {
        uint256 winAmount = (address(this).balance * poolPercentage) /
            DENOMINATOR;
        if (supernova) {
            swapForToken(winAmount);
            IBEP20 Token=IBEP20(token);
            Token.transfer(recipient, Token.balanceOf(address(this)));
            successful = true;
        } else {
            (successful, ) = recipient.call{value: winAmount}("");
        }
        fomoLottery.emitWinnerSelected(token, winAmount, recipient, supernova);
    }

    function addFunds() external payable {}

    receive() external payable {
        //TokenOwner deposits
        if (tokenOwner()) return;
        playFOMO(msg.sender);
    }

    function playFOMO(address account) public payable {
        require(msg.value >= MinBuy, "Not enough sent");
        if (timeLeft() == 0 && LastBuyer != address(0)) {
            address winner = LastBuyer;
            LastBuyer = address(0);
            LastBuyTimestamp = block.timestamp;
            withdrawPool(winner);
        }
        uint256 value = msg.value;

        uint256 feeAmount = (value * Fee) / DENOMINATOR;
        uint256 BMFeeAmount = (value * BMFee) / DENOMINATOR;
        uint256 DevFeeAmount = 0;
        bool sent;
        if (DevFee > 0 && DevAddress != address(0)) {
            DevFeeAmount = (msg.value * DevFee) / DENOMINATOR;
            (sent, ) = DevAddress.call{value: DevFeeAmount}("");
        }

        (sent, ) = address(fomoLottery).call{value: BMFeeAmount}("");
        value -= feeAmount - BMFeeAmount - DevFeeAmount;
        LastBuyer = account;
        LastBuyTimestamp = block.timestamp;
        IBEP20 Token = IBEP20(token);
        swapForToken(value);
        Token.transfer(account, Token.balanceOf(address(this)));
        fomoLottery.emitOnPlayFomo(token);
    }

    function swapForToken(uint256 amount) private {
        address[] memory path = new address[](2);
        path[1] = token;
        path[0] = router.WETH();
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, address(this), block.timestamp);
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= (LastBuyTimestamp + Duration)) return 0;
        return (LastBuyTimestamp + Duration) - block.timestamp;
    }
}

contract FOMORouter {
    BurningMoon BM = BurningMoon(0x97c6825e6911578A515B11e25B552Ecd5fE58dbA);
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping(address => address payable) public pools;
    address[] public allPools;

    function getTokenPoolInfo(address token)
        external
        view
        returns (
            uint256 LastBuyTimestamp,
            uint256 timeLeft,
            address LastBuyer,
            uint256 Duration,
            uint256 MinBuy,
            uint256 poolPercentage,
            uint256 poolSize,
            uint256 Fee,
            uint256 DevFee
        )
    {
        address payable poolAddress = pools[token];
        require(poolAddress != address(0));
        Pool pool = Pool(poolAddress);
        LastBuyTimestamp = pool.LastBuyTimestamp();
        timeLeft = pool.timeLeft();
        LastBuyer = pool.LastBuyer();
        Duration = pool.Duration();
        MinBuy = pool.MinBuy();
        poolPercentage = pool.poolPercentage();
        Fee = pool.Fee();
        DevFee = pool.DevFee();
        poolSize = poolAddress.balance;
    }

    event PoolCreated(address token, address pool);

    function getPool(address token) private returns (address payable pool) {
        pool = pools[token];
        if (pool == address(0)) {
            Pool newPool = new Pool();
            newPool.init(token, router);
            pool = payable(newPool);
            pools[token] = pool;
            allPools.push(token);
            emit PoolCreated(token, pool);
        }
    }

    event OnPlayFomo(
        address token,
        address Lottery,
        uint256 TimeLeft,
        uint256 pricePot,
        uint256 minBuy
    );

    function emitOnPlayFomo(address token) public {
        address payable poolAddress = pools[token];
        require(msg.sender == poolAddress, "Only Pools Can Emit");
        Pool pool = Pool(poolAddress);
        emit OnPlayFomo(
            token,
            pools[token],
            pool.timeLeft(),
            (poolAddress.balance * pool.poolPercentage()) / 1000,
            pool.MinBuy()
        );
    }

    event OnWinnerSelected(
        address token,
        address winner,
        address pool,
        uint256 amount,
        bool rewardInToken
    );

    function emitWinnerSelected(
        address token,
        uint256 winAmount,
        address winner,
        bool rewardInToken
    ) public {
        address payable poolAddress = pools[token];
        require(msg.sender == poolAddress, "Only Pools Can Emit");
        emit OnWinnerSelected(
            token,
            winner,
            poolAddress,
            winAmount,
            rewardInToken
        );
    }

    receive() external payable {
        BM.addFunds{value: msg.value}(false, true);
    }

    function playFomo(address token) public payable {
        address payable pool = getPool(token);
        Pool(pool).playFOMO{value: msg.value}(msg.sender);
    }

    function createPool(address token) external {
        require(pools[token] == address(0), "pool already exists");
        getPool(token);
    }
}