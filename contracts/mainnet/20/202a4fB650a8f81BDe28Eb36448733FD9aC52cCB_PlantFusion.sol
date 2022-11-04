/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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

// File: PlantFusion.sol



pragma solidity ^0.8.0;



interface IHero {
    struct Hero {
        uint8 star;
        uint8 rarity;
        uint8 plantClass;
        uint256 plantId;
        uint256 bornAt;
    }
}

interface ICNFT {
    function mint(address _to, uint8 _star, uint8 _rarity, uint8 _plantClass, uint256 _plantId) external;

    function getNft() external view returns (address);
}

interface IERC721 {
	function ownerOf(uint256 tokenId) external view returns (address owner);

	function transferFrom(address from, address to, uint256 tokenId) external;
}

interface INFT is IERC721, IHero {
	function latestTokenId() external view returns(uint);

	function getHero(uint256 _tokenId) external view returns (Hero memory);

	function getTotalClass() external view returns (uint8);

    function getPlanIds(uint8 _plantClass, uint8 _rarity) external view returns (uint256[] memory);
}

interface IHolyPackage is IERC721 {
    struct Package {
        string holyType;
        uint256 createdAt;
    }

    function getPackage(uint256 _packageId) external returns (Package memory);
}

interface IBEP20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract PlantFusion is Ownable, IHero {
	using SafeMath for uint256;

	ICNFT public cnft;

	IHolyPackage public holyPackage;

	struct Requirement {
		uint8 baseRate;
		uint8 addRate;
		address token;
		uint256 tokenRequire;
		uint8 holyPackageMaxAmount;
	}

	mapping (uint8 => Requirement) public requirements;

	mapping (string => uint8) public plantClasses;

	uint nonce = 0;

	address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public feeAddress = 0x81F403fE697CfcF2c21C019bD546C6b36370458c;

	uint8[] public classList = [1,2,3,4];

	uint8 classBaseRate;

	uint8 classAddRate;

	event Fusion(address indexed user, bool isSuccess, uint256[] heroIds, uint256 _newHeroId);

	constructor(address _cnft, address _holyPackage, uint8 _classBaseRate, uint8 _classAddRate) {
		cnft = ICNFT(_cnft);
		holyPackage = IHolyPackage(_holyPackage);
		classBaseRate = _classBaseRate;
		classAddRate = _classAddRate;
	}

	function fusion(uint256[] memory _heroIds, uint256[] memory _holyPackageIds) external {
		INFT nft = INFT(cnft.getNft());
		uint8 requiredRarity = nft.getHero(_heroIds[0]).rarity;
		require(requiredRarity > 2 && requiredRarity < 5, "require: invalid rariry");
		for (uint256 k = 0; k < _heroIds.length; k++) {
            require(nft.ownerOf(_heroIds[k]) == _msgSender(), "require: must be owner of plants");
			require(nft.getHero(_heroIds[k]).rarity == requiredRarity, "require: must same rariry");
		}
        Requirement memory requirement = requirements[requiredRarity];
		require(requirement.token != address(0), "invalid token");
		uint256 length = _holyPackageIds.length;
		uint8 targetClass = 0;
		if (length > 0) {
			require(length <= requirement.holyPackageMaxAmount, "exceed max holy package amount");
			string memory requiredHolyType = holyPackage.getPackage(_holyPackageIds[0]).holyType;
			for (uint256 i = 0; i < length; i++) {
				require(holyPackage.ownerOf(_holyPackageIds[i]) == _msgSender(), "require: must be owner of holies");
				require(compareStrings(holyPackage.getPackage(_holyPackageIds[i]).holyType, requiredHolyType), "require: wrong holy type");
			}
			for (uint256 i = 0; i < length; i++) {
				holyPackage.transferFrom(_msgSender(), deadAddress, _holyPackageIds[i]);
			}
			targetClass = plantClasses[requiredHolyType];
		}
		uint8 successRate = getSuccessRate(requirement.baseRate, requirement.addRate, length);
		require(successRate <= 100, "invalid");
		IBEP20(requirement.token).transferFrom(_msgSender(), feeAddress, getFee(requiredRarity));
		for (uint256 k = 0; k < _heroIds.length; k++) {
			nft.transferFrom(_msgSender(), deadAddress, _heroIds[k]);
		}
		uint256 randomNumber = getRandomNumber();
		bool isSuccess = randomFusion(randomNumber, successRate);
		uint8 classSuccessRate = getSuccessRate(classBaseRate, classAddRate, length);
		uint8 plantClass = randomClass(randomNumber, classSuccessRate, targetClass);
		uint8 rarity = requiredRarity;
		if (isSuccess) {
			rarity = requiredRarity + 1;
		}
		cnft.mint(_msgSender(), 3, rarity, plantClass, getPlantId(plantClass, rarity, randomNumber));
		emit Fusion(_msgSender(), isSuccess, _heroIds, nft.latestTokenId());
	}

	function getPlantId(uint8 _planClass, uint8 _rarity, uint256 _randomNumber) internal returns (uint256) {
        INFT nft = INFT(cnft.getNft());
        uint256[] memory planIds = nft.getPlanIds(_planClass, _rarity);
        return planIds[_randomNumber.mod(planIds.length)];
    }

	function getFee(uint8 _rarity) public view returns (uint256) {
		Requirement memory requirement = requirements[_rarity];
		return requirement.tokenRequire;
	}

	function getSuccessRate(uint8 _baseRate, uint8 _addRate, uint256 _numberHolyPackage) public view returns (uint8) {
		return uint8(uint256(_baseRate).add(uint256(_addRate).mul(_numberHolyPackage)));
	}

	function randomFusion(uint256 _randomNumber, uint8 _successRate) internal returns (bool) {
        uint seed = _randomNumber % 100;
        if (seed < _successRate) {
            return true;
        }
        return false;
    }

	function randomClass(uint256 _randomNumber, uint8 _successRate, uint8 _targetClass) internal returns (uint8) {
		uint256 totalClass = classList.length;
		uint seed = _randomNumber % 100;
		if (_targetClass == 0) {
			return uint8(_randomNumber.mod(totalClass).add(1));
		}
		if (seed < _successRate) {
			return _targetClass;
		}
		uint8[] memory classes = new uint8[](totalClass.sub(1));
        uint256 count;
		for (uint256 i = 0; i < totalClass; i++) {
			if (classList[i] != _targetClass) {
				classes[count] = classList[i];
                count++;
			}
        }
		return classes[_randomNumber.mod(totalClass.sub(1))];
	}

	function getRandomNumber() internal returns (uint) {
        nonce += 1;
        return uint(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }

	function setRequirement(uint8 _rarity, uint8 _baseRate, uint8 _addRate, address _token, uint256 _tokenRequire, uint8 _holyPackageMaxAmount) external onlyOwner {
        requirements[_rarity] = Requirement({
			baseRate: _baseRate,
			addRate: _addRate,
            token: _token,
            tokenRequire: _tokenRequire,
			holyPackageMaxAmount: _holyPackageMaxAmount
        });
    }

	function setPlanClasses(string memory _holyType, uint8 _planClass) external onlyOwner {
		plantClasses[_holyType] = _planClass;
	}

	function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

	function updateFeeAddress(address _newAddress) external onlyOwner {
        feeAddress = _newAddress;
    }

	function updateClassList(uint8[] memory _classList) external onlyOwner {
		classList = _classList;
	}
}