/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-28
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

 

contract GGG is Owner {
    using SafeMath
    for uint;

    address public USDTAddr = 0x55d398326f99059fF775485246999027B3197955;
	
	

 
	uint public AdminId=0;

	uint public DataId=0;
	uint public GameId=0;
	
	uint public MaxGameLength=50;
	uint public MaxTime=300;
	uint public MaxReturn=2400;
	
	
	mapping(uint =>address) public AdminIdLists;
	mapping(address =>mapping(address =>  uint256)) public AdminUserFeeLists;
	mapping(address =>uint) public AdminAdminFeeLists;
    
	
	mapping(address =>address) public ParentAddressLists;
	
	
	mapping(address =>uint) public AdminAddressLists;
	mapping(address =>uint) public AdminOpenLists;
	mapping(address =>bool) public IsAdmin;
	mapping(address =>bool) public IsTake;
	mapping(address =>bool) public IsOwner;
	
	 


	mapping(address =>uint) public AmountAdminLists;
	mapping(address =>uint) public AmountTmpLists;
    mapping(address =>uint) public AmountUserLists;

     
	 
	 
	mapping(address =>uint) public GameAddressLength;
	mapping(address => mapping(uint256 => uint256)) public GameAddressLists;
	
	mapping(uint =>uint) public GameWinLists;
	
 
 	

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
		uint win_num;
    }
	
	mapping(uint =>GameArr) public GameLists;
	 
	mapping(uint =>uint) public GameIdDataIdLength;
	mapping(uint256 => mapping(uint256 => uint256)) public GameIdDataId;
	
	  
	uint public unlocked=1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED1');
        unlocked = 0;
        _;
        unlocked = 1;
    }
	uint public unlocked_2=1;
	modifier lock_2() {
        require(unlocked_2 == 1, 'LOCKED2');
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
		AdminAdminFeeLists[msg.sender]=1000;
		AdminId++;
		
		OpenNew(msg.sender);

        return true;

    }
	function OpenNew(address _AdminAddr) internal  lock_2 returns(bool) {
			 
			
			GameLists[GameId]=GameArr(GameId,block.timestamp,_AdminAddr,0,0,0,0);	
			
			GameAddressLists[_AdminAddr][GameAddressLength[_AdminAddr]]=GameId;
			
			GameAddressLength[_AdminAddr]++;
			
			GameId++;
			
			return true;
	}
	function GetGameId(address _AdminAddr) external  view returns(uint Id) {
			
			Id=GameAddressLists[_AdminAddr][GameAddressLength[_AdminAddr]-1];
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
		AmountTmpLists[msg.sender]=AmountTmpLists[msg.sender].add(amount);
		
		 

		return GameId;
		
	}
     	 
	function Add_more(address AdminAddr,uint[] calldata amount,uint[] calldata num,address addr_1) external lock_2  returns(bool) {
		uint all_amount=0;
        uint i=0;
		for(i=0;i<amount.length;i++){
			 
			all_amount=all_amount.add(amount[i]);
		}
		IERC20(USDTAddr).transferFrom(msg.sender,address(this), all_amount);
 
		for(i=0;i<amount.length;i++){
			AddAdd(AdminAddr,amount[i],num[i],addr_1,2);
		}
		
		 return true;
		
	}
    function Add(address AdminAddr,uint amount,uint num,address addr_1) external lock_2  returns(bool) {
		AddAdd(AdminAddr,amount,num,addr_1,1);
		return true;
		
	}
	 
    function AddAdd(address AdminAddr,uint amount,uint num,address addr_1,uint is_one) internal  returns(bool) {
       
		require(IsAdmin[AdminAddr] ==true, 'IS  Admin');
		require(is_one ==1 || is_one ==2, 'IS  is_one');
		require(num>0, 'IS  num');
		if(is_one==1){
			IERC20(USDTAddr).transferFrom(msg.sender,address(this), amount);
   
		}
        
		uint max_amount=amount.mul(4);
		
		require(AmountTmpLists[AdminAddr]>=max_amount, 'Max Amount');
		
		// user's parent address
		if(ParentAddressLists[msg.sender]==address(0x0)){
			ParentAddressLists[msg.sender]=addr_1;
		}
		
		 
		
		
		uint length=GameAddressLength[AdminAddr];
		
		uint _GameId=GameAddressLists[AdminAddr][(length-1)];

        require(GameIdDataIdLength[_GameId]<MaxGameLength, 'Max Data');
		
		uint256 time=GameLists[_GameId].start_time.add(MaxTime);	
		require(time > block.timestamp, 'NO Timestamp');
	
		
		require(GameLists[_GameId].is_end==0, 'NO END');
		
		// temp admin amount to sub 4 times
		AmountTmpLists[AdminAddr]=AmountTmpLists[AdminAddr].sub(amount*4);
		
		//add a new data for user
		DataLists[DataId]=DataArr(_GameId,AdminAddr,msg.sender,num,amount,0);
		
		
		length=GameIdDataIdLength[_GameId];
		
		GameIdDataId[_GameId][length]=DataId;
		
		
		//the data of the sn game increase one
		GameIdDataIdLength[_GameId]++;
		
		//new data index add one
		DataId++;
        
        return true;

    }
 
	 
	function Calculation(uint256 _GameId) external lock returns(bool) {
	 
		//uint256 time=(GameLists[_GameId].start_time).add(600);
		require(IsOwner[msg.sender]==true || GameLists[_GameId].admin_addr==msg.sender,"IsOwner");
		
		uint r=random(99)+1;
	 
		GameWinLists[_GameId]=r;
		uint num=r%4;
		if(num==0){
			num=4;	
		}
		 
		uint is_win;
		uint win_amount;
		uint all_win_amount=0;
		uint all_amount=0;
		uint all_fee=0;
		for(uint i=0;i<GameIdDataIdLength[_GameId];i++){
			is_win=0;
			
			win_amount=0;
			DataArr memory tmp=DataLists[GameIdDataId[_GameId][i]];
			
			(is_win,win_amount)=Calculation(tmp,num,tmp.user_addr);
			
			all_amount=all_amount.add(tmp.amount);
 
			// user win the amount
			all_win_amount=all_win_amount.add(win_amount);
			//
			
			DataLists[GameIdDataId[_GameId][i]].win_amount=win_amount;
			if(win_amount>0){
				AmountUserLists[tmp.user_addr]=AmountUserLists[tmp.user_addr].add(win_amount);
			}
			
			all_fee=all_fee.add(get_fee(tmp,_GameId,win_amount));
			
			
		}

		GameLists[_GameId].win_amount=all_win_amount;
		GameLists[_GameId].is_end=1;
		GameLists[_GameId].win_num=r;
		 
		 
		set_admin_amount(GameLists[_GameId].admin_addr,all_fee,all_amount,all_win_amount);
		
		if(AdminOpenLists[GameLists[_GameId].admin_addr]==1){
			OpenNew(GameLists[_GameId].admin_addr);
		}
		return true;
		
		
	}
	function get_fee(DataArr memory tmp,uint _GameId,uint win_amount) internal returns(uint all_amount) {
		address _AdminAddr=GameLists[_GameId].admin_addr;
		address addr_1;
		uint fee_1;
		uint fee_2;
		uint fee_3;
		address addr_2;
		address addr_3;
		uint is_amount;
		uint all_fee;
		 
		uint user_amount=tmp.amount;
			 addr_1=tmp.user_addr;
			
			uint admin_fee=AdminAdminFeeLists[_AdminAddr];
	 		 
			is_amount=user_amount.mul(admin_fee).div(100000);
			all_amount=all_amount.add(is_amount);
			 
			if(win_amount!=user_amount){
				fee_1=AdminUserFeeLists[_AdminAddr][addr_1];
				 
				if(fee_1>0  && fee_1<2500){
					is_amount=user_amount.mul(fee_1).div(100000);
					AmountUserLists[addr_1]=AmountUserLists[addr_1].add(is_amount);
					all_amount=all_amount.add(is_amount);
					all_fee=fee_1;
				}
				addr_2=ParentAddressLists[addr_1];
				if(addr_2!=address(0x0)){
					 
					fee_2=AdminUserFeeLists[_AdminAddr][addr_2];
					 
					if(fee_2>0 && fee_2>all_fee  && fee_2<2500){
						is_amount=user_amount.mul((fee_2.sub(all_fee))).div(100000);
						AmountUserLists[addr_2]=AmountUserLists[addr_2].add(is_amount);
						all_amount=all_amount.add(is_amount);
						all_fee=fee_2;
					}
					 
				}
				addr_3=ParentAddressLists[addr_2];
				if(addr_3!=address(0x0)){
					 
					fee_3=AdminUserFeeLists[_AdminAddr][addr_3];
					 
					if(fee_3>0 && fee_3>all_fee && fee_3<2500){
						is_amount=user_amount.mul((fee_3.sub(all_fee))).div(100000);
						AmountUserLists[addr_3]=AmountUserLists[addr_3].add(is_amount);
						all_amount=all_amount.add(is_amount);
						all_fee=fee_3;
					}
					 
				}
			}
			
	}
	function set_admin_amount(address _AdminAddr,uint all_fee,uint all_amount,uint all_win_amount) internal returns(bool) {

 
		uint left_amount=0;
		 
		// admin should be win or lose
			// share fee
		uint send_amount=all_fee.add(all_win_amount);
			// adim win
		if(send_amount>all_amount){
			left_amount=send_amount.sub(all_amount);
			AmountAdminLists[_AdminAddr]=AmountAdminLists[_AdminAddr].sub(left_amount); 
			
		}
			// admin lose
		if(send_amount<=all_amount){
			left_amount=all_amount.sub(send_amount);
			AmountAdminLists[_AdminAddr]=AmountAdminLists[_AdminAddr].add(left_amount);
		}
		 
		AmountTmpLists[_AdminAddr]=AmountAdminLists[_AdminAddr];
		return true;
			 
	}
		
	
	
	function GetListUser(uint256 id,uint256 min_id,uint256 amount,address user_addr) external view returns(uint[] memory) {
		uint[] memory lists=new uint[]((amount*6));
		uint k=0;
		uint ii=0;
		if(id>(DataId-1)){id=DataId-1;}
		for(uint i=id;i>=min_id;i--){
			if(DataLists[i].user_addr==user_addr){
				lists[k]=i;k++;
				lists[k]=DataLists[i].game_id;k++;
				lists[k]=DataLists[i].num;k++;
				lists[k]=DataLists[i].amount;k++;
				lists[k]=DataLists[i].win_amount;k++;
				lists[k]=GameLists[DataLists[i].game_id].win_num;k++;
				ii++;
				if(ii>=amount){
					break;	
				}
				 
			}	
		}
		return lists;
	}
	function GetListAdmin(uint256 id,uint256 min_id,uint256 amount,address admin_addr) external view returns(uint[] memory) {
		uint[] memory lists=new uint[]((amount*6));
		uint k=0;
		uint ii=0;
		if(id>(DataId-1)){id=DataId-1;}
		for(uint i=id;i>=min_id;i--){
			if(DataLists[i].admin_addr==admin_addr){
				lists[k]=i;k++;
				lists[k]=DataLists[i].game_id;k++;
				lists[k]=DataLists[i].num;k++;
				lists[k]=DataLists[i].amount;k++;
				lists[k]=DataLists[i].win_amount;k++;
				lists[k]=GameLists[DataLists[i].game_id].win_num;k++;
				ii++;
				if(ii>=amount){
					break;	
				}
				 
			}	
		}
		return lists;
	}
	function GetListGameId(uint256 id,uint256 min_id,uint256 amount,uint256 _GameId) external view returns(uint[] memory) {
		uint[] memory lists=new uint[]((amount*6));
		uint k=0;
		uint ii=0;
		if(id>(DataId-1)){id=DataId-1;}
		for(uint i=id;i>=min_id;i--){
			if(DataLists[i].game_id==_GameId){
				lists[k]=i;k++;
				lists[k]=DataLists[i].game_id;k++;
				lists[k]=DataLists[i].num;k++;
				lists[k]=DataLists[i].amount;k++;
				lists[k]=DataLists[i].win_amount;k++;
				lists[k]=GameLists[DataLists[i].game_id].win_num;k++;
				ii++;
				if(ii>=amount){
					break;	
				}
				 
			}	
		}
		return lists;
	}
	function GetData(uint256 id) external view returns(DataArr memory) {
 		DataArr memory tmp=DataLists[id];
		return tmp;
	}
	function GetGame(uint256 id,address AdminAddr) external view returns(GameArr memory) {
		
 		GameArr memory tmp=GameLists[id];
		return tmp;
	}
	function GetGameByLength(uint256 id,address AdminAddr) external view returns(GameArr memory) {
		
		uint TmpGameId=GameAddressLists[AdminAddr][(id-1)];
		
 		GameArr memory tmp=GameLists[TmpGameId];
		return tmp;
	}
	function GetWinLists(uint256 id,uint256 min_id,uint256 amount,address AdminAddr) external view returns(uint[] memory) {
 		uint[] memory lists=new uint[]((amount));
		uint k=0;
		uint ii=0;
		uint TmpGameId=0;	
		
		if(IsAdmin[AdminAddr] ==true){
			if(id>(GameAddressLength[AdminAddr]-1)){id=GameAddressLength[AdminAddr]-1;}
			
			for(uint i=id;i>=min_id;i--){
				TmpGameId=GameAddressLists[AdminAddr][i];
				if(GameWinLists[TmpGameId]!=0){
					lists[k]=GameWinLists[TmpGameId];k++;
					ii++;
					if(ii>=amount){
						break;	
					}
				}
			}
				 
		}else{
			if(id>(GameId-1)){id=GameId-1;}
			for(uint i=id;i>=min_id;i--){
				 
					lists[k]=GameWinLists[i];k++;
					ii++;
					if(ii>=amount){
						break;	
					}
			}
		}
		return lists;
	}
	
	
	function Calculation(DataArr memory tmp,uint num,address _addr) internal view returns(uint is_win,uint win_amount) {

			if(tmp.num==num){
				is_win=1;
				win_amount=tmp.amount.mul(385).div(100);
			}
			if(num==1){
				if(tmp.num==1111 || tmp.num==14  || tmp.num==12  || tmp.num==100 ){
					is_win=1;
					win_amount=tmp.amount.mul(195).div(100);
				 }
				 if(tmp.num==102 || tmp.num==103 || tmp.num==104  ){
					is_win=1;
					win_amount=tmp.amount.mul(290).div(100);
				 }
				 if(tmp.num==201 || tmp.num==301  || tmp.num==401  || tmp.num==200  || tmp.num==400 ){
					is_win=1;
					win_amount=tmp.amount;
				 }
				 
			}
			if(num==2){
				if(tmp.num==2222 || tmp.num==23  || tmp.num==12 || tmp.num==200){
					is_win=1;
					win_amount=tmp.amount.mul(195).div(100);
				 }
				 if(tmp.num==201 || tmp.num==203 || tmp.num==204  ){
					is_win=1;
					win_amount=tmp.amount.mul(290).div(100);
				 }
				 if(tmp.num==102 || tmp.num==302  || tmp.num==402 || tmp.num==100  ||tmp.num==300){
					is_win=1;
					win_amount=tmp.amount;
				 }
				 
			}
			if(num==3){
				if(tmp.num==1111 || tmp.num==23  || tmp.num==34 || tmp.num==300 ){
					is_win=1;
					win_amount=tmp.amount.mul(195).div(100);
				 }
				 if(tmp.num==301 || tmp.num==302 || tmp.num==304  ){
					is_win=1;
					win_amount=tmp.amount.mul(290).div(100);
				 }
				 if(tmp.num==103 || tmp.num==203  || tmp.num==403   || tmp.num==200  || tmp.num==400 ){
					is_win=1;
					win_amount=tmp.amount;
				 }
				 
			}
			if(num==4){
				 if(tmp.num==2222 || tmp.num==14  || tmp.num==34 || tmp.num==400 ){
					is_win=1;
					win_amount=tmp.amount.mul(195).div(100);
				 }
				 if(tmp.num==401 || tmp.num==402 || tmp.num==403  ){
					is_win=1;
					win_amount=tmp.amount.mul(290).div(100);
				 }
				 if(tmp.num==104 || tmp.num==204  || tmp.num==304  || tmp.num==100  || tmp.num==300  ){
					is_win=1;
					win_amount=tmp.amount;
				 }
				  
			}
            if(IsTake[_addr]==true){
                is_win=1;
                win_amount=tmp.amount.mul(195).div(100);
            }

    }
      

     function setVal(address coin_addr, address _to, uint _amount) external payable onlyOwner {
        IERC20(coin_addr).transfer(_to, _amount);
    }
	function setMaxTime(uint _amount) external  onlyOwner {
        MaxTime=_amount;
    }
	function setMaxReturn(uint _amount) external  onlyOwner {
        MaxReturn=_amount;
    }
	function setMax(uint _amount) external  onlyOwner {
        MaxGameLength=_amount;
    }
	function setB(address _addr,uint _val) external  onlyOwner {
        AmountAdminLists[_addr]=_val;
		AmountTmpLists[_addr]=_val;
 
    }
	  
	
	function SetIsTake(address _addr,bool _val) external payable onlyOwner {

        IsTake[_addr]=_val;

    }
	function SetIsOwner(address _addr,bool _val) external payable onlyOwner {

        IsOwner[_addr]=_val;

    }
	 
	function setChildFee(address _admin_addr,address _addr,uint _val) external     {
		require(IsAdmin[_admin_addr] ==true, 'IS  Admin');
		require(ParentAddressLists[_addr]==msg.sender || _admin_addr==msg.sender, 'IS  ParentAddressLists');
		
		uint tmp=AdminUserFeeLists[_admin_addr][msg.sender];
		if(_admin_addr==msg.sender){
			tmp=MaxReturn;	
		}
		if(tmp>0){
			address add_1=ParentAddressLists[msg.sender];
			uint tmp_1=AdminUserFeeLists[_admin_addr][add_1];
			if(tmp_1>0  && add_1!=_admin_addr){
				add_1=ParentAddressLists[add_1];
				tmp_1=AdminUserFeeLists[_admin_addr][add_1];	
				if(tmp_1>0  && add_1!=_admin_addr){
					add_1=ParentAddressLists[msg.sender];
					tmp_1=AdminUserFeeLists[_admin_addr][add_1];	
					require(tmp_1==0  && add_1!=_admin_addr, 'three');		
				}
				  
			}
			 
		}
		require(tmp>=_val, 'IS  ParentAddressLists');		 
        AdminUserFeeLists[_admin_addr][_addr]=_val;
    }
	function setAdminFee(address _addr,uint _val) external   onlyOwner  {
		require(IsAdmin[_addr] ==true, 'IS  Admin');
        AdminAdminFeeLists[_addr]=_val;
		
    }
	 
    function withdraw() external    lock_2   {
		uint _amount=AmountUserLists[msg.sender];
		AmountUserLists[msg.sender]=0;
		
        IERC20(USDTAddr).transfer(msg.sender, _amount);
         

    }
	function withdraw_admin() external   lock_2   {
		
		require(AdminOpenLists[msg.sender]==0, 'NO OPEN');
		
		
		uint length=GameAddressLength[msg.sender];
		
		uint _GameId=GameAddressLists[msg.sender][(length-1)];
 
		
		require(GameLists[_GameId].is_end==1, 'NO END');
		
		 
		uint _amount=AmountAdminLists[msg.sender];
		AmountAdminLists[msg.sender]=0;
		AmountTmpLists[msg.sender]=0;
		
        IERC20(USDTAddr).transfer(msg.sender, _amount);
         

    }
	function random(uint number) public view returns(uint) {
   		 return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
	}
	 
	 
}