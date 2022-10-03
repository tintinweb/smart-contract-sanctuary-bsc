/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

// File: presale.sol


pragma solidity ^0.8.4;


abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }
}

contract PreSale is Owned {
    IERC20 public WHN;
    IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address constant receiver = 0xBb16672F37DE2E0367062a9716D40caE9920170d;
    address constant RFrom = 0x51A3C051F99F4E47f48b1C9BA59E2116B4aC6Ea9;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastTimeWithdrawReward;
    mapping(address => address) public inviters;
    mapping(address => address[]) public myInviters;
    event Deposit(address indexed _sender, uint256 _amount);

    mapping(address => bool) public called;

    modifier once() {
        require(called[msg.sender] != true, "once");
        _;
        called[msg.sender] = true;
    }

    constructor(IERC20 _whn) {
        WHN = _whn;
    }

    function buy(address _promoter) external once {
        uint256 whnAmount = 2000 * 1e18;
        uint256 usdtAmount = 100 * 1e18;

        balanceOf[msg.sender] += usdtAmount;
        USDT.transferFrom(msg.sender, receiver, usdtAmount);
        WHN.transfer(msg.sender, whnAmount);
        emit Deposit(msg.sender, usdtAmount);

        if (_promoter != address(0)) {
            inviters[msg.sender] = _promoter;
            myInviters[_promoter].push(msg.sender);
            rewards[_promoter] += 100 * 1e18;
            WHN.transfer(_promoter, 100 * 1e18);
        }
    }

    function getPromoters(
        address _promoter,
        uint256 _start,
        uint256 _count
    ) external view returns (address[] memory) {
        uint256 count = _count;
        address[] storage ins = myInviters[_promoter];
        if (ins.length < count) {
            count = ins.length;
        }
        address[] memory r = new address[](count);
        for (uint256 i = _start; i < _start + count; i++) {
            r[i - _start] = (ins[i]);
        }
        return r;
    }

    function getInviterLength(address _promoter)
        external
        view
        returns (uint256)
    {
        address[] storage ins = myInviters[_promoter];
        return ins.length;
    }

    function setWHN(IERC20 _whn) external onlyOwner {
        WHN = _whn;
    }

    function withdrawWHN(uint256 _amount) external onlyOwner {
        WHN.transfer(msg.sender, _amount);
    }

    function getRewardAmount() external view returns (uint256) {
        if (
            lastTimeWithdrawReward[msg.sender] + 60 * 60 * 24 >= block.timestamp
        ) {
            return 0;
        }
        uint256 userBal = WHN.balanceOf(msg.sender);
        if (userBal < 3000 * 1e18) {
            return 0;
        } else {
            return (userBal * 5) / 1000;
        }
    }

    function withdrawReward() external {
        require(
            lastTimeWithdrawReward[msg.sender] + 60 * 60 * 24 < block.timestamp,
            "a day"
        );

        uint256 userBal = WHN.balanceOf(msg.sender);
        require(userBal >= 3000 * 1e18, "3000");

        uint256 amount = (userBal * 5) / 1000;
        lastTimeWithdrawReward[msg.sender] = block.timestamp;
        WHN.transferFrom(RFrom, msg.sender, amount);
    }
}