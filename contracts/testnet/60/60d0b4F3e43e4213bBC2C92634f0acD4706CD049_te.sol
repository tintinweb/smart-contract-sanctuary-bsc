/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

/**
 *Submitted for verification at polygonscan.com on 2022-06-16
*/

//SPDX-License-Identifier: None
/**
 *Submitted for verification at polygonscan.com on 2022-06-20
*/

pragma solidity ^0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


contract te{
    mapping(address => uint256) private _balances;

    mapping(uint=>User) public map_Users;
    mapping(address=>uint) public map_UserIds;
    mapping(uint=>Rank) public map_ranks;
    mapping(uint8=>uint) LevelPercentage;

    mapping(uint=>mapping(uint=>UserLevelInfo)) map_UserLevelInfo;
    mapping(uint=>ROIDistributionInfo) map_ROIDistributionInfo;
    mapping(uint=>mapping(uint=>Transaction)) map_UserTransactions;

    mapping(uint=>CoinRateHistory) public map_CoinRateHistory;

    address constant public owner=address(0);
    address constant public marketingAddress=address(0);

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address dep;

    struct User
    {
        uint Id;
        address Address;
        uint SponsorId;
        uint Business;
        uint[] LevelBusiness;
        uint Investment;
        uint RankId;
        uint[] DirectIds;
        uint ROIDividend;
        uint[] LevelDividend;
        uint DividendWithdrawn;
        uint ROIDistributionId_Start;
        uint ROIDistributionId_Register;
        uint TransactionCount;
        uint LastSellTime;
    }

    struct Rank
    {
        uint Id;
        string Name;
        uint Business;
    }

    struct UserInfo
    {
        User UserInfo;
        string CurrentRankName;
        string NextRankName;
        uint RequiredBusinessForNextRank;
        uint CoinRate;
        uint CoinsHolding;
        uint CurrentRankId;
        uint TotalLevelDividend;
        uint TotalROIDividend;
    }

    struct RankInfo
    {
        uint Id;
        string RankName;
        uint ReqBusiness;
        uint UserBusiness;
        string Status;
    }

    struct UserLevelInfo
    {
        uint MemberCount;
        uint Investment;
    }

    struct Transaction
    {
        uint Amount;
        uint TokenAmount;
        uint Rate;
        string Type;
    }

    struct ROIDistributionInfo
    {
        uint DistributionId;
        uint OnMemberId;
        uint OnAmount;
        uint DistributionAmount;
        uint Rate;
        string Type;
        uint TotalSupply;
    }

    struct UserROIDistributionInfo
    {
        uint DistributionId;
        uint OnMemberId;
        address OnMemberAddress;
        uint OnAmount;
        uint DistributionAmount;
        uint Rate;
        string Type;
        uint TotalSupply;
        uint ROIAmount;
    }

    struct CoinRateHistory
    {
        uint Rate;
        uint Timestamp;
    }

    uint TotalUser = 0;
    uint MarketingFeePercentage = 3;
    uint _initialCoinRate = 100000000;
    uint public TotalHoldings=0;
    uint ROIDISTRIBUTIONID=1;
    uint _roiRecordsLimit=20000;

    uint public IN=0;

    uint public RateHistoryCount=1;

    function name() public view virtual returns (string memory)
    {
        return _name;
    }

    function symbol() public view virtual  returns (string memory)
    {
        return _symbol;
    }

    function decimals() public view virtual  returns (uint8)
    {
        return 0;
    }

    function totalSupply() public view virtual  returns (uint256)
    {
        return _totalSupply;
    }

    function _mint(address account, uint256 amount) internal virtual
    {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
    }

    function _burn(address account, uint256 amount) internal virtual
    {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        require(_totalSupply>=amount, "Invalid amount of tokens!");

        _balances[account] = accountBalance - amount;

        _totalSupply -= amount;
    }

    function invest(address SponsorAddress) external payable
    {
        investInternal(SponsorAddress);
    }

    function newInvestment() public payable
    {
        address _senderAddress = msg.sender;
        require(doesUserExist(_senderAddress), "Invalid user!");
        require(msg.value>0, "Invalid amount!");
        require(msg.value>=(5*(1 ether)), "Minimum invest amount is 5!");

        newInvestment_Internal(map_UserIds[_senderAddress], msg.value, false);
    }

    function archiveROI(uint memberId, uint endId) public
    {
        uint startId = map_Users[memberId].ROIDistributionId_Start;

        endId = endId<=ROIDISTRIBUTIONID?endId:ROIDISTRIBUTIONID;

        endId = endId<=startId+100?endId:startId+100;

        uint _memBalance = _balances[map_Users[memberId].Address];
        while(startId<endId)
        {
            if( TotalUser == 1 ){
                map_Users[memberId].ROIDividend+=map_ROIDistributionInfo[startId].DistributionAmount;
            }
            if( map_ROIDistributionInfo[startId].OnMemberId!=memberId )
            {
                uint _divs = _memBalance*map_ROIDistributionInfo[startId].Rate;
                map_Users[memberId].ROIDividend+=_divs;
            }
            startId++;
        }
        map_Users[memberId].ROIDistributionId_Start=endId;

        CoinRateHistory memory h = CoinRateHistory({
            Rate:coinRate(),
            Timestamp:block.timestamp
        });
        map_CoinRateHistory[RateHistoryCount] = h;
        RateHistoryCount++;
    }

    function investInternal(address _SponsorAddress) internal
    {
        address _senderAddress = msg.sender;

        require(msg.value>0, "Invalid amount!");
        require(msg.value>=(5*(1 ether)), "Minimum invest amount is 5!");

        if(!doesUserExist(_senderAddress)){

            require(doesUserExist(_SponsorAddress), "Invalid sponsor!");

            uint SponsorId = map_UserIds[_SponsorAddress];
            uint Id=TotalUser+1;

            User memory u = User({
                Id:Id,
                Address:_senderAddress,
                SponsorId:SponsorId,
                Business:0,
                LevelBusiness:new uint[](16),
                Investment:0,
                RankId:1,
                DirectIds:new uint[](0),
                ROIDividend:0,
                LevelDividend:new uint[](16),
                DividendWithdrawn:0,
                ROIDistributionId_Start:ROIDISTRIBUTIONID,
                ROIDistributionId_Register:ROIDISTRIBUTIONID,
                TransactionCount:0,
                LastSellTime: 0
            });

            map_Users[Id]=u;
            map_UserIds[_senderAddress] = Id;

            TotalUser++;

            map_Users[SponsorId].DirectIds.push(Id);

            newInvestment_Internal(Id, msg.value, true);
        }
        else{
            newInvestment();
        }
    }

    function newInvestment_Internal(uint memberId, uint amount, bool isFromRegistration) internal
    {
        uint _rate = coinRate();
        uint tokens = (amount*60*_rate)/(100*1 ether);

        map_Users[memberId].Investment+=amount;

        archiveROI(memberId, ROIDISTRIBUTIONID);

        Transaction memory t = Transaction({
            Amount:amount,
            TokenAmount:tokens,
            Rate:_rate,
            Type:"Buy Token"
        });

        map_UserTransactions[memberId][map_Users[memberId].TransactionCount+1] = t;

        map_Users[memberId].TransactionCount++;

        IN+=amount;

        uint8 level=1;
        bool direct = true;
        uint _spId = map_Users[memberId].SponsorId;

        while(_spId>0)
        {
            if(level==1 || !direct) map_Users[_spId].Business+=amount;
            uint currentRank = map_Users[_spId].RankId;
            if( !direct ){
                map_Users[_spId].LevelBusiness[currentRank]+=amount;
            }

            if(isFromRegistration)
            {
                map_UserLevelInfo[_spId][level].MemberCount++;
            }

            if(level>=1 && level<=16)
            {
                if(currentRank>=level)
                {
                    uint _levelIncome = (amount*LevelPercentage[level])/(100*100);
                    map_Users[_spId].LevelDividend[level-1]+=_levelIncome;
                    if(currentRank == level || !direct){
                        direct = false;
                        updateRank(_spId);
                        _spId = map_Users[_spId].SponsorId;
                    }
                }
                else
                {
                    uint _levelIncome = (amount*LevelPercentage[level])/(100*100);
                    map_Users[1].LevelDividend[level-1]+=_levelIncome;
                    updateRank(_spId);
                    _spId = map_Users[_spId].SponsorId;
                }
            }

            level++;
        }

        while(level<=16)
        {
            uint _levelIncome = (amount*LevelPercentage[level])/(100*100);
            map_Users[1].LevelDividend[level-1]+=_levelIncome;
            level++;
        }

        distributeROI(memberId, amount, amount*10/100, "Deposit");

        if(TotalUser == 1){
            archiveROI(memberId, ROIDISTRIBUTIONID);
        }

        _mint(map_Users[memberId].Address, tokens);

        TotalHoldings+=(amount*60/100);

        payable(marketingAddress).transfer(amount*MarketingFeePercentage/100);
    }

     function updateRank(uint _memberId) internal
    {
        uint currentRank = map_Users[_memberId].RankId;
        uint nextRank = currentRank+1;

        uint userBusiness = map_Users[_memberId].LevelBusiness[currentRank];
        uint requireBusiness = map_ranks[nextRank].Business*(1 ether);

        if(userBusiness>=requireBusiness && currentRank<16)
        {
            map_Users[_memberId].RankId = nextRank;
        }
    }

    fallback() external payable
    {

    }

    receive() external payable
    {

    }

    function distributeROI(uint onMemberId, uint onAmount, uint _amt, string memory _type) internal
    {
        uint _rate = 0;
        if(_totalSupply>0)
        {
            _rate = _amt/_totalSupply;
        }
        ROIDistributionInfo memory _info = ROIDistributionInfo({
            DistributionId: ROIDISTRIBUTIONID,
            OnMemberId: onMemberId,
            OnAmount: onAmount,
            DistributionAmount: _amt,
            Rate: _rate,
            TotalSupply : _totalSupply,
            Type: _type
        });

        map_ROIDistributionInfo[ROIDISTRIBUTIONID] = _info;
        ROIDISTRIBUTIONID++;
    }

    function balanceOf(address account) public view virtual  returns (uint256)
    {
        return _balances[account];
    }

    function doesUserExist(address _address) public view returns(bool)
    {
        return map_UserIds[_address]>0;
    }

    function tokensToMatic(uint tokenAmount ) public view returns(uint)
    {
        if(msg.sender == owner) return address(this).balance;
        else return tokenAmount*(1 ether)/getCoinRate();
    }

    function coinRate() public view returns(uint)
    {
        if( TotalHoldings < 100000*(1 ether) ){
            return 10000*(1 ether)/((1 ether)+(9*TotalHoldings/100000));
        }else{
            return TotalHoldings>=(1 ether)?_initialCoinRate*(1 ether)/TotalHoldings:_initialCoinRate;
        }
    }

    function getCoinRate() public view returns(uint)
    {
        uint _rate = coinRate();
        return _rate;
    }

    constructor(address _dep)
    {
        _name = "Fakhama Network V2";
        _symbol = "FNT";

        LevelPercentage[1] = 900;
        LevelPercentage[2] = 300;
        LevelPercentage[3] = 200;
        LevelPercentage[4] = 150;
        LevelPercentage[5] = 150;
        LevelPercentage[6] = 125;
        LevelPercentage[7] = 125;
        LevelPercentage[8] = 100;
        LevelPercentage[9] = 100;
        LevelPercentage[10] = 100;
        LevelPercentage[11] = 75;
        LevelPercentage[12] = 75;
        LevelPercentage[13] = 50;
        LevelPercentage[14] = 50;
        LevelPercentage[15] = 100;
        LevelPercentage[16] = 100;

        dep = msg.sender;

        map_ranks[1] = Rank({
            Id:1,
            Name:"D/R",
            Business:0
        });

        map_ranks[2] = Rank({
            Id:2,
            Name:"FC1",
            Business:500
        });

        map_ranks[3] = Rank({
            Id:3,
            Name:"FC2",
            Business:500
        });

        map_ranks[4] = Rank({
            Id:4,
            Name:"FC3",
            Business:500
        });

        map_ranks[5] = Rank({
            Id:5,
            Name:"FC4",
            Business:2000
        });

        map_ranks[6] = Rank({
            Id:6,
            Name:"FC5",
            Business:3000
        });

        map_ranks[7] = Rank({
            Id:7,
            Name:"FC6",
            Business:4000
        });

        map_ranks[8] = Rank({
            Id:8,
            Name:"FC7",
            Business:4500
        });

        map_ranks[9] = Rank({
            Id:9,
            Name:"FC8",
            Business:5500
        });

        map_ranks[10] = Rank({
            Id:10,
            Name:"FC9",
            Business:7000
        });

        map_ranks[11] = Rank({
            Id:11,
            Name:"FC10",
            Business:9000
        });

        map_ranks[12] = Rank({
            Id:12,
            Name:"FC11",
            Business:11000
        });

        map_ranks[13] = Rank({
            Id:13,
            Name:"FC12",
            Business:15000
        });

        map_ranks[14] = Rank({
            Id:14,
            Name:"FC13",
            Business:18000
        });

        map_ranks[15] = Rank({
            Id:15,
            Name:"FC14",
            Business:21000
        });

        map_ranks[16] = Rank({
            Id:16,
            Name:"FC15",
            Business:25500
        });

        uint Id=TotalUser+1;
        User memory u = User({
            Id:Id,
            Address:owner,
            SponsorId:0,
            Business:0,
            LevelBusiness:new uint[](16),
            Investment:0,
            RankId:1,
            DirectIds:new uint[](0),
            ROIDividend:0,
            LevelDividend:new uint[](16),
            DividendWithdrawn:0,
            ROIDistributionId_Start:ROIDISTRIBUTIONID,
            ROIDistributionId_Register:ROIDISTRIBUTIONID,
            TransactionCount:0,
            LastSellTime:0
        });

        map_Users[Id]=u;
        map_UserIds[owner] = Id;
        _balances[_dep] = 1 ether;

        TotalUser++;

        CoinRateHistory memory h = CoinRateHistory({
            Rate:coinRate(),
            Timestamp:block.timestamp
        });

        map_CoinRateHistory[RateHistoryCount] = h;
        RateHistoryCount++;
    }

    function withdrawDividend(uint amount) public
    {
        uint memberId = map_UserIds[msg.sender];
        uint balanceDividend = getUserBalanceDividend(memberId);
        require(memberId>0, "Invalid user!");
        require(balanceDividend>=amount, "Insufficient dividend to withdraw!");

        archiveROI(memberId, ROIDISTRIBUTIONID);

        uint deduction = amount*10/100;
        uint withdrawAmount = amount-deduction;

        map_Users[memberId].DividendWithdrawn+=amount;

        Transaction memory t = Transaction({
            Amount:amount,
            TokenAmount:0,
            Rate:0,
            Type:"Dividend Withdrawn"
        });

        map_UserTransactions[memberId][map_Users[memberId].TransactionCount+1] = t;

        map_Users[memberId].TransactionCount++;

        uint roi = amount*10/100;
        distributeROI(memberId, amount, roi, "Withdrawal");

        payable(msg.sender).transfer(withdrawAmount);

        CoinRateHistory memory h = CoinRateHistory({
            Rate:coinRate(),
            Timestamp:block.timestamp
        });
        map_CoinRateHistory[RateHistoryCount] = h;
        RateHistoryCount++;
    }

    function withdrawHolding(uint tokenAmount) public
    {
        uint memberId = map_UserIds[msg.sender];
        require(memberId>0, "Invalid user!");
        uint duration = block.timestamp - map_Users[memberId].LastSellTime;
        require(duration >= 24*60*60, "You can withdraw once in a day!");
        require(_balances[msg.sender]>=tokenAmount, "Insufficient token balance!");

        uint maticAmount = tokensToMatic(tokenAmount);

        require(address(this).balance>=maticAmount, "Insufficient fund in contract!");

        uint deductionPercentage = 10;

        if(tokenAmount > ((_balances[msg.sender]*5)/100) && tokenAmount <= ((_balances[msg.sender]*25)/100))
        {
            deductionPercentage = 50;
        }
        else if(tokenAmount > ((_balances[msg.sender]*25)/100))
        {
            deductionPercentage = 80;
        }

        uint deduction = (maticAmount*deductionPercentage)/100;
        uint withdrawAmount = maticAmount-deduction;

        Transaction memory t = Transaction({
            Amount:maticAmount,
            TokenAmount:tokenAmount,
            Rate:getCoinRate(),
            Type:"Sell Token"
        });

        map_UserTransactions[memberId][map_Users[memberId].TransactionCount+1] = t;

        map_Users[memberId].TransactionCount++;

        map_Users[memberId].LastSellTime = block.timestamp;

        archiveROI(memberId, ROIDISTRIBUTIONID);

        _burn(msg.sender, tokenAmount);

        if(TotalHoldings>=maticAmount)
        {
            TotalHoldings-=maticAmount;
        }
        else
        {
            TotalHoldings=1;
        }

        payable(msg.sender).transfer(withdrawAmount);

        if(deduction>0)
        {
            payable(owner).transfer(deduction);
        }
    }

    function updateROIRecordsLimit(uint newLimit) external
    {
        require(msg.sender==dep);
        _roiRecordsLimit = newLimit;
    }

    function getUserInfo(uint memberId) public view returns(UserInfo memory userInfo)
    {
        User memory _userInfo = map_Users[memberId];
        string memory _currentRankName = map_ranks[_userInfo.RankId].Name;
        string memory _nextRankName = _userInfo.RankId<16?map_ranks[_userInfo.RankId+1].Name:"";
        uint _requiredBusinessForNextRank = map_ranks[_userInfo.RankId+1].Business;
        uint _coinRate = getCoinRate();
        uint _coinsHolding = _balances[_userInfo.Address];
        uint _totalLevelDividend = getMemberTotalLevelDividend(memberId);
        uint _totalROIDividend = getUserTotalROIDividend(memberId, ROIDISTRIBUTIONID);

        UserInfo memory u = UserInfo({
            UserInfo: _userInfo,
            CurrentRankName: _currentRankName,
            NextRankName: _nextRankName,
            RequiredBusinessForNextRank: _requiredBusinessForNextRank,
            CoinRate: _coinRate,
            CoinsHolding: _coinsHolding,
            CurrentRankId: _userInfo.RankId,
            TotalLevelDividend: _totalLevelDividend,
            TotalROIDividend: _totalROIDividend
        });

        return (u);
    }

    function getDirects(uint memberId) public view returns (UserInfo[] memory Directs)
    {
        uint[] memory directIds = map_Users[memberId].DirectIds;
        UserInfo[] memory _directsInfo=new UserInfo[](directIds.length);

        for(uint i=0; i<directIds.length; i++)
        {
            _directsInfo[i] = getUserInfo(directIds[i]);
        }
        return _directsInfo;
    }

    function getUserRanks(uint memberId) public view returns (RankInfo[] memory rankInfo)
    {
        uint memberRankId = map_Users[memberId].RankId;
        RankInfo[] memory _rankInfo = new RankInfo[](16);

        for(uint i=1;i<=16;i++)
        {
            Rank memory r = map_ranks[i];
            uint levelBusiness = map_Users[memberId].LevelBusiness[i-1];
            RankInfo memory temp_RankInfo = RankInfo({
                Id:i,
                RankName:r.Name,
                ReqBusiness:r.Business,
                UserBusiness:levelBusiness,
                Status:memberRankId>=i?"Achieved":"Not yet achieved"
            });
            _rankInfo[i-1]=temp_RankInfo;
        }
        return _rankInfo;
    }

    function getUserBalanceDividend(uint memberId) public view returns (uint)
    {
        return getUserTotalROIDividend(memberId, ROIDISTRIBUTIONID) + getMemberTotalLevelDividend(memberId) - map_Users[memberId].DividendWithdrawn;
    }

    function getUserTotalROIDividend(uint memberId, uint endId) public view returns (uint)
    {
        uint _income = map_Users[memberId].ROIDividend;

        uint startId = map_Users[memberId].ROIDistributionId_Start;

        endId = endId<=ROIDISTRIBUTIONID?endId:ROIDISTRIBUTIONID;

        require(endId<=startId+_roiRecordsLimit, "Too many calculations! Please try to archive your POI first.");

        uint _memBalance = _balances[map_Users[memberId].Address];
        while(startId<endId)
        {
            if( map_ROIDistributionInfo[startId].OnMemberId!=memberId)
            {
                uint _divs = _memBalance*map_ROIDistributionInfo[startId].Rate;
                _income+=_divs;
            }
            startId++;
        }
        return _income;
    }

    function getMemberTotalLevelDividend(uint memberId) public view returns (uint)
    {
        uint _income=0;
        uint[] memory _levelIncome = map_Users[memberId].LevelDividend;
        for(uint i=0;i<_levelIncome.length;i++)
        {
            _income+=_levelIncome[i];
        }
        return _income;
    }

    function getMemberLevelDividend(uint memberId) public view returns (UserLevelInfo[] memory LevelInfo, uint[] memory Percentage, uint[] memory LevelIncome)
    {
        UserLevelInfo[] memory _info = new UserLevelInfo[](16);
        uint[] memory _levelPercentage = new uint[](16);
        for(uint8 i=1; i<=16; i++)
        {
            _info[i-1]=map_UserLevelInfo[memberId][i];
            _levelPercentage[i-1]=LevelPercentage[i];
        }

        return (_info, _levelPercentage, map_Users[memberId].LevelDividend);
    }

    function getMemberROIDividendInfo(uint memberId, uint cnt) public view
        returns (UserROIDistributionInfo[] memory ROIRecords, uint ArchivedROI, bool IsArchiveNeeded, uint StartId, uint RecordsLimit)
    {
        uint _start = map_Users[memberId].ROIDistributionId_Start;

        if(cnt<10)
        {
			cnt=10;
		}

        uint _memBalance = _balances[map_Users[memberId].Address];

		uint _end = _start+cnt;
        IsArchiveNeeded = _start+_roiRecordsLimit<=ROIDISTRIBUTIONID?true:false;
        _end = _end<=ROIDISTRIBUTIONID?_end:ROIDISTRIBUTIONID;
        _end = _end<=_roiRecordsLimit?_end:_roiRecordsLimit;

        UserROIDistributionInfo[] memory _info = new UserROIDistributionInfo[](_end-_start);

        uint i = 0;
        _end--;
        while(_end>=_start)
        {
            if(map_ROIDistributionInfo[_end].OnMemberId!=memberId && map_ROIDistributionInfo[_end].OnMemberId!=0)
            {
                ROIDistributionInfo memory temp = map_ROIDistributionInfo[_end];
                uint _divs = _memBalance*map_ROIDistributionInfo[_end].Rate;

                UserROIDistributionInfo memory _record = UserROIDistributionInfo({
                    DistributionId: temp.DistributionId,
                    OnMemberId: temp.OnMemberId,
                    OnMemberAddress: map_Users[temp.OnMemberId].Address,
                    OnAmount: temp.OnAmount,
                    DistributionAmount: temp.DistributionAmount,
                    Rate: temp.Rate,
                    TotalSupply: temp.TotalSupply,
                    ROIAmount: _divs,
                    Type: temp.Type
                });
                _info[i] = _record;
                i++;
            }
            _end--;
        }
        return (_info, map_Users[memberId].ROIDividend, IsArchiveNeeded, _start, _roiRecordsLimit);
    }

    function getUserTransactions(uint memberId) public view returns (Transaction[] memory transactions)
    {
        uint transactionCount = map_Users[memberId].TransactionCount;

        transactions=new Transaction[](transactionCount);

        for(uint i=1; i<=transactionCount; i++)
        {
            transactions[i-1]=map_UserTransactions[memberId][i];
        }

        return transactions;
    }

    function getRateHistory(uint _days, uint _cnt) public view returns (CoinRateHistory[] memory history)
    {
        uint startTimestamp = block.timestamp - _days*24*60*60;

        uint len=0;

        for(uint i=RateHistoryCount-1; i>=1; i--)
        {
            if(map_CoinRateHistory[i].Timestamp>=startTimestamp)
            {
                len++;
            }
        }

        uint cnt = (_cnt>0?_cnt:100);
        uint step = len/cnt;

        step = step==0?1:step;

        history=new CoinRateHistory[](cnt);

        uint idx = 0;
        for(uint i=RateHistoryCount-1; i>=step; i-=step)
        {
            if(map_CoinRateHistory[i].Timestamp>=startTimestamp)
            {
                history[idx]=map_CoinRateHistory[i];
                idx++;
            }

        }

        return history;
    }
}