/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;

interface IBEP20 {
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

interface IERC20 {    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
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



contract BUSDMinnows is Context, Ownable, IBEP20 {
    using SafeMath for uint256;
	using SafeERC20 for IERC20;
	
	IERC20 public BUSD;
    	
    event Withdraw(address indexed addr, uint256 amount);
    event RefPayout(address indexed addr, address indexed from, uint256 amount);
    event RefYields(address indexed from, address indexed to, uint256 amount);

	mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
	
    struct Player {
        uint256 total_withdrawn;
        uint256 total_ref_bonus;
        uint256[5] structure; 
        address upline;
    }

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public ref_bonus;
    uint8[5] private ref_bonuses = [20, 10, 5, 3, 2]; 
    mapping(address => Player) public players;

    uint256 private constant HOUR = 1 hours;
    uint256 private constant DAY = 24 hours;
    uint256 private numDays = 1;
    uint256 private numHours = 1;
    
    uint8 public isScheduled;
    uint8 public isHourly;
    uint8 public isDaily;
    uint8 public sellPercentage;
    uint8 public nerfDivisor = 5;
    uint256 private EGGS_TO_HATCH_1MINERS = 510000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
      
    address payable public dev;

    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => uint256) public lastSell;
    mapping (address => address) public referrals;
	
	mapping (address => uint256) public userBuys;
	mapping (address => uint256) public userHatches;
	
    uint256 public marketEggs;
    
    constructor() {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);	
        dev = payable(msg.sender);		
	    _name = "BUSD Minnows";
        _symbol = "BMINNOWS";
        _decimals = 18;
        _totalSupply =  100000000000 * 10**uint(_decimals); // 100B
        _balances[address(this)] = 60000000000 * 10**uint(_decimals); //60% locked in contract
		_balances[dev] = 40000000000 * 10**uint(_decimals); //40% will be managed by dev team

        emit Transfer(address(0), address(this), _balances[address(this)]);    
		emit Transfer(address(0), dev, _balances[dev]);    

        marketEggs = 51000000000;
    }
        
    function BuyFish(address ref, uint256 amount) public payable {
        
        require(amount >= 20 ether, "Minimum deposit amount is 20 BUSD");
		BUSD.safeTransferFrom(msg.sender, address(this), amount);
		
        uint256 eggsBought = calculateEggBuy(msg.value,SafeMath.sub(BUSD.balanceOf(address(this)), amount));
        eggsBought = SafeMath.sub(eggsBought,devFee(eggsBought,5));
        		
		uint256 fee1 = devFee(amount, 8);
        BUSD.safeTransfer(dev, fee1);
		
        userBuys[msg.sender] = SafeMath.add(userBuys[msg.sender],amount);
	    invested = SafeMath.add(invested,amount);

        setUpline(msg.sender, ref);
        payoutCommissions(msg.sender, amount);

        uint256 newMiners = SafeMath.div(eggsBought,EGGS_TO_HATCH_1MINERS);
        
        if(lastHatch[msg.sender] <=0){
            lastHatch[msg.sender] = block.timestamp;
            lastSell[msg.sender] = block.timestamp;
        }

        uint256 token = newMiners * 10**uint(_decimals);

        if(_balances[address(this)] - token >= 0)
        {
            _balances[msg.sender] = _balances[msg.sender].add(token);
		    _balances[address(this)] = _balances[address(this)].sub(token);
            emit Transfer(address(this), msg.sender, token);
		} 

        //boost market to nerf miners hoarding
        marketEggs = SafeMath.add(marketEggs, SafeMath.div(eggsBought, nerfDivisor));

    }

    function setUpline(address _addr, address _upline) private {
        if(players[_addr].upline == address(0) && _addr != owner()) {
            
            if(_balances[_upline] <= 0) {
                _upline = owner();
            }

            referrals[_addr] = _upline; 
            players[_addr].upline = _upline;
         
            for(uint8 i = 0; i < 5; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }   

    function payoutCommissions(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / 100;
            
            BUSD.safeTransfer(up, bonus);

            withdrawn += bonus;
			emit Withdraw(up, bonus);
			
            players[up].total_ref_bonus += bonus;
            ref_bonus += bonus;
            emit RefPayout(up, _addr, bonus);
        
            up = players[up].upline;
        }
    }

    function HatchEggs() public {
        require(_balances[msg.sender] > 0,'Inactive Member!');    

        uint256 eggsUsed = getMyEggs(msg.sender);
        uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        		
        //send referral eggs
        claimedEggs[referrals[msg.sender]] = SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,10));
        emit RefYields(msg.sender, referrals[msg.sender], SafeMath.div(eggsUsed,5));
      
		uint256 bnbValue = calculateEggSell(eggsUsed);
		userHatches[msg.sender] = SafeMath.add(userHatches[msg.sender],bnbValue);
		        
