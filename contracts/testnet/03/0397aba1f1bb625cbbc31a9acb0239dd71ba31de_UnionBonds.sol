/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ercToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract UnionBonds {
    using SafeMath for uint256;
    using SafeMath for uint8;
    
    ercToken public tokenERC;

    address public owner;

     struct User {
        address sponsor;
        uint256 referralCount;
        uint256 payouts;
        uint256 directBonus; // stats
        uint256 matchBonus;  // stats
        uint256 depositAmount;
        uint256 depositPayouts;
        uint256 totalDirectDeposits;
        uint256 totalPayouts;
        uint256 totalStructures;
        uint256 totalDownlineDeposits;
        uint256 incomeReinvested;
        uint256 checkpoint;
    }

    struct Airdrop {
        uint256 airdrops;
        uint256 airdropSent;
        uint256 airdropSentCount;
        uint256 airdropReceived;
        uint256 airdropReceivedCount;
        uint256 lastAirdrop;
        uint256 lastAirdropReceived;
    }

    struct Union {
        address[] members;
        address owner;
        uint256 id;
        uint256 createTime;
        string name;
        bool isReferralUnion; // first union of sponsor-user is the referral Fee union. all ref users are added automatically
    }

    struct UnionInfo {
        uint256 id;
        bool exists;
    }
    
    mapping(address => User) public users;
    mapping(address => Airdrop) public airdrops;
    mapping(uint256 => Union) public unions;
    mapping(address => uint8) public userUnionsCounter;
    mapping(address => UnionInfo[]) public userUnions;
    mapping(address => UnionInfo) public userReferralFeeUnion;
	mapping(address => uint8) public userCompoundCount;

    uint256 public referralFee = 30;
    uint256 public sustainabilityTax = 100;
    uint256 public airdropTax = 10;
    uint256 public compoundBonus = 30;
    uint256 public userMaxPayout = 3650;
    uint256 public baseYieldPercent = 12;
    uint256 public timeStep = 1 days;
    uint256 public minInvest = 1 * 1e18;  
    uint256 public airdropMin = 1 * 1e17; 
    uint256 public maxWalletDeposit = 50000 ether;
    uint256 public maxCompoundMultiplier = 5;
	uint256 public actionCooldown = 24 * 60 * 60;
    uint256 public maxAccumulation = 48 * 60 * 60;
    uint256 constant public ref_depth = 10;
    uint256 constant public percentageDivider = 1000;

    uint256 public total_users = 1;
    uint256 public totalDeposited;
    uint256 public totalWithdrawn;
    uint256 public totalReinvested;
    uint256 public totalAirdrops;
    uint256 public totalUnionsCreated;

    uint8[] public refBonuses = [4, 4, 4, 4, 4, 2, 2, 2, 2, 2];
    uint8 public maxUnionsPerUser = 6;
    uint8 public mandatoryCompoundCount = 3;
    
    bool public enabled;
    bool public initialized;
    bool public airdropEnabled;
	bool public enableMandatoryCompound;
	bool public enableActionCooldown;

    event Sponsor(address indexed addr, address indexed sponsor);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
	event CompoundedDeposit(address indexed user, uint256 amount);
    event NewAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    function initialize(address erctokenAddress) external{
		require(!initialized);
        require(isContract(erctokenAddress));	
        owner = msg.sender; //owner is marketing wallet
        tokenERC = ercToken(erctokenAddress);
        initialized = true;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    //first investment can only be done by the owner/marketing address.
    function invest(uint256 amount) external {
        _invest(msg.sender, amount);
    }

    //deposit with sponsor
    function invest(address _sponsor, uint256 amount) external {
        if (!enabled) {
			revert("Contract not enabled.");
		}	
		_setSponsor(msg.sender, _sponsor);
        _invest(msg.sender, amount);
    }

    //invest
    function _invest(address _addr, uint256 _amount) private {
        if (!enabled) {
			revert("Contract not enabled.");
		}
        require(users[_addr].sponsor != address(0) || _addr == owner, "No sponsor");
        require(_amount >= minInvest, "Mininum investment not met.");
        require(users[_addr].totalDirectDeposits.add(_amount) <= maxWalletDeposit, "Max deposit limit reached.");

        tokenERC.transferFrom(address(msg.sender), address(this), _amount);

        if(users[_addr].depositAmount == 0 ){
            total_users++;
        }

        // compound before deposit because the checkpoints will reset
        uint256 to_reinvest = this.payoutToReinvest(msg.sender);
        if(to_reinvest > 0 && users[_addr].depositAmount.add(_amount) < this.maxReinvestOf(users[_addr].totalDirectDeposits)){
            to_reinvest = to_reinvest.add(to_reinvest.mul(compoundBonus).div(percentageDivider));
            users[msg.sender].depositAmount += to_reinvest;	
            users[_addr].incomeReinvested += to_reinvest;        
            totalReinvested += to_reinvest;
            emit CompoundedDeposit(msg.sender, to_reinvest);
        }

        // deposit
        uint256 amount = _amount.sub(_amount.mul(sustainabilityTax).div(percentageDivider));
        users[_addr].depositAmount += amount;
        users[_addr].checkpoint = block.timestamp;
        users[_addr].totalDirectDeposits += amount;

        totalDeposited += amount;

        emit NewDeposit(_addr, amount);
        
        if(users[_addr].sponsor != address(0)) {
            //direct referral Fee bonus 3%
            uint256 refBonus = amount.mul(referralFee).div(percentageDivider);

			if(users[users[_addr].sponsor].checkpoint > 0 && users[users[_addr].sponsor].depositAmount < this.maxReinvestOf(users[users[_addr].sponsor].totalDirectDeposits)) {

                if(users[users[_addr].sponsor].depositAmount.add(refBonus) > this.maxReinvestOf(users[users[_addr].sponsor].totalDirectDeposits)){
                    refBonus = this.maxReinvestOf(users[users[_addr].sponsor].totalDirectDeposits).sub(users[users[_addr].sponsor].depositAmount);
                }

                users[users[_addr].sponsor].directBonus += refBonus; //for statistics purposes
                users[users[_addr].sponsor].depositAmount += refBonus; //add refBonus to sponsor user deposit amount
                emit DirectPayout(users[_addr].sponsor, _addr, refBonus);
			}
        }
        
        _downLineDeposits(_addr, amount);

    }

    function checkSponsorValid(address _addr, address _sponsor) external view returns (bool isValid) {	
        if(users[_addr].sponsor == address(0) && _sponsor != _addr && _addr != owner && (users[_sponsor].checkpoint > 0 || _sponsor == owner)) {
            isValid = true;        
        }
    }

    function _setSponsor(address _addr, address _sponsor) private {
        if(this.checkSponsorValid(_addr, _sponsor)) {
            users[_addr].sponsor = _sponsor;
            users[_sponsor].referralCount++;

            if(userReferralFeeUnion[_sponsor].exists == false){
                uint256 unionId = _createUnion(_sponsor, true); // create first union on sponsor-user. this contains the direct referralCount
                userReferralFeeUnion[_sponsor].id = unionId;
                userReferralFeeUnion[_sponsor].exists = true;
            }

            // check if current user is in ref-union
            bool memberExists = false;
            for(uint256 i = 0; i < unions[userReferralFeeUnion[_sponsor].id].members.length; i++){
                if(unions[userReferralFeeUnion[_sponsor].id].members[i] == _addr){
                    memberExists = true;
                }
            }
            if(memberExists == false){
                _addUnionMember(userReferralFeeUnion[_sponsor].id, _addr); // add referral Fee user to sponsor userReferralFeeUnion
            }

            emit Sponsor(_addr, _sponsor);

            for(uint8 i = 0; i < refBonuses.length; i++) {
                if(_sponsor == address(0)) break;

                users[_sponsor].totalStructures++;

                _sponsor = users[_sponsor].sponsor;
            }
        }
    }

    function _downLineDeposits(address _addr, uint256 _amount) private {
      address _sponsor = users[_addr].sponsor;
      for(uint8 i = 0; i < refBonuses.length; i++) {
          if(_sponsor == address(0)) break;
					if(users[_sponsor].checkpoint > 0) {
          users[_sponsor].totalDownlineDeposits = users[_sponsor].totalDownlineDeposits.add(_amount);
					}
          _sponsor = users[_sponsor].sponsor;
      }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].sponsor;

        for(uint8 i = 0; i < ref_depth; i++) {
            if(up == address(0)) break;

            if(users[up].referralCount >= i.add(1) && users[up].depositAmount.add(_amount) < this.maxReinvestOf(users[up].totalDirectDeposits)) {
                if(users[up].checkpoint > block.timestamp.sub(maxAccumulation)){  // 48h accumulation stop
                    uint256 bonus = _amount * refBonuses[i] / 100;
                    if(users[up].checkpoint!= 0) {
                        users[up].depositAmount += bonus; // bonus will be put into sponsor deposit amount.
                        users[up].matchBonus += bonus; //only for statistics
                    }     
                }  
            }

            up = users[up].sponsor;
        }
    }

    function withdraw() external {
        if (!enabled) {
			revert("Contract not enabled.");
		}

		if(enableMandatoryCompound){
            // check if the the user has not reached max compound multiplier of real deposits, if has reached max, user can only claim.
            if(users[msg.sender].depositAmount <= this.maxReinvestOf(users[msg.sender].totalDirectDeposits)){
			    require(userCompoundCount[msg.sender] >= mandatoryCompoundCount, "User is required to compound 3 times before being allowed to withdraw." );
            }
		}

        if(enableActionCooldown){
            if(users[msg.sender].checkpoint.add(actionCooldown) > block.timestamp) revert("Withdrawals can only be done after action cooldown.");
        }
        
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received.");

        //i.e totalDirectDeposits = 1
        // 18.25(maxPayoutCap) = 1 x 5(max compound multiplier) x 3650(max payout) / 1000(percent divider)
        uint256 maxPayoutCap = users[msg.sender].totalDirectDeposits.mul(maxCompoundMultiplier).mul(userMaxPayout).div(percentageDivider);

        require(users[msg.sender].payouts < maxPayoutCap, "Max payout cap reached.");

        if(to_payout > 0) {
            if(users[msg.sender].payouts.add(to_payout) > max_payout) {
                to_payout = max_payout.sub(users[msg.sender].payouts);
            }

            users[msg.sender].depositPayouts += to_payout;
            users[msg.sender].payouts += to_payout;

            _refPayout(msg.sender, to_payout);
        }

        if(users[msg.sender].totalPayouts.add(to_payout) > maxPayoutCap) {
             // only allow the amount up to maxPayoutCap
            to_payout = maxPayoutCap.sub(users[msg.sender].payouts);
        }

        require(to_payout > 0, "User has zero dividends payout.");
        to_payout = this.withdrawalTaxPercentage(to_payout);
        users[msg.sender].totalPayouts += to_payout;
        totalWithdrawn += to_payout;
        users[msg.sender].checkpoint = block.timestamp;
        
        uint256 payout = to_payout.sub(to_payout.mul(sustainabilityTax).div(percentageDivider));
        tokenERC.transfer(msg.sender, payout);
		if(enableMandatoryCompound){
			userCompoundCount[msg.sender] = 0;
		}

        emit Withdraw(msg.sender, payout);

        if(users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts);
        }
    }

    function compound() external {
		if (!enabled) {
			revert("Not started yet");
		}

        if(enableActionCooldown){
            if(users[msg.sender].checkpoint.add(actionCooldown) > block.timestamp) revert("Compounding can only be done after action cooldown.");
        }

        (, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received.");

        uint256 to_reinvest = this.payoutToReinvest(msg.sender);


        require(to_reinvest > 0, "User has zero dividends to compound.");
        to_reinvest = to_reinvest.add(to_reinvest.mul(compoundBonus).div(percentageDivider));
        uint256 finalReinvestAmount = reinvestAmountOf(msg.sender, to_reinvest);

        users[msg.sender].depositAmount += finalReinvestAmount;
        users[msg.sender].checkpoint = block.timestamp;
        users[msg.sender].incomeReinvested += finalReinvestAmount;          
        
        totalReinvested += finalReinvestAmount;
        
		if(enableMandatoryCompound){
			
			userCompoundCount[msg.sender]++;
		}

        emit CompoundedDeposit(msg.sender, finalReinvestAmount);

	}

    function reinvestAmountOf(address _addr, uint256 _toBeRolledAmount) view public returns(uint256 reinvestAmount) {
        
        uint256 maxReinvestAmount = this.maxReinvestOf(users[_addr].totalDirectDeposits); 

        reinvestAmount = _toBeRolledAmount; 

        if(users[_addr].depositAmount >= maxReinvestAmount) {
            revert("User exceeded x5 of total deposit to be rolled.");
        }

        if(users[_addr].depositAmount.add(reinvestAmount) >= maxReinvestAmount) {
            reinvestAmount = maxReinvestAmount.sub(users[_addr].depositAmount);
        }        
    }

    function maxReinvestOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(maxCompoundMultiplier);
    }

    function airdrop(address _to,uint256 _amount) external {
        require(airdropEnabled, "Airdrop not Enabled.");

        address _addr = msg.sender;

        require(_amount >= airdropMin, "Mininum airdrop amount not met.");

        tokenERC.transferFrom(address(msg.sender), address(this), _amount);

        if(users[_to].depositAmount.add(_amount) >= this.maxReinvestOf(users[_to].totalDirectDeposits) ){
            revert("User exceeded x5 of total deposit.");
        }
     
        uint256 aidropTax = _amount.mul(airdropTax).div(percentageDivider);
        uint256 payout = _amount.sub(aidropTax);

        require(users[_to].sponsor != address(0), "_to not found");

        //airdrop amount will be put in user deposit amount.
        users[_to].depositAmount += payout;

        airdrops[_addr].airdrops += payout;
        airdrops[_addr].lastAirdrop = block.timestamp;
        airdrops[_addr].airdropSent += payout;
        airdrops[_addr].airdropSentCount = airdrops[_addr].airdropSentCount.add(1);
        airdrops[_to].airdropReceived += payout;
        airdrops[_to].airdropReceivedCount = airdrops[_to].airdropReceivedCount.add(1);
        airdrops[_to].lastAirdropReceived = block.timestamp;

        totalAirdrops += payout;

        emit NewAirdrop(_addr, _to, payout, block.timestamp);
    }

    function unionAirdrop(uint256 unionId, bool excludeOwner,uint256 _amount) external {
        require(airdropEnabled, "Airdrop not Enabled.");
        
        address _addr = msg.sender;
        
        require(_amount >= airdropMin, "Mininum airdrop amount not met.");

        tokenERC.transferFrom(address(msg.sender), address(this), _amount);

        uint256 aidropTax = _amount.mul(airdropTax).div(percentageDivider);
        uint256 payout = _amount.sub(aidropTax);
        
        require(unions[unionId].owner != address(0), "union not found");

        uint256 memberDivider = unions[unionId].members.length;
        if(excludeOwner == true){
            memberDivider--;
        }
        uint256 amountDivided = payout.div(memberDivider);

        for(uint8 i = 0; i < unions[unionId].members.length; i++){

            address _to = address(unions[unionId].members[i]);
            if(excludeOwner == true && _to == unions[unionId].owner){
                continue;
            }

            if(users[_to].depositAmount.add(_amount) >= this.maxReinvestOf(users[_to].totalDirectDeposits) ){
                continue;
            }

            //airdrop amount will be put in user deposit amount.
            users[_to].depositAmount += amountDivided; 
            
            airdrops[_addr].airdrops += amountDivided;
            airdrops[_addr].lastAirdrop = block.timestamp;
            airdrops[_addr].airdropSent += amountDivided;
            airdrops[_addr].airdropSentCount = airdrops[_addr].airdropSentCount.add(1);
            airdrops[_to].airdropReceived += amountDivided;
            airdrops[_to].airdropReceivedCount = airdrops[_to].airdropReceivedCount.add(1);
            airdrops[_to].lastAirdropReceived = block.timestamp;

            emit NewAirdrop(_addr, _to, payout, block.timestamp);
        }

        totalAirdrops += payout;
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {

        max_payout = this.maxPayoutOf(users[_addr].depositAmount);

        if(users[_addr].depositPayouts < max_payout) {

            payout = (users[_addr].depositAmount.mul(baseYieldPercent).div(percentageDivider))
                    .mul(block.timestamp.sub(maxAccumulation))
                    .div(timeStep);

            if(users[_addr].depositPayouts.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].depositPayouts);

            }
        }
    }

    function payoutToReinvest(address _addr) view external returns(uint256 payout) {
        
        uint256 max_payout = this.maxPayoutOf(users[_addr].depositAmount);

        if(users[_addr].depositPayouts < max_payout) {

            payout = (users[_addr].depositAmount.mul(baseYieldPercent).div(percentageDivider))
                    .mul(block.timestamp.sub(maxAccumulation))
                    .div(timeStep);

        }            
    
    }

    function maxPayoutOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(userMaxPayout).div(percentageDivider);
    }

    function withdrawalTaxPercentage(uint256 to_payout) view external returns(uint256 finalPayout) {
      uint256 contractBalance = tokenERC.balanceOf(address(this));
	  //tax increases 5% every +1% of TVL , tax starts at 10%
      if (to_payout < contractBalance.mul(10).div(percentageDivider)) {
          finalPayout = to_payout; 
      }else if(to_payout >= contractBalance.mul(10).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(50).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(20).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(100).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(30).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(150).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(40).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(200).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(50).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(250).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(60).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(300).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(70).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(350).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(80).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(400).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(90).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(450).div(percentageDivider));
      }else if(to_payout >= contractBalance.mul(100).div(percentageDivider)){
          finalPayout = to_payout.sub(to_payout.mul(500).div(percentageDivider)); 
      }
    }

    function _createUnion(address userAddress, bool isReferralUnion) private returns(uint256 unionId){
        uint8 numberOfExistingUnions = userUnionsCounter[userAddress];

        require(numberOfExistingUnions <= maxUnionsPerUser, "Max number of unions reached.");

        unionId = totalUnionsCreated++;
        unions[unionId].id = unionId;
        unions[unionId].createTime = block.timestamp;
        unions[unionId].owner = userAddress;
        unions[unionId].members.push(userAddress);
        unions[unionId].isReferralUnion = isReferralUnion;

        userUnions[userAddress].push(UnionInfo(unionId, true));
        userUnionsCounter[userAddress]++;
    }

    function _addUnionMember(uint256 unionId, address member) private {
        Union storage union = unions[unionId];
        union.members.push(member);

        userUnions[member].push(UnionInfo(unionId, true));
        userUnionsCounter[member]++;
    }

    function userInfo(address _addr) view external returns(address sponsor, uint256 checkpoint, uint256 depositAmount, uint256 payouts, uint256 directBonus, uint256 matchBonus) {
        return (users[_addr].sponsor, users[_addr].checkpoint, users[_addr].depositAmount, users[_addr].payouts, users[_addr].directBonus, users[_addr].matchBonus);
    }

    function userInfo2(address _addr) view external returns(uint256 lastAirdrop, uint8 unions_counter, UnionInfo[] memory member_of_unions, uint8 reinvest_count) {

        return (airdrops[_addr].lastAirdrop, userUnionsCounter[_addr], userUnions[_addr], userCompoundCount[_addr]);
    }

    function userDirectUnionsInfo(address _addr) view external returns(uint256 referralFee_union, bool referralFee_union_exists, uint256 sponsor_union, bool sponsor_union_exists) {
        User memory user = users[_addr];

        return (userReferralFeeUnion[_addr].id, userReferralFeeUnion[_addr].exists, userReferralFeeUnion[user.sponsor].id, userReferralFeeUnion[user.sponsor].exists);
    }

    function unionInfo(uint256 unionId) view external returns(Union memory _union) {
        Union memory union = unions[unionId];
        return (union);
    }

    function userInfoTotals(address _addr) view external returns(uint256 referralCount, uint256 total_deposits, uint256 totalPayouts, uint256 totalStructures,uint256 totalDownlineDeposits, uint256 airdrops_total, uint256 airdropReceived) {
        return (users[_addr].referralCount, users[_addr].totalDirectDeposits, users[_addr].totalPayouts, users[_addr].totalStructures, users[_addr].totalDownlineDeposits, airdrops[_addr].airdrops, airdrops[_addr].airdropReceived);
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _totalDeposited, uint256 _totalWithdrawn, uint256 _totalAirdrops, uint256 current_tvl) {
        return (total_users, totalDeposited, totalWithdrawn, totalAirdrops, tokenERC.balanceOf(address(this)));
    }

    function transferOwnership(address value) external {
        require(msg.sender == owner, "Admin use only");
        owner = value;
    }

    function enableAirdrop(bool value) external{
        require(msg.sender == owner, "Admin use only");
        airdropEnabled = value;
    }  

	function enabledCompoundRequirement(bool value) external{
        require(msg.sender == owner, "Admin use only");
		enableMandatoryCompound = value;																					  
    } 

	function enableActionCooldownRequirement(bool value) external{
        require(msg.sender == owner, "Admin use only");
		enableActionCooldown = value;																					  
    }

    function enableInvestments(bool value) external{
        require(msg.sender == owner, "Admin use only");
		enabled = value;																					  
    }

    function setMaxAccumulation(uint256 value) external{
        require(msg.sender == owner, "Admin use only");
        require(value > 0 || value < 50, "Admin use only");
		maxAccumulation = value * 60 * 60;																					  
    }

    function setMandatoryCompoundCount(uint8 value) external{
        require(msg.sender == owner, "Admin use only");
        require(value <= 7, "Admin use only");
		mandatoryCompoundCount = value;																					  
    }
}