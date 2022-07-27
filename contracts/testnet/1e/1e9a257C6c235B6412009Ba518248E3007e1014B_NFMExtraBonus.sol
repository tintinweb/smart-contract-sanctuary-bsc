/**
 *Submitted for verification at BscScan.com on 2022-07-26
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

    function _getController() external pure returns (address);

    function _getNFM() external pure returns (address);

    function _getTimer() external pure returns (address);

    function _getSwap() external pure returns (address);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMTIMER
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmTimer {
    function _getExtraBonusAllTime() external view returns (uint256);

    function _getEndExtraBonusAllTime() external view returns (uint256);

    function _getStartTime() external view returns (uint256);

    function _updateExtraBonusAll() external returns (bool);
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
// INFM
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INFM {
    function bonusCheck(address account) external pure returns (uint256);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMSWAP
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmSwap {
    function returnCurrencyArrayLenght() external pure returns (uint256);

    function returnCurrencyArray()
        external
        pure
        returns (address[] memory Array);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// @title NFMBonus.sol
/// @author Fernando Viktor Seidl E-mail: [email protected]
/// @notice This contract regulates the special payments of currencies like WBTC,WBNB, WETH,...to the NFM community
/// @dev This extension regulates a special payout from different currencies like WBTC, WETH,... to the community every 100 days. Payments are
///      made in the form of a transfer and generated by the NfmSwap Protocol and Treasury Vaults. 10% of every realized Swap Event
///      will be send to this contract for distribution.
///
///         INFO:
///         -   Every 100 days, profit distributions are made available to this protocol in various currencies by the treasury and the UV2Pool
///             in different currencies. The profits are generated from Treasury Vaults investments and one-time swaps of the UniswapV2 protocol.
///         -   As soon as the amounts are available, a fee per NFM will be calculated. The calculation is as follows:
///             Amount available for distribution / NFM total supply = X
///         -   The distribution happens automatically during the transaction. As soon as an NFM owner makes a transfer within the bonus window,
///             the bonus will automatically be calculated on his 24 hours NFM balance and credited to his account. The NFM owner is informed about upcoming
///             special payments via the homepage. A prerequisite for participation in the bonus payments is a minimum balance of 150 NFM on the
///             participant's account.
///         -   The currencies to be paid out are based on the NfmUniswapV2 protocol.
///         -   The payout window is set to 24 hours. Every NFM owner who makes a transfer within this time window will automatically have his share
///             credited to his account. All remaining amounts will be partially credited to the staking pool after the end of the event,
///             and another portion will be returned to the treasury for investments.

///           ***All internal smart contracts belonging to the controller are excluded from the PAD check.***
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
contract NFMExtraBonus {
    //include SafeMath
    using SafeMath for uint256;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTROLLER
    OWNER = MSG.SENDER ownership will be handed over to dao
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    address private _Owner;
    INfmController private _Controller;
    address private _SController;

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    _CoinArrLength          => Length of Array 
    _CoinsArray             => Array of accepted coins for bonus payments
    _Index                  => Counter of Swap
    Schalter                => regulates the execution of the swap for the bonus
    CoinProNFM              => Payout Amount for an NFM
    PayoutRule              => Responsible for the withdraw algorithm
    nextcounter             => Savety lock. Cancels further bonus trials after 3 failed attempts 
    _locked                 => Reentrancy Lock
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    uint256 public _CoinArrLength;
    address[] public _CoinsArray;
    uint256 public Index = 0;
    uint256 private Schalter = 0;
    uint256 private CoinProNFM;
    uint256 private PayoutRule = 0;
    uint256 private nextcounter = 0;
    uint256 private _locked = 0;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MAPPINGS
    _wasPaidCheck (Owner address, ending Timestamp of Bonus);
    _updatedCoinBalance (Coin address, Balance uint256 )  //Records full Amount paid.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    mapping(address => uint256) public _wasPaidCheck;
    mapping(address => uint256) public _updatedCoinBalance;
    mapping(address => uint256) public _totalpaid;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTRACT EVENTS
    EBonus(address receiver, address Coin, uint256 amount, uint256 timer);
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    event SBonus(
        address indexed receiver,
        address indexed Coin,
        uint256 amount,
        uint256 timer
    );
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
    reentrancyGuard       => secures the protocol against reentrancy attacks
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
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_updateCurrenciesList() returns (bool);
   This function checks the currencies in the UV2Pool. If the array in the UV2Pool is longer, then update Bonus array
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _updateCurrenciesList() public onlyOwner returns (bool) {
        if (
            INfmSwap(address(_Controller._getSwap()))
                .returnCurrencyArrayLenght() > _CoinArrLength
        ) {
            _CoinsArray = INfmSwap(address(_Controller._getSwap()))
                .returnCurrencyArray();
            _CoinArrLength = _CoinsArray.length;
        }
        return true;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @addCoinToArray(address Coin) returns (bool);
    This function allows you to add more coins as soon as the Uniswap protocol has expired.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function addCoinToArray(address Coin) public onlyOwner returns (bool) {
        if (
            (INfmTimer(address(_Controller._getTimer()))._getStartTime() +
                (3600 * 24 * 30 * 12 * 8)) < block.timestamp
        ) {
            _CoinsArray.push(Coin);
            _CoinArrLength++;
        }
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_updatePayoutBalance(address Coin) returns (bool);
    This function is for the output of the total bonus amount paid out so far in a currency
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _updatePayoutBalance(address Coin, uint256 Amount)
        public
        onlyOwner
        returns (bool)
    {
        _updatedCoinBalance[Coin] += Amount;
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @ _updateIndex() returns (bool);
    This function updates the payout index to the last used index in the swap protocol
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _updateIndex() public onlyOwner returns (bool) {
        Index++;
        if (Index == _CoinArrLength) {
            Index = 0;
        }
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @makeCalc() returns (bool);
    This function is executed once at the beginning of an event. It calculates the bonus amount that is paid out for 1 NFM
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function makeCalc() public virtual onlyOwner returns (bool) {
        //Get actual TotalSupply NFM
        uint256 NFMTotalSupply = IERC20(address(_Controller._getNFM()))
            .totalSupply();
        //Get full Amount of Coin
        uint256 CoinTotal = IERC20(address(_CoinsArray[Index])).balanceOf(
            address(this)
        );
        if (CoinTotal > 0) {
            //Get Coindecimals for calculations
            uint256 CoinDecimals = IERC20(address(_CoinsArray[Index]))
                .decimals();
            if (CoinDecimals < 18) {
                //if smaller than 18 Digits, convert to 18 digits
                CoinTotal = CoinTotal * 10**(18 - CoinDecimals);
            }
            //Calculate how much Coin will receive each NFM.
            uint256 CoinvsNFM = SafeMath.div(
                SafeMath.mul(CoinTotal, 10**18),
                NFMTotalSupply
            );
            if (CoinDecimals < 18) {
                //If coin decimals not equal to 18, return to coin decimals
                CoinvsNFM = SafeMath.div(CoinvsNFM, 10**(18 - CoinDecimals));
            }
            CoinProNFM = CoinvsNFM;
            return true;
        } else {
            //No Bonus available
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_getAmountToPay(address Sender, uint256 Amount) returns (uint256);
    This function calculates the bonus amount to be paid on the sender's balance. The algorithm uses the 24-hour balance 
    as a value.
    The reason for this is to counteract manipulation of newly created accounts and balance shifts that would be used for 
    multiple bonus payments.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getAmountToPay(address Sender)
        internal
        virtual
        returns (uint256)
    {
        uint256 SenderBal = INFM(address(_Controller._getNFM())).bonusCheck(
            address(Sender)
        );
        //Calculate Bonus amount for sender.
        uint256 CoinDecimals = IERC20(address(_CoinsArray[Index])).decimals();
        uint256 CoinEighteen = CoinProNFM;
        if (CoinDecimals < 18) {
            //if smaller than 18 Digits, convert to 18 digits
            CoinEighteen = CoinProNFM * 10**(18 - CoinDecimals);
        }
        //Numbers are in 18 digit format. this produces 10^36 and need to be divided by 10^18
        //This returns a 18 digit format result.
        uint256 PayAmount = SafeMath.div(
            SafeMath.mul(SenderBal, CoinEighteen),
            10**18
        );
        //If coin has fewer digits, then we need to convert the result to coin digits
        // example if Coin is USDC (6 digits format), then result need to be divided by 10^12
        if (CoinDecimals < 18) {
            //if smaller than 18 Digits, convert to Coin digits
            PayAmount = SafeMath.div(PayAmount, 10**(18 - CoinDecimals));
        }
        return PayAmount;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @updateSchalter() returns (bool);
    This function updates the switcher
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function updateSchalter() public onlyOwner returns (bool) {
        Schalter = 0;
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_startBonusLogic() returns (bool);
    This function creates all calculations for the upcoming Bonus once. If no Bonus available, it will return false.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _startBonusLogic() public onlyOwner returns (bool) {
        _updateCurrenciesList();
        _updateIndex();
        if (IERC20(address(_CoinsArray[Index])).balanceOf(address(this)) > 0) {
            makeCalc();
            _totalpaid[_CoinsArray[Index]] += IERC20(
                address(_CoinsArray[Index])
            ).balanceOf(address(this));
            if(nextcounter>0){
                nextcounter=0;
            }
            return true;
        } else {
            nextcounter++;
            return false;
        }
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_getBonus(address Sender) returns (bool);
    This function is responsible for executing the bonus algorithm.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getBonus(address Sender) public onlyOwner reentrancyGuard returns (bool) {
        if (Schalter == 0) {
            if (_startBonusLogic() == true) {
                Schalter = 1;
                return true;
            }else{
                if(nextcounter < 4){
                    return false;
                }else{
                    nextcounter=0;
                    updateSchalter();
                    INfmTimer(address(_Controller._getTimer()))._updateExtraBonusAll();
                    return false;
                }
            
            }
        } else {
            if (CoinProNFM > 0) {
                if (
                    _wasPaidCheck[Sender] !=
                    INfmTimer(address(_Controller._getTimer()))
                        ._getEndExtraBonusAllTime()
                ) {
                    uint256 PayAmount = _getAmountToPay(Sender);
                    _updatePayoutBalance(_CoinsArray[Index], PayAmount);
                    _wasPaidCheck[Sender] = INfmTimer(
                        address(_Controller._getTimer())
                    )._getEndExtraBonusAllTime();
                    IERC20(address(_CoinsArray[Index])).transfer(
                        Sender,
                        PayAmount
                    );
                    emit SBonus(
                        Sender,
                        _CoinsArray[Index],
                        PayAmount,
                        block.timestamp
                    );
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }

    function _returnPayoutRule() public view returns (uint256) {
        return PayoutRule;
    }

    function updatePayoutRule() public onlyOwner returns (bool) {
        if (PayoutRule == 0) {
            PayoutRule = 1;
        } else if (PayoutRule == 1) {
            PayoutRule = 2;
        } else {
            PayoutRule = 0;
        }
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_getWithdraw(address Coin, address To, uint256 amount, bool percent)  returns (bool);
    This function is responsible for the distribution of the remaining bonus payments that have not been redeemed. The remaining 
    balance is split between the staking pool and treasury.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getWithdraw(
        address To,
        uint256 amount,
        bool percent
    ) public onlyOwner returns (bool) {
        if (_CoinsArray.length > 0) {
            uint256 CoinAmount = IERC20(_CoinsArray[Index]).balanceOf(
                address(this)
            );
            if (CoinAmount > 0) {
                if (percent == true) {
                    //makeCalcs on Percentatge
                    uint256 AmountToSend = SafeMath.div(
                        SafeMath.mul(CoinAmount, amount),
                        100
                    );
                    _updatePayoutBalance(_CoinsArray[Index], AmountToSend);
                    IERC20(address(_CoinsArray[Index])).transfer(
                        To,
                        AmountToSend
                    );
                    return true;
                } else {
                    if (amount == 0) {
                        _updatePayoutBalance(_CoinsArray[Index], CoinAmount);
                        IERC20(address(_CoinsArray[Index])).transfer(
                            To,
                            CoinAmount
                        );
                    } else {
                        _updatePayoutBalance(_CoinsArray[Index], amount);
                        IERC20(address(_CoinsArray[Index])).transfer(
                            To,
                            amount
                        );
                    }
                    return true;
                }
            } else {
                return true;
            }
        } else {
            return true;
        }
    }
}