        uint256 token = newMiners * 10**uint(_decimals);

        if(_balances[address(this)] - token >= 0)
        {
            _balances[msg.sender] = _balances[msg.sender].add(token);
		    _balances[address(this)] = _balances[address(this)].sub(token);
            emit Transfer(address(this), msg.sender, token);
		} 
        
        //boost market to nerf miners hoarding
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,nerfDivisor));

    }
        
    function SellFish(uint8 percentage) public {
        require(percentage <= 100);
        require(_balances[msg.sender] > 0);
        
        if(isScheduled == 1) {
            if(isDaily >= 1){
                require (block.timestamp >= (lastSell[msg.sender] + (DAY * numDays)), "Not due yet for next Sell Transaction!");
            }
            if(isHourly == 1) {
                require (block.timestamp >= (lastSell[msg.sender] + (HOUR * numHours)), "Not due yet for next Sell Transaction!");
            }
        }

        Player storage player = players[msg.sender];

        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(hasEggs);
		uint256 sellAmount = SafeMath.div(SafeMath.mul(eggValue,percentage),100);
        
        uint256 soldEggs = SafeMath.div(SafeMath.mul(hasEggs,percentage),100);
        claimedEggs[msg.sender] = SafeMath.sub(hasEggs,soldEggs);

        lastHatch[msg.sender] = block.timestamp;
        lastSell[msg.sender] = block.timestamp;
            
        marketEggs = SafeMath.add(marketEggs,soldEggs);
        BUSD.safeTransfer(msg.sender, sellAmount);

        player.total_withdrawn = SafeMath.add(player.total_withdrawn,sellAmount);

        withdrawn = SafeMath.add(withdrawn,sellAmount);
        emit Withdraw(msg.sender, sellAmount);
        
    }

    function realTimeIncome(address adr) public view returns(uint256) {
        uint256 hasEggs = getMyEggs(adr);
        uint256 eggValue = calculateEggSell(hasEggs);
        return eggValue;
    }
   
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs,marketEggs,BUSD.balanceOf(address(this)));
    }
    
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    
    function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
        return calculateEggBuy(eth,BUSD.balanceOf(address(this)));
    }
    
    function devFee(uint256 amount, uint8 fee) private pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,fee),100);
    }
   
    function getBalance() public view returns(uint256) {
        return BUSD.balanceOf(address(this));
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return SafeMath.div(_balances[adr],(1 ether));
    }
    
    function getMyEggs(address adr) public view returns(uint256) {
        return SafeMath.add(claimedEggs[adr],getEggsSinceLastHatch(adr));
    }
    
    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed, SafeMath.div(_balances[adr],(1 ether)));
    }    
	
	function accountInfo(address adr) public view returns(address, uint256, uint256, uint256, uint256, uint256) {
        if(_balances[adr] <= 0){ return (owner(),0,0,0,0,0);}
        
        uint256 hasEggs = getMyEggs(adr);
        uint256 bnbValue = calculateEggSell(hasEggs);      
        return (referrals[adr], SafeMath.div(_balances[adr],(1 ether)), hasEggs, bnbValue, userBuys[adr], userHatches[adr]);
    }
	
    function referralsInfo(address _addr) view external returns(uint256, uint256, uint256, uint256, uint256[5] memory structure) {
        Player storage player = players[_addr];

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }
        
        return (player.total_withdrawn, player.total_ref_bonus, lastHatch[_addr], lastSell[_addr], structure);
    }
	
    function setSellPercentage(uint8 newval) public onlyOwner returns (bool success) {
        sellPercentage = newval;
        return true;
    }

    function setNerfDivisor(uint8 newval) public onlyOwner returns (bool success) {
        nerfDivisor = newval;
        return true;
    }

    function setDev(address newval) public onlyOwner returns (bool success) {
        dev = payable(newval);
        return true;
    }

    function setScheduled(uint8 newval) public onlyOwner returns (bool success) {
        isScheduled = newval;
        return true;
    }
    
    function setHourly(uint8 newval) public onlyOwner returns (bool success) {
        if(newval >= 1){
            isHourly = 1;
            isDaily = 0;
        }else{
            isHourly = 0;
            isDaily = 1;
        }
        return true;
    }

    function setDaily(uint8 newval) public onlyOwner returns (bool success) {
        if(newval >= 1){
            isHourly = 0;
            isDaily = 1;
        }else{
            isHourly = 1;
            isDaily = 0;
        }return true;
    }

    function setHours(uint newval) public onlyOwner returns (bool success) {
        numHours = newval;
        return true;
    }

    function setDays(uint newval) public onlyOwner returns (bool success) {
        numDays = newval;
        return true;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function mint(uint256 amount, address receiver) public onlyOwner returns (bool) {
        _mint(receiver, amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
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