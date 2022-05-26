/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

// File: contracts/ERC20.sol


pragma solidity ^0.8.6;

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

interface ITreasury {
    function updateTaxesAccrued(uint taxType, uint amt) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

struct Slot0 {
    // the current price
    uint160 sqrtPriceX96;
    // the current tick
    int24 tick;
    // the most-recently updated index of the observations array
    uint16 observationIndex;
    // the current maximum number of observations that are being stored
    uint16 observationCardinality;
    // the next maximum number of observations to store, triggered in observations.write
    uint16 observationCardinalityNext;
    // the current protocol fee as a percentage of the swap fee taken on withdrawal
    // represented as an integer denominator (1/x)%
    uint8 feeProtocol;
    // whether the pool is locked
    bool unlocked;
}

interface IUniPool {
    function slot0() external returns(Slot0 memory slot0);
    function liquidity() external returns(uint128 liquidity);
    function fee() external returns(uint24 fee);
    function token0() external returns(address token0);
    function token1() external returns(address token1);
    function tickSpacing() external returns(int24 tickSpacing);
    function tickBitmap(int16 i) external payable returns(uint256 o);
}


interface ILiquidityPoolV4 {

}

interface IDapperTri {
    function get_paid(
        address[3] memory _route, 
        uint8[3] memory _exchanges, 
        uint24[4] memory _poolFees, 
        address _borrow, 
        uint _borrowAmt
    ) external;
}

struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
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
}

interface IUniswapQuoterV3 {
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external view returns (uint256 amountOut);
}

interface IUniswapRouterV3 {
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

// https://etherscan.io/address/0x2F9EC37d6CcFFf1caB21733BdaDEdE11c823cCB0#code
interface IBancorNetwork {
     function conversionPath(
         IERC20 _sourceToken, 
         IERC20 _targetToken
    ) external view returns (address[] memory);
    function convert(
        address[] memory path,
        uint256 sourceAmount,
        uint256 minReturn
    ) external payable returns (uint256);
    function convertByPath(
        address[] memory path,
        uint256 sourceAmount,
        uint256 minReturn,
        address payable beneficiary,
        address affiliate,
        uint256 affiliateFee
    ) external payable returns (uint256);
    function rateByPath(
        address[] memory path, 
        uint256 sourceAmount
    ) external view returns (uint256);
}

// https://etherscan.io/address/0x8301ae4fc9c624d1d396cbdaa1ed877821d7c511#code (ETH/CRV)
// https://etherscan.io/address/0xDC24316b9AE028F1497c275EB9192a3Ea0f67022#code (ETH/stETH)
interface ICRVMetaPool {
    // i = token_from
    // j = token_to
    // dx = token_from_change
    // min_dy = token_to_min_receive
    // function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256); 
    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256); 
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256); 
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external payable returns(uint256);
    function exchange_underlying(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256);
    function add_liquidity(uint256[] memory amounts_in, uint256 min_mint_amount) external payable returns(uint256);
    function remove_liquidity(uint256 amount, uint256[] memory min_amounts_out) external returns(uint256[] memory);
}

interface ICRV {
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable; 
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external payable;
}

interface ICRV_PP_128_NP {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256);
}
interface ICRV_PP_256_NP {
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external;
    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256);
}
interface ICRV_PP_256_P {
    function exchange_underlying(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256);
    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256);
}
interface ICRV_MP_256 {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external payable returns(uint256);
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external payable returns(uint256);
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256);
}

interface ICRVSBTC {
    // i = token_from
    // j = token_to
    // dx = token_from_change
    // min_dy = token_to_min_receive
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256); 
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256); 
    function add_liquidity(uint256[3] memory amounts_in, uint256 min_mint_amount) external;
    function remove_liquidity(uint256 amount, uint256[3] memory min_amounts_out) external;
    function remove_liquidity_one_coin(uint256 token_amount, int128 index, uint min_amount) external;
}

