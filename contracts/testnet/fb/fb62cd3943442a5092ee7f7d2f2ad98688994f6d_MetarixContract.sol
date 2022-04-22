/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: UNLICENSED

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

//OWnABLE contract that define owning functionality
contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
  constructor() public {
    owner = msg.sender;
  }

  /**
    * @dev Throws if called by any account other than the owner.
    */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

//SeedifyFundsContract

contract MetarixContract is Ownable {

  //token attributes
  string public constant NAME = "Metarix"; //name of the contract
  uint public immutable maxCap; // Max cap in BNB
  uint256 public immutable saleStartTime; // start sale time
  uint256 public immutable saleEndTime; // end sale time
  uint256 public totalBnbReceived; // total bnd received
  uint public totalparticipants; // total participants in ido
  address payable public projectOwner; // project Owner
  
  // CONSTRUCTOR  
  constructor(uint _maxCap, uint256 _saleStartTime, uint256 _saleEndTime, address payable _projectOwner) public {
    maxCap = _maxCap;
    saleStartTime = _saleStartTime;
    saleEndTime = _saleEndTime;    
    projectOwner = _projectOwner;   
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
        totalparticipants +=1;
    }
 
  // send bnb to the contract address
  function buy() external payable {

     require(now >= saleStartTime, "The sale is not started yet "); // solhint-disable
     require(now <= saleEndTime, "The sale is closed"); // solhint-disable
     require(totalBnbReceived + msg.value <= maxCap, "buyTokens: purchase would exceed max cap");

      totalBnbReceived += msg.value;
      sendValue(projectOwner, address(this).balance);      
   
  }
}