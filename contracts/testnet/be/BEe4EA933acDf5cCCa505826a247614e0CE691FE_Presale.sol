pragma solidity 0.8.17;
// SPDX-License-Identifier: Unlicensed


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function setCitizenTypeFromPrivate(address user) external;
}


contract Presale is ReentrancyGuard, Context, Ownable {
    
    mapping (address => Contribution) contributions;
    mapping (address => bool) public hasClaimed;
    mapping (uint256 => uint256) stageRate;

    struct Contribution {
        uint256 bnbAmount;
        uint256 tokensAmount;
    }

    IERC20 public token;
    address public wallet;
    uint256 public weiRaised;
    uint256 public tokensPurchased;
    uint256 public maxBuy;
    uint256 public hardCap;

    bool public presaleStarted;
    bool public claimEnabled;

    event TokensPurchased(address  purchaser, uint256 contribution);
    event Claim(address user, uint256 amount);

    constructor (address _wallet, IERC20 _token)  {
        require(_wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(address(_token) != address(0), "Pre-Sale: token is the zero address");
        
        wallet = _wallet;
        token = _token;
        maxBuy = 50 * 10**18;
        hardCap = type(uint256).max;
    }


    receive () external payable {
        require(presaleStarted, "Presale not active");
        buyTokens();
    }
    
    
    //Start Pre-Sale
    function start() external onlyOwner {
        require(stageRate[0] != 0, "Rate not set");
        presaleStarted = true;
    }

    // Stop Presale
    function stop() external onlyOwner{
        presaleStarted = false;
    }

    function setClaimStatus(bool enabled) external onlyOwner{
        claimEnabled = enabled;
    }
    
    
    //Pre-Sale 
    function buyTokens() public nonReentrant payable {
        require(presaleStarted, "Presale not active");
        require(msg.value > 0, "Presale: weiAmount is 0");
        require(contributions[msg.sender].bnbAmount + msg.value <= maxBuy, "You are exceeding maxBuy");
        require(weiRaised + msg.value <= hardCap, "HardCap reached");
        uint256 weiAmount = msg.value;
        (uint256 currentStage, uint256 rate) = getCurrentRate();
        uint256 tokensAmt = weiAmount * rate / 1e18;
        weiRaised += weiAmount;
        contributions[msg.sender].bnbAmount += weiAmount;
        contributions[msg.sender].tokensAmount += tokensAmt;
        (uint256 newStage, ) = getCurrentRate();
        if(currentStage < newStage) presaleStarted = false;
        tokensPurchased += tokensAmt;
        token.setCitizenTypeFromPrivate(msg.sender);
        emit TokensPurchased(msg.sender, weiAmount);
    }

    function claim() external nonReentrant{
        require(claimEnabled, "Claim not active");
        require(!hasClaimed[msg.sender], "Already claimed");
        hasClaimed[msg.sender] = true;
        uint256 tokensAmt = contributions[msg.sender].tokensAmount;
        token.transfer(msg.sender, tokensAmt);
        emit Claim(msg.sender, tokensAmt);
    }

    function getUserContribution(address user) external view returns(uint256 bnbAmount, uint256 tokensAmount) {
        return (contributions[user].bnbAmount, contributions[user].tokensAmount);
    }

    function getCurrentRate() public view returns(uint256 currentStage, uint256 currentRate) {
        currentStage = weiRaised / 60 ether;
        currentRate =  stageRate[currentStage];
    }

    function getRateByStageNumber(uint256 stageNumber) external view returns(uint256){
        return stageRate[stageNumber];
    }

    function setBulkStageRates(uint256[] memory rates) external onlyOwner{
        for(uint256 i; i < rates.length; ) {
            stageRate[i] = rates[i];
            unchecked {
                ++i;
            }
        }
    }

    function setStageRate(uint256 stageNumber, uint256 newRate) external onlyOwner{
        stageRate[stageNumber] = newRate;
    }

    function setMaxBuy(uint256 amountInWei) external onlyOwner{
        maxBuy = amountInWei;
    }

    function setHardCap(uint256 amountInWei) external onlyOwner{
        hardCap = amountInWei;
    }
    
    function setWalletReceiver(address payable newWallet) external onlyOwner{
        wallet = newWallet;
    }

    function setTokenAddress(address tokenAddr) external onlyOwner{
        token = IERC20(tokenAddr);
    }
    
    function rescueTokens(IERC20 tokenAddress, uint256 amount) external onlyOwner{
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }
    
    function rescueBNB(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, 'Insufficient BNB balance');
        payable(wallet).transfer(weiAmount);
    }
    
}