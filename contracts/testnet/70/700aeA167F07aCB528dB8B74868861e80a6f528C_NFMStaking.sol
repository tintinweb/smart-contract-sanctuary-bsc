/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// LIBRARIES
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// SAFEMATH its a Openzeppelin Lib. Check out for more info @ https://docs.openzeppelin.com/contracts/2.x/api/math
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INTERFACES
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMCONTROLLER
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmController {
    function _checkWLSC(address Controller, address Client)
        external
        pure
        returns (bool);

    function _getNFM() external pure returns (address);

    function _getNFMStaking() external pure returns (address);

    function _getNFMStakingTreasuryERC20() external pure returns (address);

    function _getNFMStakingTreasuryETH() external pure returns (address);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMSTAKINGTREASURYERC20
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmStakingTreasuryERC20 {
    function returntime()
        external
        pure
        returns (
            uint256,
            uint256,
            bool
        );

    function updateBalancesStake() external returns (bool);

    function returnDayindex() external view returns (uint256);

    function returnCoinsArray() external view returns (address[] memory arr);

    function returnSummOfReward(
        address Coin,
        uint256 InicialDay,
        uint256 LastDay,
        uint256 Deposit
    ) external view returns (uint256);

    function withdraw(
        address Coin,
        address To,
        uint256 amount,
        bool percent
    ) external returns (bool);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// IERC20
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// @title NFMStaking.sol
/// @author Fernando Viktor Seidl E-mail: [email protected]
/// @notice This contract holds the entire ERC-20 Reserves of the NFM Staking Pool.
/// @dev This extension regulates project Investments.
///
///
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
contract NFMStaking {
    //include SafeMath
    using SafeMath for uint256;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTROLLER
    OWNER = MSG.SENDER ownership will be handed over to dao
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    INfmController private _Controller;
    address private _Owner;
    address private _SController;
    uint256 private _locked = 0;

    //Stores all nfm locked
    uint256 public TotalNFMlocked;
    uint256 public generalIndex;
    //Struct for each deposit
    struct Staker {
        uint256 index;
        uint256 startday;
        uint256 inicialtimestamp;
        uint256 deposittimeDays;
        uint256 amountNFM;
    }

    //Tracks every deposit of an user by genralindex of the user
    mapping(address => mapping(uint256 => Staker)) public userDepositInfo;
    // generalindex of user for tracking deposits.
    mapping(address => uint256[]) public DepositindexStaker;
    //Tracks total deposit of the user address user => totaldepositamount in pool
    mapping(address => uint256) public TotaldepositonStaker;
    //Tracks total deposit on the day => totaldepositamount in pool
    mapping(uint256 => uint256) public Totaldepositperday;
    //generalIndex of userDepositInfo => coin address => true if paid wmatic,wbtc,...
    mapping(uint256 => mapping(address => bool)) public ClaimingConfirmation;

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /* 
    MODIFIER
    onlyOwner       => Only Controller listed Contracts and Owner can interact with this contract.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    modifier onlyOwner() {
        require(
            _Controller._checkWLSC(_SController, msg.sender) == true ||
                _Owner == msg.sender,
            "oO"
        );
        require(msg.sender != address(0), "0A");
        _;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MODIFIER
    reentrancyGuard       => Security against Reentrancy attacks
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    modifier reentrancyGuard() {
        require(_locked == 0);
        _locked = 1;
        _;
        _locked = 0;
    }

    constructor(address Controller) {
        _Owner = msg.sender;
        INfmController Cont = INfmController(Controller);
        _Controller = Cont;
        _SController = Controller;
        Totaldepositperday[0] = 0;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @depositNFM(uint256 Amount, uint256 Period) returns (bool);
    This function is responsible for the Deposit.
    User must approve first the amount before he can deposit into the contract.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function depositNFM(uint256 Amount, uint256 Period) public returns (bool) {
        //GET TIMESTAMP AND DAYCOUNTER FROM STAKING RESERVE
        (uint256 Tc, , bool inUpdate) = INfmStakingTreasuryERC20(
            address(_Controller._getNFMStakingTreasuryERC20())
        ).returntime();
        //IF TIMESTAMP SMALLER THAN BLOCK TIMESTAMP UPDATE TO NEXT DAY AND CHECK BALANCES
        if (Tc < block.timestamp || inUpdate == true) {
            require(
                INfmStakingTreasuryERC20(
                    address(_Controller._getNFMStakingTreasuryERC20())
                ).updateBalancesStake() == true,
                "NU"
            );
        }
        //ONCE UPDATE DONE, PROCEED WITH DEPOSIT
        require(
            IERC20(address(_Controller._getNFM())).transferFrom(
                msg.sender,
                address(this),
                Amount
            ) == true,
            "<A"
        );
        (, uint256 TDC, ) = INfmStakingTreasuryERC20(
            address(_Controller._getNFMStakingTreasuryERC20())
        ).returntime();
        // UPDATE USER INFO STRUCT
        userDepositInfo[msg.sender][generalIndex] = Staker(
            generalIndex,
            TDC,
            block.timestamp,
            Period,
            Amount
        );
        // ADD INDEX TO SENDERS ARRAY
        DepositindexStaker[msg.sender].push(generalIndex);
        // ADD AMOUNT TO STAKERS TOTALDEPOSIT
        TotaldepositonStaker[msg.sender] += Amount;
        TotalNFMlocked += Amount;
        Totaldepositperday[TDC] += Amount;
        generalIndex++;
        return true;
    }

    function checkDurationEnded(uint256 IndexSt) public view returns (bool) {
        if (
            userDepositInfo[msg.sender][IndexSt].inicialtimestamp +
                (300 * userDepositInfo[msg.sender][IndexSt].deposittimeDays) <
            block.timestamp
        ) {
            return true;
        } else {
            return false;
        }
    }

    function returnTotallocked() public view returns (uint256) {
        return TotalNFMlocked;
    }

    function returnTotallockedPerDay(uint256 Index)
        public
        view
        returns (uint256)
    {
        return Totaldepositperday[Index];
    }

    function claimreward(uint256 Index) public reentrancyGuard returns (bool) {
        require(checkDurationEnded(Index) == true, "NT");
        require(
            ClaimingConfirmation[Index][address(_Controller._getNFM())] != true,
            "IC"
        );
        address[] memory curr = INfmStakingTreasuryERC20(
            address(_Controller._getNFMStakingTreasuryERC20())
        ).returnCoinsArray();
        uint256[] memory RewardsToPay;
        uint256 i;
        for (i = 0; i < curr.length; i++) {
            RewardsToPay[i] = INfmStakingTreasuryERC20(
                address(_Controller._getNFMStakingTreasuryERC20())
            ).returnSummOfReward(
                    curr[i],
                    userDepositInfo[msg.sender][Index].startday,
                    userDepositInfo[msg.sender][Index].deposittimeDays,
                    userDepositInfo[msg.sender][Index].amountNFM
                );
        }
        for (i = 0; i < curr.length; i++) {
            if (RewardsToPay[i] > 0) {
                if (
                    INfmStakingTreasuryERC20(
                        address(_Controller._getNFMStakingTreasuryERC20())
                    ).withdraw(curr[i], msg.sender, RewardsToPay[i], false) ==
                    true
                ) {
                    ClaimingConfirmation[Index][curr[i]] = true;
                }
            }
        }
        TotalNFMlocked -= userDepositInfo[msg.sender][Index].amountNFM;
        TotaldepositonStaker[msg.sender] -= userDepositInfo[msg.sender][Index]
            .amountNFM;
        require(
            IERC20(address(_Controller._getNFM())).transfer(
                msg.sender,
                userDepositInfo[msg.sender][Index].amountNFM
            ) == true,
            "FT"
        );

        return true;
    }
}