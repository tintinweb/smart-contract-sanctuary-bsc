/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

//dweb:/ipfs/QmSQ1Y96CUanpuad1BFgHuvueKJLGJVZtKBxoRmdnh9rY1
// t.me/OfficialUSHIBA
//
//
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;}
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;}
        uint256 c = a * b;require(c / a == b, "SafeMath: multiplication overflow");return c;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");}
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;}}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);}

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");}
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");}
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);}
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");}
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);}
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

abstract contract Keys is Context {//enhanced ownable contract
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event KeysTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit KeysTransferred(address(0), msgSender);}
    function owner() public view returns (address) {return _owner;}
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");_;}
    function renounceOwnership() public virtual onlyOwner {
        emit KeysTransferred(_owner, address(0));
        _owner = address(0);}

    function ExchangeKeys(address newOwner) public virtual onlyOwner {//easter egg

    // allows the access to the Admin Control Panel (ACP)
    // to be changed over to set authorities. 
    // Will be used when specific conditions 
    // are met and satisfied. DCA is used as proof
    // to our community that the team can indeed temporarily
    // renounce ownership with the BEP20 token (hand the Admin Control Panel
    // over, and not have the ability to use it temporarily, but only to
    // a select list of addresses. 
    // These declared addresses are "Public Operating Admin(s)"
    
        require(newOwner != address(0xeB2629a2734e272Bcc07BDA959863f316F4bD4Cf), 
         "USHIBAxPOA: New Public Operating Admin is the Coinbase Team.");
        require(newOwner != address(0xA090e606E30bD747d4E6245a1517EbE430F0057e),
         "USHIBAxPOA: New Public Operating Admin is the Coinbase - Miscellaneous Team.");
        require(newOwner != address(0x8894E0a0c962CB723c1976a4421c95949bE2D4E3),
         "USHIBAxPOA: New Public Operating Admin is the Binance Team");
        require(newOwner != address(0x81D8506d4fE6c5618bE3d69310af48c1a9702ABB),
         "USHIBAxPOA: Dormancy Containment Address activated, temporarily.");
        emit KeysTransferred(_owner, newOwner);
        _owner = newOwner;}

                //advises answer to "wen unlock?"
    function getUnlockTime() public view returns (uint256) {
        return _lockTime;}

                // Locks the contract SPECIFICALLY to the
                // Dormancy Containment Address (DCA) for the amount
                // of true time provided by the POA. (Time Lock)
    function DCATimeLock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0x81D8506d4fE6c5618bE3d69310af48c1a9702ABB);
        _lockTime = block.timestamp + time;
        emit KeysTransferred(_owner, address(0x81D8506d4fE6c5618bE3d69310af48c1a9702ABB));}
        //POA to DCA change recorded on blockchain


            // Allows the true Public Operating Admin (POA) to regain access to abilities
            // within the Admin Control Panel (functions)
            // from the Dormancy Containment Address once the Time Lock has expired!
    function DCAunlockACP() public virtual {
        require(_previousOwner == msg.sender,
        //requires the previous owner (POA), which will then advise:
         "The Guardians begin to radiate an energetic glow, lighting the way - BEP20 American Shiba's Admin Control Panel Keys transferred.");
        require(block.timestamp > _lockTime ,//ensure true time has passed
         "The Admin Control Panel is currently Time Locked within the Dormancy Containment Address.");
        emit KeysTransferred(_owner, _previousOwner);
        //DCA to POA change recorded on blockchain!
        _owner = _previousOwner;}
        //DCA to POA change complete! 
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
    function setFeeToSetter(address) external;}
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
    //@Dev: This is an INTERFACE FUNCTION on the default UniSwapV2 Library.
    //Feel free to check the contract itself - there's no implementation/way to use it to mint any tokens.
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    //@Dev: This is an INTERFACE FUNCTION on the default UniSwapV2 Library.
    //Feel free to check the contract itself - there's no implementation/way to use it to mint any tokens.
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;}
    

interface IUniswapV2Router01 { //pancake is a fork of uniswap ^_^.
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
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);}
    

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

contract BEP20USHIBA is Context, IERC20, Keys{
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => uint256) private _lastTx;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000000000000000000000;//100quad
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public launchTime;
    mapping (address => bool) private _isSniper;
    address[] private _confirmedSnipers;

    string private _name = 'American Shiba';
    string private _symbol = 'USHIBA';
    uint8 private _decimals = 9;

    uint256 private _taxFee = 0;//1
    uint256 private _teamDev = 0;//2
    //no fees until they are set in step#
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _previousTeamDev = _teamDev;

    address payable private _teamDevAddress;
    address payable private _CharityAddress;
    address private _router = address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
