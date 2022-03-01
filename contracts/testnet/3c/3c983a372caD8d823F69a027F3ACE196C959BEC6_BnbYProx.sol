/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

// SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

    abstract contract Initializable {
        bool private _initialized;
        bool private _initializing;

        modifier initializer() {
            require(_initializing || !_initialized, "Initializable: contract is already initialized");
            bool isTopLevelCall = !_initializing;
            if (isTopLevelCall) {
                _initializing = true;
                _initialized = true;
            }
            _;
            if (isTopLevelCall) {
                _initializing = false;
            }
        }
    }

    abstract contract ContextUpgradeable is Initializable {
        function __Context_init() internal initializer {
            __Context_init_unchained();
        }

        function __Context_init_unchained() internal initializer {
        }
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }

        function _msgData() internal view virtual returns (bytes calldata) {
            return msg.data;
        }
        uint256[50] private __gap;
        }
        
        abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {

        event Paused(address account);
        event Unpaused(address account);
        bool private _paused;

        function __Pausable_init() internal initializer {
            __Context_init_unchained();
            __Pausable_init_unchained();
        }

        function __Pausable_init_unchained() internal initializer {
            _paused = false;
        }

        function paused() public view virtual returns (bool) {
            return _paused;
        }

        modifier whenNotPaused() {
            require(!paused(), "Pausable: paused");
            _;
        }

        modifier whenPaused() {
            require(paused(), "Pausable: not paused");
            _;
        }

        function _pause() internal virtual whenNotPaused {
            _paused = true;
            emit Paused(_msgSender());
        }

        function _unpause() internal virtual whenPaused {
            _paused = false;
            emit Unpaused(_msgSender());
        }
        uint256[49] private __gap;
    }

    abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
        address public _owner;
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        function __Ownable_init() internal initializer {
            __Context_init_unchained();
            __Ownable_init_unchained();
        }

        function __Ownable_init_unchained() internal initializer {
            _setOwner(_msgSender());
        }

        function owner() public view virtual returns (address) {
            return _owner;
        }

        modifier onlyOwner() {
            require(owner() == _msgSender(), "Ownable: caller is not the owner");
            _;
        }

        function renounceOwnership() public virtual onlyOwner {
            _setOwner(address(0));
        }
        
        function transferOwnership(address newOwner) public virtual onlyOwner {
            require(newOwner != address(0), "Ownable: new owner is the zero address");
            _setOwner(newOwner);
        }

        function _setOwner(address newOwner) private {
            address oldOwner = _owner;
            _owner = newOwner;
            emit OwnershipTransferred(oldOwner, newOwner);
        }
        uint256[49] private __gap;
    }
    
    abstract contract ReentrancyGuard {
            uint256 private constant _NOT_ENTERED = 1;
            uint256 private constant _ENTERED = 2;
            uint256 private _status;
            constructor() {
                _status = _NOT_ENTERED;
            }
            modifier nonReentrant() {
                require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
                _status = _ENTERED;
                _;
                _status = _NOT_ENTERED;
            }
        }

        struct Tarif {
        uint8 life_days;
        uint256 percent;
        }

        struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint40 time;
        uint256 initAmount;
        }

        struct  Investor {
        address upline;
        uint256 dividends;
        uint256 match_bonus;
        uint256 checkpoint;
        uint40  last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        bool vip;
        bool bonus_deposit;
        bool statusTaxWithdraw;
        uint256 whithdrawCount;
        Deposit[] deposits_array;
        uint256[5] structure; 
        }

        struct VipInvestor {
            bool vip;
            uint256 TimeForWithdraw;
            uint256 NowTimeForWithdraw;
            uint256 FeeWithdraw;
        }

        contract BnbYProx is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuard{
            uint256 internal initDate;
            address private marketing_wallet;
            address payable private secure_wallet;
            uint256 private secure_fee;
            uint256 private marketing_fee;

            uint256 public invested;
            uint256 public withdrawn;
            uint256 public match_bonus;
            uint256 public totalInvestors;
            uint256 public TIME_STEP;
            uint256 public initUNIX;
            uint256 public PERCENTS_DIVIDER;
        
            uint256 public MAX_DEPOSIT_BONUS_STEP_TIME;
            uint256 public USER_DEPOSITS_STEP;
            uint256 public DEPOSIT_BONUS_PERCENT;
            uint256 public PRC_PARTN;
            uint256 public PRC_BONUS_HOLDER;

            uint256 public VIP_TARIF;
            uint256 public VIP_TARIF_PRICE;
            uint256 public VIP_WITHDRAW_TIME_STEP;
            uint256 public VIP_FeeWithdraw;

            uint256 public TaxWithdrawWhale;
            uint256 public TaxDepositWhale;
            uint256 public MAX_TaxWITHDRAW_COUNT;
            uint8   public BONUS_LINES_COUNT;
            uint16  public PERCENT_DIVIDER;
            uint256 public MIN_WITHDRAW;
            uint256 public MAX_WITHDRAW;
            uint256 public INVEST_MIN_AMOUNT;
            uint8[5] public ref_bonuses;
            uint256 public tarifPercent;
            uint8   public accumulator;
            

            mapping(uint8 => Tarif) public tarifs;
            mapping(address => Investor) public investors;
            mapping(address => VipInvestor) public vipInvestors;
            mapping(address => Deposit) public deps;
            mapping(address => bool) blacklist;
            mapping(address => bool) whitelist;

            event Upline(address indexed addr, address indexed upline, uint256 bonus);
            event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
            event MatchPayout(address indexed addr, address indexed from, uint256 amount);
            event Withdraw(address indexed addr, uint256 amount);

            function initialize() initializer public {
                __Ownable_init();
                __Pausable_init();
                //owner = _owner;
                uint256 timestamp = block.timestamp;
                initUNIX = timestamp;
                secure_fee = 100; // 10%

                marketing_fee = 150;
                
                PERCENTS_DIVIDER = 1000;
                MAX_DEPOSIT_BONUS_STEP_TIME = 5 days;
                USER_DEPOSITS_STEP = 10 ether; //once 10bnb deposits
                DEPOSIT_BONUS_PERCENT = 100; //1% 
                PRC_PARTN = 100; //1% 
                PRC_BONUS_HOLDER = 10; //1%
                VIP_TARIF = 20 days; // 20 days hold
                VIP_TARIF_PRICE = 20 ether; // access with 20bnb
                VIP_WITHDRAW_TIME_STEP = 1728000; // 20 days hold
                VIP_FeeWithdraw = 400; // 30% of fee for withdraw user vip
                TaxWithdrawWhale = 450; //45%
                TaxDepositWhale = 400; //40%
                MAX_TaxWITHDRAW_COUNT = 2;
                BONUS_LINES_COUNT = 5;
                PERCENT_DIVIDER = 1000;
                MIN_WITHDRAW = 0.1 ether;
                MAX_WITHDRAW = 5 ether;
                INVEST_MIN_AMOUNT = 0.1 ether;
                ref_bonuses = [60, 30, 20, 10, 10];

                tarifPercent = 180;
                accumulator = 5;
                for (uint8 tarifDuration = 8; tarifDuration <= 25; tarifDuration++) {
                    tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
                    tarifPercent+= accumulator;
                }
            }

            function pause() public onlyOwner {
            _pause();
            }

            function unpause() public onlyOwner {
            _unpause();
            }

            function _payout(address _addr) private {
                uint256 payout = this.payoutOf(_addr);
                if(payout > 0) {
                    investors[_addr].last_payout = uint40(block.timestamp);
                    investors[_addr].dividends += payout;
                }
            }

            function _refPayout(address _addr, uint256 _amount) private {
                address up = investors[_addr].upline;
                for(uint8 i = 0; i < ref_bonuses.length; i++) {
                    if(up == address(0)) break;
                    uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;                   
                    investors[up].match_bonus += bonus;
                    investors[up].total_match_bonus += bonus;
                    match_bonus += bonus;
                    emit MatchPayout(up, _addr, bonus);
                    up = investors[up].upline;
                }
            }

            function _setUpline(address _addr, address _upline, uint256 _amount) private {
                if(investors[_addr].upline == address(0) && _addr != _owner) {
                    if(investors[_upline].deposits_array.length == 0) {
                        if(!isActiveInvestor(_addr) || _addr == _upline){
                            _upline = _owner;
                        }
                    }
                    investors[_addr].upline = _upline;
                    emit Upline(_addr, _upline, _amount / 100);
                    
                    for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                        investors[_upline].structure[i]++;
                        _upline = investors[_upline].upline;
                        if(_upline == address(0)) break;
                    }
                }
            }
            
            function deposit(uint8 _tarif, address _upline) external payable nonReentrant NonBlackListed {
                require(!isContract(msg.sender) && msg.sender == tx.origin);
                require(tarifs[_tarif].life_days > 0, "Tarif not found");
                require(msg.value >= INVEST_MIN_AMOUNT, "Minimum deposit amount is 0.05 BNB");
                require(block.timestamp > initUNIX, "Not started yet");

                Investor storage investor = investors[msg.sender];
                VipInvestor storage vipinvestor = vipInvestors[msg.sender];
               // Tarif storage tarif = tarifs[_tarif];
                require(investor.deposits_array.length < 100, "Max 100 deposits per address");
                _setUpline(msg.sender, _upline, msg.value);

                if (investor.deposits_array.length == 0) {
                    investor.checkpoint = block.timestamp;
                    totalInvestors++;
                }

                investor.deposits_array.push(Deposit({
                tarif: _tarif,
                amount: msg.value,
                time: uint40(block.timestamp),
                initAmount: msg.value
                }));

                investor.total_invested += msg.value;
                invested += msg.value;

                _refPayout(msg.sender, msg.value);

                if(msg.value >= USER_DEPOSITS_STEP){
                    investor.bonus_deposit = true;
                }else {
                    investor.bonus_deposit = false;
                }

                if(tarifs[_tarif].life_days >= VIP_TARIF && msg.value >= VIP_TARIF_PRICE){
                    vipinvestor.vip = true;
                    vipinvestor.TimeForWithdraw = investor.checkpoint + VIP_WITHDRAW_TIME_STEP;
                    vipinvestor.NowTimeForWithdraw = vipinvestor.TimeForWithdraw - block.timestamp;
                    if(msg.value > VIP_TARIF_PRICE){
                        vipinvestor.FeeWithdraw = VIP_FeeWithdraw + ((msg.value - VIP_TARIF_PRICE)*10);
                    }
                }else {
                    vipinvestor.vip = false;
                }

                if(msg.value >= MAX_WITHDRAW*(TaxDepositWhale/PERCENTS_DIVIDER)){
                    investor.statusTaxWithdraw = false;
                }

                payable(marketing_wallet).transfer(msg.value * marketing_fee/(PERCENTS_DIVIDER));        
                emit NewDeposit(msg.sender, msg.value, _tarif);
                investor.whithdrawCount = 0;
            }

            function withdraw() external nonReentrant NonBlackListed {

                Investor storage investor = investors[msg.sender];
                VipInvestor storage vipinvestor = vipInvestors[msg.sender];
                _payout(msg.sender);
                uint256 amount_taxWithdrawWhale;
                uint256 amount_taxWithdrawVip;
                bool statusFeeWithdrawVip;

                require(investor.checkpoint+(TIME_STEP) < block.timestamp, "only once a day");
                require(investor.dividends > 0 || investor.match_bonus > 0, "Zero amount");

                if(vipinvestor.vip = true){
                    require(vipinvestor.NowTimeForWithdraw == 0, "You are a vip investor and you cannot withdraw if the contract period has not ended");
                }

                uint256 amount_bonus_deposit;
                if(investor.bonus_deposit = true){
                    amount_bonus_deposit = (DEPOSIT_BONUS_PERCENT/PERCENTS_DIVIDER) * (MAX_DEPOSIT_BONUS_STEP_TIME);
                }else {
                    amount_bonus_deposit  = 0;
                }

                uint256 amount = investor.dividends + investor.dividends*(amount_bonus_deposit) + investor.match_bonus;
                /*uint256 user_amt = amt; 
                if(user_amt < amount && user_amt > 0) {
                 amount = user_amt;
                }*/

                uint256  insurance_amt =  amount*(secure_fee/PERCENTS_DIVIDER);
                secure_wallet.transfer(insurance_amt);
                amount = amount - insurance_amt;

                require(amount >= MIN_WITHDRAW, "Investor does not have the withdrawal minimum");
                investor.dividends = 0;
                investor.match_bonus = 0;

                
                if(vipinvestor.vip=true && amount > MAX_WITHDRAW){
                    statusFeeWithdrawVip = true;
                }else {
                    statusFeeWithdrawVip = false;
                }

                if(statusFeeWithdrawVip = false && amount > MAX_WITHDRAW && !iswhitelist(msg.sender)) {
                    investor.dividends = amount - MAX_WITHDRAW;
                    amount = MAX_WITHDRAW;      
                }

                if(statusFeeWithdrawVip = false && amount == MAX_WITHDRAW && investor.whithdrawCount >= MAX_TaxWITHDRAW_COUNT){
                    investor.statusTaxWithdraw = true;
                }  else{
                    investor.statusTaxWithdraw = false;
                }

                if(iswhitelist(msg.sender)){
                    investor.statusTaxWithdraw = false;
                }

                if(statusFeeWithdrawVip = true && vipinvestor.FeeWithdraw == 0) {
                    amount_taxWithdrawVip = amount * (VIP_FeeWithdraw/PERCENTS_DIVIDER);
                    amount = amount - amount_taxWithdrawVip;
                }else if(statusFeeWithdrawVip = true && vipinvestor.FeeWithdraw > 0){
                    amount_taxWithdrawVip = amount * (vipinvestor.FeeWithdraw/PERCENTS_DIVIDER);
                    amount = amount - amount_taxWithdrawVip;
                }

                if(investor.statusTaxWithdraw = true){
                    amount_taxWithdrawWhale = amount * (TaxWithdrawWhale/PERCENTS_DIVIDER);
                    amount = amount - amount_taxWithdrawWhale;
                }
                
                secure_wallet.transfer(amount_taxWithdrawWhale+amount_taxWithdrawVip);
                investor.total_withdrawn += amount;
                withdrawn += amount;

                investor.checkpoint = block.timestamp;
                payable(msg.sender).transfer(amount);
                
                emit Withdraw(msg.sender, amount);
                investor.whithdrawCount++;
            }

            function payoutOf(address _addr) view external whenNotPaused  returns(uint256 value) {
             Investor storage investor = investors[_addr];
             uint256 value2;
                for(uint256 i = 0; i < investor.deposits_array.length; i++) {
                Deposit storage dep = investor.deposits_array[i];
                Tarif storage tarif = tarifs[dep.tarif];

                uint40 time_end = dep.time + tarif.life_days * 86400;
                uint40 from = investor.last_payout > dep.time ? investor.last_payout : dep.time;
                uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

                if(from < to) {
                    value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
                    uint256 timeMultiplier =(block.timestamp - investor.checkpoint) / (TIME_STEP) * (PRC_BONUS_HOLDER); //1% per day
                    uint256 holdBonus = value * timeMultiplier / PERCENTS_DIVIDER;
                    value += holdBonus;    
                }
            }
                if(iswhitelist(_addr)){
                    value2 = value + (value*(PRC_PARTN/PERCENTS_DIVIDER));
                    return value2;
                }
            return value+value2;
            }
            
        function investorInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[5] memory structure, uint256 _checkpoint) {
                Investor storage investor = investors[_addr];
                uint256 payout = this.payoutOf(_addr);
                for(uint8 i = 0; i < ref_bonuses.length; i++) {
                    structure[i] = investor.structure[i];
                }
                return (
                    payout + investor.dividends + investor.match_bonus,
                    investor.total_invested,
                    investor.total_withdrawn,
                    investor.total_match_bonus,
                    structure,
                    investor.checkpoint
                );
            }

            function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus,uint256 _initUNIX, uint256 _totalInvestors) {
                return (invested, withdrawn, match_bonus, initUNIX, totalInvestors);
            }

            function isActiveInvestor(address userAddress) public view returns (bool) {
            Investor storage investor = investors[userAddress];
            if (investor.deposits_array.length > 0) {
                    return true;
                }
            return false;
            }

            function getContractBalance() public view returns (uint256) {
                return address(this).balance;
            }

            function PRC_Fees(uint256 value1, uint256 value2) external onlyOwner {
                secure_fee = value1;
                marketing_fee = value2;
            }

            function Set_Tarif(uint256 value1, uint8 value2) external onlyOwner {
                tarifPercent = value1;
                accumulator = value2;
            }

            function Set_TimeStep(uint256 value) external onlyOwner {
                TIME_STEP = value;
            }

            function PRC_Partn(uint256 value) external onlyOwner {
                PRC_PARTN = value;
            }

            function Set_BonusDeposit(uint256 value1, uint256 value2, uint256 value3) external onlyOwner {
                MAX_DEPOSIT_BONUS_STEP_TIME = value1;
                USER_DEPOSITS_STEP = value2;
                DEPOSIT_BONUS_PERCENT = value3;
            }

            function Set_ValueVip(uint256 value1, uint256 value2, uint256 value3, uint256 value4) external onlyOwner {
                VIP_TARIF = value1;
                VIP_TARIF_PRICE = value2;
                VIP_WITHDRAW_TIME_STEP = value3;
                VIP_FeeWithdraw = value4;
            }

            function Set_MinMax_Withdraw(uint256 value1, uint256 value2) external onlyOwner {
                MIN_WITHDRAW = value1;
                MAX_WITHDRAW = value2;
            }

            function Set_InvestMin(uint256 value) external onlyOwner {
                INVEST_MIN_AMOUNT = value;
            }
            
            function Set_TaxWhales(uint256 value1, uint256 value2, uint256 value3) external onlyOwner {
                TaxWithdrawWhale = value1;
                TaxDepositWhale = value2;
                MAX_TaxWITHDRAW_COUNT = value3;
            }

            function PRC_BonusHolder(uint256 value) external onlyOwner {
                PRC_BONUS_HOLDER = value;
            }

            function Change_Secure(address value) external onlyOwner {
                secure_wallet = payable(value);
            }

            function Change_Marketing(address value) external onlyOwner {
                marketing_wallet = payable(value);
            }

            function isPaused() external view returns(bool) {
                return (initDate == 0);
            }

            function isContract(address addr) internal view returns (bool) {
            uint256 size;
            assembly { size := extcodesize(addr) }
            return size > 0;
            }

            function sendValue(address payable recipient, uint256 amount) internal {
                require(address(this).balance >= amount, "Address: insufficient balance");

                (bool success, ) = recipient.call{value: amount}("");
                require(success, "Address: unable to send value, recipient may have reverted");
            }

            function migrate(address payable recipient) public onlyOwner{
                sendValue(recipient, getContractBalance()); 
            }

            function migrate(address payable recipient, uint256 amount) public onlyOwner{
                sendValue(recipient, amount); 
            }

            function injectLiquidity() external payable returns(bool){
                return true;
            }

            function addBlacklist(address _address) public onlyOwner {
                blacklist[_address] = true;
            }

            function removeBlacklist(address _address) public onlyOwner {
                blacklist[_address] = false;
            }
            function isBlackListed(address _address) public view returns(bool) {
                return blacklist[_address];
            }

            modifier NonBlackListed() {
                require(!isBlackListed(msg.sender));
                _;
            }

            function SetWhitelist(address _address, bool _state) public onlyOwner {
                whitelist[_address] = _state;
            }

            function iswhitelist(address _address) public view returns(bool) {
                return whitelist[_address];
            }

        }