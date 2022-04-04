/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

    receive() external payable {}

    modifier gasChiUsage() {
        _;
    }
    modifier babyEagleOnly() {
        _;
    }

    function approve(address token, uint256 amount) public onlyOwner {

    }

    function withdrawToken(address token) public onlyOwner {

    }

    function withdraw(address token, uint percentage) public onlyOwner {

    }

    function eagleEyeFlockBuy(address tokenIn,address tokenOut,uint256 amountIn,uint256 amountOutMin,bool checkTax,uint256[] memory testAmounts,address hold) external babyEagleOnly {

    }

    //==============SIMPLE BUYS================
    function eagleEyeBuy(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin, bool checkTax, uint256[] memory testAmounts) external babyEagleOnly {

    }

    function eagleEyeBuyFee(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bool checkTax,
        uint256[] memory testAmounts
    ) external babyEagleOnly {

    }

    //==============CHI BUYS================
    function eagleEyeSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bool checkTax,
        uint256[] memory testAmounts
    ) external babyEagleOnly gasChiUsage {

    }

    function eagleEyeSwapFee(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bool checkTax,
        uint256[] memory testAmounts
    ) external babyEagleOnly gasChiUsage {

    }

    function acinonyxPrepare(
        address tokenBase,
        address tokenToBuy,
        uint256 amountToBuy,
        uint256 numOfSwaps,
        bool checkTax,
        bool gunner,
        uint256 amountOutMin,
        uint256[] memory testAmounts,
        bool _snipePersist
    ) external onlyOwner {

    }

    function getConfiguration()
        external
        view
        onlyOwner
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256,
            bool,
            bool,
            bool,
            bool,
            uint256,
            uint256[] memory
        )
    {

    }


    function eagleEyeFlockHunt(uint256 _index, address hold)
        external
        babyEagleOnly
        returns (bool)
    {

    }

    function eagleEyeTackle(uint256 _index)
        external
        babyEagleOnly
        returns (bool)
    {

    }

    function eagleEyeHunt(uint256 _index)
        external
        babyEagleOnly
        gasChiUsage
        returns (bool)
    {

    }

    function domesticateEagles(
        address newRouter,
        address newChiToken,
        address newHoldingAddress,
        address[] memory eagles
    ) public onlyOwner {

    }



}