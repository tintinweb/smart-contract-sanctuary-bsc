/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

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
                revert(errorMessage);
            }
        }
    }
}
contract Rmath {

    function btoi(uint256 a)
        internal pure
        returns (uint256)
    {
        return a / 1e18;
    }

    function bfloor(uint256 a)
        internal pure
        returns (uint256)
    {
        return btoi(a) * 1e18;
    }

    function badd(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        (uint256 c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint256 a, uint256 b)
        internal pure
        returns (uint, bool)
    {
        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }


    function bmul(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        uint256 c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint256 c1 = c0 + (1e18 / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint256 c2 = c1 / 1e18;
        return c2;
    }

    function bdiv(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * 1e18;
        require(a == 0 || c0 / a == 1e18, "ERR_DIV_INTERNAL"); 
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL");
        uint256 c2 = c1 / b;
        return c2;
    }

    function bpowi(uint256 a, uint256 n)
        internal pure
        returns (uint256)
    {
        uint256 z = n % 2 != 0 ? a : 1e18;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

    function bpow(uint256 base, uint256 exp)
        internal pure
        returns (uint256)
    {
        require(base >= 1 wei, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= (2 * 1e18) - 1 wei, "ERR_BPOW_BASE_TOO_HIGH");

        uint256 whole  = bfloor(exp);
        uint256 remain = bsub(exp, whole);

        uint256 wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint256 partialResult = bpowApprox(base, remain, 1e18 / 1e10);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(uint256 base, uint256 exp, uint256 precision)
        internal pure
        returns (uint256)
    {
        uint256 a     = exp;
        (uint256 x, bool xneg)  = bsubSign(base, 1e18);
        uint256 term = 1e18;
        uint256 sum   = term;
        bool negative = false;


        for (uint256 i = 1; term >= precision; i++) {
            uint256 bigK = i * 1e18;
            (uint256 c, bool cneg) = bsubSign(a, bsub(bigK, 1e18));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }
}

library TransferHelper {
    
    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface BIGDAO {
function userRegisteredVoteAmount(address user) external view returns(uint256);
function developmentFund() external view returns(uint256);
function marketingFund()  external view returns(uint256);
function CEXFund() external view returns(uint256);
function modFund() external view returns(uint256);
function rewardFund() external view returns(uint256);
function isMod(address addy) external view returns(bool);
function modID() external view returns(uint256);
function isVoter(address addy) external view returns(bool);
function updateFunds() external;
function userLastVoted(address addy) external returns(uint256);
function userTotalVotes(address addy) external returns(uint256);
}

interface FEGex {
function depositInternal(address asset, uint256 amt) external;
function withdrawInternal(address asset, uint256 amt) external;
function swapToSwap(address path, address asset, address to, uint256 amt) external;
function payMain(address payee, uint256 amount) external;
function payToken(address payee, uint256 amount) external;
function BUY(uint256 dot, address to, uint256 minAmountOut) external payable returns(uint256 tokenAmountOut);
function BUYSmart(uint256 tokenAmountIn, uint256 minAmountOut) external returns(uint256 tokenAmountOut);
function SELL(uint256 dot, address to, uint256 tokenAmountIn, uint256 minAmountOut) external returns (uint256 tokenAmountOut);
function SELLSmart(uint256 tokenAmountIn, uint256 minAmountOut) external returns(uint256 tokenAmountOut);
function addBothLiquidity(uint256 poolAmountOut, uint[] calldata maxAmountsIn) external;   
function getBalance(address token) external view returns(uint256);
}

interface AutoDeployer {
function createPair(address token, uint256 liqmain, uint256 liqtoken, address owner) external returns (address pair);
}

contract Lima is Context, IERC20, Rmath {
    using SafeMath for uint256;
    using Address for address;

    struct privateSale {
        address user;
        uint256 amountPurchased;
        bool live;
    }

    struct POD {
        address inAsset;
        uint256 inAmount;
        address outAsset;
        uint256 outAmount;
        uint256 price;
        bool open;
    }

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public isExchange;
    mapping (address => privateSale) public ps;
    mapping (address => mapping (uint256 => uint256)) public psmd;
    mapping (address => mapping (uint256 => uint256)) public FEGexUpdateChecks;
    mapping (address => mapping (uint256 => bool)) public FEGexUpdateModLive;
    mapping (address => uint256) public Karma;
    mapping (address => uint256) public userLastGaveKarma;
    mapping (address => mapping (address => uint256)) public gaveKarma;
    mapping(address => uint256) public userTotalBIGBuy;
    mapping(address => uint256) public userTotalSpent;
    mapping(address => uint256) public userAvgBuy;
    mapping(address => uint256) public lastBuyBack;
    mapping(address => bool) public noLosses;
    mapping(address => mapping (uint256 => POD)) public pod;
    address[] private _excluded;
    address public FEGexPair;
    uint256 private FEGpairupdates = 0;
    address public UNIstable = 0xd99c7F6C65857AC913a8f880A4cb84032AB2FC5b;
    address public dao;
    address public presale;
    address public treasurer;
    address public USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address public fETH = 0x87b1AccE6a1958E522233A737313C086551a5c76;
    address public wETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public burnAddy = 0x000000000000000000000000000000000000dEaD;
    address public ROX;
    bool public psOpen = false;
    uint256 public timeLog;
    uint256 public lastMcap;
    uint256 public day = 0;
    uint256 private setup = 0;
    uint256 public buyBackFund;
    uint256 public buyBackReady;
    uint256 public FEGexModCheck;
    uint256 public birth;
    uint256 public reflection = 20;
    uint256 public burn = 10;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private used = 0;
    string private _name = "Test";
    string private _symbol = "27";
    uint8 private _decimals = 18;

    constructor () {
        _rOwned[msg.sender] = _rTotal;
        Karma[msg.sender] = 1100;
        birth = block.timestamp;
        timeLog = block.timestamp + 1800;                                 //fix
        ROX = msg.sender;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    receive() external payable {
    }

    function giveKarma(address addy, uint256 choice) external {  // 1 good, 2 bad
        require(block.timestamp > gaveKarma[msg.sender][addy] + 1 days, "Gave this karma yesterday");  //fix 7 days
        require(block.timestamp >= userLastGaveKarma[msg.sender] + 30 minutes, "You can only give Karma once per 30 minutes"); // fix 1 hour
        require(BIGDAO(dao).isVoter(msg.sender) == true, "Not voter");
        require(addy != msg.sender, "Self Karma you cannot give");
        require(isExchange[addy] == false, "Cannot give karma to exchange");
        if(choice == 1) {
            Karma[addy] += 1;
        }
        if(choice == 2 && Karma[addy] > 0){
            Karma[addy] -= 1;
        }
        gaveKarma[msg.sender][addy] = block.timestamp;
        userLastGaveKarma[msg.sender] = block.timestamp;
    }
    
    function generatePOD(address in1, uint256 amt1, address out2, uint256 amt2, uint256 ID) external {
        require(pod[msg.sender][ID].open == false, "Existing");
        require(Karma[msg.sender] >= 1, "Only super user");
        require(BIGDAO(dao).isVoter(msg.sender) == true, "Not registered voter");
        require(IERC20(in1).balanceOf(msg.sender) > amt1);
        pod[msg.sender][ID].open = true;
        pod[msg.sender][ID].inAsset = in1;
        pod[msg.sender][ID].inAmount = amt1;
        pod[msg.sender][ID].outAsset = out2;        
        pod[msg.sender][ID].outAmount = amt2;
        pod[msg.sender][ID].price = bdiv(amt2, amt1);  
        _unionFull(address(this), msg.sender, ROX, bdiv(getRewardAmount(), 100));
    }

    function cancelPOD(uint256 ID) external {
        require(pod[msg.sender][ID].open == true, "None");
        pod[msg.sender][ID].open = false;
        pod[msg.sender][ID].inAsset = address(0);
        pod[msg.sender][ID].inAmount = 0;   
        pod[msg.sender][ID].outAsset = address(0);        
        pod[msg.sender][ID].outAmount = 0;
        pod[msg.sender][ID].price = 0; 
    }

    function buyPOD(address asset, address addy, uint256 ID, uint256 amt) external returns(uint256 tokenAmountOut){
        require(pod[addy][ID].open == true, "Not open");
        require(BIGDAO(dao).isVoter(msg.sender) == true, "Not registered voter");
        require(pod[addy][ID].outAsset == asset, "Must be exact asset");
        require(pod[addy][ID].outAmount == amt, "Exact change");
        require(Karma[msg.sender] >= 1, "No Karma");
        uint256 tot = pod[addy][ID].outAmount;
        _unionFull(pod[addy][ID].outAsset , msg.sender, addy, amt); // sends directly from seller to buyer and from buyer to seller. Any token for any token, custodyless escrow limit orders!! both sends required
        _unionFull(pod[addy][ID].inAsset, addy, msg.sender,  tot);
        pod[addy][ID].open = false;
        pod[addy][ID].inAsset = address(0);
        pod[addy][ID].inAmount = 0;
        pod[addy][ID].outAsset = address(0);
        pod[addy][ID].outAmount = 0;
        pod[addy][ID].price = 0;
        tokenAmountOut = tot;
        return tokenAmountOut;
    }

    function donateKarma(address addy, uint256 amt) external {
        uint256 kAmt = Karma[msg.sender];
        require(kAmt >= amt, "Not enough karma");
        require(block.timestamp > gaveKarma[msg.sender][addy] + 1 days, "Gave this karma yesterday");  //fix 7 days
        require(block.timestamp >= userLastGaveKarma[msg.sender] + 10 minutes, "You can only donate Karma once per week"); // fix 
        Karma[msg.sender] -= amt;
        Karma[addy] += amt;
        gaveKarma[msg.sender][addy] = block.timestamp;
        userLastGaveKarma[msg.sender] = block.timestamp;
    }

    function boostKarma(address addy) external {
        require(msg.sender == dao || BIGDAO(dao).isMod(msg.sender) == true);
        if(BIGDAO(dao).isMod(msg.sender) == true){
        require(Karma[msg.sender] > 100, "Must have over 100 karma");
        }
        require(addy != msg.sender, "Cannot boost self");
        Karma[addy] += 1;
    }

    function setTreasury(address addy) external {
        require(treasurer == address(0));
        treasurer = addy;
    }

    function getDevelopmentFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).developmentFund();
        return amount;
    }

    function getMarketingFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).marketingFund();
        return amount;
    }
    
    function getMODFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).modFund();
        return amount;
    }
    function getCEXFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).CEXFund();
        return amount;
    }
    function getRewardFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).rewardFund();
        return amount;
    }

    function addPresale(address addy) external {
        require(BIGDAO(dao).isMod(msg.sender) == true, "Not approved");
        require(presale == address(0), "Can only add once");
        presale = addy;
    }
    
    function addPSData(address addy, uint256 amt, bool _bool) external {
        require(msg.sender == presale);
        if(ps[addy].user == address(0)){
        ps[addy].user = addy;
        }
        ps[addy].amountPurchased += amt;
        ps[addy].live = _bool;
    }

    function TESTaddPSData(uint256 amt, bool _bool) external {
        //require(BIGDAO(dao).isMod(msg.sender) == true);
        if(ps[msg.sender].user == address(0)){
        ps[msg.sender].user = msg.sender;
        }
        ps[msg.sender].amountPurchased += amt;
        ps[msg.sender].live = _bool;
    }

    function getSpotPerETH() public view returns(uint256) {
        uint256 spotBig = getSpotBIG();
        uint256 oneETH = 1e18;
        uint256 perETH = bdiv(oneETH, spotBig);
        return perETH;
    }

    function getBIGperUSD() public view returns(uint256) {
        uint256 mcap = getMarketCap();
        uint256 usd = bdiv(totalSupply(), mcap);
        return usd;
    }

    function getRewardAmount() public view returns(uint256) {
        uint256 amount = getBIGperUSD();
        return (amount * 100);
    }

    function getModPay() public view returns(uint256) {
        uint256 amount = getBIGperUSD();
        uint256 mcap = getMarketCap();
        uint256 mult;
        if(mcap < 500000000e18){
            mult = 500;
        }
        if(mcap >= 5000000e18 && mcap < 7500000e18){
            mult = 600;
        }
        if(mcap >= 7500000e18 && mcap < 10000000e18){
            mult = 700;
        }
        if(mcap >= 10000000e18 && mcap < 20000000e18){
            mult = 800;
        }
        if(mcap >= 20000000e18 && mcap < 50000000e18){
            mult = 900;
        }
        if(mcap >= 50000000e18){
            mult = 1000;
        }
        return (amount * mult);
    }

    function getSpotBIG() public view returns(uint256) {
        uint256 totalETH = FEGex(FEGexPair).getBalance(fETH);
        uint256 totalToken = FEGex(FEGexPair).getBalance(address(this));
        uint256 spot = bdiv(totalETH, totalToken);
        return spot;
    }

    function getETHUSD() public view returns(uint256) {
        uint256 totalETH = IERC20(wETH).balanceOf(UNIstable);
        uint256 totalUSD = IERC20(USDC).balanceOf(UNIstable);
        uint256 spot = bdiv(totalUSD, totalETH);
        return spot;
    }

    function getMarketCap() public view returns(uint256) {
        uint256 totalTokens = _tTotal;
        uint256 ETHUSD = getETHUSD();
        uint256 totalPerEth = getSpotPerETH();
        uint256 totalEth = bdiv(totalTokens, totalPerEth);
        uint256 mcap = bmul(totalEth, ETHUSD);
        return mcap;
    }

    function getMaxPSPerSell() public view returns(uint256) {
        uint256 max;
        if(getMarketCap() < 15000000e18){
        max = getSpotPerETH().mul(1); 
        }
        if(getMarketCap() >= 15000000e18 &&  getMarketCap() < 25000000e18){  //fix
        max = getSpotPerETH().mul(2);
        }
        if(getMarketCap() >= 25000000e18 && getMarketCap() < 50000000e18){
        max = getSpotPerETH().mul(10);
        }
        if(getMarketCap() >= 50000000e18){
        max = getSpotPerETH().mul(20);
        }
        return max;
    }

    function getMaxPSPerDay() public view returns(uint256) {
        uint256 max;
        if(getMarketCap() < 15000000e18){
        max = getSpotPerETH().mul(2); 
        }
        if(getMarketCap() >= 15000000e18 &&  getMarketCap() < 25000000e18){  // fix
        max = getSpotPerETH().mul(4);
        }
        if(getMarketCap() >= 25000000e18 && getMarketCap() < 50000000e18){
        max = getSpotPerETH().mul(20);
        }
        if(getMarketCap() >= 50000000e18){
        max = getSpotPerETH().mul(40);
        }
        return max;
    }

    function addisExchangeModApproval(address addy) external {
        require(BIGDAO(dao).isMod(msg.sender) == true, "Not approved");
        uint256 times = FEGpairupdates + 1;
        require(FEGexUpdateModLive[addy][times] == false);
        FEGexUpdateModLive[addy][times] = true;
        FEGexModCheck += 1;
    }

    function toggleFEGexPair(address addy) external {
        require(FEGexModCheck >= 5, "Must be 5 approvals");
        require(BIGDAO(dao).isMod(msg.sender) == true, "Not approved");
        FEGexModCheck = 0;
        FEGexPair = addy;
        isExchange[addy] = true;
        FEGpairupdates += 1;
    }

    function addInitialDEX(address addy) external {
        require(BIGDAO(dao).isMod(msg.sender) == true, "Not approved");
        require(setup == 0);
        setup = 1;
        FEGexPair = addy;
        isExchange[addy] = true;
        lastMcap = getMarketCap();
    }

    function setIsExchange(address addy, bool choice) external {
        require(BIGDAO(dao).isMod(msg.sender) == true, "Not approved");
        isExchange[addy] = choice;
    }

    function openPrivateSelling() external {
        require(getMarketCap() >= 15000000e18, "Under 150m Market Cap");
        psOpen = true;
    }

    function addDAO(address addy) external {
        require(dao == address(0));
        dao = addy;
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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromSHIBflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {   
        uint256 max; 
        if(block.timestamp > timeLog){
            day += 1;
            timeLog += 1800;                   //fix
            lastMcap = getMarketCap();
        }
        if(ps[msg.sender].live == true){            
        require(isExchange[recipient] == true, "Private Sell member can only sell");
        require(psOpen == true, "Private selling not open yet");
        require(getMarketCap() >= 5000000e18, "mcap under 5m");  //fix 15m
        max = getMaxPSPerSell();
        require(amount <= max, "Cannot sell over max per");        
        psmd[msg.sender][day] += amount;
        require(psmd[msg.sender][day] <= getMaxPSPerDay(), "Over max per day");
        if(getMarketCap() <= 15000000e18) {
            amount = bmul(amount, bdiv(60, 100));
            _transfer(msg.sender, dao, bmul(amount, bdiv(20, 100)));
            _transfer(msg.sender, address(this), bmul(amount, bdiv(20, 100)));
            buyBackFund += bmul(amount, bdiv(20, 100));
            BIGDAO(dao).updateFunds();
        }
        }

        uint256 tolerance = BIGDAO(dao).userRegisteredVoteAmount(msg.sender);
        uint256 balance = balanceOf(msg.sender);
        require(bsub(balance, amount) >= tolerance, "Cannot transfer registered voting amount or POD tokens");
        _transfer(_msgSender(), recipient, amount);

        if(noLosses[recipient] == true){
        if(isExchange[_msgSender()] == true && userTotalBIGBuy[recipient] > 0){
            uint256 spot = getSpotPerETH();
            uint256 spent = bdiv(amount, spot);
            userTotalSpent[recipient] += bmul(spent, bdiv(1047, 1000));
            userTotalBIGBuy[recipient] += bmul(amount, bdiv(97, 100));  
            uint256 avg = bdiv(userTotalBIGBuy[recipient], userTotalSpent[recipient]);
            userAvgBuy[recipient] = avg;
        }
        if(isExchange[_msgSender()] == true && userTotalBIGBuy[recipient] == 0){
            uint256 spot = getSpotPerETH();
            uint256 spent = bdiv(amount, spot);
            userTotalSpent[recipient] = bmul(spent, bdiv(1047, 1000));
            userTotalBIGBuy[recipient] = bmul(amount, bdiv(97, 100)); 
            uint256 avg = bdiv(userTotalBIGBuy[recipient], userTotalSpent[recipient]);
            userAvgBuy[recipient] = avg;
        }
        }
        return true;
    }

    function activateNoLosses() external {
        require(Karma[msg.sender] >= 1, "Need 5 or more Karma");
        require(noLosses[msg.sender] == false, "Already member");
        require(BIGDAO(dao).isVoter(msg.sender) == true, "Not registered voter");
        noLosses[msg.sender] = true;
    } 
    
    function deactivateNoLosses(uint256 choice) external {  // 1 to reset data
        require(Karma[msg.sender] >= 5, "Need 5 or more Karma");
        require(noLosses[msg.sender] == true, "Not member");
        require(BIGDAO(dao).isVoter(msg.sender) == true, "Not registered voter");
        if(choice == 1){
            userAvgBuy[msg.sender] = 0;
            userTotalBIGBuy[msg.sender] = 0;
            userTotalSpent[msg.sender] = 0;
        }
        noLosses[msg.sender] = false;
    } 

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        if(lastMcap > 0) {
        if(bmul(getMarketCap(), bdiv(105, 100)) >=  lastMcap && buyBackFund >= bmul(getSpotPerETH(), bdiv(1, 1000000))){
            _approve(address(this), FEGexPair, bmul(getSpotPerETH(), bdiv(1, 1000000)));
            FEGex(FEGexPair).SELL(1001, address(this), bmul(getSpotPerETH(), bdiv(1, 1000000)), 1);
            buyBackFund -= bmul(getSpotPerETH(), bdiv(1, 1000000));
            buyBackReady = address(this).balance;
        }
        }
        
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {        
        uint256 max; 
        if(block.timestamp > timeLog){
            day += 1;
            timeLog += 1800;                   //fix
            lastMcap = getMarketCap();
        }       
        uint256 tolerance = BIGDAO(dao).userRegisteredVoteAmount(sender);
        uint256 balance = balanceOf(sender);
        require(bsub(balance, amount) >= tolerance, "Cannot transfer registered voting amount or POD tokens");
        
        if(ps[sender].live == true){
        require(psOpen == true, "Private selling not open yet");
        require(getMarketCap() >= 5000000e18, "mcap under 5m");  //fix 15m
        require(isExchange[recipient] == true, "Private Sell member can only sell");
        max = getMaxPSPerSell();
        require(getMarketCap() <= bmul(lastMcap, bdiv(102, 100)), "Must be 2% more then last registered marketcap");
        require(amount <= max, "Cannot sell over max per");        
        psmd[msg.sender][day] += amount;
        require(psmd[msg.sender][day] <= getMaxPSPerDay(), "Over max per day");
        if(getMarketCap() <= 15000000e18) {
            uint256 amt = amount;
            amount = bmul(amount, bdiv(60, 100));           
            _transfer(msg.sender, dao, bmul(amt, bdiv(20, 100)));
            _transfer(msg.sender, address(this), bmul(amt, bdiv(20, 100)));
            buyBackFund += bmul(amt, bdiv(20, 100));
            BIGDAO(dao).updateFunds();
        }
        }
        if(noLosses[sender] == true && isExchange[recipient] == true){
            require(bmul(userAvgBuy[sender], bdiv(950, 1000)) >= getSpotPerETH(), "Nolosses - Enabled, sell price under avg buy price");
            uint256 spot = getSpotPerETH();
            uint256 gotten = bdiv(amount, spot);
            if(gotten >= userTotalSpent[sender]){
            userTotalSpent[sender] = 0;
            userTotalBIGBuy[sender] = 0;
            userAvgBuy[sender] = 0;
            noLosses[sender] = false;
            }
            else{
            userTotalSpent[sender] -= bmul(gotten, bdiv(1047, 1000));
            userTotalBIGBuy[sender] -= bmul(amount, bdiv(97, 100));
            uint256 avg = bdiv(userTotalBIGBuy[sender], userTotalSpent[sender]);
            require(bmul(userAvgBuy[sender], bdiv(940, 1000)) >= getSpotPerETH(), "Nolosses - After sell remainder was under average buy price");
            userAvgBuy[sender] = avg;
            }
        }

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function setBurn(uint256 amt) external {
        require(msg.sender == dao, "Only DAO can set");
        burn = amt;
    }

    function setReflection(uint256 amt) external {
        require(msg.sender == dao, "Only DAO can set");
        reflection = amt;
    }

    function SHIBflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount, sender, sender);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function SHIBflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        
        address sender = _msgSender();
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount, sender, sender);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount, sender, sender);
            return rTransferAmount;
        }
    }

    function tokenFromSHIBflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total SHIBflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccount(address account) external {
        require(!_isExcluded[account], "Account is already excluded");
        require(BIGDAO(dao).isMod(msg.sender) == true, "Not approved");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromSHIBflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external {
        require(_isExcluded[account], "Account is already excluded");
        require(BIGDAO(dao).isMod(msg.sender) == true, "Not approved");
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

    function buyBack() external {
        require(buyBackReady >= 1e13, "Must be over 1 ETH");  //fix
        require(getMarketCap() <= bmul(lastMcap, bdiv(98, 100)), "Must be 2% less then last registered marketcap");
        require(Karma[msg.sender] >= 5, "Must have 5 Karma");
        require(noLosses[msg.sender] == true, "Must have noLosses enabled");
        require(block.timestamp >= lastBuyBack[msg.sender] + 24 hours, "Once per day");
        require(BIGDAO(dao).isVoter(msg.sender) == true, "Not registered voter");
        require(block.timestamp + 1 days >= BIGDAO(dao).userLastVoted(msg.sender), "Have not voted in last 1 day");
        require(BIGDAO(dao).userTotalVotes(msg.sender) >= 1, "Be more active, need more registered votes");
        uint256 amt = bmul(buyBackReady, bdiv(90, 100));
        TransferHelper.safeTransferETH(ROX, bmul(buyBackReady, bdiv(10, 100)));
        buyBackReady = 0;
        uint256 tot = FEGex(FEGexPair).BUY{value: amt}(1001, address(this), 1);
        _pushUnderlying(address(this), burnAddy, bmul(tot, bdiv(90, 100)));
        _pushUnderlying(address(this), msg.sender, bmul(tot, bdiv(10, 100)));
        lastBuyBack[msg.sender] = 0;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 burnAmt = bmul(amount, bdiv(burn, 1000));
        uint256 txAmt = bsub(amount, burnAmt);
        if(recipient == dao || sender == dao || recipient == treasurer || sender == treasurer || recipient == address(this)) {
            burnAmt = 0;
            txAmt = amount;
        }
        if(lastMcap > 0){
        if(lastMcap >= bmul(getMarketCap(), bdiv(98, 100)) && burnAmt > 0){
            burnAddy = dao;
            buyBackFund += burnAmt;
        }        
        }
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, txAmt);
            if(burnAmt > 0) { 
            _transferFromExcluded(sender, burnAddy, burnAmt);    
            }
            
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, txAmt);
            if(burnAmt > 0) {
            _transferToExcluded(sender, burnAddy, burnAmt);  
            }
            
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, txAmt);
            if(burnAmt > 0) {
            _transferStandard(sender, burnAddy, burnAmt);    
            }
            
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, txAmt);
            if(burnAmt > 0) {
            _transferBothExcluded(sender, burnAddy, burnAmt);    
            }
            
        } else {
            _transferStandard(sender, recipient, txAmt);
            if(burnAmt > 0) {
            _transferStandard(sender, burnAddy, burnAmt);
            }  
        }    
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, sender, recipient);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);       
        _SHIBflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, sender, recipient);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _SHIBflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, sender, recipient);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _SHIBflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, sender, recipient);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _SHIBflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _SHIBflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount, address sender, address recipient) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount, sender, recipient);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount, address sender, address recipient) private view returns (uint256, uint256) {
        uint256 tFee; 
        uint256 tTransferAmount;
        uint256 karma = Karma[recipient];
        if(recipient == dao || sender == dao || recipient == treasurer || sender == treasurer || recipient == address(this)) {
        tFee = tAmount.div(100).mul(0);
        tTransferAmount = tAmount.sub(tFee);
        }
        else {
        if(karma >= 10) {
            karma = 10;
        }    
        uint256 tax = 10 - karma;
        tFee = tAmount.div(1000).mul(reflection + tax);
        tTransferAmount = tAmount.sub(tFee);
        }
        
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
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

    function _pullUnderlying(address erc20, address from, uint256 amount)
        internal 
    {    
        bool xfer = IERC20(erc20).transferFrom(from, address(this), amount);
        require(xfer);
    }
    
    function _union(address from, address to, uint256 amount)
        internal 
    {    
        bool xfer = IERC20(fETH).transferFrom(from, to, amount);
        require(xfer, "fETH cannot transfer, check balance");
    }

    function _unionFull(address addy, address from, address to, uint256 amount)
        internal 
    {    
        bool xfer = IERC20(addy).transferFrom(from, to, amount);
        require(xfer, "Ask cannot cover bid");
    }

    function _pushUnderlying(address erc20, address to, uint256 amount)
        internal 
    {   
        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer);
    }
}