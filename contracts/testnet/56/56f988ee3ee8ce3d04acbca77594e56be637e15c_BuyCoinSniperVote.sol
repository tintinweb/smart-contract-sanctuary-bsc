/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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
    function getReserves() external view returns (
        uint112 reserve0, 
        uint112 reserve1, 
        uint32 blockTimestampLast
    );
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

interface ICoinSniper {
    function balanceOf(address account) external view returns (uint256);
    function deliver(uint256 tAmount) external;
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract BuyCoinSniperVote is Ownable, ReentrancyGuard {
    address     private csContract  = 0xd14791Bf63AeAB3903d5112BBF13993230D057b4;
    address     private busdAddress = 0xe2026FeAac40259ba0d4Cc82d0C0C249F28c167B;
    ICoinSniper public  coinSniper = ICoinSniper(csContract);

    address public buybackWallet = 0x11111337E30f914859d8212c095b49fA0Ff25858;
    address public lotteryWallet = 0x22222e3837932FcB652A9536E2D848e2dCD1A835;
    address public DEAD = address(0xdead);

    uint256 public burnShare       = 30;
    uint256 public buybackShare    = 10;
    uint256 public lotteryShare    = 10;
    uint256 public liquidityShare  = 10;
    uint256 public reflectionShare = 40;

    uint256 private nonce;
    
    IPancakeswapV2Pair private csPair   = IPancakeswapV2Pair(0x67a6DCA182A3E3554853D699e4f8210DcE986294);
    IPancakeswapV2Pair private busdPair = IPancakeswapV2Pair(0x0afdccDa32fAd7509bF3c3Ff3B4fb1fEB1aabf71);

    event VoteBuy(address indexed voter, uint256 amount, uint256 nonce);
    event Burned(uint256 amount);
    event Redistributed(uint256 amount);
    event SendToLotteryWallet(uint256 amount);
    event SendToBuybackWallet(uint256 amount);
    event SendToAutoLiquidity(uint256 amount);

    constructor( ) { }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function buyVote(uint256 amountToken) external nonReentrant {
        require(coinSniper.balanceOf(msg.sender) >= amountToken, "Not enough CSC balance");
        uint256 cent = getPrice(amountToken);
        require(cent >= 100, "Minimum 1 dollar worth of CoinSniper Coin");

        uint256 burnAmount       = amountToken * burnShare      / 100;
        uint256 buybackAmount    = amountToken * buybackShare   / 100;
        uint256 lotteryAmount    = amountToken * lotteryShare   / 100;
        uint256 liquidityAmount  = amountToken * liquidityShare / 100;
        uint256 reflectionAmount = amountToken - burnAmount - buybackAmount - lotteryAmount - liquidityAmount;

        coinSniper.transferFrom(msg.sender, address(this), amountToken);

        coinSniper.transfer(DEAD,          burnAmount);
        coinSniper.transfer(buybackWallet, buybackAmount);
        coinSniper.transfer(lotteryWallet, lotteryAmount);
        coinSniper.transfer(csContract,    liquidityAmount);
        coinSniper.deliver(reflectionAmount);

        emit VoteBuy(msg.sender, cent, nonce);
        nonce++;
    }

    function calculateBusdAmount(uint256 _amount) public view returns (uint256) {
        (uint256 bnbInBusdPair,uint256 busdInBusdPair, ) = busdPair.getReserves();
         uint256 bnbPriceInBusd = busdInBusdPair / bnbInBusdPair;
        
        (uint256 BNB, uint256 CoinSniper,) = csPair.getReserves();
         uint256 CoinSniperBNBPrice = CoinSniper / BNB;

        uint256 amountValueInBusd = (_amount * bnbPriceInBusd / CoinSniperBNBPrice)  / 1e16;

        return (amountValueInBusd); 
    }

    function getPrice(uint256 _amount) public view returns(uint256){
        uint256 bnbInBusdPair;
        uint256 busdInBusdPair;
        uint256 BNB;
        uint256 Token;

        if(address(busdPair.token0()) == address(busdAddress))
            (busdInBusdPair, bnbInBusdPair,  ) = busdPair.getReserves();
        else
            (bnbInBusdPair, busdInBusdPair, ) = busdPair.getReserves();
            
        uint256 bnbPriceInBusd = busdInBusdPair / bnbInBusdPair;
        
        if(address(csPair.token0()) == address(this))
            (Token, BNB,) = csPair.getReserves();
        else
            (BNB, Token,) = csPair.getReserves();
        uint256 TokenBNBPrice = Token / BNB;

        uint256 TokenBusdPrice = (_amount*bnbPriceInBusd/TokenBNBPrice)  / 1e16;
        
        return (TokenBusdPrice); 
    }
}