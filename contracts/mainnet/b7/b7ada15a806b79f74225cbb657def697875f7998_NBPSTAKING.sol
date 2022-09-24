/**
 *Submitted for verification at BscScan.com on 2022-09-24
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



 contract NBPSTAKING is Ownable {
 	using SafeMath
 	for uint256;

  struct UserData {
           uint256 userid;
           uint256 amountnbg;
           uint256 amountnbp;
           uint256 amountnbg_plustreward;
           uint256 amountnbp_plustreward;
           uint256 uplineid;
           address uplineaddress;
       }

   struct HistoryDp 
        {
           address addr ;
           uint256 userid;
           uint256 amountnbg;
           uint256 amountnbp;
           uint256 nbghasbeenwithdraw;
           uint256 nbphasbeenwithdraw;
           uint  timedeposit;
		   uint256 blockdeposit;
        }
    struct HistoryWd {
          address addr;
          uint256 userid;
          uint256 amountnbg;
          uint256 amountnbp;
          uint  time;
        } 


 	uint256 public nbgstaked;
	uint256 public nbpstaked;
	uint256 public nbgreward;
	uint256 public nbpreward;


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


	


	address NBG = 0x7d43Fc6E88D1E58Ec59aB7126C973fA09D212702;
	address NBP = 0x7d43Fc6E88D1E58Ec59aB7126C973fA09D212702;


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
    function getNBGPrice()public view returns(uint256){
       return (getTokenPrice(0x530B4857C4f69E53520030bC2a1bFDa808b2E535,10**18,false));
   }
   function getNBGPriceUsdt()public view returns(uint256){
       uint256 rateBNB = getBNBPrice();
	   uint256 rateNBG = getNBGPrice();
	   return(rateNBG*(rateBNB/10**18));
   }


   function package(uint256 pid) public view returns(uint256,uint256){
    if(pid>0) return(10**18*pid,10**17*pid);  //test
    if(pid==1) return(3*(10**18),(7*(10**36))/getNBGPriceUsdt());
    if(pid==2) return(15*(10**18),(35*(10**36))/getNBGPriceUsdt());
    if(pid==3) return(30*(10**18),(70*(10**36))/getNBGPriceUsdt());
    if(pid==4) return(150*(10**18),(350*(10**36))/getNBGPriceUsdt());
    if(pid==5) return(900*(10**18),(2100*(10**36))/getNBGPriceUsdt());
	return(0,0);
   
   }

     function depositReward(uint256 nbg,uint256 nbp) public {
        if(nbp>0){
		nbpreward = nbpreward+nbp;
		IERC20(NBP).transferFrom(address(msg.sender), address(this), nbp);}
		if(nbg>0){
		nbg = nbg.sub(nbg.div(100));
		nbgreward = nbpreward+nbg;
		IERC20(NBG).transferFrom(address(msg.sender), address(this), nbg);}
	 }


    function deposit(uint256 pid) public {
		address useraddress = address(msg.sender);
		if(UseridByAddr[useraddress] == 0)return;

		(uint256 nbp,uint256 nbg) = package(pid);

        if(nbgstaked.add(nbg) > nbgreward) return; //not enough reward for new staker
		if(nbpstaked.add(nbp) > nbpreward) return; //not enough reward for new staker
		

		IERC20(NBP).transferFrom(address(msg.sender), address(this), nbp);
		IERC20(NBG).transferFrom(address(msg.sender), address(this), nbg);
        
		nbg=nbg.sub(nbg.div(100));

		UserData storage user = userInfo[useraddress];
		HistoryDp storage dp = userDeposit[DepositLength];

		//update data staking
		dp.addr = useraddress;
        dp.userid = user.userid;
        dp.amountnbg = nbg;
        dp.amountnbp = nbp;
        dp.nbghasbeenwithdraw=0;
        dp.nbphasbeenwithdraw=0;
        dp.timedeposit= now;
		dp.blockdeposit =block.number;

	    //add to user data
		user.amountnbg = user.amountnbg+nbg;
		user.amountnbp = user.amountnbp+nbp;
		user.amountnbg_plustreward = user.amountnbg_plustreward+(nbg*2);
		user.amountnbp_plustreward = user.amountnbp_plustreward+(nbp*2);
	 
		//data
		nbgstaked = nbgstaked.add(nbg);
		nbpstaked = nbpstaked.add(nbp);

		 
		_UserStakingListId[useraddress].push(uid(DepositLength));
		DepositLength++;

	}

  function userstakinglength(address useraddress) public view returns(uint256){
	 return _UserStakingListId[useraddress].length;
  }
    function UserStakingListId(address useraddress,uint256 pid) public view returns(uint256){
	 return _UserStakingListId[useraddress][pid].id;
  }

    function withdrawable(address useraddress,uint256 pid) public view returns(uint256,uint256){
	 
		if(UseridByAddr[useraddress] == 0)return (0,0);
		HistoryDp storage dp = userDeposit[pid];
	  
		uint256 wdpblocknbg = dp.amountnbg.mul(2).div(5759994);
		uint256 wdpblocknbp = dp.amountnbp.mul(2).div(5759994);
		uint256 nbgrelease = wdpblocknbg.mul(block.number.sub(dp.blockdeposit));
		uint256 nbprelease = wdpblocknbp.mul(block.number.sub(dp.blockdeposit));
		uint256 nbgwithdrawable = nbgrelease.sub(dp.nbghasbeenwithdraw);
		uint256 nbpwithdrawable = nbprelease.sub(dp.nbphasbeenwithdraw);

		if(dp.nbphasbeenwithdraw<dp.amountnbp.mul(2)){
			if(nbpwithdrawable>dp.amountnbp.mul(2).sub(dp.nbphasbeenwithdraw))
			nbpwithdrawable = dp.amountnbp.mul(2).sub(dp.nbphasbeenwithdraw);
		} else nbpwithdrawable = 0;

		if(dp.nbghasbeenwithdraw<dp.amountnbg.mul(2)){
			if(nbgwithdrawable>dp.amountnbg.mul(2).sub(dp.nbghasbeenwithdraw))
			nbgwithdrawable = dp.amountnbg.mul(2).sub(dp.nbghasbeenwithdraw);
		} else nbgwithdrawable = 0;

        return(nbpwithdrawable,nbgwithdrawable);

		
	}

    function withdraw(uint256 pid) public {
		address useraddress = address(msg.sender);
		if(UseridByAddr[useraddress] == 0)return;
		UserData storage user = userInfo[useraddress];
		HistoryDp storage dp = userDeposit[pid];
		HistoryWd storage wd = userWithdraw[WithdrawLength];

		if(dp.addr != useraddress) return;//not your
		uint256 wdpblocknbg = dp.amountnbg.mul(2).div(5759994);
		uint256 wdpblocknbp = dp.amountnbp.mul(2).div(5759994);
		uint256 nbgrelease = wdpblocknbg.mul(block.number.sub(dp.blockdeposit));
		uint256 nbprelease = wdpblocknbp.mul(block.number.sub(dp.blockdeposit));
		uint256 nbgwithdrawable = nbgrelease.sub(dp.nbghasbeenwithdraw);
		uint256 nbpwithdrawable = nbprelease.sub(dp.nbphasbeenwithdraw);

		if(dp.nbphasbeenwithdraw<dp.amountnbp.mul(2)){
			if(nbpwithdrawable>dp.amountnbp.mul(2).sub(dp.nbphasbeenwithdraw))
			nbpwithdrawable = dp.amountnbp.mul(2).sub(dp.nbphasbeenwithdraw);
		    IERC20(NBP).transfer(dp.addr, nbgwithdrawable);
		    dp.nbphasbeenwithdraw = dp.nbphasbeenwithdraw.add(nbpwithdrawable);
			user.amountnbp_plustreward = user.amountnbp_plustreward.sub(nbpwithdrawable);
			 
			 
		} else nbpwithdrawable = 0;

		if(dp.nbghasbeenwithdraw<dp.amountnbg.mul(2)){
			if(nbgwithdrawable>dp.amountnbg.mul(2).sub(dp.nbghasbeenwithdraw))
			nbgwithdrawable = dp.amountnbg.mul(2).sub(dp.nbghasbeenwithdraw);
		    IERC20(NBG).transfer(dp.addr, nbgwithdrawable);
		    dp.nbghasbeenwithdraw = dp.nbghasbeenwithdraw.add(nbgwithdrawable);
			user.amountnbg_plustreward = user.amountnbg_plustreward.sub(nbgwithdrawable);
			 
			 
		} else nbgwithdrawable = 0;

        wd.addr = useraddress;
        wd.userid = UseridByAddr[useraddress];
        wd.amountnbg = nbgwithdrawable;
        wd.amountnbp = nbpwithdrawable;
        wd.time = now;
		WithdrawLength++;
 
		//data
		nbgstaked = nbgstaked.sub(nbgwithdrawable.div(2));
		nbpstaked = nbpstaked.sub(nbpwithdrawable.div(2));
		nbgreward = nbgreward.sub(nbgwithdrawable.div(2));
		nbpreward = nbpreward.sub(nbpwithdrawable.div(2));

		
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
            user.amountnbg = 0;
            user.amountnbp = 0;
            user.amountnbg_plustreward = 0;
            user.amountnbp_plustreward = 0;
            user.uplineid = upline;
            user.uplineaddress = AddrByUserid[upline];
            UplineIdById[userid] = upline;
            UserList.push(useraddress);
            UseridByAddr[useraddress] = userid;
            AddrByUserid[userid]=useraddress;
            UserIdExist[userid] = true;
        }
    }

 
 }