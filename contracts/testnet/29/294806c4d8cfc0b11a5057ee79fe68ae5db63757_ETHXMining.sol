/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

pragma solidity ^0.5.0;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ETHXMining {		
	string public name = "ETHX Mining";
	address public owner;
	address public funder;

    IERC20 public miningToken;	
    IERC20 public yfntToken;	

    address public treasuryAddr; // 40%
    address public tradeAddr; // 25%
    address public yfntBuybackAddr; // 10%
    address public riskAddr; // 5%
    address public liquidAddr; // 20%
	// DappToken public dappToken;
	// IERC20 public daiToken;	

	address[] public stakers;
    address[] public inviteUsers;
    address[] public stakersVIPA;
    address[] public stakersVIPB;
    address[] public stakersPreVIPA;
    address[] public stakersPreVIPB;
    
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    mapping(address => address) public invitors;
    mapping(address => address[]) public _binders;
    mapping(address => bool) public _inProject;

    uint public _superHolderUsdtAmount = 6000 * 10 ** 18;    
    uint public _superHolderUsdtInvitePercent = 10;

    uint public _superHolderUsdtAmountVIPA = 6000 * 10 ** 18;    
    uint public _superHolderUsdtAmountVIPB = 3000 * 10 ** 18;    
    uint public _superHolderUsdtInvitePercentVIPA = 10;   
    uint public _superHolderUsdtInvitePercentVIPB = 5;             

    uint public _treasuryPercent = 40;   
    uint public _tradePercent = 25;  
    uint public _yfntBuybackPercent = 10;  
    uint public _riskPercent = 5;  
    uint public _liquidPercent = 10;

    uint public _inviteAwardL1Percent = 3;
    uint public _inviteAwardL2Percent = 1;
    uint public _inviteMonthWeight = 1;
    uint public _scoreTreasureInviteTotal = 0;
    uint public _scoreStakeInviteTotal = 0;
    uint public _awardsStakeInviteTotal = 0;

    uint public _awardShareTreasureInviteTotal = 0;
    uint public _awardShareStakeInviteTotal = 0;
    uint256 public startAwardShareTreasureInviteTotalBlock;
    uint256 public startAwardShareStakeInviteTotalBlock;
    mapping(address => uint256) public userStartAwardShareTreasureInviteTotalBlock;
    mapping(address => uint256) public userStartAwardShareStakeInviteTotalBlock;
    mapping(address => uint256) public unstakeYFNTBlock;
    
    bool public _canAwardShareTreasureInviteTotal = false;
    bool public _canAwardShareStakeInviteTotal = false;

    bool public _canUnstakeYFNT = false;

    uint public _yfntVIPACondition = 10;
    uint public _yfntVIPBCondition = 5;

	mapping(address => uint) public stakingBalance;
	mapping(address => bool) public hasStaked;
    mapping(address => bool) public hasStakedVIPA;
    mapping(address => bool) public hasStakedVIPB;
	mapping(address => bool) public isStaking;
    mapping(address => bool) public hasInvited;

    mapping(address => uint) public unClaimedRewardsBalance;
	mapping(address => uint) public lastClaimedRewardsBlock;
    mapping(address => uint) public unlockedBalanceTotal;
    mapping(address => uint) public unsoldAwardsBalanceTotal;

    uint public _rewardsPerBlock = 1 * 10 ** 18;
    uint public _unlockedPercent = 0;
    uint public _shareDymPercent = 50;
    bool public _canUnlock = true;


    mapping(address => uint) public scoreTreasureInvite;
    mapping(address => uint) public scoreStakeInvite;

    mapping(address => uint) public presaleVIPABalance;
    mapping(address => uint) public presaleVIPBBalance;
	
    address public _mainPair;

	// constructor(address RouterAddress, address USDTAddress, IERC20 _miningToken, IERC20 _yfntToken) public {
    constructor() public {
		owner = msg.sender;
		funder = msg.sender;

        miningToken = IERC20(address(0x6BBa2dba850A90398D033e1fFCaeba8D11b561d9));
        yfntToken = IERC20(address(0x8Fa8733014404FE5FfAB6e9391c75074efEE8F1D));

        treasuryAddr = msg.sender; 
        tradeAddr = msg.sender; 
        yfntBuybackAddr = msg.sender; 
        riskAddr = msg.sender; 
        liquidAddr = msg.sender;

        if(!hasStaked[address(this)]) {
			stakers.push(address(this));
		}
        isStaking[address(this)] = true;
		hasStaked[address(this)] = true;

        if(!hasInvited[address(this)]) {
			inviteUsers.push(address(this));
		}
        hasInvited[address(this)] = true;

        if(!hasStakedVIPA[address(this)]) {
			stakersVIPA.push(address(this));
		}

		// update stakng status
        hasStakedVIPA[address(this)] = true;
        _usdt = address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
	}

	/* Stakes Tokens (Deposit): An investor will deposit the DAI into the smart contracts
	to starting earning rewards.
		
	Core Thing: Transfer the DAI tokens from the investor's wallet to this smart contract. */
	function stakeTokens(uint _amount) public {		
        updateUserUnclaimedRewards(msg.sender);
		
		// transfer Mock DAI tokens to this contract for staking
		miningToken.transferFrom(msg.sender, address(this), _amount);

		// update staking balance
		stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;	

		// add user to stakers array *only* if they haven't staked already
		if(!hasStaked[msg.sender]) {
			stakers.push(msg.sender);
		}

		// update stakng status
		isStaking[msg.sender] = true;
		hasStaked[msg.sender] = true;

        _procesStakeInviteScore(msg.sender, _amount);
        _procesStakeInviteAwards(msg.sender, _amount);
	}

    function claimRewards() public {				
		updateUserUnclaimedRewards(msg.sender);

		uint balance = unClaimedRewardsBalance[msg.sender];

		// require amount greter than 0
		require(balance > 0, "unclaimed balance cannot be 0");

		// update unclaimed balance
		unClaimedRewardsBalance[msg.sender] = 0;

		// transfer Mock DAI tokens to this contract for staking
		miningToken.transfer(msg.sender, balance);			
	}

    // Unstaking Tokens (Withdraw): Withdraw money from DApp.
	function unlockTokens() public {
        require(_canUnlock, "unlock is not open yet");
        require(_unlockedPercent > 0, "unlock is not open yet");

		updateUserUnclaimedRewards(msg.sender);

		// fetch staking balance
		uint balance = stakingBalance[msg.sender];
        uint unlockedBalance = unlockedBalanceTotal[msg.sender];
        uint toUnstakeBalance = balance * _unlockedPercent / 100 - unlockedBalance;

		// require amount greter than 0
		require(toUnstakeBalance > 0, "staking balance cannot be 0");

		// transfer Mock Dai tokens to this contract for staking
		miningToken.transfer(msg.sender, toUnstakeBalance);

		// reset staking balance
        unlockedBalanceTotal[msg.sender] = balance * _unlockedPercent / 100;
        if (_unlockedPercent >= 100){
            stakingBalance[msg.sender] = 0;
            unlockedBalanceTotal[msg.sender] = 0;

            // update staking status
		    isStaking[msg.sender] = false;
        }
	}

    function stakeTokensVIPA(bool isVIPA) public {		
        address account = msg.sender;

        address invitorAddr = invitors[account];
        if (invitorAddr == address(0)) {
            return;
        }
        require(hasInvited[invitorAddr], "notInvited");
        require(account == tx.origin, "notOrigin");
        require(hasStakedVIPA[invitorAddr] || hasStakedVIPB[invitorAddr], "invitorNotExsitinVIPAB");

        address usdt = _usdt;

        uint  _vipPercent = 0;
        if (hasStakedVIPA[invitorAddr]) {
            _vipPercent = _superHolderUsdtInvitePercentVIPA;
        }else {
            _vipPercent = _superHolderUsdtInvitePercentVIPB;
        }

        uint superHolderUsdtAmountVIP = _superHolderUsdtAmountVIPA;
        if (!isVIPA){
            superHolderUsdtAmountVIP = _superHolderUsdtAmountVIPB;
        }

        IERC20(usdt).transferFrom(account, invitorAddr, superHolderUsdtAmountVIP * _vipPercent / 100);
        // 40%
        _vipPercent = _vipPercent + _treasuryPercent;
        IERC20(usdt).transferFrom(account, treasuryAddr, superHolderUsdtAmountVIP * _treasuryPercent / 100);
        // 25%
        _vipPercent = _vipPercent + _tradePercent;
        IERC20(usdt).transferFrom(account, tradeAddr, superHolderUsdtAmountVIP * _tradePercent / 100);
        // 10%
        _vipPercent = _vipPercent + _yfntBuybackPercent;
        IERC20(usdt).transferFrom(account, yfntBuybackAddr, superHolderUsdtAmountVIP * _yfntBuybackPercent / 100);
        // 5%
        _vipPercent = _vipPercent + _riskPercent;
        IERC20(usdt).transferFrom(account, riskAddr, superHolderUsdtAmountVIP * _riskPercent / 100);
        // 10%
        _vipPercent = _vipPercent + _liquidPercent;
        IERC20(usdt).transferFrom(account, liquidAddr, superHolderUsdtAmountVIP * _liquidPercent / 100);

        if (_vipPercent < 100){
            IERC20(usdt).transferFrom(account, funder, superHolderUsdtAmountVIP * (100 - _vipPercent) / 100);
        }
        if (isVIPA){
            yfntToken.transferFrom(msg.sender, address(this), _yfntVIPACondition);
		    // add user to stakers array *only* if they haven't staked already
		    if(!hasStakedVIPA[msg.sender]) {
			    stakersVIPA.push(msg.sender);
		    }
		    // update stakng status
            hasStakedVIPA[account] = true;
        }else {
            yfntToken.transferFrom(msg.sender, address(this), _yfntVIPBCondition);
		    // add user to stakers array *only* if they haven't staked already
		    if(!hasStakedVIPB[msg.sender]) {
			    stakersVIPB.push(msg.sender);
		    }
		    // update stakng status
            hasStakedVIPB[account] = true;
        }
        
        _processTreasureInviteScore(account, superHolderUsdtAmountVIP);
	}

    function buyAwardTokens(uint amount) public {		
        address account = msg.sender;

        address invitorAddr = invitors[account];
        if (invitorAddr == address(0)) {
            return;
        }
        require(hasInvited[invitorAddr], "notInvited");
        require(account == tx.origin, "notOrigin");
        require(hasStakedVIPA[invitorAddr] || hasStakedVIPB[invitorAddr], "invitorNotExsitinVIPAB");

        if (hasStakedVIPA[invitorAddr]){
            require(presaleVIPABalance[invitorAddr] > 0, "VIPAnotEnough");
            if (presaleVIPABalance[invitorAddr] <= amount){
                amount = presaleVIPABalance[invitorAddr];                
            }
            presaleVIPABalance[invitorAddr] = presaleVIPABalance[invitorAddr] - amount;
        }else {
            require(presaleVIPBBalance[invitorAddr] > 0, "VIPBnotEnough");
            if (presaleVIPBBalance[invitorAddr] <= amount){
                amount = presaleVIPBBalance[invitorAddr];
            }
            presaleVIPBBalance[invitorAddr] = presaleVIPBBalance[invitorAddr] - amount;
        }

        require(amount > 0, "notEnough");

        address usdt = _usdt;

        uint  _vipPercent = 0;

        IERC20(usdt).transferFrom(account, invitorAddr, amount * 50 / 100);
        // 40%
        _vipPercent = _vipPercent + _treasuryPercent;
        IERC20(usdt).transferFrom(account, treasuryAddr, amount * _treasuryPercent / 200);
        // 25%
        _vipPercent = _vipPercent + _tradePercent;
        IERC20(usdt).transferFrom(account, tradeAddr, amount * _tradePercent / 200);
        // 10%
        _vipPercent = _vipPercent + _yfntBuybackPercent;
        IERC20(usdt).transferFrom(account, yfntBuybackAddr, amount * _yfntBuybackPercent / 200);
        // 5%
        _vipPercent = _vipPercent + _riskPercent;
        IERC20(usdt).transferFrom(account, riskAddr, amount * _riskPercent / 200);
        // 10%
        _vipPercent = _vipPercent + _liquidPercent;
        IERC20(usdt).transferFrom(account, liquidAddr, amount * _liquidPercent / 200);

        if (_vipPercent < 50){
            IERC20(usdt).transferFrom(account, funder, amount * (100 - _vipPercent - 50) / 100);
        }

		updateUserUnclaimedRewards(msg.sender);

		// update staking balance
		stakingBalance[msg.sender] = stakingBalance[msg.sender] + amount / 2;	

		// add user to stakers array *only* if they haven't staked already
		if(!hasStaked[msg.sender]) {
			stakers.push(msg.sender);
		}

		// update stakng status
		isStaking[msg.sender] = true;
		hasStaked[msg.sender] = true;
	}

    function sellAwardTokensToAddress(address addr, uint amount) public {		
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        require(hasStakedVIPA[account] || hasStakedVIPB[account], "IamNotExsitinVIPAB");
        require(unsoldAwardsBalanceTotal[account] > 0, "notEnough");

        updateUserUnclaimedRewards(addr);

        if (amount >= unsoldAwardsBalanceTotal[account]){
            amount = unsoldAwardsBalanceTotal[account];
        }

		// update staking balance
		stakingBalance[addr] = stakingBalance[addr] + amount;	

        unsoldAwardsBalanceTotal[account] = unsoldAwardsBalanceTotal[account] - amount;

		// add user to stakers array *only* if they haven't staked already
		if(!hasStaked[addr]) {
			stakers.push(addr);
		}

		// update stakng status
		isStaking[addr] = true;
		hasStaked[addr] = true;
    }

    function claimTreasureAwards() public {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        require(hasStakedVIPA[account] || hasStakedVIPB[account], "IamNotExsitinVIPAB");
        require(_canAwardShareTreasureInviteTotal && _awardShareTreasureInviteTotal > 0, "notstartshare");
        require(userStartAwardShareTreasureInviteTotalBlock[account] < startAwardShareTreasureInviteTotalBlock, "cannotshare2s");        
        
        uint amount = _awardShareTreasureInviteTotal * (100 - _shareDymPercent) / (100 * (stakersVIPA.length * 2 + stakersVIPB.length));
        uint amountDym = scoreTreasureInvite[account] * _awardShareTreasureInviteTotal * _shareDymPercent/ (100 * _scoreTreasureInviteTotal);

        if(hasStakedVIPB[account]){
            miningToken.transfer(account, amount + amountDym);			
        }else if (hasStakedVIPA[account]){
            miningToken.transfer(account, amount * 2 + amountDym);			
        }
        userStartAwardShareTreasureInviteTotalBlock[account] = block.number;
    }

    function claimStakeAwards() public {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        require(hasStakedVIPA[account] || hasStakedVIPB[account], "IamNotExsitinVIPAB");
        require(_canAwardShareStakeInviteTotal && _awardShareStakeInviteTotal > 0, "notstartshare");
        require(userStartAwardShareStakeInviteTotalBlock[account] < startAwardShareStakeInviteTotalBlock, "cannotshare2s");        
        
        uint amount = _awardShareStakeInviteTotal * (100 - _shareDymPercent) / (100 * (stakersVIPA.length * 2 + stakersVIPB.length));
        uint amountDym = scoreStakeInvite[account] * _awardShareStakeInviteTotal * _shareDymPercent/ (100 * _scoreStakeInviteTotal);

        if(hasStakedVIPB[account]){
            miningToken.transfer(account, amount + amountDym);			
        }else if (hasStakedVIPA[account]){
            miningToken.transfer(account, amount * 2 + amountDym);			
        }
        userStartAwardShareStakeInviteTotalBlock[account] = block.number;
    }

    function claimTreasureUSDTBackByAve() public {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        require(hasStakedVIPA[account] || hasStakedVIPB[account], "IamNotExsitinVIPAB");
        require(_canAwardShareTreasureInviteTotal && _awardShareTreasureInviteTotal > 0, "notstartshare");
        require(userStartAwardShareTreasureInviteTotalBlock[account] < startAwardShareTreasureInviteTotalBlock, "cannotshare2s");        
        
        uint amount = _awardShareTreasureInviteTotal / (stakersVIPA.length * 2 + stakersVIPB.length);
        
        address usdt = _usdt;
        if(hasStakedVIPB[account]){
            IERC20(usdt).transfer(account, amount);			
        }else if (hasStakedVIPA[account]){
            IERC20(usdt).transfer(account, amount * 2);			
        }
        userStartAwardShareTreasureInviteTotalBlock[account] = block.number;
    }

    function claimTreasureUSDTBackByWeight() public {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        require(hasStakedVIPA[account] || hasStakedVIPB[account], "IamNotExsitinVIPAB");
        require(_canAwardShareTreasureInviteTotal && _awardShareTreasureInviteTotal > 0, "notstartshare");
        require(userStartAwardShareTreasureInviteTotalBlock[account] < startAwardShareTreasureInviteTotalBlock, "cannotshare2s");        
        
        uint amount = _awardShareTreasureInviteTotal * (100 - _shareDymPercent) / (100 * (stakersVIPA.length * 2 + stakersVIPB.length));
        uint amountDym = scoreTreasureInvite[account] * _awardShareTreasureInviteTotal * _shareDymPercent/ (100 * _scoreTreasureInviteTotal);

        address usdt = _usdt;
        if(hasStakedVIPB[account]){            
            IERC20(usdt).transfer(account, amount + amountDym);			
        }else if (hasStakedVIPA[account]){
            IERC20(usdt).transfer(account, amount * 2 + amountDym);			
        }
        userStartAwardShareTreasureInviteTotalBlock[account] = block.number;
    }

    function claimYFNTBack() public {
        address account = msg.sender;
        require(account == tx.origin, "notOrigin");
        require(hasStakedVIPA[account] || hasStakedVIPB[account], "IamNotExsitinVIPAB");        
        require(_canUnstakeYFNT, "notclaimopenyet");
        
        if (unstakeYFNTBlock[account] > 0 ){
            return ;
        }
        if (hasStakedVIPA[account]){
            yfntToken.transfer(account, _yfntVIPACondition);
        }else if (hasStakedVIPB[account]){
            yfntToken.transfer(account, _yfntVIPBCondition);
        }
        unstakeYFNTBlock[account] = block.number;
    }

    function _processTreasureInviteScore(address account, uint amount) private {
        address invitorL1 = invitors[account];
        if(hasInvited[invitorL1]){
            scoreTreasureInvite[invitorL1] = scoreTreasureInvite[invitorL1] + amount * _inviteAwardL1Percent * _inviteMonthWeight / 100;
            _scoreTreasureInviteTotal = _scoreTreasureInviteTotal + amount * _inviteAwardL1Percent * _inviteMonthWeight / 100;
            address invitorL2 = invitors[invitorL1];
            if(hasInvited[invitorL2]){
                scoreTreasureInvite[invitorL2] = scoreTreasureInvite[invitorL2] + amount * _inviteAwardL2Percent * _inviteMonthWeight / 100;
                _scoreTreasureInviteTotal = _scoreTreasureInviteTotal + amount * _inviteAwardL2Percent * _inviteMonthWeight / 100;
            }
        }
    }

    function _procesStakeInviteScore(address account, uint amount) private {
        address invitorL1 = invitors[account];
        if(hasInvited[invitorL1]){
            scoreStakeInvite[invitorL1] = scoreStakeInvite[invitorL1] + amount * _inviteAwardL1Percent * _inviteMonthWeight / 100;
            _scoreStakeInviteTotal = _scoreStakeInviteTotal + amount * _inviteAwardL1Percent * _inviteMonthWeight / 100;
            address invitorL2 = invitors[invitorL1];
            if(hasInvited[invitorL2]){
                scoreStakeInvite[invitorL2] = scoreStakeInvite[invitorL2] + amount * _inviteAwardL2Percent * _inviteMonthWeight / 100;
                _scoreStakeInviteTotal = _scoreStakeInviteTotal + amount * _inviteAwardL2Percent * _inviteMonthWeight / 100;
            }
        }
    }

    function _procesStakeInviteAwards(address account, uint amount) private {
        address invitorL1 = invitors[account];
        if(hasInvited[invitorL1]){
            require(hasStakedVIPA[invitorL1] || hasStakedVIPB[invitorL1], "invitorNotExsitinVIPAB");

            unsoldAwardsBalanceTotal[invitorL1] = unsoldAwardsBalanceTotal[invitorL1] + amount * _inviteAwardL1Percent / 100;
            _awardsStakeInviteTotal = _awardsStakeInviteTotal + amount * _inviteAwardL1Percent / 100;

            address invitorL2 = invitors[invitorL1];
            if(hasInvited[invitorL2]){
                require(hasStakedVIPA[invitorL2] || hasStakedVIPB[invitorL2], "invitorNotExsitinVIPAB");
                unsoldAwardsBalanceTotal[invitorL2] = unsoldAwardsBalanceTotal[invitorL2] + amount * _inviteAwardL2Percent / 100;
                _awardsStakeInviteTotal = _awardsStakeInviteTotal + amount * _inviteAwardL2Percent / 100;
            }
        }
    }

    function setInviteAwardL1Percent(uint tPercent) external onlyFunder {	
        _inviteAwardL1Percent = tPercent;
    }

    function setInviteAwardL2Percent(uint tPercent) external onlyFunder {	
        _inviteAwardL2Percent = tPercent;
    }

    function setInviteMonthWeight(uint tWeight) external onlyFunder {	
        _inviteMonthWeight = tWeight;
    }

    function setScoreTreasureInviteTotal(uint tTotal) external onlyFunder {	
        _scoreTreasureInviteTotal = tTotal;
    }

    function setScoreStakeInviteTotal(uint tTotal) external onlyFunder {	
        _scoreStakeInviteTotal = tTotal;
    }

    function addInProjectWithAddr(address addr) external onlyFunder {	
        _inProject[addr] = true;
    }

    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notInProj");
        require(hasInvited[invitor], "notInvited");
        _bindInvitor(account, invitor);
    }

    function bindInvitor(address invitor) public {
        address account = msg.sender;
        require(hasInvited[invitor], "notInvited");
        require(hasStakedVIPA[invitor] || hasStakedVIPB[invitor], "invitorNotExsitinVIPAB");
        _bindInvitor(account, invitor);
        hasInvited[account] = true;
    }

    function _bindInvitor(address account, address invitor) private {
        if (invitors[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                invitors[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function setUsdtAddress(address usdtAddr) external onlyFunder {	
		_usdt = usdtAddr;
	}

    function addStakersPreVIPA(address addr) external onlyFunder {	
		if(!hasStakedVIPA[addr]) {
			stakersPreVIPA.push(addr);
            stakersVIPA.push(addr);
            hasStakedVIPA[addr] = true;
            presaleVIPABalance[addr] = 2 * _superHolderUsdtAmountVIPA;
		}
	}

    function addStakersPreVIPB(address addr) external onlyFunder {	
		if(!hasStakedVIPB[addr]) {
			stakersPreVIPB.push(addr);
            stakersVIPB.push(addr);
            hasStakedVIPB[addr] = true;
            presaleVIPBBalance[addr] = 2 * _superHolderUsdtAmountVIPB;
		}
	}

    function setSuperHolderUsdtAmount(uint usdtAmount) external onlyFunder {	
		_superHolderUsdtAmount = usdtAmount;
	}

    function setSuperHolderUsdtAmountVIPA(uint usdtAmount) external onlyFunder {	
		_superHolderUsdtAmountVIPA = usdtAmount;
	}

    function setSuperHolderUsdtAmountVIPB(uint usdtAmount) external onlyFunder {	
		_superHolderUsdtAmountVIPB = usdtAmount;
	}

    function setSuperHolderUsdtInvitePercent(uint usdtPercent) external onlyFunder {	
		_superHolderUsdtInvitePercent = usdtPercent;
	}

    function setSuperHolderUsdtInvitePercentVIPA(uint usdtPercent) external onlyFunder {	
		_superHolderUsdtInvitePercentVIPA = usdtPercent;
	}

    function setSuperHolderUsdtInvitePercentVIPB(uint usdtPercent) external onlyFunder {	
		_superHolderUsdtInvitePercentVIPB = usdtPercent;
	}

    // fun percent
    function setTreasuryPercent(uint tPercent) external onlyFunder {	
		_treasuryPercent = tPercent;
	}

    function setTradePercent(uint tPercent) external onlyFunder {	
		_tradePercent = tPercent;
	}

    function setYfntBuybackPercent(uint tPercent) external onlyFunder {	
		_yfntBuybackPercent = tPercent;
	}

    function setRiskPercent(uint tPercent) external onlyFunder {	
		_riskPercent = tPercent;
	}

    function setLiquidPercent(uint tPercent) external onlyFunder {	
		_liquidPercent = tPercent;
	}

    function getInvitor(address addr) external view returns (
        address invitorAddr
    ){		
        invitorAddr = invitors[addr];
    }

	modifier onlyFunder() {
        require(owner == msg.sender || funder == msg.sender, "!Funder");
        _;
    }

	function setFunderWithAddress(address addr) external onlyFunder {	
		funder = addr;
	}

    function setTreasuryAddrWithAddress(address addr) external onlyFunder {	
		treasuryAddr = addr;
	}
    function setTradeAddrWithAddress(address addr) external onlyFunder {	
		tradeAddr = addr;
	}
    function setYfntBuybackAddrWithAddress(address addr) external onlyFunder {	
		yfntBuybackAddr = addr;
	}

    function setRiskAddrWithAddress(address addr) external onlyFunder {	
		riskAddr = addr;
	}
    function setLiquidAddrWithAddress(address addr) external onlyFunder {	
		liquidAddr = addr;
	}

	function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    function updateUserUnclaimedRewards(address addr) private {
		if(lastClaimedRewardsBlock[addr] > 0){
			uint rewards = stakingBalance[addr] * (block.number - lastClaimedRewardsBlock[addr]) * _rewardsPerBlock / (10 ** ((uint)(miningToken.decimals())));
			unClaimedRewardsBalance[addr] = unClaimedRewardsBalance[addr] + rewards;
		}else {
			unClaimedRewardsBalance[addr] = 0;
		}
		
		lastClaimedRewardsBlock[addr] = block.number;	
	}

    function setRewardsPerBlock(uint pRewards) external onlyFunder {
		_rewardsPerBlock = pRewards;
	}

    function setUnlockedPercent(uint pPercent) external onlyFunder {
		_unlockedPercent = pPercent;
	}

    function setCanUnlock(bool pStatus) external onlyFunder {
		_canUnlock = pStatus;
	}

    function setAwardShareTreasureInviteTotal(uint pAmount) external onlyFunder {	
		_awardShareTreasureInviteTotal = pAmount;
	}

    function setCanAwardShareTreasureInviteTotal(bool canShare) external onlyFunder {	
		_canAwardShareTreasureInviteTotal = canShare;
        if (canShare){
            startAwardShareTreasureInviteTotalBlock = block.number;
        }
	}

    function setAwardShareStakeInviteTotal(uint pAmount) external onlyFunder {	
		_awardShareStakeInviteTotal = pAmount;
	}

    function setCanawardShareStakeInviteTotal(bool canShare) external onlyFunder {	
		_canAwardShareStakeInviteTotal = canShare;
        if (canShare){
            startAwardShareStakeInviteTotalBlock = block.number;
        }
	}

    function setShareDymPercent(uint pPercent) external onlyFunder {	
		_shareDymPercent = pPercent;
	}

    function setYfntVIPACondition(uint pCondition) external onlyFunder {	
		_yfntVIPACondition = pCondition;
	}

    function setYfntVIPBCondition(uint pCondition) external onlyFunder {	
		_yfntVIPBCondition = pCondition;
	}

    function setCanUnstakeYFNT(bool pUnstakYFNT) external onlyFunder {	
		_canUnstakeYFNT = pUnstakYFNT;
	}
}