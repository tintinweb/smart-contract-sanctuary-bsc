/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
      if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    
    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

   function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

//start dex

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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
//end dex
abstract contract ReentrancyGuard {
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

contract LINCOLNSALE_LAUNCHPAD is Ownable, ReentrancyGuard{
    using SafeMath for uint256;

    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;  
    IDEXRouter public router;
    address public pair;

    event Log(string message, uint val);
    
    uint256 launchCharges = 1000000000000000000;
    uint256 partnerCharges = 200000000000000000;
    uint256 referPercent = 10;
    string private _name = "LINCOLNSALE IDO";
    string private _symbol = "LSL";
    uint8 private _decimals = 18;
    uint[] public lockedbuys;
    

    event buysReport(address investorAddress, uint256 bnbAmount,uint256 tokenToCollect, address refererAddress, bool releaseStatus, uint256 buysDate);
    event inventReleased(address from, address to, uint256 totalEarned, uint256 ctime); 

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

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
    mapping (address=>uint) public refererEarned;
    mapping (uint=>mapping(address=>uint)) public refererBalance;
    mapping (uint256=>address) private addresses;
    mapping (uint => Invest) private isInvested;
    mapping (uint => uint) public buyBalance;

    partnerType[] public partnerTypes;
    partnerInfo[] public partnerInfos;
    Invest[] public allBuys;
    projectDetails[] public details;
    liquidityInfo[] public lps;
    event LogTokenBulkSent(address token, address from, uint256 total);
    event LogTokenApproval(address token, uint256 total);

    function createPartnerType(partnerType memory _pType) public payable nonReentrant {
        require(msg.value >= partnerCharges || owner()==msg.sender, "You must have min of charge required in BNB to create a token");
        partnerTypes.push(_pType);
        partnerCount++;
    }

    function addPartnerType(partnerInfo memory _pInfo) public payable nonReentrant {
        require(msg.value >= partnerCharges || owner()==msg.sender, "You must have min of charge required in BNB to create a token");
        partnerInfos.push(_pInfo);
        partnerInfoCount++;
    }

    function updatePartnerInfo(uint256 _pid, string memory _telegram, string memory _website, bool _status) public payable nonReentrant {
        require(msg.value >= partnerCharges || owner()==msg.sender, "You must have min of charge required in BNB to create a token");
        partnerInfos[_pid].telegram = _telegram;
        partnerInfos[_pid].website = _website;
        partnerInfos[_pid].status = _status;
   
    }

     function updateLPInfo(uint256 _tid,  bool _kyc, bool _audit, bool _avc) public payable nonReentrant {
        address adminAddress = tokenInfos[_tid].adminAddress;
        require((msg.sender == adminAddress && msg.value == launchCharges) || owner()==msg.sender, "You are not the owner of the project");
         lps[_tid].kyc = _kyc;
         lps[_tid].audit = _audit;
         lps[_tid].avc = _avc;  
    }

    function createToken(liquidityInfo memory _liquidityInfo, projectDetails memory _projectDetails, tokenInfo memory _tokenInfo, bool _rStatus) public payable nonReentrant{
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

    function sellBackToken(uint _sid, uint amount) public payable nonReentrant{
    require(amount > 0, "amount must be greater than zero");
    IERC20 token = tokenInfos[_sid].tokenAddress;
    uint256 endTime = tokenInfos[_sid].endTime;
    uint softCap = tokenInfos[_sid].softCap;
    uint presaleBalance = buyBalance[_sid];
    uint tokenPrice = tokenInfos[_sid].tokenPricePerBnb;

    uint tokenToBnb = amount / tokenPrice;
    require(endTime > block.timestamp && presaleBalance < softCap, "You can't sell back now");
    //token.approve(msg.sender, amount);
    uint256 allowance = token.allowance(msg.sender, address(this));
    require(allowance >= amount, "Check the token allowance");
    token.transferFrom(msg.sender, address(this), amount);
    (bool tmp, ) = payable(msg.sender).call{value:tokenToBnb, gas:36000}("");
    tmp;
    }

    function buyToken(uint _sid, address referBy) public payable nonReentrant{
    address investor = msg.sender;
    tokenInfo memory info = tokenInfos[_sid];
    uint256 investedTime = block.timestamp;

    require(info.status == false, "You can't buy this token again presales has ended!");
    require(msg.value >= info.minBuy && msg.value <= info.maxBuy, "Pls, buy between minimum and maximum price of the token");
    uint256 totalToCollect = convertToken(info.tokenPricePerBnb, msg.value);
    
    buyBalance[_sid] += msg.value;
    allBuys.push(Invest(_buysCount, investor, msg.value, totalToCollect, referBy, true, investedTime ));
    referer[referBy] += 1; 
    uint refererShare = msg.value.mul(referPercent).div(100).div(2);
    uint deliverShare = msg.value.sub(refererShare);
    bool rStatus = tokenReferral[info.id];
    uint lpType = lps[_sid].fundRaiseType;
    if(lpType==0){
    if(rStatus==true && referBy != address(0)){
    payable(info.adminAddress).transfer(deliverShare);
    payable(referBy).transfer(refererShare);
    refererEarned[referBy] += refererShare;
    }
    else{
        payable(info.adminAddress).transfer(msg.value);
    }
    }
    else{
        if(rStatus==true && referBy != address(0)){
        //payable(info.adminAddress).transfer(deliverShare);
        //payable(referBy).transfer(refererShare);
        refererEarned[referBy] += refererShare;
        refererBalance[_sid][referBy] += refererShare;   
        }
        //payable(info.adminAddress).transfer(msg.value);
    }

    IERC20(info.tokenAddress).transfer(investor, totalToCollect);
    addresses[_buysCount] = msg.sender;
    _buysCount++;
    emit buysReport(investor, msg.value, totalToCollect, referBy, true, investedTime);
    
    }
    //STORE DATA
    constructor() payable{ 

    }

    receive() external payable { }

    function recoverETHfromContract(uint _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    // Withdraw ERC20 tokens that are potentially stuck
    function recoverTokensFromContract(address _tokenAddress, uint256 _amount) external onlyOwner {                               
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    function getStakerInfo(uint _id)public view returns(uint, address,uint,bool) {
        Invest storage stakerbuys = isInvested[_id];
        require(stakerbuys.staker==msg.sender || stakerbuys.staker==owner(),"You are not permitted to get the staker info");
        return(stakerbuys.id,stakerbuys.staker,stakerbuys.bnbPaid,stakerbuys.releaseStatus);

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

    function getRefererBalance(uint256 _id, address uddr) public view returns(uint, uint){
        return (refererBalance[_id][uddr],refererEarned[uddr]);
    }

    function withdrawRefererShare(uint _id) public nonReentrant{
        uint endTime = tokenInfos[_id].endTime;
        bool tStatus = tokenInfos[_id].status;
        if(block.timestamp > endTime && tStatus == true){
        payable(msg.sender).transfer(refererBalance[_id][msg.sender]);
        }
    }

    function deposit(address poolAddr, uint256 tokenAmount) public payable{
      IERC20(poolAddr).transfer(address(this), tokenAmount);  
    }

    function endSales(uint _id) public nonReentrant{
        
        IERC20 _tokenAddress = tokenInfos[_id].tokenAddress;
        address adminAddress = tokenInfos[_id].adminAddress;
        
        uint endTime = tokenInfos[_id].endTime;
        bool tStatus = tokenInfos[_id].status;
        uint presaleBal = buyBalance[_id];
        uint lpType = lps[_id].fundRaiseType;
        uint _percentageToLp = lps[_id].percentageToLp;
        uint lpShare = presaleBal.mul(_percentageToLp).div(100);
        uint ownerShare = presaleBal.sub(lpShare);
        //address Router = lps[_id].swapRouterAddress;
        require(adminAddress==msg.sender || owner()==msg.sender,"fuck you x100");
        if(block.timestamp > endTime && tStatus == false){
         uint256 tBalance = _tokenAddress.balanceOf(address(this)); 
         //_tokenAddress.transfer(adminAddress, _tokenAddress.balanceOf(address(this)));
         if(lpType==1){
             payable(adminAddress).transfer(ownerShare);
             //createPair(Router, address(_tokenAddress));
             addToLiquidity(address(_tokenAddress),tBalance,lpShare,adminAddress,0,0);
         }

        }
        tokenInfos[_id].status = true; 
       
    }

    function createPair(address Router, address poolAddr) private {
       router = IDEXRouter(Router);
       pair = IDEXFactory(router.factory()).createPair(router.WETH(), poolAddr);
    }

    function addToLiquidity(address poolAddr, uint256 tokenAmount, uint256 ethAmount, address addr, uint256 amtTokenMin, uint256 amtEthMin) private {
        // approve token transfer to cover all possible scenarios
       // _approve(address(this), address(router), tokenAmount);
        IERC20(poolAddr).approve(ROUTER, tokenAmount);
        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            poolAddr,
            tokenAmount,
            amtTokenMin, // slippage is unavoidable
            amtEthMin, // slippage is unavoidable
            addr,
            block.timestamp
        );
    }
}