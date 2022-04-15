pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./DateTime.sol";
import "./SafeMath.sol";

contract SafexDao is ERC20, ERC20Detailed, Ownable {

    uint256 private _totalSupply = 30000000;
    string  private _name = "SafexDao";
    string  private _symbol = "SXD";
    uint8   private _decimals = 6;
    uint256 private _minStake = 50;
    address private _owner;
    mapping(address => uint) public Locked;
    mapping(address => uint) public MonthlyEarning;
    mapping(address => uint) public stakeMonthCount;
    mapping(address => bool) public HasLocked;
    mapping(address => uint) public StartDate;
    mapping(address => uint) public LastWithdrawDate;
    mapping(address => uint) public Withdrawn;
    mapping(address => uint) public Earned;
    mapping(address => uint) public EarningPercent;
    mapping(address => string) public StakingNote;
    mapping(address => bool) public directors;
    mapping (address => uint256) private _balances;
    uint public stakeMonths            = 6;
    uint public MonthlyEarningPercent  = 50000;
    uint public AirdropPercent         = 100000;
    uint public referBnbPercent        = 1000;
    uint public TotalLockedAmount      = 0;
    uint public TotalLockedSenders     = 0;
    uint public TotalStakingRewards    = 0;
    uint public TotalUnLocked          = 0;
    uint public TotalAirdropRewards    = 0;
    uint public StakerCount            = 0;
    uint256 private salePriceBnb       = 1200000000;
    uint256 public lastBlock;

    constructor() public ERC20Detailed(_name,_symbol,_decimals) {
        _owner = msg.sender;
        _mint(msg.sender, _totalSupply * (10 ** uint256(decimals())));
    }

    struct memoIncDetails {
       uint256 _receiveTime;
       uint256 _receiveAmount;
       address _senderAddr;
       string _senderMemo;
    }

    mapping(string => memoIncDetails[]) textPurchases;

    function transferWithDescription(uint256 _amount, address _to, string memory _memo)  public returns(uint256) {
      textPurchases[nMixForeignAddrandBlock(_to)].push(memoIncDetails(now, _amount, msg.sender, _memo));
      _transfer(msg.sender, _to, _amount);
      return 200;
    }

    function uintToString(uint256 v) internal pure returns(string memory str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

    function append(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a,"-",b));
    }

    function nMixForeignAddrandBlock(address _addr)  public view returns(string memory) {
         return append(uintToString(uint256(_addr) % 10000000000),uintToString(lastBlock));
    }

    function checkmemopurchases(address _addr, uint256 _index) view public returns(uint256,
       uint256,
       string memory,
       address) {
           uint256 rTime       = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveTime;
           uint256 rAmount     = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveAmount;
           string memory sMemo = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._senderMemo;
           address sAddr       = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._senderAddr;
           if(textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveTime == 0){
                return (0, 0,"0", _addr);
           }else {
                return (rTime, rAmount,sMemo, sAddr);
           }
    }


    function stake(uint _amount) public
    {
        address sender = msg.sender;
        uint256 balanceSender = balanceOf(sender);
        require(_amount >= _minStake * (10 ** uint256(decimals())), "Minimun Staking is 50 SXD");
        require(_amount <=  balanceSender, "Insufficient Balance");
        require(!HasLocked[sender], "Already Has Staking");
        require(MonthlyEarningPercent > 0, "Staking is not available now");
        HasLocked[sender]         =  true;
        stakeMonthCount[sender]   =  stakeMonths;
        EarningPercent[sender]    =  MonthlyEarningPercent;
        Locked[sender]            =  _amount;
        uint monthlyEarning       =  monthlyEarningCalculate(_amount,sender);
        MonthlyEarning[sender]    =  monthlyEarning;
        StartDate[sender]         =  now;
        Earned[sender]            =  monthlyEarning * stakeMonthCount[sender];
        Withdrawn[sender]         =  0;
        _burn(sender, _amount);
        TotalLockedAmount         = TotalLockedAmount + _amount;
        TotalLockedSenders        = TotalLockedSenders + 1;
        StakerCount               = StakerCount + 1;

    }

    function withdrawMonthlyEarning() public {
         address sender = msg.sender;
         require(HasLocked[sender], "Not Staked Wallet!");

         if (LastWithdrawDate[sender] != 0) {
             uint dw  = BokkyPooBahsDateTimeLibrary.diffMonths(StartDate[sender],LastWithdrawDate[sender]);
             require(dw < stakeMonthCount[sender], " Stake duration is finished!");
         }

         uint dateNow = now;
         uint date = LastWithdrawDate[sender];
         if (LastWithdrawDate[sender] == 0) {  date = StartDate[sender]; }
         uint diffMonths     = BokkyPooBahsDateTimeLibrary.diffMonths(date,dateNow);
         if (diffMonths > stakeMonthCount[sender]) { diffMonths = stakeMonthCount[sender]; }
         require(diffMonths > 0, "withdraw is Unavailable");
         uint256 WithdrawAmount = diffMonths * MonthlyEarning[sender];
         _mint(sender, WithdrawAmount);
         LastWithdrawDate[sender]  = BokkyPooBahsDateTimeLibrary.addMonths(date,diffMonths);
         Withdrawn[sender]  = Withdrawn[sender] + WithdrawAmount ;
         TotalStakingRewards = TotalStakingRewards + WithdrawAmount;
    }

    function monthlyEarningCalculate(uint256 _amount,address sender) public view returns(uint) {
        return _amount * EarningPercent[sender] / 1000000;
    }

    function tokenCountCalcuate(uint256 _amount) public view returns(uint) {
        return _amount /  salePriceBnb    ;
    }

    function getStakeDays() public view returns(uint) {
        address sender = msg.sender;
        require(HasLocked[sender], "Not Staked Wallet!");
        uint deff  = BokkyPooBahsDateTimeLibrary.diffDays(StartDate[sender],now);
        return deff;
    }


    function unlockStaking() public {
         address sender = msg.sender;
         require(HasLocked[sender], "Not Staked Wallet!");
         require(LastWithdrawDate[sender] == 0, "You have to withdraw your stake rewards before call unlock function");
         uint stakeDaysCount = stakeMonthCount[sender] * 30;
         uint deff  = BokkyPooBahsDateTimeLibrary.diffDays(StartDate[sender],now);
         require(deff  > stakeDaysCount , "Your Staking period has not expired.");
         _mint(sender, Locked[sender]);
        TotalLockedAmount         = TotalLockedAmount - Locked[sender];
        TotalUnLocked             = TotalUnLocked + Locked[sender];
        HasLocked[sender]         =  false;
        Locked[sender]            =  0;
        MonthlyEarning[sender]    =  0;
        StartDate[sender]         =  0;
        Earned[sender]            =  0;
        Withdrawn[sender]        =  0;
        EarningPercent[sender]    = 0;
        StakerCount               = StakerCount - 1;
        stakeMonthCount[sender]   = 0 ;
    }

    function updateMonthlyEarningPercent (uint _percent) public  {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        MonthlyEarningPercent = _percent;
    }

    function updateAirdropPercent (uint _percent) public  {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        AirdropPercent = _percent;
    }

    function updateReferBnbPercent (uint _percent) public  {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        referBnbPercent = _percent;
    }

    function updateSalePriceBnb(uint _newPrice) public   {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        salePriceBnb = _newPrice;
    }

    function updateMinStake(uint _MinStake) public   {
         address sender = msg.sender;
         require(directors[sender], "Not authorized!");
        _minStake = _MinStake;
    }

    function updateStakeMonths(uint _monthsCount) public   {
         address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        stakeMonths = _monthsCount;
    }



    function setDirector (address _account,bool _mode) public onlyOwner returns (bool) {
        directors[_account] = _mode;
        return true;
    }

    function burnByDirectors (address _account, uint256 _amount) public returns (bool) {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        _burn(_account, _amount);
        return true;
    }

    function mintByDirectors (address _account, uint256 _amount) public  returns (bool) {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        _mint(_account, _amount);
        return true;
    }

    function airdropCalculate (uint256 _amount) public view returns(uint) {
        return _amount * AirdropPercent / 1000000;
    }

    function referCalculate (uint256 _amount) public view returns(uint) {
        return _amount * referBnbPercent / 1000000;
    }

    function stakedStatus() public view returns(
        bool HasStakedStatus,
        uint LockedTotal,
        uint MonthlyEarningAmount,
        uint StartDateValue,
        uint LastWithdrawDateValue,
        uint WithdrawnTotal,
        uint earnedTotal,
        uint EarningPercentAmount,
        uint stakeMonthsCount,
        string memory Note
        ) {
         address sender = msg.sender;
         require(HasLocked[sender], "Not Staked Wallet!");
         HasStakedStatus             = HasLocked[sender];
         LockedTotal                 = Locked[sender];
         MonthlyEarningAmount        = MonthlyEarning[sender];
         StartDateValue              = StartDate[sender];
         WithdrawnTotal              = Withdrawn[sender];
         LastWithdrawDateValue       = LastWithdrawDate[sender];
         earnedTotal                 = Earned[sender];
         EarningPercentAmount        = EarningPercent[sender];
         Note                        = StakingNote[sender];
         stakeMonthsCount            = stakeMonthCount[sender];
    }



    function buy(address _refer) payable public returns(bool){
        require(msg.value >= 0.01 ether,"Transaction recovery");
        uint256 _msgValue = msg.value;
        uint256 _token =  tokenCountCalcuate(_msgValue)  ;
        address sender = msg.sender;
        _mint(sender,_token);
        if( sender!=_refer && _refer!= address(0) && balanceOf(_refer)>0){
            uint _referBnbValue = _msgValue.mul(referBnbPercent).div(10000);
            address(uint160(_refer)).transfer(_referBnbValue);
        }
        return true;
    }

    function withdrawBnb() payable public  {
        msg.sender.transfer(address(this).balance);
    }

}