interface ICRVSBTC_CRV {
    // i = token_from
    // j = token_to
    // dx = token_from_change
    // min_dy = token_to_min_receive
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256); 
    // function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy, address _receiver) external; 
    function add_liquidity(uint256[3] memory amounts_in, uint256 min_mint_amount) external;
    function remove_liquidity(uint256 amount, uint256[3] memory min_amounts_out) external;
    function remove_liquidity_one_coin(uint256 token_amount, int128 index, uint min_amount) external;
}

// https://etherscan.io/address/0xd9e1ce17f2641f24ae83637ab66a2cca9c378b9f#code
interface ISushiRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

// https://etherscan.io/address/0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0#code
interface IWSTETH {
    function wrap(uint256 _stETHAmount) external returns (uint256);
    function unwrap(uint256 _wstETHAmount) external returns (uint256);
}

interface IVault {
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}

interface IWETH {
    function deposit() external payable;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// File: contracts/Treasury.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;



/// @notice The treasury is responsible for escrow of TaxToken fee's.
///         The treasury handles accounting, for what's owed to different groups.
///         The treasury handles distribution of TaxToken fees to different groups.
///         The admin can modify how TaxToken fees are distributed (the TaxDistribution struct).
contract Treasury {
 
    // ---------------
    // State Variables
    // ---------------

    address public taxToken;   /// @dev The token that fees are taken from, and what is held in escrow here.
    address public admin;      /// @dev The administrator of accounting and distribution settings.

    address public UNIV2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public UNI_VAR = IUniswapV2Router01(UNIV2_ROUTER).WETH();

    uint public taxTokenDistributionThreshold;      /// @dev The threshold for distributing taxes automatically.

    /// @notice Handles the internal accounting for how much taxToken is owed to each taxType.
    /// @dev    e.g. 10,000 taxToken owed to taxType 0 => taxTokenAccruedForTaxType[0] = 10000 * 10**18
    ///         taxType 0 => Xfer Tax
    ///         taxType 1 => Buy Tax
    ///         taxType 2 => Sell Tax
    mapping(uint => uint) public taxTokenAccruedForTaxType;

    mapping(uint => TaxDistribution) public taxSettings;   /// @dev Mapping of taxType to TaxDistribution struct.

    mapping(address => uint) public royaltiesDistributed_WETH;
    mapping(address => uint) public royaltiesDistributed_TaxToken;
 
    /// @notice Manages how TaxToken is distributed for a given taxType.
    ///         Variables:
    ///           walletCount           => The number of wallets to distribute fees to.
    ///           wallets               => The addresses to distribute fees (maps with convertToAsset and percentDistribution)
    ///           convertToAsset        => The asset to pre-convert taxToken to prior to distribution (if same as taxToken, no conversion executed).
    ///           percentDistribution   => The percentage of taxToken accrued for taxType to distribute.
    struct TaxDistribution {
        uint walletCount;
        address[] wallets;
        address[] convertToAsset;
        uint[] percentDistribution;
    }

    struct WETHWallet {
        address walletAddress;
        address asset;
        uint percentDistribution;
    }


    // -----------
    // Constructor
    // -----------

    /// @notice Initializes the Treasury.
    /// @param  _admin      The administrator of the contract.
    /// @param  _taxToken   The taxToken (ERC-20 asset) which accumulates in this Treasury.
    constructor(address _admin, address _taxToken) {
        admin = _admin;
        taxToken = _taxToken;
    }


    // ------
    // Events
    // ------

    event LogUint(string s, uint u);


 
    // ---------
    // Modifiers
    // ---------

    /// @dev    Enforces msg.sender is admin.
    modifier isAdmin {
        require(msg.sender == admin);
        _;
    }

    /// @dev    Enforces msg.sender is taxToken.
    modifier isTaxToken {
        require(msg.sender == taxToken);
        _;
    }


    // ---------
    // Functions
    // ---------

    /// @notice Increases _amt of taxToken allocated to _taxType.
    /// @dev    Only callable by taxToken.
    /// @param  _taxType The taxType to allocate more taxToken to for distribution.
    /// @param  _amt The amount of taxToken going to taxType.
    function updateTaxesAccrued(uint _taxType, uint _amt) isTaxToken public {
        taxTokenAccruedForTaxType[_taxType] += _amt;
        if (taxTokenDistributionThreshold != 0) {
            if (IERC20(taxToken).balanceOf(address(this)) >= taxTokenDistributionThreshold) {
                distributeAllTaxes();
            }
        }
    }

    /// @notice Set taxTokenDistributionThreshold to new value.
    /// @dev    Only callable by Admin.
    /// @param  _threshold The new value for taxTokenDistributionThreshold. 
    function setDistributionThreshold(uint _threshold) isAdmin public {
        taxTokenDistributionThreshold = _threshold * 10**18;
    }

    /// @notice View function for taxes accrued (a.k.a. "claimable") for each tax type, and the sum.
    /// @return _taxType0 Taxes accrued (claimable) for taxType0.
    /// @return _taxType1 Taxes accrued (claimable) for taxType1.
    /// @return _taxType2 Taxes accrued (claimable) for taxType2.
    /// @return _sum Taxes accrued (claimable) for all tax types.
    function viewTaxesAccrued() public view returns(uint _taxType0, uint _taxType1, uint _taxType2, uint _sum) {
        return (
            taxTokenAccruedForTaxType[0],
            taxTokenAccruedForTaxType[1],
            taxTokenAccruedForTaxType[2],
            taxTokenAccruedForTaxType[0] + taxTokenAccruedForTaxType[1] + taxTokenAccruedForTaxType[2]
        );
    }

    /// @notice This function modifies the distribution settings for a given taxType.
    /// @dev    Only callable by Admin.
    /// @param  taxType The taxType to update settings for.
    /// @param  walletCount The number of wallets to distribute across.
    /// @param  wallets The address of wallets to distribute fees across.
    /// @param  convertToAsset The asset to convert taxToken to, prior to distribution.
    /// @param  percentDistribution The percentage (corresponding with wallets) to distribute taxes to of overall amount owed for taxType.
    function setTaxDistribution(
        uint taxType,
        uint walletCount,
        address[] calldata wallets,
        address[] calldata convertToAsset,
        uint[] calldata percentDistribution
    ) isAdmin public {

        // Pre-check that supplied values have equal lengths.
        require(walletCount == wallets.length, "err walletCount length != wallets.length");
        require(walletCount == convertToAsset.length, "err walletCount length != convertToAsset.length");
        require(walletCount == percentDistribution.length, "err walletCount length != percentDistribution.length");

        // Enforce sum(percentDistribution) = 100;
        uint sumPercentDistribution;
        for(uint i = 0; i < walletCount; i++) {
            sumPercentDistribution += percentDistribution[i];
        }
        require(sumPercentDistribution == 100, "err sumPercentDistribution != 100");

        // Update taxSettings for taxType.
        taxSettings[taxType] = TaxDistribution(
            walletCount,
            wallets,
            convertToAsset,
            percentDistribution
        );
    }

    /// @notice Distributes taxes for given taxType.
    /// @param  taxType Chosen taxType to distribute.
    /// @return amountToDistribute TaxToken amount distributed.
    function distributeTaxes(uint taxType) public returns(uint) {
        
        uint amountToDistribute = taxTokenAccruedForTaxType[taxType];

        if(amountToDistribute > 0) {

            taxTokenAccruedForTaxType[taxType] = 0;
            // will only be at most the size of the number of wallets
            WETHWallet[] memory WETHWallets = new WETHWallet[](taxSettings[taxType].wallets.length);
            uint totalWETHDistributions = 0;
            uint totalWETHWallets = 0;

            for(uint i = 0; i < taxSettings[taxType].wallets.length; i++) {

                address walletToAirdrop = taxSettings[taxType].wallets[i];
                uint percentDistribution = taxSettings[taxType].percentDistribution[i];
                uint amountForWallet = (amountToDistribute * percentDistribution) / 100;

                if(taxSettings[taxType].convertToAsset[i] == taxToken) {
                    // distribute tax tokens to the wallet
                    royaltiesDistributed_TaxToken[walletToAirdrop] += amountForWallet;
                    IERC20(taxToken).transfer(walletToAirdrop, amountForWallet);
                }
                else if(taxSettings[taxType].convertToAsset[i] != taxToken) {
                    // sum total tax tokens to convert to WETH & add all indices into WETHWallets
                    WETHWallets[totalWETHWallets] = WETHWallet(
                        walletToAirdrop,
                        taxSettings[taxType].convertToAsset[i],
                        percentDistribution
                    );
                    totalWETHDistributions += taxSettings[taxType].percentDistribution[i];
                    totalWETHWallets += 1;
                }
            }

            // get "amountToDistributeWETH" aka the leftover taxTokens from the original
            // amountToDistribute and convert these taxTokens to WETH.
            uint amountToDistributeWETH = (amountToDistribute * totalWETHDistributions) / 100;

            if (amountToDistributeWETH > 0) {
                IERC20(address(taxToken)).approve(address(UNIV2_ROUTER), amountToDistributeWETH);

                address[] memory path_uni_v2 = new address[](2);

                path_uni_v2[0] = address(taxToken);
                path_uni_v2[1] = UNI_VAR;

                IUniswapV2Router01(UNIV2_ROUTER).swapExactTokensForTokens(
                    amountToDistributeWETH,           
                    0,
                    path_uni_v2,
                    address(this),
                    block.timestamp + 30000
                );

                uint WETHToDistribute = IERC20(UNI_VAR).balanceOf(address(this));

                emit LogUint('weth_portion', WETHWallets[1].percentDistribution);

                for(uint i = 0; i < totalWETHWallets; i++) {
                    
                    address walletToAirdrop = WETHWallets[i].walletAddress;
                    uint proportionalDistribution = (WETHWallets[i].percentDistribution * 10000) / totalWETHDistributions;
                    emit LogUint('prop_dist', (WETHWallets[i].percentDistribution * 10000) / totalWETHDistributions);
                    uint amountForWallet = (WETHToDistribute * proportionalDistribution) / 10000;
                    royaltiesDistributed_WETH[walletToAirdrop] += amountForWallet;
                    IERC20(UNI_VAR).transfer(walletToAirdrop, amountForWallet);
                }
            }
        }

        return amountToDistribute;
    }

    /// @notice Distributes taxes for all taxTypes.
    function distributeAllTaxes() public {
        distributeTaxes(0);
        distributeTaxes(1);
        distributeTaxes(2);
    }


    /// @notice Helper view function for taxSettings.
    function viewTaxSettings(uint taxType) public view returns(uint256, address[] memory, address[] memory, uint[] memory) {
        return (
            taxSettings[taxType].walletCount,
            taxSettings[taxType].wallets,
            taxSettings[taxType].convertToAsset,
            taxSettings[taxType].percentDistribution
        );
    }

    /// @notice Withdraw a non-taxToken from the treasury.
    /// @dev    Reverts if token == taxtoken.
    /// @dev    Only callable by Admin.
    /// @param  token The token to withdraw from the treasury.
    function safeWithdraw(address token) public isAdmin {
        require(token != taxToken, "err cannot withdraw native tokens from this contract");
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    /// @notice Change the admin for the treasury.
    /// @dev    Only callable by Admin.
    /// @param  _admin New admin address.
    function updateAdmin(address _admin) public isAdmin {
        admin = _admin;
    }

}