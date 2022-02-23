/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract EagleEye is Ownable {

    receive() payable external {}

    modifier gasChiUsage {
        _;
    }
    modifier babyEagleOnly {
        _;
    }

    function _setupNest(address tokenIn, address tokenOut, uint amountIn) internal returns (address[] memory path) {

    }
    function eagleEyeSwap(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin) external babyEagleOnly gasChiUsage {

    }
    function eagleEyeSwapFee(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin) external babyEagleOnly gasChiUsage {

    }
    function eagleFlockSwap(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin, uint numberOfSwaps) external babyEagleOnly gasChiUsage {

    }
    function acinonyxPrepare(address tokenBase, address tokenToBuy, uint amountToBuy, uint numOfSwaps, bool checkTax, bool gunner, uint amountOutMin, uint[] memory testAmounts) external onlyOwner {

    }
    function eagleEyeHunt() external babyEagleOnly gasChiUsage returns (bool) {

    }
    function domesticateEagle(address newRouter, address newChiToken, address newHoldingAddress, address[] memory eagles) public onlyOwner {

    }
    function setupBabyEagles(address[] memory _eagles) public onlyOwner {

    }
    function removeBabyEagles(address[] memory _eagles) public onlyOwner {

    }
    function multiTransfer(address _token, address[] memory _addresses, uint256 _amount) public onlyOwner gasChiUsage{

    }
}