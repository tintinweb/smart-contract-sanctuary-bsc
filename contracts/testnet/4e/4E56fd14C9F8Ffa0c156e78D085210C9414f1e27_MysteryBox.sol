/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// File: Contracts\openzeppelin-contracts\contracts\utils\Context.sol


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

// File: Contracts\openzeppelin-contracts\contracts\access\Ownable.sol


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

// File: Contracts\FiveTigerMysteryBox.sol

pragma solidity ^0.8.0;


interface IERC721{
    function totalSupply() external returns(uint256);
    function maxSupply() external returns(uint256);
    function mint(address) external;
}

interface IPair{
    function getReserves() external returns(uint256, uint256, uint256);
}

// 0 -> 500
// 0.16 -> 8888
// 0.22 -> 20000
// 0.28 -> 20000
// 0.34 -> 20000
// 2.5 - 22.5 - 25 - 25- 25

contract MysteryBox is Ownable {
    struct Config {
        IERC721 nft;
        uint256 max;
    }
    bytes32 private _seed;
    IPair public pair;
    Config[] public configs;
    uint256 public totalRate;
    uint256 public price;
    mapping(address => bool) public whiteList;
    mapping(address => uint256) public whiteMint;
    uint256 public contractLimit;
    uint256 public perWhiteLimit;
    address payable[] public feeTos;
    uint256[] public feeRates;
    bool public enableWhiteList;
    uint256 public contractMint;
    bool private _lock;
    
    modifier lock(){
        require(!_lock, "MBox:locked");
        _lock = true;
        _;
        _lock = false;
    }
    
    constructor(uint256 _price, IPair _pair, uint256 _contractLimit, uint256 _perWhiteLimit, bool _enableWhiteList, 
        IERC721[] memory nfts, uint256[] memory rates, address payable[] memory _feeTos, uint256[] memory _feeRates) {
        price = _price;
        pair = _pair;
        enableWhiteList = _enableWhiteList;
        contractLimit = _contractLimit;
        perWhiteLimit = _perWhiteLimit;
        setConfigs(nfts, rates);
        setFee(_feeTos, _feeRates);
    }
    
    receive() external payable {}
    
    function rescue() public onlyOwner {
        require(feeTos.length > 0, "MBox:feeTo not set");
        uint256 balance = address(this).balance;
        for(uint256 i = 0; i < feeTos.length - 1; i++){
            feeTos[i].transfer(balance * feeRates[i] / 100);
        }
        feeTos[feeTos.length - 1].transfer(address(this).balance);
    }
    
    function setConfigs(IERC721[] memory nfts, uint256[] memory rates) public onlyOwner {
        require(nfts.length == rates.length, "MBox:length not match");
        delete configs;
        totalRate = 0;
        for(uint256 i = 0; i < nfts.length; i++){
            totalRate += rates[i];
            configs.push(Config(nfts[i], totalRate));
        }
    }
    
    function setWhiteList(address[] memory list, bool enable) public onlyOwner {
        for(uint256 i = 0; i < list.length; i++){
            whiteList[list[i]] =  enable;
        }
    }
    
    function setEnableWhiteList(bool enable) public onlyOwner {
        enableWhiteList = enable;
    }
    
    function setLimit(uint256 thisContract, uint256 perWhite) public onlyOwner {
        contractLimit = thisContract;
        perWhiteLimit = perWhite;
    }
    
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }
    
    function setPair(IPair _pair) public onlyOwner {
        pair = _pair;
    }
    
    function setFee(address payable[] memory _feeTos, uint256[] memory _feeRates) public onlyOwner {
        require(_feeTos.length == _feeRates.length, "MBox:length not match");
        feeTos = _feeTos;
        feeRates = _feeRates;
    }
    
    function _rand(uint256 max) internal returns(uint256) {
        (uint256 r0, uint256 r1,) = pair.getReserves();
        _seed = keccak256(abi.encodePacked(_seed, msg.sender, blockhash(block.number-1), block.timestamp, block.difficulty, block.coinbase, r0, r1));
        return uint256(_seed) % max;
    }
    
    function _mint() internal {
        uint256 r = _rand(totalRate);
        for(uint256 i = 0; i < configs.length; i++){
            if(r < configs[i].max && configs[i].nft.totalSupply() < configs[i].nft.maxSupply()){
                configs[i].nft.mint(msg.sender);
                break;
            }
            if(i == configs.length - 1){
                require(false, "MBox:not enough nft left");
            }
        }
    }
    
    function getMintNumber(address account) public view returns(uint256) {
        uint256 limit = contractLimit - contractMint;
        if(enableWhiteList){
            uint256 limit1 = perWhiteLimit - whiteMint[account];
            if(limit1 < limit){
                limit = limit1;
            }
        }
        return limit;
    }
    
    function mint(uint256 number) payable public lock {
        require(tx.origin == msg.sender, "MBox:not allowed for contract");
        if(enableWhiteList){
            require(whiteList[msg.sender], "MBox:not in whiteList");
        }
        require(number > 0 && number <= getMintNumber(msg.sender), "MBox:invalid number");
        require(msg.value >= price * number, "MBox:invalid value");
        for(uint256 i = 0; i < number; i++) {
            _mint();
        }
        whiteMint[msg.sender] += number;
        contractMint += number;
        uint256 left = msg.value - price * number;
        if(left > 0){
            payable(msg.sender).transfer(left);
        }
    }
}