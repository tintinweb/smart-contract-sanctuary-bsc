/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "Ownable: only owner can call this function"
        );
        _;
    }

    constructor() {}

    function initilizeOwner() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
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

contract Stakeable {
    constructor() {}

    function initilizeStakeable() internal {
        stageOneReward = 1216; // 30%
        stagetwoReward = 1460; // 25%
        stagethreeReward = 1825; // 20%
        stagefourReward = 2433; // 15%
        stageFiveReward = 3650; // 10%
        stageSixReward = 7300; // 5%

        stakeholders.push();
        stageOnetime = block.timestamp + 365 days;
        stageTwotime = stageOnetime + 365 days;
        stageThreetime = stageTwotime + 365 days;
        stageFourtime = stageThreetime + 365 days;
        stageFivetime = stageFourtime + 365 days;

        devStakePercentage = 5;
    }

    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    struct StakingSummary {
        uint256 total_amount;
        Stake[] stakes;
    }

    Stakeholder[] internal stakeholders;

    mapping(address => uint256) internal stakes;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );

    uint256 internal devStakePercentage;

    uint256 private stageOneReward;
    uint256 private stagetwoReward;
    uint256 private stagethreeReward;
    uint256 private stagefourReward;
    uint256 private stageFiveReward;
    uint256 private stageSixReward;

    uint256 private stageOnetime;
    uint256 private stageTwotime;
    uint256 private stageThreetime;
    uint256 private stageFourtime;
    uint256 private stageFivetime;

    // phase 1
    function checkIFStakedInPhaseOne(uint256 stakedTime)
        internal
        view
        returns (bool)
    {
        if (stakedTime <= stageOnetime) {
            return true;
        }
        return false;
    }

    // phase 2
    function checkIFStakedInPhaseTwo(uint256 stakedTime)
        internal
        view
        returns (bool)
    {
        if (stakedTime > stageOnetime && stakedTime <= stageTwotime) {
            return true;
        }
        return false;
    }

    // phase 3
    function checkIFStakedInPhaseThree(uint256 stakedTime)
        internal
        view
        returns (bool)
    {
        if (stakedTime > stageTwotime && stakedTime <= stageThreetime) {
            return true;
        }
        return false;
    }

    // phase 4
    function checkIFStakedInPhaseFour(uint256 stakedTime)
        internal
        view
        returns (bool)
    {
        if (stakedTime > stageThreetime && stakedTime <= stageFourtime) {
            return true;
        }
        return false;
    }

    // phase 5
    function checkIFStakedInPhaseFifth(uint256 stakedTime)
        internal
        view
        returns (bool)
    {
        if (stakedTime > stageFourtime && stakedTime <= stageFivetime) {
            return true;
        }
        return false;
    }

    function getReward(
        uint256 stakedTime,
        uint256 amount,
        uint256 ratio
    ) private pure returns (uint256) {
        if (stakedTime < 24 hours) {
            return 0;
        }
        return ((stakedTime / 24 hours) * amount) / ratio;
    }

    function getStageEndTime()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            stageOnetime,
            stageTwotime,
            stageThreetime,
            stageFourtime,
            stageFivetime
        );
    }

    function calculateDiffrentStakePhaseReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        // currently running phase 1
        // check if staked in phase 1
        if (block.timestamp <= stageOnetime) {
            return
                getReward(
                    block.timestamp - _current_stake.since,
                    _current_stake.amount,
                    stageOneReward
                );
        }
        // currently running phase 2
        // check if staked in phase 1 or 2
        else if (block.timestamp <= stageTwotime) {
            uint256 phaseOneReward;
            uint256 phaseTwoReward;

            // check if staked in phase 1
            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                phaseOneReward = getReward(
                    stageOnetime - _current_stake.since,
                    _current_stake.amount,
                    stageOneReward
                );

                phaseTwoReward = getReward(
                    block.timestamp - stageOnetime,
                    _current_stake.amount,
                    stagetwoReward
                );
            } else {
                phaseTwoReward = getReward(
                    block.timestamp - _current_stake.since,
                    _current_stake.amount,
                    stagetwoReward
                );
            }
            return phaseOneReward + phaseTwoReward;
        }
        // currently running phase 3
        // check if staked in phase 1 or 2 or 3
        else if (block.timestamp <= stageThreetime) {
            uint256 phaseOneRe;
            uint256 phaseTwoRe;
            uint256 phaseThreeRe;

            // check if staked in phase 1
            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                // end of phase one - time of stake

                phaseOneRe = getReward(
                    stageOnetime - _current_stake.since,
                    _current_stake.amount,
                    stageOneReward
                );

                phaseTwoRe = getReward(
                    stageTwotime - stageOnetime,
                    _current_stake.amount,
                    stagetwoReward
                );

                phaseThreeRe = getReward(
                    block.timestamp - stageTwotime,
                    _current_stake.amount,
                    stagethreeReward
                );
            }
            // check if staked in phase 2
            else if (checkIFStakedInPhaseTwo(_current_stake.since)) {
                // end of phase two - stake time
                phaseTwoRe = getReward(
                    stageTwotime - _current_stake.since,
                    _current_stake.amount,
                    stagetwoReward
                );

                phaseThreeRe = getReward(
                    block.timestamp - stageTwotime,
                    _current_stake.amount,
                    stagethreeReward
                );
            } else {
                phaseThreeRe = getReward(
                    block.timestamp - _current_stake.since,
                    _current_stake.amount,
                    stagethreeReward
                );
            }

            // return phase 3
            return phaseOneRe + phaseTwoRe + phaseThreeRe;
        }
        // currently running phase 4
        // check if staked in phase 1 or 2 or 3 or 4
        else if (block.timestamp <= stageFourtime) {
            uint256 phaseOneRe;
            uint256 phaseTwoRe;
            uint256 phaseThreeRe;
            uint256 phaseFourRe;

            // check if staked in phase 1
            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                // end of phase one - time of stake

                phaseOneRe = getReward(
                    stageOnetime - _current_stake.since,
                    _current_stake.amount,
                    stageOneReward
                );

                phaseTwoRe = getReward(
                    stageTwotime - stageOnetime,
                    _current_stake.amount,
                    stagetwoReward
                );

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    block.timestamp - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );
            }
            // check if staked in phase 2
            else if (checkIFStakedInPhaseTwo(_current_stake.since)) {
                // end of phase two - stake time
                phaseTwoRe = getReward(
                    stageTwotime - _current_stake.since,
                    _current_stake.amount,
                    stagetwoReward
                );

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    block.timestamp - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );
            }
            // check if staked in phase 3
            else if (checkIFStakedInPhaseThree(_current_stake.since)) {
                phaseThreeRe = getReward(
                    stageThreetime - _current_stake.since,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    block.timestamp - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );
            } else {
                phaseFourRe = getReward(
                    block.timestamp - _current_stake.since,
                    _current_stake.amount,
                    stagefourReward
                );
            }

            // return phase 4
            return phaseOneRe + phaseTwoRe + phaseThreeRe + phaseFourRe;
        }
        // currently running phase 5
        // check if staked in phase 1 or 2 or 3 or 4 or 5
        else if (block.timestamp <= stageFivetime) {
            uint256 phaseOneRe;
            uint256 phaseTwoRe;
            uint256 phaseThreeRe;
            uint256 phaseFourRe;
            uint256 phaseFiveRe;

            // check if staked in phase 1
            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                // end of phase one - time of stake

                phaseOneRe = getReward(
                    stageOnetime - _current_stake.since,
                    _current_stake.amount,
                    stageOneReward
                );

                phaseTwoRe = getReward(
                    stageTwotime - stageOnetime,
                    _current_stake.amount,
                    stagetwoReward
                );

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    stageFourtime - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );

                phaseFiveRe = getReward(
                    block.timestamp - stageFourtime,
                    _current_stake.amount,
                    stageFiveReward
                );
            }
            // check if staked in phase 2
            else if (checkIFStakedInPhaseTwo(_current_stake.since)) {
                phaseTwoRe = getReward(
                    stageTwotime - _current_stake.since,
                    _current_stake.amount,
                    stagetwoReward
                );

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    stageFourtime - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );

                phaseFiveRe = getReward(
                    block.timestamp - stageFourtime,
                    _current_stake.amount,
                    stageFiveReward
                );
            }
            // check if staked in phase 3
            else if (checkIFStakedInPhaseThree(_current_stake.since)) {
                phaseThreeRe = getReward(
                    stageThreetime - _current_stake.since,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    stageFourtime - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );

                phaseFiveRe = getReward(
                    block.timestamp - stageFourtime,
                    _current_stake.amount,
                    stageFiveReward
                );
            }
            // check if staked in phase 4
            else if (checkIFStakedInPhaseFour(_current_stake.since)) {
                phaseFourRe = getReward(
                    stageFourtime - _current_stake.since,
                    _current_stake.amount,
                    stagefourReward
                );

                phaseFiveRe = getReward(
                    block.timestamp - stageFourtime,
                    _current_stake.amount,
                    stageFiveReward
                );
            } else {
                phaseFiveRe = getReward(
                    block.timestamp - _current_stake.since,
                    _current_stake.amount,
                    stageFiveReward
                );
            }
            // return last phase
            return
                phaseOneRe +
                phaseTwoRe +
                phaseThreeRe +
                phaseFourRe +
                phaseFiveRe;
        }
        // currently running phase 6
        // check if staked in phase 1 or 2 or 3 or 4 or 5 or 6
        else {
            uint256 phaseOneRe;
            uint256 phaseTwoRe;
            uint256 phaseThreeRe;
            uint256 phaseFourRe;
            uint256 phaseFifthRe;
            uint256 lastPhaseRe;

            // check if staked in phase 1
            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                // end of phase one - time of stake

                phaseOneRe = getReward(
                    stageOnetime - _current_stake.since,
                    _current_stake.amount,
                    stageOneReward
                );

                phaseTwoRe = getReward(
                    stageTwotime - stageOnetime,
                    _current_stake.amount,
                    stagetwoReward
                );

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    stageFourtime - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );

                phaseFifthRe = getReward(
                    stageFivetime - stageFourtime,
                    _current_stake.amount,
                    stageFiveReward
                );

                lastPhaseRe = getReward(
                    block.timestamp - stageFivetime,
                    _current_stake.amount,
                    stageSixReward
                );
            }
            // check if staked in phase 2
            else if (checkIFStakedInPhaseTwo(_current_stake.since)) {
                phaseTwoRe = getReward(
                    stageTwotime - _current_stake.since,
                    _current_stake.amount,
                    stagetwoReward
                );

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    stageFourtime - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );

                phaseFifthRe = getReward(
                    stageFivetime - stageFourtime,
                    _current_stake.amount,
                    stageFiveReward
                );

                lastPhaseRe = getReward(
                    block.timestamp - stageFivetime,
                    _current_stake.amount,
                    stageSixReward
                );
            }
            // check if staked in phase 3
            else if (checkIFStakedInPhaseThree(_current_stake.since)) {
                phaseThreeRe = getReward(
                    stageThreetime - _current_stake.since,
                    _current_stake.amount,
                    stagethreeReward
                );

                phaseFourRe = getReward(
                    stageFourtime - stageThreetime,
                    _current_stake.amount,
                    stagefourReward
                );

                phaseFifthRe = getReward(
                    stageFivetime - stageFourtime,
                    _current_stake.amount,
                    stageFiveReward
                );

                lastPhaseRe = getReward(
                    block.timestamp - stageFivetime,
                    _current_stake.amount,
                    stageSixReward
                );
            }
            // check if staked in phase 4
            else if (checkIFStakedInPhaseFour(_current_stake.since)) {
                phaseFourRe = getReward(
                    stageFourtime - _current_stake.since,
                    _current_stake.amount,
                    stagefourReward
                );

                phaseFifthRe = getReward(
                    stageFivetime - stageFourtime,
                    _current_stake.amount,
                    stageFiveReward
                );

                lastPhaseRe = getReward(
                    block.timestamp - stageFivetime,
                    _current_stake.amount,
                    stageSixReward
                );
            }
            // check if staked in phase 5
            else if (checkIFStakedInPhaseFifth(_current_stake.since)) {
                phaseFifthRe = getReward(
                    stageFivetime - _current_stake.since,
                    _current_stake.amount,
                    stageFiveReward
                );

                lastPhaseRe = getReward(
                    block.timestamp - stageFivetime,
                    _current_stake.amount,
                    stageSixReward
                );
            } else {
                lastPhaseRe = getReward(
                    block.timestamp - _current_stake.since,
                    _current_stake.amount,
                    stageSixReward
                );
            }

            // return last phase
            return
                phaseOneRe +
                phaseTwoRe +
                phaseThreeRe +
                phaseFourRe +
                phaseFifthRe +
                lastPhaseRe;
        }
    }

    function calculateStakeReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        return calculateDiffrentStakePhaseReward(_current_stake);
    }

    function _addStakeholder(address staker) internal returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex;
    }

    function _stake(uint256 _amount) internal {
        require(_amount > 0, "Cannot stake nothing");

        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholder(msg.sender);
        }
        stakeholders[index].address_stakes.push(
            Stake(msg.sender, _amount, timestamp, 0)
        );
        emit Staked(msg.sender, _amount, index, timestamp);
    }

    event Restaked(uint256 _amount, uint256 reward);

    function _withdrawStake(uint256 amount, uint256 index)
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];
        require(
            current_stake.amount >= amount,
            "Staking: Cannot withdraw more than you have staked"
        );
        uint256 reward = calculateStakeReward(current_stake);
        current_stake.amount = current_stake.amount - amount;
        if (current_stake.amount == 0) {
            delete stakeholders[user_index].address_stakes[index];
        } else {
            stakeholders[user_index]
                .address_stakes[index]
                .amount = current_stake.amount;
            stakeholders[user_index].address_stakes[index].since = block
                .timestamp;
        }
        uint256 devReward = (reward * devStakePercentage) / 100;
        reward -= devReward;
        return (amount, reward, devReward);
    }

    function restakeReward(uint256 reward, uint256 index) internal {
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];
        stakeholders[user_index].address_stakes[index].amount =
            current_stake.amount +
            reward;
        stakeholders[user_index].address_stakes[index].since = block.timestamp;
        emit Restaked(current_stake.amount, reward);
    }

    function _withdrawStakeWithZeroReward(uint256 amount, uint256 index)
        internal
        returns (uint256)
    {
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];
        require(
            current_stake.amount >= amount,
            "Staking: Cannot withdraw more than you have staked"
        );
        current_stake.amount = current_stake.amount - amount;
        if (current_stake.amount == 0) {
            delete stakeholders[user_index].address_stakes[index];
        } else {
            stakeholders[user_index]
                .address_stakes[index]
                .amount = current_stake.amount;
            stakeholders[user_index].address_stakes[index].since = block
                .timestamp;
        }
        return (amount);
    }

    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateStakeReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
        }
        summary.total_amount = totalStakeAmount;
        return summary;
    }

    function getTotalStakeIndex(address _staker) public view returns (uint256) {
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        return summary.stakes.length;
    }

    function getStakeAmount(address _staker, uint256 index)
        public
        view
        returns (uint256)
    {
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        return summary.stakes[index].amount;
    }
}

