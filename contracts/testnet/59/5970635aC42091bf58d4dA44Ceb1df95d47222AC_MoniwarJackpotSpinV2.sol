//// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.0;
pragma abicoder v2;

import "../Library/Context.sol";
import "../Library/Ownable.sol";
import "../Library/SafeMath.sol";
import "../Library/Strings.sol";
import "../Library/IERC20.sol";
import "../Library/IERC1155.sol";
import "./RandSpinInterface.sol";
import "./MowaItemsCore.sol";
import "../Library/ReentrancyGuard.sol";

contract MoniwarJackpotSpinV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
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
    // address private dev = 0xCAF84d187C3DD9d8ee91aFef9C9af5194dd3916e;
    address private dev = 0x171a1639Aa7fe24b406c098C8d91198D625791e9;
    uint256 public feeSpin = 500;
    uint256 public feePoolJackpot = 20; // transfer wallet fee
    uint256 public feeWithholding = 180; // holding MOWA in pool
    uint256 public taxfeeMowa = 10;
    uint256 saleOffx5 = 100;
    uint256 saleOffx10 = 200;
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
    // address => timeReward => UserSpin
    mapping(address => mapping(uint256 => UserSpin)) public userSpin;

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
    bool isActive = true;

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

    function setIsRewardForSpin(uint256 rw1, uint256 rw2, uint256 rw3, uint256 rw4, uint256 rw5, uint256 rw6) public onlySupervisor {
        if (rw1 > 0) {
            require(rewardSpin[rw1].character > 0, "reward1 is not define");
            isReward1 = rw1;
        }
        if (rw2 > 0) {
            require(rewardSpin[rw2].character > 0, "reward2 is not define");
            isReward2 = rw2;
        }
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

    function spin(uint256 _tokenId, uint256 number, uint256 time) public nonReentrant {
        uint256 character = mowaItemsCore.getNFT(_tokenId).character;
        require(character == 42, "TokenId not tickets");
        uint256 qtyTicket = mowaItemsNFT.balanceOf(_msgSender(), _tokenId);

        uint256 feeMowa = 0;
        if (qtyTicket > 0) {
            if (qtyTicket >= number) {
                mowaItemsCore.burnNFT(_msgSender(), _tokenId, number);
            } else {
                feeMowa = (number - qtyTicket) * mowaSpin;
            }
        } else {
            feeMowa = number * mowaSpin;
        }

        if (feeMowa > 0) {
            if (number == 5) {
                feeMowa = feeMowa - (feeMowa * saleOffx5 / PERCENTS_DIVIDER);
            } else if (number == 10) {
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

        uint256 qtyRw1 = 0;
        uint256 qtyRw2 = 0;
        uint256 qtyRw3 = 0;
        uint256 qtyRw4 = 0;
        uint256 qtyRw5 = 0;
        uint256 qtyRw6 = 0;
        uint256 jackpot = 0;

        for (uint256 i = 1; i <= number; i++) {
            if (qtyTicket > 0) {
                randManager.randMod(_msgSender(), 0);
            } else {
                randManager.randMod(_msgSender(), mowaToken.balanceOf(address(this)));
            }
            (uint256 _qtyRw1, uint256 _qtyRw2, uint256 _qtyRw3, uint256 _qtyRw4, uint256 _qtyRw5, uint256 _qtyRw6, uint256 _jackpot) = getSpin();
            qtyRw1 += _qtyRw1;
            qtyRw2 += _qtyRw2;
            qtyRw3 += _qtyRw3;
            qtyRw4 += _qtyRw4;
            qtyRw5 += _qtyRw5;
            qtyRw6 += _qtyRw6;
            jackpot += _jackpot;
        }

        if (jackpot > 0) {
            uint256 rewardJackpot = mowaToken.balanceOf(address(this));
            userSpin[_msgSender()][time].jackpot = rewardJackpot;

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
        if (qtyRw1 > 0) {
            userSpin[_msgSender()][time].qtyRw1 = qtyRw1;
        }
        if (qtyRw2 > 0) {
            userSpin[_msgSender()][time].qtyRw2 = qtyRw2;
        }

        if (qtyRw3 > 0 || qtyRw4 > 0 || qtyRw5 > 0 || qtyRw6 > 0) {
            uint totalArr = 0;
            if (qtyRw3 > 0) {
                userSpin[_msgSender()][time].qtyRw3 = qtyRw3;
                totalArr += 1;
            }
            if (qtyRw4 > 0) {
                userSpin[_msgSender()][time].qtyRw4 = qtyRw4;
                totalArr += 1;
            }
            if (qtyRw5 > 0) {
                userSpin[_msgSender()][time].qtyRw5 = qtyRw5;
                totalArr += 1;
            }
            if (qtyRw6 > 0) {
                userSpin[_msgSender()][time].qtyRw6 = qtyRw6;
                totalArr += 1;
            }
            uint tokenIdNew = mowaItemsCore.getNextNFTId();
            uint256[] memory tokenIdMint = new uint256[](totalArr);
            uint256[] memory qtyMint = new uint256[](totalArr);
            uint256 tokenId;
            uint n = 0;
            if (qtyRw3 > 0) {
                tokenId = mowaItemsCore.getTokenWithCharacter(isReward3);
                if (tokenId == 0) {
                    tokenId = tokenIdNew;
                    createNFTFactory(isReward3, tokenIdNew);
                    tokenIdNew += 1;
                }
                tokenIdMint[n] = tokenId;
                qtyMint[n] = qtyRw3;
                n += 1;
            }
            if (qtyRw4 > 0) {
                tokenId = mowaItemsCore.getTokenWithCharacter(isReward4);
                if (tokenId == 0) {
                    tokenId = tokenIdNew;
                    createNFTFactory(isReward4, tokenIdNew);
                    tokenIdNew += 1;
                }
                tokenIdMint[n] = tokenId;
                qtyMint[n] = qtyRw4;
                n += 1;
            }
            if (qtyRw5 > 0) {
                tokenId = mowaItemsCore.getTokenWithCharacter(isReward5);
                if (tokenId == 0) {
                    tokenId = tokenIdNew;
                    createNFTFactory(isReward5, tokenIdNew);
                    tokenIdNew += 1;
                }
                tokenIdMint[n] = tokenId;
                qtyMint[n] = qtyRw5;
                n += 1;
            }
            if (qtyRw6 > 0) {
                tokenId = mowaItemsCore.getTokenWithCharacter(isReward6);
                if (tokenId == 0) {
                    tokenId = tokenIdNew;
                    createNFTFactory(isReward6, tokenIdNew);
                    tokenIdNew += 1;
                }
                tokenIdMint[n] = tokenId;
                qtyMint[n] = qtyRw6;
            }
            mowaItemsCore.safeBatchMintNFT(_msgSender(), tokenIdMint, qtyMint);
        }

        emit RewardSpinUser(time, _msgSender());
    }

    function getSpin() internal returns (uint256 qtyRw1, uint256 qtyRw2, uint256 qtyRw3, uint256 qtyRw4, uint256 qtyRw5, uint256 qtyRw6, uint256 jackpot) {
        qtyRw1 = 0;
        qtyRw2 = 0;
        qtyRw3 = 0;
        qtyRw4 = 0;
        qtyRw5 = 0;
        qtyRw6 = 0;
        jackpot = 0;

        (uint256 reward1, uint256 reward2, uint256 reward3, uint256 reward4) = randManager.currentRandMod(_msgSender());

        // reward jackpot
        if (reward1 <= 10 && reward2 <= 60 && reward3 <= 40 && reward4 == 1) {
            jackpot = 1;
        } else {

            //  row 1
            if (reward1 > 10 && reward1 <= 12 && qtyReward6 > 0) {
                qtyRw6 += 1;
                qtyReward6 -= 1;
            } else if (reward1 > 12 && reward1 <= 20 && qtyReward3 > 0) {
                qtyRw3 += 1;
                qtyReward3 -= 1;
            } else if (reward1 > 20 && reward1 <= 30 && qtyReward5 > 0) {
                qtyRw5 += 1;
                qtyReward5 -= 1;
            } else if (reward1 > 30 && reward1 <= 50) {
                qtyRw2 += 1;
            } else if (reward1 > 50) {
                qtyRw1 += 1;
            }

            // row 2
            if (reward2 > 60 && reward2 <= 65 && qtyReward4 > 0) {
                qtyRw4 += 1;
                qtyReward4 -= 1;
            } else if (reward2 > 65 && reward2 <= 71 && qtyReward3 > 0) {
                qtyRw3 += 1;
                qtyReward3 -= 1;
            } else if (reward2 > 71 && reward2 <= 86 && qtyReward5 > 0) {
                qtyRw5 += 1;
                qtyReward5 -= 1;
            } else if (reward2 > 86 && reward2 <= 90) {
                qtyRw2 += 1;
            } else if (reward2 > 90) {
                qtyRw1 += 1;
            }

            // row 3
            if (reward3 > 40 && reward3 <= 48 && qtyReward6 > 0) {
                qtyRw6 += 1;
                qtyReward6 -= 1;
            } else if (reward3 > 48 && reward3 <= 57 && qtyReward4 > 0) {
                qtyRw4 += 1;
                qtyReward4 -= 1;
            } else if (reward3 > 57 && reward3 <= 62) {
                qtyRw2 += 1;
            } else if (reward3 > 62 && reward3 <= 73 && qtyReward3 > 0) {
                qtyRw3 += 1;
                qtyReward3 -= 1;
            } else if (reward3 > 73 && reward3 <= 85 && qtyReward5 > 0) {
                qtyRw5 += 1;
                qtyReward5 -= 1;
            } else if (reward3 > 85) {
                qtyRw1 += 1;
            }

            // row 4
            if (reward4 > 1 && reward4 <= 4 && qtyReward6 > 0) {
                qtyRw6 += 1;
                qtyReward6 -= 1;
            } else if (reward4 > 4 && reward4 <= 9 && qtyReward5 > 0) {
                qtyRw5 += 1;
                qtyReward5 -= 1;
            } else if (reward4 > 9 && reward4 <= 19 && qtyReward4 > 0) {
                qtyRw4 += 1;
                qtyReward4 -= 1;
            } else if (reward4 > 19 && reward4 <= 55) {
                qtyRw2 += 1;
            } else if (reward4 > 55) {
                qtyRw1 += 1;
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

    function getBalanceTicket(address account) public view returns (uint256 tokenId, uint256 amount) {
        tokenId = mowaItemsCore.getTokenWithCharacter(42);
        if (tokenId == 0) {
            amount = 0;
        } else {
            amount = mowaItemsNFT.balanceOf(account, tokenId);
        }
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;
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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }    
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity ^0.7.0;

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
    event Burn(address indexed account, uint256 id, uint256 value);
    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event BurnBatch(address indexed account, uint256[] ids, uint256[] values);

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

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
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

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
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

    function ownerOf(uint256 tokenId) external view returns (address[] memory);
    function _exists(address account, uint256 tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
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