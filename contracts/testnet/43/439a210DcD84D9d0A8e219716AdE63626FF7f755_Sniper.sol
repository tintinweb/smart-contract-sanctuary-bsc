/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

pragma solidity ^0.8.10;

interface IMarketplace {

    function buyTokenUsingBNB(address _collection, uint256 _tokenId) external payable;
    function createAskOrder(address _collection, uint256 _tokenId, uint256 _askPrice) external;
    function modifyAskOrder(address _collection, uint256 _tokenId, uint256 _newPrice) external;

}

interface IPancakesquad {

    function approve(address to, uint256 tokenId) external;
    
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

contract Sniper {

    using SafeMath for uint256;

    uint256 internal authorizationsNumber;
    uint256 internal initialBalance;
    uint256 internal profit;
    address internal immutable operator;
    bool internal withdrawAuthorized = false;
    IPancakesquad internal Pancakesquad = IPancakesquad(0x0a8901b0E25DEb55A87524f0cC164E9644020EBA);
    IMarketplace internal Marketplace = IMarketplace(0x17539cCa21C7933Df5c980172d22659B8C345C5A);


    struct Owner {
        uint8 id;
        bool isOwner;
        bool profitPaid;
        bool authorizedWithdraw;
        bool authOps;
    }

    mapping (address => Owner) owners;
    mapping (address => uint256) balances;

    constructor(address _owner1, address _owner2, address _owner3, address _owner4, address _owner5, address _operator) {
        Owner memory owner = Owner(1, true, false, false, true);
        owners[_owner1] = owner;
        owner = Owner(2, true, false, false, true);
        owners[_owner2] = owner;
        owner = Owner(3, true, false, false, false);
        owners[_owner3] = owner;
        owner = Owner(4, true, false, false, false);
        owners[_owner4] = owner;
        owner = Owner(5, true, false, false, false);
        owners[_owner5] = owner;
        operator = _operator;
    }

    modifier onlyAuthorized {
        require(withdrawAuthorized, 'Withdraw non autorizzato');
        _;
    }

    modifier onlyOwners {
        require(owners[msg.sender].isOwner, "!owner");
        _;
    }

    modifier onlyOperator {
        require(msg.sender == operator, "!operator");
        _;
    }

    function authWithdraw() public onlyOwners {
        if (owners[msg.sender].authOps) {
            withdrawAuthorized = true;
        } else {
            Owner storage owner = owners[msg.sender];
            if (owner.authorizedWithdraw) {
                return;
            } else {
                owner.authorizedWithdraw = true;
                authorizationsNumber++;
                if (authorizationsNumber >= 4) {
                    withdrawAuthorized = true;
                }
            }
        }
    }

    function deposit() public payable {
        require(msg.value >= 0.5 ether, 'Deposito minimo: 5 BNB');
        balances[msg.sender] += msg.value;
        initialBalance += msg.value;
    }

    function withdraw() public onlyOwners onlyAuthorized {
        uint256 _amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(_amount);
    }

    function snipe(uint256 _price, uint256 _tokenId) public onlyOperator {
        (bool success, ) = address(Marketplace).call{value: _price}(abi.encodeWithSignature("buyTokenUsingBNB(address, uint256)", address(Pancakesquad), _tokenId)); 
        require(success, "snipe fallito");
    }

    function placeOrder(uint256 _price, uint256 _tokenId) public onlyOperator {
        Pancakesquad.approve(address(Marketplace), _tokenId);
        Marketplace.createAskOrder(address(Pancakesquad), _tokenId, _price);
    }

    function modifyOrder(uint256 _newPrice, uint256 _tokenId) public onlyOperator {
        Marketplace.modifyAskOrder(address(Pancakesquad), _tokenId, _newPrice);
    }

    function takeProfit() public onlyOwners onlyAuthorized {
        require(!owners[msg.sender].profitPaid, "profitto pagato");
        if (profit == 0) {
            profit = address(this).balance.sub(initialBalance);
        }
        payable(msg.sender).transfer(profit.div(5));
    }

    // Funzione che permette al contratto di ricevere NFT
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // Funzione che permette al contratto di ricevere BNB
    receive() external payable {}

    // Funzione che cancella il contratto quando non vi e' più bisogno, manda dust all'operator. Chiamare in caso di emergenza
    function endc() external onlyOperator {
        selfdestruct(payable(operator));
    }

}