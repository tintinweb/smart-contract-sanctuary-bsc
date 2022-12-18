/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    } 
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function mint(address to, uint256 value) external returns (bool);
    function burnFrom(address from, uint256 value) external;
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}


contract Chickly {
    string public constant name = "Chickly NFT Collection";
    string public constant symbol = "CKLY";
    uint256 public totalSupply;
    uint256 constant MARKETING_FEE = 2;
	uint256 constant PROJECT_FEE = 10;
	uint256 constant PERCENTS_DIVIDER = 100;
	uint256[3] internal REFERRER_PAYOUT = [ 7, 2, 1 ];
    uint256 constant private busd_in_bnb = 250; 

	struct Plan {
        uint256 price;
        uint8 profit;
    }

	struct Deposit {
        uint256 amount;
        uint256 accrual;
        uint256 finish;
        uint40 start;
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
		uint8 base_percent;
        uint8 hold_percent;
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
	
	
    IERC20 private _busd;
    address private _defaultRef;
    address private _marketing;
    address private _project;
    string private _uri;
    uint24 _total_users;
    uint256 _total_bnb;
    uint256 _total_busd;
    Deposit[] internal _deposits;
    uint _last_deposit;
	mapping(address => User) private _users;
    mapping(address =>uint256[]) private _users_deposits;
    Plan[] plans;

    constructor(address busd, address payable marketing, address payable project, address payable defaultRef, string memory baseURI){
        plans.push(Plan(0.04 ether, 170));
        plans.push(Plan(0.4 ether, 180));
        plans.push(Plan(2 ether, 190));
        plans.push(Plan(12 ether, 200));
        plans.push(Plan(40 ether, 220));
        plans.push(Plan(10 ether, 170));
        plans.push(Plan(100 ether, 180));
        plans.push(Plan(500 ether, 190));
        plans.push(Plan(3000 ether, 200));
        plans.push(Plan(10000 ether, 220));
        _busd=IERC20(busd);
        _defaultRef=defaultRef;
        _marketing=marketing;
        _project=project;
        _uri=baseURI;
	}

	function invest(uint8 plan_id, uint256 amount, address referrer) public payable {
        require( plan_id <10, "Illegal plan ID");
        if (referrer==address(0) || referrer==msg.sender){
            referrer=_defaultRef;
        }
        if (_users[msg.sender].referrer==address(0)){
            _total_users++;
            _users[msg.sender].referrer=referrer;
            address ref=msg.sender;
            for(uint i;i<3;i++){
                if (_users[ref].referrer ==address(0)) break;
                _users[_users[ref].referrer].referrals[i]++;
                emit NewReferral(_users[ref].referrer, msg.sender,i+1);
                ref=_users[ref].referrer;
            }
        }
        require(amount >0 && amount<=10, "Amount must be 1..10");
        if ( plan_id <5){
            uint value=plans[plan_id].price * amount;
            require(msg.value >= value, "Not enough BNB");
            _total_bnb+=value;
            _users[msg.sender].invested_bnb+=value;
            refPaymentBNB(value);
        }
        else{
            uint value = plans[plan_id].price * amount;
            require(_busd.allowance(msg.sender, address(this)) >=value , "Not enough BUSD");
            _total_busd+=value;
            _users[msg.sender].invested_busd+=value;
            _busd.transferFrom(msg.sender, address(this), value );
            refPaymentBUSD(value);
        }
        _deposit(plan_id,amount);
	}

    function reinvest(uint8 plan_id, uint256 amount) public payable {
        require( plan_id <10, "Illegal plan ID");
        require(amount >0 && amount<=10, "Amount must be 1..10");
        User memory user_info=getUserInfo(msg.sender, uint40(block.timestamp));
        if ( plan_id <5){
            uint value=plans[plan_id].price * amount;
            require(user_info.available_bnb >= value, "Not enough BNB");
            _users[msg.sender].withdrawn_bnb+=value;
            _users[msg.sender].invested_bnb+=value;
            _total_bnb+=value;
            refPaymentBNB(value);
        }
        else{
            uint value = plans[plan_id].price * amount;
            require(user_info.available_busd >=value , "Not enough BUSD");
            _total_busd+=value;
            _users[msg.sender].invested_busd+=value;
            _users[msg.sender].withdrawn_busd+=value;
            refPaymentBUSD(value);
        }
        _deposit(plan_id,amount);
	}
    function _deposit(uint8 plan_id,uint amount) internal{
        Deposit memory deposit;
        totalSupply+=amount;
        if (_users[msg.sender].last_withdraw == 0){
            _users[msg.sender].last_withdraw=uint40(block.timestamp);
        }
        deposit.plan_id=plan_id;
        deposit.amount=amount;
        _last_deposit=block.timestamp;
        _users[msg.sender].last_deposit=uint40(_last_deposit);
        deposit.start=uint40(block.timestamp);
        uint value = plans[plan_id].price * amount;
        deposit.finish=value * plans[plan_id].profit / PERCENTS_DIVIDER;
        _users_deposits[msg.sender].push(_deposits.length);

        _deposits.push(deposit);
        _users[msg.sender].deposits_number++;
        emit NewDeposit(msg.sender, plan_id, amount);
        emit TransferSingle(address(this), address(0),msg.sender,plan_id,amount);

    }

    function withdrawProfitBNB(uint amount) external {
        User memory user_info=getUserInfo(msg.sender, uint40(block.timestamp));
        require( amount > 0 &&  amount <= user_info.available_bnb, "Not enough BNB deposits" );
        _users[msg.sender].withdrawn_bnb+=amount;
        _users[msg.sender].last_withdraw=uint40(block.timestamp);
        _transferBNB(msg.sender, amount);
        emit WithdrawBNB(msg.sender, amount);
    }

    function withdrawProfitBUSD(uint amount) external {
        User memory user_info=getUserInfo(msg.sender, uint40(block.timestamp));
        require( amount > 0 &&  amount <= user_info.available_busd, "Not enough BUSD deposits" );
        _users[msg.sender].withdrawn_busd+=amount;
        _users[msg.sender].last_withdraw=uint40(block.timestamp);
        _transferBUSD(msg.sender, amount);
        emit WithdrawBUSD(msg.sender, amount);
    }
    function withdrawRefBNB(uint amount) external {
        require( amount > 0 &&  amount <= _users[msg.sender].ref_available_bnb, "Not enough BNB bonuses" );
        _users[msg.sender].ref_withdrawn_bnb+=amount;
        _users[msg.sender].ref_available_bnb= _users[msg.sender].ref_bonus_bnb - _users[msg.sender].ref_withdrawn_bnb;
        _transferBNB(msg.sender, amount);
        emit WithdrawBonusBNB(msg.sender, amount);
    }

    function withdrawRefBUSD(uint amount) external {
        require( amount > 0 &&  amount <= _users[msg.sender].ref_available_busd, "Not enough BUSD bonuses" );
        _users[msg.sender].ref_withdrawn_busd+=amount;
        _users[msg.sender].ref_available_busd= _users[msg.sender].ref_bonus_busd - _users[msg.sender].ref_withdrawn_busd;
        _transferBUSD(msg.sender, amount);
        emit WithdrawBonusBUSD(msg.sender, amount);
    }
    

    function getContractInfo() external view returns(Siteinfo memory site_info){
        site_info.total_bnb=_total_bnb;
        site_info.total_busd=_total_busd;
        site_info.users=_total_users;
        site_info.deposits=_deposits.length;
        site_info.last_deposit=_last_deposit;
        site_info.percent = ((payable(address(this)).balance + _busd.balanceOf(address(this)) / busd_in_bnb )/ (400 ether)) * 100  /400;//0.25% per day
    }

    function getProfit(address user, uint user_deposit_id, uint40 timestamp ) internal view returns(uint profit, uint8 closed){
        uint deposit_id=_users_deposits[user][user_deposit_id];
        uint40 start=_deposits[ deposit_id ].start;
        if (start == 0 || start > timestamp) return (0,2);

        uint40 last_withdraw = _users[user].last_withdraw;
        if (last_withdraw == 0 || last_withdraw > timestamp){
            last_withdraw=timestamp;
        }
        uint40 hold_seconds = timestamp - last_withdraw;
        uint40 base_seconds = timestamp - start;
        uint8 plan_id=_deposits[ deposit_id ].plan_id;
        uint value = plans[plan_id].price * _deposits[ deposit_id ].amount;
        uint max_profit = _deposits[ deposit_id ].finish;
        uint basic_profit = value * base_seconds / (30 minutes) / 100; //1% per day
        uint hold_profit = value * hold_seconds / (30 minutes) / 2000; // 0.05% per day 
        if (hold_profit > value / 5) 
            hold_profit=value / 5;
        uint contract_profit = value * base_seconds  * ((payable(address(this)).balance + _busd.balanceOf(address(this)) / busd_in_bnb )/ (400 ether)) / (30 minutes) /400; //0.25% per day of contract balance
        profit=basic_profit + hold_profit + contract_profit;
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
        user_info.base_percent=uint8(100); // 1%
        user_info.hold_percent = uint8(hold_seconds *100 / (30 minutes) / 20); //0.05% per days 
        
        for(uint i;i<_users_deposits[user].length;i++){
            (uint profit,)=getProfit(user,i, timestamp);
            if (_deposits[ _users_deposits[user][i] ].plan_id <5){
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
        for(uint i;i<num_deposits;i++){
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
    function tradeIn(uint user_deposit_id) external payable {
        require(user_deposit_id < _users_deposits[msg.sender].length, "Illegal deposit" );
        (uint profit, uint8 closed)=getProfit(msg.sender, user_deposit_id, uint40(block.timestamp));
        require(closed == 1, "Deposit is active");
        uint deposit_id=_users_deposits[msg.sender][user_deposit_id];
        uint8 plan_id=_deposits[ deposit_id].plan_id;
        uint value = _deposits[ deposit_id ].amount * plans[plan_id].price * 9/10;
        require(value > 0, "Illegal deposit");
        if ( plan_id <5){
            require(msg.value >= value, "Not enough BNB");
            _total_bnb+=value;
            _users[msg.sender].accrual_bnb+=profit;
            refPaymentBNB(value);
        }
        else{
            require(_busd.allowance(msg.sender, address(this)) >= value , "Not enough BUSD");
            _total_busd+=value;
            _users[msg.sender].accrual_busd+=profit;
            _busd.transferFrom(msg.sender, address(this), value );
            refPaymentBUSD(value);
        }
        _deposits[ deposit_id ].start = uint40(block.timestamp);
        emit Revived(msg.sender, user_deposit_id, plan_id, _deposits[ deposit_id].amount);
    }

    function _transferBNB(address to, uint amount) internal {
        (bool success,)=to.call{value: amount}(new bytes(0));
            require(success, "Transfer failed");
    }
    function _transferBUSD(address to, uint amount) internal {
        (bool success,bytes memory data)=address(_busd).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");
    }

    function refPaymentBNB(uint amount) internal{
        address ref=msg.sender;
        for(uint i;i<REFERRER_PAYOUT.length;i++){
            if (_users[ref].referrer==address(0)) break;
            uint bonus = amount * REFERRER_PAYOUT[i] / PERCENTS_DIVIDER;
            _users[_users[ref].referrer].ref_bonus_bnb += bonus;
            _users[_users[ref].referrer].ref_available_bnb= 
                    _users[_users[ref].referrer].ref_bonus_bnb - _users[_users[ref].referrer].ref_withdrawn_bnb;
            _users[_users[ref].referrer].total_ref_bonus_bnb[i] += amount * REFERRER_PAYOUT[i] / PERCENTS_DIVIDER;
            emit RefPaymentBNB(_users[ref].referrer, msg.sender, i+1, amount, bonus, block.timestamp);
            ref=_users[ref].referrer;
        }
        _transferBNB(_marketing, amount * MARKETING_FEE / PERCENTS_DIVIDER);
        _transferBNB(_project, amount * PROJECT_FEE / PERCENTS_DIVIDER);
    }
	
    function refPaymentBUSD(uint amount) internal{
        address ref=msg.sender;
        for(uint i;i<REFERRER_PAYOUT.length;i++){
            uint bonus = amount * REFERRER_PAYOUT[i] / PERCENTS_DIVIDER;
            _users[_users[ref].referrer].ref_bonus_busd += bonus;
            _users[_users[ref].referrer].ref_available_busd= 
                    _users[_users[ref].referrer].ref_bonus_busd - _users[_users[ref].referrer].ref_withdrawn_busd;
            _users[_users[ref].referrer].total_ref_bonus_busd[i] += amount * REFERRER_PAYOUT[i] / PERCENTS_DIVIDER;
            emit RefPaymentBUSD(_users[ref].referrer, msg.sender, i+1, amount, bonus, block.timestamp);
            ref=_users[ref].referrer;
            if (ref==address(0)) break;
        }
        _transferBUSD(_marketing, amount * MARKETING_FEE / PERCENTS_DIVIDER);
        _transferBUSD(_project, amount * PROJECT_FEE / PERCENTS_DIVIDER);
    }

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory ){
            require(accounts.length == ids.length, "Illegal length");
            uint256[] memory balances=new uint256[](accounts.length);
            for(uint i;i<accounts.length;i++){
                balances[i]=balanceOf(accounts[i],ids[i]);
            }
            return balances;
        }

	function uri(uint256 id) public view  returns (string memory) {
        return bytes(_uri).length > 0 ? string(abi.encodePacked(_uri, Strings.toString(id), ".json")) : "";
    }

    function supportsInterface(bytes4 interfaceId) public pure  returns(bool) {
		return
			interfaceId == type(IERC1155).interfaceId ||
			interfaceId == type(IERC1155MetadataURI).interfaceId ||
			interfaceId == type(IERC165).interfaceId;
	}
    function balanceOf(address account, uint256 id) public view returns (uint256){
        uint amount=0;
        for(uint i;i<_users_deposits[account].length;i++){
            if (_deposits[_users_deposits[account][i]].plan_id==id)
                amount+=_deposits[_users_deposits[account][i]].amount;
        }
        return amount;
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
    
 2021 (C) https://t.me/nadozirny_s
        
*/