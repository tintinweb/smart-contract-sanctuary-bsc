// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.7;

contract NFTMysteryBoxV4 is Ownable {

    uint256 private key;
    uint256 public boxPrice;
    address public BUSD;

    event OpenBox(address _address,uint256 _amount,uint256[] items,string _ref);
    event TokenRecovery(address indexed token, uint256 amount);

    mapping(uint256=>uint256[]) public boxContainer;
    mapping(uint256=>uint256[]) public legentA;
    constructor(){
        boxPrice = 150 * 10 ** 18;
        BUSD = 0x32ed57673EC8a0c6e5c4cd0c53e2d0a5be1497f9;
        legentA[0] = [1,2,3,4]; // LEGENDARY 
        legentA[1] = [5,6];  // RANK S
        boxContainer[0] = [
    7, 6, 7, 8, 8, 7, 9, 8, 8, 5, 9, 7, 9, 8, 8, 9, 10, 9, 7, 1, 9, 5, 6, 9, 10,
    7, 3, 8, 7, 7, 8, 10, 10, 2, 10, 6, 10, 9, 9, 9, 10, 7, 5, 7, 8, 10, 8, 9,
    9, 4
];

boxContainer[1] = [
    7, 8, 8, 9, 9, 7, 10, 6, 10, 8, 7, 8, 4, 10, 9, 7, 9, 6, 7, 7, 8, 10, 10, 8,
    5, 10, 9, 7, 8, 2, 9, 5, 3, 7, 6, 1, 8, 10, 8, 5, 7, 7, 8, 8, 10, 10, 9, 10,
    9, 10
];

boxContainer[2] = [
    5, 8, 7, 10, 7, 7, 1, 6, 9, 9, 7, 8, 5, 7, 9, 7, 10, 10, 8, 6, 3, 9, 7, 9,
    4, 10, 7, 8, 7, 8, 8, 10, 10, 10, 10, 6, 10, 7, 8, 10, 8, 10, 5, 8, 10, 10,
    9, 2, 9, 10
];

boxContainer[3] = [
    7, 5, 8, 3, 9, 10, 7, 10, 7, 7, 7, 8, 9, 10, 8, 4, 10, 9, 10, 1, 10, 7, 7,
    7, 6, 8, 7, 7, 6, 8, 9, 10, 5, 10, 8, 6, 8, 9, 10, 8, 10, 9, 5, 10, 2, 8, 8,
    10, 9, 9
];

boxContainer[4] = [
    8, 5, 6, 9, 9, 9, 8, 10, 1, 7, 7, 5, 8, 8, 6, 10, 10, 7, 7, 5, 9, 7, 8, 8,
    4, 8, 9, 3, 7, 7, 7, 9, 10, 9, 8, 9, 8, 2, 6, 7, 8, 7, 8, 9, 10, 10, 9, 9,
    9, 10
];

boxContainer[5] = [
    7, 8, 8, 5, 9, 6, 9, 8, 8, 8, 8, 9, 1, 10, 10, 6, 10, 8, 7, 7, 8, 8, 5, 10,
    10, 10, 9, 4, 9, 9, 7, 7, 10, 3, 8, 8, 8, 7, 7, 8, 5, 2, 10, 7, 7, 9, 8, 6,
    7, 9
];

boxContainer[6] = [
    8, 7, 4, 7, 7, 8, 9, 6, 5, 9, 3, 10, 8, 6, 8, 9, 9, 7, 5, 1, 7, 7, 8, 9, 8,
    8, 7, 7, 8, 8, 8, 9, 2, 7, 9, 7, 8, 5, 8, 9, 9, 9, 9, 9, 10, 8, 8, 6, 10,
    10
];

boxContainer[7] = [
    6, 5, 7, 8, 8, 8, 8, 7, 8, 8, 10, 9, 6, 7, 9, 8, 8, 9, 10, 2, 7, 9, 9, 1, 8,
    8, 3, 5, 9, 7, 7, 8, 10, 10, 7, 7, 9, 7, 9, 10, 6, 10, 10, 9, 5, 9, 7, 9, 9,
    4
];

boxContainer[8] = [
    9, 9, 9, 9, 8, 9, 9, 9, 4, 8, 10, 10, 9, 5, 8, 9, 6, 9, 9, 2, 8, 7, 10, 6,
    10, 8, 6, 10, 7, 7, 9, 5, 3, 7, 1, 7, 7, 9, 9, 9, 7, 7, 10, 7, 5, 7, 10, 10,
    10, 10
];

boxContainer[9] = [
    8, 8, 8, 6, 9, 7, 7, 9, 7, 7, 9, 7, 6, 7, 4, 10, 7, 5, 7, 10, 7, 7, 10, 8,
    10, 8, 10, 2, 10, 10, 10, 5, 10, 5, 9, 9, 9, 10, 10, 3, 1, 10, 10, 10, 6,
    10, 10, 10, 10, 10
];

    /* VIP Box Only for x5 and x10 purchases after 0-9 Box are out of Rank NFT and Rank S */
boxContainer[10] = [
    1, 2, 3, 4, 3, 2, 1, 4, 2, 4, 5, 6, 5, 6, 5, 6, 5, 5, 6, 6, 5, 6, 5, 6,
    6, 5, 6, 5, 6, 6, 5, 5, 6, 5, 6, 5, 6, 6, 5, 6, 6, 5, 5, 6, 5,
    6, 5, 6, 5, 5
];

    }

    /* REMOVE IN PRODUCTION */
    function getBox(uint256 _boxNum) external view returns(uint256[] memory) {
        return boxContainer[_boxNum];
    }

    /* REMOVE IN PRODUCTION */
    function getBoxLength(uint256 _boxNum) external view returns(uint256) {
        return boxContainer[_boxNum].length;
    }

    /* fhunn: Able to return 0 when not found an element
    /* fhunn: able to find in boxContainer[10] for x5 and x10 purchases only
    /* CHANGE TO PRIVATE IN PRODUCTION */
    function findId(uint256[] memory _legentA)public returns(uint256 result) {
        for(uint256 i = 0; i < 11 ; i++){
            for(uint256 j = 0; j < boxContainer[i].length ; j++){
                for(uint256 k = 0; k < _legentA.length ; k++){
                    if (boxContainer[i][j] == _legentA[k]){

                        uint256[] memory _box = boxContainer[i]; 
                        result = boxContainer[i][j];
                        for (uint256 l = j; l < _box.length - 1; l++){
                            _box[l] = _box[l + 1];
                        }
                        delete _box[_box.length-1];
                        boxContainer[i] = _box;
                        boxContainer[i].pop();
                        return result;

                    }
                }
            }
        }

    }

    function random(uint256 _amt) internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _amt, key)));
    }

     /* CHANGE TO EXTERNAL IN PRODUCTION */
    function randomBox(uint256 _amt,string memory _ref) public returns(uint256[] memory){
        require (_amt <= 10 , "Over Maximum Limit");
        require (boxContainer[9].length > 0 , "Sold Out!");

        bool soldOut = false;
        IERC20(BUSD).transferFrom(msg.sender, address(this), boxPrice * _amt);
        uint256 _num;
        uint256[] memory result = new uint256[](_amt);
        _amt < 5 ? _num =_amt : _num = _amt - 1;

        for(uint256 x = 0; x < 10; x++){
            if (boxContainer[x].length > _num-1){
                uint256 index;
                uint256[] memory _box = boxContainer[x]; 

                for(uint256 i = 0; i < _num ; i++){
                    index = random(i) % (_box.length-i);
                    result[i] = _box[index];
                    for (uint256 j = index; j < _box.length - 1; j++){
                        _box[j] = _box[j + 1];
                    }
                    delete _box[_box.length-1];
                }

                boxContainer[x] = _box;
                for(uint256 k = 0; k < _num ; k++){
                    boxContainer[x].pop();
                }
                soldOut = true;
                break;
            }
        }
        if(_amt == 10){
            result[_amt-1] = findId(legentA[0]);
        } else if(_amt >= 5){
            result[_amt-1] = findId(legentA[1]);
            
        }

        require(soldOut , "Insufficient Boxes amount.");
        require (result[_amt-1] !=0 ,"Out of garuntee items.");
        emit OpenBox(msg.sender, _amt, result, _ref);
        return result;
    }

    function setKey(uint256 _key) external onlyOwner {
        key = _key;
    }

    function setBoxPrice(uint256 _price) external onlyOwner {
        boxPrice = _price;
    }

    function setBUSD(address _busd) external onlyOwner {
        BUSD = _busd;
    }

    function recoverToken(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(address(msg.sender), _amount);
        emit TokenRecovery(_token, _amount);
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
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