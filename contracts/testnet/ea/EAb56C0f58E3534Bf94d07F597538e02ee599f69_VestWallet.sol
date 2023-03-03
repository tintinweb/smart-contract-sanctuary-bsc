/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     
    function getOwner() external view returns (address); */

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract VestWallet {
    // event for locking the tokens to the smartcontract address
    event lock(address indexed _locker, address indexed _beneficary, uint256 _amount, uint256 index);
    event releaseLockTokens(address indexed _locker, address indexed _beneficary, uint256 _amount, uint256 index);

    // the token address that you want to lock or vest KIUUP.
    address token;
    //locked tokens structurted which it will includes the whole informatio about the locked tokens.
    struct Locked {
        address beneficary;
        string name;
        uint256 totalAmount;
        uint256 amount;
        uint256 released;
        uint256 start;
        uint256 duration;
        uint256 estimatedTime;
    }

    // Each lock key will reference to a specific lock structure,
    mapping(uint256 => Locked) vests;

    // The number of vesting the tokens and homw
    uint8 numOfVest;

    // The default duration of the lock/vest period in seconds 
    uint256 duration;

    constructor(address _token) {
        token = _token;
    }

    function lockTokens(
        address  _beneficary,
        uint256 _duration,
        uint256 _amount
    ) public payable {
        //the beneficary address must not be a zero address 
        require(
            _beneficary != address(0),
            "VestingWallet: beneficiary is zero address"
        );
        // the minmum lock tokens is 100 Kiuup tokens
        require(
            _amount >= 100 * 10**18,
            "VestingWallet: The minmum amount you could lock is 100 Token in wei"
        );

        // The mimum time to lock the tokens is 1 Minute
        require(
            _duration >= 60,
            "VestingWallet: Please input a Valid time"
        );

        bool transfer = IBEP20(token).transferFrom(msg.sender, address(this), _amount);
        // Add the data to the structures
        require(transfer, "VestingWallet: The transaction didn't happen Please approve the amount before.");
        vests[numOfVest].beneficary = _beneficary;
        vests[numOfVest].duration = _duration;
        vests[numOfVest].totalAmount = _amount;
        vests[numOfVest].amount = _amount;
        vests[numOfVest].start = block.timestamp;
        vests[numOfVest].estimatedTime = block.timestamp + _duration;
        numOfVest++;

        // emit the event for locking tokens
        emit lock(address(this), _beneficary, _amount, numOfVest - 1);
    }

    // Function for releasing the lock tokens 
    function release(uint256 _amount, address _beneficary, uint256 _index) public {
        // check if the address is a zero address
        require(_beneficary != address(0), "VestingWallet: You can't transfer to the zero address.");
        // check if the amount bigger than the vest amount 
        require(vests[_index].amount >= _amount, "VestingWallet: Insufficient funds");
        // The address who runing the function must be the address who vest the tokens
        require(vests[_index].beneficary == msg.sender, "VestingWallet: The address who runing the function must be the same with the vest index");
        // check if the time its finished
        require(vests[_index].estimatedTime <= block.timestamp, "VestingWallet: The time of releasing the tokens didn't came yet");

        vests[_index].amount -= _amount;
        vests[_index].released += _amount;

        bool transfer = IBEP20(token).transfer(_beneficary, _amount);

        require(transfer, "VestingWallet: The transaction of releasing the tokens didn't happened");
       
       // sent an event to the customers
       emit releaseLockTokens(address(this), _beneficary, _amount, _index);
    }



    // Get the whole data for a specific Vest
    function getVest(uint256 _index) public view returns (Locked memory) {
        return vests[_index];
    }

    // Get date of now (Timestamp)
    function getNow() public view returns (uint256) {
        return block.timestamp;
    }

    // Get date of starting the lock (Timestamp)
    function getStart(uint256 _index) public view returns (uint256) {
        return vests[_index].start;
    }

    // Get date of lock during (Timestamp)
    function getDuration(uint256 _index) public view returns (uint256) {
        return vests[_index].duration;
    }

    // Get the beneficary address (address)
    function getBeneficary(uint256 _index) public view returns (address) {
        return vests[_index].beneficary;
    }

    // Get the amount that is locked currently (uint)
    function getAmount(uint256 _index) public view returns (uint256) {
        return vests[_index].amount;
    }

    // Get the total amount locked (uint)
    function getTotalAmount(uint256 _index) public view returns (uint256) {
        return vests[_index].totalAmount;
    }

    // Get the released amount that unlocked and transfered after the locked perioed finished (uint)
    function getReleased(uint256 _index) public view returns (uint256) {
        return vests[_index].released;
    }

    // get the released time for ableing the transfer
    function getReleaseTime(uint256 _index) public view returns (uint256) {
        return vests[_index].estimatedTime;
    }

    // get the number of the locked that occured via the smart contract
    function getNumOfLock() public view returns (uint256) {
        return numOfVest;
    }

}