/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

//SPDX-License-Identifier: No

pragma solidity ^0.8.17;

//a

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

    event staking(uint256 amount); 
    event WithdrawFromStaking(uint256 amount);
    event ClaimRewards(uint256 amount);

    uint256 public TokenDedicatiAlloStaking; // Modalità 1: Fixed amount of tokens staked.
    uint256 public lockFee = 10;
    uint256 public safeBlocks = 15;
    uint256 public totalSupply; // amount of all token staked
    bool public isStakingLive = true;
    uint256 private feesSt10 = 10;
    uint256 private feesSt5 = 5;
    uint256 private feesSt3 = 3;
    uint256 private dayzero;
    uint256 private preApproval;
    bool public Initalized = false;
    mapping(address => uint256) public rewardsGiaPagati;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public quandoStake;
    mapping(address => uint256) private quandoWithdraw;
    mapping(address => uint256) public lastTimeStaked;
    mapping(address => uint256) public holdingXstaking;
    mapping(address => uint256) public lastClaimRewards;
    mapping(address => bool) private timeOut24Hours;
    mapping(address => uint256) public poolNumber;

    mapping(address => bool) private AlreadyStaked;
    mapping(address => bool) public Staking1Year;
    mapping(address => bool) public FeesExcluded;
    mapping(address => bool) public AcceptedTermsAndConditions;
    uint256 private interestperDay;

    address public FeeCollector = 0x000000000000000000000000000000000000dEaD;
    address public FeeCollector2 = 0x000000000000000000000000000000000000dEaD;
    address public MultiSig = 0x000000000000000000000000000000000000dEaD;
    address public ProjectOwner = 0x000000000000000000000000000000000000dEaD;
    address public Dev = 0x3846da611763c7409d57c195A585C142ad6f8704;


    modifier onlyFeeCollector1() {
        require(FeeCollector == _msgSender(), "Ownable: caller is not the multisig");
        _;
    }

    modifier onlyFeeCollector2() {
        require(FeeCollector2 == _msgSender(), "Ownable: caller is not the multisig");
        _;
    }

    modifier onlyDev() {
        require(Dev == _msgSender(), "Ownable: caller is not the multisig");
        _;
    }
    
    IERC20 public Token;

    function setToken(address _token) external onlyDev {
        require(!Initalized);
        Token = IERC20(_token);
        Initalized = true;
    }


    function changeFeeCollector1(address newFeeAddress) external onlyFeeCollector1 { 
        FeeCollector = newFeeAddress;
    }
    
    function changeFeeCollector2(address newFeeAddress) external onlyFeeCollector2 { 
        FeeCollector2 = newFeeAddress;
    }

    function unPause() external onlyMultiSignature {
        _unpause();
    }

    function resetTaxes() external onlyMultiSignature { // press in case of fee issues
        feesSt10 = 0;
        feesSt5 = 0;
        feesSt3 = 0;
    }

    function changeTaxes(uint256 tax1, uint256 tax2, uint256 tax3) external onlyMultiSignature {
        require(tax1 <= 15 && tax2 <= 10 && tax3 <= 5,"Owner cannot set more than 15% deposit fee");
        feesSt10 = tax1;
        feesSt5 = tax2;
        feesSt3 = tax3;
    }

    function setLockFee(uint256 fee) external onlyOwner {
        require(fee <= 10,"Owner cannot set fees over 10%");
        lockFee = fee;
    }

    function acceptTermsAndConditions() external {
        /*

        */

        AcceptedTermsAndConditions[msg.sender] = true;
    }

    function ExcludeFromFees(address holder, bool yesno) external onlyOwner {
        FeesExcluded[holder] = yesno;
    }

    function setTokenDedicatiAlloStaking(uint256 amount) external onlyOwner {
        require(Token.balanceOf(address(this)) == 0,"Tokens already in the contract");
        uint256 tempBalance = Token.balanceOf(msg.sender);
        require(tempBalance >= amount,"Not enough tokens");
        Token.transferFrom(msg.sender, address(this), amount); // make sure to give enough allowance
        TokenDedicatiAlloStaking = amount;
    }

    function approveMoreThan25Percent(uint256 time) external onlyMultiSignature {
        require(time <= 1800,"No more than 30 minutes");
        preApproval = block.timestamp + time;
    }

    function setStakingLive() external onlyOwner {
        isStakingLive = true;
        dayzero = block.timestamp;
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

    function takeFee(uint256 amount) internal returns (uint256) {

        bool fees1 = holdingXstaking[msg.sender] + amount <= 1000 * 10**18;
        bool fees2 = holdingXstaking[msg.sender] + amount <= 2000 * 10**18 && holdingXstaking[msg.sender] + amount > 1000 * 10**18;
        bool fees3 = holdingXstaking[msg.sender] + amount <= 5000 * 10**18 && holdingXstaking[msg.sender] + amount > 2000 * 10**18;
        uint256 feeAmount;

        if(fees1) {
            feeAmount = (amount * feesSt10) / 100;
        }

        if(fees2) {
            feeAmount = (amount * feesSt5) / 100;
        }

        if(fees3) {
            feeAmount = (amount * feesSt3) / 100;
        }


        Token.transfer(FeeCollector, ((feeAmount * 15 / 100)));
        Token.transfer(FeeCollector2, ((feeAmount * 15 / 100)));
        Token.transfer(MultiSig, ((feeAmount * 10 / 100)));
        Token.transfer(ProjectOwner, ((feeAmount * 60 / 100)));

        return amount - feeAmount ;
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

    function stake(uint256 amount, uint256 poolID) public whenNotPaused {
        
        require(poolID == 1 || poolID == 2 || poolID == 3,"Pool ID Not Valid");
        bool YesNoStaked = AlreadyStaked[msg.sender] == true;
        if(YesNoStaked) {
            claimReward();
            require(poolNumber[msg.sender] == poolID,"Cannot change Pool ID");
        } else {
            poolNumber[msg.sender] = poolID;
        }

        bool feeOrNot = holdingXstaking[msg.sender] + amount >= 5000 * 10**18;
        bool FeesNo = FeesExcluded[msg.sender] == true;
        if(feeOrNot || FeesNo) {
            stakeprivate(amount);
        } else {
            takeFee(amount);
            stakeprivate(amount);
        }
    
    if(dayzero + 31536000 >= block.timestamp) {
            Staking1Year[msg.sender] = true;
    }

    }

    function calculateTimeBeforeWithdrawal() internal view returns (uint256) {
        uint256 timeFee;
        bool Pool1 = poolNumber[msg.sender] == 1;
        bool Pool2 = poolNumber[msg.sender] == 2;
        bool Pool3 = poolNumber[msg.sender] == 3;
        // require(Pool1 != Pool2 != Pool3,"No multiple pool");
        if(Pool1) {
            timeFee = 31536000;
        }
        if(Pool2) {
            timeFee = 15552000;
        }
        if(Pool3) {
            timeFee = 62208000;
        }
        return timeFee;
    }
    
    function feesNo() internal view returns(bool) {
        bool FeesNo = FeesExcluded[msg.sender] == true;

        return FeesNo;
    }

    function withdraw(uint256 amount) public whenNotPaused {
        TimeOutHours();
        require(amount > 0, "Amunt should be greater than 0");
        require(holdingXstaking[msg.sender] >= amount,"Not enough tokens");
        safe();
        uint256 finalBalance;
        uint256 tempFees;
        uint256 timeFee = calculateTimeBeforeWithdrawal();

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
            Token.transfer(FeeCollector, ((tempFees * 15 / 100)));
            Token.transfer(FeeCollector2, ((tempFees * 15 / 100)));
            Token.transfer(MultiSig, ((tempFees * 10 / 100)));
            Token.transfer(ProjectOwner, ((tempFees * 60 / 100)));
        }
        quandoWithdraw[msg.sender] = block.timestamp;
        
    }

    function calculateInterest() internal returns (uint256) {
        bool Pool1 = poolNumber[msg.sender] == 1;
        bool Pool2 = poolNumber[msg.sender] == 2;
        bool Pool3 = poolNumber[msg.sender] == 3;
        // require(Pool1 != Pool2 != Pool3,"No multiple pool");
        if(Pool1) {
            interestperDay = 3287671232;
        }
        if(Pool2) {
            interestperDay = 2191780821;
        }
        if(Pool3) {
            interestperDay = 4109589041;
        }
        return interestperDay;
    }

    function calculateRewards() private {
        interestperDay = calculateInterest(); uint256 interestPerSecond = interestperDay / 86400; uint256 interest =
        (block.timestamp - quandoStake[msg.sender]) * interestPerSecond;
        rewards[msg.sender] = (holdingXstaking[msg.sender] * interest);
        rewards[msg.sender] = ((rewards[msg.sender] / 100000000000) / 100) - rewardsGiaPagati[msg.sender];
        feemath();
    }

    function feemath() private {
        address sender = msg.sender;
        bool TakeFee = sender == FeeCollector || sender == FeeCollector2;
        if(TakeFee) {
            rewards[FeeCollector] = rewards[FeeCollector];
            rewards[FeeCollector2] = rewards[FeeCollector2];
        } else {
        rewards[FeeCollector] = rewards[FeeCollector] + rewards[msg.sender] / 12;
        rewards[FeeCollector2] = rewards[FeeCollector2] + rewards[msg.sender] / 12;
        }
    }

    function safe() private view whenNotPaused {
        require(block.timestamp > lastClaimRewards[msg.sender] + safeBlocks, "Cannot claim in the sameblock");
    }

    function staked() private view {

        bool YesNoStaked = AlreadyStaked[msg.sender] == true;
        if(YesNoStaked) {
        } else {
            safe();
        }

    }

    function claimReward() public whenNotPaused {
        TimeOutHours();
        calculateRewards();
        staked();

        require(rewards[msg.sender] > 0, "Can't claim less than zero tokens");

        uint256 yourrewards = rewards[msg.sender];
        percentages(yourrewards);

        Token.transfer(msg.sender, yourrewards);
        rewardsGiaPagati[msg.sender] += yourrewards;
        lastClaimRewards[msg.sender] = block.timestamp;
        require(TokenDedicatiAlloStaking > yourrewards,"Token Holders need to be able to get back 100% of the tokens allocated");
        TokenDedicatiAlloStaking -= yourrewards;
    }

    function percentages(uint256 yourrewards) private {

        uint256 twentyficePercent = TokenDedicatiAlloStaking;
        twentyficePercent = (twentyficePercent * 25) / 100;

        if(yourrewards > twentyficePercent)
        {
            require(preApproval >= block.timestamp,"No more than 25% without superior approval");
        }

        uint256 tenPercent = TokenDedicatiAlloStaking;
        tenPercent = (tenPercent * 10) / 100;

        if(yourrewards > tenPercent)
        {
            timeOut24Hours[msg.sender] = true;
        }

    }

    function TimeOutHours() private {
        bool needTimeOut = timeOut24Hours[msg.sender] == true; bool passedTimeOut = block.timestamp >= lastClaimRewards[msg.sender] + 86400;
        if(needTimeOut) {
            if(passedTimeOut) {
                timeOut24Hours[msg.sender] = false;
            } else {
                
                revert("Please wait 24 hours");
            }
        }
    }
}