/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

contract CRICICO {
    using SafeMath for uint256;
     IBEP20 public USDTtoken;
     IBEP20 public Cricktoken;

    uint256 public constant MIN_PURCHASE = 5000 * 10 ** 18; //5k usd 
    uint256 public constant MAX_PURCHASE = 20000 * 10 ** 18 ;//20k usd
    uint256[] public RELEASE_DISTRIBUTION = [1000, 1500, 2000,2500,3000]; // 10%,15%,20%,25%,30%
    uint256[] public DIRECT_REFERRAL = [500, 300,100];//5%,3%,1%
    uint256 public current_phase_price = 300;  //0.3 //  multiplied by 1000;

    uint256[] public PHASE_TIME_PERIOD =[15724800,23587200,31536000,39398400,52531200]; // in seconds [182,273,365,456,608];// in days

    
     
  
  
    uint256 public constant PERCENTS_DIVIDER = 10000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public LAUNCH_TIME;

    

    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalReleased;
    uint256 public totalDeposits;

  
    address payable public owner;

    struct Deposit {
        uint256 amount;
        uint256 start;
        uint256 usdtAmount;
        uint8 is_released_for_phase1;
        uint8 is_released_for_phase2;
        uint8 is_released_for_phase3;
        uint8 is_released_for_phase4;
        uint8 is_released_for_phase5;
        
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address payable referrer;
        uint256 released;
        uint256[3] structure;
        uint256 direct_bonus;
    }

    mapping(address => User) public users;



    modifier beforeStarted() {
        require(block.timestamp >= LAUNCH_TIME, "!beforeStarted");
        _;
    }

    constructor(IBEP20 tokenAdd, IBEP20 _Cricktoken) {
        USDTtoken = tokenAdd;
        Cricktoken  = _Cricktoken;
        owner = msg.sender;
    }

    function purchase(address payable referrer, uint256 token_quantity) public payable beforeStarted() {

        uint256 USDT = token_quantity * 10 ** 18;
        require(USDT >= MIN_PURCHASE, "!MIN_PURCHASE");
        require(USDT <= MAX_PURCHASE, "!MAX_PURCHASE");
       USDTtoken.transferFrom(msg.sender, address(this), USDT);

        //calculate crick coin  quantity value equivalent to spended USDT

        uint256 crickCoinQuantity = USDT.div(current_phase_price).mul(1000);


        
        User storage user = users[msg.sender];

        if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
        }else if(user.referrer == address(0) && user.deposits.length == 0 )
        {
            user.referrer = owner;
        }

        if (user.referrer != address(0)) {
            address payable upline = user.referrer;
            for (uint256 i = 0; i < DIRECT_REFERRAL.length; i++) {
                if (upline != address(0)) {

                        users[upline].structure[i]++;
                        uint256 amount =
                        crickCoinQuantity.mul(DIRECT_REFERRAL[i]).div(
                            PERCENTS_DIVIDER
                        );
                       // upline.transfer(amount);

                        Cricktoken.transfer(upline, amount);

                        users[upline].direct_bonus = users[upline].direct_bonus.add(amount);
                        upline = users[upline].referrer;
                } else break;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
           
            totalUsers = totalUsers.add(1);
            user.released = 0;
        }

        

        user.deposits.push(Deposit(crickCoinQuantity, block.timestamp,USDT,0,0,0,0,0));
       

        totalInvested = totalInvested.add(crickCoinQuantity);
        totalDeposits = totalDeposits.add(1);

    }


    function chenge_phase_price(uint256 price) public{

        require(msg.sender==owner,"Permission denied");
        current_phase_price = price;
    }

    function withdraw() public beforeStarted() {
        

        User storage user = users[msg.sender];
         for (uint256 i = 0; i < user.deposits.length; i++) {

             uint256 time_elapsed = block.timestamp.sub(user.deposits[i].start); // time elapsed in seconds

                if (time_elapsed > PHASE_TIME_PERIOD[0] &&  user.deposits[i].is_released_for_phase1==0) {

                    uint256 dividends = (
                        user.deposits[i].amount.mul(RELEASE_DISTRIBUTION[0]).div(
                            PERCENTS_DIVIDER
                        )
                    );

                   
                        user.deposits[i].is_released_for_phase1 = 1;
                        user.released = user.released.add(dividends);
                        totalReleased = totalReleased.add(dividends);
                        Cricktoken.transfer(msg.sender, dividends);

                } else if(time_elapsed > PHASE_TIME_PERIOD[1] &&  user.deposits[i].is_released_for_phase2==0) {


                     uint256 dividends = (
                        user.deposits[i].amount.mul(RELEASE_DISTRIBUTION[1]).div(
                            PERCENTS_DIVIDER
                        )
                    );

                       
                        user.deposits[i].is_released_for_phase2 = 1;
                        user.released = user.released.add(dividends);
                        totalReleased = totalReleased.add(dividends);
                        Cricktoken.transfer(msg.sender, dividends);
                    
                }

                else if(time_elapsed > PHASE_TIME_PERIOD[2] &&  user.deposits[i].is_released_for_phase3==0) {


                   uint256  dividends = (
                        user.deposits[i].amount.mul(RELEASE_DISTRIBUTION[2]).div(
                            PERCENTS_DIVIDER
                        )
                    );

                       
                        user.deposits[i].is_released_for_phase3 = 1;
                        user.released = user.released.add(dividends);
                        totalReleased = totalReleased.add(dividends);
                        Cricktoken.transfer(msg.sender, dividends);
                    
                }

                 else if(time_elapsed > PHASE_TIME_PERIOD[3] &&  user.deposits[i].is_released_for_phase4==0) {


                    uint256 dividends = (
                        user.deposits[i].amount.mul(RELEASE_DISTRIBUTION[3]).div(
                            PERCENTS_DIVIDER
                        )
                    );

                       
                        user.deposits[i].is_released_for_phase4 = 1;
                        user.released = user.released.add(dividends);
                        totalReleased = totalReleased.add(dividends);

                         Cricktoken.transfer(msg.sender, dividends);
                    
                }
                 else if(time_elapsed > PHASE_TIME_PERIOD[4] &&  user.deposits[i].is_released_for_phase5==0) {


                    uint256 dividends = (
                        user.deposits[i].amount.mul(RELEASE_DISTRIBUTION[4]).div(
                            PERCENTS_DIVIDER
                        )
                    );

                        
                        user.deposits[i].is_released_for_phase5 = 1;
                        user.released = user.released.add(dividends);
                        totalReleased = totalReleased.add(dividends);
                         Cricktoken.transfer(msg.sender, dividends);
                }     
            
        }
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }


    function withdrawUSDT(uint256 amt) public{
        require(msg.sender ==owner,"permisson denied");

        uint256 USDT_to_withdraw = amt * 10 ** 18;

        USDTtoken.transfer(msg.sender, USDT_to_withdraw);
    }


    function withdrawCric(uint256 amt) public{

        require(msg.sender ==owner,"permisson denied");

        uint256 crick_to_withdraw = amt * 10 ** 18;

        Cricktoken.transfer(msg.sender, crick_to_withdraw);

    }

  
   

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return (users[userAddress].direct_bonus);
    }




    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256,uint256[] memory usdtdeposited )
    {
        User storage user = users[userAddress];

        uint256 amount;
        uint256[] memory _usdtdeposited = new uint256[](user.deposits.length);

        for (uint256 i = 0; i < user.deposits.length; i++) {
              Deposit storage dep = user.deposits[i];
               _usdtdeposited[i] = dep.usdtAmount;
            amount = amount.add(user.deposits[i].amount);
        }

        return (amount, _usdtdeposited);
    }



    function investmentsInfo(address _addr) view external returns(uint256[] memory amounts, uint256[] memory start, uint256[] memory p1, uint256[] memory p2, uint256[] memory p3, uint256[] memory p4, uint256[] memory p5){
        User storage user = users[_addr];

     uint256[] memory _amounts = new uint256[](user.deposits.length);

  
     uint256[] memory _start = new uint256[](user.deposits.length);
     uint256[] memory _p1 = new uint256[](user.deposits.length);
     uint256[] memory _p2 = new uint256[](user.deposits.length);
     uint256[] memory _p3 = new uint256[](user.deposits.length);
     uint256[] memory _p4 = new uint256[](user.deposits.length);
     uint256[] memory _p5 = new uint256[](user.deposits.length);


        for(uint256 i = 0; i < user.deposits.length; i++) {
          Deposit storage dep = user.deposits[i];
           _amounts[i] = dep.amount;
          
         _start[i] =  dep.start;
         _p1[i] = dep.is_released_for_phase1;
         _p2[i] = dep.is_released_for_phase2;
         _p3[i] = dep.is_released_for_phase3;
         _p4[i] = dep.is_released_for_phase4;
         _p5[i] = dep.is_released_for_phase5;
        }

        return (
          _amounts,
          _start,
          _p1,
          _p2,
          _p3,
          _p4,
          _p5

        );
    }




    function headsinfo(address _addr) view external returns(uint256[] memory structure) {
        User storage user = users[_addr];
        structure = new uint256[](DIRECT_REFERRAL.length);

        for(uint8 i = 0; i < DIRECT_REFERRAL.length; i++) {
            structure[i] = user.structure[i];
        }
        return (
           structure
        );
    }




    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        return user.released;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}