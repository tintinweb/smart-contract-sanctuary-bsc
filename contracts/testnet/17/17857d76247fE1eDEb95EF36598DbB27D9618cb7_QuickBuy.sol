pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;
abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

pragma solidity ^0.8.0;
import "./library/Context.sol";
import "./library/Initializable.sol";
import "./interface/IERC20.sol";
abstract contract Ownable is Context {   
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function ownable(address _newowner) internal{
        _transferOwnership(_newowner);
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

contract QuickBuy is Initializable,Ownable {
    struct Pair {
        address baseToken;
        address pairToken;
        uint totalLiqudity;
        address owner;
        mapping(address=>uint) buyers;
        uint basePrice; 
        uint totalSell;
    }

    mapping(address=>mapping(address=>bool)) private isPairExist;
    mapping(address=>mapping(address=>bytes32)) private pairHash;
    mapping(bytes32=>Pair) private quickpair;

    event QuickPair(address indexed baseToken, address indexed pairToken, address owner, uint price);
    function initialize(address _newowner) external initializer {
        ownable(_newowner);
    }

    function getPairHash(address _basetoken ,address pairToken) internal pure returns (bytes32 _pairHash) {
        _pairHash = keccak256(abi.encode(keccak256("Pair(address baseToken,address pairToken)"), _basetoken , pairToken));   
    }

    function createPair(address _token ,address _pairtoken, uint _amount, uint _price) external  {
        require(IERC20(_token).allowance(msg.sender,address(this))>_amount,"allownace exceed");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        require(!isPairExist[_token][_pairtoken],"!!pair already exist!!");
        isPairExist[_token][_pairtoken] = true;
        isPairExist[_token][_pairtoken] = true; 
        bytes32 _pairHash = getPairHash(_token,_pairtoken);
        pairHash[_token][_pairtoken] =_pairHash;
        quickpair[_pairHash].baseToken =_token;
        quickpair[_pairHash].pairToken =_pairtoken;
        quickpair[_pairHash].totalLiqudity = _amount;
        quickpair[_pairHash].owner = msg.sender;
        quickpair[_pairHash].basePrice = _price;
        emit QuickPair(_token,_pairtoken,msg.sender,_price);
    }

    function addLiqudity(address _token ,address _pairtoken, uint _amount) external payable {
        require(IERC20(_token).allowance(msg.sender,address(this))>_amount,"allownace exceed");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        require(isPairExist[_token][_pairtoken],"!!pair already exist!!");
        bytes32 _pairHash = getPairHash(_token,_pairtoken);
        quickpair[_pairHash].totalLiqudity+=_amount;
    }


    function buyTokensForTokens(bytes32 _pairHash, uint _amount) external {
        Pair storage pair = quickpair[_pairHash];
        require(IERC20(pair.pairToken).allowance(msg.sender,address(this))>=_amount,"allowance exceed");
        IERC20(pair.pairToken).transferFrom(msg.sender,address(this),_amount);
        uint256 _price = currentPrice(_pairHash);
        _amount/_price;

    }


    function sellTokensForTokens(bytes32 _pairHash, uint _amount) external {
        Pair storage pair = quickpair[_pairHash];
        require(IERC20(pair.pairToken).allowance(msg.sender,address(this))>=_amount,"allowance exceed");
        IERC20(pair.pairToken).transferFrom(msg.sender,address(this),_amount);
        uint256 _price = currentPrice(_pairHash);
        _amount/_price;

    }


    function buyTokensForETH(bytes32 _pairHash, uint _amount) external {
        Pair storage pair = quickpair[_pairHash];
        require(IERC20(pair.pairToken).allowance(msg.sender,address(this))>=_amount,"allowance exceed");
        IERC20(pair.pairToken).transferFrom(msg.sender,address(this),_amount);
        uint256 _price = currentPrice(_pairHash);
        _amount/_price;

    }


    function sellTokensForETH(bytes32 _pairHash, uint _amount) external {
        Pair storage pair = quickpair[_pairHash];
        require(IERC20(pair.pairToken).allowance(msg.sender,address(this))>=_amount,"allowance exceed");
        IERC20(pair.pairToken).transferFrom(msg.sender,address(this),_amount);
        uint256 _price = currentPrice(_pairHash);
        _amount/_price;

    }

    function currentPrice(bytes32 _hash) public view returns (uint256) {
        uint decimals = IERC20(quickpair[_hash].pairToken).decimals();
        uint256 percentSell = getSellPercent(_hash);
        return (quickpair[_hash].basePrice+((quickpair[_hash].basePrice*percentSell)/100))/(10**decimals);
    }


    function getSellPercent(bytes32 _hash) public view returns (uint256) {
        uint256 ttlTokenRealsed = quickpair[_hash].totalSell;
        uint256 percentSell;
        uint decimals = IERC20(quickpair[_hash].pairToken).decimals();
        if (ttlTokenRealsed != 0) percentSell = ((ttlTokenRealsed*100)*(10**decimals))/(quickpair[_hash].totalLiqudity);
        return percentSell;
    }
}