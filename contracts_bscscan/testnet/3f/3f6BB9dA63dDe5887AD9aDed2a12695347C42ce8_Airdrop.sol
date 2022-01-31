/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

pragma solidity >0.8.0;
//SPDX-License-Identifier: MIT

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

contract ownership{
    address payable public owner;
    
    constructor () {
      address addr = msg.sender;
      address payable wallet = payable(addr);
      owner = wallet;
    }
    
     function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }
}



/**
 * @title Airdrop
 * @dev give tokens to airdrop address
 */


contract Airdrop is Initializable, ownership{
    using SafeMath for uint;

    struct DropInfo {
        IERC20Token token;//Ksspad main Token
        bool REFERRAL_DROP; // when true, a referral address is granted benefits
        uint256 TOKEN_DECIMAL; // demimal of the token available for airdrop
        uint256 TOTAL_RECIEVERS; // total amount of recievers for airdrop
        uint256 DROP_AMOUNT; // amount of tokens earned by each reciever
        uint256 REFERRAL_AMOUNT; // amount of tokens earned by eachc refferer
        bool PAUSE_DROP; // When this is true claiming is paused 
    }
    struct DropData {
        uint256 TOTAL_RECIEVERS_CLAIMED; // Total amount of users that have claimed from airdrop
        uint256 TOTAL_TOKENS_CLAIMED; // Total amount of tokens clcaimed by users 
        uint256 TOTAL_REFERRERS; // Total amount of referes that have earned from the airdrop
        uint256 TOTAL_TOKENS_EARNED; // Total tokens earned by referrals

    }
    bool endDrop;
    address nothing = 0x000000000000000000000000000000000000dEaD;

    DropInfo public DROP_INFO;
    DropData public DROP_DATA;
    struct dropReciever {
        bool claimed;  // if true, that person has already claimed coins
        address referrer;  //address of the referrer
    }
    
     //fetch dropper information by address
     mapping(address => dropReciever) public DropperInfo;
     
    /**
     * Controller modifier
     **/
    
     address public AirdropController;
     modifier onlyController() {
     require(msg.sender == AirdropController, "You are not the controller of this airdrop");
     _;
    }
    /**
     * End Controller modifier
     **/

    function Contract_Setup( 
        IERC20Token Token_for_Drop, 
        uint256 _tokenDecimal, 
        uint256 dropTokenAmount,
        uint256 _totalRecievers, 
        uint8 _referralDrop,
        uint256 _referralAmount
        ) external {
        DROP_INFO.token = Token_for_Drop;
        DROP_INFO.TOKEN_DECIMAL = _tokenDecimal;
        DROP_INFO.DROP_AMOUNT = dropTokenAmount;
        DROP_INFO.TOTAL_RECIEVERS = _totalRecievers;
        DROP_INFO.REFERRAL_DROP = _referralDrop == 1;
        DROP_INFO.REFERRAL_AMOUNT = _referralAmount;
        AirdropController = msg.sender;
    }
    
     /**
     * Airdrop Claiming
     **/
    function ClaimAirdrop(address _referrer) public {
        address referrer = DROP_INFO.REFERRAL_DROP ? _referrer : nothing;
        dropReciever storage sender = DropperInfo[msg.sender];
        require(msg.sender != address(0), "the zero address cannot claim tokens");
        require(!sender.claimed, "You have already claimed tokens.");
        require(endDrop != true, "This airdrop has already ended");
        DROP_INFO.token.transfer(msg.sender, (DROP_INFO.DROP_AMOUNT)*10**DROP_INFO.TOKEN_DECIMAL);
        if (DROP_INFO.REFERRAL_DROP){
            DROP_INFO.token.transfer(referrer, (DROP_INFO.REFERRAL_AMOUNT)*10**DROP_INFO.TOKEN_DECIMAL);
        }

        //Update contract with claimer details
        sender.claimed = true;
        sender.referrer = referrer;
        
        //Update contractwith total tokens require at the end of the airdrop
        DROP_DATA.TOTAL_RECIEVERS_CLAIMED = DROP_DATA.TOTAL_RECIEVERS_CLAIMED ++;
        DROP_DATA.TOTAL_TOKENS_CLAIMED = DROP_DATA.TOTAL_TOKENS_CLAIMED.add(DROP_INFO.DROP_AMOUNT);
        if (DROP_INFO.REFERRAL_DROP){
            DROP_DATA.TOTAL_REFERRERS = DROP_DATA.TOTAL_REFERRERS ++;
            DROP_DATA.TOTAL_TOKENS_EARNED = DROP_DATA.TOTAL_TOKENS_EARNED.add(DROP_INFO.REFERRAL_AMOUNT);
        }
    }
     /**
     * End Airdrop Claiming 
     **/
    
    /**
     * Controller Buttons 
     **/
    
    //remove Tokens remaining
    function tokenRemover()public onlyController{
        require(DROP_INFO.token.balanceOf(address(this)) != 0, "There are no tokens to withdraw");
         DROP_INFO.token.transfer(AirdropController,DROP_INFO.token.balanceOf(address(this)));
    }
    
    
    function changeRecieveAmount(uint newAmount) public onlyController{
        DROP_INFO.DROP_AMOUNT = newAmount;
    }
    
    
    function controlAirdrop()public onlyController{
        DROP_INFO.PAUSE_DROP = !DROP_INFO.PAUSE_DROP;
    }
    
    function contToken(IERC20Token newTok)public{
        DROP_INFO.token = newTok;
    }
    /**
     * End Controller
     **/
}