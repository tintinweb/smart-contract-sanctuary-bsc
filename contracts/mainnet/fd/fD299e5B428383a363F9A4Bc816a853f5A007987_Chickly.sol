/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

// SPDX-License-Identifier: MIT
/*

                      _____ _    _ _____ _____ _  ___  __     __
                     / ____| |  | |_   _/ ____| |/ / | \ \   / /
                    | |    | |__| | | || |    | ' /| |  \ \_/ / 
                    | |    |  __  | | || |    |  < | |   \   /  
                    | |____| |  | |_| || |____| . \| |____| |   
                     \_____|_|  |_|_____\_____|_|\_\______|_|   

                            .7?!:                                        
                        ^~!?Y?JGG??7~.                           .          
                    ~J~^..YYYJ?777!~^.                     .::^          
                        ..   7J??77??JJ7:                    ^^^^^          
                        ..GG777GB#@&&BY~.                 :^^^^^.::.      
                        ^B&PGBJ5&@@@@@Y7#&#B?          :.  ^~~~~^^^^:.      
                    :YB~?BG#&@@@@@@J&@7^J#B.       .^: :!!~~~~~^^^.      
                    .?  .7P5?Y5PB&@@&#!   7G~       ^~~^!7!~~~~~~~:       
                    :Y75##[email protected]#G7^75!^       !!~777!~!!~!!^.:      
                    ^?B#[email protected]@BY?Y5!^      .777???~!7!!!~^^.      
                    [email protected]@@@@@B5YYGG~  :.:??7JJ7!?777~~~^       
                    J#575#[email protected]@@@@&@@@@@@@G::~!JJ7YY!JJ?7!!!!^  .    
                    ~##GJ7G####&&[email protected]@@@@@@@&&@@&&5?7YY?5J?YY7!77!!^::^.   
                5&PPP?~G&@@@@[email protected]@@@@@@@@@@@&BPYY5JP?Y5J7?!~^~~~^^^   
                P&BG7!~7&@G#@@@Y57!:[email protected]@@[email protected]@@&&#BGPG&@#BB#BYJ7!!!!!!~~~:. 
                P#B##PYP&@&[email protected]@@@@[email protected]@@@@&@@@&BGGB#@@@@@@@&G#Y75??J!!7~^^ 
                ##5B#B5#@@@@@@&&@@@@@@@@@@@@@@@@#&@@@@@@#&#&&&[email protected]#!P?!!!.
                &B5B#BB&@@@@@@&[email protected]@@#@@@@G&&@&PPBB&@&&@@@@BG&@@BGP&&YJGJYYG5:
                !B#BBB#&&&[email protected]@@@@@@@@@@&@B5PB##@&#@@G&@@@@@@#[email protected]&B&&PP#PPBJ&B:
                ?PGYBB#&@[email protected]@&&@&[email protected]@@&@&P&&#G#@@@@@5&@@@@@@#BB#&&B#[email protected]
                GB5Y5BBG&&&#&PP&&&#G#[email protected]@@@@@@&@@5&@@@@@@@&@&PG&@GYYPP&#^ 
                PBBBG55P5G55#GP5P#P#BG&&&@@@@@@@@@@[email protected]&&@@@@&BB&&BPBGGBP.  
                Y#BGBBB#BB#GGB&@#5&@@@@@@@@@@@@@@@@&75#&&&&##&&@#5GB5557    
                Y#BBBBB##@@@@@@@@@@@@@@@@@@&@@@@@&@@@@PG##BBB####B#BPJ~     
                .Y#BBBBB#&#@&&@@@@&@@@@@@@@@@@@@@&@@@@@GPGB###BP5P##PJG.    
                .G#BBBB###@&@@@@@@@@&@@@@@@@@@@@@@@@&@@&BPGGGGG5PBB#&&^    
                J&BGB##&&@@@@@@@&@@@@@@&@@@@@@@@@@@@@@&#&&G&&&#####Y     
                    YBBB##B#G&@&&@@@@@@@@@&@@@@@@&@@@&@@#B&&##&######J      
                    !BBBBB#BB#&&&&@&&&&&@@@&&@@@@@@&#####&&#####B#B:       
                    ~5PGGPB##########&##&&#B&&&&&####B###########~        
                    .5P55GBBB#######&#######################BBP~         
                        .PP5PP5PGGPB###BG###########B######G5GGJ.           
                        .?BPPP555JY5PGGG##B#B#BGBBGGGG5GBJPJ^~.            
                        ^.J5BB555Y?Y5J!~~~7YGGGPPYPGP5~ .                
                            ~555^  .        .^^.. ~PP5                   
                        .:^^!5BGY:                 7BG5~                  
                        !JG#BGB!               !J5B#GG^                   
                        .JY!JG~                ^?GG?GJ                    
                            !:                  ~! ~5.                    

*/

