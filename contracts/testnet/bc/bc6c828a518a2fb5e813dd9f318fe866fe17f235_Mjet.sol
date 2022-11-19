/**
 *Submitted for verification at BscScan.com on 2022-11-19
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
    uint256[] public reward_team_business_condition = [7000e18,18000e18,28000e18,57000e18,90000e18,180000e18,400000e18,1200000e18,25000000e18,45000000e18,10000000e18];
    uint256[] public GI_PERCENT = [50,25,20,15, 15,10,10,10,10,10,5,5,5,5,5,5,5,5,5,5,5];
    uint256[] public direct_business_condition  = [100e18,200e18,500e18,1000e18,1500e18,3000e18,3000e18,3000e18,3000e18,3000e18,4000e18,4000e18,4000e18,4000e18,4000e18,4000e18,4000e18,4000e18,4000e18,4000e18,4000e18];
    uint256[] public team_business_condition = [300e18,500e18,3000e18,7000e18,16000e18,38000e18,38000e18,38000e18,38000e18,38000e18,64000e18,64000e18,64000e18,64000e18,64000e18,64000e18,64000e18,64000e18,64000e18,64000e18,64000e18];

    uint256[] public level_condition = [1,2,2,5,5,5,5,5,5,5,8,8,8,8,8];
    uint256[] public BASE_PERCENT = [50, 75, 100, 125 , 150, 175 , 200, 225, 250,275,300]; // multiplied by 100
    uint256[] public DIRECT_MANDATORY = [0, 1, 3,4,5,7,10,13,17,21,26];
    uint256[] public DAYS_SLAB = [1296000,2592000,3888000,5184000,6480000,7776000,9072000,10368000,11664000,12960000,14256000]; //10,15,20,25,30,35,40,50,75,100,150
    //uint256[] public DAYS_SLAB = [60,120,180,240,2592000,3024000,3456000,4320000,6480000,8640000,17280000]; //10,15,20,25,30,35,40,50,75,100,150
    
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
        uint256 total_gi_bonus;
        uint256 id;
        uint256 reward_bonus;
        uint256 total_reward_bonus;
        uint256 available;
        uint256 withdrawn;
        uint256 team_business;
        uint256 already_released;
        uint256 total_invested;
        mapping(uint8 => uint256) structure;
        mapping(uint8 => uint256) level_business;
        mapping(uint8 => bool) rewards;
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

    function token_price(uint256 _amountIn) public view  returns(uint[] memory amounts) {
        // uint256 _amountIn = 1;
        address[] memory path;
        path = new address[](2);
        // path[0] = 0x3EBf2d629Ec3C1c54Df0e287616568D2d66161f7; //mjet on mainnet 
        // path[1] = 0x55d398326f99059fF775485246999027B3197955; //usdt on main net
        //testnet configuration 
        path[0] = 0x27521d76ecf466A405e493830a5e601c00B4Ce7a; //mjet on testnet 
        path[1] = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd; //usdt on testnet // resulted $ at 1    
        return pancakeswap.getAmountsOut(_amountIn, path);
    }


    function token_price_withdraw(uint256 _amountOut) public view  returns(uint[] memory amounts) {

        // uint256 _amountIn = 1;
        address[] memory path;
        path = new address[](2);
        // path[0] = 0x3EBf2d629Ec3C1c54Df0e287616568D2d66161f7; //mjet on mainnet 
        // path[1] = 0x55d398326f99059fF775485246999027B3197955; //usdt on main net

        //testnet configuration 
        path[0] = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd; //usdt on testnet 
        path[1] = 0x27521d76ecf466A405e493830a5e601c00B4Ce7a; //mjet on testnet 
        
        return pancakeswap.getAmountsOut(_amountOut, path);
    }


    function invest(address payable referrer,uint256 token_quantity) public payable beforeStarted() {

        uint256 tokenWei = token_quantity * 10 ** 18;
        token.transferFrom(msg.sender, address(this), tokenWei);

        uint[] memory price = token_price(tokenWei);
        uint256 usdt_eq_to_mjet = price[1];
       
        require(usdt_eq_to_mjet >= INVEST_MIN_AMOUNT, "!INVEST_MIN_AMOUNT");
        require(usdt_eq_to_mjet <= INVEST_MAX_AMOUNT, "!INVEST_MAX_AMOUNT");


        User storage user = users[msg.sender];


        token.transfer(marketingAddress,usdt_eq_to_mjet.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
       
        _setUpline(msg.sender, referrer,tokenWei);

        distribute_reward(msg.sender);

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            totalUsers = totalUsers.add(1);
            user.id = totalUsers;
            user.withdrawn = 0;
            emit Newbie(msg.sender);
        }

        user.available = user.available.add(usdt_eq_to_mjet.mul(3)); // 300 % Max at the time of joinee
        

        user.deposits.push(Deposit(usdt_eq_to_mjet, block.timestamp));
       
        user.total_invested +=usdt_eq_to_mjet;
        totalInvested = totalInvested.add(usdt_eq_to_mjet);
        totalDeposits = totalDeposits.add(1);
        emit NewDeposit(msg.sender, usdt_eq_to_mjet);
        
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
                       //token.transfer(_upline,reward[i]);
                        users[_upline].reward_bonus += reward[i];
                        
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
        if(totalAmount > 0)
        {
            totalAmount -= user.already_released;
            user.already_released += totalAmount;
        }

        require(user.available >= 0, "You have reached your 3x limit");
        

        if(totalAmount > 0)
        {
            _send_gi(msg.sender,totalAmount);
        }
         


        totalAmount += user.gi_bonus;
        totalAmount += user.reward_bonus;
        user.checkpoint = block.timestamp;


        //mjet equivalent to $
        uint[] memory price = token_price_withdraw(totalAmount);
       totalAmount = price[1];

        if (user.available < totalAmount) {
            totalAmount = user.available;
        }
         require(totalAmount > 10e18,"Min withdrawal is of 10$");

        token.transfer(msg.sender,totalAmount);


        user.total_gi_bonus +=user.gi_bonus;
        user.gi_bonus = 0;
        user.total_reward_bonus += user.reward_bonus;
       
        user.reward_bonus = 0;
        
        user.available = user.available.sub(totalAmount);

        if(user.available <=  0)
        {
            delete user.deposits;
        }
        user.withdrawn = user.withdrawn.add(totalAmount);
        totalWithdrawn = totalWithdrawn.add(totalAmount);
        emit Withdrawn(msg.sender, totalAmount);
    }


    function _send_gi(address _addr, uint256 _amount) private {
        address up = users[_addr].referrer;

        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            if(up == address(0)) break;

           if( users[up].level_business[0] >=   direct_business_condition[i]  && users[up].team_business  >= team_business_condition[i])  // need to calculate total team business and direct team business
           {
                uint256 bonus = _amount * GI_PERCENT[i] / 100;
                users[up].gi_bonus += bonus;
                //users[up].total_gi_bonus +=bonus;
                gi_bonus += bonus;
                // token.transfer(up,bonus);
                // users[up].available = users[up].available.sub(bonus);
           }
            up = users[up].referrer;
           
        }
    }


        function getdividend(address _addr) public view returns(uint256){
          User storage user = users[_addr];

            uint256 dividend = 0;
          for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.available > 0) {

               uint256 sec_passed = block.timestamp  - user.deposits[i].start;
                for( uint256 j =0; j< DAYS_SLAB.length; j++)
                {
                    if(sec_passed >=  DAYS_SLAB[j])
                    {

                        dividend += (user.deposits[i].amount.mul(BASE_PERCENT[j]).div(PERCENTS_DIVIDER));

                    }
                }
            }
        }
        return dividend;

     }


         function getUserAmountOfReferrals(address userAddress)
        public
        view
        returns (
            uint256[] memory structure,
            uint256[] memory levelBusiness
        )
    {

        uint256[] memory _structure = new uint256[](GI_PERCENT.length);
        uint256[] memory _levelBusiness = new uint256[](GI_PERCENT.length);
        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            _structure[i] = users[userAddress].structure[i];
            _levelBusiness[i] = users[userAddress].level_business[i];
        }
        return (
             _structure,_levelBusiness

        );
    }


     function getrewardinfo(address userAddress)
        public
        view
        returns (
            bool[] memory reward_info
        )
    {


        bool[] memory _reward_info = new bool[](reward.length);

        for(uint8 i = 0; i < reward.length; i++) {
            _reward_info[i] = users[userAddress].rewards[i];
            
        }
        return (
            _reward_info

        );
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


    function getTimer(address userAddress) public view returns (uint256) {
        return users[userAddress].checkpoint;
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