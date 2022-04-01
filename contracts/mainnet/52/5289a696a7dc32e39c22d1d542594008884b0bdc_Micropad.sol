/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

pragma solidity ^ 0.6.2;
interface IERC20 {
	function totalSupply() external view returns(uint256);

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
 

 
contract Micropad is Ownable {
	using SafeMath
	for uint256;
 
	struct Investor {
         
		uint256 contribution;
		uint256 tokenClaimed;
        address walletddress;	 
	}
     
    struct Addr{
    address addr;
     }

    struct Project {
		uint256 whitelevel;
        uint256 ventureID;
		uint256 totalAllocation;
        uint256 filledAllocation;
		uint256 minimumInvest;	 
        uint256 maximumInvest;	
        
		uint256 tokenPrice;
        bool    status;
        uint256 projectFee;
        uint256 countinvestor;
		uint256 tokendisribution;
		uint256 tokenDigit;
		address tokenContract;
		 
    

	}
     address the_owner;
	 address withliseter;
    constructor() public {
	 the_owner = address(msg.sender);
	 withliseter = the_owner;
	}
	

   
    address BUSD   = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
   
	Project[] public projects;
	mapping(address => uint256 ) public addresswhitlistlevel ;
    mapping(uint256 => mapping(address => bool)) private InvestorsInProject;
    mapping(uint256 => mapping(address => Investor)) public Investors;
    mapping(uint256  => Addr[])  public InvestorsAddress;
 
	//Create project
	function create( uint256 _whitelevel,uint256 _tokenPrice , uint256 _projectFee,uint256 _ventureID,uint256 busd_totalAllocation,uint256 min_busd,uint256 max_busd) public onlyOwner {
	    
		projects.push(Project({
		  whitelevel :_whitelevel,
          ventureID:_ventureID,
		  totalAllocation:busd_totalAllocation.mul(10**18),
          filledAllocation:0,
		  minimumInvest:min_busd.mul(10**18), 
          maximumInvest:max_busd.mul(10**18),
           
		  tokenPrice :_tokenPrice,
		  tokendisribution:0,
		  tokenDigit:18,
          status:false,
          projectFee:_projectFee,
          countinvestor:0,
		  tokenContract:address(0)
		 }));

	}
	 
	 function projectlength() public view returns(uint256){
		 return projects.length;
	 }
	function invest(uint256 _pid, uint256 _amount) public    {

	  Project storage proj  = projects[_pid];
      if(proj.status== false) return;
      if(proj.totalAllocation <= proj.filledAllocation)return;
      if(_amount > projects[_pid].maximumInvest) return;
      if(proj.whitelevel>0&&addresswhitlistlevel[address(msg.sender)]<proj.whitelevel)return;
      bool addressinproject = InvestorsInProject[_pid][address(msg.sender)];
     
      //update 
      if(addressinproject) {
		Investor storage user = Investors[_pid][address(msg.sender)];
        uint256 curent_invest = user.contribution;
        if(curent_invest.add(_amount) < projects[_pid].minimumInvest) return;
        if(curent_invest.add(_amount) > projects[_pid].maximumInvest) 
        _amount = projects[_pid].maximumInvest -  curent_invest;
       
        if(proj.totalAllocation < proj.filledAllocation.add(_amount)) 
        _amount = proj.totalAllocation.sub(proj.filledAllocation);
        //set max amount to invest
        IERC20(BUSD).transferFrom(address(msg.sender), address(this), _amount.add(_amount.div(100).mul(proj.projectFee)));
        
        user.contribution= user.contribution.add(_amount);

        //project filled
       
      }
      else
      {
		if(_amount < projects[_pid].minimumInvest) return;
		IERC20(BUSD).transferFrom(address(msg.sender), address(this), _amount.add(_amount.div(100).mul(proj.projectFee)));
		Investors[_pid][address(msg.sender)] = Investor({
				contribution:_amount,
				tokenClaimed:0,
				walletddress:address(msg.sender)
		});
         proj.countinvestor++;
            InvestorsAddress[_pid].push(Addr({
            addr:address(msg.sender)
            }));
      }

      
       

	  InvestorsInProject[_pid][address(msg.sender)] = true;
      //isfull
	  proj.filledAllocation = proj.filledAllocation.add(_amount);
      if(proj.totalAllocation <=  proj.filledAllocation){
            IERC20(BUSD).transfer(the_owner,proj.filledAllocation);
            proj.status = false;
        }

	} 

    function clear(address token, uint256 _amount) public onlyOwner{
        IERC20(token).transfer(address(msg.sender),_amount);
    }

	 function setwithlist(address addr, uint256 _level) public  {
		if(address(msg.sender)==withliseter) addresswhitlistlevel[addr]=_level;
    }
	 function setwithlist(address addr ) public onlyOwner{

		  withliseter = addr;
    }
	 function setPrice(uint256 _pid,uint256 price ) public onlyOwner{
		  Project storage proj  = projects[_pid];
		  proj.tokenPrice = price;
    }

    function closeproject( uint256 _pid) public onlyOwner{
        Project storage proj  = projects[_pid];
        proj.status = false;
        IERC20(BUSD).transfer(the_owner,proj.filledAllocation);
        
    }
	function openproject( uint256 _pid) public onlyOwner{
        Project storage proj  = projects[_pid];
        proj.status = true;
       // IERC20(BUSD).transfer(the_owner,proj.filledAllocation);
        
    }

	 function setProjectToken( uint256 _pid , address _addr,uint256 _digit) public onlyOwner{
        Project storage proj  = projects[_pid];
        proj.tokenContract = _addr;
		proj.tokenDigit = _digit;
        
    }

    function distibusi(uint256 _pid,uint256 _amount)  public onlyOwner{
     Project storage proj  = projects[_pid];
   
       if(address(proj.tokenContract) == address(0))return;
       uint256 bb = IERC20(proj.tokenContract).balanceOf(address(this));
       IERC20(proj.tokenContract).transferFrom(address(msg.sender), address(this), _amount);
       uint256 aa =  IERC20(proj.tokenContract).balanceOf(address(this));
       require(bb<aa,"error");
       uint256 rtc = aa-bb;
       uint256 tokenperweibusd = rtc.mul(10e30).div(proj.filledAllocation);
	   proj.tokendisribution = proj.tokendisribution.add(_amount);

       uint256 amountnow = _amount;
       for(uint256 a=0; a < proj.countinvestor;a++){
	   Investor storage user = Investors[_pid][InvestorsAddress[_pid][a].addr];
       uint256 tokenclaimed = user.contribution.mul(tokenperweibusd).div(10e30);
       if(amountnow<tokenclaimed) tokenclaimed = amountnow;
       amountnow = amountnow.sub(tokenclaimed);
	   user.tokenClaimed = user.tokenClaimed.add(tokenclaimed);
       IERC20(proj.tokenContract).transfer(user.walletddress,  tokenclaimed );
       }

    }
	

	  

   
 
}