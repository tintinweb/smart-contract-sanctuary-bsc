pragma solidity 0.8.9;

contract BeansMiningSimulator {

    uint256 private constant BEANS_REQ_PER_GPU = 1_080_000; 
    uint256 private constant INITIAL_MARKET_BEANS = 108_000_000_000;
    uint256 public constant START_TIME = 1656597600;
    
    uint256 private constant PSN = 10000;
    uint256 private constant PSNH = 5000;

    uint256 private constant getDevFeeVal = 200;
    uint256 private constant getMarketingFeeVal = 100;

    uint256 private marketBEANS = INITIAL_MARKET_BEANS;

    uint256 public uniqueUsers;

    address public immutable owner;
    address payable private devFeeReceiver;
    address payable immutable private marketingFeeReceiver;

    mapping (address => uint256) private GPUs;
    mapping (address => uint256) private claimedBEANS;
    mapping (address => uint256) private lastactivation;
    mapping (address => bool) private hasParticipated;

    mapping (address => address) private referrals;

    error OnlyOwner(address);
    error NonZeroMarketBeans(uint);
    error FeeTooLow();
    error NotStarted(uint);

    modifier hasStarted() {
        if(block.timestamp < START_TIME) revert NotStarted(block.timestamp);
        _;
    }
    
    ///@dev unlockGPUs some intitial native coin deposit here
    constructor(address _devFeeReceiver, address _marketingFeeReceiver) payable {
        owner = msg.sender;
        devFeeReceiver = payable(_devFeeReceiver);
        marketingFeeReceiver = payable(_marketingFeeReceiver);
    }

    function changeDevFeeReceiver(address newReceiver) external {
        if(msg.sender != owner) revert OnlyOwner(msg.sender);
        devFeeReceiver = payable(newReceiver);
    }

    ///@dev should market beans be 0 we can resest to initial state and also (re-)fund the contract again if needed
    function init() external payable {
        if(msg.sender != owner) revert OnlyOwner(msg.sender);
        if(marketBEANS > 0 ) revert NonZeroMarketBeans(marketBEANS);
    }

    function fund() external payable {
        if(msg.sender != owner) revert OnlyOwner(msg.sender);
    }

    // buy token from the contract
    function buyBEANS(address ref) public payable hasStarted {

        uint256 beansBought = calculateBEANSBuy(msg.value, address(this).balance - msg.value);

        uint256 devFee = getDevFee(beansBought);
        uint256 marketingFee = getMarketingFee(beansBought);

        if(marketingFee == 0) revert FeeTooLow();

        beansBought = beansBought - devFee - marketingFee;

        devFeeReceiver.transfer(getDevFee(msg.value));
        marketingFeeReceiver.transfer(getMarketingFee(msg.value));

        claimedBEANS[msg.sender] += beansBought;

        if(!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            uniqueUsers++;
        }

        unlockGPUs(ref);
    }
    
    ///@dev handles referrals
    function unlockGPUs(address ref) public hasStarted {
        
        if(ref == msg.sender) ref = address(0);
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
            if(!hasParticipated[ref]) {
                hasParticipated[ref] = true;
                uniqueUsers++;
            }
        }
        
        uint256 beansUsed = getMyBEANS(msg.sender);
        uint256 myBEANSRewards = getBEANSSinceLastUnlock(msg.sender);
        claimedBEANS[msg.sender] += myBEANSRewards;

        uint256 newGPUs = claimedBEANS[msg.sender] / BEANS_REQ_PER_GPU;
        claimedBEANS[msg.sender] -= (BEANS_REQ_PER_GPU * newGPUs);
        GPUs[msg.sender] += newGPUs;
        lastactivation[msg.sender] = block.timestamp;
        
        // send referral beans
        claimedBEANS[referrals[msg.sender]] += (beansUsed / 8);
        
        // boost market to nerf miners hoarding
        marketBEANS += (beansUsed / 5);
    }
    
    // sells token to the contract
    function sellBEANS() external hasStarted {

        uint256 ownedBEANS = getMyBEANS(msg.sender);
        uint256 beansValue = calculateBEANSSell(ownedBEANS);

        uint256 devFee = getDevFee(beansValue);
        uint256 marketingFee = getMarketingFee(beansValue);

        if(GPUs[msg.sender] == 0) uniqueUsers--;
        claimedBEANS[msg.sender] = 0;
        lastactivation[msg.sender] = block.timestamp;
        marketBEANS += ownedBEANS;

        devFeeReceiver.transfer(devFee);
        marketingFeeReceiver.transfer(marketingFee);

        payable (msg.sender).transfer(beansValue - devFee - marketingFee);
    }

    // ################################## view functions ########################################

    function beansRewards(address adr) external view returns(uint256) {
        return calculateBEANSSell(getMyBEANS(adr));
    }
    
    function calculateBEANSSell(uint256 beans) public view returns(uint256) {
        return calculateTrade(beans, marketBEANS, address(this).balance);
    }
    
    function calculateBEANSBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketBEANS);
    }
    
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function getMyGPUs(address adr) public view returns(uint256) {
        return GPUs[adr];
    }
    
    function getMyBEANS(address adr) public view returns(uint256) {
        return claimedBEANS[adr] + getBEANSSinceLastUnlock(adr);
    }
    
    function getBEANSSinceLastUnlock(address adr) public view returns(uint256) {
        // 1 BEANS per second per GPU
        return min(BEANS_REQ_PER_GPU, block.timestamp - lastactivation[adr]) * GPUs[adr];
    }

    // private ones

    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private pure returns(uint256) {
        return (PSN * bs) / (PSNH + (((rs * PSN) + (rt * PSNH)) / rt));
    }

    function getDevFee(uint256 amount) private pure returns(uint256) {
        return amount * getDevFeeVal / 10000;
    }
    
    function getMarketingFee(uint256 amount) private pure returns(uint256) {
        return amount * getMarketingFeeVal / 10000;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}