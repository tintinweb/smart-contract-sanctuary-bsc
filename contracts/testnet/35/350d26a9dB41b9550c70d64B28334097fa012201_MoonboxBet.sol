// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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
     * by making the `nonReentrant` function external, and making it call a
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

pragma solidity 0.7.5;

import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract MoonboxBet is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    struct BetResult {
        bool enable;
        uint8 result;
    }

    struct Bet {
        string betId;
        uint256 fee;
        uint256 refFee;
        uint256 totalBetAmount;
        uint256 totalRefAmount;
        uint256 claimAmount;
        bool feeClaim;
        uint256 result;
        uint256 status; //1: opening, 2: cancelled, 3: finish
        bool enable;
        mapping(uint256 => uint256) rAmounts;
        mapping(address => Player) players;
        mapping(address => Referral) referrals;
    }

    struct Player {
        uint256 amount;
        uint256 result;
        bool claim;
        address ref;
    }

    struct Referral {
        uint256 amount;
        bool claim;
    }

    uint256 public serviceFee = 50;
    uint256 public refFee = 10;
    uint256 public denominator = 1000;
    uint256 public minBetAmountInBNB = 0.1 * 10**18;
    uint256 public penaltyCancel = 900;

    address feeReceiver;
    mapping(string => Bet) public _bets;

    constructor(address _feeReceiver) {
        feeReceiver = _feeReceiver;
    }

    function createBet(string memory betId) external nonReentrant onlyOwner {
        Bet storage _bet = _bets[betId];
        require(_bet.enable, "Bet created");

        _bets[betId].betId = betId;
        _bets[betId].fee = serviceFee;
        _bets[betId].refFee = refFee;
        _bets[betId].enable = true;
        _bets[betId].status = 1;

        emit CreateBet(betId, serviceFee);
    }

    function finishBet(string memory betId, uint256 result) external onlyOwner {
        Bet storage _bet = _bets[betId];
        require(_bet.enable == true, "Not found");
        require(_bet.status == 1, "Finished");

        _bets[betId].result = result;
        if (
            _bet.rAmounts[result] == 0 ||
            _bet.rAmounts[result] == _bet.totalBetAmount
        ) {
            _bet.status = 2;
        } else {
            _bet.status = 3;
        }
        emit FinishBet(betId, result);
    }

    function placeBet(
        string memory _betId,
        uint256 result,
        address ref
    ) external payable nonReentrant {
        uint256 amount = msg.value;
        require(amount >= minBetAmountInBNB, "Min amount");
        require(result > 0, "Invalid result");

        Bet storage _bet = _bets[_betId];
        require(_bet.enable == true, "Not found");
        require(_bet.status == 1, "Finished");
        require(_bet.players[msg.sender].result == result, "Cancel first");
        require(_bet.players[msg.sender].amount == 0, "Exist place bet");

        _bet.players[msg.sender] = Player(
            _bet.players[msg.sender].amount.add(amount),
            result,
            false,
            ref
        );
        _bet.totalBetAmount = _bet.totalBetAmount.add(amount);
        _bet.rAmounts[result] = _bet.rAmounts[result].add(amount);
        if (ref != address(0)) {
            _bet.referrals[ref].amount = _bet.referrals[ref].amount.add(amount);
            _bet.totalRefAmount = _bet.totalRefAmount.add(amount);
        }
        emit PlaceBet(_betId, msg.sender, amount, result);
    }

    function cancelPlaceBet(string memory _betId) external nonReentrant {
        Bet storage _bet = _bets[_betId];
        require(_bet.enable == true, "Not found");
        require(_bet.status == 1, "Finished");

        uint256 amount = _bet.players[msg.sender].amount;
        require(amount > 0, "Place bet not exist");
        uint256 refundAmount = amount.mul(penaltyCancel).div(denominator);
        uint256 feeAmount = amount.sub(refundAmount);
        _bet.totalBetAmount = _bet.totalBetAmount.sub(amount);
        _bet.rAmounts[_bet.players[msg.sender].result] = _bet
            .rAmounts[_bet.players[msg.sender].result]
            .sub(amount);
        _bet.players[msg.sender].amount = 0;
        address ref = _bet.players[msg.sender].ref;
        if (ref != address(0)) {
            _bet.referrals[ref].amount = _bet.referrals[ref].amount.sub(amount);
            _bet.totalRefAmount = _bet.totalRefAmount.sub(amount);
        }

        (bool success, ) = payable(msg.sender).call{
            value: refundAmount,
            gas: 30000
        }("");
        require(success, "Failt refund");
        (success, ) = payable(feeReceiver).call{value: feeAmount, gas: 30000}(
            ""
        );
        require(success, "Failt send fee");
        emit CancelPlayerBet(_betId, msg.sender, refundAmount, feeAmount);
    }

    function claimBet(string memory _betId) external nonReentrant {
        Bet storage _bet = _bets[_betId];
        require(_bet.enable == true, "Not found");
        require(_bet.status == 2 || _bet.status == 3, "Not finish");

        Player memory player = _bet.players[msg.sender];
        require(player.amount > 0, "Not bet");
        require(!player.claim, "Claimed");

        uint256 claimAmount;
        if (_bet.status == 3) {
            require(player.result == _bet.result, "Not win");
            uint256 claimRate = calcWinRate(_betId);
            claimAmount = player.amount.mul(claimRate).div(denominator);
        } else {
            claimAmount = player.amount;
        }

        _bets[_betId].players[msg.sender].claim = true;
        _bets[_betId].claimAmount = _bets[_betId].claimAmount.add(claimAmount);
        (bool success, ) = payable(msg.sender).call{
            value: claimAmount,
            gas: 30000
        }("");
        require(success, "ERROR");

        emit ClaimBet(_betId, msg.sender, player.amount, claimAmount);
    }

    function claimRef(string memory _betId) external nonReentrant {
        Bet storage _bet = _bets[_betId];
        require(_bet.enable == true, "Not found");
        require(_bet.status == 2 || _bet.status == 3, "Not finish");

        Referral memory referral = _bet.referrals[msg.sender];
        require(referral.amount > 0, "Not ref");
        require(!referral.claim, "Claimed");

        uint256 claimAmount;
        if (_bet.status == 3) {
            claimAmount = referral.amount.mul(_bet.refFee).div(denominator);
        } else {
            revert("Bet cancelled");
        }

        _bets[_betId].referrals[msg.sender].claim = true;
        (bool success, ) = payable(msg.sender).call{
            value: claimAmount,
            gas: 30000
        }("");
        require(success, "ERROR");

        emit ClaimRef(_betId, msg.sender, claimAmount);
    }

    function claimFee(string memory _betId) external nonReentrant onlyOwner {
        Bet storage _bet = _bets[_betId];
        require(_bet.enable == true, "Not found");
        require(_bet.status == 3, "Not finish");
        require(!_bet.feeClaim, "Claimed");

        uint256 betResult = _bet.result;
        uint256 amountTakeFee = _bet.totalBetAmount - _bet.rAmounts[betResult];
        require(amountTakeFee > 0 && betResult > 0, "Nothing to claim");

        uint256 feeAmount = amountTakeFee.mul(_bet.fee).div(denominator);
        _bets[_betId].feeClaim = true;

        (bool success, ) = payable(feeReceiver).call{
            value: feeAmount,
            gas: 30000
        }("");
        require(success, "ERROR");
        emit ClaimFee(_betId, feeAmount);
    }

    function calcWinRate(string memory _betId) public view returns (uint256) {
        Bet storage _bet = _bets[_betId];
        uint256 resultAmount = _bet.rAmounts[_bet.result];
        if (resultAmount == 0 || _bet.totalBetAmount == resultAmount) return 1;

        uint256 totalRefFee = _bet.totalRefAmount.mul(_bet.refFee).div(
            denominator
        );
        uint256 total = _bet.totalBetAmount.sub(resultAmount);
        uint256 rateWithoutFee = denominator.sub(_bet.fee);
        return
            (
                resultAmount.add(
                    (total.mul(rateWithoutFee).div(denominator)).sub(
                        totalRefFee
                    )
                )
            ).mul(denominator).div(resultAmount);
    }

    function setServiceFee(uint256 _serviceFee) external onlyOwner {
        serviceFee = _serviceFee;
    }

    function setRefFee(uint256 _refFee) external onlyOwner {
        refFee = _refFee;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = _feeReceiver;
    }

    function setMinBetAmountInBNB(uint256 value) external onlyOwner {
        minBetAmountInBNB = value;
    }

    function setPenaltyCancel(uint256 _penaltyCancel) external onlyOwner {
        require(_penaltyCancel <= 500, "Max 50%");
        penaltyCancel = _penaltyCancel;
    }

    event CreateBet(string betId, uint256 fee);

    event FinishBet(string betId, uint256 result);

    event PlaceBet(
        string betId,
        address bettor,
        uint256 amount,
        uint256 result
    );

    event CancelPlayerBet(
        string betId,
        address bettor,
        uint256 refund,
        uint256 fee
    );

    event ClaimBet(
        string betId,
        address bettor,
        uint256 amount,
        uint256 winAmount
    );

    event ClaimRef(string betId, address ref, uint256 amount);

    event ClaimFee(string betId, uint256 feeAmount);
}