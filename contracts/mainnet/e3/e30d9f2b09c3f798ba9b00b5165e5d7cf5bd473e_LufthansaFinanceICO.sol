/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

//SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity 0.8.13;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



// pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



// pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
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

// File: contracts/LuftansaSale.sol


// pragma solidity 0.8.13;




/**
 * @dev Token Buy contract
 *
 */

contract LufthansaFinanceICO is Context, Ownable {
    enum State {
        ToStart,
        Phase1,
        Phase2,
        Phase3,
        Ended
    }
    IERC20 token;

    uint256 public startUTCDateTime;
    uint256 public endUTCDateTime;
    uint256 public phaseCap;
    uint256 public rate; // tokens per bnb
    uint256 public saleCount; // total token sold
    uint256 public raisedAmount; // in wei
    State public phase;

    constructor(address _token, uint256 _rate) {
        token = IERC20(_token);
        rate = _rate;
        phase = State.ToStart;
    }

    /**
     * BoughtTokens
     * @dev Log tokens bought on the blockchain
     */
    event BoughtTokens(address indexed buyer, uint256 indexed value);

    /**
     * buyTokens
     * @dev function that sells owner approved tokens
     */
    function buyTokens() public payable {
        require(msg.value > 0, "Incorrect amount");
        require(phase != State.ToStart, "Sale not started");
        require(phase != State.Ended, "Sale Ended");

        uint256 weiAmount = msg.value;

        uint256 tokens = weiAmount * rate;

        raisedAmount = raisedAmount + msg.value;
        emit BoughtTokens(_msgSender(), tokens);

        require(
            token.transferFrom(owner(), _msgSender(), tokens),
            "Sale: TokenTransfer failed"
        );

        payable(owner()).transfer(msg.value);
    }

    /**
     * setRate
     * @dev function that sets rate
     */
    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    /**
     * receive
     * @dev to enable contract to receive bnb
     *
     */
    receive() external payable {}

    /**
     * ownerWithdrawBNB
     * @dev owner will be able to withdraw any remaining bnb
     *
     */
    function ownerWithdrawBNB() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_msgSender()).transfer(balance);
    }

    /**
     * @dev Setup Sale from smart contract.
     */

    function addPhaseSetting(
        uint256 _rate,
        uint256 _phaseCap,
        State _state
    ) public onlyOwner {
        phase = State(_state);
        startUTCDateTime = block.timestamp;
        endUTCDateTime = block.timestamp + 864000;
        rate = _rate;
        phaseCap = _phaseCap;
    }

    /**
     * @dev View Setuped Sale from smart contract.
     */

    function viewPhaseSettings()
        public
        view
        returns (
            uint256 _startUTCDateTime,
            uint256 _endUTCDateTime,
            uint256 _phaseCap,
            uint256 _saleCount,
            uint256 _rate,
            State _phase
        )
    {
        return (
            startUTCDateTime,
            endUTCDateTime,
            phaseCap,
            saleCount,
            rate,
            phase
        );
    }
}