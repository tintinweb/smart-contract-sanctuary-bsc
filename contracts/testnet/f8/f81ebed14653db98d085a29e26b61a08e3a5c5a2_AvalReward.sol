/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



library IterableMap {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint index) internal view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint val
    ) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

abstract contract ReentrancyGuard {
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
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


contract AvalReward is ReentrancyGuard {
    struct Reward {
        uint256 id;
        uint256 deadline;
        uint256 amount;
    }

    address private owner;
    uint256 private coolingDuration;
    uint256 private primaryId;
    uint256 private discount;
    bool private pause;
    mapping(address => uint256) collectMap;
    mapping(address => Reward[]) rewardMap;

    event Collect(address to, uint256 amount);
    event WithdrawByPlayer(address from, address to, uint256 amount);

    constructor() {
        primaryId = 11;
        discount = 50;
        coolingDuration = 3600 * 24 * 30;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "msg sender is not owner");
        _;
    }

    modifier onlyDisablePause() {
        require(!pause, "Deposit and Withdraw has paused");
        _;
    }

    function enablePause() external onlyOwner {
        pause = true;
    }

    function disablePause() external onlyOwner {
        pause = false;
    }

    // 设置冷静期提现的折扣利率
    function setDiscount(uint256 _discount) external onlyOwner {
        require(_discount > 0 && _discount < 100, "Invalid input parameter");
        discount = _discount;
    }
    // 设置冷静期
    function setCoolingDuration(uint256 _coolingDuration) external onlyOwner {
        coolingDuration = _coolingDuration;
    }

    function autoIncrementId() private returns(uint256) {
        return primaryId += 1;
    }

    function collect() external nonReentrant {
        require(collectMap[msg.sender] > 0, "available amount must be greater than 0");
        uint256 amount = collectMap[msg.sender];
        rewardMap[msg.sender].push(Reward(autoIncrementId(), block.timestamp + coolingDuration, amount));
        collectMap[msg.sender] = 0;
        emit Collect(msg.sender, amount);
    }

    function airdrop(address wallet, uint256 amount) external nonReentrant {
        require(wallet != address(0x0), "wallet address must be AVAL token address");
        require(amount > 0, "airdrop amount can not be zero");
        collectMap[wallet] += amount;
    }

    function withdrawByPlayer(address token, uint256 _id) external nonReentrant onlyDisablePause {
        require(token != address(0), "Token invalid");
        require(_id > 0 && _id <= primaryId, "Invalid input parameter");
        require(rewardMap[msg.sender].length > 0, "No data");
        uint256 index;
        bool isExits = false;
        for (uint256 i = 0; i < rewardMap[msg.sender].length; i++) {
            if (rewardMap[msg.sender][i].id == _id) {
                index = i;
                isExits = true;
                break;
            }
        }
        require(isExits, "Reward record not found");
        uint256 amount = rewardMap[msg.sender][index].amount;
        require(amount > 0, "available balance is not enough");
        if (block.timestamp < rewardMap[msg.sender][index].deadline) {
            amount = amount * discount / 100;
        }
        require(amount <= IERC20(token).balanceOf(address(this)), "Contract balance is not enough");
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failure");
        Reward[] storage list = rewardMap[msg.sender];
        for (uint256 i = index; i < list.length; i++) {
            list[i] = list[i+1];
        }
        list.pop;
        emit WithdrawByPlayer(address(this), msg.sender, amount);
    }

    function getCollectBalance(address wallet) external view returns(uint256) {
        return collectMap[wallet];
    }

    function getLength(address wallet) external view returns(uint256) {
        require(wallet != address(0), "Invalid wallet address");
        return rewardMap[wallet].length;
    }

    function getRecord(address wallet, uint256 index) external view returns(uint256, uint256, uint256) {
        require(wallet != address(0), "Invalid wallet address");
        require(index < rewardMap[wallet].length, "Array out of bounds");
        return (rewardMap[wallet][index].id, rewardMap[wallet][index].deadline, rewardMap[wallet][index].amount);
    }

    function withdraw(address token) external onlyOwner onlyDisablePause {
        if (token == address(0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawTo(address wallet, address token, uint256 amount) external onlyOwner onlyDisablePause {
        require(wallet != address(0), "Wallet address can not be empty address");
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(amount <= IERC20(token).balanceOf(address(this)), "Contract balance is not enough");
        if (token == address(0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20(token).transfer(wallet, amount);
    }

    function deposit(address token, uint256 amount) external onlyDisablePause {
        require(token != address(0), "Token can not be empty address");
        require(amount > 0, "Deposit amount must be greater than 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    function getBalanceOf(address token) external view returns(uint256) {
        require(token != address(0), "Token can not be empty address");
        return IERC20(token).balanceOf(address(this));
    }
}