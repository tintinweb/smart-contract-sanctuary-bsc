/**
 100% Decentalize Smart Contract For Vara Gold Community
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.5.10;
import "./VaraUniversal.sol";

contract VaraGoldMain  is VaraGoldUniversal {

    function _Joining(uint256 amount,address referrer,uint side) public {
        require(amount == joiningAmount,'Insufficient Joining Amount !');
        require(_UserAffiliateDetails[msg.sender].selfInvestment == 0,'Already Registered !');
        require(_UserAffiliateDetails[msg.sender].userId == 0,'Already Registered !');
        UserAffiliateDetails storage userAffiliateDetails = _UserAffiliateDetails[msg.sender];
        userAffiliateDetails.selfInvestment += amount;
        userAffiliateDetails.selfSide = side;
        userAffiliateDetails.isIncomeBlocked = false;
        _UserBusinessDetails[msg.sender].isBoosterApplicable = false;
        _UserBusinessDetails[msg.sender].isEligibleForMatching = false;
        userAffiliateDetails.joiningDateTime = block.timestamp; 
        //Manage Referral Systeh Start Here
        if (userAffiliateDetails.sponsor == address(0) && (_UserAffiliateDetails[referrer].userId > 0 || referrer == contractOwner) && referrer != msg.sender ) {
            userAffiliateDetails.sponsor = referrer;
            _UserAffiliateDetails[referrer].noofDirect +=1;
            if(side==1){
              _UserAffiliateDetails[referrer].noofDirectLeft +=1;
            }
            else if(side==2){ 
              _UserAffiliateDetails[referrer].noofDirectRight +=1;
            }
            if(_UserAffiliateDetails[referrer].noofDirectLeft>=binaryEligibilityLeftRequire && _UserAffiliateDetails[referrer].noofDirectRight<=binaryEligibilityRightRequire){
                _UserBusinessDetails[referrer].isEligibleForMatching=true;
                matchingIncomeQualifier.push(referrer);
            }
            uint noofDays=view_DiffTwoDateInternal(_UserAffiliateDetails[referrer].joiningDateTime,block.timestamp);
            if(noofDays<=noofDaysForBooster){
                if(_UserBusinessDetails[referrer].isEligibleForMatching && _UserAffiliateDetails[referrer].noofDirect>=noofDirectforBooster){
                   _UserBusinessDetails[referrer].isBoosterApplicable=true;
                }
            }
        }   	
        require(userAffiliateDetails.sponsor != address(0) || msg.sender == contractOwner, "No upline");
        if (userAffiliateDetails.sponsor != address(0)) {	   
        //Level Wise Business & Id Count
        address upline = userAffiliateDetails.sponsor;
        for (uint i = 0; i < ref_bonuses.length; i++) {
            if (upline != address(0)) {
                _UserBusinessDetails[upline].levelWiseBusiness[i] += amount;
                if(userAffiliateDetails.userId == 0){
                    _UserBusinessDetails[upline].refs[i] += 1;
                }
                upline = _UserAffiliateDetails[upline].sponsor;
            } 
            else break;
        }
      }
      if(userAffiliateDetails.userId == 0) {
        userAffiliateDetails.userId = block.timestamp;
        UserWalletDetails storage userWalletDetails = _UserWalletDetails[userAffiliateDetails.userId];
        userWalletDetails.UserWalletAddress=msg.sender;
      }
      //Manage Referral System End Here
      //Referral Income Distribution
	    _refPayout(msg.sender);
      //Level Income Distribution
	    _levelPayout(msg.sender);
      //Binary Placement
      _PlaceInMatchingTree(msg.sender,referrer,side,amount);
      //Placement In Ring
      ringcontract.placeInRing(msg.sender);
      nativetoken.transferFrom(msg.sender, address(this), amount);
      emit Joining(msg.sender,amount,referrer,side);
   }

   function _Withdrawal(uint256 amount) public {  
      uint256 rewardRing=ringcontract.getRingBous(msg.sender);
      _UserIncomeDetails[msg.sender].totalRingBonus += rewardRing;
      _UserIncomeDetails[msg.sender].totalBonus += rewardRing;
      _UserIncomeDetails[msg.sender].creditedWallet += rewardRing;
      _UserIncomeDetails[msg.sender].availableWallet += rewardRing;
      ringcontract.updateRingBous(msg.sender);
      uint256 AvailableWallet = _UserIncomeDetails[msg.sender].availableWallet;
      require(AvailableWallet >= amount,'Insufficient Fund For Withdrawal !');
      require(amount >= minimumWithdrawal,'You Must Enter Minimum Withdrawal Amount !');
      require(AvailableWallet >= minimumWithdrawal,'You Must Have Minimum Withdrawal Amount !');
      uint256 adminCharge=0;
      if(amount>=tierFromWithdrawal[0] && amount<=tierToWithdrawal[0]){
        adminCharge=tierAdminCharge[0];
      }
      else if(amount>=tierFromWithdrawal[1] && amount<=tierToWithdrawal[1]) {
        adminCharge=tierAdminCharge[1];
      }
      else if(amount>= tierFromWithdrawal[2]){
        adminCharge=tierAdminCharge[2];
      }
      uint256 _fees = (amount*adminCharge)/100;
      uint256 actualAmountToSend = (amount-_fees);
      adminChargeCollected += _fees;
      _UserIncomeDetails[msg.sender].usedWallet += amount;
      _UserIncomeDetails[msg.sender].availableWallet -= amount; 
      nativetoken.transfer(msg.sender, actualAmountToSend);   
      emit Withdrawn(msg.sender,amount);
    }

    function _InternalTransfer(uint256 userId,uint256 amount) public {  
       uint256 rewardRing=ringcontract.getRingBous(msg.sender);
      _UserIncomeDetails[msg.sender].totalRingBonus += rewardRing;
      _UserIncomeDetails[msg.sender].totalBonus += rewardRing;
      _UserIncomeDetails[msg.sender].creditedWallet += rewardRing;
      _UserIncomeDetails[msg.sender].availableWallet += rewardRing;
      ringcontract.updateRingBous(msg.sender);
      uint256 AvailableWallet = _UserIncomeDetails[msg.sender].availableWallet;
      require(AvailableWallet >= amount,'Insufficient Fund For Transfer !');
      require(amount >= minimumTransfer,'You Must Enter Minimum Transfer Amount !');
      require(AvailableWallet >= minimumTransfer,'You Must Have Minimum Transfer Amount !');
      //Update Sender Wallet Details Here
      _UserIncomeDetails[msg.sender].usedWallet += amount;
      _UserIncomeDetails[msg.sender].totalTransfered += amount;
      _UserIncomeDetails[msg.sender].availableWallet -= amount;    
      //Update Receiver Wallet Details Here
      address walletAddress = _UserWalletDetails[userId].UserWalletAddress;
      _UserIncomeDetails[walletAddress].creditedWallet += amount;
      _UserIncomeDetails[walletAddress].totalReceived += amount;
      _UserIncomeDetails[walletAddress].availableWallet += amount; 
      emit InternalTransfer(msg.sender,userId,amount);
    }

    function _PlaceInMatchingTree(address user,address referrer,uint side,uint256 amount) internal {
        if(side==1){ _PlaceInLeft(user,referrer,amount);}
        else if(side==2){ _PlaceInRight(user,referrer,amount);}
    }

    function _PlaceInLeft(address user,address referrer,uint256 amount) internal {
        address left=_UserAffiliateDetails[referrer].left;
        address parent=left;
        while(true){
        if (left != address(0)) {
            parent=left;
            _UserBusinessDetails[parent].currentleftbusiness += amount;
            left=_UserAffiliateDetails[left].left;
        } 
        else break;
        }
        _UserAffiliateDetails[user].parent=parent;
        _UserAffiliateDetails[parent].left=user;
    }

    function _PlaceInRight(address user,address referrer,uint256 amount) internal {
        address right=_UserAffiliateDetails[referrer].right;
        address parent=right;
        while(true){
        if (right != address(0)) {
            parent=right;
            _UserBusinessDetails[parent].currentrightbusiness += amount;
            right=_UserAffiliateDetails[right].right;
        } 
        else break;
        }
        _UserAffiliateDetails[user].parent=parent;
        _UserAffiliateDetails[parent].right=user;
    }
}