// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/*
████████╗██╗████████╗██╗███╗░░░███╗██╗████████╗██╗
╚══██╔══╝██║╚══██╔══╝██║████╗░████║██║╚══██╔══╝██║
░░░██║░░░██║░░░██║░░░██║██╔████╔██║██║░░░██║░░░██║
░░░██║░░░██║░░░██║░░░██║██║╚██╔╝██║██║░░░██║░░░██║
░░░██║░░░██║░░░██║░░░██║██║░╚═╝░██║██║░░░██║░░░██║
░░░╚═╝░░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░░╚═╝░░░╚═╝
*/
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IContracts_TITIMITI.sol";
import "./ITrue_chest.sol";

contract True_chest is Ownable, Pausable, ITrue_chest { 
    IContracts_TITIMITI Contr;

constructor () {
    Contr=IContracts_TITIMITI(0xB9b84a5bd43FAE99e55bF3374ddB9E206150b538);
}

mapping (address => mapping (uint256 => uint256)) public chest1;
mapping (address => mapping (uint256 => uint256)) public chest2;
mapping (address => mapping (uint256 => uint256)) public chest3;
mapping (address => mapping (uint256 => uint256)) public chest4;
mapping (address => mapping (uint256 => uint256)) public chest5;
mapping (address => mapping (uint256 => uint256)) public chest6;
mapping (address => mapping (uint256 => uint256)) public chest7;
mapping (address => mapping (uint256 => uint256)) public chest8;
mapping (address => mapping (uint256 => uint256)) public chest9;
mapping (address => mapping (uint256 => uint256)) public chest10;
mapping (address => uint256) public detail;

//address_track_chest_numchest
mapping (address => mapping (uint256 => mapping (uint256 => mapping (uint256=>uint256)))) public LuckPlayer;

function Get_LavelPlayer (address adr,uint256 num_track, uint256 num_chest,uint256 Num) 
public virtual override view  returns (uint256) {
    return  LuckPlayer[adr][num_track][num_chest][Num];
}

function Get_LevelPlayer_num (address adr,uint256 num_track, uint256 num_chest) 
public virtual override view  returns (uint256) {
     return  LuckPlayer[adr][num_track][num_chest][Get_chest(adr, num_track, num_chest)];
}

function Get_detail (address adr)  public virtual override view  returns (uint256) {
    return  detail[adr];
}
function T_detail (address adr) external onlyOwner {
     detail[adr]++;
}
function take_detail (uint256 num,address adr) public virtual override {
    require(msg.sender == Contr.getZoomLoupe());
    require( detail[adr] >= num);
     detail[adr] =  detail[adr]-num;
}


function Get_chest (address adr,uint256 num_track, uint256 num_chest) public virtual override view  returns (uint256) {
    uint256 num;
    if (num_chest == 1) {
        num= chest1[adr][num_track];
    }
    if (num_chest == 2) {
       num= chest2[adr][num_track];
    }
    if (num_chest == 3) {
       num= chest3[adr][num_track];
    }
    if (num_chest == 4) {
    num= chest4[adr][num_track];
    }
    if (num_chest == 5) {
        num= chest5[adr][num_track];
    }
    if (num_chest == 6) {
       num= chest6[adr][num_track];
    }
    if (num_chest == 7) {
        num= chest7[adr][num_track];
    }
    if (num_chest == 8) {
        num= chest8[adr][num_track];
    }
    if (num_chest == 9) {
        num= chest9[adr][num_track];
    }
    if (num_chest == 10) {
        num= chest10[adr][num_track];
    }
    return num;
}

function Take_chest (uint256 num_track, uint256 num_chest,address adr) public virtual override {
    require(msg.sender == Contr.getZoomLoupe());
    LuckPlayer[adr][num_track][num_chest][Get_chest(adr, num_track, num_chest)]=0;
    if (num_chest == 1) {
    require(chest1[adr][num_track]>=1);
    chest1[adr][num_track]--;
    }
    if (num_chest == 2) {
        require(chest2[adr][num_track]>=1);
    chest2[adr][num_track]--;
    }
    if (num_chest == 3) {
        require(chest3[adr][num_track]>=1);
    chest3[adr][num_track]--;
    }
    if (num_chest == 4) {
        require(chest4[adr][num_track]>=1);
    chest4[adr][num_track]--;
    }
    if (num_chest == 5) {
        require(chest5[adr][num_track]>=1);
    chest5[adr][num_track]--;
    }
    if (num_chest == 6) {
        require(chest6[adr][num_track]>=1);
    chest6[adr][num_track]--;
    }
    if (num_chest == 7) {
        require(chest7[adr][num_track]>=1);
    chest7[adr][num_track]--; 
    }
    if (num_chest == 8) {
        require(chest8[adr][num_track]>=1);
    chest8[adr][num_track]--;
    }
    if (num_chest == 9) {
        require(chest9[adr][num_track]>=1);
    chest9[adr][num_track]--;
    }
    if (num_chest == 10) {
        require(chest10[adr][num_track]>=1);
    chest10[adr][num_track]--;
    }
}

function T_chest (address adr, uint256 num_track, uint256 num_chest, uint256 LuckPlayer_ ) external onlyOwner{
    if (num_chest == 1) {
        chest1[adr][num_track]++;
    }
    if (num_chest == 2) {
    chest2[adr][num_track]++;
    }
    if (num_chest == 3) {
       chest3[adr][num_track]++;
    }
    if (num_chest == 4) {
    chest4[adr][num_track]++;
    }
    if (num_chest == 5) {
        chest5[adr][num_track]++;
    }
    if (num_chest == 6) {
       chest6[adr][num_track]++;
    }
    if (num_chest == 7) {
        chest7[adr][num_track]++;
    }
    if (num_chest == 8) {
        chest8[adr][num_track]++;
    }
    if (num_chest == 9) {
        chest9[adr][num_track]++;
    }
    if (num_chest == 10) {
        chest10[adr][num_track]++;
    }
    LuckPlayer[adr][num_track][num_chest][Get_chest(adr, num_track, num_chest)]=LuckPlayer_;
}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ITrue_chest {

function Get_detail (address adr)  external view  returns (uint256);
function take_detail (uint256 num,address adr) external;    

function Take_chest (uint256 num_track, uint256 num_chest,address adr) external;
function Get_chest (address adr,uint256 num_track, uint256 num_chest) external view  returns (uint256);

function Get_LavelPlayer (address adr,uint256 num_track, uint256 num_chest,uint256 Num) 
external view  returns (uint256);

function Get_LevelPlayer_num (address adr,uint256 num_track, uint256 num_chest) 
external view  returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IContracts_TITIMITI {
    function getZoomLoupe() external view returns (address);
    function getMining() external view returns (address);
    function getLandLord() external view returns (address);
    function getFundNFTA() external view returns (address);
    function getBurn() external view returns (address);
    function getStock() external view returns (address);
    function getTeam() external view returns (address);
    function getCashback() external view returns (address);
    function getRsearchers() external view returns (address);
    function getDev() external view returns (address);
    function getMiningPool() external view returns (address);
    function getTitifund() external view returns (address);
    function getMINT_GNFT() external view returns (address);
    function getMiticoin() external view returns (address);
    function getDetails() external view returns (address);
    function getdis() external view returns (address);
    function getBasic_info() external view returns (address);
    function getCollections() external view returns (address);
    function getNFTO() external view returns (address);
    function getNFTA() external view returns (address);
    function getSkillUP() external view returns (address);
    function getTake() external view returns (address);
    function getTrue_chest() external view returns (address);
    function getPrice() external view returns (address);
    function getInvest() external view returns (address);
    function getSaleMITI() external view returns (address);
    function getStaking() external view returns (address);
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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