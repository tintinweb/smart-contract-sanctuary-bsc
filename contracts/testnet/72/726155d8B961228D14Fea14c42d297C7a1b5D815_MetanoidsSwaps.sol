/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: PRIVATE


pragma solidity 0.8.0; 

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

interface IOwnable {
    function manager() external view returns (address);

    function renounceManagement() external;

    function pushManagement(address newOwner_) external;

    function pullManagement() external;
}

interface IMetanoidsMigration {
    function migrateData() external; 
}


contract Ownable is IOwnable {
    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);
    event ContractMigrated(address newContract);

    constructor() {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function manager() public view override returns (address) {
        return _owner;
    }

    modifier onlyManager() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceManagement() public virtual override onlyManager {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushManagement(address newOwner_) public virtual override onlyManager {
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed(_owner, newOwner_);
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require(msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled(_owner, _newOwner);
        _owner = _newOwner;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MetanoidsSwaps is Ownable{

    using SafeMath for uint256;

    //Public variables

    mapping(address => uint256) public meta_swapped;
    mapping(address => uint256) public ingame_swapped;
    mapping(address => bool) public failsafe; 
    mapping(string => address) public registered_data;
    mapping(address => bool) public registered_users;


    uint256 public conversion_rate;
    uint256 public tax_rate;
    IERC20 public token;
    address tax_distribution;

        constructor(){
                tax_distribution = msg.sender;
                tax_rate = 1;
                conversion_rate = 1;
        }

        function setToken(IERC20 _token) public onlyManager {
            token = _token;
        }

        //Called for every user before he can interact with the contract
        function register(string memory identifier) public {
            registered_data[identifier] = msg.sender; 
            registered_users[msg.sender] = true;
        }

        //Swap from Metanoids Token to InGame Token
        function swapMeta(uint256 value) public onlyRegistered {
                require(failsafe[msg.sender] == false, "Metanoids : User Blacklisted, reach out the support");
                meta_swapped[msg.sender] = meta_swapped[msg.sender] + value;
                require(token.transferFrom(msg.sender, address(this), value), "Metanoids : Unable to proceed to the transfer");
                require(token.transfer(tax_distribution, value.div(tax_rate)), "Metanoids : Impossible to transfer the taxes");

        }

        //Swap from InGame Token to Metanoids Token
        function swapInGame(uint256 value) public onlyRegistered {
                require(failsafe[msg.sender] == false, "Metanoids : User Blacklisted, reach out the support");
                ingame_swapped[msg.sender] = ingame_swapped[msg.sender] + value;
                require(token.transfer(msg.sender, value.div(conversion_rate)));
        }

        //Sets the conversion rate (How much InGame tokens for X Meta)
          function setConversionRate(uint256 _rate) public onlyManager {
              require(_rate >= 0, "Metanoids : Unallowed operation");
                conversion_rate = _rate;
            }

        //Sets the tax rate (Division value)
             function setTaxRate(uint256 _rate) public onlyManager {
                require(_rate >= 0, "Metanoids : Unallowed operation");
                tax_rate = _rate;
            }

        //Removes a blacklist from an user
            function removeFailsafe(address user) public onlyManager {
                failsafe[user] = false;
            }

        //Adds a blacklist to an user
              function setFailsafe(address user) public onlyManager {
                failsafe[user] = true;
            }

        //Sets the wallet where the eventual taxes are distributed
            function setTaxWallet(address wallet) public onlyManager {
                tax_distribution = wallet;
            }

        //Allows to recoved any token sent by mistake except Meta Tokens
              function recoverLostToken(address _token) onlyManager external returns (bool) {
                  require(IERC20(_token) != token, "Metanoids : Unallowed Operation");
                IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
                 return true;
         }

        //Upgrade the contract to other versions & warns the blockchain;
              function upgradeContract(address upgraded) public onlyManager {
                    require(isContract(upgraded), "MetanoidsMigration : Reciever is not a contract");
                IMetanoidsMigration(upgraded).migrateData();
                IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
                emit ContractMigrated(upgraded);
              }



    //Tells us if we are in presence of a contract
    function isContract(address addr) internal returns (bool) {
         uint size;
         assembly { size := extcodesize(addr) }
         return size > 0;
    }


        //Allows only the registered users to interact
  modifier onlyRegistered() {
        require(registered_users[msg.sender] == true, "Metanoids : This address is not registered");
        _;
    }


}