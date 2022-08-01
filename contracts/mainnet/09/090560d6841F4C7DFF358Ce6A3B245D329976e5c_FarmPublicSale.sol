// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ReentrancyGuard.sol";
import "./TransferHelper.sol";
import "./Ownable.sol";

interface OracleWrapper {
    function latestAnswer() external view returns (uint128);
}

interface Token {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract FarmPublicSale is Ownable, ReentrancyGuard {
    uint256 public totalTokenSold;
    uint256 public totalTokenSoldUSD;
    uint128 public decimalsValue;
    uint8 public totalPhases;
    uint8 public defaultPhase;
    address public tokenAddress;

    // Binance Chain
    address public BNBOracleAddress =
        0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
    address public BUSDOracleAddress =
        0xcBb98864Ef56E9042e7d2efef76141f15731B82f;
    address public BUSDAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    address public receiverAddress = 0x98034A034d15014a9400a0865A4CfF915449E279;

    /* ============= STRUCT SECTION ============= */

    // Stores instances of Phases
    struct PhaseInfo {
        uint256 tokenSold;
        uint256 tokenLimit;
        uint32 startTimestamp;
        uint32 expirationTimestamp;
        uint32 price; //10**2
        bool isComplete;
    }
    mapping(uint8 => PhaseInfo) public phaseInfo;

    /* ============= EVENT SECTION ============= */

    // Emits when tokens are bought
    event TokensBought(
        uint256 buyAmount,
        uint256 noOfTokens,
        uint256 timestamp,
        uint32 price,
        uint8 phase,
        uint8 tokenType,
        address userAddress
    );

    /* ============= CONSTRUCTOR SECTION ============= */
    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        decimalsValue = uint128(10**Token(tokenAddress).decimals());
        uint32 currentTime= uint32(block.timestamp);
        defaultPhase = 1;
        totalPhases = 3;
        phaseInfo[1] = PhaseInfo({
            tokenLimit: 5_000 * decimalsValue,
            tokenSold: 0,
            startTimestamp: currentTime,
            expirationTimestamp: 1659916799,
            price: 50, // 1$ = 10^2
            isComplete: false
        });
        phaseInfo[2] = PhaseInfo({
            tokenLimit: 3_995_000 * decimalsValue,
            tokenSold: 0,
            startTimestamp: 1661126400,
            expirationTimestamp: 1663977599,
            price: 50, // 1$ = 10^2
            isComplete: false
        });

        phaseInfo[3] = PhaseInfo({
            tokenLimit: 20_000_000 * decimalsValue,
            tokenSold: 0,
            startTimestamp: 1667433600,
            expirationTimestamp: 1670111999,
            price: 70,
            isComplete: false
        });
    }

    /* ============= BUY TOKENS SECTION ============= */

    function buyTokens(uint8 _type, uint256 _busdAmount)
        public
        payable
        nonReentrant
    {
        //_type=1 for BNB and type =2 for BUSD
        require(
            block.timestamp < phaseInfo[totalPhases].expirationTimestamp,
            "Buying Phases are over"
        );
        uint256 buyAmount;

        if (_type == 1) {
            buyAmount = msg.value;
        } else {
            buyAmount = _busdAmount;

            // Balance Check
            require(
                (Token(BUSDAddress).balanceOf(msg.sender)) >= buyAmount,
                "check your balance."
            );

            // Allowance Check
            require(
                Token(BUSDAddress).allowance(msg.sender, address(this)) >=
                    buyAmount,
                "Approve BUSD."
            );
        }

        // Zero value not possible
        require(buyAmount > 0, "Zero value is not possible");

        // Calculates token amount
        (
            uint256 _tokenAmount,
            uint8 _phaseValue,
            uint256 _amountGivenInUsd
        ) = calculateTokens(_type, buyAmount);

        setPhaseInfo(_tokenAmount, defaultPhase);
        totalTokenSoldUSD += _amountGivenInUsd;
        totalTokenSold += _tokenAmount;
        defaultPhase = _phaseValue;

        // Transfers the tokens bought to the user
        TransferHelper.safeTransfer(tokenAddress, msg.sender, _tokenAmount);

        // Sending the amount to the receiver address
        if (_type == 1) {
            TransferHelper.safeTransferETH(receiverAddress, msg.value);
        } else {
            TransferHelper.safeTransferFrom(
                BUSDAddress,
                msg.sender,
                receiverAddress,
                buyAmount
            );
        }
        // Emits event
        emit TokensBought(
            buyAmount,
            _tokenAmount,
            block.timestamp,
            phaseInfo[defaultPhase].price,
            defaultPhase,
            _type,
            msg.sender
        );
    }

    function _calculateUserTransferTokens(uint256 _amount, uint256 _share)
        internal
        pure
        returns (uint256)
    {
        return (_share * _amount) / 10**4;
    }

    /* ============= TOKEN CALCULATION SECTION ============= */
    // Calculates Tokens
    function calculateTokens(uint8 _type, uint256 _amount)
        public
        view
        returns (
            uint256,
            uint8,
            uint256
        )
    {
        (uint256 _amountToUSD, uint256 _typeDecimal) = cryptoValues(_type);
        uint256 _amountGivenInUsd = ((_amount * _amountToUSD) / _typeDecimal);
        (uint256 _tokenAmount, uint8 _phaseValue) = calculateTokensInternal(
            _amountGivenInUsd,
            defaultPhase,
            0
        );
        return (_tokenAmount, _phaseValue, _amountGivenInUsd);
    }

