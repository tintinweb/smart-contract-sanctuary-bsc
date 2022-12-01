// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../library/TicketBuyingLibrary.sol";

interface ITicketBuying {
    function buyTicket(
        uint32 tickets,
        bytes calldata emailId,
        TicketBuyingLibrary.TimeType
    ) external payable;

    function getCurrentPhase()
        external
        view
        returns (TicketBuyingLibrary.PhaseNumber);

    function getTotalTicketCount() external view returns (uint64);

    function totalAmountRaisedInBNB() external view returns (uint256);

    function getTotalPrice(
        TicketBuyingLibrary.PhaseNumber phaseNumber,
        uint32 tickets
    ) external view returns (uint256 totalPrice);

    function totalAmountRaisedInUSD() external view returns (uint256);

    function perTicketPriceInBNB(TicketBuyingLibrary.PhaseNumber phaseNumber)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface TicketBuyingEvents {
    event BuyTicketEvent(uint256 totalAmount, uint32 tickets, address userAddress, uint8 phase, uint256 priceOfEachTicketInBNB, bytes email, uint8 timeType);

    event PriceSetter(uint8 phase, uint64 price);
    
    event TimeSetter(uint32[3] startTime, uint32[3] endTime);

    event Phase3TicketSetter(uint64 tickets);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface OracleWrapper {
    function latestAnswer() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

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

    // /**
    //  * @dev Leaves the contract without owner. It will not be possible to call
    //  * `onlyOwner` functions anymore. Can only be called by the current owner.
    //  *
    //  * NOTE: Renouncing ownership will leave the contract without an owner,
    //  * thereby removing any functionality that is only available to the owner.
    //  */
    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(owner, address(0));
    //     owner = address(0);
    // }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library TicketBuyingLibrary {
    enum PhaseNumber {
        Phase1,
        Phase2,
        Phase3
    }

    enum TimeType {
        IST,
        UTC
    }

    struct PhaseDetails {
        uint32 startTime;
        uint32 endTime;
        uint32 ticketSold;
        uint128 price;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.7;

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
pragma solidity ^0.8.14;

import "./library/ReentrancyGuard.sol";
import "./library/Ownable.sol";
import "./library/OracleWrapper.sol";
import "./library/TransferHelper.sol";
import "./library/TicketBuyingLibrary.sol";
import "./interface/ITicketBuying.sol";
import "./interface/TicketBuyingEvents.sol";

contract TicketBuying is
    Ownable,
    ReentrancyGuard,
    ITicketBuying,
    TicketBuyingEvents
{
    TicketBuyingLibrary.PhaseNumber public PhaseNumber;
    TicketBuyingLibrary.TimeType public TimeType;
    TicketBuyingLibrary.PhaseDetails public PhaseDetails;

    uint64 public override getTotalTicketCount;
    uint64 public totalPhase3Tickets;
    address public receiverAddress;
    address BNBtoUSD;
    bool isInititalized;
    uint256 public override totalAmountRaisedInBNB;

    mapping(TicketBuyingLibrary.PhaseNumber => TicketBuyingLibrary.PhaseDetails)
        public phase;

    function initialize(address _receiverAddress, address _ownerAddress)
        public
    {
        require(!isInititalized, "Already initialized");
        _setOwner(_ownerAddress);
        BNBtoUSD = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; //0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE mainnet
        totalPhase3Tickets = 100;
        receiverAddress = _receiverAddress;
        isInititalized = true;
        phase[TicketBuyingLibrary.PhaseNumber.Phase1] = TicketBuyingLibrary
            .PhaseDetails({
                startTime: uint32(block.timestamp),
                endTime: uint32(block.timestamp + 30 minutes),
                ticketSold: 0,
                price: 10 * 10**8
            });

        phase[TicketBuyingLibrary.PhaseNumber.Phase2] = TicketBuyingLibrary
            .PhaseDetails({
                startTime: phase[TicketBuyingLibrary.PhaseNumber.Phase1]
                    .endTime,
                endTime: phase[TicketBuyingLibrary.PhaseNumber.Phase1].endTime +
                    30 minutes,
                ticketSold: 0,
                price: 15 * 10**8
            });

        phase[TicketBuyingLibrary.PhaseNumber.Phase3] = TicketBuyingLibrary
            .PhaseDetails({
                startTime: phase[TicketBuyingLibrary.PhaseNumber.Phase2]
                    .endTime,
                endTime: 0,
                ticketSold: 0,
                price: 40 * 10**8
            });
    }

    receive() external payable {
        TransferHelper.safeTransferETH(receiverAddress, msg.value);
    }

    function buyTicket(
        uint32 _tickets,
        bytes calldata _emailId,
        TicketBuyingLibrary.TimeType _type
    ) external payable override nonReentrant {
        require(
            uint8(_type) == 0 || uint8(_type) == 1,
            "Koopverse: Invalid Time Input"
        );
        require(_tickets > 0, "Koopverse: Invalid Ticket Count Input");
        require(_emailId.length > 0, "Koopverse: Invalid email Input");

        TicketBuyingLibrary.PhaseNumber currentPhase = getCurrentPhase();

        if (currentPhase == TicketBuyingLibrary.PhaseNumber.Phase3) {
            require(
                phase[TicketBuyingLibrary.PhaseNumber.Phase3].ticketSold +
                    _tickets <=
                    totalPhase3Tickets,
                "Koopverse: Limit Exhausted"
            );
        }

        require(
            getTotalPrice(currentPhase, _tickets) <= msg.value,
            "Koopverse: Price Invalid"
        );
        totalAmountRaisedInBNB += msg.value;
        phase[currentPhase].ticketSold += _tickets;
        getTotalTicketCount += _tickets;

        TransferHelper.safeTransferETH(receiverAddress, msg.value);

        emit BuyTicketEvent(
            msg.value,
            _tickets,
            msg.sender,
            uint8(currentPhase),
            perTicketPriceInBNB(currentPhase),
            _emailId,
            uint8(_type)
        );
    }

    function perTicketPriceInBNB(TicketBuyingLibrary.PhaseNumber _phaseNumber)
        public
        view
        override
        returns (uint256 perTicketPrice)
    {
        require(
            uint8(_phaseNumber) >= 0 && uint8(_phaseNumber) < 3,
            "Koopverse: Invalid Phase Input"
        );

        perTicketPrice =
            (phase[_phaseNumber].price * (10**18)) /
            (OracleWrapper(BNBtoUSD).latestAnswer());
    }

    function getTotalPrice(
        TicketBuyingLibrary.PhaseNumber _phaseNumber,
        uint32 _tickets
    ) public view override returns (uint256 _totalPrice) {
        require(
            uint8(_phaseNumber) >= 0 && uint8(_phaseNumber) < 3,
            "Koopverse: Invalid Phase Input"
        );
        _totalPrice = perTicketPriceInBNB(_phaseNumber) * _tickets;
    }

    function totalAmountRaisedInUSD() external view override returns (uint256) {
        return
            (totalAmountRaisedInBNB *
                (OracleWrapper(BNBtoUSD).latestAnswer())) / (10**18);
    }

    function getCurrentPhase()
        public
        view
        override
        returns (TicketBuyingLibrary.PhaseNumber)
    {
        uint256 currentTimeStamp = block.timestamp;
        if (
            currentTimeStamp >=
            phase[TicketBuyingLibrary.PhaseNumber.Phase1].startTime &&
            currentTimeStamp <
            phase[TicketBuyingLibrary.PhaseNumber.Phase1].endTime
        ) return TicketBuyingLibrary.PhaseNumber.Phase1;
        else if (
            currentTimeStamp >=
            phase[TicketBuyingLibrary.PhaseNumber.Phase2].startTime &&
            currentTimeStamp <
            phase[TicketBuyingLibrary.PhaseNumber.Phase2].endTime
        ) return TicketBuyingLibrary.PhaseNumber.Phase2;
        else if (
            currentTimeStamp >=
            phase[TicketBuyingLibrary.PhaseNumber.Phase3].startTime
        ) return TicketBuyingLibrary.PhaseNumber.Phase3;
        else revert("Koopverse: No phase Active");
    }

    function setPrice(
        TicketBuyingLibrary.PhaseNumber _phaseNumber,
        uint64 _price
    ) external onlyOwner {
        require(
            uint8(_phaseNumber) >= 0 && uint8(_phaseNumber) < 3,
            "Koopverse: Invalid Phase Input"
        );
        require(_price > 0, "Koopverse: Enter value greater than 0");
        phase[_phaseNumber].price = _price;

        emit PriceSetter(uint8(_phaseNumber), _price);
    }

    function setStartAndEndTime(
        uint32[3] memory _startTime,
        uint32[3] memory _endTime
    ) external onlyOwner {
        for (uint256 i; i < 3; i++) {
            if (i < 2) {
                require(
                    _startTime[i] < _endTime[i],
                    "Koopverse: Start time should be less than End time"
                );
            }

            phase[TicketBuyingLibrary.PhaseNumber(i)].startTime = _startTime[i];
            phase[TicketBuyingLibrary.PhaseNumber(i)].endTime = _endTime[i];
        }

        require(
            phase[TicketBuyingLibrary.PhaseNumber.Phase1].endTime <=
                phase[TicketBuyingLibrary.PhaseNumber.Phase2].startTime,
            "Koopverse: Invalid Time Entered"
        );
        require(
            phase[TicketBuyingLibrary.PhaseNumber.Phase2].endTime <=
                phase[TicketBuyingLibrary.PhaseNumber.Phase3].startTime,
            "Koopverse: Invalid Time Entered"
        );

        emit TimeSetter(_startTime, _endTime);
    }

    function setTotalPhase3Tickets(uint64 _tickets) external onlyOwner {
        require(_tickets > 0, "Koopverse: Enter value greater than 0");
        totalPhase3Tickets = _tickets;

        emit Phase3TicketSetter(_tickets);
    }

    function setReceiverAddress(address _receiverAddress) external onlyOwner {
        require(
            _receiverAddress != address(0),
            "Koopverse: Zero address passed"
        );
        receiverAddress = _receiverAddress;
    }
}