/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
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
interface AggregatorInterface {
  function latestAnswer() external view returns (uint256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (uint256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(uint256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract GDeal{
    address deployer;
    address payable owner;
    address payable admin;
    address public implementation;

    AggregatorInterface internal priceFeed;
    IERC20 gameToken;

    uint[] public claim_periods;
    
    uint initial_limit = 1500;
    uint ref_bonus = 5;
    uint limit_increase_by = 100;
    uint max_direct_ref_income = 5;
    uint min_condition = 1000;
    uint devider = 100;
    uint256 coin_rate = 15;
    uint256 round_counter = 8500000;

    modifier onlyDeployer() {
        require (msg.sender == deployer);
        _;
    }

    struct User {
        address upline;
        uint referrals;
        uint counted_directs;
        uint256 direct_bonus;
        uint    deposit_time;
        uint256 total_deposit;
        uint256 limit;
        uint no_of_deposits;
        Investments [] investment;
    }
    struct Investments {
        uint256 deposit_amount;
        uint256 left_amount;
        uint time;
        uint claim_period;
        uint256 usd_value;
        uint256 price;

    }

    mapping(address => User) public users;

    constructor (address payable _owner, address payable _admin, IERC20 _gameToken)  {
        deployer = msg.sender;
        owner = _owner;
        admin = _admin;
        gameToken = _gameToken;

        priceFeed = AggregatorInterface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

        claim_periods.push(90 days);
        claim_periods.push(120 days);
        claim_periods.push(150 days);
        claim_periods.push(180 days);
    }

    fallback() external {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(gas(),sload(implementation.slot),ptr,calldatasize(),0,0)

            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
    function upgrade(address _newImplementation) 
        external onlyDeployer {
        require(implementation != _newImplementation);
        _setnew(_newImplementation);
    }
    function _setnew(address _newImp) internal {
        implementation = _newImp;
    }
    function getInvestments(address _addr, uint _level) public view returns(uint256 deposit_amount, uint time, uint claim_period, uint256 usd_value, uint256 price, uint256 left_amount) { 
        return (users[_addr].investment[_level].deposit_amount, users[_addr].investment[_level].time, users[_addr].investment[_level].claim_period, users[_addr].investment[_level].usd_value, users[_addr].investment[_level].price, users[_addr].investment[_level].left_amount);
    }
    function calculateCoins(uint256 _value) public view returns(uint256 latestPrice, uint256 usd_amount, uint256 tokens) { 
        latestPrice = priceFeed.latestAnswer() / 1e8;
        usd_amount = (latestPrice * _value) / 1e18;
        tokens = (usd_amount * devider) / coin_rate;
    }
}