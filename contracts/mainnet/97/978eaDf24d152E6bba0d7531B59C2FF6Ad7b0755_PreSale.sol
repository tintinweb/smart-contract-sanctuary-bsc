/**
 *Submitted for verification at BscScan.com on 2022-03-30
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

// File: contracts/bank.sol


pragma solidity ^0.8.4;


interface AggregatorV3Interface {
    function latestRoundData()
    external
    view
    returns (
        uint80 roundId,
        int answer,
        uint startedAt,
        uint updatedAt,
        uint80 answeredInRound
    );
}

error Unauthorized();
error UnBNB();

contract PreSale {
    IERC20 constant SOFI = IERC20(0x86463efEb5aba888D38425C4b79B49ebADC24139);
    address payable constant receiver = payable(0x897C1F2f00A03575c3956f3c2F69567130b6DB80);
    address constant sofiFrom = 0xB60D1BefdCa41bf877F9d9103b658c079D49dcB0;

    AggregatorV3Interface constant public priceFeed = AggregatorV3Interface(
        // 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526 //testnet
        0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
    );

    uint public endTime;
    uint256 public tolerance;
    address admin;

    mapping (address => uint) public balanceOf;
    event Deposit(address indexed _sender, uint _amount);
    modifier checkEnd(){
        if(block.timestamp > endTime){ revert Unauthorized(); }
        _;
    }

    constructor(uint _endTime) {
        endTime = _endTime;
        admin = msg.sender;
        tolerance = 3; 
    }

    function buy(uint8 btype, address promote) payable external checkEnd {
        uint sAmount;
        if(btype == 0){
            uint256 price = getLatestPrice();
            if( msg.value < ((2000 - tolerance) * 1e26 / price)){
                revert UnBNB();
            }
            sAmount = 1000 * 1e5;
        }else if (btype == 1) {
            uint256 price = getLatestPrice();
            if( msg.value < ((600 - tolerance) * 1e26 / price)){
                revert UnBNB();
            }
            sAmount = 300 * 1e5;
        } 
        else {
            uint256 price = getLatestPrice();
            if( msg.value < ((100 - tolerance) * 1e26 / price)){
                revert UnBNB();
            }
            sAmount = 50 * 1e5;
        }

        unchecked { balanceOf[msg.sender] += msg.value; }

        receiver.transfer(msg.value);

        SOFI.transferFrom(sofiFrom, msg.sender, sAmount);
        if (promote != address(0)) {
            SOFI.transferFrom(sofiFrom, promote, sAmount * 8 / 100);
        }
        emit Deposit(msg.sender, msg.value);
    }

    function getLatestPrice() public view returns (uint256) {
        ( , int price, , , ) = priceFeed.latestRoundData();
    // for BNB / USD price is scaled up by 10 ** 8
        return uint256(price);
    }

    function setEndTime(uint _endTime) external { 
        if(msg.sender != admin ){ revert Unauthorized(); }
        endTime = _endTime; 
    }
    function setTolerance(uint256 _tolerance) external {
        if(msg.sender != admin ){ revert Unauthorized(); }
        tolerance = _tolerance;
    }
}