pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Uniswap/IUniswapV2Router.sol";

contract EarlyPreSale is Ownable{

    event LiquidityAdded (uint256);
    event NewMaxGasPrice (uint256);
    event NewWhitelistSigner (address);
    event Sold (uint256 amount);
    event VestingSet (address user, uint256 amount, uint256 startTime);
    event Vested (address user, uint256 amount);

    struct Vesting {
        uint256 totalAmount;
        uint256 vestedAmount;
        uint256 startTime;
    }

    IEarlyToken public earlyToken;
    IUniswapV2Router02 private immutable uniswapV2Router;
    address private uniswapV2Pair;
    address private immutable linkToken;
    address private whitelistSigner;
    address public marketingWallet;
    address public DAO_Wallet;
    uint256 public tokenPrice;
    uint256 public whiteListPrice;
    uint256 public tokenDEXPrice;
    uint256 public maxGasPrice;
    uint256 public whitelistCounter = 0;
    uint256 public constant MAX_WHITELIST = 141;
    uint256 private linkAmountToBuy;
    uint256 public vestingAllocationsLimit;

    uint256 public immutable preSaleStart;
    uint256 public immutable preSalePublicStart;
    uint256 public immutable preSaleEnd;

    uint256 private maxAmountToSellPublic;
    uint256 private marketingTax;
    uint256 public tokensSold = 0;
    uint256 public tokensSoldPublic = 0;
    uint256 public vestingAllocationsLocked = 0;

    //wallet address => user balance
    mapping(address => uint256) public preSaleTokens;

    mapping(address => Vesting) public vestingList;

    bool private hasSwappedAndBurned = false;

    /*
     * uint256[] memory _preSaleData - array of presale data
     *** ([tokenPrice, maxGasPrice, tokenDEXPrice, whiteListPrice, preSaleStart, preSalePublicStart
     *** , preSaleEnd, marketingTax, linkAmountToBuy, vestingAllocationsLimit])
     * address _marketingWallet - marketing wallet address
     * address _DAO_Wallet - DAO wallet address
     * uint256 _linkAmountToBuy - Amount of LINK tokens to buy after presale
     * IUniswapV2Router02 _uniswapV2Router - Router address
     * address _whitelistSigner - Signer of whitelist addresses
     */
    constructor(
        uint256[] memory _preSaleData,
        address _marketingWallet,
        address _DAO_Wallet,
        address _linkToken,
        IUniswapV2Router02 _uniswapV2Router,
        address _whitelistSigner
    ){
        tokenPrice = _preSaleData[0];
        whiteListPrice = _preSaleData[1];
        tokenDEXPrice = _preSaleData[2];
        maxGasPrice = _preSaleData[3];
        preSaleStart = _preSaleData[4];
        preSalePublicStart = _preSaleData[5];
        preSaleEnd = _preSaleData[6];
        marketingTax = _preSaleData[7];
        linkAmountToBuy = _preSaleData[8];
        vestingAllocationsLimit = _preSaleData[9];
        marketingWallet = _marketingWallet;
        DAO_Wallet = _DAO_Wallet;
        whitelistSigner = _whitelistSigner;

        linkToken = _linkToken;

        uniswapV2Router = _uniswapV2Router;
    }

    receive() external payable {}


    /*
     * Params
     * uint8 v - V number of signature
     * bytes32 r - R number of signature
     * bytes32 s - S number of signature
     *
     * Function allows user to buy tokens
     * 1st purchase for whitelisted walled should be between 1 and 2 BNB
     * Gas price is not allowed to be higher than limit
     * Only wallets can by
     * Can't buy over wallet limit and total presale limit
     * Message should contain enough BNB value
     */
    function buyTokens(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        require(msg.value > 0);
        uint256 amount;

        uint256 currentBalance = preSaleTokens[msg.sender];
        uint256 personalTokenPrice;

        //Setting token price for user
        /****** PRIVATE ******/
        if(block.timestamp <= preSalePublicStart){
            require (
                msg.value >= 10**18 && msg.value <= 24 * 10**18,
                "You can spend [1<=...<=24] BNB for discounted purchase"
            );
            require(currentBalance == 0, "Already purchased");
            require(isWhitelisted(msg.sender, v, r, s), "Not whitelisted");
            require(whitelistCounter < MAX_WHITELIST, "Whitelisted presale is closed");

            amount = msg.value / whiteListPrice * 10**18;
            whitelistCounter ++;
        /****** PUBLIC ******/
        } else {
            require (
                msg.value <= 10 * 10**18,
                "10 BNB transaction limit"
            );
            amount = msg.value / tokenPrice * 10**18;
            uint256 expectedTokensSold = tokensSoldPublic + amount;
            require(expectedTokensSold <= maxAmountToSellPublic, 'Over max amount');
            tokensSoldPublic += amount;
        }

        require(tx.gasprice <= maxGasPrice, "Over max gas price");

        require(tx.origin == msg.sender, "Wallets only!");
        require(block.timestamp >= preSaleStart, 'Pre-Sale has not started');
        require(block.timestamp <= preSaleEnd, 'Pre-Sale has ended');

        preSaleTokens[msg.sender] += amount;

        //Marketing tax
        uint256 amountToMarketing = msg.value * marketingTax / 10000;
        payable(marketingWallet).transfer(amountToMarketing);

        tokensSold += amount;
        emit Sold(amount);
    }


    /*
     * Function allows to claim bought tokens after presale
     */
    function claimEarlyTokens() external {
        require(hasSwappedAndBurned, "Has not swapped yet");
        require(preSaleTokens[msg.sender] != 0, "Nothing to claim");

        earlyToken.transfer(msg.sender, preSaleTokens[msg.sender]);
        preSaleTokens[msg.sender] = 0;
    }


    /*
     * Params
     * address _user - Wallet address that should receive tokens
     * uint256 _amount - amount of tokens to receive
     *
     * Function sets vesting for specific users. He will be able to vest these tokens
     * 1/3 every month for 3 months
     * Vesting can't be changed
     */
    function setVesting(address _user, uint256 _amount) external onlyOwner {
        require(_amount > 0);
        uint256 expectedVestingAllocationsLocked = vestingAllocationsLocked + _amount;
        require(expectedVestingAllocationsLocked <= vestingAllocationsLimit, "Over vesting limit");
        require(vestingList[_user].totalAmount == 0, "Vesting already set");
        vestingList[_user] = Vesting ({
            totalAmount: _amount,
            vestedAmount: 0,
            startTime: block.timestamp
        });

        vestingAllocationsLocked += _amount;
        emit VestingSet(_user, _amount, block.timestamp);
    }


    /*
     * Function sends vesting tokens to user wallet
     * (1/3 of total amount every month for 3 months)
     */
    function vestTokens() external  {
        Vesting storage vesting = vestingList[msg.sender];

        require(block.timestamp > vesting.startTime + 4 weeks, "You are too EARLY");

        uint256 roundsHavePassed = (block.timestamp - vesting.startTime) / 4 weeks;
        if(roundsHavePassed > 3){
            roundsHavePassed = 3;
        }

        uint256 amountToVest = vesting.totalAmount * roundsHavePassed / 3 - vesting.vestedAmount;
        require(amountToVest != 0, "Nothing to vest");

        earlyToken.transfer(msg.sender, amountToVest);
        vesting.vestedAmount += amountToVest;
        emit Vested(msg.sender, amountToVest);
    }


    /*
     * Params
     * address _earlyToken - Early Token address
     * uint256 amountToMint - Amount tokens to mint
     *
     * Function sets Early Token address and mints tokens on this contract
     */
    function setEarlyTokenAndMint(address _earlyToken, uint256 amountToMint) external onlyOwner{
        require (address(earlyToken) == address(0), 'EarlyToken already set');
        earlyToken = IEarlyToken(_earlyToken);
        earlyToken.preSaleMint(amountToMint);

        uint256 maxAmountToSell = amountToMint / 2;             //50% to sell. Rest to liquitidy/burn
        maxAmountToSellPublic = maxAmountToSell * 2/3;          // 2/3 to sell privately
    }


    /*
     * Params
     * uint256 _newMaxGasPrice - Maximum gas price (in wei)
     *
     * Function sets maximum gas price
     */
    function setMaxGasPrice(uint256 _newMaxGasPrice) external onlyOwner {
        maxGasPrice = _newMaxGasPrice;
        emit NewMaxGasPrice(_newMaxGasPrice);
    }


    /*
     * Params
     * address _whitelistSigner - Wallet of whitelist signer
     *
     * Function sets new whitelist signer.
     */
    function setWhitelistSigner(address _whitelistSigner) external onlyOwner {
        require(_whitelistSigner != address (0));
        whitelistSigner = _whitelistSigner;
        emit NewWhitelistSigner(_whitelistSigner);
    }


    /*
     * Params
     * address _marketingWallet - Marketing wallet address
     *
     * Function sets marketing wallet address
     */
    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != address (0));
        require(_marketingWallet != marketingWallet, "Already set");
        marketingWallet = _marketingWallet;
    }

    /*
     * Adds liquidity
     * Burns leftover tokens
     */
    function swapAndBurn(IEarlyOracle oracle) external onlyOwner{
        require(block.timestamp >= preSaleEnd, 'Pre-Sale is in progress');

        /************** Buying LINK tokens **************/
        //get reserves
        IUniswapPair linkPair = IUniswapPair(IUniswapV2Factory(uniswapV2Router.factory())
        .getPair(linkToken, uniswapV2Router.WETH()));
        (uint256 reserve1, uint256 reserve2, ) = linkPair.getReserves();

        //calculate requiredETH
        uint256 requiredETH = uniswapV2Router.getAmountIn(
            linkAmountToBuy,
            reserve2,
            reserve1
        );

        //Swap to LINK
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = linkToken;

        uniswapV2Router.swapETHForExactTokens{
        value: requiredETH
        }(
            linkAmountToBuy,
            path,
            address(earlyToken),
            block.timestamp+1200
        );

        /************** Add liquidity **************/
        //Setting price for DEX
        uint256 tokensToLiquidity = address(this).balance * 10**18 / tokenDEXPrice;
        //Adding Liquidity
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .getPair(address(earlyToken), uniswapV2Router.WETH());

        earlyToken.approve(address(uniswapV2Router), earlyToken.balanceOf(address(this)));

        uniswapV2Router.addLiquidityETH
        {
            value: address(this).balance
        }(
            address(earlyToken),
            tokensToLiquidity,
            0,
            0,
            DAO_Wallet,
            block.timestamp+1200
        );

        //Collect prices info for token
        oracle.collectTokenPrices();

        hasSwappedAndBurned = true;

        uint256 tokensToBurn = earlyToken.balanceOf(address(this)) - tokensSold - vestingAllocationsLimit;
        earlyToken.burn(tokensToBurn);

        emit LiquidityAdded(tokensToLiquidity);
    }


    /*
     * Params
     * address _user - User address
     * uint8 v - V number of signature
     * bytes32 r - R number of signature
     * bytes32 s - S number of signature
     *
     * Function checks if user is approved by whitelist signer
     */
    function isWhitelisted(
        address _user,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private returns(bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n52", //20 bytes in address + 32 bytes in uint256
                msg.sender,
                uint256(0x946335D38D9)
            )
        );

        address recoveredAddress = ecrecover(hash, v, r, s);

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (
            uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
            || (v != 27 && v != 28)
            || recoveredAddress == address(0)
        ) {
            return false;
        }
        return whitelistSigner == recoveredAddress;
    }
}



interface IEarlyToken {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function burn(uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function preSaleMint(uint256 amount) external;
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IEarlyOracle {
    function collectTokenPrices() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

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

interface IUniswapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}