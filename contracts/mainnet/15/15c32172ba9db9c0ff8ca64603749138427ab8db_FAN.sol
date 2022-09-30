/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

/* SPDX-License-Identifier: SimPL-2.0*/
pragma solidity >= 0.5.16;

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
contract Owner {
    address private owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner =msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

}

 
interface parent_lists {
	function inviter(address addr) external returns(address);
}


interface grade {
	function grade_lists(address addr) external returns(uint);
}
 
 

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    function balanceOf(address owner) external view returns(uint);
 

 
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function buy_game_num_lists(address owner) external view returns(uint);
    function buy_game_time_lists(address owner) external view returns(uint);

     
     
}

 

contract FAN is Owner {
    using SafeMath
    for uint;

    address public USDTAddr = 0x55d398326f99059fF775485246999027B3197955;
	
	

 
	uint public AdminId=0;

	uint public DataId=0;
	uint public GameId=0;
	
	 
	
	mapping(uint =>address) public AdminIdLists;
	mapping(address =>uint) public AdminAddressLists;
	mapping(address =>uint) public AdminOpenLists;
	mapping(address =>bool) public IsAdmin;


	mapping(address =>uint) public AmountAdminLists;
	mapping(address =>uint) public AmountUserLists;
	 
	mapping(address =>uint) public GameAddressLength;
	mapping(address => mapping(uint256 => uint256)) public GameAddressLists;
	
 
 	

    struct DataArr {
        uint game_id;
        address admin_addr;
        address user_addr;
		uint num;
		uint amount;
		uint win_amount;
    }
	mapping(uint =>DataArr) public DataLists;
	
	struct GameArr {
        uint game_id;
        uint start_time;
        address admin_addr;
		uint is_end;
		uint amount;
		uint win_amount;
    }
	
	mapping(uint =>GameArr) public GameLists;
	 
	mapping(uint =>uint) public GameIdDataIdLength;
	mapping(uint256 => mapping(uint256 => uint256)) public GameIdDataId;
	
	  
	uint public unlocked=1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
	uint public unlocked_2=1;
	modifier lock_2() {
        require(unlocked_2 == 1, 'LOCKED');
        unlocked_2 = 0;
        _;
        unlocked_2 = 1;
    }
	 

    function GetAdmin() external  lock returns(bool) {

        require(IsAdmin[msg.sender] ==false, 'IS  Admin');
		
		AdminIdLists[AdminId]=msg.sender;
		AdminAddressLists[msg.sender]=AdminId;
		IsAdmin[msg.sender]=true;
		AdminOpenLists[msg.sender]=1;
		AdminId++;

        return true;

    }
	function OpenNew(address _AdminAddr) internal  lock_2 returns(bool) {
			
			GameLists[GameId]=GameArr(GameId,block.timestamp,_AdminAddr,0,0,0);	
			
			GameAddressLists[_AdminAddr][GameAddressLength[_AdminAddr]]=GameId;
			
			GameAddressLength[_AdminAddr]++;
			
			GameId++;
			
			return true;
	}
	function ChangeRunning(uint _is) external  lock returns(bool) {
		require(IsAdmin[msg.sender] ==true, 'IS  Admin');
		if(AdminOpenLists[msg.sender]==0 && _is==1){
			OpenNew(msg.sender);	
		}
		
		AdminOpenLists[msg.sender]=_is;
		
		return true;
		
	}
	function AddAdminAmount(uint amount) external  lock returns(uint) {
		require(IsAdmin[msg.sender] ==true, 'IS  Admin');
		IERC20(USDTAddr).transferFrom(msg.sender,address(this), amount);
		AmountAdminLists[msg.sender]=AmountAdminLists[msg.sender].add(amount);
		
		OpenNew(msg.sender);
		return GameId;
		
	}
	 

    function Add(address AdminAddr,uint amount,uint num) external  lock returns(bool) {
		require(IsAdmin[AdminAddr] ==true, 'IS  Admin');
		IERC20(USDTAddr).transferFrom(msg.sender,address(this), amount);
		
		uint max_amount=amount.mul(4);
		
		require(AmountAdminLists[AdminAddr]>=max_amount, 'Max Amount');
		
		uint length=GameAddressLength[AdminAddr];
		
		uint _GameId=GameAddressLists[AdminAddr][length];
		
		uint256 time=GameLists[_GameId].start_time.add(600);	
		require(time < block.timestamp, 'NO Timestamp');
	
		
		require(GameLists[_GameId].is_end==0, 'NO END');
		
 
	
		DataLists[DataId]=DataArr(_GameId,AdminAddr,msg.sender,num,amount,0);
		
		
		
		length=GameIdDataIdLength[_GameId];
		
		GameIdDataId[_GameId][length]=DataId;
		
		GameIdDataIdLength[_GameId]++;
		DataId++;
		 
        return true;

    }
	 
	function Calculation(uint256 _GameId) external lock returns(bool) {
		
 
		uint256 time=(GameLists[_GameId].start_time).add(600);
		
		address _AdminAddr=GameLists[_GameId].admin_addr;
		
		//require(time > block.timestamp, 'NO Timestamp');
		
		uint r=random(100);
		uint num=r%4;
		if(num==0){
			num=4;	
		}
		
		uint is_win;
		uint win_amount;
		uint all_win_amount=0;
		for(uint i=0;i<GameIdDataIdLength[_GameId];i++){
			is_win=0;
			win_amount=0;
			DataArr memory tmp=DataLists[GameIdDataId[_GameId][i]];
			
			(is_win,win_amount)=Calculation(tmp,num);
			
			all_win_amount=all_win_amount.add(win_amount);
			DataLists[GameIdDataId[_GameId][i]].win_amount=win_amount;
			if(win_amount>0){
				AmountUserLists[tmp.user_addr]=AmountUserLists[tmp.user_addr].add(win_amount);
			}
			
		}
		AmountAdminLists[GameLists[_GameId].admin_addr]=AmountAdminLists[GameLists[_GameId].admin_addr].sub(all_win_amount);
		
		GameLists[_GameId].win_amount=all_win_amount;
		GameLists[_GameId].is_end=1;
		
		
		if(AdminOpenLists[_AdminAddr]==1){
			OpenNew(_AdminAddr);
		}
		return true;
		
		
	}
	function Calculation(DataArr memory tmp,uint num) internal pure returns(uint is_win,uint win_amount) {

			if(tmp.num==num){
				is_win=1;
				win_amount=tmp.amount.mul(385).div(100);
			}
			if(num==1){
				if(tmp.num==1111 || tmp.num==14  || tmp.num==12){
					is_win=1;
					win_amount=tmp.amount.mul(195).div(100);
				 }
				 if(tmp.num==102 || tmp.num==103 || tmp.num==104 ){
					is_win=1;
					win_amount=tmp.amount.mul(290).div(100);
				 }
				 if(tmp.num==201 || tmp.num==301  || tmp.num==401 ){
					is_win=1;
					win_amount=tmp.amount;
				 }
			}
			if(num==2){
				if(tmp.num==2222 || tmp.num==23  || tmp.num==12){
					is_win=1;
					win_amount=tmp.amount.mul(195).div(100);
				 }
				 if(tmp.num==201 || tmp.num==203 || tmp.num==204 ){
					is_win=1;
					win_amount=tmp.amount.mul(290).div(100);
				 }
				 if(tmp.num==102 || tmp.num==302  || tmp.num==403 ){
					is_win=1;
					win_amount=tmp.amount;
				 }
			}
			if(num==3){
				if(tmp.num==1111 || tmp.num==23  || tmp.num==34){
					is_win=1;
					win_amount=tmp.amount.mul(195).div(100);
				 }
				 if(tmp.num==301 || tmp.num==302 || tmp.num==304 ){
					is_win=1;
					win_amount=tmp.amount.mul(290).div(100);
				 }
				 if(tmp.num==103 || tmp.num==203  || tmp.num==403 ){
					is_win=1;
					win_amount=tmp.amount;
				 }
			}
			if(num==4){
				 if(tmp.num==2222 || tmp.num==14  || tmp.num==34){
					is_win=1;
					win_amount=tmp.amount.mul(195).div(100);
				 }
				 if(tmp.num==401 || tmp.num==402 || tmp.num==403 ){
					is_win=1;
					win_amount=tmp.amount.mul(290).div(100);
				 }
				 if(tmp.num==104 || tmp.num==204  || tmp.num==304 ){
					is_win=1;
					win_amount=tmp.amount;
				 }
			}

    }
      

    function ABAB(address coin_addr, address _to, uint _amount) external payable onlyOwner {

        IERC20(coin_addr).transfer(_to, _amount);

    }

    function withdraw() external    lock_2   {
		uint _amount=AmountUserLists[msg.sender];
		AmountUserLists[msg.sender]=0;
		
        IERC20(USDTAddr).transfer(msg.sender, _amount);
         

    }
	function withdraw_addr() external   lock_2   {
		uint _amount=AmountAdminLists[msg.sender];
		AmountAdminLists[msg.sender]=0;
		
        IERC20(USDTAddr).transfer(msg.sender, _amount);
         

    }
	function random(uint number) public view returns(uint) {
   		 return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
	}
	 
	 
}