pragma solidity ^0.8.7;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}

contract Chickly {
    string public constant name = "Chickly NFT Collection";
    string public constant symbol = "CKLY";
    uint256 constant MARKETING_FEE = 3;
	uint256 constant PROJECT_FEE = 10;
	uint256 constant PERCENTS_DIVIDER = 100;
	uint256[3] internal REFERRER_PAYOUT = [ 7, 2, 1 ];
    uint256 constant private busd_in_bnb = 300; 
    uint256 constant private MAX_HOLD_DEPOSIT = 400;  // 400/2000 = 0.20 = 20%
    uint256 constant private CONTRACT_BONUS=135 ether; // every 150 BNB for contract, includes fee 
    uint256 constant private CONTRACT_BONUS_PERCENT=10; //0.1% per every 150 BNB
    uint256 constant private MAX_CONTRACT_PERCENT=700; //7%
    uint256 constant private PAYMENT_PERIOD = 1 days; //production

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    
    uint256 public totalSupply;

	struct Plan {
        uint256 price;
        uint8 profit;
    }

	struct Deposit {
        uint256 amount;
        uint256 accrual;
        uint256 finish;
        uint40 start;
        uint40 updated;
		uint8 plan_id;
        uint8 closed;
	}

    struct Siteinfo{
        uint percent;
        uint users;
        uint deposits;
        uint total_bnb;
        uint total_busd;
        uint last_deposit;
    }

	struct User {
        uint256 ref_bonus_bnb;
        uint256 ref_bonus_busd;
		address referrer;
        uint256 invested_bnb;
        uint256 invested_busd;
        uint256 available_bnb;
        uint256 available_busd;
        uint256 withdrawn_bnb;
        uint256 withdrawn_busd;
        uint256 accrual_bnb;
        uint256 accrual_busd;
        uint256 ref_available_bnb;
        uint256 ref_available_busd;
        uint256 ref_withdrawn_bnb;
        uint256 ref_withdrawn_busd;
        uint deposits_number;
        uint40 last_withdraw;
        uint40 last_deposit;
		uint16 base_percent;
        uint16 hold_percent;
        uint256[3] total_ref_bonus_bnb;
        uint256[3] total_ref_bonus_busd;
        uint256[3] referrals;
	}

    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event WithdrawBNB(address indexed user, uint256 amount);
    event WithdrawBUSD(address indexed user, uint256 amount);
    event WithdrawBonusBNB(address indexed user, uint256 amount);
    event WithdrawBonusBUSD(address indexed user, uint256 amount);
    event Revived(address indexed user, uint256 depositId, uint8 plan, uint256 amount);
    event NewReferral(address indexed referrer, address indexed referral, uint256 indexed level);
	event RefPaymentBNB(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount, uint256 bonus, uint256 timestamp);
	event RefPaymentBUSD(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount, uint256 bonus, uint256 timestamp);
	
	
    address private _busd;
    uint24 _total_users;
    uint256 _total_bnb;
    uint256 _total_busd;
    Deposit[] internal _deposits;
    uint _last_deposit;
    uint256 private _status = _NOT_ENTERED;
	mapping(address => User) private _users;
    mapping(address =>uint256[]) private _users_deposits;
    Plan[] plans;
    address[3] _owners=[
        0xA064594A86F1AbbF12b6194487bd0C60183A712f,
        0xE6f52e5f23c3DE93f9f9aA65C62E327A66Ac1DE5,
        0xE54BDf3B70f99Ed82040767d5635331c64C96e5C
    ];
    address constant private MARKETING_FEE_WALLET = 0xAfcFdAbeb94e9A8707433b33B3008D25a67470e0;
    address constant private DEFAULT_REF_WALLET=0xE6f52e5f23c3DE93f9f9aA65C62E327A66Ac1DE5;
    address constant private PROJECT_WALLET=0x221F09028A753B6302FBC55682544a68ECF8808c;
    string private _uri="https://chickly.io/metadata/";

    modifier onlyOwner{
        require(msg.sender == _owners[0] 
        || msg.sender == _owners[1] 
        || msg.sender == _owners[2] 
        ,"Not authorized");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    constructor(address busd){
        //BUSD plans
        plans.push(Plan(10 ether, 140));
        plans.push(Plan(50 ether, 145));
        plans.push(Plan(100 ether, 150));
        plans.push(Plan(500 ether, 155));
        plans.push(Plan(1000 ether, 160));
        //VIP BUSD plans
        plans.push(Plan(2000 ether, 170));
        plans.push(Plan(5000 ether, 180));
        plans.push(Plan(10000 ether, 190));
        plans.push(Plan(15000 ether, 200));
        plans.push(Plan(25000 ether, 220));
        
        //BNB plans
        plans.push(Plan(0.04 ether, 140));
        plans.push(Plan(0.2 ether, 145));
        plans.push(Plan(0.4 ether, 150));
        plans.push(Plan(2 ether, 155));
        plans.push(Plan(4 ether, 160));
        //VIP BNB plans
        plans.push(Plan(8 ether, 170));
        plans.push(Plan(20 ether, 180));
        plans.push(Plan(40 ether, 190));
        plans.push(Plan(60 ether, 200));
        plans.push(Plan(100 ether, 220));
      
        _busd=busd;
	}
    function checkVIPBUSD(uint8 plan_id) view internal {
        string memory error = "Wrong plan";
        uint limit=_total_bnb * busd_in_bnb + _total_busd;
        if (plan_id < 5) return;
        require(plan_id < 6 && limit >  1000000 ether, error);
        require(plan_id < 7 && limit >  2000000 ether, error);
        require(plan_id < 8 && limit >  5000000 ether, error);
        require(plan_id < 9 && limit >  7000000 ether, error);
        require(plan_id < 10 && limit > 10000000 ether, error);
    }
    function checkVIPBNB(uint8 plan_id) view internal {
        string memory error = "Wrong plan";
        uint limit=_total_bnb * busd_in_bnb + _total_busd;
        if (plan_id < 15) return;
        require(plan_id < 16 && limit >  1000000 ether, error);
        require(plan_id < 17 && limit >  2000000 ether, error);
        require(plan_id < 18 && limit >  5000000 ether, error);
        require(plan_id < 19 && limit >  7000000 ether, error);
        require(plan_id < 20 && limit > 10000000 ether, error);
    }
	function invest(uint8 plan_id, uint256 amount, address referrer) external payable {
        require( plan_id <plans.length, "Illegal plan ID");
        if (referrer==address(0) || referrer==msg.sender){
            referrer=DEFAULT_REF_WALLET;
        }
        if (_users[msg.sender].referrer==address(0)){
            _total_users++;
            _users[msg.sender].referrer=referrer;
            address ref=msg.sender;
            for(uint i=0;i<3;i++){
                if (_users[ref].referrer ==address(0)) break;
                _users[_users[ref].referrer].referrals[i]++;
                emit NewReferral(_users[ref].referrer, msg.sender,i+1);
                ref=_users[ref].referrer;
            }
        }
        require(amount >0 && amount<=10, "Wrong Amount");
        if ( plan_id>9){
            checkVIPBNB(plan_id);
            uint value=plans[plan_id].price * amount;
            require(msg.value >= value, "Not enough BNB");
            _total_bnb+=value;
            _users[msg.sender].invested_bnb+=value;
            refPaymentBNB(value);
        }
        else{
            checkVIPBUSD(plan_id);
            uint value = plans[plan_id].price * amount;
            uint allowance=IERC20(_busd).allowance(msg.sender, address(this));
            require(allowance >=value , "Not enough BUSD");
            _total_busd+=value;
            _users[msg.sender].invested_busd+=value;
            safeTransferFrom(_busd,msg.sender, address(this), value );
            refPaymentBUSD(value);
        }
        _deposit(msg.sender, plan_id,amount);
	}

    function gift(address[] memory addrs, uint8[] memory plan_ids, uint[] memory amounts) external onlyOwner {
        require(addrs.length == plan_ids.length && addrs.length==amounts.length,"Illegal data");
        for(uint i=0;i<addrs.length;i++){
            _deposit(addrs[i],plan_ids[i],amounts[i]);
        }
    }
    
    function reinvest(uint8 plan_id, uint256 amount) external payable {
        require( plan_id < plans.length, "Illegal plan ID");
        require(amount >0 && amount<=10, "Wrong Amount");
        User memory user_info=getUserInfo(msg.sender, uint40(block.timestamp));
        if ( plan_id >9){
            checkVIPBNB(plan_id);
            uint value=plans[plan_id].price * amount;
            require(user_info.available_bnb >= value, "Not enough BNB");
            _users[msg.sender].withdrawn_bnb+=value;
            _users[msg.sender].invested_bnb+=value;
            _total_bnb+=value;
            refPaymentBNB(value);
        }
        else{
            checkVIPBUSD(plan_id);
            uint value = plans[plan_id].price * amount;
            require(user_info.available_busd >=value , "Not enough BUSD");
            _total_busd+=value;
            _users[msg.sender].invested_busd+=value;
            _users[msg.sender].withdrawn_busd+=value;
            refPaymentBUSD(value);
        }
        _deposit(msg.sender, plan_id,amount);
	}
    function _deposit(address user, uint8 plan_id,uint amount) internal{
        Deposit memory deposit;
        totalSupply+=amount;
        if (_users[user].last_withdraw == 0){
            _users[user].last_withdraw=uint40(block.timestamp);
        }
        deposit.plan_id=plan_id;
        deposit.amount=amount;
        _last_deposit=block.timestamp;
        _users[user].last_deposit=uint40(_last_deposit);
        deposit.start=uint40(block.timestamp);
        uint value = plans[plan_id].price * amount;
        deposit.finish=value * plans[plan_id].profit / PERCENTS_DIVIDER;
        _users_deposits[user].push(_deposits.length);
        _deposits.push(deposit);
        _users[user].deposits_number++;
        emit NewDeposit(user, plan_id, amount);
        emit TransferSingle(address(this), address(0),user,plan_id,amount);
    }

    function withdrawProfitBNB(uint amount) external nonReentrant{
        User memory user_info=getUserInfo(msg.sender, uint40(block.timestamp));
        require( amount > 0 &&  amount <= user_info.available_bnb, "Not enough BNB deposits" );
        _users[msg.sender].withdrawn_bnb+=amount;
        updateDepositsInfo(msg.sender);
        _users[msg.sender].last_withdraw=uint40(block.timestamp);
        _transferBNB(msg.sender, amount);
        _transferBNB(MARKETING_FEE_WALLET, amount * MARKETING_FEE / PERCENTS_DIVIDER);
        emit WithdrawBNB(msg.sender, amount);
    }

    function withdrawProfitBUSD(uint amount) external nonReentrant{
        User memory user_info=getUserInfo(msg.sender, uint40(block.timestamp));
        require( amount > 0 &&  amount <= user_info.available_busd, "Not enough BUSD deposits" );
        _users[msg.sender].withdrawn_busd+=amount;
        updateDepositsInfo(msg.sender);
        _users[msg.sender].last_withdraw=uint40(block.timestamp);
        safeTransfer(_busd, msg.sender, amount);
        safeTransfer(_busd, MARKETING_FEE_WALLET, amount * MARKETING_FEE / PERCENTS_DIVIDER);
        emit WithdrawBUSD(msg.sender, amount);
    }
    function withdrawRefBNB(uint amount) external nonReentrant{
        require( amount > 0 &&  amount <= _users[msg.sender].ref_available_bnb, "Not enough BNB bonuses" );
        _users[msg.sender].ref_withdrawn_bnb+=amount;
        _users[msg.sender].ref_available_bnb= _users[msg.sender].ref_bonus_bnb - _users[msg.sender].ref_withdrawn_bnb;
        _transferBNB(msg.sender, amount);
        _transferBNB(MARKETING_FEE_WALLET, amount * MARKETING_FEE / PERCENTS_DIVIDER);
        emit WithdrawBonusBNB(msg.sender, amount);
    }

    function withdrawRefBUSD(uint amount) external nonReentrant{
        require( amount > 0 &&  amount <= _users[msg.sender].ref_available_busd, "Not enough BUSD bonuses" );
        _users[msg.sender].ref_withdrawn_busd+=amount;
        _users[msg.sender].ref_available_busd= _users[msg.sender].ref_bonus_busd - _users[msg.sender].ref_withdrawn_busd;
        safeTransfer(_busd, msg.sender, amount);
        safeTransfer(_busd, MARKETING_FEE_WALLET, amount * MARKETING_FEE / PERCENTS_DIVIDER);
        emit WithdrawBonusBUSD(msg.sender, amount);
    }
    

    function getContractInfo() public view returns(Siteinfo memory site_info){
        site_info.total_bnb=_total_bnb;
        site_info.total_busd=_total_busd;
        site_info.users=_total_users;
        site_info.deposits=_deposits.length;
        site_info.last_deposit=_last_deposit;
        //0.1% per day for every 150BNB and 45k BUSD of turnover
        site_info.percent = (_total_bnb + _total_busd / busd_in_bnb )/ CONTRACT_BONUS * CONTRACT_BONUS_PERCENT;
        if (site_info.percent > MAX_CONTRACT_PERCENT) site_info.percent=MAX_CONTRACT_PERCENT;
    }

    function getProfit(address user, uint user_deposit_id, uint40 timestamp ) internal view returns(uint profit, uint8 closed){
        uint deposit_id=_users_deposits[user][user_deposit_id];
        if (_deposits[ deposit_id ].closed==1) return(_deposits[ deposit_id ].finish,1);
        uint40 start=_deposits[ deposit_id ].start;
        profit=_deposits[ deposit_id ].accrual;
        if (start == 0 || start > timestamp) return (0,0);
        if (_deposits[ deposit_id ].updated > start) start=_deposits[ deposit_id ].updated;
        uint40 last_withdraw = _users[user].last_withdraw;
        if (last_withdraw == 0 || last_withdraw > timestamp){
            last_withdraw=timestamp;
        }
        uint hold_offset = 0;
        if (start>last_withdraw && _deposits[ deposit_id ].updated==0) hold_offset=1 + (start - last_withdraw) / PAYMENT_PERIOD;
        uint40 base_seconds = timestamp - start;
        uint8 plan_id=_deposits[ deposit_id ].plan_id;
        uint value = plans[plan_id].price * _deposits[ deposit_id ].amount;
        uint max_profit = _deposits[ deposit_id ].finish;
        uint basic_profit = value * base_seconds / PAYMENT_PERIOD / 100; //1% per day
        uint hold_profit = 0;

        for(uint i=0;i< (base_seconds / PAYMENT_PERIOD);i++){
            uint interest=i + hold_offset;
            if (interest > MAX_HOLD_DEPOSIT) interest = MAX_HOLD_DEPOSIT;
            hold_profit+= value * interest / 2000; // +0.05% per day , < 20%
            if (hold_profit > max_profit) break;
        }
         
        Siteinfo memory si=getContractInfo();
        uint contract_profit = value * base_seconds / (PAYMENT_PERIOD)  * si.percent / 10000; //0.1% per day of contract balance
        profit+= basic_profit +   hold_profit + contract_profit;
        if (profit > max_profit) {
            profit=max_profit;
            closed=1;
        }else{
            closed=0;
        }
    }
    
    function getUserInfo(address user, uint40 timestamp) public view returns(User memory user_info){
        user_info=_users[user];
        uint40 last_withdraw = _users[user].last_withdraw;
        if (last_withdraw == 0 || last_withdraw > timestamp){
            last_withdraw=timestamp;
        }
        uint40 hold_seconds = timestamp - last_withdraw;
        user_info.base_percent=uint16(100); // 1%
        user_info.hold_percent = uint16(hold_seconds *100 / (PAYMENT_PERIOD) / 20); //0.05% per days 
        if (user_info.hold_percent > 2000) user_info.hold_percent=2000;
        
        for(uint i=0;i<_users_deposits[user].length;i++){
            (uint profit,)=getProfit(user,i, timestamp);
            if (_deposits[ _users_deposits[user][i] ].plan_id > 9){
                user_info.accrual_bnb += profit ;
            }else{
                user_info.accrual_busd += profit ;
            }
        }
        if (user_info.accrual_bnb > user_info.withdrawn_bnb)
            user_info.available_bnb = user_info.accrual_bnb - user_info.withdrawn_bnb;
        else user_info.available_bnb=0;
        if (user_info.accrual_busd > user_info.withdrawn_busd)
            user_info.available_busd = user_info.accrual_busd - user_info.withdrawn_busd;
        else 
            user_info.available_busd = 0;
    }
    
    function getDepositsInfo(address user, uint40 timestamp) external view returns(Deposit[] memory){
        uint num_deposits=_users_deposits[user].length;
        Deposit[] memory deposits=new Deposit[](num_deposits);
        if (num_deposits==0) return deposits;
        for(uint i=0;i<num_deposits;i++){
            deposits[i]=_deposits[_users_deposits[user][i]];
            (uint profit,uint8 closed)=getProfit(user,i,timestamp);
            if (profit > deposits[i].finish){
                deposits[i].accrual=deposits[i].finish;
                deposits[i].closed=1;
            }else{
                deposits[i].accrual=profit;
                deposits[i].closed=closed;
            }
        }
        return deposits;
    }
    function updateDepositsInfo(address user) internal{
        uint num_deposits=_users_deposits[user].length;
        for(uint i=0;i<num_deposits;i++){
            uint indx=_users_deposits[user][i];
            if (_deposits[indx].closed==1) continue;
            (uint profit,uint8 closed)=getProfit(user,i,uint40(block.timestamp));
            if (closed ==1 || profit >= _deposits[indx].finish){
                _deposits[indx].accrual=_deposits[indx].finish;
                _deposits[indx].closed=1;
            }else{
                _deposits[indx].accrual=profit;
                _deposits[indx].closed=closed;
            }
            _deposits[indx].updated=uint40(block.timestamp);
        }
    }

    function tradeIn(uint user_deposit_id) external payable {
        require(user_deposit_id < _users_deposits[msg.sender].length, "Illegal deposit" );
        (uint profit, uint8 closed)=getProfit(msg.sender, user_deposit_id, uint40(block.timestamp));
        require(closed == 1, "Deposit is active");
        uint deposit_id=_users_deposits[msg.sender][user_deposit_id];
        uint8 plan_id=_deposits[ deposit_id].plan_id;
        uint value = _deposits[ deposit_id ].amount * plans[plan_id].price * 9/10;
        require(value > 0, "Illegal deposit");
        if ( plan_id >9){
            require(msg.value >= value, "Not enough BNB");
            _total_bnb+=value;
            _users[msg.sender].accrual_bnb+=profit;
            refPaymentBNB(value);
        }
        else{
            require(IERC20(_busd).allowance(msg.sender, address(this)) >= value , "Not enough BUSD");
            _total_busd+=value;
            _users[msg.sender].accrual_busd+=profit;
            safeTransferFrom(_busd,msg.sender, address(this), value );
            refPaymentBUSD(value);
        }
        _deposits[ deposit_id ].start = uint40(block.timestamp);
        emit Revived(msg.sender, user_deposit_id, plan_id, _deposits[ deposit_id].amount);
    }

    function _transferBNB(address to, uint amount) internal {
        (bool success,)=to.call{value: amount}(new bytes(0));
            require(success, "Transfer failed");
    }

    function refPaymentBNB(uint amount) internal{
        address ref=msg.sender;
        for(uint i=0;i<REFERRER_PAYOUT.length;i++){
            if (_users[ref].referrer==address(0)) break;
            uint bonus = amount * REFERRER_PAYOUT[i] / PERCENTS_DIVIDER;
            _users[_users[ref].referrer].ref_bonus_bnb += bonus;
            _users[_users[ref].referrer].ref_available_bnb= 
                    _users[_users[ref].referrer].ref_bonus_bnb - _users[_users[ref].referrer].ref_withdrawn_bnb;
            _users[_users[ref].referrer].total_ref_bonus_bnb[i] += amount * REFERRER_PAYOUT[i] / PERCENTS_DIVIDER;
            emit RefPaymentBNB(_users[ref].referrer, msg.sender, i+1, amount, bonus, block.timestamp);
            ref=_users[ref].referrer;
        }
        _transferBNB(PROJECT_WALLET, amount * PROJECT_FEE / PERCENTS_DIVIDER);
    }
	
    function refPaymentBUSD(uint amount) internal{
        address ref=msg.sender;
        for(uint i=0;i<REFERRER_PAYOUT.length;i++){
            if (_users[ref].referrer==address(0)) break;
            uint bonus = amount * REFERRER_PAYOUT[i] / PERCENTS_DIVIDER;
            _users[_users[ref].referrer].ref_bonus_busd += bonus;
            _users[_users[ref].referrer].ref_available_busd= 
                    _users[_users[ref].referrer].ref_bonus_busd - _users[_users[ref].referrer].ref_withdrawn_busd;
            _users[_users[ref].referrer].total_ref_bonus_busd[i] += amount * REFERRER_PAYOUT[i] / PERCENTS_DIVIDER;
            emit RefPaymentBUSD(_users[ref].referrer, msg.sender, i+1, amount, bonus, block.timestamp);
            ref=_users[ref].referrer;
        }
        safeTransfer(_busd, PROJECT_WALLET, amount * PROJECT_FEE / PERCENTS_DIVIDER);
    }

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory ){
            require(accounts.length == ids.length, "Illegal length");
            uint256[] memory balances=new uint256[](accounts.length);
            for(uint i=0;i<accounts.length;i++){
                balances[i]=balanceOf(accounts[i],ids[i]);
            }
            return balances;
        }

	function uri(uint256 tokenId) external view  returns (string memory) {
        return string(abi.encodePacked(_uri, toString(tokenId), ".json"));
    }
    
    function setBaseURI(string calldata url) external onlyOwner{
        _uri=url;
    }
    function supportsInterface(bytes4 interfaceId) external pure  returns(bool) {
		return
			interfaceId == 0xd9b67a26 ||
			interfaceId == 0x0e89341c ||
			interfaceId == 0x01ffc9a7;
	}
    function balanceOf(address account, uint256 id) public view returns (uint256){
        uint amount=0;
        for(uint i=0;i<_users_deposits[account].length;i++){
            if (_deposits[_users_deposits[account][i]].plan_id==id)
                amount+=_deposits[_users_deposits[account][i]].amount;
        }
        return amount;
    }
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'Transfer failed'
        );
    }
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'Transfer failed'
        );
    }
    function toString(uint256 value) internal pure returns (string memory) {
        bytes16 _SYMBOLS = "0123456789";
        unchecked {
            uint256 length = value >9?2:1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
}


/**
        
MIT LICENSE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
    
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
    
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
    
 2023 (C) https://t.me/nadozirny_s
        
*/