pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract KawaiiCheckNFT721 is Ownable {

    mapping(uint256 => bool) public checkInvalidNFT;
    mapping(address => bool) public  whiteList;
    mapping(address => bool) public canCheck;

    constructor() public {
        canCheck[msg.sender] = true;
    }

    function setWhiteList(address _account, bool _status) public onlyOwner {
        whiteList[_account] = _status;
    }

    function setValidNFT(uint256 _tokenId, bool _status) public onlyOwner {
        checkInvalidNFT[_tokenId] = _status;
    }

    function setCanCheck(address _account, bool _status) public onlyOwner {
        canCheck[_account] = _status;
    }

    function check(address _from, address _to, uint256 _id) external {
        require(canCheck[msg.sender], "Must have permission check");

        if (!whiteList[_from] && !whiteList[_to]) {
            checkInvalidNFT[_id] = true;
        }
    }
}