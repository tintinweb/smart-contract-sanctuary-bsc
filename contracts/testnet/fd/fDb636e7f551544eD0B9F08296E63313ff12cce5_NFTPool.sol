/**
 *Submitted for verification at BscScan.com on 2022-05-09
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

// File: EKA2/NFTPool.sol


pragma solidity ^0.8.1;


interface IEKA {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
}

interface INFTFactory {
    function allNFTs(uint256 i) external view returns (address);
    function allNFTsLength() external view returns (uint256);
}

interface INFT {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function getPower(uint256 tokenId) external view returns(uint256);
    function reducePower(uint256 tokenId) external;
}

contract NFTPool is Ownable {

    address public immutable ekaAddress;
    address public immutable nftFactoryAddress;
    address public adminAddress;

    uint256 savingValue = 0;

    //PreAllocation
    uint256 public dividingTime = 1649664000;
    mapping(uint256 => uint256) public poolInfo; 
    event ReceiveEka(uint256 indexed amount, uint256 indexed power);
    event PreAllocation(uint256 indexed time, uint256 indexed amount);

    //StakeInfo
    struct StakeInfo {
        address nftOwner;
        uint256 withdrawableBalance;
    }
    mapping(address => mapping(uint256 => StakeInfo)) public stakeInfo; //[nftAddress][tokenId]

    struct StakeIndex {
        address nftAddress;
        uint256 tokenId;
    }
    StakeIndex[] public stakeList;
    mapping(bytes32 => bool) inStakeList;// (hash(nftAddress, tokenId)) => bool


    constructor(address eka_, address nftFactory_, address admin_) {
        ekaAddress = eka_;
        nftFactoryAddress = nftFactory_;
        adminAddress = admin_;
    }

    //data
    //=============================================================
    function setAdminAddress(address admin_) public onlyOwner {
        adminAddress = admin_;
    }

    function setDividingTime(uint256 time) public onlyOwner {
        dividingTime = time;
    }

    //PreAllocation
    function receiveEka(uint256 amount, uint256 power) public {
        savingValue += amount;
        uint256 balance = IEKA(ekaAddress).balanceOf(address(this));
        require(IEKA(ekaAddress).transferFrom(msg.sender, address(this), amount), "eka transfer fail");
        if ((IEKA(ekaAddress).totalSupply()-amount) > 10**7 * 1e18) {
            if (savingValue < balance) {
                IEKA(ekaAddress).burn(amount);
            }
        }

        uint256 day = 60*60*24;
        uint256 current = block.timestamp;
        while (dividingTime < current) {
            dividingTime += day;
        }

        uint256 m = (power*(power+1))/2;
        uint256 total = 0;
        for(uint256 i = 0; i < power; i++) {
            uint256 slot;
            if (i == power-1) {
                slot = amount - total;
            } else {
                slot = (amount * (power-i))/m;
            }
            
            uint256 time = dividingTime + i*day;
            uint256 oldAmount = poolInfo[time];
            poolInfo[time] = oldAmount + slot;

            total += slot;

            emit PreAllocation(time, slot);
        }
        emit ReceiveEka(amount, power);
    }

    //stake
    function stake(uint256 idx, uint256 tokenId) public {
        address nftAddress = INFTFactory(nftFactoryAddress).allNFTs(idx);
        require(tokenId > 0, 'tokenId must > 0');
        

        INFT(nftAddress).transferFrom(msg.sender, address(this), tokenId);
        stakeInfo[nftAddress][tokenId] = StakeInfo(msg.sender, 0);

        bytes32 key = keccak256(abi.encodePacked(nftAddress, tokenId, idx));
        if (!inStakeList[key]) {
            inStakeList[key] = true;
            stakeList.push(StakeIndex(nftAddress, tokenId));
        }
    }

    function withdraw(uint256 idx, uint256 tokenId) public {
        address nftAddress = INFTFactory(nftFactoryAddress).allNFTs(idx);
        
        StakeInfo memory info = stakeInfo[nftAddress][tokenId];
        require(info.nftOwner == msg.sender, "not your token");
        uint256 power = INFT(nftAddress).getPower(tokenId);
        require(power == 0, "power > 0");

        INFT(nftAddress).transferFrom(address(this), msg.sender, tokenId);
        userSettlement(idx, tokenId);

        delete stakeInfo[nftAddress][tokenId];
    }

    //settlement
    function adminSettlement(uint256 time) public {
        require(msg.sender == adminAddress, "not admin");

        uint256 totalEka = poolInfo[time];
        poolInfo[time] = 0;

        uint256 totalPower = 0;
        for(uint256 i=0; i<stakeList.length; i++) {
            StakeIndex memory index = stakeList[i];
            StakeInfo memory info = stakeInfo[index.nftAddress][index.tokenId];
            if (info.nftOwner != address(0)) {
                totalPower += INFT(index.nftAddress).getPower(index.tokenId);
            }
        }

        for(uint256 i=0; i<stakeList.length; i++) {
            StakeIndex memory index = stakeList[i];
            StakeInfo memory info = stakeInfo[index.nftAddress][index.tokenId];
            if (info.nftOwner != address(0)) {
                uint256 nftPower = INFT(index.nftAddress).getPower(index.tokenId);
                INFT(index.nftAddress).reducePower(index.tokenId);

                uint256 increment = (totalEka * nftPower)/totalPower;
                stakeInfo[index.nftAddress][index.tokenId] = StakeInfo(info.nftOwner, info.withdrawableBalance+increment);
            }
        }
        
    }

    function userSettlement(uint256 idx, uint256 tokenId) public {
        address nftAddress = INFTFactory(nftFactoryAddress).allNFTs(idx);

        StakeInfo memory info = stakeInfo[nftAddress][tokenId];
        require(info.nftOwner == msg.sender, 'not your token');
        require(IEKA(ekaAddress).transfer(info.nftOwner, info.withdrawableBalance), 'eka transfer fail');
        require(savingValue >= info.withdrawableBalance, 'data error');

        savingValue -= info.withdrawableBalance;
        stakeInfo[nftAddress][tokenId] = StakeInfo(info.nftOwner, 0);
    }
}