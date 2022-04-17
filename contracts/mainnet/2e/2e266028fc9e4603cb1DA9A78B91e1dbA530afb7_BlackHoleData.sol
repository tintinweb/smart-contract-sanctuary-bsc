/**
 *Submitted for verification at BscScan.com on 2022-04-17
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

// File: contracts/blackhole.sol


pragma solidity ^0.8.0;
pragma abicoder v2;


interface IsBHO {
    function balanceOf(address account) external view returns (uint256);

    function gonsForBalance(uint amount) external view returns (uint);

    function balanceForGons(uint amount) external view returns (uint);
}

interface IBHO {
    function balanceOf(address account) external view returns (uint256);
}

interface IBlackholeSupport {

    function getAllTeamLeaders() external view returns (address [] memory);

    function userStakingAmount(address _userAddress, address tokenAddress) external view returns (uint);

    function userBondAmount(address _userAddress, address tokenAddress) external view returns (uint);

    function bondOfTeam(address _userAddress, address tokenAddress) external view returns (uint);

    function tokenOfTeam(address _address) external view returns (uint);

    function burnOfTeam(address _userAddress, address tokenAddress) external view returns (uint);

}


// BlackHole Referral And Donate Function
contract BlackHoleData is Ownable {
    uint public  recordId;

    struct TeamInfo {
        address teamAddress;
        uint BHOAmount;
        uint sBHOAmount;
        uint[] bondAmount;
        uint[] burnAmount;
        address[] bondAddress;
        string[] bondName;
        uint referrealNumber;
    }

    struct UserInfo {
        address userAddress;
        uint BHOAmount;
        uint sBHOAmount;
    }

    address[] public bondAddress;
    address public BHOAddress;
    address public sBHOAddress;
    string[] public bondName;
    address public supportAddress;
    IBlackholeSupport public support;
    IBHO public BHO;
    IsBHO public sBHO;

    constructor(
        address _bhoAddress,
        address _sbhoAddress,
        address _supportAddress
    ) {
        BHOAddress = _bhoAddress;
        sBHOAddress = _sbhoAddress;
        supportAddress = _supportAddress;
        support = IBlackholeSupport(_supportAddress);
        BHO = IBHO(_bhoAddress);
        sBHO = IsBHO(_sbhoAddress);
    }

    function addBondAddress(address _address, string memory _bondName) public onlyOwner {
        bondAddress.push(_address);
        bondName.push(_bondName);
    }

    function getAllTeamInfo() public view returns (TeamInfo []memory){
        address[] memory teamAddress = support.getAllTeamLeaders();
        TeamInfo[] memory infos = new TeamInfo[](teamAddress.length);
        for (uint i = 0; i < teamAddress.length; i++) {
            infos[i].teamAddress = teamAddress[i];
            infos[i].BHOAmount = support.bondOfTeam((teamAddress[i]), BHOAddress);
            infos[i].sBHOAmount = sBHO.balanceForGons(support.bondOfTeam(teamAddress[i], sBHOAddress));
            infos[i].bondAddress = bondAddress;

            uint[] memory _bondAmount = new uint[](bondAddress.length);

            for (uint j = 0; j < bondAddress.length; j++) {
                _bondAmount[j] = support.bondOfTeam(
                    teamAddress[i], bondAddress[j]
                );
            }

            infos[i].bondAmount = _bondAmount;


            uint[] memory _burnAmount = new uint[](bondAddress.length);

            for (uint j = 0; j < bondAddress.length; j++) {
                _burnAmount[j] = support.burnOfTeam(
                    teamAddress[i], bondAddress[j]
                );
            }
            infos[i].burnAmount = _burnAmount;
            infos[i].bondName = bondName;
        }
        return infos;
    }


    function getUserHoldingInfo(address [] memory _users) public view returns (UserInfo [] memory){
        UserInfo[] memory infos = new UserInfo[](_users.length);
        for (uint i = 0; i < _users.length; i++) {
            infos[i].userAddress = _users[i];
            infos[i].BHOAmount = support.userStakingAmount(_users[i], BHOAddress);
            infos[i].sBHOAmount = sBHO.balanceForGons(support.userStakingAmount(_users[i], sBHOAddress));
        }
        return infos;
    }
}