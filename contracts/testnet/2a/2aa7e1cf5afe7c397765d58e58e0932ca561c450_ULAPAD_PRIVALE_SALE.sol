/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// File: Contracts/ULAPAD-Private-Sale_Contract.sol


pragma solidity 0.8.15;

// SAFE MATH LIBRARY -----------------------------------------------------------

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// CONTEXT ABSTRACT ------------------------------------------------------------

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OWNABLE ABSTRACT ------------------------------------------------------------

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            'Ownable: new owner is the zero address'
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// ULAPAD PRIVALE SALE SMART CONTRACT ------------------------------------------

contract ULAPAD_PRIVALE_SALE is Context, Ownable {
    using SafeMath for uint256;

    // Sale configuration -----------------------------------------------------

    uint256 private _tokenDecimals = 18;

    uint256 private _totalSaleToken = 20000 * 10**_tokenDecimals;

    // --- 1 BNB = 5000 ULAPAD
    uint256 private _tokenSaleRatePerEther = 5000;

    // --- 0.1 BNB
    uint256 private _minContributeAmount = (1 * 10**_tokenDecimals) / 10;

    // --- 0.5 BNB
    uint256 private _maxContributeAmount = (5 * 10**_tokenDecimals) / 10;

    // Sale state --------------------------------------------------------------

    bool public _isSaleOpen = false;

    bool public _isFCFSRoundOpen = false;

    // Whitelist configuration -------------------------------------------------

    mapping(address => uint256) private _whitelistedAddresses;

    // Sold token state --------------------------------------------------------

    uint256 private _totalSoldToken = 0;

    mapping(address => uint256) private _investedAmountByAddresses;

    // Invested data export state ----------------------------------------------

    uint256 private _investedAddressesLength = 0;

    mapping(uint256 => address) private _investedAddresses;

    // Whitelist module - for control whitelisted address ----------------------

    function addMultipleWhitelistedAddresses(
        address[] calldata __addressList,
        uint256[] calldata __maxContributeAmountList
    ) external onlyOwner {
        require(
            __addressList.length == __maxContributeAmountList.length,
            'ULAPAD: Invalid data list'
        );

        for (uint256 i = 0; i < __addressList.length; i++) {
            _whitelistedAddresses[__addressList[i]] = __maxContributeAmountList[
                i
            ];
        }
    }

    function removeMultipleWhitelistedAddresses(
        address[] calldata __addressList
    ) external onlyOwner {
        for (uint256 i = 0; i < __addressList.length; i++) {
            _whitelistedAddresses[__addressList[i]] = 0;
        }
    }

    // Sale control module - for control sale state ----------------------------

    function startSale() external onlyOwner {
        _isSaleOpen = true;
    }

    function startFCFSRound() external onlyOwner {
        _isFCFSRoundOpen = false;
    }

    function endSale() external onlyOwner {
        _isFCFSRoundOpen = false;
        _isSaleOpen = false;
    }

    // DAPP modile - for dapp interactive with contract ------------------------

    function getTotalSoldToken() public view returns (uint256) {
        return _totalSoldToken;
    }

    function isWhitelistedAddresses(address __address)
        public
        view
        returns (bool)
    {
        return _whitelistedAddresses[__address] > 0;
    }

    function getContributableAmount(address __address)
        public
        view
        returns (uint256)
    {
        if (_isFCFSRoundOpen) {
            return
                _maxContributeAmount.add(_whitelistedAddresses[__address]).sub(
                    _investedAmountByAddresses[__address]
                );
        }

        if (isWhitelistedAddresses(__address)) {
            return
                _whitelistedAddresses[__address].sub(
                    _investedAmountByAddresses[__address]
                );
        }

        return 0;
    }

    function getContributedAmount(address __address)
        external
        view
        returns (uint256)
    {
        return _investedAmountByAddresses[__address];
    }

    function getBoughtTokenAmount(address __address)
        external
        view
        returns (uint256)
    {
        return
            _investedAmountByAddresses[__address].mul(_tokenSaleRatePerEther);
    }

    // Invested data export module ---------------------------------------------

    function getTotalInvestedAddresses()
        external
        view
        onlyOwner
        returns (uint256)
    {
        return _investedAddressesLength;
    }

    function getInvestedAmountByIndex(uint256 __index)
        external
        view
        onlyOwner
        returns (uint256)
    {
        address __address = _investedAddresses[__index];
        return _investedAmountByAddresses[__address];
    }

    // Contribute module - for control contributable address -------------------

    receive() external payable {
        require(_isSaleOpen, 'ULAPAD: Sale was not open yet');

        require(
            _totalSoldToken <= _totalSaleToken,
            'ULAPAD: All the token was sold out'
        );

        address __address = _msgSender();

        if (!_isFCFSRoundOpen) {
            require(
                isWhitelistedAddresses(__address),
                'ULAPAD: Address was not in whitelisted'
            );
        }

        uint256 __amount = msg.value;
        uint256 __contributableAmount = getContributableAmount(__address);

        require(
            __amount >= _minContributeAmount,
            'ULAPAD: Invalid contribute amount - hit the minimum'
        );

        require(
            __amount <= __contributableAmount,
            'ULAPAD: Invalid contribute amount - hit the maximum'
        );

        uint256 __tokenAmount = __amount.mul(_tokenSaleRatePerEther);

        require(
            __tokenAmount + _totalSoldToken <= _totalSaleToken,
            'ULAPAD: Invalid contribute amount - no funds left'
        );

        _totalSoldToken = _totalSoldToken.add(__tokenAmount);
        if (_investedAmountByAddresses[__address] == 0) {
            _investedAddressesLength = _investedAddressesLength + 1;
            _investedAddresses[_investedAddressesLength] = __address;
        }
        _investedAmountByAddresses[__address] = _investedAmountByAddresses[
            __address
        ].add(__amount);
    }

    function withdrawEther() public onlyOwner {
        require(
            address(this).balance > 0,
            'ULAPAD: No Ether available to withdraw'
        );

        payable(this).transfer(address(this).balance);
    }
}