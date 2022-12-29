/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SoftwareLocker {
    IERC20 public CLFI;
    IERC20 public LFI;

    struct softwareLicence {
    uint256 clfiRate;
    uint256 expiryPeriod;
    }

    uint256 interestRate = 12e18;
    uint256 rewardInNumberOfBlockes = 20;

    struct purchaseHistory{
    string softwareLicence;
    uint256 purchaseTime;
    uint256 expiryTime;
    }

    struct stakeRecord{
       string swLicence; 
       uint256 stakeAmount;
       uint256 timeFrame;
       uint256 lockTime;
       uint256 lockEndTime;
       uint256 lastUpdatedBlock;
       uint256 claimedAmount;

    }

    address public _owner;
    mapping(string => softwareLicence) public licenseRecord;
    mapping(string=>mapping(address=> purchaseHistory)) public licenceOwnership;
    mapping(string=>mapping(address=> stakeRecord)) public stakeHistory;

    constructor(IERC20 _clfi, IERC20 _lfi) {
        CLFI = _clfi;
        LFI = _lfi;
        _owner = msg.sender;
    }

       function owner() public view virtual returns (address) {
        return _owner;
    }
        modifier onlyOwner() {
        require(owner() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function addSoftware(string calldata _softwareLicence, uint256 _rate , uint256 _period) public onlyOwner
    {
        licenseRecord[_softwareLicence].clfiRate = _rate;
        licenseRecord[_softwareLicence].expiryPeriod = _period;

    }

    function buySoftware(string calldata _softwareLicence, uint256 amount)public {
        require(
            licenseRecord[_softwareLicence].clfiRate  <= amount,
            " amount is insufficient for purchase "
        );
        if (licenceOwnership[_softwareLicence][msg.sender].expiryTime == 0){
        CLFI.transferFrom(msg.sender, owner(), amount);
        licenceOwnership[_softwareLicence][msg.sender].softwareLicence = _softwareLicence;
        licenceOwnership[_softwareLicence][msg.sender].purchaseTime = block.timestamp;
        uint256 time = licenseRecord[_softwareLicence].expiryPeriod ;
        licenceOwnership[_softwareLicence][msg.sender].expiryTime = block.timestamp + time ;
        }
        if (licenceOwnership[_softwareLicence][msg.sender].expiryTime <= block.timestamp){
        CLFI.transferFrom(msg.sender, owner(), amount);
        licenceOwnership[_softwareLicence][msg.sender].softwareLicence = _softwareLicence;
        licenceOwnership[_softwareLicence][msg.sender].purchaseTime = block.timestamp;
        uint256 timeA = licenseRecord[_softwareLicence].expiryPeriod ;
        licenceOwnership[_softwareLicence][msg.sender].expiryTime = block.timestamp + timeA ;  
    }
    }

    function viewSoftwareBuy(string calldata _softwareLicence) public view returns  (bool flag){
       if ( licenceOwnership[_softwareLicence][msg.sender].purchaseTime == 0 || licenceOwnership[_softwareLicence][msg.sender].expiryTime <= block.number){
           return false;
    }
    if (licenceOwnership[_softwareLicence][msg.sender].purchaseTime > 0 && licenceOwnership[_softwareLicence][msg.sender].expiryTime >=block.number ){
          return true;
    }
    }
    function Stake(string calldata _softwareLicence , uint256 amount , uint256 _timeFrame) public{
    require(amount > 0 ,"amount is greater than zero" );
    require(viewSoftwareBuy(_softwareLicence) == true, "software not purchase");
    require(licenceOwnership[_softwareLicence][msg.sender].purchaseTime > 0 , "software not purchase");
    require(licenceOwnership[_softwareLicence][msg.sender].expiryTime >= block.timestamp, "software licence has expired" );
    require(stakeHistory[_softwareLicence][msg.sender].stakeAmount == 0,"user have already staked" );
       CLFI.transferFrom(msg.sender,address(this), amount);
        stakeHistory[_softwareLicence][msg.sender].swLicence = _softwareLicence;
        stakeHistory[_softwareLicence][msg.sender].stakeAmount += amount;
        stakeHistory[_softwareLicence][msg.sender].timeFrame = _timeFrame;
        stakeHistory[_softwareLicence][msg.sender].lockTime = block.timestamp;
        stakeHistory[_softwareLicence][msg.sender].lastUpdatedBlock = block.number;
        stakeHistory[_softwareLicence][msg.sender].lockEndTime = block.timestamp + _timeFrame; 
    }

  function claim (string calldata _softwareLicence) public returns (uint256){
    uint blockPeriod;
    uint amount;
    (amount,blockPeriod)  = viewclaim(_softwareLicence,msg.sender);
       require(amount > 0, " wait for claim or already full claimed");
       LFI.transfer(msg.sender,amount);
       stakeHistory[_softwareLicence][msg.sender].claimedAmount += amount;
       stakeHistory[_softwareLicence][msg.sender].lastUpdatedBlock = block.number;
       return amount;
  }

  function viewclaim (string calldata _softwareLicence , address _account) public view returns(uint256 , uint256){
        uint blockPeriod = (block.number - stakeHistory[_softwareLicence][_account].lastUpdatedBlock) / rewardInNumberOfBlockes;        
        uint claimAmount = ( stakeHistory[_softwareLicence][_account].stakeAmount * (interestRate * blockPeriod)) / 100e18;
        if((stakeHistory[_softwareLicence][_account].claimedAmount + claimAmount) >=  (stakeHistory[_softwareLicence][_account].stakeAmount)
         || (stakeHistory[_softwareLicence][_account].lockEndTime  <= block.timestamp)) {
        claimAmount =  stakeHistory[_softwareLicence][_account].stakeAmount  - stakeHistory[_softwareLicence][_account].claimedAmount  ; 
        }
        return (claimAmount,blockPeriod); 
    }
    function getRateSoftware(string calldata _softwareLicence)
        public
        view
        returns (uint256)
    {
        return  licenseRecord[_softwareLicence].clfiRate;
    }

    function getBlocknumber() public view returns (uint){
      return  block.number;
    }
}