/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

contract IDO is Ownable, ReentrancyGuard {

    uint256 public participatePeoples;  // total number of participants

    uint256 public limit;
    uint256 public crowdFundMax;        // the most popular amount raised

    uint256 public startime;        // start time
    uint256 public endtime;         // end time
    uint256 public harvestStartime; // start time of collection
    uint256 public harvestEndtime;  // end time of collection

    uint256 public minEth;          // minimum participation amount
    uint256 public maxEth;          // maximum participation amount

    uint256 public exchangeRatio;    // exchange ratio
    uint256 public rakeBackRatio;    // invit commission ratio
    uint256 public releaseRatio;     // release ratio

    address public payOutToken;     // token contract address
    address public payOutAddress;   // token payout address

    mapping (address => DepositeItem) private userDeposite; // deposit records
    mapping (address => InvitationItem) private invitation;        // invitation

    struct DepositeItem {
        // address superior;   // superior address
        uint256 amount;     // participation amount
        uint256 startime;   // participation time
        uint256 harvestime; // harvest time
    }

    struct InvitationItem {
        uint256 counts; // invitation count
        uint256 reward; // reward amount
    }
    
    event Deposite(address indexed owner, uint256 amount);
    event Harvest(address indexed owner, uint256 amount);

    constructor(address _payOutToken, address _payOutAddress) {
        payOutToken = _payOutToken;
        payOutAddress = _payOutAddress;

        limit = 56000e18;
        exchangeRatio = 280;
        rakeBackRatio = 200;
        releaseRatio = 1000; // 100% release

        crowdFundMax = 200e18;
        minEth = 0.2e18;
        maxEth = 2e18;

        startime = block.timestamp;
        endtime = startime + 7 days;
        harvestStartime = endtime + 1 seconds;
        harvestEndtime = harvestStartime + 7 days;
    }

    /**
     * @dev  query user participation in crowdfunding
     * @param _owner participant Address
     */
    function getDepositeInfo(address _owner) public view returns (DepositeItem memory) {
        return userDeposite[_owner];
    }


    /**
     * @dev  query user invitation info
     * @param _owner participant Address
     */
    function getInvitationInfo(address _owner) public view returns (InvitationItem memory) {
        return invitation[_owner];
    }


    /**
     * @dev  query user harvest info
     * @param _owner participant Address
     */
    function getHarvestInfo(address _owner) public view returns (uint256, uint256) {
        DepositeItem memory userDep = userDeposite[_owner];
        if (userDep.harvestime < harvestStartime){
            uint256 releaseAmount = userDep.amount * releaseRatio / 1000;

            if (releaseAmount > userDep.amount) {
                releaseAmount = userDep.amount;
            }

            // can harvest amount and not release amount
            return (releaseAmount * exchangeRatio, (userDep.amount - releaseAmount) * exchangeRatio);
        } else {
            return (0, userDep.amount * exchangeRatio);
        }
    }
    

    /**
     * @dev  set transaction exchange ratio
     * @param deno ratio => token/bnb
     */
    function setExchangeRate(uint256 deno) external onlyOwner {
        exchangeRatio = deno;
    }

    /**
     * @dev  set transaction exchange ratio
     * @param _crowdFundMax most popular fund raising
     */
    function setCrowdFundMax(uint256 _crowdFundMax) external onlyOwner {
        crowdFundMax = _crowdFundMax;
    }


     /**
     * @dev  set transaction exchange ratio
     * @param _limit most popular fund raising
     */
    function setCrowdLimit(uint256 _limit) external onlyOwner {
        limit = _limit;
    }

    /**
     * @dev  set the amount range of participating IDOs
     * @param _min mix value
     * @param _max max value
     */
    function setparticipateMinAndMax(uint256 _min, uint256 _max) external onlyOwner {
        minEth = _min;
        maxEth = _max;
    }

    /**
     * @dev  set Release Scale
     * @param _releaseRatio release ratio
     */
    function setReleaseRate(uint256 _releaseRatio) external onlyOwner {
        releaseRatio = _releaseRatio;
    }

    /**
     * @dev  set commission rake back ratio
     * @param _rakeBackRatio rake back ratio
     */
    function setRakeBackRate(uint256 _rakeBackRatio) external onlyOwner {
        rakeBackRatio = _rakeBackRatio;
    }

    /**
     * @dev  set token spending wallet address
     * @param _payOutAddress payout address
     */
    function setPayOutAddress(address _payOutAddress) external onlyOwner {
        payOutAddress = _payOutAddress;
    }

    /**
     * @dev  set the contract address for the project to participate in crowdfunding payment
     * @param _payOutToken payout address
     */
    function setPayOutToken(address _payOutToken) external onlyOwner {
        payOutToken = _payOutToken;
    }


    /**
     * @dev  set IDO start time
     * @param _startime start time
     * @param _endtime end time
     */
    function setStartimeAndEndtime(uint256 _startime, uint256 _endtime) external onlyOwner {
        startime = _startime;
        endtime = _endtime;
    }

    /**
     * @dev  set the collection time of crowdfunding rewards
     * @param _harvestStartime harvest start time
     * @param _harvestEndtime harvest end time
     */
    function setHarvestime(uint256 _harvestStartime, uint256 _harvestEndtime) external onlyOwner {
        harvestStartime = _harvestStartime;
        harvestEndtime = _harvestEndtime;
    }

     /**
     * @dev  crowdfunding by eth
     */
    function deposite() payable external {
        // open time
        require(block.timestamp >= startime && block.timestamp <= endtime, "Not start");
        // require(_superior != address(0), "The recommender is zero address");

        // limit participation amount
        require(msg.value >= minEth, "Amount is too low");
        require(msg.value <= maxEth, "Amount is too large");

        // limit maximum crowdfunding
        limit = limit - msg.value * exchangeRatio;
        require(limit > 0, "Crowdfund end");

        DepositeItem storage userDep = userDeposite[msg.sender];

        // you can only participate once
        require(userDep.startime == 0, "You can only participate once");

        // userDep.superior = _superior;
        userDep.startime = block.timestamp;
        userDep.amount = userDep.amount + msg.value;
        participatePeoples = participatePeoples + 1;
    
        // invit rake back
        // uint256 ivintAmount = msg.value * rakeBackRatio / 1000;
        // payable(userDep.superior).transfer(ivintAmount); // quantity of commission rake back to superior

        // invit records
        // InvitationItem storage invit =  invitation[_superior];
        // invit.counts = invit.counts + 1;
        // invit.reward = invit.reward + ivintAmount;

        emit Deposite(msg.sender, msg.value);
    }

    /**
     * @dev  receive rewards for participating in crowdfunding
     */
    function harvest() external nonReentrant {
        require(block.timestamp >= harvestStartime && block.timestamp <= harvestEndtime, "Not available");
        
        DepositeItem storage userDep = userDeposite[msg.sender];

        require(userDep.harvestime < harvestStartime, "Cannot claim repeatedly");

        // check whether the user participates
        require(userDep.amount > 0, "Insufficient funds");

        uint256 releaseAmount = userDep.amount * releaseRatio / 1000;

        if (releaseAmount > userDep.amount) {
            releaseAmount = userDep.amount;
        }

        uint256 payOutReleasesAmount = releaseAmount * exchangeRatio;
        userDep.amount = userDep.amount - releaseAmount;
        
        IERC20(payOutToken).transferFrom(payOutAddress, msg.sender, payOutReleasesAmount);// number of tokens available to participants

        userDep.harvestime = block.timestamp;

        emit Harvest(msg.sender, payOutReleasesAmount);
    }

    /**
     * @dev  withdrawal of crowdfunding ETH funds
     */
    function withdrawal() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficient funds");
        payable(msg.sender).transfer(balance);
    }
}