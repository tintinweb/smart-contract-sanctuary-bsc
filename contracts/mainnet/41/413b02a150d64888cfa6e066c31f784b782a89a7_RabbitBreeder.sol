/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

/*                                                                                          
@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@@@@
@@@@@   @&    @@@@@@@@@@@@@@@@@@@@@@@    &,   @@@@
@@@@@  &&*&&   @@@@@@@@@@@@@@@@@@@@   *&&*&/  @@@@
@@@@@  &&**,&%  @@@@@@@@@@@@@@@@@@   &&,**&(  @@@@
@@@@@  *&**,,&@  @@@@@@@@@@@@@@@@   &&,,**&   @@@@
@@@@@   &&*,,,&&  @@@@@@@@@@@@@@   &&,,,*&&   @@@@
@@@@@@  &&*,,,,&   @@@@@@@@@@@@.  &&,,,**&   @@@@@
@@@@@@   &&,,,#&&   @@@@@@@@@@@  %&##,,*&&  %@@@@@
@@@@@@@   &,####&&   @@@@@@@@@   &%####&&   @@@@@@
@@@@@@@@  &&#####&&             &&####&&   @@@@@@@
@@@@@@@@   @&##%&&&&&&&&&&&&&&&&&&&###&   @@@@@@@@
@@@@@@@@    &&&&&%////////##%..  @&&&&&   /@@@@@@@
@@@@@@   .&&&&%%##////(###%&.......& &&&&    @@@@@
@@@@@   &&&&,..&&&%%%%%%&,[email protected] &&&&   @@@@
@@@@  .&&&,[email protected]@&.................&&@...,&&&   @@@
@@@   &&&,... &&&&...............&&& @...(&&&   @@
@@@  &&&&,....&&&.....       .....&&&....,&&&   @@
@@@  &&&&,......                   ......,&&&.  @@
@@@   &&&,,....         [email protected]         ....,&&&&   @@
@@@@   &&&&,..                       ..,&&&&   @@@
@@@     &&&&&,,                     ,,&&&&%    ,@@
@    &&&&&##&&&&&&(.....   ......&&&&&@##&&&&&    
   &&##########&&&&&&&&&&&&&&&&&&&&###((###(#&&&                                                                                                                            
*/

pragma solidity ^0.8.13;

