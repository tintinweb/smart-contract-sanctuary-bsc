/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

//SPDX-License-Identifier:MIT

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
// INFMSTAKING
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmStaking {
    function returnTotallockedPerDay(uint256 Index)
        external
        view
        returns (uint256);
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
/// @title NFMStakingTreasuryERC20.sol
/// @author Fernando Viktor Seidl E-mail: [email protected]
/// @notice This contract holds the entire ERC-20 Reserves of the NFM Staking Pool.
/// @dev This extension regulates project Investments.
///
///
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
contract NFMStakingTreasuryERC20 {
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
    //Counts everyday + 1
    uint256 public TotalDayCount = 0;
    //indicates timestamp for next day
    uint256 public Timecounter;
    //Array of all currencies allowed
    address[] public Currencies;
    //Bool if in Update the true else false
    bool public inUpdate = false;
    //Bool if in Update the true else false
    uint256 public currencyUpdateCounter = 0;
    // Coinaddress => DayCount => Amounttotalavailable for Reward this day Day
    mapping(address => mapping(uint256 => uint256)) public DailyTotalAvailable; //donnerstag = 1 Mio
    // Coinaddress => DayCount => rewardPerDayPer1NFM
    mapping(address => mapping(uint256 => uint256))
        public DailyrewardCoinperNFM; //Zins pro NFM an diesem Tag
    // Coinaddress => Totalsupply of coins all entries - payouts
    mapping(address => uint256) public TotalsupplyCoinsRewardsandNFM; //gesamtguthaben einer währung im vertrag => auszahlungen werden abgezogen Beispiel 1 mio 100000 Auszahlung ergibt 900000
    // Coinaddress => Totalsupply of coins all entries - payouts
    mapping(address => uint256) public TotalRewardsPaid; //Gesamtauszahlungen pro währung

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /* 
    mapping(address => mapping(uint256 => uint256))            => Staker - Daycounter - days to live
    mapping(address => mapping(uint256 => bool))            => Staker - Daycounter - claimed status
    mapping(address => mapping(uint256 => uint256))            => Staker - Daycounter - deposited amount
    mapping(address => mapping(index => Struct[Daycount, days to live, status, amount]))            => Staker - Daycounter - deposited amount

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

    constructor(address Controller) {
        _Owner = msg.sender;
        INfmController Cont = INfmController(Controller);
        _Controller = Cont;
        _SController = Controller;
        Timecounter = block.timestamp + (300 * 3);
        Currencies.push(address(Cont._getNFM()));
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @calculateearned(
        address Curre,
        uint256 amount,
        uint256 reward
    ) returns (uint256);
    This function returns the earned amount
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function calculateearned(
        address Curre,
        uint256 amount,
        uint256 reward
    ) public view returns (uint256) {
        uint256 cdecimal = IERC20(address(Curre)).decimals();
        uint256 Camount = amount;
        uint256 NFMreward = reward;
        if (cdecimal < 18) {
            NFMreward = NFMreward * 10**(18 - cdecimal);
            if (NFMreward == 0) {
                Camount = 0;
            } else {
                Camount = SafeMath.div(
                    SafeMath.mul(Camount, NFMreward),
                    10**18
                );
                Camount = SafeMath.div(Camount, 10**(18 - cdecimal));
            }
        } else {
            if (NFMreward == 0) {
                Camount = 0;
            } else {
                Camount = SafeMath.div(
                    SafeMath.mul(Camount, NFMreward),
                    10**18
                );
            }
        }
        return Camount;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @addCurrency(address Currency) returns (bool);
    This function updates the timestamp, the DayCounter and all balances
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function addCurrency(address Currency) public onlyOwner returns (bool) {
        Currencies.push(Currency);
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returntime() returns (uint256, uint256);
    This function returns the timestamp and the DayCounter
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returntime()
        public
        view
        returns (
            uint256,
            uint256,
            bool
        )
    {
        return (Timecounter, TotalDayCount, inUpdate);
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @updateBalancesStake() returns (bool);
    This function updates the timestamp, the DayCounter and all balances and is executed min once a day on deposits or claims
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function updateBalancesStake() public onlyOwner returns (bool) {
        //Only if Timecounter is smaller than timestamp or in Update equals true update possible
        require(Timecounter < block.timestamp || inUpdate == true, "NT");
        if (Timecounter < block.timestamp) {
            //First update
            TotalDayCount++;
            //add 24 hours to timecounter timestamp
            Timecounter = Timecounter + (300 * 2);
            inUpdate = true;
        }
        uint256 LastDay = INfmStaking(address(_Controller._getNFMStaking()))
            .returnTotallockedPerDay(TotalDayCount - 1);
        //inicialice uint for calculations
        uint256 balanceContract = IERC20(
            address(Currencies[currencyUpdateCounter])
        ).balanceOf(address(this));
        uint256 TotalBalanceMonitored;
        uint256 cdecimal = IERC20(address(Currencies[currencyUpdateCounter]))
            .decimals();
        if (
            balanceContract >
            TotalsupplyCoinsRewardsandNFM[Currencies[currencyUpdateCounter]]
        ) {
            //Update necessary
            if (cdecimal < 18) {
                //Need to be converted to 18 digits
                balanceContract = balanceContract * 10**(18 - cdecimal); //Actual Contract Balance
                TotalBalanceMonitored =
                    TotalsupplyCoinsRewardsandNFM[
                        Currencies[currencyUpdateCounter]
                    ] *
                    10**(18 - cdecimal); //last Balance monitored
                uint256 YesterdayEarnings = calculateearned(
                    Currencies[currencyUpdateCounter],
                    LastDay,
                    DailyrewardCoinperNFM[Currencies[currencyUpdateCounter]][
                        TotalDayCount - 1
                    ]
                ) * 10**(18 - cdecimal); //Zinsen insgesamt vortag
                LastDay = LastDay * 10**(18 - cdecimal); // yesterday deposits
                uint256 ReinvestingPart = SafeMath.sub(
                    DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                        TotalDayCount - 1
                    ] * 10**(18 - cdecimal),
                    YesterdayEarnings
                ); //remaining from yesterday
                DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                    TotalDayCount
                ] = SafeMath.div(
                    SafeMath.add(
                        SafeMath.sub(balanceContract, TotalBalanceMonitored),
                        ReinvestingPart
                    ),
                    10**(18 - cdecimal)
                ); //New dailyTotalAvailable COINFORMAT
                DailyrewardCoinperNFM[Currencies[currencyUpdateCounter]][
                    TotalDayCount
                ] = SafeMath.div(
                    SafeMath.div(
                        SafeMath.mul(
                            SafeMath.mul(
                                DailyTotalAvailable[
                                    Currencies[currencyUpdateCounter]
                                ][TotalDayCount],
                                10**(18 - cdecimal)
                            ),
                            10**18
                        ),
                        IERC20(address(_Controller._getNFM())).totalSupply()
                    ),
                    10**(18 - cdecimal)
                ); //Reward per NFMCOINFORMAT
                TotalsupplyCoinsRewardsandNFM[
                    Currencies[currencyUpdateCounter]
                ] = SafeMath.div(balanceContract, 10**(18 - cdecimal)); //Monitor actual Balance for next update schedule
            } else {
                //no convertion nessesary
                balanceContract = balanceContract; //Actual Contract Balance
                TotalBalanceMonitored = TotalsupplyCoinsRewardsandNFM[
                    Currencies[currencyUpdateCounter]
                ]; //last Balance monitored
                uint256 YesterdayEarnings = calculateearned(
                    Currencies[currencyUpdateCounter],
                    LastDay,
                    DailyrewardCoinperNFM[Currencies[currencyUpdateCounter]][
                        TotalDayCount - 1
                    ]
                ); //Zinsen insgesamt vortag
                LastDay = LastDay; // yesterday deposits
                uint256 ReinvestingPart = SafeMath.sub(
                    DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                        TotalDayCount - 1
                    ],
                    YesterdayEarnings
                ); //remaining from yesterday
                DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                    TotalDayCount
                ] = SafeMath.add(
                    SafeMath.sub(balanceContract, TotalBalanceMonitored),
                    ReinvestingPart
                ); //New dailyTotalAvailable NFMFORMAT
                DailyrewardCoinperNFM[Currencies[currencyUpdateCounter]][
                    TotalDayCount
                ] = SafeMath.div(
                    SafeMath.mul(
                        DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                            TotalDayCount
                        ],
                        10**18
                    ),
                    IERC20(address(_Controller._getNFM())).totalSupply()
                ); //Reward per NFMFORMAT
                TotalsupplyCoinsRewardsandNFM[
                    Currencies[currencyUpdateCounter]
                ] = balanceContract; //Monitor actual Balance for next update schedule
            }

            if (currencyUpdateCounter + 1 == Currencies.length) {
                currencyUpdateCounter = 0;
                inUpdate = false;
            } else {
                currencyUpdateCounter++;
            }
        } else {
            //No update needed
            if (cdecimal < 18) {
                //Need to be converted to 18 digits
                uint256 YesterdayEarnings = calculateearned(
                    Currencies[currencyUpdateCounter],
                    LastDay,
                    DailyrewardCoinperNFM[Currencies[currencyUpdateCounter]][
                        TotalDayCount - 1
                    ]
                ) * 10**(18 - cdecimal); //Zinsen insgesamt vortag
                LastDay = LastDay * 10**(18 - cdecimal); // yesterday deposits
                uint256 ReinvestingPart = SafeMath.sub(
                    DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                        TotalDayCount - 1
                    ] * 10**(18 - cdecimal),
                    YesterdayEarnings
                ); //remaining from yesterday
                DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                    TotalDayCount
                ] = SafeMath.div(ReinvestingPart, 10**(18 - cdecimal)); //New dailyTotalAvailable COINFORMAT
                DailyrewardCoinperNFM[Currencies[currencyUpdateCounter]][
                    TotalDayCount
                ] = SafeMath.div(
                    SafeMath.div(
                        SafeMath.mul(
                            SafeMath.mul(
                                DailyTotalAvailable[
                                    Currencies[currencyUpdateCounter]
                                ][TotalDayCount],
                                10**(18 - cdecimal)
                            ),
                            10**18
                        ),
                        IERC20(address(_Controller._getNFM())).totalSupply()
                    ),
                    10**(18 - cdecimal)
                ); //Reward per NFMCOINFORMAT
            } else {
                //no convertion nessesary
                uint256 YesterdayEarnings = calculateearned(
                    Currencies[currencyUpdateCounter],
                    LastDay,
                    DailyrewardCoinperNFM[Currencies[currencyUpdateCounter]][
                        TotalDayCount - 1
                    ]
                ); //Zinsen insgesamt vortag
                LastDay = LastDay; // yesterday deposits
                uint256 ReinvestingPart = SafeMath.sub(
                    DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                        TotalDayCount - 1
                    ],
                    YesterdayEarnings
                ); //remaining from yesterday
                DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                    TotalDayCount
                ] = ReinvestingPart; //New dailyTotalAvailable NFMFORMAT
                DailyrewardCoinperNFM[Currencies[currencyUpdateCounter]][
                    TotalDayCount
                ] = SafeMath.div(
                    SafeMath.mul(
                        DailyTotalAvailable[Currencies[currencyUpdateCounter]][
                            TotalDayCount
                        ],
                        10**18
                    ),
                    IERC20(address(_Controller._getNFM())).totalSupply()
                ); //Reward per NFMFORMAT
            }
            if (currencyUpdateCounter + 1 == Currencies.length) {
                currencyUpdateCounter = 0;
                inUpdate = false;
            } else {
                currencyUpdateCounter++;
            }
        }

        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returnSecAmount(address Coin) returns (uint256);
    This function returns the amount per second
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returnSecAmount(address Coin) public view returns (uint256) {
        uint256 perSecond = SafeMath.div(
            DailyrewardCoinperNFM[Coin][TotalDayCount],
            300
        );
        return perSecond;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returnCoinsArray() returns (address[] memory Coins);
    This function returns the CoinsArray
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returnCoinsArray() public view returns (address[] memory Coins) {
        return Currencies;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returnCoinsArray() returns (address[] memory Coins);
    This function returns the CoinsArray
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returnSummOfReward(
        address Coin,
        uint256 InicialDay,
        uint256 LastDay,
        uint256 Deposit
    ) public view returns (uint256) {
        //mapping(address => mapping(uint256 => uint256))  public DailyrewardCoinperNFM;
        uint256 Reward = 0;
        uint256 cdecimal = IERC20(address(Coin)).decimals();
        if (cdecimal < 18) {
            for (uint256 i = InicialDay; i < InicialDay + LastDay; i++) {
                Reward += SafeMath.div(
                    SafeMath.mul(
                        (DailyrewardCoinperNFM[Coin][i] * 10**(18 - cdecimal)),
                        Deposit
                    ),
                    10**18
                );
            }
            Reward = SafeMath.div(Reward, 10**(18 - cdecimal));
        } else {
            for (uint256 i = InicialDay; i < InicialDay + LastDay; i++) {
                Reward += DailyrewardCoinperNFM[Coin][i];
            }
        }
        return Reward;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @withdraw(address Coin, address To, uint256 amount, bool percent) returns (bool);
    This function is responsible for the withdraw.
    There are 3 ways to initiate payouts. Either as a fixed amount, the full amount or a percentage of the balance.
    Fixed Amount    =>   Address Coin, Address Receiver, Fixed Amount, false
    Total Amount     =>   Address Coin, Address Receiver, 0, false
    A percentage     =>   Address Coin, Address Receiver, percentage, true
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function withdraw(
        address Coin,
        address To,
        uint256 amount,
        bool percent
    ) public onlyOwner returns (bool) {
        require(To != address(0), "0A");
        uint256 CoinAmount = IERC20(address(Coin)).balanceOf(address(this));
        if (percent == true) {
            //makeCalcs on Percentatge
            uint256 AmountToSend = SafeMath.div(
                SafeMath.mul(CoinAmount, amount),
                100
            );
            TotalsupplyCoinsRewardsandNFM[Coin] -= AmountToSend;
            TotalRewardsPaid[Coin] += AmountToSend;
            IERC20(address(Coin)).transfer(To, AmountToSend);
            return true;
        } else {
            if (amount == 0) {
                TotalsupplyCoinsRewardsandNFM[Coin] -= CoinAmount;
                TotalRewardsPaid[Coin] += CoinAmount;
                IERC20(address(Coin)).transfer(To, CoinAmount);
            } else {
                TotalsupplyCoinsRewardsandNFM[Coin] -= amount;
                TotalRewardsPaid[Coin] += amount;
                IERC20(address(Coin)).transfer(To, amount);
            }
            return true;
        }
    }
}