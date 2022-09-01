/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

pragma solidity ^0.8.6;

interface I{
	function transfer(address to, uint value) external returns(bool);
	function balanceOf(address) external view returns(uint);
	function genesisBlock() external view returns(uint);
	function deposits(address a) external view returns(uint);
	function sold() external view returns(uint);
}

contract Treasury {
	address private _governance;
	address private _aggregator;
	address private _letToken;
	address private _foundingEvent;
	address private _staking;
	uint public totalPosterRewards;
	uint public totalFounderRewards;
	uint public totalAirdrops;
	uint public totBenEmission;
	uint public baseRate;
	uint public posterRate;
	address public otcMarket;

	struct Beneficiary {
		uint128 amount;
		uint128 emission;
		uint lastClaim;
	}

	struct Poster {
		uint128 amount;
		uint128 lastClaim;
		uint128 cumulative;
		uint128 unapprovedAmount;
		uint reserved;
	}

	struct AirdropRecepient {
		uint128 amount;
		uint128 lastClaim;
		uint reserved;
	}

	struct Founder {
		uint128 amount;
		uint128 lastClaim;
		bool registered;
		uint reserved;
	}

	mapping (address => Beneficiary) public bens;
	mapping (address => Poster) public posters;
	mapping (address => AirdropRecepient) public airdrops;
	mapping (address => Founder) public founders;

	function init() public {
		require(msg.sender==0xc22eFB5258648D016EC7Db1cF75411f6B3421AEc);
		posterRate=1000;
		baseRate = 95e13;
		_governance=0xB23b6201D1799b0E8e209a402daaEFaC78c356Dc;
		_letToken=0x74404135DE39FABB87493c389D0Ca55665520d9A;
		_foundingEvent=0x6a0c5131fC600009cf2dfC3b5f67901767563d79;
		_staking=0x0800b0f6C3b6A08776EAA067a62C34adaB491513;
	}

	function setGov(address a)external{
		require(msg.sender==_governance);
		_governance=a;
	}

	function setAggregator(address a)external{
		require(msg.sender==_governance);
		_aggregator=a;
	}

	function _getRate() internal view returns(uint){
		return baseRate;
	}

	function setPosterRate(uint rate)external{
		require(msg.sender==_governance&&rate<=2000&&rate>=500);
		posterRate = rate;
	}

	function setRate(uint rate)external{
		require(msg.sender==_governance&&rate<baseRate&&rate>47e13);
		baseRate = rate;
	}

// ADD
	function addBen(address a, uint amount, uint emission) public {
		require(msg.sender == _governance&&amount>bens[a].amount&&emission>=bens[a].emission);
		bens[a].lastClaim = uint64(block.number);
		bens[a].amount = uint128(amount);
		bens[a].emission = uint128(emission);
		totBenEmission+=emission;
		require(totBenEmission<=1e22);
	}

	function addAirdropBulk(address[] memory r,uint[] memory amounts) external {
		require(msg.sender == _governance);
		for(uint i = 0;i<r.length;i++) {
			uint prevA = airdrops[r[i]].amount;
			airdrops[r[i]].amount += uint128(amounts[i]);
			if(prevA==0&&airdrops[r[i]].amount>0){
				totalAirdrops+=1;
			}
			airdrops[r[i]].lastClaim=uint128(block.number);
		}
	}

	function distributeGas(address[] memory r, uint Le18) external payable {
		require(address(this).balance>r.length);// bnb specific ratio
		uint toTransfer = address(this).balance/r.length-1000;
		for(uint i = 0;i<r.length;i++) {
			if(posters[r[i]].cumulative >= Le18*1e18){
				posters[r[i]].cumulative = 0;
				payable(r[i]).transfer(toTransfer);
			}
		}
	}

	function addPosters(address[] memory r, uint[] memory amounts) external{
		require(msg.sender == _aggregator);
		for(uint i = 0;i<r.length;i++) {
			posters[r[i]].unapprovedAmount += uint128(amounts[i]);
		}
	}

	function editUnapprovedPosters(address[] memory r, uint[] memory amounts) external{
		require(msg.sender == _governance);
		for(uint i = 0;i<r.length;i++) {
			posters[r[i]].unapprovedAmount = uint128(amounts[i]);
		}
	}

	function approvePosters(address[] memory r) external{
		require(msg.sender == _governance);
		for(uint i = 0;i<r.length;i++) {
			uint prevA = posters[r[i]].amount;
			if(prevA>100e18){
				claimPosterRewardsFor(r[i]);
			}
			uint128 amount = posters[r[i]].unapprovedAmount;
			posters[r[i]].amount += amount;
			posters[r[i]].unapprovedAmount = 0;
			posters[r[i]].cumulative += amount;
			totalPosterRewards+=amount;
			if(posters[r[i]].lastClaim==0){
				posters[r[i]].lastClaim=uint128(block.number);
			}
		}
	}

// CLAIM
	function getRewards(address a,uint amount) external{
		require(msg.sender == _staking);
		I(_letToken).transfer(a,amount);//token
	}

	function claimBenRewards() external returns(uint){
		uint lastClaim = bens[msg.sender].lastClaim;
		require(block.number>lastClaim);
		uint rate = _getRate();
		rate = rate*bens[msg.sender].emission/1e22;
		uint toClaim = (block.number - lastClaim)*rate;
		if(toClaim>bens[msg.sender].amount){
			toClaim=bens[msg.sender].amount;
		}
		if(toClaim>I(_letToken).balanceOf(address(this))){//this check was supposed to be added on protocol upgrade, emission was so slow, that it could not possibly trigger overflow
			toClaim=I(_letToken).balanceOf(address(this));
		}
		bens[msg.sender].lastClaim = uint64(block.number);
		bens[msg.sender].amount -= uint128(toClaim);
		I(_letToken).transfer(msg.sender, toClaim);
		return toClaim;
	}

   	function claimAirdrop()external {
   		_claimAirdrop(msg.sender);
   	}

	function claimAirdropFor(address a) public {
		_claimAirdrop(a);
	}

	function _claimAirdrop(address a) private {
		require(airdrops[a].amount>0&&I(_foundingEvent).genesisBlock()!=0&&block.number>airdrops[a].lastClaim);
		uint toClaim = airdropAvailable(a);
		airdrops[a].lastClaim=uint128(block.number);
		airdrops[a].amount -= uint128(toClaim);
		if(airdrops[a].amount==0){
			totalAirdrops-=1;
			delete airdrops[a];
		}
		I(_letToken).transfer(a, toClaim);
    }

    function airdropAvailable(address a) public view returns(uint) {
    	uint airdrop = airdrops[a].amount;
    	if(airdrop>0){
    		uint reserved = airdrops[a].reserved;
    		uint rate =_getRate()/totalAirdrops;
			if(rate>20e13){rate=20e13;}
			uint amount = (block.number-airdrops[a].lastClaim)*rate;
			if(amount>airdrop-reserved){ amount=airdrop-reserved; }
			uint treasuryBalance = I(_letToken).balanceOf(address(this));
			if(amount>treasuryBalance){	amount=treasuryBalance; }
			return amount;
    	} else {
    		return 0;
    	}
    }

   	function claimPosterRewards()external {
   		_claimPosterRewards(msg.sender);
   	}

	function claimPosterRewardsFor(address a) public {
		_claimPosterRewards(a);
	}

	function _claimPosterRewards(address a) private {
		require(posters[a].amount>0&&block.number>posters[a].lastClaim);
		uint toClaim = posterRewardsAvailable(a);
		posters[a].lastClaim=uint128(block.number);
		posters[a].amount-=uint128(toClaim);
		uint treasuryBalance = I(_letToken).balanceOf(address(this));
		if(totalPosterRewards>=toClaim)	{totalPosterRewards-=toClaim;} else {totalPosterRewards=0;}
		uint toClaimInitial = toClaim;
		uint airdrop = airdrops[a].amount;
		if(airdrop>=toClaim){
			if(toClaim*2<=treasuryBalance){
				airdrops[a].amount-=uint128(toClaim); toClaim*=2;
			}
		} else {
			if(airdrop>0){
				if(toClaim+airdrop<=treasuryBalance){
					toClaim+=airdrop; delete airdrops[a]; totalAirdrops-=1;
				}
			}
		}
		uint founder = founders[a].amount;
		if(founder>=toClaimInitial){
			if(toClaimInitial+toClaim<=treasuryBalance){
				founders[a].amount-=uint128(toClaimInitial); toClaim+=toClaimInitial;
				totalFounderRewards-=toClaimInitial;
			}
		} else {
			if(founder>0){
				if(toClaim+founder<=treasuryBalance){
					toClaim+=founder; founders[a].amount=0; totalFounderRewards-=founder;
				}
			}
		}
		I(_letToken).transfer(a, toClaim);
		if(posters[a].amount==0){
			posters[a].lastClaim=0;
		}
	}

    function posterRewardsAvailable(address a) public view returns(uint){
    	uint posterAmount = posters[a].amount;
		if(posterAmount>0){
			uint reserved = posters[a].reserved;
			uint rate =_getRate()*posterAmount/totalPosterRewards*posterRate/1000;
			uint amount = (block.number-posters[a].lastClaim)*rate;
			if (amount>posterAmount-reserved){amount=posterAmount-reserved;}
			uint treasuryBalance = I(_letToken).balanceOf(address(this));
			if(amount>treasuryBalance){amount=treasuryBalance;}
			return amount;
		} else {
			return 0;
		}
    }

   	function claimFounderRewards()external {
   		_claimFounderRewards(msg.sender);
   	}

	function claimFounderRewardsFor(address a) public {
		_claimFounderRewards(a);
	}

	function _claimFounderRewards(address a) private {
		uint genesis = uint128(I(_foundingEvent).genesisBlock());
		if(founders[a].registered==false&&genesis!=0){
			uint deposit = I(_foundingEvent).deposits(a);
			if(deposit>0){
				founders[a].amount=uint128(deposit);
				founders[a].lastClaim=uint128(genesis);
				founders[a].registered=true;
				if(totalFounderRewards==0){
					totalFounderRewards = I(_foundingEvent).sold();
				}
			}
		}
		require(founders[a].amount>0&&block.number>founders[a].lastClaim);
		uint toClaim = founderRewardsAvailable(a);
		founders[a].lastClaim=uint128(block.number);
		founders[a].amount -= uint128(toClaim);
		if(totalFounderRewards>=toClaim) {totalFounderRewards-=toClaim;} else {totalFounderRewards=0;}
		I(_letToken).transfer(a, toClaim);
    }

    function founderRewardsAvailable(address a) public view returns(uint){
    	if(founders[a].registered==true){
    		uint foundersAmount = founders[a].amount;
			if(foundersAmount>0){
				uint reserved = founders[a].reserved;
				uint rate =_getRate()*5*foundersAmount/totalFounderRewards;
				uint amount = (block.number-founders[a].lastClaim)*rate;
				if (amount>foundersAmount-reserved){amount=foundersAmount-reserved;}
				uint treasuryBalance = I(_letToken).balanceOf(address(this));
				if(amount>treasuryBalance){
					amount=treasuryBalance;
				}
				return amount;
			} else {
				return 0;
			}
    	} else {
			uint amount = I(_foundingEvent).deposits(a);
    		return amount;
    	}
    }

    function otcReassignment(address from, address to, uint amount, uint t) public {
    	require(msg.sender==otcMarket);
    	if(t==0){
    		founders[from].reserved -= amount;
    		founders[from].amount -= uint128(amount);
    		founders[to].amount += uint128(amount);
    		founders[to].lastClaim = uint128(block.number);
    		if(!founders[to].registered){
    			founders[to].registered=true;
    		}
    	} else if(t==1){
    		posters[from].reserved -= amount;
    		posters[from].amount -= uint128(amount);
    		posters[to].amount += uint128(amount);
    		posters[to].lastClaim = uint128(block.number);
    	} else {
    		airdrops[from].reserved -= amount;
    		airdrops[from].amount -= uint128(amount);
    		airdrops[to].amount += uint128(amount);
    		airdrops[to].lastClaim = uint128(block.number);
    	}
    }

    function reserveForOTC(address a, uint amount, uint t) public {
    	require(msg.sender==otcMarket);
    	if(t==0){
    		require(founders[a].amount>amount);
    		founders[a].reserved += amount;
    	} else if(t==1){
    		require(posters[a].amount>amount);
    		posters[a].reserved += amount;
    	} else {
    		require(airdrops[a].amount>amount);
    		airdrops[a].reserved += amount;
    	}
    }

    function withdrawFromOTC(address a, uint amount, uint t) public {
    	require(msg.sender==otcMarket);
    	if(t==0){
    		founders[a].reserved -= amount;
    	} else if(t==1){
    		posters[a].reserved -= amount;
    	} else {
    		airdrops[a].reserved -= amount;
    	}
    }
}