/**
 *Submitted for verification at BscScan.com on 2023-01-23
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






pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Team is Ownable {
    IERC20 public immutable usdtToken;//USDT
    mapping(address => address) public relation;
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public below1;
    mapping(address => uint) public below2;
    mapping(address => uint) public below3;
    mapping(address => bool) public white;
    mapping(address => bool) public captain;
    modifier onlyWhite() {
        require(white[msg.sender] == true, "not authorized");
        _;
    }
    constructor() {
        usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
    }


    function bulid(address superior) external{

        require(captain[msg.sender] != true,"captain not below");
        require(relation[msg.sender] == address(0),"you have captain");

        require( captain[superior] == true || relation[superior] != address(0),"superior not be to");

        relation[msg.sender] = superior;

        below1[superior] += 1;

        if(relation[superior] != address(0)){
            below2[relation[superior]] += 1;
        }

        if(relation[relation[superior]] != address(0)){
            below3[relation[relation[superior]]] += 1;
        }


    }


    function setWhit(address[] memory _adr) external onlyOwner{
        for(uint i=0;i<_adr.length;i++){
            white[_adr[i]] = true;
        }

    }


    function setCaptain(address[] memory _adr) external onlyOwner{
        for(uint i=0;i<_adr.length;i++){
            captain[_adr[i]] = true;
        }

    }





    function setBalance(address _adr,uint _num) external onlyWhite{
        uint num1 = _num * 8 / 15;
        uint num2 = _num * 1 / 3;
        uint num3 = _num - num1 - num2;

        if(relation[_adr] != address(0)){
            balanceOf[relation[_adr]] += num1;
        }else{
            balanceOf[owner()] += num1;
        }

        if(relation[relation[_adr]] != address(0)){
            balanceOf[relation[relation[_adr]]] += num2;
        }else{
            balanceOf[owner()] += num2;
        }

        if(relation[relation[relation[_adr]]] != address(0)){
            balanceOf[relation[relation[_adr]]] += num3;
        }else{
            balanceOf[owner()] += num3;
        }





    }

    function withdraw() external{
        uint num = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        if(num > 0){
            usdtToken.transfer(msg.sender,num);
        }
    }


    function isCan(address _adr) public view virtual  returns (bool) {

        return captain[_adr] || relation[_adr] != address(0);
    }


}