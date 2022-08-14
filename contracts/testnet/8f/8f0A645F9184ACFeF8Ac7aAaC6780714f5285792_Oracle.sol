//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IPresaleDatabase {
    function presaleInfo(address sale) external view returns (
        uint256 hardCap,
        uint256 presaleDuration,
        uint256 minContribution,
        uint256 maxContribution,
        uint256 exchangeRate,
        uint256 liquidityRate,
        address backingToken,
        address presaleToken,
        address DEX,
        address saleOwner
    );
    function presaleData(address sale) external view returns (
        bool isApprovedSale,
        bool hasStarted,
        bool hasEnded,
        uint256 amountRaised,
        uint256 presaleFee,
        uint256 timeStarted,
        uint256 timeFinished,
        uint256 pendingIndex,
        uint256 liveIndex
    );
    function saleData(address sale) external view returns (
        bool hasEnded,
        uint256 raised,
        uint256 hardCap,
        address backing,
        address token,
        address dex,
        uint256 timeStarted
    );

    function getHardCap(address sale) external view returns (uint256);
}

interface ISale {
    function totalValueRegistered() external view returns (uint256);
}
contract Oracle {

    IPresaleDatabase public database;

    constructor(
        address db_
    ) {
        database = IPresaleDatabase(db_);
    }

    /**
        hardCap: string;
        presaleDuration: number;
        minContribution: string;
        maxContribution: string;
        exchangeRate: string;
        liquidityRate: string;
        backingToken: string;
        presaleToken: string;
        valueGenerated: string;
        DEX: string;
        saleOwner: string;
        hasStarted: boolean;
        hasEnded: boolean;
        amountRaised: string;
        timeStarted: number;
        timeFinished: number;
     */
    function getPresaleInitialInfo(address sale) public view returns (
        uint256 hardCap,
        uint256 presaleDuration,
        uint256 minContribution,
        uint256 maxContribution,
        uint256 exchangeRate,
        uint256 liquidityRate,
        address backingToken,
        address presaleToken,
        address DEX,
        address saleOwner
    ) {
        return database.presaleInfo(sale);
    }

    function getLivePresaleInfo(address sale) public view returns (
        uint256 valueGenerated,
        bool hasStarted,
        bool hasEnded,
        uint256 amountRaised,
        uint256 timeStarted,
        uint256 timeFinished
    ) {
        valueGenerated = ISale(sale).totalValueRegistered();

        (
            ,
            hasStarted,
            hasEnded,
            amountRaised,
            ,
            timeStarted,
            timeFinished,
            ,
        ) = database.presaleData(sale);
    }

    function getPresaleTokenInfo(address sale) public view returns (
        address backingToken,
        address presaleToken,
        uint8 backingTokenDecimals,
        uint8 presaleTokenDecimals,
        string memory backingTokenSymbol,
        string memory presaleTokenSymbol
    ) {

        (
            ,
            ,
            ,
            ,
            ,
            ,
            backingToken,
            presaleToken,
            ,
        ) = database.presaleInfo(sale);

        backingTokenDecimals = IERC20(backingToken).decimals();
        presaleTokenDecimals = IERC20(presaleToken).decimals();
        backingTokenSymbol = IERC20(backingToken).symbol();
        presaleTokenSymbol = IERC20(presaleToken).symbol();
    }

    function fetchCompletionPercent(address sale) public view returns (
        uint256 amountRaised,
        uint256 hardCap
    ) {

        (
            ,
            bool hasStarted,
            bool hasEnded,
            uint256 amountR,
            ,
            ,
            ,
            ,
        ) = database.presaleData(sale);

        hardCap = database.getHardCap(sale);

        if (hasEnded) {
            amountRaised = amountR;
        }
        if (hasStarted) {
            amountRaised = ISale(sale).totalValueRegistered();
        }
    }

    function getPresaleInitialInfoJson(address sale, string[] calldata keys) external view returns (
        string memory json
    ) {

        (uint256 hardCap,
        uint256 presaleDuration,
        uint256 minContribution,
        uint256 maxContribution,
        uint256 exchangeRate,
        uint256 liquidityRate,
        address backingToken,
        address presaleToken,
        address DEX,
        address saleOwner) = getPresaleInitialInfo(sale);

        string[] memory values = new string[](10);
        values[0] = uint2str(hardCap);
        values[1] = uint2str(presaleDuration);
        values[2] = uint2str(minContribution);
        values[3] = uint2str(maxContribution);
        values[4] = uint2str(exchangeRate);
        values[5] = uint2str(liquidityRate);
        values[6] = toString(backingToken);
        values[7] = toString(presaleToken);
        values[8] = toString(DEX);
        values[9] = toString(saleOwner);

        json = toJsonPrivate(keys, values);
        delete values;
    }

    function getLivePresaleInfoJson(address sale, string[] calldata keys) external view returns (
        string memory json
    ) {

        (uint256 valueGenerated,
        bool hasStarted,
        bool hasEnded,
        uint256 amountRaised,
        uint256 timeStarted,
        uint256 timeFinished) = getLivePresaleInfo(sale);

        string[] memory values = new string[](6);
        values[0] = uint2str(valueGenerated);
        values[1] = hasStarted ? "true" : "false";
        values[2] = hasEnded ? "true" : "false";
        values[3] = uint2str(amountRaised);
        values[4] = uint2str(timeStarted);
        values[5] = uint2str(timeFinished);

        json = toJsonPrivate(keys, values);
        delete values;
    }

    function getPresaleTokenInfoJson(address sale, string[] calldata keys) external view returns (
        string memory json
    ) {

        (address backingToken,
        address presaleToken,
        uint8 backingTokenDecimals,
        uint8 presaleTokenDecimals,
        string memory backingTokenSymbol,
        string memory presaleTokenSymbol) = getPresaleTokenInfo(sale);

        string[] memory values = new string[](6);
        values[0] = toString(backingToken);
        values[1] = toString(presaleToken);
        values[2] = uint2str(uint(backingTokenDecimals));
        values[3] = uint2str(uint(presaleTokenDecimals));
        values[4] = backingTokenSymbol;
        values[5] = presaleTokenSymbol;

        json = toJsonPrivate(keys, values);
        delete values;
    }

    function fetchCompletionPercentJson(address sale, string[] calldata keys) external view returns (
        string memory json
    ) {

        (uint one, uint two) = fetchCompletionPercent(sale);

        uint256[] memory values = new uint256[](2);
        values[0] = one;
        values[1] = two;

        json = toJsonWithUints(keys, values);
        delete values;
    }


    function toJsonPrivate(string[] calldata keys, string[] memory values) internal pure returns (string memory) {

        string memory start = '{';
        string memory end = '}';
        string memory mid = ": ";
        string memory comma = ',';
        string memory quote = '"';

        uint length = keys.length;
        for (uint i = 0; i < length;) {

            start = string.concat(start, quote);
            start = string.concat(start, keys[i]);
            start = string.concat(start, quote);
            start = string.concat(start, mid);
            start = string.concat(start, quote);
            start = string.concat(start, values[i]);
            start = string.concat(start, quote);
            if (i < length - 1) {
                start = string.concat(start, comma);
            }

            unchecked { ++i; }
        }
        return string.concat(start, end);
    }

    function toJsonWithUints(string[] memory keys, uint256[] memory values) public pure returns (string memory) {

        string memory start = '{';
        string memory end = '}';
        string memory mid = ": ";
        string memory comma = ',';
        string memory quote = '"';

        uint length = keys.length;
        for (uint i = 0; i < length;) {

            start = string.concat(start, quote);
            start = string.concat(start, keys[i]);
            start = string.concat(start, quote);
            start = string.concat(start, mid);
            start = string.concat(start, quote);
            start = string.concat(start, uint2str(values[i]));
            start = string.concat(start, quote);
            if (i < length - 1) {
                start = string.concat(start, comma);
            }

            unchecked { ++i; }
        }
        return string.concat(start, end);
    }

    function toJson(string[] calldata keys, string[] calldata values) public pure returns (string memory) {

        string memory start = '{';
        string memory end = '}';
        string memory mid = ": ";
        string memory comma = ',';
        string memory quote = '"';

        uint length = keys.length;
        for (uint i = 0; i < length;) {

            start = string.concat(start, quote);
            start = string.concat(start, keys[i]);
            start = string.concat(start, quote);
            start = string.concat(start, mid);
            start = string.concat(start, quote);
            start = string.concat(start, values[i]);
            start = string.concat(start, quote);
            if (i < length - 1) {
                start = string.concat(start, comma);
            }

            unchecked { ++i; }
        }
        return string.concat(start, end);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function toString(address account) public pure returns(string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) public pure returns(string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes32 value) public pure returns(string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) public pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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