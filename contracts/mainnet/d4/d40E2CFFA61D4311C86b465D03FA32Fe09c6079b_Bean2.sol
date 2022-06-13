/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

abstract contract Context {

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

interface BIG {
    function modFund() external view returns(uint256);
    function marketingFund() external view returns(uint256);
    function developmentFund() external view returns(uint256);
    function CEXFund() external view returns(uint256);
    function rewardFund() external view returns(uint256);
    function setBurn(uint256 amt) external;
    function setReflection(uint256 amt) external;
    function getMarketCap() external view returns(uint256);
    function getSpotPerETH() external view returns(uint256);
    function getETHUSD() external view returns(uint256);
    function getRewardAmount() external view returns(uint256);
    function getModPay() external view returns(uint256);
    function Karma(address addy) external view returns(uint256);
    function boostKarma(address addy) external;
}

interface oDAO {
    function isVoter(address addy) external view returns(bool);
    function userRegisteredVoteAmount(address addy) external view returns(uint256);
}

interface tresCont {
    function generateMarketingClaim(uint256 claim, uint256 amt) external;
    function generateCEXClaim(uint256 claim, uint256 amt) external;
}

contract Bean2 is Context, Rmath {
    using SafeMath for uint256;
    using Address for address;

    struct Marketing {
        uint256 proposalID;
        string description;
        address requestor;
        uint256 cost;
        uint256 upVote;
        uint256 downVote;
        uint256 timeSubmitted;
        uint256 voteExpires;
        bool live;
        bool approved;
        bool finished;
    }
    Marketing[] public mark;

    struct userBoard {
        string bio;
        string nickName;
    }

    struct Mods {
        string telegramHandle;
        uint256 ID;
        address wallet;
        uint256 lastPay;
        uint256 upVote;
        uint256 downVote;
        uint256 timeSubmitted;
        uint256 challengeExpires;
        bool live;
        bool upForVote;
        bool upForReplace;
        bool paused;
    }
    Mods[] public mods;

    mapping (address => userBoard) public uB;    
    mapping (string => address) private nickNameAddress;
    mapping (uint256 => Marketing) public rMar;
    mapping (uint256 => Mods) public rMod;
    mapping (address => mapping (uint256 => uint256)) public userLastMarVote;
    mapping (address => mapping (uint256 => uint256)) public userLastModVote;
    mapping (uint256 => uint256) public lastModStrikeVote;
    mapping (address => mapping (uint256 => uint256)) private userLastModStriker;
    mapping (address => uint256) private userLastStriker;
    mapping (address => uint256) public userLastVoted;
    mapping (uint256 => uint256) public modStrikes;
    mapping (address => bool) public isMod;
    mapping (address => uint256) public userTotalVotes;
    mapping (uint256 => uint256) public modPauseAmt;
    mapping (address => uint256) public getModID;
    mapping (address => mapping (address => bool)) private migrateApp;
    address[] private allModWallets;
    uint256 public migrateApprovals = 0;
    address public $BIG = 0x47124b83449FfDd0166E7E6809883181B5f4774b;
    address public dao = 0x7fF93BE16f0FE11cE4CD878817a851e5f4FC692F;
    address public newLoc;
    address public treasurer;
    uint256 public voteTime = 30 minutes;
    uint256 public marketingRequestID = 0;
    uint256 public marketingInVote = 0;
    uint256 public marketingFund = 150000000000000000000000000000000;
    uint256 public marInHold = 0;
    uint256 public modID = 0;
    uint256 public modFund = 50000000000000000000000000000000;
    uint256 public liveMods = 0;
    uint256 public totalVoteCasted = 0;
    event submitMarketingRequest(string _description, uint256 _cost, uint256 ID, address _requestor);
    event approvedMarketing(string _description, uint256 _cost, uint256 ID);
    event appointMod(string _handle, address wallet);
    event liveMod(uint256 ID);
    event removedMod(uint256 ID, address wallet);
    event paidMod(uint256 ID, uint256 amount);

    constructor() {
        isMod[msg.sender] = true;
    }

    function addNewLoc(address addy) external {
        require(isMod[msg.sender] == true);
        newLoc = addy;
    }

    function approveMigrate() external {
        require(isMod[msg.sender] == true);
        require(migrateApp[msg.sender][newLoc] == false);
        migrateApprovals += 1;
        migrateApp[msg.sender][newLoc] = true;
        if(migrateApprovals >= 15){
            _pushUnderlying(address(this), newLoc, IERC20($BIG).balanceOf(address(this)));
        }
    }

    function getNickNameWallet(string memory name) external view returns(address) {
        return nickNameAddress[name];
    }

    function setTreasury(address addy) external {
        require(treasurer == address(0));
        treasurer = addy;
    }

    function setUserBio(string memory bio) external {
        require(oDAO(dao).userRegisteredVoteAmount(msg.sender) > 0, "Must be voter");
        uB[msg.sender].bio = bio;
    }

    function getUserBio(address addy) external view returns(string memory){
        return uB[addy].bio;
    }

    function getPaginatedrMod(uint256 _page, uint256 _resultsPerPage) external view returns (Mods[] memory) {
    uint256 _squareIndex = _resultsPerPage * _page - _resultsPerPage;

    if (modID == 0) {
      return new Mods[](0);
    }

    Mods[] memory id = new Mods[](_resultsPerPage);
    uint256 _returnCounter = 0;
    for (
      _squareIndex; 
      _squareIndex < _resultsPerPage * _page; 
      _squareIndex++
    ) {
      if (_squareIndex < modID + 1) {
        
            Mods storage mod = rMod[_returnCounter];
            id[_returnCounter] = mod;
      } else {
        id[_returnCounter];
      }

      _returnCounter++;
    }

    return id;
  }

    function getMods() public view returns(Mods[] memory) {
        uint256 mid = modID + 1;
        Mods[] memory id = new Mods[](mid);
        for (uint256 i = 0; i < mid; i++) {
            Mods storage mod = rMod[i];
            id[i] = mod;
        }
        return id;
    }

    function getMarketing() public view returns(Marketing[] memory) {
        uint256 mid = marketingRequestID + 1;
        Marketing[] memory id = new Marketing[](mid);
        for (uint256 i = 0; i < mid; i++) {
            Marketing storage mar = rMar[i];
            id[i] = mar;
        }
        return id;
    }

    function rMarLength() public view returns(uint256) {
        return marketingRequestID;
    }

    function rModLength() public view returns(uint256) {
        return modID;
    }

    function getPaginatedrMar(uint256 _page, uint256 _resultsPerPage) external view returns (Marketing[] memory) {
    uint256 _squareIndex = _resultsPerPage * _page - _resultsPerPage;

    if (
      marketingRequestID == 0 || 
      _squareIndex > marketingRequestID - 1
    ) {
      return new Marketing[](0);
    }

    Marketing[] memory id = new Marketing[](_resultsPerPage);
    uint256 _returnCounter = 0;
    for (
      _squareIndex; 
      _squareIndex < _resultsPerPage * _page; 
      _squareIndex++
    ) {
      if (_squareIndex < marketingRequestID + 1) {
          
            Marketing storage mar = rMar[_returnCounter];
            id[_returnCounter] = mar;
      } else {
        id[_returnCounter];
      }

      _returnCounter++;
    }

    return id;
  }

    function userRegisteredVoteAmount(address addy) public view returns(uint256) {
        return oDAO(dao).userRegisteredVoteAmount(addy);
    }

    function allMODs() external view returns(address[] memory) {
        return allModWallets;
    }

    function updateFunds() external { // gives reflections in contract to development
        uint256 bal = IERC20($BIG).balanceOf(address(this));
        uint256 hold = marketingFund + marInHold + modFund;
        if(bal > hold){
        uint256 tot = bal - hold;
        uint256 _share = tot / 3;
        marketingFund = marketingFund + (_share + _share);
        modFund = modFund + _share;
        }
    }
    
    function isVoter(address addy) public view returns(bool) {
        bool answer;
        if(userRegisteredVoteAmount(addy) > 0){
            answer = true;
        }
        else {
            answer = false;
        }
        return answer;
    }

    function appointModForVote(string memory _handle, address _wallet) external {
        require(msg.sender == treasurer && isMod[_wallet] == false);
        require(getModID[_wallet] == 0);
        modID += 1;
        getModID[_wallet] = modID;
        rMod[modID].telegramHandle = _handle;
        rMod[modID].ID = modID;
        rMod[modID].wallet = _wallet;
        rMod[modID].upForVote = true;
        rMod[modID].timeSubmitted = block.timestamp;
        rMod[modID].challengeExpires = block.timestamp + voteTime;
        emit appointMod(_handle, _wallet);
        allModWallets.push(_wallet);
    }    

    function voteModLive(uint256 ID, uint256 option) external {
        require(rMod[ID].upForVote == true, "Not up for vote");
        require(msg.sender != rMod[ID].wallet);
        require(userRegisteredVoteAmount(msg.sender) > 0);
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(block.timestamp < rMod[ID].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastModVote[msg.sender][ID] + 1 days, "7 days"); //fix
        if(option == 1) {
            rMod[ID].upVote += 10000000000000;     //fix
        }
        else{
            rMod[ID].downVote += 10000000000000;        //fix
        } 
        userLastModVote[msg.sender][ID] = block.timestamp;   
        userLastVoted[msg.sender] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function toggleVoteModReplace(uint256 ID) external {        
        require(rMod[ID].live == true && rMod[ID].upForReplace == false);
        require(rMod[ID].live == true || rMod[ID].paused == true);
        require(modStrikes[ID] >= 10000000000000000000000000000, "Insufficient strikes");    //fix  bdiv(IERC20($BIG).totalSupply(), 5)
        rMod[ID].upForReplace = true;
        rMod[ID].live = false;
        rMod[ID].timeSubmitted = block.timestamp;
        rMod[ID].challengeExpires = block.timestamp + voteTime;
        isMod[rMod[ID].wallet] = false;
    }

    function voteModReplace(uint256 ID, uint256 option) external {   
        require(rMod[ID].live == true && rMod[ID].upForReplace == true);
        require(userRegisteredVoteAmount(msg.sender) > 0, "You must hold over amount");
        require(option == 1 || option == 2, "1 for keep, 2 for remove");
        require(block.timestamp < rMod[ID].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastModVote[msg.sender][ID] + 1 days, "7 days");           //fix
        if(option == 1) {
            rMod[ID].upVote += userRegisteredVoteAmount(msg.sender);
        }
        else{
            rMod[ID].downVote += userRegisteredVoteAmount(msg.sender);
        }
        userLastModVote[msg.sender][ID] = block.timestamp;   
        userLastVoted[msg.sender] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function emergencyModPause(uint256 ID, uint256 choice) external {
        require(isMod[msg.sender] == true && block.timestamp >= userLastVoted[msg.sender] + 1 hours); //fix
        userLastVoted[msg.sender] == block.timestamp;
        if(choice == 1) {
        modPauseAmt[ID] += 1;
        if(modPauseAmt[ID] >= 5) {
            isMod[rMod[ID].wallet] = false;
            rMod[ID].live = false;
            modPauseAmt[ID] = 0;
            rMod[ID].paused = true;
        }
        }
        else{
            if(modPauseAmt[ID] > 0){
            modPauseAmt[ID] -=1;
        }
        }
    }

    function emergencyModReinstate(uint256 ID, uint256 choice) external {
        require(isMod[msg.sender] == true);
        require(rMod[ID].paused == true && rMod[ID].live == false);
        if(choice == 1) {
        modPauseAmt[ID] += 1;
        if(modPauseAmt[ID] >= 5) {
            isMod[rMod[ID].wallet] = true;
            rMod[ID].live = true;
            modPauseAmt[ID] = 0;
            rMod[ID].paused = false;
        }
        }
        else{
            if(modPauseAmt[ID] > 0){
            modPauseAmt[ID] -=1;
        }
        }
    }

    function modStepDown(uint256 ID) external {
        require(isMod[msg.sender] == true);
        require(rMod[ID].wallet == msg.sender);
        liveMods -= 1;
        rMod[ID].live = false;
        modStrikes[ID] = 0;
        isMod[msg.sender] = false;
    }

    function strikeMod(uint256 ID) external {
        require(rMod[ID].live == true, "Not live");
        require(userRegisteredVoteAmount(msg.sender) > 0);
        require(block.timestamp > userLastModStriker[msg.sender][ID] + 1 days);           //fix
        userLastModStriker[msg.sender][ID] = block.timestamp;
        lastModStrikeVote[ID] = block.timestamp;
        modStrikes[ID] += userRegisteredVoteAmount(msg.sender);
        totalVoteCasted += 1;
    }
    
    function resetModStrikes(uint256 ID) external {
        require(rMod[ID].live == true);
        require(isMod[msg.sender] == true);
        require(msg.sender != rMod[ID].wallet);
        require( block.timestamp >= lastModStrikeVote[ID] + 1 days, "1 days");          //fix
        modStrikes[ID] = 0;
    }    
    
    function activateMod(uint256 ID) external {
        require(rMod[ID].upForVote == true && rMod[ID].upForReplace == false);
        require(block.timestamp > rMod[ID].challengeExpires);
        address mod = rMod[ID].wallet;
        if(rMod[ID].upVote > rMod[ID].downVote){            
            isMod[mod] = true;
            rMod[ID].live = true;
            rMod[ID].upForVote = false;
            rMod[ID].challengeExpires = 0;
            liveMods += 1;
            require(liveMods <= 40, "Only 40 live mods");
            allModWallets.push(rMod[ID].wallet);
            emit liveMod(ID);
        }
        if(rMod[ID].upVote <= rMod[ID].downVote){
            isMod[mod] = false;
            rMod[ID].live = false;
            rMod[ID].upForVote = false;
            rMod[ID].challengeExpires = 0;
        }        
            rMod[ID].upVote = 0;
            rMod[ID].downVote = 0;
    }

    function removeMod(uint256 ID) external {
        require(rMod[ID].upForReplace == true);
        require(block.timestamp > rMod[ID].challengeExpires);
        address mod = rMod[ID].wallet;
        if(rMod[ID].upVote > rMod[ID].downVote){                       
            isMod[mod] = true;
            rMod[ID].live = true;
            rMod[ID].upForVote = false;
            rMod[ID].upForReplace = false;
            rMod[ID].challengeExpires = 0;
            emit liveMod(ID);
        }
        if(rMod[ID].upVote <= rMod[ID].downVote){
            isMod[mod] = false;
            rMod[ID].live = false;
            rMod[ID].upForVote = false;
            rMod[ID].upForReplace = false;
            rMod[ID].challengeExpires = 0;
            liveMods -= 1;
        }
            rMod[ID].upVote = 0;
            rMod[ID].downVote = 0;
    }

    function payMod(uint256 ID) external {
        require(msg.sender == rMod[ID].wallet && isMod[msg.sender] == true);
        uint256 amt = BIG($BIG).getModPay();
        uint256 frac = BIG($BIG).Karma(rMod[ID].wallet);
        if(frac >= 1500){
            frac = 1500;
        }
        if(frac <= 200){
            frac = 200;
        }
        uint256 give = bmul(amt, bdiv(frac, 1000));
        require(modFund >= give);
        require(block.timestamp > rMod[ID].lastPay + 1 hours);             //fix
        rMod[ID].lastPay = block.timestamp;
        modFund -= give;
        _pushUnderlying($BIG, rMod[ID].wallet, give);
        emit paidMod(ID, give);
    }   

    function requestMarketing(string memory _description, uint256 _cost) external {
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        require(hold > 1000000000000000, "You must hold over 1M $BIG SHIBA to open request");
        require(BIG($BIG).Karma(msg.sender) > 0, "No karma");
        require(marketingInVote <= 50, "10 open max");             //fix
        marketingRequestID += 1;
        require(_cost < marketingFund.sub(marInHold) && _cost <= bdiv(marketingFund, 10), "Over Funds");
        rMar[marketingRequestID].proposalID = marketingRequestID;
        rMar[marketingRequestID].description = _description;
        rMar[marketingRequestID].cost = _cost;
        rMar[marketingRequestID].timeSubmitted = block.timestamp;
        rMar[marketingRequestID].requestor = msg.sender;
        emit submitMarketingRequest(_description, _cost, marketingRequestID, msg.sender);
    } 

    function initiateStartMarketingVote(uint256 ID, bool _bool) external {
        require(isMod[msg.sender] == true && rMar[ID].live == false);
        require(rMar[ID].requestor != msg.sender);
        if(_bool == true) {
            uint256 amt = rMar[ID].cost;       
            marInHold += amt;
            rMar[ID].live = _bool;
            rMar[ID].voteExpires = block.timestamp + voteTime;
            marketingInVote += 1;
        }
        BIG($BIG).boostKarma(msg.sender);
    }

    function voteForMarketing(uint256 ID, uint256 option) external {
        require(rMar[ID].live == true, "Not live");
        require(userRegisteredVoteAmount(msg.sender) > 0);
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(block.timestamp < rMar[ID].voteExpires, "Vote Expired");
        require(block.timestamp > userLastMarVote[msg.sender][ID] + 7 days, "7");
        require(msg.sender != rMar[ID].requestor);
        if(option == 1) {
            rMar[ID].upVote += userRegisteredVoteAmount(msg.sender);
        }
        else{rMar[ID].downVote += userRegisteredVoteAmount(msg.sender);
        }
        userLastMarVote[msg.sender][ID] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function closeMarketingVote(uint256 ID) external {
        require(isMod[msg.sender] == true && rMar[ID].finished == false);
        require(block.timestamp > rMar[ID].voteExpires);
        if(rMar[ID].upVote > rMar[ID].downVote){
        rMar[ID].approved = true;
        _pushUnderlying($BIG, treasurer, rMar[ID].cost);
        tresCont(treasurer).generateMarketingClaim(ID, rMar[ID].cost);
        marketingFund -= rMar[ID].cost;
        marInHold -= rMar[ID].cost;
        }
        else{
        marInHold -= rMar[ID].cost;
        }      
        marketingInVote -= 1;   
        rMar[ID].live = false;
        rMar[ID].finished = true;  
    }

    function _pushUnderlying(address erc20, address to, uint256 amount)
        internal 
    {   
        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer);
    }
}