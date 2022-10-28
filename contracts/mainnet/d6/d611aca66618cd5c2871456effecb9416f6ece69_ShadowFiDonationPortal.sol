/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

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

// File: ShadowFiDonate.sol


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
    address private _court;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event CourtUpdated(
        address indexed previousOwner,
        address indexed newCourt
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        _setCourtAddress(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current court.
     */
    function court() public view virtual returns (address) {
        return _court;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyCourt() {
        require(court() == _msgSender(), "Ownable: caller is not the court");
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
     * @dev Sets court address of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function setCourtAddress(address newCourt) public virtual onlyOwner {
        require(
            newCourt != address(0),
            "Ownable: new court is the zero address"
        );
        _setCourtAddress(newCourt);
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

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _setCourtAddress(address newCourt) internal virtual {
        address oldCourt = _court;
        _court = newCourt;
        emit CourtUpdated(oldCourt, newCourt);
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

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

    function setIsFeeExempt(address holder, bool exempt) external;

    function setIsTxLimitExempt(address holder, bool exempt) external;

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

    function burn(uint256 amount) external;
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IShadowFiNFT {
    function mint(uint256 _mintAmount, address _receiver, uint256 _tier) external;
    function mintEnd() external view returns (bool);
    function tier(uint256 tokenId) external view returns (uint256 nftTier);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface ILegacyNFT {
    function nftLevel(uint256 tokenId) external view returns (uint256 level);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IRaffle {
    function deposit(address user, uint256 ticketAmount) payable external;
}

interface IAggregator {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

contract ShadowFiDonationPortal is Ownable, ReentrancyGuard, ERC721Holder {

struct StakedNFTInfo {
        address nftAddress;
        uint256 tokenId;
        uint256 unlockTime;
        uint256 stakeTier;
    }

    IPancakeRouter private pancakeRouter;
    IShadowFiToken private shadowFiToken;
    IPancakePair private pancakePairToken;
    IShadowFiNFT public nftContract;
    ILegacyNFT public legacyNFT;
    IRaffle public raffleContract;
    IAggregator public aggregatorContract;

    uint256 public minBNB = 10000000000000000;
    uint256 public minBUSD = 5000000000000000000;
    address public vaultContract;
    address private BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    uint256 public totalDonatedBNB;
    uint256 public totalDonatedBUSD;
    uint256 public totalDonatedDollars;
    uint256 public totalBNBtoLiquidate;

    uint256 public lockTime = 1209600;
    uint256 public ticketCost = 5;

    mapping(address => StakedNFTInfo) private userStakedNFT;
    mapping(address => mapping(uint8 => bool)) private mintedTier;
    mapping(uint8 => uint256) public tierCosts;
    mapping(address => uint256) public donatedAmount;

    event donatedBNB(uint256 amountBNB, uint256 amountDollars, uint256 amountLiquidity);
    event donatedBUSD(uint256 amountBUSD, uint256 amountLiquidity);
    event Staked(address nftAddress, uint256 tokenId, uint256 stakedTier);
    event Unstaked(address nftAddress, uint256 tokenId, uint256 stakedTier);
    event Liquidated(uint256 amountToken, uint256 amountBNB, uint256 amountLiquidity);

    constructor(
        address _pancakeRouter,
        address _shadowFiToken,
        address _legacyNFT,
        address _vaultContract
    ) {
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        shadowFiToken = IShadowFiToken(_shadowFiToken);
        legacyNFT = ILegacyNFT(_legacyNFT);
        vaultContract = _vaultContract;
        aggregatorContract = IAggregator(address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE));
        _initTierCosts();
        pancakePairToken = IPancakePair(IPancakeFactory(pancakeRouter.factory()).getPair(pancakeRouter.WETH(), address(shadowFiToken)));
    }

    /*******************************************************************************************************/
    /************************************* User Functions **************************************************/
    /*******************************************************************************************************/

    function donateBNB() payable public nonReentrant {
        require((msg.value >= minBNB), "You must donate more than the minimum");
                
        int256 currentPrice = aggregatorContract.latestAnswer();
        uint256 convertedPrice = uint(currentPrice);

        donatedAmount[msg.sender] += msg.value * (convertedPrice / 1e8) / 1e18;

        if (!nftContract.mintEnd()) {
            for (uint8 i = 0; i < 4; i++) {
                if(donatedAmount[msg.sender] >= tierCosts[i] && !getTierMintedStatus(msg.sender, i)){
                    mintedTier[msg.sender][i] = true;
                    nftContract.mint(1, msg.sender, i);
                }
            }
        }

        uint256 depositAmount = (msg.value * 1000000) * 70 / 100000000;
        uint256 tickets = (msg.value * (convertedPrice / 1e8) / 1e18) / ticketCost;
        raffleContract.deposit{value: depositAmount}(address(msg.sender), tickets);

        if (tickets >= 1 && userStakedNFT[msg.sender].unlockTime != 0) {
            userStakedNFT[msg.sender].unlockTime = block.timestamp + lockTime;
        }

        totalDonatedBNB += msg.value;
        totalDonatedDollars += msg.value * (convertedPrice / 1e8) / 1e18;
        totalBNBtoLiquidate += (msg.value * 1000000) * 30 / 100000000;

        emit donatedBNB(msg.value, msg.value * (convertedPrice / 1e8) / 1e18, (msg.value * 1000000) * 30 / 100000000);
    }

    function donateBUSD(uint256 _amountBUSD) nonReentrant public {
        require((_amountBUSD >= minBUSD), "You must donate more than the minimum");

        uint256 oldBalance = address(this).balance;

        address receiver = address(this);
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = pancakeRouter.WETH();

        (IERC20(BUSD)).approve(address(pancakeRouter), _amountBUSD);
        (IERC20(BUSD)).transferFrom(address(msg.sender), address(this), _amountBUSD);
        pancakeRouter.swapExactTokensForETH(_amountBUSD, 0, path, receiver, block.timestamp + 120);

        uint256 bnbAmount = address(this).balance - oldBalance;

        donatedAmount[msg.sender] += _amountBUSD / 1e18;

        if (!nftContract.mintEnd()) {
            for (uint8 i = 0; i < 4; i++) {
                if(donatedAmount[msg.sender] >= tierCosts[i] && !getTierMintedStatus(msg.sender, i)){
                    mintedTier[msg.sender][i] = true;
                    nftContract.mint(1, msg.sender, i);
                }
            }
        }

        uint256 deposit = (bnbAmount * 1000000) * 70 / 100000000;
        uint256 tickets = (_amountBUSD / 1e18) / ticketCost;
        raffleContract.deposit{value: deposit}(address(msg.sender), tickets);

        if (tickets >= 1 && userStakedNFT[msg.sender].unlockTime != 0) {
            userStakedNFT[msg.sender].unlockTime = block.timestamp + lockTime;
        }

        totalDonatedBUSD += _amountBUSD;
        totalDonatedDollars += _amountBUSD / 1e18;
        totalBNBtoLiquidate += (bnbAmount * 1000000) * 30 / 100000000;

        emit donatedBUSD(_amountBUSD, (bnbAmount * 1000000) * 30 / 100000000);
    }
    
    function stakeNFT(address nftAddress, uint256 tokenId) public nonReentrant {
        require(userStakedNFT[msg.sender].tokenId == 0, "You must not have a stake already.");
        require(nftAddress == address(nftContract) || nftAddress == address(legacyNFT), "You can only stake our NFTs!");

        userStakedNFT[msg.sender].nftAddress = nftAddress;
        userStakedNFT[msg.sender].tokenId = tokenId;
        userStakedNFT[msg.sender].unlockTime = block.timestamp + lockTime;
        
        if(nftAddress == address(nftContract)) {
            userStakedNFT[msg.sender].stakeTier = nftContract.tier(tokenId) + 1;
            nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
        }

        if(nftAddress == address(legacyNFT)) {
            userStakedNFT[msg.sender].stakeTier = legacyNFT.nftLevel(tokenId);
            legacyNFT.safeTransferFrom(msg.sender, address(this), tokenId);
        }

        emit Staked(nftAddress, tokenId, userStakedNFT[msg.sender].stakeTier);        
    }

    function unstakeNFT() public nonReentrant {
        require(userStakedNFT[msg.sender].tokenId != 0, "You don't have any NFT staked.");
        require(block.timestamp >= userStakedNFT[msg.sender].unlockTime, "Your lock period has not elapsed.");

        address stakedNFT = userStakedNFT[msg.sender].nftAddress;
        uint256 stakedID = userStakedNFT[msg.sender].tokenId;
        uint256 stakedTier = userStakedNFT[msg.sender].stakeTier;

        if (stakedNFT == address(nftContract)) {
            nftContract.safeTransferFrom(address(this), msg.sender, stakedID);
            emit Unstaked(stakedNFT, stakedID, stakedTier);
        }

        if (stakedNFT == address(legacyNFT)) {
            legacyNFT.safeTransferFrom(address(this), msg.sender, stakedID);
            emit Unstaked(stakedNFT, stakedID, stakedTier);
        }

        userStakedNFT[msg.sender].nftAddress = address(0);
        userStakedNFT[msg.sender].tokenId = 0;
        userStakedNFT[msg.sender].unlockTime = 0;
        userStakedNFT[msg.sender].stakeTier = 0;
    }

    /*******************************************************************************************************/
    /********************************** Admin/Court Functions **********************************************/
    /*******************************************************************************************************/

    function withdrawBNB() public nonReentrant onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function withdrawTokens(address _token) public nonReentrant onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 amount = token.balanceOf(address(this));
        token.transfer(address(msg.sender), amount);
    }

    function sendToLP() public nonReentrant onlyCourt {
        _liquidate();
    }

    function setMinBNB(uint256 bnbMinAmount) external onlyOwner {
        minBNB = bnbMinAmount;
    }

    function setMinBUSD(uint256 busdMinAmount) external onlyOwner {
        minBUSD = busdMinAmount;
    }

    function setTierCost(uint8 tierId, uint256 cost) external onlyOwner {
       tierCosts[tierId] = cost;
    }

    function setVaultAddress(address _vaultContract) public onlyOwner {
        vaultContract = _vaultContract;
    }

    function setNFTAddress(address _nftContractAddress) public onlyOwner {
        nftContract = IShadowFiNFT(_nftContractAddress);
    }

    function setRaffleContract(address _raffleContract) public onlyOwner {
        raffleContract = IRaffle(_raffleContract);
    }

    function setLockTime(uint256 _lockTime) public onlyOwner {
        lockTime = _lockTime;
    }

    /*******************************************************************************************************/
    /************************************ Internal Functions ***********************************************/
    /*******************************************************************************************************/

    function _liquidate() internal {
        shadowFiToken.setIsTxLimitExempt(address(msg.sender), true);
        shadowFiToken.setIsTxLimitExempt(address(pancakeRouter), true);
        shadowFiToken.setIsTxLimitExempt(address(pancakePairToken), true);
        shadowFiToken.setIsFeeExempt(address(pancakePairToken), true);

        uint256 buyAmount = totalBNBtoLiquidate / 2;
        uint256 oldTokenBalance = shadowFiToken.balanceOf(address(this));

        address receiver = address(this);
        address[] memory path = new address[](2);   
        path[0] = pancakeRouter.WETH();
        path[1] = address(shadowFiToken);
        pancakeRouter.swapExactETHForTokens{value: buyAmount}(0, path, receiver, block.timestamp + 120);

        uint256 sumAmount = shadowFiToken.balanceOf(address(this)) - oldTokenBalance;

        shadowFiToken.approve(address(pancakeRouter), sumAmount);

        (uint256 amountToken, uint256 amountBNB, uint256 liquidity) = pancakeRouter.addLiquidityETH{value: buyAmount}(address(shadowFiToken), sumAmount, 0, 0, address(vaultContract), block.timestamp + 120);

        if (sumAmount > amountToken) {
            shadowFiToken.transfer(msg.sender, sumAmount - amountToken);
        }

        if (buyAmount > amountBNB) {
            payable(msg.sender).transfer(buyAmount - amountBNB);
        }

        shadowFiToken.setIsTxLimitExempt(address(msg.sender), false);
        shadowFiToken.setIsTxLimitExempt(address(pancakeRouter), false);
        shadowFiToken.setIsTxLimitExempt(address(pancakePairToken), false);
        shadowFiToken.setIsFeeExempt(address(pancakePairToken), false);

        totalBNBtoLiquidate = 0;

        emit Liquidated(amountToken, amountBNB, liquidity);
    }

    /*******************************************************************************************************/
    /************************************** View Functions *************************************************/
    /*******************************************************************************************************/

    function getTierMintedStatus(address user, uint8 tier) public view returns (bool) {
        return mintedTier[user][tier];
    }

    function getUserStakeInfo(address _user) public view returns (address nftAddress, uint256 tokenId, uint256 unlockTime, uint256 stakeTier) {
        return (userStakedNFT[_user].nftAddress, userStakedNFT[_user].tokenId, userStakedNFT[_user].unlockTime, userStakedNFT[_user].stakeTier);
    }

    function getUserStakedTier(address _user) public view returns (uint256) {
        return userStakedNFT[_user].stakeTier;
    }

    function _initTierCosts() internal {
        tierCosts[0] = 50;
        tierCosts[1] = 200;
        tierCosts[2] = 500;
        tierCosts[3] = 1000;
     }

    receive() external payable {}
    fallback() external payable {}
}