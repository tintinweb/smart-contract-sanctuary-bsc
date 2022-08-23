/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: none

pragma solidity 0.6.12;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}

interface ILOCKER {
    function lockToken (IERC20 token, address beneficiary, uint256 amount, uint256 releaseTimestamp) external;
}

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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface CULTBurn {
    function burn(uint256 amount) external;
}

contract DistributorContractV2 is Context, Ownable {
    using SafeMath for uint256;
 
    address public OppcultureContract = 0x3cdFC8dE85c094cA8d292feE269919E407ecDc1a;
    address public EquityContract = 0x14895D191C8c2BdE4c488BE84fdAe95339eabfa1;
    address public TokenLockerContract = 0x14895D191C8c2BdE4c488BE84fdAe95339eabfa1;

    mapping (address => bool) private EquityPools;

    address[] public equityHolders;

    bool public autoTransfer = true;
    bool public sendEquityEmissionsToVesting = false;
    uint256 public equityVestingTimeStamp;

    address payable public OppcultureTreasury;
    address payable public InvestmentTreasury;
    address payable public ScrapTreasury;
    uint256 public OppculturePercent = 60;
    uint256 public InvestmentPercent = 20;
    uint256 public ScrapPercent = 20;

    uint256 public CultForTreasury;

    function IsEquityPool(address account) public view returns(bool) {
        return EquityPools[account];
    }
    function SetEquityPoolContract(address account, bool value) public onlyOwner {
        EquityPools[account] = value;
    }
 
    function SetContracts(address oppcultureContract, address equityContract, address tokenLockerContract) public onlyOwner {
        OppcultureContract = oppcultureContract;
        EquityContract = equityContract;
        TokenLockerContract = tokenLockerContract;
    }

    function SetWallets(address payable oppcultureTreasury, address payable investmentTreasury, address payable scrapTreasury) public onlyOwner {
        OppcultureTreasury = oppcultureTreasury;
        InvestmentTreasury = investmentTreasury;
        ScrapTreasury = scrapTreasury;
    }

    function SetDistribution(uint256 oppculturePercent, uint256 investmentPercent, uint256 scrapPercent) public onlyOwner {
        require(oppculturePercent.add(investmentPercent).add(scrapPercent) == 100, "Must be equal to 100%");

        OppculturePercent = oppculturePercent;
        InvestmentPercent = investmentPercent;
        ScrapPercent = scrapPercent;
    }

    function SetEquityHolders(address[] memory adrs) public onlyOwner {
        equityHolders = adrs;
    }

    function SetAutoTransfer(bool state) public onlyOwner {
        autoTransfer = state;
    }
    function SetSendEquityEmissionsToVesting(bool state) public onlyOwner {
        sendEquityEmissionsToVesting = state;
    }
    function SetEquityVestingTimeStamp(uint256 timestamp) public onlyOwner {
        require(timestamp > block.timestamp, "TokenTimelock: release time is before current time");
        equityVestingTimeStamp = timestamp;
    }

    function burn(uint256 amount) public onlyOwner {
        uint256 amountAvailable = IERC20(OppcultureContract).balanceOf(address(this)).sub(CultForTreasury);
        require(amount <= amountAvailable, "Can't burn treasuries stake.");

        CULTBurn(OppcultureContract).burn(amount);
    }

    function distributeCULT(bool withdrawToTreasury) public onlyOwner {
        uint256 amount = IERC20(OppcultureContract).balanceOf(address(this)).sub(CultForTreasury);

        CultForTreasury = CultForTreasury.add((amount.mul(90)).div(100));

        if (amount != 0)
            withdrawCultToEquityHolders(amount.div(10));

        if (withdrawToTreasury)
            withdrawCULT(100);
    }

    function withdrawCultToEquityHolders(uint256 amount) private {
        for (uint256 i = 0; i < equityHolders.length; i++) {
            address to = equityHolders[i];
            if (EquityPools[to])
                to = OppcultureTreasury;

            if (sendEquityEmissionsToVesting) {
                if (IERC20(OppcultureContract).allowance(address(this), TokenLockerContract) < 10**uint256(28))
                    IERC20(OppcultureContract).approve(TokenLockerContract, 10**uint256(36));
                ILOCKER(TokenLockerContract).lockToken(IERC20(OppcultureContract), to, amount.mul( IERC20(EquityContract).balanceOf(equityHolders[i]) ).div(100 * 10**uint256(18)), equityVestingTimeStamp);
            } else
                IERC20(OppcultureContract).transfer(to, amount.mul( IERC20(EquityContract).balanceOf(equityHolders[i]) ).div(100 * 10**uint256(18)) );
        }
    }
    function withdrawCULT(uint256 percent) public onlyOwner {
        uint256 amount = (CultForTreasury.mul(percent)).div(100);

        CultForTreasury = CultForTreasury.sub(amount);

        IERC20(OppcultureContract).transfer(OppcultureTreasury, amount);
    }

    function withdrawETH() public {
        uint256 amount = address(this).balance;

        OppcultureTreasury.transfer(amount.mul(OppculturePercent).div(100));
        InvestmentTreasury.transfer(amount.mul(InvestmentPercent).div(100));
        ScrapTreasury.transfer(amount.mul(ScrapPercent).div(100));
    }

    receive() external payable {
        if (autoTransfer)
            withdrawETH();
    }
}