/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

contract Mjet {
    using SafeMath for uint256;
    IPancakeRouter01 public pancakeswap;
    IBEP20 public token;

    uint256 public constant INVEST_MIN_AMOUNT = 30e18; //30$
    uint256 public constant INVEST_MAX_AMOUNT = 50000e18; // 50000$;
  

    uint256[] public reward = [200e18,400e18,800e18,1500e18, 2000e18,5000e18,10000e18,20000e18,50000e18,100000e18,250000e18];
    uint256[] public reward_team_business_condition = [7000e18,18000e18,28000e18,57000e18,90000e18,180000e18,400000e18,1200000e18,45000000e18,10000000e18];
    uint256[] public GI_PERCENT = [50,25,20,15, 15,10,10,10,10,10,5,5,5,5,5,5,5,5,5,5,5];
    uint256[] public level_condition = [1,2,2,5,5,5,5,5,5,5,8,8,8,8,8];
    uint256[] public BASE_PERCENT = [50, 75, 100, 125 , 150, 175 , 200, 225, 250,275,300]; // multiplied by 100
    uint256[] public DIRECT_MANDATORY = [0, 1, 3,4,5,7,10,13,17,21,26];
    uint256[] public DAYS_SLAB = [864000,1296000,1728000,2160000,2592000,3024000,3456000,4320000,6480000,8640000,17280000]; //10,15,20,25,30,35,40,50,75,100,200
    
    uint256 public constant MARKETING_FEE = 1000;
    uint256 public constant PERCENTS_DIVIDER = 10000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public LAUNCH_TIME;
    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;
    uint256 gi_bonus;

    address payable public marketingAddress;
    address payable public projectAddress;
    address payable public owner;

    struct Deposit {
        uint256 amount;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address payable referrer;
        uint256 bonus;
        uint256 gi_bonus;
        uint256 id;
        uint256 available;
        uint256 withdrawn;
        uint256 team_business;
        uint256 already_released;
        
        mapping(uint8 => uint256) structure;
        mapping(uint8 => uint256) level_business;
        mapping(uint8 => bool) rewards;
        uint256 direct_bonus;
       
    }

    mapping(address => User) public users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    modifier beforeStarted() {
        require(block.timestamp >= LAUNCH_TIME, "!beforeStarted");
        _;
    }

    constructor(address payable marketingAddr, IPancakeRouter01 routerAdd,IBEP20 tokenAdd ) {
        require(!isContract(marketingAddr), "!marketingAddr");
        owner = msg.sender;
        marketingAddress = marketingAddr;
        pancakeswap = routerAdd;
         token = tokenAdd;
    }



    function token_price() view external returns(uint[] memory amounts) {


        uint256 _amountIn = 1;
        address[] memory path;
        path = new address[](2);
        path[0] = 0x3EBf2d629Ec3C1c54Df0e287616568D2d66161f7; //mjet on mainnet 
        path[1] = 0x55d398326f99059fF775485246999027B3197955; //usdt on main net
        return pancakeswap.getAmountsOut(_amountIn, path);
    }

    function invest(address payable referrer,uint256 token_quantity) public payable beforeStarted() {

        uint256 tokenWei = token_quantity * 10 ** 18;

        require(tokenWei >= INVEST_MIN_AMOUNT, "!INVEST_MIN_AMOUNT");
        require(tokenWei <= INVEST_MAX_AMOUNT, "!INVEST_MAX_AMOUNT");


        token.transferFrom(msg.sender, address(this), tokenWei);


        User storage user = users[msg.sender];


        token.transfer(marketingAddress,tokenWei.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
       

       

        _setUpline(msg.sender, referrer,tokenWei);

        distribute_reward(msg.sender);

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            totalUsers = totalUsers.add(1);
            user.id = totalUsers;
            user.withdrawn = 0;
            emit Newbie(msg.sender);
        }

        user.available = user.available.add(msg.value.mul(3)); // 300 % Max at the time of joinee
        

        user.deposits.push(Deposit(msg.value, block.timestamp));
       

        totalInvested = totalInvested.add(msg.value);
        totalDeposits = totalDeposits.add(1);
        emit NewDeposit(msg.sender, msg.value);
        
    }


      function _setUpline(address _addr, address payable _upline,uint256 amount) private {
        if(users[_addr].referrer == address(0)) {//first time entry
            if(users[_upline].deposits.length == 0) {//no deposite from my upline
                _upline = owner;
            }
            users[_addr].referrer = _upline;
            for(uint8 i = 0; i < GI_PERCENT.length; i++) {
                users[_upline].structure[i]++;
                 users[_upline].level_business[i] += amount;
                 users[_upline].team_business +=amount;
                _upline = users[_upline].referrer;
                if(_upline == address(0)) break;
            }
        }
        
         else
             {
                _upline = users[_addr].referrer;
            for( uint8 i = 0; i < GI_PERCENT.length; i++) {
                     users[_upline].level_business[i] += amount;
                    _upline = users[_upline].referrer;
                    users[_upline].team_business +=amount;
                    if(_upline == address(0)) break;
                }
        }
        
    }

    function distribute_reward(address _addr) private {

        address payable _upline = users[_addr].referrer;


        for(uint8 j = 0; j < GI_PERCENT.length; j++) {

            for (uint8 i = 0 ; i < reward.length; i ++ )
            {
                if(users[_upline].team_business > reward_team_business_condition[i] &&  users[_upline].rewards[i] == false)
                {
                        users[_upline].rewards[i] = true;
                        token.transfer(_upline,reward[i]);
                }

            }
             _upline = users[_upline].referrer;
            if(_upline == address(0)) break;
        }
        


    }

    

    function withdraw() public beforeStarted() {
        User storage user = users[msg.sender];
        uint256 totalAmount;
      
        totalAmount =  getdividend(msg.sender);
        totalAmount -= user.already_released;
        user.already_released += totalAmount;

        if (user.available < totalAmount) {
            totalAmount = user.available;
        }

        require(totalAmount >= 10e18, "Less then the minimum withdrawal"); // 10$ mininum withdrawal
        

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

         _send_gi(msg.sender,totalAmount);


        user.checkpoint = block.timestamp;

    
        token.transfer(msg.sender,totalAmount);

        user.available = user.available.sub(totalAmount);
        user.withdrawn = user.withdrawn.add(totalAmount);
        totalWithdrawn = totalWithdrawn.add(totalAmount);
        emit Withdrawn(msg.sender, totalAmount);
    }


    function _send_gi(address _addr, uint256 _amount) private {
        address up = users[_addr].referrer;

        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            if(up == address(0)) break;

            if(1 < 2)
            {
                uint256 bonus = _amount * GI_PERCENT[i] / 1000;
                users[up].gi_bonus += bonus;
                 gi_bonus += bonus;
                 token.transfer(up,bonus);
                users[up].available = users[up].available.sub(bonus);


            }

           if( i > 1 && users[up].level_business[0] >=   500e18  && users[up].team_business  >=3000e18)  // need to calculate total team business and direct team business
           {
                uint256 bonus = _amount * GI_PERCENT[i] / 1000;
                users[up].gi_bonus += bonus;
                gi_bonus += bonus;

                token.transfer(up,bonus);
                users[up].available = users[up].available.sub(bonus);



           }
            up = users[up].referrer;
           
        }
    }


     function getdividend(address _addr) public view returns(uint256){
          User storage user = users[_addr];

            uint256 dividend = 0;
            uint currentSlabSecPassed;
          for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.available > 0) {

               uint256 sec_passed = block.timestamp  - user.deposits[i].start;
                for( uint256 j =0; j< DAYS_SLAB.length; j++)
                {

                    if(DAYS_SLAB[j] >  sec_passed ){

                        if(j >0)
                        {
                            currentSlabSecPassed =  sec_passed - DAYS_SLAB[j - 1];
                        }else{
                             currentSlabSecPassed = sec_passed;
                        }
                         dividend += (user.deposits[i].amount.mul(BASE_PERCENT[j]).div(PERCENTS_DIVIDER))
                         .mul(currentSlabSecPassed).div(TIME_STEP);
                        

                    }else
                    {
                        //sec passed is greater then current slab so user should get income of full current slab
                        
                        dividend += (user.deposits[i].amount.mul(BASE_PERCENT[j]).div(PERCENTS_DIVIDER)).mul(DAYS_SLAB[j]).div(TIME_STEP);

                    }

                }
            }
        }
        return dividend;

     }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
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
        returns (uint256, uint256)
    {
        return (users[userAddress].bonus,users[userAddress].direct_bonus);
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return getdividend(userAddress);
    }

    function getAvailable(address userAddress) public view returns (uint256) {
        return users[userAddress].available;
    }

    

    function getUserAmountOfReferrals(address userAddress)
        public
        view
        returns (
            uint256[10] memory structure
        )
    {

        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            structure[i] = users[userAddress].structure[i];
        }
        return (
             structure
        );
    }

    function getTimer(address userAddress) public view returns (uint256) {
        return users[userAddress].checkpoint;
    }

    function getChainID() public pure returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }


    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (uint256, uint256)
    {
        User storage user = users[userAddress];

        return (user.deposits[index].amount, user.deposits[index].start);
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
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].amount);
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        return user.withdrawn;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

interface IPancakeRouter01 {
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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