contract BCTK is Ownable, Stakeable {
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    address private devAddress;
    uint256 private MAX_SUPPLY;
    uint256 private rewardSupply;
    uint256 totalStaked;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event SingerChanged(address indexed from, address indexed to);

    event DevChange(address indexed from, address indexed to);

    constructor() {}

    bool isInitilize;

    modifier isInitilized() {
        require(!isInitilize, "You can not initilize contract again! ");
        _;
    }

    function initialize() public isInitilized {
        initilizeOwner();
        initilizeStakeable();

        _name = "Black Canvas";
        _symbol = "BCTK";
        _decimals = 8;

        MAX_SUPPLY = 150_000_000 * (10**_decimals);
        uint256 devAmount = 112_500_000 * (10**_decimals);
        rewardSupply = 37_500_000 * (10**_decimals);

        devAddress = msg.sender; // Owner and dev

        _mint(devAddress, devAmount);

        isInitilize = true;

        // emit Transfer(address(0), msg.sender, _totalSupply);
        emit DevChange(address(0), devAddress);
    }

    function getTotalStakedAmount() public view returns (uint256) {
        return totalStaked;
    }

    function totalStakeHolder() public view returns (uint256) {
        return stakeholders.length;
    }

    function getRemainingReward() public view returns (uint256) {
        return rewardSupply;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalMaxSupply() public view returns (uint256) {
        return MAX_SUPPLY;
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function changeDevaddress(address _devAddress) public onlyOwner {
        require(_devAddress != address(0), "Address must not be zero");
        address temp = devAddress;
        devAddress = _devAddress;
        emit SingerChanged(temp, _devAddress);
    }

    function changeDevRewardPercentage(uint256 _per) public onlyOwner {
        require(_per >= 0 && _per <= 80, "Percentage is not in range");
        devStakePercentage = _per;
    }

    function _mint(address account, uint256 amount) internal {
        require(
            account != address(0),
            "Black Canvas: cannot mint to zero address"
        );
        _totalSupply = _totalSupply + (amount);
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(
            account != address(0),
            "Black Canvas: cannot burn from zero address"
        );
        require(
            _balances[account] >= amount,
            "Black Canvas: Cannot burn more than the account owns"
        );
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function burn(address account, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        require(
            account != address(this),
            "You can not burn token from this account"
        );
        _burn(account, amount);
        return true;
    }

    function mint(address account, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        _mint(account, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            sender != address(0),
            "Black Canvas: transfer from zero address"
        );
        require(
            recipient != address(0),
            "Black Canvas: transfer to zero address"
        );
        require(
            _balances[sender] >= amount,
            "Black Canvas: cant transfer more than your account holds"
        );

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(
            owner != address(0),
            "Black Canvas: approve cannot be done from zero address"
        );
        require(
            spender != address(0),
            "Black Canvas: approve cannot be to zero address"
        );
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address spender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(
            _allowances[spender][msg.sender] >= amount,
            "Black Canvas: You cannot spend that much on this account"
        );
        _transfer(spender, recipient, amount);
        _approve(
            spender,
            msg.sender,
            _allowances[spender][msg.sender] - amount
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 amount)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + amount
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] - amount
        );
        return true;
    }

    function mintReward(
        uint256 amountStaked,
        uint256 userReward,
        uint256 devReward
    ) private {
        _mint(msg.sender, userReward);
        _mint(devAddress, devReward);
        _transfer(address(this), msg.sender, amountStaked);
        totalStaked -= amountStaked;
    }

    function mintDevReward(uint256 devReward) private {
        _mint(devAddress, devReward);
    }

    function stake(uint256 _amount) public {
        require(!isContract(msg.sender), "Caller must not be Smart Contract");
        require(
            _amount <= _balances[msg.sender],
            "Black Canvas: Cannot stake more than you own"
        );
        require(
            _amount >= 1000 * (10**_decimals),
            "Black Canvas: Cannot stake less then 1000"
        );

        _stake(_amount);
        _transfer(msg.sender, address(this), _amount);
        totalStaked += _amount;
    }

    event RewardAmountReduced(uint256 _from, uint256 _to);
    event CanNotGetReward(
        uint256 userRewardAmount,
        uint256 contractRewardAmountHold
    );

    function reduceRewardSupply(uint256 amount) private {
        uint256 temp = rewardSupply;
        rewardSupply -= amount;
        emit RewardAmountReduced(temp, rewardSupply);
    }

    event LastAmountMinted(
        uint256 stakedAmount,
        uint256 remaningAmount,
        uint256 rewardAmount,
        uint256 totalAmount
    );

    function withdrawStake(
        uint256 amount,
        uint256 stake_index,
        bool restake
    ) public {
        require(!isContract(msg.sender), "Caller must not be Smart Contract");
        uint256 amountStaked;
        uint256 devReward;
        uint256 userReward;

        if (getRemainingReward() > 0) {
            (amountStaked, userReward, devReward) = _withdrawStake(
                amount,
                stake_index
            );

            if ((userReward + devReward) > 0) {
                if ((userReward + devReward) < getRemainingReward()) {
                    reduceRewardSupply(devReward + userReward);
                } else {
                    userReward = getRemainingReward();
                    devReward = (userReward * devStakePercentage) / 100;
                    userReward -= devReward;
                    rewardSupply = 0;
                    emit LastAmountMinted(
                        amountStaked,
                        getRemainingReward(),
                        userReward,
                        amountStaked + getRemainingReward()
                    );
                }
                if (restake) {
                    require(amount == 0, "In restake amount must be 0");
                    restakeReward(userReward, stake_index);
                    mintDevReward(devReward);
                    _mint(address(this), userReward);
                    totalStaked += userReward;
                } else {
                    mintReward(amountStaked, userReward, devReward);
                }
            } else {
                require(
                    !restake,
                    "You can not restake this index before you get your reward"
                );
                _transfer(address(this), msg.sender, amountStaked);
                totalStaked -= amountStaked;
                emit CanNotGetReward(
                    userReward + devReward,
                    getRemainingReward()
                );
            }
        } else {
            require(
                !restake,
                "You can not restake your reward now because reward is empty now"
            );
            amountStaked = _withdrawStakeWithZeroReward(amount, stake_index);
            _transfer(address(this), msg.sender, amountStaked);
            totalStaked -= amountStaked;
            emit CanNotGetReward(userReward + devReward, getRemainingReward());
        }
    }

    function withdrawBNB() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    fallback() external payable {}

    receive() external payable {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawToken(address _token) public onlyOwner {
        require(!isContract(msg.sender), "Caller must not be Smart Contract");
        IERC20(_token).transfer(
            owner(),
            IERC20(_token).balanceOf(address(this))
        );
    }
}