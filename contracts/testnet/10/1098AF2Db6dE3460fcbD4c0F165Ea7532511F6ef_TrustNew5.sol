// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBEP20Token
{
    function mintTokens(address receipient, uint tokenAmount) external returns(bool);
    function transfer(address _to, uint _value) external returns (bool success);
    function balanceOf(address user) external view returns(uint);
    function totalSupply() external view returns (uint);
    function maxsupply() external view returns (uint);
    function repurches(address _from, address _to, uint _value) external returns(bool);
    function burn_internal(uint _value, address _to) external returns (bool);
}


contract TrustNew5{

    IBEP20Token public rewardToken;
    AggregatorV3Interface internal priceFeed;
     using SafeMath for uint;

      struct Deposit {
		uint amount;
		uint start;
        uint withdrawn;
	}

    struct User{
         Deposit[] deposits;
         address referrer;
         uint totalDeposit;
         uint[10] refs;
         uint totalWithdrawn;
         uint ref_bonus;
         uint totalBonus;
         bool isActiveForRoi;
         uint checkpoint;
         uint roi_direct_withdrwan;
         uint passiveRoi_checkpoint;
         uint[10] refStageBusiness;
         uint256[10] refStageBonus;
         uint roiIncomeUser;
    }

    uint roi_user;//2%
    uint roi_direct;//1%
    uint percentDivider;//1000
    uint ref_level_bonus;//2%
    uint public tokenPrice;//1$
    uint timeStamp ;
    address payable public ownerWallet;
    bool IsInitinalized;
    uint public totalUser;
    uint[5] package;
    address payable public supportWallet;
    
    mapping(address => User) public users;
    mapping (address => mapping(uint => address)) public direct_ref;

    bool private sellStarted;
    uint private maxToken;
    uint private buyTokens;
    



    function initialize(address payable _ownerWallet ,address payable _supportWallet) public {
        require(IsInitinalized==false,"You can use it only one time");
            ownerWallet = _ownerWallet;
            supportWallet = _supportWallet;
            roi_user = 20;
            roi_direct = 10;
            percentDivider = 1000;
            ref_level_bonus = 20;
            tokenPrice = 1e8;
            timeStamp = 1 days;
            package = [25*1e8,100*1e8,500*1e8,1000*1e8,2000*1e8];
            IsInitinalized = true;
    }

    function initinalizeRewardToken(IBEP20Token _rewardtoken) public {
        require(supportWallet == msg.sender,"permision Denied");
        rewardToken = _rewardtoken;

    }

    function updateTokenPrice(uint _usdAmount) public {
      require(ownerWallet == msg.sender,"permision Denied");
        tokenPrice = _usdAmount;
    }

    function invest(address _referrer, uint _index) payable public {
        uint256 userTokenBalance =  rewardToken.balanceOf(msg.sender);
        require(_index < package.length,"you select wrong package");
        uint _token = (package[_index].div(tokenPrice))*1e8;
        require(userTokenBalance >= _token, 'Low fund!');
        User storage user = users[msg.sender];
        require((users[_referrer].deposits.length > 0 && _referrer != msg.sender) || ownerWallet == msg.sender,  "No upline found");
         
        if (user.referrer == address(0) && ownerWallet != msg.sender) {
			user.referrer = _referrer;
        }
        address upline = user.referrer;
          for(uint i=0; i<10; i++){
             if (upline != address(0)){
                if(user.deposits.length == 0 ){
                    users[upline].refs[i] += 1; 
                }
                users[upline].refStageBusiness[i] = users[upline].refStageBusiness[i].add(_token);
                uint bonus = _token.mul(ref_level_bonus).div(percentDivider);
                users[upline].refStageBonus[i] = users[upline].refStageBonus[i].add(bonus);
                users[upline].ref_bonus += bonus;
             }else break; 
                 upline = users[upline].referrer;
          }

        if(user.referrer != address(0) && user.deposits.length == 0 ){
            direct_ref[user.referrer][users[user.referrer].refs[0]-1] = msg.sender;
        }

        if(user.deposits.length == 0){
            totalUser++;
            user.isActiveForRoi = true ;
            user.checkpoint = block.timestamp; 
            user.passiveRoi_checkpoint = block.timestamp;
        }


        user.totalDeposit += _token;
        rewardToken.burn_internal(_token,msg.sender);
        user.deposits.push(Deposit(_token, block.timestamp,0));
         
    }

    function maxPayoutOf(address _userAddress) view external returns(uint) {
		User storage user = users[_userAddress];
		uint maxPayof_amount;
		for (uint i = 0; i < user.deposits.length; i++) {
			maxPayof_amount = maxPayof_amount.add(user.deposits[i].amount);
		}
        return maxPayof_amount.mul(3);
    }

   

    function getUserDividends(address _userAddress) public view returns (uint) {
		User storage user = users[_userAddress];
		uint totalDividends;
		uint dividends;


		if(user.isActiveForRoi){
			for (uint i = 0; i < user.deposits.length; i++) {
					if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(3)) {

						if (user.deposits[i].start > user.checkpoint) {

							dividends = (user.deposits[i].amount.mul(roi_user).div(percentDivider))
								.mul(block.timestamp.sub(user.deposits[i].start))
								.div(timeStamp);

						} else {

							dividends = (user.deposits[i].amount.mul(roi_user).div(percentDivider))
								.mul(block.timestamp.sub(user.checkpoint))
								.div(timeStamp);

						}

						if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(3)) {
							dividends = (user.deposits[i].amount.mul(3)).sub(user.deposits[i].withdrawn);
						}

						totalDividends = totalDividends.add(dividends);

					}
				
			}
		}

		return totalDividends;
	}

    function getUserDividendsByindex(address _userAddress, uint i) public view returns (uint) {
		User storage user = users[_userAddress];
		uint dividends;
        uint totalDividends;
		if(user.isActiveForRoi){
				if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(3)) {

						if (user.deposits[i].start > user.checkpoint) {

							dividends = (user.deposits[i].amount.mul(roi_user).div(percentDivider))
								.mul(block.timestamp.sub(user.deposits[i].start))
								.div(timeStamp);

						} else {

							dividends = (user.deposits[i].amount.mul(roi_user).div(percentDivider))
								.mul(block.timestamp.sub(user.checkpoint))
								.div(timeStamp);

						}

						if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(3)) {
							dividends = (user.deposits[i].amount.mul(3)).sub(user.deposits[i].withdrawn);
						}

						totalDividends = totalDividends.add(dividends);

				}
		}
		
		return dividends;
	}

   function getUserDirectDividends(address _userAddress) public view returns (uint) {
		User storage user = users[_userAddress];
        uint totalDividends;
		uint dividends;
        uint totalDepositDirect = getDirectTotalDeposit(_userAddress);
		if(user.isActiveForRoi){
					if (user.roi_direct_withdrwan < totalDepositDirect) {

							dividends = (totalDepositDirect.mul(roi_direct).div(percentDivider))
								.mul(block.timestamp.sub(user.passiveRoi_checkpoint))
								.div(timeStamp);
					}

                    if (user.roi_direct_withdrwan.add(dividends) > totalDepositDirect) {
                        dividends = totalDepositDirect.sub(user.roi_direct_withdrwan);                  
			        }
                         totalDividends = totalDividends.add(dividends);
        }
            return totalDividends;
	}

    function getDirectTotalDeposit(address _userAddress) internal view returns(uint){
        uint deposit_directs;
        uint _directsTotalDeposit;
            for(uint j = 0 ; j < users[_userAddress].refs[0]; j++){
                address directUser = direct_ref[_userAddress][j];
                deposit_directs = users[directUser].totalDeposit;
               _directsTotalDeposit = _directsTotalDeposit.add(deposit_directs);
         }
         return _directsTotalDeposit;
    }

    function withdraw()  public {
        User storage user = users[msg.sender];
        uint userRoiIncome = getUserDividends(msg.sender);
        uint userRoiPassive = getUserDirectDividends(msg.sender);
        uint totalWithdrawAmount;
        uint bonus;

        if(user.ref_bonus > 0){
           bonus = user.ref_bonus;
           user.totalBonus += bonus;
           user.ref_bonus = 0;
           totalWithdrawAmount = totalWithdrawAmount.add(bonus);
        }
    
          if(userRoiIncome > 0){
            user.roiIncomeUser = user.roiIncomeUser.add(userRoiIncome);
            for(uint i=0; i<user.deposits.length;i++){
                 uint amount =  getUserDividendsByindex(msg.sender, i);
                 user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(amount);
                 totalWithdrawAmount = totalWithdrawAmount.add(amount);
            }
        }
          if(userRoiPassive > 0){
                totalWithdrawAmount = totalWithdrawAmount.add(userRoiPassive);
                user.passiveRoi_checkpoint = block.timestamp;
                user.roi_direct_withdrwan = user.roi_direct_withdrwan.add(userRoiPassive);
          }
             
             user.totalWithdrawn = user.totalWithdrawn.add(totalWithdrawAmount);
             rewardToken.mintTokens(msg.sender,totalWithdrawAmount);
             user.checkpoint = block.timestamp;
         
    }

   
   
       function getDepositInfo(address _useraddress , uint _index) public view returns(uint _amount,uint _withdrawn,uint _start){
        return(
            _amount = users[_useraddress].deposits[_index].amount,
            _withdrawn = users[_useraddress].deposits[_index].withdrawn,
            _start = users[_useraddress].deposits[_index].start
        );
    }

    function getUserRef(address _useraddress , uint _index) public view returns(uint _refcount, uint _refStageBusiness,uint _refStageBonus) {
        User storage user = users[_useraddress];
        return(
            _refcount = user.refs[_index],
            _refStageBusiness = user.refStageBusiness[_index],
            _refStageBonus = user.refStageBonus[_index]  
        );
    }


    function sellToken(uint _token) public {
        if (sellStarted == false){
            require(msg.sender == ownerWallet);
            rewardToken.repurches(msg.sender, address(this),_token );
            maxToken = maxToken.add(_token);
            sellStarted = true;
        }else if(sellStarted == true){
            require(_token <= maxToken, "Limit of token sold is 2000");       
                require(_token <= buyTokens,"Limit is exceed");
                rewardToken.repurches(msg.sender, address(this),_token );
                buyTokens = buyTokens.sub(_token);              
                uint bnbAmount =  calculateBnbReceived(_token); 
                payable(msg.sender).transfer(bnbAmount);                     
        }else{
            revert("You Don't have permission");
        }
    }

    function buyToken() payable public {
        uint _token = calculateTokensReceived(msg.value);
        require(_token <= maxToken.sub(buyTokens),"Limit is exceed");
        buyTokens = buyTokens.add(_token);
        rewardToken.repurches(address(this),msg.sender ,_token );
        
    }

    function updatePriceFeed() public {
        require(supportWallet == msg.sender,"Permission denied");
         priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }

    function calculateBnbReceived(uint _token) public view returns(uint ){
        uint tokenInUsd = (_token.mul(tokenPrice)).div(1e8);
        uint bnbprice = getCalculatedBnbRecieved(tokenInUsd);
        return bnbprice;
    }

    function calculateTokensReceived(uint _amount) public view returns(uint ){
         uint bnbTokenPrice = getCalculatedBnbRecieved(tokenPrice);
         uint _token = _amount.div(bnbTokenPrice)*1e8;
        return _token;
    }

    function  changeMaxToken(uint _amount) public {

         maxToken= _amount;
    }

     function getLatestPrice() public view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt */,
            /*uint timeStamp*/,
           /* uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function TotalusdPrice(int _amount) public view returns (int) {
        int usdt = getLatestPrice();
        return (usdt * _amount)/1e18;
    }

    function getCalculatedBnbRecieved(uint256 _amount) public view returns(uint256) {
		uint256 usdt = uint256(getLatestPrice());
		uint256 recieved_bnb = (_amount*1e18/usdt*1e18)/1e18;
		return recieved_bnb;
	  }
      
    function tokenBalance() public view returns(uint){
        uint balance = maxToken.sub(buyTokens);
        return balance;
    }



}
library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}