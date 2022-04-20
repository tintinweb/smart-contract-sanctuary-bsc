/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

/**
* Divvy Locker: PRM
* https://divvysd.com/dashboard/#/PRM
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
}

contract DivvyLockerRBL{
    bool  private _rentrenceLock = true;
    mapping (address => bool) private _claimer;
    mapping (address => uint256) private _locked;

    uint256 unlocktime = 0;

    constructor() {
     _claimer[msg.sender] = true;
     unlocktime = block.timestamp + 90 days;
    }

    address private _activeTokenAddress;

    modifier onlyClaimers() {
        require(_claimer[msg.sender], "Claimer: caller is not the allowed list of claimer");
        _;
    }

    modifier lock(){
        require(_rentrenceLock,"Reentrency protection hit");
        _rentrenceLock = false;
        _;
        _rentrenceLock = true;
    }

    function setTokenAddress(address tokenAddress) public onlyClaimers{
        _activeTokenAddress = tokenAddress;
    }

    function resetReflectionsFloor() external onlyClaimers{
        _locked[_activeTokenAddress] = IERC20(_activeTokenAddress).balanceOf(address(this));
    }

    function availableReflections() external view returns(uint256){
        return IERC20(_activeTokenAddress).balanceOf(address(this)) - _locked[_activeTokenAddress];
    }

    function lockedSupply(address tokenAddress) view external returns(uint256){
        return _locked[tokenAddress];
    }

    function getReflections() external lock onlyClaimers{
        uint256 amt = IERC20(_activeTokenAddress).balanceOf(address(this)) - _locked[_activeTokenAddress];
        bool xfer = IERC20(_activeTokenAddress).transfer(msg.sender, amt);
        require(xfer, "ERR_ERC20_FALSE");

    }

    function currentActiveToken() external view returns(address){
        return _activeTokenAddress;
    }

    function isClaimer(address toCheck) external view returns(bool){
        return _claimer[toCheck];
    }

    function addClaimer(address toAdd) external onlyClaimers{
        _claimer[toAdd] = true;
    }

    function removeClaimer(address toRemove) external onlyClaimers{
        _claimer[toRemove] = false;
    }

    function reaminingTime() external view returns(uint256){
        if(block.timestamp > unlocktime){
            return 0;
        }
        else{
            return unlocktime - block.timestamp;
        }
    }

    function extend(uint256 time) external onlyClaimers{
        require(time > 0, "Time can't be less than 0");
        require(time < 31556926, "Can't extend more than 1 year at a time. (31556926)");
        unlocktime = unlocktime + time;
    }

    function unlock() external {
        require(block.timestamp > unlocktime,"Enough time hasn't passed.");
        _locked[_activeTokenAddress] = 0;
    }
}