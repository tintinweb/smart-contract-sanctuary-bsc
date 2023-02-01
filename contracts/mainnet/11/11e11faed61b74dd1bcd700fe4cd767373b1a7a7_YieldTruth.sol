/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

// SPDX-License-Identifier: MIT

// File contracts/Context.sol

pragma solidity 0.8.9;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File contracts/Ownable.sol


pragma solidity 0.8.9;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/ReentrancyGuard.sol


pragma solidity 0.8.9;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File contracts/Address.sol


pragma solidity 0.8.9;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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


// File contracts/ControlledAccess.sol

pragma solidity 0.8.9;

/* @title ControlledAccess
 * @dev The ControlledAccess contract allows function to be restricted to users
 * that possess a signed authorization from the owner of the contract. This signed
 * message includes the user to give permission to and the contract address to prevent
 * reusing the same authorization message on different contract with same owner.
 */

contract ControlledAccess is Ownable {
    address public signerAddress;

    /*
     * @dev Requires msg.sender to have valid access message.
     * @param _v ECDSA signature parameter v.
     * @param _r ECDSA signature parameters r.
     * @param _s ECDSA signature parameters s.
     */
    modifier onlyValidAccess(
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    ) {
        require(isValidAccessMessage(msg.sender, _r, _s, _v));
        _;
    }

    function setSignerAddress(address newAddress) external onlyOwner {
        signerAddress = newAddress;
    }

    /*
     * @dev Verifies if message was signed by owner to give access to _add for this contract.
     *      Assumes Geth signature prefix.
     * @param _add Address of agent with access
     * @param _v ECDSA signature parameter v.
     * @param _r ECDSA signature parameters r.
     * @param _s ECDSA signature parameters s.
     * @return Validity of access message for a given address.
     */
    function isValidAccessMessage(
        address _add,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    ) public view returns (bool) {
        bytes32 hash = keccak256(abi.encode(owner(), _add));
        bytes32 message = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        address sig = ecrecover(message, _v, _r, _s);

        require(signerAddress == sig, "Signature does not match");

        return signerAddress == sig;
    }
}


pragma solidity 0.8.9;

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

