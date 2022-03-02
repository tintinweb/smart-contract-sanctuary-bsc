/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
  
  function _now() internal view returns (uint256) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return block.timestamp;
  }
}


contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    _owner = _msgSender();
    emit OwnershipTransferred(address(0), _msgSender());
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
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

contract TNG_IDO_Distribution is Ownable, ReentrancyGuard {

    IERC20 public _tngToken;
    //uint256 private _tngTokenDecimal = 18;
    uint256 public IDO_Rate = 9260 * 10 ** 18;       //1BNB = 9360 TNG token

    //Token vesting 
    uint256[] public _claimableTimeStamp;
    mapping(uint256 => uint256) public _claimablePercents;

    //Store the information of all users
    mapping(address => Account) public accounts;

    uint256 public _totalPendingVestingToken;   // Counter to track total required tokens

    struct Account {
        uint256 _userContribution;              // user's total contribution in IDO (BNB in wei)
        uint256 _userTokenAllocation;           // user's total token allocation 
        uint256 _userPendingTokenAllocation;    // user's pending token allocation
        uint256 _userClaimIndex;                // user's claimed at which index. 0 means never claim
        uint256 _userClaimedTimestamp;          // user's last claimed timestamp. 0 means never claim
    }

    constructor(address tngAddress){
        _tngToken = IERC20(tngAddress);

        //THIS PROPERTIES WILL BE SET WHEN DEPLOYING CONTRACT
        _claimableTimeStamp = [
            1648684800,     // Thursday, 31 March 2022 00:00:00 UTC
            1656547200,     // Thursday, 30 June 2022 00:00:00 UTC       
            1664496000,     // Friday, 30 September 2022 00:00:00 UTC
            1672444800];    // Saturday, 31 December 2022 00:00:00 UTC

        _claimablePercents[1648684800] = 10;
        _claimablePercents[1656547200] = 30;
        _claimablePercents[1664496000] = 30;
        _claimablePercents[1672444800] = 30;
    }

    // Register token allocation info 
    // account : IDO address
    // userContribution : IDO contribution amount in BNB 
    function register(address[] memory account, uint256[] memory userContribution) external onlyOwner{
        require(account.length > 0, "Account array input is empty");
        require(userContribution.length > 0, "userContribution array input is empty");
        require(userContribution.length == account.length, "userContribution length does not matched with account length");
        
        //Iterate through the inputs
        for(uint256 index = 0; index < account.length; index++){
            //Save into account info
            Account storage userAccount = accounts[account[index]];
            userAccount._userContribution = userContribution[index];
            userAccount._userTokenAllocation = userContribution[index] * IDO_Rate / 1 ether;
            userAccount._userPendingTokenAllocation = userAccount._userTokenAllocation;
            // For tracking purposes
            _totalPendingVestingToken += userAccount._userTokenAllocation;
        }
    }

    function claim() external nonReentrant returns(bool _sent){
        Account storage userAccount = accounts[_msgSender()];
        uint256 userTokenAllocation = userAccount._userTokenAllocation;
        require(userTokenAllocation > 0, "Nothing to claim, no token allocation registered");
        require(_claimableTimeStamp.length > 0, "Can not claim at this time, no claimable time registered");
        require(block.timestamp >= _claimableTimeStamp[0], "Can not claim at this time");

        uint256 startIndex = userAccount._userClaimIndex;
        require(startIndex < _claimableTimeStamp.length, "You have claimed all token");

        //Calculate user vesting distribution amount
        uint256 tokenQuantity = 0;
        uint256 claimIndex = userAccount._userClaimIndex;   
        for(uint256 index = startIndex; index < _claimableTimeStamp.length; index++){

            uint256 claimTimestamp = _claimableTimeStamp[index];   
            if(block.timestamp >= claimTimestamp){
                claimIndex++;
                tokenQuantity += userTokenAllocation * _claimablePercents[claimTimestamp] / 100;
            }else{
                break;
            }
        }
        require(tokenQuantity > 0, "Nothing to claim at the moment.");

        //Validate whether contract token balance is sufficient
        uint256 contractTokenBalance = _tngToken.balanceOf(address(this));
        require(contractTokenBalance >= tokenQuantity, "Contract token quantity is not sufficient");

        //Update user details
        userAccount._userClaimedTimestamp = block.timestamp;
        userAccount._userClaimIndex = claimIndex;
        userAccount._userPendingTokenAllocation -= tokenQuantity;

        //For tracking
        _totalPendingVestingToken -= tokenQuantity;

        //Release token
        _sent = _tngToken.transfer(_msgSender(), tokenQuantity);

        emit Claimed(_msgSender(), tokenQuantity);
    }

    // Calculate claimable tokens at current timestamp
    function getClaimable(address account) external view returns(uint256){
        Account storage userAccount = accounts[account];
        uint256 userTokenAllocation = userAccount._userTokenAllocation;
        uint256 claimIndex = userAccount._userClaimIndex;

        if(userTokenAllocation == 0) return 0;
        if(_claimableTimeStamp.length == 0) return 0;
        if(block.timestamp < _claimableTimeStamp[0]) return 0;
        if(claimIndex >= _claimableTimeStamp.length) return 0;

        uint256 tokenQuantity = 0;
        for(uint256 index = claimIndex; index < _claimableTimeStamp.length; index++){

            uint256 claimTimestamp = _claimableTimeStamp[index];
            if(block.timestamp >= claimTimestamp){
                tokenQuantity += userTokenAllocation * _claimablePercents[claimTimestamp] / 100;
            }else{
                break;
            }
        }

        return tokenQuantity;
    }

    // Update TheNextWar Gem token address
    function setTngToken(address newAddress) external onlyOwner{
        require(newAddress != address(0), "Zero address");
        _tngToken = IERC20(newAddress);
    }

    // Update claimable timestamp, in epoch formate
    function setClaimableTime(uint256[] memory timestamp) external onlyOwner{
        require(timestamp.length > 0, "Empty timestamp input");
        _claimableTimeStamp = timestamp;
    }

    // Update claim percentage. Timestamp must match with _claimableTime
    function setClaimablePercents(uint256[] memory timestamp, uint256[] memory percents) external onlyOwner{
        require(timestamp.length > 0, "Empty timestamp input");
        require(timestamp.length == percents.length, "Array size not matched");
        for(uint256 index = 0; index < timestamp.length; index++){
            _claimablePercents[timestamp[index]] = percents[index];
        }
    }

    // Rescue any tokens incase anyone transferred other tokens into the contract
    function rescueToken(address _token, address _to) public onlyOwner returns(bool _sent){
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    // Rescue any tokens incase anyone transferred other tokens into the contract
	function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

	receive() external payable {}

    event Claimed(address account, uint256 tokenQuantity);
}