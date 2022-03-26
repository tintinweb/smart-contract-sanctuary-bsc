/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.11;

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
}

contract ya is Context, Rmath {
    using SafeMath for uint256;
    using Address for address;

    struct Development {
        string description;
        address requestor;
        uint256 duration;
        uint256 bid;
        uint256 upVote;
        uint256 downVote;
        uint256 timeSubmitted;
        uint256 voteExpires;
        bool live;
        bool approved;
        bool devSubmitted;
        bool finished;
    }

    struct Marketing {
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

    struct Treasury {
        address treasuror;
        address requestedNew;
        uint256 treasuryCount;
        uint256 upVote;
        uint256 downVote;
        uint256 timeSubmitted;
        uint256 challengeExpires;
        bool live;
        bool upForVote;        
    }

    struct CEX {
        string name;
        uint256 cost;
        uint256 upVote;
        uint256 downVote;
        uint256 timeSubmitted;
        uint256 challengeExpires;
        bool live;
        bool upForVote;  
    }

    struct Mods {
        string telegramHandle;
        address wallet;
        uint256 cost;
        uint256 lastPay;
        uint256 upVote;
        uint256 downVote;
        uint256 timeSubmitted;
        uint256 challengeExpires;
        bool live;
        bool upForVote;
        bool upForReplace;
    }
    
    mapping (uint256 => Development) public rDev;
    mapping (uint256 => Marketing) public rMar;
    mapping (uint256 => Treasury) public tres;
    mapping (uint256  => CEX) public rCEX;
    mapping (uint256 => Mods) public rMod;
    mapping (address => uint256) public userReward;
    mapping (address => uint256) public userRewardTime;
    mapping (address => uint256) public userLastChallenge;  
    mapping (address => mapping (uint256 => uint256)) public userLastCEXVote;   
    mapping (address => mapping (uint256 => uint256)) public userLastDevVote;   
    mapping (address => uint256) public userLastDevFinishVote;
    mapping (address => mapping (uint256 => uint256)) public userLastMarVote;
    mapping (address => mapping (uint256 => uint256)) public userLastModVote;
    mapping (uint256 => uint256) public lastModStrikeVote;
    mapping (address => mapping (uint256 => uint256)) private userLastModStriker;
    mapping (address => uint256) private userLastStriker;
    mapping (address => uint256) public userLastVoted;
    mapping (uint256 => uint256) public modStrikes;
    mapping (address => uint256) private registeredVoteAmount;
    mapping (address => bool) public isMod;
    uint256 public lastTreasuryStrike;
    address public $BIG = 0xB920187854969A8879249CBD8d6a4220590ac789;
    address public treasurer = 0x3970DBe6b41710cf124Efd6dDC4CFD1C4c0aa5a2;
    uint256 public treasuryStrikes = 0;
    uint256 public voteTime = 15 minutes;
    uint256 public developmentRequestID = 0;
    uint256 public marketingRequestID = 0;
    uint256 public marketingInVote = 0;
    uint256 public rewardID = 0;
    uint256 private developmentShare = 20;
    uint256 public developmentInVote = 0;
    uint256 public developmentFund = 200000000000000e9;
    uint256 public devInHold = 0;
    uint256 private marketingShare = 150000000000000e9;
    uint256 public marketingFund;
    uint256 public marInHold = 0;
    uint256 public modID = 0;
    uint256 private modShare = 50000000000000e9;
    uint256 public modFund;
    uint256 private modWeeklyPay = 100000000 * 10**9; // 100 Million tokens per week, cannot ever be changed. Will supply 961.53 mod years with 5% supply. (20 mods for 48.05 years)
    uint256 private CEXShare = 50000000000000e9;
    uint256 public CEXFund;
    uint256 public CEXInHold = 0;
    uint256 public CEXInVote = 0;
    uint256 public CEXID = 0;
    uint256 private rewardShare = 50000000000000e9; // 1 Billion Max per day, giving 136 years of daily rewards, 1 reward max given per day.
    uint256 public rewardFund;
    event submitCEX(string cex, uint256 _cost);
    event submitDevelopmentRequest(string _description, uint256 _bid, uint256 ID, address _requestor);
    event approvedDevelopment(string _description, uint256 _bid, uint256 ID);
    event submitMarketingRequest(string _description, uint256 _cost, uint256 ID, address _requestor);
    event approvedMarketing(string _description, uint256 _cost, uint256 ID);
    event appointMod(string _handle, address wallet);
    event liveMod(uint256 ID);
    event removedMod(uint256 ID, address wallet);
    event paidMod(uint256 ID, uint256 amount);
    event newTreasurer(address _new);

    function userRegisteredVoteAmount(address user) external view returns(uint256) {
        return registeredVoteAmount[user];
    }

    function updateDevFund() external { // gives reflections in contract to development
        require(msg.sender == treasurer);
        developmentFund = IERC20(address(this)).balanceOf(address(this)).sub(marketingFund + marInHold + modFund + rewardFund + CEXFund + CEXInHold);
    }
    
    function registerVoting(uint256 amount) external {       
        require(registeredVoteAmount[msg.sender] == 0, "Already registered");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold > amount, "You must hold over amount");
        registeredVoteAmount[msg.sender] += amount;
    }

    function unRegisterVoting() external {       
        require(registeredVoteAmount[msg.sender] > 0, "Not registered");
        require(block.timestamp > userLastVoted[msg.sender] + 7 days, "Voted within 7 days");
        registeredVoteAmount[msg.sender] = 0;
    }

    function isVoter(address addy) public view returns(bool) {
        bool answer;
        if(registeredVoteAmount[addy] > 0){
            answer = true;
        }
        else {
            answer = false;
        }
        return answer;
    }

    function appointModForVote(string memory _handle, address _wallet) external {
        require(msg.sender == treasurer);
        modID += 1;
        require(modID <= 40); // Max 40 fulltime paid Mods at a time
        rMod[modID].telegramHandle = _handle;
        rMod[modID].wallet = _wallet;
        rMod[modID].upForVote = true;
        rMod[modID].timeSubmitted = block.timestamp;
        rMod[modID].challengeExpires = block.timestamp + voteTime;
        emit appointMod(_handle, _wallet);
    }    

    function voteModLive(uint256 ID, uint256 option) external {
        require(rMod[ID].upForVote == true, "Not up for vote");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(block.timestamp < rMod[ID].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastModVote[msg.sender][ID] + 7 days, "Must be over 7 days");
        if(option == 1) {
            rMod[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{
            rMod[ID].downVote += registeredVoteAmount[msg.sender];
        } 
        userLastModVote[msg.sender][ID] = block.timestamp;   
        userLastVoted[msg.sender] = block.timestamp;
    }

    function toggleVoteModReplace(uint256 ID) external {        
        require(rMod[ID].live == true && rMod[ID].upForReplace == false, "Not live");
        require(modStrikes[ID] >= bdiv(IERC20($BIG).totalSupply(), 10), "Insufficient strikes");    //fix
        rMod[ID].upForReplace = true;
        rMod[ID].timeSubmitted = block.timestamp;
        rMod[ID].challengeExpires = block.timestamp + voteTime;
    }

    function voteModReplace(uint256 ID, uint256 option) external {   
        require(rMod[ID].live == true && rMod[ID].upForReplace == true, "Not live");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(option == 1 || option == 2, "1 for keep, 2 for remove");
        require(block.timestamp < rMod[ID].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastModVote[msg.sender][ID] + 3 days, "Must be over 7 days");           //fix
        if(option == 1) {
            rMod[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{
            rMod[ID].downVote += registeredVoteAmount[msg.sender];
        }
        userLastModVote[msg.sender][ID] = block.timestamp;   
        userLastVoted[msg.sender] = block.timestamp;
    }

    function strikeMod(uint256 ID) external {
        require(rMod[ID].live == true, "Not live");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(block.timestamp > userLastModStriker[msg.sender][ID] + 3 days);           //fix
        userLastModStriker[msg.sender][ID] = block.timestamp;
        lastModStrikeVote[ID] = block.timestamp;
        modStrikes[ID] += registeredVoteAmount[msg.sender];
    }
    
    function resetModStrikes(uint256 ID) external {
        require(rMod[ID].live == true, "Not live");
        require( block.timestamp >= lastModStrikeVote[ID] + 3 days, "Must be 14 days since last mod strike");          //fix
        modStrikes[ID] = 0;
    }    
    
    function activateMod(uint256 ID) external {
        require(rMod[ID].upForVote == true && rMod[ID].upForReplace == false);
        require(block.timestamp > rMod[ID].challengeExpires);
        address mod = rMod[ID].wallet;
        if(rMod[ID].upVote > rMod[ID].downVote){            
            isMod[mod] = true;
            rMod[ID].live = true;
            rMod[ID].upVote = 0;
            rMod[ID].downVote = 0;
            rMod[ID].upForVote = false;
            rMod[ID].timeSubmitted = 0;
            rMod[ID].challengeExpires = 0;
            emit liveMod(ID);
        }
        if(rMod[ID].upVote <= rMod[ID].downVote){
            modID -= 1;                      
            isMod[mod] = false;
            rMod[ID].live = false;
            rMod[ID].upVote = 0;
            rMod[ID].downVote = 0;
            rMod[ID].upForVote = false;
            rMod[ID].timeSubmitted = 0;
            rMod[ID].challengeExpires = 0;
        }
    }

    function removeMod(uint256 ID) external {
        require(rMod[ID].upForVote == true && rMod[ID].upForReplace == true);
        require(block.timestamp > rMod[ID].challengeExpires);
        address mod = rMod[ID].wallet;
        if(rMod[ID].upVote > rMod[ID].downVote){                       
            isMod[mod] = true;
            rMod[ID].live = true;
            rMod[ID].upVote = 0;
            rMod[ID].downVote = 0;
            rMod[ID].upForVote = false;
            rMod[ID].upForReplace = false;
            rMod[ID].timeSubmitted = 0;
            rMod[ID].challengeExpires = 0;
            emit liveMod(ID);
        }
        if(rMod[ID].upVote <= rMod[ID].downVote){
            modID -= 1;
            isMod[mod] = false;
            rMod[ID].live = false;
            rMod[ID].upVote = 0;
            rMod[ID].downVote = 0;
            rMod[ID].upForVote = false;
            rMod[ID].upForReplace = false;
            rMod[ID].timeSubmitted = 0;
            rMod[ID].challengeExpires = 0;
        }
    }

    function payMod(uint256 ID) external {
        require(msg.sender == rMod[ID].wallet);
        require(modFund >= modWeeklyPay, "insufficient funds");
        require(block.timestamp > rMod[ID].lastPay + 1 hours);             //fix
        require(rMod[ID].wallet != address(0));
        rMod[ID].lastPay = block.timestamp;
        modFund -= modWeeklyPay;
        _pushUnderlying(address(this), rMod[ID].wallet, modWeeklyPay);
        emit paidMod(ID, modWeeklyPay);
    }

    function strikeTreasury() external {
        require(tres[0].upForVote == false, "Cannot be open for challenge");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(block.timestamp > userLastStriker[msg.sender] + 3 days);             //fix
        userLastStriker[msg.sender] = block.timestamp;
        treasuryStrikes += registeredVoteAmount[msg.sender];
    }
    
    function resetStrikeTreasury() external {
        require(tres[0].upForVote == false, "Cannot be open for challenge");
        require(block.timestamp >= lastTreasuryStrike + 3 days, "Must be 14 days since last treasury strike");            //fix
        treasuryStrikes = 0;
    }

    function challengeTreasurer(address addy) external {
        require(treasuryStrikes > bdiv(IERC20($BIG).totalSupply(), 10), "Must have 33% concensus to challenge");               //fix
        require(tres[0].upForVote == false, "Cannot have 2 open challenges");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        tres[0].requestedNew = addy;
        tres[0].upForVote = true;
        tres[0].live = true;
        tres[0].timeSubmitted = block.timestamp;
        tres[0].challengeExpires = block.timestamp + voteTime;
    }

    function voteChallengeTreasurer(uint256 option) external {        
        require(tres[0].upForVote == true, "Must be open challenge");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(block.timestamp < tres[0].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastChallenge[msg.sender] + 7 days);
        if(option == 1) {
            tres[0].upVote += registeredVoteAmount[msg.sender];
        }
        else{tres[0].downVote += registeredVoteAmount[msg.sender];
        }
        userLastChallenge[msg.sender] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
    }

    function closeChallengeTreasurer() external {
        require(block.timestamp > tres[0].challengeExpires, "Vote Not Expired");
        require(msg.sender == treasurer || msg.sender == tres[0].requestedNew);
        if(tres[0].upVote > tres[0].downVote){
        treasurer = tres[0].requestedNew;
        emit newTreasurer(tres[0].requestedNew);
        }
        tres[0].requestedNew = address(0);
        tres[0].upForVote = false;
        tres[0].live = false;
        tres[0].timeSubmitted = 0;
        tres[0].challengeExpires = 0;
        treasuryStrikes = 0;
    }

    function requestMarketing(string memory _description, uint256 _cost) external {
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold > 1000000e9, "You must hold over 1M $BIG SHIBA to open request");
        require(marketingInVote <= 50, "10 open max");             //fix
        marketingRequestID += 1;
        require(_cost < marketingFund.sub(marInHold) && _cost <= bdiv(marketingFund, 10), "Over Funds");
        rMar[marketingRequestID].description = _description;
        rMar[marketingRequestID].cost = _cost;
        rMar[marketingRequestID].live = true;
        rMar[marketingRequestID].timeSubmitted = block.timestamp;
        rMar[marketingRequestID].voteExpires = block.timestamp + voteTime;
        rMar[marketingRequestID].requestor = msg.sender;
        emit submitMarketingRequest(_description, _cost, marketingRequestID, msg.sender);
    } 

    function initiateStartMarketingVote(uint256 ID, bool _bool) external {
        require(msg.sender == treasurer || isMod[msg.sender] == true);
        if(_bool == true) {
            uint256 amt = rMar[ID].cost;       
            marInHold += amt;
            rMar[ID].live = _bool;
            marketingInVote += 1;
        }
    }

    function voteForMarketing(uint256 ID, uint256 option) external {
        require(rMar[ID].live == true, "Not live");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(block.timestamp < rMar[ID].voteExpires, "Vote Expired");
        require(block.timestamp > userLastMarVote[msg.sender][ID] + 7 days);
        if(option == 1) {
            rMar[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{rMar[ID].downVote += registeredVoteAmount[msg.sender];
        }
        userLastMarVote[msg.sender][ID] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
    }

    function closeMarketingVote(uint256 ID) external {
        require(msg.sender == treasurer);
        require(block.timestamp > rMar[ID].voteExpires, "Vote Not Expired");
        if(rMar[ID].upVote > rMar[ID].downVote){
        rMar[ID].approved = true;
        _pushUnderlying(address(this), treasurer, rMar[ID].cost);
        marketingFund -= rMar[ID].cost;
        marInHold -= rMar[ID].cost;
        }
        else{
        marInHold -= rMar[ID].cost;
        }      
        marketingInVote -= 1;     
    }

    function requestCEX(string memory _cex, uint256 _cost) external {  
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold > 1000000e9, "You must hold over 1M $BIG SHIBA to open request"); 
        require(_cost < CEXFund.sub(CEXInHold) && _cost < bdiv(CEXFund, 10), "over");
        require(CEXInVote <= 50, "10 open max");                //fix
        CEXID += 1;      
        require(rCEX[CEXID].upForVote == false, "Cannot be open for vote");
        require(rCEX[CEXID].cost == 0);
        rCEX[CEXID].name = _cex;
        rCEX[CEXID].upForVote = true;
        rCEX[CEXID].cost = _cost;
        rCEX[CEXID].live = true;
        rCEX[CEXID].timeSubmitted = block.timestamp;
        rCEX[CEXID].challengeExpires = block.timestamp + voteTime;
        CEXInHold -= _cost;
        emit submitCEX(_cex, _cost);
    }

    function initiateStartCEXVote(uint256 ID, bool _bool) external {
        require(msg.sender == treasurer || isMod[msg.sender] == true);
        if(_bool == true) {
            uint256 amt = rCEX[ID].cost;       
            CEXInHold += amt;
            rDev[ID].live = _bool;
            CEXInVote += 1;
        }
    }

    function voteForCEX(uint256 ID, uint256 option) external {        
        require(rCEX[ID].upForVote == true, "Must be open challenge");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(block.timestamp < rCEX[ID].challengeExpires);
        require(block.timestamp > userLastCEXVote[msg.sender][ID] + 7 days);
        if(option == 1) {
            rCEX[ID].upVote += hold;registeredVoteAmount[msg.sender];
        }
        else{rCEX[ID].downVote += registeredVoteAmount[msg.sender];
        }
        userLastCEXVote[msg.sender][ID] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
    }

    function closeCEXVote(uint256 ID) external {        
        require(block.timestamp > rCEX[ID].challengeExpires, "Vote Not Expired");
        require(msg.sender == treasurer);
        if(rCEX[ID].upVote > rCEX[ID].downVote){
        CEXFund -= rCEX[ID].cost;
        CEXInHold -= rCEX[ID].cost;
        _pushUnderlying(address(this), treasurer, rCEX[ID].cost);
        }
        else{        
        CEXInHold -= rCEX[ID].cost;    
        }
        CEXInVote -= 1;
    }

    function requestDevelopment(string memory _description, uint256 _duration, uint256 _bid) external {
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold > 10000000e9, "You must hold over 10M $BIG SHIBA to open bid");  
        require(_bid < developmentFund.sub(devInHold) && _bid < bdiv(developmentFund, 10), "Over");
        require(developmentInVote <= 50, "10 open max");               //fix
        developmentRequestID += 1;
        rDev[developmentRequestID].description = _description;
        rDev[developmentRequestID].duration = _duration;
        rDev[developmentRequestID].requestor = msg.sender;
        rDev[developmentRequestID].timeSubmitted = block.timestamp;
        rDev[developmentRequestID].voteExpires = block.timestamp + voteTime;
        rDev[developmentRequestID].bid = _bid;
        emit submitDevelopmentRequest(_description, _bid, developmentRequestID, msg.sender);
    }

    function initiateStartDevelopmentVote(uint256 ID, bool _bool) external {
        require(msg.sender == treasurer || isMod[msg.sender] == true);
        if(_bool == true) {
            uint256 amt = rDev[ID].bid;
            devInHold += amt;
            rDev[ID].live = _bool;
            developmentInVote += 1;
        }
    }

    function voteForStartDevelopment(uint256 ID, uint256 option) external {
        require(rDev[ID].live == true, "Vote not live");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(block.timestamp < rDev[ID].voteExpires, "Vote Expired");
        require(block.timestamp > userLastDevVote[msg.sender][ID] + 7 days);
        require(msg.sender != rDev[ID].requestor);
        if(option == 1) {
            rDev[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{rDev[ID].downVote += registeredVoteAmount[msg.sender];
        }        
        userLastDevVote[msg.sender][ID] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
    }

    function setDevelopmentApproval(uint256 ID) external {
        require(rDev[ID].live == true, "Vote not live");
        require(block.timestamp > rDev[ID].voteExpires, "Vote Not Expired");
        require(rDev[ID].upVote > rDev[ID].downVote, "Not passed");
        rDev[ID].approved = true;
        rDev[ID].live = false;
        rDev[ID].upVote = 0;
        rDev[ID].downVote = 0;
    }

    function devSubmitFinalDevelopment(uint256 ID) external {
        require(msg.sender == rDev[ID].requestor);        
        rDev[ID].timeSubmitted = block.timestamp;
        rDev[ID].voteExpires = block.timestamp + voteTime;
        rDev[ID].devSubmitted = true;
    }

    function voteForFinishedDevelopment(uint256 ID, uint256 option) external {
        require(rDev[ID].live == false, "Not able to place vote");
        require(rDev[ID].approved == true, "Not approved development request");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        uint256 hold = IERC20(address(this)).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(block.timestamp > userLastDevFinishVote[msg.sender] + 7 days);
        require(msg.sender != rDev[ID].requestor, "Cannot vote for own development");
        if(option == 1) {
            rDev[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{rDev[ID].downVote += registeredVoteAmount[msg.sender];
        }
        userLastDevFinishVote[msg.sender] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
    }

    function closeDevelopment(uint256 ID) external {
        require(block.timestamp > rDev[ID].voteExpires, "Vote Not Expired");
        require(rDev[ID].approved == true, "Not approved development request");
        require(msg.sender == treasurer);
        if(rDev[ID].upVote > rDev[ID].downVote){
        developmentFund -= rDev[ID].bid;
        devInHold -= rDev[ID].bid;
        rDev[ID].finished = true;
        _pushUnderlying(address(this), rDev[ID].requestor, rDev[ID].bid);
        }
        else{
        devInHold -= rDev[ID].bid;    
        }
        developmentInVote -= 1;
    }

    function giveReward(address addy, uint256 amt) external {
        uint256 timer = block.timestamp + 24 hours;
        require(block.timestamp <= timer, "24 hours must have passed from last reward");
        require(block.timestamp >= userRewardTime[addy], "User can only win once per 7 days");
        require(msg.sender == treasurer);
        require(rewardFund > amt && amt <= 1e18, "Amount must be over funding and under 1 Billion");
        require(userReward[addy] <= 10e18, "10 Billion Max lifetime rewards.");
        rewardID += 1;
        userReward[addy] += amt;
        userRewardTime[addy] = block.timestamp + 7 days;
        rewardFund -= amt;
        _pushUnderlying(address(this), addy, amt);
    }

    function _pullUnderlying(address erc20, address from, uint256 amount)
        internal 
    {    
        bool xfer = IERC20(erc20).transferFrom(from, address(this), amount);
        require(xfer);
    }
    
    function _pushUnderlying(address erc20, address to, uint256 amount)
        internal 
    {   
        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer);
    }
}