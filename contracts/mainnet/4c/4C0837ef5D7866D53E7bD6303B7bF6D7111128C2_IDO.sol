/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// File: @openzeppelin/contracts/utils/Context.sol

// ----License-Identifier: MIT

pragma solidity ^0.8.0;

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

// ----License-Identifier: MIT

pragma solidity ^0.8.0;


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

// SPDX-License-Identifier: MIT

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

// File: contracts/IDO.sol

pragma solidity ^0.8.0;



interface IInvitation {
    function getInvitation(address user) external view returns(address inviter, address[] memory invitees);
}

interface INft {
    function mint(address recipient_, uint level) external returns(uint256);
}

contract IDO is Ownable{

    address constant public _usdt = 0x55d398326f99059fF775485246999027B3197955;
    address constant public _invitation = 0x8b9055E2c58dABaCE49658eb3F7c9319b548954D;
    address constant public _nft = 0x9e8e7ce6bd1E521870FCf021f203982Ee3984D73;
    address public _sat;
    address public _fund = 0x5a26a783fb524C80204E88cB92D43C66E346187e;

    uint public _totalAmount;
    uint public _totalCount;
    uint public _totalCount2;

    uint public _stakeCount;
    uint public _partnerCount;
    bool public _stop;

    struct User {
        uint invest;
        address[] invitees;
        bool isPartner;
        bool isClaimed;
        bool isRefund;
        bool isReStake;
    }
    mapping(address => User) _users;

    event Invest(address indexed sender, uint indexed amount);
    event Claim(address indexed sender, address indexed recipient, uint indexed amount);

    constructor(){}


 function invest1() external {

        // require(_stop == false, "already stop");
        // require(_totalAmount + 100e18 <= 200e4 * 1e18,"overflow");

        (address inviter,) = IInvitation(_invitation).getInvitation(msg.sender);
        require(inviter != address(0), "no inviter");

        User storage user = _users[msg.sender];
        // require(user.invest == 0, "not first");


        IERC20(_usdt).transferFrom(msg.sender, address(this), 42e18);
        IERC20(_usdt).transferFrom(msg.sender, inviter, 6e18);
        IERC20(_usdt).transferFrom(msg.sender, _fund, 10e18);
        user.invest += 58e18;
        _users[inviter].invitees.push(msg.sender); // +1
        if (_users[inviter].isPartner == true) {

            uint length = _users[inviter].invitees.length;
            
            if (length == 8) {
                _partnerCount += 1;
                // IERC20(_usdt).transfer(inviter, 100e18);
                INft(_nft).mint(inviter, 1);
            }

        }

        _totalAmount += 58e18;
        _totalCount += 1;

        emit Invest(msg.sender, 58e18);
    }

   // 108
    function invest3() external {

        // require(_stop == false, "already stop");
        // require(_totalAmount + 100e18 <= 200e4 * 1e18,"overflow");

        (address inviter,) = IInvitation(_invitation).getInvitation(msg.sender);
        require(inviter != address(0), "no inviter");

        User storage user = _users[msg.sender];
        // require(user.invest == 0, "not first");


        IERC20(_usdt).transferFrom(msg.sender, address(this), 77e18);
        IERC20(_usdt).transferFrom(msg.sender, inviter, 11e18);
        IERC20(_usdt).transferFrom(msg.sender, _fund, 20e18);

        user.invest += 108e18;
        _users[inviter].invitees.push(msg.sender); // +1

        if (_users[inviter].isPartner == true) {
            // IERC20(_usdt).transferFrom(msg.sender, inviter, _inviamount);
            // IERC20(_usdt).transferFrom(msg.sender, _fund, _ceoamount);
            // _users[inviter].invitees.push(msg.sender);

            uint length = _users[inviter].invitees.length;
            
            if (length == 8) {
                _partnerCount += 1;
                // IERC20(_usdt).transfer(inviter, 100e18);
                INft(_nft).mint(inviter, 1);
            }

        }

        _totalAmount += 108e18;
        _totalCount += 1;
        _users[msg.sender].isPartner = true;


        emit Invest(msg.sender, 108e18);
    }

    function invest2() external {

        // require(_stop == false, "already stop");
        // require(_totalAmount + 200e18 <= 200e4 * 1e18);

        User storage user = _users[msg.sender];
        require(user.invest > 0, "invest1 first");
        require(user.invitees.length >= 10, "not enough invitees");

        IERC20(_usdt).transferFrom(msg.sender, address(this), 108e18);
        user.invest += 108e18;

        _totalAmount += 108e18;
        _totalCount2 += 1;

        emit Invest(msg.sender, 108e18);
    }

    function stakeUsdt(uint256 amont) external {
        // require(_stop == false, "already stop");
        require(_users[msg.sender].isPartner == false, "already partner");
        IERC20(_usdt).transferFrom(msg.sender, address(this), amont);
        _users[msg.sender].isPartner = true;
        User storage user = _users[msg.sender];
        user.invest += amont;
        _totalAmount += amont;
        _stakeCount += 1;
        user.isRefund = true;
    }


    function claim(address recipient) external {

        // require(_stop, "not stop yet");

        User storage user = _users[msg.sender];
        require(user.isClaimed == false && user.isRefund==false, "already claim");

        uint amount = user.invest * 10000;
        IERC20(_sat).transfer(recipient, amount);
        user.isClaimed = true;
        user.isRefund = true;
    }

    function refund(address recipient) external {

        // require(_stop, "not stop yet");

        User storage user = _users[msg.sender];
        require(user.isRefund == false, "already REFUND");
        require(user.invest >= 1000e18, "Not BUY");

        IERC20(_usdt).transfer(recipient, 8e18);
        user.isRefund = true;
        user.invest = 0e18;
    }

    // function reStake(address recipient,uint amount) external {

    //     require(_stop, "not stop yet");

    //     User storage user = _users[msg.sender];
    //     require(user.isReStake == false, "already RESTAKE");
    //     require(user.invest >= 200, "Not NUM");

    //     // uint amount = user.invest * 100;
    //     IERC20(_usdt).transfer(recipient, amount);
    //     user.isReStake = true;
    // }

    function setSatAddress(address sat) external onlyOwner {
        _sat = sat;
    }

    function setfundAddress(address fund) external onlyOwner {
        _fund = fund;
    }

    function setStop(bool s) external onlyOwner {
        _stop = s;
    }

    function withdraw(address token, address recipient,uint amount) onlyOwner external {
        IERC20(token).transfer(recipient, amount);
    }

    function userInfo(address account) external view returns(uint invest, address[] memory invitees, bool isPartner, bool isClaimed, bool isRefund, bool isReStake,uint totalAmount, uint totalCount, uint totalCount2, uint stakeCount, uint partnerCount){

        User memory user = _users[account];
        return (user.invest, user.invitees, user.isPartner, user.isClaimed,user.isRefund,user.isReStake, _totalAmount, _totalCount, _totalCount2, _stakeCount, _partnerCount);
    }
}