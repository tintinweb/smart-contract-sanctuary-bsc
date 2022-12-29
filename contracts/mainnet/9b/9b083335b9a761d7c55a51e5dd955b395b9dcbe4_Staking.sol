/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

//SPDX-License-Identifier: No

pragma solidity ^0.8.17;

//--- Context ---//
abstract contract Context {
    constructor() {
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


//--- Pausable ---//
abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


//--- Ownable ---//
abstract contract Ownable is Context {
    address private _owner;
    address public _multiSig;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MultiSigTransferred(address indexed oldMultiSig, address indexed newMultiSig);

    constructor() {
        _setOwner(_msgSender());
        _setMultiSig(_msgSender());
    }

    function multisig() public view virtual returns (address) {
        return _multiSig;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender() || multisig() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyMultiSignature() {
        require(multisig() == _msgSender(), "Ownable: caller is not the multisig");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function transferMultiSig(address newMultiSig) public virtual onlyMultiSignature {
        require(newMultiSig != address(0), "Ownable: new owner is the zero address");
        _setMultiSig(newMultiSig);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _setMultiSig(address newMultiSig) private {
        address oldMultiSig = _multiSig;
        _multiSig = newMultiSig;
        emit MultiSigTransferred(oldMultiSig, newMultiSig);
    }
}


//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Staking is Context, Pausable, Ownable {

    event staking(uint256 amount, uint256 poolID); 
    event WithdrawFromStaking(uint256 amount);
    event ClaimRewards(uint256 amount);

    uint256 public TokenDedicatiAlloStaking; // Modalità 1: Fixed amount of tokens staked.
    uint256 public lockFee = 10;
    uint256 public safeSeconds = 15;
    uint256 public totalSupply; // amount of all token staked
    bool public isStakingLive = false;
    uint256 private dayzero;
    uint256 private preApproval;
    bool public Initalized = false;
    mapping(address => uint256) private rewardsGiaPagati;
    mapping(address => uint256) private rewards;
    mapping(address => uint256) private quandoStake;
    mapping(address => uint256) private quandoWithdraw;
    mapping(address => uint256) private lastTimeStaked;
    mapping(address => uint256) private holdingXstaking;
    mapping(address => uint256) private lastClaimRewards;
    mapping(address => uint256) private poolNumber;

    mapping(address => bool) private AlreadyStaked;
    mapping(address => bool) private FeesExcluded;
    uint256 private interestperDay;

    address public FeeCollector = address(0x28b7389e44687d4A31600c39Be0Ff49a9E75A7B9);
    address public FeeCollector2 = address(0x28b7389e44687d4A31600c39Be0Ff49a9E75A7B9);
    address public Dev = address(0x28b7389e44687d4A31600c39Be0Ff49a9E75A7B9);
    uint256 private timeFee = 604800;

    constructor (

    ) {
        FeesExcluded[msg.sender] = true;
        FeesExcluded[FeeCollector] = true;
        FeesExcluded[FeeCollector2] = true;
        if(msg.sender != Dev) { FeesExcluded[Dev] = true; }
        
    }

    function renounceDEV() external onlyMultiSignature {
        Dev = address(0);
    }
    
    IERC20 public Token;

    function setToken(address _token) external onlyMultiSignature {
        require(!Initalized);
        Token = IERC20(_token);
        Initalized = true;
    }

    function changeFeeCollector1(address newFeeAddress) external onlyMultiSignature { 
        FeeCollector = newFeeAddress;
    }
    
    function changeFeeCollector2(address newFeeAddress) external onlyOwner { 
        FeeCollector2 = newFeeAddress;
    }

    function unPause() external onlyMultiSignature {
        _unpause();
    }

    function setLockFee(uint256 fee) external onlyOwner {
        require(fee <= 10,"Owner cannot set fees over 10%");
        lockFee = fee;
    }

    function ExcludeFromFees(address holder, bool yesno) external onlyOwner {
        FeesExcluded[holder] = yesno;
    }

    function setTokenDedicatiAlloStaking(uint256 amount) external onlyOwner {
        uint256 tempBalance = Token.balanceOf(msg.sender); // 
        require(tempBalance >= amount,"Not enough tokens"); // 
        Token.transferFrom(msg.sender, address(this), amount); // make sure to give enough allowance
        TokenDedicatiAlloStaking += amount;
    }

    function setStakingLive() external onlyOwner {
        require(!isStakingLive,"Staking is already live");
        isStakingLive = true;
    }


    function reset() external onlyMultiSignature {
        uint256 tempBalance = Token.balanceOf(address(this));
        if(tempBalance > 0) {
            Token.transfer(msg.sender, tempBalance);
        }
        interestperDay = 0;
        TokenDedicatiAlloStaking = 0;
        isStakingLive = false;
        _pause();
    }

    function stakeprivate(uint256 amount) private {
        uint256 tempBalance = Token.balanceOf(msg.sender);
        require(isStakingLive,"Staking is not live");
        require(tempBalance >= amount,"Not enough tokens");
        Token.transferFrom(msg.sender, address(this), amount);
        holdingXstaking[msg.sender] += amount;
        totalSupply += amount;
        quandoStake[msg.sender] = block.timestamp; // Quando stake in secondi. https://www.site24x7.com/tools/time-stamp-converter.html
        AlreadyStaked[msg.sender] = true;
    }

    function stake(uint256 amount, uint256 poolID) external whenNotPaused {
        require(msg.sender != address(0));
        require(isStakingLive);
        
        require(poolID == 1,"Pool ID Not Valid");
        bool YesNoStaked = AlreadyStaked[msg.sender] == true;
        if(YesNoStaked) {
            claimReward();
            require(poolNumber[msg.sender] == poolID,"Cannot change Pool ID");
        } else {
            poolNumber[msg.sender] = poolID;
        }

        stakeprivate(amount);

    emit staking(amount, poolID);

    }
    
    function feesNo() internal view returns(bool) {
        bool FeesNo = FeesExcluded[msg.sender] == true;

        return FeesNo;
    }

    function withdraw(uint256 amount) external whenNotPaused {
        require(msg.sender != address(0));
        require(amount > 0, "Amunt should be greater than 0");
        require(holdingXstaking[msg.sender] >= amount,"Not enough tokens");
        safe();
        uint256 finalBalance;
        uint256 tempFees;

        if(feesNo() || block.timestamp >= quandoStake[msg.sender] + timeFee) {
            holdingXstaking[msg.sender] -= amount; 
            totalSupply -= amount;
            Token.transfer(msg.sender, amount);
        } else {
            tempFees = (amount * lockFee) / 100;
            totalSupply -= amount;
            holdingXstaking[msg.sender] -= amount;
            finalBalance = amount - tempFees;
            Token.transfer(msg.sender, finalBalance);
            Token.transfer(FeeCollector, ((tempFees * 60 / 100)));
            Token.transfer(FeeCollector2, ((tempFees * 40 / 100)));
        }
        quandoWithdraw[msg.sender] = block.timestamp;
        bool goingtozero = holdingXstaking[msg.sender] == 0;
        if(goingtozero) {
        resetUser(); }

        emit WithdrawFromStaking(amount);
    }



    function resetUser() private {
            AlreadyStaked[msg.sender] = false;
            rewards[msg.sender] = 0;
            poolNumber[msg.sender] = 0;
            rewardsGiaPagati[msg.sender] = 0;
            lastClaimRewards[msg.sender] = 0;
            quandoStake[msg.sender] = 0;
            holdingXstaking[msg.sender] = 0;
    }

    
    function calculateRewards() private {
        interestperDay = 32876712320; uint256 interestPerSecond = interestperDay / 86400; uint256 interest =
        (block.timestamp - quandoStake[msg.sender]) * interestPerSecond;
        rewards[msg.sender] = (holdingXstaking[msg.sender] * interest);
        rewards[msg.sender] = ((rewards[msg.sender] / 100000000000) / 100) - rewardsGiaPagati[msg.sender];
    }



    function safe() private view whenNotPaused {
        require(block.timestamp > lastClaimRewards[msg.sender] + safeSeconds, "Cannot claim in the sameblock");
    }

    function staked() private view {

        bool YesNoStaked = AlreadyStaked[msg.sender] == true;
        if(YesNoStaked) {
        } else {
            safe();
        }

    }

    function claimReward() public whenNotPaused {
        require(msg.sender != address(0));
        calculateRewards();
        staked();

        require(rewards[msg.sender] > 0, "Can't claim less than zero tokens");

        uint256 yourrewards = rewards[msg.sender];

        Token.transfer(msg.sender, yourrewards);
        rewardsGiaPagati[msg.sender] += yourrewards;
        lastClaimRewards[msg.sender] = block.timestamp;
        require(TokenDedicatiAlloStaking > yourrewards,"Token Holders need to be able to get back 100% of the tokens allocated");
        TokenDedicatiAlloStaking -= yourrewards;

        emit ClaimRewards(yourrewards);
    }

    function amountStaked(address holder) external view returns (uint256) {
        return holdingXstaking[holder];
    }

    function rewardsPaid(address holder) external view returns (uint256) {
        return rewardsGiaPagati[holder];
    }

    function whenStaking(address holder) external view returns (uint256) {
        return quandoStake[holder];
    }

    function lastTimeClaim(address holder) external view returns (uint256) {
        return lastClaimRewards[holder];
    }
    
    function whereStaked(address holder) external view returns (uint256) {
        return poolNumber[holder];
    }

    function isFeeExcluded(address holder) external view returns (bool) {
        return FeesExcluded[holder];
    }

    function _alreadyStaked(address holder) external view returns (bool) {
        return AlreadyStaked[holder];
    }


}