/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract RoboChef is Context, Ownable {

    bool private initialized = false;

    uint32 private PLAY_FEE = 300;
    uint32 private SELL_FEE = 300;
    uint32 private MEAL_RATE = 500;
    uint32 private RATE_FEE_DIVISOR = 10000;
    uint32 private COMPOUND_GAIN = 34;
    uint32 private COMPOUND_SECONDS = 518400;
    uint32 private NEXT_SALE_SECONDS = 604800;
    uint32 private GAIN_DIVISOR = 100;

    uint32 private REFERRAL_RATE = 500;
    address private bonusWallet;

    address payable private feeWallet;
    uint256 private globalParts;

    struct Player {
		uint256 amount;
        uint256 claims;
		uint256 first;
        uint256 last;
		uint256 next;
        uint256 parts;
        uint256 referrals;
	}

	mapping (address => Player) private players;

    event Played(address indexed player, uint256 value, uint256 total, uint256 parts, uint256 timestamp);
    event Sold(address indexed player, uint256 value, uint256 total, uint256 parts, uint256 timestamp, uint256 next);

    constructor() {
        feeWallet = payable(msg.sender);
        globalParts = 69096;
    }

    function initialize() external payable onlyOwner {
        globalParts = 108000000000;
        initialized = true;
    }

    // only owner functions to set fees, change timings, ...  

    function setFeeWallet(address wallet) public onlyOwner {
        feeWallet = payable(wallet);
    }

    function setBonusWallet(address wallet) public onlyOwner {
        bonusWallet = wallet;
    }

    function setGamenomics(uint32 playFee, uint32 sellFee, uint32 mealRate, uint32 compoundGain, uint32 compoundSeconds, uint32 nextSaleSeconds) public onlyOwner {
        require(playFee > 10, "Play fee must be greater than 0.1%");
        require(playFee < 1000, "Play fee must be less than 10%");
        require(sellFee > 10, "Sell fee must be greater than 0.1%");
        require(sellFee < 1000, "Sell fee must be less than 10%");
        require(mealRate > 10, "Meal rate must be greater than 0.1%");
        require(mealRate < 1000, "Meal rate must be less than 10%");
        require(compoundGain > 1, "Compound rate must be greater than or equal to 2%, i.e. 1% for 2 days");
        require(compoundGain < 1487, "Compound rate must be less than or equal to 1486%, i.e. 10% for 29 days");
        require(compoundSeconds > 172799, "Compound time (in seconds) must be greater than or equal to 2 days");
        require(compoundSeconds < 2505601, "Compound time (in seconds) must be less than or equal to 29 days");
        require(nextSaleSeconds > 259199, "Next sale time must be at least 3 days away");
        require(nextSaleSeconds < 2592001, "Next sale time must be up to 30 days away");

        PLAY_FEE = playFee;
        SELL_FEE = sellFee;
        MEAL_RATE = mealRate;
        COMPOUND_GAIN = compoundGain;
        COMPOUND_SECONDS = compoundSeconds;
        NEXT_SALE_SECONDS = nextSaleSeconds;
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function getGlobalParts() external view returns(uint256) {
        return globalParts;
    }

    function getParts() external view returns(uint256) {
        return players[msg.sender].parts;
    }

    function getPartsGrowth() external view returns(uint256) {
        return gains();
    }

    function getMeals() external view returns(uint256) {
        return (elapsed() / COMPOUND_SECONDS) * evaluate(players[msg.sender].parts + gains());
    }

    function getEstimatedRewards() external view returns(uint256) {
        return (elapsed() / COMPOUND_SECONDS) * MEAL_RATE * (players[msg.sender].parts + gains()) / RATE_FEE_DIVISOR;
    }

    function play(address referral) external payable {
        require(initialized, "The game is not ready for players.");
        require(msg.value > 0, "Cannot play with nothing!");
        
        uint256 fee = msg.value * PLAY_FEE / RATE_FEE_DIVISOR;
        feeWallet.transfer(fee);

        if (players[msg.sender].first == 0) {
            players[msg.sender] = Player({amount:0, claims:0, first:block.timestamp, last:block.timestamp, next:block.timestamp + COMPOUND_SECONDS, parts:0, referrals:0});
        } else {
            compound();
        }

        if (referral == address(0)) { referral = bonusWallet; }
        if (referral == msg.sender) { referral = bonusWallet; }
        if (players[referral].first == 0) { referral = bonusWallet; }

        uint256 gain = purchase(msg.value);

        uint256 bonus = 0;
        
        if (referral != address(0)) 
        { 
            bonus = REFERRAL_RATE * gain / RATE_FEE_DIVISOR;
            players[referral].parts += bonus;
            players[referral].referrals++;
            // consider emitting referral data too...
        }

        players[msg.sender].parts += gain;
        players[msg.sender].amount += msg.value;
        globalParts += gain + bonus;

        emit Played(msg.sender, msg.value, players[msg.sender].amount, players[msg.sender].parts, block.timestamp);
    }

    function elapsed() private view returns (uint256) {
        unchecked {
            uint256 next = players[msg.sender].next;
            if (block.timestamp < next) { next = block.timestamp; }
            if ( next < players[msg.sender].last) { return uint256(0); }
            uint256 result = next - players[msg.sender].last;
            if (result > COMPOUND_SECONDS) { result = COMPOUND_SECONDS; }
            return result;
        }
    }

    function gains() private view returns (uint256) {
        return (COMPOUND_GAIN * elapsed() / COMPOUND_SECONDS) * players[msg.sender].parts / GAIN_DIVISOR;
    }

    function compound() private {
        uint256 gain = gains();
        players[msg.sender].parts += gain;
        globalParts += gain;
        players[msg.sender].last = block.timestamp;
    }

    function evaluate(uint256 amount) private view returns (uint256) {
        return MEAL_RATE * amount / RATE_FEE_DIVISOR;
    }

    function sell() external payable {
        require(initialized, "The game is not ready for players.");
        require(players[msg.sender].first > 0, "Player must have played!");
        require(address(this).balance > 0, "Contract balance must be positive!");
        require(block.timestamp > players[msg.sender].next);
        
        compound();

        uint256 reward = sale(evaluate(players[msg.sender].parts));
        uint256 max = evaluate(players[msg.sender].amount);
        if (reward > max) { reward = max; }

        uint256 fee = reward * SELL_FEE / RATE_FEE_DIVISOR;
        feeWallet.transfer(fee);

        reward -= fee;

        players[msg.sender].last = players[msg.sender].next + 24 * 3600;
        players[msg.sender].next = players[msg.sender].next + NEXT_SALE_SECONDS;
        
        players[msg.sender].claims += reward;

        payable(msg.sender).transfer(reward);

        emit Sold(msg.sender, reward, players[msg.sender].claims, players[msg.sender].parts, block.timestamp, players[msg.sender].next);
    }

    function purchase(uint256 amount) private view returns(uint256) {
        return trade(amount, address(this).balance, globalParts);
    }

    function sale(uint256 meals) private view returns(uint256) {
        return trade(meals, globalParts, address(this).balance);
    }

    function trade(uint256 value, uint256 pool, uint256 measure) private pure returns(uint256) {
        unchecked {
            return measure * value / (value + pool);
        }
    }
}