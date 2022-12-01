// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./interfaces/IERC20.sol";
import "./interfaces/IPancakePair.sol";

import "./interfaces/IMysteryBox.sol";
import "./interfaces/ISeqToken.sol";
import "./interfaces/ISeqNFT.sol";

import "./utils/Randomness.sol";
import "./utils/SafeMath.sol";
import "./utils/TransferHelper.sol";
import "./utils/SeqIdentifier.sol";

contract MysteryBox is IMysteryBox {
    using SafeMath for uint256;

    event Swapped(
        address indexed to,
        uint256 tokens,
        uint256 pieces,
        uint256[] ids
    );

    event Revealed(address indexed to, uint256[] ids);

    event PrizeSent(address indexed to, uint256, uint256);

    event HardwareSwapped(address indexed to, uint32 num, uint128 orderId);

    event RecommendNFT(
        address indexed r,
        address indexed u,
        uint8 indexed ty,
        uint256 id
    );

    event Recommended(address indexed r, address indexed u, uint8 indexed lvl);

    event FeeRecommend(
        address indexed r,
        address u,
        uint256 a,
        uint8 indexed t
    );

    struct User {
        bool basic;
        bool advanced;
        uint8 child;
        uint16 luck;
        uint32 childBasic;
        uint32 childAdvanced;
        address recommender;
    }

    // constants

    address public constant PRIZE_BASE_ADDR = address(1);
    address public constant PRIZE_ADDR = address(2);
    address public constant STORAGE_ADDR = address(6);

    // vars

    mapping(address => User) public users;

    address public router;
    address public usd;
    address public seqToken;
    address public pair;
    ISeqNFT public seqNFT;

    address public presaleAddr;
    address public lockedAddr;

    uint256 public latestPrizeBaseBalance;
    uint256 public latestPrizeBalance;
    address public latestBuyAddr;
    uint256 public latestBuyTime;
    uint256 public firstPrizeBuyTime;

    mapping(address => uint256) public buyPieceDeadlines;
    mapping(address => uint256) public pieceBalance;

    // internal vars

    uint256 _seq1eDecimal;
    uint256 _usd1eDecimal;

    uint256 _unlockedCount = 0;
    uint256 _swappedCount = 0;

    // methods

    constructor(
        address router_,
        address usd_,
        address lockedAddr_,
        address presaleAddr_,
        address seqToken_,
        address seqNFT_
    ) {
        router = router_;
        usd = usd_;
        seqToken = seqToken_;
        pair = ISeqToken(seqToken_).pair();
        seqNFT = ISeqNFT(seqNFT_);
        presaleAddr = presaleAddr_;
        lockedAddr = lockedAddr_;

        _seq1eDecimal = 10**IERC20(seqToken_).decimals();
        _usd1eDecimal = 10**IERC20(usd_).decimals();
    }

    // pub: read

    function getSeq2UsdAmount(uint256 amount) external view returns (uint256) {
        amount = amount.mul(92) / 100; // fee
        return _checkSwap(pair, amount, seqToken, usd);
    }

    function getUsd2SeqAmount(uint256 amount) external view returns (uint256) {
        amount = _checkSwap(pair, amount, usd, seqToken);
        amount = amount.mul(92) / 100; // fee
        return amount;
    }

    function prizePoolBalance() external view returns (uint256) {
        uint256 prizeBaseBalance = IERC20(seqToken).balanceOf(PRIZE_BASE_ADDR);
        uint256 prizeBalance = IERC20(seqToken).balanceOf(PRIZE_ADDR);

        (
        uint256 a,
        address addr,
        uint256 b,
        uint256 c,
        bool res,
        bool isFirst,
        ,
        uint256 buyTime
        ) = _calcPrizeAmount();
        if (res) {
            prizeBaseBalance -= a;
            if (addr == PRIZE_BASE_ADDR) {
                prizeBaseBalance -= b;
            } else {
                prizeBalance -= b;
            }
            prizeBalance -= c;
            prizeBaseBalance += c;
        }

        if (
            ISeqToken(seqToken).swapDay() < _endOfDay(block.timestamp) / 1 days
        ) {
            return prizeBaseBalance + prizeBalance;
        }

        uint256 bt;
        if (isFirst) {
            bt = buyTime;
        } else {
            bt = firstPrizeBuyTime;
        }

        bool isFirstPrize = block.timestamp >= _endOfDay(bt);
        if (isFirstPrize) {
            return prizeBaseBalance + prizeBalance / 5;
        } else {
            return prizeBalance / 5;
        }
    }

    function recommenders(address who)
        public
        view
        override
        returns (address r1, address r2)
    {
        if (who == address(0)) {
            return (r1, r2);
        }

        r1 = users[who].recommender;
        if (r1 == address(0)) {
            return (r1, r2);
        }
        User storage ur1 = users[r1];
        if (!ur1.basic && !ur1.advanced) {
            r1 = address(0);
        }

        r2 = ur1.recommender;
        if (r2 == address(0)) {
            return (r1, r2);
        }
        User storage ur2 = users[r2];
        if (!ur2.basic && !ur2.advanced) {
            r2 = address(0);
        }
    }

    // pub: write

    function manualSendPrize() external {
        _trySendPrize();
    }

    function swapSeqForUsd(uint256 amount) external {
        require(amount > 0, "amount must be greater than 0");
        _trySendPrize();
        _sell(amount);
    }

    function buyBasic() external {
        buyBasic(address(0));
    }

    function buyBasic(address recommender) public {
        return buyBasic(1, recommender);
    }

    function buyBasic(uint8 num, address recommender) public {
        require(num > 0 && num <= 50, "invalid number");

        _trySendPrize();

        // swap token
        uint256 nonce;
        if (ISeqToken(seqToken).isPresale()) {
            nonce = _presaleSwap(28, 15, uint256(num));
        } else {
            nonce = _swap(uint256(num) * 28 * _usd1eDecimal);
            _setLastBuy();
        }

        User storage user = users[msg.sender];
        user.basic = true;

        // luck logic
        uint16 luck = user.luck;
        uint256[] memory ids = new uint256[](num);
        uint256 r = Randomness.pseudoRandomness(nonce % 1024);
        for (uint8 i = 0; i < num; i++) {
            if (luck >= 1000) {
                luck = 0;
                ids[i] = seqNFT.mintProfit(msg.sender);
            } else {
                uint16 rand = uint16(r);
                r >>= 2;
                if (0 <= rand && rand < 28901) {
                    luck += 5;
                } else if (28901 <= rand && rand < 44958) {
                    luck += 25;
                } else if (44958 <= rand && rand < 54591) {
                    luck += 50;
                } else if (54591 <= rand && rand < 59730) {
                    luck += 125;
                } else if (59730 <= rand && rand < 62299) {
                    luck += 250;
                } else if (62299 <= rand && rand < 63583) {
                    luck += 375;
                } else if (63583 <= rand && rand < 64225) {
                    luck += 500;
                } else if (64225 <= rand && rand < 65536) {
                    luck = 0;
                    ids[i] = seqNFT.mintProfit(msg.sender);
                }
            }
        }
        user.luck = luck;

        pieceBalance[msg.sender] += num;

        // recommend logic
        if (recommender != address(0) && user.recommender == address(0)) {
            _recommend(user, 1, recommender);
        }

        emit Swapped(msg.sender, nonce, num, ids);
    }

    function buyAdvanced() external {
        buyAdvanced(address(0));
    }

    function buyAdvanced(address recommender) public {
        return buyAdvanced(1, recommender);
    }

    function buyAdvanced(uint8 num, address recommender) public {
        require(num > 0 && num <= 50, "invalid number");

        _trySendPrize();

        // swap token
        uint256 nonce;
        if (ISeqToken(seqToken).isPresale()) {
            nonce = _presaleSwap(188, 15, uint256(num));
        } else {
            nonce = _swap(uint256(num) * 188 * _usd1eDecimal);
            _setLastBuy();
        }

        User storage user = users[msg.sender];
        user.advanced = true;

        // luck logic
        uint16 luck = user.luck;
        uint256[] memory ids = new uint256[](num);
        uint256 r = Randomness.pseudoRandomness(nonce % 1024);
        for (uint8 i = 0; i < num; i++) {
            if (luck >= 1000) {
                luck = 0;
                ids[i] = seqNFT.mintBonus(msg.sender);
            } else {
                uint16 rand = uint16(r);
                r >>= 2;
                if (0 <= rand && rand < 28312) {
                    luck += 20;
                } else if (28312 <= rand && rand < 47186) {
                    luck += 100;
                } else if (47186 <= rand && rand < 58511) {
                    luck += 200;
                } else if (58511 <= rand && rand < 61656) {
                    luck += 500;
                } else if (61656 <= rand && rand < 62915) {
                    luck += 1000;
                } else if (62915 <= rand && rand < 65536) {
                    luck = 0;
                    ids[i] = seqNFT.mintBonus(msg.sender);
                }
            }
        }
        user.luck = luck;

        pieceBalance[msg.sender] += 2 * num;

        // recommend logic
        if (recommender != address(0) && user.recommender == address(0)) {
            _recommend(user, 2, recommender);
        }

        emit Swapped(msg.sender, nonce, 2 * num, ids);
    }

    function buyGenesis() external {
        buyGenesis(address(0));
    }

    function buyGenesis(address recommender) public {
        _trySendPrize();

        User storage user = users[msg.sender];
        user.advanced = true;

        // swap token
        uint256 nonce;
        if (ISeqToken(seqToken).isPresale()) {
            nonce = _presaleSwap(3000, 15, 1);
        } else {
            nonce = _swap(3000 * _usd1eDecimal);
            _setLastBuy();
        }

        uint256[] memory ids = new uint256[](3);

        ISeqNFT seqNFT_ = seqNFT;
        ids[0] = seqNFT_.mintGenesis(msg.sender);
        ids[1] = seqNFT_.mintProfit(msg.sender);
        ids[2] = seqNFT_.mintBonus(msg.sender);

        // recommend logic
        if (recommender != address(0) && user.recommender == address(0)) {
            _recommend(user, 3, recommender);
        }

        emit Swapped(msg.sender, nonce, 0, ids);
    }

    function buyPiece() external {
        require(block.timestamp > buyPieceDeadlines[msg.sender], "deadline");

        _trySendPrize();

        buyPieceDeadlines[msg.sender] = _endOfDay(block.timestamp);

        _sendPiece(msg.sender, 1);
    }

    function openPiece(uint8 num) external {
        require(num > 0 && num <= 10, "invalid number");

        _trySendPrize();

        pieceBalance[msg.sender] = pieceBalance[msg.sender].sub(num);

        _sendPiece(msg.sender, num);
    }

    function buildP() external {
        buildP(0, 0, 0);
    }

    function buildP(
        uint256 id,
        uint256 id1,
        uint256 id2
    ) public {
        _trySendPrize();
        _rewardOr(msg.sender, 10, 0);
        seqNFT.buildP(msg.sender, id, id1, id2);
    }

    function buildS() external {
        _trySendPrize();
        _rewardOr(msg.sender, 600, 0);
        seqNFT.buildS(msg.sender);
        _swapTokenForNFT(STORAGE_ADDR, msg.sender, 1);
    }

    function buildB() external {
        buildB(0);
    }

    function buildB(uint256 id) public {
        _trySendPrize();
        _rewardOr(msg.sender, 100, 0);
        seqNFT.buildB(msg.sender, id);
    }

    function upgradeProfit(uint256 id0, uint256 id1) external {
        _trySendPrize();

        uint8 code = seqNFT.upgradeProfit(msg.sender, id0, id1);

        if (code == 1) {
            _rewardOr(msg.sender, 300, 1);
        } else if (code == 2) {
            _rewardOr(msg.sender, 300, 1);
        } else if (code == 3) {
            _rewardOr(msg.sender, 600, 1);
        } else {
            revert("invalid token id");
        }
    }

    function swapTokenForNFT() external {
        swapTokenForNFT(1);
    }

    function swapTokenForNFT(uint256 num) public {
        require(num > 0, "invalid number");
        _trySendPrize();
        _swapTokenForNFT(msg.sender, msg.sender, num);
    }

    function swapNFTForToken() external {
        swapNFTForToken(1);
    }

    function swapNFTForToken(uint256 num) public {
        require(num > 0, "invalid number");
        _trySendPrize();
        _swapNFTForToken(num);
    }

    function swapHardware(uint32 num, uint128 orderId) external {
        require(num > 0, "invalid number");
        _trySendPrize();
        seqNFT.burnStorage(msg.sender, num);
        TransferHelper.safeTransferFrom(
            seqToken,
            address(seqNFT),
            0x000000000000000000000000000000000000dEaD,
            uint256(num).mul(1000 * _seq1eDecimal)
        );
        emit HardwareSwapped(msg.sender, num, orderId);
    }

    // pri: read

    function _checkSwap(
        address pair_,
        uint256 amount,
        address tokenA,
        address tokenB
    ) private view returns (uint256) {
        require(amount > 0, "amount must be greater than 0");
        address token0 = tokenA < tokenB ? tokenA : tokenB;
        (uint256 r0, uint256 r1, ) = IPancakeSwapPair(pair_).getReserves();
        (uint256 ri, uint256 ro) = tokenA == token0 ? (r0, r1) : (r1, r0);
        return _getAmountOut(amount, ri, ro);
    }

    function _getAmountOut(
        uint256 amount,
        uint256 reserveIn,
        uint256 reserveOut
    ) private pure returns (uint256) {
        uint256 amountInWithFee = amount.mul(9975); // pancake fee
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        return numerator / denominator;
    }

    function _beginOfDay(uint256 timestamp) private pure returns (uint256) {
        uint256 secs = timestamp % 1 days;
        if (secs < 16 hours) {
            return timestamp - secs - 8 hours;
        } else {
            return timestamp - secs + 16 hours;
        }
    }

    function _endOfDay(uint256 timestamp) private pure returns (uint256) {
        uint256 secs = timestamp % 1 days;
        if (secs < 16 hours) {
            return timestamp - secs + 16 hours;
        } else {
            return timestamp - secs + 40 hours;
        }
    }

    function _prizeType(uint256 cur, uint256 latest)
        private
        pure
        returns (uint8)
    {
        if (latest == 0) {
            return 0;
        } else if (_endOfDay(latest) <= cur) {
            return 2;
        } else if (latest + 5 minutes <= cur) {
            return 1;
        }
        return 0;
    }

    function _calcPrizeAmount()
        private
        view
        returns (
            uint256,
            address,
            uint256,
            uint256,
            bool,
            bool,
            address,
            uint256
        )
    {
        address latestBuyAddr_ = latestBuyAddr;
        if (latestBuyAddr_ == address(0)) {
            return (0, address(0), 0, 0, false, false, address(0), 0);
        }
        uint256 latestBuyTime_ = latestBuyTime;
        {
            uint8 typ = _prizeType(block.timestamp, latestBuyTime_);
            if (typ == 0) {
                return (0, address(0), 0, 0, false, false, address(0), 0);
            }
        }

        bool isFirstPrize = latestBuyTime_ >= _endOfDay(firstPrizeBuyTime);

        uint256 balance = latestPrizeBalance;
        uint256 part1 = balance / 5;
        uint256 part2 = balance - part1;

        address addr = PRIZE_ADDR;
        if (
            ISeqToken(seqToken).swapDay() > _endOfDay(latestBuyTime_) / 1 days
        ) {
            addr = PRIZE_BASE_ADDR;
            part2 = 0;
        }

        balance = 0;
        if (isFirstPrize) {
            balance = latestPrizeBaseBalance;
        }

        return (
            balance,
            addr,
            part1,
            part2,
            true,
            isFirstPrize,
            latestBuyAddr_,
            latestBuyTime_
        );
    }

    function _canUnlock() private view returns (uint256) {
        return
        uint256(2000).mul(ISeqToken(seqToken).presaleDays()) -
        _unlockedCount;
    }

    // pri: write

    function _trySendPrize() private {
        (
            uint256 a,
            address addr,
            uint256 b,
            uint256 c,
            bool isFirst,
            bool res,
            address buyAddr,
            uint256 buyTime
        ) = _calcPrizeAmount();
        if (!res) {
            return;
        }
        if (a > 0) {
            TransferHelper.safeTransferFrom(
                seqToken,
                PRIZE_BASE_ADDR,
                buyAddr,
                a
            );
        }
        if (b > 0) {
            TransferHelper.safeTransferFrom(seqToken, addr, buyAddr, b);
        }
        if (c > 0) {
            TransferHelper.safeTransferFrom(
                seqToken,
                PRIZE_ADDR,
                PRIZE_BASE_ADDR,
                c
            );
        }

        latestBuyAddr = address(0);
        if (isFirst) {
            firstPrizeBuyTime = buyTime;
        }
        emit PrizeSent(buyAddr, buyTime, a + b);
    }

    function _setLastBuy() private {
        latestBuyAddr = msg.sender;
        latestBuyTime = block.timestamp;
        latestPrizeBaseBalance = IERC20(seqToken).balanceOf(PRIZE_BASE_ADDR);
        latestPrizeBalance = IERC20(seqToken).balanceOf(PRIZE_ADDR);
    }

    function _recommend(
        User storage user,
        uint8 lvl,
        address recommender
    ) private {
        if (msg.sender == recommender) {
            return;
        }

        User storage parent = users[recommender];
        {
            address r2 = parent.recommender;
            if (r2 != address(0) && r2 == msg.sender) {
                return;
            }
        }

        user.recommender = recommender;

        // 1.
        pieceBalance[msg.sender] += 1;
        pieceBalance[recommender] += 1;

        // 2.
        ISeqNFT seqNFT_ = seqNFT;
        uint8 state = seqNFT_.genesisState(recommender);
        if (state == 1 || state == 2) {
            if (lvl == 1) {
                parent.childBasic += 1;
            } else if (lvl == 2 || lvl == 3) {
                parent.childAdvanced += 1;
            }

            if (
                (state == 1 &&
                    parent.childAdvanced >= 10 &&
                    parent.childBasic >= 30) ||
                (state == 2 &&
                    parent.childAdvanced >= 5 &&
                    parent.childBasic >= 20)
            ) {
                parent.childBasic = 0;
                parent.childAdvanced = 0;
                seqNFT_.activateGenesis(recommender);
            }
        }

        // 3.
        if (parent.advanced) {
            parent.child = (parent.child + 1) % 30;
            if (parent.child % 3 == 0) {
                emit RecommendNFT(
                    recommender,
                    msg.sender,
                    1,
                    seqNFT_.mintProfit(recommender)
                );
            }
            if (parent.child % 10 == 0) {
                emit RecommendNFT(
                    recommender,
                    msg.sender,
                    2,
                    seqNFT_.mintBonus(recommender)
                );
            }
        }

        emit Recommended(recommender, msg.sender, lvl);
        if (parent.recommender != address(0)) {
            emit Recommended(parent.recommender, msg.sender, lvl + 8);
        }
    }

    function _swapTokenForNFT(
        address who,
        address to,
        uint256 num
    ) private {
        if (who == lockedAddr) {
            _swappedCount += num;
        }
        ISeqNFT seqNFT_ = seqNFT;
        TransferHelper.safeTransferFrom(
            seqToken,
            who,
            address(seqNFT_),
            num.mul(1000 * _seq1eDecimal)
        );
        seqNFT_.mintStorage(to, num);
    }

    function _swapNFTForToken(uint256 num) private {
        if (msg.sender == lockedAddr) {
            require(_canUnlock() + _swappedCount >= num, "can't swap");
            if (num > _swappedCount) {
                _unlockedCount += num - _swappedCount;
                _swappedCount = 0;
            } else {
                _swappedCount -= num;
            }
        }
        ISeqNFT seqNFT_ = seqNFT;
        seqNFT_.burnStorage(msg.sender, num);
        TransferHelper.safeTransferFrom(
            seqToken,
            address(seqNFT_),
            msg.sender,
            num.mul(1000 * _seq1eDecimal)
        );
    }

    function _presaleSwap(
        uint256 amount,
        uint256 extra,
        uint256 num
    ) private returns (uint256) {
        uint256 day = ISeqToken(seqToken).presaleDays();
        uint256 usdAmount = num * amount * _usd1eDecimal;
        uint256 seqAmount = num * (amount + extra - day) * 5 * _seq1eDecimal;

        TransferHelper.safeTransferFrom(
            usd,
            msg.sender,
            presaleAddr,
            usdAmount
        );
        TransferHelper.safeTransferFrom(
            seqToken,
            presaleAddr,
            msg.sender,
            seqAmount
        );
        return seqAmount;
    }

    function _sendPiece(address to, uint8 num) private {
        uint256 r = Randomness.pseudoRandomness(0);
        uint256[] memory ids = new uint256[](num);
        for (uint8 i = 0; i < num; i++) {
            uint16 rand = uint16(r);
            r >>= 2;
            uint256 id;
            if (0 <= rand && rand < 66) {
                if (IERC20(seqToken).balanceOf(STORAGE_ADDR) >= 1000 * _seq1eDecimal) {
                    _swapTokenForNFT(STORAGE_ADDR, to, 1);
                    id = SeqIdentifier.TYPE_S;
                } else {
                    id = seqNFT.mintBonus(to);
                }
            } else if (66 <= rand && rand < 721) {
                id = seqNFT.mintProfit(to);
            } else if (721 <= rand && rand < 787) {
                id = seqNFT.mintBonus(to);
            } else if (787 <= rand && rand < 1377) {
                id = seqNFT.mintPieceS1(to);
            } else if (1377 <= rand && rand < 6620) {
                id = seqNFT.mintPieceS2(to);
            } else if (6620 <= rand && rand < 12518) {
                id = seqNFT.mintPieceS3(to);
            } else if (12518 <= rand && rand < 19072) {
                id = seqNFT.mintPieceS4(to);
            } else if (19072 <= rand && rand < 19662) {
                id = seqNFT.mintPieceB1(to);
            } else if (19662 <= rand && rand < 24905) {
                id = seqNFT.mintPieceB2(to);
            } else if (24905 <= rand && rand < 30148) {
                id = seqNFT.mintPieceB3(to);
            } else if (30148 <= rand && rand < 36702) {
                id = seqNFT.mintPieceB4(to);
            } else if (36702 <= rand && rand < 43256) {
                id = seqNFT.mintPieceB5(to);
            } else if (43256 <= rand && rand < 45877) {
                id = seqNFT.mintPieceP1(to);
            } else if (45877 <= rand && rand < 52431) {
                id = seqNFT.mintPieceP2(to);
            } else if (52431 <= rand && rand < 65536) {
                id = seqNFT.mintPieceP3(to);
            }
            ids[i] = id;
        }

        emit Revealed(to, ids);
    }

    function _rewardOr(
        address who,
        uint256 amount,
        uint8 typ1
    ) private {
        uint256 total = amount.mul(_seq1eDecimal);
        uint256 left = total;

        (address r1, address r2) = recommenders(who);
        if (r1 != address(0)) {
            uint256 tmp;
            if (users[r1].advanced) {
                tmp = total / 5;
            } else {
                tmp = total / 10;
            }
            left -= tmp;
            TransferHelper.safeTransferFrom(seqToken, who, r1, tmp);
            emit FeeRecommend(r1, who, tmp, typ1);
        }
        if (r2 != address(0)) {
            uint256 tmp;
            if (users[r2].advanced) {
                tmp = total / 10;
            } else {
                tmp = total / 20;
            }
            left -= tmp;
            TransferHelper.safeTransferFrom(seqToken, who, r2, tmp);
            emit FeeRecommend(r2, who, tmp, typ1);
        }

        TransferHelper.safeTransferFrom(seqToken, who, address(this), left);
        ISeqToken(seqToken).burnOrBonus();
    }

    function _delegatecall(address target, bytes memory data)
        private
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        if (!success) {
            if (returndata.length == 0) revert();
            assembly {
                revert(add(32, returndata), mload(returndata))
            }
        }
        return returndata;
    }

    function _swap(uint256 amount) private returns (uint256 amountOut) {
        return _pairSwap(amount, usd, seqToken);
    }

    function _sell(uint256 amount) private {
        _pairSwap(amount, seqToken, usd);
    }

    function _pairSwap(
        uint256 amount,
        address from,
        address to
    ) private returns (uint256 amountOut) {
        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = to;

        uint256 b = IERC20(to).balanceOf(msg.sender);
        _delegatecall(
            router,
            abi.encodeWithSelector(
                0x5c11d795,
                amount,
                0,
                path,
                msg.sender,
                block.timestamp
            )
        );
        uint256 a = IERC20(to).balanceOf(msg.sender);
        require(a > b, "balance not increased");
        return a - b;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface IPancakeSwapPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface IMysteryBox {
    function recommenders(address) external view returns (address, address);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.7.6;

library Randomness {
    function pseudoRandomness(uint256 nonce) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp + block.difficulty + block.number,
                        msg.sender,
                        block.coinbase,
                        nonce
                    )
                )
            );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface ISeqNFT {
    function activateGenesis(address who) external;

    function genesisState(address who) external view returns (uint8);

    function genesisTotal() external view returns (uint256);

    function mintGenesis(address to) external returns (uint256);

    function mintBonus(address to) external returns (uint256);

    function mintProfit(address to) external returns (uint256);

    function mintStorage(address to, uint256 count) external;

    function mintPieceS1(address to) external returns (uint256);

    function mintPieceS2(address to) external returns (uint256);

    function mintPieceS3(address to) external returns (uint256);

    function mintPieceS4(address to) external returns (uint256);

    function mintPieceB1(address to) external returns (uint256);

    function mintPieceB2(address to) external returns (uint256);

    function mintPieceB3(address to) external returns (uint256);

    function mintPieceB4(address to) external returns (uint256);

    function mintPieceB5(address to) external returns (uint256);

    function mintPieceP1(address to) external returns (uint256);

    function mintPieceP2(address to) external returns (uint256);

    function mintPieceP3(address to) external returns (uint256);

    function buildS(address to) external;

    function buildB(address to) external;

    function buildB(address to, uint256 id) external;

    function buildP(address to) external;

    function buildP(
        address to,
        uint256 id,
        uint256 id1,
        uint256 id2
    ) external;

    function upgradeProfit(
        address to,
        uint256 id0,
        uint256 id1
    ) external returns (uint8);

    function burnStorage(address owner, uint256 count) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface ISeqToken {
    event FeeSent(address addr, uint256 amount, uint8 kind);
    event FeeRecommend(address indexed rec, address usr, uint256 amount);

    function isPresale() external view returns (bool);

    function presaleDays() external view returns (uint256);

    function swapDay() external view returns (uint256);

    function pair() external view returns (address);

    function burnOrBonus() external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errMsg
    ) internal pure returns (uint256) {
        require(b <= a, errMsg);
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

library SeqIdentifier {
    uint8 public constant INDEX_BITS = 56;

    uint256 public constant TYPE_MASK = uint256(-1) << INDEX_BITS;

    uint256 public constant TYPE_G = uint256(10) << INDEX_BITS;

    uint256 public constant TYPE_S = uint256(20) << INDEX_BITS;
    uint256 public constant TYPE_S1 = uint256(21) << INDEX_BITS;
    uint256 public constant TYPE_S2 = uint256(22) << INDEX_BITS;
    uint256 public constant TYPE_S3 = uint256(23) << INDEX_BITS;
    uint256 public constant TYPE_S4 = uint256(24) << INDEX_BITS;

    uint256 public constant TYPE_B = uint256(30) << INDEX_BITS;
    uint256 public constant TYPE_B1 = uint256(31) << INDEX_BITS;
    uint256 public constant TYPE_B2 = uint256(32) << INDEX_BITS;
    uint256 public constant TYPE_B3 = uint256(33) << INDEX_BITS;
    uint256 public constant TYPE_B4 = uint256(34) << INDEX_BITS;
    uint256 public constant TYPE_B5 = uint256(35) << INDEX_BITS;

    uint256 public constant TYPE_PA = uint256(40) << INDEX_BITS;
    uint256 public constant TYPE_PB = uint256(41) << INDEX_BITS;
    uint256 public constant TYPE_PC = uint256(42) << INDEX_BITS;
    uint256 public constant TYPE_PD = uint256(43) << INDEX_BITS;

    uint256 public constant TYPE_P1 = uint256(45) << INDEX_BITS;
    uint256 public constant TYPE_P2 = uint256(46) << INDEX_BITS;
    uint256 public constant TYPE_P3 = uint256(47) << INDEX_BITS;

    function isTypeG(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_G;
    }

    function isTypeB(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_B;
    }

    function isTypePA(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_PA;
    }

    function isTypePB(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_PB;
    }

    function isTypePC(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_PC;
    }

    function isTypePD(uint256 id) internal pure returns (bool) {
        return id & TYPE_MASK == TYPE_PD;
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