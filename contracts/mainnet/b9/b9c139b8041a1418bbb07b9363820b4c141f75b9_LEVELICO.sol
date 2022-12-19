/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);  
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
contract LEVELICO is  Ownable {
    IERC20 public token;
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    AggregatorV3Interface public priceFeedBnb;
    struct User{
        uint256 depositeAmount;
        uint256 time;
        uint256 tokenWindrwal;
        address referrer;
		uint256[5] levels;
    }
    mapping(address=>User) public userInfo;
    uint256[] public REFERRAL_PERCENTS 	= [1000, 500, 400, 300, 200];
	uint256 constant public PERCENTS_DIVIDER = 10000;
    uint256 public airdrop = 10;
    uint256 public rewards=5; 
    uint256 public rate=200;
    address[]  public _airaddress;
    address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }
    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;   	
	mapping(address => address) public referralLevel1Address;
    mapping(address => address) public referralLevel2Address;
    mapping(address => address) public referralLevel3Address;
    mapping(address => address) public referralLevel4Address;
    mapping(address => address) public referralLevel5Address;
    constructor(IERC20 _token)  {
            token = _token;
            priceFeedBnb = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
    }    
    function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }    
    function getLatestPriceBnb(uint256 amount) public view returns (uint256) {
        (,int price,,,) = priceFeedBnb.latestRoundData();
        return uint256(price).div(1e8).mul(amount);
    }
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

    function distributeRef(address _referredBy,address _sender, bool _newReferral) internal {       
        address _customerAddress= _sender;
        referralLevel1Address[_customerAddress]= _referredBy;
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1);
        }        
        chkLv2= referralLevel1Address[_referredBy];
        chkLv3= referralLevel2Address[_referredBy];
        chkLv4= referralLevel3Address[_referredBy];
        chkLv5= referralLevel4Address[_referredBy];
        if(chkLv2 != 0x0000000000000000000000000000000000000000) {
            referralLevel2Address[_customerAddress]                     = referralLevel1Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
            }
        }
        if(chkLv3 != 0x0000000000000000000000000000000000000000) {
            referralLevel3Address[_customerAddress]                     = referralLevel2Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3);
            }
        }
        if(chkLv4 != 0x0000000000000000000000000000000000000000) {
            referralLevel4Address[_customerAddress]                     = referralLevel3Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
            }
        }        
        if(chkLv5 != 0x0000000000000000000000000000000000000000) {
            referralLevel5Address[_customerAddress]                     = referralLevel4Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
            }
        }
      
	}	
   function Invest(address referrer) public payable{
       User storage user = userInfo[msg.sender];
       uint256 bonus=0;
       uint256 dollars=getLatestPriceBnb(msg.value);
       if(dollars.div(1e18)>=100) bonus=10;
       if(dollars.div(1e18)>500 && dollars.div(1e18)<=1000) bonus=15;
       if(dollars.div(1e18)>1000) bonus=20;
        if (user.referrer == address(0)) {
			if ( referrer != msg.sender) {
				user.referrer = referrer;
			}
			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					userInfo[upline].levels[i] = userInfo[upline].levels[i].add(1);
					upline = userInfo[upline].referrer;
				} else break;
			}
			
		}
		 bool _newReferral= true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer= referralLevel1Address[msg.sender];
            _newReferral= false;
        }		
		distributeRef(referrer, msg.sender, _newReferral);
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                    payable (upline).transfer(amount);
					upline = userInfo[upline].referrer;
				} else break;
			}
		}
       uint256 numberOfTokens = bnbToToken(msg.value);
       uint256 bonusTokens= numberOfTokens.mul(bonus).div(100);
	   token.transfer(msg.sender,numberOfTokens.div(1e18).add(bonusTokens.div(1e18)));
       userInfo[msg.sender].depositeAmount=msg.value.add(userInfo[msg.sender].depositeAmount);
       userInfo[msg.sender].time=block.timestamp;       
   }
    function changePrice(uint256 _rate) external onlyOwner{
        rate = _rate;
    }
    function withdrwal() public onlyOwner{
        payable(owner()).transfer(address(this).balance);
    } 
    function bnbToToken(uint256 amount) public view returns(uint256){
        uint256 numberOfTokens;
        uint256 bnbToUsd;        
        bnbToUsd = getLatestPriceBnb(amount);        
        numberOfTokens = bnbToUsd.mul(rate);
        return numberOfTokens.mul(1e18);
    } 
   function setDrop(uint256 _airdrop, uint256 _rewards) onlyOwner public returns(bool){
        airdrop = _airdrop;
        rewards = _rewards;
        delete _airaddress;
        return true;
    }
    function airdropTokens(address referrer) public payable returns(bool){
        require(airdrop!=0, "No Airdrop started yet");
        require(msg.value>0,"Low Airdrop Fees");
            bool _isExist = false;
            for (uint8 i=0; i < _airaddress.length; i++) {
                if(_airaddress[i]==msg.sender){
                    _isExist = true;
                }
            }
			User storage user = userInfo[msg.sender];
        if (user.referrer == address(0)) {
			if ( referrer != msg.sender) {
				user.referrer = referrer;
			}
			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					userInfo[upline].levels[i] = userInfo[upline].levels[i].add(1);
					upline = userInfo[upline].referrer;
				} else break;
			}
			
		}
		 bool _newReferral= true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer= referralLevel1Address[msg.sender];
            _newReferral= false;
        }		
		distributeRef(referrer, msg.sender, _newReferral);
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 4; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                    payable (upline).transfer(amount);
					upline = userInfo[upline].referrer;
				} else break;
			}
		}
        require(_isExist==false, "Already Dropped");
        token.transfer(msg.sender, airdrop*(10**18));
        _airaddress.push(msg.sender);                
    return true;
    }
    function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return userInfo[userAddress].levels[0]+userInfo[userAddress].levels[1]+userInfo[userAddress].levels[2]+userInfo[userAddress].levels[3]+userInfo[userAddress].levels[4];
	}
}