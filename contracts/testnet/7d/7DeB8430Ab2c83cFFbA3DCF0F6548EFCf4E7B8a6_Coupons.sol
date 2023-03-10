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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/ICoupons.sol";
//import "hardhat/console.sol";

/* Errors */
error Coupons__CouponNotFound();
error Coupons__PlayerAddressMismatch();
error Coupons__CouponAlreadyUsed();
error Coupons__RuleNotFound();
error Coupons__NotEnoughFunds();
error Coupons__TransferToSafeFailed();
error Coupons__NotForPaidCoupons();
error Coupons__ZeroCouponFee();
error Coupons__BadOrderOfRndMinMax();
error Coupons__OutOfMaxRndPctLimit();
error Coupons__StepOutOfRange();

contract Coupons is ICoupons {
    string private constant VERSION = "0.7.0";

    enum CRUD_action {
        GET,
        ADD_OR_UPDATE,
        DELETE,
        DELETE_ALL
    }

    address private s_owner;
    address payable private s_safeAddress;
    uint s_nonce;

    // Contracts table
    address [] private s_contractList;
    mapping(address => bool) private s_contracts;
    // Public coupons table: contractAddress -> coupon
    mapping(address => ICoupons.Coupon[]) private s_coupons;
    // Coupons rule:  contractAddress => couponRule
    mapping(address => ICoupons.CouponRule) private s_couponRule;
    // Paid Coupons store
    // Number of paid coupons: contractAddress -> raffleId -> playerAddress -> number of coupon tickets
    mapping(address => mapping(uint32 => mapping(address => uint16))) private s_nCouponTickets;
    // Paid coupon ticket: contractAddress => raffleId => couponHash => coupon ticket data
    mapping(address => mapping(uint32 => mapping(bytes32 => ICoupons.CouponTicket))) private s_couponTickets;
    // Contract balance: contractAddress => balance
    mapping(address => uint) private s_contractBalance;

    event CouponsUpdate(address contractAddress, bytes32 keyHash);
    event CouponPurchase(string couponKey, ICoupons.CouponTicket couponTicket, uint nonce);
    event CouponUsed(bytes32 couponHash, address playerAddress, address contractAddress, uint32 raffleId);
    event ContractWithdraw(address contractAddress, uint funds);
    event CouponRuleUpdated(address contractAddress);

    constructor(address payable safe) {
        s_owner = msg.sender;
        s_safeAddress = safe;
        s_nonce = 1;
    }

    /** Public Coupons CRUD **/
    function getCoupon(
        bytes32 couponHash,
        address playerAddress,
        address contractAddress,
        uint32 raffleId
    ) public view override returns (ICoupons.Coupon memory) {
        return _getCoupon(couponHash, playerAddress, contractAddress, raffleId);
    }

    function _getCoupon(
        bytes32 couponHash,
        address playerAddress,
        address contractAddress,
        uint32 raffleId
    ) internal view returns (ICoupons.Coupon memory) {
        ICoupons.CouponTicket memory couponTicket = s_couponTickets[contractAddress][raffleId][couponHash];
        if (couponTicket.playerAddress == address(0)) {
            for (uint i=0; i < s_coupons[contractAddress].length; i++) {
                if (s_coupons[contractAddress][i].couponHash == couponHash) {
                    return (s_coupons[contractAddress][i]);
                }
            }
        } else {
            if (playerAddress != couponTicket.playerAddress) {
                revert Coupons__PlayerAddressMismatch();
            }
            if (couponTicket.used) {
                revert Coupons__CouponAlreadyUsed();
            } else {
                return ICoupons.Coupon(couponHash, 0, 100, couponTicket.multiplierPct, true);
            }
        }
        revert Coupons__CouponNotFound();
    }

    function setCoupon(address contractAddress, ICoupons.Coupon memory coupon) public onlyOwner {
        if (coupon.isPaid) {
            revert Coupons__NotForPaidCoupons();
        }
        bool found = false;
        uint id = 0;
        if (s_coupons[contractAddress].length > 0) {
            for (uint i=0; i < s_coupons[contractAddress].length; i++) {
                if (s_coupons[contractAddress][i].couponHash == coupon.couponHash) {
                    found = true;
                    id = i;
                    break;
                }
            }
        }
        if (found) {
            s_coupons[contractAddress][id] = coupon;
        } else {
            s_coupons[contractAddress].push(coupon);
        }
        emit CouponsUpdate(contractAddress, coupon.couponHash);
    }

    function deleteCoupon(address contractAddress, bytes32 keyHash) public onlyOwner {
        if (s_coupons[contractAddress].length > 0) {
            bool found = false;
            uint id;
            for (uint i = 0; i < s_coupons[contractAddress].length; i++) {
                if (s_coupons[contractAddress][i].couponHash == keyHash) {
                    id = i;
                    found = true;
                    block;
                }
            }
            if (found) {
                for (uint i = id; i < s_coupons[contractAddress].length - 1; i++){
                    s_coupons[contractAddress][i] = s_coupons[contractAddress][i + 1];
                }
                s_coupons[contractAddress].pop();
            }
        }
        emit CouponsUpdate(contractAddress, keyHash);
    }

    function deleteAllCoupons(address contractAddress) public onlyOwner {
        while(s_coupons[contractAddress].length > 0) {
            s_coupons[contractAddress].pop();
        }
        emit CouponsUpdate(contractAddress, keccak256(abi.encodePacked('')));
    }

    function getCouponHashes(address contractAddress) public view returns (bytes32[] memory result) {
        result = new bytes32[](s_coupons[contractAddress].length);
        for (uint i=0; i < s_coupons[contractAddress].length; i++) {
            result[i] = s_coupons[contractAddress][i].couponHash;
        }
    }
    /** End Public Coupons CRUD **/

    function buyCoupon(address contractAddress, uint32 raffleId) public payable override {
        // Find contract rule
        CouponRule memory couponRule = s_couponRule[contractAddress];
        if (couponRule.couponFee == 0) {
            revert Coupons__RuleNotFound();
        }
        // Check incoming value
        if (msg.value < couponRule.couponFee) {
            revert Coupons__NotEnoughFunds();
        }

        s_nCouponTickets[contractAddress][raffleId][msg.sender] += 1;
        uint16 ticketId = s_nCouponTickets[contractAddress][raffleId][msg.sender];
        string memory couponKey = _getPaidCouponKey(msg.sender, contractAddress, raffleId, ticketId);
        bytes32 couponHash = keccak256(abi.encodePacked(couponKey));
        uint16 multiplierPct = _getRoundedRandomPct(
            couponRule.minRndPct, couponRule.maxRndPct, couponRule.step, msg.sender, s_nonce
        );

        ICoupons.CouponTicket memory couponTicket = ICoupons.CouponTicket(
            msg.sender, multiplierPct, false
        );
        s_couponTickets[contractAddress][raffleId][couponHash] = couponTicket;
        emit CouponPurchase(couponKey, couponTicket, s_nonce);
        s_nonce += 1;
    }

    function useCoupon(
        bytes32 couponHash,
        address playerAddress,
        uint32 raffleId
    ) public override returns (ICoupons.Coupon memory) {
        address contractAddress = msg.sender;
        ICoupons.Coupon memory coupon = _getCoupon(couponHash, playerAddress, contractAddress, raffleId);
        if (coupon.isPaid) {
            s_couponTickets[contractAddress][raffleId][couponHash].used = true;
        }
        emit CouponUsed(couponHash, playerAddress, contractAddress, raffleId);
        return coupon;
    }

    function withdraw() public onlyOwner {
        (bool safeTxSuccess, ) = s_safeAddress.call{value: address(this).balance}("");
        if (!safeTxSuccess) {
            revert Coupons__TransferToSafeFailed();
        }
    }

    /** Getters **/
    function getVersion() public pure returns (string memory) {
        return VERSION;
    }

    function getCouponRule(address contractAddress) public view returns (CouponRule memory) {
        return s_couponRule[contractAddress];
    }

    function getCouponTicket(
        address contractAddress,
        uint32 raffleId,
        bytes32 couponHash
    ) external view override returns (ICoupons.CouponTicket memory) {
        return s_couponTickets[contractAddress][raffleId][couponHash];
    }

    function getNumberOfCouponTickets(
        address contractAddress,
        uint32 raffleId,
        address playerAddress
    ) external view returns (uint16) {
        return s_nCouponTickets[contractAddress][raffleId][playerAddress];
    }

    function getSafeAddress() public view returns (address payable) {
        return s_safeAddress;
    }

    /** Setters **/
    function setCouponRule(address contractAddress, ICoupons.CouponRule memory couponRule) external onlyOwner {
        if (couponRule.couponFee == 0) {
            revert Coupons__ZeroCouponFee();
        }
        // MinRndPct < MaxRndPct <= 500
        if (couponRule.maxRndPct > 500) {
            revert Coupons__OutOfMaxRndPctLimit();
        }
        if (couponRule.minRndPct >= couponRule.maxRndPct) {
            revert Coupons__BadOrderOfRndMinMax();
        }
        // 0 < step <= max-min
        if (couponRule.step == 0 || couponRule.step > (couponRule.maxRndPct - couponRule.minRndPct)) {
            revert Coupons__StepOutOfRange();
        }
        s_couponRule[contractAddress] = couponRule;
        emit CouponRuleUpdated(contractAddress);
    }

    function setSafeAddress(address payable safeAddress) external onlyOwner {
        s_safeAddress = safeAddress;
    }

    function changeOwner(address owner) external onlyOwner {
        s_owner = owner;
    }

    /** Modifiers **/
    modifier onlyOwner() {
        require(msg.sender == s_owner, 'Only owner allowed');
        _;
    }

    /** Utils **/
    function _round(uint x, uint y) public pure returns (uint) {
        // Rounding X to nearest multiple of Y
        return ((x + y / 2) / y) * y;
    }

    function _getPseudoRandomPct(uint16 minRndPct, uint16 maxRndPct, address playerAddress, uint nonce) public view
    returns (uint16 randomPct) {
        uint16 rangeLength = maxRndPct - minRndPct + 1;
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, playerAddress, nonce)));
        randomPct = uint16(randomNumber % rangeLength) + minRndPct;
    }

    function _getRoundedRandomPct(
        uint16 minRndPct,
        uint16 maxRndPct,
        uint16 step,
        address playerAddress,
        uint nonce
    ) public view returns (uint16 roundedRandomPct) {
        uint16 randomPct = _getPseudoRandomPct(minRndPct, maxRndPct, playerAddress, nonce);
        roundedRandomPct = uint16(_round(randomPct, step));
        // console.log('_getRoundedRandomPct: nonce=%s, timestamp=%s, difficulty=%s', nonce, block.timestamp, block.difficulty);
        // console.log('                      randomPct=%s, roundedPct=%s,  playerAddress=%s', randomPct, roundedRandomPct, playerAddress);
    }

    function _toString(bytes memory data, bool with0x) public pure returns (string memory) {
        bytes memory alphabet = "0123456789ABCDEF";
        bytes memory str = new bytes(data.length * 2);
        for (uint i = 0; i < data.length; i++) {
            str[i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[1 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        if (with0x) {
            return string(abi.encodePacked('0x', str));
        } else {
            return string(str);
        }
    }

    function _getPaidCouponKey(address playerAddress, address contractAddress, uint32 raffleId, uint32 ticketId)
    public pure returns (string memory){
        return string(abi.encodePacked(
                _toString(abi.encodePacked(playerAddress), false), '-',
                _toString(abi.encodePacked(contractAddress), false), '-',
                Strings.toString(raffleId), '-',
                Strings.toString(ticketId)
            ));
    }

    function getKeyHash(string memory key) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(key));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface ICoupons{

    struct Coupon {
        bytes32 couponHash;
        uint8 minPct;
        uint8 maxPct;
        uint16 multiplierPct;
        bool isPaid;
    }

    struct CouponRule {
        uint16 minRndPct;
        uint16 maxRndPct;
        uint16 step;
        uint256 couponFee;
    }

    struct CouponTicket {
        address playerAddress;
//        uint32 timestamp;
//        uint32 nonce;
        uint16 multiplierPct;
        bool used;
    }

    function getCoupon(
        bytes32 couponHash,
        address playerAddress,
        address contractAddress,
        uint32 raffleId
    ) external view returns (Coupon memory);

    function buyCoupon(
        address contractAddress,
        uint32 raffleId
    ) external payable;

    function useCoupon(
        bytes32 couponHash,
        address playerAddress,
        uint32 raffleId
    ) external returns (Coupon memory);

    function getCouponTicket(
        address contractAddress,
        uint32 raffleId,
        bytes32 couponHash
    ) external returns (CouponTicket memory);
}