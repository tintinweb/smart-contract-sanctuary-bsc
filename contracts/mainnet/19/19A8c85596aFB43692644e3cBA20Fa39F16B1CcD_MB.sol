// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IBEP20Token
{
    function mintTokens(address receipient, uint256 tokenAmount) external returns(bool);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address user) external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function maxsupply() external view returns (uint256);
    function repurches(address _from, address _to, uint256 _value) external returns(bool);
    function burn_internal(uint256 _value, address _to) external returns (bool);
}

contract MB{

    IBEP20Token public rewardToken;

    AggregatorV3Interface internal priceFeed;

    using SafeMath for uint256;
    using SafeMath for uint;

    struct Deposit {
		uint256 amountbnb;
    uint256 amountToken;
		uint256 start;  
	}


     struct User {
		    Deposit[] deposits;
        address referrer;
        uint256 burnedToken;
        uint256 totalBNBDeposit;
        uint256 totalTokenDeposit;
        uint totalBNBDeposit_USD;
        uint totalTokenDeposit_USD;  
        uint totalWithdrawal;
     }

     uint public tokenPriceUSD;
     uint public minDepositBNB;
     uint public minDepositToken;
     address payable public ownerWallet;
     uint public totalSupply;
     uint public tokenPriceIncrement;
     uint public token_price_changeOn;
     bool private IsInitinalized;
     uint public minWithdrawAmount;
    


     mapping(address => User) public users;




    function initialize(address payable _ownerWallet,IBEP20Token _rewardToken) public {
        require (IsInitinalized == false,"Already Started");
        tokenPriceUSD = 1e8;
        minDepositBNB = 0 ;
        minDepositToken = 0;
        ownerWallet = _ownerWallet;
        minWithdrawAmount = 0;
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        rewardToken = _rewardToken;
        IsInitinalized = true;

	}

    function investBNB(address _referrer) public payable {
      require(msg.value >= minDepositBNB,"Min deposit is 0");
       User storage user = users[msg.sender];

       require((users[_referrer].deposits.length > 0 && _referrer != msg.sender) || ownerWallet == msg.sender,  "No upline found");
         
        if (user.referrer == address(0) && ownerWallet != msg.sender) {
			    user.referrer = _referrer;
        }

        user.totalBNBDeposit += msg.value;
        user.totalBNBDeposit_USD += uint256(TotalusdPrice(int(msg.value)));

        user.deposits.push(Deposit(msg.value , 0,block.timestamp));


    }

    function investToken(address _referrer,uint _amount ) public payable {
      require(_amount >= minDepositToken,"Min deposit is 0");
      uint balance = rewardToken.balanceOf(msg.sender);
      require(balance >= _amount, "You don't have token");
      User storage user = users[msg.sender];

      require((users[_referrer].deposits.length > 0 && _referrer != msg.sender) || ownerWallet == msg.sender,  "No upline found");
         
      if (user.referrer == address(0) && ownerWallet != msg.sender) {
        user.referrer = _referrer;
      }

      user.totalTokenDeposit += _amount;
      user.totalTokenDeposit_USD += (_amount.mul(tokenPriceUSD)).div(1e8);

      rewardToken.burn_internal(_amount,msg.sender);
      user.deposits.push(Deposit( 0, _amount,block.timestamp));

    }

    function burnToken(address _user , uint _amount ) public {
       rewardToken.burn_internal(_amount, _user);
       users[_user].burnedToken += _amount;
    
    }

    function withdraw( address _user ,uint _amount ) public {
        User storage user = users[_user];
        require(msg.sender == ownerWallet, "permission Denied");
        require(_amount > minWithdrawAmount,"You don't have enough balnce to withdraw");
        uint halfWithdraw = checkBurnToken(_user,_amount);
        require(halfWithdraw >= user.burnedToken,"you don't burned enough tokens");

        rewardToken.mintTokens(_user, _amount);
        totalSupply += _amount;
        user.totalWithdrawal += _amount;

        if(totalSupply >= token_price_changeOn){
            uint increment = tokenPriceIncrement;
            totalSupply = 0;
            tokenPriceUSD=tokenPriceUSD.add(increment);
        }
         
    }

    function checkBurnToken(address _user,uint _amount) private view returns(uint){
      User storage user = users[_user];
      uint token = user.totalWithdrawal + _amount;
      token = token.mul(50).div(100);
      return token;     
    }

    function updateTokenSettings(uint usdvalue, uint onChangeValueUsd) public {
        require(ownerWallet == msg.sender,"permision Denied");
        tokenPriceIncrement = usdvalue;
        token_price_changeOn = onChangeValueUsd;
    }


    function getUser(address _useraddress) public view returns(uint256 tokenDeposit , uint256 bnbDeposit, uint256 totalBNBDeposit_USD, uint256 totalTokenDeposit_USD, uint256 totalWithdrawal, uint256 burnedToken ){
        User storage u = users[_useraddress] ;
        tokenDeposit = u.totalTokenDeposit;
        bnbDeposit = u.totalBNBDeposit;
        totalBNBDeposit_USD = u.totalBNBDeposit_USD;
        totalTokenDeposit_USD =  u.totalTokenDeposit_USD;
        totalWithdrawal = u.totalWithdrawal;
        burnedToken = u.burnedToken;
        
        return (tokenDeposit , bnbDeposit, totalBNBDeposit_USD, totalTokenDeposit_USD, totalWithdrawal, burnedToken);
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

}



library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b == 0, 'SafeMath add failed');
        return (a % b);
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