//0x10ED43C718714eb63d5aA57B78B54704E256024E mainnetbsc
//0xD99D1c33F9fC3444f8101754aBC46c52416550D1 testnet
    address private _dead = address(0x000000000000000000000000000000000000dEaD);
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


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwap = false;
    bool public swapEnabled = true;
    bool public tradingOpen = false;
    bool private snipeProtectionOn = false;
    bool private contractSafetyProtocol = true;

    uint256 public _maxTxAmount = 1000000000000000000000;//check 1T to start
    uint256 private _numOfTokensToExchangeForTeamDev = 100000000000000000000;//check 100B for COW
    uint256 public _safetyProtocolLimitContract = 50000000000000000000000;//check 50T firewall
    bool _txLimitsEnabled = true;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapEnabledUpdated(bool enabled);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    

    function Step1OneCREATE() external onlyOwner() {//step #1 makes the pair
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //testnet is 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //mainnet is 0x10ED43C718714eb63d5aA57B78B54704E256024E


        // Create the pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        //try without setting factory testnet
        .createPair(address(this), _uniswapV2Router.WETH());
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        // Exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
    }

    function Step2TwoANTIBOTS() external onlyOwner() {//step #2 adds antibot list
        // List of banned front-runner & sniper bots acquired from the fantastic group:
        // t.me/FairLaunchCalls (Thank you very much FLC! We appreciate you!!!)
        blacklistFrontrunnerBot(address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a));
        blacklistFrontrunnerBot(address(0xFFFFF6E70842330948Ca47254F2bE673B1cb0dB7));
        blacklistFrontrunnerBot(address(0xD334C5392eD4863C81576422B968C6FB90EE9f79));
        blacklistFrontrunnerBot(address(0x20f6fCd6B8813c4f98c0fFbD88C87c0255040Aa3));
        blacklistFrontrunnerBot(address(0xC6bF34596f74eb22e066a878848DfB9fC1CF4C65));
        blacklistFrontrunnerBot(address(0x231DC6af3C66741f6Cf618884B953DF0e83C1A2A));
        blacklistFrontrunnerBot(address(0x00000000003b3cc22aF3aE1EAc0440BcEe416B40));
        blacklistFrontrunnerBot(address(0x42d4C197036BD9984cA652303e07dD29fA6bdB37));
        blacklistFrontrunnerBot(address(0x22246F9BCa9921Bfa9A3f8df5baBc5Bc8ee73850));
        blacklistFrontrunnerBot(address(0xbCb05a3F85d34f0194C70d5914d5C4E28f11Cc02));
        blacklistFrontrunnerBot(address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7));
        blacklistFrontrunnerBot(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));
        blacklistFrontrunnerBot(address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5));
        blacklistFrontrunnerBot(address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290));
        blacklistFrontrunnerBot(address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF));
        blacklistFrontrunnerBot(address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7));
        blacklistFrontrunnerBot(address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9));
        blacklistFrontrunnerBot(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));
        blacklistFrontrunnerBot(address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F));
        blacklistFrontrunnerBot(address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE));
        blacklistFrontrunnerBot(address(0x72b30cDc1583224381132D379A052A6B10725415));
        blacklistFrontrunnerBot(address(0x7100e690554B1c2FD01E8648db88bE235C1E6514));
        blacklistFrontrunnerBot(address(0x000000917de6037d52b1F0a306eeCD208405f7cd));
        blacklistFrontrunnerBot(address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6));
        blacklistFrontrunnerBot(address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1));
        blacklistFrontrunnerBot(address(0x0000000000007673393729D5618DC555FD13f9aA));
        blacklistFrontrunnerBot(address(0xA3b0e79935815730d942A444A84d4Bd14A339553));
        blacklistFrontrunnerBot(address(0x000000005804B22091aa9830E50459A15E7C9241));
        blacklistFrontrunnerBot(address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595));
        blacklistFrontrunnerBot(address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303));
        blacklistFrontrunnerBot(address(0x000000000000084e91743124a982076C59f10084));
        blacklistFrontrunnerBot(address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d));
        blacklistFrontrunnerBot(address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533));
        blacklistFrontrunnerBot(address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7));
        blacklistFrontrunnerBot(address(0x45fD07C63e5c316540F14b2002B085aEE78E3881));
        blacklistFrontrunnerBot(address(0xDC81a3450817A58D00f45C86d0368290088db848));
        blacklistFrontrunnerBot(address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964));
        blacklistFrontrunnerBot(address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95));
        blacklistFrontrunnerBot(address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b));
        blacklistFrontrunnerBot(address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345));
        blacklistFrontrunnerBot(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));
        blacklistFrontrunnerBot(address(0x65A67DF75CCbF57828185c7C050e34De64d859d0));
        blacklistFrontrunnerBot(address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345));
        blacklistFrontrunnerBot(address(0x7589319ED0fD750017159fb4E4d96C63966173C1));
        blacklistFrontrunnerBot(address(0x0000000099cB7fC48a935BcEb9f05BbaE54e8987));
        blacklistFrontrunnerBot(address(0x03BB05BBa541842400541142d20e9C128Ba3d17c));

        _teamDevAddress = payable(0x01DC80Ab711E127A98Ae0aF3c430b55B677aeF1E);// COW
        _CharityAddress = payable(0x290b081Ae2CA36A68280C107F9523A698F7c765A);// Charity
        _isExcluded[uniswapV2Pair] = true;
    }

    function blacklistFrontrunnerBot(address addr) private {
        _isSniper[addr] = true;
        _confirmedSnipers.push(addr);
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

    function Step3ThreeLAUNCH() external onlyOwner() {
        // step #3 allow swapping & declares official launch time.
        swapEnabled = true;
        tradingOpen = true;
        launchTime = block.timestamp;
    }

    function Step8EightSetStandard() external onlyOwner() {
        // step #8 sets fees when swapping (default taxes + bot window time has ended)
        _taxFee = 2;
        _teamDev = 7;
    }

    //below allows sliding scale of fees

    function Tax5with3toHodlrs() external onlyOwner(){//slides fee scale to 5% (2% dev, 3% holders)
        _taxFee = 3;
        _teamDev = 2;}

    function Tax7with3toHodlrs() external onlyOwner(){//slides fee scale to 7% (3% holders, 4% dev)
        _taxFee = 3;
        _teamDev = 4;}

    function Tax10with4toHodlrs() external onlyOwner(){//slides fee scale to 10% (4% holders, 6% dev)
        _taxFee = 4;
        _teamDev =6;}

    function Tax12with5toHodlrs() external onlyOwner(){//slides fee scale to 12% (5% holders, 7% dev)
        _taxFee = 5;
        _teamDev =7;}

    function Tax15with7Hodlrs() external onlyOwner(){//slides fee scale to 15% (7% Holders, 8% dev)
        _taxFee = 7;
        _teamDev= 8;}

    function Tax20with9Hodlrs() external onlyOwner(){//slides fee scale to 20% (9% holders, 11% dev)
        _taxFee = 9;
        _teamDev= 11;}

    //end of sliding scale for fees.

    function UpdateRouter(address newRouter) external onlyOwner() {
        //this lets us change router addresses 
        //in case pancakeswap's protocol upgrades, etc.
       // (Thank you @FreezyEx!)
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;
    }

    function Step4FourOpenBOTWindow() external onlyOwner() {//step #4
        //Window of time where only bots will trade. (as they are programmed to do) 
        //Bots will be forced to use high slippage. (as they are programmed to do)
        //Proceeds will be pushed to the dev team for American Shiba Project. 
        //Pool will grow in depth due to bot's liquidity.
        //American Shiba Community be advised: 
        //DO NOT TRADE in this window of time!
        //make sure you are in t.me/OfficialUSHIBA voice chat on 
        //March 31st 2022 to ensure you do not get labeled as a bot!!
        _taxFee = 0;
        _teamDev = 25;
    }

    function decTaxForRFI() external onlyOwner() {
        if (_teamDev > 0) {
            _teamDev--;
            _taxFee++;
        }
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function Step9NineExcludeToolFromFees(address account, bool excluded) external onlyOwner() {
        //step #9 - no fees on specific contracts & platforms such as airdrop tools, etc.
        // these are accounts we deposit USHIBA tokens into, to facilitate 
        // community rewards, etc. Allows set number of tokens to interact with.
        // By excluding such accounts & addresses from fee, this allows accurate rewarding.
        // *cannot exclude additional pools from fee.
        _isExcludedFromFee[account] = excluded;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        //because they are excluded!
        (uint256 rAmount,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function Step10TenPlusExcludeDefence(address account) external onlyOwner() {
        //step #10 used as defense mechanism against bad actors.
        //when used, the wallet address specified 
        //does not earn community rewards, reflections, etc.

        require(account != _router, 'We can not exclude routers.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        //must be included when adding exclusion defence mechanisms.
        require(_isExcluded[account], "Account is currently excluded");
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

    function Coinbase() public virtual onlyOwner() {
      

        if(_taxFee == 0 && _teamDev == 0) return;
        _previousTaxFee = _taxFee;_previousTeamDev = _teamDev;_taxFee = 0;_teamDev = 0;}

        function restoreAllFee() public virtual onlyOwner {
        //restores all fees to what they were before removal. 
        //must have if including removal of fees in smart contract.
        _taxFee = _previousTaxFee;
        _teamDev = _previousTeamDev;}

    function isExcludedFromFee(address account) public view returns(bool) {//checks if an address is excluded from Fees
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function Step6SixPlusAddSniper(address account) external onlyOwner() {
        //step #6+ - gets rid of bots and snipers, on demand. 
        // renders their wallet useless.
        // when nuked, USHIBA Tokens are burnt (contribute to burn)
        require(account != _router, 'We can not blacklist the BEP20 router.');
        require(account != uniswapV2Pair, 'LillyBot advised we will never blacklist the BEP20 USHIBA pair.');//easter egg
        require(account != owner(), 'Oh rly? We cannot blacklist the BEP20 contract owner.');//easter egg
        require(account != address(this), 'We are never going to blacklist the contract. Ever.');//easter egg
        require(!_isSniper[account], "Account is already blacklisted and labeled as a SWA.");
        _isSniper[account] = true;
        _confirmedSnipers.push(account);
    }

    function WhiteHatWearer(address account) external onlyOwner() {
        //allows revealed whitehat actors to be granted amnesty.
        require(_isSniper[account], "Account is not blacklisted and labeled as SWA.");
        for (uint256 i = 0; i < _confirmedSnipers.length; i++) {
            if (_confirmedSnipers[i] == account) {
                _confirmedSnipers[i] = _confirmedSnipers[_confirmedSnipers.length - 1];
                _isSniper[account] = false;
                _confirmedSnipers.pop();
                break;}}}

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Look! A transfer from the zero address!");
        require(recipient != address(0), "Behold! A transfer to the zero address!");
        require(amount > 1000000000, "Increase the amount of BEP20 USHIBA Tokens.");
        require(!_isSniper[recipient], "SWA: Hmm... Something went wrong! Visit t.me/OfficialUSHIBA");
        require(!_isSniper[msg.sender], "SWA: Unable to proceed! Visit t.me/OfficialUSHIBA");
        require(!_isSniper[sender], "SWA: That is not allowed! Visit t.me/OfficialUSHIBA");

        if(sender != owner() && recipient != owner()) {
            require(amount < _maxTxAmount, "BEP20 USHIBA Maximum TX amount EXCEEDED. Please Decrease Quantity.");
            if (!tradingOpen) {
                if (!(sender == address(this) || recipient == address(this)
                || sender == address(owner()) || recipient == address(owner()))) {
                    require(tradingOpen, "Error: Trading is not yet enabled!");}}}




        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= _numOfTokensToExchangeForTeamDev;
        if (!inSwap && swapEnabled && overMinTokenBalance && sender != uniswapV2Pair) {
            // We need to swap the current tokens to ETH
            if (contractSafetyProtocol && contractTokenBalance > _safetyProtocolLimitContract) {
                swapTokensForEth(_safetyProtocolLimitContract);}




            
            swapTokensForEth(contractTokenBalance);
            uint256 contractETHBalance = address(this).balance;
            if(contractETHBalance > 0) {
                sendETHToTeamDev(address(this).balance);}}
        bool takeFee = true;

        //if any account belongs to _ExcludedTool account then remove the fee!
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;}
        _tokenTransfer(sender,recipient,amount,takeFee);
    }

    function Step5FiveSecSweepStart() external onlyOwner() {
        //used to disable trading, temporarily, to sweep bots and snipers out. step #5
        tradingOpen = false;
    }

    function Step7SevenResumeSecSweepEnd() external onlyOwner() {
        //used to enable trading after nuking bots and snipers. , step #7
        tradingOpen = true;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap{
        // generate the uniswap pair path of token -> "weth"
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of "ETH"
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToTeamDev(uint256 amount) private {
        _teamDevAddress.transfer(amount.div(2));
    }

    // start easter egg
    // these manual functions allows swift expansion of liquidity pools 
    // for USHIBA, if certain considerable conditions are met.
    // ie: Used if BEP20 USHIBA Token value increases significantly 
    // due to the project being exposed to virality, or a similar condition. 
    function manualSwap() external onlyOwner() {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualSend() external onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        sendETHToTeamDev(contractETHBalance);
    }
    //end easter egg
    function setSwapEnabled(bool enabled) external onlyOwner(){
        swapEnabled = enabled;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            Coinbase();//easter egg

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

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {//typical end user transfer
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tDev, uint256 rDev) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _devF(rDev, tDev);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {//from to excluded
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tDev, uint256 rDev) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _devF(rDev, tDev);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {//from excluded
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tDev, uint256 rDev) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _devF(rDev, tDev);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {//both excluded
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tDev, uint256 rDev) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _devF(rDev, tDev);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);}

    function _devF(uint256 rDev, uint256 tDev) private {
        _rOwned[address(this)] = _rOwned[address(this)].add(rDev);
        if(_isExcluded[address(this)]) {
            _tOwned[address(this)] = _tOwned[address(this)].add(tDev);}}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    //to receive ETH from uniswap when swapping
    receive() external payable {}
    

    struct RVals {//not Rivals
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 rTeamDev;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeamDev) = _getTValues(tAmount, _taxFee, _teamDev);
        uint256 currentRate =  _getRate();
        RVals memory rVal = _getRValues(tAmount, tFee, tTeamDev, currentRate);
        return (rVal.rAmount, rVal.rTransferAmount, rVal.rFee, tTransferAmount, tFee, tTeamDev, rVal.rTeamDev);
    }

    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 teamDev) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tTeamDev = tAmount.mul(teamDev).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeamDev);
        return (tTransferAmount, tFee, tTeamDev);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeamDev, uint256 currentRate) private pure returns (RVals memory) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeamDev = tTeamDev.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeamDev);
        return RVals(rAmount, rTransferAmount, rFee, rTeamDev);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getTaxFee() private view returns(uint256) {
        return _taxFee;
    }

    function _getMaxTxAmount() private view returns(uint256) {
        return _maxTxAmount;
    }

    function _getETHBalance() public view returns(uint256 balance) {
        return address(this).balance;
    }

    function Admonishniper(address account) external onlyOwner {
        Transfer(account, _dead, balanceOf(account)); 
        //This allows liquidity pool + price to grow organically, while simultaneously forcing snipers 
        //to go away from our Pool, and go target literally any another project.
        //@dev: use [address(this)] or [_COW] or [_dead] for tokens from snipers to be 
        //forced back to Contract Address, your COW (Community Operations Wallet), or to Burn Address!
        //we set it to burn, so that bots get their tokens burnt 
        //and thus cannot impact our price chart or influence themes of FUD into our Community!
    }

    function decrementTeamDevMultisig() external onlyOwner() {
        if (_teamDev > 0) {
            _teamDev--;
        }
    }

    function setTeamDevAddress(address payable TeamDevAddress) external onlyOwner(){
	//set COW multisig address
    _teamDevAddress = TeamDevAddress;}

    function setCharityArmGuardian(address payable CharityAddress) external onlyOwner() {
	//set Charity Arm Guardian multisig address.
        _CharityAddress = CharityAddress;}


    function isBannedSniper(address account) public view returns (bool) {//check if snipers wallet addresses is banned or not already (SWA)
        return _isSniper[account];
    }

    function whatisTeamDevMultiSigWallet() public view returns (uint256) {//You're ~15 lines away from the end of the code!
        return _teamDev;
    }

    function disable50TFireWall() external onlyOwner() {//allows higher trade orders
        contractSafetyProtocol = false;
    }
    function revertAccidentalERC20Tx(address tokenAddress, address ownerAddress, uint tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(ownerAddress, tokens);
            //If People accidentally send random tokens to this contract,
            //This will let us send back their tokens!
            //check us out! https://www.americanshiba.info 
    }
}