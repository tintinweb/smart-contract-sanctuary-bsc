/**
 *Submitted for verification at BscScan.com on 2022-04-07
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

interface tresCont {
    function generateMarketingClaim(uint256 claim, uint256 amt) external;
    function generateCEXClaim(uint256 claim, uint256 amt) external;
}

contract yuma is Context, Rmath {
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
    
    struct burnVote {
        uint256 burnAmt;
        bool live;
        uint256 upVote;
        uint256 downVote;
        uint256 timeSubmitted;
        uint256 challengeExpires;
    }

    struct reflectionVote {
        uint256 refAmt;
        bool live;
        uint256 upVote;
        uint256 downVote;
        uint256 timeSubmitted;
        uint256 challengeExpires;
    }

    mapping (uint256 => Development) public rDev;
    mapping (uint256 => Marketing) public rMar;
    mapping (uint256 => Treasury) public tres;
    mapping (uint256  => CEX) public rCEX;
    mapping (uint256 => Mods) public rMod;
    mapping (uint256 => burnVote) public bVote;
    mapping (uint256 => reflectionVote) public rVote;
    mapping (address => uint256) public userReward;
    mapping (address => uint256) public userRewardTime;
    mapping (address => uint256) public userLastChallenge;  
    mapping (address => mapping (uint256 => uint256)) public userLastCEXVote;   
    mapping (address => mapping (uint256 => uint256)) public userLastDevVote;   
    mapping (address => uint256) public userLastDevFinishVote;
    mapping (address => mapping (uint256 => uint256)) public userLastMarVote;
    mapping (address => mapping (uint256 => uint256)) public userLastModVote;
    mapping (address => mapping (uint256 => uint256)) public userLastBurnVote;
    mapping (address => mapping (uint256 => uint256)) public userLastRefVote;
    mapping (uint256 => uint256) public lastModStrikeVote;
    mapping (address => mapping (uint256 => uint256)) private userLastModStriker;
    mapping (address => uint256) private userLastStriker;
    mapping (address => uint256) public userLastVoted;
    mapping (uint256 => uint256) public modStrikes;
    mapping (address => uint256) private registeredVoteAmount;
    mapping (address => bool) public isMod;
    mapping (address => uint256) public userTotalVotes;
    uint256 public lastTreasuryStrike;
    address public $BIG = 0xEce5D9B94081827423C3b8409C5f262A7875e152;
    address public treasurer;
    uint256 public treasuryStrikes = 0;
    uint256 public voteTime = 30 minutes;
    uint256 public developmentRequestID = 0;
    uint256 public marketingRequestID = 0;
    uint256 public marketingInVote = 0;
    uint256 public rewardID = 0;
    uint256 private developmentShare = 20;
    uint256 public developmentInVote = 0;
    uint256 public developmentFund = 200000000000000000000000000000000;
    uint256 public devInHold = 0;
    uint256 private marketingShare = 15;
    uint256 public marketingFund = 150000000000000000000000000000000;
    uint256 public marInHold = 0;
    uint256 public modID = 0;
    uint256 private modShare = 5;
    uint256 public modFund = 50000000000000000000000000000000;
    uint256 public liveMods = 0;
    uint256 private CEXShare = 5;
    uint256 public CEXFund = 50000000000000000000000000000000;
    uint256 public CEXInHold = 0;
    uint256 public CEXInVote = 0;
    uint256 public CEXID = 0;
    uint256 private rewardShare = 5; 
    uint256 public lastReward;
    uint256 private testTokens = 500000000000000000000000000000;
    uint256 public rewardFund = 50000000000000000000000000000000;
    uint256 public registeredVoters = 0;
    uint256 public registeredVotes = 0;
    uint256 public totalVoteCasted = 0;
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
    event updateBurn(uint256 amt);
    event updateReflection(uint256 amt);

    constructor() {
        isMod[msg.sender] = true;
    }

    function setTreasury(address addy) external {
        require(treasurer == address(0));
        treasurer = addy;
    }

    function claimTestTokensandRegisterVote() external {
        testTokens -= 5000000000e18;
        _pushUnderlying($BIG, msg.sender, 5000000000e18);
        registerVoting(4000000000e18);
    }

    function activateBurnVote(uint256 amt) external {
        require(isMod[msg.sender] == true);
        bVote[0].live = true;
        bVote[0].burnAmt = amt;
        bVote[0].timeSubmitted = block.timestamp;
        bVote[0].challengeExpires = block.timestamp + voteTime;
        BIG($BIG).boostKarma(msg.sender);
    }

    function voteChangeBurn(uint256 option) external {
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(bVote[0].live == true, "Not live");
        require(block.timestamp < bVote[0].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastBurnVote[msg.sender][0] + 1 days, "7 days"); //fix
        if(option == 1) {
            bVote[0].upVote += registeredVoteAmount[msg.sender];
        }
        else{
            bVote[0].downVote += registeredVoteAmount[msg.sender];
        }
        userLastVoted[msg.sender] = block.timestamp;
        userLastBurnVote[msg.sender][0] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function closeBurnVote() external {
        require(block.timestamp > bVote[0].challengeExpires, "Not expired");
        require(bVote[0].live == true);
        if(bVote[0].upVote > bVote[0].downVote){ 
            uint256 amt = bVote[0].burnAmt;
            BIG($BIG).setBurn(amt);
            emit updateBurn(amt);
        }        
        bVote[0].burnAmt = 0;
        bVote[0].upVote = 0;
        bVote[0].downVote = 0;
        bVote[0].timeSubmitted = 0;        
        bVote[0].live = false;
        bVote[0].challengeExpires = 0;
    }

    function activateReflectionVote(uint256 amt) external {
        require(isMod[msg.sender] == true);
        rVote[0].live = true;
        rVote[0].refAmt = amt;
        rVote[0].timeSubmitted = block.timestamp;
        rVote[0].challengeExpires = block.timestamp + voteTime;
    }

    function voteChangeReflection(uint256 option) external {
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(rVote[0].live == true);
        require(block.timestamp < rVote[0].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastRefVote[msg.sender][0] + 1 days, "7 days");  //fix
        if(option == 1) {
            rVote[0].upVote += registeredVoteAmount[msg.sender];
        }
        else{
            rVote[0].downVote += registeredVoteAmount[msg.sender];
        }
        userLastVoted[msg.sender] = block.timestamp;
        userLastRefVote[msg.sender][0] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function closeReflectionVote() external {
        require(block.timestamp > bVote[0].challengeExpires, "Not expired");
        require(rVote[0].live == true);
        if(rVote[0].upVote > rVote[0].downVote){ 
            uint256 amt = rVote[0].refAmt;
            BIG($BIG).setReflection(amt);
            emit updateReflection(amt);
        }

        rVote[0].upVote = 0;
        rVote[0].downVote = 0;
        rVote[0].timeSubmitted = 0;
        rVote[0].refAmt = 0;
        rVote[0].live = false;
        rVote[0].challengeExpires = 0;
    }

    function userRegisteredVoteAmount(address user) external view returns(uint256) {
        return registeredVoteAmount[user];
    }

    function updateFunds() external { // gives reflections in contract to development
        uint256 bal = IERC20($BIG).balanceOf(address(this));
        uint256 hold = marketingFund + marInHold + modFund + rewardFund + CEXFund + CEXInHold + testTokens;
        uint256 tot = bsub(bal, hold);
        uint256 share = bdiv(tot, 5);
        developmentFund += share;
        marketingFund += share;
        modFund += share;
        rewardFund += share;
        CEXFund += share;
    }
    
    function registerVoting(uint256 amount) public {       
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        uint256 tot = registeredVoteAmount[msg.sender];
        require(hold >= amount + tot, "You must hold over amount");
        if(isVoter(msg.sender) == true){
        registeredVoteAmount[msg.sender] = tot + amount;  
        registeredVotes += amount;  
        }
        else{
        registeredVoteAmount[msg.sender] += amount;
        registeredVoters += 1;
        registeredVotes += amount;
        }
    }

    function unRegisterVoting() external {       
        require(isVoter(msg.sender) == true, "Not registered");
        require(block.timestamp >= userLastVoted[msg.sender] + 4 hours, "Voted within 4 hours"); // FIX
        uint256 amt = registeredVoteAmount[msg.sender];
        registeredVoteAmount[msg.sender] = 0;
        registeredVoters -= 1;
        registeredVotes -= amt;
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
        require(msg.sender == treasurer && isMod[_wallet] == false);
        modID += 1;
        rMod[modID].telegramHandle = _handle;
        rMod[modID].wallet = _wallet;
        rMod[modID].upForVote = true;
        rMod[modID].timeSubmitted = block.timestamp;
        rMod[modID].challengeExpires = block.timestamp + voteTime;
        emit appointMod(_handle, _wallet);
    }    

    function voteModLive(uint256 ID, uint256 option) external {
        require(rMod[ID].upForVote == true, "Not up for vote");
        require(msg.sender != rMod[ID].wallet);
        require(registeredVoteAmount[msg.sender] > 0);
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(block.timestamp < rMod[ID].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastModVote[msg.sender][ID] + 7 days, "7 days");
        if(option == 1) {
            rMod[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{
            rMod[ID].downVote += registeredVoteAmount[msg.sender];
        } 
        userLastModVote[msg.sender][ID] = block.timestamp;   
        userLastVoted[msg.sender] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function toggleVoteModReplace(uint256 ID) external {        
        require(rMod[ID].live == true && rMod[ID].upForReplace == false, "Not live");
        require(modStrikes[ID] >= 10000000000000000000000000000, "Insufficient strikes");    //fix  bdiv(IERC20($BIG).totalSupply(), 5)
        rMod[ID].upForReplace = true;
        rMod[ID].timeSubmitted = block.timestamp;
        rMod[ID].challengeExpires = block.timestamp + voteTime;
    }

    function voteModReplace(uint256 ID, uint256 option) external {   
        require(rMod[ID].live == true && rMod[ID].upForReplace == true, "Not live");
        require(registeredVoteAmount[msg.sender] > 0, "You must hold over amount");
        require(option == 1 || option == 2, "1 for keep, 2 for remove");
        require(block.timestamp < rMod[ID].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastModVote[msg.sender][ID] + 1 days, "7 days");           //fix
        if(option == 1) {
            rMod[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{
            rMod[ID].downVote += registeredVoteAmount[msg.sender];
        }
        userLastModVote[msg.sender][ID] = block.timestamp;   
        userLastVoted[msg.sender] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function modStepDown(uint256 ID) external {
        require(isMod[msg.sender] == true);
        require(rMod[ID].wallet == msg.sender, "Only mod can step down");
        liveMods -= 1;
        rMod[ID].live = false;
        modStrikes[ID] = 0;
        isMod[msg.sender] = false;
    }

    function strikeMod(uint256 ID) external {
        require(rMod[ID].live == true, "Not live");
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(block.timestamp > userLastModStriker[msg.sender][ID] + 1 days);           //fix
        userLastModStriker[msg.sender][ID] = block.timestamp;
        lastModStrikeVote[ID] = block.timestamp;
        modStrikes[ID] += registeredVoteAmount[msg.sender];
        totalVoteCasted += 1;
    }
    
    function resetModStrikes(uint256 ID) external {
        require(rMod[ID].live == true, "Not live");
        require(isMod[msg.sender] == true, "Only mod");
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
            rMod[ID].timeSubmitted = 0;
            rMod[ID].challengeExpires = 0;
            liveMods += 1;
            require(liveMods <= 40, "Only 40 live mods");
            emit liveMod(ID);
        }
        if(rMod[ID].upVote <= rMod[ID].downVote){
            modID -= 1;                      
            isMod[mod] = false;
            rMod[ID].live = false;
            rMod[ID].upForVote = false;
            rMod[ID].timeSubmitted = 0;
            rMod[ID].challengeExpires = 0;
        }        
            rMod[ID].upVote = 0;
            rMod[ID].downVote = 0;
    }

    function removeMod(uint256 ID) external {
        require(rMod[ID].upForVote == true && rMod[ID].upForReplace == true);
        require(block.timestamp > rMod[ID].challengeExpires);
        address mod = rMod[ID].wallet;
        if(rMod[ID].upVote > rMod[ID].downVote){                       
            isMod[mod] = true;
            rMod[ID].live = true;
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
            rMod[ID].upForVote = false;
            rMod[ID].upForReplace = false;
            rMod[ID].timeSubmitted = 0;
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
        require(modFund >= give, "insufficient funds");
        require(block.timestamp > rMod[ID].lastPay + 1 hours);             //fix
        rMod[ID].lastPay = block.timestamp;
        modFund -= give;
        _pushUnderlying($BIG, rMod[ID].wallet, give);
        emit paidMod(ID, give);
    }

    function strikeTreasury() external {
        require(tres[0].upForVote == false, "Cannot be open for challenge");
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        require(hold >= registeredVoteAmount[msg.sender], "You must hold over amount");
        require(block.timestamp > userLastStriker[msg.sender] + 1 days);             //fix
        userLastStriker[msg.sender] = block.timestamp;
        treasuryStrikes += registeredVoteAmount[msg.sender];
        totalVoteCasted += 1;
    }
    
    function resetStrikeTreasury() external {
        require(tres[0].upForVote == false, "Cannot be open for challenge");
        require(block.timestamp >= lastTreasuryStrike + 1 days, "Must be 14 days since last treasury strike");            //fix
        treasuryStrikes = 0;
    }

    function challengeTreasurer(address addy) external {
        require(treasuryStrikes > 10000000000000000000000000000 , "Must have 33% concensus to challenge");               //fix  bdiv(IERC20($BIG).totalSupply(), 5)
        require(tres[0].upForVote == false, "Cannot have 2 open challenges");
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
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
        require(registeredVoteAmount[msg.sender] > 0, "You must hold over amount");
        require(block.timestamp < tres[0].challengeExpires, "Vote Expired");
        require(block.timestamp > userLastChallenge[msg.sender] + 7 days, "7 days");
        if(option == 1) {
            tres[0].upVote += registeredVoteAmount[msg.sender];
        }
        else{tres[0].downVote += registeredVoteAmount[msg.sender];
        }
        userLastChallenge[msg.sender] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function closeChallengeTreasurer() external {
        require(block.timestamp > tres[0].challengeExpires, "Vote Not Expired");
        require(msg.sender == tres[0].requestedNew);
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
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        require(hold > 1000000000000000, "You must hold over 1M $BIG SHIBA to open request");
        require(BIG($BIG).Karma(msg.sender) > 0, "No karma");
        require(marketingInVote <= 50, "10 open max");             //fix
        marketingRequestID += 1;
        require(_cost < marketingFund.sub(marInHold) && _cost <= bdiv(marketingFund, 10), "Over Funds");
        rMar[marketingRequestID].description = _description;
        rMar[marketingRequestID].cost = _cost;
        rMar[marketingRequestID].timeSubmitted = block.timestamp;
        rMar[marketingRequestID].requestor = msg.sender;
        emit submitMarketingRequest(_description, _cost, marketingRequestID, msg.sender);
    } 

    function initiateStartMarketingVote(uint256 ID, bool _bool, uint256 _voteTime) external {
        require(isMod[msg.sender] == true && rMar[ID].live == false);
        if(_bool == true) {
            uint256 amt = rMar[ID].cost;       
            marInHold += amt;
            rMar[ID].live = _bool;
            rMar[ID].voteExpires = block.timestamp + _voteTime;
            marketingInVote += 1;
        }
        BIG($BIG).boostKarma(msg.sender);
    }

    function voteForMarketing(uint256 ID, uint256 option) external {
        require(rMar[ID].live == true, "Not live");
        require(registeredVoteAmount[msg.sender] > 0, "You must hold over amount");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(block.timestamp < rMar[ID].voteExpires, "Vote Expired");
        require(block.timestamp > userLastMarVote[msg.sender][ID] + 7 days, "7 days");
        if(option == 1) {
            rMar[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{rMar[ID].downVote += registeredVoteAmount[msg.sender];
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

    function requestCEX(string memory _cex, uint256 _cost) external {  
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        require(hold > 1000000000000000, "You must hold over 1M $BIG SHIBA to open request"); 
        require(_cost < CEXFund.sub(CEXInHold) && _cost < bdiv(CEXFund, 10), "over");
        require(BIG($BIG).Karma(msg.sender) > 0, "No karma");
        require(CEXInVote <= 50, "10 open max");                //fix
        CEXID += 1;      
        require(rCEX[CEXID].cost == 0);
        rCEX[CEXID].name = _cex;
        rCEX[CEXID].timeSubmitted = block.timestamp;
        rCEX[CEXID].cost = _cost;
        emit submitCEX(_cex, _cost);
    }

    function initiateStartCEXVote(uint256 ID, bool _bool, uint256 _voteTime) external {
        require(isMod[msg.sender] == true && rCEX[ID].live == false);
        require(rCEX[CEXID].upForVote == false);
        if(_bool == true) {
            uint256 amt = rCEX[ID].cost;       
            CEXInHold += amt;
            rDev[ID].live = _bool;            
            rCEX[CEXID].upForVote = true;
            rCEX[CEXID].challengeExpires = block.timestamp + _voteTime;
            CEXInVote += 1;
        }
        BIG($BIG).boostKarma(msg.sender);
    }

    function voteForCEX(uint256 ID, uint256 option) external {        
        require(rCEX[ID].upForVote == true, "Must be open challenge");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(registeredVoteAmount[msg.sender] > 0);
        require(block.timestamp < rCEX[ID].challengeExpires);
        require(block.timestamp > userLastCEXVote[msg.sender][ID] + 7 days);
        if(option == 1) {
            rCEX[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{rCEX[ID].downVote += registeredVoteAmount[msg.sender];
        }
        userLastCEXVote[msg.sender][ID] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function closeCEXVote(uint256 ID) external {        
        require(block.timestamp > rCEX[ID].challengeExpires, "Vote Not Expired");
        require(isMod[msg.sender] == true && rCEX[ID].live == true);
        if(rCEX[ID].upVote > rCEX[ID].downVote){
        CEXFund -= rCEX[ID].cost;
        CEXInHold -= rCEX[ID].cost;
        _pushUnderlying($BIG, treasurer, rCEX[ID].cost);        
        tresCont(treasurer).generateCEXClaim(ID, rCEX[ID].cost);
        }
        else{        
        CEXInHold -= rCEX[ID].cost;    
        }
        CEXInVote -= 1;
        rCEX[ID].live = false;
        rCEX[ID].upForVote = false;
    }

    function requestDevelopment(string memory _description, uint256 _duration, uint256 _bid) external {
        uint256 hold = IERC20($BIG).balanceOf(msg.sender);
        require(hold > 10000000000000000, "You must hold over 10M $BIG SHIBA to open bid");  
        require(_bid < developmentFund.sub(devInHold) && _bid < bdiv(developmentFund, 10));
        require(BIG($BIG).Karma(msg.sender) > 0, "No karma");
        require(developmentInVote <= 50, "10 open max");               //fix
        developmentRequestID += 1;
        rDev[developmentRequestID].description = _description;
        rDev[developmentRequestID].duration = _duration;
        rDev[developmentRequestID].requestor = msg.sender;
        rDev[developmentRequestID].bid = _bid;
        emit submitDevelopmentRequest(_description, _bid, developmentRequestID, msg.sender);
    }

    function initiateStartDevelopmentVote(uint256 ID, bool _bool, uint256 _voteTime) external {
        require(isMod[msg.sender] == true && rDev[ID].finished == false && rDev[ID].live == false);
        if(_bool == true) {
            uint256 amt = rDev[ID].bid;
            devInHold += amt;
            rDev[ID].live = _bool;
            rDev[developmentRequestID].timeSubmitted = block.timestamp;
            rDev[developmentRequestID].voteExpires = block.timestamp + _voteTime;
            developmentInVote += 1;
        }
        BIG($BIG).boostKarma(msg.sender);
    }

    function voteForStartDevelopment(uint256 ID, uint256 option) external {
        require(rDev[ID].live == true, "Vote not live");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(registeredVoteAmount[msg.sender] > 0, "Amount");
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
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function setDevelopmentApproval(uint256 ID) external {
        require(rDev[ID].live == true, "Vote not live");
        require(block.timestamp > rDev[ID].voteExpires);
        if(rDev[ID].upVote > rDev[ID].downVote) {
        rDev[ID].approved = true;
        }
        else{
        devInHold -= rDev[ID].bid;
        developmentInVote -= 1;  
        rDev[ID].finished = true;  
        }
        rDev[ID].live = false;
        rDev[ID].upVote = 0;
        rDev[ID].downVote = 0;
    }

    function devSubmitFinalDevelopment(uint256 ID) external {
        require(msg.sender == rDev[ID].requestor && rDev[ID].approved == true && rDev[ID].finished == false);        
        rDev[ID].timeSubmitted = block.timestamp;
        rDev[ID].voteExpires = block.timestamp + voteTime;
        rDev[ID].devSubmitted = true;
    }

    function voteForFinishedDevelopment(uint256 ID, uint256 option) external {
        require(rDev[ID].live == false, "Not able to place vote");
        require(rDev[ID].approved == true && rDev[ID].devSubmitted == true, "Not approved development request");
        require(option == 1 || option == 2, "1 for upVote, 2 for downVote");
        require(registeredVoteAmount[msg.sender] > 0, "You must hold over amount");
        require(block.timestamp > userLastDevFinishVote[msg.sender] + 7 days, "7 days");
        require(msg.sender != rDev[ID].requestor);
        if(option == 1) {
            rDev[ID].upVote += registeredVoteAmount[msg.sender];
        }
        else{rDev[ID].downVote += registeredVoteAmount[msg.sender];
        }
        userLastDevFinishVote[msg.sender] = block.timestamp;
        userLastVoted[msg.sender] = block.timestamp;
        totalVoteCasted += 1;
        userTotalVotes[msg.sender] += 1;
    }

    function closeDevelopment(uint256 ID) external {
        require(block.timestamp > rDev[ID].voteExpires);
        require(rDev[ID].approved == true && rDev[ID].devSubmitted == true);
        require(isMod[msg.sender] == true && rDev[ID].finished == false);
        if(rDev[ID].upVote > rDev[ID].downVote){
        developmentFund -= rDev[ID].bid;
        devInHold -= rDev[ID].bid;
        _pushUnderlying($BIG, rDev[ID].requestor, rDev[ID].bid);
        }
        else{
        devInHold -= rDev[ID].bid;    
        }
        developmentInVote -= 1;
        rDev[ID].live = false;
        rDev[ID].finished = true;
    }

    function giveReward(address addy) external {
        uint256 timer = lastReward + 1 hours;
        uint256 amt = BIG($BIG).getRewardAmount();
        uint256 karma = BIG($BIG).Karma(addy);
        if(karma >= 15) {
            karma = 15;
        }
        if(karma == 0) {
            karma = 1;
        }
        uint256 gift = bmul(amt, bdiv(karma, 10));
        require(block.timestamp >= timer, "1 hours must have passed from last reward");
        require(block.timestamp >= userRewardTime[addy], "User can only win once per 7 days");
        require(isMod[msg.sender] == true);
        //require(addy != msg.sender);
        //require(userReward[addy] <= 5e17, "500 Million Max lifetime rewards.");
        lastReward = block.timestamp;
        rewardID += 1;
        userReward[addy] += gift;
        userRewardTime[addy] = block.timestamp + 7 days;
        rewardFund -= gift;
        _pushUnderlying($BIG, addy, gift);
        
    }

    function _pushUnderlying(address erc20, address to, uint256 amount)
        internal 
    {   
        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer);
    }
}