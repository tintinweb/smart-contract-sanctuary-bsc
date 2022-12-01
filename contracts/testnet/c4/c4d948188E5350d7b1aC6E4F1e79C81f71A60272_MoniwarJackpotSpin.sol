//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Address.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./IERC1155.sol";
import "./RandSpinInterface.sol";
import "./MowaItemsCore.sol";
import "./ReentrancyGuard.sol";

contract MoniwarJackpotSpin is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    MowaItemsCore public mowaItemsCore;
    IERC1155 public mowaItemsNFT;
    IERC20 public mowaToken;

    event RewardSpinUser(uint256 indexed time, address user);

    RandSpinInterface public randManager;

    struct RewardSpin {
        uint256 character;
        uint256 class;
        uint256 level;
        uint256 star;
        uint256 characterPet;
        uint256 attr1;
        uint256 attr2;
        uint256 attr3;
    }

    mapping(uint256 => RewardSpin) public rewardSpin;
    uint256 public mowaSpin = 50 * 10 ** 18;
    address public feeWallet = 0x2f2f1af022aD334e73ebA2378BD20aB337bdE042;
    uint256 public feeSpin = 500;
    uint256 public feePoolJackpot = 20; // transfer wallet fee
    uint256 public feeWithholding = 180; // holding MOWA in pool
    uint256 public taxfeeMowa = 10;
    uint256 public saleOffx5 = 100;
    uint256 public saleOffx10 = 200;
    uint256 constant public PERCENTS_DIVIDER = 1000;

    struct CountRewardUser {
        uint256 timeReward;
    }

    mapping(address => CountRewardUser[]) public countRewardUser;

    struct UserSpin {
        uint256 characterRw1;
        uint256 qtyRw1;
        uint256 characterRw2;
        uint256 qtyRw2;
        uint256 characterRw3;
        uint256 qtyRw3;
        uint256 characterRw4;
        uint256 qtyRw4;
        uint256 characterRw5;
        uint256 qtyRw5;
        uint256 characterRw6;
        uint256 qtyRw6;
        uint256 jackpot;
        uint256 xSpin;
    }

    struct AlphabetSpin {
        uint256 qtyM;
        uint256 qtyO;
        uint256 qtyW;
        uint256 qtyA;
    }

    // address => timeReward => UserSpin
    mapping(address => mapping(uint256 => UserSpin)) public userSpin;
    // address => timeReward => countdown => AlphabetSpin
    mapping(address => mapping(uint256 => mapping(uint256 => AlphabetSpin))) public alphabetSpin;

    uint256 public isReward1 = 10001; // Card lv1
    uint256 public isReward2 = 10002; // Card lv2
    uint256 public isReward3 = 24; // Đá lv1
    uint256 public isReward4 = 34; // Lucky charm lv1
    uint256 public isReward5 = 42; // Spin ticket
    uint256 public isReward6 = 43; // Pet Pieces nova

    uint256 public qtyReward3 = 1000;
    uint256 public qtyReward4 = 100;
    uint256 public qtyReward5 = 1000;
    uint256 public qtyReward6 = 30;

    address private supervisor = 0x317A449138Dd7D2FD2c11a66D2FCB2B315e4711D;
    address private admin = 0x36b5628e587C257B64c41c63c9f0b67c0D27cad4;
    bool public isActive = true;
    bool public offContract = false;

    constructor(
        address _randManager,
        IERC20 _mowaToken,
        MowaItemsCore _mowaItemsCore,
        IERC1155 _mowaItemsNFT
    ) {
        mowaItemsCore = MowaItemsCore(_mowaItemsCore);
        mowaItemsNFT = _mowaItemsNFT;
        randManager = RandSpinInterface(_randManager);
        mowaToken = _mowaToken;
        rewardSpin[24] = RewardSpin(24, 1, 1, 0, 0, 0, 0, 0);
        rewardSpin[34] = RewardSpin(34, 4, 1, 0, 0, 0, 0, 0);
        rewardSpin[42] = RewardSpin(42, 5, 0, 0, 0, 0, 0, 0);
        rewardSpin[43] = RewardSpin(43, 2, 1, 3, 23, 0, 0, 0);
        rewardSpin[10001] = RewardSpin(10001, 0, 0, 0, 0, 0, 0, 0);
        rewardSpin[10002] = RewardSpin(10002, 0, 0, 0, 0, 0, 0, 0);
    }

    modifier onlySupervisor() {
        require(isActive == true, "ask admin for approval");
        require(_msgSender() == supervisor, "require safe supervisor Address.");
        _;
    }
    modifier onlyAdmin(){
        require(_msgSender() == admin, "require safe Admin Address.");
        _;
    }
    function changeIsActive(bool active) public onlyAdmin {
        isActive = active;
    }
    function changeOffContract(bool active) public onlyAdmin {
        offContract = active;
    }
    function changeSupervisor(address _supervisor) public onlyOwner {
        supervisor = _supervisor;
    }
    function changeAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure virtual returns (bytes32) {
        return this.onERC1155Received.selector;
    }
    function changeMowaToken(address _mowa) public onlyOwner {
        mowaToken = IERC20(_mowa);
    }
    function changeTaxfeeMowa(uint256 _taxfee) public onlyOwner {
        taxfeeMowa = _taxfee;
    }
    function setFeeWallet(address _wallet) public onlyOwner {
        feeWallet = _wallet;
    }
    function setFeeSpin(uint256 _feeSpin) public onlySupervisor {
        feeSpin = _feeSpin;
    }
    function changeSaleOff(uint256 x5, uint256 x10) public onlySupervisor {
        if (x5 > 0) {
            saleOffx5 = x5;
        }
        if (x10 > 0) {
            saleOffx10 = x10;
        }
    }
    function setFeeWithholding(uint256 _feeWithholding) public onlySupervisor {
        feeWithholding = _feeWithholding;
    }
    function setFeePoolJackpot(uint256 _feePoolJackpot) public onlySupervisor {
        feePoolJackpot = _feePoolJackpot;
    }
    function setMowaSpin(uint256 _mowaSpin) public onlySupervisor {
        mowaSpin = _mowaSpin;
    }
    function getTimereward(address acount) public view returns (CountRewardUser[] memory){
        return countRewardUser[acount];
    }
    function setQtyReward(uint256 qty3, uint256 qty4, uint256 qty5, uint256 qty6) public onlySupervisor {
        if (qty3 > 0) qtyReward3 = qty3;
        if (qty4 > 0) qtyReward4 = qty4;
        if (qty5 > 0) qtyReward5 = qty5;
        if (qty6 > 0) qtyReward6 = qty6;
    }
    function setRewardSpin(uint256 character, uint256 class, uint256 level, uint256 star, uint256 characterPet, uint256 attr1, uint256 attr2, uint256 attr3) public onlySupervisor {
        rewardSpin[character] = RewardSpin(character, class, level, star, characterPet, attr1, attr2, attr3);
    }
    function setIsRewardForSpin(uint256 rw3, uint256 rw4, uint256 rw5, uint256 rw6) public onlySupervisor {
        if (rw3 > 0) {
            require(rewardSpin[rw3].character > 0, "reward3 is not define");
            isReward3 = rw3;
        }
        if (rw4 > 0) {
            require(rewardSpin[rw4].character > 0, "reward4 is not define");
            isReward4 = rw4;
        }
        if (rw5 > 0) {
            require(rewardSpin[rw5].character > 0, "reward5 is not define");
            isReward5 = rw5;
        }
        if (rw6 > 0) {
            require(rewardSpin[rw6].character > 0, "reward6 is not define");
            isReward6 = rw6;
        }
    }

    function spin(uint256 number, uint256 time) public nonReentrant {
        require(offContract == false, "contract is not active");
        uint256 _tokenId = mowaItemsCore.getTokenWithCharacter(42);
        uint256 qtyTicket = mowaItemsNFT.balanceOf(_msgSender(), _tokenId);

        uint256 feeMowa = 0;
        if (qtyTicket > 0) {
            if (qtyTicket >= number) {
                mowaItemsCore.burnNFT(_msgSender(), _tokenId, number);
            } else {
                feeMowa = (number - qtyTicket) * mowaSpin;
                mowaItemsCore.burnNFT(_msgSender(), _tokenId, qtyTicket);
            }
        } else {
            feeMowa = number * mowaSpin;
        }

        if (feeMowa > 0) {
            if (number == 5 && saleOffx5 > 0) {
                feeMowa = feeMowa - (feeMowa * saleOffx5 / PERCENTS_DIVIDER);
            } else if (number == 10 && saleOffx10 > 0) {
                feeMowa = feeMowa - (feeMowa * saleOffx10 / PERCENTS_DIVIDER);
            }
            require(mowaToken.balanceOf(_msgSender()) >= feeMowa, "Insufficient funds MOWA in the account");
            bool transfer = mowaToken.transferFrom(_msgSender(), address(this), feeMowa);
            require(transfer == true, "Transfer MOWA failed");
            uint256 amountSendAfterFee = feeMowa.sub(feeMowa.mul(taxfeeMowa).div(PERCENTS_DIVIDER));

            if (feeSpin > 0) {
                uint256 _mowaFeeSpin = amountSendAfterFee.mul(feeSpin).div(PERCENTS_DIVIDER);
                mowaToken.transfer(feeWallet, _mowaFeeSpin);
            }
        }

        for (uint256 i = 0; i < number; i++) {
            if (qtyTicket > i || userSpin[_msgSender()][time].jackpot > 0) {
                randManager.randMod(_msgSender(), 0);
            } else {
                randManager.randMod(_msgSender(), mowaToken.balanceOf(address(this)));
            }
            getSpin(time, i);
        }

        if (userSpin[_msgSender()][time].jackpot > 0) {
            uint256 rewardJackpot = userSpin[_msgSender()][time].jackpot;
            uint256 _feeWithholding = rewardJackpot.mul(feeWithholding).div(PERCENTS_DIVIDER);
            uint256 rewardUser = rewardJackpot.sub(_feeWithholding);
            if (feePoolJackpot > 0) {
                uint256 _feePoolJackpot = rewardJackpot.mul(feePoolJackpot).div(PERCENTS_DIVIDER);
                rewardUser -= _feePoolJackpot;
                mowaToken.transfer(feeWallet, _feePoolJackpot);
            }
            mowaToken.transfer(_msgSender(), rewardUser);
        }

        countRewardUser[_msgSender()].push(CountRewardUser({timeReward : time}));

        userSpin[_msgSender()][time].characterRw1 = isReward1;
        userSpin[_msgSender()][time].characterRw2 = isReward2;
        userSpin[_msgSender()][time].characterRw3 = isReward3;
        userSpin[_msgSender()][time].characterRw4 = isReward4;
        userSpin[_msgSender()][time].characterRw5 = isReward5;
        userSpin[_msgSender()][time].characterRw6 = isReward6;
        userSpin[_msgSender()][time].xSpin = number;

        uint totalArr = 0;
        if (userSpin[_msgSender()][time].qtyRw3 > 0) totalArr += 1;
        if (userSpin[_msgSender()][time].qtyRw4 > 0) totalArr += 1;
        if (userSpin[_msgSender()][time].qtyRw5 > 0) totalArr += 1;
        if (userSpin[_msgSender()][time].qtyRw6 > 0) totalArr += 1;
        if (totalArr > 0) {
            uint tokenIdNew = mowaItemsCore.getNextNFTId();
            uint256[] memory tokenIdMint = new uint256[](totalArr);
            uint256[] memory qtyMint = new uint256[](totalArr);
            uint256 tokenId;
            uint n = 0;
            if (userSpin[_msgSender()][time].qtyRw3 > 0) {
                tokenId = mowaItemsCore.getTokenWithCharacter(isReward3);
                if (tokenId == 0) {
                    tokenId = tokenIdNew;
                    createNFTFactory(isReward3, tokenIdNew);
                    tokenIdNew += 1;
                }
                tokenIdMint[n] = tokenId;
                qtyMint[n] = userSpin[_msgSender()][time].qtyRw3;
                n += 1;
            }
            if (userSpin[_msgSender()][time].qtyRw4 > 0) {
                tokenId = mowaItemsCore.getTokenWithCharacter(isReward4);
                if (tokenId == 0) {
                    tokenId = tokenIdNew;
                    createNFTFactory(isReward4, tokenIdNew);
                    tokenIdNew += 1;
                }
                tokenIdMint[n] = tokenId;
                qtyMint[n] = userSpin[_msgSender()][time].qtyRw4;
                n += 1;
            }
            if (userSpin[_msgSender()][time].qtyRw5 > 0) {
                tokenId = mowaItemsCore.getTokenWithCharacter(isReward5);
                if (tokenId == 0) {
                    tokenId = tokenIdNew;
                    createNFTFactory(isReward5, tokenIdNew);
                    tokenIdNew += 1;
                }
                tokenIdMint[n] = tokenId;
                qtyMint[n] = userSpin[_msgSender()][time].qtyRw5;
                n += 1;
            }
            if (userSpin[_msgSender()][time].qtyRw6 > 0) {
                tokenId = mowaItemsCore.getTokenWithCharacter(isReward6);
                if (tokenId == 0) {
                    tokenId = tokenIdNew;
                    createNFTFactory(isReward6, tokenIdNew);
                    tokenIdNew += 1;
                }
                tokenIdMint[n] = tokenId;
                qtyMint[n] = userSpin[_msgSender()][time].qtyRw6;
            }
            mowaItemsCore.safeBatchMintNFT(_msgSender(), tokenIdMint, qtyMint);
        }

        emit RewardSpinUser(time, _msgSender());
    }

    function getSpin(uint256 time, uint256 count) internal {

        (uint256 reward1, uint256 reward2, uint256 reward3, uint256 reward4) = randManager.currentRandMod(_msgSender());

        // reward jackpot
        if (reward1 <= 10 && reward2 <= 60 && reward3 <= 40 && reward4 == 1) {
            userSpin[_msgSender()][time].jackpot = mowaToken.balanceOf(address(this));
        } else {

            //  row 1
            if (reward1 <= 10) {
                alphabetSpin[_msgSender()][time][count].qtyM += 1;
            } else if (reward1 > 10 && reward1 <= 12 && qtyReward6 > 0) {
                userSpin[_msgSender()][time].qtyRw6 += 1;
                qtyReward6 -= 1;
            } else if (reward1 > 12 && reward1 <= 20 && qtyReward3 > 0) {
                userSpin[_msgSender()][time].qtyRw3 += 1;
                qtyReward3 -= 1;
            } else if (reward1 > 20 && reward1 <= 30 && qtyReward5 > 0) {
                userSpin[_msgSender()][time].qtyRw5 += 1;
                qtyReward5 -= 1;
            } else if (reward1 > 30 && reward1 <= 50) {
                userSpin[_msgSender()][time].qtyRw2 += 1;
            } else {
                userSpin[_msgSender()][time].qtyRw1 += 1;
            }

            // row 2
            if (reward1 <= 60) {
                alphabetSpin[_msgSender()][time][count].qtyO += 1;
            } else if (reward2 > 60 && reward2 <= 65 && qtyReward4 > 0) {
                userSpin[_msgSender()][time].qtyRw4 += 1;
                qtyReward4 -= 1;
            } else if (reward2 > 65 && reward2 <= 71 && qtyReward3 > 0) {
                userSpin[_msgSender()][time].qtyRw3 += 1;
                qtyReward3 -= 1;
            } else if (reward2 > 71 && reward2 <= 86 && qtyReward5 > 0) {
                userSpin[_msgSender()][time].qtyRw5 += 1;
                qtyReward5 -= 1;
            } else if (reward2 > 86 && reward2 <= 90) {
                userSpin[_msgSender()][time].qtyRw2 += 1;
            } else {
                userSpin[_msgSender()][time].qtyRw1 += 1;
            }

            // row 3
            if (reward1 <= 40) {
                alphabetSpin[_msgSender()][time][count].qtyW += 1;
            } else if (reward3 > 40 && reward3 <= 48 && qtyReward6 > 0) {
                userSpin[_msgSender()][time].qtyRw6 += 1;
                qtyReward6 -= 1;
            } else if (reward3 > 48 && reward3 <= 57 && qtyReward4 > 0) {
                userSpin[_msgSender()][time].qtyRw4 += 1;
                qtyReward4 -= 1;
            } else if (reward3 > 57 && reward3 <= 62) {
                userSpin[_msgSender()][time].qtyRw2 += 1;
            } else if (reward3 > 62 && reward3 <= 73 && qtyReward3 > 0) {
                userSpin[_msgSender()][time].qtyRw3 += 1;
                qtyReward3 -= 1;
            } else if (reward3 > 73 && reward3 <= 85 && qtyReward5 > 0) {
                userSpin[_msgSender()][time].qtyRw5 += 1;
                qtyReward5 -= 1;
            } else {
                userSpin[_msgSender()][time].qtyRw1 += 1;
            }

            // row 4
            if (reward1 <= 1) {
                alphabetSpin[_msgSender()][time][count].qtyA += 1;
            } else if (reward4 > 1 && reward4 <= 4 && qtyReward6 > 0) {
                userSpin[_msgSender()][time].qtyRw6 += 1;
                qtyReward6 -= 1;
            } else if (reward4 > 4 && reward4 <= 9 && qtyReward5 > 0) {
                userSpin[_msgSender()][time].qtyRw5 += 1;
                qtyReward5 -= 1;
            } else if (reward4 > 9 && reward4 <= 19 && qtyReward4 > 0) {
                userSpin[_msgSender()][time].qtyRw4 += 1;
                qtyReward4 -= 1;
            } else if (reward4 > 19 && reward4 <= 55) {
                userSpin[_msgSender()][time].qtyRw2 += 1;
            } else {
                userSpin[_msgSender()][time].qtyRw1 += 1;
            }
        }
    }

    function createNFTFactory(uint256 character, uint256 tokenId) internal {
        MowaItems memory mowa = MowaItems(
            rewardSpin[character].character,
            rewardSpin[character].class,
            rewardSpin[character].level,
            rewardSpin[character].star,
            rewardSpin[character].characterPet,
            rewardSpin[character].attr1,
            rewardSpin[character].attr2,
            rewardSpin[character].attr3
        );
        mowaItemsCore.setNFTFactory(mowa, tokenId);
    }

    function mowaPool() public view returns (uint256 _mowa){
        return mowaToken.balanceOf(address(this));
    }

    function getFeeSpin(address account) public view returns (uint256 tokenId, uint256 amount, uint256 pricex1, uint256 pricex5, uint256 pricex10) {
        tokenId = mowaItemsCore.getTokenWithCharacter(42);
        amount = 0;
        if (tokenId > 0) {
            amount = mowaItemsNFT.balanceOf(account, tokenId);
        }
        if (amount == 0) {
            pricex1 = mowaSpin;
            pricex5 = 5 * mowaSpin;
            pricex10 = 10 * mowaSpin;
        } else {
            if (amount >= 1) {
                pricex1 = 0;
            } else {
                pricex1 = (1 - amount) * mowaSpin;
            }
            if (amount >= 5) {
                pricex5 = 0;
            } else {
                pricex5 = (5 - amount) * mowaSpin;
            }
            if (amount >= 10) {
                pricex10 = 0;
            } else {
                pricex10 = (10 - amount) * mowaSpin;
            }
        }
        if (saleOffx5 > 0) {
            pricex5 = pricex5 - (pricex5 * saleOffx5 / PERCENTS_DIVIDER);
        }
        if (saleOffx10 > 0) {
            pricex10 = pricex10 - (pricex10 * saleOffx10 / PERCENTS_DIVIDER);
        }
    }

    function getAlphabet(address user, uint256 timeSpin, uint256 xSpin) public view returns (AlphabetSpin[] memory){
        AlphabetSpin[] memory allAlphabetSpin = new AlphabetSpin[](xSpin);
        for (uint256 index = 0; index < timeSpin; index++) {
            allAlphabetSpin[index] = AlphabetSpin({
                qtyM: alphabetSpin[user][timeSpin][index].qtyM,
                qtyO: alphabetSpin[user][timeSpin][index].qtyO,
                qtyW: alphabetSpin[user][timeSpin][index].qtyW,
                qtyA: alphabetSpin[user][timeSpin][index].qtyA
            });
        }
        return allAlphabetSpin;
    }


    /**
     * @dev Withdraw bnb from this contract (Callable by owner only)
     */
    function SwapExactToken(
        address coinAddress,
        uint256 value,
        address payable to
    ) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }

    function setRandManager(address _addr) external onlyOwner {
        randManager = RandSpinInterface(_addr);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;

struct Rand {
    uint256 currentRand1;
    uint256 currentRand2;
    uint256 currentRand3;
    uint256 currentRand4;
}

interface RandSpinInterface {
    function currentRandMod(address userAddress) external view returns(uint256 rw1, uint256 rw2, uint256 rw3, uint256 rw4);
    function randMod(address userAddress, uint256 mowaPool) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;

struct MowaItems {
    uint256 character;
    uint256 class;
    uint256 level;
    uint256 star;
    uint256 characterPet;
    uint256 attr1;
    uint256 attr2;
    uint256 attr3;
}

interface MowaItemsCore {
    function getNFT(uint256 _tokenId) external view returns (MowaItems memory);
    function setNFTFactory(MowaItems memory _mowa, uint256 _tokenId) external;
    function safeMintNFT(address _addr, uint256 tokenId, uint256 amount) external;
    function safeBatchMintNFT(address _addr, uint256[] memory tokenId, uint256[] memory amount) external;
    function burnNFT(address _addr, uint256 tokenId, uint256 amount) external;
    function burnBatchNFT(address _addr, uint256[] memory ids, uint256[] memory amounts) external;
    function getAllNFT(uint256 _fromTokenId, uint256 _toTokenId) external view returns (MowaItems[] memory);
    function getNextNFTId() external view returns (uint256);
    function getTokenWithCharacter(uint256 _character) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address[] memory);
    function _exists(address account, uint256 tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}