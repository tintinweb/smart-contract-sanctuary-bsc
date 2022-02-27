/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract TheNextGemIDO is Ownable {
    using SafeMath for uint256;

    address payable public _icoRecipientAddress;

    uint256 public constant _minContribution = 0.3 * 10**18;    //0.3 bnb min contribution
    uint256 public constant _maxContribution = 10 * 10**18;     //10 bnb max contribution

    uint256 public _startTimestamp;
    uint256 public _endTimestamp;
    uint256 public _totalBnbRaised = 0;
    uint256 public _totalParticipants = 0;

    //Store the number of token that user can buy
    //Mapping user address and the number of ELMON user can buy
    mapping(address => bool) public _whiteLists;
    mapping(address => uint256) public _userContribution;
    mapping(address => uint256) public _claimCounts;

    constructor(address icoRecipientAddress){
        _icoRecipientAddress = payable(icoRecipientAddress);
        _startTimestamp = block.timestamp + 1 hours;
        _endTimestamp = _startTimestamp + 24 hours;
    }

    function contribute() public payable {
        require(_icoRecipientAddress != address(0), "ICO recepient address has not been setted");
        require(block.timestamp >= _startTimestamp && block.timestamp <= _endTimestamp, "Can not register at this time");
        require(_whiteLists[_msgSender()], "You are not in whitelist");

        uint256 _contributionInBnb = msg.value;
        uint256 _totalContributionInBnb = _userContribution[_msgSender()].add(_contributionInBnb);

        require(_totalContributionInBnb  <= _maxContribution, "Total contribution exceeded maximum contribution threshold");
        require(_totalContributionInBnb >= _minContribution, "Contribution is lower than minimum contribution threshold");
        require(_contributionInBnb <= _maxContribution, "Contribution exceeded maximum contribution threshold");
        
        //Add participants count if participant never contribute before
        if(_userContribution[_msgSender()] == 0)
            _totalParticipants++;

        //Forward funds to treasury
        _forwardFunds(_contributionInBnb);

        //Add contribution amount for selected address
        _userContribution[_msgSender()] += _contributionInBnb;

        //Add contribution amount to totalBnbPool
        _totalBnbRaised += _contributionInBnb;

        emit Contributed(_msgSender(), _contributionInBnb);
    }

    function setIcoRecipientAddress(address newAddress) external onlyOwner{
        require(newAddress != address(0), "Zero address");
        _icoRecipientAddress = payable(newAddress);
    }

    function setIcoStartEndTime(uint256 startTimestamp, uint256 endTimestamp) external onlyOwner{
        require(startTimestamp < endTimestamp, "Start block should be less than end block");
        _startTimestamp = startTimestamp;
        _endTimestamp = endTimestamp;
    }

    function addToWhiteList(address[] memory accounts) external onlyOwner{
        require(accounts.length > 0, "Invalid input");
        for(uint256 index = 0; index < accounts.length; index++){
            _whiteLists[accounts[index]] = true;
        }
    }

    function removeFromWhiteList(address[] memory accounts) external onlyOwner{
        require(accounts.length > 0, "Invalid input");
        for(uint256 index = 0; index < accounts.length; index++){
            _whiteLists[accounts[index]] = false;
        }
    }

    function _forwardFunds(uint256 contributionInBnb) internal {
        _icoRecipientAddress.transfer(contributionInBnb);
    }

    function rescueToken(address _token, address _to) public onlyOwner returns(bool _sent){
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

	function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
	
	receive() external payable {}
	
    event Contributed(address account, uint256 _contributionInBnb);
}