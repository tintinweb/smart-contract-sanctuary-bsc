/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
  

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function decimals() external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

contract WeddingAirdrop is Ownable {
    IBEP20 public Token;
    string[] guests;
    string[] claimedGuest;
    uint256 length = 0;
    uint256 amountAirdrop = 1000000000000000000000; // 1000 tokens - decimal: 18

    mapping(string => uint) guestIndex;
    address payable private sender;


     // constructor
    constructor(
        address _token
    ) {
        Token = IBEP20(_token);
        sender = payable(msg.sender);
    }

    function addGuests(string[] memory _guests) public onlyOwner {
        for(uint256 i = 0; i < _guests.length; i++) {
            guests.push(_guests[i]);
            guestIndex[_guests[i]] = length++;
        }
    }

    function getUnclaimGuests() public view returns (string[] memory) {
        return guests;
    }

    function claim(string calldata name) public {
        require(keccak256(abi.encodePacked((guests[guestIndex[name]]))) 
        == keccak256(abi.encodePacked((name))), "You have already claimed");
        Token.transferFrom(sender, msg.sender, amountAirdrop);
        guests[guestIndex[name]] = " ";
        claimedGuest.push(name);
    }

    function changeToken(address _token) public onlyOwner {
        Token = IBEP20(_token);
    }

    function getAirdrop() public view returns (uint256) {
        return amountAirdrop;
    }

    function getClaimedGuests() public view returns (string[] memory) {
        return claimedGuest;
    }

    function setSender(address payable  _sender) public onlyOwner {
        sender = payable(_sender);
    }
   
}