    // Internal Function to calculate tokens
    function calculateTokensInternal(
        uint256 _amount,
        uint8 _phaseNo,
        uint256 _previousTokens
    ) internal view returns (uint256, uint8) {
        // Phases cannot exceed totalPhases
        require(
            _phaseNo <= totalPhases,
            "Not enough tokens in the contract or Phase expired"
        );

        PhaseInfo memory pInfo = phaseInfo[_phaseNo];

        if (block.timestamp < pInfo.expirationTimestamp) {
            require(
                uint32(block.timestamp) > pInfo.startTimestamp,
                "Phase has not started yet"
            );

            // If phase is still going on
            uint256 _tokensAmount = tokensUserWillGet(_amount, pInfo.price);

            uint256 _tokensLeftToSell = (pInfo.tokenLimit + _previousTokens) -
                pInfo.tokenSold;

            require(
                _tokensLeftToSell >= _tokensAmount,
                "Insufficient tokens available in phase"
            );
            return (_tokensAmount, _phaseNo);
        } else {
            // we neeed to remove this line check with shubham
            // if its a new phase
            uint256 _remainingTokens = pInfo.tokenLimit - pInfo.tokenSold;
            return
                calculateTokensInternal(
                    _amount,
                    _phaseNo + 1,
                    _remainingTokens + _previousTokens
                );
        }
    }

    // Tokens user will get according to the price
    function tokensUserWillGet(uint256 _amount, uint32 _price)
        internal
        view
        returns (uint256)
    {
        return ((_amount * decimalsValue * 10**2) /
            ((10**8) * uint256(_price)));
    }

    // Returns the crypto values used
    function cryptoValues(uint8 _type)
        internal
        view
        returns (uint256, uint256)
    {
        uint128 _amountToUsd;
        uint128 _decimalValue;

        if (_type == 1) {
            _amountToUsd = OracleWrapper(BNBOracleAddress).latestAnswer();
            _decimalValue = 10**18;
        } else if (_type == 2) {
            _amountToUsd = OracleWrapper(BUSDOracleAddress).latestAnswer();
            _decimalValue = uint128(10**Token(BUSDAddress).decimals());
        }
        return (_amountToUsd, _decimalValue);
    }

    /* ============= SETS PHASE INFO SECTION ============= */

    // Updates phase struct instances according to the new tokens bought
    function setPhaseInfo(uint256 _totalTokens, uint8 _phase) internal {
        require(
            _phase <= (totalPhases),
            "Not enough tokens in the contract or Phase expired"
        );
        PhaseInfo storage pInfo = phaseInfo[_phase];

        if (block.timestamp < pInfo.expirationTimestamp) {
            // Case 1: Tokens left in the current phase are more than the tokens bought
            if ((pInfo.tokenLimit - pInfo.tokenSold) > _totalTokens) {
                pInfo.tokenSold += _totalTokens;
            }
            // Case 2: Tokens left in the current phase are equal to the tokens bought
            else if ((pInfo.tokenLimit - pInfo.tokenSold) == _totalTokens) {
                pInfo.tokenSold = pInfo.tokenLimit;
                pInfo.isComplete = true;
            }
            // Case 3: Tokens left in the current phase are less than the tokens bought (Recursion)
            else {
                uint256 _leftTokens = _totalTokens -
                    (pInfo.tokenLimit - pInfo.tokenSold);
                pInfo.tokenSold = pInfo.tokenLimit;
                pInfo.isComplete = true;
                setPhaseInfo(_leftTokens, _phase + 1);
            }
        } else {
            uint256 _remainingTokens = pInfo.tokenLimit - pInfo.tokenSold;
            pInfo.tokenLimit = pInfo.tokenSold;
            pInfo.isComplete = true;

            // Limit of next phase is increased
            phaseInfo[_phase + 1].tokenLimit += _remainingTokens;
            setPhaseInfo(_totalTokens, _phase + 1);
        }
    }

    function transferToReceiverAfterICO() external onlyOwner {
        uint256 _contractBalance = Token(tokenAddress).balanceOf(address(this));

        // Phases should have ended
        require(
            (phaseInfo[totalPhases].expirationTimestamp < block.timestamp),
            "ICO is running."
        );

        // Balance should not already be claimed
        require(_contractBalance > 0, "Already Claimed.");

        // Transfers the left over tokens to the receiver
        TransferHelper.safeTransfer(
            tokenAddress,
            receiverAddress,
            _contractBalance
        );
    }

    /* ============= OTHER FUNCTION SECTION ============= */
    // Updates receiver address
    function updateReceiverAddress(address _receiverAddress)
        external
        onlyOwner
    {
        receiverAddress = _receiverAddress;
    }

    // Updates BUSD Address
    function updateBUSDAddress(address _BUSDAddress) external onlyOwner {
        BUSDAddress = _BUSDAddress;
    }

    // Updates BNB Oracle Address
    function updateBNBOracleAddress(address _BNBOracleAddress)
        external
        onlyOwner
    {
        BNBOracleAddress = _BNBOracleAddress;
    }

    // Updates BUSD Oracle Address
    function updateBUSDOracleAddress(address _BUSDOracleAddress)
        external
        onlyOwner
    {
        BUSDOracleAddress = _BUSDOracleAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}