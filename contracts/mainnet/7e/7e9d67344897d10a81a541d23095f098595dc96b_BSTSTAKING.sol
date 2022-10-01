/**
 *Submitted for verification at BscScan.com on 2022-10-01
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

 
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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



 contract BSTSTAKING is Ownable {
 	using SafeMath
 	for uint256;

  struct UserData {
           uint256 userid;
           uint256 uplineid;
       }

   struct HistoryDp 
        {  
           uint256 pid;
           address addr ;
           uint256 userid;
           uint256 amountbst;
           uint256 bstreward;
           uint256 rewardhasbeenwithdraw;
           uint    timedeposit;
		   uint256 blockdeposit;
           uint256 lastharvest;
		   uint256 endblock;
		   uint256 fromcompund;
		   uint256 withdrawn;
        }
    struct HistoryWd {
          address addr;
          uint256 userid;
          uint256 amountbst;
          uint  time;
        } 


 	uint256 public bststaked;
	uint256 public bstreward;
	uint256 public onemonthblock = 1000; //864000
	uint256 public minimumdeposit = 1;


	mapping(address => uint256) public UseridByAddr;
    mapping(uint256 => address) public AddrByUserid;
    mapping(uint256 => bool) public UserIdExist;
    
   
 	mapping(address => UserData) public userInfo;
	mapping(uint256 => HistoryDp) public userDeposit;
	mapping(uint256 => HistoryWd) public userWithdraw;

		struct uid{
        uint id;
    }
	mapping(address => uid[]) private _UserStakingListId;
	mapping(uint256 => uint256) public UplineIdById;
    address[] public UserList;
	uint256 public DepositLength;
	uint256 public WithdrawLength;


	


	address BSTCONTRACT = 0x1d89272821b3ACC245AcC1794e79A07D13C3E7E7;
	 

	constructor() public {
		   register(1,1);
 	}


   // calculate price based on pair reserves
     function getTokenPrice(address pairAddress, uint amount,bool nolper1) private view returns(uint)
   {
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
  
    (uint Res0, uint Res1,) = pair.getReserves();
     if(nolper1) return ((Res0*amount)/Res1);
     else return ((Res1*amount)/Res0);
   }

   function getBNBPrice()public view returns(uint256){
       return (getTokenPrice(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16,10**18,false));
   }
    function getbstPrice()public view returns(uint256){
       return (getTokenPrice(0x1300b407A2ec61556279c111DF687eA17c1fEFBB,10**18,false));
   }
   function getbstPriceUsdt()public view returns(uint256){
       uint256 rateBNB = getBNBPrice();
	   uint256 ratebst = getbstPrice();
	   return(ratebst*(rateBNB/10**18));
   }


    function set(uint256 block1month,uint256 minimum) public onlyOwner {
       onemonthblock = block1month;
	   minimumdeposit = minimum;
	 }

     function depositReward(uint256 bst) public {
       
		if(bst>0){
		uint256 bb = IERC20(BSTCONTRACT).balanceOf(address(this));
		IERC20(BSTCONTRACT).transferFrom(address(msg.sender), address(this), bst);
		uint256 ba = IERC20(BSTCONTRACT).balanceOf(address(this));
		bstreward = bstreward.add(ba.sub(bb));
		}
	 }

     function compound(uint256 pid) public {
		address useraddress = address(msg.sender);
		HistoryDp storage dp = userDeposit[pid];
		HistoryWd storage wd = userWithdraw[WithdrawLength];
		if(dp.addr != useraddress) return;//not your
	   if(dp.endblock <= block.number)return;//end staking time
		uint256 av = withdrawable(pid);

        wd.addr = useraddress;
        wd.userid = UseridByAddr[useraddress];
        wd.amountbst = av;
        wd.time = now;
		WithdrawLength++;

		bstreward = bstreward.sub(av);
		dp.rewardhasbeenwithdraw  = dp.rewardhasbeenwithdraw.add(av);
		bststaked = bststaked.add(av);
        dp.fromcompund = av;
		//add reward to staking
        dp.amountbst = dp.amountbst.add(av);
        dp.lastharvest = block.number;
	 
	    uint256 timetoend = dp.endblock.sub(block.number) ;
 		uint256 longtime  = dp.endblock.sub(dp.blockdeposit) ;

		uint256 perhreward = 75;
        if(dp.pid==2){perhreward = 150; }
        if(dp.pid==3){perhreward = 850; }
		uint256 fullreward = av.mul(perhreward).div(1000);
		fullreward = fullreward.sub(fullreward.mul(timetoend).div(longtime));
	    dp.bstreward = dp.bstreward.add(fullreward);
		
      
	 }
	function minimum() view public returns(uint256){
		return (minimumdeposit*1e18) / getbstPriceUsdt();
	}

    function deposit(uint256 pid,uint256 amount) public {
		address useraddress = address(msg.sender);
        if(pid<1)return;
        if(pid>3)return;
		if(UseridByAddr[useraddress] == 0)return;
        if(bststaked.add(amount) > bstreward) return; //not enough reward for new staker
		if(minimum() > amount) return; //minimum deposit
		uint256 bb = IERC20(BSTCONTRACT).balanceOf(address(this));
		IERC20(BSTCONTRACT).transferFrom(address(msg.sender), address(this), amount);
		uint256 ba = IERC20(BSTCONTRACT).balanceOf(address(this));
		uint256 bst = ba.sub(bb).mul(98).div(100);
        bstreward = bstreward.add(ba.sub(bb).sub(bst));
		HistoryDp storage dp = userDeposit[DepositLength];
        uint256 timeid = onemonthblock;
		uint256 perhreward = 75;
        if(pid==2){perhreward = 150; timeid = timeid.mul(2) ;}
        if(pid==3){perhreward = 850; timeid = timeid.mul(4) ;}
		//update data staking
        dp.pid = pid;
		dp.addr = useraddress;
        dp.userid = UseridByAddr[useraddress] ;
        dp.amountbst = bst;
        dp.rewardhasbeenwithdraw=0;
        dp.timedeposit= now;
		dp.blockdeposit = block.number;
        dp.lastharvest = block.number;
		dp.endblock = block.number.add(timeid);

	    //add to user data
	    dp.bstreward = bst.mul(perhreward).div(1000);
		 
		//data
		bststaked = bststaked.add(bst);
		_UserStakingListId[useraddress].push(uid(DepositLength));
		DepositLength++;

	}

  function userstakinglength(address useraddress) public view returns(uint256){
	 return _UserStakingListId[useraddress].length;
  }
    function UserStakingListId(address useraddress,uint256 pid) public view returns(uint256){
	 return _UserStakingListId[useraddress][pid].id;
  }

    function withdrawable(uint256 pid) public view returns(uint256){
	 
		HistoryDp storage dp = userDeposit[pid];
        if(dp.endblock <= block.number){
            return  dp.bstreward.sub(dp.rewardhasbeenwithdraw);
        }
        uint256 blockdivider = dp.endblock.sub(dp.lastharvest); //count block to end
        uint256 rewardperblock = dp.bstreward.sub(dp.rewardhasbeenwithdraw).div(blockdivider);//perblock reward
		uint256 unwithdrawable = rewardperblock.mul(dp.endblock.sub(block.number));
		uint256 bstrelease = dp.bstreward.sub(dp.rewardhasbeenwithdraw).sub(unwithdrawable);
	
        return(bstrelease);

	}

    function harvest(uint256 pid) public {
		address useraddress = address(msg.sender);
		if(UseridByAddr[useraddress] == 0)return;
		HistoryDp storage dp = userDeposit[pid];
		HistoryWd storage wd = userWithdraw[WithdrawLength];
		if(dp.endblock>block.number)
		if(dp.addr != useraddress) return;//not your
        uint256 av = withdrawable(pid);
        if(av==0)return;
        wd.addr = useraddress;
        wd.userid = UseridByAddr[useraddress];
        wd.amountbst = av;
        wd.time = now;
		WithdrawLength++;
 
		//data
		bstreward = bstreward.sub(av);
		dp.rewardhasbeenwithdraw  = dp.rewardhasbeenwithdraw.add(av);
		IERC20(BSTCONTRACT).transfer(dp.addr, av);
		dp.lastharvest = block.number;
		
	}

   
    function register(uint256 userid,uint256 upline) public {
        address useraddress = address(msg.sender);
		if(userid==1)AddrByUserid[upline]=useraddress;
        if(UseridByAddr[useraddress]>0)return;
        UserData storage user = userInfo[useraddress];
		if(UserIdExist[upline] == false && upline > 1)return;
        if(UserIdExist[userid] == false)
        if(user.userid==0){
            user.userid = userid;
            user.uplineid = upline;
            UplineIdById[userid] = upline;
            UserList.push(useraddress);
            UseridByAddr[useraddress] = userid;
            AddrByUserid[userid]=useraddress;
            UserIdExist[userid] = true;
        }
    }


    function ifout(uint256 pid) public view returns(uint256){
		HistoryDp storage dp = userDeposit[pid];
		if(dp.endblock<=block.number) return dp.amountbst.sub(dp.fromcompund).mul(97).div(100).add(dp.fromcompund);
		uint256 finaltiperblock = dp.amountbst.mul(30).div(100).div(dp.endblock.sub(dp.blockdeposit));
        return dp.amountbst.sub(finaltiperblock.mul(dp.endblock.sub(block.number)));
	}

    function withdraw(uint256 pid) private {
		address useraddress = address(msg.sender);
		if(UseridByAddr[useraddress] == 0)return;
		HistoryDp storage dp = userDeposit[pid];
		if(dp.endblock>block.number)
		if(dp.addr != useraddress) return;//not your
        uint256 av = ifout(pid);
		if(av==0)return;
        IERC20(BSTCONTRACT).transfer(dp.addr, av);
		bststaked = bststaked.sub(dp.amountbst);
		dp.rewardhasbeenwithdraw  = dp.bstreward;
		dp.withdrawn = dp.amountbst;
		
	}


    function endgame_check(uint256 pid) public  view returns(uint256){
		HistoryDp storage dp = userDeposit[pid];
		if(dp.endblock<=block.number){
			return 0;
		}
		return dp.endblock.sub(block.number);
	}
	function endgame(uint256 pid) public {
		if(endgame_check(pid) == 0 ){
			harvest(pid);
			withdraw(pid);
		}
	}
	 function forceendgame(uint256 pid) public {
			harvest(pid);
			withdraw(pid);
	}

 }