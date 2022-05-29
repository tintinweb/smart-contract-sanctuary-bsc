/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library SafeMath {

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
	
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
	
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
	
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
	
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
	
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
	
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
	
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
	
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
	
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
	
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
	
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require( (value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
	
    function balanceOf(address account) external view returns (uint256);
	
    function transfer(address to, uint256 amount) external returns (bool);
	
    function allowance(address owner, address spender) external view returns (uint256);
	
    function approve(address spender, uint256 amount) external returns (bool);
	
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;
		
        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

interface IReferrals {
    function addMember(address _member, address _parent) external;
    function updateEarn(address _member, uint256 _amount) external;
    function registerUser(address _member, address _sponsor) external;
    function countReferrals(address _member) external view returns (uint256[] memory);
    function getListReferrals(address _member) external view returns (address[] memory);
    function getSponsor(address account) external view returns (address);
    function isMember(address _user) external view returns (bool);
    function transfer(address _user, uint256 _amount) external;
}

contract BNBMint is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint40;
    using SafeMath for uint8;
    using SafeMath for uint;
    using SafeERC20 for IERC20;
	
    struct packagesStruct {
        bool isExist;
        uint rate;
        uint percent;
        uint min;
        uint256[5] refPercent;
		uint256[5] refPercentST;
    }
	
    struct Deposit {
        uint256 amount;
        uint256 lastClaim;
        uint256 profit;
        uint256 withdraw;
		uint256 nextWithdraw;
    }
	
	struct UserInfo {
       Deposit[] deposits;
    }
	
    mapping(uint => packagesStruct) public packages;
    mapping(address => UserInfo) internal userInfo;
    mapping(address => bool) public gainSponsorsCheck;
    mapping(uint => address) public countGainSponsorsCheck;
    mapping(address => mapping(address => bool)) public firstDeposit;
	mapping(address => bool) public firstEntry;
	
    uint256 public totalStaked;
    uint256 public totalWithdraws;
    IReferrals Referrals;
	
    uint256 constant public factor = 10000;
    uint256 constant public devFee = 1500;
	uint256 constant public webFee = 300;

    uint256[5] private refPercent = [800,500,300,200,100];
    uint256[5] private refPercentST = [300,200,100,50,50];

	address payable public devOne = payable(0xd7f79920e68fB6e7e4693196B399437f34e9F2F8);
	address payable public devTwo = payable(0x7EEe7008cAE93255D9557EA2bAD07f8B76bc3686);
	
    address payable public webOne = payable(0x0E68915483F0C4882d80098D1CA116d496Ca92a4);
	address payable public webTwo = payable(0x2ad6e2EAFe19645A15dA0EC46dA82e881Dd7a035);
	
	uint256 public timeStart = block.timestamp;
	
    constructor(IReferrals _Referrals) {
        Referrals = _Referrals;
		
		packages[0] =  packagesStruct({
            isExist: true,
            rate: 1400,
            percent: 14000,
            min: 50000000000000000,
            refPercent: refPercent,
			refPercentST: refPercentST
        });

		packages[1] =  packagesStruct({
            isExist: true,
            rate: 925,
            percent: 18500,
            min: 100000000000000000,
            refPercent: refPercent,
			refPercentST: refPercentST
        });
		
        packages[2] = packagesStruct({
            isExist: true,
            rate: 833,
            percent: 25000,
            min: 200000000000000000,
            refPercent: refPercent,
			refPercentST: refPercentST
        });
    }
	
	receive() external payable {}
	
    function _referrals(uint _package, address _user, uint256 _amount, uint256 _type) internal {
        address _sponsor = _user;
		
        for(uint i = 0; i < 5; i++) {
            _sponsor = Referrals.getSponsor(_sponsor);
            if(_sponsor == address(0)) break;
            if(_sponsor == _user) break;
			
            if(gainSponsorsCheck[_sponsor] == true) {
                continue;
            }
			
            UserInfo storage user = userInfo[_sponsor];
			
            if(user.deposits[0].amount > 0 || user.deposits[1].amount > 0 || user.deposits[2].amount > 0) {
			    uint256 fee;
			    if(_type==2)
				{
				    fee = _amount.mul(packages[_package].refPercentST[i]).div(factor);
				}
				else
				{
				    fee = _amount.mul(packages[_package].refPercent[i]).div(factor);
				}
                _transfer(_sponsor, fee);
                Referrals.updateEarn(_sponsor, fee);
                gainSponsorsCheck[_sponsor] = true;
                countGainSponsorsCheck[i] = _sponsor;
            }
        }
		
        for(uint i = 0; i < 5; i++) {
            gainSponsorsCheck[countGainSponsorsCheck[i]] = false;
            countGainSponsorsCheck[i] = address(0);
        }
    }
	
    function _transfer(address _user, uint256 _amount) internal {
        if(_amount > 0){
            Referrals.transfer(_user, _amount);
        }
    }
	
    function deposit(address _ref, uint256 _pa) external nonReentrant payable {
        uint256 amount = msg.value;
        require(packages[_pa].isExist, "Package not found");
        require(amount >= packages[_pa].min, "Minimum deposit error!");
        require(uint256(block.timestamp) > timeStart == true, "We still havent launched yet!");
		
        if(amount > 0) {
            payable(address(Referrals)).transfer(amount);
        }
		
        UserInfo storage user = userInfo[msg.sender];
		
		if(!firstEntry[msg.sender])
		{
		   user.deposits[0].amount = 0;
		   user.deposits[0].lastClaim = 0;
		   user.deposits[0].nextWithdraw = 0;
		   user.deposits[0].profit = 0;
		   user.deposits[0].withdraw = 0;
		   
		   user.deposits[1].amount = 0;
		   user.deposits[1].lastClaim = 0;
		   user.deposits[1].nextWithdraw = 0;
		   user.deposits[1].profit = 0;
		   user.deposits[1].withdraw = 0;
		   
		   user.deposits[2].amount = 0;
		   user.deposits[2].lastClaim = 0;
		   user.deposits[2].nextWithdraw = 0;
		   user.deposits[2].profit = 0;
		   user.deposits[2].withdraw = 0;
		   
		   firstEntry[msg.sender] = true;
		}
		
        _transfer(devOne, amount.mul(devFee).div(factor).div(2));
		_transfer(devTwo, amount.mul(devFee).div(factor).div(2));
		_transfer(webOne, amount.mul(webFee).div(factor).div(2));
		_transfer(webTwo, amount.mul(webFee).div(factor).div(2));
		
        if(Referrals.isMember(msg.sender) == false) 
		{
            Referrals.registerUser(msg.sender, _ref);
        } 
		else 
		{
            _ref = Referrals.getSponsor(msg.sender);
        }
		
        UserInfo storage sponsor = userInfo[_ref];
		
		if(!firstEntry[_ref])
		{
		   sponsor.deposits[0].amount = 0;
		   sponsor.deposits[0].lastClaim = 0;
		   sponsor.deposits[0].nextWithdraw = 0;
		   sponsor.deposits[0].profit = 0;
		   sponsor.deposits[0].withdraw = 0;
		   
		   sponsor.deposits[1].amount = 0;
		   sponsor.deposits[1].lastClaim = 0;
		   sponsor.deposits[1].nextWithdraw = 0;
		   sponsor.deposits[1].profit = 0;
		   sponsor.deposits[1].withdraw = 0;
		   
		   sponsor.deposits[2].amount = 0;
		   sponsor.deposits[2].lastClaim = 0;
		   sponsor.deposits[2].nextWithdraw = 0;
		   sponsor.deposits[2].profit = 0;
		   sponsor.deposits[2].withdraw = 0;
		   
		   firstEntry[_ref] = true;
		}
		
        if((sponsor.deposits[0].amount > 0 || sponsor.deposits[1].amount > 0 || sponsor.deposits[2].amount > 0) && firstDeposit[_ref][msg.sender] == false) 
		{
             firstDeposit[_ref][msg.sender] = true;
			 _referrals(_pa, msg.sender, amount, 1);
        }
		else
		{
		     _referrals(_pa, msg.sender, amount, 2);
		}
		
        totalStaked = totalStaked.add(amount);
		
        if(user.deposits[_pa].amount > 0 && this.pendingReward(msg.sender,_pa) > 0) 
		{
            _claim(msg.sender, _pa);
        }
		
        user.deposits[_pa].amount = user.deposits[_pa].amount.add(amount);
        user.deposits[_pa].lastClaim = block.timestamp;
		user.deposits[_pa].nextWithdraw = block.timestamp.add(24 hours);
    }
	
    function _claim(address _user, uint256 _pa) internal {
        packagesStruct storage package = packages[_pa];
        UserInfo storage user = userInfo[_user];

        uint256 pending = this.pendingReward(_user, _pa);

        if(user.deposits[_pa].amount > 0 && pending > 0) {
            user.deposits[_pa].lastClaim = block.timestamp;

            bool finish = false;
            uint256 max = (user.deposits[_pa].amount * package.percent / factor);
            uint256 toSend = user.deposits[_pa].profit + pending;
			
            if(toSend >= max) {
                pending = max.sub(user.deposits[_pa].profit);
                finish = true;
            }
			
            if(pending > address(Referrals).balance.mul(30).div(100))
			{
                 pending = address(Referrals).balance.mul(30).div(100);
            }
			
            if (pending > 0) {
                user.deposits[_pa].profit = user.deposits[_pa].profit.add(pending);
                _transfer(_user, pending);
                user.deposits[_pa].withdraw = user.deposits[_pa].withdraw.add(pending);
                totalWithdraws = totalWithdraws.add(pending);
            }
			
            if(finish) {
                totalStaked = totalStaked.sub(user.deposits[_pa].amount);
                user.deposits[_pa].profit = 0;
                user.deposits[_pa].amount = 0;
                user.deposits[_pa].lastClaim = 0;
				user.deposits[_pa].nextWithdraw = 0;
            }
        }
    }
	
    function withdraw(address _user) external nonReentrant {
        UserInfo storage user = userInfo[_user];
		
        uint256 pendingOne = this.pendingReward(_user, 0);
		uint256 pendingTwo = this.pendingReward(_user, 1);
		uint256 pendingThree = this.pendingReward(_user, 2);
		
        if(user.deposits[0].amount > 0 && pendingOne > 0) 
		{
		    _claim(_user, 0);
		}
		
		if(user.deposits[1].amount > 0 && pendingTwo > 0) 
		{
		    _claim(_user, 1);
		}
		
		if(user.deposits[2].amount > 0 && pendingThree > 0) 
		{
		    _claim(_user, 2);
		}
    }
	
    function pendingReward(address _user, uint256 _pa) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        packagesStruct storage package = packages[_pa];
        if(user.deposits[_pa].amount > 0 && user.deposits[_pa].lastClaim > 0 && user.deposits[_pa].nextWithdraw <= block.timestamp){
           uint256 dayInSeconds = 1 days;
           uint256 timeBetweenLast = block.timestamp.sub(user.deposits[_pa].lastClaim);
           return (user.deposits[_pa].amount.mul(package.rate).mul(timeBetweenLast)).div(dayInSeconds).div(factor);
        }
        return 0;
    }
	
    function updateRate(uint _value, uint256 _pa) external onlyOwner nonReentrant {
        packagesStruct storage package = packages[_pa];
		require(packages[_pa].isExist, "Package not found");
        package.rate = _value;
    }

    function updatePercent(uint _value, uint256 _pa) external onlyOwner nonReentrant {
        packagesStruct storage package = packages[_pa];
		require(packages[_pa].isExist, "Package not found");
        package.percent = _value;
    }
	
    function updateMin(uint _value, uint256 _pa) external onlyOwner nonReentrant {
        packagesStruct storage package = packages[_pa];
		require(packages[_pa].isExist, "Package not found");
        package.min = _value;
    }
	
    function updateRefPercent(uint256[5] memory _value, uint256 _pa) external onlyOwner nonReentrant {
        packagesStruct storage package = packages[_pa];
		require(packages[_pa].isExist, "Package not found");
        package.refPercent = _value;
    }
	
	function updateRefPercentST(uint256[5] memory _value, uint256 _pa) external onlyOwner nonReentrant {
        packagesStruct storage package = packages[_pa];
		require(packages[_pa].isExist, "Package not found");
        package.refPercentST = _value;
    }
	
    function getPackage(uint256 _pa) external view returns(uint, uint, uint) {
        packagesStruct storage p = packages[_pa];
        return (p.rate, p.percent, p.min);
    }

    function getRefPercent(uint256 _pa) external view returns(uint, uint, uint, uint, uint) {
        packagesStruct storage p = packages[_pa];
        return (p.refPercent[0], p.refPercent[1], p.refPercent[2], p.refPercent[3], p.refPercent[4]);
    }
	
	function getRefPercentST(uint256 _pa) external view returns(uint, uint, uint, uint, uint) {
        packagesStruct storage p = packages[_pa];
        return (p.refPercentST[0], p.refPercentST[1], p.refPercentST[2], p.refPercentST[3], p.refPercentST[4]);
    }
	
    function infoUser(address _user, uint256 _pa) external view returns(uint, uint, uint, uint, uint) {
        UserInfo storage u = userInfo[_user];
		return(u.deposits[_pa].amount, u.deposits[_pa].lastClaim, u.deposits[_pa].profit, u.deposits[_pa].withdraw,  u.deposits[_pa].nextWithdraw);
    }
	
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }
	
    function withdrawERC20(address _token) public onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
}