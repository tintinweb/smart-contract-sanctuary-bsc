/**
 *Submitted for verification at BscScan.com on 2022-10-22
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

// File: contracts/House_Wallet.sol


pragma solidity ^0.8.7;


contract Multiple_Transaction is Ownable {
    uint256 playerFee;
    uint256 bossFee;
    uint256 ownerFee;
    uint256 gangsterFee;
    uint256 housewalletFee;
    uint256 betValue;

    address Fee_Wallet;
    address Boss_Address;
    address Housewallet_Address;
    address Owner_Address;

    address[] shootA;

    constructor(
        address _Housewallet,
        address _Fee_Wallet,
        address _Owner_Address,
        address _Boss_Address
    ) {
        setHousewallet_Address(_Housewallet);
        setFee_Wallet(_Fee_Wallet);
        setOwner_Address(_Owner_Address);
        setBoss_Address(_Boss_Address);
    }

    receive() external payable {}

    function flip(uint256 card, uint256 _bet) external payable {
        require(0.7 * 10**18 >= msg.value && 0.005 * 10**18 <= msg.value);

        if (card == 0) {
            playerFee = ((msg.value * 25) / 1025);
            betValue = (msg.value - playerFee);
            bossFee = ((betValue * 15) / 1015);
            gangsterFee = ((betValue * 5) / 1005);
            ownerFee = ((betValue * 3) / 1003);
        } else if (card == 1) {
            playerFee = ((msg.value * 24) / 1024);
            betValue = (msg.value - playerFee);
            bossFee = ((betValue * 14) / 1014);
            gangsterFee = ((betValue * 5) / 1005);
            ownerFee = ((betValue * 3) / 1003);
        } else if (card == 2) {
            playerFee = ((msg.value * 21) / 1021);
            betValue = (msg.value - playerFee);
            bossFee = ((betValue * 13) / 1013);
            gangsterFee = ((betValue * 4) / 1004);
            ownerFee = ((betValue * 3) / 1003);
        } else if (card == 3) {
            playerFee = ((msg.value * 15) / 1015);
            betValue = (msg.value - playerFee);
            bossFee = ((betValue * 9) / 1009);
            gangsterFee = ((betValue * 3) / 1003);
            ownerFee = ((betValue * 2) / 1002);
        } else if (card == 4) {
            playerFee = ((msg.value * 9) / 1009);
            betValue = (msg.value - playerFee);
            bossFee = ((betValue * 5) / 1005);
            gangsterFee = ((betValue * 2) / 1002);
            ownerFee = ((betValue * 1) / 1001);
        } else if (card == 5) {
            playerFee = ((msg.value * 2) / 1002);
            betValue = (msg.value - playerFee);
            bossFee = ((betValue * 12) / 10012);
            gangsterFee = ((betValue * 4) / 10004);
            ownerFee = ((betValue * 24) / 100024);
        }
        housewalletFee = (msg.value - playerFee);
        shootA.push(msg.sender);
        send(_bet);
    }

    function send(uint256 _bet) private {
        if (_bet != 2) {
            housewalletFee = (msg.value - playerFee);
            payable(Fee_Wallet).transfer(bossFee);
            payable(Boss_Address).transfer(gangsterFee);
            payable(Owner_Address).transfer(ownerFee);
            payable(Housewallet_Address).transfer(address(this).balance);
        }
    }

    function setHousewallet_Address(address _Housewallet_Address)
        public
        onlyOwner
    {
        Housewallet_Address = _Housewallet_Address;
    }

    function setFee_Wallet(address _Fee_Wallet) public onlyOwner {
        Fee_Wallet = _Fee_Wallet;
    }

    function setBoss_Address(address _Boss_Address) public onlyOwner {
        Boss_Address = _Boss_Address;
    }

    function setOwner_Address(address _Owner_Address) public onlyOwner {
        Owner_Address = _Owner_Address;
    }
}