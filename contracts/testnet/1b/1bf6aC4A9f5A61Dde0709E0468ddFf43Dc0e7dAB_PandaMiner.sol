/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/*
* PandaMiner Contract
*/
contract PandaMiner is Ownable, ReentrancyGuard {
    uint256 public constant MIN = 50 ether;
    uint256 public constant MAX = 100000 ether;
    uint256 public constant ROI = 17;
    uint256 public constant FEE = 6;
    uint256 public constant WITHDRAW_FEE = 10;
    uint256 public constant REF_FEE = 10;
    address public constant DEV = 0xccD42484785ef5Df06713e457a0f6B5D56d44FE2;

    // Initialization check
    bool public init = false;

    modifier alreadyInit() {
        require(init, "Not Started Yet");
        _;
    }

    modifier checkDeposit() {
        require(investors[msg.sender].investment > 0, "No Deposit");
        _;
    }

    // Token IERC20
    IERC20 public immutable token;

    constructor() {
        address tokenAddress = 0x95aB689EeA6A896A81eA1ac9dD08bd0f83D045D5;
        token = IERC20(tokenAddress);
    }

    struct Investor {
        bool alreadyInvested;
        uint256 lastClaim;
        uint256 lastWithdraw;
        uint256 investment;
        uint256 approvedWithdrawal;
        uint256 totalWithdrawal;
        uint256 totalReward;
        uint256 refReward;
        uint256 refTotalWithdraw;
    }

    mapping(address => Investor) public investors;

    // Contract start function
    function mark_contract() public onlyOwner {
        init = true;
    }

    // Deposit function
    function deposit(address _ref, uint256 _amount)
        public
        noReentrant
        alreadyInit
    {
        require(_amount >= MIN && _amount <= MAX, "Cannot Deposit");

        // Check referral
        address _to = _ref == address(0) || _ref == msg.sender ? DEV : _ref;

        investors[_to].refReward += refFee(_amount);
        investors[msg.sender].investment += _amount;

        // Time limit for deposit withdrawal
        if (!investors[msg.sender].alreadyInvested) {
            investors[msg.sender].alreadyInvested = true;
            investors[msg.sender].lastWithdraw = block.timestamp;
            investors[msg.sender].lastClaim = block.timestamp;
        }

        // Deposit distribution
        uint256 deposit_fee = depositFee(_amount);
        token.transferFrom(msg.sender, DEV, deposit_fee);
        token.transferFrom(msg.sender, address(this), _amount - deposit_fee);
    }   

    // Daily reward calculation
    function userReward(address _address) public view returns (uint256) {
        uint256 userDailyReturn = dailyRoi(investors[_address].investment);
        uint256 claimInvestStart = investors[_address].lastClaim;

        if (claimInvestStart + 1 days < block.timestamp) {
            return userDailyReturn;
        }

        uint256 earned = block.timestamp - claimInvestStart;
        uint256 totalEarned = (earned * userDailyReturn) / 1 days;

        return totalEarned;
    }

    // Claim daily reward
    function claimDailyRewards() public noReentrant alreadyInit checkDeposit {
        require(
            investors[msg.sender].lastClaim <= block.timestamp,
            "You cant claim"
        );

        uint256 rewards = userReward(msg.sender);

        investors[msg.sender].approvedWithdrawal += rewards;
        investors[msg.sender].totalReward += rewards;
        investors[msg.sender].lastClaim = block.timestamp;
    }

    // Weekly withdraw function
    function withdraw() public noReentrant alreadyInit checkDeposit {
        require(
            investors[msg.sender].lastWithdraw + 7 days <= block.timestamp,
            "You cant withdraw"
        );

        // Investment details
        require(
            investors[msg.sender].totalReward <=
                investors[msg.sender].investment * 5,
            "You cant withdraw you have collected five times already"
        );

        // Withdrawal details
        uint256 aval_withdraw2 = investors[msg.sender].approvedWithdrawal / 2;
        uint256 wFee = withdrawFee(aval_withdraw2);

        token.transfer(DEV, wFee);
        token.transfer(msg.sender, aval_withdraw2 - wFee);

        investors[msg.sender].approvedWithdrawal -= aval_withdraw2;
        investors[msg.sender].totalWithdrawal += aval_withdraw2;
        investors[msg.sender].lastWithdraw = block.timestamp;
    }

    // Early withdrawal of funds
    function unStake() external noReentrant alreadyInit checkDeposit {
        uint256 t_withdraw = investors[msg.sender].totalWithdrawal;
        uint256 investment = investors[msg.sender].investment;

        require(
            investment > t_withdraw,
            "You already withdraw a lot than your investment"
        );

        delete investors[msg.sender].investment;
        delete investors[msg.sender].approvedWithdrawal;

        uint256 lastFee = depositFee(investment);
        uint256 unstakeValueCore = (investment - lastFee - t_withdraw) / 2;

        // 50% to the investor, 50% to the contract
        token.transfer(msg.sender, unstakeValueCore);
    }

    // Referral fee
    function refWithdraw() external noReentrant alreadyInit {
        uint256 value = investors[msg.sender].refReward;

        token.transfer(msg.sender, value);
        delete investors[msg.sender].refReward;

        investors[msg.sender].refTotalWithdraw += value;
    }

    // Other functions

    function dailyRoi(uint256 _amount) public pure returns (uint256) {
        return (_amount * ROI) / 100;
    }

    function depositFee(uint256 _amount) public pure returns (uint256) {
        return (_amount * FEE) / 100;
    }

    function refFee(uint256 _amount) public pure returns (uint256) {
        return (_amount * REF_FEE) / 100;
    }

    function withdrawFee(uint256 _amount) public pure returns (uint256) {
        return (_amount * WITHDRAW_FEE) / 100;
    }

    function getBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}