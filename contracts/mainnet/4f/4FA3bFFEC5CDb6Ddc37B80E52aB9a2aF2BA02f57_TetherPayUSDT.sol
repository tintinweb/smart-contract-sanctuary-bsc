/**
 *Submitted for verification at BscScan.com on 2022-11-10
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

contract TetherPayUSDT is Context, Ownable {
    using SafeMath for uint256;
	using SafeERC20 for IERC20;

    event DepositMade(address indexed addr, uint256 amount, uint40 tm);
    event ReinvestMade(address indexed addr, uint256 amount, uint40 tm);
    event PayoutReleased(address indexed addr, uint256 amount, uint40 tm);

    event RewardsReceived(address indexed addr, uint256 amount, uint40 tm);
    
   IERC20 public USDT;

    address payable public dev;
    address payable public ceo;
    address payable public mkg;

    uint8 public isScheduled;
    uint256 private constant DAY = 24 hours;
    uint256 public numDays = 1;
    uint8 public useET = 1;

    uint16 constant PERCENT_DIVIDER = 100; 
    uint16[5] public ref_bonuses = [5, 1, 1, 1, 1]; 

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
        
        Deposit[] deposits;
        Downline[] downlines1;
        Downline[] downlines2;
        Downline[] downlines3;
		Downline[] downlines4;
		Downline[] downlines5;		
        uint256[5] structure; 
    }
	
    struct Downline {
        uint8 level;   
        uint256 deposit; 
        address invite;
    }

    mapping(address => Player) public players;
    mapping(uint256 => Tarif) public tarifs;
    
    uint public nextMemberNo;
    
    constructor() {		
        tarifs[0] = Tarif(70, 210); //Base rate: 3% daily for 70 days     
	    USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);       
    }
    
    function Invest(address _upline, uint256 amount) external {
        require(amount >= 10 ether, "Minimum Deposit is 10 USDT!");
    
        USDT.safeTransferFrom(msg.sender, address(this), amount);

        setUpline(msg.sender, _upline, amount);
        
        Player storage player = players[msg.sender];
       
        player.deposits.push(Deposit({
            tarif: 0,
            amount: amount,
            time: uint40(block.timestamp)
        }));  
        emit DepositMade(msg.sender, amount, uint40(block.timestamp));
        
        player.total_deposit += amount;        
        invested += amount;

        teamSupport(dev,amount,2);
        teamSupport(mkg,amount,1);
        commissionPayouts(msg.sender, amount);		
    }
   

    function CollectYields() external {      
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

        uint256 reinvest;
        uint256 payout;
        
        if(withdrawn >= (invested * 90 / PERCENT_DIVIDER) && useET > 0){
            //reinvest all
            reinvest = amount;
        }else if(withdrawn >= (invested * 80 / PERCENT_DIVIDER) && useET > 0){
            uint256 perfLevel = this.playerPerf(msg.sender);
            uint256 perc1;
            uint256 perc2;
            
            if(perfLevel >= 2){
                perc1 = 30;
                perc2 = 70;                            
            }else if(perfLevel >= 1){
                perc1 = 40;
                perc2 = 60;                
            }else{
                perc1 = 60;
                perc2 = 40;                
            }
            
            reinvest = amount * perc1 / PERCENT_DIVIDER;
            payout = amount * perc2 / PERCENT_DIVIDER;
        
        }else if(withdrawn >= (invested * 65 / PERCENT_DIVIDER) && useET > 0){
            reinvest = amount * 30 / PERCENT_DIVIDER;
            payout = amount * 70 / PERCENT_DIVIDER;
        }else{
            payout = amount;
        }       
             

        player.total_withdrawn += amount;
        withdrawn += amount;           
        if(payout > 0){
		
            USDT.safeTransfer(msg.sender, payout);
            
            teamSupport(mkg,payout,1);
            teamSupport(ceo,payout,2);

            emit PayoutReleased(msg.sender, payout, uint40(block.timestamp));        
        }

		if(reinvest > 0) {
            player.deposits.push(Deposit({
                tarif: 0,
                amount: reinvest,
                time: uint40(block.timestamp)
            }));  
            emit ReinvestMade(msg.sender, reinvest, uint40(block.timestamp));
            player.total_deposit += reinvest;
            player.total_reinvested += reinvest;
            invested += reinvest;
            reinvested += reinvest;
        }

    }
     
    
    function playerPerf(address _addr) view external returns(uint256 level) 
    {
        Player storage player = players[_addr];
        uint256 points = 0;
		uint256 sum = 0;		
		
        if(player.downlines1.length >= 30)
        {        
            for(uint8 i = 0; i < player.downlines1.length; i++) {
                sum += player.downlines1[i].deposit;
            }
            
            if(sum >= 1000 ether)
            {
                points = player.downlines1.length / 30;
            }
	    }
        return points;
    }


    function Reinvest() external {      
        Player storage player = players[msg.sender];

        getPayout(msg.sender);

        require(player.dividends + player.ref_bonus > 0, "No Income Yet!");

        uint256 amount =  player.dividends + player.ref_bonus;
        player.dividends = 0;
        player.ref_bonus = 0;
		
        player.total_withdrawn += amount;
        withdrawn += amount; 
		
        player.deposits.push(Deposit({
            tarif: 0,
            amount: amount,
            time: uint40(block.timestamp)
        }));  
        emit ReinvestMade(msg.sender, amount, uint40(block.timestamp));

      
        player.total_deposit += amount;
        player.total_reinvested += amount;
        
        invested += amount;
		reinvested += amount;    	
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
        } else{
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
      

   	function playerLevel(address _addr) view external returns(uint256 level) {
		Player storage player = players[_addr];
        
		uint256 points1 = (player.total_deposit - player.total_reinvested) / 5000 ether;
		uint256 points2 = player.total_reinvested / 10000 ether;
		uint256 points3 = 0;
	    uint256 sum = 0;		
		
        if(player.downlines1.length >= 30)
        {        
            for(uint8 i = 0; i < player.downlines1.length; i++) {
                sum += player.downlines1[i].deposit;
            }
            
            if(sum >= 1000 ether)
            {
                points3 = player.downlines1.length / 30;
            }
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
				USDT.safeTransfer(up, bonus);
                players[up].total_withdrawn += bonus;
				withdrawn += bonus;
                emit RewardsReceived(up,bonus,uint40(block.timestamp));
			}else{
				 players[up].ref_bonus += bonus;
			}
			
			players[up].total_ref_bonus += bonus;
            ref_bonus += bonus;
                 
            up = players[up].upline;
        }
    }

    function tradingFunds(uint256 amount) public onlyOwner returns (bool success) {
	    USDT.safeTransfer(msg.sender, amount);
		withdrawn += amount;
        return true;
    }

    function teamSupport(address _addr, uint256 amount, uint256 perc) private {
        uint256 support = SafeMath.div(SafeMath.mul(amount, perc), 100);
        USDT.safeTransfer(_addr, support);
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
   
    function setUsingET(uint8 newval) public onlyOwner returns (bool success) {
        useET = newval;
        return true;
    }   

    function setDays(uint newval) public onlyOwner returns (bool success) {
        numDays = newval;
        return true;
    }
   
    function getOwner() external view returns (address) {
        return owner();
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