/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * IPinkAntiBot for protection of multiple sales with bots every seconds
 */
interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

 contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;
     _status = _NOT_ENTERED;
    }
}

// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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

contract IDO is Context, Ownable{
    using SafeMath for uint256;

    // address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    // address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    // address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;  
    string private _name = "Lincolnsale Launchpad";
    string private _symbol = "LSP";
    uint8 private _decimals = 18;

    event Log(string message, uint val);
    
    uint256 launchCharges = 1000000000000000000;
    uint256 partnerCharges = 200000000000000000;
    uint256 referPercent = 10;

    uint[] public lockedbuys;
    

    event buysReport(address investorAddress, uint256 bnbAmount,uint256 tokenToCollect, address refererAddress, bool releaseStatus, uint256 buysDate);
   // event inventReleased(address from, address to, uint256 totalEarned, uint256 ctime); 

    function referPercentage() public view returns (uint256) {
        return referPercent;
    }
    function presaleCharges() public view returns (uint256) {
        return launchCharges;
    }

    uint256 _buysCount; //counting the number of time buys occur

    struct partnerType{
        uint id;
        string name;
        string description;
    }

    struct partnerInfo{
        uint id;
        string partnerName;
        string phone;
        string telegram;
        string website;
        bool status;
    }

    struct Invest{
    uint256 id;
    address staker;
    uint256 bnbPaid;
    uint256 tokenToCollect;
    address refererAddress;
    bool releaseStatus;
    uint256 date;
    }
    
    struct projectDetails{
    uint256 id;
    string logo;
    string url;
    string facebook;
    string telegram;
    string twitter;
    string github;
    string discord;
    string desc;
    }

    struct liquidityInfo{
    uint256 id;
    uint fundRaiseType;
    string swapRouter;
    address swapRouterAddress;
    uint listingRate;
    uint percentageToLp;
    bool whiteListOnly;
    bool audit;
    bool kyc;
    bool avc;//Antimatter Verification Certificate;
    uint lpUnlockTime;
    }

    struct tokenInfo{
    uint256 id;
    IERC20 tokenAddress;
    string projectUrl;
    uint256 softCap;
    uint256 hardCap;
    uint256 tokenPricePerBnb;
    uint256 minBuy;
    uint256 maxBuy;
    address adminAddress;
    uint256 startTime;
    uint256 endTime;
    bool status;
    }
    
    uint256 public partnerCount = 0;
    uint256 public projectCount = 0;
    uint256 public partnerInfoCount = 0;
    tokenInfo[] public tokenInfos;
    mapping (uint=>bool) public tokenReferral;
    mapping (address=>uint) public referer;
    mapping (address=>uint) public refererBalance;
    mapping (uint => Invest) public isInvested;
    mapping (uint => uint) public buyBalance;

    partnerType[] public partnerTypes;
    partnerInfo[] public partnerInfos;
    Invest[] public allBuys;
    projectDetails[] public details;
    liquidityInfo[] public lps;
    event LogTokenBulkSent(address token, address from, uint256 total);
    event LogTokenApproval(address token, uint256 total);

    function createPartnerType(partnerType memory _pType) public payable {
        require(msg.value >= partnerCharges || owner()==msg.sender, "You must have min of charge required in BNB to create a token");
        partnerTypes.push(_pType);
        partnerCount++;
    }

    function addPartnerType(partnerInfo memory _pInfo) public payable {
        require(msg.value >= partnerCharges || owner()==msg.sender, "You must have min of charge required in BNB to create a token");
        partnerInfos.push(_pInfo);
        partnerInfoCount++;
    }

    function updatePartnerInfo(uint256 _pid, string memory _telegram, string memory _website, bool _status) public payable {
        require(msg.value >= partnerCharges || owner()==msg.sender, "You must have min of charge required in BNB to create a token");
        partnerInfos[_pid].telegram = _telegram;
        partnerInfos[_pid].website = _website;
        partnerInfos[_pid].status = _status;
   
    }

     function updateLPInfo(uint256 _tid,  bool _kyc, bool _audit, bool _avc) public payable {
        address adminAddress = tokenInfos[_tid].adminAddress;
        require((msg.sender == adminAddress && msg.value == launchCharges) || owner()==msg.sender, "You are not the owner of the project");
         lps[_tid].kyc = _kyc;
         lps[_tid].audit = _audit;
         lps[_tid].avc = _avc;  
    }

    function createToken(liquidityInfo memory _liquidityInfo, projectDetails memory _projectDetails, tokenInfo memory _tokenInfo, bool _rStatus) public payable{
        require(msg.value >= launchCharges || owner()==msg.sender, "You must have min of charge required in BNB to create a token");
        IERC20 token = _tokenInfo.tokenAddress;
        //uint decimal = IERC20(token).decimals();
       
        uint amount = convertToken(_tokenInfo.tokenPricePerBnb, _tokenInfo.hardCap); //_tokenInfo.hardCap.mul(_tokenInfo.tokenPricePerBnb);
        //token.approve(msg.sender, amount);
        uint256 allowance = token.allowance(msg.sender, address(this));
       //  uint tokenAmount = amount ** decimal;
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);

        tokenInfos.push(_tokenInfo);
        lps.push(_liquidityInfo);
        details.push(_projectDetails);
        tokenInfos[projectCount].id = projectCount;
        lps[projectCount].id = projectCount;
        details[projectCount].id = projectCount;
        tokenReferral[projectCount] = _rStatus;
        projectCount++;
    }

    function updateDetails(uint256 _pid, projectDetails memory _projectDetail) public {
        details[_pid] = _projectDetail;
        }

    function updateBNBCharges(uint256 _amount, uint256 _referPercent) public onlyOwner{
        launchCharges = _amount;
        referPercent = _referPercent;
    }

    function updateStakeType(uint _id, bool status) public onlyOwner{
        tokenInfos[_id].status = status;    
    }

    function getReleaseDate(uint256 time) public view returns (uint256) {
        uint256 newTimestamp = block.timestamp.add(60 * 60 * time);
        return newTimestamp;
    }

    function convertToken(uint256 _tokenPerBNB, uint256 _amountBought) public pure returns (uint256){
        return _tokenPerBNB.mul(_amountBought);
    }
    
    function calcTokenToSend(uint256 _id) public view returns (uint256){
        uint hardCap = tokenInfos[_id].hardCap;
        uint tokenPrice = tokenInfos[_id].tokenPricePerBnb;
        uint price = convertToken(tokenPrice, hardCap);
        return price;
    }

    function sellBackToken(uint _sid, uint amount) public payable{
    require(amount > 0, "amount must be greater than zero");
     IERC20 token = tokenInfos[_sid].tokenAddress;
    // uint256 endTime = tokenInfos[_sid].endTime;
    // uint softCap = tokenInfos[_sid].softCap;
    // uint presaleBalance = buyBalance[_sid];
    uint tokenPrice = tokenInfos[_sid].tokenPricePerBnb;

    uint tokenToBnb = amount / tokenPrice;
   // require(endTime > block.timestamp && presaleBalance < softCap, "You can't sell back now");
    //token.approve(msg.sender, amount);
    // uint256 allowance = token.allowance(msg.sender, address(this));
    // require(allowance >= amount, "Check the token allowance");
    token.transferFrom(msg.sender, address(this), amount);
    (bool tmp, ) = payable(msg.sender).call{value:tokenToBnb, gas:36000}("");
    tmp;
    }

    function buyToken(uint _sid, address referBy) public payable{
    address investor = msg.sender;
    tokenInfo memory info = tokenInfos[_sid];
    uint256 investedTime = block.timestamp;

    require(info.status == false, "You can't buy this token again presales has ended!");
    require(msg.value >= info.minBuy && msg.value <= info.maxBuy, "Pls, buy between minimum and maximum price of the token");
    uint256 totalToCollect = convertToken(info.tokenPricePerBnb, msg.value);
    
    buyBalance[_sid] += msg.value;
    allBuys.push(Invest(_buysCount, investor, msg.value, totalToCollect, referBy, true, investedTime ));
    referer[referBy] += 1; 
    uint refererShare = msg.value.mul(referPercent).div(100);
    uint deliverShare = msg.value.sub(refererShare);
    bool rStatus = tokenReferral[info.id];
    uint lpType = lps[_sid].fundRaiseType;
    if(lpType==0){
    if(rStatus==true && referBy != address(0)){
    payable(info.adminAddress).transfer(deliverShare);
    }
    else{
        payable(info.adminAddress).transfer(msg.value);
    }
    }

    if(rStatus==true && referBy != address(0)){
    payable(referBy).transfer(refererShare);
    }
    
    IERC20(info.tokenAddress).transfer(investor, totalToCollect);
    _buysCount++;
    emit buysReport(investor, msg.value, totalToCollect, referBy, true, investedTime);
    
    }
    //STORE DATA
    IUniswapV2Router02 public immutable uniswapV2Router;
   // address public immutable uniswapV2Pair;
    address public WBNB;// = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    constructor(){ 
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        /*
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        */
        //MainNet Change to 0x10ED43C718714eb63d5aA57B78B54704E256024E  Testnet Option 1: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 PancakeSwapRouterDev2 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    }

    function recoverETHfromContract() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Withdraw ERC20 tokens that are potentially stuck
    function recoverTokensFromContract(address _tokenAddress, uint256 _amount) external onlyOwner {                               
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    function getStakerInfo(uint _id)public view returns(uint, address,uint,bool, uint) {
        Invest storage stakerbuys = isInvested[_id];
        require(stakerbuys.staker==msg.sender || stakerbuys.staker==owner(),"You are not permitted to get the staker info");
        return(stakerbuys.id,stakerbuys.staker,stakerbuys.bnbPaid,stakerbuys.releaseStatus, stakerbuys.date);

    }

    function getAllBuysRecord() public view returns(Invest[] memory){
        return allBuys;
    }

    function getAllTokenInfo() public view returns(tokenInfo[] memory){
        return tokenInfos;
    }

    function getAllPartnerType() public view returns(partnerType[] memory){
        return partnerTypes;
    }

    function getAllPartnerInfo() public view returns(partnerInfo[] memory){
        return partnerInfos;
    }

    function getPartnerInfo(uint256 _id) public view returns(partnerInfo memory){
        return partnerInfos[_id];
    }

    function getTokenInfo(uint256 _id) public view returns(tokenInfo memory){
       // tokenInfo memory info = tokenInfos[_id];
        return tokenInfos[_id];
    }

    function getAllTokenLp(uint256 _id) public view returns(liquidityInfo memory){
        return lps[_id];
    }

    function getAllProjectDetails(uint256 _id) public view returns(projectDetails memory){
        return details[_id];
    }

    function getPresaleBalance(uint256 _id) public view returns(uint){
        return buyBalance[_id];
    }

    function endSales(uint _id) public {
        
        IERC20 _tokenAddress = tokenInfos[_id].tokenAddress;
        address adminAddress = tokenInfos[_id].adminAddress;
        
        uint endTime = tokenInfos[_id].endTime;
        bool tStatus = tokenInfos[_id].status;
        uint256 amountTokenMin = lps[_id].listingRate;
        uint256 ethMin = 1 ether;
        uint presaleBal = buyBalance[_id];
        uint lpType = lps[_id].fundRaiseType;
        uint _percentageToLp = lps[_id].percentageToLp;
        uint lpShare = presaleBal.mul(_percentageToLp).div(100);
        uint ownerShare = presaleBal.sub(lpShare);
        uint tokenBalance = _tokenAddress.balanceOf(address(this));
        require(adminAddress==msg.sender || owner()==msg.sender,"fuck you x100");
        if(block.timestamp > endTime && tStatus == false){
        // _tokenAddress.transfer(adminAddress, tokenBalance);
         if(lpType==1){
             payable(adminAddress).transfer(ownerShare);
            // pair = IDEXFactory(router.factory()).createPair(address(_tokenAddress), router.WETH());
            // router.addLiquidityETH(
            // address(_tokenAddress),
            // tokenBalance, 
            // amountTokenMin,
            // ethMin,
            // msg.sender,
            // block.timestamp + 300
            // );

            launchToLP(address(_tokenAddress), tokenBalance, lpShare,amountTokenMin, ethMin, 300);
 
         }

        }
        else{
             _tokenAddress.transfer(adminAddress, tokenBalance);
        }
        tokenInfos[_id].status = true; 
       
    }

      function launchToLP(address token, uint256 tokenAmount, uint256 ethA, uint256 amountTokenMin, uint256 amountETHMin, uint addTime) public {
        // approve token transfer to cover all possible scenarios
    //    token.approve(address(this), tokenA);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethA}(
            token,
            tokenAmount,
            amountTokenMin, // slippage is unavoidable
            amountETHMin, // slippage is unavoidable
            owner(),
            block.timestamp + addTime
        );

    }

}