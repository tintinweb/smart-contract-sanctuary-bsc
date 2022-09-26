/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract DOXToken {
    using SafeMath for uint256;
    string public constant name = "PRODOX";
    string public constant symbol = "DOX";
    uint8 public constant decimals = 18;
    uint256 public constant tokenPrice = 5;
    uint256 constant gweiNumber = 1e18;
    uint256 private initSupply = 500000000;
    uint256 totalSupply_ = initSupply * gweiNumber;

    address host;

    // testnet
    //2
    address seedSaleWallet = 0x4FCc67786CBA4134BbEe1574bA09c8d312725365;
    uint256 public seedSaleTotal = (7 * initSupply* gweiNumber) / 100;

    //3
    address privateWallet = 0xc80b0Cc46F6CF31ABdC0FAea05867f57118E3F28;
    uint256 public privateTotal = (10 * initSupply* gweiNumber) / 100;

    //4
    address IDOWallet = 0x926137fEc6ced5A1efAb076f5c72E1158f09Bb53;
    uint256 public IDOTotal = (20 * initSupply* gweiNumber) / 100;

    //5
    address airdropWallet = 0xD421F710480Cd2795cC5dAEfa38CB6FF79Ba0ea5;
    uint256 public airdropTotal = (5 * initSupply* gweiNumber) / 100;

    //6
    address marketingWallet = 0xCe85936D593FEF15Ad7aF63501151eDED88Ab86c;
    uint256 public marketingTotal = (15 * initSupply* gweiNumber) / 100;

    //7
    address devWallet = 0xe7feF92961666F38A0366737ff0c98b09Ed9C3E0;
    uint256 public devTotal = (15 * initSupply)* gweiNumber / 100;

    //8
    address reserveSupplyWallet = 0x80B59cdEbcFFf228E3C4Bf17FCe631E0e0309c69;
    uint256 public reserveSupplyTotal = (28 * initSupply* gweiNumber) / 100;

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event IssuerRights(address indexed issuer, bool value);
    event TransferOwnership(address indexed previousOwner, address indexed newOwner);

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    mapping(address => bool) public isIssuer;

    constructor() {
        host = msg.sender;
        emit TransferOwnership(address(0), msg.sender);
        transferOwners(seedSaleWallet, seedSaleTotal);
        transferOwners(privateWallet, privateTotal);
        transferOwners(IDOWallet, IDOTotal);
        transferOwners(airdropWallet, airdropTotal);
        transferOwners(marketingWallet, marketingTotal);
        transferOwners(devWallet, devTotal);
        transferOwners(reserveSupplyWallet, reserveSupplyTotal);
    }

    modifier restricted() {
        require(msg.sender == host, "This function is restricted to host");
        _;
    }
    modifier issuerOnly() {
        require(isIssuer[msg.sender], "You do not have issuer rights");
        _;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function transferOwners(address receiver, uint256 amount) public {
        uint256 tokenAmount = amount;
        balances[receiver] = balances[receiver].add(tokenAmount);
        emit Transfer(msg.sender, receiver, amount);
    }


    function getOwner() public view returns (address) {
        return host;
    }

    function mint(address _to, uint256 _amount) public issuerOnly returns (bool success) {
        require(_amount > 0, "Invalid token amount");
        uint256 amount = _amount ;
        totalSupply_ += amount;
        balances[_to] = balances[_to].add(amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function burn(uint256 _amount) public issuerOnly returns (bool success) {
        require(_amount > 0, "Invalid token amount");
        uint256 amount = _amount;
        totalSupply_ -= amount;
        balances[msg.sender] = balances[msg.sender].sub(amount);
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function burnFrom(address _from, uint256 _amount) public issuerOnly returns (bool success) {
        require(_amount > 0, "Invalid token amount");
        uint256 amount = _amount;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(amount);
        balances[_from] = balances[_from].sub(amount);
        totalSupply_ -= amount;
        emit Transfer(_from, address(0), amount);
        return true;
    }

    function approve(address delegate, uint256 amount) public {
        allowed[msg.sender][delegate] = amount;
        emit Approval(msg.sender, delegate, amount);
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(_amount > 0, "Invalid token amount");
        uint256 amount = _amount;
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[_to] = balances[_to].add(amount);
        emit Transfer(msg.sender, _to, amount);
        return true;
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 amount
    ) public {
        uint256 tokenAmount = amount;
        require(balances[owner].sub(tokenAmount) >= 0, "Owner token insufficient fund");
        require(tokenAmount <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner].sub(tokenAmount);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(tokenAmount);
        balances[buyer] = balances[buyer].add(tokenAmount);
        emit Transfer(owner, buyer, amount);
    }

    function transferOwnership(address _newOwner) public restricted {
        require(_newOwner != address(0), "Invalid address: should not be 0x0");
        emit TransferOwnership(host, _newOwner);
        host = _newOwner;
    }

    function setIssuerRights(address _issuer, bool _value) public restricted {
        isIssuer[_issuer] = _value;
        emit IssuerRights(_issuer, _value);
    }
}
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