contract RabbitBreeder {

    // constants
    uint constant rabbit_TO_BREEDING_BREEDER = 1080000;
    uint constant PSN = 10000;
    uint constant PSNH = 5000;

    // attributes
    uint public marketrabbit;
    uint public startTime = 8888888888888888;
    address public owner;
    address public address2;
    mapping (address => uint) private lastBreeding;
    mapping (address => uint) private breedingBreeders;
    mapping (address => uint) private claimedrabbit;
    mapping (address => uint) private tempClaimedrabbit;
    mapping (address => address) private referrals;
    mapping (address => ReferralData) private referralData;

    // structs
    struct ReferralData {
        address[] invitees;
        uint rebates;
    }

    // modifiers
    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyOpen {
        require(block.timestamp > startTime, "not open");
        _;
    }

    modifier onlyStartOpen {
        require(marketrabbit > 0, "not start open");
        _;
    }

    // events
    event Create(address indexed sender, uint indexed amount);
    event Merge(address indexed sender, uint indexed amount);

    constructor() {
        owner = msg.sender;
        address2 = 0x070F32bB8cfBE8Db352db4Fd7674a950aAa7E7d0;
    }

    // Create rabbit
    function createrabbit(address _ref) external payable onlyStartOpen {
        uint rabbitDivide = calculaterabbitDivide(msg.value, address(this).balance - msg.value);
        rabbitDivide -= devFee(rabbitDivide);
        uint fee = devFee(msg.value);

        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee * 80 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool address2Success, ) = address2.call{value: fee * 20 / 100}("");
        require(address2Success, "address2 pay failed");

        claimedrabbit[msg.sender] += rabbitDivide;
        dividerabbit(_ref);

        emit Create(msg.sender, msg.value);
    }

    // Divide rabbit
    function dividerabbit(address _ref) public onlyStartOpen {
        if (_ref == msg.sender || _ref == address(0) || breedingBreeders[_ref] == 0) {
            _ref = owner;
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = _ref;
            referralData[_ref].invitees.push(msg.sender);
        }

        uint rabbitUsed = getMyrabbit(msg.sender);
        uint newBreeders = rabbitUsed / rabbit_TO_BREEDING_BREEDER;
        breedingBreeders[msg.sender] += newBreeders;
        claimedrabbit[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp > startTime ? block.timestamp : startTime;
        
        // referral rebate
        uint rabbitRebate = rabbitUsed * 13 / 100;
        if (referrals[msg.sender] == owner) {
            claimedrabbit[owner] += rabbitRebate * 80 / 100;
            claimedrabbit[address2] += rabbitRebate * 20 / 100;
            tempClaimedrabbit[owner] += rabbitRebate * 80 / 100;
            tempClaimedrabbit[address2] += rabbitRebate * 20 / 100;
        } else {
            claimedrabbit[referrals[msg.sender]] += rabbitRebate;
            tempClaimedrabbit[referrals[msg.sender]] += rabbitRebate;
        }
        
        marketrabbit += rabbitUsed / 5;
    }

    // Merge rabbit
    function mergerabbit() external onlyOpen {
        uint hasrabbit = getMyrabbit(msg.sender);
        uint rabbitValue = calculaterabbitMerge(hasrabbit);
        uint fee = devFee(rabbitValue);
        uint realReward = rabbitValue - fee;

        if (tempClaimedrabbit[msg.sender] > 0) {
            referralData[msg.sender].rebates += calculaterabbitMerge(tempClaimedrabbit[msg.sender]);
        }
        
        // dev fee
        (bool ownerSuccess, ) = owner.call{value: fee * 80 / 100}("");
        require(ownerSuccess, "owner pay failed");
        (bool address2Success, ) = address2.call{value: fee * 20 / 100}("");
        require(address2Success, "address2 pay failed");

        claimedrabbit[msg.sender] = 0;
        tempClaimedrabbit[msg.sender] = 0;
        lastBreeding[msg.sender] = block.timestamp;
        marketrabbit += hasrabbit;

        (bool success1, ) = msg.sender.call{value: realReward}("");
        require(success1, "msg.sender pay failed");
    
        emit Merge(msg.sender, realReward);
    }

    //only owner
    function seedMarket(uint _startTime) external payable onlyOwner {
        require(marketrabbit == 0);
        startTime = _startTime;
        marketrabbit = 108000000000;
    }

    function rabbitRewards(address _address) public view returns(uint) {
        return calculaterabbitMerge(getMyrabbit(_address));
    }

    function getMyrabbit(address _address) public view returns(uint) {
        return claimedrabbit[_address] + getrabbitSinceLastDivide(_address);
    }

    function getClaimrabbit(address _address) public view returns(uint) {
        return claimedrabbit[_address];
    }

    function getrabbitSinceLastDivide(address _address) public view returns(uint) {
        if (block.timestamp > startTime) {
            uint secondsPassed = min(rabbit_TO_BREEDING_BREEDER, block.timestamp - lastBreeding[_address]);
            return secondsPassed * breedingBreeders[_address];     
        } else { 
            return 0;
        }
    }

    function getTempClaimrabbit(address _address) public view returns(uint) {
        return tempClaimedrabbit[_address];
    }
    
    function getPoolAmount() public view returns(uint) {
        return address(this).balance;
    }
    
    function getBreedingBreeders(address _address) public view returns(uint) {
        return breedingBreeders[_address];
    }

    function getReferralData(address _address) public view returns(ReferralData memory) {
        return referralData[_address];
    }

    function getReferralAllRebate(address _address) public view returns(uint) {
        return referralData[_address].rebates;
    }

    function getReferralAllInvitee(address _address) public view returns(uint) {
       return referralData[_address].invitees.length;
    }

    function calculaterabbitDivide(uint _eth,uint _contractBalance) private view returns(uint) {
        return calculateTrade(_eth, _contractBalance, marketrabbit);
    }

    function calculaterabbitMerge(uint rabbit) public view returns(uint) {
        return calculateTrade(rabbit, marketrabbit, address(this).balance);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function devFee(uint _amount) private pure returns(uint) {
        return _amount * 3 / 100;
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}