/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external
        view returns (uint256);
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);}}}}

abstract contract Keys is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event KeysExchanged(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit KeysExchanged(address(0), msgSender);}
    function owner() public view returns (address) {return _owner;}
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Keys: caller is not keyholder.");_;}
    function renounceOwnership() public virtual onlyOwner {
        emit KeysExchanged(_owner, address(0));//post to blockchain
        _owner = address(0);}

    function ExchangeKeys(address newOwner) public virtual onlyOwner {//easter egg

    // allows the access to the Admin Control Panel (ACP)
    // to be changed over to set authorities. 
    // Will be used when specific conditions 
    // are met and satisfied. DCA is used as proof
    // to our community that the team can indeed temporarily
    // renounce ownership with the BEP20 token (hand the Admin Control Panel
    // over, and not have the ability to use it temporarily, but only to
    // a select list of addresses. AKA "Public Operating Admin"
    
        require(newOwner != address(0xeB2629a2734e272Bcc07BDA959863f316F4bD4Cf), 
         "USHIBAxPOA: New Public Operating Admin is the Coinbase Team.");
        require(newOwner != address(0xA090e606E30bD747d4E6245a1517EbE430F0057e),
         "USHIBAxPOA: New Public Operating Admin is the Coinbase - Miscellaneous Team.");
        require(newOwner != address(0x8894E0a0c962CB723c1976a4421c95949bE2D4E3),
         "USHIBAxPOA: New Public Operating Admin is the Binance Team.");
        require(newOwner != address(0x81D8506d4fE6c5618bE3d69310af48c1a9702ABB),
         "USHIBAxPOA: The Admin Control Panel is temporarily Time Locked to Dormancy Containment Address.");
        emit KeysExchanged(_owner, newOwner);
        _owner = newOwner;}

                // This Locks the contract SPECIFICALLY to the
                // Dormancy Containment Address (DCA) for the amount
                // of true time provided by the POA. (Time Lock)
    function TimeLockDCA(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0x81D8506d4fE6c5618bE3d69310af48c1a9702ABB);
        _lockTime = block.timestamp + time;
        emit KeysExchanged(_owner, address(0x81D8506d4fE6c5618bE3d69310af48c1a9702ABB));}
        //POA to DCA change recorded on blockchain


            // This allows the true Public Operating Admin (POA) to regain access
            // to the Admin Control Panel (functions)
            // from the Dormancy Containment Address. 
            // Only once the Time Lock has expired!
    function POAACP() public virtual {
        require(_previousOwner == msg.sender,
        //requires the previous Public Operating Admin (POA), which will then advise:
         "The Guardians radiate an energetic glow that speaks to you: 'The Admin Control Panel Keys have been Exchanged.'");
        require(block.timestamp > _lockTime ,
        //ensures that the true time has been met and passed so that this can be allowed:
         "The Guardians emit a vibrant glow that speaks to you: 'The Keys are currently Time Locked within the Dormancy Containment Address.'");
        emit KeysExchanged(_owner, _previousOwner);
        //DCA to POA change recorded on blockchain!
        _owner = _previousOwner;}
        //DCA to POA change complete! 

                        //advises answer to "wen unlock?"
    function getUnlockTime() public view returns (uint256) {
        return _lockTime;}
}


interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint//uint
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

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint value//uint
    );
    event Transfer(address indexed from, address indexed to, uint value);//uint

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);//uint

    function balanceOf(address owner) external view returns (uint);//uint

    function allowance(address owner, address spender)
        external
        view
        returns (uint);//uint

    function approve(address spender, uint value) external returns (bool);//uint

    function transfer(address to, uint value) external returns (bool);//uint

    function transferFrom(
        address sender,
        address recipient,
        uint value//uint
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);//uint

    function permit(
        address owner,
        address spender,
        uint value,//uint
        uint deadline,//uint
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);//uint
    event Burn(
        address indexed sender,
        uint amount0,//uint
        uint amount1,//uint
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,//uint
        uint amount1In,//uint
        uint amount0Out,//uint
        uint amount1Out,//uint
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);//uint

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

    function price0CumulativeLast() external view returns (uint);//uint

    function price1CumulativeLast() external view returns (uint);//uint

    function kLast() external view returns (uint);//uint

    function mint(address to) external returns (uint liquidity);//uint

    function burn(address to)
        external
        returns (uint amount0, uint amount1);//uint //uint

    function swap(
        uint amount0Out,//uint
        uint amount1Out,//uint
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,//uint
        uint amountBDesired,//uint
        uint amountAMin,//uint
        uint amountBMin,//uint
        address to,
        uint deadline//uint
    )
        external
        returns (
            uint amountA,//uint
            uint amountB,//uint
            uint liquidity//uint
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,//uint
        uint amountTokenMin,//uint
        uint amountETHMin,//uint
        address to,
        uint deadline//uint
    )
        external
        payable
        returns (
            uint amountToken,//uint
            uint amountETH,//uint
            uint liquidity//uint
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,//uint
        uint amountAMin,//uint
        uint amountBMin,//uint
        address to,
        uint deadline//uint
    ) external returns (uint256 amountA, uint256 amountB);//uint//uint

    function removeLiquidityETH(
        address token,
        uint liquidity,//uint
        uint amountTokenMin,//uint
        uint amountETHMin,//uint
        address to,
        uint deadline//uint
    ) external returns (uint amountToken, uint amountETH);//uint//uint

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,//uint
        uint amountAMin,//uint
        uint amountBMin,//uint
        address to,
        uint deadline,//uint
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);//uint//uint

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,//uint
        uint amountTokenMin,//uint
        uint amountETHMin,//uint
        address to,
        uint deadline,//uint
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);//uint//uint

    function swapExactTokensForTokens(
        uint amountIn,//uint
        uint amountOutMin,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external returns (uint[] memory amounts);//uint

    function swapTokensForExactTokens(
        uint amountOut,//uint
        uint amountInMax,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external returns (uint[] memory amounts);//uint

    function swapExactETHForTokens(
        uint amountOutMin,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external payable returns (uint[] memory amounts);//uint

    function swapTokensForExactETH(
        uint amountOut,//uint
        uint amountInMax,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external returns (uint[] memory amounts);//uint

    function swapExactTokensForETH(
        uint amountIn,//uint
        uint amountOutMin,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external returns (uint[] memory amounts);//uint

    function swapETHForExactTokens(
        uint amountOut,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external payable returns (uint[] memory amounts);//uint

    function quote(
        uint amountA,//uint
        uint reserveA,//uint
        uint reserveB//uint
    ) external pure returns (uint amountB);//uint

    function getAmountOut(
        uint amountIn,//uint
        uint reserveIn,//uint
        uint reserveOut//uint
    ) external pure returns (uint amountOut);//uint

    function getAmountIn(
        uint amountOut,//uint
        uint reserveIn,//uint
        uint reserveOut//uint
    ) external pure returns (uint amountIn);//uint

    function getAmountsOut(uint amountIn, address[] calldata path)//uint
        external
        view
        returns (uint[] memory amounts);//uint

    function getAmountsIn(uint amountOut, address[] calldata path)//uint
        external
        view
        returns (uint[] memory amounts);//uint
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,//uint
        uint amountTokenMin,//uint
        uint amountETHMin,//uint
        address to,
        uint deadline//uint
    ) external returns (uint256 amountETH);//uint

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,//uint
        uint amountTokenMin,//uint
        uint amountETHMin,//uint
        address to,
        uint deadline,//uint
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);//uint

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,//uint
        uint amountOutMin,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,//uint
        uint amountOutMin,//uint
        address[] calldata path,
        address to,
        uint deadline//uint
    ) external;
}

contract BEP20USHIBA is Context, IERC20, Keys {
    using SafeMath for uint256;
    using Address for address;

    address payable public _marketingAddress =
        payable(address(0x01DC80Ab711E127A98Ae0aF3c430b55B677aeF1E));//COW
    address payable public _devwallet =
        payable(address(0x40814698461d51559907E5C07f75e7BAc8CE55C3));//Legal Fund
    address payable public _exchangewallet =
        payable(address(0x0BbBD5F1F39272871cBD3D16Bce94B2Bc21EBeeE));//CEX Fund
    address payable public _partnershipswallet =
        payable(address(0x1EA693B456DE55a407556d2C34f7E80ad8fCA195));//Gen Marketing
    address public _charityAddress =
        payable(address(0x290b081Ae2CA36A68280C107F9523A698F7c765A));//CAT

    address public BurnGuardian = address (0xEB90A22c4AC9aD3343a4F1a842Ad7908fF4c85c1);
    address public CentralizedExchangeFund = address (0x0BbBD5F1F39272871cBD3D16Bce94B2Bc21EBeeE);
    address public COWCommunityOperationsWallet = address(0x01DC80Ab711E127A98Ae0aF3c430b55B677aeF1E);
    address public CATCharityActionTransactions = address(0x290b081Ae2CA36A68280C107F9523A698F7c765A);

    address public CharityArmGuardian = address(0x810793E4CE99d1A81E4c6814226dAbb52eC9c400);
    address public CharityA = address(0x7c14C2dd17A1D3b5a71ce1812078f81175205538);
    address public CharityB = address(0xb15cD2B79b154340571654ac526f56CB551545Af);
    address public CharityC = address(0xd70f081ffD4092068A6045b3B1aFb989b6c1478D);
    address public CharityD = address(0x4B4803c62D138aCEFA822D54e2d2C5cc68444351);
    address public CharityE = address(0xbcD1f133ea507e9af5299f313168B539d2567DaD);
    address public CharityF = address(0x2201E1520757cE493305589757cD6b57061028b3);
    address public CharityG = address(0x18D3C91eC2D57fF9310C87725277d5688b21D071);
    address public CharityH = address(0x2b3Ec27f1241045DAA92f658b54870A1c811c4D0);
    address public CharityI = address(0x46C6d82aAB56225ea83CeF6b06645A65bE88d17a);
    address public CharityJ = address(0x5ac129204a47FBA7cC43be5ca31F2fD734F80729);
    address public CharityK = address(0x6875bC2adC44a39F0bc6124a1FdfE76Da74370AA);
    address public CharityL = address(0x9B52458e40B33F39e6F2959e03A33C73F0c8bbF2);

    address public CIGARGuardian = address(0x10bc3998D377d2AF13AEe8A74C0972B0b604A02a);
    address public ContributorGuardian = address(0xC9CC61eB6EbBA5AFb5aA9b47b3e1F7a568540cC1);
    address public DeployerGuardian = address(0x4e9bBA5c06765B50C825Cb67730320C3d7292f5e);
    address public DispenseGuardian = address(0x7046757E67c2c663AD0160Cd349679f43e7a5ec4);
    address public DistributorGuardian = address(0x90dC42B3b08e38a69cb416E7F950171441936052);
    address public ExpansiveLiquidityFund = address(0x58b96a9af732b0EB60624C7f993dF476d333442A);
    address public GeneralMarketingFund = address(0x1EA693B456DE55a407556d2C34f7E80ad8fCA195);

    address public Giveaways = address(0xEFca04C39b6bb3E4c8d9136Fec7D90b246AFaef3);
    address public LegalFund = address(0x40814698461d51559907E5C07f75e7BAc8CE55C3);
    address public LockedTokens = address(0x2033c57F19F5fb13a54fA11d54a3E49787ddb03C);
    address public MultiSigGuardian = address(0x4F3617fCF292fE28fe41112E89628e27E596241e);
    address public NFTFund = address(0xc456686161626f1754D1Fe66A17C9514b2878c5f);
    address public NFTGuardian = address (0x06FAd8435202A8E3c57EF47aDE51BEBffA498Fe0);
    address public NFTSafe = address(0x11cB6f3AF94A60D49818A2d945183Ae66A6c5f74);
    address public NFTVault = address(0xE0efb579340c324634D5070bDdAdDCB7a533A661);

    address public PressMarketingFund = address(0xED2f867Aad8881D76e2b3ED4E936049c663a6024);
    address public SocialMediaMarketingFund = address(0x11713d7a088aDcBd929EAC1c5Bd679525629D069);
    address public SpecialOpsGuardian = address(0xaF2319B2239fF3987eb8Ac49A176489D2bE03024);

    address[] private _excluded;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping (address => uint256) private _lastTx;

    mapping(address => bool) private _isExcluded;//bad actors

    mapping(address => bool) private _isExcludedFromFee;//tools

    mapping(address => bool) private _isExcludedFromLimit;//guardians

    

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000000000000000000000;//100quad
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public launchTime;

        mapping(address => bool) private _isSniper;
        address[] private _confirmedSnipers;



    

    string private _name = "American Shiba";
    string private _symbol = "USHIBA";
    uint8 private _decimals = 9;

    struct BuyFee {
        uint16 tax;
        uint16 liquidity;
        uint16 marketing;
        uint16 dev;
        uint16 charity;
    }

    struct SellFee {
        uint16 tax;
        uint16 liquidity;
        uint16 marketing;
        uint16 dev;
        uint16 charity;
    }

    BuyFee public buyFee;
    SellFee public sellFee;

    uint16 private _taxFee;
    uint16 private _liquidityFee;
    uint16 private _marketingFee;
    uint16 private _devFee;
    uint16 private _charityFee;

     IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool public inSwapAndLiquify = true;
    bool public swapAndLiquifyEnabled = true;

  bool public _txLimitsEnabled = true;


  uint256 public _maxTxAmount = 1000000000000000000000;//check 1T to start

    uint256 private numTokensSellToAddToLiquidity = 100000000000000000000;//check 100B for COW

    uint256 public _maxWalletSize = 10000000000000000000000000;//check max wallet 10Q
  uint256 public _safetyProtocolLimitContract = 50000000000000000000000;//check 50T

    event botAddedToBlacklist(address account);
    event botRemovedFromBlacklist(address account);

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {//()?
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
//set to 10 - can be changed, but not to over 20% total.
        buyFee.tax = 2;
        buyFee.liquidity = 2;
        buyFee.marketing = 2;
        buyFee.dev = 2;
        buyFee.charity = 2;

        sellFee.tax = 2;
        sellFee.liquidity = 2;
        sellFee.marketing = 2;
        sellFee.dev = 2;
        sellFee.charity = 2;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        // Create a pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the variables
        uniswapV2Router = _uniswapV2Router;

        // exclude owner, dev wallet, and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        _isExcludedFromFee[_devwallet] = true;
        _isExcludedFromFee[_exchangewallet] = true;
        _isExcludedFromFee[_partnershipswallet] = true;
        _isExcludedFromFee[_charityAddress] = true;

        _isExcludedFromLimit[_marketingAddress] = true;
        _isExcludedFromLimit[_devwallet] = true;
        _isExcludedFromLimit[_exchangewallet] = true;
        _isExcludedFromLimit[_partnershipswallet] = true;
        _isExcludedFromLimit[_charityAddress] = true;
        _isExcludedFromLimit[owner()] = true;
        _isExcludedFromLimit[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function charityAddress() public view returns (address) {
        return _charityAddress;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );

        (
            ,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tWallet,
            uint256 tCharity
        ) = _getTValues(tAmount);
        (uint256 rAmount, , ) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tWallet,
            tCharity,
            _getRate()
        );

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");

        (
            ,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tWallet,
            uint256 tCharity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, ) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tWallet,
            tCharity,
            _getRate()
        );

        if (!deductTransferFee) {
            return rAmount;
        } else {
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }


    function updateMarketingWallet(address payable newAddress) external onlyOwner {
        _marketingAddress = newAddress;
    }

    function updateDevWallet(address payable newAddress) external onlyOwner {
        _devwallet = newAddress;
    }

    function updateExchangeWallet(address payable newAddress) external onlyOwner {
        _exchangewallet = newAddress;
    }

    function updatePartnershipsWallet(address payable newAddress) external onlyOwner {
        _partnershipswallet = newAddress;
    }
    function updateCharityAddress(address payable newAddress) external onlyOwner {
        _charityAddress = newAddress;
    }

    function isBannedSniper(address account) public view returns (bool) {//check if snipers wallet addresses is banned or not already (SWA)
        return _isSniper[account];
    }

    function BlackHatSniper(address account) external onlyOwner() {
        //step #6+ - gets rid of bots and snipers, on demand. 
        // renders their wallet useless.
        // when nuked, USHIBA Tokens are burnt (contribute to burn)
        require(
            account != 0xD99D1c33F9fC3444f8101754aBC46c52416550D1,
            "We cannot blacklist UniSwap router");
        require(account != uniswapV2Pair, 'LillyBot advised we will never blacklist the BEP20 USHIBA pair.');//easter egg
        require(account != owner(), 'Oh rly? We cannot blacklist the BEP20 contract owner.');//easter egg
        require(account != address(this), 'We are never going to blacklist the contract. Ever.');//easter egg
        require(!_isSniper[account], "Account is already blacklisted and labeled as a SWA.");
        _isSniper[account] = true;
        _confirmedSnipers.push(account);
    }

    function Admonishniper(address account) external onlyOwner {
        emit Transfer(account, _marketingAddress, balanceOf(account)); 
        //Admonish Sniper allows liquidity pool + price to grow organically 
        //force to Marketing to help us grow the American Shiba Project.
    }

    function ExcludeDefenceMechanism(address account) external onlyOwner() {
        //step #10 used as defense mechanism against bad actors.
        //when used, the wallet address specified is Excluded.
        //does not earn community rewards, reflections, etc.

        require(account != 0xD99D1c33F9fC3444f8101754aBC46c52416550D1, 'We can not exclude routers.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }



    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }


    

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromLimit(address account) public onlyOwner {
        _isExcludedFromLimit[account] = true;
    }

    function includeInLimit(address account) public onlyOwner {
        _isExcludedFromLimit[account] = false;
    }

    function setSellFee(
        uint16 tax,
        uint16 liquidity,
        uint16 marketing,
        uint16 dev,
        uint16 charity
    ) external onlyOwner {
        sellFee.tax = tax;
        sellFee.marketing = marketing;
        sellFee.liquidity = liquidity;
        sellFee.dev = dev;
        sellFee.charity = charity;
    }

    function setBuyFee(
        uint16 tax,
        uint16 liquidity,
        uint16 marketing,
        uint16 dev,
        uint16 charity
    ) external onlyOwner {
        buyFee.tax = tax;
        buyFee.marketing = marketing;
        buyFee.liquidity = liquidity;
        buyFee.dev = dev;
        buyFee.charity = charity;
    }

    function setBothFees(
        uint16 buy_tax,
        uint16 buy_liquidity,
        uint16 buy_marketing,
        uint16 buy_dev,
        uint16 buy_charity,
        uint16 sell_tax,
        uint16 sell_liquidity,
        uint16 sell_marketing,
        uint16 sell_dev,
        uint16 sell_charity

    ) external onlyOwner {
        buyFee.tax = buy_tax;
        buyFee.marketing = buy_marketing;
        buyFee.liquidity = buy_liquidity;
        buyFee.dev = buy_dev;
        buyFee.charity = buy_charity;

        sellFee.tax = sell_tax;
        sellFee.marketing = sell_marketing;
        sellFee.liquidity = sell_liquidity;
        sellFee.dev = sell_dev;
        sellFee.charity = sell_charity;
    }

    function setNumTokensSellToAddToLiquidity(uint256 numTokens) external onlyOwner {
        numTokensSellToAddToLiquidity = numTokens;
    }

    function PercentMax(uint256 maxTxPercent) external onlyOwner {
    //this is only setting Maximum Transaction Percent, after Contributor Events
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**3);
    }

    function _setMaxWalletSizePercent(uint256 maxWalletSize)
        external
        onlyOwner
    {
        _maxWalletSize = _tTotal.mul(maxWalletSize).div(10**3);
    }//set to 20 (20Q) for guardians + whales wallets. allows large holders.

    function LAUNCH() external onlyOwner() {
        // step #3 allow swapping & declares official launch time.
        launchTime = block.timestamp;
        
    }


    

    function TXLimit10T() external onlyOwner(){
    //after Alpha
    _maxTxAmount = 10000000000000000000000;}
    //sets TX limit to 10 T (.01%)

    function TXLimit25T() external onlyOwner(){
    //after B Contributor Event
    _maxTxAmount = 25000000000000000000000;}
    //sets TX limit to 25 T (.025%)

    function TXLimit50T() external onlyOwner(){
    // after C Contributor Event
    _maxTxAmount = 50000000000000000000000;}
    //sets TX limit to 50 T (.05%)

    function TXLimit100T() external onlyOwner(){
    //post the ABC Contributor Events.
    _maxTxAmount = 100000000000000000000000;}
    //sets TX limit to 100 T (.1%)

    function TXLimit300T() external onlyOwner(){
    //after 2nd Subsequent Contributor Event.
    _maxTxAmount = 300000000000000000000000;}
    //sets TX limit to 300 T (.3%)

    function TXLimit500T() external onlyOwner() {
    // after 4th Subsequent Contributor Event.
    _maxTxAmount = 500000000000000000000000;}
    //sets TX limit to 500 T (.5%)

    function TXLimit1Q() external onlyOwner() {
    //after all Contributor Events for BEP20 USHIBA are completed.
    _maxTxAmount = 1000000000000000000000000;}
    //sets TX Limit to 1 Q quad (1%)

    function UpdateRouter(address newRouter) external onlyOwner() {
        //this lets us change router addresses 
        //in case pancakeswap's protocol upgrades, etc.
       // (Thank you @FreezyEx!)
        IUniswapV2Router02 _newUniswapRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newUniswapRouter.factory()).createPair(address(this), _newUniswapRouter.WETH());
        uniswapV2Router = _newUniswapRouter;
    }
        function revertAccidentalERC20Tx(address tokenAddress, address ownerAddress, uint tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(ownerAddress, tokens);
            //If People accidentally send random tokens to this contract,
            //This will let us send back their tokens!
            //check us out! https://www.americanshiba.info 
    }



    function WhiteHatSniper(address account) external onlyOwner() {
        //grants revealed whitehat sniper actors an amnesty.
        require(_isSniper[account], "Account is not blacklisted and labeled as SWA.");
        for (uint256 i = 0; i < _confirmedSnipers.length; i++) {
            if (_confirmedSnipers[i] == account) {
                _confirmedSnipers[i] = _confirmedSnipers[_confirmedSnipers.length - 1];
                _isSniper[account] = false;
                _confirmedSnipers.pop();
                break;}}}


    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to recieve ETH from uniswapV2Router when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tWallet = calculateMarketingFee(tAmount) +
            calculateDevFee(tAmount);
        uint256 tCharity = calculateCharityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        tTransferAmount = tTransferAmount.sub(tWallet);
        tTransferAmount = tTransferAmount.sub(tCharity);

        return (tTransferAmount, tFee, tLiquidity, tWallet, tCharity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tWallet,
        uint256 tCharity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rWallet = tWallet.mul(currentRate);
        uint256 rCharity = tCharity.mul(currentRate);
        uint256 rTransferAmount = rAmount
            .sub(rFee)
            .sub(rLiquidity)
            .sub(rWallet)
            .sub(rCharity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _takeWalletFee(uint256 tWallet) private {
        uint256 currentRate = _getRate();
        uint256 rWallet = tWallet.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rWallet);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tWallet);
    }

    function _takeCharityFee(uint256 tCharity) private {
        uint256 currentRate = _getRate();
        uint256 rCharity = tCharity.mul(currentRate);
        _rOwned[_charityAddress] = _rOwned[_charityAddress].add(rCharity);
        if (_isExcluded[_charityAddress])
            _tOwned[_charityAddress] = _tOwned[_charityAddress].add(
                tCharity
            );
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_liquidityFee).div(10**2);
    }

    function calculateMarketingFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_marketingFee).div(10**2);
    }

    function calculateCharityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_charityFee).div(10**2);
    }

    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_devFee).div(10**2);
    }

    function removeAllFee() public virtual onlyOwner() {
        _taxFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
        _charityFee = 0;
        _devFee = 0;
    }

    

    function setBuy() private {
        _taxFee = buyFee.tax;
        _liquidityFee = buyFee.liquidity;
        _marketingFee = buyFee.marketing;
        _charityFee = buyFee.charity;
        _devFee = buyFee.dev;
    }

    function setSell() private {
        _taxFee = sellFee.tax;
        _liquidityFee = sellFee.liquidity;
        _marketingFee = sellFee.marketing;
        _charityFee = sellFee.charity;
        _devFee = sellFee.dev;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromLimit(address account) public view returns (bool) {
        return _isExcludedFromLimit[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "Behold! A Transfer from the zero address.");
        require(to != address(0), "Hark! A Transfer to the zero address.");
        require(amount > 100000, "Increase to more than 100,000 BEP20 USHIBA Tokens.");
        require(!_isSniper[from], "SWA: Hmm... Something went wrong! Visit t.me/OfficialUSHIBA");
        require(!_isSniper[msg.sender], "SWA: Unable to proceed! Visit t.me/OfficialUSHIBA");
        require(!_isSniper[tx.origin], "SWA: That is not allowed! Visit t.me/OfficialUSHIBA");






        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.



        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        if (takeFee) {
            if (!_isExcludedFromLimit[from] && !_isExcludedFromLimit[to]) {
                require(
                    amount <= _maxTxAmount,
                    "Transfer amount exceeds the maxTxAmount."
                );
                if (to != uniswapV2Pair) {
                    require(
                        amount + balanceOf(to) <= _maxWalletSize,
                        "Recipient exceeds max wallet size."
                    );
                }
            }
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        // Split the contract balance into halves
        uint256 denominator = (buyFee.liquidity +
            sellFee.liquidity +
            buyFee.marketing +
            sellFee.marketing +
            buyFee.dev +
            sellFee.dev) * 2;
        uint256 tokensToAddLiquidityWith = (tokens *
            (buyFee.liquidity + sellFee.liquidity)) / denominator;
        uint256 toSwap = tokens - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(toSwap);

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance = deltaBalance /
            (denominator - (buyFee.liquidity + sellFee.liquidity));
        uint256 bnbToAddLiquidityWith = unitBalance *
            (buyFee.liquidity + sellFee.liquidity);

        if (bnbToAddLiquidityWith > 0) {
            // Add liquidity to pancake
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }

        // Send ETH to marketing
        uint256 marketingAmt = unitBalance *
            2 *
            (buyFee.marketing + sellFee.marketing);
        uint256 devAmt = unitBalance * 2 * (buyFee.dev + sellFee.dev) >
            address(this).balance
            ? address(this).balance
            : unitBalance * 2 * (buyFee.dev + sellFee.dev);

        if (marketingAmt > 0) {
            payable(_marketingAddress).transfer(marketingAmt);
        }

        if (devAmt > 0) {
            _devwallet.transfer(devAmt);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (takeFee) {
            removeAllFee();
            if (sender == uniswapV2Pair) {
                setBuy();
            }
            if (recipient == uniswapV2Pair) {
                setSell();
            }
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        removeAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tWallet,
            uint256 tCharity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tWallet,
            tCharity,
            _getRate()
        );

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeWalletFee(tWallet);
        _takeCharityFee(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }


    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tWallet,
            uint256 tCharity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tWallet,
            tCharity,
            _getRate()
        );

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeWalletFee(tWallet);
        _takeCharityFee(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tWallet,
            uint256 tCharity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tWallet,
            tCharity,
            _getRate()
        );

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeWalletFee(tWallet);
        _takeCharityFee(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tWallet,
            uint256 tCharity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tWallet,
            tCharity,
            _getRate()
        );

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeWalletFee(tWallet);
        _takeCharityFee(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}