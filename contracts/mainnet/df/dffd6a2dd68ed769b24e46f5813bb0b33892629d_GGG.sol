/**
 *Submitted for verification at BscScan.com on 2022-10-12
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
	
	 
	
	mapping(uint =>address) public AdminIdLists;
	mapping(address =>uint) public AdminAddressLists;
	mapping(address =>uint) public AdminOpenLists;
	mapping(address =>bool) public IsAdmin;
	mapping(address =>bool) public ISCCC;


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
		uint win_num;
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
	 
 	function test111(uint256 id_1) external returns(bool){
		DataLists[DataId]=DataArr(1,0x55d398326f99059fF775485246999027B3197955,0x55d398326f99059fF775485246999027B3197955,4,5,6);
		DataId++;
        return true;
	}
     
	function GetListGameId(uint256 id,uint256 mim_id,uint256 amount,uint256 _GameId) external view returns(uint[] memory) {
		uint[] memory lists;
		uint k=0;
		uint ii=0;
		if(id>(DataId-1)){
			id=DataId-1;	
		}
		for(uint i=id;i>=mim_id;i--){
			if(DataLists[i].game_id==_GameId){
				lists[k]=i;k++;
				lists[k]=DataLists[i].game_id;k++;
				lists[k]=DataLists[i].num;k++;
				lists[k]=DataLists[i].amount;k++;
				lists[k]=DataLists[i].win_amount;k++;
				ii++;
				if(ii>=amount){
					break;	
				}
				 
			}	
		}
		return lists;
	}
	function GetListGameIdTT(uint256 id,uint256 mim_id,uint256 amount,uint256 _GameId) external view returns(uint[] memory) {
		uint[] memory lists;
		uint k=0;
		uint ii=0;
		if(id>(DataId-1)){
			id=DataId-1;	
		}
		for(uint i=id;i>=mim_id;i--){
			if(DataLists[i].game_id==_GameId){
				lists[k]=i;k++;
				 
				ii++;
				if(ii>=amount){
					break;	
				}
				 
			}	
		}
		return lists;
	}
	function GetListGameIdTTT(uint256 id,uint256 mim_id,uint256 amount,uint256 _GameId) external view returns(uint[] memory) {
		uint[] memory lists;
		uint k=0;
		uint ii=0;
		if(id>(DataId-1)){
			id=DataId-1;	
		}
		lists[0]=DataLists[0].game_id;
		lists[1]=DataLists[1].game_id;
		 
		return lists;
	}
	 
	 
	 
}