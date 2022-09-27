/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;
// pragma experimental ABIEncoderV2;

contract HaulingChain {

	struct Bet{
		uint256 betId; // id of the bet
		BetStatus betStatus; // status of the bet {Open | Closed | Settled}
		mapping(uint256 => BetterDatum[]) bettersData; // stores bet data
		uint256 correctChoice; // winning team
		uint256 jackpot;
        uint256 minFee;
        uint256 maxFee;
        uint256 minBet;
        uint256 maxBet;
        uint256 roundTimes;
	}

	struct BetterDatum {
		address payable better; // betters address
		uint256 value; // bet value of the better
		uint256 fee; // fee value of the better
	}

	address	payable owner; // store owner address

	mapping(uint256 => Bet) public bets; // store all bet.
	uint256 public lengthBets; // length of bets.
	uint256 public currentId; // current round id.
    uint256 public startTime; // game start time;

// referal page

	struct ExperienceDatum {
	    bool onGoing; // whether round ongoing or not
		uint256 totBet0; // 0: red betted amount
		uint256 totBet1; // 1: blue betted amount
		uint256 revenue; // revenue for round
		uint256 profit; // profit for round
	}

    struct RefererDatum{
        address payable referer;
        uint256 amount;
    }

    mapping(address => mapping(uint256 => ExperienceDatum)) _mapExperience;
    mapping(address => uint256[]) _mapExpRounds;
    mapping(uint256 => RefererDatum[]) _mapReferer;
    mapping(address => address) _mapBetterForRef;
    
// hall of fame page

    struct Hof{
        uint256 totRevenue;
        uint256 totProfit;
    }
    
    address[] _addrPlayers;
    mapping(address => Hof) _mapHofData;
    
	enum BetStatus {Open, Closed, Settled} //enums for different status of the bet
    enum MatchStatus {Pending, Win, Lose, Tie} //enums for different match status of the bet
    uint256 _gst = 2;
    
	// constructor
	constructor() public{
		owner = msg.sender; // set owner
		addBet(8,1,50,1000000000000000,10000000000000000000);
		currentId=0;
	}

	// to restrict access to non admin users
	modifier onlyByOwner{
		require(msg.sender == owner, "Unauthorised Access");
		_;
	}

    function getFirstStartTime() public view returns(uint256){
        return now - now % 86400 + 3600 * _gst;
    }
    
    function getSecondStartTime() public view returns(uint256){
        return now - now % 86400 + 3600 * (_gst + 12);
    }
    
    function getTimestamp() public view returns(uint256){
        return now;
    }

    // to find if the specific id exists
    function getBetId() public view returns(uint256){
        return lengthBets;
    }
    
    function getCurrentPos() public view returns(uint256){
        return currentId;
    }
    
    function addressToString(address _pool) public pure returns (string memory _uintAsString) {
          uint _i = uint256(_pool);
          if (_i == 0) {
              return "0";
          }
          uint j = _i;
          uint len;
          while (j != 0) {
              len++;
              j /= 10;
          }
          bytes memory bstr = new bytes(len);
          uint k = len - 1;
          while (_i != 0) {
              bstr[k--] = byte(uint8(48 + _i % 10));
              _i /= 10;
          }
          return string(bstr);
    }
    
    function integerToString(uint256 _i)  internal pure returns (string memory) {
        if (_i == 0) {
             return "0";
        }
        uint256 j = _i;
        uint256 len;
        
        while (j != 0) {
             len++;
             j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        
        while (_i != 0) {
             bstr[k--] = byte(uint8(48 + _i % 10));
             _i /= 10;
        }
        return string(bstr);
    }
    
    function concatString(string memory str1, string memory str2) internal pure returns(string memory) {
        bytes memory _str1 = bytes(str1);
        bytes memory _str2 = bytes(str2);
        string memory strRes = new string(_str1.length + _str2.length);
        bytes memory _strRes = bytes(strRes);
        
        
        uint256 k = 0; uint256 i=0;
        for (i = 0; i < _str1.length; i++) _strRes[k++] = _str1[i];
        for (i = 0; i < _str2.length; i++) _strRes[k++] = _str2[i];

        return string(_strRes);
    }
    
    function getGeneralInfo(uint256 betId) public view returns(string memory) {
        string memory strRes="";
        strRes = concatString(strRes, integerToString(bets[betId].jackpot));
        strRes = concatString(strRes, "#");
        strRes = concatString(strRes, integerToString(bets[betId].minFee));
        strRes = concatString(strRes, "#");
        strRes = concatString(strRes, integerToString(bets[betId].maxFee));
        strRes = concatString(strRes, "#");
        strRes = concatString(strRes, integerToString(bets[betId].minBet));
        strRes = concatString(strRes, "#");
        strRes = concatString(strRes, integerToString(bets[betId].maxBet));
        strRes = concatString(strRes, "#");
        strRes = concatString(strRes, integerToString(bets[betId].roundTimes));
        return string(strRes);
    }
    
    function convertIntarrayToString(uint256[] memory arr) public pure returns(string memory){
        string memory strRes="";
        for(uint256 i=0;i<arr.length; i++){
            strRes = concatString(strRes, integerToString(arr[i]));
            if(i<arr.length-1) strRes = concatString(strRes, "#");
        }
        return string(strRes);
    }

    // to get the specific bet status
    function getBetStatus(uint256 betId) public view returns(uint256) {
        require(betId < lengthBets, "overflow bet length");
        uint256 res = 100;
        if(bets[betId].betStatus == BetStatus.Open) res = 10;
        else if (bets[betId].betStatus == BetStatus.Closed) res = 20;
        else res = 30;
        return res;
    }

	// to find if the current user is admin
	function isOwner() public view returns(bool) {
		if(msg.sender == owner) {
			return true;
		} else {
			return false;
		}
	}
    
    // get owner
    function getOwner() public view returns(address) {
        return owner;
    }
    
    // find the round id with open status
    function findOpenedId() public view returns(uint256) {
        uint256 i;
        for(i=0;i<lengthBets;i++){
            if(bets[i].betStatus==BetStatus.Open)break;
        }
        return i;
    }
    
	// adds a bet without setting any values
	function addNewEmptyBet() public {
		Bet memory bet;
		bets[lengthBets] = bet;
	}
	
	// to add bet
	function addBet(uint256 roundTimes, uint256 minFee, uint256 maxFee, 
	                uint256 minBet, uint256 maxBet) public onlyByOwner {
		require(maxFee > minFee && minFee > 0, "Error Fee");
		require(maxBet > minBet && minBet > 0, "Error Bet");
		require(roundTimes >= 6, "too small round times(round times >= 6).");
		addNewEmptyBet();
		Bet storage bet = bets[lengthBets];
		bet.betId = lengthBets; //set id
		bet.betStatus = BetStatus.Open; // set status
		bet.minFee = minFee;
		bet.maxFee = maxFee;
		bet.minBet = minBet;
		bet.maxBet = maxBet;
		bet.roundTimes = roundTimes;
		lengthBets += 1;
	}

    // set the jackpot money of admin to contract
    function setJackpot(uint256 betId, uint256 jackpot) public payable onlyByOwner {
		require(jackpot > 0, "Error Jackpot");
		bets[betId].jackpot = jackpot;
    }

	// get total betting value for a given bet and a given team
	function getTotalBetData(uint256 betId, uint256 optionId) public view returns(uint256) {
		uint256 totalBetValue = 0;
		for(uint256 i=0; i<bets[betId].bettersData[optionId].length; i++) {
			totalBetValue += bets[betId].bettersData[optionId][i].value;
		}
		return totalBetValue;
	}

	// get total fee value for a given bet and a given team
	function getTotalFeeData(uint256 betId, uint256 optionId) public view returns(uint256) {
		uint256 totalFeeValue = 0;
		for(uint256 i=0; i<bets[betId].bettersData[optionId].length; i++) {
			totalFeeValue += bets[betId].bettersData[optionId][i].fee;
		}
		return totalFeeValue;
	}

    function getCryptoExperiences(address payable player) public view returns(string memory) {
        string memory strRes="";
        uint len = _mapExpRounds[player].length;
        for(uint i=0; i<len; i++){
            uint round = _mapExpRounds[player][i];
            strRes = concatString(strRes, integerToString(round));
            strRes = concatString(strRes, "#");
            strRes = (_mapExperience[player][round].onGoing == true)? concatString(strRes, "true#") : concatString(strRes, "false#");
            strRes = concatString(strRes, integerToString(_mapExperience[player][round].totBet0));
            strRes = concatString(strRes, "#");
            strRes = concatString(strRes, integerToString(_mapExperience[player][round].totBet1));
            strRes = concatString(strRes, "#");
            strRes = concatString(strRes, integerToString(_mapExperience[player][round].revenue));
            strRes = concatString(strRes, "#");
            strRes = concatString(strRes, integerToString(_mapExperience[player][round].profit));
            if(i<len-1) strRes = concatString(strRes, "@");
        }
        return string(strRes);
    }

    function getReferalEarnings(uint256 betId) public view returns(string memory){
        string memory strRes="";
        uint len = _mapReferer[betId].length;
        for(uint i=0; i<len; i++){
            strRes = concatString(strRes, addressToString(_mapReferer[betId][i].referer));
            strRes = concatString(strRes, "#");
            strRes = concatString(strRes, integerToString(_mapReferer[betId][i].amount));
            if(i<len-1) strRes = concatString(strRes, "@");
        }
        return string(strRes);
    }
    
    function getHallOfFame() public view returns(string memory){
        string memory strRes="";
        uint len = _addrPlayers.length;
        for(uint i=0; i<len; i++){
            strRes = concatString(strRes, addressToString(_addrPlayers[i]));
            strRes = concatString(strRes, "#");
            strRes = concatString(strRes, integerToString(_mapHofData[_addrPlayers[i]].totRevenue));
            strRes = concatString(strRes, "#");
            strRes = concatString(strRes, integerToString(_mapHofData[_addrPlayers[i]].totProfit));
            if(i<len-1) strRes = concatString(strRes, "@");
        }
        return string(strRes);
    }
    
    function addExpRounds(address payable sender, uint round) public{
        uint len = _mapExpRounds[sender].length;
        uint i;
        for(i=0; i<len; i++){
            if(round == _mapExpRounds[sender][i]) break;
        }
        if(i==len)_mapExpRounds[sender].push(round);
    }
    
    function addAddress(address payable sender) public{
        uint len = _addrPlayers.length;
        uint i;
        for(i=0; i<len; i++){
            if(sender == _addrPlayers[i]) break;
        }
        if(i == len)_addrPlayers.push(sender);
    }
    
    address payable owner2 = 0xb0527453dB6FFF587873f758c1683406c26ed799;
 	function bet(uint256 betId, uint256 optionId, address payable referer) payable public {
 	    require( msg.sender!=address(0) ,"Zero address error");
	   // uint256 zero = now - now % 86400;
        uint256 st1 = getFirstStartTime();
        uint256 st2 = getSecondStartTime();
        require(bets[betId].roundTimes > 0, "round times is zero");
        uint256 period = bets[betId].roundTimes * 3600;
        uint256 current = getTimestamp();
	    uint256 cst = 0;
        if(current >= st1 && current <= st1 + period) {
            cst = st1;
        } else if(current >= st2 && current <= st2 + period) {
            cst = st2;
        }
	    require(cst > 0, "time error!!");
	    require(bets[betId].betStatus==BetStatus.Open, "Completed match");
	    uint256 betValue = msg.value;
	    require(betValue >= bets[betId].minBet && betValue <= bets[betId].maxBet, "bet Input Error");
	    require(current - startTime >= 0 && current - cst < period, "flowed time error");
	    uint256 totAmount = getTotalBetData(betId, optionId);
	    uint256 feeValue = (totAmount==0)? betValue*(1+49*(current-cst)/period)/100 : totAmount*(1+49*(current-cst)/period)/100;
	    require(betValue > feeValue , "too_small_than_fee");
	    betValue -= feeValue;
	    if(referer != address(0)) {
	        feeValue = feeValue * 70 / 100;
            _mapReferer[betId].push(RefererDatum(referer, feeValue * 30 / 100));
            _mapBetterForRef[referer] = msg.sender;
	    }
		bets[betId].bettersData[optionId].push(BetterDatum(msg.sender, betValue, feeValue));

        addAddress(msg.sender);
        addExpRounds(msg.sender, betId);
        
        ExperienceDatum memory expData = _mapExperience[msg.sender][betId];
        expData.onGoing = true;
        expData.totBet0 += (optionId == 0)? betValue : 0;
        expData.totBet1 += (optionId == 1)? betValue : 0;
        _mapExperience[msg.sender][betId] = expData;
	}
	
	// decide the match at the end of round.
	function decideMatch(uint256 betId) public view returns (uint256) {
	    uint redTot = getTotalBetData(betId, 0);
	    uint greenTot = getTotalBetData(betId, 1);
	    if (redTot > greenTot) return 0;
	    else if(greenTot > redTot) return 1;
	    else return 2;
	}
	
	// close a bet before the toss
	function closeBet(uint256 betId) public onlyByOwner {
		bets[betId].betStatus = BetStatus.Closed;
	}

	// start the payout process after the winner is known
	function payout(uint256 betId) public onlyByOwner {
		bets[betId].betStatus = BetStatus.Closed;
		bets[betId].correctChoice = decideMatch(betId);
		if(bets[betId].betStatus == BetStatus.Closed) {
			uint256 correctChoice = decideMatch(betId);
		    if(correctChoice < 2) {
    			uint256 totWinBet = getTotalBetData(betId, correctChoice);
    			uint256 failId = (correctChoice + uint256(1)) % uint256(2);
    			uint256 totFailBet = getTotalBetData(betId, failId);

    			require(owner!=address(0),"Error Owner");
    			if(totFailBet==0){
    			    owner.transfer(bets[betId].jackpot);
            		for(uint256 i=0; i<bets[betId].bettersData[correctChoice].length; i++) {
            			address payable better = bets[betId].bettersData[correctChoice][i].better;
            			uint256 betValue = bets[betId].bettersData[correctChoice][i].value + 
                        			                bets[betId].bettersData[correctChoice][i].fee;
            			better.transfer(betValue);
            		}
                } else {
                    totFailBet += bets[betId].jackpot;
        			owner.transfer(getTotalFeeData(betId, 0));
        			owner.transfer(getTotalFeeData(betId, 1));
        			for(uint i=0; i<_mapReferer[betId].length; i++){
        			    RefererDatum memory info = _mapReferer[betId][i];
        			    info.referer.transfer(info.amount);
        			}
        			for(uint256 i=0; i<bets[betId].bettersData[correctChoice].length; i++) {
        				address payable better = bets[betId].bettersData[correctChoice][i].better;
        				uint256 betValue = bets[betId].bettersData[correctChoice][i].value;
        				uint256 feeValue = bets[betId].bettersData[correctChoice][i].fee;
        				uint256 earn = totFailBet * (betValue / totWinBet);
        				betValue += earn;
        				
        				_mapExperience[better][betId].onGoing = false;
        				_mapExperience[better][betId].revenue += earn + feeValue;
        				_mapExperience[better][betId].profit += earn;
        				
        				_mapHofData[better].totRevenue += earn + feeValue;
        				_mapHofData[better].totProfit += earn;
        				
        				// require(address(this).balance > 0, "second block: balance is zero or small than zero");
        				if(address(this).balance > 0) better.transfer(betValue);
        			}
        			if(address(this).balance > 0) owner.transfer(address(this).balance);
                }
		    } else {
		        owner.transfer(bets[betId].jackpot);
    			for(uint256 i=0; i<bets[betId].bettersData[0].length; i++) {
    				address payable better = bets[betId].bettersData[0][i].better;
    				uint256 betValue = bets[betId].bettersData[0][i].value;
    				uint256 betFee = bets[betId].bettersData[0][i].fee;
    				// require(address(this).balance > 0, "third block: balance is zero or small than zero");
    				if(address(this).balance > 0) better.transfer(betValue + betFee);
    			}
		    }
		}
	}

	// get ethers held by the contact
	function getBalance() public view returns(uint256) {
		return address(this).balance;
	}
}