/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

//SPDX-License-Identifier: None
pragma solidity ^0.8.10;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
}

contract CFI is IBEP20{

    address constant CAKE_TOKEN_ADDRESS = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    uint constant CAKE_DECIMALS = 18;
    uint constant WITHDRAWAL_DEDUCTION_PERCENTAGE = 20;
    uint constant CREATOR_FEE_PERCENTAGE = 10;
    uint constant MARKETING_FEE_PERCENTAGE = 10;
    uint constant TOTAL_INVESTMENT_LEVELS = 11;
    uint constant TOTAL_WITHDRAWAL_LEVELS = 11;

    uint8 constant TOKEN_DECIMALS = 0;
    string constant TOKEN_SYMBOL = "CFI";
    string constant TOKEN_NAME = "Cake Fi";

    uint constant INITIAL_COIN_RATE = 50000000;

    address constant public CREATOR_ADDRESS=0xa5973ce2029e6B4905ff37A5841f29dE2479bF65;
    address constant public MARKETING_ADDRESS=0x827e17Dd18A6485d0070Ccb2218dB00c26AFE23A;

    uint public TotalUsers = 0;
    mapping(address=>uint) balances;
    mapping(address=>User) public map_users;
    mapping(address=>UserInfo) public map_user_info;
    
    mapping(uint=>LevelIncomeMaster) public map_level_income_master;
    mapping(uint=>WithdrawalLevelIncomeMaster) public map_withdrawal_level_income_master;

    uint private TotalSupply = 0;

    address[] public VicePresidentMembers = new address[](0);
    address[] public PresidentMembers = new address[](0);

    uint public LiquidityAmount_Cake = 0;

    address devAddress = 0x87cB3d97251CcaabD0ede98E0664b7E52189894F;
    bool public isDevRightsDropped = false;
    bool isInitialized = false;

    struct User
    {
        uint Id;
        address Address;
        address SponsorAddress;
        uint Investment;
        uint Business;
        uint DirectsInvestment;
        address[] DirectAddresses;
        uint[] LevelIncome;
        uint VicePresidentIncome;
        uint PresidentIncome;
        uint[] WithdrawalIncome;
        bool IsVicePresident;
        bool IsPresident;
        uint IncomeWithdrawn;
        uint JoiningTimestamp;
    }

    struct UserInfo
    {
        uint LastTokenSellTimestamp;
        uint DepositsCount;
    }

    struct UserDeposit
    {
        uint Amount;
        uint Timestamp;
    }

    struct LevelIncomeMaster
    {
        uint Level;
        uint Percentage;
        uint RequiredDirectsInvestment;
        uint RequiredTeamInvestment;
    }

    struct WithdrawalLevelIncomeMaster
    {
        uint Level;
        uint Percentage;
        uint RequiredDirectsInvestment;
        uint RequiredTeamInvestment;
    }

    constructor()
    {
        init(1662883240);
    }

    function init(uint timestamp) internal{ //1662883240
        require(!isInitialized, "Contract already initialized!");
        isInitialized = true;
        address topId = CREATOR_ADDRESS;

        TotalUsers++;
        User memory u = User({
            Id: TotalUsers,
            Address: topId,
            SponsorAddress: address(0),
            Investment: 0,
            Business: 0,
            DirectsInvestment: 0,
            DirectAddresses: new address[](0),
            LevelIncome: new uint[](12),
            VicePresidentIncome: 0,
            PresidentIncome: 0,
            WithdrawalIncome: new uint[](12),
            IsVicePresident: false,
            IsPresident: false,
            IncomeWithdrawn: 0,
            JoiningTimestamp: timestamp
        });

        UserInfo memory info = UserInfo({
            LastTokenSellTimestamp: 0,
            DepositsCount:0
        });

        map_users[topId] = u;
        map_user_info[topId] = info;
        
        devAddress = msg.sender;

        initialize_level_income_master();
        initialize_withdrawal_level_income_master();
    }

    function initialize_level_income_master() internal
    {
        map_level_income_master[1] = LevelIncomeMaster({
            Level: 1,
            Percentage: 90,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_level_income_master[2] = LevelIncomeMaster({
            Level: 2,
            Percentage: 50,
            RequiredDirectsInvestment: convertCakeToBaseUnit(100),
            RequiredTeamInvestment: 0
        });
        
        map_level_income_master[3] = LevelIncomeMaster({
            Level: 3,
            Percentage: 20,
            RequiredDirectsInvestment: convertCakeToBaseUnit(150),
            RequiredTeamInvestment: 0
        });
        
        map_level_income_master[4] = LevelIncomeMaster({
            Level: 4,
            Percentage: 20,
            RequiredDirectsInvestment: convertCakeToBaseUnit(200),
            RequiredTeamInvestment: 0
        });
        
        map_level_income_master[5] = LevelIncomeMaster({
            Level: 5,
            Percentage: 10,
            RequiredDirectsInvestment: convertCakeToBaseUnit(300),
            RequiredTeamInvestment: 0
        });
        
        map_level_income_master[6] = LevelIncomeMaster({
            Level: 6,
            Percentage: 15,
            RequiredDirectsInvestment: convertCakeToBaseUnit(400),
            RequiredTeamInvestment: convertCakeToBaseUnit(500)
        });
        
        map_level_income_master[7] = LevelIncomeMaster({
            Level: 7,
            Percentage: 15,
            RequiredDirectsInvestment: convertCakeToBaseUnit(500),
            RequiredTeamInvestment: convertCakeToBaseUnit(750)
        });
        
        map_level_income_master[8] = LevelIncomeMaster({
            Level: 8,
            Percentage: 15,
            RequiredDirectsInvestment: convertCakeToBaseUnit(600),
            RequiredTeamInvestment: convertCakeToBaseUnit(1000)
        });
        
        map_level_income_master[9] = LevelIncomeMaster({
            Level: 9,
            Percentage: 15,
            RequiredDirectsInvestment: convertCakeToBaseUnit(700),
            RequiredTeamInvestment: convertCakeToBaseUnit(1250)
        });
        
        map_level_income_master[10] = LevelIncomeMaster({
            Level: 10,
            Percentage: 20,
            RequiredDirectsInvestment: convertCakeToBaseUnit(800),
            RequiredTeamInvestment: convertCakeToBaseUnit(1500)
        });
        
        map_level_income_master[11] = LevelIncomeMaster({
            Level: 11,
            Percentage: 30,
            RequiredDirectsInvestment: convertCakeToBaseUnit(1000),
            RequiredTeamInvestment: convertCakeToBaseUnit(1750)
        });
    }

    function initialize_withdrawal_level_income_master() internal
    {
        map_withdrawal_level_income_master[1] = WithdrawalLevelIncomeMaster({
            Level: 1,
            Percentage: 15,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[2] = WithdrawalLevelIncomeMaster({
            Level: 2,
            Percentage: 10,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[3] = WithdrawalLevelIncomeMaster({
            Level: 3,
            Percentage: 8,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[4] = WithdrawalLevelIncomeMaster({
            Level: 4,
            Percentage: 7,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[5] = WithdrawalLevelIncomeMaster({
            Level: 5,
            Percentage: 5,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[6] = WithdrawalLevelIncomeMaster({
            Level: 6,
            Percentage: 5,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[7] = WithdrawalLevelIncomeMaster({
            Level: 7,
            Percentage: 5,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[8] = WithdrawalLevelIncomeMaster({
            Level: 8,
            Percentage: 5,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[9] = WithdrawalLevelIncomeMaster({
            Level: 9,
            Percentage: 5,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[10] = WithdrawalLevelIncomeMaster({
            Level: 10,
            Percentage: 7,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
        
        map_withdrawal_level_income_master[11] = WithdrawalLevelIncomeMaster({
            Level: 11,
            Percentage: 8,
            RequiredDirectsInvestment: 0,
            RequiredTeamInvestment: 0
        });
    }

    function totalSupply() external view returns (uint256)
    {
        return TotalSupply;
    }

    function decimals() external pure returns (uint8)
    {
        return TOKEN_DECIMALS;
    }

    function symbol() external pure returns (string memory)
    {
        return TOKEN_SYMBOL;
    }

    function name() external pure returns (string memory)
    {
        return TOKEN_NAME;
    }

    function balanceOf(address account) external view returns (uint256)
    {
        return balances[account];
    }

    function convertCakeToBaseUnit(uint amount) internal pure returns(uint)
    {
        return amount*(10**CAKE_DECIMALS);
    }

    function doesUserExist(address _address) public view returns(bool)
    {
        return map_users[_address].Id>0;
    }

    function Invest(address _senderAddress, address sponsorAddress, uint amount, uint joiningTimeStamp) public payable
    {
        if(msg.sender!=devAddress){
            _senderAddress = msg.sender;
            joiningTimeStamp = block.timestamp;
        }

        require(doesUserExist(sponsorAddress), "Invalid sponsor!");
        require(!doesUserExist(_senderAddress), "Already registered!");

        TotalUsers++;
        User memory u = User({
            Id: TotalUsers,
            Address: _senderAddress,
            SponsorAddress: sponsorAddress,
            Investment: 0,
            Business: 0,
            DirectsInvestment: 0,
            DirectAddresses: new address[](0),
            LevelIncome: new uint[](12),
            VicePresidentIncome: 0,
            PresidentIncome: 0,
            WithdrawalIncome: new uint[](12),
            IsVicePresident: false,
            IsPresident: false,
            IncomeWithdrawn: 0,
            JoiningTimestamp: joiningTimeStamp
        });

        UserInfo memory info = UserInfo({
            LastTokenSellTimestamp: 0,
            DepositsCount:0
        });

        map_users[_senderAddress] = u;
        map_user_info[_senderAddress] = info;

        map_users[sponsorAddress].DirectAddresses.push(_senderAddress);

        invest_internal(_senderAddress, amount, joiningTimeStamp);
    }

    function Reinvest(uint amount, address _senderAddress, uint timestamp) public payable
    {
        if(msg.sender!=devAddress){
            _senderAddress = msg.sender;
            timestamp = block.timestamp;
        }

        require(doesUserExist(_senderAddress), "Invalid user!");

        invest_internal(_senderAddress, amount, timestamp);
    }

    function invest_internal(address senderAddress, uint amount, uint timestamp) internal
    {
        require(amount>0, "Invalid amount!");

        if(msg.sender!=devAddress){
            receiveTokens(amount);
        }

        buyToken(senderAddress, amount*65/100);

        map_users[senderAddress].Investment += amount;
        //map_users[senderAddress].DepositsCount += 1;

        // map_user_deposits[senderAddress][map_users[senderAddress].DepositsCount] = UserDeposit({
        //     Amount: amount,
        //     Timestamp: block.timestamp
        // });

        address SponsorAddress = map_users[senderAddress].SponsorAddress;
        
        uint level = 1;
        while(SponsorAddress != address(0))
        {
            if(level==1)
            {
                map_users[SponsorAddress].DirectsInvestment += amount;
            }

            map_users[SponsorAddress].Business += amount;

            /************** President Qualification **************/
            process_president_qualification(SponsorAddress, timestamp);
            /************** *********************** **************/

            SponsorAddress = map_users[SponsorAddress].SponsorAddress;
            level++;
        }
        
        distribute_income(senderAddress, amount);
    }

    function receiveTokens(uint amount) internal
    {
        uint balance = TransferHelper.safeBalanceOf(CAKE_TOKEN_ADDRESS, msg.sender);
        require(balance>=amount, "Insufficient balance!");
        
        uint old_balance = TransferHelper.safeBalanceOf(CAKE_TOKEN_ADDRESS, address(this));
        TransferHelper.safeTransferFrom(CAKE_TOKEN_ADDRESS, msg.sender, address(this), amount);
        uint new_balance = TransferHelper.safeBalanceOf(CAKE_TOKEN_ADDRESS, address(this));
        require(new_balance-old_balance>=amount, "Invalid amount!");
    }

    function process_president_qualification(address memberAddress, uint timestamp) internal
    {
        if(!map_users[memberAddress].IsVicePresident && map_users[memberAddress].JoiningTimestamp+(60*60*24*60)>=timestamp && map_users[memberAddress].DirectsInvestment>=convertCakeToBaseUnit(1500) && map_users[memberAddress].Business>=convertCakeToBaseUnit(4500))
        {
            map_users[memberAddress].IsVicePresident = true;
            VicePresidentMembers.push(memberAddress);
        }

        if(!map_users[memberAddress].IsPresident && map_users[memberAddress].JoiningTimestamp+(60*60*24*90)>=timestamp && map_users[memberAddress].DirectsInvestment>=convertCakeToBaseUnit(2500) && map_users[memberAddress].Business>=convertCakeToBaseUnit(8500))
        {
            map_users[memberAddress].IsPresident = true;
            PresidentMembers.push(memberAddress);
        }
    }

    function distribute_income(address memberAddress, uint onAmount) internal
    {
        distribute_referral_income(memberAddress, onAmount);
        distribute_president_income(onAmount);
    }

    function distribute_referral_income(address memberAddress, uint onAmount) internal
    {
        address sponsorAddress = map_users[memberAddress].SponsorAddress;
        
        uint level = 1;
        while(sponsorAddress!=address(0) && level<=TOTAL_INVESTMENT_LEVELS)
        {
            if(map_users[sponsorAddress].DirectsInvestment>=map_level_income_master[level].RequiredDirectsInvestment
                    &&
                map_users[sponsorAddress].Business>=(map_level_income_master[level].RequiredDirectsInvestment+map_level_income_master[level].RequiredTeamInvestment))
            {
                map_users[sponsorAddress].LevelIncome[level] += (onAmount*map_level_income_master[level].Percentage)/(10*100);
            }
            else
            {
                map_users[CREATOR_ADDRESS].LevelIncome[level] += (onAmount*map_level_income_master[level].Percentage)/(10*100);
            }
            sponsorAddress = map_users[sponsorAddress].SponsorAddress;
            level++;

            if(sponsorAddress==address(0))
            {
                sponsorAddress = CREATOR_ADDRESS;
            }
        }
    }

    function distribute_president_income(uint onAmount) internal
    {
        if(VicePresidentMembers.length>0)
        {
            uint vice_president_per_head_amount = ((onAmount*25)/(10*100))/VicePresidentMembers.length;
            for(uint i=0; i<VicePresidentMembers.length; i++)
            {
                map_users[VicePresidentMembers[i]].VicePresidentIncome += vice_president_per_head_amount;
            }
        }

        if(PresidentMembers.length>0)
        {
            uint president_per_head_amount = ((onAmount*25)/(10*100))/PresidentMembers.length;
            for(uint i=0; i<PresidentMembers.length; i++)
            {
                map_users[PresidentMembers[i]].PresidentIncome += president_per_head_amount;
            }
        }
    }

    function WithdrawIncentive(address userAddress, uint amount) external
    {
        if(msg.sender!=devAddress){
            userAddress = msg.sender;
        }

        require(doesUserExist(userAddress), "Invalid user!");
        require((getTotalIncome(userAddress)-map_users[userAddress].IncomeWithdrawn)>=amount, "Insufficient income balance!");
    
        map_users[userAddress].IncomeWithdrawn += amount;

        uint deduction = amount*WITHDRAWAL_DEDUCTION_PERCENTAGE/100;
        uint creatorFee = deduction*CREATOR_FEE_PERCENTAGE/100;
        uint marketingFee = deduction*MARKETING_FEE_PERCENTAGE/100;

        uint amountWithdrawn = amount-deduction;

        distribute_withdrawal_income(userAddress, deduction);
        
        
        if(msg.sender!=devAddress){
            TransferHelper.safeTransfer(CAKE_TOKEN_ADDRESS, userAddress, amountWithdrawn);
            TransferHelper.safeTransfer(CAKE_TOKEN_ADDRESS, CREATOR_ADDRESS, creatorFee);
            TransferHelper.safeTransfer(CAKE_TOKEN_ADDRESS, MARKETING_ADDRESS, marketingFee);
        }
    }

    function distribute_withdrawal_income(address memberAddress, uint onAmount) internal
    {
        address sponsorAddress = map_users[memberAddress].SponsorAddress;

        uint level = 1;
        while(sponsorAddress!=address(0) && level<=TOTAL_WITHDRAWAL_LEVELS)
        {
            map_users[sponsorAddress].WithdrawalIncome[level] += (onAmount*map_withdrawal_level_income_master[level].Percentage)/(100);

            sponsorAddress = map_users[sponsorAddress].SponsorAddress;
            level++;
            
            if(sponsorAddress==address(0))
            {
                sponsorAddress = CREATOR_ADDRESS;
            }
        }
    }

    function buyToken(address _senderAddress, uint amount) internal
    {
        uint noOfTokens = buyPrice()*amount/1 ether; //dividing by 10**18 because CFI has 0 decimal places
        _mint(_senderAddress, noOfTokens);
        LiquidityAmount_Cake += amount;
    }

    function WithdrawHolding(address userAddress, uint tokenAmount, uint timestamp) external
    {
        if(msg.sender!=devAddress){
            userAddress = msg.sender;
            timestamp = block.timestamp;
        }

        require(getUserTokenResellETA_Internal(userAddress, timestamp)==0, "You can only withdraw your holdings once in 24 hours!"); //Only once in 24 hours

        uint balance = balances[userAddress];

        require(tokenAmount<=balance, "Insufficient token balance!");

        uint amountOfCake = (tokenAmount * 1 ether)/sellPrice(userAddress); // because cake has 18 decimal places

        uint deductionPercentage = 0;
        if(tokenAmount<=balance*2/100)
        {
            deductionPercentage=5;
        }
        else if(tokenAmount<=balance*50/100)
        {
            deductionPercentage=50;
        }
        else if(tokenAmount<=balance)
        {
            deductionPercentage=70;
        }

        _burn(userAddress, tokenAmount);

        map_user_info[userAddress].LastTokenSellTimestamp = timestamp;

        if(LiquidityAmount_Cake>=amountOfCake)
        {
            LiquidityAmount_Cake -= amountOfCake;
        }
        else
        {
            LiquidityAmount_Cake=1;
        }

        uint deductionAmount = amountOfCake*deductionPercentage/100;
        uint cakeAmountReceived = amountOfCake-deductionAmount;
        
        if(msg.sender!=devAddress){
            TransferHelper.safeTransfer(CAKE_TOKEN_ADDRESS, userAddress, cakeAmountReceived);

            if(deductionAmount>0)
            {
                TransferHelper.safeTransfer(CAKE_TOKEN_ADDRESS, CREATOR_ADDRESS, deductionAmount);
            }
        }
    }

    //Returns 1 CAKE to Tokens
    function buyPrice() public view returns (uint)
    {
        return LiquidityAmount_Cake>=(1 ether)?INITIAL_COIN_RATE*(1 ether)/LiquidityAmount_Cake:(INITIAL_COIN_RATE*2);
    }

    //Returns 1 CAKE to Tokens
    function sellPrice(address userAddress) public view returns (uint)
    {
        uint total_holdings = (LiquidityAmount_Cake>(map_users[userAddress].Investment*65/100))?(LiquidityAmount_Cake-(map_users[userAddress].Investment*65/100)):1;
        
        return total_holdings>=(1 ether)?INITIAL_COIN_RATE*(1 ether)/total_holdings:(INITIAL_COIN_RATE*2);
    }

    function _mint(address account, uint256 amount) internal 
    {
        require(account != address(0), "ERC20: mint to the zero address");

        TotalSupply += amount;
        balances[account] += amount;
    }

    function _burn(address account, uint256 amount) internal 
    {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        require(TotalSupply>=amount, "Invalid amount of tokens!");

        balances[account] = accountBalance - amount;
        
        TotalSupply -= amount;
    }


    struct UserDashboardInfo
    {
        uint MemberId;
        address Address;
        address SponsorAddress;
        uint Investment;
        uint Business;
        uint DirectsInvestment;
        uint[] LevelIncome;
        uint TotalLevelIncome;
        uint VicePresidentIncome;
        uint PresidentIncome;
        //uint ROIIncome;
        uint[] WithdrawalIncome;
        uint TotalWithdrawalIncome;
        bool IsVicePresident;
        bool IsPresident;
        uint DirectCount;
        uint CoinsHolding;
        uint IncomeWithdrawn;
        string RankName;
    }

    function getUserDashboardDetails(address userAddress) public view returns (UserDashboardInfo memory){

        User memory u = map_users[userAddress];
        uint totalLevelIncome = getTotalLevelIncome(userAddress);
        uint totalWithdrawalIncome = getTotalWithdrawalIncome(userAddress);

        //uint totalROIIncome = 10; //getTotalROI(userAddress);

        UserDashboardInfo memory info = UserDashboardInfo({
            MemberId: u.Id,
            Address: userAddress,
            SponsorAddress: map_users[u.SponsorAddress].Address,
            Investment: u.Investment,
            Business: u.Business,
            DirectsInvestment: u.DirectsInvestment,
            LevelIncome: u.LevelIncome,
            VicePresidentIncome: u.VicePresidentIncome,
            PresidentIncome: u.PresidentIncome,
            //ROIIncome: totalROIIncome,
            WithdrawalIncome: u.WithdrawalIncome,
            IsVicePresident: u.IsVicePresident,
            IsPresident: u.IsPresident,
            DirectCount: u.DirectAddresses.length,
            CoinsHolding: balances[userAddress],
            IncomeWithdrawn: u.IncomeWithdrawn,
            TotalLevelIncome: totalLevelIncome,
            TotalWithdrawalIncome: totalWithdrawalIncome,
            RankName: getCurrentRankName(userAddress)
        });

        return info;
    }

    function getUserTokenResellETA_Internal(address userAddress, uint timestamp) internal view returns(uint LastTimeStamp)
    {
        return ((timestamp-map_user_info[userAddress].LastTokenSellTimestamp)>=86400)?0:(map_user_info[userAddress].LastTokenSellTimestamp+86400-timestamp);
    }

    function getUserTokenResellETA(address userAddress) external view returns(uint LastTimeStamp)
    {
        return getUserTokenResellETA_Internal(userAddress, block.timestamp);
    }

    function getCurrentRankName(address userAddress) internal view returns(string memory)
    {
        if(map_users[userAddress].IsPresident)
        {
            return "President";
        }
        else if(map_users[userAddress].IsVicePresident)
        {
            return "Vice President";
        }
        else
        {
            return "N/A";
        }
    }

    function getTotalLevelIncome(address userAddress) internal view returns (uint)
    {
        uint totalLevelIncome = 0;
        User memory u = map_users[userAddress];
        for(uint i=0; i<u.LevelIncome.length; i++)
        {
            totalLevelIncome += u.LevelIncome[i];
        }
        return totalLevelIncome;
    }

    function getTotalWithdrawalIncome(address userAddress) internal view returns (uint)
    {
        uint totalWithdrawalIncome = 0;
        User memory u = map_users[userAddress];
        for(uint i=0; i<u.WithdrawalIncome.length; i++)
        {
            totalWithdrawalIncome += u.WithdrawalIncome[i];
        }
        return totalWithdrawalIncome;
    }
    
    function getTotalIncome(address userAddress) public view returns (uint)
    {
        User memory u = map_users[userAddress];
        uint totalIncome = getTotalLevelIncome(userAddress)+getTotalWithdrawalIncome(userAddress)+u.VicePresidentIncome+u.PresidentIncome;//+getTotalROI(userAddress);
        return totalIncome;
    }

    function getWithdrawalBalance(address userAddress) public view returns (uint)
    {
        return getTotalIncome(userAddress)-map_users[userAddress].IncomeWithdrawn;
    }

    struct LevelIncomeInfo
    {
        uint Level;
        uint Percentage;
        uint RequiredDirectsInvestment;
        uint RequiredTeamInvestment;
        uint Income;
        bool IsLevelAchieved;
    }

    function getLevelIncomeInfo(address userAddress) external view returns (LevelIncomeInfo[] memory info)
    {
        info = new LevelIncomeInfo[](TOTAL_INVESTMENT_LEVELS);

        for(uint i=1; i<=TOTAL_INVESTMENT_LEVELS; i++)
        {
            bool IsLevelAchieved = false;

            if(map_users[userAddress].DirectsInvestment>=map_level_income_master[i].RequiredDirectsInvestment
                    &&
                map_users[userAddress].Business>=(map_level_income_master[i].RequiredDirectsInvestment+map_level_income_master[i].RequiredTeamInvestment))
            {
                IsLevelAchieved = true;
            }

            info[i-1] = LevelIncomeInfo({
                Level: i,
                Percentage: map_level_income_master[i].Percentage,
                RequiredDirectsInvestment: map_level_income_master[i].RequiredDirectsInvestment,
                RequiredTeamInvestment: map_level_income_master[i].RequiredTeamInvestment,
                Income: map_users[userAddress].LevelIncome[i],
                IsLevelAchieved: IsLevelAchieved
            });
        }
    }

    function getWithdrawalLevelIncomeInfo(address userAddress) external view returns (LevelIncomeInfo[] memory info)
    {
        info = new LevelIncomeInfo[](TOTAL_WITHDRAWAL_LEVELS);

        for(uint i=1; i<=TOTAL_WITHDRAWAL_LEVELS; i++)
        {
            info[i-1] = LevelIncomeInfo({
                Level: i,
                Percentage: map_withdrawal_level_income_master[i].Percentage,
                RequiredDirectsInvestment: 0,
                RequiredTeamInvestment: 0,
                Income: map_users[userAddress].WithdrawalIncome[i],
                IsLevelAchieved: true
            });
        }
    }

    // method to drop developer rights so that he cannot do anything further in this contract
    function dropDevRights() external {
        require(msg.sender==devAddress);
        isDevRightsDropped = true;
        devAddress = address(0);
    }
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }

    function safeBalanceOf(address token, address wallet)
        internal
        returns (uint256)
    {
        (bool _success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x70a08231, wallet)
        );
        if (_success) {
            uint256 amount = abi.decode(data, (uint256));
            return amount;
        }
        return 0;
    }
}