contract YieldTruth is Ownable, ReentrancyGuard, ControlledAccess {
    using SafeERC20 for IERC20;
    
    IERC20 public payToken;
    address public payTokenAddress;

    event _Deposit(address indexed addr, uint256 amount, uint40 time);
    event _Payout(address indexed addr, uint256 amount);
    event _Refund(address indexed addr, uint256 amount);
	event _Reinvest(address indexed addr, uint256 amount, uint40 time);
		
	address payable public team = payable(0xb6433157f6E71057f1d3552b75155B3a8c110632);
    address payable public dev = payable(0x637C69E4e68Ac9E344bBbc8e264E643bCD9db694);  
   
    uint256 private constant DAY = 24 hours;
    uint256 public claimPeriod = 86400;    //seconds = 1 day
    uint8 public refundLimitDate = 15;      //days
	
    uint8 public dailyReward = 22;
    struct RewardConfig {
        uint8 reward;
        uint40 time;
    }
    RewardConfig[] public rewardConfigs;

	uint16 constant PERCENT_DIVIDER = 1000; 
    uint8 constant REFERRAL_BONUS = 60; // 6%
    uint8 constant REFERRAL_BONUS_1 = 20; // 2%

    uint8 public DEPOSIT_MIN_AMOUNT = 10;
    uint8 public CLAIM_MIN_AMOUNT = 10;

    uint256 public totalInvestors;
    uint256 public totalInvested;
    uint256 public totalReinvested;
    uint256 public totalClaimed;
    uint256 public totalWithdrawn;
    uint256 public totalReferralBonus;
	uint256 public totalRefunded;

    uint256 public launchTime;
    uint256 public stepValue = 5000000;
	uint256 public stepTime;

    struct DepositTrans {
        uint256 amount;
        uint40 time;
        uint40 investedTime;
    }

    struct User {
        address invitor;
        uint256 dividends;
                
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_referral_bonus;
        uint256 total_reinvested;
		uint256 total_refunded;
		
        uint40 last_withdrawn;
        DepositTrans[] deposits;
        address[] invited_users;
        uint40 invitation_count; 
    }

    mapping(address => User) public users;
    mapping(address => bool) public banned;

    uint public decimals;

    constructor(address _token) {         
	    // team = payable(msg.sender);		
        
        payTokenAddress = _token;
		payToken = IERC20(payTokenAddress);
        decimals = IERC20(payTokenAddress).decimals();
        launchTime = 0;

        rewardConfigs.push(
            RewardConfig({
                reward: dailyReward,
                time: uint40(block.timestamp)
            })
        );
    }

    function launch(uint256 _launchTime) public onlyOwner() {
        require(launchTime == 0, "Launch time has been set already.");
        if( _launchTime == 0 )
            launchTime = block.timestamp;
        else if( _launchTime > block.timestamp ) 
            launchTime = _launchTime;
    }
   
    function deposit(address _invitor, uint256 _amount) external {
        require(launchTime > 0 && launchTime <= block.timestamp, "Not started yet!");
        require(_amount >= DEPOSIT_MIN_AMOUNT * (10**decimals), "Please check the minimum deposit amount.");
        payToken.safeTransferFrom(msg.sender, address(this), _amount);
    
        _setInvitor(msg.sender, _invitor);
        if(totalInvested + _amount > stepValue * (10**decimals)){
            stepTime = block.timestamp;
        }
        User storage player = users[msg.sender];
        if( player.total_invested == 0 ) 
            totalInvestors += 1;
            
        player.deposits.push(DepositTrans({
            amount: _amount,
            time: uint40(block.timestamp),
            investedTime: uint40(block.timestamp)
        }));  
        emit _Deposit(msg.sender, _amount, uint40(block.timestamp));
		
		uint256 fee = _amount / 100; 
		payToken.safeTransfer(dev, fee);
		payToken.safeTransfer(team, fee + fee);

        player.total_invested += _amount;
        
        totalInvested += _amount;
        totalWithdrawn += fee * 3;
        commissionPayouts(msg.sender, _amount);
    }

    function redeposit() external {   
		require(banned[msg.sender] == false, 'Banned Wallet!');
        User storage player = users[msg.sender];

        updateUserState(msg.sender);

        require(player.dividends >= DEPOSIT_MIN_AMOUNT * (10**decimals), "Minimum reinvest is 10 BUSD.");

        uint256 amount =  player.dividends;
        player.dividends = 0;
		
        uint256 fee = amount / 100; 
		payToken.safeTransfer(dev, fee);
		payToken.safeTransfer(team, fee + fee);

        player.total_withdrawn += amount;
        totalWithdrawn += amount + fee * 3; 
        totalClaimed += amount; 
		
        player.deposits.push(DepositTrans({
            amount: amount,
            time: uint40(block.timestamp),
            investedTime: 0
        }));  
        emit _Reinvest(msg.sender, amount, uint40(block.timestamp));

        player.total_invested += amount;
        player.total_reinvested += amount;
        
        totalInvested += amount;
		totalReinvested += amount;    	
    }
	
    function claim() external {      
        require(banned[msg.sender] == false,'Banned Wallet!');
        User storage player = users[msg.sender];

        require (block.timestamp >= (player.last_withdrawn + claimPeriod), "You should wait until next claim date.");

        updateUserState(msg.sender);

        require(player.dividends >= CLAIM_MIN_AMOUNT * (10**decimals), "It is less than minimum claim amount.");

        uint256 amount =  player.dividends;
        player.dividends = 0;
        
        player.total_withdrawn += amount;
        
		payToken.safeTransfer(msg.sender, amount);
		emit _Payout(msg.sender, amount);
        
		totalWithdrawn += amount;    
        totalClaimed += amount;
    }
	

    function pendingReward(address _addr) view external returns(uint256 value) {
		if(banned[_addr] == true ){ return 0; }
        User storage player = users[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            DepositTrans storage dep = player.deposits[i];

            uint256 _rewardStartTime = player.last_withdrawn;
            if( player.last_withdrawn < dep.time ) {
                _rewardStartTime = dep.time;
            }

            for(uint256 k = rewardConfigs.length - 1; k >= 0; k -- ) {
                uint8 _dailyReward = rewardConfigs[k].reward;
                uint40 _setTime = rewardConfigs[k].time;
                uint40 _endTime;
                if( k < rewardConfigs.length - 1 )
                    _endTime = rewardConfigs[k+1].time;
                else 
                    _endTime = uint40(block.timestamp);

                uint256 _startTime = max(_setTime, _rewardStartTime);
                if( _startTime >= _endTime )
                    break;

                value += (_endTime - _startTime) * dep.amount * _dailyReward / PERCENT_DIVIDER / 86400;

                if( _setTime <= _rewardStartTime ) 
                    break;
            }
        }
        return value;
    }

 
    function updateUserState(address _addr) private {
        uint256 payout = this.pendingReward(_addr);

        if(payout > 0) {            
            users[_addr].last_withdrawn = uint40(block.timestamp);
            users[_addr].dividends += payout;
        }
    }      


    function _setInvitor(address _addr, address _invitor) private {
        if( _invitor != address(0) && _addr != _invitor && users[_addr].invitor == address(0) ) {
            users[_addr].invitor = _invitor;
            
            User storage invitor = users[_invitor];
            invitor.invitation_count++;
            invitor.invited_users.push(_addr);  
        }
    } 
        
    function commissionPayouts(address _addr, uint256 _amount) private {
        address invitor = users[_addr].invitor;

        if(invitor == address(0)) return;
        if(banned[invitor] == false )
		{   
            uint256 ref_bonus = REFERRAL_BONUS;
            if(block.timestamp > launchTime + 30 days){
                ref_bonus = REFERRAL_BONUS_1;
            }

			uint256 bonus = _amount * ref_bonus / PERCENT_DIVIDER;
		    
			payToken.safeTransfer(invitor, bonus);
			
			users[invitor].total_referral_bonus += bonus;
			users[invitor].total_withdrawn += bonus;

			totalReferralBonus += bonus;
			totalWithdrawn += bonus;
		}    
    }
    
    function applyToBot(uint256 _amount, address _botAddress) public onlyOwner {
	    payToken.safeTransfer(_botAddress, _amount);
    }

    function addRewardFromBot(uint256 _amount) public onlyOwner {
        payToken.safeTransferFrom(msg.sender, address(this), _amount);
    }
	
    function nextClaimDate(address _addr) view external returns(uint40 nextDate) {
		if(banned[_addr] == true ) { return 0; }
        User storage player = users[_addr];
        if(player.deposits.length > 0 && player.last_withdrawn > 0)
        {
          return uint40(player.last_withdrawn + claimPeriod);
        }
        return 0;
    }

    function setPaymentToken(address tokenAddr) public onlyOwner {
        payTokenAddress = tokenAddr;
    }  

    function setLimitAmount(uint8 _deposit, uint8 _claim) public onlyOwner {
        DEPOSIT_MIN_AMOUNT = _deposit;
        CLAIM_MIN_AMOUNT = _claim;
    }  

    function setDaliyReward(uint8 rewardPercent) public onlyOwner {
        dailyReward = rewardPercent; // 22 = 2.2%
        rewardConfigs.push(
            RewardConfig({
                reward: rewardPercent,
                time: uint40(block.timestamp)
            })
        );
    } 

    function setInvitor(address _addr, address _invitor) public onlyOwner
    {
        users[_addr].invitor = _invitor;
    }

    function setTeam(address payable addr) public onlyOwner {
        team = addr;
    }     
   
    function setClaimPeriod(uint256 periodSeconds) public onlyOwner {    
        claimPeriod = periodSeconds;
    }    

    function setRefundLimitDate(uint8 _refundLimitDate) public onlyOwner {
        refundLimitDate = _refundLimitDate;
    }
    
    function setStepValue(uint256 _stepValue) public onlyOwner {
        stepValue = _stepValue;
    }

	function banWallet(address wallet) public onlyOwner {
        banned[wallet] = true;
    }
	
	function unbanWallet(address wallet) public onlyOwner {
        banned[wallet] = false;
    }

    function refundAll(address[] memory wallets) public onlyOwner {
        for (uint256 i=0; i < wallets.length; i++) {
            refundOne(wallets[i]);
        }
    }
	
	function refundOne(address wallet) internal {
	       
        if(banned[wallet] == true ){ return; }
        User storage player = users[wallet]; 
        if(player.total_invested == 0){
            return;
        }
        uint256 amount = 0;
        for(uint256 i = 0; i < player.deposits.length; i++) {
            DepositTrans storage dep = player.deposits[i];
            if(dep.investedTime > 0 && (block.timestamp >= dep.investedTime + (refundLimitDate * DAY))){
                amount += dep.amount;
            }
        }
        if(amount == 0){
            return;
        }
		player.total_refunded += amount;
		totalWithdrawn += amount;
		totalRefunded += amount;
        payToken.safeTransfer(wallet, amount);
		emit _Refund(wallet, amount);
		banned[wallet] = true;
    }

    function userInfo(address _addr) view external returns(
        uint256 totalDeposited,
        uint256 totalReferralEarnings,
        uint256 totalClaimedRewards,
        uint256 totalUserWithdrawn,
        uint256 unclaimedReward, 
        uint256 numDeposits,  
		uint40 invitationCount) {

        User storage player = users[_addr];
        uint256 payout = this.pendingReward(_addr);      

        return (
            player.total_invested,
            player.total_referral_bonus,
            player.total_withdrawn - player.total_referral_bonus,
            player.total_withdrawn,
            payout + player.dividends,
            player.deposits.length,
            player.invitation_count
        );
    }
    
    function invitedUser(address _addr, uint256 _index) view external returns(address)
    {
        User storage player = users[_addr];
        return player.invited_users[_index];
    }

    function depositedData(address _addr, uint256 _index) view external returns(uint40 time, uint256 amount, uint40 investedTime)
    {
        User storage player = users[_addr];
        DepositTrans storage dep = player.deposits[_index];
        return(dep.time, dep.amount, dep.investedTime);
    }

    function getBNBBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getContractBalance() public view returns (uint256) {
        return IERC20(payTokenAddress).balanceOf(address(this));
    }

    function max(uint256 a, uint256 b) public pure returns(uint256) {
        if( a > b ) 
            return a;

        return b;
    }
}