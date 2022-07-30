// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Register is Ownable {

    mapping(address => bool) public registerAdd;
    mapping(address => address) public sponsorAdd;
    mapping(address => address[]) public childAdds;

    bool public _pause;
    
    constructor()  {
        
    }

    function registerWithoutSponsor() external payable {
        require(!_pause, "Register Paused!");
        require(msg.value >= 0.18 ether, "Insufficient funds.");
        require(!registerAdd[msg.sender], "Duplicated Address.");
        registerAdd[msg.sender] = true;
    }

    function registerWithSponsor(address _sponsorAdd) external payable {
        require(!_pause, "Register Paused!");
        require(msg.value >= 0.06 ether, "Insufficient funds.");
        require(!registerAdd[msg.sender], "Duplicated Address.");

        registerAdd[msg.sender] = true;
        sponsorAdd[msg.sender] = _sponsorAdd;
        childAdds[_sponsorAdd].push(msg.sender);
    }

    function getDownline(address _add) public view returns(
                                        uint256 first_level, 
                                        uint256 second_level, 
                                        uint256 third_level, 
                                        uint256 forth_level){

        first_level = 0;
        second_level = 0;
        third_level = 0;
        forth_level = 0;

        address _ownAdd = _add;
        address[] memory allFirstLevels = childAdds[_ownAdd];
        first_level = allFirstLevels.length;
        for(uint256 i = 0; i < allFirstLevels.length; i++) {
            address[] memory secondChilds = childAdds[allFirstLevels[i]];
            second_level += secondChilds.length;
            for(uint256 j = 0; j < secondChilds.length; j++) {
                address[] memory thirdChilds = childAdds[secondChilds[j]];
                third_level += thirdChilds.length;
                for(uint256 k = 0; k < thirdChilds.length; k++) {
                    address[] memory forthChilds = childAdds[thirdChilds[k]];
                    forth_level += forthChilds.length;
                }
            }
        }
    }

    function getGenealogicalTree(address _add) public view returns(
                                        address[] memory first_level, 
                                        address[] memory second_level, 
                                        address[] memory third_level, 
                                        address[] memory forth_level){

        address _ownAdd = _add;
        (, uint256 level2Cnt, uint256 level3Cnt, uint256 level4Cnt) = getDownline(_ownAdd);
        first_level = childAdds[_ownAdd];
        second_level = new address[](level2Cnt);
        second_level = new address[](level2Cnt);
        third_level = new address[](level3Cnt);
        forth_level = new address[](level4Cnt);
        
        for(uint256 i = 0; i < first_level.length; i++) {
            address[] memory secondChilds = childAdds[first_level[i]];
            for(uint256 j = 0; j < secondChilds.length; j++) {
                second_level[i * secondChilds.length + j] = secondChilds[j];
                address[] memory thirdChilds = childAdds[secondChilds[j]];
                for(uint256 k = 0; k < thirdChilds.length; k++) {
                    third_level[j * thirdChilds.length + k] = thirdChilds[k];
                    address[] memory forthChilds = childAdds[thirdChilds[k]];
                    for(uint256 l = 0; l < forthChilds.length; l++) {
                        forth_level[k * forthChilds.length + l] = forthChilds[l];
                    }
                }
            }
        }
    }

    function pause(bool _flag) public onlyOwner() {
        _pause = _flag;
    }

    function withdraw() public onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }
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