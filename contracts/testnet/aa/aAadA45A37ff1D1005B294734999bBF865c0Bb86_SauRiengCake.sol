/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT


// File: @openzeppelin/contracts/utils/Strings.sol


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

// File: contracts/SauRiengCake.sol




// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


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

// File: contracts/SauRiengCake.sol


contract SauRiengCake {
    IERC20 tokenXu;
    IERC20 tokenXeng;
    uint bnbPerXuRatio = 1000000; 
    uint bnbPerXengRatio = 2000000;
    uint xuPerXengRatio = 2;
    uint minXu = 1000; // 0.001 BNB
    uint minXeng = 2000; // 0.001 BNB

    constructor(address tokenXu_Address, address tokenXeng_Address) {
        tokenXu = IERC20(tokenXu_Address);
        tokenXeng = IERC20(tokenXeng_Address);
    }

    function buyXuWithXeng(uint xengAmount) public {
        uint xuAmount = xengAmount / xuPerXengRatio;
        require(tokenXu.balanceOf(address(this)) >= xuAmount, "Sorry, XU balance not enough to transfer!");
        require(xuAmount >= minXu, "Minimum purchase of 1000 XU required!");

        _sellXeng(xengAmount);
        
        tokenXu.transferFrom(address(this), msg.sender, xuAmount); // Send XU
    }

    function _sellXeng(uint xengAmount) internal {
        require(tokenXeng.balanceOf(msg.sender) >= xengAmount * 10**18, "Sorry, you don't have XENG enought to sell");
        
        //require(tokenXeng.allowance(msg.sender, address(this)) >= xengAmount * 10**18, string.concat("Please approve ", Strings.toString(xengAmount), " XENG before sell"));
        tokenXeng.transfer(address(this), xengAmount * 10**18); // Get XENG

        //return xengAmount * 10**18 / bnbPerXengRatio;
    }

    function buyXengWithXu(uint xuAmount) public {
        uint xengAmount = xuAmount * xuPerXengRatio;
        require(tokenXeng.balanceOf(address(this)) >= xengAmount, "Sorry, XENG balance not enough to transfer!");
        require(xengAmount >= minXeng, "Minimum purchase of 2000 XENG required!");

        _sellXu(xuAmount);
        
        tokenXeng.transferFrom(address(this), msg.sender, xengAmount); // Send XENG
    }

    function _sellXu(uint xuAmount) internal {
        require(tokenXu.balanceOf(msg.sender) >= xuAmount * 10**18, "Sorry, you don't have XU enought to sell");
        
        // require(tokenXu.allowance(msg.sender, address(this)) >= xuAmount * 10**18, string.concat("Please approve ", Strings.toString(xuAmount), " XU before sell"));
        tokenXu.transfer(address(this), xuAmount * 10**18); // Get XU

        //return xengAmount * 10**18 / bnbPerXengRatio;
    }
}


// 1: 0x44decC21d0B3C5F466A937D4eB59581EA3A34766
// 2: 0xafb728AC88533E0FE79044cdcb5afe800473B574
// 3: 0x9eB11A5703068B2FBFCDCe1E9EEA0e727a570FF5

// XU: 0x49A33dB6A2e4C3322A107571275eF5CF68504C5c
// XENG: 0xFB14c5a0E2119E3fFA3c7CBd4546e153022A4C5e