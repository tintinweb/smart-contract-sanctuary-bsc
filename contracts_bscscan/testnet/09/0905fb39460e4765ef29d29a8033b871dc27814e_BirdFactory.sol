/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: tt.sol


pragma solidity ^0.8.0;



contract BirdFactory is Ownable {
    address[] public allowedTokens;
    IERC20 public potoToken;
    uint256 potoPrice; // could be array

    constructor(address _POTOTokenAddress) public {
        potoToken = IERC20(_POTOTokenAddress);
    }

    //modify-- event NewZombie(uint zombieId, string name, uint dna);
    event NewBird(uint256 birdID, string name, uint256 dna);
    uint256 dnaDigits = 20;
    uint256 dnaModulus = 10**dnaDigits;
    uint256 cooldownTime = 1 minutes;

    struct Bird {
        string name;
        string gene; //  5 type
        uint256 dna;
        uint256 level;
        uint256 readyTime; // block.timestamp
        uint256 pvpReadytime; // block.timestamp
        uint256 attack;
        uint256 defence;
        uint256 health;
        uint256 specialPower;
        uint256 pvpEnergy; // 4
        uint256 arenaEnergy; // 4
    }
    Bird[] public birds;
    // address that owns a zombie ( add zombie name or somthing else)
    mapping(uint256 => address) public birdToOwner;
    //track of how many zombies an owner has
    mapping(address => uint256) public ownerBirdCount;

    modifier onlyOwnerOf(uint256 _birdId) {
        require(msg.sender == birdToOwner[_birdId]);
        _;
    }

    function _createBird(
        string memory _name,
        string memory _gene,
        uint256 _dna,
        uint256 _attack,
        uint256 _defence,
        uint256 _health
    ) internal {
        // in this line we can intialize birds struct
        birds.push(
            Bird(
                _name,
                _gene,
                _dna,
                0,
                block.timestamp,
                block.timestamp,
                _attack,
                _defence,
                _health,
                0,
                4,
                4
            )
        );
        uint256 id = birds.length - 1;
        // mapping
        birdToOwner[id] = msg.sender;
        ownerBirdCount[msg.sender]++;
        emit NewBird(id, _name, _dna);
    }

    // _str mitavanad esm bashad
    function _generateRandomDna(string memory _str)
        private
        view
        returns (uint256)
    {
        // modify _str and add other feature ( attack , defence...)
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    _str,
                    block.timestamp,
                    msg.sig
                )
            )
        );
        return rand % dnaModulus;
    }

    function _generateGene(uint256 _randDna) internal returns (uint256) {
        uint256 whichGene = _randDna / (10**18);
        uint256 randomGene;
        if (whichGene < 40) {
            randomGene = 1;
        } else if (whichGene < 65) {
            randomGene = 2;
        } else if (whichGene < 85) {
            randomGene = 3;
        } else if (whichGene < 95) {
            randomGene = 4;
        } else if (whichGene <= 99) {
            randomGene = 5;
        }
        return randomGene;
    }

    function _generateAttack(uint256 _randGene) internal returns (uint256) {
        uint256 attackPower;
        if (_randGene == 1) {
            attackPower = 9;
        } else if (_randGene == 2) {
            attackPower = 11;
        } else if (_randGene == 3) {
            attackPower = 12;
        } else if (_randGene == 4) {
            attackPower = 14;
        } else if (_randGene == 5) {
            attackPower = 17;
        }
        return attackPower;
    }

    function _generateDefence(uint256 _randGene) internal returns (uint256) {
        uint256 defencePower;
        if (_randGene == 1) {
            defencePower = 9;
        } else if (_randGene == 2) {
            defencePower = 13;
        } else if (_randGene == 3) {
            defencePower = 12;
        } else if (_randGene == 4) {
            defencePower = 15;
        } else if (_randGene == 5) {
            defencePower = 14;
        }
        return defencePower;
    }

    function _generateHealth(uint256 _randGene) internal returns (uint256) {
        uint256 healthPower;
        if (_randGene == 1) {
            healthPower = 15;
        } else if (_randGene == 2) {
            healthPower = 16;
        } else if (_randGene == 3) {
            healthPower = 17;
        } else if (_randGene == 4) {
            healthPower = 18;
        } else if (_randGene == 5) {
            healthPower = 20;
        }
        return healthPower;
    }

    function createRandomBird(
        string memory _name,
        address _token,
        uint256 _amount
    ) public {
        require(tokenIsAllowed(_token), "Token is currently no allowed");
        IERC20(_token).transfer(address(this), _amount); // amount could be = potoPrice
        uint256 randDna = _generateRandomDna(_name);
        uint256 randGene = _generateGene(randDna);
        uint256 randAttack = _generateAttack(randGene);
        string memory geneMaker = (
            randGene == 1 ? "type1" : randGene == 2 ? "type2" : randGene == 3
                ? "type3"
                : randGene == 4
                ? "type4"
                : "type5"
        );
        uint256 randDefence = _generateDefence(randGene);
        uint256 randHealth = _generateHealth(randGene);

        _createBird(
            _name,
            geneMaker,
            randDna,
            randAttack,
            randDefence,
            randHealth
        ); ///************???? */
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function tokenIsAllowed(address _token) public returns (bool) {
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            if (allowedTokens[allowedTokensIndex] == _token) {
                return true;
            }
        }
        return false;
    }

    function setPotoPrice(uint256 _amount)
        external
        onlyOwner
        returns (uint256)
    {
        return potoPrice = _amount;
    }
    /*
    function stakeTokens(uint256 _amount, address _token) public {
        require(_amount > 0, "Amount must be more than 0");
        require(tokenIsAllowed(_token), "Token is currently no allowed");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        updateUniqueTokensStaked(msg.sender, _token);
        stakingBalance[_token][msg.sender] = stakingBalance[_token][msg.sender] + _amount;
        if (uniqueTokensStaked[msg.sender] == 1){
            stakers.push(msg.sender);
        }*/
}