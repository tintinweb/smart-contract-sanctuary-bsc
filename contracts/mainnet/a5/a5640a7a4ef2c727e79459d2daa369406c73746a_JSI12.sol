/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

pragma solidity ^ 0.6.2;

 interface IERC20 {
 	function totalSupply() external pure returns(uint256);
    function decimals() external view returns (uint8);
 	function balanceOf(address account) external view returns(uint256);
 	function transfer(address recipient, uint256 amount) external returns(bool);
 	function allowance(address owner, address spender) external view returns(uint256);
 	function approve(address spender, uint256 amount) external returns(bool);
 	function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
 	event Transfer(address indexed from, address indexed to, uint256 value);
 	event Approval(address indexed owner, address indexed spender, uint256 value);
 }

 

 library SafeMath {
 	function add(uint256 a, uint256 b) internal pure returns(uint256) {
 		uint256 c = a + b;
 		require(c >= a, "SafeMath: addition overflow");
 		return c;
 	}

 	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
 		return sub(a, b, "SafeMath: subtraction overflow");
 	}

 	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
 		require(b <= a, errorMessage);
 		uint256 c = a - b;
 		return c;
 	}

 	function mul(uint256 a, uint256 b) internal pure returns(uint256) {
 		// benefit is lost if 'b' is also tested.
 		if (a == 0) {
 			return 0;
 		}
 		uint256 c = a * b;
 		require(c / a == b, "SafeMath: multiplication overflow");
 		return c;
 	}

 	function div(uint256 a, uint256 b) internal pure returns(uint256) {
 		return div(a, b, "SafeMath: division by zero");
 	}

 	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
 		require(b > 0, errorMessage);
 		uint256 c = a / b;
 		return c;
 	}

 	function mod(uint256 a, uint256 b) internal pure returns(uint256) {
 		return mod(a, b, "SafeMath: modulo by zero");
 	}

 	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
 		require(b != 0, errorMessage);
 		return a % b;
 	}
 }

 library Address {
 	function isContract(address account) internal view returns(bool) {
 		bytes32 codehash;
 		bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
 		assembly {
 			codehash:= extcodehash(account)
 		}
 		return (codehash != accountHash && codehash != 0x0);
 	}

 	function sendValue(address payable recipient, uint256 amount) internal {
 		require(address(this).balance >= amount, "Address: insufficient balance");
 		(bool success, ) = recipient.call {
 			value: amount
 		}("");
 		require(success, "Address: unable to send value, recipient may have reverted");
 	}

 	function functionCall(address target, bytes memory data) internal returns(bytes memory) {
 		return functionCall(target, data, "Address: low-level call failed");
 	}

 	function functionCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
 		return _functionCallWithValue(target, data, 0, errorMessage);
 	}

 	function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns(bytes memory) {
 		return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 	}

 	function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns(bytes memory) {
 		require(address(this).balance >= value, "Address: insufficient balance for call");
 		return _functionCallWithValue(target, data, value, errorMessage);
 	}

 	function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns(bytes memory) {
 		require(isContract(target), "Address: call to non-contract");
 		(bool success, bytes memory returndata) = target.call {
 			value: weiValue
 		}(data);
 		if (success) {
 			return returndata;
 		} else {
 			if (returndata.length > 0) {

 				assembly {
 					let returndata_size:= mload(returndata)
 					revert(add(32, returndata), returndata_size)
 				}
 			} else {
 				revert(errorMessage);
 			}
 		}
 	}
 }



 abstract contract Context {
 	function _msgSender() internal view virtual returns(address payable) {
 		return msg.sender;
 	}

 	function _msgData() internal view virtual returns(bytes memory) {
 		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
 		return msg.data;
 	}
 }


 contract Ownable is Context {
 	address private _owner;
 	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 	constructor() internal {
 		address msgSender = _msgSender();
 		_owner = msgSender;
 		emit OwnershipTransferred(address(0), msgSender);
 	}

 	function owner() public view returns(address) {
 		return _owner;
 	}
 	modifier onlyOwner() {
 		require(_owner == _msgSender(), "Ownable: caller is not the owner");
 		_;
 	}

 	function renounceOwnership() public virtual onlyOwner {
 		emit OwnershipTransferred(_owner, address(0));
 		_owner = address(0);
 	}

 	function transferOwnership(address newOwner) public virtual onlyOwner {
 		require(newOwner != address(0), "Ownable: new owner is the zero address");
 		emit OwnershipTransferred(_owner, newOwner);
 		_owner = newOwner;
 	}
 }



 contract JSI12 is Ownable {
 	using SafeMath
 	for uint256;

 uint256 amount = 12e16;
 address pool;
 uint256 public userlength = 0;
  address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  struct UserData {
           uint256 userid;
           address addr;
           address upline1;
           address upline2;
           address upline3;
           address upline4;
           address upline5;
           address upline6;
           address upline7;
       }
    mapping(address => uint256) public balance;
	mapping(address => uint256) public hasbeenwd;
    mapping(uint256 => address) public AddrByUserid;
    mapping(uint256 => bool) public UserIdExist;
 	mapping(address => UserData) public userInfo;
    address[] public UserList;
 
	constructor() public {
 	}

    function update_amount(uint256 a,address p ) public onlyOwner {
      if(a>0)  amount = a;
      if(p!=address(0) )  pool = p;
        
    }

     function config() public view returns(uint256,address) {
        return(amount,pool);
    }

    function withdraw() public {
      uint256 am = balance[address(msg.sender)];
      balance[address(msg.sender)] = 0;
	  hasbeenwd[address(msg.sender)]=hasbeenwd[address(msg.sender)].add(am);
      IERC20(BUSD).transfer(address(msg.sender),am);
    }
     function withdrawable() public view returns(uint256) {
      uint256 am = balance[address(msg.sender)];
      return(am);
    }

    function register(uint256 userid,uint256 upline) public {
        address useraddress = address(msg.sender);
		if(userid==1) AddrByUserid[upline]=useraddress;
        UserData storage uplinedata = userInfo[AddrByUserid[upline]];
        UserData storage user = userInfo[useraddress];
		if(UserIdExist[upline] == false && upline > 1)return;
        if(UserIdExist[userid] == false)
        if(user.userid==0){
           
            user.userid = userid;
            user.addr = useraddress;
            if(userid>1){
            IERC20(BUSD).transferFrom(address(msg.sender), address(this), amount);
            user.upline1 = uplinedata.addr;
            user.upline2 = uplinedata.upline1;
            user.upline3 = uplinedata.upline2;
            user.upline4 = uplinedata.upline3;
            user.upline5 = uplinedata.upline4;
            user.upline6 = uplinedata.upline5;
            user.upline7 = uplinedata.upline6;

            balance[user.upline1] = balance[user.upline1].add(amount.div(120).mul(50));
            balance[user.upline2] = balance[user.upline2].add(amount.div(120).mul(20));
            balance[user.upline3] = balance[user.upline3].add(amount.div(120).mul(10));
            balance[user.upline4] = balance[user.upline4].add(amount.div(120).mul(5));
            balance[user.upline5] = balance[user.upline5].add(amount.div(120).mul(5));
            balance[user.upline6] = balance[user.upline6].add(amount.div(120).mul(5));
            balance[user.upline7] = balance[user.upline7].add(amount.div(120).mul(5));
            balance[pool] = balance[pool].add(amount.div(120).mul(20));


           
            }
            else
            {
            user.upline1 = useraddress;
            user.upline2 = useraddress;
            user.upline3 = useraddress;
            user.upline4 = useraddress;
            user.upline5 = useraddress;
            user.upline6 = useraddress;
            user.upline7 = useraddress;
            }


           
            AddrByUserid[userid]=useraddress;
            UserIdExist[userid] = true;
			UserList.push(useraddress);
            userlength++;
        }
    }

 }