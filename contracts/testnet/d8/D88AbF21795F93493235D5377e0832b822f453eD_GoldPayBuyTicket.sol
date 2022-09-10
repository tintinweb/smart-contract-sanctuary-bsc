/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IUniswapV2Router01 {
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


interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IUniswapV2Factory {
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
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


interface IPancakeswapV2Pair {
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

    function permit(
        address owner, 
        address spender, 
        uint value, 
        uint deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external;

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
    function getReserves() external view returns (
        uint112 reserve0, 
        uint112 reserve1, 
        uint32 blockTimestampLast
    );
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract GoldPayBuyTicket is Ownable, ReentrancyGuard {
    

    IUniswapV2Router02 public uniswapV2Router;

    IPancakeswapV2Pair public USDPair;
    IPancakeswapV2Pair public GoldPayPair;
    
    
    address public USD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public GoldPayAddress = 0x5c2727DD010Ab2d982040EF40d735DB425CA4466;


    address public MarketingPool = address(this);
    address public TreasuryPool = 0xfadDD1CFBd4D323e166cB63035571286420F9E49; 
    address public DEAD = address(0xdead);

    mapping(bytes32 => address) public referrallCode;
    mapping(address => bytes32) public referrallAddress;
    mapping(address => bool) public isUsedRefCode;

    uint256 rewardPoolShare         = 70;
    uint256 buyBackGoldPayShare     = 10;
    uint256 referralShare           = 10;
    uint256 treasuryShare                = 10;

    event MarketingPoolWalletChanged(address MarketingPool);
    event TreasuryWalletChanged(address TreasuryPool);
    event StandartTicketBuy(address indexed voter, uint256 amount, uint256 nonce, uint256 ticket, bool golden);
    event TokenAmount(uint256 tokenAmount);
    event Voter(address indexed voter);
    event Nonce(uint256 nonce);
    event TicketAmount(uint256 ticket);
    event TicketType(bool golden);
    event RewardsDistrubuted(address winner, uint256 lunaApeAmount, uint256 busdAmount);

 
    IERC20 public  BUSD = IERC20(USD);
    IERC20 public  GoldPay = IERC20(GoldPayAddress);

    uint256 public ticketStandartPrice = 1e17;
    uint256 public ticketGoldenPrice = 2e17;

    uint256 private nonce;

   receive() external payable {}


    constructor() {
        address router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address _uniswapV2USDPair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(USD), _uniswapV2Router.WETH());
        USDPair = IPancakeswapV2Pair(_uniswapV2USDPair);

        uint256 timestamp = block.timestamp;
        referrallCode[keccak256(abi.encode(TreasuryPool,timestamp))] = TreasuryPool;
        referrallAddress[TreasuryPool] = keccak256(abi.encode(TreasuryPool,timestamp));
        uint256 MAX;
        unchecked{
            MAX = uint256(0) - 1;
        }
        BUSD.approve(router,MAX);
        GoldPay.approve(router,MAX);
    }

    function setShares(
        uint256 _rewardPoolShare,
        uint256 _buyBackGoldPayShare,
        uint256 _referralShare,
        uint256 _treasuryShare
    ) 
    external onlyOwner{
        require(_rewardPoolShare + _buyBackGoldPayShare + _referralShare + _treasuryShare == 100, "Must be add up 100");
        rewardPoolShare = _rewardPoolShare;
        buyBackGoldPayShare = _buyBackGoldPayShare;
        referralShare = _referralShare;
        treasuryShare = _treasuryShare;
    }

    function buyBack(uint256 amount, address token, address to) private{
        address[] memory path = new address[](3);
        path[0] = USD;
        path[1] = uniswapV2Router.WETH();
        path[2] = token;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp);
    }  

    function setRouter(address _router) public onlyOwner{
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Router = _uniswapV2Router;
    }


    function setUSDPair(address _usd) public onlyOwner{
        require(USD != _usd);
        USD = _usd;
        address _uniswapV2USDPair = IUniswapV2Factory(uniswapV2Router.factory())
            .getPair(address(_usd), uniswapV2Router.WETH());
        USDPair = IPancakeswapV2Pair(_uniswapV2USDPair);
    }

    function setGoldPayPair(address _goldPay) public onlyOwner{
        require(GoldPayAddress != _goldPay);
        GoldPayAddress = _goldPay;
        address _uniswapV2GoldPayPair = IUniswapV2Factory(uniswapV2Router.factory())
            .getPair(address(_goldPay), uniswapV2Router.WETH());
        GoldPayPair = IPancakeswapV2Pair(_uniswapV2GoldPayPair);
    }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function changeMarketingPoolWallet(address _MarketingPool) external onlyOwner {
        require(MarketingPool != _MarketingPool, "Banana Peels Reward Pool is already that address");
        MarketingPool = _MarketingPool;
        emit MarketingPoolWalletChanged(MarketingPool);
    }

    function changeTreasuryWallet(address _TreasuryWallet) external onlyOwner {
        require(_TreasuryWallet != TreasuryPool, "Treasury Wallet is already that address");
        TreasuryPool = _TreasuryWallet;
        emit TreasuryWalletChanged(TreasuryPool);
    }    

    function changeStandartTicketPrice(uint256 _ticketStandartPrice) external onlyOwner{
        ticketStandartPrice = _ticketStandartPrice;
    }
    
    function changeGoldenTicketPrice(uint256 _ticketGoldenPrice) external onlyOwner{
        ticketGoldenPrice = _ticketGoldenPrice;
    }

    function buyTicket(uint256 ticket, bytes32 _referral, bool _golden) external nonReentrant {
        uint256 tokenAmount;

        if(_golden == true){
            tokenAmount = ticketGoldenPrice;
        }
        else{
            tokenAmount = ticketStandartPrice;
        }

        address refReceiver = TreasuryPool;
        if (isUsedRefCode[msg.sender] == false)
        {
            if(address(referrallCode[_referral]) != TreasuryPool && address(referrallCode[_referral]) != address(0) && address(referrallCode[_referral]) != msg.sender)
            {
                tokenAmount = (tokenAmount * 9500) / 1e4; 
                isUsedRefCode[msg.sender] = true;
                refReceiver = address(referrallCode[_referral]);
            }
        }

        uint256 rewardPoolAmount = (tokenAmount * rewardPoolShare) / 100;
        uint256 referralAmount = (tokenAmount * referralShare) / 100;
        uint256 treasuryAmount = (tokenAmount * treasuryShare) / 100;
        uint256 buyBackGoldPayAmount = (tokenAmount * buyBackGoldPayShare) / 100;

        if(rewardPoolShare > 0)
            BUSD.transferFrom(msg.sender,MarketingPool, rewardPoolAmount);
        if(referralShare > 0)
            BUSD.transferFrom(msg.sender,refReceiver, referralAmount);
        if(treasuryShare > 0)
            BUSD.transferFrom(msg.sender,TreasuryPool,    treasuryAmount);
        if(buyBackGoldPayShare > 0)
        {
            BUSD.transferFrom(msg.sender,address(this),    buyBackGoldPayAmount);
            buyBack(buyBackGoldPayAmount,GoldPayAddress,DEAD);
        }
  
            

        emit StandartTicketBuy(msg.sender, tokenAmount, nonce, ticket,_golden);
        
        emit Voter(msg.sender);
        emit TokenAmount(tokenAmount);
        emit Nonce( nonce);
        emit TicketAmount( ticket);
        emit TicketType( _golden);
        
        nonce++;
        uint256 timestamp = block.timestamp;
        if (referrallAddress[msg.sender] == bytes32(0))
        {
            referrallCode[keccak256(abi.encode(msg.sender,timestamp))] = msg.sender;
            referrallAddress[msg.sender] = keccak256(abi.encode(msg.sender,timestamp));
        }
    }


    function getOneTicketPrice(uint256 token_) public view returns(uint256){
        uint256 bnbInUsdPair;
        uint256 usdInUsdPair;
        uint256 BNB;
        uint256 Token;
        uint256 tokenPrice;
        
        if(address(USDPair.token0()) == address(USD))
            (usdInUsdPair, bnbInUsdPair,  ) = USDPair.getReserves();
        else
            (bnbInUsdPair, usdInUsdPair, ) = USDPair.getReserves();
            
        uint256 bnbPriceInUsd = (usdInUsdPair * 1e18) / bnbInUsdPair;
        
        if(address(GoldPayPair.token0()) == GoldPayAddress)
            (Token, BNB,) = GoldPayPair.getReserves();
        else
            (BNB, Token,) = GoldPayPair.getReserves();

        uint256 TokenBNBPrice = (Token * 1e18) / BNB;

        uint256 TokenUsdPrice = (1e18 * bnbPriceInUsd) / TokenBNBPrice;

        tokenPrice = (token_ * 1e18) / TokenUsdPrice;
  
        return tokenPrice; 
    }

    function distributeRewards(uint256 goldPayAmount, uint256 busdAmount,address winner) external onlyOwner nonReentrant{
        if(goldPayAmount > 0){
            goldPayAmount = getOneTicketPrice(goldPayAmount);
            GoldPay.transfer(winner, goldPayAmount);
        }
            
        if(busdAmount > 0)
            BUSD.transfer(winner, busdAmount);
        
        emit RewardsDistrubuted(winner,goldPayAmount,busdAmount);
    }

    function getTicketPrice(uint256 _amount,uint256 ticket, bool _golden) public view returns(uint256){
        uint256 bnbInUsdPair;
        uint256 usdInUsdPair;
        uint256 BNB;
        uint256 Token;
        uint256 tokenPrice;
        
        if(address(USDPair.token0()) == address(USD))
            (usdInUsdPair, bnbInUsdPair,  ) = USDPair.getReserves();
        else
            (bnbInUsdPair, usdInUsdPair, ) = USDPair.getReserves();
            
        uint256 bnbPriceInUsd = (usdInUsdPair * 1e18) / bnbInUsdPair;
        
        if(address(GoldPayPair.token0()) == GoldPayAddress)
            (Token, BNB,) = GoldPayPair.getReserves();
        else
            (BNB, Token,) = GoldPayPair.getReserves();

        uint256 TokenBNBPrice = (Token * 1e18) / BNB;

        uint256 TokenUsdPrice = (_amount * bnbPriceInUsd) / TokenBNBPrice;

        if (_golden)
            tokenPrice = (ticketGoldenPrice * ticket) * 1e18 / TokenUsdPrice;
        else
            tokenPrice = (ticketStandartPrice * ticket) * 1e18 / TokenUsdPrice;
        
        return tokenPrice; 
    }
}