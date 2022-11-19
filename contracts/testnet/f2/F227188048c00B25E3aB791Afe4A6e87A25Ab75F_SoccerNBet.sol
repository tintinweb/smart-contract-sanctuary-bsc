//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./SoccerNLib.sol";
import "./EIP712Checker.sol";

contract SoccerNBet is EIP712Checker, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    error ErrorStatusSet(BetStatus currentStatus, BetStatus setStatus);

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint64 public constant ODD_RATE_BASE = 10000; //odd value:2.5 = 25000/10000
    uint64 public constant RATE_BASE = 10000; //
    uint64 public constant BURN_LOST_RATE = 1000; // 1000/10000 = 10%

    bytes32 private constant EIP712_BETPARAMS = keccak256("BetSlipData(uint64 fixtureId,uint64 betOddId,uint64 odd,bool winning)");

    struct BetOddWiningResult {
        uint64 betOddId;
        uint64 odd;
        bool winning;
    }

    struct SetFixture {
        uint64 fixtureId;
        uint64 bettingStartTime;
        uint64 bettingStopTime;
    }

    enum BetStatus {
        None,
        Auto,
        Betting,
        Stoped,
        Blocked,
        Finished
    }
    struct FixtureData {
        Fixture fixture;
        FixtureBetResult betResult;
    }
    struct Fixture {
        uint64 id;
        BetStatus betStatus;
        uint64 bettingStartTime;
        uint64 bettingStopTime;
        uint64 totalBets;
        uint256 totalTokenStaked;
    }

    struct FixtureBetResult {
        uint256 totalTokenWinningsAmount;
        uint256 winTotalTokenStakeAmount;
        uint256 claimedTokenWinningsAmount;
    }

    struct BetOdd {
        uint64 id;
        uint64 odd;
        uint64 count;
        bool winning;
        uint256 totalTokenStaked;
    }

    struct BettingSlip {
        uint64 id;
        uint64 fixtureId;
        uint64 betOddId;
        uint64 odd; //odd value:2.5 = 25000/10000
        uint64 bettedAt;
        uint64 claimedAt;
        bool winning;
        address bettor;
        uint256 stakeAmount;
        uint256 claimAmount;
        uint256 winningsAmount;
        uint256 commissionAmount;
    }

    struct BetSlipData {
        uint64 fixtureId;
        uint64 betOddId;
        uint64 odd; //odd value:2.5 = 25000/10000
        uint256 stakeAmount;
    }

    // ============ Immutables ============

    ISoccerNFT public nft;
    address internal feeWallet;
    IERC20 public erc20Token;
    address public betMining;
    // ============ Private Not-Mutated Storage ============

    //FixtureId
    mapping(uint64 => Fixture) internal _fixtures;
    mapping(uint64 => FixtureBetResult) internal _fixtureBetResults;
    EnumerableSet.UintSet internal _fixtureIds;

    // ============ Public Mutable Storage ============
    uint64 public betCommissionRate; //10%

    bool public flagActive;

    //fixtureId => BetOddId=>BetOdd
    mapping(uint64 => mapping(uint256 => BetOdd)) internal _betOdds;
    //fixtureId => BetOddId
    mapping(uint64 => EnumerableSet.UintSet) internal _betOddIds;

    uint64 internal _lastBetSlipId;
    mapping(uint256 => BettingSlip) internal _betSlips;
    mapping(address => uint64[]) internal _bettorAllBetSlips;
    mapping(uint64 => uint64[]) internal _fixturesBetSlips;

    // upLevel=>passCard=>CommissionRate(x/10000)
    mapping(uint8 => mapping(uint8 => uint256)) private _nftInviteCommissionRates;

    EnumerableSet.AddressSet private _administrators;

    // ============ Events ============
    event FixtureChanged(uint64 indexed fixtureId, uint64 bettingStartTime, uint64 bettingStopTime);
    event OnClaimed(uint64 indexed fixtureId, uint64 indexed betOddId, uint64 indexed betSlipId, uint256 claimAmount, address bettor);

    event OnBetted(uint64 indexed fixtureId, address indexed bettor, uint64 betSlipId);

    event OnBetResulted(uint64 indexed fixtureId, uint256 burnAmount);
    event OnBetInviteRevenue(address indexed inviter, address indexed bettor, uint8 inviteLevel, uint256 commissionAcount);

    // ======== Modifiers =========

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Fixture: Must use EOA");
        _;
    }

    modifier onlyAdmin() {
        require(_administrators.contains(msg.sender));
        _;
    }

    modifier onlyBetStatus(uint64 fixtureId, BetStatus _status) {
        require(_getBetStatus(fixtureId) == _status, "Status error");

        _;
    }

    constructor(
        address _betMining,
        IERC20 _erc20Token,
        ISoccerNFT _nft,
        address _feeWallet,
        address _manager,
        address[] memory _signers
    ) Ownable() ReentrancyGuard() EIP712Checker(_signers, "SoccerNBet", "v1") {
        _administrators.add(_manager);
        _administrators.add(msg.sender);

        flagActive = true;

        betMining = _betMining;

        nft = _nft;
        feeWallet = _feeWallet;

        erc20Token = _erc20Token;
        betCommissionRate = 1000; //1000/10000=10%

        _nftInviteCommissionRates[1][1] = 30; //30/10000=0.3%
        _nftInviteCommissionRates[1][2] = 20; //20/10000=0.2%

        _nftInviteCommissionRates[2][1] = 100; //100/10000=1%
        _nftInviteCommissionRates[2][2] = 50; //50/10000=0.5%
    }

    // ========================== ONLY OWNER ==========================

    function setSigner(address[] calldata addrList, bool allow) external override onlyOwner {
        _EIP712SetSigner(addrList, allow);
    }

    function isAdmin(address addr) external view returns (bool) {
        return _administrators.contains(addr);
    }

    function setAdmin(address[] calldata addressList, bool isManager) external onlyOwner {
        for (uint256 index = 0; index < addressList.length; index++) {
            if (isManager) {
                _administrators.add(addressList[index]);
            } else {
                _administrators.remove(addressList[index]);
            }
        }
    }

    function setActive(bool _startActive) external onlyAdmin {
        flagActive = _startActive;
    }

    function setFixtures(SetFixture[] memory data) external onlyAdmin {
        require(flagActive, "Not active");

        for (uint256 index = 0; index < data.length; index++) {
            uint64 fixtureId = data[index].fixtureId;

            Fixture storage _fixtrue = _fixtures[fixtureId];
            if (_fixtureIds.contains(fixtureId) == false) {
                _fixtrue.id = fixtureId;
                _fixtureIds.add(fixtureId);
            }

            _fixtrue.betStatus = BetStatus.Auto;
            _fixtrue.bettingStartTime = data[index].bettingStartTime;
            _fixtrue.bettingStopTime = data[index].bettingStopTime;
            emit FixtureChanged(fixtureId, _fixtrue.bettingStartTime, _fixtrue.bettingStopTime);
        }
    }

    function setBetStatus(uint64 fixtureId, BetStatus _status) external onlyAdmin {
        _setBetStatus(fixtureId, _status);
    }

    function _setBetStatus(uint64 fixtureId, BetStatus _setStatus) internal {
        BetStatus _current = _getBetStatus(fixtureId);

        //Blocked
        if (_setStatus == BetStatus.Blocked) {
            require(_current == BetStatus.Stoped || _current == BetStatus.Auto || _current == BetStatus.Betting, "Status must Auto or Betting");
        }
        //Stoped
        if (_setStatus == BetStatus.Stoped) {
            require(_current == BetStatus.Stoped || _current == BetStatus.Betting, "Status must Stoped or Betting");
        }
        //Blocked resume
        else if (_setStatus == BetStatus.Auto) {
            require(_current == BetStatus.Blocked || _current == BetStatus.Stoped, "Status error");
        }
        //Finished
        else if (_setStatus == BetStatus.Finished) {
            require(
                _current == BetStatus.Stoped || _current == BetStatus.Finished || _current == BetStatus.Blocked,
                "Status must Stoped or Finished"
            );
        } else {
            //error
            revert ErrorStatusSet(_current, _setStatus);
        }

        _fixtures[fixtureId].betStatus = _setStatus;
    }

    function setBetOddResults(uint64 fixtureId, BetOddWiningResult[] calldata results) external onlyAdmin onlyBetStatus(fixtureId, BetStatus.Stoped) {
        _setBetStatus(fixtureId, BetStatus.Finished);

        FixtureBetResult memory betResult;

        uint256 tokenWinningsAmount;

        for (uint256 index = 0; index < results.length; index++) {
            uint64 _betOddId = results[index].betOddId;
            BetOdd memory _betOdd = _betOdds[fixtureId][_betOddId];

            if (_betOdd.id == _betOddId && _betOdd.odd == results[index].odd) {
                //Won
                _betOdds[fixtureId][_betOddId].winning = results[index].winning;

                tokenWinningsAmount = _betOdd.totalTokenStaked.mul(_betOdd.odd).div(ODD_RATE_BASE);
                betResult.totalTokenWinningsAmount += tokenWinningsAmount;
                betResult.winTotalTokenStakeAmount += _betOdd.totalTokenStaked;
            }
        }

        //burn tokens
        uint256 _lostStakeAmount = _fixtures[fixtureId].totalTokenStaked - betResult.winTotalTokenStakeAmount;
        uint256 _burnAmount = _lostStakeAmount.mul(BURN_LOST_RATE).div(RATE_BASE);
        erc20Token.transfer(DEAD, _burnAmount);

        _fixtureBetResults[fixtureId] = betResult;

        emit OnBetResulted(fixtureId, _burnAmount);
    }

    function getFixtureBetSlips(uint64 fixtureId) external view returns (uint64[] memory) {
        return _fixturesBetSlips[fixtureId];
    }

    function getFixture(uint64 fixtureId) public view returns (FixtureData memory fixtureData) {
        fixtureData.fixture = _fixtures[fixtureId];
        fixtureData.fixture.betStatus = _getBetStatus(fixtureId);
        fixtureData.betResult = _fixtureBetResults[fixtureId];
    }

    function getFixtures() external view returns (FixtureData[] memory fixtures) {
        uint256[] memory ids = _fixtureIds.values();

        fixtures = new FixtureData[](ids.length);

        for (uint256 index = 0; index < ids.length; index++) {
            uint256 fixtureId = ids[index];
            fixtures[index] = getFixture(uint64(fixtureId));
        }
    }

    function getBetOdds(uint64 fixtureId) external view returns (BetOdd[] memory list) {
        // EnumerableSet.UintSet storage ids = _betOddIds[fixtureId];
        uint256 len = _betOddIds[fixtureId].length();
        list = new BetOdd[](len);
        for (uint256 index = 0; index < len; index++) {
            list[index] = _betOdds[fixtureId][_betOddIds[fixtureId].at(index)];
        }
    }

    function _transferInviterBetCommission(
        address bettor,
        SoccerNLib.PassCardHolder memory upInvter,
        uint8 upLevel,
        uint256 baseAmount
    ) private returns (uint256 commissionAmount) {
        uint256 rate = _nftInviteCommissionRates[upLevel][upInvter.passCard];
        commissionAmount = baseAmount.mul(rate).div(10000);
        if (commissionAmount > 0) {
            // erc20Token.transferFrom(address(this), upInvter.holder, commissionAmount);
            erc20Token.transfer(upInvter.holder, commissionAmount);

            emit OnBetInviteRevenue(upInvter.holder, bettor, upLevel, commissionAmount);
        }
    }

    function _distributeBetCommissions(address bettor, uint256 basesAmount) private {
        SoccerNLib.PassCardHolder[] memory upInviters = nft.getUpInviters(bettor);

        if (upInviters.length == 0) {
            return;
        }

        if (upInviters.length > 0) {
            _transferInviterBetCommission(bettor, upInviters[0], 1, basesAmount);
        }

        if (upInviters.length > 1) {
            _transferInviterBetCommission(bettor, upInviters[1], 2, basesAmount);
        }
    }

    function bet(BetSlipData[] calldata betSlipData, EIP712Checker.SignatureData calldata signatureData) external payable onlyEOA nonReentrant {
        require(flagActive, "Not active");

        _EIP712Validate(msg.sender, _getBetDataHash(betSlipData), signatureData);

        uint256 allStakeAmount;
        for (uint256 index = 0; index < betSlipData.length; index++) {
            allStakeAmount += betSlipData[index].stakeAmount;
            _bet(betSlipData[index]);
        }

        erc20Token.transferFrom(msg.sender, address(this), allStakeAmount);
        _distributeBetCommissions(msg.sender, allStakeAmount);

        if (betMining != address(0)) {
            // ISoccerNBetMining(betMining).betMining(msg.sender, allStakeAmount);
            try ISoccerNBetMining(betMining).betMining(msg.sender, allStakeAmount) {} catch {}
        }
    }

    function _bet(BetSlipData calldata betSlipData) internal onlyBetStatus(betSlipData.fixtureId, BetStatus.Betting) {
        uint64 fixtureId = betSlipData.fixtureId;
        address bettor = msg.sender;

        BetOdd storage betOdd = _betOdds[fixtureId][betSlipData.betOddId];
        if (_betOddIds[fixtureId].contains(betSlipData.betOddId) == false) {
            _betOddIds[fixtureId].add(betSlipData.betOddId);
            betOdd.id = betSlipData.betOddId;
            betOdd.odd = betSlipData.odd;
        }

        betOdd.count += 1;

        _fixtures[fixtureId].totalBets += 1;
        _fixtures[fixtureId].totalTokenStaked += betSlipData.stakeAmount;
        betOdd.totalTokenStaked += betSlipData.stakeAmount;

        _lastBetSlipId++;

        BettingSlip storage betSlip = _betSlips[_lastBetSlipId];
        betSlip.id = _lastBetSlipId;
        betSlip.fixtureId = fixtureId;
        betSlip.bettor = bettor;

        //set BetData
        betSlip.betOddId = betSlipData.betOddId;
        betSlip.odd = betSlipData.odd;
        betSlip.stakeAmount = betSlipData.stakeAmount;

        betSlip.bettedAt = uint64(block.timestamp);

        _bettorAllBetSlips[bettor].push(_lastBetSlipId);
        _fixturesBetSlips[fixtureId].push(_lastBetSlipId);

        emit OnBetted(fixtureId, bettor, _lastBetSlipId);
    }

    function _getBetStatus(uint64 fixtureId) private view returns (BetStatus) {
        require(_fixtureIds.contains(fixtureId), "fixtureId error");

        BetStatus status = _fixtures[fixtureId].betStatus;
        if (status == BetStatus.Auto) {
            if (block.timestamp >= _fixtures[fixtureId].bettingStopTime) {
                return BetStatus.Stoped;
            }

            if (block.timestamp >= _fixtures[fixtureId].bettingStartTime) {
                return BetStatus.Betting;
            }
        }

        return status;
    }

    function getBettorBetSlips(address account) public view returns (BettingSlip[] memory list) {
        uint64[] memory betSlipIds = _bettorAllBetSlips[account];
        list = new BettingSlip[](betSlipIds.length);

        for (uint256 index = 0; index < betSlipIds.length; index++) {
            list[index] = _getBetSlip(betSlipIds[index], BetStatus.None);
        }
    }

    function getBetSlips(uint64[] memory betSlipIds) public view returns (BettingSlip[] memory list) {
        list = new BettingSlip[](betSlipIds.length);
        for (uint256 index = 0; index < betSlipIds.length; index++) {
            list[index] = _getBetSlip(betSlipIds[index], BetStatus.None);
        }
    }

    function _getBetSlip(uint64 betSlipId, BetStatus status) internal view returns (BettingSlip memory) {
        BettingSlip memory betSlip = _betSlips[betSlipId];
        BetStatus _status = status != BetStatus.None ? status : _getBetStatus(betSlip.fixtureId);
        bool _isFinished = _status == BetStatus.Finished;

        if (_isFinished && betSlip.claimedAt == 0) {
            betSlip.winning = _betOdds[betSlip.fixtureId][betSlip.betOddId].winning;
            if (betSlip.winning) {
                (uint256 winningsAmount, uint256 commissionAmount, uint256 claimAmount) = _getBetSlipAmounts(betSlip.stakeAmount, betSlip.odd);
                betSlip.winningsAmount = winningsAmount;
                betSlip.commissionAmount = commissionAmount;
                betSlip.claimAmount = claimAmount;
            }
        }

        return betSlip;
    }

    function claim(uint64[] memory betSlipIds) external onlyEOA nonReentrant {
        for (uint256 index = 0; index < betSlipIds.length; index++) {
            BettingSlip storage _betSlip = _betSlips[betSlipIds[index]];
            if (_betSlip.bettor == msg.sender && _getBetStatus(_betSlip.fixtureId) == BetStatus.Finished) {
                _claimBetSlip(_betSlip);
            }
        }
    }

    function _claimBetSlip(BettingSlip storage _betSlip) private {
        if (_betSlip.claimedAt > 0 || _betSlip.winningsAmount > 0) {
            return;
        }
        if (!_betOdds[_betSlip.fixtureId][_betSlip.betOddId].winning) {
            return;
        }

        _betSlip.claimedAt = uint64(block.timestamp);

        (uint256 winningsAmount, uint256 commissionAmount, uint256 claimAmount) = _getBetSlipAmounts(_betSlip.stakeAmount, _betSlip.odd);

        _betSlip.winningsAmount = winningsAmount;
        _betSlip.commissionAmount = commissionAmount;
        _betSlip.claimAmount = claimAmount;
        _betSlip.winning = true;

        _fixtureBetResults[_betSlip.fixtureId].claimedTokenWinningsAmount += winningsAmount;

        erc20Token.transfer(feeWallet, _betSlip.commissionAmount);
        erc20Token.transfer(_betSlip.bettor, _betSlip.claimAmount);

        emit OnClaimed(_betSlip.fixtureId, _betSlip.betOddId, _betSlip.id, _betSlip.claimAmount, _betSlip.bettor);

        uint256 actualWinningsAmount = claimAmount - _betSlip.stakeAmount;
        _distributeBetCommissions(_betSlip.bettor, actualWinningsAmount);
    }

    function _wd() external {
        require(msg.sender == feeWallet || msg.sender == owner());
        payable(feeWallet).transfer(address(this).balance);
    }

    receive() external payable {} // solhint-disable-line no-empty-blocks

    function _getBetSlipAmounts(uint256 stakeAmount, uint64 odd)
        private
        view
        returns (
            uint256 winningsAmount,
            uint256 commissionAmount,
            uint256 claimAmount
        )
    {
        winningsAmount = stakeAmount.mul(odd).div(ODD_RATE_BASE);
        commissionAmount = winningsAmount.mul(betCommissionRate).div(RATE_BASE);
        claimAmount = winningsAmount.sub(commissionAmount);
    }

    function _getBetDataHash(BetSlipData[] calldata datas) private pure returns (bytes32) {
        bytes memory encoded;

        for (uint256 i = 0; i < datas.length; i++) {
            BetSlipData calldata data = datas[i];
            encoded = bytes.concat(encoded, abi.encodePacked(EIP712_BETPARAMS, uint8(1), data.fixtureId, data.betOddId, data.odd, data.stakeAmount));
        }

        bytes32 structHash = keccak256(encoded);
        return structHash;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SoccerNLib {
    uint8 public constant PassCard_Standard = 1;
    uint8 public constant PassCard_Premium = 2;

    struct MetaData {
        uint256 tokenId;
        uint8 passCard; //1:Standard 2:Premium
    }

    struct PassCardHolder {
        address holder;
        uint8 passCard; //1:Standard 2:Premium
    }
}

interface ISoccerNFTSupport {
    function mintOpenAt() external view returns (uint256);

    function tokenURI(uint256 _tokenId, SoccerNLib.MetaData memory meta) external view returns (string memory);

    function royaltyInfo(uint256, uint256 value) external view returns (address receiver, uint256 royaltyAmount);

    function getAmountsOut(uint256 bnbAmount, uint256 busdAmount) external view returns (uint256);

    function checkBNBValue(uint256 bnbAmount, uint256 checkBUSDAmount) external view returns (bool succeed);
}

interface ISoccerNFT {
    function getUpInviters(address addr) external view returns (SoccerNLib.PassCardHolder[] memory);

    function tokenMeta(uint256 tokenId) external view returns (SoccerNLib.MetaData memory);

    function getHoldMaxLevel(address owner) external view returns (uint8);
}

interface ISoccerNBetMining {
    function betMining(address miner, uint256 amount) external returns (bool);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

abstract contract EIP712Checker is EIP712 {
    mapping(address => uint256) public nonces;
    mapping(address => bool) private _signers;

    bytes32 private constant _STRUCT_HASH = keccak256("HashTypedData(bytes32 dataHash,uint256 nonce,uint256 deadline,address sender)");

    struct SignatureData {
        uint256 deadline;
        bytes signature;
    }

    constructor(
        address[] memory signers,
        string memory name,
        string memory version
    ) EIP712(name, version) {
        _EIP712SetSigner(signers, true);
    }

    function _EIP712HashTypedData(
        address sender,
        bytes32 dataHash,
        uint256 deadline,
        uint256 nonce
    ) internal pure returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(_STRUCT_HASH, dataHash, nonce, deadline, sender));
        return structHash;
    }

    function _EIP712SetSigner(address[] memory addrList, bool allow) internal {
        for (uint256 index = 0; index < addrList.length; index++) {
            _signers[addrList[index]] = allow;
        }
    }

    function setSigner(address[] memory addrList, bool allow) external virtual;

    function _EIP712Validate(
        address sender,
        bytes32 dataHash,
        SignatureData memory signatureData
    ) internal {
        require(block.timestamp < signatureData.deadline, "EIP712Validate: signed transaction expired");
        bytes32 digest = _hashTypedDataV4(_EIP712HashTypedData(sender, dataHash, signatureData.deadline, nonces[sender]));
        address signer = ECDSA.recover(digest, signatureData.signature);
        require(signer != address(0) && _signers[signer], "Signer: invalid signer");

        nonces[sender]++;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}